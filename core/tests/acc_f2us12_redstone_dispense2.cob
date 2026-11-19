*> Acceptance test (T29530..T29539, US12-4; docs/protocol/30-redstone-4 sections 4.5, 4.6, 4.10, 4.11, 4.13 and 4.22): the registered behaviours of a dispenser other than TNT: flint and steel lights the
*> fire in front or primes TNT and is not spent, bone meal grows a crop, the water bucket places a source and leaves an empty bucket, the empty bucket takes a source and leaves the filled one, a minecart
*> comes out onto a rail, a spawn egg spawns its mob. Needs the generated packs.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-F2US12-REDSTONE-DISPENSE2.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY DIMENSIONS.
 COPY CBLOCKS.
 COPY CITEMS.
 COPY BESTATE.
 COPY PROJSTATE.
 01 WS-SKIP                BINARY-LONG.
 01 WS-NAME                PIC X(16) VALUE "Alice".
 01 WS-NAME-LENGTH         BINARY-LONG VALUE 5.
 01 WS-ALICE               BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-K                   PIC X(48).
 01 WS-PR                  PIC X(160).
 01 WS-ST                  BINARY-LONG.
 01 WS-ST2                 BINARY-LONG.
 01 WS-PN                  PIC X(16).
 01 WS-PV                  PIC X(16).
 01 WS-OLD                 PIC X(16).
 01 WS-FLAGS               BINARY-LONG VALUE 3.
 01 WS-BUDGET              BINARY-LONG VALUE 512.
 01 WS-RESULT              BINARY-LONG.
 01 WS-TICKS               BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-PROPS               PIC X(160).
 01 WS-EXP                 PIC X(160).
 01 WS-CASE                PIC X(240).
 01 WS-WIRE-BLOCK          BINARY-LONG.
 01 WS-ID                  BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-E                   BINARY-LONG.
 01 WS-S                   BINARY-LONG.
 01 WS-W                   BINARY-LONG.
 01 WS-P                   BINARY-LONG.
 01 WS-D                   BINARY-LONG.
 01 WS-SIG                 BINARY-LONG.
 01 WS-ED                  PIC -(9)9.
 01 WS-PX                  FLOAT-LONG.
 01 WS-BE                  BINARY-LONG.
 01 WS-BE2                 BINARY-LONG.
 01 WS-ITEM                BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-FKEY                PIC X(112).
 01 WS-FY                  FLOAT-LONG.
 01 WS-FZ                  FLOAT-LONG.
 01 WS-FROW                BINARY-LONG.
 01 WS-FSLOT               BINARY-LONG.
 01 WS-FDIR                BINARY-LONG.
 01 WS-FKIND               BINARY-LONG.
 01 WS-K2                  PIC X(48).
 01 WS-P1N                 PIC X(16).
 01 WS-P1V                 PIC X(16).
 01 WS-P2N                 PIC X(16).
 01 WS-BLOCK               BINARY-LONG.
 01 WS-BE3                 BINARY-LONG.
 01 WS-TNT-TYPE            BINARY-LONG.
 01 WS-ENTITY-ROW          PIC X(66).
 01 WS-KEY112              PIC X(112).
 01 WS-STATUS              BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-RULE-NAME           PIC X(40).
 01 WS-RULE-INDEX          BINARY-LONG.
 01 WS-RULE-VALUE          BINARY-DOUBLE.
 01 WS-BEFORE              BINARY-LONG.
 01 WS-TNT-BEFORE          BINARY-LONG.
 01 WS-ITEM2               BINARY-LONG.
 01 WS-HITS                BINARY-LONG.
 01 WS-KEYN                PIC X(48).
 01 WS-EXP-TMP             PIC X(160).
 01 WS-ECOUNT              BINARY-LONG.
 01 WS-EKEY                PIC X(48).
 01 WS-HIT                 BINARY-LONG.
 PROCEDURE DIVISION.
     MOVE "T" TO TL-MODE
     CALL "PT-OPEN" USING WS-SKIP
     IF WS-SKIP = 1
         MOVE "N" TO TL-MODE
         MOVE "acceptance US12-4 redstone dispense: no generated packs here, skipped" TO TL-CASE
         MOVE 1 TO TL-EXPECTED-N
         MOVE 1 TO TL-OBSERVED-N
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
         STOP RUN
     END-IF
     MOVE DIM-STANDARD-OVERWORLD TO WS-DIM
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-ALICE
     MOVE CN-PLAYER(WS-ALICE) TO WS-ROW
     MOVE 1 TO PL-MODE(WS-ROW)
     PERFORM VARYING WS-ID FROM 1 BY 1 UNTIL WS-ID > CB-BLOCK-COUNT
         IF CB-KEY(WS-ID) = "redstone_wire"
             COMPUTE WS-WIRE-BLOCK = WS-ID
         END-IF
     END-PERFORM
     PERFORM VARYING WS-Z FROM 0 BY 1 UNTIL WS-Z > 30
         PERFORM VARYING WS-X FROM 0 BY 1 UNTIL WS-X > 6
             MOVE 100 TO WS-Y
             MOVE "stone" TO WS-K
             PERFORM PUT-DEF
             PERFORM VARYING WS-Y FROM 101 BY 1 UNTIL WS-Y > 103
                 MOVE "air" TO WS-K
                 PERFORM PUT-DEF
             END-PERFORM
         END-PERFORM
     END-PERFORM
     MOVE 0.5 TO WS-PX
     PERFORM PLAYER-AWAY
     MOVE 10 TO WS-TICKS PERFORM RUN-TICKS
     MOVE "minecraft:tnt" TO WS-KEY112
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY112 WS-TNT-TYPE WS-ENTITY-ROW WS-STATUS

     MOVE "stone" TO WS-K
     PERFORM FIND-ITEM

*>   a dispenser at x 3 facing east with the redstone block at x 2; WS-K item in slot 1
     MOVE "flint_and_steel" TO WS-K PERFORM FIND-ITEM MOVE WS-ITEM TO WS-ITEM2
*>   flint and steel into air above stone: fire at x 4, the item stays
     MOVE 0 TO WS-Z
     PERFORM SETUP-DISPENSER
     MOVE WS-ITEM2 TO BE-SLOT-ITEM(WS-BE, 1) MOVE 1 TO BE-SLOT-COUNT(WS-BE, 1)
     PERFORM POWER-ON
     MOVE 4 TO WS-X PERFORM READ-KEY
     MOVE 0 TO WS-P
     IF WS-PROPS(1:5) = "fire:"
         MOVE 1 TO WS-P
     END-IF
     MOVE "acceptance US12-4 dispenser 30-4 4.10 flint and steel lights a fire in the air in front" TO WS-CASE
     MOVE "1" TO WS-EXP
     PERFORM ASSERT-POWER
     MOVE BE-SLOT-COUNT(WS-BE, 1) TO WS-P
     MOVE "acceptance US12-4 dispenser 30-4 4.10 and is not spent (it is only worn)" TO WS-CASE
     MOVE "1" TO WS-EXP
     PERFORM ASSERT-POWER
*>   flint and steel in front of TNT: the block goes, a primed TNT appears
     MOVE 3 TO WS-Z
     PERFORM SETUP-DISPENSER
     MOVE WS-ITEM2 TO BE-SLOT-ITEM(WS-BE, 1) MOVE 1 TO BE-SLOT-COUNT(WS-BE, 1)
     MOVE 4 TO WS-X MOVE "tnt" TO WS-K PERFORM PUT-DEF
     PERFORM COUNT-TNT
     MOVE WS-COUNT TO WS-BEFORE
     PERFORM POWER-ON
     MOVE 4 TO WS-X PERFORM READ-KEY
     MOVE "acceptance US12-4 dispenser 30-4 4.10 rule 4 the TNT block is removed" TO WS-CASE
     MOVE "air" TO WS-EXP
     PERFORM ASSERT-PROPS
     PERFORM COUNT-TNT
     COMPUTE WS-P = WS-COUNT - WS-BEFORE
     MOVE "acceptance US12-4 dispenser 30-4 4.10 rule 4 and a primed TNT entity appears" TO WS-CASE
     MOVE "1" TO WS-EXP
     PERFORM ASSERT-POWER
*>   flint and steel at a stone block: nothing to light, the dry click, the item stays
     MOVE 6 TO WS-Z
     PERFORM SETUP-DISPENSER
     MOVE WS-ITEM2 TO BE-SLOT-ITEM(WS-BE, 1) MOVE 1 TO BE-SLOT-COUNT(WS-BE, 1)
     MOVE 4 TO WS-X MOVE "stone" TO WS-K PERFORM PUT-DEF
     PERFORM POWER-ON
     MOVE 4 TO WS-X PERFORM READ-KEY
     MOVE "acceptance US12-4 dispenser 30-4 4.10 rule 5 a stone block stays" TO WS-CASE
     MOVE "stone" TO WS-EXP
     PERFORM ASSERT-PROPS
*>   bone meal on wheat: grows
     MOVE "bone_meal" TO WS-K PERFORM FIND-ITEM MOVE WS-ITEM TO WS-ITEM2
     MOVE 9 TO WS-Z
     PERFORM SETUP-DISPENSER
     MOVE WS-ITEM2 TO BE-SLOT-ITEM(WS-BE, 1) MOVE 3 TO BE-SLOT-COUNT(WS-BE, 1)
     MOVE 4 TO WS-X MOVE 100 TO WS-Y MOVE "farmland" TO WS-K PERFORM PUT-DEF
     MOVE 101 TO WS-Y MOVE "wheat" TO WS-K PERFORM PUT-DEF
     PERFORM POWER-ON
     MOVE 4 TO WS-X PERFORM READ-KEY
     MOVE "acceptance US12-4 dispenser 30-4 4.13 bone meal grows the wheat (age above 0)" TO WS-CASE
     MOVE "wheat:age=0" TO WS-EXP
     MOVE 0 TO WS-P
     IF WS-PROPS NOT = "wheat:age=0"
         MOVE 1 TO WS-P
     END-IF
     MOVE "1" TO WS-EXP
     PERFORM ASSERT-POWER
     MOVE BE-SLOT-COUNT(WS-BE, 1) TO WS-P
     MOVE "acceptance US12-4 dispenser 30-4 4.13 and one bone meal is spent" TO WS-CASE
     MOVE "2" TO WS-EXP
     PERFORM ASSERT-POWER
*>   water bucket into air: a water block, the empty bucket in the slot
     MOVE "water_bucket" TO WS-K PERFORM FIND-ITEM MOVE WS-ITEM TO WS-ITEM2
     MOVE 12 TO WS-Z
     PERFORM SETUP-DISPENSER
     MOVE WS-ITEM2 TO BE-SLOT-ITEM(WS-BE, 1) MOVE 1 TO BE-SLOT-COUNT(WS-BE, 1)
     PERFORM POWER-ON
     MOVE 4 TO WS-X PERFORM READ-KEY
     MOVE "acceptance US12-4 dispenser 30-4 4.5 a water bucket puts a water source in front" TO WS-CASE
     MOVE "water:level=0" TO WS-EXP
     PERFORM ASSERT-PROPS
     MOVE "bucket" TO WS-K PERFORM FIND-ITEM
     MOVE 0 TO WS-P
     IF BE-SLOT-ITEM(WS-BE, 1) = WS-ITEM AND BE-SLOT-COUNT(WS-BE, 1) = 1
         MOVE 1 TO WS-P
     END-IF
     MOVE "acceptance US12-4 dispenser 30-4 4.5 and the empty bucket takes the slot" TO WS-CASE
     MOVE "1" TO WS-EXP
     PERFORM ASSERT-POWER
*>   the empty bucket takes a source: air in front, the water bucket in the slot
     MOVE 15 TO WS-Z
     PERFORM SETUP-DISPENSER
     MOVE WS-ITEM TO BE-SLOT-ITEM(WS-BE, 1) MOVE 1 TO BE-SLOT-COUNT(WS-BE, 1)
     MOVE 4 TO WS-X MOVE "water" TO WS-K PERFORM PUT-DEF
     PERFORM POWER-ON
     MOVE 4 TO WS-X PERFORM READ-KEY
     MOVE "acceptance US12-4 dispenser 30-4 4.6 the empty bucket takes the water source" TO WS-CASE
     MOVE "air" TO WS-EXP
     PERFORM ASSERT-PROPS
     MOVE "water_bucket" TO WS-K PERFORM FIND-ITEM
     MOVE 0 TO WS-P
     IF BE-SLOT-ITEM(WS-BE, 1) = WS-ITEM AND BE-SLOT-COUNT(WS-BE, 1) = 1
         MOVE 1 TO WS-P
     END-IF
     MOVE "acceptance US12-4 dispenser 30-4 4.6 and the water bucket takes the slot" TO WS-CASE
     MOVE "1" TO WS-EXP
     PERFORM ASSERT-POWER
*>   a minecart onto a rail
     MOVE "minecart" TO WS-K PERFORM FIND-ITEM MOVE WS-ITEM TO WS-ITEM2
     MOVE 18 TO WS-Z
     PERFORM SETUP-DISPENSER
     MOVE WS-ITEM2 TO BE-SLOT-ITEM(WS-BE, 1) MOVE 1 TO BE-SLOT-COUNT(WS-BE, 1)
     MOVE 4 TO WS-X MOVE "rail" TO WS-K PERFORM PUT-DEF
     MOVE "minecart" TO WS-EKEY PERFORM COUNT-ENTITY
     MOVE WS-ECOUNT TO WS-BEFORE
     PERFORM POWER-ON
     PERFORM COUNT-ENTITY
     COMPUTE WS-P = WS-ECOUNT - WS-BEFORE
     MOVE "acceptance US12-4 dispenser 30-4 4.22 a minecart comes out onto the rail" TO WS-CASE
     MOVE "1" TO WS-EXP
     PERFORM ASSERT-POWER
     MOVE BE-SLOT-COUNT(WS-BE, 1) TO WS-P
     MOVE "acceptance US12-4 dispenser 30-4 4.22 and the item is spent" TO WS-CASE
     MOVE "0" TO WS-EXP
     PERFORM ASSERT-POWER
*>   a minecart in front of stone: the default drop (no cart)
     MOVE 21 TO WS-Z
     PERFORM SETUP-DISPENSER
     MOVE WS-ITEM2 TO BE-SLOT-ITEM(WS-BE, 1) MOVE 1 TO BE-SLOT-COUNT(WS-BE, 1)
     MOVE 4 TO WS-X MOVE "stone" TO WS-K PERFORM PUT-DEF
     MOVE "minecart" TO WS-EKEY PERFORM COUNT-ENTITY
     MOVE WS-ECOUNT TO WS-BEFORE
     PERFORM POWER-ON
     PERFORM COUNT-ENTITY
     COMPUTE WS-P = WS-ECOUNT - WS-BEFORE
     MOVE "acceptance US12-4 dispenser 30-4 4.22 not onto a rail: no cart, the item is dropped" TO WS-CASE
     MOVE "0" TO WS-EXP
     PERFORM ASSERT-POWER
*>   a spawn egg
     MOVE "cow_spawn_egg" TO WS-K PERFORM FIND-ITEM MOVE WS-ITEM TO WS-ITEM2
     MOVE 24 TO WS-Z
     PERFORM SETUP-DISPENSER
     MOVE WS-ITEM2 TO BE-SLOT-ITEM(WS-BE, 1) MOVE 1 TO BE-SLOT-COUNT(WS-BE, 1)
     MOVE "cow" TO WS-EKEY PERFORM COUNT-ENTITY
     MOVE WS-ECOUNT TO WS-BEFORE
     PERFORM POWER-ON
     PERFORM COUNT-ENTITY
     COMPUTE WS-P = WS-ECOUNT - WS-BEFORE
     MOVE "acceptance US12-4 dispenser 30-4 4.11 a spawn egg spawns its mob" TO WS-CASE
     MOVE "1" TO WS-EXP
     PERFORM ASSERT-POWER
*>   flint and steel lights a candle in front (4.10 rule 3)
     MOVE "flint_and_steel" TO WS-K PERFORM FIND-ITEM MOVE WS-ITEM TO WS-ITEM2
     MOVE 27 TO WS-Z
     PERFORM SETUP-DISPENSER
     MOVE WS-ITEM2 TO BE-SLOT-ITEM(WS-BE, 1) MOVE 1 TO BE-SLOT-COUNT(WS-BE, 1)
     MOVE 4 TO WS-X MOVE "candle" TO WS-K PERFORM PUT-DEF
     PERFORM POWER-ON
     MOVE 4 TO WS-X PERFORM READ-KEY
     MOVE "acceptance US12-4 dispenser 30-4 4.10 rule 3 flint and steel lights the candle" TO WS-CASE
     MOVE 0 TO WS-P
     IF WS-PROPS(1:7) = "candle:" AND WS-PROPS(8:35) NOT = SPACES
         MOVE 1 TO WS-P
     END-IF
     MOVE 0 TO WS-HITS
     INSPECT WS-PROPS TALLYING WS-HITS FOR ALL "lit=true"
     MOVE WS-HITS TO WS-P
     MOVE "1" TO WS-EXP
     PERFORM ASSERT-POWER
*>   a lava bucket, then the empty bucket takes the lava again (4.5, 4.6)
     MOVE "lava_bucket" TO WS-K PERFORM FIND-ITEM MOVE WS-ITEM TO WS-ITEM2
     MOVE 0 TO WS-Z
     PERFORM SETUP-DISPENSER
     MOVE WS-ITEM2 TO BE-SLOT-ITEM(WS-BE, 1) MOVE 1 TO BE-SLOT-COUNT(WS-BE, 1)
     PERFORM POWER-ON
     MOVE 4 TO WS-X PERFORM READ-KEY
     MOVE 0 TO WS-HITS
     INSPECT WS-PROPS TALLYING WS-HITS FOR ALL "lava:"
     MOVE WS-HITS TO WS-P
     MOVE "acceptance US12-4 dispenser 30-4 4.5 a lava bucket puts lava in front" TO WS-CASE
     MOVE "1" TO WS-EXP
     PERFORM ASSERT-POWER
     MOVE "bucket" TO WS-K PERFORM FIND-ITEM MOVE WS-ITEM TO WS-ITEM2
     MOVE 3 TO WS-Z
     PERFORM SETUP-DISPENSER
     MOVE WS-ITEM2 TO BE-SLOT-ITEM(WS-BE, 1) MOVE 1 TO BE-SLOT-COUNT(WS-BE, 1)
     MOVE 4 TO WS-X MOVE "lava" TO WS-K PERFORM PUT-DEF
     PERFORM POWER-ON
     MOVE "lava_bucket" TO WS-K PERFORM FIND-ITEM
     MOVE 0 TO WS-P
     IF BE-SLOT-ITEM(WS-BE, 1) = WS-ITEM
         MOVE 1 TO WS-P
     END-IF
     MOVE "acceptance US12-4 dispenser 30-4 4.6 the empty bucket takes the lava: the lava bucket takes the slot" TO WS-CASE
     MOVE "1" TO WS-EXP
     PERFORM ASSERT-POWER
*>   consumeWithRemainder with items left: the empty bucket goes into another slot, or is dropped when the dispenser is full (2)
     MOVE "water_bucket" TO WS-K PERFORM FIND-ITEM MOVE WS-ITEM TO WS-ITEM2
     MOVE 6 TO WS-Z
     PERFORM SETUP-DISPENSER
     MOVE WS-ITEM2 TO BE-SLOT-ITEM(WS-BE, 1) MOVE 2 TO BE-SLOT-COUNT(WS-BE, 1)
     PERFORM POWER-ON
     MOVE "bucket" TO WS-K PERFORM FIND-ITEM
     MOVE 0 TO WS-P
     IF BE-SLOT-ITEM(WS-BE, 2) = WS-ITEM AND BE-SLOT-COUNT(WS-BE, 2) = 1 AND BE-SLOT-COUNT(WS-BE, 1) = 1
         MOVE 1 TO WS-P
     END-IF
     MOVE "acceptance US12-4 dispenser 30-4 2 with water buckets left the empty bucket goes into the next free slot" TO WS-CASE
     MOVE "1" TO WS-EXP
     PERFORM ASSERT-POWER
     MOVE "stone" TO WS-K PERFORM FIND-ITEM
     MOVE 9 TO WS-Z
     PERFORM SETUP-DISPENSER
     MOVE WS-ITEM2 TO BE-SLOT-ITEM(WS-BE, 1) MOVE 2 TO BE-SLOT-COUNT(WS-BE, 1)
     PERFORM VARYING WS-I FROM 2 BY 1 UNTIL WS-I > 9
         MOVE WS-ITEM TO BE-SLOT-ITEM(WS-BE, WS-I) MOVE 1 TO BE-SLOT-COUNT(WS-BE, WS-I)
     END-PERFORM
     MOVE "bucket" TO WS-K PERFORM FIND-ITEM
     MOVE WS-ITEM TO WS-ITEM2
     MOVE "stone" TO WS-K PERFORM FIND-ITEM
     MOVE 0 TO WS-I
     MOVE "water_bucket" TO WS-K PERFORM FIND-ITEM
     MOVE WS-ITEM TO BE-SLOT-ITEM(WS-BE, 1)
     PERFORM VARYING WS-I FROM 2 BY 1 UNTIL WS-I > 9
         MOVE 64 TO BE-SLOT-COUNT(WS-BE, WS-I)
     END-PERFORM
     PERFORM COUNT-LOOSE
     MOVE WS-COUNT TO WS-BEFORE
     PERFORM POWER-ON
     PERFORM COUNT-LOOSE
     COMPUTE WS-P = WS-COUNT - WS-BEFORE
     MOVE "acceptance US12-4 dispenser 30-4 2 a full dispenser drops the empty bucket" TO WS-CASE
     MOVE "1" TO WS-EXP
     PERFORM ASSERT-POWER
*>   the other minecarts and a minecart above a rail (4.22)
     MOVE "chest_minecart" TO WS-K PERFORM FIND-ITEM MOVE WS-ITEM TO WS-ITEM2
     MOVE 12 TO WS-Z
     PERFORM SETUP-DISPENSER
     MOVE WS-ITEM2 TO BE-SLOT-ITEM(WS-BE, 1) MOVE 1 TO BE-SLOT-COUNT(WS-BE, 1)
     MOVE 4 TO WS-X MOVE 99 TO WS-Y MOVE "stone" TO WS-K PERFORM PUT-DEF
     MOVE 100 TO WS-Y MOVE "rail" TO WS-K PERFORM PUT-DEF
     MOVE "chest_minecart" TO WS-EKEY PERFORM COUNT-ENTITY
     MOVE WS-ECOUNT TO WS-BEFORE
     PERFORM POWER-ON
     PERFORM COUNT-ENTITY
     COMPUTE WS-P = WS-ECOUNT - WS-BEFORE
     MOVE "acceptance US12-4 dispenser 30-4 4.22 a chest minecart comes out above a rail" TO WS-CASE
     MOVE "1" TO WS-EXP
     PERFORM ASSERT-POWER
     MOVE "hopper_minecart" TO WS-K PERFORM FIND-ITEM MOVE WS-ITEM TO WS-ITEM2
     MOVE 15 TO WS-Z
     PERFORM SETUP-DISPENSER
     MOVE WS-ITEM2 TO BE-SLOT-ITEM(WS-BE, 1) MOVE 1 TO BE-SLOT-COUNT(WS-BE, 1)
     MOVE 4 TO WS-X MOVE "rail" TO WS-K PERFORM PUT-DEF
     PERFORM POWER-ON
     MOVE "furnace_minecart" TO WS-K PERFORM FIND-ITEM MOVE WS-ITEM TO WS-ITEM2
     MOVE 18 TO WS-Z
     PERFORM SETUP-DISPENSER
     MOVE WS-ITEM2 TO BE-SLOT-ITEM(WS-BE, 1) MOVE 1 TO BE-SLOT-COUNT(WS-BE, 1)
     MOVE 4 TO WS-X MOVE "rail" TO WS-K PERFORM PUT-DEF
     PERFORM POWER-ON
     MOVE "tnt_minecart" TO WS-K PERFORM FIND-ITEM MOVE WS-ITEM TO WS-ITEM2
     MOVE 21 TO WS-Z
     PERFORM SETUP-DISPENSER
     MOVE WS-ITEM2 TO BE-SLOT-ITEM(WS-BE, 1) MOVE 1 TO BE-SLOT-COUNT(WS-BE, 1)
     MOVE 4 TO WS-X MOVE "rail" TO WS-K PERFORM PUT-DEF
     PERFORM POWER-ON
     MOVE "command_block_minecart" TO WS-K PERFORM FIND-ITEM MOVE WS-ITEM TO WS-ITEM2
     MOVE 24 TO WS-Z
     PERFORM SETUP-DISPENSER
     MOVE WS-ITEM2 TO BE-SLOT-ITEM(WS-BE, 1) MOVE 1 TO BE-SLOT-COUNT(WS-BE, 1)
     MOVE 4 TO WS-X MOVE "rail" TO WS-K PERFORM PUT-DEF
     PERFORM POWER-ON
     MOVE BE-SLOT-COUNT(WS-BE, 1) TO WS-P
     MOVE "acceptance US12-4 dispenser 30-4 4.22 a command block minecart is spent too" TO WS-CASE
     MOVE "0" TO WS-EXP
     PERFORM ASSERT-POWER
     STOP RUN.

 SETUP-DISPENSER.
*>   a dispenser facing east at (3, 101, WS-Z), air in front at x 4 (floor stone at y 100), nothing at x 2
     MOVE 4 TO WS-X MOVE 100 TO WS-Y MOVE "stone" TO WS-K PERFORM PUT-DEF
     MOVE 101 TO WS-Y MOVE "air" TO WS-K PERFORM PUT-DEF
     MOVE 2 TO WS-X MOVE "air" TO WS-K PERFORM PUT-DEF
     MOVE 3 TO WS-X MOVE "dispenser" TO WS-K PERFORM MAKE-DEF
     MOVE "facing" TO WS-PN MOVE "east" TO WS-PV PERFORM SET-P
     PERFORM PUT-ST
     CALL "BE-FIND" USING WS-DIM WS-X WS-Y WS-Z WS-BE.

 POWER-ON.
     MOVE 2 TO WS-X MOVE "redstone_block" TO WS-K PERFORM PUT-DEF
     MOVE 8 TO WS-TICKS PERFORM RUN-TICKS
     MOVE 101 TO WS-Y.

 READ-KEY.
*>   WS-PROPS = block key, ":" and the properties of the cell at (WS-X, 101, WS-Z); a block with no properties is the bare key
     MOVE 101 TO WS-Y
     CALL "WORLD-GET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-STATE
     CALL "BLOCKS-STATE-PROPS" USING WS-STATE WS-PROPS
     CALL "KEY-BARE" USING CB-KEY(CB-S-BLOCK(WS-STATE + 1) + 1) WS-KEYN
     MOVE SPACES TO WS-EXP-TMP
     IF WS-PROPS = SPACES
         MOVE WS-KEYN TO WS-EXP-TMP
     ELSE
         STRING FUNCTION TRIM(WS-KEYN) ":" FUNCTION TRIM(WS-PROPS) DELIMITED BY SIZE INTO WS-EXP-TMP
     END-IF
     MOVE WS-EXP-TMP TO WS-PROPS.

 COUNT-ENTITY.
*>   the entity rows whose type key is WS-EKEY
     MOVE 0 TO WS-ECOUNT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > EN-COUNT
         IF EN-USED(WS-I) = 1
             MOVE ET-KEY(EN-TYPE(WS-I) + 1) TO WS-KEYN
             CALL "KEY-BARE" USING WS-KEYN WS-EXP-TMP
             IF WS-EXP-TMP = WS-EKEY
                 ADD 1 TO WS-ECOUNT
             END-IF
         END-IF
     END-PERFORM.

 COUNT-LOOSE.
     MOVE 0 TO WS-COUNT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > EN-COUNT
         IF EN-USED(WS-I) = 1 AND EN-TYPE(WS-I) = CR-LOOSE-ITEM
             ADD 1 TO WS-COUNT
         END-IF
     END-PERFORM.

 COUNT-TNT.
     MOVE 0 TO WS-COUNT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > EN-COUNT
         IF EN-USED(WS-I) = 1 AND EN-TYPE(WS-I) = WS-TNT-TYPE
             ADD 1 TO WS-COUNT
         END-IF
     END-PERFORM.

 MAKE-DEF.
*>   the default state of the block of key WS-K into WS-ST
     MOVE SPACES TO WS-PR
     CALL "PT-STATE" USING WS-K WS-PR WS-ST.

 PUT-DEF.
*>   the default state of the block of key WS-K at (WS-X, WS-Y, WS-Z) into WS-ST and the world
     PERFORM MAKE-DEF
     PERFORM PUT-ST.

 SET-P.
*>   property WS-PN of WS-ST set to WS-PV
     CALL "SW-SET-PROP" USING WS-ST WS-PN WS-PV WS-ST2 WS-OLD
     MOVE WS-ST2 TO WS-ST.

 PUT-ST.
     CALL "LEVEL-SET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-ST WS-FLAGS WS-BUDGET WS-RESULT.

 RUN-TICKS.
     CALL "TEST-TICKS" USING WS-TICKS.

 FIND-ITEM.
     MOVE 0 TO WS-ITEM
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > IT-COUNT
         IF IT-KEY(WS-I) = WS-K
             COMPUTE WS-ITEM = WS-I - 1
         END-IF
     END-PERFORM.

 PLAYER-AWAY.
     MOVE 0.5 TO WS-PX
     MOVE WS-PX TO PL-X(WS-ROW)
     MOVE 104.0 TO PL-Y(WS-ROW)
     MOVE 28.5 TO PL-Z(WS-ROW).

 PLAYER-ON-PLATE.
*>   the player stands on the plate of row WS-Z at x 3 (feet at the floor of the cell)
     MOVE 3.5 TO PL-X(WS-ROW)
     MOVE 101.0 TO PL-Y(WS-ROW)
     COMPUTE WS-PX = WS-Z + 0.5
     MOVE WS-PX TO PL-Z(WS-ROW).

 READ-PROPS.
     CALL "WORLD-GET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-STATE
     CALL "BLOCKS-STATE-PROPS" USING WS-STATE WS-PROPS.

 READ-WIRE.
     CALL "WORLD-GET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-STATE
     MOVE 0 TO WS-N WS-E WS-S WS-W WS-P
     IF CB-S-BLOCK(WS-STATE + 1) = WS-WIRE-BLOCK - 1
         COMPUTE WS-ID = WS-STATE - CB-FIRST-STATE(WS-WIRE-BLOCK) + 5567
         CALL "RS1-WIRE-DECODE" USING WS-ID WS-N WS-E WS-S WS-W WS-P
     ELSE
         MOVE -1 TO WS-P
     END-IF.

 READ-SIGNAL.
*>   level.getSignal at (WS-X, WS-Y, WS-Z) asked with direction WS-D
     CALL "RL-SIGNAL" USING WS-DIM WS-X WS-Y WS-Z WS-D WS-SIG
     MOVE WS-SIG TO WS-P.

 ASSERT-POWER.
     MOVE WS-P TO WS-ED
     MOVE WS-CASE TO TL-CASE
     MOVE WS-EXP TO TL-EXPECTED
     MOVE SPACES TO TL-OBSERVED
     MOVE FUNCTION TRIM(WS-ED) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

 ASSERT-SIGNAL.
     PERFORM ASSERT-POWER.

 ASSERT-PROPS.
     MOVE WS-CASE TO TL-CASE
     MOVE WS-EXP TO TL-EXPECTED
     MOVE WS-PROPS TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

 END PROGRAM ACC-F2US12-REDSTONE-DISPENSE2.

 COPY CORETEST.
 COPY PORTALTEST.
