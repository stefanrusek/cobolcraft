*> Implementation test of the client's world type decision (WT-16, docs/design/world-types.md §7.4; content-api
*> CONTENT-CLIENT-REGISTRY-ADD and CONTENT-CLIENT-FINISH): on a network connection the Registry Data and Update
*> Tags of the configuration phase build the connection's content set, and Finish Configuration decides the type
*> from minecraft:dimension_type: standard when it holds no cobolcraft:surface, cobolcraft when it does; the set is
*> then the type's (standard: its block states; cobolcraft: the 19 built-in ones) and CL-WORLD-TYPE says which.
*> Disconnecting closes the set. A memory connection (a hosted single-player world) leaves the set to the core.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-WT16.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLSTATE.
 COPY CLCONST.
 COPY CONTENT.
 COPY TESTLIB.
 01 WS-CONN                BINARY-LONG VALUE 1.
 01 WS-PATH                PIC X(256).
 01 WS-TEXT                PIC X(512).
 01 WS-LENGTH              BINARY-LONG VALUE 0.
 01 WS-E1                  PIC 9.
 01 WS-E2                  PIC 9.
 01 WS-E3                  PIC 9.
 01 WS-E4                  PIC 9(6).
 PROCEDURE DIVISION.
     INITIALIZE CT-SET
     CALL "CL-INIT" USING CLIENT-STATE
     CALL "PACK-STACK-INIT" USING CLIENT-STATE
     CALL "LANG-LOAD" USING CLIENT-STATE
     CALL "NET-BUFFERS-INIT" USING CLIENT-STATE WS-CONN
     MOVE PH-CONFIG TO CN-PHASE(WS-CONN)

*>   A standard server: the three standard dimension types, the tags, Finish Configuration.
     MOVE "contract/fixtures/wire/config-s2c-07-registry-data-dimension-type-standard.hex" TO WS-PATH
     CALL "TEST-FEED" USING CLIENT-STATE WS-CONN WS-PATH
     MOVE "contract/fixtures/wire/config-s2c-0e-update-tags-standard.hex" TO WS-PATH
     CALL "TEST-FEED" USING CLIENT-STATE WS-CONN WS-PATH
     MOVE "contract/fixtures/wire/config-s2c-03-finish-configuration.hex" TO WS-PATH
     CALL "TEST-FEED" USING CLIENT-STATE WS-CONN WS-PATH
     MOVE "wt16 a server whose dimension types have no cobolcraft:surface opens the standard set at "
         & "Finish Configuration (the standard block states)" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE CT-OPEN TO WS-E1
     MOVE CT-SET-TYPE TO WS-E2
     MOVE CL-WORLD-TYPE TO WS-E3
     MOVE SPACES TO TL-OBSERVED
     STRING "open " WS-E1 " set " WS-E2 " world " WS-E3 DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "open 1 set 0 world 0" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "wt16 the standard set holds more than 30,000 block states" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF CT-STATE-COUNT > 30000
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "wt16 the connection is in play after Finish Configuration" TO TL-CASE
     MOVE PH-PLAY TO TL-EXPECTED-N
     MOVE CN-PHASE(WS-CONN) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Disconnecting closes the set.
     CALL "CLIENT-DISCONNECT" USING CLIENT-STATE WS-CONN WS-TEXT WS-LENGTH
     MOVE "wt16 leaving the server closes its content set" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE CT-OPEN TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   A cobolcraft server: its dimension types hold cobolcraft:surface.
     MOVE PH-CONFIG TO CN-PHASE(WS-CONN)
     MOVE "contract/fixtures/wire/config-s2c-07-registry-data-dimension-type.hex" TO WS-PATH
     CALL "TEST-FEED" USING CLIENT-STATE WS-CONN WS-PATH
     MOVE "contract/fixtures/wire/config-s2c-0e-update-tags.hex" TO WS-PATH
     CALL "TEST-FEED" USING CLIENT-STATE WS-CONN WS-PATH
     MOVE "contract/fixtures/wire/config-s2c-03-finish-configuration.hex" TO WS-PATH
     CALL "TEST-FEED" USING CLIENT-STATE WS-CONN WS-PATH
     MOVE "wt16 a server whose dimension types hold cobolcraft:surface opens the cobolcraft set (19 "
         & "built-in states)" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE CT-OPEN TO WS-E1
     MOVE CT-SET-TYPE TO WS-E2
     MOVE CL-WORLD-TYPE TO WS-E3
     MOVE CT-STATE-COUNT TO WS-E4
     MOVE SPACES TO TL-OBSERVED
     STRING "open " WS-E1 " set " WS-E2 " world " WS-E3 " states " WS-E4 DELIMITED BY SIZE
         INTO TL-OBSERVED
     MOVE "open 1 set 1 world 1 states 000019" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "CLIENT-DISCONNECT" USING CLIENT-STATE WS-CONN WS-TEXT WS-LENGTH

*>   A Finish Configuration with no registry packet before it decides nothing and keeps nothing open.
     MOVE PH-CONFIG TO CN-PHASE(WS-CONN)
     MOVE "contract/fixtures/wire/config-s2c-03-finish-configuration.hex" TO WS-PATH
     CALL "TEST-FEED" USING CLIENT-STATE WS-CONN WS-PATH
     MOVE "wt16 Finish Configuration with no Registry Data decides no type and opens no set" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE CT-OPEN TO WS-E1
     MOVE CL-WORLD-TYPE TO WS-E3
     MOVE SPACES TO TL-OBSERVED
     STRING "open " WS-E1 " world " WS-E3 DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "open 0 world 0" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Finish Configuration after Update Tags alone (no dimension_type came): no type is decided, the set closes.
     MOVE PH-CONFIG TO CN-PHASE(WS-CONN)
     MOVE 0 TO CN-MEMORY(WS-CONN)
     MOVE "contract/fixtures/wire/config-s2c-0e-update-tags-standard.hex" TO WS-PATH
     CALL "TEST-FEED" USING CLIENT-STATE WS-CONN WS-PATH
     MOVE "contract/fixtures/wire/config-s2c-03-finish-configuration.hex" TO WS-PATH
     CALL "TEST-FEED" USING CLIENT-STATE WS-CONN WS-PATH
     MOVE "wt16 a set with no dimension_type at Finish Configuration decides nothing and is closed" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE CT-OPEN TO WS-E1
     MOVE CL-WORLD-TYPE TO WS-E3
     MOVE CL-SET-OWNED TO WS-E2
     MOVE SPACES TO TL-OBSERVED
     STRING "open " WS-E1 " world " WS-E3 " owned " WS-E2 DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "open 0 world 0 owned 0" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   A memory connection (the hosted world): the set is the core's and is not touched.
     MOVE 1 TO CN-MEMORY(WS-CONN)
     MOVE PH-CONFIG TO CN-PHASE(WS-CONN)
     MOVE "contract/fixtures/wire/config-s2c-07-registry-data-dimension-type-standard.hex" TO WS-PATH
     CALL "TEST-FEED" USING CLIENT-STATE WS-CONN WS-PATH
     MOVE "contract/fixtures/wire/config-s2c-03-finish-configuration.hex" TO WS-PATH
     CALL "TEST-FEED" USING CLIENT-STATE WS-CONN WS-PATH
     MOVE "wt16 on a memory connection the client builds no content set of its own" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 0 TO TL-EXPECTED-N
     MOVE CT-OPEN TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM TEST-WT16.
 COPY CLTEST.
