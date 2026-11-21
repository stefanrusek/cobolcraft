*> Implementation test of CLIENT-SESSION-RESET (client/src/session-reset.cob; lane bugchat, operator report: "I opened the
*> chat and saw chat messages from the previous world I was in"): what the client keeps of one game session (the chat
*> lines and the line being typed, the command tree and suggestions, the recipe book, the inventory, bench and carried
*> stack, experience, effects, the entity replica and player list, the world replica, the book, sign and anvil editors,
*> the merchant and creative screens, the block break progress) is dropped when the game connection is closed (quit to
*> title, the multiplayer Disconnect control, a server's Disconnect) and again when the next one opens; a dimension
*> change (Respawn) keeps the chat. Every field is checked after leaving world A and after joining world B.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-CLIENT-SESSION-RESET.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLSTATE.
 COPY CLCONST.
 COPY TESTLIB.
 COPY CCSHIM.
 01 WS-DIR                 PIC X(64) VALUE "build/client-test-session-reset".
 01 WS-DIR-LENGTH          BINARY-LONG VALUE 31.
 01 WS-FOLDER              PIC X(80) VALUE "First".
 01 WS-FOLDER-LENGTH       BINARY-LONG VALUE 5.
 01 WS-NAME                PIC X(64) VALUE "First".
 01 WS-NAME-LENGTH         BINARY-LONG VALUE 5.
 01 WS-FOLDER-B            PIC X(80) VALUE "Second".
 01 WS-NAME-B              PIC X(64) VALUE "Second".
 01 WS-LENGTH-B            BINARY-LONG VALUE 6.
 01 WS-NAME-LENGTH-B       BINARY-LONG VALUE 6.
 01 WS-MODE                BINARY-LONG VALUE 0.
 01 WS-JOINED              BINARY-LONG.
 01 WS-KEY                 BINARY-LONG.
 01 WS-ACTION              BINARY-LONG.
 01 WS-ARG                 BINARY-LONG VALUE 0.
 01 WS-FOUND               BINARY-LONG.
 01 WS-CONN                BINARY-LONG VALUE CONN-GAME.
 01 WS-PATH                PIC X(256).
 01 WS-STALE               PIC X(512).
 01 WS-STALE-LENGTH        BINARY-LONG.
 01 WS-FIELD               PIC X(40).
 01 WS-VALUE               BINARY-LONG.
 01 WS-MOMENT              PIC X(32).
 01 WS-I                   BINARY-LONG.
 01 WS-STALE-LINES         BINARY-LONG.
 01 WS-USED                BINARY-LONG.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-TEXT                PIC X(512).
 01 WS-LENGTH              BINARY-LONG.
 01 WS-E1                  PIC -(9)9.
 01 WS-E2                  PIC -(9)9.
 01 WS-E3                  PIC -(9)9.
 01 WS-E4                  PIC -(9)9.
 PROCEDURE DIVISION.
     CALL "TEST-SP-START" USING CLIENT-STATE WS-DIR WS-DIR-LENGTH
     CALL "SP-OPEN" USING CLIENT-STATE WS-FOLDER WS-FOLDER-LENGTH WS-NAME WS-NAME-LENGTH WS-MODE
     CALL "TEST-SP-JOIN" USING CLIENT-STATE WS-JOINED
     MOVE "T" TO TL-MODE
     MOVE "session reset world A joined" TO TL-CASE
     MOVE "joined 1" TO TL-EXPECTED
     MOVE SPACES TO TL-OBSERVED
     MOVE WS-JOINED TO WS-E1
     STRING "joined " FUNCTION TRIM(WS-E1) DELIMITED BY SIZE INTO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   A chat line of world A arrives, the Player starts typing, and the rest of the session state is filled with 5s.
     PERFORM FILL-SESSION
     MOVE "stale chat from world A" TO WS-STALE
     MOVE 23 TO WS-STALE-LENGTH
     CALL "CHAT-MESSAGE-ADD" USING CLIENT-STATE WS-STALE WS-STALE-LENGTH
     MOVE "second line" TO WS-STALE
     MOVE 11 TO WS-STALE-LENGTH
     CALL "CHAT-MESSAGE-ADD" USING CLIENT-STATE WS-STALE WS-STALE-LENGTH

*>   A dimension change is not leaving the session: the chat stays.
     MOVE "contract/fixtures/wire/play-s2c-54-respawn-subroutine.hex" TO WS-PATH
     CALL "TEST-FEED" USING CLIENT-STATE WS-CONN WS-PATH
     MOVE "dimension change (Respawn) keeps the chat lines" TO TL-CASE
     MOVE "chat 2 typed 5 command tree 5 recipes 5" TO TL-EXPECTED
     MOVE SPACES TO TL-OBSERVED
     MOVE CH-COUNT TO WS-E1
     MOVE CH-LINE-LENGTH TO WS-E2
     MOVE CM-COUNT TO WS-E3
     MOVE RK-COUNT TO WS-E4
     STRING "chat " FUNCTION TRIM(WS-E1) " typed " FUNCTION TRIM(WS-E2) " command tree "
         FUNCTION TRIM(WS-E3) " recipes " FUNCTION TRIM(WS-E4) DELIMITED BY SIZE INTO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Leaving through the pause menu (Escape, Save and Leave the World).
     PERFORM FILL-SESSION
     CALL "SP-QUIT" USING CLIENT-STATE
     MOVE "left (quit to title)" TO WS-MOMENT
     PERFORM CHECK-SESSION
     MOVE "session reset quit to title: the title screen is shown" TO TL-CASE
     MOVE "screen 1" TO TL-EXPECTED
     MOVE SPACES TO TL-OBSERVED
     MOVE SM-SCREEN TO WS-E1
     STRING "screen " FUNCTION TRIM(WS-E1) DELIMITED BY SIZE INTO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   World B: single-player open.
     CALL "SP-OPEN" USING CLIENT-STATE WS-FOLDER-B WS-LENGTH-B WS-NAME-B WS-NAME-LENGTH-B WS-MODE
     CALL "TEST-SP-JOIN" USING CLIENT-STATE WS-JOINED
     MOVE "session reset world B joined" TO TL-CASE
     MOVE "joined 1" TO TL-EXPECTED
     MOVE SPACES TO TL-OBSERVED
     MOVE WS-JOINED TO WS-E1
     STRING "joined " FUNCTION TRIM(WS-E1) DELIMITED BY SIZE INTO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "joined world B" TO WS-MOMENT
     PERFORM CHECK-SESSION

*>   Opening a game connection resets too, whatever state was left on the client by a path that never closed one.
     CALL "SP-QUIT" USING CLIENT-STATE
     PERFORM FILL-SESSION
     CALL "SP-OPEN" USING CLIENT-STATE WS-FOLDER WS-FOLDER-LENGTH WS-NAME WS-NAME-LENGTH WS-MODE
     MOVE "opened world A again" TO WS-MOMENT
     PERFORM CHECK-SESSION
     CALL "TEST-SP-JOIN" USING CLIENT-STATE WS-JOINED
     MOVE "joined world A again" TO WS-MOMENT
     PERFORM CHECK-SESSION

*>   The multiplayer Disconnect control (pause menu): the connection closes and the server list shows.
     PERFORM FILL-SESSION
     MOVE ACT-DISCONNECT TO WS-ACTION
     CALL "SCREEN-ACTION" USING CLIENT-STATE WS-ACTION WS-ARG
     MOVE "left (Disconnect control)" TO WS-MOMENT
     PERFORM CHECK-SESSION

*>   A Disconnect packet of the server: the connection closes and the server list shows the reason.
     CALL "SP-STOP" USING CLIENT-STATE
     CALL "SP-OPEN" USING CLIENT-STATE WS-FOLDER-B WS-LENGTH-B WS-NAME-B WS-NAME-LENGTH-B WS-MODE
     CALL "TEST-SP-JOIN" USING CLIENT-STATE WS-JOINED
     PERFORM FILL-SESSION
     MOVE "kicked" TO WS-TEXT
     MOVE 6 TO WS-LENGTH
     CALL "CLIENT-DISCONNECT" USING CLIENT-STATE WS-CONN WS-TEXT WS-LENGTH
     MOVE "left (server Disconnect)" TO WS-MOMENT
     PERFORM CHECK-SESSION
     CALL "SP-STOP" USING CLIENT-STATE

*>   Leaving through the pause menu (Escape, Save and Leave the World).
     CALL "SP-OPEN" USING CLIENT-STATE WS-FOLDER-B WS-LENGTH-B WS-NAME-B WS-NAME-LENGTH-B WS-MODE
     CALL "TEST-SP-JOIN" USING CLIENT-STATE WS-JOINED
     PERFORM FILL-SESSION
     MOVE CC-KEY-ESCAPE TO WS-KEY
     CALL "TEST-KEY" USING CLIENT-STATE WS-KEY
     MOVE ACT-QUIT-WORLD TO WS-ACTION
     CALL "TEST-CLICK" USING CLIENT-STATE WS-ACTION WS-ARG WS-FOUND
     MOVE "left (pause menu quit)" TO WS-MOMENT
     PERFORM CHECK-SESSION
     GOBACK.

*>   Every field the session keeps, set to the sentinel 5 (the permission level 3, a rain level 0.5).
 FILL-SESSION.
     MOVE 5 TO CH-LINE-LENGTH CH-SCROLL CM-COUNT CM-LINK-COUNT CS-COUNT CS-ASKED-LENGTH CS-ANSWERS
     MOVE "typed" TO CH-LINE(1:5)
     MOVE 5 TO RK-COUNT RK-SEARCH-LENGTH
     MOVE 5 TO PL-SLOT-COUNT(20) PL-OFFHAND-COUNT PL-CARRIED-COUNT IX-COUNT(2) BX-COUNT(2) BM-ID MX-COUNT
     MOVE 5 TO PL-XP-LEVEL PL-XP-TOTAL EF-COUNT
     MOVE 3 TO PL-PERM
     MOVE 1 TO EN-COUNT
     MOVE 1 TO EN-USED(1)
     MOVE 5 TO EN-ID(1) PI-COUNT
     MOVE 5 TO BK-LEN BE-PAGE-COUNT SG-LEN(1) AN-NAME-LENGTH MC-COUNT SC-COUNT BDS-COUNT
         EB-CMD-LEN EF-LEN(1) CR-QUERY-LEN MT-ENTITY
     MOVE 1 TO CT-BREAKING BE-ACTIVE
     MOVE 0.5 TO PL-RAIN DX-PORTAL
     MOVE 5 TO DX-SOUND DX-FLASH-SOUND
     EXIT PARAGRAPH.

*>   Each field is not the sentinel any more (after leaving the world, and after joining the next).
 CHECK-SESSION.
     MOVE 0 TO WS-STALE-LINES
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > CH-COUNT
         IF CH-TEXT(WS-I)(1:11) = "stale chat " OR CH-TEXT(WS-I)(1:11) = "second line"
             ADD 1 TO WS-STALE-LINES
         END-IF
     END-PERFORM
     MOVE "chat lines of the old world" TO WS-FIELD
     MOVE WS-STALE-LINES TO WS-VALUE
     PERFORM EXPECT-ZERO
     MOVE "chat line count" TO WS-FIELD
     MOVE 0 TO WS-VALUE
     IF CH-COUNT = 2 AND WS-MOMENT(1:4) = "left"
         MOVE 2 TO WS-VALUE
     END-IF
     PERFORM EXPECT-ZERO
     MOVE "typed chat line length" TO WS-FIELD
     MOVE CH-LINE-LENGTH TO WS-VALUE
     PERFORM EXPECT-NOT-SENTINEL
     MOVE "chat scroll" TO WS-FIELD
     MOVE CH-SCROLL TO WS-VALUE
     PERFORM EXPECT-NOT-SENTINEL
     MOVE "command tree nodes" TO WS-FIELD
     MOVE CM-COUNT TO WS-VALUE
     PERFORM EXPECT-NOT-SENTINEL
     MOVE "command tree links" TO WS-FIELD
     MOVE CM-LINK-COUNT TO WS-VALUE
     PERFORM EXPECT-NOT-SENTINEL
     MOVE "suggestion names" TO WS-FIELD
     MOVE CS-COUNT TO WS-VALUE
     PERFORM EXPECT-NOT-SENTINEL
     MOVE "suggestion asked length" TO WS-FIELD
     MOVE CS-ASKED-LENGTH TO WS-VALUE
     PERFORM EXPECT-NOT-SENTINEL
     MOVE "suggestion answers" TO WS-FIELD
     MOVE CS-ANSWERS TO WS-VALUE
     PERFORM EXPECT-NOT-SENTINEL
     MOVE "recipe book entries" TO WS-FIELD
     MOVE RK-COUNT TO WS-VALUE
     PERFORM EXPECT-NOT-SENTINEL
     MOVE "recipe book search length" TO WS-FIELD
     MOVE RK-SEARCH-LENGTH TO WS-VALUE
     PERFORM EXPECT-NOT-SENTINEL
     MOVE "inventory slot 20" TO WS-FIELD
     MOVE PL-SLOT-COUNT(20) TO WS-VALUE
     PERFORM EXPECT-NOT-SENTINEL
     MOVE "off-hand stack" TO WS-FIELD
     MOVE PL-OFFHAND-COUNT TO WS-VALUE
     PERFORM EXPECT-NOT-SENTINEL
     MOVE "carried stack" TO WS-FIELD
     MOVE PL-CARRIED-COUNT TO WS-VALUE
     PERFORM EXPECT-NOT-SENTINEL
     MOVE "armour slot of the menu" TO WS-FIELD
     MOVE IX-COUNT(2) TO WS-VALUE
     PERFORM EXPECT-NOT-SENTINEL
     MOVE "bench slot of the menu" TO WS-FIELD
     MOVE BX-COUNT(2) TO WS-VALUE
     PERFORM EXPECT-NOT-SENTINEL
     MOVE "open bench container id" TO WS-FIELD
     MOVE BM-ID TO WS-VALUE
     PERFORM EXPECT-NOT-SENTINEL
     MOVE "max damage entries" TO WS-FIELD
     MOVE MX-COUNT TO WS-VALUE
     PERFORM EXPECT-NOT-SENTINEL
     MOVE "experience level" TO WS-FIELD
     MOVE PL-XP-LEVEL TO WS-VALUE
     PERFORM EXPECT-NOT-SENTINEL
     MOVE "experience total" TO WS-FIELD
     MOVE PL-XP-TOTAL TO WS-VALUE
     PERFORM EXPECT-NOT-SENTINEL
     MOVE "effects" TO WS-FIELD
     MOVE EF-COUNT TO WS-VALUE
     PERFORM EXPECT-NOT-SENTINEL
     MOVE "permission level" TO WS-FIELD
     MOVE PL-PERM TO WS-VALUE
     PERFORM EXPECT-NOT-3
     MOVE "entity replica rows" TO WS-FIELD
     MOVE EN-COUNT TO WS-VALUE
     PERFORM EXPECT-NOT-1
     MOVE "player list rows" TO WS-FIELD
     MOVE PI-COUNT TO WS-VALUE
     PERFORM EXPECT-NOT-SENTINEL
     MOVE 0 TO WS-USED
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WR-COUNT
         ADD WR-USED(WS-I) TO WS-USED
     END-PERFORM
     IF WS-MOMENT(1:4) = "left"
         MOVE "chunks of the world replica" TO WS-FIELD
         MOVE WS-USED TO WS-VALUE
         PERFORM EXPECT-ZERO
     END-IF
     MOVE "book page editor length" TO WS-FIELD
     MOVE BK-LEN TO WS-VALUE
     PERFORM EXPECT-NOT-SENTINEL
     MOVE "book pages" TO WS-FIELD
     MOVE BE-PAGE-COUNT TO WS-VALUE
     PERFORM EXPECT-NOT-SENTINEL
     MOVE "book editor active" TO WS-FIELD
     MOVE BE-ACTIVE TO WS-VALUE
     PERFORM EXPECT-NOT-1
     MOVE "sign line 1 length" TO WS-FIELD
     MOVE SG-LEN(1) TO WS-VALUE
     PERFORM EXPECT-NOT-SENTINEL
     MOVE "anvil name length" TO WS-FIELD
     MOVE AN-NAME-LENGTH TO WS-VALUE
     PERFORM EXPECT-NOT-SENTINEL
     MOVE "merchant offers" TO WS-FIELD
     MOVE MC-COUNT TO WS-VALUE
     PERFORM EXPECT-NOT-SENTINEL
     MOVE "stonecutter entries" TO WS-FIELD
     MOVE SC-COUNT TO WS-VALUE
     PERFORM EXPECT-NOT-SENTINEL
     MOVE "other players' block breaks" TO WS-FIELD
     MOVE BDS-COUNT TO WS-VALUE
     PERFORM EXPECT-NOT-SENTINEL
     MOVE "own block break in progress" TO WS-FIELD
     MOVE CT-BREAKING TO WS-VALUE
     PERFORM EXPECT-NOT-1
     MOVE "command block command length" TO WS-FIELD
     MOVE EB-CMD-LEN TO WS-VALUE
     PERFORM EXPECT-NOT-SENTINEL
     MOVE "form box 1 length" TO WS-FIELD
     MOVE EF-LEN(1) TO WS-VALUE
     PERFORM EXPECT-NOT-SENTINEL
     MOVE "creative search length" TO WS-FIELD
     MOVE CR-QUERY-LEN TO WS-VALUE
     PERFORM EXPECT-NOT-SENTINEL
     MOVE "mount inventory entity" TO WS-FIELD
     MOVE MT-ENTITY TO WS-VALUE
     PERFORM EXPECT-NOT-SENTINEL
     MOVE "portal sound waiting" TO WS-FIELD
     MOVE DX-SOUND TO WS-VALUE
     PERFORM EXPECT-NOT-SENTINEL
     MOVE "end flash sound waiting" TO WS-FIELD
     MOVE DX-FLASH-SOUND TO WS-VALUE
     PERFORM EXPECT-NOT-SENTINEL
     MOVE "portal overlay" TO WS-FIELD
     MOVE 0 TO WS-VALUE
     IF DX-PORTAL > 0.4 AND DX-PORTAL < 0.6
         MOVE 1 TO WS-VALUE
     END-IF
     PERFORM EXPECT-ZERO
     MOVE "rain level" TO WS-FIELD
     MOVE 0 TO WS-VALUE
     IF PL-RAIN > 0.4 AND PL-RAIN < 0.6
         MOVE 1 TO WS-VALUE
     END-IF
     PERFORM EXPECT-ZERO
     EXIT PARAGRAPH.

 EXPECT-NOT-SENTINEL.
     MOVE 0 TO TL-OBSERVED-N
     IF WS-VALUE = 5
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     PERFORM ASSERT-FIELD
     EXIT PARAGRAPH.

 EXPECT-NOT-3.
     MOVE 0 TO TL-OBSERVED-N
     IF WS-VALUE = 3
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     PERFORM ASSERT-FIELD
     EXIT PARAGRAPH.

 EXPECT-NOT-1.
     MOVE 0 TO TL-OBSERVED-N
     IF WS-VALUE = 1
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     PERFORM ASSERT-FIELD
     EXIT PARAGRAPH.

 EXPECT-ZERO.
     MOVE WS-VALUE TO TL-OBSERVED-N
     PERFORM ASSERT-FIELD
     EXIT PARAGRAPH.

 ASSERT-FIELD.
     MOVE SPACES TO TL-CASE
     STRING "session reset " FUNCTION TRIM(WS-MOMENT) ": " FUNCTION TRIM(WS-FIELD) " is not carried over"
         DELIMITED BY SIZE INTO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 0 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "T" TO TL-MODE
     EXIT PARAGRAPH.
 END PROGRAM TEST-CLIENT-SESSION-RESET.

 COPY CLTEST.
