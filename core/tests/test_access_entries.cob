*> Implementation test of the entries of the access lists (docs/protocol/07-nbt-and-anvil.md §9.2 access.dat; docs/protocol/15-commands-framework.md
*> §2.2; core/copy/CORESTATE.cpy AC-ENTRY, core/src/access.cob, core/src/persistence.cob): an operator entry has the permission level
*> (Level, 1 to 4; a new operator is level 4), a ban entry the creation time, the source, the expiry text (forever by default) and the
*> reason (absent when none); the file keeps them and reading it back restores them; an operator entry without a Level (a file of
*> an earlier run) reads as level 4; BR-SOURCE-LEVEL gives an operator the level of the entry.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-ACCESS-ENTRIES.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY PROTO.
 01 WS-FILE                PIC X(256) VALUE "build/core-test-world/access.dat".
 01 WS-ROOT                BINARY-LONG.
 01 WS-LIST                BINARY-LONG.
 01 WS-OUTCOME             BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-LEVEL               BINARY-LONG.
 01 WS-NAME                PIC X(16).
 01 WS-LENGTH              BINARY-LONG.
 01 WS-UUID                PIC X(16).
 01 WS-PATH                PIC X(128).
 01 WS-TEXT                PIC X(8192).
 01 WS-EDIT                PIC -(9)9.
 01 WS-OBSERVED            PIC X(1024).
 01 WS-ID                  BINARY-LONG.
 01 WS-PLAYER              BINARY-LONG.
 PROCEDURE DIVISION.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     MOVE "Opal" TO WS-NAME
     MOVE 4 TO WS-LENGTH
     CALL "LOGIN-OFFLINE-UUID" USING WS-NAME WS-LENGTH WS-UUID
     MOVE ACCESS-OPERATORS TO WS-LIST
     CALL "ACCESS-ADD" USING WS-LIST WS-NAME WS-LENGTH WS-UUID WS-OUTCOME
     MOVE "test access entries a new operator is level 4" TO TL-CASE
     MOVE AC-LEVEL(ACCESS-OPERATORS, 1) TO WS-EDIT
     MOVE FUNCTION TRIM(WS-EDIT) TO TL-OBSERVED
     MOVE "4" TO TL-EXPECTED
     PERFORM CHECK
     MOVE "Bob" TO WS-NAME
     MOVE 3 TO WS-LENGTH
     CALL "LOGIN-OFFLINE-UUID" USING WS-NAME WS-LENGTH WS-UUID
     MOVE ACCESS-BANS TO WS-LIST
     CALL "ACCESS-ADD" USING WS-LIST WS-NAME WS-LENGTH WS-UUID WS-OUTCOME
     MOVE "test access entries a new ban expires never (forever) and has no reason" TO TL-CASE
     MOVE SPACES TO TL-OBSERVED
     MOVE AC-REASON-LENGTH(ACCESS-BANS, 1) TO WS-EDIT
     STRING AC-EXPIRES(ACCESS-BANS, 1)(1:AC-EXPIRES-LENGTH(ACCESS-BANS, 1)) "/" FUNCTION TRIM(WS-EDIT)
         DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "forever/0" TO TL-EXPECTED
     PERFORM CHECK
     MOVE 2 TO AC-LEVEL(ACCESS-OPERATORS, 1)
     MOVE "2026-11-10 12:00:00 +0000" TO AC-CREATED(ACCESS-BANS, 1)
     MOVE 25 TO AC-CREATED-LENGTH(ACCESS-BANS, 1)
     MOVE "Opal" TO AC-SOURCE(ACCESS-BANS, 1)
     MOVE 4 TO AC-SOURCE-LENGTH(ACCESS-BANS, 1)
     MOVE "griefing" TO AC-REASON(ACCESS-BANS, 1)
     MOVE 8 TO AC-REASON-LENGTH(ACCESS-BANS, 1)
     CALL "ACCESS-DAT-WRITE"
     CALL "TEST-NBT-FILE" USING WS-FILE PB-BUFFER WS-ROOT
     MOVE "test access entries the file holds the operator Level and the ban Created, Source, Expires and Reason" TO TL-CASE
     MOVE SPACES TO TL-OBSERVED
     MOVE "Operators" TO WS-PATH
     CALL "TEST-NBT-GET" USING PB-BUFFER WS-ROOT WS-PATH WS-TEXT
     MOVE WS-TEXT(1:200) TO TL-OBSERVED
     MOVE "[{Name:Opal,UUID:I[-1260147075,-1547422121,-1680628341,279471202],Level:2}]" TO TL-EXPECTED
     PERFORM CHECK
     MOVE SPACES TO TL-OBSERVED
     MOVE "Bans" TO WS-PATH
     CALL "TEST-NBT-GET" USING PB-BUFFER WS-ROOT WS-PATH WS-TEXT
     MOVE WS-TEXT(1:300) TO TL-OBSERVED
     MOVE "test access entries the ban entry" TO TL-CASE
     MOVE SPACES TO TL-EXPECTED
     STRING "[{Name:Bob,UUID:I[-89793373,-1009502901,-1373905431,-442414277],Created:2026-11-10 12:00:00 +0000,"
         "Source:Opal,Expires:forever,Reason:griefing}]" DELIMITED BY SIZE INTO TL-EXPECTED
     PERFORM CHECK
     INITIALIZE CORE-ACCESS
     CALL "ACCESS-DAT-READ"
     MOVE "test access entries read back restores the level, the creation time, the source, the expiry and the reason" TO TL-CASE
     MOVE SPACES TO TL-OBSERVED
     MOVE AC-LEVEL(ACCESS-OPERATORS, 1) TO WS-EDIT
     STRING FUNCTION TRIM(WS-EDIT) "/" AC-CREATED(ACCESS-BANS, 1)(1:AC-CREATED-LENGTH(ACCESS-BANS, 1)) "/"
         AC-SOURCE(ACCESS-BANS, 1)(1:AC-SOURCE-LENGTH(ACCESS-BANS, 1)) "/"
         AC-EXPIRES(ACCESS-BANS, 1)(1:AC-EXPIRES-LENGTH(ACCESS-BANS, 1)) "/"
         AC-REASON(ACCESS-BANS, 1)(1:AC-REASON-LENGTH(ACCESS-BANS, 1)) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "2/2026-11-10 12:00:00 +0000/Opal/forever/griefing" TO TL-EXPECTED
     PERFORM CHECK
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     MOVE "Opal" TO WS-NAME
     MOVE 4 TO WS-LENGTH
     CALL "TEST-JOIN-OP" USING WS-NAME WS-LENGTH WS-ID
     MOVE CN-PLAYER(WS-ID) TO WS-PLAYER
     MOVE "test access entries an operator holds level 4 by default (BR-SOURCE-LEVEL)" TO TL-CASE
     CALL "BR-SOURCE-LEVEL" USING WS-PLAYER WS-LEVEL
     MOVE WS-LEVEL TO WS-EDIT
     MOVE FUNCTION TRIM(WS-EDIT) TO TL-OBSERVED
     MOVE "4" TO TL-EXPECTED
     PERFORM CHECK
     MOVE 2 TO AC-LEVEL(ACCESS-OPERATORS, 1)
     MOVE "test access entries an operator holds the level of the entry" TO TL-CASE
     CALL "BR-SOURCE-LEVEL" USING WS-PLAYER WS-LEVEL
     MOVE WS-LEVEL TO WS-EDIT
     MOVE FUNCTION TRIM(WS-EDIT) TO TL-OBSERVED
     MOVE "2" TO TL-EXPECTED
     PERFORM CHECK
     MOVE 9 TO AC-LEVEL(ACCESS-OPERATORS, 1)
     MOVE "test access entries a stored level above 4 is clamped to 4" TO TL-CASE
     CALL "BR-SOURCE-LEVEL" USING WS-PLAYER WS-LEVEL
     MOVE WS-LEVEL TO WS-EDIT
     MOVE FUNCTION TRIM(WS-EDIT) TO TL-OBSERVED
     MOVE "4" TO TL-EXPECTED
     PERFORM CHECK
     MOVE 0 TO PL-OPERATOR(WS-PLAYER)
     MOVE "test access entries a player without operator status holds level 0" TO TL-CASE
     CALL "BR-SOURCE-LEVEL" USING WS-PLAYER WS-LEVEL
     MOVE WS-LEVEL TO WS-EDIT
     MOVE FUNCTION TRIM(WS-EDIT) TO TL-OBSERVED
     MOVE "0" TO TL-EXPECTED
     PERFORM CHECK
     GOBACK.

 CHECK.
     MOVE "T" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

 END PROGRAM TEST-ACCESS-ENTRIES.

 COPY CORETEST.
 COPY CMDTEST.
