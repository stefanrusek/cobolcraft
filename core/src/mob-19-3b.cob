*> Spawn genes of the equines (lane p49v; docs/protocol/19-mobs-land-friendly-and-neutral.md sections 3.2 and 3.6).
*>   M19-ZOMBIE-HORSE-GENES USING r1, r2, r3 (nextDouble draws), jump out, speed out    ZombieHorse.randomizeAttributes: jump 0.5 + (r1 + r2 + r3) / 15, speed (9 + r1 + r2 + r3) / 42.16
*>   M19-EQUINE-BORN USING row                                                         a horse, donkey or mule draws its max health 15 + nextInt(8) + nextInt(9); a donkey or mule keeps the chested
*>                                                                                     base jump strength 0.5 (the horse's jump gene is M44-HORSE-BORN)
*> The zombie horse and the skeleton horse have no row of the core, so M19-ZOMBIE-HORSE-GENES is a formula only.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. M19-ZOMBIE-HORSE-GENES.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-R1                   FLOAT-LONG.
 01 L-R2                   FLOAT-LONG.
 01 L-R3                   FLOAT-LONG.
 01 L-JUMP                 FLOAT-LONG.
 01 L-SPEED                FLOAT-LONG.
 PROCEDURE DIVISION USING L-R1 L-R2 L-R3 L-JUMP L-SPEED.
     COMPUTE L-JUMP = 0.5 + (L-R1 + L-R2 + L-R3) / 15
     COMPUTE L-SPEED = (9 + L-R1 + L-R2 + L-R3) / 42.16
     GOBACK.
 END PROGRAM M19-ZOMBIE-HORSE-GENES.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. M19-EQUINE-BORN.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-KEY                 PIC X(24).
 01 WS-SALT-A              BINARY-LONG VALUE 5221.
 01 WS-SALT-B              BINARY-LONG VALUE 5222.
 01 WS-BOUND-A             BINARY-LONG VALUE 8.
 01 WS-BOUND-B             BINARY-LONG VALUE 9.
 01 WS-D1                  BINARY-LONG.
 01 WS-D2                  BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     CALL "XP-RANDOM" USING WS-SALT-A WS-BOUND-A WS-D1
     CALL "XP-RANDOM" USING WS-SALT-B WS-BOUND-B WS-D2
     CALL "M19-GENE-HEALTH" USING WS-D1 WS-D2 EN-HEALTH(L-ROW)
     CALL "MOB-SPECIES-KEY" USING L-ROW WS-KEY
     IF WS-KEY = "donkey" OR "mule"
         MOVE 0.5 TO EN-HORSE-JUMP(L-ROW)
     END-IF
     GOBACK.
 END PROGRAM M19-EQUINE-BORN.
