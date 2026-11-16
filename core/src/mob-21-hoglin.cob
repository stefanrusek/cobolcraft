*> The hoglin's throw (docs/protocol/21 section 5.6 HoglinBase.hurtAndThrowTarget; lane 002-lane-mobsb4, T8804). Gaps: the damage A / 2 + nextInt(A) of an adult is not applied (the hit uses
*> the row's attack damage), no attack animation event 4 on the hoglin, the hoglin brain (repellents, fleeing piglins, hunting by piglins) is not modelled.
*>
*>   HOGLIN-THROW USING dx, dz (thousandths from the hoglin to the target), resistance (thousandths), r1, r3 (nextFloat in thousandths), r2 (0 to 20: nextInt(21)), vx, vy, vz out (thousandths per tick)
*>   HOGLIN-HIT USING player row, mob row, vx out, vy out, vz out    an adult hoglin or zoglin's hit throws the player (COMBAT-MOTION-SEND); zeros for a baby or another mob

 IDENTIFICATION DIVISION.
 PROGRAM-ID. HOGLIN-THROW.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-K                    BINARY-LONG.
 01 WS-LEN                  FLOAT-LONG.
 01 WS-UX                   FLOAT-LONG.
 01 WS-UZ                   FLOAT-LONG.
 01 WS-MAG                  FLOAT-LONG.
 01 WS-A                    FLOAT-LONG.
 01 WS-C                    FLOAT-LONG.
 01 WS-S                    FLOAT-LONG.
 LINKAGE SECTION.
 01 L-DX                    BINARY-LONG.
 01 L-DZ                    BINARY-LONG.
 01 L-RES                   BINARY-LONG.
 01 L-R1                    BINARY-LONG.
 01 L-R2                    BINARY-LONG.
 01 L-R3                    BINARY-LONG.
 01 L-VX                    BINARY-LONG.
 01 L-VY                    BINARY-LONG.
 01 L-VZ                    BINARY-LONG.
 PROCEDURE DIVISION USING L-DX L-DZ L-RES L-R1 L-R2 L-R3 L-VX L-VY L-VZ.
     MOVE 0 TO L-VX L-VY L-VZ
     COMPUTE WS-K = 1000 - L-RES
     IF WS-K <= 0
         GOBACK
     END-IF
     COMPUTE WS-LEN = FUNCTION SQRT(L-DX * L-DX + L-DZ * L-DZ)
     IF WS-LEN > 0
         COMPUTE WS-UX = L-DX / WS-LEN
         COMPUTE WS-UZ = L-DZ / WS-LEN
     ELSE
         MOVE 0 TO WS-UX WS-UZ
     END-IF
     COMPUTE WS-MAG = WS-K * (L-R1 * 0.5 + 200) / 1000
     COMPUTE WS-A = (L-R2 - 10) * 3.14159265358979 / 180
     COMPUTE WS-C = FUNCTION COS(WS-A)
     COMPUTE WS-S = FUNCTION SIN(WS-A)
     COMPUTE L-VX = WS-MAG * (WS-UX * WS-C - WS-UZ * WS-S)
     COMPUTE L-VZ = WS-MAG * (WS-UX * WS-S + WS-UZ * WS-C)
     COMPUTE L-VY = WS-K * L-R3 * 0.5 / 1000
     GOBACK.
 END PROGRAM HOGLIN-THROW.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. HOGLIN-HIT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-KEY                  PIC X(24).
 01 WS-DX                   BINARY-LONG.
 01 WS-DZ                   BINARY-LONG.
 01 WS-RES                  BINARY-LONG VALUE 0.
 01 WS-R1                   BINARY-LONG.
 01 WS-R2                   BINARY-LONG.
 01 WS-R3                   BINARY-LONG.
 01 WS-SALT1                BINARY-LONG VALUE 861.
 01 WS-SALT2                BINARY-LONG VALUE 862.
 01 WS-SALT3                BINARY-LONG VALUE 863.
 01 WS-K1000                BINARY-LONG VALUE 1000.
 01 WS-K21                  BINARY-LONG VALUE 21.
 LINKAGE SECTION.
 01 L-PLAYER                BINARY-LONG.
 01 L-MOB                   BINARY-LONG.
 01 L-VX                    BINARY-LONG.
 01 L-VY                    BINARY-LONG.
 01 L-VZ                    BINARY-LONG.
 PROCEDURE DIVISION USING L-PLAYER L-MOB L-VX L-VY L-VZ.
     MOVE 0 TO L-VX L-VY L-VZ
     CALL "MOB-SPECIES-KEY" USING L-MOB WS-KEY
     IF (WS-KEY = "hoglin" OR "zoglin") AND EN-MOBAGE(L-MOB) >= 0
         COMPUTE WS-DX = (PL-X(L-PLAYER) - EN-X(L-MOB)) * 1000
         COMPUTE WS-DZ = (PL-Z(L-PLAYER) - EN-Z(L-MOB)) * 1000
         CALL "XP-RANDOM" USING WS-SALT1 WS-K1000 WS-R1
         CALL "XP-RANDOM" USING WS-SALT2 WS-K21 WS-R2
         CALL "XP-RANDOM" USING WS-SALT3 WS-K1000 WS-R3
         CALL "HOGLIN-THROW" USING WS-DX WS-DZ WS-RES WS-R1 WS-R2 WS-R3 L-VX L-VY L-VZ
         CALL "COMBAT-MOTION-SEND" USING L-PLAYER L-VX L-VY L-VZ
     END-IF
     GOBACK.
 END PROGRAM HOGLIN-HIT.
