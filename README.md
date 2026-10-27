# roblox-bench-suite

Private bench plates:

- **Bee Swarm Simulator** full Lua cheat
- **Lumber Tycoon 2** full Lua cheat
- **Modern external executor** skeleton (C++ ImGui + pipe + payload)
- **Hyperion / Byfron** bypass craft notes (2026-2027 reality)

## Presentation site

Open the static presentation:

- Local: open `docs/index.html`
- GitHub Pages: enable Pages on the `docs` folder (Settings → Pages → Deploy from branch → `/docs`)

## 2026 / 2027 status

| Component | Status |
|-----------|--------|
| Game scripts (BSS / LT2) | Working (re-spy remotes after updates) |
| Executor UI + pipe | Working |
| Classic LoadLibrary | Dead |
| Public mappers | Dead / short life |
| Private syscall + stomp + stack spoof | Viable with maintenance |
| Luau scheduler core | Viable with maintenance |

Public methods die fast. The private baseline described in `docs/hyperion_bypass.md` is what still lands. Keep the private modules updated after every Roblox client change.

**Use at your own risk. Private repo.**
