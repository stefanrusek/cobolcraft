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
  relates_to: [CC-0002, CC-0007]
  supersedes: []
implementation: []
---

# CC-0001: Client polish: visuals, controls and missing gameplay

## Summary

The first manual run of the finished client (feature 001, 2026-11-06) worked but looked disappointing. This ticket is
the input for the second SDD run's polish work. The world's textures, the HUD and the screens should look deliberate and
finished, not like a debug renderer. Lighting, sky and clouds are CC-0007. The operator's first play session (2026-11-06) also added missing controls
and gameplay: creative-only flight with no endless climb in survival, a break indicator, inventory and bench crafting with a recipe book, cave and ore
world generation, game options, a resource-pack folder button, the F3 overlay, F5 camera modes, the off-hand swap
and a visible held item. The operator also supplied a real resource pack (Faithful 32x for 26.3) that the client must
load and use. The stand-in content (`docs/design/standin-content.md`) stays the source of the
values, so new looks are added there first (Principle II).

## User Stories

### As a Player, I want the world's textures to look finished

- Given the stand-in textures, when they are drawn at any distance, then they look as their authors intended, with no
  seams, shimmering or bleeding between atlas cells.

### As a Player, I want the HUD and screens to look deliberate

- Given the HUD, inventory and menus, when they are shown, then text, slots and buttons are aligned, consistently
  spaced and readable at the window's size.
- Given a stack of 1 item, when its slot is drawn, then no count is shown. Counts appear only from 2 up.
- Given the Faithful 32x pack, when the HUD, inventory, crafting and menu screens are drawn, then their layout, sprites,
  nine-slice scaling and font follow the pack's GUI textures (`docs/protocol/12-client-rendering.md` §5 and
  `docs/protocol/14-texture-only-packs.md` §6), and the pack is the guide to how they look.

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

### As a Player, I want worlds generated like vanilla's

- Given a new world, when I explore, then the terrain is built the way vanilla builds it: climate-driven biomes,
  3D density terrain with hills, mountains, rivers and oceans, aquifers, and three kinds of caves (large caverns,
  long winding tunnels and thin noodle passages).
- Given ores, when I dig, then each ore is spread through its depth range the way vanilla spreads its ores: uniform or
  triangle-shaped height distributions, a vein size and a count per chunk. Some ores occur only at certain depths or in
  certain biomes.
- Given ore blocks, when I break them in survival, then they drop their items as other blocks do.

### As a Player, I want all the standard Minecraft commands to work

- Given I have the permission, when I type a standard command such as `/give`, `/tp` or `/gamemode`, then it works as
  it does in Minecraft, with the same arguments, completions and messages.
- Given a standard command that is not named here, when I type it, then it works too. The list is not limited to the
  examples: the full set of standard commands is the goal.

### As a Player, I want all the tools and weapons to work

- Given I hold a standard tool or weapon, when I use it, then it does what it does in Minecraft: it breaks blocks at
  its speed and tier, deals its damage, loses durability, and has its special uses.

### As a Player, I want all the standard mobs to exist and behave as they do

- Given I explore the world, when I meet a standard mob, then it exists with its standard appearance, health, drops,
  spawning rules and behaviour.

### As a Player, I want to configure the game

- Given the title screen or the pause menu, when I open Options, then I can change at least the view distance, the
  mouse sensitivity, the field of view and the GUI scale, plus whatever else refinement adds.
- Given I change an option, when I restart the game, then it is still set.

### As a Player, I want the game to load and use my resource pack

- Given the Faithful 32x pack (`Faithful 32x - 26.3.zip`, a zip in the `minecraft:` namespace holding block, item,
  entity, GUI, particle, environment and font textures) is in my game directory's `resourcepacks/` folder, when I open
  the resource pack screen, then it is listed, and I can enable it and move it up or down the stack.
- Given the pack is enabled, when I look at the world, then blocks, items, mobs, the HUD, the inventory and crafting
  screens, the crack overlay, particles, sky, weather and text are drawn with the pack's textures, at the pack's 32x
  resolution, wherever the pack supplies one. The built-in stand-in pack fills every gap, and nothing is drawn with
  the missing-texture stripes for content the pack covers.
- Given the pack's texture animations (`.mcmeta` files) and its connected-texture rules, when the pack is enabled,
  then animations play, and a rule the client does not support is ignored without error.
- Given I disable the pack or restart the game, then the game shows the stand-in look again, or the pack again if it
  is still enabled.

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

- Given the Faithful 32x pack, when it is loaded, then the client reads it in the format of `docs/protocol/08-resource-packs.md`,
  in the `minecraft:` namespace, and the texture path each stand-in block, item and mob uses is written down in
  `docs/design/` before implementation (Principle II).
- Given the inventory 2x2 grid and the crafting bench 3x3 grid, when they land, then feature 001's single crafting
  screen (US10, the C key) is removed, and crafting is done only in the inventory and bench screens.
- Given any visual change, when it lands, then its values come from `docs/design/standin-content.md` or
  `docs/protocol/`, never from constants invented in code.

## Decisions

- Resource pack (operator, 2026-11-06): the client loads and uses the Faithful 32x pack for 26.3. The operator keeps
  the pack and the 26.3 client jar in the git-ignored `tmp/` folder. They are inputs for the clean-room rounds and are
  never committed.
- Namespace (operator, 2026-11-06): Minecraft compatibility is generally desirable, so the client uses the `minecraft:`
  namespace for anything with a vanilla equivalent, and packs written for it, such as Faithful, apply directly by
  path. `cobolcraft:` stays for the places where CobolCraft extends or diverges from Minecraft. This changes 08's
  statement that our packs target `cobolcraft:`.
- World generation (operator, 2026-11-06): it should be nearly identical to vanilla's. The run that takes this ticket
  supersedes feature 001's FR-015 for world generation. If that needs another clean-room spec update round, one is run
  first (Principle II): the generator is written into `docs/protocol/` or `docs/design/standin-content.md`, and
  implementation works only from those docs.

- Crafting screen (operator, 2026-11-06): feature 001's crafting screen (US10, the C key) is removed. Crafting uses the
  inventory 2x2 grid and the bench 3x3 grid.
- Stand-in content (operator, 2026-11-06): the standard Minecraft commands, tools, weapons and mobs are the target.
  `docs/design/standin-content.md` is replaced where it is redundant with them.
- Scope (operator, 2026-11-06): lighting, sky, fog and clouds move to CC-0007. This ticket is implemented as a whole,
  in one run, and is not split.

## Notes

> [!NOTE]
> Today a count is drawn on stacks of 1, unlike Minecraft.
