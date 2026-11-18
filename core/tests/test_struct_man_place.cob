*> Test of the woodland mansion's placement hooks (docs/protocol/36-structures-7 sections 7.1 and 8; core/src/struct-man-start.cob; T10500): the chest markers (facing turned by the piece rotation, loot
*> table, no second chest, one nextLong each), the mob markers (the marker becomes air), an unknown marker, and the foundation (air and liquid under the lowest layer become cobblestone down to the first
*> other block, only under piece boxes and non-air blocks). Written with the code (no separate red run).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-STRUCT-MAN-PLACE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY CBLOCKS.
 COPY STRUCTPIECE.
 COPY CELLS.
 COPY FEATLEVEL.
 COPY GENENT.
 01 WS-PTR                 USAGE POINTER.
 01 WS-BOX.
    COPY STRUCTBOX REPLACING LEADING ==BX-== BY ==A-==.
 01 WS-CX                  BINARY-LONG VALUE 0.
 01 WS-CZ                  BINARY-LONG VALUE 0.
 01 WS-MIN                 BINARY-LONG VALUE -64.
 01 WS-HEIGHT              BINARY-LONG VALUE 384.
 01 WS-SEA                 BINARY-LONG VALUE 63.
 01 WS-IDX                 BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-PAIRS               PIC X(600) VALUE SPACES.
 01 WS-STONE               BINARY-LONG.
 01 WS-COBBLE              BINARY-LONG.
 01 WS-WATER               BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-PT                  BINARY-LONG VALUE 100.
 01 WS-PO                  BINARY-LONG VALUE 2.
 01 WS-DEP                 BINARY-LONG VALUE 0.
 01 WS-MST                 BINARY-LONG VALUE 0.
 01 WS-META                PIC X(96).
 01 WS-MODE                BINARY-LONG VALUE 1.
 01 WS-PROP                PIC X(24) VALUE "facing".
 01 WS-TEXT                PIC X(32).
 01 WS-FOUND               BINARY-LONG.
 01 WS-BEFORE-LO           BINARY-DOUBLE UNSIGNED.
 01 WS-OK                  BINARY-LONG.
 01 WS-FLAGS               BINARY-LONG VALUE 2.
 01 WS-Y1                  BINARY-LONG.
 01 WS-CHEST-BLOCK         BINARY-LONG.
 PROCEDURE DIVISION.
     MOVE "N" TO TL-MODE
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE "standard" TO CS-WORLD-TYPE
     MOVE "content/tests/fixtures/std" TO CS-GENERATED-DIR
     MOVE "12345" TO CS-SEED-TEXT
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     ALLOCATE 304640 CHARACTERS INITIALIZED RETURNING WS-PTR
     MOVE "minecraft:stone" TO WS-KEY
     CALL "BLOCKS-STATE-OF" USING WS-KEY WS-PAIRS WS-STONE
     MOVE "minecraft:cobblestone" TO WS-KEY
     CALL "BLOCKS-STATE-OF" USING WS-KEY WS-PAIRS WS-COBBLE
     MOVE "minecraft:water" TO WS-KEY
     CALL "BLOCKS-STATE-OF" USING WS-KEY WS-PAIRS WS-WATER
     CALL "SPB-RESET"
     SET ADDRESS OF CE-CHUNK TO WS-PTR
     MOVE LOW-VALUES TO CE-CHUNK
*>   stone up to y 49, air above
     PERFORM VARYING WS-IDX FROM 1 BY 1 UNTIL WS-IDX > 114 * 256
         MOVE WS-STONE TO CE-STATE(WS-IDX)
     END-PERFORM
     CALL "FL-OPEN" USING WS-PTR WS-CX WS-CZ WS-MIN WS-HEIGHT WS-SEA
     CALL "MSP-OPEN"
     MOVE 5 TO SP-XR-LO
     MOVE 7 TO SP-XR-HI
     MOVE 0 TO SW-X0
     MOVE -63 TO SW-Y0
     MOVE 0 TO SW-Z0
     MOVE 15 TO SW-X1
     MOVE 319 TO SW-Y1
     MOVE 15 TO SW-Z1
*>   a piece of kind 5 with the box (2, 60, 2) to (9, 70, 9); stone at (3, 60, 3) and (4, 60, 3), water at (4, 59, 3)
     MOVE 2 TO A-X0 MOVE 60 TO A-Y0 MOVE 2 TO A-Z0 MOVE 9 TO A-X1 MOVE 70 TO A-Y1 MOVE 9 TO A-Z1
     CALL "SPB-ADD" USING WS-PT WS-PO WS-DEP WS-MST WS-BOX WS-ROW
     MOVE 5 TO SP-T-KIND(WS-ROW)
     MOVE 1 TO SP-T-ROT(WS-ROW)
     MOVE 3 TO WS-X MOVE 60 TO WS-Y MOVE 3 TO WS-Z
     CALL "FL-SET-STATE" USING WS-X WS-Y WS-Z WS-STONE WS-FLAGS WS-OK
     MOVE 4 TO WS-X
     CALL "FL-SET-STATE" USING WS-X WS-Y WS-Z WS-STONE WS-FLAGS WS-OK
     MOVE 59 TO WS-Y
     CALL "FL-SET-STATE" USING WS-X WS-Y WS-Z WS-WATER WS-FLAGS WS-OK
*>   a stone at (12, 60, 12) outside the piece box: no foundation there
     MOVE 12 TO WS-X MOVE 60 TO WS-Y MOVE 12 TO WS-Z
     CALL "FL-SET-STATE" USING WS-X WS-Y WS-Z WS-STONE WS-FLAGS WS-OK
     CALL "MAN-AFTER"
     MOVE 3 TO WS-X MOVE 50 TO WS-Y MOVE 3 TO WS-Z
     CALL "FL-GET-STATE" USING WS-X WS-Y WS-Z WS-STATE
     MOVE "acceptance US12 36-7§8 the air under the lowest layer becomes cobblestone down to y 50" TO TL-CASE
     MOVE WS-COBBLE TO TL-EXPECTED-N
     MOVE WS-STATE TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 49 TO WS-Y
     CALL "FL-GET-STATE" USING WS-X WS-Y WS-Z WS-STATE
     MOVE "acceptance US12 36-7§8 the column stops at the first solid block (y 49 stays stone)" TO TL-CASE
     MOVE WS-STONE TO TL-EXPECTED-N
     MOVE WS-STATE TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 4 TO WS-X MOVE 59 TO WS-Y
     CALL "FL-GET-STATE" USING WS-X WS-Y WS-Z WS-STATE
     MOVE "acceptance US12 36-7§8 liquid under the lowest layer becomes cobblestone" TO TL-CASE
     MOVE WS-COBBLE TO TL-EXPECTED-N
     MOVE WS-STATE TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 5 TO WS-X MOVE 59 TO WS-Y MOVE 5 TO WS-Z
     CALL "FL-GET-STATE" USING WS-X WS-Y WS-Z WS-STATE
     MOVE "acceptance US12 36-7§8 a column whose lowest-layer block is air gets no foundation" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-STATE TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 12 TO WS-X MOVE 59 TO WS-Y MOVE 12 TO WS-Z
     CALL "FL-GET-STATE" USING WS-X WS-Y WS-Z WS-STATE
     MOVE "acceptance US12 36-7§8 a column outside every piece box gets no foundation" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-STATE TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   the chest markers
     MOVE 6 TO WS-X MOVE 65 TO WS-Y MOVE 6 TO WS-Z
     MOVE SPACES TO WS-META
     MOVE "ChestSouth" TO WS-META
     MOVE SP-XR-LO TO WS-BEFORE-LO
     CALL "MAN-MARKER" USING WS-ROW WS-META WS-X WS-Y WS-Z
     CALL "FL-GET-STATE" USING WS-X WS-Y WS-Z WS-STATE
     CALL "BLOCK-STATE-PROP" USING WS-MODE WS-STATE WS-PROP WS-TEXT WS-FOUND
     MOVE "acceptance US12 36-7§7.1 ChestSouth in a piece turned 90 faces west" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-FOUND = 1 AND WS-TEXT = "west"
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 36-7§7.1 a chest marker draws one nextLong of the piece random" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF SP-XR-LO NOT = WS-BEFORE-LO
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE SP-XR-LO TO WS-BEFORE-LO
     CALL "MAN-MARKER" USING WS-ROW WS-META WS-X WS-Y WS-Z
     MOVE "acceptance US12 36-7§7.1 a second chest marker on a chest does nothing and draws nothing" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF SP-XR-LO = WS-BEFORE-LO
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   a plain Chest marker keeps the default facing (north), a chest of another name too
     MOVE 7 TO WS-X
     MOVE "Chest" TO WS-META
     CALL "MAN-MARKER" USING WS-ROW WS-META WS-X WS-Y WS-Z
     CALL "FL-GET-STATE" USING WS-X WS-Y WS-Z WS-STATE
     CALL "BLOCK-STATE-PROP" USING WS-MODE WS-STATE WS-PROP WS-TEXT WS-FOUND
     MOVE "acceptance US12 36-7§7.1 a Chest marker without a direction keeps the default facing" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-FOUND = 1 AND WS-TEXT = "north"
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO GEL-COUNT GEL-LOST
     PERFORM VARYING WS-Y1 FROM 1 BY 1 UNTIL WS-Y1 > 3
         MOVE 8 TO WS-X
         MOVE 66 TO WS-Y
         MOVE WS-STONE TO WS-STATE
         CALL "FL-SET-STATE" USING WS-X WS-Y WS-Z WS-STATE WS-FLAGS WS-OK
         EVALUATE WS-Y1
             WHEN 1
                 MOVE "Mage" TO WS-META
             WHEN 2
                 MOVE "Warrior" TO WS-META
             WHEN OTHER
                 MOVE "Group of Allays" TO WS-META
         END-EVALUATE
         CALL "MAN-MARKER" USING WS-ROW WS-META WS-X WS-Y WS-Z
         CALL "FL-GET-STATE" USING WS-X WS-Y WS-Z WS-STATE
         MOVE "acceptance US12 36-7§7.1 a mob marker becomes air" TO TL-CASE
         MOVE 0 TO TL-EXPECTED-N
         MOVE WS-STATE TO TL-OBSERVED-N
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     END-PERFORM
*>   the mobs: an evoker, a vindicator, then 1 to 3 allays, all asked of the entity channel at the centre of the marker block
     MOVE "acceptance US12 36-7§7.1 the three mob markers ask for an evoker, a vindicator and 1 to 3 allays (3 to 5 requests)" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     IF GEL-COUNT >= 3 AND GEL-COUNT <= 5
         MOVE 1 TO TL-EXPECTED-N
     END-IF
     MOVE 1 TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "T" TO TL-MODE
     MOVE "acceptance US12 36-7§7.1 the first two requests are the evoker and the vindicator at (8.5, 66, z + 0.5), the third an allay" TO TL-CASE
     MOVE SPACES TO TL-OBSERVED
     IF GEL-NBT(1)(8:16) = "minecraft:evoker" AND GEL-NBT(2)(8:20) = "minecraft:vindicator" AND GEL-NBT(3)(8:15) = "minecraft:allay"
             AND GEL-X(1) = 8.5 AND GEL-Y(1) = 66
         MOVE "ok" TO TL-OBSERVED
     END-IF
     MOVE "ok" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "N" TO TL-MODE
     MOVE WS-STONE TO WS-STATE
     CALL "FL-SET-STATE" USING WS-X WS-Y WS-Z WS-STATE WS-FLAGS WS-OK
     MOVE "Golem" TO WS-META
     CALL "MAN-MARKER" USING WS-ROW WS-META WS-X WS-Y WS-Z
     CALL "FL-GET-STATE" USING WS-X WS-Y WS-Z WS-STATE
     MOVE "acceptance US12 36-7§7.1 an unknown marker does nothing" TO TL-CASE
     MOVE WS-STONE TO TL-EXPECTED-N
     MOVE WS-STATE TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   the hooks of a builder without a mansion do nothing
     CALL "SPB-RESET"
     CALL "MAN-AFTER"
     MOVE "acceptance US12 36-7§8 an empty builder has no foundation work" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE SP-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 5 TO A-X0
     CALL "SPB-ADD" USING WS-PT WS-PO WS-DEP WS-MST WS-BOX WS-ROW
     MOVE 0 TO SP-T-KIND(WS-ROW)
     CALL "MAN-AFTER"
     MOVE "acceptance US12 36-7§8 a start that is not a mansion has no foundation work" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE SP-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM TEST-STRUCT-MAN-PLACE.

 COPY NOSPAWN.
 COPY CORETEST.
