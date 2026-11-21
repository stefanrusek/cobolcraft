*> The chunk overflow of the feature stage (GENOVER.cpy; docs/design/world-types.md "Chunk borders"): blocks a feature writes outside the chunk being generated are kept
*> and written into the neighbour chunk when it exists, only into air, leaves and plants.
*>
*> Entry points:
*>   OV-KEEP USING job: appends the level's recorded writes (FL-OV) to the job's list (GJ-OV, bounded) and empties the level's list.
*>   OV-REPLACEABLE USING state, flag out: 1 for air, cave air, void air, leaves and non-solid blocks other than water and lava.
*>   OV-APPLY-ROW USING row, x, y, z, state, result out: writes the state into a cached chunk when its cell is replaceable; 1 written.
*>   OV-PEND-ADD USING dimension row, x, y, z, state: appends to the pending list (the oldest GP-DROP go when it is full).
*>   OV-ROUTE USING dimension row: routes GEN-OVERFLOW (loaded chunk: written at once; else pending) and empties it.
*>   OV-TAKE USING row: applies the pending entries of the chunk just loaded and removes them.
*>   OV-FLUSH: sends the lit chunks that changed (CK-RESEND) again to their viewers, after relighting them.
*>   OV-RESET: forgets everything pending.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. OV-KEEP.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY FEATLEVEL.
 01 WS-I                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-JOB.
    COPY GENJOB REPLACING LEADING ==GJ-== BY ==J-==.
 PROCEDURE DIVISION USING L-JOB.
     ADD FL-OV-LOST TO J-OV-LOST
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > FL-OV-COUNT
         IF J-OV-COUNT < 1024
             ADD 1 TO J-OV-COUNT
             MOVE FL-OV-ENTRY(WS-I) TO J-OV-ENTRY(J-OV-COUNT)
         ELSE
             ADD 1 TO J-OV-LOST
         END-IF
     END-PERFORM
     MOVE 0 TO FL-OV-COUNT FL-OV-LOST
     GOBACK.
 END PROGRAM OV-KEEP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. OV-REPLACEABLE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CBLOCKS.
 01 WS-B                   BINARY-LONG.
 01 WS-FULL                PIC X(48).
 01 WS-LEN                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-STATE                BINARY-LONG.
 01 L-FLAG                 BINARY-LONG.
 PROCEDURE DIVISION USING L-STATE L-FLAG.
     MOVE 0 TO L-FLAG
     CALL "FL-BLOCK-OF" USING L-STATE WS-B
     IF WS-B = 0
         GOBACK
     END-IF
     CALL "KEY-NAMESPACED" USING CB-KEY(WS-B) WS-FULL
     EVALUATE FUNCTION TRIM(WS-FULL)
         WHEN "minecraft:air"
         WHEN "minecraft:cave_air"
         WHEN "minecraft:void_air"
             MOVE 1 TO L-FLAG
         WHEN "minecraft:water"
         WHEN "minecraft:lava"
         WHEN "minecraft:bedrock"
             CONTINUE
         WHEN OTHER
             MOVE CB-KEY-LENGTH(WS-B) TO WS-LEN
             IF CB-SOLID(WS-B) = 0
                 MOVE 1 TO L-FLAG
             END-IF
             IF WS-LEN >= 7 AND CB-KEY(WS-B)(WS-LEN - 6:7) = "_leaves"
                 MOVE 1 TO L-FLAG
             END-IF
     END-EVALUATE
     GOBACK.
 END PROGRAM OV-REPLACEABLE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. OV-APPLY-ROW.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY DIMENSIONS.
 COPY CBLOCKS.
 COPY CELLS.
 COPY GENOVER.
 01 WS-CX                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-CELL                BINARY-LONG.
 01 WS-SECTION             BINARY-LONG.
 01 WS-OLD                 BINARY-LONG.
 01 WS-FLAG                BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-STATE                BINARY-LONG.
 01 L-RESULT               BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-X L-Y L-Z L-STATE L-RESULT.
     MOVE 0 TO L-RESULT
     IF L-Y < DM-MIN-Y(CK-DIM(L-ROW)) OR L-Y >= DM-MIN-Y(CK-DIM(L-ROW)) + DM-HEIGHT(CK-DIM(L-ROW))
         GOBACK
     END-IF
     SET ADDRESS OF CE-CHUNK TO CK-ADDR(L-ROW)
     COMPUTE WS-CX = CK-X(L-ROW) * 16
     COMPUTE WS-CZ = CK-Z(L-ROW) * 16
     COMPUTE WS-CELL = (L-Y - DM-MIN-Y(CK-DIM(L-ROW))) * 256 + (L-Z - WS-CZ) * 16 + L-X - WS-CX + 1
     MOVE CE-STATE(WS-CELL) TO WS-OLD
     IF WS-OLD = L-STATE
         GOBACK
     END-IF
     CALL "OV-REPLACEABLE" USING WS-OLD WS-FLAG
     IF WS-FLAG = 0
         GOBACK
     END-IF
     MOVE L-STATE TO CE-STATE(WS-CELL)
     MOVE 1 TO CK-CHANGED(L-ROW) L-RESULT
     COMPUTE WS-SECTION = (WS-CELL - 1) / 4096 + 1
     IF CB-S-LIGHT(WS-OLD + 1) > 0
         SUBTRACT 1 FROM CK-SOURCES(L-ROW, WS-SECTION)
     END-IF
     IF CB-S-LIGHT(L-STATE + 1) > 0
         ADD 1 TO CK-SOURCES(L-ROW, WS-SECTION)
     END-IF
     CALL "BR-ADJUST" USING L-ROW WS-SECTION WS-OLD L-STATE
     IF CK-LIT(L-ROW) = 1 AND CK-RESEND(L-ROW) = 0
         MOVE 1 TO CK-RESEND(L-ROW)
         ADD 1 TO GP-FLUSH
     END-IF
     GOBACK.
 END PROGRAM OV-APPLY-ROW.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. OV-PEND-ADD.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY GENOVER.
 01 WS-I                   BINARY-LONG.
 01 WS-FROM                BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-STATE                BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z L-STATE.
     IF GP-COUNT >= GP-MAX
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > GP-COUNT - GP-DROP
             COMPUTE WS-FROM = WS-I + GP-DROP
             MOVE GP-ENTRY(WS-FROM) TO GP-ENTRY(WS-I)
         END-PERFORM
         SUBTRACT GP-DROP FROM GP-COUNT
         ADD GP-DROP TO GP-LOST
     END-IF
     ADD 1 TO GP-COUNT
     MOVE L-DIM TO GP-DIM(GP-COUNT)
     COMPUTE GP-CX(GP-COUNT) = (L-X - FUNCTION MOD(L-X, 16)) / 16
     COMPUTE GP-CZ(GP-COUNT) = (L-Z - FUNCTION MOD(L-Z, 16)) / 16
     MOVE L-X TO GP-X(GP-COUNT)
     MOVE L-Y TO GP-Y(GP-COUNT)
     MOVE L-Z TO GP-Z(GP-COUNT)
     MOVE L-STATE TO GP-STATE(GP-COUNT)
     GOBACK.
 END PROGRAM OV-PEND-ADD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. OV-ROUTE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY GENOVER.
 01 WS-I                   BINARY-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-RESULT              BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM.
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > GO-COUNT
         COMPUTE WS-CX = (GO-X(WS-I) - FUNCTION MOD(GO-X(WS-I), 16)) / 16
         COMPUTE WS-CZ = (GO-Z(WS-I) - FUNCTION MOD(GO-Z(WS-I), 16)) / 16
         CALL "WORLD-FIND" USING L-DIM WS-CX WS-CZ WS-ROW
         IF WS-ROW > 0
             CALL "OV-APPLY-ROW" USING WS-ROW GO-X(WS-I) GO-Y(WS-I) GO-Z(WS-I) GO-STATE(WS-I) WS-RESULT
         ELSE
             CALL "OV-PEND-ADD" USING L-DIM GO-X(WS-I) GO-Y(WS-I) GO-Z(WS-I) GO-STATE(WS-I)
         END-IF
     END-PERFORM
     MOVE 0 TO GO-COUNT GO-LOST
     GOBACK.
 END PROGRAM OV-ROUTE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. OV-TAKE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY GENOVER.
 01 WS-I                   BINARY-LONG.
 01 WS-KEEP                BINARY-LONG.
 01 WS-RESULT              BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     MOVE 0 TO WS-KEEP
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > GP-COUNT
         IF GP-DIM(WS-I) = CK-DIM(L-ROW) AND GP-CX(WS-I) = CK-X(L-ROW) AND GP-CZ(WS-I) = CK-Z(L-ROW)
             CALL "OV-APPLY-ROW" USING L-ROW GP-X(WS-I) GP-Y(WS-I) GP-Z(WS-I) GP-STATE(WS-I) WS-RESULT
         ELSE
             ADD 1 TO WS-KEEP
             MOVE GP-ENTRY(WS-I) TO GP-ENTRY(WS-KEEP)
         END-IF
     END-PERFORM
     MOVE WS-KEEP TO GP-COUNT
     GOBACK.
 END PROGRAM OV-TAKE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. OV-FLUSH.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY GENOVER.
 01 WS-READY               PIC 9 VALUE 0.
 01 WS-CAPACITY            BINARY-LONG VALUE 65536.
 01 WS-ROW                 BINARY-LONG.
 01 WS-NONE                BINARY-LONG VALUE 0.
 COPY PROTO.
 PROCEDURE DIVISION.
     IF GP-FLUSH = 0
         GOBACK
     END-IF
     IF WS-READY = 0
         CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
         MOVE 1 TO WS-READY
     END-IF
     PERFORM VARYING WS-ROW FROM 1 BY 1 UNTIL WS-ROW > CK-COUNT
         IF CK-USED(WS-ROW) = 1 AND CK-RESEND(WS-ROW) = 1
             MOVE 0 TO CK-RESEND(WS-ROW)
             CALL "LIGHT-CHUNK" USING WS-ROW
             CALL "PB-RESET" USING PB-BUFFER
             CALL "CHUNK-PACKET-BUILD" USING CK-DIM(WS-ROW) CK-X(WS-ROW) CK-Z(WS-ROW) PB-BUFFER
             CALL "VIEWERS-SEND" USING CK-DIM(WS-ROW) CK-X(WS-ROW) CK-Z(WS-ROW) WS-NONE PB-BUFFER
         END-IF
     END-PERFORM
     MOVE 0 TO GP-FLUSH
     GOBACK.
 END PROGRAM OV-FLUSH.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. OV-RESET.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY GENOVER.
 PROCEDURE DIVISION.
     MOVE 0 TO GP-COUNT GP-LOST GP-FLUSH GO-COUNT GO-LOST
     GOBACK.
 END PROGRAM OV-RESET.
