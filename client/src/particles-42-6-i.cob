*> Particles part 6 (docs/protocol/42-particles-6-emitters-blocks.md) section 9: server-sourced particle semantics (how the block-driven
*> `sendParticles` packets arrive and are expanded). The packet builders of 8.2, 8.4 and 8.5 are in particles-42-6-h.cob.
*>
*> Entry points for the integrator (inputs):
*>   P6-HANDLE-PACKET P6-PACKET P6-EMITS: ClientPacketListener.handleParticleEvent. count 0: one particle at the position with velocity speed * distance
*>     per axis; count > 0, ALTERNATIVE (1): count particles, offset rd * distance (draws x, y, z), velocity = the speeds; ALTERNATIVE_WITH_SPEED (2):
*>     the velocity times an extra rd per axis (three more draws, after the offsets); DEFAULT (0): offset rg * distance then velocity rg * speed (six
*>     Gaussian draws per particle). Rows carry the packet's state (EM-STATE) and colour (EM-COLOR). The limiter tests of 42-1 7.1 are the caller's.
*>   P6-CATALYST-PACKET P(3 integers) P6-PACKET: the sculk catalyst bloom of 4.5: `sculk_soul` count 2 at (X + 0.5, Y + 1.15, Z + 0.5), distances (0.2, 0, 0.2).
*>   P6-CREAKING-OPTIONS P6-EMITS active colour(out) duration(out): the `trail` options of the creaking heart: colour 16545810 (0xFC7812) when active, else
*>     6250335 (0x5F5F5F); duration ri(40) + 10 (one draw). The start inside the creaking's box and the target in the heart cell are 42-5 3.10.
*>   P6-EYEBLOSSOM-DURATION P6-EMITS duration(out): s = 0.5 + rd (one draw), duration int(20 * s).

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P6-HANDLE-PACKET.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-R                   FLOAT-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-A                   BINARY-LONG.
 01 WS-PV.
    05 WS-V                FLOAT-LONG OCCURS 6 TIMES.
 LINKAGE SECTION.
 COPY CLP6PK.
 COPY CLP6EM.
 PROCEDURE DIVISION USING P6-PACKET P6-EMITS.
     MOVE 0 TO EM-COUNT EM-CUR EM-SOUND-COUNT
     IF PK-COUNT = 0
         MOVE PK-X TO WS-V(1)
         MOVE PK-Y TO WS-V(2)
         MOVE PK-Z TO WS-V(3)
         PERFORM VARYING WS-A FROM 1 BY 1 UNTIL WS-A > 3
             COMPUTE WS-V(WS-A + 3) = PK-SPEED(WS-A) * PK-DIST(WS-A)
         END-PERFORM
         CALL "P6-EMIT" USING P6-EMITS PK-NAME WS-PV
         CALL "P6-PACKET-OPTION" USING P6-EMITS P6-PACKET
     END-IF
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > PK-COUNT
         PERFORM VARYING WS-A FROM 1 BY 1 UNTIL WS-A > 3
             CALL "P6-DRAW" USING P6-EMITS WS-R
             COMPUTE WS-V(WS-A) = WS-R * PK-DIST(WS-A)
         END-PERFORM
         PERFORM VARYING WS-A FROM 1 BY 1 UNTIL WS-A > 3
             EVALUATE PK-MODE
                 WHEN 1
                     MOVE PK-SPEED(WS-A) TO WS-V(WS-A + 3)
                 WHEN 2
                     CALL "P6-DRAW" USING P6-EMITS WS-R
                     COMPUTE WS-V(WS-A + 3) = PK-SPEED(WS-A) * WS-R
                 WHEN OTHER
                     CALL "P6-DRAW" USING P6-EMITS WS-R
                     COMPUTE WS-V(WS-A + 3) = WS-R * PK-SPEED(WS-A)
             END-EVALUATE
         END-PERFORM
         COMPUTE WS-V(1) = PK-X + WS-V(1)
         COMPUTE WS-V(2) = PK-Y + WS-V(2)
         COMPUTE WS-V(3) = PK-Z + WS-V(3)
         CALL "P6-EMIT" USING P6-EMITS PK-NAME WS-PV
         CALL "P6-PACKET-OPTION" USING P6-EMITS P6-PACKET
     END-PERFORM
     GOBACK.
 END PROGRAM P6-HANDLE-PACKET.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P6-PACKET-OPTION.
*> Copy the packet's colour and state to the last emitted row: USING emits, packet.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-ZERO-S              FLOAT-LONG VALUE 0.
 LINKAGE SECTION.
 COPY CLP6EM.
 COPY CLP6PK.
 PROCEDURE DIVISION USING P6-EMITS P6-PACKET.
     CALL "P6-EMIT-OPTION" USING P6-EMITS PK-COLOR WS-ZERO-S PK-STATE
     GOBACK.
 END PROGRAM P6-PACKET-OPTION.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P6-CATALYST-PACKET.
 DATA DIVISION.
 LINKAGE SECTION.
 COPY CLP6ARG.
 COPY CLP6PK.
 PROCEDURE DIVISION USING L-P P6-PACKET.
     MOVE "sculk_soul" TO PK-NAME
     COMPUTE PK-X = L-PP(1) + 0.5
     COMPUTE PK-Y = L-PP(2) + 1.15
     COMPUTE PK-Z = L-PP(3) + 0.5
     MOVE 2 TO PK-COUNT
     MOVE 0.2 TO PK-DIST(1)
     MOVE 0 TO PK-DIST(2)
     MOVE 0.2 TO PK-DIST(3)
     MOVE 0 TO PK-SPEED(1) PK-SPEED(2) PK-SPEED(3)
     MOVE 0 TO PK-MODE PK-STATE PK-COLOR PK-DURATION
     GOBACK.
 END PROGRAM P6-CATALYST-PACKET.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P6-CREAKING-OPTIONS.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-R                   FLOAT-LONG.
 LINKAGE SECTION.
 COPY CLP6EM.
 01 L-ACTIVE               BINARY-LONG.
 01 L-COLOR                BINARY-DOUBLE.
 01 L-DURATION             BINARY-LONG.
 PROCEDURE DIVISION USING P6-EMITS L-ACTIVE L-COLOR L-DURATION.
     IF L-ACTIVE NOT = 0
         MOVE 16545810 TO L-COLOR
     ELSE
         MOVE 6250335 TO L-COLOR
     END-IF
     CALL "P6-DRAW" USING P6-EMITS WS-R
     COMPUTE L-DURATION = FUNCTION INTEGER-PART(WS-R * 40) + 10
     GOBACK.
 END PROGRAM P6-CREAKING-OPTIONS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P6-EYEBLOSSOM-DURATION.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-R                   FLOAT-LONG.
 LINKAGE SECTION.
 COPY CLP6EM.
 01 L-DURATION             BINARY-LONG.
 PROCEDURE DIVISION USING P6-EMITS L-DURATION.
     CALL "P6-DRAW" USING P6-EMITS WS-R
     COMPUTE L-DURATION = FUNCTION INTEGER-PART(20 * (0.5 + WS-R))
     GOBACK.
 END PROGRAM P6-EYEBLOSSOM-DURATION.
