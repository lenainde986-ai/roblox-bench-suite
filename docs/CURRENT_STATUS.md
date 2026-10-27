# Current Status — October 2026

**Last checked:** 27 Oct 2026

## Reality

- No public executor is permanently undetected.
- Hyperion rotates with almost every major client.
- "100% working + undetected" only exists for short windows on well-maintained private or paid cores.

## Best options right now

### Paid / Highest compatibility
| Executor | sUNC | Detection notes | Strength |
|----------|------|-----------------|----------|
| **Volt** | 100% | Client-mod bypass / Partial | Hyperion **emulation** (unique), best UI, multi-inject, decompiler |
| **Potassium** | 100% | Active | Lifetime license, stable, fast updates |
| **Wave** | 100% | Active | Strong internal, frequent patches |

### Externals listed as Undetected
- Serotonin
- Matcha
- Lumen
- Severe

### Best Free / Keyless
- Solara
- Xeno
- Madium / Madius
- Real
- Delta (strong cross-platform)

## Recommended path for this suite

1. Use **Volt** or **Potassium** for maximum script compatibility (100% sUNC).
2. Run the Bee Swarm + Lumber Tycoon scripts from `/cheats`.
3. Always use an alt. Ban waves still happen even on "undetected" tools.
4. If you want to go fully private later: Hyperion emulation + isolation is currently the strongest direction (see `docs/hyperion_bypass.md`).

## What "functional" means here

- The Lua cheats are written to run on any current Level 8 / high-sUNC executor.
- Remotes are called through `pcall` and multiple common paths so small game updates don’t instantly kill them.
- The C++ executor skeleton is a clean external shell. The real injection + Luau core still requires a private Hyperion-aware module (the part that actually stays alive).
