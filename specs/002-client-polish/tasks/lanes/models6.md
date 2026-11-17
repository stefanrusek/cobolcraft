## Lane models6 (T10200-T10299)

- [x] T10200 shim: CC_TEX_GLINT (5) and CC_TEX_GLINT_ARMOR (6) repeat textures, cc_vk_glint_offset (glint draws only), push constants 32 floats (shim/tests/test_cc_vk_glint.c, contract_shim_provider.c, shim-abi 9).
- [x] T10201 client glint: glint.cob (textures, offset, strength, GLINT-UV, STACK-FOIL, GLINT-ICON), armour glint layers 13 to 16, icon glint (tests test_glint, test_glint_slots, test_entity_glint, test_submit). Held items, creeper charge and dragon passes stay open under T9903.
- [x] T10202 ITEM-NBT-SKIP and inline trim holders (test_item_nbt, test_entity_eqcomp); trim pack glue test (test_entity_trim_pack).
- [ ] T10203 not started by models6: T9904 to T9906 (baby and zombie villager armor meshes, banner and shield layers, held-item poses, guardian beam, dragon passes, axolotl animators, glow squid, fangs burst, boat water patch).
