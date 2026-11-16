# Vanilla client evidence (Q-1, SC-013, FR-039)

Status: pending operator

This file is the record of the manual half of Q-1: the operator's own vanilla 26.3 client against this server
(`quickstart.md` section 9). The automated half is the configuration and play sequence tests of the core. The
project's gates do not read this file; an automated run leaves it as `pending operator`.

## Steps

Prerequisite: your own Minecraft launcher with a 26.3 profile, and the generated packs built from your client
jar (`quickstart.md` section 1).

1. In an empty server directory, start the server with the standard world type and the generated packs:
   `build/bin/cobolcraft-server` with `world-type=standard` in `cobolcraft-server.conf`, and the `generated/`
   directory made by `build/bin/cobolcraft-extract --jar <jar> --game-dir <server directory>`.
2. Start the vanilla client, add a server `localhost` (offline mode, no secure chat), and connect.
3. Expected: configuration completes with no registry, tag or known-packs error, the client enters play and the
   spawn chunks render.
4. Then stop the server, set `world-type=cobolcraft` (a new directory), start it and connect the same client.
   Expected: configuration only completes (04 section 5); the client does not enter play.
5. Replace the first line `Status: pending operator` with `Status: done` after filling the sections below.

## Server console lines (standard world)

(paste the real lines)

## Observed client state (standard world)

(what the client showed: configuration result, whether it entered play, whether spawn chunks rendered)

## Server console lines and client state (cobolcraft world)

(paste the real lines and the observed state)
