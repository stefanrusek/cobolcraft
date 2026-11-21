*> The lightning bolt of lane 002-lane-mobsb6 (21 section 8.6, 44 part 9 section 2), PJ-KIND 9: PJ-I1 life (2 at the start), PJ-I2 flashes (nextInt(3) + 1), PJ-I3 visual only. Each tick
*> (LIGHTNING-STEP) life falls by 1; below 0 the bolt ends when no flash is left, else when life < -nextInt(10) a flash is used and life is 1 again; while life >= 0 and not visual
*> only every player and mob in the box +- 3 horizontally, -3 to +9 vertically gets thunderHit (LIGHTNING-HIT): the default is the 5.0 damage (a mob loses 5 points, a player 5.0 through
*> HEALTH-HURT, CAUSE-COMMAND) and a fire counter of +1 (EN-BURN); a creeper becomes powered (EN-VARIANT 1) after it; a pig (not Peaceful) becomes a zombified_piglin and a villager (not
*> Peaceful) a witch, neither taking damage; a turtle dies; a mooshroom swaps red and brown once per bolt (the bolt's PJ-V list) and takes nothing.
*> Gaps: powering a lightning rod, clearing copper oxidation and wax (44 part 9 section 9.3 of 29b-3 gives the walks; not built here),
*> the game event, the advancement for players within 15 blocks, sounds, the copper golem, armor stands and item frames (not entities of this core), the witch's finalizeSpawn, the zombified piglin's
*> default equipment, releasing the villager's points of interest, thunderHit on dropped items and other non-mob entities, igniteForSeconds(8) for a counter of -1.
*>
*>   LIGHTNING-SPAWN USING dim, x, y, z (FLOAT-LONG, the bottom centre), visual only (0 or 1), row out
*>   LIGHTNING-HIT USING slot, bolt row, tracker row, player row (one of the last two 0)
*>   LIGHTNING-STEP USING tracker row

 IDENTIFICATION DIVISION.
 PROGRAM-ID. LIGHTNING-SPAWN.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY PROJSTATE.
 01 WS-KEY                 PIC X(112) VALUE "minecraft:lightning_bolt".
 01 WS-KIND                BINARY-LONG VALUE 9.
 01 WS-ZERO                FLOAT-LONG VALUE 0.
 01 WS-ZERO2               FLOAT-LONG VALUE 0.
 01 WS-ZERO3               FLOAT-LONG VALUE 0.
 01 WS-NONE                BINARY-LONG VALUE 0.
 01 WS-SLOT                BINARY-LONG.
 01 WS-SALT                BINARY-LONG VALUE 9091.
 01 WS-THREE               BINARY-LONG VALUE 3.
 01 WS-R                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    FLOAT-LONG.
 01 L-Y                    FLOAT-LONG.
 01 L-Z                    FLOAT-LONG.
 01 L-VISUAL               BINARY-LONG.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z L-VISUAL L-ROW.
     CALL "THROWN-SPAWN" USING WS-KIND WS-KEY L-DIM L-X L-Y L-Z WS-ZERO WS-ZERO2 WS-ZERO3 WS-NONE L-ROW
     IF L-ROW = 0
         GOBACK
     END-IF
     CALL "PJ-FIND" USING EN-ID(L-ROW) WS-SLOT
     CALL "XP-RANDOM" USING WS-SALT WS-THREE WS-R
     MOVE 2 TO PJ-I1(WS-SLOT)
     COMPUTE PJ-I2(WS-SLOT) = WS-R + 1
     MOVE L-VISUAL TO PJ-I3(WS-SLOT)
     GOBACK.
 END PROGRAM LIGHTNING-SPAWN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. LIGHTNING-CONVERT.
*> USING tracker row, new type key (PIC X(112)): the mob is replaced by a new one of that type at its place (the old row is removed).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-TYPE                BINARY-LONG.
 01 WS-NEW                 BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-YAW                 FLOAT-SHORT.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-KEY                  PIC X(112).
 PROCEDURE DIVISION USING L-ROW L-KEY.
     CALL "THROWN-TYPE" USING L-KEY WS-TYPE
     IF WS-TYPE > 0
         MOVE EN-DIM(L-ROW) TO WS-DIM
         MOVE EN-X(L-ROW) TO WS-X
         MOVE EN-Y(L-ROW) TO WS-Y
         MOVE EN-Z(L-ROW) TO WS-Z
         MOVE EN-YAW(L-ROW) TO WS-YAW
         CALL "ENTITY-REMOVE" USING L-ROW
         CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-X WS-Y WS-Z WS-YAW WS-NEW
     END-IF
     GOBACK.
 END PROGRAM LIGHTNING-CONVERT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. LIGHTNING-HIT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY BRWORLD.
 COPY RULES.
 COPY PROJSTATE.
 01 WS-SPECIES             PIC X(24).
 01 WS-WITCH               PIC X(112) VALUE "minecraft:witch".
 01 WS-ZPIG                PIC X(112) VALUE "minecraft:zombified_piglin".
 01 WS-CAUSE               BINARY-LONG VALUE CAUSE-COMMAND.
 01 WS-NONE                BINARY-LONG VALUE 0.
 01 WS-NONE2               BINARY-LONG VALUE 0.
 01 WS-RESULT              BINARY-LONG.
 01 WS-DAMAGE              BINARY-LONG VALUE 5000.
 01 WS-POINTS              BINARY-LONG VALUE 5.
 01 WS-TURTLE-DAMAGE       BINARY-LONG VALUE 1000.
 01 WS-KNOWN               BINARY-LONG.
 01 WS-ID                  BINARY-LONG.
 01 WS-CONVERTED           BINARY-LONG.
 01 WS-IGNITE-TICKS        BINARY-LONG VALUE 160.
 LINKAGE SECTION.
 01 L-SLOT                 BINARY-LONG.
 01 L-BOLT                 BINARY-LONG.
 01 L-ROW                  BINARY-LONG.
 01 L-PLAYER               BINARY-LONG.
 PROCEDURE DIVISION USING L-SLOT L-BOLT L-ROW L-PLAYER.
     IF L-PLAYER > 0
*>       Entity.thunderHit: the fire counter + 1, the 8 second ignition when it is then 0, then the damage (44-9 section 2.1).
         ADD 1 TO EN-BURN(PL-ENTITY-ROW(L-PLAYER))
         IF EN-BURN(PL-ENTITY-ROW(L-PLAYER)) = 0
             CALL "PLAYER-IGNITE" USING L-PLAYER WS-IGNITE-TICKS
         END-IF
         CALL "HEALTH-HURT" USING L-PLAYER WS-DAMAGE WS-CAUSE WS-NONE WS-NONE2 WS-RESULT
         GOBACK
     END-IF
     MOVE EN-ID(L-ROW) TO WS-ID
     CALL "MOB-SPECIES-KEY" USING L-ROW WS-SPECIES
     MOVE 0 TO WS-CONVERTED
     IF WS-SPECIES = "copper_golem"
         CALL "CG-BOLT" USING L-SLOT L-ROW
     END-IF
     EVALUATE TRUE
         WHEN WS-SPECIES = "pig" AND BW-DIFFICULTY > 0
             CALL "LIGHTNING-CONVERT" USING L-ROW WS-ZPIG
             MOVE 1 TO WS-CONVERTED
         WHEN WS-SPECIES = "villager" AND BW-DIFFICULTY > 0
             CALL "LIGHTNING-CONVERT" USING L-ROW WS-WITCH
             MOVE 1 TO WS-CONVERTED
         WHEN WS-SPECIES = "mooshroom"
             CALL "CLOUD-VICTIM" USING L-SLOT WS-ID WS-KNOWN
             IF WS-KNOWN = 0
                 CALL "CLOUD-VICTIM-ADD" USING L-SLOT WS-ID
                 IF EN-WOOL(L-ROW) = 0
                     MOVE 1 TO EN-WOOL(L-ROW)
                 ELSE
                     MOVE 0 TO EN-WOOL(L-ROW)
                 END-IF
             END-IF
             MOVE 1 TO WS-CONVERTED
         WHEN WS-SPECIES = "turtle"
             MOVE 0 TO EN-HURT(L-ROW)
             MOVE EN-HEALTH(L-ROW) TO WS-POINTS
             CALL "HEALTH-MOB-DAMAGE" USING L-ROW WS-POINTS WS-CAUSE WS-NONE
             MOVE 1 TO WS-CONVERTED
     END-EVALUATE
     IF WS-CONVERTED = 0
         ADD 1 TO EN-BURN(L-ROW)
         IF EN-BURN(L-ROW) = 0
             CALL "MOB-IGNITE" USING L-ROW WS-IGNITE-TICKS
         END-IF
         MOVE 5 TO WS-POINTS
         CALL "HEALTH-MOB-DAMAGE" USING L-ROW WS-POINTS WS-CAUSE WS-NONE
         IF WS-SPECIES = "creeper"
             MOVE 1 TO EN-VARIANT(L-ROW)
         END-IF
     END-IF
     GOBACK.
 END PROGRAM LIGHTNING-HIT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. LIGHTNING-STRIKE.
*> USING tracker row of the bolt, slot: thunderHit for every player and mob in the box +- 3 horizontally, -3 to +9 vertically (relative to the bolt's feet).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CITEMS.
 COPY PROJSTATE.
 01 WS-P                   BINARY-LONG.
 01 WS-E                   BINARY-LONG.
 01 WS-M                   BINARY-LONG.
 01 WS-NONE                BINARY-LONG VALUE 0.
 01 WS-NONE2               BINARY-LONG VALUE 0.
 01 WS-COUNT               BINARY-LONG.
 01 WS-LIST.
    05 WS-LIST-ROW         BINARY-LONG OCCURS 64 TIMES.
 01 WS-I                   BINARY-LONG.
 01 WS-H                   FLOAT-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-SLOT                 BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-SLOT.
     PERFORM VARYING WS-P FROM 1 BY 1 UNTIL WS-P > CORE-MAX-PLAYERS
         IF PL-USED(WS-P) = 1 AND PL-ENTITY-ROW(WS-P) > 0 AND PL-STATE(WS-P) = PS-ALIVE AND PL-DIM(WS-P) = EN-DIM(L-ROW) AND PL-MODE(WS-P) < 3
             IF FUNCTION ABS(PL-X(WS-P) - EN-X(L-ROW)) <= 3.3 AND FUNCTION ABS(PL-Z(WS-P) - EN-Z(L-ROW)) <= 3.3
                     AND PL-Y(WS-P) + 1.8 >= EN-Y(L-ROW) - 3 AND PL-Y(WS-P) <= EN-Y(L-ROW) + 9
                 CALL "LIGHTNING-HIT" USING L-SLOT L-ROW WS-NONE WS-P
             END-IF
         END-IF
     END-PERFORM
*>   Collect the mob rows first: a conversion removes and adds rows while they are visited.
     MOVE 0 TO WS-COUNT
     PERFORM VARYING WS-E FROM 1 BY 1 UNTIL WS-E > EN-COUNT OR WS-COUNT >= 64
         IF EN-USED(WS-E) = 1 AND WS-E NOT = L-ROW AND EN-DIM(WS-E) = EN-DIM(L-ROW) AND EN-HEALTH(WS-E) > 0
             CALL "STDMOB-INDEX" USING EN-TYPE(WS-E) WS-M
             IF WS-M > 0
                 COMPUTE WS-H = ET-WIDTH-MILLI(EN-TYPE(WS-E) + 1) / 2000
                 IF FUNCTION ABS(EN-X(WS-E) - EN-X(L-ROW)) <= 3 + WS-H AND FUNCTION ABS(EN-Z(WS-E) - EN-Z(L-ROW)) <= 3 + WS-H
                         AND EN-Y(WS-E) >= EN-Y(L-ROW) - 3 - 1 AND EN-Y(WS-E) <= EN-Y(L-ROW) + 9
                     ADD 1 TO WS-COUNT
                     MOVE WS-E TO WS-LIST-ROW(WS-COUNT)
                 END-IF
             END-IF
         END-IF
     END-PERFORM
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-COUNT
         CALL "LIGHTNING-HIT" USING L-SLOT L-ROW WS-LIST-ROW(WS-I) WS-NONE2
     END-PERFORM
     GOBACK.
 END PROGRAM LIGHTNING-STRIKE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. LIGHTNING-STEP.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY PROJSTATE.
 01 WS-SLOT                BINARY-LONG.
 01 WS-SALT                BINARY-LONG VALUE 9092.
 01 WS-TEN                 BINARY-LONG VALUE 10.
 01 WS-R                   BINARY-LONG.
 01 WS-NO-FIRES            BINARY-LONG VALUE 0.
 01 WS-EV-LIGHTNING        PIC X(32) VALUE "lightning_strike".
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     CALL "PJ-FIND" USING EN-ID(L-ROW) WS-SLOT
     IF WS-SLOT = 0
         GOBACK
     END-IF
     IF PJ-I1(WS-SLOT) = 2
         CALL "LIGHTNING-FIRST" USING L-ROW
*>   LightningBolt.tick posts lightning_strike on the tick where its life counter equals 2 (the first), the bolt as the source (30-8 14.3.10)
         CALL "GAME-EVENT-AT" USING WS-EV-LIGHTNING L-ROW
         CALL "RL-ROD-STRIKE" USING L-ROW
     END-IF
     SUBTRACT 1 FROM PJ-I1(WS-SLOT)
     IF PJ-I1(WS-SLOT) < 0
         IF PJ-I2(WS-SLOT) = 0
             CALL "PJ-DROP" USING L-ROW
             GOBACK
         END-IF
         CALL "XP-RANDOM" USING WS-SALT WS-TEN WS-R
         IF PJ-I1(WS-SLOT) < 0 - WS-R
             SUBTRACT 1 FROM PJ-I2(WS-SLOT)
             MOVE 1 TO PJ-I1(WS-SLOT)
*>           A flash calls spawnFire(0) at every difficulty (21 section 8.6).
             CALL "LIGHTNING-SPAWN-FIRE" USING L-ROW WS-NO-FIRES
         END-IF
     END-IF
     IF PJ-I1(WS-SLOT) >= 0 AND PJ-I3(WS-SLOT) = 0
         CALL "LIGHTNING-STRIKE" USING L-ROW WS-SLOT
     END-IF
     GOBACK.
 END PROGRAM LIGHTNING-STEP.
