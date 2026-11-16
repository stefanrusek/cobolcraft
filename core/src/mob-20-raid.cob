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
 COPY DIMENSIONS.
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
 01 WS-RAIDS-RULE           PIC X(40) VALUE "raids".
 01 WS-RAIDS                BINARY-DOUBLE.
 LINKAGE SECTION.
 01 L-PLAYER                BINARY-LONG.
 01 L-X                     BINARY-LONG.
 01 L-Y                     BINARY-LONG.
 01 L-Z                     BINARY-LONG.
 01 L-SLOT                  BINARY-LONG.
 PROCEDURE DIVISION USING L-PLAYER L-X L-Y L-Z L-SLOT.
     MOVE 0 TO L-SLOT WS-N WS-SUM-X WS-SUM-Y WS-SUM-Z
*>   Nothing for a spectator (the caller), with the raids game rule false or where can_start_raid is false (the Nether, 37-1 section 3.8).
     CALL "BR-RULE-GET" USING WS-RAIDS-RULE WS-RAIDS
     IF WS-RAIDS = 0 OR DM-KEY(PL-DIM(L-PLAYER)) = "minecraft:the_nether"
         GOBACK
     END-IF
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
 PROGRAM-ID. RAID-AT.
*> USING dim, x, y, z, slot out (0 none): getRaidAt (44 section 5): the ongoing raid whose centre is nearest to the position, below squared distance 9216 (96 blocks).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY RAIDSTATE.
 01 WS-I                    BINARY-LONG.
 01 WS-D2                   FLOAT-LONG.
 01 WS-BEST                 FLOAT-LONG.
 LINKAGE SECTION.
 01 L-DIM                   BINARY-LONG.
 01 L-X                     BINARY-LONG.
 01 L-Y                     BINARY-LONG.
 01 L-Z                     BINARY-LONG.
 01 L-SLOT                  BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z L-SLOT.
     MOVE 0 TO L-SLOT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > RD-MAX
         IF RD-USED(WS-I) = 1 AND RD-STATUS(WS-I) = 1 AND RD-DIM(WS-I) = L-DIM
             COMPUTE WS-D2 = (RD-CX(WS-I) - L-X) ** 2 + (RD-CY(WS-I) - L-Y) ** 2 + (RD-CZ(WS-I) - L-Z) ** 2
             IF WS-D2 < 9216 AND (L-SLOT = 0 OR WS-D2 < WS-BEST)
                 MOVE WS-D2 TO WS-BEST
                 MOVE WS-I TO L-SLOT
             END-IF
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM RAID-AT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RAID-RAIDER-STEP.
*> USING entity row: Raider.aiStep (20 section 14.2) for a raider species (vindicator, evoker, pillager, ravager, witch, illusioner): without a raid, on a game tick that is a
*> multiple of 20, the raider joins the raid at its position at wave groups + 1 (the no-action time of canJoinRaid is not kept).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY STDMOBS.
 COPY RAIDSTATE.
 01 WS-M                    BINARY-LONG.
 01 WS-I                    BINARY-LONG.
 01 WS-X                    BINARY-LONG.
 01 WS-Y                    BINARY-LONG.
 01 WS-Z                    BINARY-LONG.
 01 WS-SLOT                 BINARY-LONG.
 01 WS-WAVE                 BINARY-LONG.
 01 WS-ZERO                 BINARY-LONG VALUE 0.
 01 WS-MEMBER               BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                   BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     IF FUNCTION MOD(CW-TICKS, 20) NOT = 0
         GOBACK
     END-IF
     CALL "STDMOB-INDEX" USING EN-TYPE(L-ROW) WS-M
     IF WS-M = 0
         GOBACK
     END-IF
     IF NOT (SM-KEY(WS-M) = "vindicator" OR "evoker" OR "pillager" OR "ravager" OR "witch" OR "illusioner")
         GOBACK
     END-IF
     MOVE 0 TO WS-MEMBER
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > RR-MAX
         IF RR-ID(WS-I) = EN-ID(L-ROW)
             MOVE 1 TO WS-MEMBER
         END-IF
     END-PERFORM
     IF WS-MEMBER = 1
         GOBACK
     END-IF
     COMPUTE WS-X = FUNCTION INTEGER(EN-X(L-ROW))
     COMPUTE WS-Y = FUNCTION INTEGER(EN-Y(L-ROW))
     COMPUTE WS-Z = FUNCTION INTEGER(EN-Z(L-ROW))
     CALL "RAID-AT" USING EN-DIM(L-ROW) WS-X WS-Y WS-Z WS-SLOT
     IF WS-SLOT > 0
         COMPUTE WS-WAVE = RD-GROUPS(WS-SLOT) + 1
         CALL "RAID-JOIN" USING WS-SLOT WS-WAVE L-ROW WS-ZERO
     END-IF
     GOBACK.
 END PROGRAM RAID-RAIDER-STEP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RAID-WALK.
*> USING raider row, hx out, hz out, walk out: PathfindToRaidGoal (20 section 13, priority 3): a raider that belongs to an ongoing raid, has no target, no mob rider and is not in a village walks
*> toward a point within 15 blocks of the raid centre at its walk speed (a straight line: no pathfinder; the point is chosen again every 100 ticks or on arrival). Every 20 ticks it recruits
*> the raiders within 16 blocks that have no raid into the raid's current wave (groupsSpawned + 1).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY STDMOBS.
 COPY RAIDSTATE.
 01 WS-M                    BINARY-LONG.
 01 WS-I                    BINARY-LONG.
 01 WS-SLOT                 BINARY-LONG.
 01 WS-X                    BINARY-LONG.
 01 WS-Y                    BINARY-LONG.
 01 WS-Z                    BINARY-LONG.
 01 WS-VILLAGE              BINARY-LONG.
 01 WS-N                    BINARY-LONG.
 01 WS-S                    BINARY-LONG.
 01 WS-WAVE                 BINARY-LONG.
 01 WS-ZERO                 BINARY-LONG VALUE 0.
 01 WS-MEMBER               BINARY-LONG.
 01 WS-COUNT                BINARY-LONG VALUE 3.
 01 WS-ARGS.
    05 WS-ARG               BINARY-DOUBLE OCCURS 16 TIMES.
 01 WS-R                    BINARY-DOUBLE.
 01 WS-Q                    BINARY-DOUBLE.
 01 WS-DX                   FLOAT-LONG.
 01 WS-DZ                   FLOAT-LONG.
 01 WS-H                    FLOAT-LONG.
 01 WS-SPEED                FLOAT-LONG.
 LINKAGE SECTION.
 01 L-ROW                   BINARY-LONG.
 01 L-HX                    FLOAT-LONG.
 01 L-HZ                    FLOAT-LONG.
 01 L-WALK                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-HX L-HZ L-WALK.
     MOVE 0 TO L-HX L-HZ L-WALK WS-SLOT
     CALL "STDMOB-INDEX" USING EN-TYPE(L-ROW) WS-M
     IF WS-M = 0
         GOBACK
     END-IF
     IF NOT (SM-KEY(WS-M) = "vindicator" OR "evoker" OR "pillager" OR "ravager" OR "witch" OR "illusioner")
         GOBACK
     END-IF
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > RR-MAX
         IF RR-ID(WS-I) = EN-ID(L-ROW)
             MOVE RR-RAID(WS-I) TO WS-SLOT
         END-IF
     END-PERFORM
     IF WS-SLOT = 0
         GOBACK
     END-IF
     IF RD-USED(WS-SLOT) = 0 OR RD-STATUS(WS-SLOT) NOT = 1
         GOBACK
     END-IF
*>   Recruit nearby raiders without a raid every 20 ticks.
     IF FUNCTION MOD(CW-TICKS, 20) = 0
         COMPUTE WS-WAVE = RD-GROUPS(WS-SLOT) + 1
         PERFORM VARYING WS-N FROM 1 BY 1 UNTIL WS-N > EN-COUNT
             IF WS-N NOT = L-ROW AND EN-USED(WS-N) = 1 AND EN-PLAYER(WS-N) = 0 AND EN-HEALTH(WS-N) > 0 AND EN-DIM(WS-N) = EN-DIM(L-ROW)
                 CALL "STDMOB-INDEX" USING EN-TYPE(WS-N) WS-S
                 IF WS-S > 0
                     IF SM-KEY(WS-S) = "vindicator" OR "evoker" OR "pillager" OR "ravager" OR "witch" OR "illusioner"
                         MOVE 0 TO WS-MEMBER
                         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > RR-MAX
                             IF RR-ID(WS-I) = EN-ID(WS-N)
                                 MOVE 1 TO WS-MEMBER
                             END-IF
                         END-PERFORM
                         IF WS-MEMBER = 0 AND FUNCTION ABS(EN-X(WS-N) - EN-X(L-ROW)) <= 16 AND FUNCTION ABS(EN-Z(WS-N) - EN-Z(L-ROW)) <= 16
                                 AND FUNCTION ABS(EN-Y(WS-N) - EN-Y(L-ROW)) <= 16
                             CALL "RAID-JOIN" USING WS-SLOT WS-WAVE WS-N WS-ZERO
                         END-IF
                     END-IF
                 END-IF
             END-IF
         END-PERFORM
     END-IF
     IF EN-TARGET(L-ROW) > 0 OR EN-PASS(L-ROW) > 0
         GOBACK
     END-IF
     COMPUTE WS-X = FUNCTION INTEGER(EN-X(L-ROW))
     COMPUTE WS-Y = FUNCTION INTEGER(EN-Y(L-ROW))
     COMPUTE WS-Z = FUNCTION INTEGER(EN-Z(L-ROW))
     CALL "RAID-IS-VILLAGE" USING EN-DIM(L-ROW) WS-X WS-Y WS-Z WS-VILLAGE
     IF WS-VILLAGE = 1
         GOBACK
     END-IF
     COMPUTE WS-DX = EN-DEST-X(L-ROW) + 0.5 - EN-X(L-ROW)
     COMPUTE WS-DZ = EN-DEST-Z(L-ROW) + 0.5 - EN-Z(L-ROW)
     COMPUTE WS-H = FUNCTION SQRT(WS-DX * WS-DX + WS-DZ * WS-DZ)
     IF (EN-DEST-X(L-ROW) = 0 AND EN-DEST-Z(L-ROW) = 0) OR WS-H < 1.5 OR FUNCTION MOD(CW-TICKS + EN-ID(L-ROW), 100) = 0
         MOVE EN-ID(L-ROW) TO WS-ARG(1)
         MOVE CW-TICKS TO WS-ARG(2)
         MOVE 53 TO WS-ARG(3)
         CALL "RNG-HASH" USING WS-COUNT WS-ARGS WS-R
         COMPUTE EN-DEST-X(L-ROW) = RD-CX(WS-SLOT) + FUNCTION MOD(WS-R, 31) - 15
         COMPUTE WS-Q = WS-R / 31
         COMPUTE EN-DEST-Z(L-ROW) = RD-CZ(WS-SLOT) + FUNCTION MOD(WS-Q, 31) - 15
         COMPUTE WS-DX = EN-DEST-X(L-ROW) + 0.5 - EN-X(L-ROW)
         COMPUTE WS-DZ = EN-DEST-Z(L-ROW) + 0.5 - EN-Z(L-ROW)
         COMPUTE WS-H = FUNCTION SQRT(WS-DX * WS-DX + WS-DZ * WS-DZ)
     END-IF
     IF WS-H > 0.1
         COMPUTE WS-SPEED = SM-WALK-MILLI(WS-M) / 1000
         COMPUTE L-HX = WS-DX / WS-H * WS-SPEED
         COMPUTE L-HZ = WS-DZ / WS-H * WS-SPEED
         MOVE 1 TO L-WALK
     END-IF
     GOBACK.
 END PROGRAM RAID-WALK.

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
             CALL "RAID-AT" USING PL-DIM(L-PLAYER) WS-X WS-Y WS-Z WS-SLOT
             IF WS-SLOT > 0
                 IF RD-OMEN(WS-SLOT) >= 5
                     MOVE 1 TO WS-HIT
                 END-IF
             END-IF
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
 PROGRAM-ID. RAID-SPAWN-POS.
*> USING raid slot, found out: getValidSpawnPos / findRandomSpawnPos(8) (20 section 14.2): up to 8 attempts on the ring of RAID-SPAWN-OFFSET; the position is kept in RD-SX/SY/SZ.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY RAIDSTATE.
 01 WS-A                    BINARY-LONG.
 01 WS-N                    BINARY-LONG.
 01 WS-START                FLOAT-LONG.
 01 WS-DRAW-X               BINARY-LONG.
 01 WS-DRAW-Z               BINARY-LONG.
 01 WS-OX                   BINARY-LONG.
 01 WS-OZ                   BINARY-LONG.
 01 WS-X                    BINARY-LONG.
 01 WS-Z                    BINARY-LONG.
 01 WS-Y                    BINARY-LONG.
 01 WS-GROUND               BINARY-LONG.
 01 WS-YES                  BINARY-LONG.
 01 WS-SALT                 BINARY-LONG VALUE 74.
 01 WS-BOUND                BINARY-LONG.
 01 WS-R                    BINARY-LONG.
 LINKAGE SECTION.
 01 L-SLOT                  BINARY-LONG.
 01 L-FOUND                 BINARY-LONG.
 PROCEDURE DIVISION USING L-SLOT L-FOUND.
     MOVE 0 TO L-FOUND
     COMPUTE WS-N = RD-COOLDOWN(L-SLOT) / 20
     MOVE 6283 TO WS-BOUND
     CALL "XP-RANDOM" USING WS-SALT WS-BOUND WS-R
     COMPUTE WS-START = WS-R / 1000
     PERFORM VARYING WS-A FROM 0 BY 1 UNTIL WS-A > 7 OR L-FOUND = 1
         MOVE 3 TO WS-BOUND
         CALL "XP-RANDOM" USING WS-SALT WS-BOUND WS-DRAW-X
         CALL "XP-RANDOM" USING WS-SALT WS-BOUND WS-DRAW-Z
         CALL "RAID-SPAWN-OFFSET" USING RD-COOLDOWN(L-SLOT) WS-START WS-A WS-DRAW-X WS-DRAW-Z WS-OX WS-OZ
         COMPUTE WS-X = RD-CX(L-SLOT) + WS-OX
         COMPUTE WS-Z = RD-CZ(L-SLOT) + WS-OZ
         CALL "TRADER-GROUND" USING RD-DIM(L-SLOT) WS-X WS-Z RD-CY(L-SLOT) WS-GROUND WS-Y
         IF WS-GROUND = 1
             IF FUNCTION ABS(WS-Y - RD-CY(L-SLOT)) <= 96
                 MOVE 0 TO WS-YES
                 IF WS-N > 7
                     CALL "RAID-IS-VILLAGE" USING RD-DIM(L-SLOT) WS-X WS-Y WS-Z WS-YES
                 END-IF
                 IF WS-YES = 0
                     MOVE WS-X TO RD-SX(L-SLOT)
                     MOVE WS-Y TO RD-SY(L-SLOT)
                     MOVE WS-Z TO RD-SZ(L-SLOT)
                     MOVE 1 TO RD-SPAWN-SET(L-SLOT)
                     MOVE 1 TO L-FOUND
                 END-IF
             END-IF
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM RAID-SPAWN-POS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RAID-JOIN.
*> USING raid slot, wave, entity row, leader (0/1): the raider becomes a member; its health joins the total.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY RAIDSTATE.
 01 WS-I                    BINARY-LONG.
 01 WS-DONE                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-SLOT                  BINARY-LONG.
 01 L-WAVE                  BINARY-LONG.
 01 L-ROW                   BINARY-LONG.
 01 L-LEADER                BINARY-LONG.
 PROCEDURE DIVISION USING L-SLOT L-WAVE L-ROW L-LEADER.
     MOVE 0 TO WS-DONE
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > RR-MAX OR WS-DONE = 1
         IF RR-ID(WS-I) = 0
             INITIALIZE RR-ENTRY(WS-I)
             MOVE EN-ID(L-ROW) TO RR-ID(WS-I)
             MOVE L-SLOT TO RR-RAID(WS-I)
             MOVE L-WAVE TO RR-WAVE(WS-I)
             MOVE L-LEADER TO RR-LEADER(WS-I)
             IF L-LEADER = 1
                 MOVE EN-ID(L-ROW) TO RD-LEADER(L-SLOT)
             END-IF
             COMPUTE RD-TOTAL(L-SLOT) = RD-TOTAL(L-SLOT) + EN-HEALTH(L-ROW) * 1000
             MOVE 1 TO WS-DONE
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM RAID-JOIN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RAID-ALIVE.
*> USING raid slot, count out: the members that are alive entities.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY RAIDSTATE.
 01 WS-I                    BINARY-LONG.
 01 WS-E                    BINARY-LONG.
 LINKAGE SECTION.
 01 L-SLOT                  BINARY-LONG.
 01 L-COUNT                 BINARY-LONG.
 PROCEDURE DIVISION USING L-SLOT L-COUNT.
     MOVE 0 TO L-COUNT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > RR-MAX
         IF RR-ID(WS-I) > 0 AND RR-RAID(WS-I) = L-SLOT
             PERFORM VARYING WS-E FROM 1 BY 1 UNTIL WS-E > EN-COUNT
                 IF EN-USED(WS-E) = 1 AND EN-ID(WS-E) = RR-ID(WS-I) AND EN-HEALTH(WS-E) > 0
                     ADD 1 TO L-COUNT
                 END-IF
             END-PERFORM
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM RAID-ALIVE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RAID-SPAWN-GROUP.
*> USING raid slot, bonus group (0/1): spawnGroup (20 section 14.3): vindicators, evokers, pillagers, witches, ravagers at the wave spawn position, one leader per call among
*> the raiders that can lead, the riders of the ravagers (they ride it: MOB-MOUNT), then groupsSpawned + 1.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY BRWORLD.
 COPY RAIDSTATE.
 01 WS-KEYS.
    05 FILLER               PIC X(112) VALUE "minecraft:vindicator".
    05 FILLER               PIC X(112) VALUE "minecraft:evoker".
    05 FILLER               PIC X(112) VALUE "minecraft:pillager".
    05 FILLER               PIC X(112) VALUE "minecraft:witch".
    05 FILLER               PIC X(112) VALUE "minecraft:ravager".
 01 WS-KEY-TABLE REDEFINES WS-KEYS.
    05 WS-KEY               PIC X(112) OCCURS 5 TIMES.
 01 WS-ENTITY-ROW           PIC X(66).
 01 WS-STATUS               BINARY-LONG.
 01 WS-TYPE                 BINARY-LONG OCCURS 5 TIMES.
 01 WS-WAVE                 BINARY-LONG.
 01 WS-T                    BINARY-LONG.
 01 WS-K                    BINARY-LONG.
 01 WS-COUNT                BINARY-LONG.
 01 WS-LEADER-DONE          BINARY-LONG.
 01 WS-LEAD                 BINARY-LONG.
 01 WS-RAVAGERS             BINARY-LONG.
 01 WS-ROW                  BINARY-LONG.
 01 WS-RIDER-TYPE           BINARY-LONG.
 01 WS-RIDER                BINARY-LONG.
 01 WS-MOUNTED              BINARY-LONG.
 01 WS-X                    FLOAT-LONG.
 01 WS-Y                    FLOAT-LONG.
 01 WS-Z                    FLOAT-LONG.
 01 WS-YAW                  FLOAT-SHORT VALUE 0.
 01 WS-DIFF                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-SLOT                  BINARY-LONG.
 01 L-BONUS                 BINARY-LONG.
 PROCEDURE DIVISION USING L-SLOT L-BONUS.
     PERFORM VARYING WS-T FROM 1 BY 1 UNTIL WS-T > 5
         CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY(WS-T) WS-TYPE(WS-T) WS-ENTITY-ROW WS-STATUS
     END-PERFORM
     MOVE 0 TO RD-TOTAL(L-SLOT)
     COMPUTE WS-WAVE = RD-GROUPS(L-SLOT) + 1
     MOVE BW-DIFFICULTY TO WS-DIFF
     COMPUTE WS-X = RD-SX(L-SLOT) + 0.5
     COMPUTE WS-Y = RD-SY(L-SLOT)
     COMPUTE WS-Z = RD-SZ(L-SLOT) + 0.5
     MOVE 0 TO WS-LEADER-DONE WS-RAVAGERS
     PERFORM VARYING WS-T FROM 1 BY 1 UNTIL WS-T > 5
         CALL "RAID-WAVE-COUNT" USING WS-T WS-WAVE WS-DIFF L-BONUS WS-COUNT
         PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > WS-COUNT
             CALL "MOB-SPAWN" USING RD-DIM(L-SLOT) WS-TYPE(WS-T) WS-X WS-Y WS-Z WS-YAW WS-ROW
             MOVE 0 TO WS-LEAD
             IF WS-LEADER-DONE = 0 AND WS-T < 4
                 MOVE 1 TO WS-LEAD
                 MOVE 1 TO WS-LEADER-DONE
             END-IF
             CALL "RAID-JOIN" USING L-SLOT WS-WAVE WS-ROW WS-LEAD
             IF WS-T = 5
                 MOVE 0 TO WS-RIDER-TYPE
                 IF WS-WAVE = 5
                     MOVE WS-TYPE(3) TO WS-RIDER-TYPE
                 END-IF
                 IF WS-WAVE >= 7
                     IF WS-RAVAGERS = 0
                         MOVE WS-TYPE(2) TO WS-RIDER-TYPE
                     ELSE
                         MOVE WS-TYPE(1) TO WS-RIDER-TYPE
                     END-IF
                 END-IF
                 ADD 1 TO WS-RAVAGERS
                 IF WS-RIDER-TYPE > 0
                     MOVE 0 TO WS-LEAD
                     CALL "MOB-SPAWN" USING RD-DIM(L-SLOT) WS-RIDER-TYPE WS-X WS-Y WS-Z WS-YAW WS-RIDER
                     CALL "RAID-JOIN" USING L-SLOT WS-WAVE WS-RIDER WS-LEAD
                     CALL "MOB-MOUNT" USING WS-RIDER WS-ROW WS-MOUNTED
                 END-IF
             END-IF
         END-PERFORM
     END-PERFORM
     MOVE 0 TO RD-SPAWN-SET(L-SLOT)
     ADD 1 TO RD-GROUPS(L-SLOT)
     GOBACK.
 END PROGRAM RAID-SPAWN-GROUP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RAID-CELEBRATE.
*> USING raid slot, on (1 celebrate, 0 stop): RaiderCelebration (20 section 13): after a lost raid the member raiders without a target celebrate, metadata 16 true (EN-VARIANT 1,
*> sent by STDMOB-VARIANT-SEND); when the raid ends the flag is cleared (EN-VARIANT 2 stands for "sent false"). Gaps: the celebrate sound and the jump on 1 in 50 ticks.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY RAIDSTATE.
 01 WS-I                    BINARY-LONG.
 01 WS-E                    BINARY-LONG.
 LINKAGE SECTION.
 01 L-SLOT                  BINARY-LONG.
 01 L-ON                    BINARY-LONG.
 PROCEDURE DIVISION USING L-SLOT L-ON.
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > RR-MAX
         IF RR-ID(WS-I) > 0 AND RR-RAID(WS-I) = L-SLOT
             PERFORM VARYING WS-E FROM 1 BY 1 UNTIL WS-E > EN-COUNT
                 IF EN-USED(WS-E) = 1 AND EN-ID(WS-E) = RR-ID(WS-I) AND EN-HEALTH(WS-E) > 0
                     IF L-ON = 1 AND EN-TARGET(WS-E) = 0
                         MOVE 1 TO EN-VARIANT(WS-E)
                         CALL "STDMOB-VARIANT-SEND" USING WS-E
                     END-IF
                     IF L-ON = 0 AND EN-VARIANT(WS-E) = 1
                         MOVE 2 TO EN-VARIANT(WS-E)
                         CALL "STDMOB-VARIANT-SEND" USING WS-E
                     END-IF
                 END-IF
             END-PERFORM
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM RAID-CELEBRATE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RAID-DROP.
*> USING raid slot: removes the raid, its boss bar and the memberships of its raiders.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY RAIDSTATE.
 01 WS-I                    BINARY-LONG.
 01 WS-REMOVE               BINARY-LONG VALUE 1.
 01 WS-OFF                  BINARY-LONG VALUE 0.
 LINKAGE SECTION.
 01 L-SLOT                  BINARY-LONG.
 PROCEDURE DIVISION USING L-SLOT.
     CALL "RAID-CELEBRATE" USING L-SLOT WS-OFF
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 64
         IF RP-BAR(WS-I) > 0 AND RP-BAR(WS-I) = RD-ID(L-SLOT)
             CALL "RAID-BAR-SEND" USING L-SLOT WS-REMOVE WS-I
             MOVE 0 TO RP-BAR(WS-I)
         END-IF
     END-PERFORM
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > RR-MAX
         IF RR-ID(WS-I) > 0 AND RR-RAID(WS-I) = L-SLOT
             INITIALIZE RR-ENTRY(WS-I)
         END-IF
     END-PERFORM
     MOVE 0 TO RD-USED(L-SLOT)
     GOBACK.
 END PROGRAM RAID-DROP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RAID-REFRESH.
*> USING raid slot: updateRaiders (20 section 14.2), every 20 ticks: a member that is gone, in another dimension or 112 blocks (squared 12544) from the centre leaves the raid.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY RAIDSTATE.
 01 WS-I                    BINARY-LONG.
 01 WS-E                    BINARY-LONG.
 01 WS-ROW                  BINARY-LONG.
 01 WS-GONE                 BINARY-LONG.
 01 WS-D2                   FLOAT-LONG.
 LINKAGE SECTION.
 01 L-SLOT                  BINARY-LONG.
 PROCEDURE DIVISION USING L-SLOT.
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > RR-MAX
         IF RR-ID(WS-I) > 0 AND RR-RAID(WS-I) = L-SLOT
             MOVE 0 TO WS-ROW
             PERFORM VARYING WS-E FROM 1 BY 1 UNTIL WS-E > EN-COUNT
                 IF EN-USED(WS-E) = 1 AND EN-ID(WS-E) = RR-ID(WS-I)
                     MOVE WS-E TO WS-ROW
                 END-IF
             END-PERFORM
             MOVE 0 TO WS-GONE
             IF WS-ROW = 0
                 MOVE 1 TO WS-GONE
             ELSE
                 COMPUTE WS-D2 = (EN-X(WS-ROW) - RD-CX(L-SLOT)) ** 2 + (EN-Z(WS-ROW) - RD-CZ(L-SLOT)) ** 2
                 IF EN-DIM(WS-ROW) NOT = RD-DIM(L-SLOT) OR WS-D2 >= 12544
                     MOVE 1 TO WS-GONE
                 END-IF
             END-IF
             IF WS-GONE = 1
                 IF RR-LEADER(WS-I) = 1
                     MOVE 0 TO RD-LEADER(L-SLOT)
                 END-IF
                 INITIALIZE RR-ENTRY(WS-I)
             END-IF
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM RAID-REFRESH.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RAID-RAIDER-DIED.
*> USING entity row, killer player row (0 none): Raider.die (20 section 14.2): a killing player becomes a hero of the village, a dead leader clears the wave's leader, the raider
*> leaves the raid.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY RAIDSTATE.
 01 WS-I                    BINARY-LONG.
 01 WS-H                    BINARY-LONG.
 01 WS-SLOT                 BINARY-LONG.
 01 WS-HAS                  BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                   BINARY-LONG.
 01 L-KILLER                BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-KILLER.
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > RR-MAX
         IF RR-ID(WS-I) > 0 AND RR-ID(WS-I) = EN-ID(L-ROW)
             MOVE RR-RAID(WS-I) TO WS-SLOT
             IF RR-LEADER(WS-I) = 1
                 MOVE 0 TO RD-LEADER(WS-SLOT)
             END-IF
             IF L-KILLER > 0
                 MOVE 0 TO WS-HAS
                 PERFORM VARYING WS-H FROM 1 BY 1 UNTIL WS-H > 8
                     IF RD-HERO(WS-SLOT, WS-H) = PL-ENTITY-ID(L-KILLER)
                         MOVE 1 TO WS-HAS
                     END-IF
                 END-PERFORM
                 IF WS-HAS = 0
                     PERFORM VARYING WS-H FROM 1 BY 1 UNTIL WS-H > 8 OR WS-HAS = 1
                         IF RD-HERO(WS-SLOT, WS-H) = 0
                             MOVE PL-ENTITY-ID(L-KILLER) TO RD-HERO(WS-SLOT, WS-H)
                             MOVE 1 TO WS-HAS
                         END-IF
                     END-PERFORM
                 END-IF
             END-IF
             INITIALIZE RR-ENTRY(WS-I)
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM RAID-RAIDER-DIED.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RAID-MOVE-CENTER.
*> USING raid slot: moveRaidCenterToNearbyVillageSection: the village point section within 2 sections of the centre's whose section centre is nearest becomes the centre.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY VILPOIX.
 COPY RAIDSTATE.
 01 WS-I                    BINARY-LONG.
 01 WS-SX                   BINARY-LONG.
 01 WS-SY                   BINARY-LONG.
 01 WS-SZ                   BINARY-LONG.
 01 WS-PX                   BINARY-LONG.
 01 WS-PY                   BINARY-LONG.
 01 WS-PZ                   BINARY-LONG.
 01 WS-D2                   FLOAT-LONG.
 01 WS-BEST                 FLOAT-LONG.
 01 WS-HAVE                 BINARY-LONG.
 01 WS-NX                   BINARY-LONG.
 01 WS-NY                   BINARY-LONG.
 01 WS-NZ                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-SLOT                  BINARY-LONG.
 PROCEDURE DIVISION USING L-SLOT.
     COMPUTE WS-SX = FUNCTION INTEGER(RD-CX(L-SLOT) / 16)
     COMPUTE WS-SY = FUNCTION INTEGER(RD-CY(L-SLOT) / 16)
     COMPUTE WS-SZ = FUNCTION INTEGER(RD-CZ(L-SLOT) / 16)
     MOVE 0 TO WS-HAVE
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > PX-MAX
         IF PX-KIND(WS-I) > 0 AND PX-DIM(WS-I) = RD-DIM(L-SLOT)
             COMPUTE WS-PX = FUNCTION INTEGER(PX-X(WS-I) / 16)
             COMPUTE WS-PY = FUNCTION INTEGER(PX-Y(WS-I) / 16)
             COMPUTE WS-PZ = FUNCTION INTEGER(PX-Z(WS-I) / 16)
             IF FUNCTION ABS(WS-PX - WS-SX) <= 2 AND FUNCTION ABS(WS-PY - WS-SY) <= 2 AND FUNCTION ABS(WS-PZ - WS-SZ) <= 2
                 COMPUTE WS-D2 = (WS-PX * 16 + 8 - RD-CX(L-SLOT)) ** 2 + (WS-PY * 16 + 8 - RD-CY(L-SLOT)) ** 2
                     + (WS-PZ * 16 + 8 - RD-CZ(L-SLOT)) ** 2
                 IF WS-HAVE = 0 OR WS-D2 < WS-BEST
                     MOVE WS-D2 TO WS-BEST
                     MOVE 1 TO WS-HAVE
                     COMPUTE WS-NX = WS-PX * 16 + 8
                     COMPUTE WS-NY = WS-PY * 16 + 8
                     COMPUTE WS-NZ = WS-PZ * 16 + 8
                 END-IF
             END-IF
         END-IF
     END-PERFORM
     IF WS-HAVE = 1
         MOVE WS-NX TO RD-CX(L-SLOT)
         MOVE WS-NY TO RD-CY(L-SLOT)
         MOVE WS-NZ TO RD-CZ(L-SLOT)
     END-IF
     GOBACK.
 END PROGRAM RAID-MOVE-CENTER.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RAID-BAR-PROGRESS.
*> USING raid slot, progress out (millionths): after a victory 0; between waves (no raider alive, cooldown above 0) (300 - cooldown) / 300; else the living raiders' health
*> over the total health of the raiders that joined.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY RAIDSTATE.
 01 WS-I                    BINARY-LONG.
 01 WS-E                    BINARY-LONG.
 01 WS-ALIVE                BINARY-LONG.
 01 WS-SUM                  BINARY-DOUBLE.
 LINKAGE SECTION.
 01 L-SLOT                  BINARY-LONG.
 01 L-PROGRESS              BINARY-LONG.
 PROCEDURE DIVISION USING L-SLOT L-PROGRESS.
     MOVE 0 TO L-PROGRESS WS-SUM
     IF RD-STATUS(L-SLOT) = 2
         GOBACK
     END-IF
     CALL "RAID-ALIVE" USING L-SLOT WS-ALIVE
     IF WS-ALIVE = 0 AND RD-COOLDOWN(L-SLOT) > 0
         COMPUTE L-PROGRESS = FUNCTION MAX(0, FUNCTION MIN(1000000, (300 - RD-COOLDOWN(L-SLOT)) * 1000000 / 300))
         GOBACK
     END-IF
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > RR-MAX
         IF RR-ID(WS-I) > 0 AND RR-RAID(WS-I) = L-SLOT
             PERFORM VARYING WS-E FROM 1 BY 1 UNTIL WS-E > EN-COUNT
                 IF EN-USED(WS-E) = 1 AND EN-ID(WS-E) = RR-ID(WS-I) AND EN-HEALTH(WS-E) > 0
                     COMPUTE WS-SUM = WS-SUM + EN-HEALTH(WS-E) * 1000
                 END-IF
             END-PERFORM
         END-IF
     END-PERFORM
     IF RD-TOTAL(L-SLOT) > 0
         COMPUTE L-PROGRESS = FUNCTION MAX(0, FUNCTION MIN(1000000, WS-SUM * 1000000 / RD-TOTAL(L-SLOT)))
     END-IF
     GOBACK.
 END PROGRAM RAID-BAR-PROGRESS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RAID-BAR-NAME.
*> USING raid slot, text out (X(64)), length out: "Raid", followed by " - Victory" or " - Defeat" after the end, or " - N raiders remaining" while 1 or 2 are alive (the component
*> strings were not read in the document: plain text is used).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY RAIDSTATE.
 01 WS-ALIVE                BINARY-LONG.
 01 WS-DIGIT                PIC 9.
 LINKAGE SECTION.
 01 L-SLOT                  BINARY-LONG.
 01 L-TEXT                  PIC X(64).
 01 L-LEN                   BINARY-LONG.
 PROCEDURE DIVISION USING L-SLOT L-TEXT L-LEN.
     MOVE SPACES TO L-TEXT
     MOVE "Raid" TO L-TEXT
     MOVE 4 TO L-LEN
     EVALUATE RD-STATUS(L-SLOT)
         WHEN 2
             MOVE "Raid - Victory" TO L-TEXT
             MOVE 14 TO L-LEN
         WHEN 3
             MOVE "Raid - Defeat" TO L-TEXT
             MOVE 13 TO L-LEN
         WHEN OTHER
             CALL "RAID-ALIVE" USING L-SLOT WS-ALIVE
             IF WS-ALIVE >= 1 AND WS-ALIVE <= 2
                 MOVE WS-ALIVE TO WS-DIGIT
                 STRING "Raid - Raiders Remaining: " WS-DIGIT DELIMITED BY SIZE INTO L-TEXT
                 MOVE 27 TO L-LEN
             END-IF
     END-EVALUATE
     GOBACK.
 END PROGRAM RAID-BAR-NAME.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RAID-BAR-SEND.
*> USING raid slot, operation (0 ADD, 1 REMOVE, 2 UPDATE_PROGRESS, 3 UPDATE_NAME), player row: Boss Event 0x09 (05a) to that player. The bar is red, notched_10, no flags;
*> its uuid is 15 zero bytes and 100 + the raid slot.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY RAIDSTATE.
 COPY PROTO.
 01 WS-CAPACITY             BINARY-LONG VALUE 1024.
 01 WS-ID                   BINARY-LONG VALUE 9.
 01 WS-UUID                 PIC X(16).
 01 WS-PROGRESS             BINARY-LONG.
 01 WS-FLOAT                FLOAT-SHORT.
 01 WS-TEXT                 PIC X(1024).
 01 WS-NAME                 PIC X(64).
 01 WS-LEN                  BINARY-LONG.
 01 WS-COLOR                BINARY-LONG VALUE 2.
 01 WS-STYLE                BINARY-LONG VALUE 2.
 01 WS-FLAGS                BINARY-LONG VALUE 0.
 01 WS-BYTE                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-SLOT                  BINARY-LONG.
 01 L-OP                    BINARY-LONG.
 01 L-ROW                   BINARY-LONG.
 PROCEDURE DIVISION USING L-SLOT L-OP L-ROW.
     MOVE LOW-VALUES TO WS-UUID
     COMPUTE WS-BYTE = 100 + L-SLOT
     MOVE FUNCTION CHAR(WS-BYTE + 1) TO WS-UUID(16:1)
     CALL "RAID-BAR-PROGRESS" USING L-SLOT WS-PROGRESS
     COMPUTE WS-FLOAT = WS-PROGRESS / 1000000
     CALL "RAID-BAR-NAME" USING L-SLOT WS-NAME WS-LEN
     MOVE SPACES TO WS-TEXT
     MOVE WS-NAME TO WS-TEXT
     CALL "BX-LITERAL" USING WS-TEXT WS-LEN PB-TEXT
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-ID
     CALL "PB-PUT-UUID" USING PB-BUFFER WS-UUID
     CALL "PB-PUT-VARINT" USING PB-BUFFER L-OP
     EVALUATE L-OP
         WHEN 0
             CALL "PB-PUT-TEXT" USING PB-BUFFER PB-TEXT
             CALL "PB-PUT-FLOAT" USING PB-BUFFER WS-FLOAT
             CALL "PB-PUT-VARINT" USING PB-BUFFER WS-COLOR
             CALL "PB-PUT-VARINT" USING PB-BUFFER WS-STYLE
             CALL "PB-PUT-UBYTE" USING PB-BUFFER WS-FLAGS
         WHEN 2
             CALL "PB-PUT-FLOAT" USING PB-BUFFER WS-FLOAT
         WHEN 3
             CALL "PB-PUT-TEXT" USING PB-BUFFER PB-TEXT
     END-EVALUATE
     CALL "CORE-SEND" USING PL-CONN(L-ROW) PB-BUFFER
     CALL "PB-FREE" USING PB-BUFFER
     GOBACK.
 END PROGRAM RAID-BAR-SEND.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RAID-BAR-REFRESH.
*> USING raid slot: every player in the raid's dimension gets ADD once, then the progress and the name (the document does not say which players the raid refreshes: every
*> player of the dimension is used).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY RAIDSTATE.
 01 WS-P                    BINARY-LONG.
 01 WS-ADD                  BINARY-LONG VALUE 0.
 01 WS-PROGRESS-OP          BINARY-LONG VALUE 2.
 01 WS-NAME-OP              BINARY-LONG VALUE 3.
 LINKAGE SECTION.
 01 L-SLOT                  BINARY-LONG.
 PROCEDURE DIVISION USING L-SLOT.
     PERFORM VARYING WS-P FROM 1 BY 1 UNTIL WS-P > 64
         IF PL-USED(WS-P) = 1 AND PL-ENTITY-ROW(WS-P) > 0 AND PL-DIM(WS-P) = RD-DIM(L-SLOT)
             IF RP-BAR(WS-P) = RD-ID(L-SLOT)
                 CALL "RAID-BAR-SEND" USING L-SLOT WS-PROGRESS-OP WS-P
                 CALL "RAID-BAR-SEND" USING L-SLOT WS-NAME-OP WS-P
             ELSE
                 CALL "RAID-BAR-SEND" USING L-SLOT WS-ADD WS-P
                 MOVE RD-ID(L-SLOT) TO RP-BAR(WS-P)
             END-IF
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM RAID-BAR-REFRESH.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RAID-TICK.
*> USING raid slot: Raid.tick (20 section 14.2) in the order of the document. Not modelled: the active flag (a loaded centre chunk), the boss bar, the horn, the 600 tick raider
*> grace and the outside-village counter of the raiders (no no-action time is kept).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY BRWORLD.
 COPY RAIDSTATE.
 01 WS-VILLAGE              BINARY-LONG.
 01 WS-ALIVE                BINARY-LONG.
 01 WS-N                    BINARY-LONG.
 01 WS-BONUS                BINARY-LONG.
 01 WS-MORE                 BINARY-LONG.
 01 WS-FOUND                BINARY-LONG.
 01 WS-FAILS                BINARY-LONG.
 01 WS-GO                   BINARY-LONG.
 01 WS-H                    BINARY-LONG.
 01 WS-P                    BINARY-LONG.
 01 WS-AMP                  BINARY-LONG.
 01 WS-DUR                  BINARY-LONG VALUE 48000.
 01 WS-FLAGS                BINARY-LONG VALUE 4.
 01 WS-HERO                 BINARY-LONG VALUE 31.
 01 WS-BONUS-GROUP          BINARY-LONG.
 01 WS-ON                   BINARY-LONG VALUE 1.
 LINKAGE SECTION.
 01 L-SLOT                  BINARY-LONG.
 PROCEDURE DIVISION USING L-SLOT.
     IF RD-USED(L-SLOT) = 0
         GOBACK
     END-IF
     IF RD-STATUS(L-SLOT) = 2 OR RD-STATUS(L-SLOT) = 3
         ADD 1 TO RD-CELEB(L-SLOT)
         IF FUNCTION MOD(RD-CELEB(L-SLOT), 20) = 0
             CALL "RAID-BAR-REFRESH" USING L-SLOT
         END-IF
         IF RD-CELEB(L-SLOT) >= 600
             CALL "RAID-DROP" USING L-SLOT
         END-IF
         GOBACK
     END-IF
     IF BW-DIFFICULTY = 0
         CALL "RAID-DROP" USING L-SLOT
         GOBACK
     END-IF
     CALL "RAID-IS-VILLAGE" USING RD-DIM(L-SLOT) RD-CX(L-SLOT) RD-CY(L-SLOT) RD-CZ(L-SLOT) WS-VILLAGE
     IF WS-VILLAGE = 0
         CALL "RAID-MOVE-CENTER" USING L-SLOT
         CALL "RAID-IS-VILLAGE" USING RD-DIM(L-SLOT) RD-CX(L-SLOT) RD-CY(L-SLOT) RD-CZ(L-SLOT) WS-VILLAGE
         IF WS-VILLAGE = 0
             IF RD-GROUPS(L-SLOT) > 0
                 MOVE 3 TO RD-STATUS(L-SLOT)
                 CALL "RAID-CELEBRATE" USING L-SLOT WS-ON
             ELSE
                 CALL "RAID-DROP" USING L-SLOT
             END-IF
             GOBACK
         END-IF
     END-IF
     ADD 1 TO RD-TICKS(L-SLOT)
     IF RD-TICKS(L-SLOT) >= 48000
         CALL "RAID-DROP" USING L-SLOT
         GOBACK
     END-IF
     CALL "RAID-ALIVE" USING L-SLOT WS-ALIVE
     CALL "RAID-NUM-GROUPS" USING BW-DIFFICULTY WS-N
     MOVE 0 TO WS-BONUS
     IF RD-OMEN(L-SLOT) > 1
         MOVE 1 TO WS-BONUS
     END-IF
     MOVE 0 TO WS-MORE
     IF RD-GROUPS(L-SLOT) < WS-N + WS-BONUS
         MOVE 1 TO WS-MORE
     END-IF
     IF WS-ALIVE = 0 AND WS-MORE = 1
         IF RD-COOLDOWN(L-SLOT) > 0
             IF RD-SPAWN-SET(L-SLOT) = 0 AND FUNCTION MOD(RD-COOLDOWN(L-SLOT), 5) = 0
                 CALL "RAID-SPAWN-POS" USING L-SLOT WS-FOUND
             END-IF
             SUBTRACT 1 FROM RD-COOLDOWN(L-SLOT)
         ELSE
             IF RD-GROUPS(L-SLOT) > 0
                 MOVE 300 TO RD-COOLDOWN(L-SLOT)
                 GOBACK
             END-IF
         END-IF
     END-IF
     IF FUNCTION MOD(RD-TICKS(L-SLOT), 20) = 0
         CALL "RAID-REFRESH" USING L-SLOT
         CALL "RAID-ALIVE" USING L-SLOT WS-ALIVE
         CALL "RAID-BAR-REFRESH" USING L-SLOT
     END-IF
*>   Wave spawning: while the cooldown is 0, no raider lives and a wave (or the bonus wave) remains.
     MOVE 0 TO WS-FAILS
     MOVE 1 TO WS-GO
     PERFORM UNTIL WS-GO = 0
         MOVE 0 TO WS-GO
         IF RD-COOLDOWN(L-SLOT) = 0 AND WS-ALIVE = 0
             MOVE 0 TO WS-BONUS-GROUP
             IF RD-GROUPS(L-SLOT) = WS-N AND WS-BONUS = 1
                 MOVE 1 TO WS-BONUS-GROUP
             END-IF
             IF RD-GROUPS(L-SLOT) < WS-N OR WS-BONUS-GROUP = 1
                 IF RD-SPAWN-SET(L-SLOT) = 1
                     MOVE 1 TO WS-FOUND
                 ELSE
                     CALL "RAID-SPAWN-POS" USING L-SLOT WS-FOUND
                 END-IF
                 IF WS-FOUND = 1
                     MOVE 1 TO RD-STARTED(L-SLOT)
                     CALL "RAID-SPAWN-GROUP" USING L-SLOT WS-BONUS-GROUP
                     CALL "RAID-ALIVE" USING L-SLOT WS-ALIVE
                 ELSE
                     ADD 1 TO WS-FAILS
                     IF WS-FAILS > 5
                         CALL "RAID-DROP" USING L-SLOT
                         GOBACK
                     END-IF
                     MOVE 1 TO WS-GO
                 END-IF
             END-IF
         END-IF
     END-PERFORM
*>   Victory after the last wave: 40 ticks without raiders, then the heroes are rewarded.
     IF RD-STARTED(L-SLOT) = 1 AND WS-MORE = 0 AND WS-ALIVE = 0
         IF RD-POST(L-SLOT) < 40
             ADD 1 TO RD-POST(L-SLOT)
         ELSE
             MOVE 2 TO RD-STATUS(L-SLOT)
             COMPUTE WS-AMP = RD-OMEN(L-SLOT) - 1
             PERFORM VARYING WS-H FROM 1 BY 1 UNTIL WS-H > 8
                 IF RD-HERO(L-SLOT, WS-H) > 0
                     PERFORM VARYING WS-P FROM 1 BY 1 UNTIL WS-P > 64
                         IF PL-USED(WS-P) = 1 AND PL-ENTITY-ID(WS-P) = RD-HERO(L-SLOT, WS-H) AND PL-MODE(WS-P) NOT = 3
                             CALL "EFFECT-ADD" USING WS-P WS-HERO WS-AMP WS-DUR WS-FLAGS
                         END-IF
                     END-PERFORM
                 END-IF
             END-PERFORM
         END-IF
     END-IF
     GOBACK.
 END PROGRAM RAID-TICK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RAID-WORLD-TICK.
*> The per-tick raid work (STDMOB-SPAWN-TICK): the omen effects of every player and every raid.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY RAIDSTATE.
 01 WS-P                    BINARY-LONG.
 01 WS-R                    BINARY-LONG.
 01 WS-RAIDS-RULE           PIC X(40) VALUE "raids".
 01 WS-RAIDS                BINARY-DOUBLE.
 PROCEDURE DIVISION.
     CALL "BR-RULE-GET" USING WS-RAIDS-RULE WS-RAIDS
     PERFORM VARYING WS-P FROM 1 BY 1 UNTIL WS-P > 64
         IF PL-USED(WS-P) = 1 AND PL-ENTITY-ROW(WS-P) > 0
             CALL "RAID-PLAYER-TICK" USING WS-P
         END-IF
     END-PERFORM
     PERFORM VARYING WS-R FROM 1 BY 1 UNTIL WS-R > RD-MAX
         IF RD-USED(WS-R) = 1
*>           Raids.tick: with the raids game rule false a raid is stopped and removed.
             IF WS-RAIDS = 0
                 CALL "RAID-DROP" USING WS-R
             ELSE
                 CALL "RAID-TICK" USING WS-R
             END-IF
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM RAID-WORLD-TICK.
