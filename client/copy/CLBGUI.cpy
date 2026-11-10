*> Generated table of the built-in GUI art (docs/design/builtin-ui-art.md section 4.1 to 4.9): the sprites,
*> then the drawing steps (BG-OP rows) and the character art that BGUI-DRAW in client/src/packs/builtin-gui.cob runs.
*> Sprite row: path (PIC X(80)), width, height, nine-slice border (0 = none), name (noise and stage name).
*> Op row: sprite number (3), op (2), six numbers (3 each), four colours RRGGBBAA ('--------' = none), argument (3).
 78 BG-SPRITE-COUNT        VALUE 134.
 78 BG-GUI-COUNT           VALUE 102.
 78 BG-OP-COUNT            VALUE 300.
 78 BG-ART-COUNT           VALUE 10.
 01 BG-SPRITE-DATA.
    05 FILLER PIC X(100) VALUE "assets/minecraft/textures/gui/sprites/hud/hotbar.png".
    05 FILLER PIC X(15) VALUE "18202200       ".
    05 FILLER PIC X(100) VALUE "assets/minecraft/textures/gui/sprites/hud/hotbar_selection.png".
    05 FILLER PIC X(15) VALUE "02402300       ".
    05 FILLER PIC X(100) VALUE "assets/minecraft/textures/gui/sprites/hud/hotbar_offhand_left.png".
    05 FILLER PIC X(15) VALUE "02902400       ".
    05 FILLER PIC X(100) VALUE "assets/minecraft/textures/gui/sprites/hud/hotbar_offhand_right.png".
    05 FILLER PIC X(15) VALUE "02902400       ".
    05 FILLER PIC X(100) VALUE "assets/minecraft/textures/gui/sprites/hud/hotbar_attack_indicator_background.png".
    05 FILLER PIC X(15) VALUE "01801800       ".
    05 FILLER PIC X(100) VALUE "assets/minecraft/textures/gui/sprites/hud/hotbar_attack_indicator_progress.png".
    05 FILLER PIC X(15) VALUE "01801800       ".
    05 FILLER PIC X(100) VALUE "assets/minecraft/textures/gui/sprites/hud/crosshair.png".
    05 FILLER PIC X(15) VALUE "01501500       ".
    05 FILLER PIC X(100) VALUE "assets/minecraft/textures/gui/sprites/hud/crosshair_attack_indicator_background.png".
    05 FILLER PIC X(15) VALUE "01601600       ".
    05 FILLER PIC X(100) VALUE "assets/minecraft/textures/gui/sprites/hud/crosshair_attack_indicator_progress.png".
    05 FILLER PIC X(15) VALUE "01601600       ".
    05 FILLER PIC X(100) VALUE "assets/minecraft/textures/gui/sprites/hud/crosshair_attack_indicator_full.png".
    05 FILLER PIC X(15) VALUE "01601600       ".
    05 FILLER PIC X(100) VALUE "assets/minecraft/textures/gui/sprites/hud/experience_bar_background.png".
    05 FILLER PIC X(15) VALUE "18200500       ".
    05 FILLER PIC X(100) VALUE "assets/minecraft/textures/gui/sprites/hud/experience_bar_progress.png".
    05 FILLER PIC X(15) VALUE "18200500       ".
    05 FILLER PIC X(100) VALUE "assets/minecraft/textures/gui/sprites/hud/effect_background.png".
    05 FILLER PIC X(15) VALUE "02402400       ".
    05 FILLER PIC X(100) VALUE "assets/minecraft/textures/gui/sprites/hud/effect_background_ambient.png".
    05 FILLER PIC X(15) VALUE "02402400       ".
    05 FILLER PIC X(100) VALUE "assets/minecraft/textures/gui/sprites/hud/heart/container.png".
    05 FILLER PIC X(15) VALUE "00900900       ".
    05 FILLER PIC X(100) VALUE "assets/minecraft/textures/gui/sprites/hud/heart/container_hardcore.png".
    05 FILLER PIC X(15) VALUE "00900900       ".
    05 FILLER PIC X(100) VALUE "assets/minecraft/textures/gui/sprites/hud/heart/container_blinking.png".
    05 FILLER PIC X(15) VALUE "00900900       ".
    05 FILLER PIC X(100) VALUE "assets/minecraft/textures/gui/sprites/hud/heart/container_hardcore_blinking.png".
    05 FILLER PIC X(15) VALUE "00900900       ".
    05 FILLER PIC X(100) VALUE "assets/minecraft/textures/gui/sprites/hud/heart/full.png".
    05 FILLER PIC X(15) VALUE "00900900       ".
    05 FILLER PIC X(100) VALUE "assets/minecraft/textures/gui/sprites/hud/heart/full_blinking.png".
    05 FILLER PIC X(15) VALUE "00900900       ".
    05 FILLER PIC X(100) VALUE "assets/minecraft/textures/gui/sprites/hud/heart/half.png".
    05 FILLER PIC X(15) VALUE "00900900       ".
    05 FILLER PIC X(100) VALUE "assets/minecraft/textures/gui/sprites/hud/heart/half_blinking.png".
    05 FILLER PIC X(15) VALUE "00900900       ".
    05 FILLER PIC X(100) VALUE "assets/minecraft/textures/gui/sprites/hud/heart/hardcore_full.png".
    05 FILLER PIC X(15) VALUE "00900900       ".
    05 FILLER PIC X(100) VALUE "assets/minecraft/textures/gui/sprites/hud/heart/hardcore_full_blinking.png".
    05 FILLER PIC X(15) VALUE "00900900       ".
    05 FILLER PIC X(100) VALUE "assets/minecraft/textures/gui/sprites/hud/heart/hardcore_half.png".
    05 FILLER PIC X(15) VALUE "00900900       ".
    05 FILLER PIC X(100) VALUE "assets/minecraft/textures/gui/sprites/hud/heart/hardcore_half_blinking.png".
    05 FILLER PIC X(15) VALUE "00900900       ".
    05 FILLER PIC X(100) VALUE "assets/minecraft/textures/gui/sprites/hud/heart/absorbing_full.png".
    05 FILLER PIC X(15) VALUE "00900900       ".
    05 FILLER PIC X(100) VALUE "assets/minecraft/textures/gui/sprites/hud/heart/absorbing_full_blinking.png".
    05 FILLER PIC X(15) VALUE "00900900       ".
    05 FILLER PIC X(100) VALUE "assets/minecraft/textures/gui/sprites/hud/heart/absorbing_half.png".
    05 FILLER PIC X(15) VALUE "00900900       ".
    05 FILLER PIC X(100) VALUE "assets/minecraft/textures/gui/sprites/hud/heart/absorbing_half_blinking.png".
    05 FILLER PIC X(15) VALUE "00900900       ".
    05 FILLER PIC X(100) VALUE "assets/minecraft/textures/gui/sprites/hud/heart/poisoned_full.png".
    05 FILLER PIC X(15) VALUE "00900900       ".
    05 FILLER PIC X(100) VALUE "assets/minecraft/textures/gui/sprites/hud/heart/poisoned_full_blinking.png".
    05 FILLER PIC X(15) VALUE "00900900       ".
    05 FILLER PIC X(100) VALUE "assets/minecraft/textures/gui/sprites/hud/heart/poisoned_half.png".
    05 FILLER PIC X(15) VALUE "00900900       ".
    05 FILLER PIC X(100) VALUE "assets/minecraft/textures/gui/sprites/hud/heart/poisoned_half_blinking.png".
    05 FILLER PIC X(15) VALUE "00900900       ".
    05 FILLER PIC X(100) VALUE "assets/minecraft/textures/gui/sprites/hud/heart/withered_full.png".
    05 FILLER PIC X(15) VALUE "00900900       ".
    05 FILLER PIC X(100) VALUE "assets/minecraft/textures/gui/sprites/hud/heart/withered_full_blinking.png".
    05 FILLER PIC X(15) VALUE "00900900       ".
    05 FILLER PIC X(100) VALUE "assets/minecraft/textures/gui/sprites/hud/heart/withered_half.png".
    05 FILLER PIC X(15) VALUE "00900900       ".
    05 FILLER PIC X(100) VALUE "assets/minecraft/textures/gui/sprites/hud/heart/withered_half_blinking.png".
    05 FILLER PIC X(15) VALUE "00900900       ".
    05 FILLER PIC X(100) VALUE "assets/minecraft/textures/gui/sprites/hud/heart/frozen_full.png".
    05 FILLER PIC X(15) VALUE "00900900       ".
    05 FILLER PIC X(100) VALUE "assets/minecraft/textures/gui/sprites/hud/heart/frozen_full_blinking.png".
    05 FILLER PIC X(15) VALUE "00900900       ".
    05 FILLER PIC X(100) VALUE "assets/minecraft/textures/gui/sprites/hud/heart/frozen_half.png".
    05 FILLER PIC X(15) VALUE "00900900       ".
    05 FILLER PIC X(100) VALUE "assets/minecraft/textures/gui/sprites/hud/heart/frozen_half_blinking.png".
    05 FILLER PIC X(15) VALUE "00900900       ".
    05 FILLER PIC X(100) VALUE "assets/minecraft/textures/gui/sprites/hud/food_empty.png".
    05 FILLER PIC X(15) VALUE "00900900       ".
    05 FILLER PIC X(100) VALUE "assets/minecraft/textures/gui/sprites/hud/food_half.png".
    05 FILLER PIC X(15) VALUE "00900900       ".
    05 FILLER PIC X(100) VALUE "assets/minecraft/textures/gui/sprites/hud/food_full.png".
    05 FILLER PIC X(15) VALUE "00900900       ".
    05 FILLER PIC X(100) VALUE "assets/minecraft/textures/gui/sprites/hud/food_empty_hunger.png".
    05 FILLER PIC X(15) VALUE "00900900       ".
    05 FILLER PIC X(100) VALUE "assets/minecraft/textures/gui/sprites/hud/food_half_hunger.png".
    05 FILLER PIC X(15) VALUE "00900900       ".
    05 FILLER PIC X(100) VALUE "assets/minecraft/textures/gui/sprites/hud/food_full_hunger.png".
    05 FILLER PIC X(15) VALUE "00900900       ".
    05 FILLER PIC X(100) VALUE "assets/minecraft/textures/gui/sprites/hud/armor_empty.png".
    05 FILLER PIC X(15) VALUE "00900900       ".
    05 FILLER PIC X(100) VALUE "assets/minecraft/textures/gui/sprites/hud/armor_half.png".
    05 FILLER PIC X(15) VALUE "00900900       ".
    05 FILLER PIC X(100) VALUE "assets/minecraft/textures/gui/sprites/hud/armor_full.png".
    05 FILLER PIC X(15) VALUE "00900900       ".
    05 FILLER PIC X(100) VALUE "assets/minecraft/textures/gui/sprites/hud/air.png".
    05 FILLER PIC X(15) VALUE "00900900       ".
    05 FILLER PIC X(100) VALUE "assets/minecraft/textures/gui/sprites/hud/air_empty.png".
    05 FILLER PIC X(15) VALUE "00900900       ".
    05 FILLER PIC X(100) VALUE "assets/minecraft/textures/gui/sprites/hud/air_bursting.png".
    05 FILLER PIC X(15) VALUE "00900900       ".
    05 FILLER PIC X(100) VALUE "assets/minecraft/textures/gui/sprites/container/slot.png".
    05 FILLER PIC X(15) VALUE "01801800       ".
    05 FILLER PIC X(100) VALUE "assets/minecraft/textures/gui/sprites/container/slot_highlight_back.png".
    05 FILLER PIC X(15) VALUE "02402400       ".
    05 FILLER PIC X(100) VALUE "assets/minecraft/textures/gui/sprites/container/slot_highlight_front.png".
    05 FILLER PIC X(15) VALUE "02402400       ".
    05 FILLER PIC X(100) VALUE "assets/minecraft/textures/gui/sprites/container/slot/helmet.png".
    05 FILLER PIC X(15) VALUE "01601600       ".
    05 FILLER PIC X(100) VALUE "assets/minecraft/textures/gui/sprites/container/slot/chestplate.png".
    05 FILLER PIC X(15) VALUE "01601600       ".
    05 FILLER PIC X(100) VALUE "assets/minecraft/textures/gui/sprites/container/slot/leggings.png".
    05 FILLER PIC X(15) VALUE "01601600       ".
    05 FILLER PIC X(100) VALUE "assets/minecraft/textures/gui/sprites/container/slot/boots.png".
    05 FILLER PIC X(15) VALUE "01601600       ".
    05 FILLER PIC X(100) VALUE "assets/minecraft/textures/gui/sprites/container/slot/shield.png".
    05 FILLER PIC X(15) VALUE "01601600       ".
    05 FILLER PIC X(100) VALUE "assets/minecraft/textures/gui/sprites/widget/button.png".
    05 FILLER PIC X(15) VALUE "20002003       ".
    05 FILLER PIC X(100) VALUE "assets/minecraft/textures/gui/sprites/widget/button_highlighted.png".
    05 FILLER PIC X(15) VALUE "20002003       ".
    05 FILLER PIC X(100) VALUE "assets/minecraft/textures/gui/sprites/widget/button_disabled.png".
    05 FILLER PIC X(15) VALUE "20002002       ".
    05 FILLER PIC X(100) VALUE "assets/minecraft/textures/gui/sprites/widget/text_field.png".
    05 FILLER PIC X(15) VALUE "20002001       ".
    05 FILLER PIC X(100) VALUE "assets/minecraft/textures/gui/sprites/widget/text_field_highlighted.png".
    05 FILLER PIC X(15) VALUE "20002001       ".
    05 FILLER PIC X(100) VALUE "assets/minecraft/textures/gui/sprites/widget/slider.png".
    05 FILLER PIC X(15) VALUE "20002002       ".
    05 FILLER PIC X(100) VALUE "assets/minecraft/textures/gui/sprites/widget/slider_highlighted.png".
    05 FILLER PIC X(15) VALUE "20002002       ".
    05 FILLER PIC X(100) VALUE "assets/minecraft/textures/gui/sprites/widget/slider_handle.png".
    05 FILLER PIC X(15) VALUE "00802002       ".
    05 FILLER PIC X(100) VALUE "assets/minecraft/textures/gui/sprites/widget/slider_handle_highlighted.png".
    05 FILLER PIC X(15) VALUE "00802002       ".
    05 FILLER PIC X(100) VALUE "assets/minecraft/textures/gui/sprites/widget/checkbox.png".
    05 FILLER PIC X(15) VALUE "01701700       ".
    05 FILLER PIC X(100) VALUE "assets/minecraft/textures/gui/sprites/widget/checkbox_highlighted.png".
    05 FILLER PIC X(15) VALUE "01701700       ".
    05 FILLER PIC X(100) VALUE "assets/minecraft/textures/gui/sprites/widget/checkbox_selected.png".
    05 FILLER PIC X(15) VALUE "01701700       ".
    05 FILLER PIC X(100) VALUE "assets/minecraft/textures/gui/sprites/widget/checkbox_selected_highlighted.png".
    05 FILLER PIC X(15) VALUE "01701700       ".
    05 FILLER PIC X(100) VALUE "assets/minecraft/textures/gui/sprites/widget/scroller.png".
    05 FILLER PIC X(15) VALUE "00603202       ".
    05 FILLER PIC X(100) VALUE "assets/minecraft/textures/gui/sprites/widget/scroller_background.png".
    05 FILLER PIC X(15) VALUE "00603201       ".
    05 FILLER PIC X(100) VALUE "assets/minecraft/textures/gui/sprites/tooltip/background.png".
    05 FILLER PIC X(15) VALUE "10010009       ".
    05 FILLER PIC X(100) VALUE "assets/minecraft/textures/gui/sprites/tooltip/frame.png".
    05 FILLER PIC X(15) VALUE "10010009       ".
    05 FILLER PIC X(100) VALUE "assets/minecraft/textures/gui/sprites/popup/background.png".
    05 FILLER PIC X(15) VALUE "03203204       ".
    05 FILLER PIC X(100) VALUE "assets/minecraft/textures/gui/sprites/toast/recipe.png".
    05 FILLER PIC X(15) VALUE "16003200       ".
    05 FILLER PIC X(100) VALUE "assets/minecraft/textures/gui/sprites/recipe_book/button.png".
    05 FILLER PIC X(15) VALUE "02001800       ".
    05 FILLER PIC X(100) VALUE "assets/minecraft/textures/gui/sprites/recipe_book/button_highlighted.png".
    05 FILLER PIC X(15) VALUE "02001800       ".
    05 FILLER PIC X(100) VALUE "assets/minecraft/textures/gui/sprites/recipe_book/tab.png".
    05 FILLER PIC X(15) VALUE "03202700       ".
    05 FILLER PIC X(100) VALUE "assets/minecraft/textures/gui/sprites/recipe_book/tab_selected.png".
    05 FILLER PIC X(15) VALUE "03202700       ".
    05 FILLER PIC X(100) VALUE "assets/minecraft/textures/gui/sprites/recipe_book/slot_craftable.png".
    05 FILLER PIC X(15) VALUE "02502500       ".
    05 FILLER PIC X(100) VALUE "assets/minecraft/textures/gui/sprites/recipe_book/slot_many_craftable.png".
    05 FILLER PIC X(15) VALUE "02502500       ".
    05 FILLER PIC X(100) VALUE "assets/minecraft/textures/gui/sprites/recipe_book/slot_uncraftable.png".
    05 FILLER PIC X(15) VALUE "02502500       ".
    05 FILLER PIC X(100) VALUE "assets/minecraft/textures/gui/sprites/recipe_book/slot_many_uncraftable.png".
    05 FILLER PIC X(15) VALUE "02502500       ".
    05 FILLER PIC X(100) VALUE "assets/minecraft/textures/gui/sprites/recipe_book/page_forward.png".
    05 FILLER PIC X(15) VALUE "01201700       ".
    05 FILLER PIC X(100) VALUE "assets/minecraft/textures/gui/sprites/recipe_book/page_forward_highlighted.png".
    05 FILLER PIC X(15) VALUE "01201700       ".
    05 FILLER PIC X(100) VALUE "assets/minecraft/textures/gui/sprites/recipe_book/page_backward.png".
    05 FILLER PIC X(15) VALUE "01201700       ".
    05 FILLER PIC X(100) VALUE "assets/minecraft/textures/gui/sprites/recipe_book/page_backward_highlighted.png".
    05 FILLER PIC X(15) VALUE "01201700       ".
    05 FILLER PIC X(100) VALUE "assets/minecraft/textures/gui/sprites/recipe_book/filter_enabled.png".
    05 FILLER PIC X(15) VALUE "02601600       ".
    05 FILLER PIC X(100) VALUE "assets/minecraft/textures/gui/sprites/recipe_book/filter_enabled_highlighted.png".
    05 FILLER PIC X(15) VALUE "02601600       ".
    05 FILLER PIC X(100) VALUE "assets/minecraft/textures/gui/sprites/recipe_book/filter_disabled.png".
    05 FILLER PIC X(15) VALUE "02601600       ".
    05 FILLER PIC X(100) VALUE "assets/minecraft/textures/gui/sprites/recipe_book/filter_disabled_highlighted.png".
    05 FILLER PIC X(15) VALUE "02601600       ".
    05 FILLER PIC X(100) VALUE "assets/minecraft/textures/gui/sprites/recipe_book/overlay_recipe.png".
    05 FILLER PIC X(15) VALUE "03203204       ".
    05 FILLER PIC X(100) VALUE "assets/minecraft/textures/gui/sprites/recipe_book/crafting_overlay.png".
    05 FILLER PIC X(15) VALUE "02502500       ".
    05 FILLER PIC X(100) VALUE "assets/minecraft/textures/gui/sprites/recipe_book/crafting_overlay_highlighted.png".
    05 FILLER PIC X(15) VALUE "02502500       ".
    05 FILLER PIC X(100) VALUE "assets/minecraft/textures/gui/sprites/recipe_book/crafting_overlay_disabled.png".
    05 FILLER PIC X(15) VALUE "02502500       ".
    05 FILLER PIC X(100) VALUE "assets/minecraft/textures/gui/sprites/recipe_book/crafting_overlay_disabled_highlighted.png".
    05 FILLER PIC X(15) VALUE "02502500       ".
    05 FILLER PIC X(100) VALUE "assets/minecraft/textures/gui/menu_background.png".
    05 FILLER PIC X(15) VALUE "03203200       ".
    05 FILLER PIC X(100) VALUE "assets/minecraft/textures/gui/menu_list_background.png".
    05 FILLER PIC X(15) VALUE "03203200       ".
    05 FILLER PIC X(100) VALUE "assets/minecraft/textures/gui/header_separator.png".
    05 FILLER PIC X(15) VALUE "03200200       ".
    05 FILLER PIC X(100) VALUE "assets/minecraft/textures/gui/footer_separator.png".
    05 FILLER PIC X(15) VALUE "03200200       ".
    05 FILLER PIC X(100) VALUE "assets/minecraft/textures/gui/inworld_menu_background.png".
    05 FILLER PIC X(15) VALUE "03203200       ".
    05 FILLER PIC X(100) VALUE "assets/minecraft/textures/gui/inworld_menu_list_background.png".
    05 FILLER PIC X(15) VALUE "03203200       ".
    05 FILLER PIC X(100) VALUE "assets/minecraft/textures/gui/inworld_header_separator.png".
    05 FILLER PIC X(15) VALUE "03200200       ".
    05 FILLER PIC X(100) VALUE "assets/minecraft/textures/gui/inworld_footer_separator.png".
    05 FILLER PIC X(15) VALUE "03200200       ".
    05 FILLER PIC X(100) VALUE "assets/minecraft/textures/misc/unknown_pack.png".
    05 FILLER PIC X(15) VALUE "06406400       ".
    05 FILLER PIC X(100) VALUE "assets/minecraft/textures/block/destroy_stage_0.png".
    05 FILLER PIC X(15) VALUE "01601600       ".
    05 FILLER PIC X(100) VALUE "assets/minecraft/textures/block/destroy_stage_1.png".
    05 FILLER PIC X(15) VALUE "01601600       ".
    05 FILLER PIC X(100) VALUE "assets/minecraft/textures/block/destroy_stage_2.png".
    05 FILLER PIC X(15) VALUE "01601600       ".
    05 FILLER PIC X(100) VALUE "assets/minecraft/textures/block/destroy_stage_3.png".
    05 FILLER PIC X(15) VALUE "01601600       ".
    05 FILLER PIC X(100) VALUE "assets/minecraft/textures/block/destroy_stage_4.png".
    05 FILLER PIC X(15) VALUE "01601600       ".
    05 FILLER PIC X(100) VALUE "assets/minecraft/textures/block/destroy_stage_5.png".
    05 FILLER PIC X(15) VALUE "01601600       ".
    05 FILLER PIC X(100) VALUE "assets/minecraft/textures/block/destroy_stage_6.png".
    05 FILLER PIC X(15) VALUE "01601600       ".
    05 FILLER PIC X(100) VALUE "assets/minecraft/textures/block/destroy_stage_7.png".
    05 FILLER PIC X(15) VALUE "01601600       ".
    05 FILLER PIC X(100) VALUE "assets/minecraft/textures/block/destroy_stage_8.png".
    05 FILLER PIC X(15) VALUE "01601600       ".
    05 FILLER PIC X(100) VALUE "assets/minecraft/textures/block/destroy_stage_9.png".
    05 FILLER PIC X(15) VALUE "01601600       ".
    05 FILLER PIC X(100) VALUE "assets/minecraft/textures/block/destroy_oit_stage_0.png".
    05 FILLER PIC X(15) VALUE "01601600       ".
    05 FILLER PIC X(100) VALUE "assets/minecraft/textures/block/destroy_oit_stage_1.png".
    05 FILLER PIC X(15) VALUE "01601600       ".
    05 FILLER PIC X(100) VALUE "assets/minecraft/textures/block/destroy_oit_stage_2.png".
    05 FILLER PIC X(15) VALUE "01601600       ".
    05 FILLER PIC X(100) VALUE "assets/minecraft/textures/block/destroy_oit_stage_3.png".
    05 FILLER PIC X(15) VALUE "01601600       ".
    05 FILLER PIC X(100) VALUE "assets/minecraft/textures/block/destroy_oit_stage_4.png".
    05 FILLER PIC X(15) VALUE "01601600       ".
    05 FILLER PIC X(100) VALUE "assets/minecraft/textures/block/destroy_oit_stage_5.png".
    05 FILLER PIC X(15) VALUE "01601600       ".
    05 FILLER PIC X(100) VALUE "assets/minecraft/textures/block/destroy_oit_stage_6.png".
    05 FILLER PIC X(15) VALUE "01601600       ".
    05 FILLER PIC X(100) VALUE "assets/minecraft/textures/block/destroy_oit_stage_7.png".
    05 FILLER PIC X(15) VALUE "01601600       ".
    05 FILLER PIC X(100) VALUE "assets/minecraft/textures/block/destroy_oit_stage_8.png".
    05 FILLER PIC X(15) VALUE "01601600       ".
    05 FILLER PIC X(100) VALUE "assets/minecraft/textures/block/destroy_oit_stage_9.png".
    05 FILLER PIC X(15) VALUE "01601600       ".
    05 FILLER PIC X(100) VALUE "assets/minecraft/textures/gui/container/inventory.png".
    05 FILLER PIC X(15) VALUE "25625600       ".
    05 FILLER PIC X(100) VALUE "assets/minecraft/textures/gui/container/crafting_table.png".
    05 FILLER PIC X(15) VALUE "25625600       ".
    05 FILLER PIC X(100) VALUE "assets/minecraft/textures/gui/recipe_book.png".
    05 FILLER PIC X(15) VALUE "25625600       ".
 01 BG-SPRITE-TABLE REDEFINES BG-SPRITE-DATA.
    05 BG-SPRITE OCCURS 134 TIMES.
       10 BG-PATH          PIC X(100).
       10 BG-W             PIC 999.
       10 BG-H             PIC 999.
       10 BG-B             PIC 99.
       10 FILLER           PIC X(7).
 01 BG-NAME-DATA.
    05 FILLER PIC X(40) VALUE "hotbar".
    05 FILLER PIC X(40) VALUE "hotbar_selection".
    05 FILLER PIC X(40) VALUE "hotbar_offhand_left".
    05 FILLER PIC X(40) VALUE "hotbar_offhand_right".
    05 FILLER PIC X(40) VALUE "hotbar_attack_indicator_background".
    05 FILLER PIC X(40) VALUE "hotbar_attack_indicator_progress".
    05 FILLER PIC X(40) VALUE "crosshair".
    05 FILLER PIC X(40) VALUE "crosshair_attack_indicator_background".
    05 FILLER PIC X(40) VALUE "crosshair_attack_indicator_progress".
    05 FILLER PIC X(40) VALUE "crosshair_attack_indicator_full".
    05 FILLER PIC X(40) VALUE "experience_bar_background".
    05 FILLER PIC X(40) VALUE "experience_bar_progress".
    05 FILLER PIC X(40) VALUE "effect_background".
    05 FILLER PIC X(40) VALUE "effect_background_ambient".
    05 FILLER PIC X(40) VALUE "container".
    05 FILLER PIC X(40) VALUE "container_hardcore".
    05 FILLER PIC X(40) VALUE "container_blinking".
    05 FILLER PIC X(40) VALUE "container_hardcore_blinking".
    05 FILLER PIC X(40) VALUE "full".
    05 FILLER PIC X(40) VALUE "full_blinking".
    05 FILLER PIC X(40) VALUE "half".
    05 FILLER PIC X(40) VALUE "half_blinking".
    05 FILLER PIC X(40) VALUE "hardcore_full".
    05 FILLER PIC X(40) VALUE "hardcore_full_blinking".
    05 FILLER PIC X(40) VALUE "hardcore_half".
    05 FILLER PIC X(40) VALUE "hardcore_half_blinking".
    05 FILLER PIC X(40) VALUE "absorbing_full".
    05 FILLER PIC X(40) VALUE "absorbing_full_blinking".
    05 FILLER PIC X(40) VALUE "absorbing_half".
    05 FILLER PIC X(40) VALUE "absorbing_half_blinking".
    05 FILLER PIC X(40) VALUE "poisoned_full".
    05 FILLER PIC X(40) VALUE "poisoned_full_blinking".
    05 FILLER PIC X(40) VALUE "poisoned_half".
    05 FILLER PIC X(40) VALUE "poisoned_half_blinking".
    05 FILLER PIC X(40) VALUE "withered_full".
    05 FILLER PIC X(40) VALUE "withered_full_blinking".
    05 FILLER PIC X(40) VALUE "withered_half".
    05 FILLER PIC X(40) VALUE "withered_half_blinking".
    05 FILLER PIC X(40) VALUE "frozen_full".
    05 FILLER PIC X(40) VALUE "frozen_full_blinking".
    05 FILLER PIC X(40) VALUE "frozen_half".
    05 FILLER PIC X(40) VALUE "frozen_half_blinking".
    05 FILLER PIC X(40) VALUE "food_empty".
    05 FILLER PIC X(40) VALUE "food_half".
    05 FILLER PIC X(40) VALUE "food_full".
    05 FILLER PIC X(40) VALUE "food_empty_hunger".
    05 FILLER PIC X(40) VALUE "food_half_hunger".
    05 FILLER PIC X(40) VALUE "food_full_hunger".
    05 FILLER PIC X(40) VALUE "armor_empty".
    05 FILLER PIC X(40) VALUE "armor_half".
    05 FILLER PIC X(40) VALUE "armor_full".
    05 FILLER PIC X(40) VALUE "air".
    05 FILLER PIC X(40) VALUE "air_empty".
    05 FILLER PIC X(40) VALUE "air_bursting".
    05 FILLER PIC X(40) VALUE "slot".
    05 FILLER PIC X(40) VALUE "slot_highlight_back".
    05 FILLER PIC X(40) VALUE "slot_highlight_front".
    05 FILLER PIC X(40) VALUE "helmet".
    05 FILLER PIC X(40) VALUE "chestplate".
    05 FILLER PIC X(40) VALUE "leggings".
    05 FILLER PIC X(40) VALUE "boots".
    05 FILLER PIC X(40) VALUE "shield".
    05 FILLER PIC X(40) VALUE "button".
    05 FILLER PIC X(40) VALUE "button_highlighted".
    05 FILLER PIC X(40) VALUE "button_disabled".
    05 FILLER PIC X(40) VALUE "text_field".
    05 FILLER PIC X(40) VALUE "text_field_highlighted".
    05 FILLER PIC X(40) VALUE "slider".
    05 FILLER PIC X(40) VALUE "slider_highlighted".
    05 FILLER PIC X(40) VALUE "slider_handle".
    05 FILLER PIC X(40) VALUE "slider_handle_highlighted".
    05 FILLER PIC X(40) VALUE "checkbox".
    05 FILLER PIC X(40) VALUE "checkbox_highlighted".
    05 FILLER PIC X(40) VALUE "checkbox_selected".
    05 FILLER PIC X(40) VALUE "checkbox_selected_highlighted".
    05 FILLER PIC X(40) VALUE "scroller".
    05 FILLER PIC X(40) VALUE "scroller_background".
    05 FILLER PIC X(40) VALUE "background".
    05 FILLER PIC X(40) VALUE "frame".
    05 FILLER PIC X(40) VALUE "background".
    05 FILLER PIC X(40) VALUE "recipe".
    05 FILLER PIC X(40) VALUE "button".
    05 FILLER PIC X(40) VALUE "button_highlighted".
    05 FILLER PIC X(40) VALUE "tab".
    05 FILLER PIC X(40) VALUE "tab_selected".
    05 FILLER PIC X(40) VALUE "slot_craftable".
    05 FILLER PIC X(40) VALUE "slot_many_craftable".
    05 FILLER PIC X(40) VALUE "slot_uncraftable".
    05 FILLER PIC X(40) VALUE "slot_many_uncraftable".
    05 FILLER PIC X(40) VALUE "page_forward".
    05 FILLER PIC X(40) VALUE "page_forward_highlighted".
    05 FILLER PIC X(40) VALUE "page_backward".
    05 FILLER PIC X(40) VALUE "page_backward_highlighted".
    05 FILLER PIC X(40) VALUE "filter_enabled".
    05 FILLER PIC X(40) VALUE "filter_enabled_highlighted".
    05 FILLER PIC X(40) VALUE "filter_disabled".
    05 FILLER PIC X(40) VALUE "filter_disabled_highlighted".
    05 FILLER PIC X(40) VALUE "overlay_recipe".
    05 FILLER PIC X(40) VALUE "crafting_overlay".
    05 FILLER PIC X(40) VALUE "crafting_overlay_highlighted".
    05 FILLER PIC X(40) VALUE "crafting_overlay_disabled".
    05 FILLER PIC X(40) VALUE "crafting_overlay_disabled_highlighted".
    05 FILLER PIC X(40) VALUE "menu_background".
    05 FILLER PIC X(40) VALUE "menu_list_background".
    05 FILLER PIC X(40) VALUE "header_separator".
    05 FILLER PIC X(40) VALUE "footer_separator".
    05 FILLER PIC X(40) VALUE "inworld_menu_background".
    05 FILLER PIC X(40) VALUE "inworld_menu_list_background".
    05 FILLER PIC X(40) VALUE "inworld_header_separator".
    05 FILLER PIC X(40) VALUE "inworld_footer_separator".
    05 FILLER PIC X(40) VALUE "unknown_pack".
    05 FILLER PIC X(40) VALUE "destroy_stage_0".
    05 FILLER PIC X(40) VALUE "destroy_stage_1".
    05 FILLER PIC X(40) VALUE "destroy_stage_2".
    05 FILLER PIC X(40) VALUE "destroy_stage_3".
    05 FILLER PIC X(40) VALUE "destroy_stage_4".
    05 FILLER PIC X(40) VALUE "destroy_stage_5".
    05 FILLER PIC X(40) VALUE "destroy_stage_6".
    05 FILLER PIC X(40) VALUE "destroy_stage_7".
    05 FILLER PIC X(40) VALUE "destroy_stage_8".
    05 FILLER PIC X(40) VALUE "destroy_stage_9".
    05 FILLER PIC X(40) VALUE "destroy_oit_stage_0".
    05 FILLER PIC X(40) VALUE "destroy_oit_stage_1".
    05 FILLER PIC X(40) VALUE "destroy_oit_stage_2".
    05 FILLER PIC X(40) VALUE "destroy_oit_stage_3".
    05 FILLER PIC X(40) VALUE "destroy_oit_stage_4".
    05 FILLER PIC X(40) VALUE "destroy_oit_stage_5".
    05 FILLER PIC X(40) VALUE "destroy_oit_stage_6".
    05 FILLER PIC X(40) VALUE "destroy_oit_stage_7".
    05 FILLER PIC X(40) VALUE "destroy_oit_stage_8".
    05 FILLER PIC X(40) VALUE "destroy_oit_stage_9".
    05 FILLER PIC X(40) VALUE "inventory".
    05 FILLER PIC X(40) VALUE "crafting_table".
    05 FILLER PIC X(40) VALUE "recipe_book".
 01 BG-NAME-TABLE REDEFINES BG-NAME-DATA.
    05 BG-NAME OCCURS 134 TIMES PIC X(40).
 01 BG-OP-DATA.
    05 FILLER PIC X(58) VALUE "001BV1820220010010000001A1A1AFF45454FFF1F1F25FF2B2B33FF000".
    05 FILLER PIC X(58) VALUE "001FR00200201801800100014141AFF55556AFF1F1F25FF--------000".
    05 FILLER PIC X(58) VALUE "001FR02200201801800100014141AFF55556AFF1F1F25FF--------000".
    05 FILLER PIC X(58) VALUE "001FR04200201801800100014141AFF55556AFF1F1F25FF--------000".
    05 FILLER PIC X(58) VALUE "001FR06200201801800100014141AFF55556AFF1F1F25FF--------000".
    05 FILLER PIC X(58) VALUE "001FR08200201801800100014141AFF55556AFF1F1F25FF--------000".
    05 FILLER PIC X(58) VALUE "001FR10200201801800100014141AFF55556AFF1F1F25FF--------000".
    05 FILLER PIC X(58) VALUE "001FR12200201801800100014141AFF55556AFF1F1F25FF--------000".
    05 FILLER PIC X(58) VALUE "001FR14200201801800100014141AFF55556AFF1F1F25FF--------000".
    05 FILLER PIC X(58) VALUE "001FR16200201801800100014141AFF55556AFF1F1F25FF--------000".
    05 FILLER PIC X(58) VALUE "002RG000000023022002000FFFFFFFF------------------------000".
    05 FILLER PIC X(58) VALUE "002PX00000000000000000000000000------------------------000".
    05 FILLER PIC X(58) VALUE "002PX02300000000000000000000000------------------------000".
    05 FILLER PIC X(58) VALUE "002PX00002200000000000000000000------------------------000".
    05 FILLER PIC X(58) VALUE "002PX02302200000000000000000000------------------------000".
    05 FILLER PIC X(58) VALUE "003BV0290240010010000001A1A1AFF45454FFF1F1F25FF2B2B33FF000".
    05 FILLER PIC X(58) VALUE "003FR00200301801800100014141AFF55556AFF1F1F25FF--------000".
    05 FILLER PIC X(58) VALUE "004BV0290240010010000001A1A1AFF45454FFF1F1F25FF2B2B33FF000".
    05 FILLER PIC X(58) VALUE "004FR00900301801800100014141AFF55556AFF1F1F25FF--------000".
    05 FILLER PIC X(58) VALUE "005BV0180180010010000001A1A1AFF45454FFF1F1F25FF2B2B33FF000".
    05 FILLER PIC X(58) VALUE "006RC002002015015000000E6E1CFFF------------------------000".
    05 FILLER PIC X(58) VALUE "006RC002002015002000000FFFFFFFF------------------------000".
    05 FILLER PIC X(58) VALUE "007LN000007014007001000FFFFFFFF------------------------000".
    05 FILLER PIC X(58) VALUE "007LN007000007014001000FFFFFFFF------------------------000".
    05 FILLER PIC X(58) VALUE "008RC0000060150090000001A1A1A99------------------------000".
    05 FILLER PIC X(58) VALUE "009RC001007014008000000FFFFFFFF------------------------000".
    05 FILLER PIC X(58) VALUE "010RC000006015009000000FFFFFFFF------------------------000".
    05 FILLER PIC X(58) VALUE "010RC001007014008000000F4EFDDFF------------------------000".
    05 FILLER PIC X(58) VALUE "011RC0000001810040000001A1A1AFF------------------------000".
    05 FILLER PIC X(58) VALUE "011RC0010011800030000003A3A44FF------------------------000".
    05 FILLER PIC X(58) VALUE "012RC0000001810040000005FBF2AFF------------------------000".
    05 FILLER PIC X(58) VALUE "012RC000000181000000000A8E86AFF------------------------000".
    05 FILLER PIC X(58) VALUE "012RC0000041810040000003E8A1CFF------------------------000".
    05 FILLER PIC X(58) VALUE "013BV0240240010010000001A1A1AFF7FA9C9FF24425AFF3E6C8FFF000".
    05 FILLER PIC X(58) VALUE "014BV0240240010010000001A1A1AFFA58BE0FF3B2F5CFF6A4FB3FF000".
    05 FILLER PIC X(58) VALUE "015AR0000080000000000001A1A1AFF3C2323FF3C2323FF3C2323FF001".
    05 FILLER PIC X(58) VALUE "016AR0000080000000000001A1A1AFF2E2236FF2E2236FF2E2236FF001".
    05 FILLER PIC X(58) VALUE "017AR000008000000000000FFFFFFFF5A3A3AFF5A3A3AFF5A3A3AFF001".
    05 FILLER PIC X(58) VALUE "018AR000008000000000000FFFFFFFF4A3A55FF4A3A55FF4A3A55FF001".
    05 FILLER PIC X(58) VALUE "019AR0000080000000000001A1A1AFFFF8A80FFD8362FFF9E1F1FFF001".
    05 FILLER PIC X(58) VALUE "020AR000008000000000000FFFFFFFFFFD0CCFFFF6A62FFD8362FFF001".
    05 FILLER PIC X(58) VALUE "021AR0000040000000000001A1A1AFFFF8A80FFD8362FFF9E1F1FFF001".
    05 FILLER PIC X(58) VALUE "021AR0050080000000000001A1A1AFF3C2323FF3C2323FF3C2323FF001".
    05 FILLER PIC X(58) VALUE "022AR000004000000000000FFFFFFFFFFD0CCFFFF6A62FFD8362FFF001".
    05 FILLER PIC X(58) VALUE "022AR005008000000000000FFFFFFFF5A3A3AFF5A3A3AFF5A3A3AFF001".
    05 FILLER PIC X(58) VALUE "023AR0000080000000000001A1A1AFFE08AD6FFA02A8FFF6A1B60FF001".
    05 FILLER PIC X(58) VALUE "024AR000008000000000000FFFFFFFFFFBAFFFFD05ABFFF9A4B90FF001".
    05 FILLER PIC X(58) VALUE "025AR0000040000000000001A1A1AFFE08AD6FFA02A8FFF6A1B60FF001".
    05 FILLER PIC X(58) VALUE "025AR0050080000000000001A1A1AFF2E2236FF2E2236FF2E2236FF001".
    05 FILLER PIC X(58) VALUE "026AR000004000000000000FFFFFFFFFFBAFFFFD05ABFFF9A4B90FF001".
    05 FILLER PIC X(58) VALUE "026AR005008000000000000FFFFFFFF4A3A55FF4A3A55FF4A3A55FF001".
    05 FILLER PIC X(58) VALUE "027AR0000080000000000001A1A1AFFFFE680FFE6B422FFA8801AFF001".
    05 FILLER PIC X(58) VALUE "028AR000008000000000000FFFFFFFFFFFFB0FFFFE452FFD8B04AFF001".
    05 FILLER PIC X(58) VALUE "029AR0000040000000000001A1A1AFFFFE680FFE6B422FFA8801AFF001".
    05 FILLER PIC X(58) VALUE "029AR0050080000000000001A1A1AFF3C2323FF3C2323FF3C2323FF001".
    05 FILLER PIC X(58) VALUE "030AR000004000000000000FFFFFFFFFFFFB0FFFFE452FFD8B04AFF001".
    05 FILLER PIC X(58) VALUE "030AR005008000000000000FFFFFFFF5A3A3AFF5A3A3AFF5A3A3AFF001".
    05 FILLER PIC X(58) VALUE "031AR0000080000000000001A1A1AFFB5D55AFF6B8E23FF4A6516FF001".
    05 FILLER PIC X(58) VALUE "032AR000008000000000000FFFFFFFFE5FF8AFF9BBE53FF7A9546FF001".
    05 FILLER PIC X(58) VALUE "033AR0000040000000000001A1A1AFFB5D55AFF6B8E23FF4A6516FF001".
    05 FILLER PIC X(58) VALUE "033AR0050080000000000001A1A1AFF3C2323FF3C2323FF3C2323FF001".
    05 FILLER PIC X(58) VALUE "034AR000004000000000000FFFFFFFFE5FF8AFF9BBE53FF7A9546FF001".
    05 FILLER PIC X(58) VALUE "034AR005008000000000000FFFFFFFF5A3A3AFF5A3A3AFF5A3A3AFF001".
    05 FILLER PIC X(58) VALUE "035AR0000080000000000001A1A1AFF7A7A7AFF3A3A3AFF1F1F1FFF001".
    05 FILLER PIC X(58) VALUE "036AR000008000000000000FFFFFFFFAAAAAAFF6A6A6AFF4F4F4FFF001".
    05 FILLER PIC X(58) VALUE "037AR0000040000000000001A1A1AFF7A7A7AFF3A3A3AFF1F1F1FFF001".
    05 FILLER PIC X(58) VALUE "037AR0050080000000000001A1A1AFF3C2323FF3C2323FF3C2323FF001".
    05 FILLER PIC X(58) VALUE "038AR000004000000000000FFFFFFFFAAAAAAFF6A6A6AFF4F4F4FFF001".
    05 FILLER PIC X(58) VALUE "038AR005008000000000000FFFFFFFF5A3A3AFF5A3A3AFF5A3A3AFF001".
    05 FILLER PIC X(58) VALUE "039AR0000080000000000001A1A1AFFD2F0FFFF6FC3E8FF3F8FB5FF001".
    05 FILLER PIC X(58) VALUE "040AR000008000000000000FFFFFFFFFFFFFFFF9FF3FFFF6FBFE5FF001".
    05 FILLER PIC X(58) VALUE "041AR0000040000000000001A1A1AFFD2F0FFFF6FC3E8FF3F8FB5FF001".
    05 FILLER PIC X(58) VALUE "041AR0050080000000000001A1A1AFF3C2323FF3C2323FF3C2323FF001".
    05 FILLER PIC X(58) VALUE "042AR000004000000000000FFFFFFFFFFFFFFFF9FF3FFFF6FBFE5FF001".
    05 FILLER PIC X(58) VALUE "042AR005008000000000000FFFFFFFF5A3A3AFF5A3A3AFF5A3A3AFF001".
    05 FILLER PIC X(58) VALUE "043AR0000080000000000001A1A1AFF2E2622FF2E2622FF4A4540FF002".
    05 FILLER PIC X(58) VALUE "044AR0000040000000000001A1A1AFFC0703AFFE8A56AFFEDE6CFFF002".
    05 FILLER PIC X(58) VALUE "044AR0050080000000000001A1A1AFF2E2622FF2E2622FF4A4540FF002".
    05 FILLER PIC X(58) VALUE "045AR0000080000000000001A1A1AFFC0703AFFE8A56AFFEDE6CFFF002".
    05 FILLER PIC X(58) VALUE "046AR0000080000000000001A1A1AFF2A2E22FF2A2E22FF4A4A40FF002".
    05 FILLER PIC X(58) VALUE "047AR0000040000000000001A1A1AFF7C8A3AFFB0BE6AFFC9C9A8FF002".
    05 FILLER PIC X(58) VALUE "047AR0050080000000000001A1A1AFF2A2E22FF2A2E22FF4A4A40FF002".
    05 FILLER PIC X(58) VALUE "048AR0000080000000000001A1A1AFF7C8A3AFFB0BE6AFFC9C9A8FF002".
    05 FILLER PIC X(58) VALUE "049AR0000080000000000001A1A1AFF2D3036FF2D3036FF2D3036FF003".
    05 FILLER PIC X(58) VALUE "050AR0000040000000000001A1A1AFFC7CED6FFF2F5F8FF8E98A3FF003".
    05 FILLER PIC X(58) VALUE "050AR0050080000000000001A1A1AFF2D3036FF2D3036FF2D3036FF003".
    05 FILLER PIC X(58) VALUE "051AR0000080000000000001A1A1AFFC7CED6FFF2F5F8FF8E98A3FF003".
    05 FILLER PIC X(58) VALUE "052AR0000080000000000001A1A1AFF7FB8E8FFE6F6FFFF--------004".
    05 FILLER PIC X(58) VALUE "053AR0000080000000000003A5A78FF------------------------004".
    05 FILLER PIC X(58) VALUE "054AR000008000000000000E6F6FFFF------------------------005".
    05 FILLER PIC X(58) VALUE "055FR0000000180180010005E5740FFF4EFDDFFA39A7AFF--------000".
    05 FILLER PIC X(58) VALUE "056RG002002021021002000FFFFFF40------------------------000".
    05 FILLER PIC X(58) VALUE "057RC004004019019000000FFFFFF66------------------------000".
    05 FILLER PIC X(58) VALUE "058AR0000150000000000006F674DFF------------------------006".
    05 FILLER PIC X(58) VALUE "059AR0000150000000000006F674DFF------------------------007".
    05 FILLER PIC X(58) VALUE "060AR0000150000000000006F674DFF------------------------008".
    05 FILLER PIC X(58) VALUE "061AR0000150000000000006F674DFF------------------------009".
    05 FILLER PIC X(58) VALUE "062AR0000150000000000006F674DFF------------------------010".
    05 FILLER PIC X(58) VALUE "063BV2000200010010000001A1A1AFF7FA9C9FF24425AFF3E6C8FFF000".
    05 FILLER PIC X(58) VALUE "064BV200020001001000000FFFFFFFFA3C6E0FF2F5876FF4F82A8FF000".
    05 FILLER PIC X(58) VALUE "065BV2000200010010000001A1A1AFF555B62FF2A2D31FF3A3F45FF000".
    05 FILLER PIC X(58) VALUE "066BV2000200000000000006B6B75FF14141AFF14141AFF14141AFF000".
    05 FILLER PIC X(58) VALUE "067BV200020000000000000FFFFFFFF14141AFF14141AFF14141AFF000".
    05 FILLER PIC X(58) VALUE "068BV2000200010010000001A1A1AFF0B0B10FF4A4A56FF14141AFF000".
    05 FILLER PIC X(58) VALUE "069BV200020001001000000FFFFFFFF0B0B10FF4A4A56FF14141AFF000".
    05 FILLER PIC X(58) VALUE "070BV0080200010010000001A1A1AFF7FA9C9FF24425AFF3E6C8FFF000".
    05 FILLER PIC X(58) VALUE "071BV008020001001000000FFFFFFFFA3C6E0FF2F5876FF4F82A8FF000".
    05 FILLER PIC X(58) VALUE "072BV0170170010000000001A1A1AFF0B0B10FF4A4A56FF14141AFF000".
    05 FILLER PIC X(58) VALUE "073BV017017001000000000FFFFFFFF0B0B10FF4A4A56FF14141AFF000".
    05 FILLER PIC X(58) VALUE "074CP000000000000000000--------------------------------072".
    05 FILLER PIC X(58) VALUE "074LN0030070060100020007CD33AFF------------------------000".
    05 FILLER PIC X(58) VALUE "074LN0060100120040020007CD33AFF------------------------000".
    05 FILLER PIC X(58) VALUE "075CP000000000000000000--------------------------------073".
    05 FILLER PIC X(58) VALUE "075LN0030070060100020007CD33AFF------------------------000".
    05 FILLER PIC X(58) VALUE "075LN0060100120040020007CD33AFF------------------------000".
    05 FILLER PIC X(58) VALUE "076BV0060320010000000001A1A1AFF7FA9C9FF24425AFF3E6C8FFF000".
    05 FILLER PIC X(58) VALUE "077FL00000000000000000000000066------------------------000".
    05 FILLER PIC X(58) VALUE "078RC00700709209200000016121FF0------------------------000".
    05 FILLER PIC X(58) VALUE "078PX00700700000000000000000000------------------------000".
    05 FILLER PIC X(58) VALUE "078PX09200700000000000000000000------------------------000".
    05 FILLER PIC X(58) VALUE "078PX00709200000000000000000000------------------------000".
    05 FILLER PIC X(58) VALUE "078PX09209200000000000000000000------------------------000".
    05 FILLER PIC X(58) VALUE "079RG0070070920920010006A4FB3FF------------------------000".
    05 FILLER PIC X(58) VALUE "079RG0080080910910010003B2F5CFF------------------------000".
    05 FILLER PIC X(58) VALUE "079PX00700700000000000000000000------------------------000".
    05 FILLER PIC X(58) VALUE "079PX09200700000000000000000000------------------------000".
    05 FILLER PIC X(58) VALUE "079PX00709200000000000000000000------------------------000".
    05 FILLER PIC X(58) VALUE "079PX09209200000000000000000000------------------------000".
    05 FILLER PIC X(58) VALUE "080BV0320320010010000001A1A1AFF45454FFF1F1F25FF2B2B33FF000".
    05 FILLER PIC X(58) VALUE "081BV1600320010010000002A2A2AFFF4EFDDFF8C8366FFD8D0B4FF000".
    05 FILLER PIC X(58) VALUE "082BV0200180010010000001A1A1AFF7FA9C9FF24425AFF3E6C8FFF000".
    05 FILLER PIC X(58) VALUE "082RC005004014013000000F4EFDDFF------------------------000".
    05 FILLER PIC X(58) VALUE "082RC0090040100130000003B2F5CFF------------------------000".
    05 FILLER PIC X(58) VALUE "083BV020018001001000000FFFFFFFFA3C6E0FF2F5876FF4F82A8FF000".
    05 FILLER PIC X(58) VALUE "083RC005004014013000000F4EFDDFF------------------------000".
    05 FILLER PIC X(58) VALUE "083RC0090040100130000003B2F5CFF------------------------000".
    05 FILLER PIC X(58) VALUE "084BV0320270010010000001A1A1AFFC9C2A5FF6F674DFFA39A7AFF000".
    05 FILLER PIC X(58) VALUE "085BV0320270010010000002A2A2AFFF4EFDDFF8C8366FFD8D0B4FF000".
    05 FILLER PIC X(58) VALUE "086BV0250250010010000001A1A1AFF5E5740FFF4EFDDFFA39A7AFF000".
    05 FILLER PIC X(58) VALUE "087CP000000000000000000--------------------------------086".
    05 FILLER PIC X(58) VALUE "087TR018023023023023018F4EFDDFF------------------------000".
    05 FILLER PIC X(58) VALUE "088BV0250250010010000001A1A1AFF6A3B36FFC98A82FFA0645CFF000".
    05 FILLER PIC X(58) VALUE "089CP000000000000000000--------------------------------088".
    05 FILLER PIC X(58) VALUE "089TR018023023023023018F4EFDDFF------------------------000".
    05 FILLER PIC X(58) VALUE "090TR0040040040140100091A1A1AFF------------------------000".
    05 FILLER PIC X(58) VALUE "090TR003003003013009008F4EFDDFF------------------------000".
    05 FILLER PIC X(58) VALUE "091TR0040040040140100091A1A1AFF------------------------000".
    05 FILLER PIC X(58) VALUE "091TR003003003013009008FFFFFFFF------------------------000".
    05 FILLER PIC X(58) VALUE "092TR0090040090140030091A1A1AFF------------------------000".
    05 FILLER PIC X(58) VALUE "092TR008003008013002008F4EFDDFF------------------------000".
    05 FILLER PIC X(58) VALUE "093TR0090040090140030091A1A1AFF------------------------000".
    05 FILLER PIC X(58) VALUE "093TR008003008013002008FFFFFFFF------------------------000".
    05 FILLER PIC X(58) VALUE "094BV0260160010010000001A1A1AFF7FC066FF2F5E22FF4F8F3AFF000".
    05 FILLER PIC X(58) VALUE "094TR008004017004012011F4EFDDFF------------------------000".
    05 FILLER PIC X(58) VALUE "095BV026016001001000000FFFFFFFF7FC066FF2F5E22FF4F8F3AFF000".
    05 FILLER PIC X(58) VALUE "095TR008004017004012011F4EFDDFF------------------------000".
    05 FILLER PIC X(58) VALUE "096BV0260160010010000001A1A1AFF7FA9C9FF24425AFF3E6C8FFF000".
    05 FILLER PIC X(58) VALUE "096TR008004017004012011F4EFDDFF------------------------000".
    05 FILLER PIC X(58) VALUE "097BV026016001001000000FFFFFFFF7FA9C9FF24425AFF3E6C8FFF000".
    05 FILLER PIC X(58) VALUE "097TR008004017004012011F4EFDDFF------------------------000".
    05 FILLER PIC X(58) VALUE "098BV0320320010010000002A2A2AFFF4EFDDFF8C8366FFD8D0B4FF000".
    05 FILLER PIC X(58) VALUE "099BV0250250010010000001A1A1AFF7FA9C9FF24425AFF3E6C8FFF000".
    05 FILLER PIC X(58) VALUE "100BV025025001001000000FFFFFFFFA3C6E0FF2F5876FF4F82A8FF000".
    05 FILLER PIC X(58) VALUE "101BV0250250010010000001A1A1AFF555B62FF2A2D31FF3A3F45FF000".
    05 FILLER PIC X(58) VALUE "102BV025025001001000000FFFFFFFF555B62FF2A2D31FF3A3F45FF000".
    05 FILLER PIC X(58) VALUE "103NZ0120060000000000001E1E26FF262630FF16161CFF--------000".
    05 FILLER PIC X(58) VALUE "104NZ010005000000000000101016FF17171EFF0B0B10FF--------000".
    05 FILLER PIC X(58) VALUE "105RC0000000310000000000B0B10FF------------------------000".
    05 FILLER PIC X(58) VALUE "105RC0000010310010000004A4A56FF------------------------000".
    05 FILLER PIC X(58) VALUE "106RC0000000310000000004A4A56FF------------------------000".
    05 FILLER PIC X(58) VALUE "106RC0000010310010000000B0B10FF------------------------000".
    05 FILLER PIC X(58) VALUE "107CP000000000000000000--------------------------------103".
    05 FILLER PIC X(58) VALUE "107AA204000000000000000--------------------------------000".
    05 FILLER PIC X(58) VALUE "108CP000000000000000000--------------------------------104".
    05 FILLER PIC X(58) VALUE "108AA153000000000000000--------------------------------000".
    05 FILLER PIC X(58) VALUE "109CP000000000000000000--------------------------------105".
    05 FILLER PIC X(58) VALUE "109AA153000000000000000--------------------------------000".
    05 FILLER PIC X(58) VALUE "110CP000000000000000000--------------------------------106".
    05 FILLER PIC X(58) VALUE "110AA153000000000000000--------------------------------000".
    05 FILLER PIC X(58) VALUE "111UP000000000000000000--------------------------------000".
    05 FILLER PIC X(58) VALUE "112CR000000000000000000--------------------------------000".
    05 FILLER PIC X(58) VALUE "113CR001000000000000000--------------------------------000".
    05 FILLER PIC X(58) VALUE "114CR002000000000000000--------------------------------000".
    05 FILLER PIC X(58) VALUE "115CR003000000000000000--------------------------------000".
    05 FILLER PIC X(58) VALUE "116CR004000000000000000--------------------------------000".
    05 FILLER PIC X(58) VALUE "117CR005000000000000000--------------------------------000".
    05 FILLER PIC X(58) VALUE "118CR006000000000000000--------------------------------000".
    05 FILLER PIC X(58) VALUE "119CR007000000000000000--------------------------------000".
    05 FILLER PIC X(58) VALUE "120CR008000000000000000--------------------------------000".
    05 FILLER PIC X(58) VALUE "121CR009000000000000000--------------------------------000".
    05 FILLER PIC X(58) VALUE "122CP000000000000000000--------------------------------112".
    05 FILLER PIC X(58) VALUE "123CP000000000000000000--------------------------------113".
    05 FILLER PIC X(58) VALUE "124CP000000000000000000--------------------------------114".
    05 FILLER PIC X(58) VALUE "125CP000000000000000000--------------------------------115".
    05 FILLER PIC X(58) VALUE "126CP000000000000000000--------------------------------116".
    05 FILLER PIC X(58) VALUE "127CP000000000000000000--------------------------------117".
    05 FILLER PIC X(58) VALUE "128CP000000000000000000--------------------------------118".
    05 FILLER PIC X(58) VALUE "129CP000000000000000000--------------------------------119".
    05 FILLER PIC X(58) VALUE "130CP000000000000000000--------------------------------120".
    05 FILLER PIC X(58) VALUE "131CP000000000000000000--------------------------------121".
    05 FILLER PIC X(58) VALUE "132BV1761660020010000002A2A2AFFF4EFDDFF8C8366FFD8D0B4FF000".
    05 FILLER PIC X(58) VALUE "132FR0070830180180010005E5740FFF4EFDDFFA39A7AFF--------000".
    05 FILLER PIC X(58) VALUE "132FR0250830180180010005E5740FFF4EFDDFFA39A7AFF--------000".
    05 FILLER PIC X(58) VALUE "132FR0430830180180010005E5740FFF4EFDDFFA39A7AFF--------000".
    05 FILLER PIC X(58) VALUE "132FR0610830180180010005E5740FFF4EFDDFFA39A7AFF--------000".
    05 FILLER PIC X(58) VALUE "132FR0790830180180010005E5740FFF4EFDDFFA39A7AFF--------000".
    05 FILLER PIC X(58) VALUE "132FR0970830180180010005E5740FFF4EFDDFFA39A7AFF--------000".
    05 FILLER PIC X(58) VALUE "132FR1150830180180010005E5740FFF4EFDDFFA39A7AFF--------000".
    05 FILLER PIC X(58) VALUE "132FR1330830180180010005E5740FFF4EFDDFFA39A7AFF--------000".
    05 FILLER PIC X(58) VALUE "132FR1510830180180010005E5740FFF4EFDDFFA39A7AFF--------000".
    05 FILLER PIC X(58) VALUE "132FR0071010180180010005E5740FFF4EFDDFFA39A7AFF--------000".
    05 FILLER PIC X(58) VALUE "132FR0251010180180010005E5740FFF4EFDDFFA39A7AFF--------000".
    05 FILLER PIC X(58) VALUE "132FR0431010180180010005E5740FFF4EFDDFFA39A7AFF--------000".
    05 FILLER PIC X(58) VALUE "132FR0611010180180010005E5740FFF4EFDDFFA39A7AFF--------000".
    05 FILLER PIC X(58) VALUE "132FR0791010180180010005E5740FFF4EFDDFFA39A7AFF--------000".
    05 FILLER PIC X(58) VALUE "132FR0971010180180010005E5740FFF4EFDDFFA39A7AFF--------000".
    05 FILLER PIC X(58) VALUE "132FR1151010180180010005E5740FFF4EFDDFFA39A7AFF--------000".
    05 FILLER PIC X(58) VALUE "132FR1331010180180010005E5740FFF4EFDDFFA39A7AFF--------000".
    05 FILLER PIC X(58) VALUE "132FR1511010180180010005E5740FFF4EFDDFFA39A7AFF--------000".
    05 FILLER PIC X(58) VALUE "132FR0071190180180010005E5740FFF4EFDDFFA39A7AFF--------000".
    05 FILLER PIC X(58) VALUE "132FR0251190180180010005E5740FFF4EFDDFFA39A7AFF--------000".
    05 FILLER PIC X(58) VALUE "132FR0431190180180010005E5740FFF4EFDDFFA39A7AFF--------000".
    05 FILLER PIC X(58) VALUE "132FR0611190180180010005E5740FFF4EFDDFFA39A7AFF--------000".
    05 FILLER PIC X(58) VALUE "132FR0791190180180010005E5740FFF4EFDDFFA39A7AFF--------000".
    05 FILLER PIC X(58) VALUE "132FR0971190180180010005E5740FFF4EFDDFFA39A7AFF--------000".
    05 FILLER PIC X(58) VALUE "132FR1151190180180010005E5740FFF4EFDDFFA39A7AFF--------000".
    05 FILLER PIC X(58) VALUE "132FR1331190180180010005E5740FFF4EFDDFFA39A7AFF--------000".
    05 FILLER PIC X(58) VALUE "132FR1511190180180010005E5740FFF4EFDDFFA39A7AFF--------000".
    05 FILLER PIC X(58) VALUE "132FR0071410180180010005E5740FFF4EFDDFFA39A7AFF--------000".
    05 FILLER PIC X(58) VALUE "132FR0251410180180010005E5740FFF4EFDDFFA39A7AFF--------000".
    05 FILLER PIC X(58) VALUE "132FR0431410180180010005E5740FFF4EFDDFFA39A7AFF--------000".
    05 FILLER PIC X(58) VALUE "132FR0611410180180010005E5740FFF4EFDDFFA39A7AFF--------000".
    05 FILLER PIC X(58) VALUE "132FR0791410180180010005E5740FFF4EFDDFFA39A7AFF--------000".
    05 FILLER PIC X(58) VALUE "132FR0971410180180010005E5740FFF4EFDDFFA39A7AFF--------000".
    05 FILLER PIC X(58) VALUE "132FR1151410180180010005E5740FFF4EFDDFFA39A7AFF--------000".
    05 FILLER PIC X(58) VALUE "132FR1331410180180010005E5740FFF4EFDDFFA39A7AFF--------000".
    05 FILLER PIC X(58) VALUE "132FR1511410180180010005E5740FFF4EFDDFFA39A7AFF--------000".
    05 FILLER PIC X(58) VALUE "132FR0070070180180010005E5740FFF4EFDDFFA39A7AFF--------000".
    05 FILLER PIC X(58) VALUE "132FR0070250180180010005E5740FFF4EFDDFFA39A7AFF--------000".
    05 FILLER PIC X(58) VALUE "132FR0070430180180010005E5740FFF4EFDDFFA39A7AFF--------000".
    05 FILLER PIC X(58) VALUE "132FR0070610180180010005E5740FFF4EFDDFFA39A7AFF--------000".
    05 FILLER PIC X(58) VALUE "132FR0970170180180010005E5740FFF4EFDDFFA39A7AFF--------000".
    05 FILLER PIC X(58) VALUE "132FR1150170180180010005E5740FFF4EFDDFFA39A7AFF--------000".
    05 FILLER PIC X(58) VALUE "132FR0970350180180010005E5740FFF4EFDDFFA39A7AFF--------000".
    05 FILLER PIC X(58) VALUE "132FR1150350180180010005E5740FFF4EFDDFFA39A7AFF--------000".
    05 FILLER PIC X(58) VALUE "132FR0760610180180010005E5740FFF4EFDDFFA39A7AFF--------000".
    05 FILLER PIC X(58) VALUE "132FR1510250220220020005E5740FFF4EFDDFFA39A7AFF--------000".
    05 FILLER PIC X(58) VALUE "132FR02600805007100100014141AFF55556AFF2B2B33FF--------000".
    05 FILLER PIC X(58) VALUE "132RC1350351410370000006F674DFF------------------------000".
    05 FILLER PIC X(58) VALUE "132TR1420321420401470366F674DFF------------------------000".
    05 FILLER PIC X(58) VALUE "133BV1761660020010000002A2A2AFFF4EFDDFF8C8366FFD8D0B4FF000".
    05 FILLER PIC X(58) VALUE "133FR0070830180180010005E5740FFF4EFDDFFA39A7AFF--------000".
    05 FILLER PIC X(58) VALUE "133FR0250830180180010005E5740FFF4EFDDFFA39A7AFF--------000".
    05 FILLER PIC X(58) VALUE "133FR0430830180180010005E5740FFF4EFDDFFA39A7AFF--------000".
    05 FILLER PIC X(58) VALUE "133FR0610830180180010005E5740FFF4EFDDFFA39A7AFF--------000".
    05 FILLER PIC X(58) VALUE "133FR0790830180180010005E5740FFF4EFDDFFA39A7AFF--------000".
    05 FILLER PIC X(58) VALUE "133FR0970830180180010005E5740FFF4EFDDFFA39A7AFF--------000".
    05 FILLER PIC X(58) VALUE "133FR1150830180180010005E5740FFF4EFDDFFA39A7AFF--------000".
    05 FILLER PIC X(58) VALUE "133FR1330830180180010005E5740FFF4EFDDFFA39A7AFF--------000".
    05 FILLER PIC X(58) VALUE "133FR1510830180180010005E5740FFF4EFDDFFA39A7AFF--------000".
    05 FILLER PIC X(58) VALUE "133FR0071010180180010005E5740FFF4EFDDFFA39A7AFF--------000".
    05 FILLER PIC X(58) VALUE "133FR0251010180180010005E5740FFF4EFDDFFA39A7AFF--------000".
    05 FILLER PIC X(58) VALUE "133FR0431010180180010005E5740FFF4EFDDFFA39A7AFF--------000".
    05 FILLER PIC X(58) VALUE "133FR0611010180180010005E5740FFF4EFDDFFA39A7AFF--------000".
    05 FILLER PIC X(58) VALUE "133FR0791010180180010005E5740FFF4EFDDFFA39A7AFF--------000".
    05 FILLER PIC X(58) VALUE "133FR0971010180180010005E5740FFF4EFDDFFA39A7AFF--------000".
    05 FILLER PIC X(58) VALUE "133FR1151010180180010005E5740FFF4EFDDFFA39A7AFF--------000".
    05 FILLER PIC X(58) VALUE "133FR1331010180180010005E5740FFF4EFDDFFA39A7AFF--------000".
    05 FILLER PIC X(58) VALUE "133FR1511010180180010005E5740FFF4EFDDFFA39A7AFF--------000".
    05 FILLER PIC X(58) VALUE "133FR0071190180180010005E5740FFF4EFDDFFA39A7AFF--------000".
    05 FILLER PIC X(58) VALUE "133FR0251190180180010005E5740FFF4EFDDFFA39A7AFF--------000".
    05 FILLER PIC X(58) VALUE "133FR0431190180180010005E5740FFF4EFDDFFA39A7AFF--------000".
    05 FILLER PIC X(58) VALUE "133FR0611190180180010005E5740FFF4EFDDFFA39A7AFF--------000".
    05 FILLER PIC X(58) VALUE "133FR0791190180180010005E5740FFF4EFDDFFA39A7AFF--------000".
    05 FILLER PIC X(58) VALUE "133FR0971190180180010005E5740FFF4EFDDFFA39A7AFF--------000".
    05 FILLER PIC X(58) VALUE "133FR1151190180180010005E5740FFF4EFDDFFA39A7AFF--------000".
    05 FILLER PIC X(58) VALUE "133FR1331190180180010005E5740FFF4EFDDFFA39A7AFF--------000".
    05 FILLER PIC X(58) VALUE "133FR1511190180180010005E5740FFF4EFDDFFA39A7AFF--------000".
    05 FILLER PIC X(58) VALUE "133FR0071410180180010005E5740FFF4EFDDFFA39A7AFF--------000".
    05 FILLER PIC X(58) VALUE "133FR0251410180180010005E5740FFF4EFDDFFA39A7AFF--------000".
    05 FILLER PIC X(58) VALUE "133FR0431410180180010005E5740FFF4EFDDFFA39A7AFF--------000".
    05 FILLER PIC X(58) VALUE "133FR0611410180180010005E5740FFF4EFDDFFA39A7AFF--------000".
    05 FILLER PIC X(58) VALUE "133FR0791410180180010005E5740FFF4EFDDFFA39A7AFF--------000".
    05 FILLER PIC X(58) VALUE "133FR0971410180180010005E5740FFF4EFDDFFA39A7AFF--------000".
    05 FILLER PIC X(58) VALUE "133FR1151410180180010005E5740FFF4EFDDFFA39A7AFF--------000".
    05 FILLER PIC X(58) VALUE "133FR1331410180180010005E5740FFF4EFDDFFA39A7AFF--------000".
    05 FILLER PIC X(58) VALUE "133FR1511410180180010005E5740FFF4EFDDFFA39A7AFF--------000".
    05 FILLER PIC X(58) VALUE "133FR0290160180180010005E5740FFF4EFDDFFA39A7AFF--------000".
    05 FILLER PIC X(58) VALUE "133FR0470160180180010005E5740FFF4EFDDFFA39A7AFF--------000".
    05 FILLER PIC X(58) VALUE "133FR0650160180180010005E5740FFF4EFDDFFA39A7AFF--------000".
    05 FILLER PIC X(58) VALUE "133FR0290340180180010005E5740FFF4EFDDFFA39A7AFF--------000".
    05 FILLER PIC X(58) VALUE "133FR0470340180180010005E5740FFF4EFDDFFA39A7AFF--------000".
    05 FILLER PIC X(58) VALUE "133FR0650340180180010005E5740FFF4EFDDFFA39A7AFF--------000".
    05 FILLER PIC X(58) VALUE "133FR0290520180180010005E5740FFF4EFDDFFA39A7AFF--------000".
    05 FILLER PIC X(58) VALUE "133FR0470520180180010005E5740FFF4EFDDFFA39A7AFF--------000".
    05 FILLER PIC X(58) VALUE "133FR0650520180180010005E5740FFF4EFDDFFA39A7AFF--------000".
    05 FILLER PIC X(58) VALUE "133FR1210320220220020005E5740FFF4EFDDFFA39A7AFF--------000".
    05 FILLER PIC X(58) VALUE "133RC0900421070440000006F674DFF------------------------000".
    05 FILLER PIC X(58) VALUE "133TR1060381060481140436F674DFF------------------------000".
    05 FILLER PIC X(58) VALUE "134BV1471660020010000002A2A2AFFF4EFDDFF8C8366FFD8D0B4FF000".
 01 BG-OP-TABLE REDEFINES BG-OP-DATA.
    05 BG-OPROW OCCURS 300 TIMES.
       10 BG-O-SPRITE      PIC 999.
       10 BG-O-OP          PIC XX.
       10 BG-O-N           PIC 999 OCCURS 6 TIMES.
       10 BG-O-C           PIC X(8) OCCURS 4 TIMES.
       10 BG-O-ARG         PIC 999.
 01 BG-ART-DATA.
    05 FILLER PIC X(4) VALUE "KrRD".
    05 FILLER PIC X(16) VALUE ".KK...KK.       ".
    05 FILLER PIC X(16) VALUE "KrRK.KRRK       ".
    05 FILLER PIC X(16) VALUE "KrRRKRRRK       ".
    05 FILLER PIC X(16) VALUE "KRRRRRRDK       ".
    05 FILLER PIC X(16) VALUE ".KRRRRDK.       ".
    05 FILLER PIC X(16) VALUE "..KRRDK..       ".
    05 FILLER PIC X(16) VALUE "...KDK...       ".
    05 FILLER PIC X(16) VALUE "....K....       ".
    05 FILLER PIC X(16) VALUE ".........       ".
    05 FILLER PIC X(16) VALUE ".........       ".
    05 FILLER PIC X(16) VALUE ".........       ".
    05 FILLER PIC X(16) VALUE ".........       ".
    05 FILLER PIC X(16) VALUE ".........       ".
    05 FILLER PIC X(16) VALUE ".........       ".
    05 FILLER PIC X(16) VALUE ".........       ".
    05 FILLER PIC X(16) VALUE ".........       ".
    05 FILLER PIC X(4) VALUE "KFhb".
    05 FILLER PIC X(16) VALUE "....KKK..       ".
    05 FILLER PIC X(16) VALUE "...KFFFK.       ".
    05 FILLER PIC X(16) VALUE "..KFhFFK.       ".
    05 FILLER PIC X(16) VALUE "..KFFFFK.       ".
    05 FILLER PIC X(16) VALUE "...KFFK..       ".
    05 FILLER PIC X(16) VALUE "..KKKK...       ".
    05 FILLER PIC X(16) VALUE ".KbbK....       ".
    05 FILLER PIC X(16) VALUE "KbbK.....       ".
    05 FILLER PIC X(16) VALUE ".KK......       ".
    05 FILLER PIC X(16) VALUE ".........       ".
    05 FILLER PIC X(16) VALUE ".........       ".
    05 FILLER PIC X(16) VALUE ".........       ".
    05 FILLER PIC X(16) VALUE ".........       ".
    05 FILLER PIC X(16) VALUE ".........       ".
    05 FILLER PIC X(16) VALUE ".........       ".
    05 FILLER PIC X(16) VALUE ".........       ".
    05 FILLER PIC X(4) VALUE "KAhD".
    05 FILLER PIC X(16) VALUE ".KKK.KKK.       ".
    05 FILLER PIC X(16) VALUE "KAAAKAAAK       ".
    05 FILLER PIC X(16) VALUE "KAhAAAAAK       ".
    05 FILLER PIC X(16) VALUE "KAAAAAAAK       ".
    05 FILLER PIC X(16) VALUE ".KAAAAAK.       ".
    05 FILLER PIC X(16) VALUE ".KAAAADK.       ".
    05 FILLER PIC X(16) VALUE ".KAAADDK.       ".
    05 FILLER PIC X(16) VALUE ".KKKKKKK.       ".
    05 FILLER PIC X(16) VALUE ".........       ".
    05 FILLER PIC X(16) VALUE ".........       ".
    05 FILLER PIC X(16) VALUE ".........       ".
    05 FILLER PIC X(16) VALUE ".........       ".
    05 FILLER PIC X(16) VALUE ".........       ".
    05 FILLER PIC X(16) VALUE ".........       ".
    05 FILLER PIC X(16) VALUE ".........       ".
    05 FILLER PIC X(16) VALUE ".........       ".
    05 FILLER PIC X(4) VALUE "Kbh ".
    05 FILLER PIC X(16) VALUE "..KKKKK..       ".
    05 FILLER PIC X(16) VALUE ".KbbbbbK.       ".
    05 FILLER PIC X(16) VALUE "KbhhbbbbK       ".
    05 FILLER PIC X(16) VALUE "KbhbbbbbK       ".
    05 FILLER PIC X(16) VALUE "KbbbbbbbK       ".
    05 FILLER PIC X(16) VALUE "KbbbbbbbK       ".
    05 FILLER PIC X(16) VALUE "KbbbbbbbK       ".
    05 FILLER PIC X(16) VALUE ".KbbbbbK.       ".
    05 FILLER PIC X(16) VALUE "..KKKKK..       ".
    05 FILLER PIC X(16) VALUE ".........       ".
    05 FILLER PIC X(16) VALUE ".........       ".
    05 FILLER PIC X(16) VALUE ".........       ".
    05 FILLER PIC X(16) VALUE ".........       ".
    05 FILLER PIC X(16) VALUE ".........       ".
    05 FILLER PIC X(16) VALUE ".........       ".
    05 FILLER PIC X(16) VALUE ".........       ".
    05 FILLER PIC X(4) VALUE "h   ".
    05 FILLER PIC X(16) VALUE "h...h...h       ".
    05 FILLER PIC X(16) VALUE ".h..h..h.       ".
    05 FILLER PIC X(16) VALUE "..h.h.h..       ".
    05 FILLER PIC X(16) VALUE "...hhh...       ".
    05 FILLER PIC X(16) VALUE "hhhh.hhhh       ".
    05 FILLER PIC X(16) VALUE "...hhh...       ".
    05 FILLER PIC X(16) VALUE "..h.h.h..       ".
    05 FILLER PIC X(16) VALUE ".h..h..h.       ".
    05 FILLER PIC X(16) VALUE "h...h...h       ".
    05 FILLER PIC X(16) VALUE ".........       ".
    05 FILLER PIC X(16) VALUE ".........       ".
    05 FILLER PIC X(16) VALUE ".........       ".
    05 FILLER PIC X(16) VALUE ".........       ".
    05 FILLER PIC X(16) VALUE ".........       ".
    05 FILLER PIC X(16) VALUE ".........       ".
    05 FILLER PIC X(16) VALUE ".........       ".
    05 FILLER PIC X(4) VALUE "S   ".
    05 FILLER PIC X(16) VALUE "................".
    05 FILLER PIC X(16) VALUE "................".
    05 FILLER PIC X(16) VALUE "....SSSSSSSS....".
    05 FILLER PIC X(16) VALUE "...SSSSSSSSSS...".
    05 FILLER PIC X(16) VALUE "..SSSSSSSSSSSS..".
    05 FILLER PIC X(16) VALUE "..SSSSSSSSSSSS..".
    05 FILLER PIC X(16) VALUE "..SSSSSSSSSSSS..".
    05 FILLER PIC X(16) VALUE "..SSSSSSSSSSSS..".
    05 FILLER PIC X(16) VALUE "..SSS......SSS..".
    05 FILLER PIC X(16) VALUE "..SSS......SSS..".
    05 FILLER PIC X(16) VALUE "..SSS......SSS..".
    05 FILLER PIC X(16) VALUE "................".
    05 FILLER PIC X(16) VALUE "................".
    05 FILLER PIC X(16) VALUE "................".
    05 FILLER PIC X(16) VALUE "................".
    05 FILLER PIC X(16) VALUE "................".
    05 FILLER PIC X(4) VALUE "S   ".
    05 FILLER PIC X(16) VALUE "................".
    05 FILLER PIC X(16) VALUE "..SSSS....SSSS..".
    05 FILLER PIC X(16) VALUE ".SSSSSS..SSSSSS.".
    05 FILLER PIC X(16) VALUE ".SSSSSSSSSSSSSS.".
    05 FILLER PIC X(16) VALUE ".SSSSSSSSSSSSSS.".
    05 FILLER PIC X(16) VALUE "..SSSSSSSSSSSS..".
    05 FILLER PIC X(16) VALUE "...SSSSSSSSSS...".
    05 FILLER PIC X(16) VALUE "...SSSSSSSSSS...".
    05 FILLER PIC X(16) VALUE "...SSSSSSSSSS...".
    05 FILLER PIC X(16) VALUE "...SSSSSSSSSS...".
    05 FILLER PIC X(16) VALUE "...SSSSSSSSSS...".
    05 FILLER PIC X(16) VALUE "...SSSSSSSSSS...".
    05 FILLER PIC X(16) VALUE "...SSSSSSSSSS...".
    05 FILLER PIC X(16) VALUE "................".
    05 FILLER PIC X(16) VALUE "................".
    05 FILLER PIC X(16) VALUE "................".
    05 FILLER PIC X(4) VALUE "S   ".
    05 FILLER PIC X(16) VALUE "................".
    05 FILLER PIC X(16) VALUE "................".
    05 FILLER PIC X(16) VALUE "...SSSSSSSSSS...".
    05 FILLER PIC X(16) VALUE "...SSSSSSSSSS...".
    05 FILLER PIC X(16) VALUE "...SSSSSSSSSS...".
    05 FILLER PIC X(16) VALUE "...SSSSSSSSSS...".
    05 FILLER PIC X(16) VALUE "...SSSS..SSSS...".
    05 FILLER PIC X(16) VALUE "...SSSS..SSSS...".
    05 FILLER PIC X(16) VALUE "...SSSS..SSSS...".
    05 FILLER PIC X(16) VALUE "...SSSS..SSSS...".
    05 FILLER PIC X(16) VALUE "...SSSS..SSSS...".
    05 FILLER PIC X(16) VALUE "...SSSS..SSSS...".
    05 FILLER PIC X(16) VALUE "...SSSS..SSSS...".
    05 FILLER PIC X(16) VALUE "................".
    05 FILLER PIC X(16) VALUE "................".
    05 FILLER PIC X(16) VALUE "................".
    05 FILLER PIC X(4) VALUE "S   ".
    05 FILLER PIC X(16) VALUE "................".
    05 FILLER PIC X(16) VALUE "................".
    05 FILLER PIC X(16) VALUE "................".
    05 FILLER PIC X(16) VALUE "..SSSS....SSSS..".
    05 FILLER PIC X(16) VALUE "..SSSS....SSSS..".
    05 FILLER PIC X(16) VALUE "..SSSS....SSSS..".
    05 FILLER PIC X(16) VALUE "..SSSS....SSSS..".
    05 FILLER PIC X(16) VALUE "..SSSSSS..SSSSSS".
    05 FILLER PIC X(16) VALUE "..SSSSSS..SSSSSS".
    05 FILLER PIC X(16) VALUE "..SSSSSS..SSSSSS".
    05 FILLER PIC X(16) VALUE "................".
    05 FILLER PIC X(16) VALUE "................".
    05 FILLER PIC X(16) VALUE "................".
    05 FILLER PIC X(16) VALUE "................".
    05 FILLER PIC X(16) VALUE "................".
    05 FILLER PIC X(16) VALUE "................".
    05 FILLER PIC X(4) VALUE "S   ".
    05 FILLER PIC X(16) VALUE "................".
    05 FILLER PIC X(16) VALUE "..SSSSSSSSSSSS..".
    05 FILLER PIC X(16) VALUE "..SSSSSSSSSSSS..".
    05 FILLER PIC X(16) VALUE "..SSSSSSSSSSSS..".
    05 FILLER PIC X(16) VALUE "..SSSSSSSSSSSS..".
    05 FILLER PIC X(16) VALUE "..SSSSSSSSSSSS..".
    05 FILLER PIC X(16) VALUE "..SSSSSSSSSSSS..".
    05 FILLER PIC X(16) VALUE "..SSSSSSSSSSSS..".
    05 FILLER PIC X(16) VALUE "...SSSSSSSSSS...".
    05 FILLER PIC X(16) VALUE "...SSSSSSSSSS...".
    05 FILLER PIC X(16) VALUE "....SSSSSSSS....".
    05 FILLER PIC X(16) VALUE ".....SSSSSS.....".
    05 FILLER PIC X(16) VALUE "......SSSS......".
    05 FILLER PIC X(16) VALUE ".......SS.......".
    05 FILLER PIC X(16) VALUE "................".
    05 FILLER PIC X(16) VALUE "................".
 01 BG-ART-TABLE REDEFINES BG-ART-DATA.
    05 BG-ARTROW OCCURS 10 TIMES.
       10 BG-ART-KEY       PIC X(4).
       10 BG-ART-LINE      PIC X(16) OCCURS 16 TIMES.
