#### Phase 61: US6-client — HUD and screens

- [x] T2994 [US6-client] Write acceptance test `client/tests/acc_f2us6_layout.cob` (US6-1, SC-003): the HUD, inventory and menus at every GUI scale from 1 to the maximum, at the smallest supported window size and below it (edge case) have no overlapping or clipped element (render list bounds) [FR-013, FR-014, FR-015]
- [x] T2995 [US6-client] Implement the layout rules (alignment, spacing, GUI scale, minimum window size from Round GUI) in `client/src/ui-render.cob`
- [x] T2996 [US6-client] Write acceptance test `client/tests/acc_f2us6_counts.cob` (US6-2, FR-014): edge cases: a slot with 1 item shows no count, and the cases 2, 64 and a count too wide for the slot each show it aligned and unclipped (four named cases) [SC-003]
- [x] T2997 [US6-client] Implement the count rule in `client/src/ui-render.cob`
- [x] T2998 [US6-client] Write acceptance test `client/tests/acc_f2us6_nine_slice.cob` (US6-3): with the Faithful fixture the screens' sprites, nine-slice scaling and font follow the pack's GUI textures (12 §5, 14 §6) [FR-013, FR-014, FR-015; SC-003]
- [x] T2999 [US6-client] Implement nine-slice drawing and pack font use in `client/src/ui-render.cob` and `client/src/packs/font.cob`
- [x] T3000 [US6-client] Write acceptance test `client/tests/acc_f2us6_builtin_art.cob` (US6-4): in a cobolcraft world with no pack the screens use the built-in art, font and language and nothing is blank (`docs/design/builtin-ui-art.md`) [FR-013, FR-014, FR-015; SC-003]
- [x] T3001 [US6-client] Complete the built-in UI art, glyphs and language in `client/src/packs/builtin.cob`, `client/copy/CLGLYPHS.cpy`, `client/copy/CLBUILTIN.cpy`
- [x] T3002 [US6-client] Restyle the HUD in `client/src/screens/hud.cob` and the title, pause, world list, create-world screens (`client/src/screens/*.cob`) to the layout rules
- [x] T3003 [US6-client] Gate: run `make gate-client` and record the command and real output
