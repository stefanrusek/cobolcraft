*> Implementation test (002-lane-mobsa5; 24 section 6.3, 21 section 8.15, 45 section 10.1): the fence knot. A right click on a fence binds the mobs the player holds to a
*> leash_knot entity at the block + (0.5, 0.375, 0.5) (one knot a block); a click on another block binds nothing; the knot holds the mob: a pull beyond 6 blocks, the lead
*> breaks beyond 12, with the fence gone the lead drops; the last mob released discards the knot; the interact of the knot hands the mobs back to the player; a mob held by a
*> knot is saved with the block position as an Int Array of 3 and is held by a knot again after the load.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-MOB-18-KNOT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY CONTENT.
 COPY COREAPI.
 COPY PROTO.
 COPY BRWORLD.
 COPY STDMOBS.
 COPY CBLOCKS.
 01 WS-TREG                PIC X(48) VALUE "block".
 01 WS-TTAG                PIC X(112) VALUE "minecraft:fences".
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-MEMBERS.
    05 WS-MEMBER           BINARY-LONG OCCURS 1 TIMES.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-ENTITY-ROW          PIC X(66).
 01 WS-BLOCK-ROW           PIC X(819).
 01 WS-STATUS              BINARY-LONG.
 01 WS-STATE-TEXT          PIC X(5).
 01 WS-STATE               BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-KNOT-TYPE           BINARY-LONG.
 01 WS-COW                 BINARY-LONG.
 01 WS-SHEEP               BINARY-LONG.
 01 WS-KNOT                BINARY-LONG.
 01 WS-A                   BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-X0                  BINARY-LONG.
 01 WS-Z0                  BINARY-LONG.
 01 WS-FX                  BINARY-LONG.
 01 WS-FY                  BINARY-LONG.
 01 WS-FZ                  BINARY-LONG.
 01 WS-FLOOR               BINARY-LONG VALUE 40.
 01 WS-SIZE                BINARY-LONG VALUE 48.
 01 WS-STONE               BINARY-LONG VALUE 1.
 01 WS-AIR                 BINARY-LONG VALUE 0.
 01 WS-FACE                BINARY-LONG VALUE 1.
 01 WS-SEQ                 BINARY-LONG VALUE 0.
 01 WS-CONN                BINARY-LONG.
 01 WS-ID                  BINARY-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-X0F                 FLOAT-LONG.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 01 WS-HAND0               BINARY-LONG VALUE 0.
 01 WS-SNEAK0              BINARY-LONG VALUE 0.
 01 WS-OK                  BINARY-LONG.
 01 WS-CREATED             BINARY-LONG.
 01 WS-ROOT                BINARY-LONG.
 01 WS-FRAMING             BINARY-LONG VALUE 1.
 01 WS-ROOT-TYPE           BINARY-LONG.
 01 WS-OUTCOME             BINARY-LONG.
 01 WS-PATH                PIC X(128).
 01 WS-TEXT                PIC X(8192).
 01 WS-HAYSTACK            PIC X(8194).
 01 WS-CX                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 PROCEDURE DIVISION.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     COMPUTE WS-X0 = FUNCTION INTEGER(PL-X(WS-PLAYER)) - 24
     COMPUTE WS-Z0 = FUNCTION INTEGER(PL-Z(WS-PLAYER)) - 24
     CALL "MS-TEST-FLOOR" USING WS-DIM WS-X0 WS-Z0 WS-SIZE WS-FLOOR WS-STONE
     COMPUTE PL-X(WS-PLAYER) = WS-X0 + 24.5
     COMPUTE PL-Y(WS-PLAYER) = WS-FLOOR + 1
     COMPUTE PL-Z(WS-PLAYER) = WS-Z0 + 24.5
     MOVE PL-CONN(WS-PLAYER) TO WS-CONN
     MOVE "N" TO TL-MODE
     MOVE 6000 TO CW-TIME
     MOVE "minecraft:leash_knot" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-KNOT-TYPE WS-ENTITY-ROW WS-STATUS
     MOVE "minecraft:oak_fence" TO WS-KEY
     CALL "CONTENT-BLOCK-BY-KEY" USING WS-KEY WS-BLOCK WS-BLOCK-ROW WS-STATUS
     MOVE WS-BLOCK-ROW(1 + 4 + 35 + 32 + 288 + 4 + 5:5) TO WS-STATE-TEXT
     COMPUTE WS-STATE = FUNCTION NUMVAL(WS-STATE-TEXT)
     MOVE WS-BLOCK TO WS-MEMBER(1)
     CALL "TAG-PUT" USING WS-TREG WS-TTAG WS-ONE WS-MEMBERS WS-STATUS
     COMPUTE WS-FX = WS-X0 + 28
     COMPUTE WS-FY = WS-FLOOR + 1
     COMPUTE WS-FZ = WS-Z0 + 24
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-FX WS-FY WS-FZ WS-STATE
     MOVE "minecraft:cow" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE WS-ENTITY-ROW WS-STATUS
     COMPUTE WS-X = WS-X0 + 26.5
     COMPUTE WS-Y = WS-FLOOR + 1
     COMPUTE WS-Z = WS-Z0 + 24.5
     CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-X WS-Y WS-Z WS-YAW WS-COW
     MOVE WS-PLAYER TO EN-LEASH(WS-COW)
     MOVE "minecraft:sheep" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE WS-ENTITY-ROW WS-STATUS
     CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-X WS-Y WS-Z WS-YAW WS-SHEEP
     CALL "TEST-DRAIN-IDS" USING WS-CONN WS-TEXT

*>   A click on a block that is not a fence binds nothing.
     COMPUTE WS-FX = WS-X0 + 26
     COMPUTE WS-FY = WS-FLOOR
     COMPUTE WS-FZ = WS-Z0 + 24
     CALL "TEST-USE-ON" USING WS-CONN WS-FX WS-FY WS-FZ WS-FACE WS-SEQ
     MOVE "acceptance US15 24§6.3 Fence knot: a click on stone binds nothing" TO TL-CASE
     MOVE WS-PLAYER TO TL-EXPECTED-N
     MOVE EN-LEASH(WS-COW) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   A click on the fence binds the held cow (the sheep is not held) to a new knot.
     COMPUTE WS-FX = WS-X0 + 28
     COMPUTE WS-FY = WS-FLOOR + 1
     COMPUTE WS-FZ = WS-Z0 + 24
     CALL "TEST-USE-ON" USING WS-CONN WS-FX WS-FY WS-FZ WS-FACE WS-SEQ
     MOVE EN-LEASH-KNOT(WS-COW) TO WS-KNOT
     MOVE "acceptance US15 24§6.3 Fence knot: the click on a fence ties the held cow to a knot, the player lets go" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-KNOT > 0 AND EN-LEASH(WS-COW) = 0
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 24§6.3 Fence knot: the knot is a leash_knot entity at the block + (0.5, 0.375, 0.5)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF EN-TYPE(WS-KNOT) = WS-KNOT-TYPE AND EN-X(WS-KNOT) = WS-X0 + 28.5 AND EN-Y(WS-KNOT) = WS-FLOOR + 1.375
             AND EN-Z(WS-KNOT) = WS-Z0 + 24.5
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 24§6.3 Fence knot: the sheep the player does not hold stays free" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = EN-LEASH(WS-SHEEP) + EN-LEASH-KNOT(WS-SHEEP)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   A viewer that starts to track the knotted cow is sent Set Entity Link (0x66 = 102) to the knot.
     CALL "TEST-DRAIN-IDS" USING WS-CONN WS-TEXT
     CALL "MOB-LEASH-PAIR" USING WS-PLAYER WS-COW
     CALL "TEST-DRAIN-IDS" USING WS-CONN WS-TEXT
     MOVE SPACES TO WS-HAYSTACK
     STRING " " DELIMITED BY SIZE WS-TEXT DELIMITED BY SIZE INTO WS-HAYSTACK
     MOVE 0 TO WS-A
     INSPECT WS-HAYSTACK TALLYING WS-A FOR ALL " 102"
     MOVE "acceptance US15 18§8.3 Leashing: a new viewer is sent the link of a knotted mob" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-A TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   A second mob on the same fence shares the knot.
     MOVE WS-PLAYER TO EN-LEASH(WS-SHEEP)
     CALL "TEST-USE-ON" USING WS-CONN WS-FX WS-FY WS-FZ WS-FACE WS-SEQ
     MOVE "acceptance US15 24§6.3 Fence knot: one knot a block, the sheep joins the cow's knot" TO TL-CASE
     MOVE WS-KNOT TO TL-EXPECTED-N
     MOVE EN-LEASH-KNOT(WS-SHEEP) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-N
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > EN-COUNT
         IF EN-USED(WS-I) = 1 AND EN-TYPE(WS-I) = WS-KNOT-TYPE
             ADD 1 TO WS-N
         END-IF
     END-PERFORM
     MOVE "acceptance US15 24§6.3 Fence knot: exactly one knot entity exists" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-N TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   The knot's box is bound by the same spring: a cow 8 blocks from the knot is pulled toward it.
     MOVE EN-X(WS-COW) TO WS-X0F
     COMPUTE EN-X(WS-COW) = WS-X0 + 20.5
     MOVE EN-X(WS-COW) TO WS-X0F
     MOVE 0 TO EN-VX(WS-COW)
     CALL "MOB-LEASH-TICK" USING WS-COW
     MOVE "acceptance US15 18§8.3 Leashing: a mob 8 blocks from its knot is pulled toward it" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF EN-VX(WS-COW) > 0
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Beyond 12 blocks the lead breaks and drops, the knot stays for the sheep.
     COMPUTE EN-X(WS-COW) = WS-X0 + 10.5
     CALL "MOB-LEASH-TICK" USING WS-COW
     MOVE "acceptance US15 18§8.3 Leashing: beyond 12 blocks of the knot the lead breaks" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE EN-LEASH-KNOT(WS-COW) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 21§8.15 Leash knot: the knot stays while the sheep hangs on it" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE EN-USED(WS-KNOT) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   The interact of the knot hands the sheep back to the player; the empty knot is discarded.
     MOVE EN-ID(WS-KNOT) TO WS-ID
     MOVE 0 TO PL-SNEAKING(WS-PLAYER)
     CALL "TEST-INTERACT" USING WS-CONN WS-ID WS-HAND0 WS-SNEAK0
     MOVE "acceptance US15 21§8.15 Leash knot: an interact on the knot hands the sheep back to the player" TO TL-CASE
     MOVE WS-PLAYER TO TL-EXPECTED-N
     MOVE EN-LEASH(WS-SHEEP) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 21§8.15 Leash knot: the knot without a leashed mob discards itself" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE EN-USED(WS-KNOT) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   And back again by the interact of a player holding mobs: bind with the click, then the knot's interact moves the held mob to it.
     COMPUTE WS-FX = WS-X0 + 28
     CALL "TEST-USE-ON" USING WS-CONN WS-FX WS-FY WS-FZ WS-FACE WS-SEQ
     MOVE EN-LEASH-KNOT(WS-SHEEP) TO WS-KNOT
     MOVE WS-PLAYER TO EN-LEASH(WS-COW)
     MOVE WS-X0F TO EN-X(WS-COW)
     COMPUTE EN-X(WS-COW) = WS-X0 + 26.5
     MOVE EN-ID(WS-KNOT) TO WS-ID
     CALL "TEST-INTERACT" USING WS-CONN WS-ID WS-HAND0 WS-SNEAK0
     MOVE "acceptance US15 21§8.15 Leash knot: an interact on the knot moves a mob the player holds to the knot" TO TL-CASE
     MOVE WS-KNOT TO TL-EXPECTED-N
     MOVE EN-LEASH-KNOT(WS-COW) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   The saved cow carries the block position as an Int Array of 3; after the load a knot holds it again.
     COMPUTE WS-CX = FUNCTION INTEGER(EN-X(WS-COW) / 16)
     COMPUTE WS-CZ = FUNCTION INTEGER(EN-Z(WS-COW) / 16)
     CALL "PB-RESET" USING PB-BUFFER
     CALL "ENTITY-NBT-WRITE" USING WS-DIM WS-CX WS-CZ PB-BUFFER
     MOVE 0 TO PB-POS
     CALL "NBT-READ-ROOT" USING PB-BUFFER WS-FRAMING WS-ROOT-TYPE
     MOVE PB-POS TO WS-ROOT
     MOVE "Entities" TO WS-PATH
     CALL "TEST-NBT-GET" USING PB-BUFFER WS-ROOT WS-PATH WS-TEXT
     MOVE 0 TO WS-A
     COMPUTE WS-FX = WS-X0 + 28
     INSPECT WS-TEXT TALLYING WS-A FOR ALL ",leash:I["
     MOVE "acceptance US15 45§10.1 leash: the cow and the sheep held by a knot are saved with the leash as an Int Array" TO TL-CASE
     MOVE 2 TO TL-EXPECTED-N
     MOVE WS-A TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "MOB-LEASH-DROP" USING WS-SHEEP
*>   Both mobs go before the reload: a UUID that a loaded entity has refuses the entity (45-1 section 6).
     CALL "ENTITY-REMOVE" USING WS-SHEEP
     CALL "ENTITY-REMOVE" USING WS-COW
     CALL "ENTITY-REMOVE" USING WS-KNOT
     MOVE 0 TO PB-POS
     CALL "ENTITY-NBT-READ" USING WS-DIM PB-BUFFER WS-OUTCOME
     MOVE 0 TO WS-COW
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > EN-COUNT
         IF EN-USED(WS-I) = 1 AND EN-TYPE(WS-I) = WS-TYPE - 0 AND WS-COW = 0 AND EN-LEASH-UUID(WS-I) NOT = SPACES
             MOVE WS-I TO WS-COW
         END-IF
     END-PERFORM
     MOVE "acceptance US15 45§10.1 leash: the loaded cow waits for its knot" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-COW > 0
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "TEST-TICKS-ANSWERED" USING 1
     MOVE EN-LEASH-KNOT(WS-COW) TO WS-KNOT
     MOVE "acceptance US15 45§10.1 leash: a tick of the loaded cow makes the knot again at the fence" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-KNOT > 0
         IF EN-TYPE(WS-KNOT) = WS-KNOT-TYPE AND EN-X(WS-KNOT) = WS-X0 + 28.5 AND EN-Z(WS-KNOT) = WS-Z0 + 24.5
             MOVE 1 TO TL-OBSERVED-N
         END-IF
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   With the fence gone the lead drops and the knot goes.
     COMPUTE WS-FX = WS-X0 + 28
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-FX WS-FY WS-FZ WS-AIR
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > EN-COUNT
         IF EN-USED(WS-I) = 1 AND EN-LEASH-KNOT(WS-I) = WS-KNOT
             CALL "MOB-LEASH-TICK" USING WS-I
         END-IF
     END-PERFORM
     MOVE "acceptance US15 21§8.15 Leash knot: with the fence gone the lead breaks" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE EN-LEASH-KNOT(WS-COW) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-N
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > EN-COUNT
         IF EN-USED(WS-I) = 1 AND EN-TYPE(WS-I) = WS-KNOT-TYPE
             ADD 1 TO WS-N
         END-IF
     END-PERFORM
     MOVE "acceptance US15 21§8.15 Leash knot: the knot of a gone fence is discarded" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-N TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM TEST-MOB-18-KNOT.
 COPY CORETEST.
 COPY MOBSPTEST.
