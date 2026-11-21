*> Helper of the creaking heart runner tests (lane p49x; COPY after the test program, touch the test after changing it).
*>   HT5-SCAN USING connection id, scan record: drains the connection and counts what the heart sent: the trail particles (Level Particles 0x30, type 59: target, colour, duration) and the sounds
*>     (Sound 0x77). The record holds the creaking's position and the heart cell (inputs) and the counts (outputs): SC-TRAILS all trails; SC-NORMAL-OK those of colour 6250335 that start inside the
*>     creaking's box (0.9 x 2.7) and aim into the heart cell; SC-REVERSE-OK those of colour 16545810 that start in the heart cell and aim into the box; both with a duration of 10 to 49; SC-OTHER the
*>     trails that are neither; SC-SOUNDS the Sound packets.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. HT5-SCAN.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY PROTO.
 COPY PROTO REPLACING LEADING ==PB-== BY ==PK-==.
 01 WS-CAPACITY            BINARY-LONG VALUE 65536.
 01 WS-CLOSE               BINARY-LONG.
 01 WS-THRESHOLD           BINARY-LONG VALUE -1.
 01 WS-PACKET-ID           BINARY-LONG.
 01 WS-OUTCOME             BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-TX                  FLOAT-LONG.
 01 WS-TY                  FLOAT-LONG.
 01 WS-TZ                  FLOAT-LONG.
 01 WS-COLOUR              BINARY-LONG.
 01 WS-DURATION            BINARY-LONG.
 01 WS-FLAG                BINARY-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-START-IN-BOX        BINARY-LONG.
 01 WS-START-IN-HEART      BINARY-LONG.
 01 WS-TARGET-IN-BOX       BINARY-LONG.
 01 WS-TARGET-IN-HEART     BINARY-LONG.
 01 WS-HX                  FLOAT-LONG.
 01 WS-HY                  FLOAT-LONG.
 01 WS-HZ                  FLOAT-LONG.
 LINKAGE SECTION.
 01 L-ID                   BINARY-LONG.
 01 L-SCAN.
    05 SC-TRAILS           BINARY-LONG.
    05 SC-NORMAL-OK        BINARY-LONG.
    05 SC-REVERSE-OK       BINARY-LONG.
    05 SC-OTHER            BINARY-LONG.
    05 SC-SOUNDS           BINARY-LONG.
    05 SC-CX               FLOAT-LONG.
    05 SC-CY               FLOAT-LONG.
    05 SC-CZ               FLOAT-LONG.
    05 SC-HX               BINARY-LONG.
    05 SC-HY               BINARY-LONG.
    05 SC-HZ               BINARY-LONG.
 PROCEDURE DIVISION USING L-ID L-SCAN.
     MOVE 0 TO SC-TRAILS SC-NORMAL-OK SC-REVERSE-OK SC-OTHER SC-SOUNDS
     MOVE SC-HX TO WS-HX
     MOVE SC-HY TO WS-HY
     MOVE SC-HZ TO WS-HZ
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "PB-INIT" USING PK-BUFFER WS-CAPACITY
     CALL "TEST-DRAIN" USING L-ID PB-BUFFER WS-CLOSE
     MOVE 0 TO WS-OUTCOME
     PERFORM UNTIL WS-OUTCOME NOT = 0
         CALL "TEST-NEXT-PACKET" USING PB-BUFFER PK-BUFFER WS-THRESHOLD WS-PACKET-ID WS-OUTCOME
         IF WS-OUTCOME = 0 AND WS-PACKET-ID = 119
             ADD 1 TO SC-SOUNDS
         END-IF
         IF WS-OUTCOME = 0 AND WS-PACKET-ID = 48
             CALL "PB-GET-VARINT" USING PK-BUFFER WS-TYPE
             IF WS-TYPE = 59
                 ADD 1 TO SC-TRAILS
                 CALL "PB-GET-DOUBLE" USING PK-BUFFER WS-TX
                 CALL "PB-GET-DOUBLE" USING PK-BUFFER WS-TY
                 CALL "PB-GET-DOUBLE" USING PK-BUFFER WS-TZ
                 CALL "PB-GET-INT" USING PK-BUFFER WS-COLOUR
                 CALL "PB-GET-VARINT" USING PK-BUFFER WS-DURATION
                 CALL "PB-GET-BOOL" USING PK-BUFFER WS-FLAG
                 CALL "PB-GET-BOOL" USING PK-BUFFER WS-FLAG
                 CALL "PB-GET-DOUBLE" USING PK-BUFFER WS-X
                 CALL "PB-GET-DOUBLE" USING PK-BUFFER WS-Y
                 CALL "PB-GET-DOUBLE" USING PK-BUFFER WS-Z
                 MOVE 0 TO WS-START-IN-BOX WS-START-IN-HEART WS-TARGET-IN-BOX WS-TARGET-IN-HEART
                 IF WS-X >= SC-CX - 0.45 AND WS-X <= SC-CX + 0.45 AND WS-Y >= SC-CY AND WS-Y <= SC-CY + 2.7
                         AND WS-Z >= SC-CZ - 0.45 AND WS-Z <= SC-CZ + 0.45
                     MOVE 1 TO WS-START-IN-BOX
                 END-IF
                 IF WS-X >= WS-HX AND WS-X <= WS-HX + 1 AND WS-Y >= WS-HY AND WS-Y <= WS-HY + 1 AND WS-Z >= WS-HZ AND WS-Z <= WS-HZ + 1
                     MOVE 1 TO WS-START-IN-HEART
                 END-IF
                 IF WS-TX >= SC-CX - 0.45 AND WS-TX <= SC-CX + 0.45 AND WS-TY >= SC-CY AND WS-TY <= SC-CY + 2.7
                         AND WS-TZ >= SC-CZ - 0.45 AND WS-TZ <= SC-CZ + 0.45
                     MOVE 1 TO WS-TARGET-IN-BOX
                 END-IF
                 IF WS-TX >= WS-HX AND WS-TX <= WS-HX + 1 AND WS-TY >= WS-HY AND WS-TY <= WS-HY + 1 AND WS-TZ >= WS-HZ AND WS-TZ <= WS-HZ + 1
                     MOVE 1 TO WS-TARGET-IN-HEART
                 END-IF
                 EVALUATE TRUE
                     WHEN WS-COLOUR = 6250335 AND WS-START-IN-BOX = 1 AND WS-TARGET-IN-HEART = 1 AND WS-DURATION >= 10 AND WS-DURATION <= 49
                         ADD 1 TO SC-NORMAL-OK
                     WHEN WS-COLOUR = 16545810 AND WS-START-IN-HEART = 1 AND WS-TARGET-IN-BOX = 1 AND WS-DURATION >= 10 AND WS-DURATION <= 49
                         ADD 1 TO SC-REVERSE-OK
                     WHEN OTHER
                         ADD 1 TO SC-OTHER
                 END-EVALUATE
             END-IF
         END-IF
     END-PERFORM
     CALL "PB-FREE" USING PB-BUFFER
     CALL "PB-FREE" USING PK-BUFFER
     GOBACK.
 END PROGRAM HT5-SCAN.
