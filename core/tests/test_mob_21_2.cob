*> Acceptance test (002-lane-p49b; docs/protocol/21 section 2): the cross-check table of all 161 entity types. Every row (id, key, size width x height from the builder's
*> sized(w, h); the three display entities are 0 x 0) is written out here from the document's table; each key must resolve to that registry id (the registration index of 04 section
*> 5.1) and the entity table must hold the same width and height in thousandths. Column data other than the size (eye height, tracking range, update interval, builder flags) has no
*> reader in the core and is not asserted.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-MOB-21-2.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY CONTENT.
 COPY CITEMS.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-ENTITY-ROW          PIC X(66).
 01 WS-STATUS              BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-NAME                PIC X(40).
 01 WS-ID-TEXT             PIC X(10).
 01 WS-W-TEXT              PIC X(10).
 01 WS-H-TEXT              PIC X(10).
 01 WS-ID                  BINARY-LONG.
 01 WS-W                   BINARY-LONG.
 01 WS-H                   BINARY-LONG.
 01 WS-LINE                PIC X(40).
 01 WS-BAD                 BINARY-LONG VALUE 0.
 01 WS-BAD-SIZE            BINARY-LONG VALUE 0.
 01 WS-DATA.
    05 FILLER              PIC X(40) VALUE "acacia_boat 0 1375 563".
    05 FILLER              PIC X(40) VALUE "acacia_chest_boat 1 1375 563".
    05 FILLER              PIC X(40) VALUE "allay 2 350 600".
    05 FILLER              PIC X(40) VALUE "area_effect_cloud 3 6000 500".
    05 FILLER              PIC X(40) VALUE "armadillo 4 700 650".
    05 FILLER              PIC X(40) VALUE "armor_stand 5 500 1975".
    05 FILLER              PIC X(40) VALUE "arrow 6 500 500".
    05 FILLER              PIC X(40) VALUE "axolotl 7 750 420".
    05 FILLER              PIC X(40) VALUE "bamboo_chest_raft 8 1375 563".
    05 FILLER              PIC X(40) VALUE "bamboo_raft 9 1375 563".
    05 FILLER              PIC X(40) VALUE "bat 10 500 900".
    05 FILLER              PIC X(40) VALUE "bee 11 550 500".
    05 FILLER              PIC X(40) VALUE "birch_boat 12 1375 563".
    05 FILLER              PIC X(40) VALUE "birch_chest_boat 13 1375 563".
    05 FILLER              PIC X(40) VALUE "blaze 14 600 1800".
    05 FILLER              PIC X(40) VALUE "block_display 15 0 0".
    05 FILLER              PIC X(40) VALUE "bogged 16 600 1990".
    05 FILLER              PIC X(40) VALUE "breeze 17 600 1770".
    05 FILLER              PIC X(40) VALUE "breeze_wind_charge 18 313 313".
    05 FILLER              PIC X(40) VALUE "camel 19 1700 2375".
    05 FILLER              PIC X(40) VALUE "camel_husk 20 1700 2375".
    05 FILLER              PIC X(40) VALUE "cat 21 600 700".
    05 FILLER              PIC X(40) VALUE "cave_spider 22 700 500".
    05 FILLER              PIC X(40) VALUE "cherry_boat 23 1375 563".
    05 FILLER              PIC X(40) VALUE "cherry_chest_boat 24 1375 563".
    05 FILLER              PIC X(40) VALUE "chest_minecart 25 980 700".
    05 FILLER              PIC X(40) VALUE "chicken 26 400 700".
    05 FILLER              PIC X(40) VALUE "cod 27 500 300".
    05 FILLER              PIC X(40) VALUE "copper_golem 28 490 980".
    05 FILLER              PIC X(40) VALUE "command_block_minecart 29 980 700".
    05 FILLER              PIC X(40) VALUE "cow 30 900 1400".
    05 FILLER              PIC X(40) VALUE "creaking 31 900 2700".
    05 FILLER              PIC X(40) VALUE "creeper 32 600 1700".
    05 FILLER              PIC X(40) VALUE "cushion 33 1000 250".
    05 FILLER              PIC X(40) VALUE "dark_oak_boat 34 1375 563".
    05 FILLER              PIC X(40) VALUE "dark_oak_chest_boat 35 1375 563".
    05 FILLER              PIC X(40) VALUE "dolphin 36 900 600".
    05 FILLER              PIC X(40) VALUE "donkey 37 1396 1500".
    05 FILLER              PIC X(40) VALUE "dragon_fireball 38 1000 1000".
    05 FILLER              PIC X(40) VALUE "drowned 39 600 1950".
    05 FILLER              PIC X(40) VALUE "egg 40 250 250".
    05 FILLER              PIC X(40) VALUE "elder_guardian 41 1998 1998".
    05 FILLER              PIC X(40) VALUE "enderman 42 600 2900".
    05 FILLER              PIC X(40) VALUE "endermite 43 400 300".
    05 FILLER              PIC X(40) VALUE "ender_dragon 44 16000 8000".
    05 FILLER              PIC X(40) VALUE "ender_pearl 45 250 250".
    05 FILLER              PIC X(40) VALUE "end_crystal 46 2000 2000".
    05 FILLER              PIC X(40) VALUE "evoker 47 600 1950".
    05 FILLER              PIC X(40) VALUE "evoker_fangs 48 500 800".
    05 FILLER              PIC X(40) VALUE "experience_bottle 49 250 250".
    05 FILLER              PIC X(40) VALUE "experience_orb 50 500 500".
    05 FILLER              PIC X(40) VALUE "eye_of_ender 51 250 250".
    05 FILLER              PIC X(40) VALUE "falling_block 52 980 980".
    05 FILLER              PIC X(40) VALUE "fireball 53 1000 1000".
    05 FILLER              PIC X(40) VALUE "firework_rocket 54 250 250".
    05 FILLER              PIC X(40) VALUE "fox 55 600 700".
    05 FILLER              PIC X(40) VALUE "frog 56 500 500".
    05 FILLER              PIC X(40) VALUE "furnace_minecart 57 980 700".
    05 FILLER              PIC X(40) VALUE "ghast 58 4000 4000".
    05 FILLER              PIC X(40) VALUE "happy_ghast 59 4000 4000".
    05 FILLER              PIC X(40) VALUE "giant 60 3600 12000".
    05 FILLER              PIC X(40) VALUE "glow_item_frame 61 500 500".
    05 FILLER              PIC X(40) VALUE "glow_squid 62 800 800".
    05 FILLER              PIC X(40) VALUE "goat 63 900 1300".
    05 FILLER              PIC X(40) VALUE "guardian 64 850 850".
    05 FILLER              PIC X(40) VALUE "hoglin 65 1396 1400".
    05 FILLER              PIC X(40) VALUE "hopper_minecart 66 980 700".
    05 FILLER              PIC X(40) VALUE "horse 67 1396 1600".
    05 FILLER              PIC X(40) VALUE "husk 68 600 1950".
    05 FILLER              PIC X(40) VALUE "illusioner 69 600 1950".
    05 FILLER              PIC X(40) VALUE "interaction 70 0 0".
    05 FILLER              PIC X(40) VALUE "iron_golem 71 1400 2700".
    05 FILLER              PIC X(40) VALUE "item 72 250 250".
    05 FILLER              PIC X(40) VALUE "item_display 73 0 0".
    05 FILLER              PIC X(40) VALUE "item_frame 74 500 500".
    05 FILLER              PIC X(40) VALUE "jungle_boat 75 1375 563".
    05 FILLER              PIC X(40) VALUE "jungle_chest_boat 76 1375 563".
    05 FILLER              PIC X(40) VALUE "leash_knot 77 375 500".
    05 FILLER              PIC X(40) VALUE "lightning_bolt 78 0 0".
    05 FILLER              PIC X(40) VALUE "llama 79 900 1870".
    05 FILLER              PIC X(40) VALUE "llama_spit 80 250 250".
    05 FILLER              PIC X(40) VALUE "magma_cube 81 520 520".
    05 FILLER              PIC X(40) VALUE "mangrove_boat 82 1375 563".
    05 FILLER              PIC X(40) VALUE "mangrove_chest_boat 83 1375 563".
    05 FILLER              PIC X(40) VALUE "mannequin 84 600 1800".
    05 FILLER              PIC X(40) VALUE "marker 85 0 0".
    05 FILLER              PIC X(40) VALUE "minecart 86 980 700".
    05 FILLER              PIC X(40) VALUE "mooshroom 87 900 1400".
    05 FILLER              PIC X(40) VALUE "mule 88 1396 1600".
    05 FILLER              PIC X(40) VALUE "nautilus 89 875 950".
    05 FILLER              PIC X(40) VALUE "oak_boat 90 1375 563".
    05 FILLER              PIC X(40) VALUE "oak_chest_boat 91 1375 563".
    05 FILLER              PIC X(40) VALUE "ocelot 92 600 700".
    05 FILLER              PIC X(40) VALUE "ominous_item_spawner 93 250 250".
    05 FILLER              PIC X(40) VALUE "painting 94 500 500".
    05 FILLER              PIC X(40) VALUE "pale_oak_boat 95 1375 563".
    05 FILLER              PIC X(40) VALUE "pale_oak_chest_boat 96 1375 563".
    05 FILLER              PIC X(40) VALUE "panda 97 1300 1250".
    05 FILLER              PIC X(40) VALUE "parched 98 600 1990".
    05 FILLER              PIC X(40) VALUE "parrot 99 500 900".
    05 FILLER              PIC X(40) VALUE "phantom 100 900 500".
    05 FILLER              PIC X(40) VALUE "pig 101 900 900".
    05 FILLER              PIC X(40) VALUE "piglin 102 600 1950".
    05 FILLER              PIC X(40) VALUE "piglin_brute 103 600 1950".
    05 FILLER              PIC X(40) VALUE "pillager 104 600 1950".
    05 FILLER              PIC X(40) VALUE "polar_bear 105 1400 1400".
    05 FILLER              PIC X(40) VALUE "poplar_boat 106 1375 563".
    05 FILLER              PIC X(40) VALUE "poplar_chest_boat 107 1375 563".
    05 FILLER              PIC X(40) VALUE "splash_potion 108 250 250".
    05 FILLER              PIC X(40) VALUE "lingering_potion 109 250 250".
    05 FILLER              PIC X(40) VALUE "pufferfish 110 700 700".
    05 FILLER              PIC X(40) VALUE "rabbit 111 490 600".
    05 FILLER              PIC X(40) VALUE "ravager 112 1950 2200".
    05 FILLER              PIC X(40) VALUE "salmon 113 700 400".
    05 FILLER              PIC X(40) VALUE "sheep 114 900 1300".
    05 FILLER              PIC X(40) VALUE "shulker 115 1000 1000".
    05 FILLER              PIC X(40) VALUE "shulker_bullet 116 313 313".
    05 FILLER              PIC X(40) VALUE "silverfish 117 400 300".
    05 FILLER              PIC X(40) VALUE "skeleton 118 600 1990".
    05 FILLER              PIC X(40) VALUE "skeleton_horse 119 1396 1600".
    05 FILLER              PIC X(40) VALUE "slime 120 520 520".
    05 FILLER              PIC X(40) VALUE "small_fireball 121 313 313".
    05 FILLER              PIC X(40) VALUE "sniffer 122 1900 1750".
    05 FILLER              PIC X(40) VALUE "snowball 123 250 250".
    05 FILLER              PIC X(40) VALUE "snow_golem 124 700 1900".
    05 FILLER              PIC X(40) VALUE "spawner_minecart 125 980 700".
    05 FILLER              PIC X(40) VALUE "spectral_arrow 126 500 500".
    05 FILLER              PIC X(40) VALUE "spider 127 1400 900".
    05 FILLER              PIC X(40) VALUE "spruce_boat 128 1375 563".
    05 FILLER              PIC X(40) VALUE "spruce_chest_boat 129 1375 563".
    05 FILLER              PIC X(40) VALUE "squid 130 800 800".
    05 FILLER              PIC X(40) VALUE "stray 131 600 1990".
    05 FILLER              PIC X(40) VALUE "strider 132 900 1700".
    05 FILLER              PIC X(40) VALUE "sulfur_cube 133 490 490".
    05 FILLER              PIC X(40) VALUE "tadpole 134 400 300".
    05 FILLER              PIC X(40) VALUE "text_display 135 0 0".
    05 FILLER              PIC X(40) VALUE "tnt 136 980 980".
    05 FILLER              PIC X(40) VALUE "tnt_minecart 137 980 700".
    05 FILLER              PIC X(40) VALUE "trader_llama 138 900 1870".
    05 FILLER              PIC X(40) VALUE "trident 139 500 500".
    05 FILLER              PIC X(40) VALUE "tropical_fish 140 500 400".
    05 FILLER              PIC X(40) VALUE "turtle 141 1200 400".
    05 FILLER              PIC X(40) VALUE "vex 142 400 800".
    05 FILLER              PIC X(40) VALUE "villager 143 600 1950".
    05 FILLER              PIC X(40) VALUE "vindicator 144 600 1950".
    05 FILLER              PIC X(40) VALUE "wandering_trader 145 600 1950".
    05 FILLER              PIC X(40) VALUE "warden 146 900 2900".
    05 FILLER              PIC X(40) VALUE "wind_charge 147 313 313".
    05 FILLER              PIC X(40) VALUE "witch 148 600 1950".
    05 FILLER              PIC X(40) VALUE "wither 149 900 3500".
    05 FILLER              PIC X(40) VALUE "wither_skeleton 150 700 2400".
    05 FILLER              PIC X(40) VALUE "wither_skull 151 313 313".
    05 FILLER              PIC X(40) VALUE "wolf 152 600 850".
    05 FILLER              PIC X(40) VALUE "zoglin 153 1396 1400".
    05 FILLER              PIC X(40) VALUE "zombie 154 600 1950".
    05 FILLER              PIC X(40) VALUE "zombie_horse 155 1396 1600".
    05 FILLER              PIC X(40) VALUE "zombie_nautilus 156 875 950".
    05 FILLER              PIC X(40) VALUE "zombie_villager 157 600 1950".
    05 FILLER              PIC X(40) VALUE "zombified_piglin 158 600 1950".
    05 FILLER              PIC X(40) VALUE "player 159 600 1800".
    05 FILLER              PIC X(40) VALUE "fishing_bobber 160 250 250".
 01 WS-TABLE REDEFINES WS-DATA.
    05 WS-ROW              PIC X(40) OCCURS 161 TIMES.
 PROCEDURE DIVISION.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     MOVE "N" TO TL-MODE
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 161
         MOVE WS-ROW(WS-I) TO WS-LINE
         MOVE SPACES TO WS-NAME WS-ID-TEXT WS-W-TEXT WS-H-TEXT
         UNSTRING WS-LINE DELIMITED BY SPACE INTO WS-NAME WS-ID-TEXT WS-W-TEXT WS-H-TEXT
         COMPUTE WS-ID = FUNCTION NUMVAL(WS-ID-TEXT)
         COMPUTE WS-W = FUNCTION NUMVAL(WS-W-TEXT)
         COMPUTE WS-H = FUNCTION NUMVAL(WS-H-TEXT)
         MOVE SPACES TO WS-KEY
         STRING "minecraft:" DELIMITED BY SIZE WS-NAME DELIMITED BY SPACE INTO WS-KEY
         CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE WS-ENTITY-ROW WS-STATUS
         MOVE SPACES TO TL-CASE
         STRING "acceptance US15 21§2 " DELIMITED BY SIZE WS-NAME DELIMITED BY SPACE " has the id of the table" DELIMITED BY SIZE
             INTO TL-CASE
         MOVE WS-ID TO TL-EXPECTED-N
         MOVE -1 TO TL-OBSERVED-N
         IF WS-STATUS = 0
             MOVE WS-TYPE TO TL-OBSERVED-N
         END-IF
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
         IF WS-STATUS = 0
             MOVE SPACES TO TL-CASE
             STRING "acceptance US15 21§2 " DELIMITED BY SIZE WS-NAME DELIMITED BY SPACE " size in thousandths" DELIMITED BY SIZE
                 INTO TL-CASE
             COMPUTE TL-EXPECTED-N = WS-W * 100000 + WS-H
             COMPUTE TL-OBSERVED-N = ET-WIDTH-MILLI(WS-TYPE + 1) * 100000 + ET-HEIGHT-MILLI(WS-TYPE + 1)
             CALL "TEST-ASSERT" USING TESTLIB-ASSERT
         END-IF
     END-PERFORM
     STOP RUN.
 END PROGRAM TEST-MOB-21-2.
 COPY CORETEST.
 COPY MOBSPTEST.
