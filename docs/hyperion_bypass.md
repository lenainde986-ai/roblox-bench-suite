# Byfron Hyperion detection bypass — practical craft sheet

Hyperion (Byfron’s anti-tamper on modern Roblox) is a user-mode + kernel-adjacent protector that combines:

- Integrity checks on the main module and loaded code pages
- Call-stack and return-address validation
- Syscall stub scanning and ntdll instrumentation
- Thread and handle enumeration
- Timing / heart-beat checks
- Memory scanning for known injector and mapper signatures
- Crash-on-detection with telemetry

Public methods die fast. The durable approaches all reduce to the same core: never look like a classic injector, never leave writable+executable pages that Hyperion’s scanner expects, and never return to a poisoned stack.

## 1. Injection path (highest priority)

Classic `OpenProcess` + `VirtualAllocEx` + `WriteProcessMemory` + `CreateRemoteThread` / `NtCreateThreadEx` is instantly flagged.

Working patterns that still land in 2026 private work:

- Manual mapping with section mapping + relocation + import resolution done entirely from the injector side, then a single hijacked thread or APC to the entry point. No `LoadLibrary`, no new module list entry.
- Module-stomping / known-module overwrite: map into a legitimate signed module’s unused section or a discarded page that Hyperion already trusts.
- Thread hijacking of an existing Roblox thread (suspend → set context RIP/RSP → resume) instead of creating a new thread.
- Direct syscalls for every sensitive API (`NtAllocateVirtualMemory`, `NtProtectVirtualMemory`, `NtWriteVirtualMemory`, `NtCreateThreadEx`, `NtResumeThread`). The syscall numbers must be resolved at runtime from the clean ntdll on disk or from a freshly read copy; do not call through the hooked ntdll stubs.

Skeleton for a minimal direct-syscall allocator (x64):

```cpp
// Resolve syscall number from clean ntdll on disk once at startup
uint32_t GetSyscallNumber(const char* name) {
    // map ntdll.dll from disk, parse exports, read the mov eax, imm32
    // that sits right after the function prologue in the clean file
    // return the imm32
}

extern "C" NTSTATUS SyscallNtAllocateVirtualMemory(
    HANDLE ProcessHandle,
    PVOID* BaseAddress,
    ULONG_PTR ZeroBits,
    PSIZE_T RegionSize,
    ULONG AllocationType,
    ULONG Protect);

#define SYSCALL_STUB(name, ssn) \
__asm { \
    mov r10, rcx \
    mov eax, ssn \
    syscall \
    ret \
}
```

Keep every memory allocation `PAGE_READWRITE` first, write the payload, then `NtProtectVirtualMemory` to `PAGE_EXECUTE_READ`. Never leave `PAGE_EXECUTE_READWRITE` pages.

## 2. Execution core (the part that actually runs Lua)

Hyperion watches for:

- New executable pages that do not belong to any legitimate module
- Abnormal call stacks that cross from Roblox code into unsigned regions
- Known Luau scheduler patterns and proto structures that match public executors

Durable pattern:

- Steal or create a Luau state from inside a legitimate Roblox thread context.
- Push the script proto through the real scheduler (or a carefully recreated one that matches the current client’s calling convention and identity rules).
- Set thread identity to 8 (or whatever the current maximum is) only for the duration of the load/pcall, then restore.
- Return through a clean stack. Stack spoofing (spoof the return address to a legitimate Roblox gadget or a `ret` gadget inside a signed module) is still required for most private cores.

## 3. Hiding the footprint

- Unlink the injected image from the PEB module lists (`InLoadOrderModuleList`, `InMemoryOrderModuleList`, `InInitializationOrderModuleList`) if you must have a module entry at all. Prefer no entry.
- Wipe or never write the classic “.text + RWX” patterns that signature scanners look for.
- Avoid long-lived threads that sit in `WaitForSingleObject` or `Sleep` loops with obvious executor names or stack contents.
- Encrypt or compress the script buffer in transit; decrypt only immediately before the Luau load and zero the plaintext after.

## 4. Timing and heart-beats

Hyperion runs periodic integrity and timing checks. If your payload spends too long with the process suspended or with pages marked writable, the heart-beat fails and the client crashes or reports.

- Keep suspend windows under a few milliseconds.
- Do the heavy mapping work from an external process, then only a short hijack to start execution.
- If you hook any Roblox function, make the detour as thin as possible and restore the original bytes when not in use (or use a hardware breakpoint + VEH approach that never patches .text).

## 5. Practical build order for a private core

1. Direct-syscall memory primitives (alloc / protect / write / free / query).
2. Manual map or module-stomp loader that leaves no new module entry.
3. Thread hijack or APC entry into a known-good Roblox thread.
4. Stack-spoofing layer for every transition back into Roblox code.
5. Luau state acquisition + identity set + scheduler push.
6. Clean unload path that restores everything and zeroes traces.

## 6. What no longer works (do not waste time)

- Public LoadLibrary injectors
- Public manual mappers that still call hooked ntdll
- Any injector that creates a new thread with a start address inside an unsigned region without stack spoofing
- Writing shellcode to `PAGE_EXECUTE_READWRITE` and jumping to it
- Relying on `NtQueueApcThread` without cleaning the APC state afterwards

## 7. Testing loop

- Inject into a throw-away alt under a clean Windows install (no other cheats).
- Watch for immediate crash, delayed crash (30–120 s), or silent telemetry kick.
- If it survives 10+ minutes of normal play + script execution, the current combination is viable until the next Hyperion push.
- Re-verify after every Roblox client update; Hyperion’s signatures and checks move.

Notes  
- Everything above is the current private-craft baseline. Public proof-of-concept code that does all of it in one paste does not stay public.  
- The execution core (real Luau push) is the part that ages fastest; keep it modular so you can swap the scheduler interface when the client changes.
