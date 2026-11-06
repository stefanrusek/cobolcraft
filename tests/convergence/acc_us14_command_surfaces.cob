*> Convergence acceptance test of SC-009 and US14-1 (spec.md SC-009, US14-1 to US14-3, US15-1,
*> US16-3, US17-2; standin-content §16.2 command table, §16.1 target rule): every command of the
*> command set produces its defined effect from each surface it is permitted on, and is refused for
*> a sender who is not permitted. Surfaces, in order (one core per process, so one after another):
*>   1. the server program's console (in process, loopback server);
*>   2. chat of a Player with operator status on that server (Alice, promoted at the console);
*>   3. chat of a Player without it (Bobby): the three everyone commands work, every other command
*>      is refused with the not-permitted message;
*>   then Bobby's shutdown is refused and Alice's stops the server;
*>   4. the single-player host (Alice's own world, not opened to others: commands acting on another
*>      player find nobody, §16.1), ending with shutdown (the host quitting the world);
*>   5. the host of the same world opened to others (guest operator commands allowed);
*>   6. a guest of that world (Bobby, over loopback TCP), ending with shutdown (the host quits);
*>   and last the console's shutdown, of the server program started again.
*> Carl is the Player the eject command disconnects (he joins again after each eject).
*> The table below has one representative valid invocation per command (both forms of mode, so the
*> target ends in survival for vitality and ration); "@" stands for the target player (the sender
*> for chat surfaces, Bobby for the console), "%" for the player to eject, "&" for the number of
*> howto entries. Each row checks the confirmation the sender sees (the console's printed reply);
*> some rows also check an effect in the world (eject, mode, clock, announce).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-US14-COMMAND-SURFACES.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CONVH.
 COPY CLCONST.
 COPY CCSHIM.
 COPY COREAPI.
 COPY TESTLIB.
 01 WS-DIR                 PIC X(64) VALUE "build/conv-us14-command-surfaces".
 01 WS-DIR-LENGTH          BINARY-LONG VALUE 32.
 01 WS-CONF                PIC X(1024)
     VALUE "view-distance=2|hostile-mobs=false|default-game-mode=survival".
 01 WS-NAME                PIC X(16).
 01 WS-NAME-LENGTH         BINARY-LONG VALUE 5.
 01 WS-ALICE               BINARY-LONG.
 01 WS-BOBBY               BINARY-LONG.
 01 WS-CARL                BINARY-LONG.
 01 WS-CONSOLE             BINARY-LONG VALUE 0.
 01 WS-JOINED              BINARY-LONG.
 01 WS-LINE                PIC X(256).
 01 WS-SURFACE.
    05 SF-LABEL            PIC X(40).
    05 SF-SENDER           BINARY-LONG.
    05 SF-TARGET           BINARY-LONG.
    05 SF-VICTIM           BINARY-LONG.
    05 SF-PERMITTED        BINARY-LONG.
    05 SF-PORT             BINARY-LONG.
    05 SF-SHUTDOWN         BINARY-LONG.
 01 WS-FOLDER              PIC X(80) VALUE "Hosted".
 01 WS-FOLDER-LENGTH       BINARY-LONG VALUE 6.
 01 WS-MODE                BINARY-LONG VALUE 0.
 01 WS-I                   BINARY-LONG.
 01 WS-ACTION              BINARY-LONG.
 01 WS-ARG                 BINARY-LONG VALUE 0.
 01 WS-FOUND               BINARY-LONG.
 01 WS-KEY                 BINARY-LONG.
 01 WS-SCREEN              BINARY-LONG.
 01 WS-REACHED             BINARY-LONG.
 01 WS-TEXT                PIC X(64).
 01 WS-LENGTH              BINARY-LONG.
 01 WS-SUGGESTED           PIC X(1024).
 01 WS-E1                  PIC -(9)9.
 01 WS-E2                  PIC -(9)9.
 LINKAGE SECTION.
 COPY CLSTATE.
 PROCEDURE DIVISION.
     CALL "CV-INIT" USING CONVH WS-DIR WS-DIR-LENGTH
     MOVE "Alice" TO WS-NAME
     CALL "CV-CLIENT-ADD" USING CONVH WS-NAME WS-NAME-LENGTH WS-ALICE
     MOVE "Bobby" TO WS-NAME
     CALL "CV-CLIENT-ADD" USING CONVH WS-NAME WS-NAME-LENGTH WS-BOBBY
     MOVE "Carl" TO WS-NAME
     MOVE 4 TO WS-NAME-LENGTH
     CALL "CV-CLIENT-ADD" USING CONVH WS-NAME WS-NAME-LENGTH WS-CARL

*>   The server: Alice is made an operator at the console before she joins.
     CALL "CV-SERVER-START" USING CONVH WS-CONF
     MOVE "promote Alice" TO WS-LINE
     CALL "CV-SERVER-CONSOLE" USING CONVH WS-LINE
     CALL "CV-STEP" USING CONVH
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 3
         CALL "CV-JOIN" USING CONVH WS-I CV-PORT
         CALL "CV-UNTIL-PLAY" USING CONVH WS-I WS-JOINED
     END-PERFORM

*>   US14-1: the suggestions shown under the chat line.
     MOVE "/pr" TO WS-TEXT
     MOVE 3 TO WS-LENGTH
     CALL "CS-SUGGEST" USING CONVH WS-ALICE WS-TEXT WS-LENGTH WS-SUGGESTED
     MOVE "acceptance US14-1 given an operator with the chat line open when they type the "
         & "command prefix and pr then the commands they may use starting with pr are suggested"
         TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "promote" TO TL-EXPECTED
     MOVE WS-SUGGESTED TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "/" TO WS-TEXT
     MOVE 1 TO WS-LENGTH
     CALL "CS-SUGGEST" USING CONVH WS-BOBBY WS-TEXT WS-LENGTH WS-SUGGESTED
     MOVE "acceptance US14-1 given a Player without operator status when they type the command "
         & "prefix then only the commands they may use are suggested" TO TL-CASE
     MOVE "howto roster murmur" TO TL-EXPECTED
     MOVE WS-SUGGESTED TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "/murmur A" TO WS-TEXT
     MOVE 9 TO WS-LENGTH
     CALL "CS-SUGGEST" USING CONVH WS-BOBBY WS-TEXT WS-LENGTH WS-SUGGESTED
     MOVE "acceptance US14-1 as they type a player name argument the online player names are "
         & "suggested" TO TL-CASE
     MOVE "Alice" TO TL-EXPECTED
     MOVE WS-SUGGESTED TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Surfaces 1 to 3 on the server.
     MOVE "the server console" TO SF-LABEL
     MOVE WS-CONSOLE TO SF-SENDER
     MOVE WS-BOBBY TO SF-TARGET
     MOVE WS-CARL TO SF-VICTIM
     MOVE 1 TO SF-PERMITTED
     MOVE CV-PORT TO SF-PORT
     MOVE 0 TO SF-SHUTDOWN
     CALL "CS-SURFACE" USING CONVH WS-SURFACE
     MOVE "chat with operator status" TO SF-LABEL
     MOVE WS-ALICE TO SF-SENDER SF-TARGET
     CALL "CS-SURFACE" USING CONVH WS-SURFACE
     MOVE "chat without operator status" TO SF-LABEL
     MOVE WS-BOBBY TO SF-SENDER SF-TARGET
     MOVE 0 TO SF-PERMITTED
     MOVE 1 TO SF-SHUTDOWN
     CALL "CS-SURFACE" USING CONVH WS-SURFACE
     CALL "CS-SHUTDOWN" USING CONVH WS-SURFACE
     MOVE "chat with operator status" TO SF-LABEL
     MOVE WS-ALICE TO SF-SENDER SF-TARGET
     MOVE 1 TO SF-PERMITTED
     CALL "CS-SHUTDOWN" USING CONVH WS-SURFACE

*>   Surface 4: the single-player host, alone.
     CALL "CV-HOST-OPEN" USING CONVH WS-ALICE WS-FOLDER WS-FOLDER-LENGTH WS-MODE
     CALL "CV-UNTIL-PLAY" USING CONVH WS-ALICE WS-JOINED
     MOVE "the single-player host" TO SF-LABEL
     MOVE 0 TO SF-VICTIM SF-PORT
     CALL "CS-SURFACE" USING CONVH WS-SURFACE
     CALL "CS-SHUTDOWN" USING CONVH WS-SURFACE

*>   Surfaces 5 and 6: the world opened to others (guests may use operator commands).
     CALL "CV-HOST-OPEN" USING CONVH WS-ALICE WS-FOLDER WS-FOLDER-LENGTH WS-MODE
     CALL "CV-UNTIL-PLAY" USING CONVH WS-ALICE WS-JOINED
     SET ADDRESS OF CLIENT-STATE TO CV-ADDR(WS-ALICE)
     MOVE CC-KEY-ESCAPE TO WS-KEY
     CALL "CV-KEY" USING CONVH WS-ALICE WS-KEY
     MOVE ACT-OPEN-TO-OTHERS TO WS-ACTION
     CALL "CV-CLICK" USING CONVH WS-ALICE WS-ACTION WS-ARG WS-FOUND
     MOVE ACT-GUEST-OPERATOR TO WS-ACTION
     CALL "CV-CLICK" USING CONVH WS-ALICE WS-ACTION WS-ARG WS-FOUND
     MOVE ACT-OPEN-WORLD TO WS-ACTION
     CALL "CV-CLICK" USING CONVH WS-ALICE WS-ACTION WS-ARG WS-FOUND
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 3 OR SM-SCREEN = SCR-WORLD
         CALL "CV-KEY" USING CONVH WS-ALICE WS-KEY
     END-PERFORM
     MOVE SP-PORT TO CV-PORT SF-PORT
     CALL "CV-JOIN" USING CONVH WS-BOBBY CV-PORT
     CALL "CV-UNTIL-PLAY" USING CONVH WS-BOBBY WS-JOINED
     CALL "CV-JOIN" USING CONVH WS-CARL CV-PORT
     CALL "CV-UNTIL-PLAY" USING CONVH WS-CARL WS-JOINED
     MOVE "SC-009 setup the world opened to others: both guests joined over loopback" TO TL-CASE
     MOVE "screen 5 port 1 guests joined 1" TO TL-EXPECTED
     MOVE SM-SCREEN TO WS-E1
     MOVE 0 TO WS-E2
     IF SP-PORT > 0
         MOVE 1 TO WS-E2
     END-IF
     MOVE SPACES TO TL-OBSERVED
     STRING "screen " FUNCTION TRIM(WS-E1) " port " FUNCTION TRIM(WS-E2) " guests joined "
         DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE WS-JOINED TO WS-E1
     MOVE TL-OBSERVED TO WS-SUGGESTED
     MOVE SPACES TO TL-OBSERVED
     STRING FUNCTION TRIM(WS-SUGGESTED) " " FUNCTION TRIM(WS-E1) DELIMITED BY SIZE
         INTO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "the opened-world host" TO SF-LABEL
     MOVE WS-ALICE TO SF-SENDER SF-TARGET
     MOVE WS-CARL TO SF-VICTIM
     MOVE 0 TO SF-SHUTDOWN
     CALL "CS-SURFACE" USING CONVH WS-SURFACE
     MOVE "an opened-world guest" TO SF-LABEL
     MOVE WS-BOBBY TO SF-SENDER SF-TARGET
     CALL "CS-SURFACE" USING CONVH WS-SURFACE
     CALL "CS-SHUTDOWN" USING CONVH WS-SURFACE

*>   The console's shutdown: the server program started again on the same world, stopped from its
*>   console.
     CALL "CV-SERVER-START" USING CONVH WS-CONF
     CALL "CV-JOIN" USING CONVH WS-BOBBY CV-PORT
     CALL "CV-UNTIL-PLAY" USING CONVH WS-BOBBY WS-JOINED
     MOVE "the server console" TO SF-LABEL
     MOVE WS-CONSOLE TO SF-SENDER
     MOVE 1 TO SF-PERMITTED
     CALL "CS-SHUTDOWN" USING CONVH WS-SURFACE
     STOP RUN.
 END PROGRAM ACC-US14-COMMAND-SURFACES.

*> Test helpers (test infrastructure).
*>   CS-SURFACE USING CONVH, surface (WS-SURFACE above): every row of the command table from that
*>     surface (the shutdown row excluded), one assertion per row.
*>   CS-SHUTDOWN USING CONVH, surface: the shutdown row from that surface, then frames until the
*>     world has stopped (the server program shut down, or hosting ended).
*>   CS-RUN USING CONVH, sender (0 = the console), line (PIC X(64), without "/"), length, reply out
*>     (PIC X(4096)): the line run from the sender's surface; the reply: the console's lines, or the
*>     chat messages the sender received ("|"-separated).
*>   CS-SUGGEST USING CONVH, index, text (PIC X(64)), length, suggestions out (PIC X(1024)): chat
*>     opened, the text typed, a few frames; the names suggested and the server's answers
*>     (space-separated); chat closed again.
*>   CS-SAY USING CONVH, index, text, length: CV-SAY typing at most 30 characters per frame.
*>   CS-SUBST USING template (PIC X(64)), target name (PIC X(16)), victim name, count text
*>     (PIC X(4)), out (PIC X(64)), out length.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. CS-SURFACE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLCONST.
 COPY TESTLIB.
*> The command table (standin-content §16.2), shutdown last: line, expected text, everyone (Y/N).
 01 WS-ROWS.
    05 FILLER PIC X(48) VALUE "howto".
    05 FILLER PIC X(64) VALUE "Commands you may use (&):".
    05 FILLER PIC X VALUE "Y".
    05 FILLER PIC X(48) VALUE "roster".
    05 FILLER PIC X(64) VALUE "Online (3): ".
    05 FILLER PIC X VALUE "Y".
    05 FILLER PIC X(48) VALUE "murmur @ hello".
    05 FILLER PIC X(64) VALUE "You murmur to @: hello".
    05 FILLER PIC X VALUE "Y".
    05 FILLER PIC X(48) VALUE "promote Zed".
    05 FILLER PIC X(64) VALUE "Zed now holds operator status".
    05 FILLER PIC X VALUE "N".
    05 FILLER PIC X(48) VALUE "demote Zed".
    05 FILLER PIC X(64) VALUE "Zed no longer holds operator status".
    05 FILLER PIC X VALUE "N".
    05 FILLER PIC X(48) VALUE "eject %".
    05 FILLER PIC X(64) VALUE "Ejected %".
    05 FILLER PIC X VALUE "N".
    05 FILLER PIC X(48) VALUE "bar Zed".
    05 FILLER PIC X(64) VALUE "Barred Zed".
    05 FILLER PIC X VALUE "N".
    05 FILLER PIC X(48) VALUE "unbar Zed".
    05 FILLER PIC X(64) VALUE "Lifted the bar on Zed".
    05 FILLER PIC X VALUE "N".
    05 FILLER PIC X(48) VALUE "barlist".
    05 FILLER PIC X(64) VALUE "Barred (0)".
    05 FILLER PIC X VALUE "N".
    05 FILLER PIC X(48) VALUE "guestlist on".
    05 FILLER PIC X(64) VALUE "The guest list is now enforced".
    05 FILLER PIC X VALUE "N".
    05 FILLER PIC X(48) VALUE "guestlist off".
    05 FILLER PIC X(64) VALUE "The guest list is no longer enforced".
    05 FILLER PIC X VALUE "N".
    05 FILLER PIC X(48) VALUE "guestlist add Zed".
    05 FILLER PIC X(64) VALUE "Added Zed to the guest list".
    05 FILLER PIC X VALUE "N".
    05 FILLER PIC X(48) VALUE "guestlist remove Zed".
    05 FILLER PIC X(64) VALUE "Removed Zed from the guest list".
    05 FILLER PIC X VALUE "N".
    05 FILLER PIC X(48) VALUE "guestlist show".
    05 FILLER PIC X(64) VALUE "Guest list enforcement off; guests (0)".
    05 FILLER PIC X VALUE "N".
    05 FILLER PIC X(48) VALUE "mode @ creative".
    05 FILLER PIC X(64) VALUE "@ now plays in creative mode".
    05 FILLER PIC X VALUE "N".
    05 FILLER PIC X(48) VALUE "mode @ survival".
    05 FILLER PIC X(64) VALUE "@ now plays in survival mode".
    05 FILLER PIC X VALUE "N".
    05 FILLER PIC X(48) VALUE "relocate @ at 10 60 10".
    05 FILLER PIC X(64) VALUE "Relocated @ to 10.00, 60.00, 10.00 in main".
    05 FILLER PIC X VALUE "N".
    05 FILLER PIC X(48) VALUE "relocate @ to @".
    05 FILLER PIC X(64) VALUE "Relocated @ to @".
    05 FILLER PIC X VALUE "N".
    05 FILLER PIC X(48) VALUE "supply @ greystone 5".
    05 FILLER PIC X(64) VALUE "Supplied 5 greystone to @".
    05 FILLER PIC X VALUE "N".
    05 FILLER PIC X(48) VALUE "empty @".
    05 FILLER PIC X(64) VALUE "Emptied the inventory of @ (".
    05 FILLER PIC X VALUE "N".
    05 FILLER PIC X(48) VALUE "vitality @ 20".
    05 FILLER PIC X(64) VALUE "Set the health of @ to 20".
    05 FILLER PIC X VALUE "N".
    05 FILLER PIC X(48) VALUE "ration @ 20".
    05 FILLER PIC X(64) VALUE "Set the food level of @ to 20".
    05 FILLER PIC X VALUE "N".
    05 FILLER PIC X(48) VALUE "conjure sodgrazer 10 60 10".
    05 FILLER PIC X(64) VALUE "Conjured a sodgrazer at 10.00, 60.00, 10.00 in main".
    05 FILLER PIC X VALUE "N".
    05 FILLER PIC X(48) VALUE "sweep mobs everywhere".
    05 FILLER PIC X(64) VALUE "Swept away ".
    05 FILLER PIC X VALUE "N".
    05 FILLER PIC X(48) VALUE "clock 1000".
    05 FILLER PIC X(64) VALUE "The clock now reads 1000".
    05 FILLER PIC X VALUE "N".
    05 FILLER PIC X(48) VALUE "skies main drizzle 60".
    05 FILLER PIC X(64) VALUE "The skies over main turn to drizzle for 60 seconds".
    05 FILLER PIC X VALUE "N".
    05 FILLER PIC X(48) VALUE "homestead 4 54 8".
    05 FILLER PIC X(64) VALUE "The world spawn point is now 4.00, 54.00, 8.00".
    05 FILLER PIC X VALUE "N".
    05 FILLER PIC X(48) VALUE "announce hello".
    05 FILLER PIC X(64) VALUE "Announcement sent".
    05 FILLER PIC X VALUE "N".
    05 FILLER PIC X(48) VALUE "persist".
    05 FILLER PIC X(64) VALUE "The world has been saved".
    05 FILLER PIC X VALUE "N".
 01 WS-TABLE REDEFINES WS-ROWS.
    05 WS-ROW OCCURS 29 TIMES.
       10 WS-ROW-LINE      PIC X(48).
       10 WS-ROW-EXPECT    PIC X(64).
       10 WS-ROW-EVERYONE  PIC X.
 01 WS-R                   BINARY-LONG.
 01 WS-NAMES.
    05 WS-NAME             PIC X(16) OCCURS 4 TIMES.
 01 WS-TARGET              PIC X(16).
 01 WS-VICTIM              PIC X(16).
 01 WS-HOWTO               PIC X(4).
 01 WS-LINE                PIC X(64).
 01 WS-LINE-LENGTH         BINARY-LONG.
 01 WS-TEMPLATE            PIC X(64).
 01 WS-EXPECT              PIC X(64).
 01 WS-EXPECT-LENGTH       BINARY-LONG.
 01 WS-WORD                PIC X(48).
 01 WS-REPLY               PIC X(4096).
 01 WS-COUNT               BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-JOINED              BINARY-LONG.
 01 WS-SCREEN              BINARY-LONG VALUE SCR-SERVER-LIST.
 01 WS-REACHED             BINARY-LONG.
 01 WS-LOG                 PIC X(4096).
 01 WS-EFFECT              PIC X(128).
 01 WS-SEEN                PIC X(128).
 01 WS-E1                  PIC -(9)9.
 LINKAGE SECTION.
 COPY CONVH.
 COPY CLSTATE.
 01 L-SURFACE.
    05 SF-LABEL            PIC X(40).
    05 SF-SENDER           BINARY-LONG.
    05 SF-TARGET           BINARY-LONG.
    05 SF-VICTIM           BINARY-LONG.
    05 SF-PERMITTED        BINARY-LONG.
    05 SF-PORT             BINARY-LONG.
    05 SF-SHUTDOWN         BINARY-LONG.
 PROCEDURE DIVISION USING CONVH L-SURFACE.
     MOVE "Alice" TO WS-NAME(1)
     MOVE "Bobby" TO WS-NAME(2)
     MOVE "Carl" TO WS-NAME(3)
     MOVE WS-NAME(SF-TARGET) TO WS-TARGET
     MOVE "Zed" TO WS-VICTIM
     IF SF-VICTIM > 0
         MOVE WS-NAME(SF-VICTIM) TO WS-VICTIM
     END-IF
     MOVE "35" TO WS-HOWTO
     IF SF-PERMITTED = 0
         MOVE "3" TO WS-HOWTO
     END-IF
     PERFORM VARYING WS-R FROM 1 BY 1 UNTIL WS-R > 29
         MOVE WS-ROW-LINE(WS-R) TO WS-TEMPLATE
         CALL "CS-SUBST" USING WS-TEMPLATE WS-TARGET WS-VICTIM WS-HOWTO WS-LINE WS-LINE-LENGTH
         MOVE WS-ROW-EXPECT(WS-R) TO WS-TEMPLATE
         CALL "CS-SUBST" USING WS-TEMPLATE WS-TARGET WS-VICTIM WS-HOWTO WS-EXPECT
             WS-EXPECT-LENGTH
*>       The roster from the single-player host alone: only the host is online.
         IF WS-R = 2 AND SF-PORT = 0
             MOVE "Online (1): Alice" TO WS-EXPECT
         END-IF
*>       Eject with nobody else in the world: the §16.1 target rule.
         IF WS-R = 6 AND SF-VICTIM = 0
             MOVE "No player named Zed is online" TO WS-EXPECT
         END-IF
         IF SF-PERMITTED = 0 AND WS-ROW-EVERYONE(WS-R) = "N"
             MOVE SPACES TO WS-WORD WS-EXPECT
             UNSTRING WS-ROW-LINE(WS-R) DELIMITED BY SPACE INTO WS-WORD
             STRING "You may not use " FUNCTION TRIM(WS-WORD) DELIMITED BY SIZE
                 INTO WS-EXPECT
         END-IF
         MOVE FUNCTION LENGTH(FUNCTION TRIM(WS-EXPECT TRAILING)) TO WS-EXPECT-LENGTH
         IF SF-VICTIM > 0
             SET ADDRESS OF CLIENT-STATE TO CV-ADDR(SF-VICTIM)
             MOVE 0 TO CH-COUNT
         END-IF
         CALL "CS-RUN" USING CONVH SF-SENDER WS-LINE WS-LINE-LENGTH WS-REPLY
         MOVE SPACES TO TL-CASE
         STRING "SC-009 given " FUNCTION TRIM(SF-LABEL) " when " WS-LINE(1:WS-LINE-LENGTH)
             " runs then the sender sees: " WS-EXPECT(1:WS-EXPECT-LENGTH)
             DELIMITED BY SIZE INTO TL-CASE
         MOVE "T" TO TL-MODE
         MOVE WS-EXPECT TO TL-EXPECTED
         MOVE 0 TO WS-COUNT
         INSPECT WS-REPLY TALLYING WS-COUNT FOR ALL WS-EXPECT(1:WS-EXPECT-LENGTH)
         IF WS-COUNT > 0
             MOVE WS-EXPECT TO TL-OBSERVED
         ELSE
             MOVE WS-REPLY TO TL-OBSERVED
         END-IF
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>       Effects in the world of the permitted runs.
         MOVE SPACES TO WS-EFFECT WS-SEEN
         EVALUATE TRUE
             WHEN SF-PERMITTED = 0
                 CONTINUE
             WHEN WS-R = 6 AND SF-VICTIM > 0
                 CALL "CV-UNTIL-SCREEN" USING CONVH SF-VICTIM WS-SCREEN WS-REACHED
                 SET ADDRESS OF CLIENT-STATE TO CV-ADDR(SF-VICTIM)
                 MOVE "the ejected Player is back on the server list: screen 2" TO WS-EFFECT
                 MOVE SM-SCREEN TO WS-E1
                 STRING "the ejected Player is back on the server list: screen "
                     FUNCTION TRIM(WS-E1) DELIMITED BY SIZE INTO WS-SEEN
                 CALL "CV-JOIN" USING CONVH SF-VICTIM SF-PORT
                 CALL "CV-UNTIL-PLAY" USING CONVH SF-VICTIM WS-JOINED
             WHEN WS-R = 15 OR WS-R = 16
                 SET ADDRESS OF CLIENT-STATE TO CV-ADDR(SF-TARGET)
                 COMPUTE WS-E1 = 16 - WS-R
                 STRING "the target's game mode is " FUNCTION TRIM(WS-E1) DELIMITED BY SIZE
                     INTO WS-EFFECT
                 MOVE PL-MODE TO WS-E1
                 STRING "the target's game mode is " FUNCTION TRIM(WS-E1) DELIMITED BY SIZE
                     INTO WS-SEEN
             WHEN WS-R = 25
                 SET ADDRESS OF CLIENT-STATE TO CV-ADDR(SF-TARGET)
                 MOVE "the target's clock is within 10 ticks of 1000: 1" TO WS-EFFECT
                 MOVE 0 TO WS-E1
                 IF PL-TIME >= 1000 AND PL-TIME < 1010
                     MOVE 1 TO WS-E1
                 END-IF
                 STRING "the target's clock is within 10 ticks of 1000: " FUNCTION TRIM(WS-E1)
                     DELIMITED BY SIZE INTO WS-SEEN
             WHEN WS-R = 28 AND SF-VICTIM > 0
                 CALL "CV-CHAT-LOG" USING CONVH SF-VICTIM WS-LOG
                 MOVE "another Player sees [Server] hello: 1" TO WS-EFFECT
                 MOVE 0 TO WS-COUNT
                 INSPECT WS-LOG TALLYING WS-COUNT FOR ALL "[Server] hello"
                 MOVE WS-COUNT TO WS-E1
                 STRING "another Player sees [Server] hello: " FUNCTION TRIM(WS-E1)
                     DELIMITED BY SIZE INTO WS-SEEN
         END-EVALUATE
         IF WS-EFFECT NOT = SPACES
             MOVE SPACES TO TL-CASE
             STRING "SC-009 given " FUNCTION TRIM(SF-LABEL) " when " WS-LINE(1:WS-LINE-LENGTH)
                 " runs then " FUNCTION TRIM(WS-EFFECT) DELIMITED BY SIZE INTO TL-CASE
             MOVE WS-EFFECT TO TL-EXPECTED
             MOVE WS-SEEN TO TL-OBSERVED
             CALL "TEST-ASSERT" USING TESTLIB-ASSERT
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM CS-SURFACE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CS-SHUTDOWN.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLCONST.
 COPY COREAPI.
 COPY TESTLIB.
 01 WS-LINE                PIC X(64) VALUE "shutdown".
 01 WS-LINE-LENGTH         BINARY-LONG VALUE 8.
 01 WS-REPLY               PIC X(4096).
 01 WS-EXPECT              PIC X(64).
 01 WS-COUNT               BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-HOST                BINARY-LONG.
 01 WS-PTR                 BINARY-LONG.
 01 WS-PTR2                BINARY-LONG.
 01 WS-E1                  PIC -(9)9.
 01 WS-E2                  PIC -(9)9.
 LINKAGE SECTION.
 COPY CONVH.
 COPY CLSTATE.
 01 L-SURFACE.
    05 SF-LABEL            PIC X(40).
    05 SF-SENDER           BINARY-LONG.
    05 SF-TARGET           BINARY-LONG.
    05 SF-VICTIM           BINARY-LONG.
    05 SF-PERMITTED        BINARY-LONG.
    05 SF-PORT             BINARY-LONG.
    05 SF-SHUTDOWN         BINARY-LONG.
 PROCEDURE DIVISION USING CONVH L-SURFACE.
     CALL "CS-RUN" USING CONVH SF-SENDER WS-LINE WS-LINE-LENGTH WS-REPLY
     MOVE "Shutting down" TO WS-EXPECT
     IF SF-PERMITTED = 0
         MOVE "You may not use shutdown" TO WS-EXPECT
     END-IF
     MOVE SPACES TO TL-CASE
     STRING "SC-009 given " FUNCTION TRIM(SF-LABEL) " when shutdown runs then the sender sees: "
         FUNCTION TRIM(WS-EXPECT) DELIMITED BY SIZE INTO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE WS-EXPECT TO TL-EXPECTED
     MOVE 0 TO WS-COUNT
     INSPECT WS-REPLY TALLYING WS-COUNT FOR ALL FUNCTION TRIM(WS-EXPECT)
     IF WS-COUNT > 0
         MOVE WS-EXPECT TO TL-OBSERVED
     ELSE
         MOVE WS-REPLY TO TL-OBSERVED
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     IF SF-PERMITTED = 1
*>       The world stops: the server program shuts down, or the host's world closes.
         MOVE 0 TO CST-RUN-STATE
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 100 OR CST-RUN-STATE = 2
             CALL "CV-STEP" USING CONVH
             CALL "CORE-STATUS-GET" USING CORE-STATUS
         END-PERFORM
         MOVE 20 TO WS-I
         CALL "CV-STEPS" USING CONVH WS-I
         IF CV-SERVER = 1
             CALL "SV-SHUTDOWN"
             MOVE 0 TO CV-SERVER
         END-IF
         MOVE CV-HOST TO WS-HOST
         MOVE 0 TO CV-HOST
         MOVE SPACES TO TL-CASE
         STRING "SC-009 given " FUNCTION TRIM(SF-LABEL) " when shutdown runs then the world "
             "stops: a host is back on the title screen, every other Player on the server list"
             DELIMITED BY SIZE INTO TL-CASE
         MOVE SPACES TO TL-EXPECTED TL-OBSERVED
         MOVE CST-RUN-STATE TO WS-E2
         MOVE 1 TO WS-PTR WS-PTR2
         STRING "stopped 2 screens" DELIMITED BY SIZE INTO TL-EXPECTED WITH POINTER WS-PTR
         STRING "stopped " FUNCTION TRIM(WS-E2) " screens" DELIMITED BY SIZE INTO TL-OBSERVED
             WITH POINTER WS-PTR2
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > CV-COUNT
             SET ADDRESS OF CLIENT-STATE TO CV-ADDR(WS-I)
             MOVE SM-SCREEN TO WS-E1
             EVALUATE TRUE
             WHEN WS-I NOT = WS-HOST AND SM-SCREEN = SCR-TITLE
*>               A Player who was not in this world (back on the title screen from another).
                 CONTINUE
             WHEN WS-I = WS-HOST
                 STRING " 1 hosting 0" DELIMITED BY SIZE INTO TL-EXPECTED WITH POINTER WS-PTR
                 STRING " " FUNCTION TRIM(WS-E1) " hosting " SP-ACTIVE DELIMITED BY SIZE
                     INTO TL-OBSERVED WITH POINTER WS-PTR2
             WHEN OTHER
                 STRING " 2" DELIMITED BY SIZE INTO TL-EXPECTED WITH POINTER WS-PTR
                 STRING " " FUNCTION TRIM(WS-E1) DELIMITED BY SIZE INTO TL-OBSERVED
                     WITH POINTER WS-PTR2
             END-EVALUATE
         END-PERFORM
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     END-IF
     GOBACK.
 END PROGRAM CS-SHUTDOWN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CS-RUN.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY COREAPI.
 01 WS-LINE                PIC X(256).
 01 WS-SLASHED             PIC X(64).
 01 WS-LENGTH              BINARY-LONG.
 01 WS-THREE               BINARY-LONG VALUE 3.
 01 WS-AREA                PIC X(65536).
 01 WS-I                   BINARY-LONG.
 LINKAGE SECTION.
 COPY CONVH.
 COPY CLSTATE.
 01 L-SENDER               BINARY-LONG.
 01 L-TEXT                 PIC X(64).
 01 L-LENGTH               BINARY-LONG.
 01 L-REPLY                PIC X(4096).
 PROCEDURE DIVISION USING CONVH L-SENDER L-TEXT L-LENGTH L-REPLY.
     MOVE SPACES TO L-REPLY
     IF L-SENDER = 0
*>       The console: earlier lines drained (and dropped), the line run, its reply drained.
         SET CB-ADDR TO ADDRESS OF WS-AREA
         MOVE 65536 TO CB-CAPACITY
         MOVE 0 TO CB-LENGTH
         CALL "CORE-CONSOLE-DRAIN" USING CORE-BUFFER
         MOVE SPACES TO WS-LINE
         MOVE L-TEXT(1:L-LENGTH) TO WS-LINE
         CALL "CV-SERVER-CONSOLE" USING CONVH WS-LINE
         SET CB-ADDR TO ADDRESS OF WS-AREA
         MOVE 65536 TO CB-CAPACITY
         MOVE 0 TO CB-LENGTH
         CALL "CORE-CONSOLE-DRAIN" USING CORE-BUFFER
         MOVE FUNCTION MIN(CB-LENGTH, 4096) TO WS-I
         IF WS-I > 0
             MOVE WS-AREA(1:WS-I) TO L-REPLY
         END-IF
         CALL "CV-STEPS" USING CONVH WS-THREE
     ELSE
         SET ADDRESS OF CLIENT-STATE TO CV-ADDR(L-SENDER)
         MOVE 0 TO CH-COUNT
         MOVE SPACES TO WS-SLASHED
         STRING "/" L-TEXT(1:L-LENGTH) DELIMITED BY SIZE INTO WS-SLASHED
         COMPUTE WS-LENGTH = L-LENGTH + 1
         CALL "CS-SAY" USING CONVH L-SENDER WS-SLASHED WS-LENGTH
         CALL "CV-STEPS" USING CONVH WS-THREE
         CALL "CV-CHAT-LOG" USING CONVH L-SENDER L-REPLY
     END-IF
     GOBACK.
 END PROGRAM CS-RUN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CS-SUGGEST.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CCSHIM.
 01 WS-T                   BINARY-LONG VALUE CC-KEY-T.
 01 WS-ESCAPE              BINARY-LONG VALUE CC-KEY-ESCAPE.
 01 WS-THREE               BINARY-LONG VALUE 3.
 01 WS-I                   BINARY-LONG.
 01 WS-PTR                 BINARY-LONG.
 01 WS-LENGTH              BINARY-LONG.
 LINKAGE SECTION.
 COPY CONVH.
 COPY CLSTATE.
 01 L-INDEX                BINARY-LONG.
 01 L-TEXT                 PIC X(64).
 01 L-LENGTH               BINARY-LONG.
 01 L-OUT                  PIC X(1024).
 PROCEDURE DIVISION USING CONVH L-INDEX L-TEXT L-LENGTH L-OUT.
     CALL "CV-KEY" USING CONVH L-INDEX WS-T
     CALL "CV-TYPE" USING CONVH L-INDEX L-TEXT L-LENGTH
     CALL "CV-STEPS" USING CONVH WS-THREE
     SET ADDRESS OF CLIENT-STATE TO CV-ADDR(L-INDEX)
     MOVE SPACES TO L-OUT
     MOVE 1 TO WS-PTR
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > CS-COUNT
         MOVE CS-LENGTH(WS-I) TO WS-LENGTH
         IF WS-I > 1
             STRING " " DELIMITED BY SIZE INTO L-OUT WITH POINTER WS-PTR
         END-IF
         STRING CS-TEXT(WS-I)(1:WS-LENGTH) DELIMITED BY SIZE INTO L-OUT WITH POINTER WS-PTR
     END-PERFORM
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > CS-ANSWERS
         MOVE CS-A-LENGTH(WS-I) TO WS-LENGTH
         IF WS-PTR > 1
             STRING " " DELIMITED BY SIZE INTO L-OUT WITH POINTER WS-PTR
         END-IF
         STRING CS-A-TEXT(WS-I)(1:WS-LENGTH) DELIMITED BY SIZE INTO L-OUT WITH POINTER WS-PTR
     END-PERFORM
     CALL "CV-KEY" USING CONVH L-INDEX WS-ESCAPE
     GOBACK.
 END PROGRAM CS-SUGGEST.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CS-SAY.
*> CV-SAY, typing at most 30 characters per frame (a frame takes at most 32 typed characters,
*> CLSTATE IN-TEXT).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CCSHIM.
 01 WS-T                   BINARY-LONG VALUE CC-KEY-T.
 01 WS-ENTER               BINARY-LONG VALUE CC-KEY-ENTER.
 01 WS-FROM                BINARY-LONG.
 01 WS-PART                PIC X(64).
 01 WS-PART-LENGTH         BINARY-LONG.
 LINKAGE SECTION.
 COPY CONVH.
 01 L-INDEX                BINARY-LONG.
 01 L-TEXT                 PIC X(64).
 01 L-LENGTH               BINARY-LONG.
 PROCEDURE DIVISION USING CONVH L-INDEX L-TEXT L-LENGTH.
     CALL "CV-KEY" USING CONVH L-INDEX WS-T
     PERFORM VARYING WS-FROM FROM 1 BY 30 UNTIL WS-FROM > L-LENGTH
         COMPUTE WS-PART-LENGTH = FUNCTION MIN(30, L-LENGTH - WS-FROM + 1)
         MOVE SPACES TO WS-PART
         MOVE L-TEXT(WS-FROM:WS-PART-LENGTH) TO WS-PART
         CALL "CV-TYPE" USING CONVH L-INDEX WS-PART WS-PART-LENGTH
     END-PERFORM
     CALL "CV-KEY" USING CONVH L-INDEX WS-ENTER
     GOBACK.
 END PROGRAM CS-SAY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CS-SUBST.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-I                   BINARY-LONG.
 01 WS-PTR                 BINARY-LONG.
 01 WS-END                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-TEMPLATE             PIC X(64).
 01 L-TARGET               PIC X(16).
 01 L-VICTIM               PIC X(16).
 01 L-COUNT                PIC X(4).
 01 L-OUT                  PIC X(64).
 01 L-LENGTH               BINARY-LONG.
 PROCEDURE DIVISION USING L-TEMPLATE L-TARGET L-VICTIM L-COUNT L-OUT L-LENGTH.
     MOVE SPACES TO L-OUT
     MOVE 1 TO WS-PTR
     MOVE 64 TO WS-END
     PERFORM UNTIL WS-END = 0 OR L-TEMPLATE(WS-END:1) NOT = SPACE
         SUBTRACT 1 FROM WS-END
     END-PERFORM
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-END
         EVALUATE L-TEMPLATE(WS-I:1)
             WHEN "@"
                 STRING FUNCTION TRIM(L-TARGET) DELIMITED BY SIZE INTO L-OUT WITH POINTER WS-PTR
             WHEN "%"
                 STRING FUNCTION TRIM(L-VICTIM) DELIMITED BY SIZE INTO L-OUT WITH POINTER WS-PTR
             WHEN "&"
                 STRING FUNCTION TRIM(L-COUNT) DELIMITED BY SIZE INTO L-OUT WITH POINTER WS-PTR
             WHEN OTHER
                 STRING L-TEMPLATE(WS-I:1) DELIMITED BY SIZE INTO L-OUT WITH POINTER WS-PTR
         END-EVALUATE
     END-PERFORM
     COMPUTE L-LENGTH = WS-PTR - 1
     GOBACK.
 END PROGRAM CS-SUBST.
