*> The mount rows of documents 20 sections 4.3, 4.4 and 18.3 and 19 sections 3.6 and 3.8 (wrap I2, T2450 and T2506; rows in core/copy/MOBROWSMT.cpy): the camel husk jockey of a natural husk,
*> the zombie horse (its spawn genes and its zombie jockey) and the skeleton horse (the jump gene). The loot of the three comes from the tables entities/<key> (STDMOB-DROPS).
*>   HUSK-CAMEL-BOX USING dim, x, y, z (BINARY-LONG feet cell of the husk), free out    4.3 step 3: the camel husk's spawn box (1.7 x 2.375 at the cell's centre) holds no full block
*>   HUSK-CAMEL USING xoro state, husk row                                              4.3 step 3: one attempt per natural group: nextFloat below 0.1 gives the husk an iron spear and a camel husk to ride
*>                                                                                      (the parched jockey of the same step is created and finalized beside it: a mob carries one mob rider, EN-PASS)
*>   MS6-PACK-EXTRA USING xoro state, new row, members already in the pack                the finalizeSpawn extras of a natural spawn: the first husk of a group tries a camel husk, a zombie horse takes its zombie
*>   ZOMBIE-HORSE-BORN USING row                                                        19 3.6: jump strength 0.5 + (r1 + r2 + r3) / 15 (EN-HORSE-JUMP) and speed (9 + r1 + r2 + r3) / 42.16 (WC-ZH-SPEED, millionths)
*>   ZOMBIE-HORSE-JOCKEY USING xoro state, zombie horse row                             19 3.6 "Zombie horse spawn extra": a natural zombie horse carries a zombie (JOCKEY) with an iron spear
*>   SKELETON-HORSE-BORN USING row                                                      19 3.2: the jump strength of the shared horse formula; health stays 15

 IDENTIFICATION DIVISION.
 PROGRAM-ID. HUSK-CAMEL-BOX.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-DX                  BINARY-LONG.
 01 WS-DY                  BINARY-LONG.
 01 WS-DZ                  BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-KIND                BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-FREE                 BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z L-FREE.
*>   Centre (x + 0.5, z + 0.5), half width 0.85: the cells x - 1 to x + 1 and z - 1 to z + 1; height 2.375 from the feet: the cells y to y + 2.
     MOVE 1 TO L-FREE
     PERFORM VARYING WS-DX FROM -1 BY 1 UNTIL WS-DX > 1
         PERFORM VARYING WS-DY FROM 0 BY 1 UNTIL WS-DY > 2
             PERFORM VARYING WS-DZ FROM -1 BY 1 UNTIL WS-DZ > 1
                 COMPUTE WS-X = L-X + WS-DX
                 COMPUTE WS-Y = L-Y + WS-DY
                 COMPUTE WS-Z = L-Z + WS-DZ
                 CALL "MS6-BLOCK-KIND" USING L-DIM WS-X WS-Y WS-Z WS-KIND
                 IF WS-KIND = 1
                     MOVE 0 TO L-FREE
                 END-IF
             END-PERFORM
         END-PERFORM
     END-PERFORM
     GOBACK.
 END PROGRAM HUSK-CAMEL-BOX.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. HUSK-CAMEL RECURSIVE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CONTENT.
 01 WS-D                   FLOAT-LONG.
 01 WS-KEY                 PIC X(112) VALUE "minecraft:camel_husk".
 01 WS-KEY-PARCHED         PIC X(112) VALUE "minecraft:parched".
 01 WS-ENTITY-ROW          PIC X(66).
 01 WS-STATUS              BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-CAMEL               BINARY-LONG.
 01 WS-PARCHED             BINARY-LONG.
 01 WS-MOUNTED             BINARY-LONG.
 01 WS-FREE                BINARY-LONG.
 01 WS-BX                  BINARY-LONG.
 01 WS-BY                  BINARY-LONG.
 01 WS-BZ                  BINARY-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-YAW                 FLOAT-SHORT.
 01 WS-IRON-SPEAR          BINARY-LONG VALUE 2.
 LINKAGE SECTION.
 COPY XORO REPLACING LEADING ==XR-== BY ==L-==.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-STATE L-ROW.
     COMPUTE WS-BX = FUNCTION INTEGER(EN-X(L-ROW))
     COMPUTE WS-BY = FUNCTION INTEGER(EN-Y(L-ROW))
     COMPUTE WS-BZ = FUNCTION INTEGER(EN-Z(L-ROW))
     CALL "HUSK-CAMEL-BOX" USING EN-DIM(L-ROW) WS-BX WS-BY WS-BZ WS-FREE
     IF WS-FREE = 1
         CALL "XORO-NEXT-DOUBLE" USING L-STATE WS-D
         IF WS-D < 0.1
             MOVE WS-IRON-SPEAR TO EN-HAND(L-ROW)
             CALL "STDMOB-EQUIP-SEND" USING L-ROW
             MOVE EN-X(L-ROW) TO WS-X
             MOVE EN-Y(L-ROW) TO WS-Y
             MOVE EN-Z(L-ROW) TO WS-Z
             MOVE EN-YAW(L-ROW) TO WS-YAW
             CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE WS-ENTITY-ROW WS-STATUS
             CALL "MOB-SPAWN" USING EN-DIM(L-ROW) WS-TYPE WS-X WS-Y WS-Z WS-YAW WS-CAMEL
             CALL "STDMOB-FINALIZE" USING L-STATE WS-CAMEL
             CALL "MOB-MOUNT" USING L-ROW WS-CAMEL WS-MOUNTED
             CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY-PARCHED WS-TYPE WS-ENTITY-ROW WS-STATUS
             CALL "MOB-SPAWN" USING EN-DIM(L-ROW) WS-TYPE WS-X WS-Y WS-Z WS-YAW WS-PARCHED
             CALL "STDMOB-FINALIZE" USING L-STATE WS-PARCHED
             CALL "MOB-MOUNT" USING WS-PARCHED WS-CAMEL WS-MOUNTED
         END-IF
     END-IF
     GOBACK.
 END PROGRAM HUSK-CAMEL.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MS6-PACK-EXTRA.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-KEY                 PIC X(24).
 LINKAGE SECTION.
 COPY XORO REPLACING LEADING ==XR-== BY ==L-==.
 01 L-ROW                  BINARY-LONG.
 01 L-IN-PACK              BINARY-LONG.
 PROCEDURE DIVISION USING L-STATE L-ROW L-IN-PACK.
     CALL "MOB-SPECIES-KEY" USING L-ROW WS-KEY
     IF WS-KEY = "husk" AND L-IN-PACK = 0
         CALL "HUSK-CAMEL" USING L-STATE L-ROW
     END-IF
     IF WS-KEY = "zombie_horse"
         CALL "ZOMBIE-HORSE-JOCKEY" USING L-STATE L-ROW
     END-IF
     GOBACK.
 END PROGRAM MS6-PACK-EXTRA.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ZOMBIE-HORSE-BORN.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY WCSTATE.
 01 WS-SALT                BINARY-LONG VALUE 5231.
 01 WS-BOUND               BINARY-LONG VALUE 10000.
 01 WS-D1                  BINARY-LONG.
 01 WS-D2                  BINARY-LONG.
 01 WS-D3                  BINARY-LONG.
 01 WS-R1                  FLOAT-LONG.
 01 WS-R2                  FLOAT-LONG.
 01 WS-R3                  FLOAT-LONG.
 01 WS-SPEED               FLOAT-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     CALL "XP-RANDOM" USING WS-SALT WS-BOUND WS-D1
     ADD 1 TO WS-SALT
     CALL "XP-RANDOM" USING WS-SALT WS-BOUND WS-D2
     ADD 1 TO WS-SALT
     CALL "XP-RANDOM" USING WS-SALT WS-BOUND WS-D3
     SUBTRACT 2 FROM WS-SALT
     COMPUTE WS-R1 = WS-D1 / 10000
     COMPUTE WS-R2 = WS-D2 / 10000
     COMPUTE WS-R3 = WS-D3 / 10000
     CALL "M19-ZOMBIE-HORSE-GENES" USING WS-R1 WS-R2 WS-R3 EN-HORSE-JUMP(L-ROW) WS-SPEED
     CALL "WC-ROW-OPEN" USING L-ROW
     COMPUTE WC-ZH-SPEED(L-ROW) = WS-SPEED * 1000000
     GOBACK.
 END PROGRAM ZOMBIE-HORSE-BORN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ZOMBIE-HORSE-JOCKEY RECURSIVE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CONTENT.
 01 WS-KEY                 PIC X(112) VALUE "minecraft:zombie".
 01 WS-ENTITY-ROW          PIC X(66).
 01 WS-STATUS              BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-ZOMBIE              BINARY-LONG.
 01 WS-MOUNTED             BINARY-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-YAW                 FLOAT-SHORT.
 01 WS-IRON-SPEAR          BINARY-LONG VALUE 2.
 LINKAGE SECTION.
 COPY XORO REPLACING LEADING ==XR-== BY ==L-==.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-STATE L-ROW.
     MOVE EN-X(L-ROW) TO WS-X
     MOVE EN-Y(L-ROW) TO WS-Y
     MOVE EN-Z(L-ROW) TO WS-Z
     MOVE EN-YAW(L-ROW) TO WS-YAW
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE WS-ENTITY-ROW WS-STATUS
     CALL "MOB-SPAWN" USING EN-DIM(L-ROW) WS-TYPE WS-X WS-Y WS-Z WS-YAW WS-ZOMBIE
     CALL "STDMOB-FINALIZE" USING L-STATE WS-ZOMBIE
     MOVE WS-IRON-SPEAR TO EN-HAND(WS-ZOMBIE)
     CALL "STDMOB-EQUIP-SEND" USING WS-ZOMBIE
     CALL "MOB-MOUNT" USING WS-ZOMBIE L-ROW WS-MOUNTED
     GOBACK.
 END PROGRAM ZOMBIE-HORSE-JOCKEY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SKELETON-HORSE-BORN.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     CALL "M44-HORSE-BORN" USING L-ROW
     GOBACK.
 END PROGRAM SKELETON-HORSE-BORN.
