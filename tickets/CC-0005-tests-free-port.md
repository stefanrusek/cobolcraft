---
spile: ticket
id: CC-0005
type: bug
status: draft
owner: stefanrusek
resolution:
blocked_by: []
created: 2026-11-06
relations:
  depends_on: []
  relates_to: []
  supersedes: []
implementation: []
---

# CC-0005: Server tests do not depend on port 25565 being free

## Summary

Some server tests listen on the default port 25565. They fail when a CobolCraft or Minecraft server is already running
on the contributor's machine, which is exactly when a contributor is likely to be testing by hand. Tests should use a
free port chosen at run time. The convergence harness already does this.

## User Stories

### As a Contributor, I want the gate to pass while a server is running

- Given a server already listening on 25565, when I run `make gate-server` or `make gate`, then every test passes.
- Given a test that checks the default port value, when it runs, then it checks the configured value without binding
  the default port.
