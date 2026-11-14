*> Block-break crack overlay (12 §4): BREAK-OVERLAY-SET keeps the break progress of each breaker (Block
*> Destruction packets, and the local player's own break), BREAK-OVERLAY-MESH builds the frame's crack mesh.
*> One entry per breaker entity id; a stage outside 0 to 9 removes the breaker's entry; a new position
*> replaces it; an entry not updated for 20 s (400 ticks) is dropped; of several breakers on one block the
*> highest stage is drawn; only blocks within 32 blocks of the camera. The mesh is the six faces of the
*> block, each carrying the whole image of the stage (block atlas sprite minecraft:block/destroy_stage_N),
*> eye-relative, drawn with the crumbling pipeline (2 x source x destination, 12 §4.3).

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BREAK-OVERLAY-SET.
*> USING CLIENT-STATE, breaker entity id, x, y, z, stage.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-I                   BINARY-LONG.
 01 WS-AT                  BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-ENTITY               BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-STAGE                BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-ENTITY L-X L-Y L-Z L-STAGE.
     MOVE 0 TO WS-AT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > BDS-COUNT
         IF BDS-ENTITY(WS-I) = L-ENTITY
             MOVE WS-I TO WS-AT
         END-IF
     END-PERFORM
     IF L-STAGE < 0 OR L-STAGE > 9
         IF WS-AT > 0
*>           Remove: the last entry takes its place.
             MOVE BDS-ENTRY(BDS-COUNT) TO BDS-ENTRY(WS-AT)
             SUBTRACT 1 FROM BDS-COUNT
         END-IF
         GOBACK
     END-IF
     IF WS-AT = 0
         IF BDS-COUNT < 16
             ADD 1 TO BDS-COUNT
         END-IF
         MOVE BDS-COUNT TO WS-AT
     END-IF
     MOVE L-ENTITY TO BDS-ENTITY(WS-AT)
     MOVE L-X TO BDS-X(WS-AT)
     MOVE L-Y TO BDS-Y(WS-AT)
     MOVE L-Z TO BDS-Z(WS-AT)
     MOVE L-STAGE TO BDS-STAGE(WS-AT)
     MOVE CL-NOW-MS TO BDS-AT-MS(WS-AT)
     GOBACK.
 END PROGRAM BREAK-OVERLAY-SET.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BREAK-OVERLAY-MESH.
*> USING CLIENT-STATE, eye (3 FLOAT-LONG): fills RL-BO-VERTEX and RL-BO-COUNT (36 vertices a block).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-I                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-STAGE               BINARY-LONG.
 01 WS-NONE                BINARY-LONG VALUE 255.
 01 WS-SKIP                BINARY-LONG.
 01 WS-ENTITY              BINARY-LONG.
 01 WS-BX                  BINARY-LONG.
 01 WS-BY                  BINARY-LONG.
 01 WS-BZ                  BINARY-LONG.
 01 WS-DX                  FLOAT-LONG.
 01 WS-DY                  FLOAT-LONG.
 01 WS-DZ                  FLOAT-LONG.
 01 WS-ID                  PIC X(80).
 01 WS-ID-LENGTH           BINARY-LONG VALUE 31.
 01 WS-DIGIT               PIC 9.
 01 WS-SPRITE              BINARY-LONG.
 01 WS-A                   BINARY-LONG.
 01 WS-SIDE                BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-C                   BINARY-LONG.
 01 WS-U-AXIS              BINARY-LONG.
 01 WS-V-AXIS              BINARY-LONG.
 01 WS-LO                  FLOAT-LONG VALUE -0.002.
 01 WS-HI                  FLOAT-LONG VALUE 1.002.
 01 WS-P                   FLOAT-LONG OCCURS 3 TIMES.
 01 WS-BLOCK               FLOAT-LONG OCCURS 3 TIMES.
 01 WS-CORNERS             PIC X(6) VALUE "123134".
 01 WS-S16A                FLOAT-SHORT.
 01 WS-S16B                FLOAT-SHORT.
 01 WS-TU                  FLOAT-SHORT.
 01 WS-TV                  FLOAT-SHORT.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-EYE-TABLE.
    05 L-EYE               FLOAT-LONG OCCURS 3 TIMES.
 PROCEDURE DIVISION USING CLIENT-STATE L-EYE-TABLE.
*>   The local player's own break: its stage is int(progress * 10), none while no progress or no break.
     MOVE PL-ENTITY-ID TO WS-ENTITY
     MOVE WS-NONE TO WS-STAGE
     IF CT-BREAKING = 1 AND CT-BREAK-MS > 0 AND CL-NOW-MS > CT-BREAK-START
         COMPUTE WS-STAGE = FUNCTION MIN(9, (CL-NOW-MS - CT-BREAK-START) * 10 / CT-BREAK-MS)
     END-IF
     CALL "BREAK-OVERLAY-SET" USING CLIENT-STATE WS-ENTITY CT-BREAK-X CT-BREAK-Y CT-BREAK-Z WS-STAGE
*>   Expired entries go (the last one takes the place, so the same index is looked at again).
     MOVE 1 TO WS-I
     PERFORM UNTIL WS-I > BDS-COUNT
         IF CL-NOW-MS - BDS-AT-MS(WS-I) > 20000
             MOVE BDS-ENTRY(BDS-COUNT) TO BDS-ENTRY(WS-I)
             SUBTRACT 1 FROM BDS-COUNT
         ELSE
             ADD 1 TO WS-I
         END-IF
     END-PERFORM
     MOVE 0 TO RL-BO-COUNT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > BDS-COUNT
         MOVE 0 TO WS-SKIP
         PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > BDS-COUNT
             IF WS-J NOT = WS-I AND BDS-X(WS-J) = BDS-X(WS-I) AND BDS-Y(WS-J) = BDS-Y(WS-I)
                     AND BDS-Z(WS-J) = BDS-Z(WS-I)
                 IF BDS-STAGE(WS-J) > BDS-STAGE(WS-I)
                         OR (BDS-STAGE(WS-J) = BDS-STAGE(WS-I) AND WS-J < WS-I)
                     MOVE 1 TO WS-SKIP
                 END-IF
             END-IF
         END-PERFORM
         COMPUTE WS-DX = BDS-X(WS-I) + 0.5 - L-EYE(1)
         COMPUTE WS-DY = BDS-Y(WS-I) + 0.5 - L-EYE(2)
         COMPUTE WS-DZ = BDS-Z(WS-I) + 0.5 - L-EYE(3)
         IF WS-DX ** 2 + WS-DY ** 2 + WS-DZ ** 2 > 1024
             MOVE 1 TO WS-SKIP
         END-IF
         MOVE 0 TO WS-SPRITE
         IF WS-SKIP = 0
             MOVE BDS-STAGE(WS-I) TO WS-DIGIT
             MOVE SPACES TO WS-ID
             STRING "minecraft:block/destroy_stage_" WS-DIGIT DELIMITED BY SIZE INTO WS-ID
             CALL "ATLAS-FIND" USING CLIENT-STATE WS-ID WS-ID-LENGTH WS-SPRITE
         END-IF
         IF WS-SPRITE > 0
             MOVE BDS-X(WS-I) TO WS-BLOCK(1)
             MOVE BDS-Y(WS-I) TO WS-BLOCK(2)
             MOVE BDS-Z(WS-I) TO WS-BLOCK(3)
             PERFORM VARYING WS-A FROM 1 BY 1 UNTIL WS-A > 3
                 COMPUTE WS-U-AXIS = FUNCTION MOD(WS-A, 3) + 1
                 COMPUTE WS-V-AXIS = FUNCTION MOD(WS-A + 1, 3) + 1
                 PERFORM VARYING WS-SIDE FROM 0 BY 1 UNTIL WS-SIDE > 1
                     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 6
                         MOVE FUNCTION NUMVAL(WS-CORNERS(WS-K:1)) TO WS-C
                         COMPUTE WS-P(WS-A) = WS-LO + WS-SIDE * (WS-HI - WS-LO)
                         MOVE WS-LO TO WS-P(WS-U-AXIS)
                         MOVE 0 TO WS-S16A
                         IF WS-C = 2 OR WS-C = 3
                             MOVE WS-HI TO WS-P(WS-U-AXIS)
                             MOVE 16 TO WS-S16A
                         END-IF
                         MOVE WS-LO TO WS-P(WS-V-AXIS)
                         MOVE 0 TO WS-S16B
                         IF WS-C >= 3
                             MOVE WS-HI TO WS-P(WS-V-AXIS)
                             MOVE 16 TO WS-S16B
                         END-IF
                         CALL "ATLAS-UV" USING CLIENT-STATE WS-SPRITE WS-S16A WS-S16B WS-TU WS-TV
                         ADD 1 TO RL-BO-COUNT
                         COMPUTE RL-BO-X(RL-BO-COUNT) = WS-BLOCK(1) + WS-P(1) - L-EYE(1)
                         COMPUTE RL-BO-Y(RL-BO-COUNT) = WS-BLOCK(2) + WS-P(2) - L-EYE(2)
                         COMPUTE RL-BO-Z(RL-BO-COUNT) = WS-BLOCK(3) + WS-P(3) - L-EYE(3)
                         MOVE WS-TU TO RL-BO-U(RL-BO-COUNT)
                         MOVE WS-TV TO RL-BO-V(RL-BO-COUNT)
                         MOVE 1 TO RL-BO-B(RL-BO-COUNT)
                         MOVE 1 TO RL-BO-A(RL-BO-COUNT)
                         MOVE 0 TO RL-BO-SKY(RL-BO-COUNT)
                         MOVE 1 TO RL-BO-R(RL-BO-COUNT) RL-BO-G(RL-BO-COUNT) RL-BO-BLUE(RL-BO-COUNT)
                     END-PERFORM
                 END-PERFORM
             END-PERFORM
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM BREAK-OVERLAY-MESH.
