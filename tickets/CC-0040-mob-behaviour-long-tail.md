---
spile: ticket
id: CC-0040
type: feature
status: draft
owner: stefanrusek
resolution:
blocked_by: []
created: 2026-11-23
relations:
  depends_on: []
  relates_to: [CC-0001, CC-0036, CC-0039]
  supersedes: []
implementation: []
---

# CC-0040: The remaining mob behaviours of docs 44 and 19 to 21 are built

## Summary

Mob behaviours that lanes listed as not built and that need no new doc are built: rabbit hop and panic, copper golem
transport, boats and minecarts with passengers and containers, projectiles' details, the villager and piglin
leftovers, panda, sniffer and turtle goals, nautilus sensors.

## User Stories

### As a Player, I want the standard mobs to behave as they do in Minecraft

- Given each mob or vehicle below, when I meet it, then it shows the behaviour named on its task line.

## Functional Requirements

- FR-001: Each behaviour has red-first tests with real data, and code coverage stays 100 percent for what is added.

## State at the end of the polish run (2026-11-23)

- Open task lines, each with its own description in the lane file: T24090 (nautilus: sensors, line of sight, the mob
  anger; lanes/p49j-a.md); T24202, T24205 (boat second passenger, push and load, bubble column, chest boat menu),
  T24208 (container minecarts, comparator slowdown, hopper pull, spawner and command carts, boarding by mobs), T24211,
  T24214 (player-thrown wind charge, wither skull details, trident, snowball blaze damage) in lanes/p49j-b.md; T52090
  (rabbit hop, move control, panic, avoid, raid garden, killer bunny), T52092 (copper golem transport brain; needs
  CC-0036 first) in lanes/p49v.md; T38505 (piglin charging spear damage), T38621 (panda scared in thunder, panda avoid
  and attack, sneeze only for babies) in lanes/p49s.md; T50007 (the DoNothing pause group of IDLE stroll, hurt_by from
  any attacker) in lanes/p49u.md; T23507 (sniffer dig position, turtle goals; lanes/p70c.md) and T9213
  (lanes/mobsa5.md); T37008 (trade sharing, ShowTrades, WorkAtComposter, MoveToSkySeeingSpot, celebration;
  lanes/p49q.md); T42704 (the villager head shake counter, the already-trading refusal, hit boxes of the leash knot,
  frames and paintings; lanes/bugtrade.md); T57003 (door hold-off countdown, second-villager check, trapdoors and
  fence gates as walls, zombie BreakDoorGoal; lanes/bugvlclaim.md); T58503 (see CC-0023).
- Judged low value by the 2026-11-19 analysis and recommended for cutting: T52091 polar bear leftovers, T25094,
  T24209, T24210.
