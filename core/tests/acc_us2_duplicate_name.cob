*> Acceptance test, US2 edge case "same name logs in twice" (spec US2; 02 Login sequence; 09 §3.1;
*> standin §17): a player is online (in play) when a second connection logs in with the same name.
*> The earlier connection gets Disconnect cobolcraft.disconnect.replaced and is closed, its player
*> leaves, and the new connection logs in and joins under that name.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-US2-DUPLICATE-NAME.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY COREAPI.
 COPY TESTLIB.
 COPY PROTO REPLACING LEADING ==PB-== BY ==ST-==.
 COPY PROTO REPLACING LEADING ==PB-== BY ==PK-==.
 01 WS-CAPACITY            BINARY-LONG VALUE 256.
 01 WS-PATH                PIC X(256).
 01 WS-KIND                BINARY-LONG.
 01 WS-CONN                BINARY-LONG.
 01 WS-FIRST               BINARY-LONG.
 01 WS-SECOND              BINARY-LONG.
 01 WS-CLOSE               BINARY-LONG.
 01 WS-FIRST-CLOSE         BINARY-LONG.
 01 WS-THRESHOLD           BINARY-LONG VALUE -1.
 01 WS-PACKET-ID           BINARY-LONG.
 01 WS-OUTCOME             BINARY-LONG.
 01 WS-ONLINE-BEFORE       BINARY-LONG.
 01 WS-ONLINE-AFTER        BINARY-LONG.
 01 WS-REPLACED            PIC X(3).
 01 WS-FINISHED            PIC X(3).
 01 WS-ON-SECOND           PIC X(3).
 01 WS-NAME                PIC X(16) VALUE "Alice".
 01 WS-NAME-LENGTH         BINARY-LONG VALUE 5.
 01 WS-ROW                 BINARY-LONG.
 01 WS-EDIT                PIC -(9)9.
 01 WS-EDIT2               PIC -(9)9.
 01 WS-EDIT3               PIC -(9)9.
 PROCEDURE DIVISION.
     CALL "PB-INIT" USING ST-BUFFER WS-CAPACITY
     CALL "PB-INIT" USING PK-BUFFER WS-CAPACITY
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     MOVE CORE-CONN-MEMORY TO WS-KIND

*>   Given a player online: Alice logs in and completes configuration (the client's packets of
*>   01 §7.3 and 03 Configuration sequence).
     CALL "CORE-CONN-OPEN" USING WS-KIND WS-FIRST
     MOVE WS-FIRST TO WS-CONN
     PERFORM LOGIN-AND-CONFIGURE
     CALL "PLAYERS-ONLINE" USING WS-ONLINE-BEFORE
     CALL "PB-RESET" USING ST-BUFFER
     CALL "TEST-DRAIN" USING WS-FIRST ST-BUFFER WS-CLOSE

*>   When a second login uses the same name.
     CALL "CORE-CONN-OPEN" USING WS-KIND WS-SECOND
     MOVE WS-SECOND TO WS-CONN
     MOVE "contract/fixtures/wire/handshake-c2s-00-intention-login.hex" TO WS-PATH
     CALL "TEST-FEED" USING WS-CONN WS-PATH
     MOVE "contract/fixtures/wire/login-c2s-00-hello.hex" TO WS-PATH
     CALL "TEST-FEED" USING WS-CONN WS-PATH

*>   Then the first connection gets the replaced Disconnect and is closed.
     CALL "PB-RESET" USING ST-BUFFER
     MOVE CN-CLOSE(WS-FIRST) TO WS-FIRST-CLOSE
     CALL "TEST-DRAIN" USING WS-FIRST ST-BUFFER WS-CLOSE
     CALL "PB-RESET" USING PK-BUFFER
     CALL "TEST-NEXT-PACKET" USING ST-BUFFER PK-BUFFER WS-THRESHOLD WS-PACKET-ID WS-OUTCOME
     MOVE "contract/fixtures/wire/play-s2c-20-disconnect-duplicate-login.hex" TO WS-PATH
     CALL "DUP-SAME-AS" USING WS-OUTCOME PK-BUFFER WS-PATH WS-REPLACED

*>   And the new one logs in (Login Finished for Alice) and joins.
     CALL "PB-RESET" USING ST-BUFFER
     CALL "TEST-DRAIN" USING WS-SECOND ST-BUFFER WS-CLOSE
     CALL "PB-RESET" USING PK-BUFFER
     CALL "TEST-NEXT-PACKET" USING ST-BUFFER PK-BUFFER WS-THRESHOLD WS-PACKET-ID WS-OUTCOME
     MOVE "contract/fixtures/wire/login-s2c-02-login-finished.hex" TO WS-PATH
     CALL "DUP-SAME-AS" USING WS-OUTCOME PK-BUFFER WS-PATH WS-FINISHED
     MOVE "contract/fixtures/wire/login-c2s-03-login-acknowledged.hex" TO WS-PATH
     CALL "TEST-FEED" USING WS-CONN WS-PATH
     PERFORM CONFIGURE
     CALL "PLAYERS-ONLINE" USING WS-ONLINE-AFTER
     CALL "PLAYER-FIND-NAME" USING WS-NAME WS-NAME-LENGTH WS-ROW
     MOVE "no" TO WS-ON-SECOND
     IF WS-ROW > 0
         IF PL-CONN(WS-ROW) = WS-SECOND AND CN-PHASE(WS-SECOND) = PH-PLAY
             MOVE "yes" TO WS-ON-SECOND
         END-IF
     END-IF

     MOVE "acceptance US2 edge given a player online when a second login uses the same name then "
         & "the first connection is disconnected and the new one joins" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "online 1; first: replaced disconnect yes, closed 1; second: login finished yes, "
         & "online 1, Alice in play on second yes" TO TL-EXPECTED
     MOVE WS-ONLINE-BEFORE TO WS-EDIT
     MOVE WS-FIRST-CLOSE TO WS-EDIT2
     MOVE WS-ONLINE-AFTER TO WS-EDIT3
     MOVE SPACES TO TL-OBSERVED
     STRING "online " FUNCTION TRIM(WS-EDIT) "; first: replaced disconnect "
         FUNCTION TRIM(WS-REPLACED) ", closed " FUNCTION TRIM(WS-EDIT2)
         "; second: login finished " FUNCTION TRIM(WS-FINISHED) ", online "
         FUNCTION TRIM(WS-EDIT3) ", Alice in play on second " FUNCTION TRIM(WS-ON-SECOND)
         DELIMITED BY SIZE INTO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.

 LOGIN-AND-CONFIGURE.
     MOVE "contract/fixtures/wire/handshake-c2s-00-intention-login.hex" TO WS-PATH
     CALL "TEST-FEED" USING WS-CONN WS-PATH
     MOVE "contract/fixtures/wire/login-c2s-00-hello.hex" TO WS-PATH
     CALL "TEST-FEED" USING WS-CONN WS-PATH
     MOVE "contract/fixtures/wire/login-c2s-03-login-acknowledged.hex" TO WS-PATH
     CALL "TEST-FEED" USING WS-CONN WS-PATH
     PERFORM CONFIGURE.

 CONFIGURE.
     MOVE "contract/fixtures/wire/config-c2s-02-custom-payload-brand.hex" TO WS-PATH
     CALL "TEST-FEED" USING WS-CONN WS-PATH
     MOVE "contract/fixtures/wire/config-c2s-00-client-information.hex" TO WS-PATH
     CALL "TEST-FEED" USING WS-CONN WS-PATH
     MOVE "contract/fixtures/wire/config-c2s-07-select-known-packs.hex" TO WS-PATH
     CALL "TEST-FEED" USING WS-CONN WS-PATH
     MOVE "contract/fixtures/wire/config-c2s-03-finish-configuration.hex" TO WS-PATH
     CALL "TEST-FEED" USING WS-CONN WS-PATH.
 END PROGRAM ACC-US2-DUPLICATE-NAME.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. DUP-SAME-AS.
*> USING outcome of TEST-NEXT-PACKET, packet PB-BUFFER, fixture path, result out ("yes" when a
*> packet was read and its bytes equal the fixture's, else "no").
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY PROTO REPLACING LEADING ==PB-== BY ==FX-==.
 01 WS-CAPACITY            BINARY-LONG VALUE 256.
 01 B-GOT                  PIC X(1073741824) BASED.
 01 B-WANT                 PIC X(1073741824) BASED.
 LINKAGE SECTION.
 COPY PROTO.
 01 L-OUTCOME              BINARY-LONG.
 01 L-PATH                 PIC X(256).
 01 L-RESULT               PIC X(3).
 PROCEDURE DIVISION USING L-OUTCOME PB-BUFFER L-PATH L-RESULT.
     MOVE "no" TO L-RESULT
     CALL "PB-INIT" USING FX-BUFFER WS-CAPACITY
     CALL "TEST-LOAD-HEX" USING L-PATH FX-BUFFER
     IF L-OUTCOME = 0 AND PB-LENGTH = FX-LENGTH
         SET ADDRESS OF B-GOT TO PB-ADDR
         SET ADDRESS OF B-WANT TO FX-ADDR
         IF B-GOT(1:PB-LENGTH) = B-WANT(1:FX-LENGTH)
             MOVE "yes" TO L-RESULT
         END-IF
     END-IF
     CALL "PB-FREE" USING FX-BUFFER
     GOBACK.
 END PROGRAM DUP-SAME-AS.

 COPY CORETEST.
