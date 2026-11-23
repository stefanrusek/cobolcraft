---
spile: ticket
id: CC-0019
type: feature
status: draft
owner: stefanrusek
resolution:
blocked_by: []
created: 2026-11-23
relations:
  depends_on: []
  relates_to: [CC-0001]
  supersedes: []
implementation: []
---

# CC-0019: Sleeping in a bed works on the client and with villagers

## Summary

A player lies in a bed with the lying pose, the camera at the bed and input locked, Sneak leaves the bed, a villager
lies in its bed, and using an occupied bed kicks the villager out.

## User Stories

### As a Player, I want to sleep in a bed and see others sleep

- Given a bed at night, when I use it, then my pose lies along the bed, the camera sits at the bed, my input is
  locked, and Sneak (Leave Bed) stands me up beside it.
- Given a villager asleep in a bed, when I look at it, then it lies along the bed; when I use the occupied bed, then
  the villager is kicked out and I lie down.

## Functional Requirements

- FR-001: The core sends the sleeping pose and bed position and keeps the bed occupied; the client keeps the pose and
  bed position, draws models along the bed and moves the camera.

## State at the end of the polish run (2026-11-23)

- Built on branch 002-lane-bugsleep (tip 393d385b, two commits not on origin): 56c9bfec core (a villager lies in its
  bed, pose and bed position sent, bed occupied; a player using an occupied bed kicks the villager out; the player
  lies on the bed and stands up beside it) and 393d385b client (pose and bed position kept, models lie along the bed,
  camera at the bed, input locked, Sneak leaves the bed). The lane file is an untracked file in the worktree
  /Users/stefanrusek/Code/cobolcraft-bugsleep (specs/002-client-polish/tasks/lanes/bugsleep.md).
- Left: the lane was stopped before integration, so the branch is unmerged and its gate evidence is only what its
  commit messages say; the sleeping villager render is part of the brief and was not checked (the bed shape itself
  belongs to lane bugbed, T58102).
