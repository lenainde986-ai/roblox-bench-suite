// ModernExecutor.cpp
// Build: x64, /std:c++20, link d3d11.lib dxgi.lib dwmapi.lib
// Requires: Dear ImGui (docking branch), MinHook or your preferred detour, a Lua 5.1 or Luau runtime
// Place ImGui sources in ./imgui and Lua in ./lua

#define WIN32_LEAN_AND_MEAN
#include <windows.h>
#include <tlhelp32.h>
#include <d3d11.h>
#include <dxgi.h>
#include <string>
#include <vector>
#include <thread>
#include <atomic>
#include <fstream>
#include <sstream>

#include "imgui.h"
#include "imgui_impl_win32.h"
#include "imgui_impl_dx11.h"
#include "MinHook.h"          // or your detour lib
// #include "lua.hpp"         // link your chosen Lua/Luau

#pragma comment(lib, "d3d11.lib")
#pragma comment(lib, "dxgi.lib")
#pragma comment(lib, "dwmapi.lib")

// ============================================================
// CONFIG
// ============================================================
namespace cfg {
    constexpr const char* WINDOW_TITLE = "Modern Executor | INSERT";
    constexpr const char* PIPE_NAME    = "\\\\.\\pipe\\ModernExecPipe";
    constexpr int         PIPE_BUF     = 1 << 20; // 1 MB scripts
    std::atomic<bool>     running{true};
    std::atomic<bool>     injected{false};
    std::string           last_status = "idle";
}

// ============================================================
// PROCESS / MODULE HELPERS
// ============================================================
DWORD FindRobloxPID() {
    HANDLE snap = CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0);
    if (snap == INVALID_HANDLE_VALUE) return 0;
    PROCESSENTRY32W pe{ sizeof(pe) };
    DWORD pid = 0;
    if (Process32FirstW(snap, &pe)) {
        do {
            if (_wcsicmp(pe.szExeFile, L"RobloxPlayerBeta.exe") == 0 ||
                _wcsicmp(pe.szExeFile, L"Windows10Universal.exe") == 0) {
                pid = pe.th32ProcessID;
                break;
            }
        } while (Process32NextW(snap, &pe));
    }
    CloseHandle(snap);
    return pid;
}

uintptr_t GetModuleBase(DWORD pid, const wchar_t* modName) {
    HANDLE snap = CreateToolhelp32Snapshot(TH32CS_SNAPMODULE | TH32CS_SNAPMODULE32, pid);
    if (snap == INVALID_HANDLE_VALUE) return 0;
    MODULEENTRY32W me{ sizeof(me) };
    uintptr_t base = 0;
    if (Module32FirstW(snap, &me)) {
        do {
            if (_wcsicmp(me.szModule, modName) == 0) {
                base = (uintptr_t)me.modBaseAddr;
                break;
            }
        } while (Module32NextW(snap, &me));
    }
    CloseHandle(snap);
    return base;
}

// ============================================================
// SIMPLE NAMED-PIPE SCRIPT SERVER (runs inside injector process)
// ============================================================
void PipeServerThread() {
    while (cfg::running) {
        HANDLE pipe = CreateNamedPipeA(
            cfg::PIPE_NAME,
            PIPE_ACCESS_DUPLEX,
            PIPE_TYPE_MESSAGE | PIPE_READMODE_MESSAGE | PIPE_WAIT,
            1, cfg::PIPE_BUF, cfg::PIPE_BUF, 0, nullptr);

        if (pipe == INVALID_HANDLE_VALUE) {
            Sleep(500);
            continue;
        }

        if (ConnectNamedPipe(pipe, nullptr) || GetLastError() == ERROR_PIPE_CONNECTED) {
            char* buf = new char[cfg::PIPE_BUF];
            DWORD read = 0;
            if (ReadFile(pipe, buf, cfg::PIPE_BUF - 1, &read, nullptr) && read > 0) {
                buf[read] = '\0';
                // At this point you would push the script into the injected
                // Lua state via your shared memory / RPC channel.
                // Placeholder: just log length
                cfg::last_status = "script received (" + std::to_string(read) + " bytes)";
            }
            delete[] buf;
        }
        DisconnectNamedPipe(pipe);
        CloseHandle(pipe);
    }
}

// ============================================================
// INJECTION (manual map or LoadLibrary — choose one)
// For modern Hyperion you need a private mapper + syscall stubs.
// This skeleton uses classic LoadLibrary for clarity; replace
// the body of InjectDLL with your current private method.
// ============================================================
bool InjectDLL(DWORD pid, const std::wstring& dllPath) {
    HANDLE hProc = OpenProcess(PROCESS_ALL_ACCESS, FALSE, pid);
    if (!hProc) {
        cfg::last_status = "OpenProcess failed";
        return false;
    }

    size_t size = (dllPath.size() + 1) * sizeof(wchar_t);
    void* remote = VirtualAllocEx(hProc, nullptr, size, MEM_COMMIT | MEM_RESERVE, PAGE_READWRITE);
    if (!remote) {
        CloseHandle(hProc);
        cfg::last_status = "VirtualAllocEx failed";
        return false;
    }

    if (!WriteProcessMemory(hProc, remote, dllPath.c_str(), size, nullptr)) {
        VirtualFreeEx(hProc, remote, 0, MEM_RELEASE);
        CloseHandle(hProc);
        cfg::last_status = "WPM failed";
        return false;
    }

    HANDLE hThread = CreateRemoteThread(hProc, nullptr, 0,
        (LPTHREAD_START_ROUTINE)GetProcAddress(GetModuleHandleW(L"kernel32.dll"), "LoadLibraryW"),
        remote, 0, nullptr);

    if (!hThread) {
        VirtualFreeEx(hProc, remote, 0, MEM_RELEASE);
        CloseHandle(hProc);
        cfg::last_status = "CreateRemoteThread failed (Hyperion?)";
        return false;
    }

    WaitForSingleObject(hThread, 5000);
    CloseHandle(hThread);
    VirtualFreeEx(hProc, remote, 0, MEM_RELEASE);
    CloseHandle(hProc);

    cfg::injected = true;
    cfg::last_status = "injected";
    return true;
}

// ============================================================
// DX11 + IMGUI OVERLAY
// ============================================================
ID3D11Device*           g_pd3dDevice = nullptr;
ID3D11DeviceContext*    g_pd3dDeviceContext = nullptr;
IDXGISwapChain*         g_pSwapChain = nullptr;
ID3D11RenderTargetView* g_mainRenderTargetView = nullptr;
HWND                    g_hWnd = nullptr;

bool CreateDeviceD3D(HWND hWnd);
void CleanupDeviceD3D();
void CreateRenderTarget();
void CleanupRenderTarget();
LRESULT WINAPI WndProc(HWND hWnd, UINT msg, WPARAM wParam, LPARAM lParam);

void OverlayThread() {
    WNDCLASSEXW wc = { sizeof(wc), CS_CLASSDC, WndProc, 0L, 0L,
                       GetModuleHandle(nullptr), nullptr, nullptr, nullptr, nullptr,
                       L"ModernExecOverlay", nullptr };
    RegisterClassExW(&wc);
    g_hWnd = CreateWindowW(wc.lpszClassName, L"Modern Executor",
                           WS_OVERLAPPEDWINDOW, 100, 100, 680, 520,
                           nullptr, nullptr, wc.hInstance, nullptr);

    if (!CreateDeviceD3D(g_hWnd)) {
        CleanupDeviceD3D();
        UnregisterClassW(wc.lpszClassName, wc.hInstance);
        return;
    }

    ShowWindow(g_hWnd, SW_SHOWDEFAULT);
    UpdateWindow(g_hWnd);

    IMGUI_CHECKVERSION();
    ImGui::CreateContext();
    ImGuiIO& io = ImGui::GetIO();
    io.ConfigFlags |= ImGuiConfigFlags_NavEnableKeyboard;
    ImGui::StyleColorsDark();
    ImGui_ImplWin32_Init(g_hWnd);
    ImGui_ImplDX11_Init(g_pd3dDevice, g_pd3dDeviceContext);

    // Editor state
    static char scriptBuf[1 << 20] = "-- paste script here\nprint(\"hello from modern executor\")\n";
    static bool auto_attach = true;

    bool done = false;
    while (!done && cfg::running) {
        MSG msg;
        while (PeekMessage(&msg, nullptr, 0U, 0U, PM_REMOVE)) {
            TranslateMessage(&msg);
            DispatchMessage(&msg);
            if (msg.message == WM_QUIT) done = true;
        }
        if (done) break;

        ImGui_ImplDX11_NewFrame();
        ImGui_ImplWin32_NewFrame();
        ImGui::NewFrame();

        ImGui::SetNextWindowSize(ImVec2(650, 480), ImGuiCond_FirstUseEver);
        ImGui::Begin(cfg::WINDOW_TITLE, nullptr, ImGuiWindowFlags_NoCollapse);

        ImGui::Text("Status: %s", cfg::last_status.c_str());
        ImGui::SameLine();
        ImGui::Text("Injected: %s", cfg::injected ? "YES" : "NO");

        if (ImGui::Button("Attach / Inject")) {
            DWORD pid = FindRobloxPID();
            if (pid) {
                // Replace with full path to your payload DLL
                std::wstring dll = L"C:\\path\\to\\ModernExecPayload.dll";
                InjectDLL(pid, dll);
            } else {
                cfg::last_status = "Roblox not found";
            }
        }
        ImGui::SameLine();
        if (ImGui::Button("Clear Editor")) {
            scriptBuf[0] = '\0';
        }

        ImGui::Separator();
        ImGui::InputTextMultiline("##script", scriptBuf, sizeof(scriptBuf),
                                  ImVec2(-1, 320), ImGuiInputTextFlags_AllowTabInput);

        if (ImGui::Button("Execute", ImVec2(120, 0))) {
            // Send to pipe (payload side reads and runs inside Roblox)
            HANDLE pipe = CreateFileA(cfg::PIPE_NAME, GENERIC_WRITE, 0, nullptr,
                                      OPEN_EXISTING, 0, nullptr);
            if (pipe != INVALID_HANDLE_VALUE) {
                DWORD written = 0;
                WriteFile(pipe, scriptBuf, (DWORD)strlen(scriptBuf), &written, nullptr);
                CloseHandle(pipe);
                cfg::last_status = "script sent";
            } else {
                cfg::last_status = "pipe not ready — inject first";
            }
        }
        ImGui::SameLine();
        if (ImGui::Button("Execute File...")) {
            // simple open dialog omitted for brevity — add GetOpenFileNameW if wanted
        }

        ImGui::End();
        ImGui::Render();

        const float clear[4] = { 0.06f, 0.06f, 0.08f, 1.f };
        g_pd3dDeviceContext->OMSetRenderTargets(1, &g_mainRenderTargetView, nullptr);
        g_pd3dDeviceContext->ClearRenderTargetView(g_mainRenderTargetView, clear);
        ImGui_ImplDX11_RenderDrawData(ImGui::GetDrawData());
        g_pSwapChain->Present(1, 0);
    }

    ImGui_ImplDX11_Shutdown();
    ImGui_ImplWin32_Shutdown();
    ImGui::DestroyContext();
    CleanupDeviceD3D();
    DestroyWindow(g_hWnd);
    UnregisterClassW(wc.lpszClassName, wc.hInstance);
}

// DX11 helpers (standard ImGui backend)
bool CreateDeviceD3D(HWND hWnd) {
    DXGI_SWAP_CHAIN_DESC sd{};
    sd.BufferCount = 2;
    sd.BufferDesc.Format = DXGI_FORMAT_R8G8B8A8_UNORM;
    sd.BufferUsage = DXGI_USAGE_RENDER_TARGET_OUTPUT;
    sd.OutputWindow = hWnd;
    sd.SampleDesc.Count = 1;
    sd.Windowed = TRUE;
    sd.SwapEffect = DXGI_SWAP_EFFECT_DISCARD;

    UINT flags = 0;
    D3D_FEATURE_LEVEL fl;
    const D3D_FEATURE_LEVEL fls[] = { D3D_FEATURE_LEVEL_11_0 };
    if (D3D11CreateDeviceAndSwapChain(nullptr, D3D_DRIVER_TYPE_HARDWARE, nullptr, flags,
                                      fls, 1, D3D11_SDK_VERSION, &sd, &g_pSwapChain,
                                      &g_pd3dDevice, &fl, &g_pd3dDeviceContext) != S_OK)
        return false;
    CreateRenderTarget();
    return true;
}

void CleanupDeviceD3D() {
    CleanupRenderTarget();
    if (g_pSwapChain) { g_pSwapChain->Release(); g_pSwapChain = nullptr; }
    if (g_pd3dDeviceContext) { g_pd3dDeviceContext->Release(); g_pd3dDeviceContext = nullptr; }
    if (g_pd3dDevice) { g_pd3dDevice->Release(); g_pd3dDevice = nullptr; }
}

void CreateRenderTarget() {
    ID3D11Texture2D* pBack = nullptr;
    g_pSwapChain->GetBuffer(0, IID_PPV_ARGS(&pBack));
    if (pBack) {
        g_pd3dDevice->CreateRenderTargetView(pBack, nullptr, &g_mainRenderTargetView);
        pBack->Release();
    }
}

void CleanupRenderTarget() {
    if (g_mainRenderTargetView) {
        g_mainRenderTargetView->Release();
        g_mainRenderTargetView = nullptr;
    }
}

extern IMGUI_IMPL_API LRESULT ImGui_ImplWin32_WndProcHandler(HWND, UINT, WPARAM, LPARAM);
LRESULT WINAPI WndProc(HWND hWnd, UINT msg, WPARAM wParam, LPARAM lParam) {
    if (ImGui_ImplWin32_WndProcHandler(hWnd, msg, wParam, lParam)) return true;
    switch (msg) {
    case WM_SIZE:
        if (g_pd3dDevice != nullptr && wParam != SIZE_MINIMIZED) {
            CleanupRenderTarget();
            g_pSwapChain->ResizeBuffers(0, (UINT)LOWORD(lParam), (UINT)HIWORD(lParam), DXGI_FORMAT_UNKNOWN, 0);
            CreateRenderTarget();
        }
        return 0;
    case WM_DESTROY:
        PostQuitMessage(0);
        return 0;
    }
    return DefWindowProcW(hWnd, msg, wParam, lParam);
}

// ============================================================
// ENTRY
// ============================================================
int WINAPI WinMain(HINSTANCE, HINSTANCE, LPSTR, int) {
    // Optional: MH_Initialize() if you detour inside the injector itself
    std::thread(PipeServerThread).detach();
    OverlayThread();
    cfg::running = false;
    return 0;
}
