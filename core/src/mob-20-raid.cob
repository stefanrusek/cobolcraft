*> Raids (docs/protocol/20 sections 14.2 and 14.3; lane 002-lane-mobsb5, T8901). State: core/copy/RAIDSTATE.cpy.
*>
*>   RAID-NUM-GROUPS USING difficulty (0 peaceful to 3 hard), waves out
*>   RAID-DEFAULT USING type (1 vindicator, 2 evoker, 3 pillager, 4 witch, 5 ravager), index 0 to 7, count out    the default spawns per wave table
*>   RAID-BONUS-MAX USING type, difficulty, wave number, bonus group (0/1), easy draw (0 or 1), max out
*>   RAID-WAVE-COUNT USING type, wave number, difficulty, bonus group, count out   default plus nextInt(max + 1) (two draws on Easy for vindicators and pillagers)
*>   RAID-ENCHANT-ODDS USING omen level, odds out (thousandths)
*>   RAID-OMEN-ADD USING omen level, amplifier, new level out   clamp(level + amplifier + 1, 0, 5)
*>   RAID-SPAWN-OFFSET USING cooldown, start angle, attempt, draw x, draw z, x out, z out   one attempt of findRandomSpawnPos(8)
*>   RAID-IS-VILLAGE USING dim, x, y, z, yes out       a village point of interest (bed, bell, job site) within one section of the position's section
*>   RAID-CREATE-OR-EXTEND USING player row, x, y, z, slot out      createOrExtendRaid: the centre is the average of the village points within 64 blocks
*>   RAID-PLAYER-TICK USING player row                 Bad Omen in a village becomes Raid Omen; Raid Omen with 1 tick left starts or extends a raid
*> Gaps: the raids game rule and the can_start_raid attribute (no game rule store is readable), the points of interest are not validated against the world or tested for
*> being occupied, getRaidAt for a position uses a 64 block box around the centre (the document does not say).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. RAID-NUM-GROUPS.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 LINKAGE SECTION.
 01 L-DIFF                  BINARY-LONG.
 01 L-N                     BINARY-LONG.
 PROCEDURE DIVISION USING L-DIFF L-N.
     EVALUATE L-DIFF
         WHEN 1
             MOVE 3 TO L-N
         WHEN 2
             MOVE 5 TO L-N
         WHEN 3
             MOVE 7 TO L-N
         WHEN OTHER
             MOVE 0 TO L-N
     END-EVALUATE
     GOBACK.
 END PROGRAM RAID-NUM-GROUPS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RAID-DEFAULT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-TABLE.
    05 FILLER               PIC X(8) VALUE "00201425".
    05 FILLER               PIC X(8) VALUE "00000112".
    05 FILLER               PIC X(8) VALUE "04334442".
    05 FILLER               PIC X(8) VALUE "00003001".
    05 FILLER               PIC X(8) VALUE "00010102".
 01 WS-ROWS REDEFINES WS-TABLE.
    05 WS-ROW               OCCURS 5 TIMES.
       10 WS-CELL           PIC 9 OCCURS 8 TIMES.
 LINKAGE SECTION.
 01 L-TYPE                  BINARY-LONG.
 01 L-INDEX                 BINARY-LONG.
 01 L-COUNT                 BINARY-LONG.
 PROCEDURE DIVISION USING L-TYPE L-INDEX L-COUNT.
     MOVE WS-CELL(L-TYPE, L-INDEX + 1) TO L-COUNT
     GOBACK.
 END PROGRAM RAID-DEFAULT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RAID-BONUS-MAX.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 LINKAGE SECTION.
 01 L-TYPE                  BINARY-LONG.
 01 L-DIFF                  BINARY-LONG.
 01 L-WAVE                  BINARY-LONG.
 01 L-BONUS                 BINARY-LONG.
 01 L-EASY                  BINARY-LONG.
 01 L-MAX                   BINARY-LONG.
 PROCEDURE DIVISION USING L-TYPE L-DIFF L-WAVE L-BONUS L-EASY L-MAX.
     MOVE 0 TO L-MAX
     EVALUATE L-TYPE
         WHEN 1
         WHEN 3
             EVALUATE L-DIFF
                 WHEN 1
                     MOVE L-EASY TO L-MAX
                 WHEN 2
                     MOVE 1 TO L-MAX
                 WHEN OTHER
                     MOVE 2 TO L-MAX
             END-EVALUATE
         WHEN 4
             IF L-DIFF NOT = 1 AND L-WAVE > 2 AND L-WAVE NOT = 4
                 MOVE 1 TO L-MAX
             END-IF
         WHEN 5
             IF L-DIFF NOT = 1 AND L-BONUS = 1
                 MOVE 1 TO L-MAX
             END-IF
         WHEN OTHER
             MOVE 0 TO L-MAX
     END-EVALUATE
     GOBACK.
 END PROGRAM RAID-BONUS-MAX.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RAID-WAVE-COUNT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-INDEX                BINARY-LONG.
 01 WS-EASY                 BINARY-LONG.
 01 WS-MAX                  BINARY-LONG.
 01 WS-DEF                  BINARY-LONG.
 01 WS-DRAW                 BINARY-LONG.
 01 WS-SALT                 BINARY-LONG VALUE 73.
 01 WS-BOUND                BINARY-LONG.
 LINKAGE SECTION.
 01 L-TYPE                  BINARY-LONG.
 01 L-WAVE                  BINARY-LONG.
 01 L-DIFF                  BINARY-LONG.
 01 L-BONUS                 BINARY-LONG.
 01 L-COUNT                 BINARY-LONG.
 PROCEDURE DIVISION USING L-TYPE L-WAVE L-DIFF L-BONUS L-COUNT.
     IF L-BONUS = 1
         CALL "RAID-NUM-GROUPS" USING L-DIFF WS-INDEX
     ELSE
         MOVE L-WAVE TO WS-INDEX
     END-IF
     CALL "RAID-DEFAULT" USING L-TYPE WS-INDEX WS-DEF
     MOVE 0 TO WS-EASY
     IF L-DIFF = 1 AND (L-TYPE = 1 OR L-TYPE = 3)
         MOVE 2 TO WS-BOUND
         CALL "XP-RANDOM" USING WS-SALT WS-BOUND WS-EASY
     END-IF
     CALL "RAID-BONUS-MAX" USING L-TYPE L-DIFF L-WAVE L-BONUS WS-EASY WS-MAX
     MOVE 0 TO WS-DRAW
     IF WS-MAX > 0
         COMPUTE WS-BOUND = WS-MAX + 1
         CALL "XP-RANDOM" USING WS-SALT WS-BOUND WS-DRAW
     END-IF
     COMPUTE L-COUNT = WS-DEF + WS-DRAW
     GOBACK.
 END PROGRAM RAID-WAVE-COUNT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RAID-ENCHANT-ODDS.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 LINKAGE SECTION.
 01 L-OMEN                  BINARY-LONG.
 01 L-ODDS                  BINARY-LONG.
 PROCEDURE DIVISION USING L-OMEN L-ODDS.
     EVALUATE L-OMEN
         WHEN 2
             MOVE 100 TO L-ODDS
         WHEN 3
             MOVE 250 TO L-ODDS
         WHEN 4
             MOVE 500 TO L-ODDS
         WHEN 5
             MOVE 750 TO L-ODDS
         WHEN OTHER
             MOVE 0 TO L-ODDS
     END-EVALUATE
     GOBACK.
 END PROGRAM RAID-ENCHANT-ODDS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RAID-OMEN-ADD.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 LINKAGE SECTION.
 01 L-LEVEL                 BINARY-LONG.
 01 L-AMP                   BINARY-LONG.
 01 L-NEW                   BINARY-LONG.
 PROCEDURE DIVISION USING L-LEVEL L-AMP L-NEW.
     COMPUTE L-NEW = FUNCTION MAX(0, FUNCTION MIN(5, L-LEVEL + L-AMP + 1))
     GOBACK.
 END PROGRAM RAID-OMEN-ADD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RAID-SPAWN-OFFSET.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-N                    BINARY-LONG.
 01 WS-F                    FLOAT-LONG.
 01 WS-FF                   BINARY-LONG.
 01 WS-A                    FLOAT-LONG.
 LINKAGE SECTION.
 01 L-COOLDOWN              BINARY-LONG.
 01 L-START                 FLOAT-LONG.
 01 L-ATTEMPT               BINARY-LONG.
 01 L-DRAW-X                BINARY-LONG.
 01 L-DRAW-Z                BINARY-LONG.
 01 L-X                     BINARY-LONG.
 01 L-Z                     BINARY-LONG.
 PROCEDURE DIVISION USING L-COOLDOWN L-START L-ATTEMPT L-DRAW-X L-DRAW-Z L-X L-Z.
     COMPUTE WS-N = L-COOLDOWN / 20
     COMPUTE WS-F = 0.22 * WS-N - 0.24
     COMPUTE WS-FF = FUNCTION INTEGER(WS-F)
     COMPUTE WS-A = L-START + FUNCTION PI * L-ATTEMPT / 8
     COMPUTE L-X = FUNCTION INTEGER(FUNCTION COS(WS-A) * 32 * WS-F) + L-DRAW-X * WS-FF
     COMPUTE L-Z = FUNCTION INTEGER(FUNCTION SIN(WS-A) * 32 * WS-F) + L-DRAW-Z * WS-FF
     GOBACK.
 END PROGRAM RAID-SPAWN-OFFSET.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RAID-IS-VILLAGE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY VILPOIX.
 01 WS-I                    BINARY-LONG.
 01 WS-SX                   BINARY-LONG.
 01 WS-SY                   BINARY-LONG.
 01 WS-SZ                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIM                   BINARY-LONG.
 01 L-X                     BINARY-LONG.
 01 L-Y                     BINARY-LONG.
 01 L-Z                     BINARY-LONG.
 01 L-YES                   BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z L-YES.
     MOVE 0 TO L-YES
     COMPUTE WS-SX = FUNCTION INTEGER(L-X / 16)
     COMPUTE WS-SY = FUNCTION INTEGER(L-Y / 16)
     COMPUTE WS-SZ = FUNCTION INTEGER(L-Z / 16)
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > PX-MAX OR L-YES = 1
         IF PX-KIND(WS-I) > 0 AND PX-DIM(WS-I) = L-DIM
             IF FUNCTION ABS(FUNCTION INTEGER(PX-X(WS-I) / 16) - WS-SX) <= 1
                     AND FUNCTION ABS(FUNCTION INTEGER(PX-Y(WS-I) / 16) - WS-SY) <= 1
                     AND FUNCTION ABS(FUNCTION INTEGER(PX-Z(WS-I) / 16) - WS-SZ) <= 1
                 MOVE 1 TO L-YES
             END-IF
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM RAID-IS-VILLAGE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RAID-CREATE-OR-EXTEND.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY VILPOIX.
 COPY RAIDSTATE.
 01 WS-I                    BINARY-LONG.
 01 WS-N                    BINARY-LONG.
 01 WS-SUM-X                BINARY-LONG.
 01 WS-SUM-Y                BINARY-LONG.
 01 WS-SUM-Z                BINARY-LONG.
 01 WS-CX                   BINARY-LONG.
 01 WS-CY                   BINARY-LONG.
 01 WS-CZ                   BINARY-LONG.
 01 WS-LEVEL                BINARY-LONG.
 01 WS-LEFT                 BINARY-LONG.
 01 WS-AMP                  BINARY-LONG.
 01 WS-OLD                 BINARY-LONG.
 01 WS-ROMEN                BINARY-LONG VALUE 34.
 LINKAGE SECTION.
 01 L-PLAYER                BINARY-LONG.
 01 L-X                     BINARY-LONG.
 01 L-Y                     BINARY-LONG.
 01 L-Z                     BINARY-LONG.
 01 L-SLOT                  BINARY-LONG.
 PROCEDURE DIVISION USING L-PLAYER L-X L-Y L-Z L-SLOT.
     MOVE 0 TO L-SLOT WS-N WS-SUM-X WS-SUM-Y WS-SUM-Z
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > PX-MAX
         IF PX-KIND(WS-I) > 0 AND PX-DIM(WS-I) = PL-DIM(L-PLAYER)
             IF FUNCTION ABS(PX-X(WS-I) - L-X) <= 64 AND FUNCTION ABS(PX-Y(WS-I) - L-Y) <= 64 AND FUNCTION ABS(PX-Z(WS-I) - L-Z) <= 64
                 ADD 1 TO WS-N
                 ADD PX-X(WS-I) TO WS-SUM-X
                 ADD PX-Y(WS-I) TO WS-SUM-Y
                 ADD PX-Z(WS-I) TO WS-SUM-Z
             END-IF
         END-IF
     END-PERFORM
     IF WS-N > 0
         COMPUTE WS-CX = FUNCTION INTEGER(WS-SUM-X / WS-N)
         COMPUTE WS-CY = FUNCTION INTEGER(WS-SUM-Y / WS-N)
         COMPUTE WS-CZ = FUNCTION INTEGER(WS-SUM-Z / WS-N)
     ELSE
         MOVE L-X TO WS-CX
         MOVE L-Y TO WS-CY
         MOVE L-Z TO WS-CZ
     END-IF
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > RD-MAX OR L-SLOT > 0
         IF RD-USED(WS-I) = 1 AND RD-STATUS(WS-I) = 1 AND RD-DIM(WS-I) = PL-DIM(L-PLAYER)
                 AND RD-CX(WS-I) = WS-CX AND RD-CY(WS-I) = WS-CY AND RD-CZ(WS-I) = WS-CZ
             MOVE WS-I TO L-SLOT
         END-IF
     END-PERFORM
     IF L-SLOT = 0
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > RD-MAX OR L-SLOT > 0
             IF RD-USED(WS-I) = 0
                 INITIALIZE RD-ENTRY(WS-I)
                 ADD 1 TO RD-NEXT-ID
                 MOVE 1 TO RD-USED(WS-I)
                 MOVE RD-NEXT-ID TO RD-ID(WS-I)
                 MOVE PL-DIM(L-PLAYER) TO RD-DIM(WS-I)
                 MOVE WS-CX TO RD-CX(WS-I)
                 MOVE WS-CY TO RD-CY(WS-I)
                 MOVE WS-CZ TO RD-CZ(WS-I)
                 MOVE 1 TO RD-STATUS(WS-I)
                 MOVE 300 TO RD-COOLDOWN(WS-I)
                 MOVE WS-I TO L-SLOT
             END-IF
         END-PERFORM
     END-IF
     IF L-SLOT > 0
         IF RD-STARTED(L-SLOT) = 0 OR RD-OMEN(L-SLOT) < 5
             CALL "EFFECT-LEVEL" USING L-PLAYER WS-ROMEN WS-LEVEL WS-LEFT
             IF WS-LEVEL > 0
                 COMPUTE WS-AMP = WS-LEVEL - 1
                 MOVE RD-OMEN(L-SLOT) TO WS-OLD
                 CALL "RAID-OMEN-ADD" USING WS-OLD WS-AMP RD-OMEN(L-SLOT)
             END-IF
         END-IF
     END-IF
     GOBACK.
 END PROGRAM RAID-CREATE-OR-EXTEND.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RAID-PLAYER-TICK.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY BRWORLD.
 COPY RAIDSTATE.
 01 WS-BAD                  BINARY-LONG VALUE 30.
 01 WS-ROMEN                BINARY-LONG VALUE 34.
 01 WS-LEVEL                BINARY-LONG.
 01 WS-LEFT                 BINARY-LONG.
 01 WS-AMP                  BINARY-LONG.
 01 WS-DUR                  BINARY-LONG VALUE 600.
 01 WS-FLAGS                BINARY-LONG VALUE 4.
 01 WS-X                    BINARY-LONG.
 01 WS-Y                    BINARY-LONG.
 01 WS-Z                    BINARY-LONG.
 01 WS-YES                  BINARY-LONG.
 01 WS-I                    BINARY-LONG.
 01 WS-HIT                  BINARY-LONG.
 01 WS-SLOT                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-PLAYER                BINARY-LONG.
 PROCEDURE DIVISION USING L-PLAYER.
     COMPUTE WS-X = FUNCTION INTEGER(PL-X(L-PLAYER))
     COMPUTE WS-Y = FUNCTION INTEGER(PL-Y(L-PLAYER))
     COMPUTE WS-Z = FUNCTION INTEGER(PL-Z(L-PLAYER))
     CALL "EFFECT-LEVEL" USING L-PLAYER WS-BAD WS-LEVEL WS-LEFT
     IF WS-LEVEL > 0 AND PL-MODE(L-PLAYER) NOT = 3 AND BW-DIFFICULTY > 0
         CALL "RAID-IS-VILLAGE" USING PL-DIM(L-PLAYER) WS-X WS-Y WS-Z WS-YES
         IF WS-YES = 1
*>           A raid at the position that already has the maximum omen level leaves the effect alone.
             MOVE 0 TO WS-HIT
             PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > RD-MAX
                 IF RD-USED(WS-I) = 1 AND RD-STATUS(WS-I) = 1 AND RD-DIM(WS-I) = PL-DIM(L-PLAYER) AND RD-OMEN(WS-I) >= 5
                         AND FUNCTION ABS(RD-CX(WS-I) - WS-X) <= 64 AND FUNCTION ABS(RD-CZ(WS-I) - WS-Z) <= 64
                     MOVE 1 TO WS-HIT
                 END-IF
             END-PERFORM
             IF WS-HIT = 0
                 COMPUTE WS-AMP = WS-LEVEL - 1
                 CALL "EFFECT-ADD" USING L-PLAYER WS-ROMEN WS-AMP WS-DUR WS-FLAGS
                 MOVE WS-X TO RP-X(L-PLAYER)
                 MOVE WS-Y TO RP-Y(L-PLAYER)
                 MOVE WS-Z TO RP-Z(L-PLAYER)
                 MOVE 1 TO RP-SET(L-PLAYER)
                 CALL "EFFECT-REMOVE" USING L-PLAYER WS-BAD
             END-IF
         END-IF
     END-IF
     CALL "EFFECT-LEVEL" USING L-PLAYER WS-ROMEN WS-LEVEL WS-LEFT
     IF WS-LEVEL > 0 AND WS-LEFT = 1 AND RP-SET(L-PLAYER) = 1 AND PL-MODE(L-PLAYER) NOT = 3
         CALL "RAID-CREATE-OR-EXTEND" USING L-PLAYER RP-X(L-PLAYER) RP-Y(L-PLAYER) RP-Z(L-PLAYER) WS-SLOT
         MOVE 0 TO RP-SET(L-PLAYER)
     END-IF
     GOBACK.
 END PROGRAM RAID-PLAYER-TICK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RAID-WORLD-TICK.
*> The per-tick raid work (STDMOB-SPAWN-TICK): the omen effects of every player.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-P                    BINARY-LONG.
 PROCEDURE DIVISION.
     PERFORM VARYING WS-P FROM 1 BY 1 UNTIL WS-P > 64
         IF PL-USED(WS-P) = 1 AND PL-ENTITY-ROW(WS-P) > 0
             CALL "RAID-PLAYER-TICK" USING WS-P
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM RAID-WORLD-TICK.
