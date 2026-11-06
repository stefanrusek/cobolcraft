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
- Pack limits (CobolCraft's record sizes, not 08's): a `pack.mcmeta` overlays or filter section with more
  than 8 entries is read with its first 8 and the console gets one line `ERROR pack: <pack id>: more than 8
  overlays|filter patterns, the first 8 are used`; a language or features section with more than 8 makes
  the metadata invalid. At most 8 server packs are pending per connection: a further pushed pack is dropped
  with `ERROR server pack: <uuid> dropped, 8 packs already pending` (FR-012 non-fatal).
- Server address text: `host` or `host:port`, default port 25565.

## 3. Controls (Player vantage; the in-game controls screen is not specified, these are fixed)

| Control | Binding |
|---|---|
| Move forward / back / left / right | W / S / A / D |
| Run (sprint) | Hold Left Control while moving forward (survival and creative); sends Player Command start sprinting, and stop sprinting on release or when forward movement stops (operator decision G1) |
| Jump; fly up (creative, flying) | Space |
| Fly toggle (creative) | Space pressed twice within 0.3 s |
| Descend (flying) | Left Shift |
| Look | Mouse (cursor captured while in the world) |
| Break / attack | Left mouse button (hold to break in survival) |
| Place / use / toggle glowtube / eat (hold) | Right mouse button |
| Hotbar slot | 1 to 9, scroll wheel |
| Inventory screen | E |
| Crafting screen | C |
| Throw one / throw stack | Q / Ctrl+Q (the held slot; on the inventory screen, the slot under the pointer) |
| Throw what the cursor carries (inventory screen) | Release a left click or a drag outside the window: the whole carried stack; a right click outside: one item. Leaving the screen puts the carried stack back into the inventory |
| Chat / command | T / `/` (opens chat with `/` typed) |
| Pause menu (disconnect, open to others, quit world) | Escape |

## 4. Chat area (US6-2)

- While chat is closed, the chat area shows at most the **10** most recent messages, each for **10 seconds**
  after it arrived; older or expired messages are hidden.
- While chat is open, the chat area shows the most recent 10 messages regardless of age, and the Player
  scrolls back (scroll wheel) through a history of the last **100** messages received this session; older
  messages are discarded.
- Messages are shown in the order received; `translate` components are rendered through the active packs'
  lang (wire-profile.md §1).
