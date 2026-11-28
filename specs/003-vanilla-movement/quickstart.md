# Quickstart: validating Movement That Matches Minecraft

Run from the repository root. Test names and layers are in [plan.md](plan.md) "Test strategy"; expected values come
from the documents cited in [data-model.md](data-model.md) and [research.md](research.md) section 3.

## 1. Prerequisites

- `make bootstrap` once.
- Check free disk space (`df -h .`) before a full gate.
- No client jar is needed for the feature's own tests. Older convergence tests that read generated packs need
  `CC_GENERATED_DIR`; set it so that they really run.

## 2. Contracts

```sh
python3 tools/gen/gen_contract.py --check
make gate-contract
make gate-content
```

Expected: exit status 0; the `contract_movement_blocks_*`, `contract_motion_engine_*`,
`contract_moving_blocks_*` and `contract_motion_wire_*` programs of [contracts/](contracts/) report no failing case.

## 3. Automated scenarios

```sh
make gate-client
make gate-core
make gate
```

Expected: exit status 0, no failing case, 0 uncovered lines. In the output:

- `test_motion_examples_*` and `acc_f3us1_worked_examples`: the worked examples within 0.001 blocks (SC-001);
- `acc_f3us1_*` cases for every scenario and edge case of US1;
- `acc_f3us1_world_types`: the same end position under both content sets (SC-002);
- `acc_f3us1_pistons*`, `acc_f3us1_shulker`: pushes, launch and carry as the documents give (scenario 18);
- `acc_f3us1_lift_*`: the lift of 59 §13.6 on both sides (scenario 20);
- `acc_f3us1_no_pullback`: 0 corrections and 0 disconnects (SC-004).

Reference figures for reading a failure (59 §7, §10, §11, §13):

| Movement | Figure |
|---|---|
| walk, sprint | 4.317 and 5.612 blocks per second |
| release glide from a walk | 0.256 blocks |
| first tick on ice after ordinary ground | 2.807 blocks per second; above 4 again on the 20th tick on ice |
| slide on ice | 1.688 blocks |
| first tick back on ordinary ground | 5.667 blocks per second |
| jump height | 1.2522 blocks |
| sneak | 1.295 blocks per second |
| flight | 10.89, 21.78 sprinting, 7.5 vertical |
| soul sand; cobweb | 2.508; 0.49 blocks per second |
| Speed II | 6.044 blocks per second |
| 10-block fall | 7 damage on stone, 1 on hay or honey, 0 on slime, powder snow or water; 5 on stone with Jump Boost II |
| first opening tick of a shulker box under the Player | lifted 0.11 |
| piston push into the Player | 0.51 on the first moving tick; a slime block upward sets vertical speed 1.0 |
| farmland trampled under a Player; eye of ender into the frame underfoot | lifted 0.0625; 0.1875 |

## 4. Operator comparison with Minecraft (SC-003, manual)

Only the operator runs this: it opens the game window.

1. `make build`, then start a world hosted by CobolCraft that a Minecraft client can join.
2. Prepare a flat stretch of ordinary ground, an ice strip, a one-block gap, a pool of water, a pool of lava, a ladder,
   patches of soul sand, honey and cobweb, a drop of five blocks, a piston with a slime block and one with a honey
   block, a shulker box to stand on, farmland and an empty end portal frame.
3. Walk, sprint, stop, jump and slide over the same stretch in both clients, side by side. Take a hurting fall while
   walking, a hit while moving and a burn; ride the pistons, open the shulker box under your feet, trample the
   farmland and fill the frame while standing on it.
4. Record whether starting, stopping, jumping and sliding differ, and note anything else that differs (the effects of a
   hit and of a hurting fall rest on rules not yet observed). Passing: no reported difference.
