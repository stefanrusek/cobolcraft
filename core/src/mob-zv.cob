*> Curing a zombie villager (docs/protocol/20 section 4.2; lane 002-lane-mobsb3, T8102). The state is ZVCURE.cpy; the villager state (profession, level, offers, xp) and the gossip of
*> the zombie villager, when it has any, move to the new villager. Gaps: the converting flag (metadata 19) is not sent, the equipment of the zombie villager is not dropped (mobs hold none
*> here), a villager killed by a zombie does not become a zombie villager yet (no profession carried over), and a converting zombie villager is not exempt from despawning.
*>
*>   ZV-USE USING player row, entity row, held key, used out   a golden apple on a zombie villager with Weakness starts the cure
*>   ZV-TICK USING entity row                                  one tick: the progress, the speed-up blocks, the conversion at 0 (the row may be gone afterwards)
*>   VL-TRANSFER USING old entity id, new entity id            the villager state and gossip of the old entity belong to the new one

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ZC-FIND.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY ZVCURE.
 01 WS-I                    BINARY-LONG.
 LINKAGE SECTION.
 01 L-ID                    BINARY-LONG.
 01 L-CREATE                BINARY-LONG.
 01 L-SLOT                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ID L-CREATE L-SLOT.
     MOVE 0 TO L-SLOT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > ZC-MAX OR L-SLOT > 0
         IF ZC-ID(WS-I) = L-ID
             MOVE WS-I TO L-SLOT
         END-IF
     END-PERFORM
     IF L-SLOT = 0 AND L-CREATE = 1
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > ZC-MAX OR L-SLOT > 0
             IF ZC-ID(WS-I) = 0
                 INITIALIZE ZC-ENTRY(WS-I)
                 MOVE L-ID TO ZC-ID(WS-I)
                 MOVE WS-I TO L-SLOT
             END-IF
         END-PERFORM
     END-IF
     GOBACK.
 END PROGRAM ZC-FIND.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. VL-TRANSFER.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY VILSTATE.
 COPY VILGOSSIP.
 01 WS-OLD                  BINARY-LONG.
 01 WS-NEW                  BINARY-LONG.
 01 WS-NO                   BINARY-LONG VALUE 0.
 01 WS-I                    BINARY-LONG.
 LINKAGE SECTION.
 01 L-OLD                   BINARY-LONG.
 01 L-NEW                   BINARY-LONG.
 PROCEDURE DIVISION USING L-OLD L-NEW.
     CALL "VL-FIND" USING L-OLD WS-NO WS-OLD
     IF WS-OLD > 0
         CALL "VL-FIND" USING L-NEW WS-NO WS-NEW
         IF WS-NEW > 0
             INITIALIZE VL-ENTRY(WS-NEW)
         END-IF
         MOVE L-NEW TO VL-ID(WS-OLD)
     END-IF
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > GS-MAX
         IF GS-VIL(WS-I) = L-OLD
             MOVE L-NEW TO GS-VIL(WS-I)
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM VL-TRANSFER.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ZV-USE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY ZVCURE.
 COPY PROTO.
 COPY BRWORLD.
 01 WS-SLOT                 BINARY-LONG.
 01 WS-YES                  BINARY-LONG VALUE 1.
 01 WS-NO                   BINARY-LONG VALUE 0.
 01 WS-WEAKNESS             BINARY-LONG VALUE 17.
 01 WS-STRENGTH             BINARY-LONG VALUE 4.
 01 WS-LEVEL                BINARY-LONG.
 01 WS-TICKS                BINARY-LONG.
 01 WS-SALT                 BINARY-LONG VALUE 141.
 01 WS-BOUND                BINARY-LONG VALUE 3600.
 01 WS-R                    BINARY-LONG.
 01 WS-TIME                 BINARY-LONG.
 01 WS-AMP                  BINARY-LONG.
 01 WS-FLAGS                BINARY-LONG VALUE 3.
 01 WS-CAPACITY             BINARY-LONG VALUE 64.
 01 WS-EVENT                BINARY-LONG VALUE 16.
 LINKAGE SECTION.
 01 L-ROW                   BINARY-LONG.
 01 L-ENTITY                BINARY-LONG.
 01 L-HELD                  PIC X(24).
 01 L-USED                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-ENTITY L-HELD L-USED.
     MOVE 0 TO L-USED
     IF L-HELD NOT = "golden_apple"
         GOBACK
     END-IF
     CALL "MEF-LEVEL" USING EN-ID(L-ENTITY) WS-WEAKNESS WS-LEVEL WS-TICKS
     IF WS-LEVEL = 0
         GOBACK
     END-IF
     CALL "ZC-FIND" USING EN-ID(L-ENTITY) WS-NO WS-SLOT
     IF WS-SLOT > 0
         GOBACK
     END-IF
     CALL "ZC-FIND" USING EN-ID(L-ENTITY) WS-YES WS-SLOT
     IF WS-SLOT = 0
         GOBACK
     END-IF
     CALL "MOB-TAKE" USING L-ROW
     CALL "XP-RANDOM" USING WS-SALT WS-BOUND WS-R
     COMPUTE WS-TIME = 2401 + WS-R
     MOVE WS-TIME TO ZC-TIME(WS-SLOT)
     MOVE PL-ENTITY-ID(L-ROW) TO ZC-PLAYER(WS-SLOT)
     CALL "MEF-REMOVE" USING EN-ID(L-ENTITY) WS-WEAKNESS
*>   Strength amplifier min(difficultyId - 1, 0): 0 on every difficulty.
     MOVE 0 TO WS-AMP
     CALL "MEF-ADD" USING EN-ID(L-ENTITY) WS-STRENGTH WS-AMP WS-TIME WS-FLAGS
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "ENTITY-EVENT-BUILD" USING EN-ID(L-ENTITY) WS-EVENT PB-BUFFER
     CALL "HEALTH-VIEWERS-SEND" USING L-ENTITY PB-BUFFER
     CALL "PB-FREE" USING PB-BUFFER
     MOVE 1 TO L-USED
     GOBACK.
 END PROGRAM ZV-USE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ZV-CONVERT.
*> USING entity row, converting player entity id: the zombie villager becomes a villager (spawn reason CONVERSION): same position, the villager state and gossip, Nausea 200 ticks,
*> level event 1027, the ZOMBIE_VILLAGER_CURED reputation event (event 1 of VG-EVENT) for the player.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-KEY                  PIC X(112).
 01 WS-ENTITY-ROW           PIC X(66).
 01 WS-STATUS               BINARY-LONG.
 01 WS-TYPE                 BINARY-LONG.
 01 WS-NEW                  BINARY-LONG.
 01 WS-X                    FLOAT-LONG.
 01 WS-Y                    FLOAT-LONG.
 01 WS-Z                    FLOAT-LONG.
 01 WS-YAW                  FLOAT-SHORT.
 01 WS-BX                   BINARY-LONG.
 01 WS-BY                   BINARY-LONG.
 01 WS-BZ                   BINARY-LONG.
 01 WS-NAUSEA               BINARY-LONG VALUE 8.
 01 WS-NAUSEA-TICKS         BINARY-LONG VALUE 200.
 01 WS-ZERO                 BINARY-LONG VALUE 0.
 01 WS-FLAGS                BINARY-LONG VALUE 3.
 01 WS-EVENT                BINARY-LONG VALUE 1027.
 01 WS-DIM                  BINARY-LONG.
 01 WS-OLD                  BINARY-LONG.
 01 WS-EVENT-CURED          BINARY-LONG VALUE 1.
 01 WS-NO-PLAYER            BINARY-LONG VALUE 0.
 LINKAGE SECTION.
 01 L-ROW                   BINARY-LONG.
 01 L-PLAYER-ID             BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-PLAYER-ID.
     MOVE "minecraft:villager" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE WS-ENTITY-ROW WS-STATUS
     MOVE EN-X(L-ROW) TO WS-X
     MOVE EN-Y(L-ROW) TO WS-Y
     MOVE EN-Z(L-ROW) TO WS-Z
     MOVE EN-YAW(L-ROW) TO WS-YAW
     MOVE EN-DIM(L-ROW) TO WS-DIM
     MOVE EN-ID(L-ROW) TO WS-OLD
     CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-X WS-Y WS-Z WS-YAW WS-NEW
     IF WS-NEW > 0
         CALL "VL-TRANSFER" USING WS-OLD EN-ID(WS-NEW)
         CALL "MEF-ADD" USING EN-ID(WS-NEW) WS-NAUSEA WS-ZERO WS-NAUSEA-TICKS WS-FLAGS
         IF L-PLAYER-ID > 0
             CALL "VG-EVENT" USING EN-ID(WS-NEW) L-PLAYER-ID WS-EVENT-CURED
         END-IF
     END-IF
     COMPUTE WS-BX = FUNCTION INTEGER(WS-X)
     COMPUTE WS-BY = FUNCTION INTEGER(WS-Y)
     COMPUTE WS-BZ = FUNCTION INTEGER(WS-Z)
     CALL "LEVEL-EVENT" USING WS-DIM WS-EVENT WS-BX WS-BY WS-BZ WS-ZERO WS-NO-PLAYER
     CALL "ENTITY-REMOVE" USING L-ROW
     GOBACK.
 END PROGRAM ZV-CONVERT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ZV-TICK.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CBLOCKS.
 COPY ZVCURE.
 01 WS-NO                   BINARY-LONG VALUE 0.
 01 WS-SLOT                 BINARY-LONG.
 01 WS-SALT                 BINARY-LONG VALUE 142.
 01 WS-SALT2                BINARY-LONG VALUE 143.
 01 WS-HUNDRED              BINARY-LONG VALUE 100.
 01 WS-TEN                  BINARY-LONG VALUE 10.
 01 WS-R                    BINARY-LONG.
 01 WS-PROGRESS             BINARY-LONG.
 01 WS-COUNT                BINARY-LONG.
 01 WS-PX                   BINARY-LONG.
 01 WS-PY                   BINARY-LONG.
 01 WS-PZ                   BINARY-LONG.
 01 WS-DX                   BINARY-LONG.
 01 WS-DY                   BINARY-LONG.
 01 WS-DZ                   BINARY-LONG.
 01 WS-BX                   BINARY-LONG.
 01 WS-BY                   BINARY-LONG.
 01 WS-BZ                   BINARY-LONG.
 01 WS-STATE                BINARY-LONG.
 01 WS-KEY48                PIC X(48).
 01 WS-PLAYER               BINARY-LONG.
 01 WS-LEN                  BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                   BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     CALL "ZC-FIND" USING EN-ID(L-ROW) WS-NO WS-SLOT
     IF WS-SLOT = 0
         GOBACK
     END-IF
     MOVE 1 TO WS-PROGRESS
     MOVE 0 TO WS-COUNT
*>   With probability 0.01 per tick the box [floor - 4, floor + 4) is scanned for up to 14 iron bars or beds, each adding 1 with probability 0.3.
     CALL "XP-RANDOM" USING WS-SALT WS-HUNDRED WS-R
     IF WS-R = 0
         COMPUTE WS-PX = FUNCTION INTEGER(EN-X(L-ROW))
         COMPUTE WS-PY = FUNCTION INTEGER(EN-Y(L-ROW))
         COMPUTE WS-PZ = FUNCTION INTEGER(EN-Z(L-ROW))
         PERFORM VARYING WS-DX FROM -4 BY 1 UNTIL WS-DX > 3
             PERFORM VARYING WS-DY FROM -4 BY 1 UNTIL WS-DY > 3
                 PERFORM VARYING WS-DZ FROM -4 BY 1 UNTIL WS-DZ > 3
                     IF WS-COUNT < 14
                         COMPUTE WS-BX = WS-PX + WS-DX
                         COMPUTE WS-BY = WS-PY + WS-DY
                         COMPUTE WS-BZ = WS-PZ + WS-DZ
                         PERFORM CANDIDATE
                     END-IF
                 END-PERFORM
             END-PERFORM
         END-PERFORM
     END-IF
     ADD WS-COUNT TO WS-PROGRESS
     SUBTRACT WS-PROGRESS FROM ZC-TIME(WS-SLOT)
     IF ZC-TIME(WS-SLOT) <= 0
         MOVE ZC-PLAYER(WS-SLOT) TO WS-PLAYER
         INITIALIZE ZC-ENTRY(WS-SLOT)
         CALL "ZV-CONVERT" USING L-ROW WS-PLAYER
     END-IF
     GOBACK.

 CANDIDATE.
     CALL "WORLD-GET-BLOCK" USING EN-DIM(L-ROW) WS-BX WS-BY WS-BZ WS-STATE
     IF WS-STATE > 0 AND WS-STATE < CB-STATE-COUNT
         MOVE CB-KEY(CB-S-BLOCK(WS-STATE + 1) + 1) TO WS-KEY48
         COMPUTE WS-LEN = FUNCTION LENGTH(FUNCTION TRIM(WS-KEY48))
         IF WS-KEY48 = "minecraft:iron_bars" OR (WS-LEN > 4 AND WS-KEY48(WS-LEN - 3:4) = "_bed")
             CALL "XP-RANDOM" USING WS-SALT2 WS-TEN WS-R
             IF WS-R < 3
                 ADD 1 TO WS-COUNT
             END-IF
         END-IF
     END-IF.
 END PROGRAM ZV-TICK.
