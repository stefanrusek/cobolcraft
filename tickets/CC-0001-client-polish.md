---
spile: ticket
id: CC-0001
type: feature
status: draft
owner: stefanrusek
resolution:
blocked_by: []
created: 2026-11-06
relations:
  depends_on: []
  relates_to: [CC-0002]
  supersedes: []
implementation: []
---

# CC-0001: Client polish: visuals, controls and missing gameplay

## Summary

The first manual run of the finished client (feature 001, 2026-11-06) worked but looked disappointing. This ticket is
the input for the second SDD run's polish work. The world, the HUD and the screens should look deliberate and
finished, not like a debug renderer. The operator's first play session (2026-11-06) also added missing controls
and gameplay: creative-only flight with no endless climb in survival, a break indicator, inventory and bench crafting with a recipe book, cave and ore
world generation, game options, a resource-pack folder button, the F3 overlay, F5 camera modes, the off-hand swap
and a visible held item. The stand-in content (`docs/design/standin-content.md`) stays the source of the
values, so new looks are added there first (Principle II).

## User Stories

### As a Player, I want the world to look finished

- Given a new world, when I look across the terrain, then block faces are shaded so that the shapes read clearly.
  The exact lighting model is an open question.
- Given the stand-in textures, when they are drawn at any distance, then they look as their authors intended, with no
  seams, shimmering or bleeding between atlas cells.

### As a Player, I want the HUD and screens to look deliberate

- Given the HUD, inventory and menus, when they are shown, then text, slots and buttons are aligned, consistently
  spaced and readable at the window's size.
- Given a stack of 1 item, when its slot is drawn, then no count is shown. Counts appear only from 2 up.

### As a Player, I want double Space to fly only in creative, and no endless climb in survival

- Given I am in creative, when I press Space twice quickly, then flying turns on, or off if I was flying.
- Given I am in survival, when I press Space twice quickly, then I do not fly. Flight is allowed only in creative mode.
- Given I am in survival and in the air, when I press Space again, then no new jump starts. I never rise above the
  height of one jump from the ground.

### As a Player in survival, I want to see a block breaking

- Given I hold the break button on a block in survival, when breaking progresses, then the block shows a crack overlay
  that grows in stages until it breaks.
- Given I release the button or look away, when breaking stops, then the overlay disappears.
- Given another player breaks a block I can see, when they do, then I see their crack overlay too.

### As a Player, I want to craft from the inventory screen and use the recipe book

- Given the inventory screen is open, when I place ingredients in its small crafting grid, then the result slot shows
  the item they make, and taking it uses up the ingredients.
- Given the inventory screen is open, when I open the recipe book, then I see the recipes I know, with the ones I can
  make now marked, and choosing one fills the grid from my inventory.

### As a Player, I want to craft a crafting bench and use it

- Given I have the ingredients, when I craft a crafting bench and place it, then it stands in the world as a block.
- Given a placed bench, when I use it, then a crafting screen with the large grid, a result slot and the recipe book
  opens, and recipes that need the large grid can be made only there.

### As a Player, I want worlds with caves and ores that feel like vanilla

- Given a new world, when I explore, then the terrain is built the way vanilla builds it: climate-driven biomes,
  3D density terrain with hills, mountains, rivers and oceans, aquifers, and three kinds of caves (large caverns,
  long winding tunnels and thin noodle passages).
- Given ores, when I dig, then each ore is spread through its depth range the way vanilla spreads its ores: uniform or
  triangle-shaped height distributions, a vein size and a count per chunk. Some ores occur only at certain depths or in
  certain biomes.
- Given ore blocks, when I break them in survival, then they drop their items as other blocks do.

### As a Player, I want to configure the game

- Given the title screen or the pause menu, when I open Options, then I can change at least the view distance, the
  mouse sensitivity, the field of view and the GUI scale, plus whatever else refinement adds.
- Given I change an option, when I restart the game, then it is still set.

### As a Player on the resource pack screen, I want an Open Pack Folder button

- Given the resource pack screen, when I press Open Pack Folder, then my system's file browser opens the
  `resourcepacks/` folder of my game directory, so I can copy packs into it.
- Given I copy a pack in and return to the screen, when it refreshes, then the new pack is listed.

### As a Player, I want an F3 debug overlay

- Given I am in a world, when I press F3, then an overlay shows my position (x, y, z), the block and chunk I am in, the
  direction I face, the dimension, the frame rate, and other diagnostics refinement adds.
- Given the overlay is shown, when I press F3 again, then it hides.

### As a Player, I want F5 to switch the camera view

- Given I am in a world, when I press F5, then the view cycles from first person to third person from behind, then
  third person from in front, then back to first person.
- Given a third-person view, when I look at my player, then my player model is drawn, and the camera does not pass
  through blocks.

### As a Player, I want F to swap an item into my off hand

- Given no screen is open, when I press F, then the held hotbar item and the off-hand item swap.
- Given the inventory screen is open, when I press F with the mouse over a slot, then that slot's item and the
  off-hand item swap.
- Given an item in my off hand, when I look at my HUD, then the off-hand slot is shown beside the hotbar.

### As a Player, I want to see my hand and what I am holding

- Given first person, when I play, then my main hand is drawn at the lower right of the view, holding the selected
  item or block as a small 3D model.
- Given I break, place or attack, when I do, then the hand plays a swing animation.

## Functional Requirements

- Given any visual change, when it lands, then its values come from `docs/design/standin-content.md` or
  `docs/protocol/`, never from constants invented in code.

## Open Questions

- What exactly disappointed the operator in the first run? Capture screenshots and the specific complaints in a
  sidecar before refining.
- Which looks are in scope: lighting (smooth lighting, ambient occlusion), sky and fog, clouds, HUD layout, font,
  screen backgrounds?
- Crafting: 001 has a single crafting screen (US10, the C key). Does it give way to the inventory 2×2 grid plus the
  bench 3×3 grid, or stay alongside them?
- This ticket now covers visuals, controls and gameplay. Should it split into several tickets before refining?

## Decisions

- World generation (operator, 2026-11-06): it should be nearly identical to vanilla's. The run that takes this ticket
  supersedes feature 001's FR-015 for world generation. It starts with a clean-room spec round (Principle II): the
  generator's techniques and their parameters are written into `docs/protocol/` or `docs/design/standin-content.md`
  first, and implementation works only from those docs. The limit: the techniques and the feel match vanilla
  closely, but the result is not a reproduction of Minecraft's worlds. The noise parameters are CobolCraft's own,
  so a given seed does not produce vanilla's terrain, and block names and textures stay CobolCraft's.

## Notes

> [!NOTE]
> Today a count is drawn on stacks of 1, unlike Minecraft.
