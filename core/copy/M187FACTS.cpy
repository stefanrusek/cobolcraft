*> What canReplaceCurrentItem reads of one stack (docs/protocol/18 section 7.2, 44-1 RQ-1.3; core/src/mob-18-7.cob). COPY it with REPLACING LEADING ==MF-== BY ==<own prefix>==.
*>   MF-EMPTY 1 for an empty stack. MF-ARMOR, MF-TOUGH, MF-DAMAGE: the approximated armor, armor toughness and attack damage attributes of the stack in the slot asked
*>   (getApproximateAttributeWith). MF-ENCH the number of distinct enchantments, MF-WEAR the damage value, MF-NAMED 1 with a custom name, MF-BINDING 1 when the
*>   stack has prevent_armor_change (the binding curse), MF-PREF 1 when the stack is in the mob's preferred weapon tag.
 01 MF-FACTS.
    05 MF-EMPTY            BINARY-LONG.
    05 MF-ARMOR            FLOAT-LONG.
    05 MF-TOUGH            FLOAT-LONG.
    05 MF-DAMAGE           FLOAT-LONG.
    05 MF-ENCH             BINARY-LONG.
    05 MF-WEAR             BINARY-LONG.
    05 MF-NAMED            BINARY-LONG.
    05 MF-BINDING          BINARY-LONG.
    05 MF-PREF             BINARY-LONG.
