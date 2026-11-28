# Contract: the motion engine (content to client and core)

Fixed before any task that consumes it (constitution 3.3). A change of shape returns to the plan. Provider: `content`.
Consumers: `client` (full input, every tick) and `core` (no input, plus replayed moves). Rules: document 59 and those it
extends; this contract fixes only the interface.

## 1. Motion state, `contract/copy/CTMOTION.cpy`

Level-10 items with the prefix `MO-`, included inside a group of the caller (`REPLACING LEADING ==MO-== BY ...` where
the caller keeps its own names). Velocities and positions are `FLOAT-LONG`.

| Group | Members | Set by |
|---|---|---|
| Position and velocity | feet position; velocity; collided displacement of the last move | caller and engine |
| Input | strafe and forward impulses, jumping, live shift, yaw, pitch | caller (all zero on the server) |
| Modes | sprinting, swimming, flying, spectator, may fly, pose, flying speed, leather boots worn | caller |
| Attributes | movement speed, sneaking speed, water movement efficiency, movement efficiency | caller |
| Effects | amplifiers of Jump Boost and Levitation (-1 none); Slow Falling, Dolphin's Grace | caller |
| Collision results | on ground, horizontal collision, minor collision, vertical collision, supporting block (present, cell, no-block flag) | engine |
| Fall | fall distance; fall mode (the move accumulates it, as on the client, or only resets it, as on the server) | engine; the caller sets the mode and clears the distance for a new player |
| Block state | stuck multiplier, in powder snow now and last tick, movement records of the tick | engine |
| Timers | ground jump delay | engine |
| Fluids | water and lava heights, eyes in water and lava | engine |

## 2. World access, `contract/copy/CTMWORLD.cpy`

| Member | Meaning |
|---|---|
| cell program | a `PROGRAM-POINTER` the engine calls with: handle, block x, y, z (`BINARY-LONG`), state out, loaded out |
| handle | `BINARY-LONG` the caller understands (a dimension row on the server) |
| minimum y, height | of the dimension |
| fast lava | 1 in a dimension with that rule (29a §8.3) |
| collision context | `BSX-CONTEXT`, refreshed by the engine from the motion state at each query |

The caller defines its cell program in the same source file as the program that takes its pointer (probe
`spike_motion_callback`). An unloaded cell answers loaded 0.

## 3. Entries (each `USING` motion state and world access, plus what is listed)

| Entry | Does | Rules |
|---|---|---|
| `MOTION-FLUIDS` | fluid heights, eyes, fall reset in water, currents | 29a §8; 59 §2.2 steps 5 and 7 |
| `MOTION-PUSH-OUT` | pushes out of suffocating blocks | 59 §4.4 |
| `MOTION-CLEANUP` | velocity clean-up | 59 §4.3 |
| `MOTION-JUMP` | the jump decision, ground jump, swim up | 59 §6.1 to §6.3 |
| `MOTION-TRAVEL` | fall resets of effects, swimming steering, air, water, lava, flight; the move inside | 59 §7; 53 §9.1 |
| `MOTION-MOVE` (+ requested vector, mover kind: own, replayed, piston, shulker) | stuck multiplier, edge rule, collision and step-up, flags, fall bookkeeping, restitution, speed factor | 59 §8, §12.1 to §12.3 |
| `MOTION-BLOCKS` | step-on and the inside pass in cell order | 59 §9, §10.2 to §10.4 |
| `MOTION-GEYSER` | the launch of an erupting geyser | 31 part 8 §9.6; 59 §10.5 |
| `MOTION-FALL` (+ vertical displacement, ground flag) | the server's fall bookkeeping for one position packet: accumulate, land, reset on an upward packet | 59 §12.1 |

A landing found by `MOTION-MOVE` or `MOTION-FALL` reaches the caller through an output group of `CTMOTION.cpy`:
landed flag, fall distance at the landing, landing cell state. The caller deals damage (the engine never does).

The moving-block entries and the world access they add are in [moving-blocks.md](moving-blocks.md).

## 4. Rules of use

- The client calls the entries in the order of 59 §2.2, with its own key, sprint, flight-toggle and pose steps between
  them.
- The server's tick calls `MOTION-FLUIDS`, `MOTION-CLEANUP`, `MOTION-TRAVEL` and `MOTION-BLOCKS` with zero input,
  then restores the client's position; its block entity phase calls `MOTION-GEYSER`. The packet handler calls
  `MOTION-JUMP` for a packet that leaves the ground upward, `MOTION-MOVE` as a replayed move, then `MOTION-FALL`.
- The engine keeps no state of its own between calls except the sine table and constant tables.

## 5. Contract tests (both sides)

| Program | Package | Asserts |
|---|---|---|
| `contract_motion_engine_content` | content | each entry against a worked example of 59 through a test world |
| `contract_motion_engine_client` | client | the client's world pointer answers as the replica holds; a tick calls the entries in the documented order (observed on the state) |
| `contract_motion_engine_core` | core | the core's world pointer answers as the world holds; a no-input tick of a resting player gives the velocity of 59 §13.5 |
