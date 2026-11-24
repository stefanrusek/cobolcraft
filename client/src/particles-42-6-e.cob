*> Particles part 6 (docs/protocol/42-particles-6-emitters-blocks.md) section 5: fluid `animateTick`. Draws and output rows are those of
*> client/copy/CLP6EM.cpy (see particles-42-6-b.cob).
*>
*> Entry point for the integrator (inputs):
*>   P6-FLUID-TICK fluid(PIC X(24): water, lava) P(3 integers) PROPS(12 integers) P6-EMITS: PROPS 1 for water: the state is a source or falling;
*>     for lava: the cell above is air and not solid-rendering. The generic drip of 1.2 and 1.5 is not part of this entry point (P6-DRIP-*).
*> The ambient sounds are reported as sound events; the lava pop and ambient sounds' own draws are not specified and are not drawn. The
*> ri(200) of the lava ambient sound is drawn after the pop test whether or not the pop played.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P6-FLUID-TICK.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-UNDERWATER          PIC X(40) VALUE "underwater".
 01 WS-LAVA                PIC X(40) VALUE "lava".
 01 WS-S1                  PIC X(40) VALUE "water.ambient".
 01 WS-S2                  PIC X(40) VALUE "lava.pop".
 01 WS-S3                  PIC X(40) VALUE "lava.ambient".
 01 WS-R                   FLOAT-LONG.
 01 WS-A                   BINARY-LONG.
 01 WS-PV.
    05 WS-V                FLOAT-LONG OCCURS 6 TIMES.
 LINKAGE SECTION.
 01 L-FLUID                PIC X(24).
 COPY CLP6ARG.
 COPY CLP6EM.
 PROCEDURE DIVISION USING L-FLUID L-P L-PROPS P6-EMITS.
     MOVE 0 TO EM-COUNT EM-CUR EM-SOUND-COUNT
     INITIALIZE WS-PV
     EVALUATE L-FLUID
         WHEN "water"
             CALL "P6-DRAW" USING P6-EMITS WS-R
             IF L-PR(1) NOT = 0
                 IF WS-R < 0.1
                     PERFORM VARYING WS-A FROM 1 BY 1 UNTIL WS-A > 3
                         CALL "P6-DRAW" USING P6-EMITS WS-R
                         COMPUTE WS-V(WS-A) = L-PP(WS-A) + WS-R
                     END-PERFORM
                     CALL "P6-EMIT" USING P6-EMITS WS-UNDERWATER WS-PV
                 END-IF
             ELSE
                 IF WS-R < 0.015625
                     CALL "P6-DRAW" USING P6-EMITS WS-R
                     CALL "P6-DRAW" USING P6-EMITS WS-R
                     CALL "P6-EMIT-SOUND" USING P6-EMITS WS-S1
                 END-IF
             END-IF
         WHEN "lava"
             IF L-PR(1) NOT = 0
                 CALL "P6-DRAW" USING P6-EMITS WS-R
                 IF WS-R < 0.01
                     CALL "P6-DRAW" USING P6-EMITS WS-R
                     COMPUTE WS-V(1) = L-PP(1) + WS-R
                     CALL "P6-DRAW" USING P6-EMITS WS-R
                     COMPUTE WS-V(3) = L-PP(3) + WS-R
                     COMPUTE WS-V(2) = L-PP(2) + 1
                     CALL "P6-EMIT" USING P6-EMITS WS-LAVA WS-PV
                     CALL "P6-EMIT-SOUND" USING P6-EMITS WS-S2
                 END-IF
                 CALL "P6-DRAW" USING P6-EMITS WS-R
                 IF WS-R < 0.005
                     CALL "P6-EMIT-SOUND" USING P6-EMITS WS-S3
                 END-IF
             END-IF
     END-EVALUATE
     GOBACK.
 END PROGRAM P6-FLUID-TICK.
