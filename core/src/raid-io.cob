*> The saved data of raids (docs/protocol/44 section 5 "Persistence", 45-entity-nbt-6 sections 12.2, 12.3 and 14.5, 07 section 9.6; lane 002-lane-p49h, T22007): a standard
*> world keeps one file per dimension, dimensions/minecraft/<dimension>/data/minecraft/raids.dat (gzip NBT, root keys data and DataVersion 5023) holding next_id, tick and a
*> compound per raid (id, started, active, ticks_active, raid_omen_level, groups_spawned, cooldown_ticks, post_raid_ticks, total_health, group_count, status, center,
*> heroes_of_the_village). A cobolcraft world writes none (07 section 9.6). The state is RAIDSTATE.cpy. Gaps: the heroes are written as the UUIDs of the players in play but read back
*> as none (RD-HERO holds entity ids, which a new session does not know), the raiders of a wave rejoin through their own save (RaidId is not saved), RD-NEXT-ID is one counter for
*> every dimension, `tick` is the game tick of the save.
*>   RAID-IO USING action (1 load: clears the raids and reads the file of every standard dimension, 2 save: writes the file of a standard dimension that has raids or has a file)
*>   RAID-FILE-PATH USING dimension row, path out (PIC X(1100)), path length out
*>   RAID-NBT-WRITE USING PB-BUFFER, dimension row      the file's root of that dimension (the raids of RD-ENTRY whose RD-DIM it is)
*>   RAID-NBT-READ USING PB-BUFFER, dimension row       the raids of the file's root enter RD-ENTRY of that dimension; RD-NEXT-ID becomes the largest next_id read

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RAID-FILE-PATH.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-DIR                 PIC X(1024).
 01 WS-DIR-LENGTH          BINARY-LONG.
 01 WS-KIND                PIC X(8) VALUE "data".
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-PATH                 PIC X(1100).
 01 L-LENGTH               BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-PATH L-LENGTH.
     CALL "PERSIST-DIM-DIR" USING L-DIM WS-KIND WS-DIR WS-DIR-LENGTH
     MOVE SPACES TO L-PATH
     STRING WS-DIR(1:WS-DIR-LENGTH) "/minecraft/raids.dat" DELIMITED BY SIZE INTO L-PATH
     COMPUTE L-LENGTH = WS-DIR-LENGTH + 20
     GOBACK.
 END PROGRAM RAID-FILE-PATH.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RAID-IO.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY DIMENSIONS.
 COPY RAIDSTATE.
 01 WS-D                   BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-PATH                PIC X(1100).
 01 WS-PATH-LENGTH         BINARY-LONG.
 01 WS-MADE                PIC X(1100).
 01 WS-INFO                PIC X(16).
 01 WS-EXISTS              BINARY-LONG.
 LINKAGE SECTION.
 01 L-ACTION               BINARY-LONG.
 PROCEDURE DIVISION USING L-ACTION.
     IF L-ACTION = 1
         INITIALIZE RD-STATE
     END-IF
     PERFORM VARYING WS-D FROM 1 BY 1 UNTIL WS-D > CW-DIM-COUNT
         MOVE CW-DIM(WS-D) TO WS-DIM
         IF DM-KEY(WS-DIM)(1:10) = "minecraft:"
             CALL "RAID-FILE-PATH" USING WS-DIM WS-PATH WS-PATH-LENGTH
             MOVE SPACES TO WS-MADE
             STRING WS-PATH(1:WS-PATH-LENGTH) X"00" DELIMITED BY SIZE INTO WS-MADE
             CALL "CBL_CHECK_FILE_EXIST" USING WS-MADE WS-INFO
             MOVE RETURN-CODE TO WS-EXISTS
             MOVE 0 TO RETURN-CODE
             MOVE 0 TO WS-COUNT
             PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > RD-MAX
                 IF RD-USED(WS-I) = 1 AND RD-DIM(WS-I) = WS-DIM
                     ADD 1 TO WS-COUNT
                 END-IF
             END-PERFORM
*>           A dimension without raids and without a file writes none; one whose file exists is rewritten so that an ended raid is not resurrected.
             IF L-ACTION = 1 AND WS-EXISTS = 0
                 CALL "RAID-FILE-LOAD" USING WS-DIM WS-PATH WS-PATH-LENGTH
             END-IF
             IF L-ACTION = 2 AND (WS-COUNT > 0 OR WS-EXISTS = 0)
                 CALL "RAID-FILE-SAVE" USING WS-DIM WS-PATH WS-PATH-LENGTH
             END-IF
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM RAID-IO.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RAID-FILE-LOAD.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY PROTO.
 01 WS-OUTCOME             BINARY-LONG.
 01 WS-CAPACITY            BINARY-LONG VALUE 16384.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-PATH                 PIC X(1100).
 01 L-LENGTH               BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-PATH L-LENGTH.
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "NBT-FILE-READ" USING L-PATH L-LENGTH PB-BUFFER WS-OUTCOME
*>   A file that cannot be read is an empty value (45-6 section 12.3).
     IF WS-OUTCOME = 0
         CALL "RAID-NBT-READ" USING PB-BUFFER L-DIM
     END-IF
     CALL "PB-FREE" USING PB-BUFFER
     GOBACK.
 END PROGRAM RAID-FILE-LOAD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RAID-FILE-SAVE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY PROTO.
 01 WS-MADE                PIC X(1100).
 01 WS-CAPACITY            BINARY-LONG VALUE 16384.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-PATH                 PIC X(1100).
 01 L-LENGTH               BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-PATH L-LENGTH.
*>   data/ and data/minecraft/ of the dimension's folder are made first (the path ends in /minecraft/raids.dat, 20 bytes).
     MOVE SPACES TO WS-MADE
     STRING L-PATH(1:L-LENGTH - 20) X"00" DELIMITED BY SIZE INTO WS-MADE
     CALL "CBL_CREATE_DIR" USING WS-MADE
     MOVE SPACES TO WS-MADE
     STRING L-PATH(1:L-LENGTH - 10) X"00" DELIMITED BY SIZE INTO WS-MADE
     CALL "CBL_CREATE_DIR" USING WS-MADE
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "RAID-NBT-WRITE" USING PB-BUFFER L-DIM
     CALL "PERSIST-WRITE-FILE" USING L-PATH L-LENGTH PB-BUFFER
     CALL "PB-FREE" USING PB-BUFFER
     GOBACK.
 END PROGRAM RAID-FILE-SAVE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RAID-NBT-WRITE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY RAIDSTATE.
 COPY BRWORLD.
 01 WN                     PIC X(32).
 01 WL                     BINARY-LONG.
 01 WS-ELEMENT             BINARY-LONG VALUE -1.
 01 WS-VERSION             BINARY-LONG VALUE 5023.
 01 WS-COUNT               BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-H                   BINARY-LONG.
 01 WS-P                   BINARY-LONG.
 01 WS-HEROES              BINARY-LONG.
 01 WS-GROUPS              BINARY-LONG.
 01 WS-ACTIVE              BINARY-LONG.
 01 WS-LONG                BINARY-DOUBLE.
 01 WS-HEALTH              FLOAT-SHORT.
 01 WS-STATUS              PIC X(8).
 01 WS-STATUS-LENGTH       BINARY-LONG.
 01 WS-TICK                BINARY-LONG.
 01 WS-THREE               BINARY-LONG VALUE 3.
 01 WS-FOUR                BINARY-LONG VALUE 4.
 01 WS-DIRECTION           BINARY-LONG VALUE 0.
 01 WS-T-COMPOUND          BINARY-LONG VALUE 10.
 01 WS-T-INTS              BINARY-LONG VALUE 11.
 01 WS-CENTRE.
    05 WS-CENTRE-INT       BINARY-LONG OCCURS 3 TIMES.
 01 WS-UUID.
    05 WS-UUID-INT         BINARY-LONG OCCURS 4 TIMES.
 LINKAGE SECTION.
 COPY PROTO.
 01 L-DIM                  BINARY-LONG.
 PROCEDURE DIVISION USING PB-BUFFER L-DIM.
     CALL "PB-RESET" USING PB-BUFFER
     MOVE 0 TO WS-COUNT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > RD-MAX
         IF RD-USED(WS-I) = 1 AND RD-DIM(WS-I) = L-DIM
             ADD 1 TO WS-COUNT
         END-IF
     END-PERFORM
     CALL "RAID-NUM-GROUPS" USING BW-DIFFICULTY WS-GROUPS
     MOVE SPACES TO WN
     MOVE 0 TO WL
     CALL "NBT-WRITE-COMPOUND-BEGIN" USING PB-BUFFER WN WL
     MOVE "DataVersion" TO WN MOVE 11 TO WL
     CALL "NBT-WRITE-INT" USING PB-BUFFER WN WL WS-VERSION
     MOVE "data" TO WN MOVE 4 TO WL
     CALL "NBT-WRITE-COMPOUND-BEGIN" USING PB-BUFFER WN WL
     MOVE "next_id" TO WN MOVE 7 TO WL
     CALL "NBT-WRITE-INT" USING PB-BUFFER WN WL RD-NEXT-ID
     MOVE "tick" TO WN MOVE 4 TO WL
     MOVE CW-TICKS TO WS-TICK
     CALL "NBT-WRITE-INT" USING PB-BUFFER WN WL WS-TICK
*>   The raids key is omitted for an empty list (45-6 section 14.5).
     IF WS-COUNT > 0
         MOVE "raids" TO WN MOVE 5 TO WL
         CALL "NBT-WRITE-LIST-BEGIN" USING PB-BUFFER WN WL WS-T-COMPOUND WS-COUNT
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > RD-MAX
             IF RD-USED(WS-I) = 1 AND RD-DIM(WS-I) = L-DIM
                 CALL "NBT-WRITE-COMPOUND-BEGIN" USING PB-BUFFER WN WS-ELEMENT
                 MOVE "id" TO WN MOVE 2 TO WL
                 CALL "NBT-WRITE-INT" USING PB-BUFFER WN WL RD-ID(WS-I)
                 MOVE "started" TO WN MOVE 7 TO WL
                 CALL "NBT-WRITE-BYTE" USING PB-BUFFER WN WL RD-STARTED(WS-I)
                 MOVE 0 TO WS-ACTIVE
                 IF RD-STATUS(WS-I) = 1
                     MOVE 1 TO WS-ACTIVE
                 END-IF
                 MOVE "active" TO WN MOVE 6 TO WL
                 CALL "NBT-WRITE-BYTE" USING PB-BUFFER WN WL WS-ACTIVE
                 MOVE "ticks_active" TO WN MOVE 12 TO WL
                 MOVE RD-TICKS(WS-I) TO WS-LONG
                 CALL "NBT-WRITE-LONG" USING PB-BUFFER WN WL WS-LONG
                 MOVE "raid_omen_level" TO WN MOVE 15 TO WL
                 CALL "NBT-WRITE-INT" USING PB-BUFFER WN WL RD-OMEN(WS-I)
                 MOVE "groups_spawned" TO WN MOVE 14 TO WL
                 CALL "NBT-WRITE-INT" USING PB-BUFFER WN WL RD-GROUPS(WS-I)
                 MOVE "cooldown_ticks" TO WN MOVE 14 TO WL
                 CALL "NBT-WRITE-INT" USING PB-BUFFER WN WL RD-COOLDOWN(WS-I)
                 MOVE "post_raid_ticks" TO WN MOVE 15 TO WL
                 CALL "NBT-WRITE-INT" USING PB-BUFFER WN WL RD-POST(WS-I)
                 MOVE "total_health" TO WN MOVE 12 TO WL
                 COMPUTE WS-HEALTH = RD-TOTAL(WS-I) / 1000
                 CALL "NBT-WRITE-FLOAT" USING PB-BUFFER WN WL WS-HEALTH
                 MOVE "group_count" TO WN MOVE 11 TO WL
                 CALL "NBT-WRITE-INT" USING PB-BUFFER WN WL WS-GROUPS
                 MOVE "status" TO WN MOVE 6 TO WL
                 EVALUATE RD-STATUS(WS-I)
                     WHEN 2
                         MOVE "victory" TO WS-STATUS
                         MOVE 7 TO WS-STATUS-LENGTH
                     WHEN 3
                         MOVE "loss" TO WS-STATUS
                         MOVE 4 TO WS-STATUS-LENGTH
                     WHEN 4
                         MOVE "stopped" TO WS-STATUS
                         MOVE 7 TO WS-STATUS-LENGTH
                     WHEN OTHER
                         MOVE "ongoing" TO WS-STATUS
                         MOVE 7 TO WS-STATUS-LENGTH
                 END-EVALUATE
                 CALL "NBT-WRITE-STRING" USING PB-BUFFER WN WL WS-STATUS WS-STATUS-LENGTH
                 MOVE "center" TO WN MOVE 6 TO WL
                 MOVE RD-CX(WS-I) TO WS-CENTRE-INT(1)
                 MOVE RD-CY(WS-I) TO WS-CENTRE-INT(2)
                 MOVE RD-CZ(WS-I) TO WS-CENTRE-INT(3)
                 CALL "NBT-WRITE-INT-ARRAY" USING PB-BUFFER WN WL WS-THREE WS-CENTRE
*>               The heroes: the UUIDs of the players in play that hold the effect (RD-HERO holds their entity ids).
                 MOVE 0 TO WS-HEROES
                 PERFORM VARYING WS-H FROM 1 BY 1 UNTIL WS-H > 8
                     PERFORM VARYING WS-P FROM 1 BY 1 UNTIL WS-P > CORE-MAX-PLAYERS
                         IF RD-HERO(WS-I, WS-H) > 0 AND PL-USED(WS-P) = 1 AND PL-ENTITY-ID(WS-P) = RD-HERO(WS-I, WS-H)
                             ADD 1 TO WS-HEROES
                         END-IF
                     END-PERFORM
                 END-PERFORM
                 MOVE "heroes_of_the_village" TO WN MOVE 21 TO WL
                 CALL "NBT-WRITE-LIST-BEGIN" USING PB-BUFFER WN WL WS-T-INTS WS-HEROES
                 PERFORM VARYING WS-H FROM 1 BY 1 UNTIL WS-H > 8
                     PERFORM VARYING WS-P FROM 1 BY 1 UNTIL WS-P > CORE-MAX-PLAYERS
                         IF RD-HERO(WS-I, WS-H) > 0 AND PL-USED(WS-P) = 1 AND PL-ENTITY-ID(WS-P) = RD-HERO(WS-I, WS-H)
                             CALL "PERSIST-UUID-INTS" USING WS-DIRECTION PL-UUID(WS-P) WS-UUID
                             CALL "NBT-WRITE-INT-ARRAY" USING PB-BUFFER WN WS-ELEMENT WS-FOUR WS-UUID
                         END-IF
                     END-PERFORM
                 END-PERFORM
                 CALL "NBT-WRITE-LIST-END" USING PB-BUFFER
                 CALL "NBT-WRITE-COMPOUND-END" USING PB-BUFFER
             END-IF
         END-PERFORM
         CALL "NBT-WRITE-LIST-END" USING PB-BUFFER
     END-IF
     CALL "NBT-WRITE-COMPOUND-END" USING PB-BUFFER
     CALL "NBT-WRITE-COMPOUND-END" USING PB-BUFFER
     GOBACK.
 END PROGRAM RAID-NBT-WRITE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RAID-NBT-READ.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY RAIDSTATE.
 01 WN                     PIC X(32).
 01 WL                     BINARY-LONG.
 01 WS-CAPACITY            BINARY-LONG VALUE 32.
 01 WS-FRAMING             BINARY-LONG VALUE 1.
 01 WS-TYPE                BINARY-LONG.
 01 WS-INNER               BINARY-LONG.
 01 WS-ET                  BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-NEXT                BINARY-LONG.
 LINKAGE SECTION.
 COPY PROTO.
 01 L-DIM                  BINARY-LONG.
 PROCEDURE DIVISION USING PB-BUFFER L-DIM.
     MOVE 0 TO PB-POS
     CALL "NBT-READ-ROOT" USING PB-BUFFER WS-FRAMING WS-TYPE
     PERFORM UNTIL PB-ERROR = 1
         MOVE SPACES TO WN
         CALL "NBT-READ-COMPOUND-NEXT" USING PB-BUFFER WS-TYPE WN WS-CAPACITY WL
         IF WS-TYPE = 0
             EXIT PERFORM
         END-IF
         IF WN = "data" AND WS-TYPE = 10
             PERFORM UNTIL PB-ERROR = 1
                 MOVE SPACES TO WN
                 CALL "NBT-READ-COMPOUND-NEXT" USING PB-BUFFER WS-INNER WN WS-CAPACITY WL
                 IF WS-INNER = 0
                     EXIT PERFORM
                 END-IF
                 EVALUATE TRUE
                     WHEN WN = "next_id" AND WS-INNER = 3
                         CALL "PB-GET-INT" USING PB-BUFFER WS-NEXT
                         IF WS-NEXT > RD-NEXT-ID
                             MOVE WS-NEXT TO RD-NEXT-ID
                         END-IF
                     WHEN WN = "raids" AND WS-INNER = 9
                         CALL "NBT-READ-LIST-BEGIN" USING PB-BUFFER WS-ET WS-COUNT
                         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-COUNT OR PB-ERROR = 1
                             CALL "RAID-NBT-READ-ONE" USING PB-BUFFER L-DIM
                         END-PERFORM
                     WHEN OTHER
                         CALL "NBT-READ-SKIP" USING PB-BUFFER WS-INNER
                 END-EVALUATE
             END-PERFORM
         ELSE
             CALL "NBT-READ-SKIP" USING PB-BUFFER WS-TYPE
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM RAID-NBT-READ.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RAID-NBT-READ-ONE.
*> USING PB-BUFFER (at the payload of one raid compound), dimension row: the raid enters the first free RD-ENTRY (a raid that finds none is dropped).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY RAIDSTATE.
 01 WN                     PIC X(32).
 01 WL                     BINARY-LONG.
 01 WS-CAPACITY            BINARY-LONG VALUE 32.
 01 WS-TYPE                BINARY-LONG.
 01 WS-SLOT                BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-ID                  BINARY-LONG.
 01 WS-STARTED             BINARY-LONG.
 01 WS-TICKS               BINARY-DOUBLE.
 01 WS-OMEN                BINARY-LONG.
 01 WS-GROUPS              BINARY-LONG.
 01 WS-COOLDOWN            BINARY-LONG.
 01 WS-POST                BINARY-LONG.
 01 WS-HEALTH              FLOAT-SHORT.
 01 WS-TOTAL               BINARY-LONG.
 01 WS-STATUS              BINARY-LONG VALUE 1.
 01 WS-TEXT                PIC X(16).
 01 WS-TEXT-LENGTH         BINARY-LONG.
 01 WS-TEXT-CAPACITY       BINARY-LONG VALUE 16.
 01 WS-CAP3                BINARY-LONG VALUE 3.
 01 WS-COUNT               BINARY-LONG.
 01 WS-CENTRE.
    05 WS-CENTRE-INT       BINARY-LONG OCCURS 3 TIMES.
 LINKAGE SECTION.
 COPY PROTO.
 01 L-DIM                  BINARY-LONG.
 PROCEDURE DIVISION USING PB-BUFFER L-DIM.
     MOVE 0 TO WS-ID WS-STARTED WS-TICKS WS-OMEN WS-GROUPS WS-COOLDOWN WS-POST WS-TOTAL
     MOVE 1 TO WS-STATUS
     MOVE 0 TO WS-CENTRE-INT(1) WS-CENTRE-INT(2) WS-CENTRE-INT(3)
     PERFORM UNTIL PB-ERROR = 1
         MOVE SPACES TO WN
         CALL "NBT-READ-COMPOUND-NEXT" USING PB-BUFFER WS-TYPE WN WS-CAPACITY WL
         IF WS-TYPE = 0
             EXIT PERFORM
         END-IF
         EVALUATE TRUE
             WHEN WN = "id" AND WS-TYPE = 3
                 CALL "PB-GET-INT" USING PB-BUFFER WS-ID
             WHEN WN = "started" AND WS-TYPE = 1
                 CALL "PB-GET-BYTE" USING PB-BUFFER WS-STARTED
             WHEN WN = "ticks_active" AND WS-TYPE = 4
                 CALL "PB-GET-LONG" USING PB-BUFFER WS-TICKS
             WHEN WN = "raid_omen_level" AND WS-TYPE = 3
                 CALL "PB-GET-INT" USING PB-BUFFER WS-OMEN
             WHEN WN = "groups_spawned" AND WS-TYPE = 3
                 CALL "PB-GET-INT" USING PB-BUFFER WS-GROUPS
             WHEN WN = "cooldown_ticks" AND WS-TYPE = 3
                 CALL "PB-GET-INT" USING PB-BUFFER WS-COOLDOWN
             WHEN WN = "post_raid_ticks" AND WS-TYPE = 3
                 CALL "PB-GET-INT" USING PB-BUFFER WS-POST
             WHEN WN = "total_health" AND WS-TYPE = 5
                 CALL "PB-GET-FLOAT" USING PB-BUFFER WS-HEALTH
                 COMPUTE WS-TOTAL ROUNDED = WS-HEALTH * 1000
             WHEN WN = "status" AND WS-TYPE = 8
                 MOVE SPACES TO WS-TEXT
                 CALL "NBT-READ-STRING" USING PB-BUFFER WS-TEXT WS-TEXT-CAPACITY WS-TEXT-LENGTH
                 EVALUATE WS-TEXT
                     WHEN "victory"
                         MOVE 2 TO WS-STATUS
                     WHEN "loss"
                         MOVE 3 TO WS-STATUS
                     WHEN "stopped"
                         MOVE 4 TO WS-STATUS
                     WHEN OTHER
                         MOVE 1 TO WS-STATUS
                 END-EVALUATE
             WHEN WN = "center" AND WS-TYPE = 11
                 CALL "NBT-READ-INT-ARRAY" USING PB-BUFFER WS-CAP3 WS-COUNT WS-CENTRE
             WHEN OTHER
                 CALL "NBT-READ-SKIP" USING PB-BUFFER WS-TYPE
         END-EVALUATE
     END-PERFORM
     MOVE 0 TO WS-SLOT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > RD-MAX OR WS-SLOT > 0
         IF RD-USED(WS-I) = 0
             MOVE WS-I TO WS-SLOT
         END-IF
     END-PERFORM
     IF WS-SLOT > 0
         INITIALIZE RD-ENTRY(WS-SLOT)
         MOVE 1 TO RD-USED(WS-SLOT)
         MOVE WS-ID TO RD-ID(WS-SLOT)
         MOVE L-DIM TO RD-DIM(WS-SLOT)
         MOVE WS-CENTRE-INT(1) TO RD-CX(WS-SLOT)
         MOVE WS-CENTRE-INT(2) TO RD-CY(WS-SLOT)
         MOVE WS-CENTRE-INT(3) TO RD-CZ(WS-SLOT)
         MOVE WS-STATUS TO RD-STATUS(WS-SLOT)
         MOVE WS-STARTED TO RD-STARTED(WS-SLOT)
         MOVE WS-GROUPS TO RD-GROUPS(WS-SLOT)
         MOVE WS-COOLDOWN TO RD-COOLDOWN(WS-SLOT)
         MOVE WS-TICKS TO RD-TICKS(WS-SLOT)
         MOVE WS-POST TO RD-POST(WS-SLOT)
         MOVE WS-OMEN TO RD-OMEN(WS-SLOT)
         MOVE WS-TOTAL TO RD-TOTAL(WS-SLOT)
     END-IF
     GOBACK.
 END PROGRAM RAID-NBT-READ-ONE.
