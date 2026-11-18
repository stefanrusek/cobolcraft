*> Warden (002-lane-p49b; docs/protocol/20-mobs-overworld-hostile.md section 15).
*> Entry points:
*>   WARDEN-DARKNESS USING tracker row: every 120 ticks offset by the entity id ((id + tickCount) mod 120 = 0) the warden gives every player within 20 blocks of it, in its
*>     dimension, the Darkness effect (amplifier 0, 260 ticks, flags 4: icon, no particles). The tick count of an entity is not tracked: the world time CW-TIME stands in.
*>     The anger manager, the brain activities and the sonic boom of the section are not here.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. WARDEN-DARKNESS.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-DARKNESS            BINARY-LONG VALUE 32.
 01 WS-AMPLIFIER           BINARY-LONG VALUE 0.
 01 WS-DURATION            BINARY-LONG VALUE 260.
 01 WS-FLAGS               BINARY-LONG VALUE 4.
 01 WS-P                   BINARY-LONG.
 01 WS-DX                  FLOAT-LONG.
 01 WS-DY                  FLOAT-LONG.
 01 WS-DZ                  FLOAT-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     IF FUNCTION MOD(EN-ID(L-ROW) + CW-TIME, 120) NOT = 0
         GOBACK
     END-IF
     PERFORM VARYING WS-P FROM 1 BY 1 UNTIL WS-P > CORE-MAX-PLAYERS
         IF PL-USED(WS-P) = 1 AND PL-DIM(WS-P) = EN-DIM(L-ROW)
             COMPUTE WS-DX = PL-X(WS-P) - EN-X(L-ROW)
             COMPUTE WS-DY = PL-Y(WS-P) - EN-Y(L-ROW)
             COMPUTE WS-DZ = PL-Z(WS-P) - EN-Z(L-ROW)
             IF WS-DX * WS-DX + WS-DY * WS-DY + WS-DZ * WS-DZ <= 400
                 CALL "EFFECT-ADD" USING WS-P WS-DARKNESS WS-AMPLIFIER WS-DURATION WS-FLAGS
             END-IF
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM WARDEN-DARKNESS.
