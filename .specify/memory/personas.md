# CobolCraft Personas

The people on whose behalf CobolCraft behavior is specified (constitution, Principle 2.2).
The specify phase may propose a new persona or term, but must not add one silently.

## Player

- **Role**: Plays CobolCraft: joins a world, moves around, places and breaks blocks, and talks to other players. Cares that the game starts, connects, renders correctly and stays connected.
- **Vantage**: The game window (world view, inventory, chat, menus, on-screen messages), the server list and connect screen, and any message shown when a connection fails or the player is disconnected.
- **Horizon**: Packets, protocol phases, compression and encryption, registries and numeric ids, chunk encoding, the renderer, the server's storage, and the COBOL and C code.

## Server operator

- **Role**: Runs a CobolCraft server for a group of players. Cares that the server starts, accepts connections, keeps the world safe across restarts, and gives clear reasons when something goes wrong.
- **Vantage**: The server's command line and console output, its configuration file, the world folder on disk (as a unit to back up or move), and what players tell them.
- **Horizon**: The internal layout of world files, the wire protocol, registry contents, and the program's internals.

## Pack creator

- **Role**: Makes resource packs that change how CobolCraft blocks and items look. Cares that a pack loads, shows up as intended, and reports clearly when part of it is invalid.
- **Vantage**: The pack's own files as they author them (textures, models, metadata) in their usual tools, the game's pack selection screen, how the game looks with the pack applied, and any pack error messages.
- **Horizon**: How the client loads, merges and stitches pack contents, and the renderer's internals.

## Contributor

- **Role**: Develops CobolCraft: builds it locally, runs its tests, and opens pull requests. Cares that the build and tests are reproducible and that failures point to the cause.
- **Vantage**: A terminal (build commands, test runner output), the repository's documentation and specifications, pull request checks and review comments.
- **Horizon**: Parts of the codebase outside the change at hand, and the shipped client jar that the protocol spec was derived from. Implementation works from `docs/protocol/`, not from the jar (constitution, Principle II).

## Terms

- **World**: The persistent place players join, as the Player and the Server operator experience it: its terrain, the blocks placed in it, and where they were when they left.
- **Resource pack**: A bundle of textures, models and metadata, made by a Pack creator, that changes how the game looks without changing how it plays.
