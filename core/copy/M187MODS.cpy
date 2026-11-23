*> The attribute modifier list of one stack (docs/protocol/17 section 1.3, 18 section 7.2; core/src/mob-18-7.cob): up to 8 entries in list order. MM-ATTR 1 armor,
*> 2 armor_toughness, 3 attack_damage; MM-GROUP the slot group (M187-GROUP-HAS: 1 any, 2 mainhand, 3 offhand, 4 hand, 5 feet, 6 legs, 7 chest, 8 head, 9 armor,
*> 10 body, 11 saddle, the order of the 04 slot group list); MM-OP 0 add_value, 1 add_multiplied_base, 2 add_multiplied_total. COPY it with REPLACING LEADING ==MM-==.
 01 MM-MODS.
    05 MM-MOD OCCURS 8 TIMES.
       10 MM-ATTR            BINARY-LONG.
       10 MM-GROUP           BINARY-LONG.
       10 MM-OP              BINARY-LONG.
       10 MM-AMOUNT          FLOAT-LONG.
