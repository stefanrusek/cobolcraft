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

Expected: exit status 0; the `contract_movement_blocks_*` and `contract_motion_wire_*` programs of
[contracts/](contracts/) report no failing case.

## 3. Automated scenarios

```sh
make gate-client
make gate-core
make gate
```

Expected: exit status 0, no failing case, 0 uncovered lines. In the output:

- `acc_f3us1_*` cases for every scenario and edge case of US1;
- `acc_f3us1_worked_examples`: every worked example within 0.001 blocks (SC-001);
- `acc_f3us1_world_types`: the same end position under both content sets (SC-002);
- `acc_f3us1_no_pullback`: 0 corrections and 0 disconnects (SC-004).

Reference figures for a quick reading of a failure: walk 4.32 blocks per second, sprint 5.61, release glide about a
quarter block, ice slide about 1.7 blocks, jump height 1.25, sneak 1.3, flight 10.9, 21.8 sprinting, 7.5 vertical
(spec US1; 13 section 1; 53 section 6.2).

## 4. Operator comparison with Minecraft (SC-003, manual)

Only the operator runs this: it opens the game window.

1. `make build`, then start a world hosted by CobolCraft that a Minecraft client can join.
2. Prepare a flat stretch of ordinary ground followed by an ice strip, a one-block gap, a pool of water, a pool of
   lava, a ladder, and patches of soul sand, honey and cobweb.
3. Walk, sprint, stop, jump and slide over the same stretch in both clients, side by side.
4. Record whether starting, stopping, jumping and sliding differ. Passing: no reported difference.
