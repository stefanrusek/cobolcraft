---
spile: ticket
id: CC-0053
type: bug
status: draft
owner: stefanrusek
resolution:
blocked_by: []
created: 2026-11-25
relations:
  depends_on: []
  relates_to: [CC-0014, CC-0034]
  supersedes: []
implementation: []
---

# CC-0053: Other players see what a player holds and wears at all times

## Summary

A player in view of another player shows the items in both hands and the four armour pieces that the other player has
equipped, from the moment the two come into view and after every change: choosing another hotbar slot, swapping the hands,
picking up or placing an item, equipping or removing armour, and an item that is used up or breaks.

## User Stories

### As a Player, I want to see the item another player holds and the armour they wear as soon as they are in view

- Given two players in the same world and the second holds a tool in the main hand and wears armour, when the second comes
  into view of the first (joining, walking into view range, changing dimension), then the first sees the tool in the
  second's hand and the armour on the second's body.
- Given the second player in view, when the second chooses another hotbar slot, then the first sees the item of that slot in
  the hand at once (an empty slot shows an empty hand).
- Given the second player in view, when the second swaps the main and the off hand, equips or takes off an armour piece, or
  the item in the hand is used up or breaks, then the first sees the change at once.

## Functional Requirements

- FR-001: The pairing of a player with a viewer (the same moment the entity is added for the viewer) sends Set Equipment
  (05b 0x68) with every slot of the player that holds a stack: main hand, off hand, feet, legs, chest, head (18 section 9.1;
  an empty slot is not sent).
- FR-002: Every tick the server compares each equipment slot of a player with the stack last sent and broadcasts Set
  Equipment with the changed slots (a copy of the stack, the empty stack included) to the players that see the player
  (18 section 9.1, `detectEquipmentUpdates`). A changed held slot, a hand swap, an inventory click, a drop, a pick-up into
  the hand, an armour equip or removal, a used-up or broken item and a death all change a slot and are covered by the one
  comparison.
- FR-003: The stack in a Set Equipment keeps its components (the patch of `SP-EXPORT`), so the models of the client draw
  the dye, trim, glint and banner patterns, and a goat horn keeps its instrument (58 section 5.2).
- FR-004: A test with two real players through the real play path: the second changes the held slot, swaps hands and equips
  armour, and the first receives Set Equipment with the new stack of the right slot each time, and in the pairing bundle when
  it comes into view with items already equipped.

## Open Questions

- The core's use of Set Equipment today is the used hand of an item that starts to be used (`USE-FLAGS-SYNC`, CC-0014), which
  makes a viewer's hand show the item only once the first item is used. Whether the same comparison also serves the
  armour of mobs (`core/src/mob-20-3.cob` already sends the armour of a mob in its pairing) is left to the fix.

## Notes

> [!NOTE]
> The current behaviour, found while fixing CC-0014 (round 3 of the bug wave): the core never sends Set Equipment of a
> player's hands or armour at any time other than the start of an item use (`USE-FLAGS-SYNC` in `core/src/poses.cob`: the used
> hand only). A viewer therefore sees an empty hand and no armour on another player at pairing, after a held-slot change and
> after a swap, until the first used item sets that hand. The client already keeps the equipment (`EN-EQ`, `EN-EQX` of
> `client/copy/CLSTATE.cpy`, Set Equipment in `ENTITY-PACKET`) and draws it with the held-item and armour layers.
