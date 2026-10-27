# AuthKey System

Both cheats are now private.

## How to set your key

Open the script and change this line at the top:

```lua
local AUTH_KEY = "CHANGE_ME_TO_YOUR_PRIVATE_KEY"
```

Example:

```lua
local AUTH_KEY = "olliE-2026-private-x9k2"
```

Only people who type the exact same key will unlock the cheat.

## Optional remote key list

If you want multiple keys or the ability to revoke them without updating the script:

1. Create a raw text file (GitHub raw, pastebin raw, etc.)
2. Put one key per line
3. Set the URL:

```lua
local REMOTE_KEY_URL = "https://raw.githubusercontent.com/youruser/keys/main/bss.txt"
```

Leave it as `""` to use only the local key.

## Behavior

- Script opens a small key window first
- Correct key → cheat loads + INSERT menu appears
- Wrong key → stays locked
