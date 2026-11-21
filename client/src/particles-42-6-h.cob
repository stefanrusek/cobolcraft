*> Particles part 6 (docs/protocol/42-particles-6-emitters-blocks.md) sections 8.2, 8.4, 8.5 and 9: the packets the server routes for block-driven
*> particles (record client/copy/CLP6PK.cpy) and the client's expansion of a Level Particles packet.
*>
*> Entry points for the integrator (inputs):
*>   P6-LANDING fall-distance safe-fall-distance entity(x y z floats) entity-block(x z) supporting-block(x z) state send(out) P6-PACKET: 8.2.
*>   P6-POWDER-SNOW P6-EMITS entity-x entity-z P(3 integers: the block the entity stands in) P(unused) send(out) P6-PACKET: 8.4.
*>   P6-POT-PACKET P(3 integers) P6-PACKET: 8.5.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P6-LANDING.
*> 8.2: power = max(0, floor(fall + 1e-6 - safe)); none when power is 0 (send 0). The point moves onto the supporting block's edge when its
*> horizontal position differs from the entity's block: m = max(|dx|, |dz|), x = bx + 0.5 + (dx / m) * 0.5. amount = min(0.2f + power / 15, 2.5),
*> count = int(150 * amount); a `block` packet with the state, no spread, speed 0.15f, randomisation DEFAULT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-POWER               BINARY-LONG.
 01 WS-DX                  FLOAT-LONG.
 01 WS-DZ                  FLOAT-LONG.
 01 WS-M                   FLOAT-LONG.
 01 WS-AMOUNT              FLOAT-LONG.
 01 WS-T                   FLOAT-LONG.
 LINKAGE SECTION.
 01 L-FALL                 FLOAT-LONG.
 01 L-SAFE                 FLOAT-LONG.
 01 L-ENTITY.
    05 L-E                 FLOAT-LONG OCCURS 3 TIMES.
 01 L-EBLOCK.
    05 L-EB                BINARY-LONG OCCURS 2 TIMES.
 01 L-SBLOCK.
    05 L-SB                BINARY-LONG OCCURS 2 TIMES.
 01 L-STATE                BINARY-LONG.
 01 L-SEND                 BINARY-LONG.
 COPY CLP6PK.
 PROCEDURE DIVISION USING L-FALL L-SAFE L-ENTITY L-EBLOCK L-SBLOCK L-STATE L-SEND P6-PACKET.
     MOVE 0 TO L-SEND
     COMPUTE WS-T = L-FALL + 0.000001 - L-SAFE
     COMPUTE WS-POWER = FUNCTION INTEGER(WS-T)
     IF WS-POWER > 0
         MOVE 1 TO L-SEND
         MOVE L-E(1) TO PK-X
         MOVE L-E(2) TO PK-Y
         MOVE L-E(3) TO PK-Z
         IF L-EB(1) NOT = L-SB(1) OR L-EB(2) NOT = L-SB(2)
             COMPUTE WS-DX = L-E(1) - (L-SB(1) + 0.5)
             COMPUTE WS-DZ = L-E(3) - (L-SB(2) + 0.5)
             COMPUTE WS-M = FUNCTION MAX(FUNCTION ABS(WS-DX) FUNCTION ABS(WS-DZ))
             COMPUTE PK-X = L-SB(1) + 0.5 + (WS-DX / WS-M) * 0.5
             COMPUTE PK-Z = L-SB(2) + 0.5 + (WS-DZ / WS-M) * 0.5
         END-IF
         COMPUTE WS-AMOUNT = 0.20000000298023224 + WS-POWER / 15
         IF WS-AMOUNT > 2.5
             MOVE 2.5 TO WS-AMOUNT
         END-IF
         COMPUTE PK-COUNT = FUNCTION INTEGER-PART(150 * WS-AMOUNT)
         MOVE "block" TO PK-NAME
         MOVE 0 TO PK-DIST(1) PK-DIST(2) PK-DIST(3)
         MOVE 0.15000000596046448 TO PK-SPEED(1) PK-SPEED(2) PK-SPEED(3)
         MOVE 0 TO PK-MODE PK-COLOR PK-DURATION
         MOVE L-STATE TO PK-STATE
     END-IF
     GOBACK.
 END PROGRAM P6-LANDING.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P6-POWDER-SNOW.
*> 8.4: draw rb (true at r >= 0.5, else nothing is sent), then two draws for randomBetween(-1, 1) * 0.083333336 on x and z; `snowflake` at (entity x,
*> block y + 1, entity z), count 1, no spread, speeds (those, 0.05000000074505806, ...), randomisation ALTERNATIVE (1).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-R                   FLOAT-LONG.
 LINKAGE SECTION.
 COPY CLP6EM.
 01 L-EX                   FLOAT-LONG.
 01 L-EZ                   FLOAT-LONG.
 COPY CLP6ARG.
 01 L-SEND                 BINARY-LONG.
 COPY CLP6PK.
 PROCEDURE DIVISION USING P6-EMITS L-EX L-EZ L-P L-SEND P6-PACKET.
     MOVE 0 TO L-SEND
     CALL "P6-DRAW" USING P6-EMITS WS-R
     IF WS-R >= 0.5
         MOVE 1 TO L-SEND
         MOVE "snowflake" TO PK-NAME
         MOVE L-EX TO PK-X
         COMPUTE PK-Y = L-PP(2) + 1
         MOVE L-EZ TO PK-Z
         MOVE 1 TO PK-COUNT
         MOVE 0 TO PK-DIST(1) PK-DIST(2) PK-DIST(3)
         CALL "P6-DRAW" USING P6-EMITS WS-R
         COMPUTE PK-SPEED(1) = (2 * WS-R - 1) * 0.083333336
         MOVE 0.05000000074505806 TO PK-SPEED(2)
         CALL "P6-DRAW" USING P6-EMITS WS-R
         COMPUTE PK-SPEED(3) = (2 * WS-R - 1) * 0.083333336
         MOVE 1 TO PK-MODE
         MOVE 0 TO PK-STATE PK-COLOR PK-DURATION
     END-IF
     GOBACK.
 END PROGRAM P6-POWDER-SNOW.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P6-POT-PACKET.
*> 8.5: `dust_plume` at (X + 0.5, Y + 1.2, Z + 0.5), count 7, no spread, speed 0, randomisation DEFAULT.
 DATA DIVISION.
 LINKAGE SECTION.
 COPY CLP6ARG.
 COPY CLP6PK.
 PROCEDURE DIVISION USING L-P P6-PACKET.
     MOVE "dust_plume" TO PK-NAME
     COMPUTE PK-X = L-PP(1) + 0.5
     COMPUTE PK-Y = L-PP(2) + 1.2
     COMPUTE PK-Z = L-PP(3) + 0.5
     MOVE 7 TO PK-COUNT
     MOVE 0 TO PK-DIST(1) PK-DIST(2) PK-DIST(3)
     MOVE 0 TO PK-SPEED(1) PK-SPEED(2) PK-SPEED(3)
     MOVE 0 TO PK-MODE PK-STATE PK-COLOR PK-DURATION
     GOBACK.
 END PROGRAM P6-POT-PACKET.
