*> Implementation test of the finalizeSpawn effects of the bastion's mobs (docs/protocol/36-structures-8-nether-and-end.md section 15.3; core/src/gen-ent.cob STRUCT-MOB-FINALIZE; T26004):
*> a mob that the worldgen entity channel makes is finalized with reason STRUCTURE from a generator seeded by its entity id and the tick: a piglin brute holds a golden axe whatever its template
*> held; an adult piglin tries golden helmet, chestplate, leggings and boots in that order, one nextFloat each, wearing the piece for a draw below 0.1 (a baby piglin tries none); a hoglin is a
*> baby for a first nextFloat below 0.2; no other mob is touched. The expected values are drawn independently from the same seed with XORO-SEED and XORO-NEXT-FLOAT. Set Equipment carries the
*> brute's axe in the main hand and the worn pieces head first with the continuation bit.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-STRUCT-36-8-MOBS.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY CONTENT.
 COPY GENENT.
 COPY XORO.
 COPY PROTO.
 01 WS-CAPACITY            BINARY-LONG VALUE 256.
 01 WS-NAME                PIC X(16) VALUE "Stefan".
 01 WS-NAME-LENGTH         BINARY-LONG VALUE 6.
 01 WS-CONN                BINARY-LONG.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-ROW                 BINARY-LONG VALUE 7.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-ID                  PIC X(32).
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-I                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-G                   BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-ENTITY-ROW          PIC X(66).
 01 WS-STATUS              BINARY-LONG.
 01 WS-BRUTE-TYPE          BINARY-LONG.
 01 WS-PIGLIN-TYPE         BINARY-LONG.
 01 WS-HOGLIN-TYPE         BINARY-LONG.
 01 WS-WITCH-TYPE          BINARY-LONG.
 01 WS-SEED                BINARY-DOUBLE UNSIGNED.
 01 WS-F                   FLOAT-LONG.
 01 WS-MASK                BINARY-LONG.
 01 WS-BIT                 BINARY-LONG.
 01 WS-BAD-BRUTE           BINARY-LONG VALUE 0.
 01 WS-BAD-PIGLIN          BINARY-LONG VALUE 0.
 01 WS-BAD-HOGLIN          BINARY-LONG VALUE 0.
 01 WS-BRUTES              BINARY-LONG VALUE 0.
 01 WS-PIGLINS             BINARY-LONG VALUE 0.
 01 WS-HOGLINS             BINARY-LONG VALUE 0.
 01 WS-BABIES              BINARY-LONG VALUE 0.
 01 WS-DRESSED             BINARY-LONG VALUE 0.
 01 WS-GEAR-ROW            BINARY-LONG VALUE 0.
 01 WS-OFF                 BINARY-LONG.
 01 WS-HAND-KEY            PIC X(40).
 01 WS-WITCH-HAND          BINARY-LONG VALUE 0.
 01 WS-SEEN                BINARY-LONG.
 01 WS-FIRST-ID            BINARY-LONG.
 01 WS-VIEW BASED.
    05 WS-BYTE             PIC X OCCURS 64 TIMES.
 PROCEDURE DIVISION.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE 2 TO CS-VIEW-DISTANCE
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     CALL "TEST-STANDARD-TABLES"
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-CONN
     MOVE CN-PLAYER(WS-CONN) TO WS-PLAYER
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     MOVE "N" TO TL-MODE
     MOVE "minecraft:piglin_brute" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-BRUTE-TYPE WS-ENTITY-ROW WS-STATUS
     MOVE "minecraft:piglin" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-PIGLIN-TYPE WS-ENTITY-ROW WS-STATUS
     MOVE "minecraft:hoglin" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-HOGLIN-TYPE WS-ENTITY-ROW WS-STATUS
     MOVE "minecraft:witch" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-WITCH-TYPE WS-ENTITY-ROW WS-STATUS
     MOVE 0 TO GEL-COUNT GEL-LOST GE-COUNT GE-LOST
     MOVE CW-NEXT-ENTITY-ID TO WS-FIRST-ID
*>   four lists of 16: brutes, piglins, hoglins, and a witch with the rest
     PERFORM VARYING WS-G FROM 1 BY 1 UNTIL WS-G > 4
         MOVE 0 TO GEL-COUNT GEL-LOST
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 16
             COMPUTE WS-X = FUNCTION INTEGER(PL-X(WS-PLAYER)) + 3 * WS-I + 0.5
             MOVE PL-Y(WS-PLAYER) TO WS-Y
             COMPUTE WS-Z = FUNCTION INTEGER(PL-Z(WS-PLAYER)) + 3 * WS-G + 0.5
             EVALUATE WS-G
                 WHEN 1 MOVE "minecraft:piglin_brute" TO WS-ID
                 WHEN 2 MOVE "minecraft:piglin" TO WS-ID
                 WHEN 3 MOVE "minecraft:hoglin" TO WS-ID
                 WHEN OTHER MOVE "minecraft:witch" TO WS-ID
             END-EVALUATE
             CALL "GENT-ADD-MOB" USING WS-X WS-Y WS-Z WS-ID WS-ONE
         END-PERFORM
         MOVE GEN-ENT-LEVEL TO GEN-ENT
         MOVE 0 TO GEL-COUNT
         CALL "GENT-APPLY" USING WS-DIM WS-ROW
     END-PERFORM
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > EN-COUNT
         IF EN-USED(WS-I) = 1 AND EN-PLAYER(WS-I) = 0 AND EN-ID(WS-I) >= WS-FIRST-ID
             COMPUTE WS-SEED = EN-ID(WS-I) * 7919 + CW-TICKS
             CALL "XORO-SEED" USING WS-SEED XR-STATE
             EVALUATE TRUE
                 WHEN EN-TYPE(WS-I) = WS-BRUTE-TYPE
                     ADD 1 TO WS-BRUTES
                     IF EN-HAND(WS-I) NOT = 16
                         ADD 1 TO WS-BAD-BRUTE
                     END-IF
                 WHEN EN-TYPE(WS-I) = WS-PIGLIN-TYPE
                     ADD 1 TO WS-PIGLINS
*>                   golden helmet, chestplate, leggings, boots: bits 1, 2, 4, 8, one nextFloat each
                     MOVE 0 TO WS-MASK
                     MOVE 1 TO WS-BIT
                     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 4
                         CALL "XORO-NEXT-FLOAT" USING XR-STATE WS-F
                         IF WS-F < 0.1
                             ADD WS-BIT TO WS-MASK
                         END-IF
                         COMPUTE WS-BIT = WS-BIT * 2
                     END-PERFORM
                     IF EN-PIG-GEAR(WS-I) NOT = WS-MASK
                         ADD 1 TO WS-BAD-PIGLIN
                     END-IF
                     IF WS-MASK > 0
                         ADD 1 TO WS-DRESSED
                         MOVE WS-I TO WS-GEAR-ROW
                     END-IF
                 WHEN EN-TYPE(WS-I) = WS-HOGLIN-TYPE
                     ADD 1 TO WS-HOGLINS
                     CALL "XORO-NEXT-FLOAT" USING XR-STATE WS-F
                     MOVE 0 TO WS-K
                     IF WS-F < 0.2
                         MOVE 1 TO WS-K
                         ADD 1 TO WS-BABIES
                     END-IF
                     IF EN-VARIANT(WS-I) NOT = WS-K
                         ADD 1 TO WS-BAD-HOGLIN
                     END-IF
                 WHEN EN-TYPE(WS-I) = WS-WITCH-TYPE
                     IF EN-HAND(WS-I) NOT = 0 OR EN-PIG-GEAR(WS-I) NOT = 0
                         ADD 1 TO WS-WITCH-HAND
                     END-IF
             END-EVALUATE
         END-IF
     END-PERFORM
     MOVE "acceptance US12 36-8§15.3 C. Entity data and finalizeSpawn: 16 brutes, 16 piglins and 16 hoglins were made" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-BRUTES * 10000 + WS-PIGLINS * 100 + WS-HOGLINS
     MOVE 161616 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 36-8§15.3 C. Entity data and finalizeSpawn: every piglin brute holds a golden axe" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-BAD-BRUTE TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 36-8§15.3 C. Entity data and finalizeSpawn: an adult piglin wears golden pieces for the draws below 0.1, helmet, chestplate, leggings, boots in order" TO TL-CASE
     MOVE WS-BAD-PIGLIN TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 36-8§15.3 C. Entity data and finalizeSpawn: a hoglin is a baby when its first nextFloat is below 0.2" TO TL-CASE
     MOVE WS-BAD-HOGLIN TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 36-8§15.3 C. Entity data and finalizeSpawn: the draws are not degenerate (some hoglins are babies and not all, some piglins wear gold)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-BABIES >= 1 AND WS-BABIES < 16 AND WS-DRESSED >= 1
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 36-8§15.3 C. Entity data and finalizeSpawn: a mob that is not of the piglin family is not touched" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-WITCH-HAND TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     DISPLAY "PROBE babies " WS-BABIES " dressed piglins " WS-DRESSED
*>   Set Equipment: the brute's axe in the main hand (slot 0, no continuation bit)
     MOVE 16 TO WS-K
     CALL "STDMOB-HAND-KEY" USING WS-K WS-HAND-KEY
     MOVE "T" TO TL-MODE
     MOVE "acceptance US12 36-8§15.3 C. Entity data and finalizeSpawn: main-hand code 16 is the golden axe" TO TL-CASE
     MOVE "minecraft:golden_axe" TO TL-EXPECTED
     MOVE WS-HAND-KEY TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "N" TO TL-MODE
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > EN-COUNT
         IF EN-USED(WS-I) = 1 AND EN-TYPE(WS-I) = WS-BRUTE-TYPE
             MOVE WS-I TO WS-K
         END-IF
     END-PERFORM
     CALL "PB-RESET" USING PB-BUFFER
     CALL "STDMOB-EQUIP-BUILD" USING WS-K PB-BUFFER
     MOVE 3 TO WS-OFF
     IF EN-ID(WS-K) >= 128
         MOVE 4 TO WS-OFF
     END-IF
     SET ADDRESS OF WS-VIEW TO PB-ADDR
     MOVE "acceptance US12 36-8§15.3 C. Entity data and finalizeSpawn: a brute's Set Equipment is the axe in slot 0 without continuation" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF PB-LENGTH > 4 AND WS-BYTE(1) = X"68" AND WS-BYTE(WS-OFF) = X"00"
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   a piglin with the helmet and the leggings (bits 1 and 4): head first with the continuation bit, then legs (ordinal 3) last
     MOVE WS-GEAR-ROW TO WS-K
     MOVE 5 TO EN-PIG-GEAR(WS-K)
     MOVE 0 TO EN-HAND(WS-K)
     MOVE 3 TO WS-OFF
     IF EN-ID(WS-K) >= 128
         MOVE 4 TO WS-OFF
     END-IF
     CALL "PB-RESET" USING PB-BUFFER
     CALL "STDMOB-EQUIP-BUILD" USING WS-K PB-BUFFER
     SET ADDRESS OF WS-VIEW TO PB-ADDR
     MOVE "acceptance US12 36-8§15.3 C. Entity data and finalizeSpawn: a piglin's worn pieces are sent head first, the helmet (ordinal 5) with the continuation bit" TO TL-CASE
     MOVE 0 TO TL-OBSERVED-N
     IF PB-LENGTH > 8 AND WS-BYTE(WS-OFF) = X"85"
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM TEST-STRUCT-36-8-MOBS.

 COPY NOSPAWN.
 COPY CORETEST.
