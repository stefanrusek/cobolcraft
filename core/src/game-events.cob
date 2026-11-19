*> Game events (lane 002-lane-p49w; docs/protocol/30-redstone-8 sections 2 and 3, 31-block-entities-8 section 3, 20 section 15.1). One emitter, one dispatch:
*>   GAME-EVENT USING dim, x, y, z (FLOAT-LONG, the event position), event name (PIC X(32), the registry name without minecraft:), source entity row (0 none), affected block state id
*>     (-1 none): Level.gameEvent. The checks every listener shares (30 section 3.5): an event with frequency 0 that is not one of the warden's two extras is dropped; a spectator source, a warden
*>     source (Warden.dampensVibrations: it never hears itself) and an item entity whose stack is in the item tag dampens_vibrations are not valid; an affected state in the block tag
*>     dampens_vibrations (wool) is not valid. Then the listeners are told: GAME-EVENT-SENSORS (the hook of the sculk sensors and the shrieker, see below) and every warden (WARDEN-HEAR).
*>   GAME-EVENT-BLOCK USING dim, bx, by, bz (BINARY-LONG), event name, player row (0 none), affected state: Level.gameEvent(player, event, pos) of a block: the position is the block
*>     centre (30 section 2.1), the source the player's entity.
*>   GAME-EVENT-AT USING event name, source entity row, affected state: Entity.gameEvent: the event at the position of the entity (a player's own position, a mob's feet) with the entity as its source.
*>   GAME-EVENT-SHOOT USING projectile row, owner entity id: Projectile.tick's first game event: projectile_shoot at the projectile's position with the owner as the source (44-8 section 6.1; 0 when the
*>     owner is not in the tracker). Called by ARROW-SPAWN.
*>   GAME-EVENT-FREQUENCY USING event name, frequency out (30 section 3.1; BE8-FREQUENCY)
*>   GAME-EVENT-LISTENS USING event name, flag out: the event is in the game event tag warden_can_listen (20 section 15.1: the 55 events of vibrations except flap, plus shriek and
*>     sculk_sensor_tendrils_clicking).
*>   GAME-EVENT-SNEAKS USING event name, flag out: the event is in ignore_vibrations_sneaking. Only step is documented (30 section 12 V9); the rest of the tag is a gap named in the lane report.
*>   GAME-EVENT-TAGGED USING dim, x, y, z, tag key (PIC X(112)), flag out: the block at the cell is in that block tag.
*>   GAME-EVENT-RAY USING dim, start xyz, end xyz (FLOAT-LONG), hit out: Level.isBlockInLine with the occludes_vibration_signals predicate: the cells the segment passes through, in order
*>     from the start cell to the end cell (a plain voxel walk: the clip algorithm itself is not in the documents, 30 Open question 5).
*>   GAME-EVENT-OCCLUDED USING dim, event xyz, listener xyz (FLOAT-LONG), occluded out: 3.6: both points snapped to their block centres; six rays start 0.00001 from the event centre along
*>     each direction (down, up, north, south, west, east); the vibration is occluded only when every ray meets a block of occludes_vibration_signals.
*> THE SHARED HOOK: GAME-EVENT-SENSORS USING dim, x, y, z (FLOAT-LONG), event name, frequency, source entity row, block state. A lane that has sculk sensors or shrieker block entities
*> (lane p46h builds VIB-POST for them) replaces the body of this one program with its dispatch; the validity checks above have already passed when it is called, and the sensors apply their own
*> listener rules (radius 8 / 16, tags, cooldown phases) behind it. Nothing else needs to change for them to hear the events the core posts.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GAME-EVENT-FREQUENCY.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-NAME                PIC X(48).
 01 WS-LENGTH              BINARY-LONG.
 LINKAGE SECTION.
 01 L-EVENT                PIC X(32).
 01 L-FREQUENCY            BINARY-LONG.
 PROCEDURE DIVISION USING L-EVENT L-FREQUENCY.
     MOVE L-EVENT TO WS-NAME
     COMPUTE WS-LENGTH = FUNCTION LENGTH(FUNCTION TRIM(L-EVENT))
     CALL "BE8-FREQUENCY" USING WS-NAME WS-LENGTH L-FREQUENCY
     GOBACK.
 END PROGRAM GAME-EVENT-FREQUENCY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GAME-EVENT-IN-TAG.
*> USING tag name (PIC X(32), without minecraft:), event name, flag out: the member lists of the game event tags (30-8 section 3.5.1): vibrations (every event with a non-zero frequency),
*> warden_can_listen (vibrations minus flap, plus shriek and sculk_sensor_tendrils_clicking), ignore_vibrations_sneaking (hit_ground, projectile_shoot, step, swim, item_interact_start,
*> item_interact_finish), shrieker_can_listen (sculk_sensor_tendrils_clicking), allay_can_listen (note_block_play). Any other tag name has no member.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-FREQ                BINARY-LONG.
 LINKAGE SECTION.
 01 L-TAG                  PIC X(32).
 01 L-EVENT                PIC X(32).
 01 L-FLAG                 BINARY-LONG.
 PROCEDURE DIVISION USING L-TAG L-EVENT L-FLAG.
     MOVE 0 TO L-FLAG
     CALL "GAME-EVENT-FREQUENCY" USING L-EVENT WS-FREQ
     EVALUATE L-TAG
         WHEN "vibrations"
             IF WS-FREQ > 0
                 MOVE 1 TO L-FLAG
             END-IF
         WHEN "warden_can_listen"
             IF (WS-FREQ > 0 AND L-EVENT NOT = "flap") OR L-EVENT = "shriek"
                     OR L-EVENT = "sculk_sensor_tendrils_clicking"
                 MOVE 1 TO L-FLAG
             END-IF
         WHEN "ignore_vibrations_sneaking"
             IF L-EVENT = "hit_ground" OR L-EVENT = "projectile_shoot" OR L-EVENT = "step"
                     OR L-EVENT = "swim" OR L-EVENT = "item_interact_start" OR L-EVENT = "item_interact_finish"
                 MOVE 1 TO L-FLAG
             END-IF
         WHEN "shrieker_can_listen"
             IF L-EVENT = "sculk_sensor_tendrils_clicking"
                 MOVE 1 TO L-FLAG
             END-IF
         WHEN "allay_can_listen"
             IF L-EVENT = "note_block_play"
                 MOVE 1 TO L-FLAG
             END-IF
     END-EVALUATE
     GOBACK.
 END PROGRAM GAME-EVENT-IN-TAG.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GAME-EVENT-LISTENS.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-TAG                 PIC X(32) VALUE "warden_can_listen".
 LINKAGE SECTION.
 01 L-EVENT                PIC X(32).
 01 L-FLAG                 BINARY-LONG.
 PROCEDURE DIVISION USING L-EVENT L-FLAG.
     CALL "GAME-EVENT-IN-TAG" USING WS-TAG L-EVENT L-FLAG
     GOBACK.
 END PROGRAM GAME-EVENT-LISTENS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GAME-EVENT-SNEAKS.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-TAG                 PIC X(32) VALUE "ignore_vibrations_sneaking".
 LINKAGE SECTION.
 01 L-EVENT                PIC X(32).
 01 L-FLAG                 BINARY-LONG.
 PROCEDURE DIVISION USING L-EVENT L-FLAG.
     CALL "GAME-EVENT-IN-TAG" USING WS-TAG L-EVENT L-FLAG
     GOBACK.
 END PROGRAM GAME-EVENT-SNEAKS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GAME-EVENT-WOOL-KEY.
*> USING key (PIC X(48), with minecraft:), tag selector (1 dampens_vibrations: the 64 <colour>_wool, _carpet, _wool_slab and _wool_stairs; 2 occludes_vibration_signals: the 16 <colour>_wool), flag out.
*> The block tag lists of 30-8 section 3.5.1; the item tag dampens_vibrations has the same four families.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-COLOURS.
    05 FILLER              PIC X(11) VALUE "white".
    05 FILLER              PIC X(11) VALUE "orange".
    05 FILLER              PIC X(11) VALUE "magenta".
    05 FILLER              PIC X(11) VALUE "light_blue".
    05 FILLER              PIC X(11) VALUE "yellow".
    05 FILLER              PIC X(11) VALUE "lime".
    05 FILLER              PIC X(11) VALUE "pink".
    05 FILLER              PIC X(11) VALUE "gray".
    05 FILLER              PIC X(11) VALUE "light_gray".
    05 FILLER              PIC X(11) VALUE "cyan".
    05 FILLER              PIC X(11) VALUE "purple".
    05 FILLER              PIC X(11) VALUE "blue".
    05 FILLER              PIC X(11) VALUE "brown".
    05 FILLER              PIC X(11) VALUE "green".
    05 FILLER              PIC X(11) VALUE "red".
    05 FILLER              PIC X(11) VALUE "black".
 01 WS-COLOUR-TABLE REDEFINES WS-COLOURS.
    05 WS-COLOUR           PIC X(11) OCCURS 16 TIMES.
 01 WS-WANT                PIC X(48).
 01 WS-KEY                 PIC X(48).
 01 WS-C                   BINARY-LONG.
 01 WS-WOOLISH             BINARY-LONG.
 LINKAGE SECTION.
 01 L-KEY                  PIC X(48).
 01 L-TAG                  BINARY-LONG.
 01 L-FLAG                 BINARY-LONG.
 PROCEDURE DIVISION USING L-KEY L-TAG L-FLAG.
     MOVE 0 TO L-FLAG
     MOVE L-KEY TO WS-KEY
     IF WS-KEY(1:10) = "minecraft:"
         MOVE L-KEY(11:38) TO WS-KEY
     END-IF
     MOVE 0 TO WS-WOOLISH
     INSPECT WS-KEY TALLYING WS-WOOLISH FOR ALL "wool" ALL "carpet"
     IF WS-WOOLISH = 0
         GOBACK
     END-IF
     PERFORM VARYING WS-C FROM 1 BY 1 UNTIL WS-C > 16
         MOVE SPACES TO WS-WANT
         STRING FUNCTION TRIM(WS-COLOUR(WS-C)) DELIMITED BY SIZE
             "_wool" DELIMITED BY SIZE INTO WS-WANT
         IF WS-KEY = WS-WANT
             MOVE 1 TO L-FLAG
         END-IF
         IF L-TAG = 1
             MOVE SPACES TO WS-WANT
             STRING FUNCTION TRIM(WS-COLOUR(WS-C)) DELIMITED BY SIZE
                 "_carpet" DELIMITED BY SIZE INTO WS-WANT
             IF WS-KEY = WS-WANT
                 MOVE 1 TO L-FLAG
             END-IF
             MOVE SPACES TO WS-WANT
             STRING FUNCTION TRIM(WS-COLOUR(WS-C)) DELIMITED BY SIZE
                 "_wool_slab" DELIMITED BY SIZE INTO WS-WANT
             IF WS-KEY = WS-WANT
                 MOVE 1 TO L-FLAG
             END-IF
             MOVE SPACES TO WS-WANT
             STRING FUNCTION TRIM(WS-COLOUR(WS-C)) DELIMITED BY SIZE
                 "_wool_stairs" DELIMITED BY SIZE INTO WS-WANT
             IF WS-KEY = WS-WANT
                 MOVE 1 TO L-FLAG
             END-IF
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM GAME-EVENT-WOOL-KEY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GAME-EVENT-IN-BLOCK-TAG.
*> USING block state id, tag selector (1 dampens_vibrations, 2 occludes_vibration_signals, 3 vibration_resonators), flag out: the member lists of the block tags (30-8 section 3.5.1; GAME-EVENT-WOOL-KEY,
*> vibration_resonators is amethyst_block). The block is read by its key in the core's block table (CB-KEY), so the lists hold in every world.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CBLOCKS.
 01 WS-BLOCK               BINARY-LONG.
 01 WS-KEY                 PIC X(48).
 LINKAGE SECTION.
 01 L-STATE                BINARY-LONG.
 01 L-TAG                  BINARY-LONG.
 01 L-FLAG                 BINARY-LONG.
 PROCEDURE DIVISION USING L-STATE L-TAG L-FLAG.
     MOVE 0 TO L-FLAG
     IF L-STATE <= 0 OR L-STATE >= CB-STATE-COUNT
         GOBACK
     END-IF
     MOVE CB-S-BLOCK(L-STATE + 1) TO WS-BLOCK
     MOVE CB-KEY(WS-BLOCK + 1) TO WS-KEY
     IF L-TAG = 3
         IF WS-KEY = "amethyst_block" OR WS-KEY = "minecraft:amethyst_block"
             MOVE 1 TO L-FLAG
         END-IF
         GOBACK
     END-IF
     CALL "GAME-EVENT-WOOL-KEY" USING WS-KEY L-TAG L-FLAG
     GOBACK.
 END PROGRAM GAME-EVENT-IN-BLOCK-TAG.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GAME-EVENT-TAGGED.
*> USING dim, x, y, z (BINARY-LONG cell), tag selector (GAME-EVENT-IN-BLOCK-TAG: 1 dampens_vibrations, 2 occludes_vibration_signals, 3 vibration_resonators), flag out: the block at the cell is in that block tag.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-STATE               BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-TAG                  BINARY-LONG.
 01 L-FLAG                 BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z L-TAG L-FLAG.
     MOVE 0 TO L-FLAG
     CALL "WORLD-GET-BLOCK" USING L-DIM L-X L-Y L-Z WS-STATE
     IF WS-STATE > 0
         CALL "GAME-EVENT-IN-BLOCK-TAG" USING WS-STATE L-TAG L-FLAG
     END-IF
     GOBACK.
 END PROGRAM GAME-EVENT-TAGGED.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GAME-EVENT-RAY.
*> USING dim, start xyz, end xyz (FLOAT-LONG), hit out: BlockGetter.isBlockInLine with the occludes_vibration_signals predicate (31-8 section 3.6.2 and 3.6.3). Equal points: no cell, a miss. The segment is
*> extended by 1e-7 of its vector at both ends (S = A - 1e-7 (B - A), T = B + 1e-7 (B - A)), the cell floor(S) is tested first, then at every step the axis with the smallest tmax <= 1 is crossed (a tie goes to Z over Y
*> over X) and the new cell tested; the cell holding T is the last. A cell holding wool (the block tag member list) ends the walk with a hit.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-EXTEND              FLOAT-LONG VALUE 0.0000001.
 01 WS-BIG                 FLOAT-LONG VALUE 1000000000000000000000000000000.
 01 WS-TAG                 BINARY-LONG VALUE 2.
 01 WS-S1                  FLOAT-LONG.
 01 WS-S2                  FLOAT-LONG.
 01 WS-S3                  FLOAT-LONG.
 01 WS-D1                  FLOAT-LONG.
 01 WS-D2                  FLOAT-LONG.
 01 WS-D3                  FLOAT-LONG.
 01 WS-SG1                 BINARY-LONG.
 01 WS-SG2                 BINARY-LONG.
 01 WS-SG3                 BINARY-LONG.
 01 WS-ST1                 FLOAT-LONG.
 01 WS-ST2                 FLOAT-LONG.
 01 WS-ST3                 FLOAT-LONG.
 01 WS-TM1                 FLOAT-LONG.
 01 WS-TM2                 FLOAT-LONG.
 01 WS-TM3                 FLOAT-LONG.
 01 WS-C1                  BINARY-LONG.
 01 WS-C2                  BINARY-LONG.
 01 WS-C3                  BINARY-LONG.
 01 WS-F1                  FLOAT-LONG.
 01 WS-F2                  FLOAT-LONG.
 01 WS-F3                  FLOAT-LONG.
 01 WS-DONE                BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-SX                   FLOAT-LONG.
 01 L-SY                   FLOAT-LONG.
 01 L-SZ                   FLOAT-LONG.
 01 L-EX                   FLOAT-LONG.
 01 L-EY                   FLOAT-LONG.
 01 L-EZ                   FLOAT-LONG.
 01 L-HIT                  BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-SX L-SY L-SZ L-EX L-EY L-EZ L-HIT.
     MOVE 0 TO L-HIT WS-DONE
     IF L-SX = L-EX AND L-SY = L-EY AND L-SZ = L-EZ
         GOBACK
     END-IF
     COMPUTE WS-S1 = L-SX - WS-EXTEND * (L-EX - L-SX)
     COMPUTE WS-S2 = L-SY - WS-EXTEND * (L-EY - L-SY)
     COMPUTE WS-S3 = L-SZ - WS-EXTEND * (L-EZ - L-SZ)
     COMPUTE WS-D1 = L-EX + WS-EXTEND * (L-EX - L-SX) - WS-S1
     COMPUTE WS-D2 = L-EY + WS-EXTEND * (L-EY - L-SY) - WS-S2
     COMPUTE WS-D3 = L-EZ + WS-EXTEND * (L-EZ - L-SZ) - WS-S3
     COMPUTE WS-C1 = FUNCTION INTEGER(WS-S1)
     COMPUTE WS-C2 = FUNCTION INTEGER(WS-S2)
     COMPUTE WS-C3 = FUNCTION INTEGER(WS-S3)
     COMPUTE WS-F1 = WS-S1 - WS-C1
     COMPUTE WS-F2 = WS-S2 - WS-C2
     COMPUTE WS-F3 = WS-S3 - WS-C3
     MOVE WS-BIG TO WS-ST1 WS-ST2 WS-ST3
     MOVE 0 TO WS-SG1 WS-SG2 WS-SG3
     IF WS-D1 > 0
         MOVE 1 TO WS-SG1
         COMPUTE WS-ST1 = 1 / WS-D1
     END-IF
     IF WS-D1 < 0
         MOVE -1 TO WS-SG1
         COMPUTE WS-ST1 = -1 / WS-D1
     END-IF
     IF WS-D2 > 0
         MOVE 1 TO WS-SG2
         COMPUTE WS-ST2 = 1 / WS-D2
     END-IF
     IF WS-D2 < 0
         MOVE -1 TO WS-SG2
         COMPUTE WS-ST2 = -1 / WS-D2
     END-IF
     IF WS-D3 > 0
         MOVE 1 TO WS-SG3
         COMPUTE WS-ST3 = 1 / WS-D3
     END-IF
     IF WS-D3 < 0
         MOVE -1 TO WS-SG3
         COMPUTE WS-ST3 = -1 / WS-D3
     END-IF
     COMPUTE WS-TM1 = WS-ST1 * WS-F1
     IF WS-SG1 > 0
         COMPUTE WS-TM1 = WS-ST1 * (1 - WS-F1)
     END-IF
     COMPUTE WS-TM2 = WS-ST2 * WS-F2
     IF WS-SG2 > 0
         COMPUTE WS-TM2 = WS-ST2 * (1 - WS-F2)
     END-IF
     COMPUTE WS-TM3 = WS-ST3 * WS-F3
     IF WS-SG3 > 0
         COMPUTE WS-TM3 = WS-ST3 * (1 - WS-F3)
     END-IF
     CALL "GAME-EVENT-TAGGED" USING L-DIM WS-C1 WS-C2 WS-C3 WS-TAG L-HIT
     IF L-HIT = 1
         MOVE 1 TO WS-DONE
     END-IF
     PERFORM UNTIL WS-DONE = 1 OR (WS-TM1 > 1 AND WS-TM2 > 1 AND WS-TM3 > 1)
         EVALUATE TRUE
             WHEN WS-TM3 <= WS-TM1 AND WS-TM3 <= WS-TM2
                 ADD WS-SG3 TO WS-C3
                 ADD WS-ST3 TO WS-TM3
             WHEN WS-TM2 <= WS-TM1
                 ADD WS-SG2 TO WS-C2
                 ADD WS-ST2 TO WS-TM2
             WHEN OTHER
                 ADD WS-SG1 TO WS-C1
                 ADD WS-ST1 TO WS-TM1
         END-EVALUATE
         CALL "GAME-EVENT-TAGGED" USING L-DIM WS-C1 WS-C2 WS-C3 WS-TAG L-HIT
         IF L-HIT = 1
             MOVE 1 TO WS-DONE
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM GAME-EVENT-RAY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GAME-EVENT-OCCLUDED.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-OFFSET              FLOAT-LONG VALUE 0.000009999999747378752.
 01 WS-EX                  FLOAT-LONG.
 01 WS-EY                  FLOAT-LONG.
 01 WS-EZ                  FLOAT-LONG.
 01 WS-LX                  FLOAT-LONG.
 01 WS-LY                  FLOAT-LONG.
 01 WS-LZ                  FLOAT-LONG.
 01 WS-SX                  FLOAT-LONG.
 01 WS-SY                  FLOAT-LONG.
 01 WS-SZ                  FLOAT-LONG.
 01 WS-D                   BINARY-LONG.
 01 WS-HIT                 BINARY-LONG.
 01 WS-HALF                FLOAT-LONG VALUE 0.5.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-EX                   FLOAT-LONG.
 01 L-EY                   FLOAT-LONG.
 01 L-EZ                   FLOAT-LONG.
 01 L-LX                   FLOAT-LONG.
 01 L-LY                   FLOAT-LONG.
 01 L-LZ                   FLOAT-LONG.
 01 L-OCCLUDED             BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-EX L-EY L-EZ L-LX L-LY L-LZ L-OCCLUDED.
     COMPUTE WS-EX = FUNCTION INTEGER(L-EX) + WS-HALF
     COMPUTE WS-EY = FUNCTION INTEGER(L-EY) + WS-HALF
     COMPUTE WS-EZ = FUNCTION INTEGER(L-EZ) + WS-HALF
     COMPUTE WS-LX = FUNCTION INTEGER(L-LX) + WS-HALF
     COMPUTE WS-LY = FUNCTION INTEGER(L-LY) + WS-HALF
     COMPUTE WS-LZ = FUNCTION INTEGER(L-LZ) + WS-HALF
     MOVE 1 TO L-OCCLUDED
     PERFORM VARYING WS-D FROM 0 BY 1 UNTIL WS-D > 5 OR L-OCCLUDED = 0
         MOVE WS-EX TO WS-SX
         MOVE WS-EY TO WS-SY
         MOVE WS-EZ TO WS-SZ
         EVALUATE WS-D
             WHEN 0
                 SUBTRACT WS-OFFSET FROM WS-SY
             WHEN 1
                 ADD WS-OFFSET TO WS-SY
             WHEN 2
                 SUBTRACT WS-OFFSET FROM WS-SZ
             WHEN 3
                 ADD WS-OFFSET TO WS-SZ
             WHEN 4
                 SUBTRACT WS-OFFSET FROM WS-SX
             WHEN OTHER
                 ADD WS-OFFSET TO WS-SX
         END-EVALUATE
         CALL "GAME-EVENT-RAY" USING L-DIM WS-SX WS-SY WS-SZ WS-LX WS-LY WS-LZ WS-HIT
         IF WS-HIT = 0
             MOVE 0 TO L-OCCLUDED
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM GAME-EVENT-OCCLUDED.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GAME-EVENT-SENSORS.
*> The shared hook (see the head of the file). USING dim, x, y, z (FLOAT-LONG), event name, frequency, source entity row, block state: no sculk listener exists in this lane, so nothing is told here.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    FLOAT-LONG.
 01 L-Y                    FLOAT-LONG.
 01 L-Z                    FLOAT-LONG.
 01 L-EVENT                PIC X(32).
 01 L-FREQUENCY            BINARY-LONG.
 01 L-SOURCE               BINARY-LONG.
 01 L-STATE                BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z L-EVENT L-FREQUENCY L-SOURCE L-STATE.
     GOBACK.
 END PROGRAM GAME-EVENT-SENSORS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GAME-EVENT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CITEMS.
 COPY STDMOBS.
 COPY GAMEEVENT.
 01 WS-FREQ                BINARY-LONG.
 01 WS-WARDEN              BINARY-LONG.
 01 WS-FLAGS               BINARY-LONG.
 01 WS-LISTENS             BINARY-LONG.
 01 WS-SNEAKS              BINARY-LONG.
 01 WS-M                   BINARY-LONG.
 01 WS-CODE                BINARY-LONG.
 01 WS-OWNER               BINARY-LONG.
 01 WS-SNEAK               BINARY-LONG.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-P                   BINARY-LONG.
 01 WS-ARROW               BINARY-LONG.
 01 WS-TAGGED              BINARY-LONG.
 01 WS-SOURCE              BINARY-LONG.
 01 WS-DAMPENS             BINARY-LONG VALUE 1.
 01 WS-CAREFUL             BINARY-LONG.
 01 WS-ITEM-KEY            PIC X(48).
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    FLOAT-LONG.
 01 L-Y                    FLOAT-LONG.
 01 L-Z                    FLOAT-LONG.
 01 L-EVENT                PIC X(32).
 01 L-SOURCE               BINARY-LONG.
 01 L-STATE                BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z L-EVENT L-SOURCE L-STATE.
*>   The record of what was posted (GAMEEVENT.cpy).
     ADD 1 TO GE-COUNT
     MOVE L-EVENT TO GE-NAME
     MOVE L-X TO GE-X
     MOVE L-Y TO GE-Y
     MOVE L-Z TO GE-Z
     MOVE L-SOURCE TO GE-SOURCE
     MOVE L-STATE TO GE-STATE
     CALL "GAME-EVENT-FREQUENCY" USING L-EVENT WS-FREQ
     CALL "GAME-EVENT-LISTENS" USING L-EVENT WS-LISTENS
     IF WS-FREQ = 0 AND WS-LISTENS = 0
         GOBACK
     END-IF
     MOVE L-SOURCE TO WS-SOURCE
     MOVE 0 TO WS-CODE WS-OWNER WS-SNEAK WS-CAREFUL
     IF WS-SOURCE > 0
         IF EN-USED(WS-SOURCE) NOT = 1
             MOVE 0 TO WS-SOURCE
         END-IF
     END-IF
     IF WS-SOURCE > 0
         MOVE EN-PLAYER(WS-SOURCE) TO WS-PLAYER
         CALL "STDMOB-INDEX" USING EN-TYPE(WS-SOURCE) WS-M
         MOVE 0 TO WS-WARDEN
         IF WS-M > 0
             IF SM-KEY(WS-M) = "warden"
                 MOVE 1 TO WS-WARDEN
             END-IF
         END-IF
         EVALUATE TRUE
             WHEN WS-PLAYER > 0
*>               a spectator is never a valid source; the shift key with an event of ignore_vibrations_sneaking filters the player out
                 IF PL-MODE(WS-PLAYER) = 3
                     GOBACK
                 END-IF
                 MOVE WS-PLAYER TO WS-CODE
*>               Entity.isSteppingCarefully: the shift-key flag (30-8 section 3.5)
                 COMPUTE WS-FLAGS = PL-POSE-FLAGS(WS-PLAYER) / 2
                 IF FUNCTION MOD(WS-FLAGS, 2) = 1
                     MOVE 1 TO WS-CAREFUL
                 END-IF
             WHEN WS-WARDEN = 1
*>               Warden.dampensVibrations: the warden never hears its own events and a sculk sensor never hears it either
                 GOBACK
             WHEN WS-M > 0
                 COMPUTE WS-CODE = CORE-MAX-PLAYERS + WS-SOURCE
*>               a crouching cat or ocelot is also stepping carefully (Cat and Ocelot override isSteppingCarefully with isCrouching, 30-8 section 3.5.1)
                 IF EN-CROUCHING(WS-SOURCE) = 1 AND (SM-KEY(WS-M) = "cat" OR SM-KEY(WS-M) = "ocelot")
                     MOVE 1 TO WS-CAREFUL
                 END-IF
             WHEN EN-TYPE(WS-SOURCE) = CR-LOOSE-ITEM
*>               ItemEntity.dampensVibrations: the stack is in the item tag dampens_vibrations (wool)
                 MOVE IT-KEY(EN-ITEM(WS-SOURCE) + 1) TO WS-ITEM-KEY
                 CALL "GAME-EVENT-WOOL-KEY" USING WS-ITEM-KEY WS-DAMPENS WS-TAGGED
                 IF WS-TAGGED = 1
                     GOBACK
                 END-IF
             WHEN OTHER
*>               a projectile: the vibration carries its owner (31-8 section 3.5: getProjectileOwner), an arrow's EN-TARGET-ID is the owner's entity id
                 CALL "ARROW-TYPE" USING WS-ARROW
                 IF EN-TYPE(WS-SOURCE) = WS-ARROW
                     PERFORM VARYING WS-P FROM 1 BY 1 UNTIL WS-P > CORE-MAX-PLAYERS
                         IF PL-USED(WS-P) = 1 AND PL-ENTITY-ID(WS-P) = EN-TARGET-ID(WS-SOURCE) AND PL-MODE(WS-P) NOT = 3
                             MOVE WS-P TO WS-OWNER
                         END-IF
                     END-PERFORM
                 END-IF
         END-EVALUATE
     END-IF
*>   a careful source (shift key, crouching cat or ocelot) with an event of ignore_vibrations_sneaking is not valid (30-8 section 3.5 step 2)
     IF WS-CAREFUL = 1
         CALL "GAME-EVENT-SNEAKS" USING L-EVENT WS-SNEAKS
         IF WS-SNEAKS = 1
             GOBACK
         END-IF
     END-IF
*>   the affected block state in the block tag dampens_vibrations (30 section 3.5 step 3)
     IF L-STATE > 0
         CALL "GAME-EVENT-IN-BLOCK-TAG" USING L-STATE WS-DAMPENS WS-TAGGED
         IF WS-TAGGED = 1
             GOBACK
         END-IF
     END-IF
     CALL "GAME-EVENT-SENSORS" USING L-DIM L-X L-Y L-Z L-EVENT WS-FREQ WS-SOURCE L-STATE
     IF WS-LISTENS = 1
         CALL "WARDEN-HEAR" USING L-DIM L-X L-Y L-Z WS-CODE WS-OWNER WS-SNEAK
     END-IF
     GOBACK.
 END PROGRAM GAME-EVENT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GAME-EVENT-BLOCK.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-SOURCE              BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-BX                   BINARY-LONG.
 01 L-BY                   BINARY-LONG.
 01 L-BZ                   BINARY-LONG.
 01 L-EVENT                PIC X(32).
 01 L-PLAYER               BINARY-LONG.
 01 L-STATE                BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-BX L-BY L-BZ L-EVENT L-PLAYER L-STATE.
     COMPUTE WS-X = L-BX + 0.5
     COMPUTE WS-Y = L-BY + 0.5
     COMPUTE WS-Z = L-BZ + 0.5
     MOVE 0 TO WS-SOURCE
     IF L-PLAYER > 0
         MOVE PL-ENTITY-ROW(L-PLAYER) TO WS-SOURCE
     END-IF
     CALL "GAME-EVENT" USING L-DIM WS-X WS-Y WS-Z L-EVENT WS-SOURCE L-STATE
     GOBACK.
 END PROGRAM GAME-EVENT-BLOCK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GAME-EVENT-AT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-STATE               BINARY-LONG VALUE -1.
 LINKAGE SECTION.
 01 L-EVENT                PIC X(32).
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-EVENT L-ROW.
     MOVE EN-X(L-ROW) TO WS-X
     MOVE EN-Y(L-ROW) TO WS-Y
     MOVE EN-Z(L-ROW) TO WS-Z
     IF EN-PLAYER(L-ROW) > 0
         MOVE PL-X(EN-PLAYER(L-ROW)) TO WS-X
         MOVE PL-Y(EN-PLAYER(L-ROW)) TO WS-Y
         MOVE PL-Z(EN-PLAYER(L-ROW)) TO WS-Z
     END-IF
     CALL "GAME-EVENT" USING EN-DIM(L-ROW) WS-X WS-Y WS-Z L-EVENT L-ROW WS-STATE
     GOBACK.
 END PROGRAM GAME-EVENT-AT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GAME-EVENT-SHOOT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-EVENT               PIC X(32) VALUE "projectile_shoot".
 01 WS-STATE               BINARY-LONG VALUE -1.
 01 WS-E                   BINARY-LONG.
 01 WS-OWNER               BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-OWNER-ID             BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-OWNER-ID.
     MOVE 0 TO WS-OWNER
     PERFORM VARYING WS-E FROM 1 BY 1 UNTIL WS-E > EN-COUNT
         IF EN-USED(WS-E) = 1 AND EN-ID(WS-E) = L-OWNER-ID AND WS-E NOT = L-ROW
             MOVE WS-E TO WS-OWNER
         END-IF
     END-PERFORM
     CALL "GAME-EVENT" USING EN-DIM(L-ROW) EN-X(L-ROW) EN-Y(L-ROW) EN-Z(L-ROW) WS-EVENT WS-OWNER WS-STATE
     GOBACK.
 END PROGRAM GAME-EVENT-SHOOT.
