*> Care of tame pets: cats, ocelots and wolves (docs/protocol/19-mobs-land-friendly-and-neutral.md sections 5.1, 5.2 and 6.1; 18 section 8.2).
*> Open items: the cat's begging and tempt goal, relaxing on the owner and the morning gift, CatSpawner, cat variants, lying and sitting on blocks, following the owner (stop 5),
*> the ocelot's distrust (avoiding players), breeding offspring that inherit the owner and the mixed collar, wolf armour, anger and the other wolf goals.
*>
*> Entry points:
*>   M195-DYE-COLOR USING item key, colour out           the dye id of "<colour>_dye" (-1 for any other item)
*>   M195-COLLAR USING stored, colour out                the collar colour of EN-COLLAR (0 is the default red 14, else the dye id + 1)
*>   M195-FOOD USING species, item key, ok out, nutrition out   wolf_food for a wolf, cat_food (cod, salmon) for a cat, ocelot_food for an ocelot, with the nutrition
*>   M195-HEAL USING health, max, nutrition, multiplier, new out   the shared tamable feeding routine: health + multiplier x nutrition, at most max
*>   MOB-CARE-USE USING player row, entity row, max health, multiplier, consumed out   a tame wolf or cat: the owner's dye sets the collar, food heals a hurt pet
*>   MOB-CAT-USE USING player row, entity row           the main hand on a cat or an ocelot
*>   MOB-CARE-DATA USING row, PB-BUFFER                  the entity data entries of the collar (wolf 21, cat 23) and of a trusting ocelot (18)

 IDENTIFICATION DIVISION.
 PROGRAM-ID. M195-DYE-COLOR.
*> USING item key (PIC X(24)), colour out: the dye id 0 to 15 of an item "<colour>_dye" of the tag #dyes, else -1. The colour names come from M188-COLOR-KEY.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-I                   BINARY-LONG.
 01 WS-WOOL                PIC X(24).
 01 WS-DYE                 PIC X(24).
 01 WS-LENGTH              BINARY-LONG.
 LINKAGE SECTION.
 01 L-KEY                  PIC X(24).
 01 L-COLOR                BINARY-LONG.
 PROCEDURE DIVISION USING L-KEY L-COLOR.
     MOVE -1 TO L-COLOR
     PERFORM VARYING WS-I FROM 0 BY 1 UNTIL WS-I > 15
         CALL "M188-COLOR-KEY" USING WS-I WS-WOOL
         COMPUTE WS-LENGTH = FUNCTION LENGTH(FUNCTION TRIM(WS-WOOL)) - 5
         MOVE SPACES TO WS-DYE
         STRING WS-WOOL(1:WS-LENGTH) DELIMITED BY SIZE "_dye" DELIMITED BY SIZE INTO WS-DYE
         IF WS-DYE = L-KEY
             MOVE WS-I TO L-COLOR
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM M195-DYE-COLOR.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. M195-COLLAR.
*> USING stored (EN-COLLAR), colour out: 0 was never dyed and wears the default red (dye id 14), else the stored value is the dye id + 1.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 LINKAGE SECTION.
 01 L-STORED               BINARY-LONG.
 01 L-COLOR                BINARY-LONG.
 PROCEDURE DIVISION USING L-STORED L-COLOR.
     MOVE 14 TO L-COLOR
     IF L-STORED > 0
         COMPUTE L-COLOR = L-STORED - 1
     END-IF
     GOBACK.
 END PROGRAM M195-COLLAR.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. M195-FOOD.
*> USING species (PIC X(24): wolf, cat or ocelot), item key (PIC X(24)), ok out, nutrition out: wolf_food (tag meat, the fish, rabbit stew; 19 section 6.1), cat_food and ocelot_food (raw cod,
*> raw salmon) with the nutrition of the item's food (docs 25 section 4.1: the standard item rows carry no food value in the core table, so it is listed here).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-FOODS.
    05 FILLER PIC X(26) VALUE "beef                    03".
    05 FILLER PIC X(26) VALUE "chicken                 02".
    05 FILLER PIC X(26) VALUE "cooked_beef             08".
    05 FILLER PIC X(26) VALUE "cooked_chicken          06".
    05 FILLER PIC X(26) VALUE "cooked_mutton           06".
    05 FILLER PIC X(26) VALUE "cooked_porkchop         08".
    05 FILLER PIC X(26) VALUE "cooked_rabbit           05".
    05 FILLER PIC X(26) VALUE "mutton                  02".
    05 FILLER PIC X(26) VALUE "porkchop                03".
    05 FILLER PIC X(26) VALUE "rabbit                  03".
    05 FILLER PIC X(26) VALUE "rotten_flesh            04".
    05 FILLER PIC X(26) VALUE "cod                     02".
    05 FILLER PIC X(26) VALUE "cooked_cod              05".
    05 FILLER PIC X(26) VALUE "salmon                  02".
    05 FILLER PIC X(26) VALUE "cooked_salmon           06".
    05 FILLER PIC X(26) VALUE "tropical_fish           01".
    05 FILLER PIC X(26) VALUE "pufferfish              01".
    05 FILLER PIC X(26) VALUE "rabbit_stew             10".
 01 WS-FOOD-TABLE REDEFINES WS-FOODS.
    05 WS-FOOD               OCCURS 18 TIMES.
       10 WS-F-ITEM          PIC X(24).
       10 WS-F-NUTRITION     PIC 99.
 01 WS-I                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-SPECIES              PIC X(24).
 01 L-ITEM                 PIC X(24).
 01 L-OK                   BINARY-LONG.
 01 L-NUTRITION            BINARY-LONG.
 PROCEDURE DIVISION USING L-SPECIES L-ITEM L-OK L-NUTRITION.
     MOVE 0 TO L-OK L-NUTRITION
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 18
         IF WS-F-ITEM(WS-I) = L-ITEM AND (L-SPECIES = "wolf" OR ((L-SPECIES = "cat" OR "ocelot") AND (L-ITEM = "cod" OR "salmon")))
             MOVE 1 TO L-OK
             MOVE WS-F-NUTRITION(WS-I) TO L-NUTRITION
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM M195-FOOD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. M195-HEAL.
*> USING health, max, nutrition, multiplier, new out: the shared tamable feeding routine heals multiplier x the nutrition of the food (2 for a wolf, 1 for a cat), at most max.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 LINKAGE SECTION.
 01 L-HEALTH               BINARY-LONG.
 01 L-MAX                  BINARY-LONG.
 01 L-NUTRITION            BINARY-LONG.
 01 L-MULT                 BINARY-LONG.
 01 L-NEW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-HEALTH L-MAX L-NUTRITION L-MULT L-NEW.
     COMPUTE L-NEW = FUNCTION MIN(L-MAX, L-HEALTH + L-MULT * L-NUTRITION)
     GOBACK.
 END PROGRAM M195-HEAL.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MOB-CARE-USE.
*> USING player row, entity row (a tame wolf or cat), max health, multiplier, consumed out: the main hand on a tame pet. A dye by the owner whose colour is not the collar's sets the
*> collar (EN-COLLAR) and the viewers get the entity data. Food of the species (M195-FOOD) on a pet below max health heals multiplier x nutrition (a cat only for its owner). The item
*> is used (MOB-TAKE) and consumed is 1 when either happened; otherwise 0 and the caller toggles the sit order.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-KEY48               PIC X(48).
 01 WS-ITEM                PIC X(24).
 01 WS-SPECIES             PIC X(24).
 01 WS-COLOR               BINARY-LONG.
 01 WS-FOOD                BINARY-LONG.
 01 WS-NUTRITION           BINARY-LONG.
 01 WS-OWNER               BINARY-LONG.
 01 WS-NEW                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-ENTITY               BINARY-LONG.
 01 L-MAX                  BINARY-LONG.
 01 L-MULT                 BINARY-LONG.
 01 L-CONSUMED             BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-ENTITY L-MAX L-MULT L-CONSUMED.
     MOVE 0 TO L-CONSUMED WS-OWNER
     MOVE SPACES TO WS-KEY48
     IF PL-SLOT-COUNT(L-ROW, PL-HELD(L-ROW) + 1) > 0
         CALL "TOOLUSE-KEY" USING PL-SLOT-ITEM(L-ROW, PL-HELD(L-ROW) + 1) WS-KEY48
     END-IF
     MOVE WS-KEY48 TO WS-ITEM
     CALL "MOB-SPECIES-KEY" USING L-ENTITY WS-SPECIES
     IF EN-OWNER-UUID(L-ENTITY) = PL-UUID(L-ROW)
         MOVE 1 TO WS-OWNER
     END-IF
     CALL "M195-DYE-COLOR" USING WS-ITEM WS-COLOR
     CALL "M195-FOOD" USING WS-SPECIES WS-ITEM WS-FOOD WS-NUTRITION
     EVALUATE TRUE
         WHEN WS-OWNER = 1 AND WS-COLOR >= 0 AND EN-COLLAR(L-ENTITY) NOT = WS-COLOR + 1
             COMPUTE EN-COLLAR(L-ENTITY) = WS-COLOR + 1
             CALL "MOB-TAKE" USING L-ROW
             CALL "MOB-DATA-SEND" USING L-ENTITY
             MOVE 1 TO L-CONSUMED
         WHEN WS-FOOD = 1 AND EN-HEALTH(L-ENTITY) < L-MAX AND (WS-OWNER = 1 OR WS-SPECIES = "wolf")
             CALL "M195-HEAL" USING EN-HEALTH(L-ENTITY) L-MAX WS-NUTRITION L-MULT WS-NEW
             MOVE WS-NEW TO EN-HEALTH(L-ENTITY)
             CALL "MOB-TAKE" USING L-ROW
             MOVE 1 TO L-CONSUMED
     END-EVALUATE
     GOBACK.
 END PROGRAM MOB-CARE-USE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MOB-CAT-USE.
*> USING player row, entity row (a cat or an ocelot): the main hand. An untamed cat with raw cod or salmon: the fish is used and nextInt(3) = 0 tames it (the player is the owner, the sit
*> order, Entity Event 7) else Entity Event 6 (5.1). A tame cat: MOB-CARE-USE (max health 10, multiplier 1), else the owner's hand toggles the sit order. An ocelot that does not trust yet
*> with raw cod or salmon: the fish is used and nextInt(3) = 0 makes it trust (EN-TAMED 1, Entity Event 41, metadata 18) else Entity Event 40 (5.2).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY PROTO.
 01 WS-CAPACITY            BINARY-LONG VALUE 64.
 01 WS-CAT-SALT            BINARY-LONG VALUE 45.
 01 WS-OCELOT-SALT         BINARY-LONG VALUE 46.
 01 WS-BOUND               BINARY-LONG VALUE 3.
 01 WS-CAT-MAX             BINARY-LONG VALUE 10.
 01 WS-CAT-MULT            BINARY-LONG VALUE 1.
 01 WS-DRAW                BINARY-LONG.
 01 WS-OK                  BINARY-LONG.
 01 WS-EVENT               BINARY-LONG.
 01 WS-OWNER               BINARY-LONG.
 01 WS-CONSUMED            BINARY-LONG.
 01 WS-NEW                 BINARY-LONG.
 01 WS-FOOD                BINARY-LONG.
 01 WS-NUTRITION           BINARY-LONG.
 01 WS-KEY48               PIC X(48).
 01 WS-ITEM                PIC X(24).
 01 WS-SPECIES             PIC X(24).
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-ENTITY               BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-ENTITY.
     MOVE SPACES TO WS-KEY48
     IF PL-SLOT-COUNT(L-ROW, PL-HELD(L-ROW) + 1) > 0
         CALL "TOOLUSE-KEY" USING PL-SLOT-ITEM(L-ROW, PL-HELD(L-ROW) + 1) WS-KEY48
     END-IF
     MOVE WS-KEY48 TO WS-ITEM
     CALL "MOB-SPECIES-KEY" USING L-ENTITY WS-SPECIES
     CALL "M195-FOOD" USING WS-SPECIES WS-ITEM WS-FOOD WS-NUTRITION
     EVALUATE TRUE
         WHEN WS-SPECIES = "cat" AND EN-TAMED(L-ENTITY) = 0 AND WS-FOOD = 1
             CALL "MOB-TAKE" USING L-ROW
             CALL "XP-RANDOM" USING WS-CAT-SALT WS-BOUND WS-DRAW
             CALL "M188-TAME-TRY" USING WS-DRAW WS-OK
             MOVE 6 TO WS-EVENT
             IF WS-OK = 1
                 MOVE 7 TO WS-EVENT
                 MOVE 1 TO EN-TAMED(L-ENTITY) EN-SIT(L-ENTITY)
                 MOVE PL-UUID(L-ROW) TO EN-OWNER-UUID(L-ENTITY)
             END-IF
             CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
             CALL "ENTITY-EVENT-BUILD" USING EN-ID(L-ENTITY) WS-EVENT PB-BUFFER
             CALL "HEALTH-VIEWERS-SEND" USING L-ENTITY PB-BUFFER
             CALL "PB-FREE" USING PB-BUFFER
             IF WS-OK = 1
                 CALL "MOB-DATA-SEND" USING L-ENTITY
             END-IF
         WHEN WS-SPECIES = "ocelot" AND EN-TAMED(L-ENTITY) = 0 AND WS-FOOD = 1
             CALL "MOB-TAKE" USING L-ROW
             CALL "XP-RANDOM" USING WS-OCELOT-SALT WS-BOUND WS-DRAW
             CALL "M188-TAME-TRY" USING WS-DRAW WS-OK
             MOVE 40 TO WS-EVENT
             IF WS-OK = 1
                 MOVE 41 TO WS-EVENT
                 MOVE 1 TO EN-TAMED(L-ENTITY)
             END-IF
             CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
             CALL "ENTITY-EVENT-BUILD" USING EN-ID(L-ENTITY) WS-EVENT PB-BUFFER
             CALL "HEALTH-VIEWERS-SEND" USING L-ENTITY PB-BUFFER
             CALL "PB-FREE" USING PB-BUFFER
             IF WS-OK = 1
                 CALL "MOB-DATA-SEND" USING L-ENTITY
             END-IF
         WHEN WS-SPECIES = "cat" AND EN-TAMED(L-ENTITY) = 1
             CALL "MOB-CARE-USE" USING L-ROW L-ENTITY WS-CAT-MAX WS-CAT-MULT WS-CONSUMED
             MOVE 0 TO WS-OWNER
             IF EN-OWNER-UUID(L-ENTITY) = PL-UUID(L-ROW)
                 MOVE 1 TO WS-OWNER
             END-IF
             CALL "M188-SIT-TOGGLE" USING EN-SIT(L-ENTITY) WS-CONSUMED WS-OWNER WS-NEW
             IF WS-NEW NOT = EN-SIT(L-ENTITY)
                 MOVE WS-NEW TO EN-SIT(L-ENTITY)
                 CALL "MOB-DATA-SEND" USING L-ENTITY
             END-IF
     END-EVALUATE
     GOBACK.
 END PROGRAM MOB-CAT-USE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MOB-CARE-DATA.
*> USING row, PB-BUFFER: the entries MOB-DATA-BUILD adds before the end marker for the pets of this file: the collar colour of a dyed wolf (index 21 INT) or cat (index 23 INT, 19
*> section 1.3) and the trusting flag of an ocelot (index 18 BOOLEAN, 5.2).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY PROTO REPLACING LEADING ==PB-== BY ==CD-==.
 01 WS-KEY                 PIC X(24).
 01 WS-COLOR               BINARY-LONG.
 01 WS-SERIALIZER-INT      BINARY-LONG VALUE 1.
 01 WS-SERIALIZER-BOOLEAN  BINARY-LONG VALUE 8.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 COPY PROTO.
 PROCEDURE DIVISION USING L-ROW PB-BUFFER.
     CALL "MOB-SPECIES-KEY" USING L-ROW WS-KEY
     CALL "M195-COLLAR" USING EN-COLLAR(L-ROW) WS-COLOR
     INITIALIZE CD-METADATA-ENTRY-X
     MOVE WS-SERIALIZER-INT TO CD-MX-SERIALIZER
     MOVE WS-COLOR TO CD-MX-INT
     EVALUATE TRUE
         WHEN WS-KEY = "wolf" AND EN-COLLAR(L-ROW) > 0
             MOVE 21 TO CD-MX-INDEX
             CALL "PB-PUT-METADATA-ENTRY-X" USING PB-BUFFER CD-METADATA-ENTRY-X
         WHEN WS-KEY = "cat" AND EN-COLLAR(L-ROW) > 0
             MOVE 23 TO CD-MX-INDEX
             CALL "PB-PUT-METADATA-ENTRY-X" USING PB-BUFFER CD-METADATA-ENTRY-X
         WHEN WS-KEY = "ocelot" AND EN-TAMED(L-ROW) = 1
             MOVE 18 TO CD-MX-INDEX
             MOVE WS-SERIALIZER-BOOLEAN TO CD-MX-SERIALIZER
             MOVE 1 TO CD-MX-INT
             CALL "PB-PUT-METADATA-ENTRY-X" USING PB-BUFFER CD-METADATA-ENTRY-X
     END-EVALUATE
     GOBACK.
 END PROGRAM MOB-CARE-DATA.
