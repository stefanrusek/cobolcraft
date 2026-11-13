*> The stored state of a known player beyond KN-INVENTORY (core/src/player-state.cob; docs/protocol/45-entity-nbt-3-player-and-player-data.md
*> section 2.3, 3.5, 4): EXTERNAL, one KX-ROW per CORE-KNOWN row. A known player's patch handles cannot be kept (the pool of
*> CSTACK.cpy frees what no player in the world holds), so each stored stack with data components keeps a copy of its patch
*> in KX-PATCH (the layout of CSTACKE.cpy, KP-LIVE 1 while a row of KX-ROW refers to it) and the row holds its number (KX-*-KP,
*> 0 = none). KX-EQUIP holds boots, leggings, chestplate, helmet and off-hand (container slots 36 to 40). KX-SET is 1 once the
*> row holds a player's state. KX-BOOK-SET is 1 once it holds the recipe book; KX-FLAG(n) is the book of RC-STORE row n: 1 known,
*> 2 known and still highlighted (3 is not used), with the settings of the four book types.
 78 KX-MAX-PATCHES        VALUE 1024.
 01 CORE-KNOWN-EXTRA EXTERNAL.
    05 KX-ROW OCCURS 4096 TIMES.
       10 KX-SET             PIC 9.
       10 KX-EQUIP OCCURS 5 TIMES.
          15 KX-EQUIP-ITEM   BINARY-LONG.
          15 KX-EQUIP-COUNT  BINARY-LONG.
          15 KX-EQUIP-KP     BINARY-LONG.
       10 KX-SLOT-KP         BINARY-LONG OCCURS 36 TIMES.
       10 KX-SATURATION      FLOAT-LONG.
*>     --- 002-lane-mobs2: experience (xp.cob) ---
       10 KX-XP-LEVEL        BINARY-LONG.
       10 KX-XP-POINTS       BINARY-LONG.
       10 KX-XP-TOTAL        BINARY-LONG.
*>     --- end 002-lane-mobs2 ---
       10 KX-BOOK-SET        PIC 9.
       10 KX-BOOK-OPEN       PIC 9 OCCURS 4 TIMES.
       10 KX-BOOK-FILTER     PIC 9 OCCURS 4 TIMES.
       10 KX-FLAG            BINARY-CHAR UNSIGNED OCCURS 4096 TIMES.
    05 KX-PATCH OCCURS 1024 TIMES.
       COPY CSTACKE REPLACING LEADING ==SP-== BY ==KP-==.
