*> State owned by the administration, state and chat commands of docs/protocol/16-commands-catalog.md that need none of the
*> world records (core/src/cmds-admin.cob, cmds-state.cob, cmds-chat.cob). All fields are zero at the start; a program that
*> wants another default sets it when BA-INIT is 0 (BA-ENSURE).
*>
*> BA-DEV-COMMANDS 1 registers the dev and debug commands of §12 (DEBUG_DEV_COMMANDS: raid, debugpath, debugmobspawning,
*> warden_spawn_tracker, spawn_armor_trims, serverpack, and with a dedicated host debugconfig), BA-CHASE-COMMAND 1 chase
*> (DEBUG_CHASE_COMMAND), BA-PROFILER 1 jfr (profiler available); production leaves all three 0 (16 §2, §16), a test sets them
*> before BR-STD-TREE builds the tree. publish and unpublish are registered when the host is not dedicated (CS-HOST-KIND not 0).
*>
*> The tick manager (16 §4.9): rate, frozen, ticks of a step and a sprint still to run; the published port (16 §11.15); the
*> start ticks of the tick profiler (debug, 1) and the performance profiler (perf, 2), 0 = not running (a run starts at tick + 1).
 01 BR-CMDA EXTERNAL.
    05 BA-INIT              BINARY-LONG.
    05 BA-DEV-COMMANDS      BINARY-LONG.
    05 BA-CHASE-COMMAND     BINARY-LONG.
    05 BA-PROFILER          BINARY-LONG.
    05 BT-RATE              FLOAT-LONG.
    05 BT-FROZEN            BINARY-LONG.
    05 BT-STEP-LEFT         BINARY-LONG.
    05 BT-SPRINT-LEFT       BINARY-LONG.
    05 BP-PUBLISHED         BINARY-LONG.
    05 BP-PORT              BINARY-LONG.
    05 BF-START            BINARY-DOUBLE OCCURS 2 TIMES.
