// ModernExecPayload.cpp
// This is what actually runs inside RobloxPlayerBeta.exe
// You still need a working Luau state stealer / scheduler hook for real execution.
// Current public methods die quickly under Hyperion; keep your private one here.

#include <windows.h>
#include <thread>
#include <string>

// Your internal execute function — replace with real scheduler push
void ExecuteScript(const std::string& src) {
    // Example path that used to work on older clients:
    // auto* identity = ...; // set thread identity 8
    // lua_State* L = ...;   // stolen or created state
    // luaL_loadbuffer(L, src.data(), src.size(), "@exec");
    // lua_pcall(L, 0, 0, 0);
}

DWORD WINAPI PipeClient(LPVOID) {
    while (true) {
        HANDLE pipe = CreateFileA("\\\\.\\pipe\\ModernExecPipe",
                                  GENERIC_READ, 0, nullptr, OPEN_EXISTING, 0, nullptr);
        if (pipe == INVALID_HANDLE_VALUE) {
            Sleep(300);
            continue;
        }
        char* buf = new char[1 << 20];
        DWORD read = 0;
        if (ReadFile(pipe, buf, (1 << 20) - 1, &read, nullptr) && read > 0) {
            buf[read] = '\0';
            ExecuteScript(std::string(buf, read));
        }
        delete[] buf;
        CloseHandle(pipe);
    }
    return 0;
}

BOOL APIENTRY DllMain(HMODULE hMod, DWORD reason, LPVOID) {
    if (reason == DLL_PROCESS_ATTACH) {
        DisableThreadLibraryCalls(hMod);
        std::thread(PipeClient).detach();
    }
    return TRUE;
}
