*> Acceptance test of docs/protocol/42-particles-1-shared-model-engine.md section 2 (registry: the 128
*> particle types): ids 0 to 127 in registration order, the counts of the validation paragraph
*> (option kinds, 32 override-limiter types by id, parts 50 / 27 / 26 / 25, 14 plain providers),
*> shared providers, spot rows, lookup by name with and without the namespace.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-PARTICLES-42-1-2.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 01 WS-ID                  BINARY-LONG.
 01 WS-NAME                PIC X(32).
 01 WS-OPTIONS             PIC X(16).
 01 WS-OVERRIDE            BINARY-LONG.
 01 WS-PROVIDER            PIC X(56).
 01 WS-SPRITES             BINARY-LONG.
 01 WS-PART                BINARY-LONG.
 01 WS-COUNTS.
    05 WS-SIMPLE           BINARY-LONG VALUE 0.
    05 WS-BLOCK            BINARY-LONG VALUE 0.
    05 WS-COLOR            BINARY-LONG VALUE 0.
    05 WS-SPELL            BINARY-LONG VALUE 0.
    05 WS-GEYSER           BINARY-LONG VALUE 0.
    05 WS-GEYSER-BASE      BINARY-LONG VALUE 0.
    05 WS-OTHER            BINARY-LONG VALUE 0.
    05 WS-OVERRIDES        BINARY-LONG VALUE 0.
    05 WS-PLAIN            BINARY-LONG VALUE 0.
    05 WS-PARTS            BINARY-LONG OCCURS 5 TIMES VALUE 0.
    05 WS-FLAME            BINARY-LONG VALUE 0.
    05 WS-NAMED            BINARY-LONG VALUE 0.
 01 WS-OVERRIDE-LIST       PIC X(96) VALUE
     "002007008009010014024029030031033034035048049058069075076077087088109110111112113114118119120122".
 01 WS-OVERRIDE-IDS REDEFINES WS-OVERRIDE-LIST.
    05 WS-OV-ID            PIC 999 OCCURS 32 TIMES.
 01 WS-I                   BINARY-LONG.
 01 WS-LISTED              BINARY-LONG.
 01 WS-LOOKUP              PIC X(32).
 01 WS-D1                  PIC Z9.
 01 WS-D2                  PIC Z9.
 01 WS-D3                  PIC Z9.
 PROCEDURE DIVISION.
     PERFORM VARYING WS-ID FROM 0 BY 1 UNTIL WS-ID > 127
         CALL "PART-TYPE" USING WS-ID WS-NAME WS-OPTIONS WS-OVERRIDE WS-PROVIDER WS-SPRITES
             WS-PART
         EVALUATE WS-OPTIONS
             WHEN "simple"
                 ADD 1 TO WS-SIMPLE
             WHEN "block"
                 ADD 1 TO WS-BLOCK
             WHEN "color"
                 ADD 1 TO WS-COLOR
             WHEN "spell"
                 ADD 1 TO WS-SPELL
             WHEN "geyser"
                 ADD 1 TO WS-GEYSER
             WHEN "geyser-base"
                 ADD 1 TO WS-GEYSER-BASE
             WHEN OTHER
                 ADD 1 TO WS-OTHER
         END-EVALUATE
         ADD WS-OVERRIDE TO WS-OVERRIDES
         IF WS-SPRITES = 0
             ADD 1 TO WS-PLAIN
         END-IF
         ADD 1 TO WS-PARTS(WS-PART)
         IF WS-PROVIDER = "FlameParticle$Provider"
             ADD 1 TO WS-FLAME
         END-IF
         IF WS-NAME NOT = SPACES
             ADD 1 TO WS-NAMED
         END-IF
     END-PERFORM
     MOVE "acceptance US12 42-1§2 Registry: the 128 particle types: 128 named types" TO TL-CASE
     MOVE 128 TO TL-EXPECTED-N
     MOVE WS-NAMED TO TL-OBSERVED-N
     PERFORM ASSERT-NUMBER
     MOVE "acceptance US12 42-1§2 Registry: the 128 particle types: 106 simple" TO TL-CASE
     MOVE 106 TO TL-EXPECTED-N
     MOVE WS-SIMPLE TO TL-OBSERVED-N
     PERFORM ASSERT-NUMBER
     MOVE "acceptance US12 42-1§2 Registry: the 128 particle types: 5 block" TO TL-CASE
     MOVE 5 TO TL-EXPECTED-N
     MOVE WS-BLOCK TO TL-OBSERVED-N
     PERFORM ASSERT-NUMBER
     MOVE "acceptance US12 42-1§2 Registry: the 128 particle types: 3 color" TO TL-CASE
     MOVE 3 TO TL-EXPECTED-N
     MOVE WS-COLOR TO TL-OBSERVED-N
     PERFORM ASSERT-NUMBER
     MOVE "acceptance US12 42-1§2 Registry: the 128 particle types: 2 spell" TO TL-CASE
     MOVE 2 TO TL-EXPECTED-N
     MOVE WS-SPELL TO TL-OBSERVED-N
     PERFORM ASSERT-NUMBER
     MOVE "acceptance US12 42-1§2 Registry: the 128 particle types: 2 geyser" TO TL-CASE
     MOVE WS-GEYSER TO TL-OBSERVED-N
     PERFORM ASSERT-NUMBER
     MOVE "acceptance US12 42-1§2 Registry: the 128 particle types: 2 geyser-base" TO TL-CASE
     MOVE WS-GEYSER-BASE TO TL-OBSERVED-N
     PERFORM ASSERT-NUMBER
     MOVE "acceptance US12 42-1§2 Registry: the 128 particle types: 8 single-option kinds" TO TL-CASE
     MOVE 8 TO TL-EXPECTED-N
     MOVE WS-OTHER TO TL-OBSERVED-N
     PERFORM ASSERT-NUMBER
     MOVE "acceptance US12 42-1§2 Registry: the 128 particle types: 32 override-limiter types" TO TL-CASE
     MOVE 32 TO TL-EXPECTED-N
     MOVE WS-OVERRIDES TO TL-OBSERVED-N
     PERFORM ASSERT-NUMBER
     MOVE "acceptance US12 42-1§2 Registry: the 128 particle types: 14 plain providers" TO TL-CASE
     MOVE 14 TO TL-EXPECTED-N
     MOVE WS-PLAIN TO TL-OBSERVED-N
     PERFORM ASSERT-NUMBER
     MOVE "acceptance US12 42-1§2 Registry: the 128 particle types: part 2 has 50" TO TL-CASE
     MOVE 50 TO TL-EXPECTED-N
     MOVE WS-PARTS(2) TO TL-OBSERVED-N
     PERFORM ASSERT-NUMBER
     MOVE "acceptance US12 42-1§2 Registry: the 128 particle types: part 3 has 27" TO TL-CASE
     MOVE 27 TO TL-EXPECTED-N
     MOVE WS-PARTS(3) TO TL-OBSERVED-N
     PERFORM ASSERT-NUMBER
     MOVE "acceptance US12 42-1§2 Registry: the 128 particle types: part 4 has 26" TO TL-CASE
     MOVE 26 TO TL-EXPECTED-N
     MOVE WS-PARTS(4) TO TL-OBSERVED-N
     PERFORM ASSERT-NUMBER
     MOVE "acceptance US12 42-1§2 Registry: the 128 particle types: part 5 has 25" TO TL-CASE
     MOVE 25 TO TL-EXPECTED-N
     MOVE WS-PARTS(5) TO TL-OBSERVED-N
     PERFORM ASSERT-NUMBER
     MOVE "acceptance US12 42-1§2 Registry: the 128 particle types: Flame provider serves 3 types"
         TO TL-CASE
     MOVE 3 TO TL-EXPECTED-N
     MOVE WS-FLAME TO TL-OBSERVED-N
     PERFORM ASSERT-NUMBER
*>   V2: the 32 override-limiter types by id.
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 32
         MOVE WS-OV-ID(WS-I) TO WS-ID
         CALL "PART-TYPE" USING WS-ID WS-NAME WS-OPTIONS WS-OVERRIDE WS-PROVIDER WS-SPRITES
             WS-PART
         MOVE "acceptance US12 42-1§2 Registry: the 128 particle types: override limiter by id"
             TO TL-CASE
         MOVE 1 TO TL-EXPECTED-N
         MOVE WS-OVERRIDE TO TL-OBSERVED-N
         PERFORM ASSERT-NUMBER
     END-PERFORM
*>   Spot rows.
     MOVE 0 TO WS-ID
     PERFORM SPOT-ROW
     MOVE "angry_villager|simple|0|HeartParticle$AngryVillagerProvider|1|2" TO TL-EXPECTED
     PERFORM ASSERT-ROW
     MOVE 26 TO WS-ID
     PERFORM SPOT-ROW
     MOVE "enchant|simple|0|FlyTowardsPositionParticle$EnchantProvider|26|2" TO TL-EXPECTED
     PERFORM ASSERT-ROW
     MOVE 48 TO WS-ID
     PERFORM SPOT-ROW
     MOVE "sculk_charge|sculk-charge|1|SculkChargeParticle$Provider|7|5" TO TL-EXPECTED
     PERFORM ASSERT-ROW
     MOVE 121 TO WS-ID
     PERFORM SPOT-ROW
     MOVE "dust_pillar|block|0|TerrainParticle$DustPillarProvider|0|4" TO TL-EXPECTED
     PERFORM ASSERT-ROW
     MOVE 127 TO WS-ID
     PERFORM SPOT-ROW
     MOVE "sulfur_cube_goo|simple|0|BreakingItemParticle$SulfurCubeProvider|1|4" TO TL-EXPECTED
     PERFORM ASSERT-ROW
     MOVE 120 TO WS-ID
     PERFORM SPOT-ROW
     MOVE "vault_connection|simple|1|FlyTowardsPositionParticle$VaultConnectionProvider|1|5"
         TO TL-EXPECTED
     PERFORM ASSERT-ROW
*>   Lookup by name, with and without the namespace; unknown names and ids out of range.
     MOVE "minecraft:flame" TO WS-LOOKUP
     CALL "PART-TYPE-ID" USING WS-LOOKUP WS-ID
     MOVE "acceptance US12 42-1§2 Registry: the 128 particle types: minecraft:flame is 39"
         TO TL-CASE
     MOVE 39 TO TL-EXPECTED-N
     MOVE WS-ID TO TL-OBSERVED-N
     PERFORM ASSERT-NUMBER
     MOVE "sulfur_cube_goo" TO WS-LOOKUP
     CALL "PART-TYPE-ID" USING WS-LOOKUP WS-ID
     MOVE "acceptance US12 42-1§2 Registry: the 128 particle types: last name is 127" TO TL-CASE
     MOVE 127 TO TL-EXPECTED-N
     MOVE WS-ID TO TL-OBSERVED-N
     PERFORM ASSERT-NUMBER
     MOVE "no_such_particle" TO WS-LOOKUP
     CALL "PART-TYPE-ID" USING WS-LOOKUP WS-ID
     MOVE "acceptance US12 42-1§2 Registry: the 128 particle types: unknown name is -1" TO TL-CASE
     MOVE -1 TO TL-EXPECTED-N
     MOVE WS-ID TO TL-OBSERVED-N
     PERFORM ASSERT-NUMBER
     MOVE 128 TO WS-ID
     CALL "PART-TYPE" USING WS-ID WS-NAME WS-OPTIONS WS-OVERRIDE WS-PROVIDER WS-SPRITES WS-PART
     MOVE "acceptance US12 42-1§2 Registry: the 128 particle types: id 128 has no name" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE SPACES TO TL-EXPECTED
     MOVE WS-NAME TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.

 SPOT-ROW.
     CALL "PART-TYPE" USING WS-ID WS-NAME WS-OPTIONS WS-OVERRIDE WS-PROVIDER WS-SPRITES WS-PART.

 ASSERT-ROW.
     MOVE "acceptance US12 42-1§2 Registry: the 128 particle types: row" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE SPACES TO TL-OBSERVED
     MOVE WS-OVERRIDE TO WS-D1
     MOVE WS-SPRITES TO WS-D2
     MOVE WS-PART TO WS-D3
     STRING FUNCTION TRIM(WS-NAME) "|" FUNCTION TRIM(WS-OPTIONS) "|" FUNCTION TRIM(WS-D1) "|"
         FUNCTION TRIM(WS-PROVIDER) "|" FUNCTION TRIM(WS-D2) "|" FUNCTION TRIM(WS-D3)
         DELIMITED BY SIZE INTO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

 ASSERT-NUMBER.
     MOVE "N" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-PARTICLES-42-1-2.
