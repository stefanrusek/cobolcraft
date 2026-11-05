*> Implementation test of the offline UUID (02 Offline mode; 09 §1; research R11):
*> UUID.nameUUIDFromBytes("OfflinePlayer:" + name), MD5 with the version-3 and variant bits.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-LOGIN.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 01 WS-NAME                PIC X(16).
 01 WS-LENGTH              BINARY-LONG.
 01 WS-UUID                PIC X(16).
 01 WS-SIXTEEN             BINARY-LONG VALUE 16.
 01 WS-HEX                 PIC X(1024).
 01 WS-AREA                PIC X(512).
 PROCEDURE DIVISION.
     MOVE "Notch" TO WS-NAME
     MOVE 5 TO WS-LENGTH
     MOVE "test login offline UUID of Notch is b50ad385-829d-3141-a216-7e7d7539ba7f" TO TL-CASE
     MOVE "b50ad385829d3141a2167e7d7539ba7f" TO TL-EXPECTED
     PERFORM CHECK-UUID
     MOVE "Alice" TO WS-NAME
     MOVE "test login offline UUID of Alice equals the profile id of login-c2s-00-hello "
         & "(10920508-d5d8-3eed-93d2-92f193afe7d7)" TO TL-CASE
     MOVE "10920508d5d83eed93d292f193afe7d7" TO TL-EXPECTED
     PERFORM CHECK-UUID
     STOP RUN.

 CHECK-UUID.
     CALL "LOGIN-OFFLINE-UUID" USING WS-NAME WS-LENGTH WS-UUID
     MOVE WS-UUID TO WS-AREA
     CALL "TEST-HEX-OF" USING WS-AREA WS-SIXTEEN WS-HEX
     MOVE "T" TO TL-MODE
     MOVE WS-HEX(1:32) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-LOGIN.

 COPY CORETEST.
