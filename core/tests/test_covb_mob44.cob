*> Implementation test (lane covB; docs/protocol/44 part 4, 19 section 5): residual land animal paths: a held item on a note block, the sniffer's idle pick and dig when it cannot sniff,
*> a kitten of a mixed collar, a llama following its leashed head close by and a bee that wants its hive when the hive block entity is gone.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-COVB-MOB44.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-X0                  BINARY-LONG.
 01 WS-Y0                  BINARY-LONG.
 01 WS-Z0                  BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-ENTITY-ROW          PIC X(66).
 01 WS-STATUS              BINARY-LONG.
 01 WS-T                   BINARY-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 01 WS-ROW                 BINARY-LONG.
 01 WS-A                   BINARY-LONG.
 01 WS-B                   BINARY-LONG.
 01 WS-BABY                BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-NOTE-STATE          BINARY-LONG.
 01 WS-STICK               BINARY-LONG.
 01 WS-ITEM-ROW            PIC X(270).
 01 WS-HELD                BINARY-LONG.
 01 WS-FACE                BINARY-LONG VALUE 2.
 01 WS-USED                BINARY-LONG.
 01 WS-BX                  BINARY-LONG.
 01 WS-BY                  BINARY-LONG.
 01 WS-BZ                  BINARY-LONG.
 01 WS-HX                  FLOAT-LONG.
 01 WS-HZ                  FLOAT-LONG.
 01 WS-WALK                BINARY-LONG.
 01 WS-COIN                BINARY-LONG VALUE 0.
 01 WS-SEEN2               BINARY-LONG.
 PROCEDURE DIVISION.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     MOVE "N" TO TL-MODE
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     COMPUTE WS-X0 = FUNCTION INTEGER(PL-X(WS-PLAYER))
     COMPUTE WS-Y0 = FUNCTION INTEGER(PL-Y(WS-PLAYER))
     COMPUTE WS-Z0 = FUNCTION INTEGER(PL-Z(WS-PLAYER))
     COMPUTE WS-BX = WS-X0 - 24
     COMPUTE WS-BZ = WS-Z0 - 24
     COMPUTE WS-BY = WS-Y0 - 1
     CALL "MS-TEST-FLOOR" USING WS-DIM WS-BX WS-BZ 48 WS-BY 1
*>   A note block played with an item in the hand (not a head: the note goes up).
     MOVE "note_block" TO WS-KEY
     CALL "MS-TEST-STATE" USING WS-KEY WS-NOTE-STATE
     COMPUTE WS-BX = WS-X0 + 3
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-Y0 WS-Z0 WS-NOTE-STATE
     MOVE "minecraft:stick" TO WS-KEY
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-STICK WS-ITEM-ROW WS-STATUS
     COMPUTE WS-HELD = PL-HELD(WS-PLAYER) + 1
     MOVE WS-STICK TO PL-SLOT-ITEM(WS-PLAYER, WS-HELD)
     MOVE 1 TO PL-SLOT-COUNT(WS-PLAYER, WS-HELD)
     CALL "M44-NOTE-USE" USING WS-PLAYER WS-NOTE-STATE WS-BX WS-Y0 WS-Z0 WS-FACE WS-USED
     MOVE "covB 30-5 8.4 a stick in the hand does not keep a note block from being tuned" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-USED TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   A baby sniffer cannot sniff: the picks 2 and 3 of the idle draw are dropped and a digging state returns to idle.
     MOVE "minecraft:sniffer" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-T WS-ENTITY-ROW WS-STATUS
     COMPUTE WS-X = PL-X(WS-PLAYER) + 6
     MOVE PL-Y(WS-PLAYER) TO WS-Y
     MOVE PL-Z(WS-PLAYER) TO WS-Z
     CALL "MOB-SPAWN" USING WS-DIM WS-T WS-X WS-Y WS-Z WS-YAW WS-ROW
     MOVE -1000 TO EN-MOBAGE(WS-ROW)
     MOVE 0 TO WS-SEEN2
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 80
         MOVE 0 TO EN-SNIF(WS-ROW) EN-SNIF-T(WS-ROW) EN-SNIF-CD(WS-ROW)
         CALL "M44-SNIF-BRAIN" USING WS-ROW
         IF EN-SNIF(WS-ROW) NOT = 0
             ADD 1 TO WS-SEEN2
         END-IF
     END-PERFORM
     MOVE "covB 44-4 13 a sniffer that cannot sniff never leaves idle by the idle draw" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-SEEN2 TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 4 TO EN-SNIF(WS-ROW)
     CALL "M44-SNIF-BRAIN" USING WS-ROW
     MOVE "covB 44-4 13 a digging sniffer that can no longer dig goes back to idle" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE EN-SNIF(WS-ROW) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   A kitten of a tame mother and a father with a collar: tame with a collar of the mix.
     MOVE "minecraft:cat" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-T WS-ENTITY-ROW WS-STATUS
     CALL "MOB-SPAWN" USING WS-DIM WS-T WS-X WS-Y WS-Z WS-YAW WS-A
     CALL "MOB-SPAWN" USING WS-DIM WS-T WS-X WS-Y WS-Z WS-YAW WS-B
     CALL "MOB-SPAWN" USING WS-DIM WS-T WS-X WS-Y WS-Z WS-YAW WS-BABY
     MOVE 1 TO EN-TAMED(WS-A)
     MOVE 5 TO EN-COLLAR(WS-A)
     MOVE 9 TO EN-COLLAR(WS-B)
     CALL "CAT-BRED" USING WS-A WS-B WS-BABY WS-COIN
     MOVE "covB 19 5.1 a kitten of a tame mother is tame with a collar" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF EN-TAMED(WS-BABY) = 1 AND EN-COLLAR(WS-BABY) >= 1 AND EN-COLLAR(WS-BABY) <= 16
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   A llama following its (leashed) head 5 blocks ahead counts the follow distance down.
     MOVE "minecraft:llama" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-T WS-ENTITY-ROW WS-STATUS
     CALL "MOB-SPAWN" USING WS-DIM WS-T WS-X WS-Y WS-Z WS-YAW WS-A
     COMPUTE WS-X = PL-X(WS-PLAYER) + 11
     CALL "MOB-SPAWN" USING WS-DIM WS-T WS-X WS-Y WS-Z WS-YAW WS-B
     MOVE 1 TO EN-LEASH(WS-A)
     MOVE WS-A TO EN-LLAMA-HEAD(WS-B)
     MOVE 5 TO EN-LLAMA-DIST(WS-B)
     MOVE 1.5 TO EN-LLAMA-SPEED(WS-B)
     CALL "M44-LLAMA-CARAVAN" USING WS-B WS-HX WS-HZ WS-WALK
     MOVE "covB 44-4 2.2 a llama near its head counts its follow distance down" TO TL-CASE
     MOVE 4 TO TL-EXPECTED-N
     MOVE EN-LLAMA-DIST(WS-B) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   A bee that wants its hive and stands at it, with no hive block entity there, forgets the hive.
     MOVE "minecraft:bee" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-T WS-ENTITY-ROW WS-STATUS
     COMPUTE WS-X = WS-X0 + 0.5 - 3
     COMPUTE WS-Y = WS-Y0 + 0.5
     COMPUTE WS-Z = WS-Z0 + 0.5
     CALL "MOB-SPAWN" USING WS-DIM WS-T WS-X WS-Y WS-Z WS-YAW WS-ROW
     MOVE 1 TO EN-BEE-HV-ON(WS-ROW)
     COMPUTE EN-BEE-HV-X(WS-ROW) = WS-X0 - 3
     MOVE WS-Y0 TO EN-BEE-HV-Y(WS-ROW)
     MOVE WS-Z0 TO EN-BEE-HV-Z(WS-ROW)
     MOVE 1 TO EN-BEE-NECTAR(WS-ROW)
     MOVE 0 TO EN-BEE-STAY(WS-ROW) EN-BEE-POLL(WS-ROW) EN-BEE-STUNG(WS-ROW) EN-TARGET(WS-ROW)
     MOVE 50 TO EN-BEE-VAL(WS-ROW)
     CALL "M44-BEE-BRAIN" USING WS-ROW
     MOVE "covB 44-4 15 a bee at a hive that no longer exists forgets it" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE EN-BEE-HV-ON(WS-ROW) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM TEST-COVB-MOB44.
 COPY CORETEST.
 COPY MOBSPTEST.
