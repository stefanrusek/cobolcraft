*> Acceptance test (lane p49o, T36040; docs/protocol/16 sections 5.1 kill, 5.2 teleport and 10.1 data): the entities /summon creates answer the commands that take entities. For a sample of
*> every family: `data get entity @e[type=..,limit=1]` reads the saved form (id, Pos, Motion, Rotation; a non-living entity has no Health, 45-8 section 1), `tp` moves the entity (its
*> viewers are sent the move) and `kill` removes it with commands.kill.success.single [type key]. Opal holds operator status in a standard world.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-CMD-SUMMON-ENTITY-CMDS.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY PROTO.
 COPY CITEMS.
 COPY BRWORLD.
 01 WS-ID-OPAL             BINARY-LONG.
 01 WS-ID-BOB              BINARY-LONG.
 01 WS-SUB-DIM             BINARY-LONG VALUE 2.
 01 WS-SUB-X               FLOAT-LONG VALUE 3.5.
 01 WS-SUB-Y               FLOAT-LONG VALUE 40.
 01 WS-SUB-Z               FLOAT-LONG VALUE 3.5.
 01 WS-NAME                PIC X(16).
 01 WS-NAME-LENGTH         BINARY-LONG.
 01 WS-LINE                PIC X(768).
 01 WS-TEXT                PIC X(4096).
 01 WS-DISCARD             PIC X(4096).
 01 WS-EXPECTED            PIC X(1024).
 01 WS-EXPECTED-N          BINARY-DOUBLE.
 01 WS-NUM                 BINARY-DOUBLE.
 01 WS-CASE                PIC X(240).
 01 WS-I                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-KEEP                BINARY-LONG.
 01 WS-KEY-TEXT            PIC X(48).
 01 WS-KEY-LENGTH          BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-HITS                BINARY-LONG.
 01 WS-KEYS.
    05 FILLER PIC X(32) VALUE "oak_boat".
    05 FILLER PIC X(32) VALUE "minecart".
    05 FILLER PIC X(32) VALUE "armor_stand".
    05 FILLER PIC X(32) VALUE "item_frame".
    05 FILLER PIC X(32) VALUE "painting".
    05 FILLER PIC X(32) VALUE "tnt".
    05 FILLER PIC X(32) VALUE "falling_block".
    05 FILLER PIC X(32) VALUE "experience_orb".
    05 FILLER PIC X(32) VALUE "area_effect_cloud".
    05 FILLER PIC X(32) VALUE "end_crystal".
    05 FILLER PIC X(32) VALUE "interaction".
    05 FILLER PIC X(32) VALUE "block_display".
    05 FILLER PIC X(32) VALUE "item_display".
    05 FILLER PIC X(32) VALUE "mannequin".
    05 FILLER PIC X(32) VALUE "cushion".
    05 FILLER PIC X(32) VALUE "marker".
    05 FILLER PIC X(32) VALUE "arrow".
    05 FILLER PIC X(32) VALUE "snowball".
    05 FILLER PIC X(32) VALUE "bat".
    05 FILLER PIC X(32) VALUE "happy_ghast".
    05 FILLER PIC X(32) VALUE "lightning_bolt".
    05 FILLER PIC X(32) VALUE "wind_charge".
 01 WS-KEY-TABLE REDEFINES WS-KEYS.
    05 WS-KEY-ROW             PIC X(32) OCCURS 22 TIMES.
 PROCEDURE DIVISION.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE 1 TO CS-EXTRA-DIMENSIONS
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     CALL "TEST-STANDARD-TABLES"
     MOVE "Opal" TO WS-NAME
     MOVE 4 TO WS-NAME-LENGTH
     CALL "TEST-JOIN-OP" USING WS-NAME WS-NAME-LENGTH WS-ID-OPAL
     CALL "TEST-DRAIN-CHAT" USING WS-ID-OPAL WS-DISCARD
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 22
         MOVE WS-KEY-ROW(WS-I) TO WS-KEY-TEXT
         COMPUTE WS-KEY-LENGTH = FUNCTION LENGTH(FUNCTION TRIM(WS-KEY-TEXT))
         MOVE SPACES TO WS-LINE
         STRING "summon minecraft:" WS-KEY-TEXT(1:WS-KEY-LENGTH) " ~1 ~ ~1" DELIMITED BY SIZE INTO WS-LINE
         CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT

*>       data get entity: the saved form holds the type id and a Pos.
         MOVE SPACES TO WS-LINE
         STRING "data get entity @e[type=minecraft:" WS-KEY-TEXT(1:WS-KEY-LENGTH) ",limit=1] id" DELIMITED BY SIZE INTO WS-LINE
         CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
         MOVE 0 TO WS-HITS
         INSPECT WS-TEXT TALLYING WS-HITS FOR ALL "commands.data.entity.get("
         MOVE SPACES TO WS-CASE
         STRING "acceptance US13 /data get entity " WS-KEY-TEXT(1:WS-KEY-LENGTH) " answers the id" DELIMITED BY SIZE INTO WS-CASE
         MOVE 1 TO WS-EXPECTED-N
         MOVE WS-HITS TO WS-NUM
         CALL "TEST-EXPECT-NUMBER" USING WS-CASE WS-EXPECTED-N WS-NUM

*>       A non-living entity has no Health (45-8 section 1; the saved form leaves it out); a living one (the bat, the happy ghast, the armor stand) has it.
         MOVE SPACES TO WS-LINE
         STRING "data get entity @e[type=minecraft:" WS-KEY-TEXT(1:WS-KEY-LENGTH) ",limit=1] Health" DELIMITED BY SIZE INTO WS-LINE
         CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
         MOVE 0 TO WS-HITS
         INSPECT WS-TEXT TALLYING WS-HITS FOR ALL "commands.data.entity.get("
         MOVE SPACES TO WS-CASE
         STRING "acceptance US13 /data get entity " WS-KEY-TEXT(1:WS-KEY-LENGTH) " Health only for a living entity" DELIMITED BY SIZE INTO WS-CASE
         MOVE 0 TO WS-EXPECTED-N
         IF WS-KEY-TEXT = "bat" OR WS-KEY-TEXT = "happy_ghast" OR WS-KEY-TEXT = "armor_stand" OR WS-KEY-TEXT = "mannequin"
             MOVE 1 TO WS-EXPECTED-N
         END-IF
         MOVE WS-HITS TO WS-NUM
         CALL "TEST-EXPECT-NUMBER" USING WS-CASE WS-EXPECTED-N WS-NUM

*>       tp moves the entity.
         MOVE SPACES TO WS-LINE
         STRING "tp @e[type=minecraft:" WS-KEY-TEXT(1:WS-KEY-LENGTH) ",limit=1] 100.5 70 100.5" DELIMITED BY SIZE INTO WS-LINE
         CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
         PERFORM FIND-ENTITY
         MOVE SPACES TO WS-CASE
         STRING "acceptance US13 /tp moves the " WS-KEY-TEXT(1:WS-KEY-LENGTH) " to x 100.5" DELIMITED BY SIZE INTO WS-CASE
         MOVE 100.5 TO WS-EXPECTED-N
         MOVE 0 TO WS-NUM
         IF WS-ROW > 0
             IF EN-X(WS-ROW) = 100.5
                 MOVE 100.5 TO WS-NUM
             END-IF
         END-IF
         CALL "TEST-EXPECT-NUMBER" USING WS-CASE WS-EXPECTED-N WS-NUM

*>       kill removes it.
         MOVE SPACES TO WS-LINE
         STRING "kill @e[type=minecraft:" WS-KEY-TEXT(1:WS-KEY-LENGTH) "]" DELIMITED BY SIZE INTO WS-LINE
         CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
         MOVE SPACES TO WS-EXPECTED
         STRING "commands.kill.success.single(" WS-KEY-TEXT(1:WS-KEY-LENGTH) ")" DELIMITED BY SIZE INTO WS-EXPECTED
         MOVE SPACES TO WS-CASE
         STRING "acceptance US13 /kill the " WS-KEY-TEXT(1:WS-KEY-LENGTH) ": Killed" DELIMITED BY SIZE INTO WS-CASE
         CALL "TEST-EXPECT" USING WS-CASE WS-EXPECTED WS-TEXT
*>       Nothing is left to select (a living standard mob dies over its death time, the others are removed at once).
         MOVE SPACES TO WS-LINE
         STRING "kill @e[type=minecraft:" WS-KEY-TEXT(1:WS-KEY-LENGTH) "]" DELIMITED BY SIZE INTO WS-LINE
         CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
         MOVE "argument.entity.notfound.entity()" TO WS-EXPECTED
         MOVE SPACES TO WS-CASE
         STRING "acceptance US13 /kill the " WS-KEY-TEXT(1:WS-KEY-LENGTH) " is gone" DELIMITED BY SIZE INTO WS-CASE
         CALL "TEST-EXPECT" USING WS-CASE WS-EXPECTED WS-TEXT
     END-PERFORM
*>   An entity of another dimension: tp to a destination in the subroutine (Bob, moved there) changes its dimension (ENTITY-CHANGE-DIM) and the entity stands where Bob stands.
     MOVE "Bob" TO WS-NAME
     MOVE 3 TO WS-NAME-LENGTH
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-ID-BOB
     CALL "DIM-SWITCH" USING CN-PLAYER(WS-ID-BOB) WS-SUB-DIM WS-SUB-X WS-SUB-Y WS-SUB-Z
     MOVE "oak_boat" TO WS-KEY-TEXT
     MOVE "summon minecraft:oak_boat ~1 ~ ~1" TO WS-LINE
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     MOVE "tp @e[type=minecraft:oak_boat,limit=1] Bob" TO WS-LINE
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     MOVE "acceptance US13 /tp into the subroutine: Teleported" TO WS-CASE
     MOVE "commands.teleport.success.entity.single(oak_boat,Bob)" TO WS-EXPECTED
     CALL "TEST-EXPECT" USING WS-CASE WS-EXPECTED WS-TEXT
     PERFORM FIND-ENTITY
     MOVE "acceptance US13 /tp an entity into the subroutine dimension" TO WS-CASE
     MOVE 2 TO WS-EXPECTED-N
     MOVE 0 TO WS-NUM
     IF WS-ROW > 0
         MOVE EN-DIM(WS-ROW) TO WS-NUM
     END-IF
     CALL "TEST-EXPECT-NUMBER" USING WS-CASE WS-EXPECTED-N WS-NUM
     MOVE "acceptance US13 /tp the entity stands where Bob stands (x in tenths)" TO WS-CASE
     COMPUTE WS-EXPECTED-N = PL-X(CN-PLAYER(WS-ID-BOB)) * 10
     MOVE 0 TO WS-NUM
     IF WS-ROW > 0
         COMPUTE WS-NUM = EN-X(WS-ROW) * 10
     END-IF
     CALL "TEST-EXPECT-NUMBER" USING WS-CASE WS-EXPECTED-N WS-NUM
     STOP RUN.

 FIND-ENTITY.
     MOVE 0 TO WS-COUNT WS-ROW
     PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > EN-COUNT
         IF EN-USED(WS-J) = 1 AND EN-PLAYER(WS-J) = 0
             COMPUTE WS-KEEP = EN-TYPE(WS-J) + 1
             IF ET-KEY(WS-KEEP) = WS-KEY-TEXT
                 ADD 1 TO WS-COUNT
                 MOVE WS-J TO WS-ROW
             END-IF
         END-IF
     END-PERFORM.
 END PROGRAM TEST-CMD-SUMMON-ENTITY-CMDS.

 COPY CORETEST.
 COPY CMDTEST.
