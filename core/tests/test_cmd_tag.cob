*> Acceptance test of docs/protocol/16-commands-catalog.md §5.9 `tag` (permission level 2) with 14a: tag <targets> add <name> | remove <name> | list over the tags of
*> entities (players and mobs; at most 1024 per entity). add/remove: none changed is commands.tag.add.failed / .remove.failed, one is .success.single [tag, name],
*> several .success.multiple [tag, count] (broadcast); the result is the count. list: union of the tags; no target with tags is commands.tag.list.multiple.empty [0],
*> one is .single.success [name, its count, tags], several .multiple.success [targets with tags, union size, tags] (not broadcast); the result is the size of the union.
*> Opal holds operator status.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-CMD-TAG.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY PROTO.
 01 WS-ID-OPAL           BINARY-LONG.
 01 WS-ID-ALICE          BINARY-LONG.
 01 WS-ID-CLEO           BINARY-LONG.
 01 WS-NAME                PIC X(16).
 01 WS-NAME-LENGTH         BINARY-LONG.
 01 WS-LINE                PIC X(768).
 01 WS-TEXT                PIC X(4096).
 01 WS-DISCARD             PIC X(4096).
 01 WS-EXPECTED            PIC X(1024).
 01 WS-EXPECTED-N          BINARY-DOUBLE.
 01 WS-NUM                 BINARY-DOUBLE.
 01 WS-I                   BINARY-LONG.
 01 WS-EDIT                PIC Z(4)9.
 01 WS-MOB-SELECTOR        PIC X(80) VALUE "@e[type=cobolcraft:sodgrazer,x=5,y=64,z=5,sort=nearest,limit=1]".
 PROCEDURE DIVISION.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     MOVE "Opal" TO WS-NAME
     MOVE 4 TO WS-NAME-LENGTH
     CALL "TEST-JOIN-OP" USING WS-NAME WS-NAME-LENGTH WS-ID-OPAL
     MOVE "Alice" TO WS-NAME
     MOVE 5 TO WS-NAME-LENGTH
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-ID-ALICE
     MOVE "Cleo" TO WS-NAME
     MOVE 4 TO WS-NAME-LENGTH
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-ID-CLEO
     CALL "TEST-DRAIN-CHAT" USING WS-ID-OPAL WS-DISCARD
     MOVE "acceptance US13 /tag add one tag to one player: Added tag 'foo' to Alice" TO TL-CASE
     MOVE "tag Alice add foo" TO WS-LINE
     MOVE "commands.tag.add.success.single(foo,Alice)" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /tag add a tag the target has: failed" TO TL-CASE
     MOVE "tag Alice add foo" TO WS-LINE
     MOVE "commands.tag.add.failed()" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /tag add to three players: Added tag 'bar' to 3 entities" TO TL-CASE
     MOVE "tag @a add bar" TO WS-LINE
     MOVE "commands.tag.add.success.multiple(bar,3)" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /tag add to nobody that lacks it: failed" TO TL-CASE
     MOVE "tag @a add bar" TO WS-LINE
     MOVE "commands.tag.add.failed()" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /tag add the result is the number changed" TO TL-CASE
     MOVE "tag @a add baz" TO WS-LINE
     CALL "TEST-RUN-RESULT" USING WS-ID-OPAL WS-LINE WS-NUM
     MOVE 3 TO WS-EXPECTED-N
     CALL "TEST-EXPECT-NUMBER" USING TL-CASE WS-EXPECTED-N WS-NUM
     CALL "TEST-DRAIN-CHAT" USING WS-ID-OPAL WS-DISCARD
     MOVE "tag @a remove baz" TO WS-LINE
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     MOVE "acceptance US13 /tag list one entity: Alice has 2 tags" TO TL-CASE
     MOVE "tag Alice list" TO WS-LINE
     MOVE "commands.tag.list.single.success(Alice,2,foo, bar)" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /tag list several: the union of foo and bar" TO TL-CASE
     MOVE "tag @a list" TO WS-LINE
     MOVE "commands.tag.list.multiple.success(3,2,bar, foo)" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /tag list the result is the size of the union" TO TL-CASE
     CALL "TEST-RUN-RESULT" USING WS-ID-OPAL WS-LINE WS-NUM
     MOVE 2 TO WS-EXPECTED-N
     CALL "TEST-EXPECT-NUMBER" USING TL-CASE WS-EXPECTED-N WS-NUM
     CALL "TEST-DRAIN-CHAT" USING WS-ID-OPAL WS-DISCARD
     MOVE "acceptance US13 /tag remove one tag from one player: Removed tag 'foo' from Alice" TO TL-CASE
     MOVE "tag Alice remove foo" TO WS-LINE
     MOVE "commands.tag.remove.success.single(foo,Alice)" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /tag remove a tag the target lacks: failed" TO TL-CASE
     MOVE "tag Alice remove foo" TO WS-LINE
     MOVE "commands.tag.remove.failed()" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /tag add after a removal reuses the entry" TO TL-CASE
     MOVE "tag Cleo add foo" TO WS-LINE
     MOVE "commands.tag.add.success.single(foo,Cleo)" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /tag remove from three players: Removed tag 'bar' from 3 entities" TO TL-CASE
     MOVE "tag @a remove bar" TO WS-LINE
     MOVE "commands.tag.remove.success.multiple(bar,3)" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /tag a mob is tagged as well" TO TL-CASE
     MOVE "summon cobolcraft:sodgrazer 5.0 64.0 5.0" TO WS-LINE
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     STRING "tag " DELIMITED BY SIZE WS-MOB-SELECTOR DELIMITED BY SPACE " add m" DELIMITED BY SIZE INTO WS-LINE
     MOVE "commands.tag.add.success.single(m,cobolcraft:sodgrazer)" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /tag remove the mob tag" TO TL-CASE
     MOVE SPACES TO WS-LINE
     STRING "tag " DELIMITED BY SIZE WS-MOB-SELECTOR DELIMITED BY SPACE " remove m" DELIMITED BY SIZE INTO WS-LINE
     MOVE "commands.tag.remove.success.single(m,cobolcraft:sodgrazer)" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /tag list on an entity without tags: There are no tags on the 0 entities" TO TL-CASE
     MOVE SPACES TO WS-LINE
     STRING "tag " DELIMITED BY SIZE WS-MOB-SELECTOR DELIMITED BY SPACE " list" DELIMITED BY SIZE INTO WS-LINE
     MOVE "commands.tag.list.multiple.empty(0)" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /tag a player without operator status does not know the command" TO TL-CASE
     MOVE "tag Opal list" TO WS-LINE
     MOVE "command.unknown.command() |" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-ALICE WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /tag the console prints the English text" TO TL-CASE
     MOVE "tag Cleo remove foo" TO WS-LINE
     MOVE "Removed tag 'foo' from Cleo" TO WS-EXPECTED
     CALL "TEST-RUN-CONSOLE" USING WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /tag an entity holds at most 1024 tags" TO TL-CASE
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 1024
         MOVE WS-I TO WS-EDIT
         MOVE SPACES TO WS-LINE
         STRING "tag Alice add t" FUNCTION TRIM(WS-EDIT) DELIMITED BY SIZE INTO WS-LINE
         CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     END-PERFORM
     MOVE "tag Alice add t1025" TO WS-LINE
     MOVE "commands.tag.add.failed()" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /tag the store is full: 1024 tags on each of three players and a mob fill it, the next fails" TO TL-CASE
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 1024
         MOVE WS-I TO WS-EDIT
         MOVE SPACES TO WS-LINE
         STRING "tag Cleo add u" FUNCTION TRIM(WS-EDIT) DELIMITED BY SIZE INTO WS-LINE
         CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     END-PERFORM
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 1023
         MOVE WS-I TO WS-EDIT
         MOVE SPACES TO WS-LINE
         STRING "tag Opal add v" FUNCTION TRIM(WS-EDIT) DELIMITED BY SIZE INTO WS-LINE
         CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     END-PERFORM
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 1024
         MOVE WS-I TO WS-EDIT
         MOVE SPACES TO WS-LINE
         STRING "tag " DELIMITED BY SIZE WS-MOB-SELECTOR DELIMITED BY SPACE " add w" DELIMITED BY SIZE
             FUNCTION TRIM(WS-EDIT) DELIMITED BY SIZE INTO WS-LINE
         CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     END-PERFORM
     MOVE "summon cobolcraft:sodgrazer 9.0 64.0 9.0" TO WS-LINE
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     MOVE "tag @e[type=cobolcraft:sodgrazer,x=9,y=64,z=9,sort=nearest,limit=1] add z1" TO WS-LINE
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     MOVE "tag Opal add vz" TO WS-LINE
     MOVE "commands.tag.add.failed()" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /tag a removal frees an entry of the full store" TO TL-CASE
     MOVE "tag Alice remove t1" TO WS-LINE
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     MOVE "tag Opal add vz" TO WS-LINE
     MOVE "commands.tag.add.success.single(vz,Opal)" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     GOBACK.
 END PROGRAM TEST-CMD-TAG.

 COPY CORETEST.
 COPY CMDTEST.
