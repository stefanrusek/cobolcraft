# Contract: server program operator surface (`server` ↔ Server operator)

**Status**: frozen at plan time. This is the Server operator's vantage (personas): the command line, the
console and the configuration file. Command names and texts come from the FR-015 command set in
`docs/design/standin-content.md`.

## 1. Command line

`cobolcraft-server` takes no arguments. It works in the current directory: configuration file
`./cobolcraft-server.conf`, world folder `./world/`.

## 2. Configuration file (FR-009, US13-2)

Plain UTF-8 text, one `key=value` per line, `#` starts a comment line, blank lines ignored, keys in any order.
When the file is absent the server writes it with the defaults below, each preceded by a one-line comment,
and uses them.

| Key | Values | Default | FR-009 setting |
|---|---|---|---|
| `port` | 1 to 65535 | `25565` | listening port |
| `default-game-mode` | `creative`, `survival` | `creative` | game mode for new players |
| `description` | text, up to 256 characters | `A CobolCraft server` | server-list description |
| `view-distance` | 2 to 32 | `8` | view distance |
| `player-combat` | `true`, `false` | `true` | player combat |
| `hostile-mobs` | `true`, `false` | `true` | hostile mobs |
| `weather-changes` | `true`, `false` | `true` | weather changes on its own |
| `extra-dimensions` | `true`, `false` | `true` | travel to extra dimensions |
| `allow-list` | `true`, `false` | `false` | allow-list enforced: seeds the enforcement flag of a newly created world only; an existing world keeps the flag stored in its `access.dat`, which the allow-list on/off commands change (operator decision A2; world-folder.md §2) |
| `pack-url` | `http://…` or `https://…`, or empty | empty | pack offer: download address (empty = no offer) |
| `pack-sha1` | 40 hex digits, or empty | empty | integrity hash |
| `pack-id` | UUID text, or empty | empty | stable identifier |
| `pack-required` | `true`, `false` | `false` | required |
| `pack-prompt` | text, or empty | empty | prompt message |

A missing key takes its default. An unknown key or an invalid value is a fatal error (research R14): the
console shows `FATAL configuration: <key>: <problem>` and the server exits with status 1.

## 3. Console output (US13-1, US13-3, US15)

Every line is prefixed with `[HH:MM:SS] `. Lines whose text is defined by the command set or the extension's
messages use that text; messages the server sends as `translate` components (wire-profile.md §1 message
rule) are printed as the `en_us` text of their key with the arguments filled in. Fixed lines of the program
itself:

| Event | Line |
|---|---|
| New world created | `Created new world in ./world` |
| Ready (US13-1) | `Ready: accepting players on <address>:<port>` (address `0.0.0.0` means every interface) |
| Join / leave (US13-3) | `<name> joined` / `<name> left` |
| Dimension change | `<name> went to <dimension key>` |
| Death | the death message the players see (extension) |
| Chat | `<name> message` |
| Stopping (US15-2) | `Stopping: saving world and disconnecting players` then `Stopped` |
| Non-fatal failure (FR-012) | `ERROR <what failed>: <detail>` |

## 4. Console input (US15)

Each line typed at the console is a command of the command set without a leading `/`, run with operator
permission (FR-016). Its result or error text is printed (US15-1, US15-3). End of input on the console has
no effect on the running server.
