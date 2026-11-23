*> The first-person fire overlay (docs/protocol/57-client-closures-1-rendering-and-animation.md section 1, T11106): a burning local player sees two quads of the block atlas
*> sprite fire_1 over the lower screen. They are drawn in the hand pass (after the hand and the arm, before the GUI) in the camera space of the hand projection: +x right, +y up, the
*> viewer looks along -z, no part of the camera pose, the bobbing or the hurt tilt applies.
*>   FIRE-OVERLAY-MESH USING CLIENT-STATE: RL-HF-COUNT and RL-HF-VERTEX for this frame (0 when nothing is drawn).
*> Condition (1.2): the local player is on fire (PL-ON-FIRE, the flag of entry 0, bit 0, of its own Set Entity Data), the world screen, the first person view, not a spectator
*> (PL-MODE 3). The client keeps no sleeping state of the local player, so the extraction's sleeping test is not made; a fire immune type never reports the flag, and creative mode
*> needs no test of its own. The pack must hold fire_1 (the atlas sprite, animated by the atlas: the quad uses its whole region, the frame is the one the atlas last wrote); a pack
*> without it shows nothing.
*> Geometry (1.3): each quad is the unit square at z = -0.5 (corners (-0.5, -0.5), (0.5, -0.5), (0.5, 0.5), (-0.5, 0.5)), rotated about y (first quad by -10 degrees, second by +10) and
*> then translated by (+0.24, -0.3, 0) or (-0.24, -0.3, 0); the texture coordinates of those corners are (u1, v1), (u0, v1), (u0, v0), (u1, v0), so the image is mirrored horizontally.
*> Colour: white, alpha 229 / 255, no light, no fog (brightness 1, no sky term). The six vertices of a quad are its corners 1 2 3 1 3 4.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FIRE-OVERLAY-MESH.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLCONST.
 01 WS-ID                  PIC X(80).
 01 WS-LEN                 BINARY-LONG VALUE 22.
 01 WS-SPRITE              BINARY-LONG.
 01 WS-COS                 FLOAT-LONG VALUE 0.98480775.
 01 WS-SIN                 FLOAT-LONG VALUE 0.17364818.
 01 WS-SIDE                FLOAT-LONG.
 01 WS-Q                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-CX                  FLOAT-LONG.
 01 WS-CY                  FLOAT-LONG.
 01 WS-U16                 FLOAT-SHORT.
 01 WS-V16                 FLOAT-SHORT.
 01 WS-CORNERS.
    05 WS-C OCCURS 4 TIMES.
       10 WS-X             FLOAT-SHORT.
       10 WS-Y             FLOAT-SHORT.
       10 WS-Z             FLOAT-SHORT.
       10 WS-U             FLOAT-SHORT.
       10 WS-V             FLOAT-SHORT.
 01 WS-ORDER-DATA          PIC X(6) VALUE "123134".
 01 WS-ORDER REDEFINES WS-ORDER-DATA.
    05 WS-ORD              PIC 9 OCCURS 6 TIMES.
 LINKAGE SECTION.
 COPY CLSTATE.
 PROCEDURE DIVISION USING CLIENT-STATE.
     MOVE 0 TO RL-HF-COUNT
     IF PL-ON-FIRE = 1 AND SM-SCREEN = SCR-WORLD AND CL-CAMERA = 0 AND PL-MODE NOT = 3
         MOVE SPACES TO WS-ID
         MOVE "minecraft:block/fire_1" TO WS-ID
         CALL "ATLAS-FIND" USING CLIENT-STATE WS-ID WS-LEN WS-SPRITE
     ELSE
         GOBACK
     END-IF
     IF WS-SPRITE = 0
         GOBACK
     END-IF
     PERFORM VARYING WS-Q FROM 1 BY 1 UNTIL WS-Q > 2
*>       The first quad turns by -10 degrees and moves by +0.24 in x, the second by +10 degrees and -0.24.
         IF WS-Q = 1
             MOVE 1 TO WS-SIDE
         ELSE
             MOVE -1 TO WS-SIDE
         END-IF
         PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 4
             MOVE -0.5 TO WS-CX
             IF WS-K = 2 OR WS-K = 3
                 MOVE 0.5 TO WS-CX
             END-IF
             MOVE -0.5 TO WS-CY
             IF WS-K >= 3
                 MOVE 0.5 TO WS-CY
             END-IF
             MOVE 0 TO WS-U16
             IF WS-K = 1 OR WS-K = 4
                 MOVE 16 TO WS-U16
             END-IF
             MOVE 0 TO WS-V16
             IF WS-K <= 2
                 MOVE 16 TO WS-V16
             END-IF
*>           x' = cos a x + sin a z, z' = -sin a x + cos a z with z = -0.5 and sin a = -side sin 10 degrees.
             COMPUTE WS-X(WS-K) = WS-COS * WS-CX + WS-SIDE * WS-SIN * 0.5 + 0.24 * WS-SIDE
             COMPUTE WS-Y(WS-K) = WS-CY - 0.3
             COMPUTE WS-Z(WS-K) = WS-SIDE * WS-SIN * WS-CX - WS-COS * 0.5
             CALL "ATLAS-UV" USING CLIENT-STATE WS-SPRITE WS-U16 WS-V16 WS-U(WS-K) WS-V(WS-K)
         END-PERFORM
         PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 6
             MOVE WS-ORD(WS-K) TO WS-N
             ADD 1 TO RL-HF-COUNT
             MOVE WS-X(WS-N) TO RL-HF-X(RL-HF-COUNT)
             MOVE WS-Y(WS-N) TO RL-HF-Y(RL-HF-COUNT)
             MOVE WS-Z(WS-N) TO RL-HF-Z(RL-HF-COUNT)
             MOVE WS-U(WS-N) TO RL-HF-U(RL-HF-COUNT)
             MOVE WS-V(WS-N) TO RL-HF-V(RL-HF-COUNT)
             MOVE 1 TO RL-HF-B(RL-HF-COUNT)
             COMPUTE RL-HF-A(RL-HF-COUNT) = 229 / 255
             MOVE 0 TO RL-HF-SKY(RL-HF-COUNT)
             MOVE 1 TO RL-HF-R(RL-HF-COUNT) RL-HF-G(RL-HF-COUNT) RL-HF-BLUE(RL-HF-COUNT)
         END-PERFORM
     END-PERFORM
     GOBACK.
 END PROGRAM FIRE-OVERLAY-MESH.
