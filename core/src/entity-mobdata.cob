*> The saved gameplay state of a mob (docs/protocol/45-entity-nbt-2 sections 4 and 5, 45-4 sections 3 to 8, 45-5 section 4.1; 07 section 9.3;
*> lane 002-lane-mobsfull-h25). entity-data.cob stores type, position, motion and health; these programs add the keys of the mob's class chain:
*> the age keys of an ageable animal, the owner and sitting order of a tamed pet, the collar, the variant, the saddle, the wolf armour, the
*> baby, powered and size keys of the hostile species, and the leash holder.
*>   MOB-NBT-WRITE USING row, PB-BUFFER      the keys after Health of a mob compound (nothing for a type that has no species row)
*>   MOB-NBT-KEY USING PB-BUFFER, tag type, name, MQ-DATA, handled out   reads one tag of a mob compound into MQ-DATA (handled 1), else leaves it
*>   MOB-NBT-APPLY USING row, MQ-DATA        puts what MOB-NBT-KEY collected into the new mob
*>   MOB-LEASH-RESTORE USING row             a mob loaded leashed: finds the holder among the players of its dimension
*> Open items (recorded in tasks.md T2288): the custom name (no field), LoveCause, the variants of wolf, cat, rabbit and horse (no field), the other
*> equipment slots and the horse armour, the fence-knot form of leash (Int Array of 3), hoglin and piglin age and IsBaby.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MOB-NBT-WRITE.
*> USING row, PB-BUFFER (a mob compound being written, after its Health): the keys of the species of the row in the order of the class chain
*> (Age, ForcedAge, AgeLocked, InLove; Tame, Temper, Trusting, Owner, Sitting; CollarColor; the species keys; equipment; leash).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CITEMS.
 COPY STDMOBS.
 01 WN                     PIC X(32).
 01 WL                     BINARY-LONG.
 01 WS-KEY                 PIC X(24).
 01 WS-CATKEY              PIC X(48).
 01 WS-CV                  BINARY-LONG.
 01 WS-M                   BINARY-LONG.
 01 WS-KIND                BINARY-LONG.
 01 WS-VALUE               BINARY-LONG.
 01 WS-TEXT                PIC X(48).
 01 WS-TEXT-LENGTH         BINARY-LONG.
 01 WS-NS-KEY              PIC X(64).
 01 WS-NS-LENGTH           BINARY-LONG.
 01 WS-DIRECTION           BINARY-LONG VALUE 0.
 01 WS-FOUR                BINARY-LONG VALUE 4.
 01 WS-THREE               BINARY-LONG VALUE 3.
 01 WS-T-COMPOUND          BINARY-LONG VALUE 10.
 01 WS-INTS.
    05 WS-INT              BINARY-LONG OCCURS 4 TIMES.
 01 WS-GENES.
    05 FILLER              PIC X(10) VALUE "normal".
    05 FILLER              PIC X(10) VALUE "lazy".
    05 FILLER              PIC X(10) VALUE "worried".
    05 FILLER              PIC X(10) VALUE "playful".
    05 FILLER              PIC X(10) VALUE "brown".
    05 FILLER              PIC X(10) VALUE "weak".
    05 FILLER              PIC X(10) VALUE "aggressive".
 01 WS-GENE-TABLE REDEFINES WS-GENES.
    05 WS-GENE             PIC X(10) OCCURS 7 TIMES.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 COPY PROTO.
 PROCEDURE DIVISION USING L-ROW PB-BUFFER.
*>   The Mob keys written every time (45-2 section 3): CanPickUpLoot, PersistenceRequired, LeftHanded (no state here: false).
     MOVE "CanPickUpLoot" TO WN MOVE 13 TO WL
     CALL "NBT-WRITE-BYTE" USING PB-BUFFER WN WL WS-DIRECTION
     MOVE "PersistenceRequired" TO WN MOVE 19 TO WL
     CALL "NBT-WRITE-BYTE" USING PB-BUFFER WN WL EN-PERSISTENT(L-ROW)
     MOVE "LeftHanded" TO WN MOVE 10 TO WL
     CALL "NBT-WRITE-BYTE" USING PB-BUFFER WN WL WS-DIRECTION
     CALL "MOB-SPECIES-KEY" USING L-ROW WS-KEY
     IF WS-KEY = SPACES
         GOBACK
     END-IF
     CALL "STDMOB-INDEX" USING EN-TYPE(L-ROW) WS-M
     MOVE SM-KIND(WS-M) TO WS-KIND
*>   AgeableMob and Animal: every passive species but the allay and the golems.
     IF WS-KIND = 0 AND NOT (WS-KEY = "allay" OR "iron_golem" OR "snow_golem")
         MOVE "Age" TO WN MOVE 3 TO WL
         CALL "NBT-WRITE-INT" USING PB-BUFFER WN WL EN-MOBAGE(L-ROW)
         MOVE "ForcedAge" TO WN MOVE 9 TO WL
         CALL "NBT-WRITE-INT" USING PB-BUFFER WN WL EN-FORCED(L-ROW)
         MOVE "AgeLocked" TO WN MOVE 9 TO WL
         CALL "NBT-WRITE-BYTE" USING PB-BUFFER WN WL EN-LOCKED(L-ROW)
         MOVE "InLove" TO WN MOVE 6 TO WL
         CALL "NBT-WRITE-INT" USING PB-BUFFER WN WL EN-LOVE(L-ROW)
     END-IF
*>   AbstractHorse: Tame and Temper.
     IF WS-KEY = "horse" OR "donkey" OR "mule" OR "llama" OR "trader_llama" OR "camel"
         MOVE "Tame" TO WN MOVE 4 TO WL
         CALL "NBT-WRITE-BYTE" USING PB-BUFFER WN WL EN-TAMED(L-ROW)
         MOVE "Temper" TO WN MOVE 6 TO WL
         CALL "NBT-WRITE-INT" USING PB-BUFFER WN WL EN-TEMPER(L-ROW)
     END-IF
     IF WS-KEY = "ocelot"
         MOVE "Trusting" TO WN MOVE 8 TO WL
         CALL "NBT-WRITE-BYTE" USING PB-BUFFER WN WL EN-TAMED(L-ROW)
     END-IF
*>   The owner of a pet or an equine (the UUID as four Ints), then the sitting order of a pet.
     IF WS-KEY = "horse" OR "donkey" OR "mule" OR "llama" OR "trader_llama" OR "camel" OR "wolf" OR "cat" OR "parrot"
         IF EN-OWNER-UUID(L-ROW) NOT = SPACES
             MOVE "Owner" TO WN MOVE 5 TO WL
             CALL "PERSIST-UUID-INTS" USING WS-DIRECTION EN-OWNER-UUID(L-ROW) WS-INTS
             CALL "NBT-WRITE-INT-ARRAY" USING PB-BUFFER WN WL WS-FOUR WS-INTS
         END-IF
     END-IF
     IF WS-KEY = "wolf" OR "cat" OR "parrot"
         MOVE "Sitting" TO WN MOVE 7 TO WL
         CALL "NBT-WRITE-BYTE" USING PB-BUFFER WN WL EN-SIT(L-ROW)
     END-IF
*>   The collar: the dye id, 14 (red) when never dyed.
     IF WS-KEY = "wolf" OR "cat"
         MOVE "CollarColor" TO WN MOVE 11 TO WL
         MOVE 14 TO WS-VALUE
         IF EN-COLLAR(L-ROW) > 0
             COMPUTE WS-VALUE = EN-COLLAR(L-ROW) - 1
         END-IF
         CALL "NBT-WRITE-INT" USING PB-BUFFER WN WL WS-VALUE
     END-IF
*>   The species keys.
     IF WS-KEY = "sheep"
         MOVE "Sheared" TO WN MOVE 7 TO WL
         COMPUTE WS-VALUE = FUNCTION INTEGER(EN-WOOL(L-ROW) / 16)
         CALL "NBT-WRITE-BYTE" USING PB-BUFFER WN WL WS-VALUE
         MOVE "Color" TO WN MOVE 5 TO WL
         COMPUTE WS-VALUE = FUNCTION MOD(EN-WOOL(L-ROW), 16)
         CALL "NBT-WRITE-INT" USING PB-BUFFER WN WL WS-VALUE
     END-IF
     IF WS-KEY = "mooshroom" OR "fox"
         MOVE "Type" TO WN MOVE 4 TO WL
         MOVE "red" TO WS-TEXT
         IF EN-WOOL(L-ROW) = 1 AND WS-KEY = "fox"
             MOVE "snow" TO WS-TEXT
         END-IF
         IF EN-WOOL(L-ROW) = 1 AND WS-KEY = "mooshroom"
             MOVE "brown" TO WS-TEXT
         END-IF
         COMPUTE WS-TEXT-LENGTH = FUNCTION LENGTH(FUNCTION TRIM(WS-TEXT))
         CALL "NBT-WRITE-STRING" USING PB-BUFFER WN WL WS-TEXT WS-TEXT-LENGTH
     END-IF
     IF WS-KEY = "cat"
         MOVE "variant" TO WN MOVE 7 TO WL
         CALL "M44-VARIANT-KEY" USING WS-KEY EN-WOOL(L-ROW) WS-CATKEY
         MOVE SPACES TO WS-TEXT
         STRING "minecraft:" FUNCTION TRIM(WS-CATKEY) DELIMITED BY SIZE INTO WS-TEXT
         COMPUTE WS-TEXT-LENGTH = FUNCTION LENGTH(FUNCTION TRIM(WS-TEXT))
         CALL "NBT-WRITE-STRING" USING PB-BUFFER WN WL WS-TEXT WS-TEXT-LENGTH
     END-IF
     IF WS-KEY = "pig" OR "cow" OR "chicken"
         MOVE "variant" TO WN MOVE 7 TO WL
         MOVE "minecraft:temperate" TO WS-TEXT
         IF EN-WOOL(L-ROW) = 1
             MOVE "minecraft:cold" TO WS-TEXT
         END-IF
         IF EN-WOOL(L-ROW) = 2
             MOVE "minecraft:warm" TO WS-TEXT
         END-IF
         COMPUTE WS-TEXT-LENGTH = FUNCTION LENGTH(FUNCTION TRIM(WS-TEXT))
         CALL "NBT-WRITE-STRING" USING PB-BUFFER WN WL WS-TEXT WS-TEXT-LENGTH
     END-IF
     IF WS-KEY = "chicken"
         MOVE "EggLayTime" TO WN MOVE 10 TO WL
         CALL "NBT-WRITE-INT" USING PB-BUFFER WN WL EN-EGG(L-ROW)
     END-IF
     IF WS-KEY = "llama" OR "trader_llama" OR "parrot"
         MOVE "Variant" TO WN MOVE 7 TO WL
         CALL "NBT-WRITE-INT" USING PB-BUFFER WN WL EN-WOOL(L-ROW)
     END-IF
     IF WS-KEY = "llama" OR "trader_llama"
         MOVE "Strength" TO WN MOVE 8 TO WL
         CALL "NBT-WRITE-INT" USING PB-BUFFER WN WL EN-STRENGTH(L-ROW)
     END-IF
     IF WS-KEY = "panda"
         MOVE "MainGene" TO WN MOVE 8 TO WL
         MOVE WS-GENE(EN-GENE-MAIN(L-ROW) + 1) TO WS-TEXT
         COMPUTE WS-TEXT-LENGTH = FUNCTION LENGTH(FUNCTION TRIM(WS-TEXT))
         CALL "NBT-WRITE-STRING" USING PB-BUFFER WN WL WS-TEXT WS-TEXT-LENGTH
         MOVE "HiddenGene" TO WN MOVE 10 TO WL
         MOVE WS-GENE(EN-GENE-HIDDEN(L-ROW) + 1) TO WS-TEXT
         COMPUTE WS-TEXT-LENGTH = FUNCTION LENGTH(FUNCTION TRIM(WS-TEXT))
         CALL "NBT-WRITE-STRING" USING PB-BUFFER WN WL WS-TEXT WS-TEXT-LENGTH
     END-IF
     IF WS-KEY = "zombie" OR "husk" OR "zombie_villager" OR "zombified_piglin"
         MOVE "IsBaby" TO WN MOVE 6 TO WL
         CALL "NBT-WRITE-BYTE" USING PB-BUFFER WN WL EN-VARIANT(L-ROW)
     END-IF
     IF WS-KEY = "creeper"
         MOVE "powered" TO WN MOVE 7 TO WL
         CALL "NBT-WRITE-BYTE" USING PB-BUFFER WN WL EN-VARIANT(L-ROW)
     END-IF
     IF WS-KEY = "slime" OR "magma_cube"
         MOVE "Size" TO WN MOVE 4 TO WL
         COMPUTE WS-VALUE = FUNCTION MAX(EN-VARIANT(L-ROW), 1) - 1
         CALL "NBT-WRITE-INT" USING PB-BUFFER WN WL WS-VALUE
     END-IF
     CALL "SPECIES4-NBT-WRITE" USING L-ROW WS-KEY PB-BUFFER
*>   equipment: the main hand, the armour, the saddle slot and the wolf's body slot (MOB-EQUIP-WRITE).
     CALL "MOB-EQUIP-WRITE" USING L-ROW WS-KEY PB-BUFFER
*>   leash: the holder's UUID (a player; the lead is restored when that player is in the dimension, MOB-LEASH-RESTORE).
     IF EN-LEASH(L-ROW) > 0
         MOVE "leash" TO WN MOVE 5 TO WL
         CALL "NBT-WRITE-COMPOUND-BEGIN" USING PB-BUFFER WN WL
         MOVE "UUID" TO WN MOVE 4 TO WL
         CALL "PERSIST-UUID-INTS" USING WS-DIRECTION PL-UUID(EN-LEASH(L-ROW)) WS-INTS
         CALL "NBT-WRITE-INT-ARRAY" USING PB-BUFFER WN WL WS-FOUR WS-INTS
         CALL "NBT-WRITE-COMPOUND-END" USING PB-BUFFER
     END-IF
*>   held by a fence knot: the knot's block position as an Int Array of 3 (45 section 10.1); the knot itself is not saved.
     IF EN-LEASH-KNOT(L-ROW) > 0
         MOVE "leash" TO WN MOVE 5 TO WL
         COMPUTE WS-INT(1) = FUNCTION INTEGER(EN-X(EN-LEASH-KNOT(L-ROW)))
         COMPUTE WS-INT(2) = FUNCTION INTEGER(EN-Y(EN-LEASH-KNOT(L-ROW)))
         COMPUTE WS-INT(3) = FUNCTION INTEGER(EN-Z(EN-LEASH-KNOT(L-ROW)))
         CALL "NBT-WRITE-INT-ARRAY" USING PB-BUFFER WN WL WS-THREE WS-INTS
     END-IF
     GOBACK.
 END PROGRAM MOB-NBT-WRITE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MOB-NBT-KEY.
*> USING PB-BUFFER (a mob compound at the payload of the tag; ENTITY-NBT-ONE reads Age itself), tag type (BINARY-LONG), name (PIC X(32)), MQ-DATA, handled out (BINARY-LONG): when
*> the tag is one of the keys MOB-NBT-WRITE writes, its payload is read into MQ-DATA and handled is 1; otherwise nothing is read and handled is 0.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CITEMS.
 01 WS-BYTE                BINARY-LONG.
 01 WS-TO-UUID             BINARY-LONG VALUE 1.
 01 WS-INT-CAPACITY        BINARY-LONG VALUE 4.
 01 WS-INT-COUNT           BINARY-LONG.
 01 WS-KM.
    05 WS-KM-MARK          PIC X(4).
    05 WS-KM-X             BINARY-LONG.
    05 WS-KM-Y             BINARY-LONG.
    05 WS-KM-Z             BINARY-LONG.
 01 WS-INTS.
    05 WS-INT              BINARY-LONG OCCURS 4 TIMES.
 01 WS-TEXT-CAPACITY       BINARY-LONG VALUE 48.
 01 WS-TEXT-LENGTH         BINARY-LONG.
 01 WS-START               BINARY-LONG.
 01 WS-CONTAINER           BINARY-LONG VALUE 10.
 01 WS-FOUND               BINARY-LONG.
 01 WS-PATH                PIC X(48).
 01 WS-PATH-LENGTH         BINARY-LONG.
 01 WS-KEY                 PIC X(64).
 01 WS-KEY-CAPACITY        BINARY-LONG VALUE 64.
 01 WS-KEY-LENGTH          BINARY-LONG.
 01 WS-LOCAL               PIC X(48).
 01 WS-BARE                PIC X(48).
 01 WS-I                   BINARY-LONG.
 LINKAGE SECTION.
 COPY PROTO.
 01 L-TYPE                 BINARY-LONG.
 01 L-NAME                 PIC X(32).
 COPY ENMOBDATA.
 01 L-HANDLED              BINARY-LONG.
 PROCEDURE DIVISION USING PB-BUFFER L-TYPE L-NAME MQ-DATA L-HANDLED.
     MOVE 1 TO L-HANDLED
     MOVE PB-POS TO WS-START
     EVALUATE TRUE
         WHEN L-NAME = "ForcedAge" AND L-TYPE = 3
             CALL "PB-GET-INT" USING PB-BUFFER MQ-FORCED
         WHEN L-NAME = "AgeLocked" AND L-TYPE = 1
             CALL "PB-GET-BYTE" USING PB-BUFFER MQ-LOCKED
         WHEN L-NAME = "InLove" AND L-TYPE = 3
             CALL "PB-GET-INT" USING PB-BUFFER MQ-LOVE
         WHEN L-NAME = "Owner" AND L-TYPE = 11
             CALL "NBT-READ-INT-ARRAY" USING PB-BUFFER WS-INT-CAPACITY WS-INT-COUNT WS-INTS
             CALL "PERSIST-UUID-INTS" USING WS-TO-UUID MQ-OWNER WS-INTS
         WHEN L-NAME = "Sitting" AND L-TYPE = 1
             CALL "PB-GET-BYTE" USING PB-BUFFER MQ-SIT
         WHEN L-NAME = "Tame" AND L-TYPE = 1
             CALL "PB-GET-BYTE" USING PB-BUFFER MQ-TAME
         WHEN L-NAME = "Trusting" AND L-TYPE = 1
             CALL "PB-GET-BYTE" USING PB-BUFFER MQ-TRUST
         WHEN L-NAME = "CollarColor" AND L-TYPE = 3
             CALL "PB-GET-INT" USING PB-BUFFER MQ-COLLAR
         WHEN L-NAME = "Sheared" AND L-TYPE = 1
             CALL "PB-GET-BYTE" USING PB-BUFFER MQ-SHEARED
         WHEN L-NAME = "Color" AND L-TYPE = 3
             CALL "PB-GET-INT" USING PB-BUFFER MQ-COLOR
         WHEN L-NAME = "Type" AND L-TYPE = 8
             MOVE SPACES TO MQ-TYPE-NAME
             CALL "NBT-READ-STRING" USING PB-BUFFER MQ-TYPE-NAME WS-TEXT-CAPACITY WS-TEXT-LENGTH
         WHEN L-NAME = "variant" AND L-TYPE = 8
             MOVE SPACES TO MQ-VARIANT-NAME
             CALL "NBT-READ-STRING" USING PB-BUFFER MQ-VARIANT-NAME WS-TEXT-CAPACITY WS-TEXT-LENGTH
         WHEN L-NAME = "Variant" AND L-TYPE = 3
             CALL "PB-GET-INT" USING PB-BUFFER MQ-VARIANT-INT
         WHEN L-NAME = "Strength" AND L-TYPE = 3
             CALL "PB-GET-INT" USING PB-BUFFER MQ-STRENGTH
         WHEN L-NAME = "Temper" AND L-TYPE = 3
             CALL "PB-GET-INT" USING PB-BUFFER MQ-TEMPER
         WHEN L-NAME = "EggLayTime" AND L-TYPE = 3
             CALL "PB-GET-INT" USING PB-BUFFER MQ-EGG
         WHEN L-NAME = "MainGene" AND L-TYPE = 8
             MOVE SPACES TO MQ-GENE-MAIN
             CALL "NBT-READ-STRING" USING PB-BUFFER MQ-GENE-MAIN WS-TEXT-CAPACITY WS-TEXT-LENGTH
         WHEN L-NAME = "HiddenGene" AND L-TYPE = 8
             MOVE SPACES TO MQ-GENE-HIDDEN
             CALL "NBT-READ-STRING" USING PB-BUFFER MQ-GENE-HIDDEN WS-TEXT-CAPACITY WS-TEXT-LENGTH
         WHEN L-NAME = "IsBaby" AND L-TYPE = 1
             CALL "PB-GET-BYTE" USING PB-BUFFER MQ-BABY
         WHEN L-NAME = "powered" AND L-TYPE = 1
             CALL "PB-GET-BYTE" USING PB-BUFFER MQ-POWERED
         WHEN L-NAME = "Size" AND L-TYPE = 3
             CALL "PB-GET-INT" USING PB-BUFFER MQ-SIZE
         WHEN L-NAME = "PersistenceRequired" AND L-TYPE = 1
             CALL "PB-GET-BYTE" USING PB-BUFFER MQ-PERSIST
         WHEN L-NAME = "VillagerData" AND L-TYPE = 10
*>           The compound {profession, level, type}: the profession key (without its namespace) and the level; the type follows the biome (19 section 22.1).
             MOVE "profession" TO WS-PATH
             MOVE 10 TO WS-PATH-LENGTH
             CALL "NBT-READ-FIND" USING PB-BUFFER WS-CONTAINER WS-PATH WS-PATH-LENGTH WS-FOUND
             IF WS-FOUND = 8
                 MOVE SPACES TO WS-KEY
                 CALL "NBT-READ-STRING" USING PB-BUFFER WS-KEY WS-KEY-CAPACITY WS-KEY-LENGTH
                 CALL "PERSIST-LOCAL-KEY" USING WS-KEY WS-LOCAL
                 CALL "KEY-BARE" USING WS-LOCAL WS-BARE
                 MOVE WS-BARE TO MQ-PROF
             END-IF
             MOVE WS-START TO PB-POS
             MOVE "level" TO WS-PATH
             MOVE 5 TO WS-PATH-LENGTH
             CALL "NBT-READ-FIND" USING PB-BUFFER WS-CONTAINER WS-PATH WS-PATH-LENGTH WS-FOUND
             IF WS-FOUND = 3
                 CALL "PB-GET-INT" USING PB-BUFFER MQ-VLEVEL
             END-IF
             MOVE WS-START TO PB-POS
             CALL "NBT-READ-SKIP" USING PB-BUFFER L-TYPE
         WHEN L-NAME = "leash" AND L-TYPE = 10
*>           The compound {UUID: Int Array(4)}; the whole compound is skipped after the one entry is read.
             MOVE "UUID" TO WS-PATH
             MOVE 4 TO WS-PATH-LENGTH
             CALL "NBT-READ-FIND" USING PB-BUFFER WS-CONTAINER WS-PATH WS-PATH-LENGTH WS-FOUND
             IF WS-FOUND = 11
                 CALL "NBT-READ-INT-ARRAY" USING PB-BUFFER WS-INT-CAPACITY WS-INT-COUNT WS-INTS
                 CALL "PERSIST-UUID-INTS" USING WS-TO-UUID MQ-LEASH WS-INTS
             END-IF
             MOVE WS-START TO PB-POS
             CALL "NBT-READ-SKIP" USING PB-BUFFER L-TYPE
         WHEN L-NAME = "leash" AND L-TYPE = 11
*>           The block position of a fence knot: kept in MQ-LEASH as "KNOT" and the three ints (MOB-LEASH-RESTORE).
             CALL "NBT-READ-INT-ARRAY" USING PB-BUFFER WS-INT-CAPACITY WS-INT-COUNT WS-INTS
             IF WS-INT-COUNT = 3
                 MOVE "KNOT" TO WS-KM-MARK
                 MOVE WS-INT(1) TO WS-KM-X
                 MOVE WS-INT(2) TO WS-KM-Y
                 MOVE WS-INT(3) TO WS-KM-Z
                 MOVE WS-KM TO MQ-LEASH
             END-IF
         WHEN L-NAME = "equipment" AND L-TYPE = 10
*>           The slots of MOB-EQUIP-WRITE: saddle, body, main hand and armour.
             CALL "MOB-EQUIP-READ" USING PB-BUFFER MQ-DATA
         WHEN OTHER
             MOVE 0 TO L-HANDLED
     END-EVALUATE
     GOBACK.
 END PROGRAM MOB-NBT-KEY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MOB-NBT-APPLY.
*> USING row, MQ-DATA: what MOB-NBT-KEY collected becomes the state of the mob of the row (its fields as MOB-NBT-WRITE took them): the age state of
*> an animal (a negative age is a baby: EN-VARIANT 1), the owner and tame state, the collar (the dye id + 1, the default red 14 stays 0), the variant
*> and type, strength and temper, the saddle, the wolf armour, the hostile species' baby, powered and size, and the pending leash holder.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY STDMOBS.
 COPY VILSTATE.
 01 WS-KEY                 PIC X(24).
 01 WS-CATKEY              PIC X(48).
 01 WS-CV                  BINARY-LONG.
 01 WS-M                   BINARY-LONG.
 01 WS-KIND                BINARY-LONG.
 01 WS-BARE                PIC X(48).
 01 WS-LOCAL               PIC X(48).
 01 WS-I                   BINARY-LONG.
 01 WS-GENE-NAMES.
    05 FILLER              PIC X(10) VALUE "normal".
    05 FILLER              PIC X(10) VALUE "lazy".
    05 FILLER              PIC X(10) VALUE "worried".
    05 FILLER              PIC X(10) VALUE "playful".
    05 FILLER              PIC X(10) VALUE "brown".
    05 FILLER              PIC X(10) VALUE "weak".
    05 FILLER              PIC X(10) VALUE "aggressive".
 01 WS-GENE-TABLE REDEFINES WS-GENE-NAMES.
    05 WS-GENE             PIC X(10) OCCURS 7 TIMES.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-SLOT                BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 COPY ENMOBDATA.
 PROCEDURE DIVISION USING L-ROW MQ-DATA.
     MOVE MQ-PERSIST TO EN-PERSISTENT(L-ROW)
     CALL "MOB-SPECIES-KEY" USING L-ROW WS-KEY
     IF WS-KEY = SPACES
         GOBACK
     END-IF
     CALL "STDMOB-INDEX" USING EN-TYPE(L-ROW) WS-M
     MOVE SM-KIND(WS-M) TO WS-KIND
     IF WS-KIND = 0 AND NOT (WS-KEY = "allay" OR "iron_golem" OR "snow_golem")
         MOVE MQ-AGE TO EN-MOBAGE(L-ROW)
         MOVE MQ-FORCED TO EN-FORCED(L-ROW)
         MOVE MQ-LOCKED TO EN-LOCKED(L-ROW)
         MOVE MQ-LOVE TO EN-LOVE(L-ROW)
         MOVE 0 TO EN-VARIANT(L-ROW)
         IF MQ-AGE < 0
             MOVE 1 TO EN-VARIANT(L-ROW)
         END-IF
     END-IF
*>   An owner makes a pet tame; an equine is tame by its own key.
     IF WS-KEY = "wolf" OR "cat" OR "parrot"
         MOVE MQ-SIT TO EN-SIT(L-ROW)
         IF MQ-OWNER NOT = SPACES
             MOVE 1 TO EN-TAMED(L-ROW)
             MOVE MQ-OWNER TO EN-OWNER-UUID(L-ROW)
         END-IF
     END-IF
     IF WS-KEY = "horse" OR "donkey" OR "mule" OR "llama" OR "trader_llama" OR "camel"
         MOVE MQ-TAME TO EN-TAMED(L-ROW)
         MOVE MQ-TEMPER TO EN-TEMPER(L-ROW)
         IF MQ-OWNER NOT = SPACES
             MOVE MQ-OWNER TO EN-OWNER-UUID(L-ROW)
         END-IF
     END-IF
     IF WS-KEY = "ocelot"
         MOVE MQ-TRUST TO EN-TAMED(L-ROW)
     END-IF
     IF WS-KEY = "wolf" OR "cat"
         MOVE 0 TO EN-COLLAR(L-ROW)
         IF MQ-COLLAR NOT = 14
             COMPUTE EN-COLLAR(L-ROW) = MQ-COLLAR + 1
         END-IF
     END-IF
     IF WS-KEY = "cat" AND MQ-VARIANT-NAME NOT = SPACES
         MOVE MQ-VARIANT-NAME TO WS-LOCAL
         CALL "KEY-BARE" USING WS-LOCAL WS-BARE
         MOVE 0 TO EN-WOOL(L-ROW)
         PERFORM VARYING WS-CV FROM 1 BY 1 UNTIL WS-CV > 10
             CALL "M44-VARIANT-KEY" USING WS-KEY WS-CV WS-CATKEY
             IF WS-CATKEY = WS-BARE
                 MOVE WS-CV TO EN-WOOL(L-ROW)
             END-IF
         END-PERFORM
     END-IF
     IF WS-KEY = "sheep"
         COMPUTE EN-WOOL(L-ROW) = FUNCTION MOD(MQ-COLOR, 16) + 16 * MQ-SHEARED
     END-IF
     IF WS-KEY = "mooshroom" OR "fox"
         MOVE 0 TO EN-WOOL(L-ROW)
         IF MQ-TYPE-NAME = "brown" OR "snow"
             MOVE 1 TO EN-WOOL(L-ROW)
         END-IF
     END-IF
     IF (WS-KEY = "pig" OR "cow" OR "chicken") AND MQ-VARIANT-NAME NOT = SPACES
         MOVE MQ-VARIANT-NAME TO WS-LOCAL
         CALL "KEY-BARE" USING WS-LOCAL WS-BARE
         MOVE 0 TO EN-WOOL(L-ROW)
         IF WS-BARE = "cold"
             MOVE 1 TO EN-WOOL(L-ROW)
         END-IF
         IF WS-BARE = "warm"
             MOVE 2 TO EN-WOOL(L-ROW)
         END-IF
     END-IF
     IF WS-KEY = "chicken" AND MQ-EGG >= 0
         MOVE MQ-EGG TO EN-EGG(L-ROW)
     END-IF
     IF (WS-KEY = "llama" OR "trader_llama") AND MQ-VARIANT-INT >= 0
         COMPUTE EN-WOOL(L-ROW) = FUNCTION MIN(MQ-VARIANT-INT, 3)
     END-IF
     IF WS-KEY = "parrot" AND MQ-VARIANT-INT >= 0
         COMPUTE EN-WOOL(L-ROW) = FUNCTION MIN(MQ-VARIANT-INT, 4)
     END-IF
     IF (WS-KEY = "llama" OR "trader_llama") AND MQ-STRENGTH > 0
         COMPUTE EN-STRENGTH(L-ROW) = FUNCTION MIN(MQ-STRENGTH, 5)
     END-IF
     IF WS-KEY = "panda"
         MOVE 0 TO EN-GENE-MAIN(L-ROW) EN-GENE-HIDDEN(L-ROW)
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 7
             IF WS-GENE(WS-I) = MQ-GENE-MAIN
                 COMPUTE EN-GENE-MAIN(L-ROW) = WS-I - 1
             END-IF
             IF WS-GENE(WS-I) = MQ-GENE-HIDDEN
                 COMPUTE EN-GENE-HIDDEN(L-ROW) = WS-I - 1
             END-IF
         END-PERFORM
     END-IF
     IF WS-KEY = "zombie" OR "husk" OR "zombie_villager" OR "zombified_piglin"
         MOVE MQ-BABY TO EN-VARIANT(L-ROW)
     END-IF
     IF WS-KEY = "creeper"
         MOVE MQ-POWERED TO EN-VARIANT(L-ROW)
     END-IF
     IF (WS-KEY = "slime" OR "magma_cube") AND MQ-SIZE >= 0
         COMPUTE EN-VARIANT(L-ROW) = MQ-SIZE + 1
     END-IF
     IF WS-KEY = "pig" OR "horse" OR "donkey" OR "mule" OR "camel"
         MOVE MQ-SADDLE TO EN-SADDLE(L-ROW)
     END-IF
     IF WS-KEY = "wolf"
         MOVE MQ-BODY TO EN-WOLF-ARM(L-ROW)
         MOVE MQ-BODY-DMG TO EN-WOLF-ARM-DMG(L-ROW)
     END-IF
     MOVE MQ-HAND TO EN-HAND(L-ROW)
     MOVE MQ-EQUIP TO EN-EQUIP(L-ROW)
     MOVE MQ-HEAD-WEAR TO EN-HEAD-WEAR(L-ROW)
     MOVE MQ-LEASH TO EN-LEASH-UUID(L-ROW)
*>   A villager keeps the profession and level it was saved with (a template's nitwit); a profession of "none" is the default.
     IF WS-KEY = "villager" AND MQ-PROF NOT = SPACES AND MQ-PROF NOT = "none"
         CALL "VL-FIND" USING EN-ID(L-ROW) WS-ZERO WS-SLOT
         IF WS-SLOT > 0
             MOVE MQ-PROF TO VL-PROF(WS-SLOT)
             IF MQ-VLEVEL > 0
                 MOVE MQ-VLEVEL TO VL-LEVEL(WS-SLOT)
             END-IF
         END-IF
     END-IF
     GOBACK.
 END PROGRAM MOB-NBT-APPLY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MOB-LEASH-RESTORE.
*> USING row (a mob whose EN-LEASH-UUID is set, loaded from a save): the lead goes to the player of that UUID who is in the mob's dimension (EN-LEASH,
*> Set Entity Link to the viewers, EN-LEASH-UUID cleared); until such a player is there the mob waits unleashed.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-P                   BINARY-LONG.
 01 WS-KM.
    05 WS-KM-MARK          PIC X(4).
    05 WS-KM-X             BINARY-LONG.
    05 WS-KM-Y             BINARY-LONG.
    05 WS-KM-Z             BINARY-LONG.
 01 WS-KNOT                BINARY-LONG.
 01 WS-CREATED             BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
*>   A fence knot ("KNOT" and the block position, see MOB-NBT-APPLY): the knot is found or made there.
     MOVE EN-LEASH-UUID(L-ROW) TO WS-KM
     IF WS-KM-MARK = "KNOT"
         CALL "MOB-KNOT-GET" USING EN-DIM(L-ROW) WS-KM-X WS-KM-Y WS-KM-Z WS-KNOT WS-CREATED
         MOVE WS-KNOT TO EN-LEASH-KNOT(L-ROW)
         MOVE SPACES TO EN-LEASH-UUID(L-ROW)
         CALL "MOB-LEASH-LINK" USING L-ROW EN-ID(WS-KNOT)
     END-IF
     PERFORM VARYING WS-P FROM 1 BY 1 UNTIL WS-P > CORE-MAX-PLAYERS
         IF PL-USED(WS-P) = 1 AND PL-UUID(WS-P) = EN-LEASH-UUID(L-ROW) AND PL-DIM(WS-P) = EN-DIM(L-ROW)
             MOVE WS-P TO EN-LEASH(L-ROW)
             MOVE SPACES TO EN-LEASH-UUID(L-ROW)
             CALL "MOB-LEASH-LINK" USING L-ROW PL-ENTITY-ID(WS-P)
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM MOB-LEASH-RESTORE.
