# Contract: client program command line and game directory (`client` ↔ Player, Pack creator)

**Status**: frozen at plan time.

## 1. Command line (FR-010)

`cobolcraft --name <name> [--gamedir <path>]`

- `--name` is required: the offline identity, 1 to 16 characters of `A`-`Z`, `a`-`z`, `0`-`9`, `_`
  (`wire-profile.md` §1). Missing or invalid: fatal (`FATAL arguments: …`, exit 1).
- `--gamedir` defaults to `$HOME/.cobolcraft`; created if absent.

## 2. Game directory

```text
<gamedir>/
  servers.dat            gzip NBT: List `Servers` of {Name: String, Address: String, PackPolicy: Int (0 prompt, 1 enabled, 2 disabled)}  (US2-1, 08 §9.1)
  options.dat            gzip NBT: {EnabledPacks: List of String (pack ids, top first)}                                             (US18-2)
  resourcepacks/         local packs: `<name>.zip` files and `<name>/` folders (08 §1.1), listed on the pack screen (US18-1)
  saves/<folder>/        single-player worlds, each a world folder of world-folder.md (US16)
  downloads/             server pack cache (08 §9.4)
```

- Single-player folder names: the world name with characters outside `A-Z a-z 0-9 _ - space` replaced by
  `_`; if the folder exists, ` (2)`, ` (3)`, … is appended (US16 edge case). The world list shows the
  `LevelName` and the folder name.
- Local pack ids are `file/<name>` (08 §3.1).
- Server address text: `host` or `host:port`, default port 25565.

## 3. Controls (Player vantage; the in-game controls screen is not specified, these are fixed)

| Control | Binding |
|---|---|
| Move forward / back / left / right | W / S / A / D |
| Jump; fly up (creative, flying) | Space |
| Fly toggle (creative) | Space pressed twice within 0.3 s |
| Descend (flying) | Left Shift |
| Look | Mouse (cursor captured while in the world) |
| Break / attack | Left mouse button (hold to break in survival) |
| Place / use / toggle glowtube / eat (hold) | Right mouse button |
| Hotbar slot | 1 to 9, scroll wheel |
| Inventory screen | E |
| Crafting screen | C |
| Throw one / throw stack | Q / Ctrl+Q |
| Chat / command | T / `/` (opens chat with `/` typed) |
| Pause menu (disconnect, open to others, quit world) | Escape |
