---
spile: ticket
id: CC-0064
type: feature
status: implementing
owner: stefanrusek
resolution:
blocked_by: []
created: 2026-11-27
relations:
  depends_on: []
  relates_to: [CC-0001, CC-0014, CC-0036, CC-0038]
  supersedes: []
implementation:
  branch: 005-doc-rounds
---

# CC-0064: Reference docs state the game's sound events, sound definitions and music

## Summary

The client plays no sound and no music, and no document under docs/protocol says what the game plays, when, or from
which data. The operator chose "sounds and music" as the next work (2026-11-27), starting with the reference docs.
Clean-room round (Principle II, skill clean-room): a reader agent studies the shipped artifact and writes prose,
tables and data schemas only, a separate reviewer checks for contamination and completeness. Implementation (the audio
backend, decoding, where a client obtains audio data without CobolCraft shipping any Minecraft file) is decided by the
operator after this round shows what the artifact does and does not contain.

## User Stories

### As a Contributor, I want the docs to state what sound the game plays and when, so that a client can be built from them

- Given each question below, when the round is done, then the doc section states the rule with its numbers and an
  implementer needs no guess.
- Given the artifact does not contain a piece of audio data or a definition file, when the round is done, then the
  doc says so, names what a client needs instead, and records where the artifact says it comes from.

## Functional Requirements

- FR-001: Each question is answered in a numbered document under docs/protocol (new document 59, and 60 if one is not
  enough), in prose, tables and data schemas only.
- FR-002: A reviewer pass checks contamination and completeness before any implementation starts.
- FR-003: The round records where the audio data and the sound definitions live (inside the artifact or fetched from
  somewhere else at run time) and which of them a player's own Minecraft client jar alone provides.

## Open Questions

- Sound events: the registry of sound event names and their numeric ids as the Sound packets carry them (how the id is
  assigned, whether the order is the registry order); what 05a and the existing packet documents already state; the
  inline-sound form of the packets; the Stop Sound packet.
- Sound definitions: how an event name maps to audio files (file format, variants and weights, volume, pitch, streaming
  and preload flags, attenuation distance, replace, subtitle key); how the variant is chosen from the seed the Sound
  packets carry.
- Where the data lives: the definition file and the audio files (inside the jar, or in an asset index that has to be
  downloaded); the audio container and codec, sample rates, channel counts, and what the game depends on (mono for
  positional sounds, stereo for music).
- Categories and positional audio: the sound categories and their volume sliders, the distance model, stereo placement,
  the volume and pitch ranges and clamps, pitch for baby mobs, the order in which concurrent sounds are limited.
- Block and step sounds: the sound type of every block (break, step, place, hit, fall volume and pitch), when a step
  sound plays (distance accumulation, water, ladders, sneaking, riding), landing and hurt sounds.
- Entity sounds: the ambient, hurt, death and step sounds of every entity type, the ambient interval rule (scratchpad
  doc-gaps 18 section 2.4: mob to ambient sound table), and the other sounds a mob or player plays.
- Item and block events: the goat horn instrument to sound table (the eight instruments; CC-0014), note block
  instruments and the note to pitch rule, jukebox and music discs (the song registry, duration in ticks, comparator
  output), the respawn anchor charge sound (CC-0038), bells and other events that carry a fixed sound.
- Music and ambience: when background music plays (menu, creative, survival, underwater, dimension and biome music),
  the delays between tracks, how a disc or the music volume setting interrupts it; ambient loops, additions and mood
  sounds (cave sounds), weather sounds; the subtitles the sounds name.

## State at the start (2026-11-27)

- No reader round is running. Existing evidence: CC-0014 notes (the instrument table is in no document), CC-0036 and
  scratchpad/doc-gaps.md (mob sound table), CC-0038 (respawn anchor sound). The core already sends Sound packets by
  registry name for some events; nothing plays them.
