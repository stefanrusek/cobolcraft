*> The creaking heart block entity in the live world (lane 002-lane-p49x; docs/protocol/31 section 6, 44-5 section 8, 20 section 17, 30-2 section 5; state HEARTSTATE.cpy, mob-20-17c.cob has the
*> state update itself). BE-TICK-ALL calls HEART-RUN for every heart block entity of a loaded chunk.
*>   HEART-IS-LOG USING state, axis out (X(32)), log out         the tag pale_oak_logs (pale_oak_log, pale_oak_wood, stripped_pale_oak_log, stripped_pale_oak_wood) and the axis property
*>   HEART-LOGS USING dim, x, y, z, axis (X(32)), logs out       hasRequiredLogs: both neighbours along the axis are pale oak logs of that axis
*>   HEART-PROTECTOR USING heart slot, creaking row out          the protector of the heart's link (0 none)
*>   HEART-SIGNAL USING heart slot, block id                      the comparator output (cached; updateNeighbourForOutputSignal when it changes)
*>   HEART-SOUND USING dim, x, y, z, key (X(48)), volume, pitch  Sound (0x77) of a block sound to the viewers of the chunk
*>   HEART-TRAILS USING heart slot, reverse, count                emitParticles: trail particles between the creaking and the heart
*>   HEART-EMIT USING heart slot                                  step 3 of the server tick: the hurt emitter (particles, the hurt sound every 10 ticks)
*>   HEART-DIRECTIONS USING table of six                          the directions 0 to 5 in a random order (Util.shuffledCopy)
*>   HEART-RESIN USING dim, x, y, z, found out, resin x, y, z out spreadResin
*>   HEART-HURT USING creaking row                                creakingHurt: 20 particles, resin while awake, the emitter
*>   CREAKING-REDIRECT USING creaking row, cause, redirected out  a hit on a heart-bound creaking goes to the heart (damage that bypasses invulnerability does not)
*>   CREAKING-LEASH USING creaking row, walk x, walk z            the path evaluator's 32 blocks around the home: a step that ends farther is cancelled
*>   HEART-SWEEP                                                  a heart whose block entity is gone (broken, chunk dropped) tears its protector down (removeProtector(null)) and is forgotten
*>   HEART-RUN USING block entity index                           one tick of a heart
*> Not built: isPersistenceRequired of the protector is 0 (the document does not give it), "a player is stuck in it" is 0, the creaking's own spawn sound (creaking.spawn), the game events
*> (entity_place, block_place), the explosion path (onExplosionHit) and the experience of a natural heart, the save and load of the link (key creaking), hasRequiredLogs read at the
*> scheduled tick of a neighbour change (here: every runner tick of an uprooted heart, at most one tick late), the water level of a flowing source and the shapes of the floor.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. HEART-IS-LOG.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CBLOCKS.
 01 WS-KEY                 PIC X(48).
 01 WS-LENGTH              BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
 01 WS-NAME                PIC X(24) VALUE "axis".
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-RESULT              BINARY-LONG.
 LINKAGE SECTION.
 01 L-STATE                BINARY-LONG.
 01 L-AXIS                 PIC X(32).
 01 L-LOG                  BINARY-LONG.
 PROCEDURE DIVISION USING L-STATE L-AXIS L-LOG.
     MOVE 0 TO L-LOG
     MOVE SPACES TO L-AXIS
     MOVE CB-S-BLOCK(L-STATE + 1) TO WS-BLOCK
     CALL "BE-BLOCK-KEY" USING WS-BLOCK WS-KEY WS-LENGTH
     IF WS-KEY = "minecraft:pale_oak_log" OR "minecraft:pale_oak_wood" OR "minecraft:stripped_pale_oak_log" OR "minecraft:stripped_pale_oak_wood"
         MOVE 1 TO L-LOG
         CALL "BLOCK-STATE-PROP" USING WS-ONE L-STATE WS-NAME L-AXIS WS-RESULT
     END-IF
     GOBACK.
 END PROGRAM HEART-IS-LOG.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. HEART-LOGS.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-XYZ                 PIC X(3) VALUE "xyz".
 01 WS-N                   BINARY-LONG.
 01 WS-DX                  BINARY-LONG.
 01 WS-DY                  BINARY-LONG.
 01 WS-DZ                  BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-AXIS                PIC X(32).
 01 WS-LOG1                BINARY-LONG.
 01 WS-SAME1               BINARY-LONG.
 01 WS-LOG2                BINARY-LONG.
 01 WS-SAME2               BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-AXIS                 PIC X(32).
 01 L-LOGS                 BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z L-AXIS L-LOGS.
*>   The axis x, y, z is the index 0, 1, 2 of "xyz": the step along it is one on that axis.
     MOVE 0 TO WS-N
     INSPECT WS-XYZ TALLYING WS-N FOR CHARACTERS BEFORE INITIAL L-AXIS(1:1)
     COMPUTE WS-DX = FUNCTION MAX(0, 1 - WS-N)
     COMPUTE WS-DY = 1 - FUNCTION ABS(WS-N - 1)
     COMPUTE WS-DZ = FUNCTION MAX(0, WS-N - 1)
     COMPUTE WS-X = L-X + WS-DX
     COMPUTE WS-Y = L-Y + WS-DY
     COMPUTE WS-Z = L-Z + WS-DZ
     CALL "WORLD-GET-BLOCK" USING L-DIM WS-X WS-Y WS-Z WS-STATE
     CALL "HEART-IS-LOG" USING WS-STATE WS-AXIS WS-LOG1
     MOVE 0 TO WS-SAME1
     IF WS-AXIS = L-AXIS
         MOVE 1 TO WS-SAME1
     END-IF
     COMPUTE WS-X = L-X - WS-DX
     COMPUTE WS-Y = L-Y - WS-DY
     COMPUTE WS-Z = L-Z - WS-DZ
     CALL "WORLD-GET-BLOCK" USING L-DIM WS-X WS-Y WS-Z WS-STATE
     CALL "HEART-IS-LOG" USING WS-STATE WS-AXIS WS-LOG2
     MOVE 0 TO WS-SAME2
     IF WS-AXIS = L-AXIS
         MOVE 1 TO WS-SAME2
     END-IF
     CALL "BE5-HEART-LOGS" USING WS-LOG1 WS-SAME1 WS-LOG2 WS-SAME2 L-LOGS
     GOBACK.
 END PROGRAM HEART-LOGS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. HEART-PROTECTOR.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY HEARTSTATE.
 01 WS-E                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-SLOT                 BINARY-LONG.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-SLOT L-ROW.
     MOVE 0 TO L-ROW
     IF HT-LINK(L-SLOT) > 0
         PERFORM VARYING WS-E FROM 1 BY 1 UNTIL WS-E > EN-COUNT
             IF EN-USED(WS-E) = 1 AND EN-ID(WS-E) = HT-LINK(L-SLOT)
                 MOVE WS-E TO L-ROW
             END-IF
         END-PERFORM
     END-IF
     GOBACK.
 END PROGRAM HEART-PROTECTOR.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. HEART-SIGNAL.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY HEARTSTATE.
 01 WS-ROW                 BINARY-LONG.
 01 WS-LINK                BINARY-LONG.
 01 WS-PROTECTOR           BINARY-LONG.
 01 WS-DX                  FLOAT-LONG.
 01 WS-DY                  FLOAT-LONG.
 01 WS-DZ                  FLOAT-LONG.
 01 WS-DIST                FLOAT-LONG.
 01 WS-SIGNAL              BINARY-LONG.
 LINKAGE SECTION.
 01 L-SLOT                 BINARY-LONG.
 01 L-BLOCK                BINARY-LONG.
 PROCEDURE DIVISION USING L-SLOT L-BLOCK.
*>   The distance from the protector to the bottom centre of the heart cell; the formula of 31 section 6.6 is BE5-HEART-COMPARATOR's.
     CALL "HEART-PROTECTOR" USING L-SLOT WS-ROW
     MOVE 0 TO WS-LINK WS-PROTECTOR WS-DIST
     IF HT-LINK(L-SLOT) > 0
         MOVE 1 TO WS-LINK
     END-IF
     IF WS-ROW > 0
         MOVE 1 TO WS-PROTECTOR
         COMPUTE WS-DX = EN-X(WS-ROW) - HT-X(L-SLOT) - 0.5
         COMPUTE WS-DY = EN-Y(WS-ROW) - HT-Y(L-SLOT)
         COMPUTE WS-DZ = EN-Z(WS-ROW) - HT-Z(L-SLOT) - 0.5
         COMPUTE WS-DIST = FUNCTION SQRT(WS-DX * WS-DX + WS-DY * WS-DY + WS-DZ * WS-DZ)
     END-IF
     CALL "BE5-HEART-COMPARATOR" USING WS-LINK WS-PROTECTOR WS-DIST WS-SIGNAL
     IF WS-SIGNAL NOT = HT-SIGNAL(L-SLOT)
         MOVE WS-SIGNAL TO HT-SIGNAL(L-SLOT)
         CALL "BU-OUTPUT-SIGNAL" USING HT-DIM(L-SLOT) HT-X(L-SLOT) HT-Y(L-SLOT) HT-Z(L-SLOT) L-BLOCK
     END-IF
     GOBACK.
 END PROGRAM HEART-SIGNAL.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. HEART-SOUND.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CONTENT.
 COPY PROTO.
 01 WS-CAPACITY            BINARY-LONG VALUE 64.
 01 WS-PACKET-ID           BINARY-LONG VALUE 119.
 01 WS-REGISTRY            PIC X(48) VALUE "minecraft:sound_event".
 01 WS-KEY                 PIC X(112).
 01 WS-ID                  BINARY-LONG.
 01 WS-STATUS              BINARY-LONG.
 01 WS-HOLDER              BINARY-LONG.
 01 WS-SOURCE              BINARY-LONG VALUE 4.
 01 WS-FX                  BINARY-LONG.
 01 WS-FY                  BINARY-LONG.
 01 WS-FZ                  BINARY-LONG.
 01 WS-SEED                BINARY-DOUBLE VALUE 0.
 01 WS-CX                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-NONE                BINARY-LONG VALUE 0.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-KEY                  PIC X(48).
 01 L-VOLUME               FLOAT-SHORT.
 01 L-PITCH                FLOAT-SHORT.
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z L-KEY L-VOLUME L-PITCH.
     MOVE L-KEY TO WS-KEY
     CALL "CONTENT-STATIC-ID" USING WS-REGISTRY WS-KEY WS-ID WS-STATUS
     COMPUTE WS-HOLDER = WS-ID + 1
     COMPUTE WS-FX = L-X * 8 + 4
     COMPUTE WS-FY = L-Y * 8 + 4
     COMPUTE WS-FZ = L-Z * 8 + 4
     COMPUTE WS-CX = (L-X - FUNCTION MOD(L-X, 16)) / 16
     COMPUTE WS-CZ = (L-Z - FUNCTION MOD(L-Z, 16)) / 16
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-PACKET-ID
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-HOLDER
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-SOURCE
     CALL "PB-PUT-INT" USING PB-BUFFER WS-FX
     CALL "PB-PUT-INT" USING PB-BUFFER WS-FY
     CALL "PB-PUT-INT" USING PB-BUFFER WS-FZ
     CALL "PB-PUT-FLOAT" USING PB-BUFFER L-VOLUME
     CALL "PB-PUT-FLOAT" USING PB-BUFFER L-PITCH
     CALL "PB-PUT-LONG" USING PB-BUFFER WS-SEED
     CALL "VIEWERS-SEND" USING L-DIM WS-CX WS-CZ WS-NONE PB-BUFFER
     CALL "PB-FREE" USING PB-BUFFER
     GOBACK.
 END PROGRAM HEART-SOUND.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. HEART-TRAILS.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY HEARTSTATE.
 01 WS-SALT                BINARY-LONG VALUE 101.
 01 WS-B1M                 BINARY-LONG VALUE 1000000.
 01 WS-B40                 BINARY-LONG VALUE 40.
 01 WS-ROW                 BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-DRAW                BINARY-LONG.
 01 WS-DURATION            BINARY-LONG.
 01 WS-COLOUR              BINARY-LONG.
 01 WS-CX                  FLOAT-LONG.
 01 WS-CY                  FLOAT-LONG.
 01 WS-CZ                  FLOAT-LONG.
 01 WS-HX                  FLOAT-LONG.
 01 WS-HY                  FLOAT-LONG.
 01 WS-HZ                  FLOAT-LONG.
 01 WS-SX                  FLOAT-LONG.
 01 WS-SY                  FLOAT-LONG.
 01 WS-SZ                  FLOAT-LONG.
 01 WS-TX                  FLOAT-LONG.
 01 WS-TY                  FLOAT-LONG.
 01 WS-TZ                  FLOAT-LONG.
 LINKAGE SECTION.
 01 L-SLOT                 BINARY-LONG.
 01 L-REVERSE              BINARY-LONG.
 01 L-COUNT                BINARY-LONG.
 PROCEDURE DIVISION USING L-SLOT L-REVERSE L-COUNT.
*>   Nothing without a protector. Each repetition draws a point in the creaking's box (min corner + a fraction of 0.9 x 2.7 x 0.9) and a point in the heart cell, and a duration of
*>   10 + nextInt(40); a reverse emission swaps them (it leaves the heart and flows to the creaking).
     CALL "HEART-PROTECTOR" USING L-SLOT WS-ROW
     IF WS-ROW = 0
         GOBACK
     END-IF
     MOVE 6250335 TO WS-COLOUR
     IF L-REVERSE = 1
         MOVE 16545810 TO WS-COLOUR
     END-IF
     PERFORM L-COUNT TIMES
         CALL "XP-RANDOM" USING WS-SALT WS-B1M WS-DRAW
         COMPUTE WS-CX = EN-X(WS-ROW) - 0.45 + WS-DRAW / 1000000 * 0.9
         CALL "XP-RANDOM" USING WS-SALT WS-B1M WS-DRAW
         COMPUTE WS-CY = EN-Y(WS-ROW) + WS-DRAW / 1000000 * 2.7
         CALL "XP-RANDOM" USING WS-SALT WS-B1M WS-DRAW
         COMPUTE WS-CZ = EN-Z(WS-ROW) - 0.45 + WS-DRAW / 1000000 * 0.9
         CALL "XP-RANDOM" USING WS-SALT WS-B1M WS-DRAW
         COMPUTE WS-HX = HT-X(L-SLOT) + WS-DRAW / 1000000
         CALL "XP-RANDOM" USING WS-SALT WS-B1M WS-DRAW
         COMPUTE WS-HY = HT-Y(L-SLOT) + WS-DRAW / 1000000
         CALL "XP-RANDOM" USING WS-SALT WS-B1M WS-DRAW
         COMPUTE WS-HZ = HT-Z(L-SLOT) + WS-DRAW / 1000000
         CALL "XP-RANDOM" USING WS-SALT WS-B40 WS-DRAW
         COMPUTE WS-DURATION = 10 + WS-DRAW
         IF L-REVERSE = 1
             MOVE WS-HX TO WS-SX
             MOVE WS-HY TO WS-SY
             MOVE WS-HZ TO WS-SZ
             MOVE WS-CX TO WS-TX
             MOVE WS-CY TO WS-TY
             MOVE WS-CZ TO WS-TZ
         ELSE
             MOVE WS-CX TO WS-SX
             MOVE WS-CY TO WS-SY
             MOVE WS-CZ TO WS-SZ
             MOVE WS-HX TO WS-TX
             MOVE WS-HY TO WS-TY
             MOVE WS-HZ TO WS-TZ
         END-IF
         CALL "PARTICLE-TRAIL-SEND" USING HT-DIM(L-SLOT) WS-SX WS-SY WS-SZ WS-TX WS-TY WS-TZ WS-COLOUR WS-DURATION
     END-PERFORM
     GOBACK.
 END PROGRAM HEART-TRAILS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. HEART-EMIT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY HEARTSTATE.
 01 WS-ROW                 BINARY-LONG.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-REVERSE             BINARY-LONG VALUE 1.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-HALF                BINARY-LONG.
 01 WS-T                   FLOAT-LONG.
 01 WS-PX                  FLOAT-LONG.
 01 WS-PY                  FLOAT-LONG.
 01 WS-PZ                  FLOAT-LONG.
 01 WS-BX                  BINARY-LONG.
 01 WS-BY                  BINARY-LONG.
 01 WS-BZ                  BINARY-LONG.
 01 WS-KEY                 PIC X(48) VALUE "minecraft:block.creaking_heart.hurt".
 01 WS-VOLUME              FLOAT-SHORT VALUE 1.
 01 WS-PITCH               FLOAT-SHORT.
 LINKAGE SECTION.
 01 L-SLOT                 BINARY-LONG.
 PROCEDURE DIVISION USING L-SLOT.
     IF HT-EMITTER(L-SLOT) > 0
*>       Two bursts a tick while the emitter is above 50 (the reverse one first), one after.
         IF HT-EMITTER(L-SLOT) > 50
             CALL "HEART-TRAILS" USING L-SLOT WS-REVERSE WS-ONE
         END-IF
         CALL "HEART-TRAILS" USING L-SLOT WS-ZERO WS-ONE
         IF FUNCTION MOD(HT-EMITTER(L-SLOT), 10) = 0
*>           The hurt effect on the protector: its target is the centre of the creaking's box; the sound plays at the block of target + (heart centre - target) x t.
             CALL "HEART-PROTECTOR" USING L-SLOT WS-ROW
             IF WS-ROW > 0
                 MOVE EN-X(WS-ROW) TO HT-TX(L-SLOT)
                 COMPUTE HT-TY(L-SLOT) = EN-Y(WS-ROW) + 1.35
                 MOVE EN-Z(WS-ROW) TO HT-TZ(L-SLOT)
             END-IF
             COMPUTE WS-T = 0.2 + 0.8 * (100 - HT-EMITTER(L-SLOT)) / 100
             COMPUTE WS-PX = HT-TX(L-SLOT) + (HT-X(L-SLOT) + 0.5 - HT-TX(L-SLOT)) * WS-T
             COMPUTE WS-PY = HT-TY(L-SLOT) + (HT-Y(L-SLOT) + 0.5 - HT-TY(L-SLOT)) * WS-T
             COMPUTE WS-PZ = HT-TZ(L-SLOT) + (HT-Z(L-SLOT) + 0.5 - HT-TZ(L-SLOT)) * WS-T
             COMPUTE WS-BX = FUNCTION INTEGER(WS-PX)
             COMPUTE WS-BY = FUNCTION INTEGER(WS-PY)
             COMPUTE WS-BZ = FUNCTION INTEGER(WS-PZ)
             DIVIDE HT-EMITTER(L-SLOT) BY 2 GIVING WS-HALF
             COMPUTE WS-PITCH = 0.5 + WS-HALF / 100
             CALL "HEART-SOUND" USING HT-DIM(L-SLOT) WS-BX WS-BY WS-BZ WS-KEY WS-VOLUME WS-PITCH
         END-IF
         SUBTRACT 1 FROM HT-EMITTER(L-SLOT)
     END-IF
     GOBACK.
 END PROGRAM HEART-EMIT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. HEART-DIRECTIONS.
*> USING table of six (BINARY-LONG): the Direction ordinals 0 to 5 in the order of Util.shuffledCopy (from the end: swap the element with the one at nextInt(i + 1)).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-SALT                BINARY-LONG VALUE 102.
 01 WS-I                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-T                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIRS.
    05 L-DIR               BINARY-LONG OCCURS 6 TIMES.
 PROCEDURE DIVISION USING L-DIRS.
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 6
         COMPUTE L-DIR(WS-I) = WS-I - 1
     END-PERFORM
     PERFORM VARYING WS-I FROM 6 BY -1 UNTIL WS-I < 2
         CALL "XP-RANDOM" USING WS-SALT WS-I WS-J
         COMPUTE WS-K = WS-J + 1
         MOVE L-DIR(WS-I) TO WS-T
         MOVE L-DIR(WS-K) TO L-DIR(WS-I)
         MOVE WS-T TO L-DIR(WS-K)
     END-PERFORM
     GOBACK.
 END PROGRAM HEART-DIRECTIONS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. HEART-RESIN.
*> USING dim, x, y, z (the heart), found out, rx, ry, rz out: BlockPos.breadthFirstTraversal from the heart (depth 2, at most 64 cells) through pale oak logs; the visitor does nothing at a cell
*> that is not a log (the heart itself) and at a log tries the six neighbours in a fresh random order: air gives a resin_clump with the face looking back at the log, a water source a waterlogged
*> clump with that face, a clump lacking that face gets it; the first success is written (with a block update) and stops the traversal. Any other neighbour is skipped.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CBLOCKS.
 01 WS-QUEUE.
    05 WS-Q                OCCURS 64 TIMES.
       10 WS-QX            BINARY-LONG.
       10 WS-QY            BINARY-LONG.
       10 WS-QZ            BINARY-LONG.
       10 WS-QD            BINARY-LONG.
 01 WS-HEAD                BINARY-LONG.
 01 WS-TAIL                BINARY-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CY                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-CD                  BINARY-LONG.
 01 WS-NX                  BINARY-LONG.
 01 WS-NY                  BINARY-LONG.
 01 WS-NZ                  BINARY-LONG.
 01 WS-DIRS.
    05 WS-DIR              BINARY-LONG OCCURS 6 TIMES.
 01 WS-K                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-D                   BINARY-LONG.
 01 WS-DX                  BINARY-LONG.
 01 WS-DY                  BINARY-LONG.
 01 WS-DZ                  BINARY-LONG.
 01 WS-OPP                 BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-NSTATE              BINARY-LONG.
 01 WS-AXIS                PIC X(32).
 01 WS-LOG                 BINARY-LONG.
 01 WS-SEEN                BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
 01 WS-KEY                 PIC X(48).
 01 WS-LENGTH              BINARY-LONG.
 01 WS-CAND                BINARY-LONG.
 01 WS-EDIT                BINARY-LONG.
 01 WS-KIND                BINARY-LONG.
 01 WS-NAME                PIC X(24).
 01 WS-TEXT                PIC X(32).
 01 WS-RESULT              BINARY-LONG.
 01 WS-MODE                BINARY-LONG.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-CLUMP-KEY           PIC X(112) VALUE "minecraft:resin_clump".
 01 WS-CLUMP-PAIRS         PIC X(160) VALUE SPACES.
 01 WS-CLUMP               BINARY-LONG.
 01 WS-FACE-DATA.
    05 FILLER              PIC X(24) VALUE "down".
    05 FILLER              PIC X(24) VALUE "up".
    05 FILLER              PIC X(24) VALUE "north".
    05 FILLER              PIC X(24) VALUE "south".
    05 FILLER              PIC X(24) VALUE "west".
    05 FILLER              PIC X(24) VALUE "east".
 01 WS-FACES REDEFINES WS-FACE-DATA.
    05 WS-FACE             PIC X(24) OCCURS 6 TIMES.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-FOUND                BINARY-LONG.
 01 L-RX                   BINARY-LONG.
 01 L-RY                   BINARY-LONG.
 01 L-RZ                   BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z L-FOUND L-RX L-RY L-RZ.
     MOVE 0 TO L-FOUND
     CALL "BLOCKS-STATE-OF" USING WS-CLUMP-KEY WS-CLUMP-PAIRS WS-CLUMP
     MOVE 1 TO WS-HEAD WS-TAIL
     MOVE L-X TO WS-QX(1)
     MOVE L-Y TO WS-QY(1)
     MOVE L-Z TO WS-QZ(1)
     MOVE 0 TO WS-QD(1)
     PERFORM UNTIL WS-HEAD > WS-TAIL OR L-FOUND = 1
         MOVE WS-QX(WS-HEAD) TO WS-CX
         MOVE WS-QY(WS-HEAD) TO WS-CY
         MOVE WS-QZ(WS-HEAD) TO WS-CZ
         MOVE WS-QD(WS-HEAD) TO WS-CD
         ADD 1 TO WS-HEAD
         CALL "WORLD-GET-BLOCK" USING L-DIM WS-CX WS-CY WS-CZ WS-STATE
         CALL "HEART-IS-LOG" USING WS-STATE WS-AXIS WS-LOG
         IF WS-LOG = 1
             CALL "HEART-DIRECTIONS" USING WS-DIRS
             PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 6 OR L-FOUND = 1
                 MOVE WS-DIR(WS-K) TO WS-D
                 CALL "BU-DIRECTION" USING WS-D WS-DX WS-DY WS-DZ
                 COMPUTE WS-NX = WS-CX + WS-DX
                 COMPUTE WS-NY = WS-CY + WS-DY
                 COMPUTE WS-NZ = WS-CZ + WS-DZ
*>               The face of the neighbour that looks back at the log: the opposite direction (0 and 1, 2 and 3, 4 and 5 are pairs).
                 COMPUTE WS-OPP = WS-D + 2 - 2 * FUNCTION MOD(WS-D, 2)
                 CALL "WORLD-GET-BLOCK" USING L-DIM WS-NX WS-NY WS-NZ WS-NSTATE
                 MOVE CB-S-BLOCK(WS-NSTATE + 1) TO WS-BLOCK
                 CALL "BE-BLOCK-KEY" USING WS-BLOCK WS-KEY WS-LENGTH
*>               WS-KIND: 1 air, 2 water source, 3 a resin clump, 0 anything else.
                 MOVE 0 TO WS-KIND
                 IF WS-KEY = "minecraft:air" OR "minecraft:cave_air" OR "minecraft:void_air"
                     MOVE 1 TO WS-KIND
                 END-IF
                 IF WS-KEY = "minecraft:water"
                     MOVE "level" TO WS-NAME
                     CALL "BLOCK-STATE-PROP" USING WS-ONE WS-NSTATE WS-NAME WS-TEXT WS-RESULT
                     IF WS-TEXT = "0"
                         MOVE 2 TO WS-KIND
                     END-IF
                 END-IF
                 IF WS-KEY = "minecraft:resin_clump"
                     MOVE 3 TO WS-KIND
                 END-IF
                 IF WS-KIND > 0
                     MOVE WS-CLUMP TO WS-CAND
                     IF WS-KIND = 3
                         MOVE WS-NSTATE TO WS-CAND
                     END-IF
                     MOVE WS-FACE(WS-OPP) TO WS-NAME
                     CALL "BLOCK-STATE-PROP" USING WS-ONE WS-CAND WS-NAME WS-TEXT WS-RESULT
                     IF WS-TEXT NOT = "true"
                         MOVE 2 TO WS-MODE
                         MOVE "true" TO WS-TEXT
                         IF WS-KIND = 2
                             MOVE "waterlogged" TO WS-NAME
                             CALL "BLOCK-STATE-PROP" USING WS-MODE WS-CAND WS-NAME WS-TEXT WS-EDIT
                             MOVE WS-EDIT TO WS-CAND
                         END-IF
                         MOVE WS-FACE(WS-OPP) TO WS-NAME
                         CALL "BLOCK-STATE-PROP" USING WS-MODE WS-CAND WS-NAME WS-TEXT WS-EDIT
                         MOVE WS-EDIT TO WS-CAND
                         CALL "BLOCK-CHANGE" USING L-DIM WS-NX WS-NY WS-NZ WS-CAND
                         MOVE 1 TO L-FOUND
                         MOVE WS-NX TO L-RX
                         MOVE WS-NY TO L-RY
                         MOVE WS-NZ TO L-RZ
                     END-IF
                 END-IF
             END-PERFORM
         END-IF
*>       The heart and the logs of depth 0 and 1 offer their neighbours that are pale oak logs (a cell is queued once, at most 64 cells).
         IF L-FOUND = 0 AND WS-CD < 2
             CALL "HEART-DIRECTIONS" USING WS-DIRS
             PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 6
                 MOVE WS-DIR(WS-K) TO WS-D
                 CALL "BU-DIRECTION" USING WS-D WS-DX WS-DY WS-DZ
                 COMPUTE WS-NX = WS-CX + WS-DX
                 COMPUTE WS-NY = WS-CY + WS-DY
                 COMPUTE WS-NZ = WS-CZ + WS-DZ
                 CALL "WORLD-GET-BLOCK" USING L-DIM WS-NX WS-NY WS-NZ WS-NSTATE
                 CALL "HEART-IS-LOG" USING WS-NSTATE WS-AXIS WS-LOG
                 MOVE 0 TO WS-SEEN
                 PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > WS-TAIL
                     IF WS-QX(WS-J) = WS-NX AND WS-QY(WS-J) = WS-NY AND WS-QZ(WS-J) = WS-NZ
                         MOVE 1 TO WS-SEEN
                     END-IF
                 END-PERFORM
                 IF WS-LOG = 1 AND WS-SEEN = 0 AND WS-TAIL < 64
                     ADD 1 TO WS-TAIL
                     MOVE WS-NX TO WS-QX(WS-TAIL)
                     MOVE WS-NY TO WS-QY(WS-TAIL)
                     MOVE WS-NZ TO WS-QZ(WS-TAIL)
                     COMPUTE WS-QD(WS-TAIL) = WS-CD + 1
                 END-IF
             END-PERFORM
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM HEART-RESIN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. HEART-HURT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CREAKSTATE.
 COPY HEARTSTATE.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-TWENTY              BINARY-LONG VALUE 20.
 01 WS-TWO                 BINARY-LONG VALUE 2.
 01 WS-SALT                BINARY-LONG VALUE 103.
 01 WS-CSLOT               BINARY-LONG.
 01 WS-SLOT                BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-NAME                PIC X(24) VALUE "creaking_heart_state".
 01 WS-TEXT                PIC X(32).
 01 WS-RESULT              BINARY-LONG.
 01 WS-DRAW                BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-FOUND               BINARY-LONG.
 01 WS-RX                  BINARY-LONG.
 01 WS-RY                  BINARY-LONG.
 01 WS-RZ                  BINARY-LONG.
 01 WS-KEY                 PIC X(48) VALUE "minecraft:block.resin.place".
 01 WS-VOLUME              FLOAT-SHORT VALUE 1.
 01 WS-PITCH               FLOAT-SHORT VALUE 1.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
*>   The heart that lists this creaking as its protector; nothing while the emitter runs.
     CALL "CRK-FIND" USING EN-ID(L-ROW) WS-ZERO WS-CSLOT
     CALL "HEART-FIND" USING EN-DIM(L-ROW) CRK-HX(WS-CSLOT) CRK-HY(WS-CSLOT) CRK-HZ(WS-CSLOT) WS-ZERO WS-SLOT
     IF WS-SLOT = 0
         GOBACK
     END-IF
     IF HT-LINK(WS-SLOT) NOT = EN-ID(L-ROW) OR HT-EMITTER(WS-SLOT) > 0
         GOBACK
     END-IF
     CALL "HEART-TRAILS" USING WS-SLOT WS-ZERO WS-TWENTY
*>   An awake heart spreads resin nextIntBetweenInclusive(2, 3) times.
     CALL "WORLD-GET-BLOCK" USING HT-DIM(WS-SLOT) HT-X(WS-SLOT) HT-Y(WS-SLOT) HT-Z(WS-SLOT) WS-STATE
     CALL "BLOCK-STATE-PROP" USING WS-ONE WS-STATE WS-NAME WS-TEXT WS-RESULT
     IF WS-TEXT = "awake"
         CALL "XP-RANDOM" USING WS-SALT WS-TWO WS-DRAW
         COMPUTE WS-N = 2 + WS-DRAW
         PERFORM WS-N TIMES
             CALL "HEART-RESIN" USING HT-DIM(WS-SLOT) HT-X(WS-SLOT) HT-Y(WS-SLOT) HT-Z(WS-SLOT) WS-FOUND WS-RX WS-RY WS-RZ
             IF WS-FOUND = 1
                 CALL "HEART-SOUND" USING HT-DIM(WS-SLOT) WS-RX WS-RY WS-RZ WS-KEY WS-VOLUME WS-PITCH
             END-IF
         END-PERFORM
     END-IF
     MOVE 100 TO HT-EMITTER(WS-SLOT)
     MOVE EN-X(L-ROW) TO HT-TX(WS-SLOT)
     COMPUTE HT-TY(WS-SLOT) = EN-Y(L-ROW) + 1.35
     MOVE EN-Z(L-ROW) TO HT-TZ(WS-SLOT)
     GOBACK.
 END PROGRAM HEART-HURT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CREAKING-REDIRECT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CREAKSTATE.
 COPY RULES.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-SLOT                BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-CAUSE                BINARY-LONG.
 01 L-FLAG                 BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-CAUSE L-FLAG.
*>   A creaking bound to a heart takes no damage itself: the hit is the heart's creakingHurt. Damage that bypasses invulnerability (the void, the command kill) and the heart's own removal
*>   (the generic death of a creaking its heart does not list) go through.
     MOVE 0 TO L-FLAG
     CALL "CRK-FIND" USING EN-ID(L-ROW) WS-ZERO WS-SLOT
     IF WS-SLOT > 0
         IF CRK-HOME(WS-SLOT) = 1 AND L-CAUSE NOT = CAUSE-VOID AND L-CAUSE NOT = CAUSE-COMMAND AND L-CAUSE NOT = CAUSE-GENERIC
             MOVE 1 TO L-FLAG
             CALL "HEART-HURT" USING L-ROW
         END-IF
     END-IF
     GOBACK.
 END PROGRAM CREAKING-REDIRECT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CREAKING-LEASH.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CREAKSTATE.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-SLOT                BINARY-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CY                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-NX                  BINARY-LONG.
 01 WS-NZ                  BINARY-LONG.
 01 WS-NEW                 BINARY-LONG.
 01 WS-OLD                 BINARY-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-HX                   FLOAT-LONG.
 01 L-HZ                   FLOAT-LONG.
 PROCEDURE DIVISION USING L-ROW L-HX L-HZ.
*>   The path evaluator of a creaking with a home treats a cell with a squared distance above 1024 (32 blocks) to the home block as blocked: a step into one that is farther than the cell the
*>   creaking stands in is cancelled (a creaking that stands outside can still walk toward the home).
     CALL "CRK-FIND" USING EN-ID(L-ROW) WS-ZERO WS-SLOT
     IF WS-SLOT > 0
         IF CRK-HOME(WS-SLOT) = 1
             COMPUTE WS-X = EN-X(L-ROW) + L-HX
             COMPUTE WS-Z = EN-Z(L-ROW) + L-HZ
             COMPUTE WS-CX = FUNCTION INTEGER(EN-X(L-ROW)) - CRK-HX(WS-SLOT)
             COMPUTE WS-CY = FUNCTION INTEGER(EN-Y(L-ROW)) - CRK-HY(WS-SLOT)
             COMPUTE WS-CZ = FUNCTION INTEGER(EN-Z(L-ROW)) - CRK-HZ(WS-SLOT)
             COMPUTE WS-NX = FUNCTION INTEGER(WS-X) - CRK-HX(WS-SLOT)
             COMPUTE WS-NZ = FUNCTION INTEGER(WS-Z) - CRK-HZ(WS-SLOT)
             COMPUTE WS-OLD = WS-CX * WS-CX + WS-CY * WS-CY + WS-CZ * WS-CZ
             COMPUTE WS-NEW = WS-NX * WS-NX + WS-CY * WS-CY + WS-NZ * WS-NZ
             IF WS-NEW > 1024 AND WS-NEW > WS-OLD
                 MOVE 0 TO L-HX L-HZ
             END-IF
         END-IF
     END-IF
     GOBACK.
 END PROGRAM CREAKING-LEASH.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. HEART-SWEEP.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY HEARTSTATE.
 01 WS-I                   BINARY-LONG.
 01 WS-INDEX               BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 PROCEDURE DIVISION.
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > HT-MAX
         IF HT-USED(WS-I) = 1
             CALL "BE-FIND" USING HT-DIM(WS-I) HT-X(WS-I) HT-Y(WS-I) HT-Z(WS-I) WS-INDEX
             IF WS-INDEX = 0
                 CALL "HEART-PROTECTOR" USING WS-I WS-ROW
                 IF WS-ROW > 0
                     CALL "CREAKING-TEAR-DOWN" USING WS-ROW
                 END-IF
                 INITIALIZE HT-ENTRY(WS-I)
             END-IF
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM HEART-SWEEP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. HEART-RUN.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CBLOCKS.
 COPY BESTATE.
 COPY HEARTSTATE.
 01 WS-DIM                 BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
 01 WS-NAME-AXIS           PIC X(24) VALUE "axis".
 01 WS-NAME-STATE          PIC X(24) VALUE "creaking_heart_state".
 01 WS-AXIS                PIC X(32).
 01 WS-TEXT                PIC X(32).
 01 WS-NEW-TEXT            PIC X(32).
 01 WS-RESULT              BINARY-LONG.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-TWO                 BINARY-LONG VALUE 2.
 01 WS-LOGS                BINARY-LONG.
 01 WS-ACTIVE              BINARY-LONG.
 01 WS-SLOT                BINARY-LONG.
 01 WS-PREV                BINARY-LONG.
 01 WS-PERSISTENT          BINARY-LONG VALUE 0.
 01 WS-NEW                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-INDEX                BINARY-LONG.
 PROCEDURE DIVISION USING L-INDEX.
     MOVE BE-DIM(L-INDEX) TO WS-DIM
     MOVE BE-X(L-INDEX) TO WS-X
     MOVE BE-Y(L-INDEX) TO WS-Y
     MOVE BE-Z(L-INDEX) TO WS-Z
     CALL "WORLD-GET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-STATE
     CALL "BLOCK-STATE-PROP" USING WS-ONE WS-STATE WS-NAME-AXIS WS-AXIS WS-RESULT
     CALL "BLOCK-STATE-PROP" USING WS-ONE WS-STATE WS-NAME-STATE WS-TEXT WS-RESULT
     CALL "HEART-LOGS" USING WS-DIM WS-X WS-Y WS-Z WS-AXIS WS-LOGS
     CALL "CREAKING-ACTIVE-ATTR" USING WS-DIM CW-TIME WS-ACTIVE
*>   An uprooted heart has no ticker; the block's own update (the scheduled tick that updateShape asks for) makes it awake or dormant once its logs are there.
     IF WS-TEXT = "uprooted"
         IF WS-LOGS = 1
             MOVE "dormant" TO WS-NEW-TEXT
             IF WS-ACTIVE = 1
                 MOVE "awake" TO WS-NEW-TEXT
             END-IF
             CALL "BLOCK-STATE-PROP" USING WS-TWO WS-STATE WS-NAME-STATE WS-NEW-TEXT WS-NEW
             CALL "BLOCK-CHANGE" USING WS-DIM WS-X WS-Y WS-Z WS-NEW
         END-IF
         GOBACK
     END-IF
     CALL "HEART-FIND" USING WS-DIM WS-X WS-Y WS-Z WS-ONE WS-SLOT
     IF WS-SLOT = 0
         GOBACK
     END-IF
     MOVE CB-S-BLOCK(WS-STATE + 1) TO WS-BLOCK
     CALL "HEART-SIGNAL" USING WS-SLOT WS-BLOCK
     CALL "HEART-EMIT" USING WS-SLOT
     MOVE HT-TICKER(WS-SLOT) TO WS-PREV
     CALL "HEART-TICK" USING WS-SLOT WS-LOGS CW-TIME WS-PERSISTENT
*>   The state update ran (the ticker was below 0): its state is written to the block when it differs.
     IF WS-PREV < 0
         EVALUATE HT-STATE(WS-SLOT)
             WHEN 0
                 MOVE "uprooted" TO WS-NEW-TEXT
             WHEN 1
                 MOVE "dormant" TO WS-NEW-TEXT
             WHEN OTHER
                 MOVE "awake" TO WS-NEW-TEXT
         END-EVALUATE
         IF WS-NEW-TEXT NOT = WS-TEXT
             CALL "BLOCK-STATE-PROP" USING WS-TWO WS-STATE WS-NAME-STATE WS-NEW-TEXT WS-NEW
             CALL "BLOCK-CHANGE" USING WS-DIM WS-X WS-Y WS-Z WS-NEW
         END-IF
     END-IF
     GOBACK.
 END PROGRAM HEART-RUN.
