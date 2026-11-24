*> The particles a replica entity makes (docs/protocol/42-particles-7 section 6, the per-entity emissions): the library's emitter P7-MOB turns the draws of the
*> particle random source into rows (name, position, velocity), and each row becomes a live particle (PARTICLE-SPAWN, particles-live.cob).

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ENTITY-MOB-PARTICLES.
*> USING CLIENT-STATE, site (X(24), the site name of P7-MOB), inputs (16 FLOAT-LONG, the IN of the site), draws (BINARY-LONG, how many random draws the site takes):
*> runs the emitter site with draws of PARTICLE-RANDOM and spawns every emitted particle of a type the live store has a class for (the others spawn nothing).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLP6EM.
 01 WS-I                   BINARY-LONG.
 01 WS-NAME                PIC X(32).
 01 WS-ID                  BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-SITE                 PIC X(24).
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 16 TIMES.
 01 L-DRAWS                BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-SITE L-IN L-DRAWS.
     MOVE 0 TO EM-COUNT EM-CUR EM-SOUND-COUNT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > L-DRAWS OR WS-I > 2048
         CALL "PARTICLE-RANDOM" USING EM-DRAW(WS-I)
     END-PERFORM
     CALL "P7-MOB" USING L-SITE L-IN P6-EMITS
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > EM-COUNT
         MOVE EM-NAME(WS-I) TO WS-NAME
         CALL "PART-TYPE-ID" USING WS-NAME WS-ID
         IF WS-ID >= 0
             CALL "PARTICLE-SPAWN" USING CLIENT-STATE WS-ID EM-X(WS-I) EM-Y(WS-I) EM-Z(WS-I) EM-VX(WS-I) EM-VY(WS-I) EM-VZ(WS-I)
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM ENTITY-MOB-PARTICLES.
