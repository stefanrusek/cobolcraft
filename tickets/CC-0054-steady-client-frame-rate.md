---
spile: ticket
id: CC-0054
type: bug
status: draft
owner: stefanrusek
resolution:
blocked_by: []
created: 2026-11-26
relations:
  depends_on: []
  relates_to: [CC-0002, CC-0047, CC-0052]
  supersedes: []
implementation:
  branch: 004-perf-frame
---

# CC-0054: The client holds a steady frame rate at the agreed target in a standard world

## Summary

In a standard single-player world the client draws at a steady frame rate that meets a target agreed with the operator
for a named machine, view distance and window size. The target is a measured number (constitution 2.7); it is not set
yet and is agreed before any code changes.

## User Stories

### As a Player, I want the game to draw smoothly while I stand, walk and fly in a standard world

- Given a release build, a standard world and the agreed view distance and window size on the agreed machine, when the
  player stands still after the view has loaded, then the F3 overlay shows a frame rate at or above the agreed target.
- Given the same setup, when the player walks or flies so that new chunks arrive, then the frame rate stays at or above
  the agreed lower bound for movement.

## Functional Requirements

- FR-001: The cause of the reported frame rate is found by measurement of a release build before code changes: the
  share of a frame spent in the core tick, the client tick, meshing, the render list, the window submit and the present.
- FR-002: The frame rate target (machine, world, view distance, window size, standing and moving) is agreed with the
  operator and recorded here.
- FR-003: Each change made for this ticket has a test through the real code path with real data that fails before the
  change.

## Notes

> [!NOTE]
> Reported on 2026-11-26: a steady frame rate of about 15 on an M1 MacBook Air, with the vanilla client at 60 on the
> same machine and no other load. The build was v0.2.0 with Minecraft content; view distance, window size and
> single-player or server were not recorded.
> Measured so far (M4 Pro, -O2 build of main aba05242, `acc_perfframe_bench`, view 12, 24 mobs): mean CPU time of one
> frame step 8541 us, slowest 35383 us. The window submit and the present are not in that number and are not measured
> on any machine yet. They can only be measured with a window on the screen; that check is the operator's.
>
> Windowed measurements of 2026-11-26 (M4 Pro, release build of main aba05242, `CC_GPU_STATS=1`, single-player view
> distance 8, load average 7 to 10 from other work; logs in the operator's gatefast-logs/perfround folder):
> - Standard world, settled, vsync: 60 fps; app 5.64 ms and GPU 5.05 ms a frame, render list 2.58 ms, core tick 1.96 ms a
>   frame, 1518 draws, 3,594,864 vertices.
> - The same without vsync (`CC_VK_PRESENT=immediate`): 118 fps (the display's 120); app 4.07 ms, GPU 3.89 ms a frame.
> - Standard world while its chunks load: 44 to 100 fps without vsync, 28 to 54 with it, for about 100 s after the join.
>   The frame is bound by the main thread: of 4508 main-thread samples, `MESH-DIRTY` 1157, `CORE-TICK` 1107
>   (`WORLDSIM-TICK` 479, `CHUNK-FEED-TICK` 298, `GEN-QUEUE-TICK` 211), `NET-PUMP` 425, `RENDER-LIST-BUILD` 227. The mesh
>   phase took 6 to 15 ms a frame: its 4000 us limit is checked between sections and doubles near unmeshed sections
>   (`client/src/mesher.cob`).
> - Old stand-in world, standing: 60 fps with vsync (app 2.5 ms, GPU 1.0 ms, 285 draws, 488 thousand vertices).
> - The present path is not the limit on this machine (submit waits only for the display).
> Not measured: anything on the M1 Air. One `CC_GPU_STATS=1` run there tells whether its frame is bound by the GPU
> (`gpu ms/frame`), the main thread (`app` and the phase line) or the present (`submit`, `fence`).
>
> M1 Air, 2026-11-26 (8 GB, 8 GPU cores, 2560 x 1600, AC power; v0.2.0 release download b0259ecb; the operator's
> standard save, a new player standing at the spawn point, no input; nothing else of the operator's running, load
> average 3.8 to 7.9): the steady 15 fps was not reproduced.
> - Settled (from about 95 s after the world appears; 1159 draws, 3,182,442 vertices): 57.9 fps with vsync (app 12.24 ms,
>   GPU 7.71 ms a frame; core tick 5.26 ms a frame at 0.3 ticks a frame, render list 4.00 ms, mesh phase 1.93 ms);
>   about 110 fps with `CC_VK_PRESENT=immediate` (app 7.81 ms, GPU 4.75 ms).
> - While chunks load (about 90 s): 30 to 50 fps in both present modes; app 18 to 26 ms a frame (core tick 6.4 to 12.8,
>   mesh phase 6.6 to 7.3, render list 3.3 to 4.0), GPU 5 to 7 ms.
> - Main-thread sample of the settled state with vsync (7730 samples): `CL-STEP` 5186 = `SP-PUMP` 2608 (`CORE-TICK` 2606:
>   `MOBS-TICK` 1683 with `MOB-PUSH-TICK` 1045, `WORLDSIM-TICK` 224, `MOBS-SPAWN-TICK` 204, `REDSTONE-ENTITY-TICK` 197),
>   `RENDER-LIST-BUILD` 1742 (`ENTITIES-MESH` 901, `HAND-MESH` 156, `SECTION-MATRIX` 146), `MESH-DIRTY` 575;
>   `SUBMIT-FRAME` 2507, of which 1775 waiting for the next drawable (vsync).
> Not measured: the Air with the vanilla client running beside it, or a player who moves (new chunks keep arriving).
