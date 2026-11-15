*> Implementation test (002-lane-mobsfull-h8; docs/protocol/20 section 3.5 Daylight burning): a burning-tagged mob ignites only in the day window, in light
*> 13 or more with the sky visible, and not in water, powder snow or rain; a mob wearing a helmet does not ignite but wears the helmet (durability damage
*> nextInt(2) a hit, the helmet breaking at its maximum), and ignites once the head is empty.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-MOB-20-3-5.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CONTENT.
 COPY BRWORLD.
 COPY PROTO.
 COPY STDMOBS.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-ENTITY-ROW          PIC X(66).
 01 WS-STATUS              BINARY-LONG.
 01 WS-ZOMBIE-TYPE         BINARY-LONG.
 01 WS-HUSK-TYPE           BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-M                   BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-BX                  BINARY-LONG.
 01 WS-BY                  BINARY-LONG.
 01 WS-BZ                  BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-STONE               BINARY-LONG.
 01 WS-RX                 BINARY-LONG.
 01 WS-RZ                 BINARY-LONG.
 01 WS-PX                 BINARY-LONG.
 01 WS-PZ                 BINARY-LONG.
 01 WS-EYE                BINARY-LONG.
 01 WS-SKY                BINARY-LONG.
 01 WS-BLK                BINARY-LONG.
 01 WS-ROOF                BINARY-LONG.
 01 WS-TIER                BINARY-LONG.
 01 WS-AIR                 BINARY-LONG VALUE 0.
 01 WS-FX                  BINARY-LONG.
 01 WS-FZ                  BINARY-LONG.
 01 WS-FY                  BINARY-LONG.
 01 WS-SIZE                BINARY-LONG VALUE 9.
 01 WS-KIND                BINARY-LONG VALUE 1.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 01 WS-CASE                PIC X(100).
 01 WS-EXP                 BINARY-LONG.
 01 WS-OBS                 BINARY-LONG.
 01 WS-CAPACITY            BINARY-LONG VALUE 256.
 01 WS-VIEW BASED.
    05 WS-BYTE             PIC X OCCURS 64 TIMES.
 PROCEDURE DIVISION.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     MOVE 1 TO PL-MODE(WS-PLAYER)
     MOVE "minecraft:zombie" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-ZOMBIE-TYPE WS-ENTITY-ROW WS-STATUS
     MOVE "minecraft:husk" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-HUSK-TYPE WS-ENTITY-ROW WS-STATUS
     COMPUTE WS-BX = FUNCTION INTEGER(PL-X(WS-PLAYER))
     COMPUTE WS-BY = FUNCTION INTEGER(PL-Y(WS-PLAYER))
     COMPUTE WS-BZ = FUNCTION INTEGER(PL-Z(WS-PLAYER))
*>   A stone floor under the mob, open sky above it.
     COMPUTE WS-FX = WS-BX - 4
     COMPUTE WS-FZ = WS-BZ - 4
     COMPUTE WS-FY = WS-BY - 1
     CALL "MS-TEST-FLOOR" USING WS-DIM WS-FX WS-FZ WS-SIZE WS-FY WS-KIND
     COMPUTE WS-X = WS-BX + 0.5
     COMPUTE WS-Y = WS-BY
     COMPUTE WS-Z = WS-BZ + 0.5
     MOVE 6000 TO CW-TIME
     CALL "MOB-SPAWN" USING WS-DIM WS-ZOMBIE-TYPE WS-X WS-Y WS-Z WS-YAW WS-ROW
     CALL "STDMOB-INDEX" USING WS-ZOMBIE-TYPE WS-M
*>   In the open by day a zombie ignites within 600 ticks.
     PERFORM IGNITE-RUN
     MOVE "acceptance US15 20§3.5 Daylight burning: a zombie in open daylight ignites" TO WS-CASE
     MOVE 1 TO WS-EXP
     MOVE 0 TO WS-OBS
     IF EN-BURN(WS-ROW) > 0
         MOVE 1 TO WS-OBS
     END-IF
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
*>   A husk is no burner: the engine calls STDMOB-BURN only for SM-BURNS rows.
     CALL "STDMOB-INDEX" USING WS-HUSK-TYPE WS-M
     MOVE "acceptance US15 20§3.5 Daylight burning: a husk is not in the burn_in_daylight tag" TO WS-CASE
     MOVE 0 TO WS-EXP
     MOVE SM-BURNS(WS-M) TO WS-OBS
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     CALL "STDMOB-INDEX" USING WS-ZOMBIE-TYPE WS-M
*>   Under a roof (sky light 14 at the eye cell, light 14 is enough but the sky is not visible): no ignition.
     MOVE 0 TO EN-BURN(WS-ROW)
     COMPUTE WS-ROOF = WS-BY + 2
     MOVE "minecraft:stone" TO WS-KEY
     CALL "MS-TEST-STATE" USING WS-KEY WS-STONE
     PERFORM VARYING WS-RX FROM -1 BY 1 UNTIL WS-RX > 1
         PERFORM VARYING WS-RZ FROM -1 BY 1 UNTIL WS-RZ > 1
             COMPUTE WS-PX = WS-BX + WS-RX
             COMPUTE WS-PZ = WS-BZ + WS-RZ
             CALL "WORLD-SET-BLOCK" USING WS-DIM WS-PX WS-ROOF WS-PZ WS-STONE
         END-PERFORM
     END-PERFORM
     COMPUTE WS-EYE = WS-BY + 1
     CALL "STDMOB-LIGHTS" USING WS-DIM WS-BX WS-EYE WS-BZ WS-SKY WS-BLK
     MOVE "minecraft:glowstone" TO WS-KEY
     CALL "MS-TEST-STATE" USING WS-KEY WS-STATE
     COMPUTE WS-PX = WS-BX + 1
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-PX WS-EYE WS-BZ WS-STATE
     PERFORM IGNITE-RUN
     MOVE "acceptance US15 20§3.5 Daylight burning: no ignition when the sky is not visible (lit roof)" TO WS-CASE
     MOVE 0 TO WS-EXP
     MOVE EN-BURN(WS-ROW) TO WS-OBS
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     PERFORM VARYING WS-RX FROM -1 BY 1 UNTIL WS-RX > 1
         PERFORM VARYING WS-RZ FROM -1 BY 1 UNTIL WS-RZ > 1
             COMPUTE WS-PX = WS-BX + WS-RX
             COMPUTE WS-PZ = WS-BZ + WS-RZ
             CALL "WORLD-SET-BLOCK" USING WS-DIM WS-PX WS-ROOF WS-PZ WS-AIR
         END-PERFORM
     END-PERFORM
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-PX WS-EYE WS-BZ WS-AIR
*>   Rain with the sky open: no ignition.
     MOVE 1 TO CW-RAIN-LEVEL(WS-DIM)
     PERFORM IGNITE-RUN
     MOVE "acceptance US15 20§3.5 Daylight burning: no ignition in rain" TO WS-CASE
     MOVE EN-BURN(WS-ROW) TO WS-OBS
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 0 TO CW-RAIN-LEVEL(WS-DIM)
*>   In water: no ignition.
     MOVE "minecraft:water" TO WS-KEY
     CALL "MS-TEST-STATE" USING WS-KEY WS-STATE
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-BY WS-BZ WS-STATE
     PERFORM IGNITE-RUN
     MOVE "acceptance US15 20§3.5 Daylight burning: no ignition in water" TO WS-CASE
     MOVE EN-BURN(WS-ROW) TO WS-OBS
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
*>   In powder snow: no ignition.
     MOVE "minecraft:powder_snow" TO WS-KEY
     CALL "MS-TEST-STATE" USING WS-KEY WS-STATE
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-BY WS-BZ WS-STATE
     PERFORM IGNITE-RUN
     MOVE "acceptance US15 20§3.5 Daylight burning: no ignition in powder snow" TO WS-CASE
     MOVE EN-BURN(WS-ROW) TO WS-OBS
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-BY WS-BZ WS-AIR
*>   A leather helmet (durability 55): no ignition for the first 100 ticks, the helmet takes damage, and it breaks in the end, after which the head is empty.
     MOVE 11 TO EN-EQUIP(WS-ROW)
     MOVE 0 TO EN-HEAD-WEAR(WS-ROW)
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 100
         CALL "STDMOB-BURN" USING WS-ROW WS-M
         ADD 1 TO CW-TIME
     END-PERFORM
     MOVE "acceptance US15 20§3.5 Daylight burning: a mob wearing a helmet does not ignite" TO WS-CASE
     MOVE EN-BURN(WS-ROW) TO WS-OBS
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE "acceptance US15 20§3.5 Daylight burning: the helmet is damaged by sunlight" TO WS-CASE
     MOVE 1 TO WS-EXP
     MOVE 0 TO WS-OBS
     IF EN-HEAD-WEAR(WS-ROW) > 0 AND EN-HEAD-WEAR(WS-ROW) < 55
         MOVE 1 TO WS-OBS
     END-IF
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 6000 OR EN-BURN(WS-ROW) > 0
         CALL "STDMOB-BURN" USING WS-ROW WS-M
         ADD 1 TO CW-TIME
     END-PERFORM
     MOVE "acceptance US15 20§3.5 Daylight burning: a worn-out helmet breaks, then the mob ignites" TO WS-CASE
     MOVE 1 TO WS-EXP
     MOVE 0 TO WS-OBS
     IF EN-BURN(WS-ROW) > 0 AND EN-HEAD-WEAR(WS-ROW) = -1
         MOVE 1 TO WS-OBS
     END-IF
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
*>   The equipment packet then shows the head slot empty (slot 5, an empty stack).
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "STDMOB-EQUIP-BUILD" USING WS-ROW PB-BUFFER
     SET ADDRESS OF WS-VIEW TO PB-ADDR
     MOVE "acceptance US15 20§3.5 Daylight burning: a broken helmet is sent as an empty head slot" TO WS-CASE
     MOVE 0 TO WS-OBS
     IF PB-LENGTH > 3 AND WS-BYTE(PB-LENGTH - 1) = X"05" AND WS-BYTE(PB-LENGTH) = X"00"
         MOVE 1 TO WS-OBS
     END-IF
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     CALL "PB-FREE" USING PB-BUFFER
*>   Helmet durability by tier: leather 55, copper 121, golden 77, chainmail 165, iron 165, diamond 363 (25 section 8.4).
     MOVE "acceptance US15 20§3.5 Daylight burning: head durability leather 55 copper 121 golden 77" TO WS-CASE
     MOVE 0 TO WS-TIER
     CALL "STDMOB-HEAD-MAX" USING WS-TIER WS-OBS
     MOVE 55 TO WS-EXP
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 1 TO WS-TIER
     CALL "STDMOB-HEAD-MAX" USING WS-TIER WS-OBS
     MOVE 121 TO WS-EXP
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 2 TO WS-TIER
     CALL "STDMOB-HEAD-MAX" USING WS-TIER WS-OBS
     MOVE 77 TO WS-EXP
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE "acceptance US15 20§3.5 Daylight burning: head durability chainmail 165 iron 165 diamond 363" TO WS-CASE
     MOVE 3 TO WS-TIER
     CALL "STDMOB-HEAD-MAX" USING WS-TIER WS-OBS
     MOVE 165 TO WS-EXP
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 4 TO WS-TIER
     CALL "STDMOB-HEAD-MAX" USING WS-TIER WS-OBS
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 5 TO WS-TIER
     CALL "STDMOB-HEAD-MAX" USING WS-TIER WS-OBS
     MOVE 363 TO WS-EXP
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 6 TO WS-TIER
     CALL "STDMOB-HEAD-MAX" USING WS-TIER WS-OBS
     MOVE "acceptance US15 20§3.5 Daylight burning: a tier above 5 has no helmet durability" TO WS-CASE
     MOVE 0 TO WS-EXP
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     STOP RUN.
 IGNITE-RUN.
     MOVE 0 TO EN-BURN(WS-ROW)
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 600 OR EN-BURN(WS-ROW) > 0
         CALL "STDMOB-BURN" USING WS-ROW WS-M
         ADD 1 TO CW-TIME
     END-PERFORM
     MOVE 6000 TO CW-TIME.
 END PROGRAM TEST-MOB-20-3-5.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-CHK.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 LINKAGE SECTION.
 01 L-CASE                 PIC X(100).
 01 L-EXPECTED             BINARY-LONG.
 01 L-OBSERVED             BINARY-LONG.
 PROCEDURE DIVISION USING L-CASE L-EXPECTED L-OBSERVED.
     MOVE "N" TO TL-MODE
     MOVE L-CASE TO TL-CASE
     MOVE L-EXPECTED TO TL-EXPECTED-N
     MOVE L-OBSERVED TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     GOBACK.
 END PROGRAM TEST-CHK.
 COPY CORETEST.
 COPY MOBSPTEST.
