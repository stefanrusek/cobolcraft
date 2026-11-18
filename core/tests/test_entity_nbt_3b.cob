*> Entity NBT, part 3 rest (docs/protocol/45-entity-nbt-3 sections 3 and 6; lane 002-lane-p49m, T31020): in a world of the 26.3 layout the player file keeps LastDeathLocation,
*> previousPlayerGameType, warden_spawn_tracker, entered_nether_pos, last_explosion_impact_pos, raid_omen_position, respawn, ender_pearls, the shoulder entities and RootVehicle
*> from a file it loaded; a player that dies gets LastDeathLocation, a game mode change gets previousPlayerGameType.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-ENTITY-NBT-3B.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY DIMENSIONS.
 COPY RULES.
 COPY KKEEP.
 COPY PROTO.
 01 WS-CAPACITY            BINARY-LONG VALUE 65536.
 01 WS-NAME                PIC X(16) VALUE "Alice".
 01 WS-NAME-LENGTH         BINARY-LONG VALUE 5.
 01 WS-ALICE               BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-KNOWN               BINARY-LONG.
 01 WS-ROOT                BINARY-LONG.
 01 WS-PATH                PIC X(128).
 01 WS-TEXT                PIC X(8192).
 01 WS-SNBT                PIC X(1024).
 01 WS-UUID                PIC X(16).
 01 WS-UUID-TEXT           PIC X(36).
 01 WS-SUFFIX              PIC X(128).
 01 WS-FILE-PATH           PIC X(1100).
 01 WS-FILE-LENGTH         BINARY-LONG.
 01 WS-FILE                PIC X(256).
 01 WS-HEX                 PIC X(1024).
 01 WS-AREA                PIC X(512).
 01 WS-SIXTEEN             BINARY-LONG VALUE 16.
 01 WS-LINE                PIC X(128).
 01 WS-CAUSE               BINARY-LONG.
 01 WS-ATTACKER            BINARY-LONG VALUE 0.
 PROCEDURE DIVISION.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE 0 TO CS-DEFAULT-MODE CS-HOSTILE-MOBS
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     MOVE 1 TO CW-LAYOUT
     CALL "CBL_CREATE_DIR" USING "build/core-test-world/players/data"
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-ALICE
     MOVE CN-PLAYER(WS-ALICE) TO WS-ROW
     MOVE PL-UUID(WS-ROW) TO WS-UUID
*>   A player file of the game with the keys, loaded and saved again.
     MOVE SPACES TO WS-SNBT
     STRING '{previousPlayerGameType:1,LastDeathLocation:{dimension:"minecraft:overworld",pos:[I;5,6,7]},'
         'warden_spawn_tracker:{ticks_since_last_warning:3,warning_level:2,cooldown_ticks:40},'
         'entered_nether_pos:[1.0d,2.0d,3.0d],last_explosion_impact_pos:[4.0d,5.0d,6.0d],raid_omen_position:[I;7,8,9],'
         'respawn:{dimension:"minecraft:overworld",pos:[I;1,2,3],yaw:90.0f,pitch:0.0f,forced:1b},'
         'ender_pearls:[{id:"minecraft:ender_pearl",ender_pearl_dimension:"minecraft:overworld"}],'
         'ShoulderEntityLeft:{id:"minecraft:parrot"},ShoulderEntityRight:{},'
         'RootVehicle:{Attach:[I;1,2,3,4],Entity:{id:"minecraft:pig"}}}' DELIMITED BY SIZE INTO WS-SNBT
     CALL "PLAYER-SNBT" USING WS-SNBT PB-BUFFER
     CALL "PERSIST-UUID-TEXT" USING WS-UUID WS-UUID-TEXT
     MOVE SPACES TO WS-SUFFIX
     STRING "/players/data/" WS-UUID-TEXT ".dat" DELIMITED BY SIZE INTO WS-SUFFIX
     CALL "PERSIST-PATH" USING WS-SUFFIX WS-FILE-PATH WS-FILE-LENGTH
     CALL "PERSIST-WRITE-FILE" USING WS-FILE-PATH WS-FILE-LENGTH PB-BUFFER
     CALL "PLAYER-DAT-READ" USING WS-UUID WS-KNOWN
     MOVE 1 TO KN-DIRTY(WS-KNOWN)
     MOVE 0 TO PB-POS
     CALL "CORE-SAVE"
     PERFORM PLAYER-FILE
     CALL "TEST-NBT-FILE" USING WS-FILE PB-BUFFER WS-ROOT
     MOVE "T" TO TL-MODE
     MOVE "LastDeathLocation" TO WS-PATH
     MOVE "acceptance US15 45-3§6.2 LastDeathLocation is kept" TO TL-CASE
     MOVE "{dimension:minecraft:overworld,pos:I[5,6,7]}" TO TL-EXPECTED
     PERFORM CHECK
     MOVE "warden_spawn_tracker" TO WS-PATH
     MOVE "acceptance US15 45-3§6.3 warden_spawn_tracker keeps its three counters" TO TL-CASE
     MOVE "{ticks_since_last_warning:3,warning_level:2,cooldown_ticks:40}" TO TL-EXPECTED
     PERFORM CHECK
     MOVE "previousPlayerGameType" TO WS-PATH
     MOVE "acceptance US15 45-3§3.4 previousPlayerGameType is kept" TO TL-CASE
     MOVE "1" TO TL-EXPECTED
     PERFORM CHECK
     MOVE "entered_nether_pos" TO WS-PATH
     MOVE "acceptance US15 45-3§3.1 entered_nether_pos is kept" TO TL-CASE
     MOVE "[1.000,2.000,3.000]" TO TL-EXPECTED
     PERFORM CHECK
     MOVE "last_explosion_impact_pos" TO WS-PATH
     MOVE "acceptance US15 45-3§3.1 last_explosion_impact_pos is kept" TO TL-CASE
     MOVE "[4.000,5.000,6.000]" TO TL-EXPECTED
     PERFORM CHECK
     MOVE "raid_omen_position" TO WS-PATH
     MOVE "acceptance US15 45-3§3.1 raid_omen_position is kept" TO TL-CASE
     MOVE "I[7,8,9]" TO TL-EXPECTED
     PERFORM CHECK
     MOVE "respawn" TO WS-PATH
     MOVE "acceptance US15 45-3§6.1 respawn is kept" TO TL-CASE
     MOVE "{dimension:minecraft:overworld,pos:I[1,2,3],yaw:90.000,pitch:0.000,forced:1}" TO TL-EXPECTED
     PERFORM CHECK
     MOVE "ender_pearls" TO WS-PATH
     MOVE "acceptance US15 45-3§3.7 ender_pearls is kept" TO TL-CASE
     MOVE "[{id:minecraft:ender_pearl,ender_pearl_dimension:minecraft:overworld}]" TO TL-EXPECTED
     PERFORM CHECK
     MOVE "ShoulderEntityLeft" TO WS-PATH
     MOVE "acceptance US15 45-3§3.6 a shoulder entity is kept" TO TL-CASE
     MOVE "{id:minecraft:parrot}" TO TL-EXPECTED
     PERFORM CHECK
     MOVE "ShoulderEntityRight" TO WS-PATH
     MOVE "acceptance US15 45-3§3.6 an empty shoulder compound is not written" TO TL-CASE
     MOVE "absent" TO TL-EXPECTED
     PERFORM CHECK
     MOVE "RootVehicle" TO WS-PATH
     MOVE "acceptance US15 45-3§3.3 RootVehicle is kept" TO TL-CASE
     MOVE "{Attach:I[1,2,3,4],Entity:{id:minecraft:pig}}" TO TL-EXPECTED
     PERFORM CHECK
*>   A player that dies: LastDeathLocation is the block of the death; a /gamemode leaves the mode before it as previousPlayerGameType.
     MOVE 10.5 TO PL-X(WS-ROW)
     MOVE 64 TO PL-Y(WS-ROW)
     MOVE -3.5 TO PL-Z(WS-ROW)
     MOVE CAUSE-COMMAND TO WS-CAUSE
     CALL "HEALTH-DIE" USING WS-ROW WS-CAUSE WS-ATTACKER
     CALL "CORE-SAVE"
     CALL "TEST-NBT-FILE" USING WS-FILE PB-BUFFER WS-ROOT
     MOVE "LastDeathLocation" TO WS-PATH
     MOVE "acceptance US15 45-3§6.2 a player that died at (10.5, 64, -3.5) has LastDeathLocation (10, 64, -4)" TO TL-CASE
     MOVE "{dimension:cobolcraft:main,pos:I[10,64,-4]}" TO TL-EXPECTED
     PERFORM CHECK
     MOVE "previousPlayerGameType" TO WS-PATH
     MOVE "acceptance US15 45-3§3.4 the mode before /gamemode creative (survival, 0) is the previousPlayerGameType" TO TL-CASE
     MOVE "0" TO TL-EXPECTED
     MOVE 1 TO KK-PREV-ON(WS-KNOWN)
     PERFORM MODE-CHANGE
     PERFORM CHECK
     STOP RUN.
*> Alice's previous mode set to something else, then /gamemode creative from the console, saved and the file read.
 MODE-CHANGE.
     MOVE 3 TO KK-PREV-MODE(WS-KNOWN)
     MOVE SPACES TO WS-LINE
     MOVE Z"gamemode creative Alice" TO WS-LINE
     MOVE 0 TO PL-MODE(WS-ROW)
     CALL "CORE-CONSOLE" USING WS-LINE
     CALL "CORE-SAVE"
     CALL "TEST-NBT-FILE" USING WS-FILE PB-BUFFER WS-ROOT.
 PLAYER-FILE.
     MOVE PL-UUID(WS-ROW) TO WS-AREA
     CALL "TEST-HEX-OF" USING WS-AREA WS-SIXTEEN WS-HEX
     MOVE SPACES TO WS-FILE
     STRING "build/core-test-world/players/data/" WS-HEX(1:8) "-" WS-HEX(9:4) "-" WS-HEX(13:4) "-"
         WS-HEX(17:4) "-" WS-HEX(21:12) ".dat" DELIMITED BY SIZE INTO WS-FILE.
 CHECK.
     CALL "TEST-NBT-GET" USING PB-BUFFER WS-ROOT WS-PATH WS-TEXT
     MOVE FUNCTION TRIM(WS-TEXT) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-ENTITY-NBT-3B.
 COPY ENTSNBT.
 COPY CORETEST.
