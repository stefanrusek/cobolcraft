## Lane 002-lane-spproc (T60200-T60399): single-player core in a child process

Design: docs/design/singleplayer-process.md. Mode switch: CC_SP_PROCESS=1 (in-process stays the default and the test path).

### Stage A: study

- [X] T60200 [spproc] List every core call the client makes with a verdict (replaced by protocol, control channel, in-process only): the inventory table of docs/design/singleplayer-process.md
- [X] T60201 [spproc] Design note docs/design/singleplayer-process.md (spawn, handshake, control channel, pause, quit, crash, open to others, loading, cost)
