*> Scope and the fire block (sections 1 and 2.1 to 2.5) of docs/protocol/29b part 8 as programs of plain numbers (GC8- prefix), helpers like those of growth-29b-6.cob.
*> Fire kinds: 1 fire, 2 soul fire. Float compares use FCMP-GT (a GnuCOBOL float compare has a tolerance).

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC8-OWNER.
*> USING the row (1 to 11) of the owner table of 1 in its order (BINARY-LONG), the owner document PIC X(64) out (blank for a row outside the table).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-DOC                  PIC X(64).
 PROCEDURE DIVISION USING L-ROW L-DOC.
     MOVE SPACES TO L-DOC
     EVALUATE L-ROW
         WHEN 1
             MOVE "17 s3.3, s3.3a" TO L-DOC
         WHEN 2
             MOVE "24 p2 (rows 180, 181; s5.7)" TO L-DOC
         WHEN 3
             MOVE "30 p7 s8; 21 s8.3" TO L-DOC
         WHEN 4
             MOVE "29a (lava)" TO L-DOC
         WHEN 5
             MOVE "33 s4.4; 29b-3" TO L-DOC
         WHEN 6
             MOVE "16 s13; 33" TO L-DOC
         WHEN 7
             MOVE "29a; 44-1" TO L-DOC
         WHEN 8
             MOVE "41; 18 s2.5" TO L-DOC
         WHEN 9
             MOVE "42 p6 (FIRE_AMBIENT); 12" TO L-DOC
         WHEN 10
             MOVE "31 p4 s5" TO L-DOC
         WHEN 11
             MOVE "24 p7 s11.3" TO L-DOC
     END-EVALUATE
     GOBACK.
 END PROGRAM GC8-OWNER.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC8-HANDOFF.
*> USING the hand-off note (1 for 17 section 3.3a step 7, 2 for 30 part 7 section 8.1 and 8.3) (BINARY-LONG), the note PIC X(64) out (blank for another number).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-DOC                  PIC X(64).
 PROCEDURE DIVISION USING L-ROW L-DOC.
     MOVE SPACES TO L-DOC
     EVALUATE L-ROW
         WHEN 1
             MOVE "17 s3.3a step 7: attribute at the fire position (biome data)" TO L-DOC
         WHEN 2
             MOVE "30 p7 s8.1, s8.3: table is 17 s3.3a, burn-out step is 2.7" TO L-DOC
     END-EVALUATE
     GOBACK.
 END PROGRAM GC8-HANDOFF.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC8-FIRE-AMBIENT.
*> USING the draw nextInt(24), the volume float and the pitch float (FLOAT-LONG), then the sound played, its volume x 1e6 (1 + nextFloat) and pitch x 1e6 (0.3 + nextFloat x 0.7) out (1, client).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-DRAW                 BINARY-LONG.
 01 L-F1                   FLOAT-LONG.
 01 L-F2                   FLOAT-LONG.
 01 L-SOUND                BINARY-LONG.
 01 L-VOLUME               BINARY-LONG.
 01 L-PITCH                BINARY-LONG.
 PROCEDURE DIVISION USING L-DRAW L-F1 L-F2 L-SOUND L-VOLUME L-PITCH.
     MOVE 0 TO L-SOUND L-VOLUME L-PITCH
     IF L-DRAW = 0
         MOVE 1 TO L-SOUND
         COMPUTE L-VOLUME ROUNDED = (1 + L-F1) * 1000000
         COMPUTE L-PITCH ROUNDED = (0.3 + L-F2 * 0.7) * 1000000
     END-IF
     GOBACK.
 END PROGRAM GC8-FIRE-AMBIENT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC8-FIRE-FACTS.
*> USING the selector (BINARY-LONG), the value out (2.1, 2.5, 2.6): 1 MAX_AGE, 2 fire damage x 10, 3 soul fire damage x 10, 4 floor sheet height in pixels, 5 fire states, 6 soul fire states,
*> 7 random ticks of fire, 8 ticks of soul fire, 9 spread cells, 10 tick delay base, 11 tick delay range, 12 side flags, 13 inside effects.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-VALUES.
    05 FILLER              BINARY-LONG VALUE 15.
    05 FILLER              BINARY-LONG VALUE 10.
    05 FILLER              BINARY-LONG VALUE 20.
    05 FILLER              BINARY-LONG VALUE 1.
    05 FILLER              BINARY-LONG VALUE 512.
    05 FILLER              BINARY-LONG VALUE 1.
    05 FILLER              BINARY-LONG VALUE 0.
    05 FILLER              BINARY-LONG VALUE 0.
    05 FILLER              BINARY-LONG VALUE 53.
    05 FILLER              BINARY-LONG VALUE 30.
    05 FILLER              BINARY-LONG VALUE 10.
    05 FILLER              BINARY-LONG VALUE 5.
    05 FILLER              BINARY-LONG VALUE 3.
 01 WS-VALUE-T REDEFINES WS-VALUES.
    05 WS-VALUE            BINARY-LONG OCCURS 13 TIMES.
 LINKAGE SECTION.
 01 L-SEL                  BINARY-LONG.
 01 L-VALUE                BINARY-LONG.
 PROCEDURE DIVISION USING L-SEL L-VALUE.
     MOVE WS-VALUE(L-SEL) TO L-VALUE
     GOBACK.
 END PROGRAM GC8-FIRE-FACTS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC8-FIRE-ODDS.
*> USING the odds registered for the block, waterlogged, the odds of the state out (2.1): 0 when waterlogged.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-REGISTERED           BINARY-LONG.
 01 L-WATERLOGGED          BINARY-LONG.
 01 L-ODDS                 BINARY-LONG.
 PROCEDURE DIVISION USING L-REGISTERED L-WATERLOGGED L-ODDS.
     MOVE L-REGISTERED TO L-ODDS
     IF L-WATERLOGGED = 1
         MOVE 0 TO L-ODDS
     END-IF
     GOBACK.
 END PROGRAM GC8-FIRE-ODDS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC8-FIRE-CANBURN.
*> USING the kind, the odds registered for the block, waterlogged, canBurn out (2.1): soul fire always, fire when its odds are above 0 and it is not waterlogged.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-KIND                 BINARY-LONG.
 01 L-REGISTERED           BINARY-LONG.
 01 L-WATERLOGGED          BINARY-LONG.
 01 L-CAN                  BINARY-LONG.
 PROCEDURE DIVISION USING L-KIND L-REGISTERED L-WATERLOGGED L-CAN.
     MOVE 0 TO L-CAN
     IF L-KIND = 2 OR (L-REGISTERED > 0 AND L-WATERLOGGED = 0)
         MOVE 1 TO L-CAN
     END-IF
     GOBACK.
 END PROGRAM GC8-FIRE-CANBURN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC8-FIRE-PLACEMENT.
*> USING a soul_fire_base_blocks block below, the block below can burn, it has a sturdy top, then whether the north, east, south, west and up neighbours can burn, the kind, the north, east,
*> south, west and up flags out (2.2 BaseFireBlock.getState).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-SOUL-BASE            BINARY-LONG.
 01 L-BELOW-BURNS          BINARY-LONG.
 01 L-STURDY               BINARY-LONG.
 01 L-N-IN                 BINARY-LONG.
 01 L-E-IN                 BINARY-LONG.
 01 L-S-IN                 BINARY-LONG.
 01 L-W-IN                 BINARY-LONG.
 01 L-U-IN                 BINARY-LONG.
 01 L-KIND                 BINARY-LONG.
 01 L-N                    BINARY-LONG.
 01 L-E                    BINARY-LONG.
 01 L-S                    BINARY-LONG.
 01 L-W                    BINARY-LONG.
 01 L-U                    BINARY-LONG.
 PROCEDURE DIVISION USING L-SOUL-BASE L-BELOW-BURNS L-STURDY L-N-IN L-E-IN L-S-IN L-W-IN L-U-IN L-KIND L-N L-E L-S L-W L-U.
     MOVE 1 TO L-KIND
     MOVE 0 TO L-N L-E L-S L-W L-U
     IF L-SOUL-BASE = 1
         MOVE 2 TO L-KIND
     ELSE
         IF L-BELOW-BURNS = 0 AND L-STURDY = 0
             MOVE L-N-IN TO L-N
             MOVE L-E-IN TO L-E
             MOVE L-S-IN TO L-S
             MOVE L-W-IN TO L-W
             MOVE L-U-IN TO L-U
         END-IF
     END-IF
     GOBACK.
 END PROGRAM GC8-FIRE-PLACEMENT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC8-FIRE-AGE.
*> USING the kind the placement gave, the age, the kind and age of getStateWithAge out (2.2 step 3): a soul fire is returned unchanged, with no age.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-KIND-IN              BINARY-LONG.
 01 L-AGE-IN               BINARY-LONG.
 01 L-KIND                 BINARY-LONG.
 01 L-AGE                  BINARY-LONG.
 PROCEDURE DIVISION USING L-KIND-IN L-AGE-IN L-KIND L-AGE.
     MOVE L-KIND-IN TO L-KIND
     MOVE 0 TO L-AGE
     IF L-KIND-IN = 1
         MOVE L-AGE-IN TO L-AGE
     END-IF
     GOBACK.
 END PROGRAM GC8-FIRE-AGE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC8-FIRE-SURVIVE.
*> USING the kind, the block below has a sturdy top, isValidFireLocation, a soul_fire_base_blocks block below, canSurvive out (2.3).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-KIND                 BINARY-LONG.
 01 L-STURDY               BINARY-LONG.
 01 L-VALID                BINARY-LONG.
 01 L-SOUL-BASE            BINARY-LONG.
 01 L-SURVIVE              BINARY-LONG.
 PROCEDURE DIVISION USING L-KIND L-STURDY L-VALID L-SOUL-BASE L-SURVIVE.
     MOVE 0 TO L-SURVIVE
     IF L-KIND = 2
         MOVE L-SOUL-BASE TO L-SURVIVE
     ELSE
         IF L-STURDY = 1 OR L-VALID = 1
             MOVE 1 TO L-SURVIVE
         END-IF
     END-IF
     GOBACK.
 END PROGRAM GC8-FIRE-SURVIVE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC8-FIRE-UPDATE.
*> USING the kind, canSurvive, a soul_fire_base_blocks block below, the result out (2.3 updateShape): 0 air, 1 fire with its flags recomputed, 2 soul fire.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-KIND                 BINARY-LONG.
 01 L-SURVIVE              BINARY-LONG.
 01 L-SOUL-BASE            BINARY-LONG.
 01 L-RESULT               BINARY-LONG.
 PROCEDURE DIVISION USING L-KIND L-SURVIVE L-SOUL-BASE L-RESULT.
     MOVE 0 TO L-RESULT
     IF L-SURVIVE = 1
         MOVE 1 TO L-RESULT
         IF L-KIND = 2 OR L-SOUL-BASE = 1
             MOVE 2 TO L-RESULT
         END-IF
     END-IF
     GOBACK.
 END PROGRAM GC8-FIRE-UPDATE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC8-FIRE-ONPLACE.
*> USING the old state is the same block, the dimension is the Overworld or the Nether, a portal shape was found, canSurvive, the kind, then the portal created, the fire removed,
*> a tick scheduled, the draws made out (2.4).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-SAME                 BINARY-LONG.
 01 L-PORTAL-DIM           BINARY-LONG.
 01 L-SHAPE                BINARY-LONG.
 01 L-SURVIVE              BINARY-LONG.
 01 L-KIND                 BINARY-LONG.
 01 L-PORTAL               BINARY-LONG.
 01 L-REMOVED              BINARY-LONG.
 01 L-SCHEDULED            BINARY-LONG.
 01 L-DRAWS                BINARY-LONG.
 PROCEDURE DIVISION USING L-SAME L-PORTAL-DIM L-SHAPE L-SURVIVE L-KIND L-PORTAL L-REMOVED L-SCHEDULED L-DRAWS.
     MOVE 0 TO L-PORTAL L-REMOVED L-SCHEDULED L-DRAWS
     IF L-SAME = 0
         IF L-PORTAL-DIM = 1 AND L-SHAPE = 1
             MOVE 1 TO L-PORTAL
         ELSE
             IF L-SURVIVE = 0
                 MOVE 1 TO L-REMOVED
             END-IF
         END-IF
     END-IF
     IF L-KIND = 1
         MOVE 1 TO L-SCHEDULED L-DRAWS
     END-IF
     GOBACK.
 END PROGRAM GC8-FIRE-ONPLACE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC8-FIRE-DELAY.
*> USING the draw nextInt(10), the tick delay out (2.4, 2.5 step 1): 30 + draw.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-DRAW                 BINARY-LONG.
 01 L-DELAY                BINARY-LONG.
 PROCEDURE DIVISION USING L-DRAW L-DELAY.
     COMPUTE L-DELAY = 30 + L-DRAW
     GOBACK.
 END PROGRAM GC8-FIRE-DELAY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC8-FIRE-NEAR-RAIN.
*> USING rain at the position, then at the west, east, north and south neighbours, near rain, the tests made out (2.5 step 5, short circuit in that order).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-I                   BINARY-LONG.
 01 WS-RAIN-T.
    05 WS-RAIN             BINARY-LONG OCCURS 5 TIMES.
 LINKAGE SECTION.
 01 L-AT                   BINARY-LONG.
 01 L-WEST                 BINARY-LONG.
 01 L-EAST                 BINARY-LONG.
 01 L-NORTH                BINARY-LONG.
 01 L-SOUTH                BINARY-LONG.
 01 L-NEAR                 BINARY-LONG.
 01 L-TESTS                BINARY-LONG.
 PROCEDURE DIVISION USING L-AT L-WEST L-EAST L-NORTH L-SOUTH L-NEAR L-TESTS.
     MOVE L-AT TO WS-RAIN(1)
     MOVE L-WEST TO WS-RAIN(2)
     MOVE L-EAST TO WS-RAIN(3)
     MOVE L-NORTH TO WS-RAIN(4)
     MOVE L-SOUTH TO WS-RAIN(5)
     MOVE 0 TO L-NEAR L-TESTS
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 5 OR L-NEAR = 1
         MOVE WS-I TO L-TESTS
         MOVE WS-RAIN(WS-I) TO L-NEAR
     END-PERFORM
     GOBACK.
 END PROGRAM GC8-FIRE-NEAR-RAIN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC8-FIRE-TICK.
*> USING age (the entry age), canSpreadFireAround, canSurvive, infiniburn, raining, near rain, the rain float (FLOAT-LONG), the age draw nextInt(3), isValidFireLocation, the block below has a sturdy
*> top, the draw nextInt(4), the block below can burn, then the end step (0 goes on to the burn-out and spread, 2 5 7 the step that ends it), a removal happened, the age was written (flags 260),
*> the age, the random draws made (the reschedule included), quirk A's extra draw out (2.5).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-LIMIT               FLOAT-LONG.
 01 WS-BELOW               BINARY-LONG.
 01 WS-HALF                BINARY-LONG.
 LINKAGE SECTION.
 01 L-AGE                  BINARY-LONG.
 01 L-SPREAD               BINARY-LONG.
 01 L-SURVIVE              BINARY-LONG.
 01 L-INFINIBURN           BINARY-LONG.
 01 L-RAINING              BINARY-LONG.
 01 L-NEAR                 BINARY-LONG.
 01 L-RAIN-DRAW            FLOAT-LONG.
 01 L-AGE-DRAW             BINARY-LONG.
 01 L-VALID                BINARY-LONG.
 01 L-STURDY               BINARY-LONG.
 01 L-DRAW4                BINARY-LONG.
 01 L-BELOW-BURNS          BINARY-LONG.
 01 L-END                  BINARY-LONG.
 01 L-REMOVED              BINARY-LONG.
 01 L-WROTE                BINARY-LONG.
 01 L-NEW-AGE              BINARY-LONG.
 01 L-DRAWS                BINARY-LONG.
 01 L-EXTRA                BINARY-LONG.
 01 L-CONTINUES            BINARY-LONG.
 PROCEDURE DIVISION USING L-AGE L-SPREAD L-SURVIVE L-INFINIBURN L-RAINING L-NEAR L-RAIN-DRAW L-AGE-DRAW L-VALID L-STURDY L-DRAW4 L-BELOW-BURNS
                          L-END L-REMOVED L-WROTE L-NEW-AGE L-DRAWS L-EXTRA L-CONTINUES.
     MOVE 0 TO L-END L-REMOVED L-WROTE L-EXTRA L-CONTINUES
     MOVE L-AGE TO L-NEW-AGE
     MOVE 1 TO L-DRAWS
     EVALUATE TRUE
         WHEN L-SPREAD = 0
             MOVE 2 TO L-END
         WHEN OTHER
             IF L-SURVIVE = 0
                 MOVE 1 TO L-REMOVED
             END-IF
             IF L-INFINIBURN = 0 AND L-RAINING = 1 AND L-NEAR = 1
                 ADD 1 TO L-DRAWS
                 COMPUTE WS-LIMIT = 0.2 + 0.03 * L-AGE
                 CALL "FCMP-GT" USING WS-LIMIT L-RAIN-DRAW WS-BELOW
                 IF WS-BELOW = 1
                     MOVE 5 TO L-END
                     MOVE 1 TO L-REMOVED
                 END-IF
             END-IF
             IF L-END = 0
                 ADD 1 TO L-DRAWS
                 DIVIDE L-AGE-DRAW BY 2 GIVING WS-HALF
                 COMPUTE L-NEW-AGE = FUNCTION MIN(15, L-AGE + WS-HALF)
                 IF L-NEW-AGE NOT = L-AGE
                     MOVE 1 TO L-WROTE
                     IF L-REMOVED = 1
                         MOVE 1 TO L-EXTRA
                         ADD 1 TO L-DRAWS
                     END-IF
                 END-IF
                 IF L-INFINIBURN = 0
                     IF L-VALID = 0
                         MOVE 7 TO L-END
                         IF L-STURDY = 0 OR L-AGE > 3
                             MOVE 1 TO L-REMOVED
                         END-IF
                     ELSE
                         IF L-AGE = 15
                             ADD 1 TO L-DRAWS
                             IF L-DRAW4 = 0 AND L-BELOW-BURNS = 0
                                 MOVE 7 TO L-END
                                 MOVE 1 TO L-REMOVED
                             END-IF
                         END-IF
                     END-IF
                 END-IF
                 IF L-END = 0
                     MOVE 1 TO L-CONTINUES
                 END-IF
             END-IF
     END-EVALUATE
     GOBACK.
 END PROGRAM GC8-FIRE-TICK.
