*> Acceptance test, a player rings a bell (docs/protocol/30 part 8 sections 8.2 and 8.3 "use without item", 44 part 3 section 2.11a; lane 002-lane-p49q, T37003): Use Item On a bell with an empty
*> hand rings it when the hit is a proper one: a floor bell facing north rings from its north or south face (the axis of its facing), not from the east or west face or the top; a ringing bell makes the
*> villagers within 32 blocks hear it (heard_bell_time = the game tick).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-US15-BELL-USE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY VILSTATE.
 COPY VLMEM.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-CONN                BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-CASE                PIC X(240).
 01 WS-E                   BINARY-LONG.
 01 WS-O                   BINARY-LONG.
 01 WS-FY                  BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-X0                  BINARY-LONG.
 01 WS-Z0                  BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-BX                  BINARY-LONG.
 01 WS-V                   BINARY-LONG.
 01 WS-S                   BINARY-LONG.
 01 WS-VX                  BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-PAIRS               PIC X(160).
 01 WS-FACE                BINARY-LONG.
 01 WS-SEQ                 BINARY-LONG VALUE 1.
 01 WS-HAS                 BINARY-LONG.
 PROCEDURE DIVISION.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     MOVE 0 TO WS-CONN
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > CORE-MAX-CONNS
         IF CN-PLAYER(WS-I) = WS-PLAYER
             MOVE WS-I TO WS-CONN
         END-IF
     END-PERFORM
     CALL "VT-FLAT" USING WS-PLAYER WS-FY
     COMPUTE WS-X0 = FUNCTION INTEGER(PL-X(WS-PLAYER))
     COMPUTE WS-Z0 = FUNCTION INTEGER(PL-Z(WS-PLAYER)) + 3
     COMPUTE WS-Y = WS-FY + 1
     COMPUTE WS-BX = WS-X0 + 3
     COMPUTE WS-VX = WS-X0 - 8
     MOVE "minecraft:bell" TO WS-KEY
     MOVE "attachment=floor,facing=north,powered=false" TO WS-PAIRS
     CALL "VT-PLACE" USING WS-DIM WS-BX WS-Y WS-Z0 WS-KEY WS-PAIRS
     CALL "VT-SPAWN" USING WS-DIM WS-VX WS-Y WS-Z0 WS-V WS-S
     MOVE 5000 TO CW-TIME
     MOVE 1000 TO CW-TICKS
*>   The top face does not ring.
     MOVE 1 TO WS-FACE
     CALL "TEST-USE-ON" USING WS-CONN WS-BX WS-Y WS-Z0 WS-FACE WS-SEQ
     CALL "VM-HAS" USING WS-S MT-HEARD-BELL-TIME WS-HAS
     MOVE "acceptance US15 30-8§8.2 a hit on the top face does not ring the bell" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-HAS TO WS-O
     CALL "Q3-EQ" USING WS-CASE WS-E WS-O
*>   The east face of a floor bell facing north (the axes differ) does not ring.
     MOVE 5 TO WS-FACE
     ADD 1 TO WS-SEQ
     CALL "TEST-USE-ON" USING WS-CONN WS-BX WS-Y WS-Z0 WS-FACE WS-SEQ
     CALL "VM-HAS" USING WS-S MT-HEARD-BELL-TIME WS-HAS
     MOVE "acceptance US15 30-8§8.2 a hit on the east face of a floor bell facing north does not ring it" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-HAS TO WS-O
     CALL "Q3-EQ" USING WS-CASE WS-E WS-O
*>   The north face rings it.
     MOVE 2 TO WS-FACE
     ADD 1 TO WS-SEQ
     CALL "TEST-USE-ON" USING WS-CONN WS-BX WS-Y WS-Z0 WS-FACE WS-SEQ
     CALL "VM-HAS" USING WS-S MT-HEARD-BELL-TIME WS-HAS
     MOVE "acceptance US15 30-8§8.3 a hit on the north face rings the bell: the villager within 32 blocks hears it" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE WS-HAS TO WS-O
     CALL "Q3-EQ" USING WS-CASE WS-E WS-O
     STOP RUN.
 END PROGRAM ACC-US15-BELL-USE.
 COPY CORETEST.
 COPY MOBSPTEST.
 COPY Q3TEST.
 COPY VILLTEST.
