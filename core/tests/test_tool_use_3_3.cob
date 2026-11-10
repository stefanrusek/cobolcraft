*> Test of special use 3.3 (17 section 3.3; core/src/tools-use.cob TOOL-FIRE-USE and TOOL-FIRE-PITCH): flint and steel and the fire
*> charge light a campfire, candle or candle cake or place fire beside the clicked face (soul fire on a soul fire base block).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-TOOL-USE-3-3.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 01 WS-ITEM                PIC X(16).
 01 WS-KEY                 PIC X(48).
 01 WS-LIT                 BINARY-LONG.
 01 WS-WATERLOGGED         BINARY-LONG.
 01 WS-AIR                 BINARY-LONG.
 01 WS-SUPPORT             BINARY-LONG.
 01 WS-FLAMMABLE           BINARY-LONG.
 01 WS-SOUL                BINARY-LONG.
 01 WS-CREATIVE            BINARY-LONG.
 01 WS-ACTION              BINARY-LONG.
 01 WS-NEW                 PIC X(48).
 01 WS-SOUND               PIC X(32).
 01 WS-ST2                 PIC X(200).
 01 WS-DAMAGE              BINARY-LONG.
 01 WS-CONSUME             BINARY-LONG.
 01 WS-R1                  BINARY-LONG.
 01 WS-R2                  BINARY-LONG.
 01 WS-PITCH               BINARY-LONG.
 01 WS-ST1                 PIC X(200).
 01 WS-E1                  PIC -(9)9.
 01 WS-E2                  PIC -(9)9.
 01 WS-E3                  PIC -(9)9.
 PROCEDURE DIVISION.
     MOVE "acceptance US14 flint_steel lights an unlit campfire: lit set, sound item.flintandsteel.use, 1 durability" TO TL-CASE
     MOVE "flint_and_steel" TO WS-ITEM
     MOVE "campfire" TO WS-KEY
     PERFORM DEFAULTS
     PERFORM DO-USE
     MOVE "1 campfire item.flintandsteel.use 1 0" TO TL-EXPECTED
     PERFORM CHECK-DONE

     MOVE "acceptance US14 flint_steel lights candles and candle cakes, not a lit or waterlogged one" TO TL-CASE
     MOVE SPACES TO TL-OBSERVED
     PERFORM DEFAULTS
     MOVE "red_candle" TO WS-KEY
     PERFORM USE-SHORT
     MOVE "candle_cake" TO WS-KEY
     PERFORM USE-SHORT
     MOVE "white_candle_cake" TO WS-KEY
     PERFORM USE-SHORT
     MOVE 1 TO WS-LIT
     PERFORM USE-SHORT
     MOVE 0 TO WS-LIT
     MOVE 1 TO WS-WATERLOGGED
     MOVE "campfire" TO WS-KEY
     PERFORM USE-SHORT
     MOVE "1 1 1 0 0" TO TL-EXPECTED
     PERFORM CHECK-DONE

     MOVE "acceptance US14 flint_steel on another block places fire beside the clicked face when the target is air and the fire can survive" TO TL-CASE
     MOVE SPACES TO TL-OBSERVED
     PERFORM DEFAULTS
     MOVE "stone" TO WS-KEY
     MOVE 1 TO WS-AIR
     MOVE 1 TO WS-SUPPORT
     PERFORM DO-USE
     MOVE "2 fire item.flintandsteel.use 1 0" TO TL-EXPECTED
     PERFORM CHECK-DONE

     MOVE "acceptance US14 fire survives on a flammable neighbour without a sturdy floor; none without either, none when the target is not air" TO TL-CASE
     MOVE SPACES TO TL-OBSERVED
     PERFORM DEFAULTS
     MOVE "stone" TO WS-KEY
     MOVE 1 TO WS-AIR
     MOVE 1 TO WS-FLAMMABLE
     PERFORM USE-SHORT
     MOVE 0 TO WS-FLAMMABLE
     PERFORM USE-SHORT
     MOVE 0 TO WS-AIR
     MOVE 1 TO WS-SUPPORT
     PERFORM USE-SHORT
     MOVE "2 0 0" TO TL-EXPECTED
     PERFORM CHECK-DONE

     MOVE "acceptance US14 soul_fire is placed when the block below the target is in soul_fire_base_blocks" TO TL-CASE
     PERFORM DEFAULTS
     MOVE "stone" TO WS-KEY
     MOVE 1 TO WS-AIR
     MOVE 1 TO WS-SUPPORT
     MOVE 1 TO WS-SOUL
     PERFORM DO-USE
     MOVE "2 soul_fire item.flintandsteel.use 1 0" TO TL-EXPECTED
     PERFORM CHECK-DONE

     MOVE "acceptance US14 fire_charge places fire with sound item.firecharge.use, consumes 1 from the stack (not durability), nothing in creative" TO TL-CASE
     PERFORM DEFAULTS
     MOVE "fire_charge" TO WS-ITEM
     MOVE "stone" TO WS-KEY
     MOVE 1 TO WS-AIR
     MOVE 1 TO WS-SUPPORT
     PERFORM DO-USE
     MOVE TL-OBSERVED TO WS-ST1
     MOVE 1 TO WS-CREATIVE
     PERFORM DO-USE
     PERFORM JOIN-1
     MOVE "2 fire item.firecharge.use 0 1|2 fire item.firecharge.use 0 0" TO TL-EXPECTED
     PERFORM CHECK-DONE

     MOVE "acceptance US14 fire_charge lights a campfire like flint_steel; flint_steel in creative loses no durability" TO TL-CASE
     PERFORM DEFAULTS
     MOVE "fire_charge" TO WS-ITEM
     MOVE "campfire" TO WS-KEY
     PERFORM DO-USE
     MOVE TL-OBSERVED TO WS-ST1
     MOVE "flint_and_steel" TO WS-ITEM
     MOVE 1 TO WS-CREATIVE
     PERFORM DO-USE
     PERFORM JOIN-1
     MOVE "1 campfire item.firecharge.use 0 1|1 campfire item.flintandsteel.use 0 0" TO TL-EXPECTED
     PERFORM CHECK-DONE

     MOVE "acceptance US14 flint_steel pitch is nextFloat x 0.4 + 0.8 (0.8 to 1.2); fire charge pitch (nextFloat - nextFloat) x 0.2 + 1.0 (0.8 to 1.2)" TO TL-CASE
     MOVE SPACES TO TL-OBSERVED
     MOVE "flint_and_steel" TO WS-ITEM
     MOVE 0 TO WS-R1
     MOVE 0 TO WS-R2
     PERFORM PITCH-OF
     MOVE 500 TO WS-R1
     PERFORM PITCH-OF
     MOVE 999 TO WS-R1
     PERFORM PITCH-OF
     MOVE "fire_charge" TO WS-ITEM
     MOVE 500 TO WS-R1
     MOVE 500 TO WS-R2
     PERFORM PITCH-OF
     MOVE 0 TO WS-R1
     MOVE 999 TO WS-R2
     PERFORM PITCH-OF
     MOVE 999 TO WS-R1
     MOVE 0 TO WS-R2
     PERFORM PITCH-OF
     MOVE "800 1000 1199 1000 800 1199" TO TL-EXPECTED
     PERFORM CHECK-DONE
     STOP RUN.

 JOIN-1.
     MOVE TL-OBSERVED TO WS-ST2
     MOVE SPACES TO TL-OBSERVED
     STRING FUNCTION TRIM(WS-ST1) "|" FUNCTION TRIM(WS-ST2) DELIMITED BY SIZE INTO TL-OBSERVED.

 DEFAULTS.
     MOVE 0 TO WS-LIT WS-WATERLOGGED WS-AIR WS-SUPPORT WS-FLAMMABLE WS-SOUL WS-CREATIVE.

 DO-USE.
     CALL "TOOL-FIRE-USE" USING WS-ITEM WS-KEY WS-LIT WS-WATERLOGGED WS-AIR WS-SUPPORT WS-FLAMMABLE WS-SOUL WS-CREATIVE
         WS-ACTION WS-NEW WS-SOUND WS-DAMAGE WS-CONSUME
     MOVE WS-ACTION TO WS-E1
     MOVE WS-DAMAGE TO WS-E2
     MOVE WS-CONSUME TO WS-E3
     MOVE SPACES TO TL-OBSERVED
     STRING FUNCTION TRIM(WS-E1) " " FUNCTION TRIM(WS-NEW) " " FUNCTION TRIM(WS-SOUND) " " FUNCTION TRIM(WS-E2) " "
         FUNCTION TRIM(WS-E3) DELIMITED BY SIZE INTO TL-OBSERVED.

 USE-SHORT.
     CALL "TOOL-FIRE-USE" USING WS-ITEM WS-KEY WS-LIT WS-WATERLOGGED WS-AIR WS-SUPPORT WS-FLAMMABLE WS-SOUL WS-CREATIVE
         WS-ACTION WS-NEW WS-SOUND WS-DAMAGE WS-CONSUME
     MOVE WS-ACTION TO WS-E1
     IF TL-OBSERVED = SPACES
         MOVE FUNCTION TRIM(WS-E1) TO TL-OBSERVED
     ELSE
         STRING FUNCTION TRIM(TL-OBSERVED) " " FUNCTION TRIM(WS-E1) DELIMITED BY SIZE INTO TL-OBSERVED
     END-IF.

 PITCH-OF.
     CALL "TOOL-FIRE-PITCH" USING WS-ITEM WS-R1 WS-R2 WS-PITCH
     MOVE WS-PITCH TO WS-E1
     IF TL-OBSERVED = SPACES
         MOVE FUNCTION TRIM(WS-E1) TO TL-OBSERVED
     ELSE
         STRING FUNCTION TRIM(TL-OBSERVED) " " FUNCTION TRIM(WS-E1) DELIMITED BY SIZE INTO TL-OBSERVED
     END-IF.

 CHECK-DONE.
     MOVE "T" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-TOOL-USE-3-3.
