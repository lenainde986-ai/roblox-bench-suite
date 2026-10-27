# roblox-bench-suite

Private functional suite for late 2026.

## Quick Start (recommended)

1. Get a current high-sUNC executor:
 - **Best overall right now:** Volt (Hyperion emulation) or Potassium (lifetime)
 - Solid free: Solara / Xeno / Madium
2. Join Bee Swarm Simulator or Lumber Tycoon 2
3. Execute the matching script from `/cheats`

## Contents

```
cheats/
  bee_swarm_simulator.lua   ← full auto farm + ESP + movement
  lumber_tycoon_2.lua       ← auto chop/sell + fly + ESP
executor/
  ModernExecutor.cpp        ← ImGui external shell
  ModernExecPayload.cpp     ← payload skeleton
docs/
  CURRENT_STATUS.md         ← October 2026 live ranking
  hyperion_bypass.md        ← current private craft notes
  index.html                ← presentation site
```

## October 2026 Status

| Component | Status |
|---------|--------|
| BSS / LT2 scripts | Functional on Volt / Potassium / Wave / Solara / Xeno |
| Classic public inject | Dead |
| Hyperion emulation (Volt-style) | Currently strongest public-facing approach |
| Fully private core | Still requires maintained private modules |

See `docs/CURRENT_STATUS.md` for the full live picture.

**Always use an alt. Nothing is permanently safe.**
