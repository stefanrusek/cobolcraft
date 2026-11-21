*> Particles part 6 (docs/protocol/42-particles-6-emitters-blocks.md) sections 7 and 8: block break, hit and crack, and the entity-on-block
*> particles. Draws and output rows are those of client/copy/CLP6EM.cpy (see particles-42-6-b.cob); the server-routed packets are in
*> particles-42-6-h.cob.
*>
*> Entry points for the integrator (inputs):
*>   P6-DESTROY P(3 integers) state box-count BOXES(16 boxes of six floats minX minY minZ maxX maxY maxZ) P6-EMITS: 7.1 addDestroyBlockEffect for
*>     the block's outline shape (the caller has checked: not air, shouldSpawnTerrainParticles). Rows are `block` with EM-STATE = state.
*>   P6-BLOCK-EFFECT class(PIC X(24)) P PROPS P6-EMITS: class and PROPS (floats in thousandths):
*>     crack          1 state, 2 face (0 DOWN, 1 UP, 2 NORTH, 3 SOUTH, 4 WEST, 5 EAST), 3-8 outline bounds minX minY minZ maxX maxY maxZ (7.2); one row
*>                    with velocity 0; EM-SCALE 0.6 is the scale(0.6) of the crack particle, whose setPower(0.2) the particle itself applies (42-4 3.7)
*>     sprint         1 state of the block under the entity (P is its position), 2-4 entity x y z, 5 width, 6-7 deltaMovement x and z,
*>                    8-9 the entity's own block x and z (8.1; the caller has checked canSpawnSprintParticle and the render shape)
*>     honey          1 state, 2-4 entity x y z, 5 kind (0 slide: 5 particles, 1 jump: 10) (8.3)
*>     decorated_pot  none: seven dust_plume rows at (X + 0.5, Y + 1.2, Z + 0.5) as the client expands the packet of 8.5 (count 7, no spread, no speed)

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P6-DESTROY.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-N                   PIC X(40) VALUE "block".
 01 WS-ZERO-C              BINARY-DOUBLE VALUE 0.
 01 WS-ZERO-S              FLOAT-LONG VALUE 0.
 01 WS-B                   BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-A                   BINARY-LONG.
 01 WS-S                   FLOAT-LONG OCCURS 3 TIMES.
 01 WS-CNT                 BINARY-LONG OCCURS 3 TIMES.
 01 WS-Q                   FLOAT-LONG.
 01 WS-F                   FLOAT-LONG OCCURS 3 TIMES.
 01 WS-PV.
    05 WS-V                FLOAT-LONG OCCURS 6 TIMES.
 LINKAGE SECTION.
 COPY CLP6ARG.
 01 L-STATE                BINARY-LONG.
 01 L-COUNT                BINARY-LONG.
 01 L-BOXES.
    05 L-BOX               OCCURS 16 TIMES.
       10 L-BX             FLOAT-LONG OCCURS 6 TIMES.
 COPY CLP6EM.
 PROCEDURE DIVISION USING L-P L-STATE L-COUNT L-BOXES P6-EMITS.
     MOVE 0 TO EM-COUNT EM-CUR EM-SOUND-COUNT
     PERFORM VARYING WS-B FROM 1 BY 1 UNTIL WS-B > L-COUNT
         PERFORM VARYING WS-A FROM 1 BY 1 UNTIL WS-A > 3
             COMPUTE WS-S(WS-A) = L-BX(WS-B, WS-A + 3) - L-BX(WS-B, WS-A)
             IF WS-S(WS-A) > 1
                 MOVE 1 TO WS-S(WS-A)
             END-IF
             COMPUTE WS-Q = WS-S(WS-A) / 0.25
             COMPUTE WS-CNT(WS-A) = FUNCTION INTEGER-PART(WS-Q)
             IF WS-Q > WS-CNT(WS-A)
                 ADD 1 TO WS-CNT(WS-A)
             END-IF
             IF WS-CNT(WS-A) < 2
                 MOVE 2 TO WS-CNT(WS-A)
             END-IF
         END-PERFORM
         PERFORM VARYING WS-I FROM 0 BY 1 UNTIL WS-I >= WS-CNT(1)
             PERFORM VARYING WS-J FROM 0 BY 1 UNTIL WS-J >= WS-CNT(2)
                 PERFORM VARYING WS-K FROM 0 BY 1 UNTIL WS-K >= WS-CNT(3)
                     COMPUTE WS-F(1) = (WS-I + 0.5) / WS-CNT(1)
                     COMPUTE WS-F(2) = (WS-J + 0.5) / WS-CNT(2)
                     COMPUTE WS-F(3) = (WS-K + 0.5) / WS-CNT(3)
                     PERFORM VARYING WS-A FROM 1 BY 1 UNTIL WS-A > 3
                         COMPUTE WS-V(WS-A) = L-PP(WS-A) + WS-F(WS-A) * WS-S(WS-A) + L-BX(WS-B, WS-A)
                         COMPUTE WS-V(WS-A + 3) = WS-F(WS-A) - 0.5
                     END-PERFORM
                     CALL "P6-EMIT" USING P6-EMITS WS-N WS-PV
                     CALL "P6-EMIT-OPTION" USING P6-EMITS WS-ZERO-C WS-ZERO-S L-STATE
                 END-PERFORM
             END-PERFORM
         END-PERFORM
     END-PERFORM
     GOBACK.
 END PROGRAM P6-DESTROY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P6-CRACK.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-N                   PIC X(40) VALUE "block".
 01 WS-ZERO-C              BINARY-DOUBLE VALUE 0.
 01 WS-SCALE               FLOAT-LONG VALUE 0.6.
 01 WS-R                   FLOAT-LONG.
 01 WS-A                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-B                   FLOAT-LONG OCCURS 6 TIMES.
 01 WS-PV.
    05 WS-V                FLOAT-LONG OCCURS 6 TIMES.
 LINKAGE SECTION.
 COPY CLP6ARG.
 COPY CLP6EM.
 PROCEDURE DIVISION USING L-P L-PROPS P6-EMITS.
     INITIALIZE WS-PV
     PERFORM VARYING WS-A FROM 1 BY 1 UNTIL WS-A > 6
         COMPUTE WS-K = WS-A + 2
         COMPUTE WS-B(WS-A) = L-PR(WS-K) / 1000
     END-PERFORM
     PERFORM VARYING WS-A FROM 1 BY 1 UNTIL WS-A > 3
         CALL "P6-DRAW" USING P6-EMITS WS-R
         COMPUTE WS-V(WS-A) = L-PP(WS-A) + WS-R * ((WS-B(WS-A + 3) - WS-B(WS-A)) - 0.2) + 0.1 + WS-B(WS-A)
     END-PERFORM
     EVALUATE L-PR(2)
         WHEN 0
             COMPUTE WS-V(2) = L-PP(2) + WS-B(2) - 0.1
         WHEN 1
             COMPUTE WS-V(2) = L-PP(2) + WS-B(5) + 0.1
         WHEN 2
             COMPUTE WS-V(3) = L-PP(3) + WS-B(3) - 0.1
         WHEN 3
             COMPUTE WS-V(3) = L-PP(3) + WS-B(6) + 0.1
         WHEN 4
             COMPUTE WS-V(1) = L-PP(1) + WS-B(1) - 0.1
         WHEN OTHER
             COMPUTE WS-V(1) = L-PP(1) + WS-B(4) + 0.1
     END-EVALUATE
     CALL "P6-EMIT" USING P6-EMITS WS-N WS-PV
     CALL "P6-EMIT-OPTION" USING P6-EMITS WS-ZERO-C WS-SCALE L-PR(1)
     GOBACK.
 END PROGRAM P6-CRACK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P6-SPRINT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-N                   PIC X(40) VALUE "block".
 01 WS-ZERO-C              BINARY-DOUBLE VALUE 0.
 01 WS-ZERO-S              FLOAT-LONG VALUE 0.
 01 WS-R                   FLOAT-LONG.
 01 WS-W                   FLOAT-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-PV.
    05 WS-V                FLOAT-LONG OCCURS 6 TIMES.
 LINKAGE SECTION.
 COPY CLP6ARG.
 COPY CLP6EM.
 PROCEDURE DIVISION USING L-P L-PROPS P6-EMITS.
     INITIALIZE WS-PV
     COMPUTE WS-W = L-PR(5) / 1000
     CALL "P6-DRAW" USING P6-EMITS WS-R
     COMPUTE WS-X = L-PR(2) / 1000 + (WS-R - 0.5) * WS-W
     CALL "P6-DRAW" USING P6-EMITS WS-R
     COMPUTE WS-Z = L-PR(4) / 1000 + (WS-R - 0.5) * WS-W
     IF L-PR(8) NOT = L-PP(1)
         IF WS-X < L-PP(1)
             MOVE L-PP(1) TO WS-X
         END-IF
         IF WS-X > L-PP(1) + 1
             COMPUTE WS-X = L-PP(1) + 1
         END-IF
     END-IF
     IF L-PR(9) NOT = L-PP(3)
         IF WS-Z < L-PP(3)
             MOVE L-PP(3) TO WS-Z
         END-IF
         IF WS-Z > L-PP(3) + 1
             COMPUTE WS-Z = L-PP(3) + 1
         END-IF
     END-IF
     MOVE WS-X TO WS-V(1)
     COMPUTE WS-V(2) = L-PR(3) / 1000 + 0.1
     MOVE WS-Z TO WS-V(3)
     COMPUTE WS-V(4) = L-PR(6) / 1000 * -4
     MOVE 1.5 TO WS-V(5)
     COMPUTE WS-V(6) = L-PR(7) / 1000 * -4
     CALL "P6-EMIT" USING P6-EMITS WS-N WS-PV
     CALL "P6-EMIT-OPTION" USING P6-EMITS WS-ZERO-C WS-ZERO-S L-PR(1)
     GOBACK.
 END PROGRAM P6-SPRINT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P6-HONEY.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-N                   PIC X(40) VALUE "block".
 01 WS-ZERO-C              BINARY-DOUBLE VALUE 0.
 01 WS-ZERO-S              FLOAT-LONG VALUE 0.
 01 WS-COUNT               BINARY-LONG.
 01 WS-PV.
    05 WS-V                FLOAT-LONG OCCURS 6 TIMES.
 LINKAGE SECTION.
 COPY CLP6ARG.
 COPY CLP6EM.
 PROCEDURE DIVISION USING L-P L-PROPS P6-EMITS.
     INITIALIZE WS-PV
     MOVE 5 TO WS-COUNT
     IF L-PR(5) NOT = 0
         MOVE 10 TO WS-COUNT
     END-IF
     COMPUTE WS-V(1) = L-PR(2) / 1000
     COMPUTE WS-V(2) = L-PR(3) / 1000
     COMPUTE WS-V(3) = L-PR(4) / 1000
     PERFORM WS-COUNT TIMES
         CALL "P6-EMIT" USING P6-EMITS WS-N WS-PV
         CALL "P6-EMIT-OPTION" USING P6-EMITS WS-ZERO-C WS-ZERO-S L-PR(1)
     END-PERFORM
     GOBACK.
 END PROGRAM P6-HONEY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P6-POT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-N                   PIC X(40) VALUE "dust_plume".
 01 WS-PV.
    05 WS-V                FLOAT-LONG OCCURS 6 TIMES.
 LINKAGE SECTION.
 COPY CLP6ARG.
 COPY CLP6EM.
 PROCEDURE DIVISION USING L-P L-PROPS P6-EMITS.
     INITIALIZE WS-PV
     COMPUTE WS-V(1) = L-PP(1) + 0.5
     COMPUTE WS-V(2) = L-PP(2) + 1.2
     COMPUTE WS-V(3) = L-PP(3) + 0.5
     PERFORM 7 TIMES
         CALL "P6-EMIT" USING P6-EMITS WS-N WS-PV
     END-PERFORM
     GOBACK.
 END PROGRAM P6-POT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P6-BLOCK-EFFECT.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-CLASS                PIC X(24).
 COPY CLP6ARG.
 COPY CLP6EM.
 PROCEDURE DIVISION USING L-CLASS L-P L-PROPS P6-EMITS.
     MOVE 0 TO EM-COUNT EM-CUR EM-SOUND-COUNT
     EVALUATE L-CLASS
         WHEN "crack"
             CALL "P6-CRACK" USING L-P L-PROPS P6-EMITS
         WHEN "sprint"
             CALL "P6-SPRINT" USING L-P L-PROPS P6-EMITS
         WHEN "honey"
             CALL "P6-HONEY" USING L-P L-PROPS P6-EMITS
         WHEN "decorated_pot"
             CALL "P6-POT" USING L-P L-PROPS P6-EMITS
     END-EVALUATE
     GOBACK.
 END PROGRAM P6-BLOCK-EFFECT.
