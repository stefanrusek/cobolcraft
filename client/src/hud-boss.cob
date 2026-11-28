*> The boss bars (docs/protocol/57-client-closures-5 section 4, task T47420): BOSS-READ handles the Boss Event packet (05a 0x09 = 9: the UUID, the operation as a VarInt, then ADD
*> (title, progress Float, colour VarInt, overlay VarInt, flags UByte), REMOVE, UPDATE_PROGRESS, UPDATE_NAME, UPDATE_STYLE or UPDATE_PROPERTIES) into HX-BB in insertion order
*> (an added UUID that is already there is replaced in its place; at most 32). Progress glides over 100 ms of real time (BOSS-DISPLAYED); an update of a bar that was never
*> added is a protocol error (the client disconnects with "Network Protocol Error"). BOSS-TICK ramps the darkening factor (4.4); BOSS-HUD-ADD builds the widgets (4.3);
*> BOSS-MUSIC says whether the boss track is wanted. Not built: the use of the darkening factor and of the fog flag by the light map and the fog (12 section 1.8 and 3.3: the
*> state is kept in HX-BB-DARK and the flags of HX-BB-FLAGS), and the music (the client has no music player).

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BOSS-DISPLAYED.
*> USING CLIENT-STATE, bar row (1 to HX-BB-COUNT), progress out (FLOAT-LONG): lerp(clamp((now - the time of the last UPDATE_PROGRESS) / 100 ms, 0, 1), the progress it
*> started from, the target); the target is not clamped to 0 to 1.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-T                   FLOAT-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-ROW                  BINARY-LONG.
 01 L-PROGRESS             FLOAT-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-ROW L-PROGRESS.
     COMPUTE WS-T = (CL-NOW-MS - HX-BB-SET-MS(L-ROW)) / 100
     IF WS-T < 0
         MOVE 0 TO WS-T
     END-IF
     IF WS-T > 1
         MOVE 1 TO WS-T
     END-IF
     COMPUTE L-PROGRESS = HX-BB-START(L-ROW) + WS-T * (HX-BB-TARGET(L-ROW) - HX-BB-START(L-ROW))
     GOBACK.
 END PROGRAM BOSS-DISPLAYED.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BOSS-READ.
*> USING CLIENT-STATE, PB-BUFFER: Boss Event (57-5 sections 4.1 and 4.2).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY PROTO REPLACING LEADING ==PB-== BY ==TX-==.
 01 WS-UUID                PIC X(16).
 01 WS-OP                  BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-TEXT                PIC X(512).
 01 WS-LENGTH              BINARY-LONG.
 01 WS-FLOAT               FLOAT-SHORT.
 01 WS-PROGRESS            FLOAT-LONG.
 01 WS-COLOUR              BINARY-LONG.
 01 WS-OVERLAY             BINARY-LONG.
 01 WS-FLAGS               BINARY-LONG.
 01 WS-CONN                BINARY-LONG VALUE 1.
 01 WS-KEY                 PIC X(80) VALUE "disconnect.packetError".
 01 WS-KEY-LENGTH          BINARY-LONG VALUE 22.
 01 WS-EMPTY               PIC X(256) VALUE SPACES.
 01 WS-EMPTY2              PIC X(256) VALUE SPACES.
 01 WS-EMPTY3              PIC X(256) VALUE SPACES.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-ZERO2               BINARY-LONG VALUE 0.
 01 WS-ZERO3               BINARY-LONG VALUE 0.
 01 WS-MSG                 PIC X(512).
 01 WS-MSG-LENGTH          BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 COPY PROTO.
 PROCEDURE DIVISION USING CLIENT-STATE PB-BUFFER.
     CALL "PB-GET-UUID" USING PB-BUFFER WS-UUID
     CALL "PB-GET-VARINT" USING PB-BUFFER WS-OP
     IF PB-ERROR = 1
         GOBACK
     END-IF
     MOVE 0 TO WS-ROW
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > HX-BB-COUNT OR WS-ROW > 0
         IF HX-BB-UUID(WS-I) = WS-UUID
             MOVE WS-I TO WS-ROW
         END-IF
     END-PERFORM
     IF WS-OP NOT = 0 AND WS-OP < 6 AND WS-ROW = 0
*>       No null check in the vanilla handler: the lookup fails and the packet ends the connection.
         CALL "CHAT-TR" USING CLIENT-STATE WS-KEY WS-KEY-LENGTH WS-EMPTY WS-ZERO WS-EMPTY2 WS-ZERO2 WS-EMPTY3 WS-ZERO3 WS-MSG WS-MSG-LENGTH
         CALL "CLIENT-DISCONNECT" USING CLIENT-STATE WS-CONN WS-MSG WS-MSG-LENGTH
         GOBACK
     END-IF
     EVALUATE WS-OP
         WHEN 0
             CALL "PB-GET-TEXT" USING PB-BUFFER TX-TEXT
             CALL "PB-GET-FLOAT" USING PB-BUFFER WS-FLOAT
             CALL "PB-GET-VARINT" USING PB-BUFFER WS-COLOUR
             CALL "PB-GET-VARINT" USING PB-BUFFER WS-OVERLAY
             CALL "PB-GET-UBYTE" USING PB-BUFFER WS-FLAGS
             IF PB-ERROR = 1
                 GOBACK
             END-IF
             IF WS-ROW = 0 AND HX-BB-COUNT < 32
                 ADD 1 TO HX-BB-COUNT
                 MOVE HX-BB-COUNT TO WS-ROW
             END-IF
             IF WS-ROW > 0
                 CALL "TEXT-RENDER" USING CLIENT-STATE TX-TEXT WS-TEXT WS-LENGTH
                 MOVE WS-UUID TO HX-BB-UUID(WS-ROW)
                 MOVE WS-TEXT(1:256) TO HX-BB-TITLE(WS-ROW)
                 MOVE FUNCTION MIN(WS-LENGTH, 256) TO HX-BB-LENGTH(WS-ROW)
                 MOVE WS-FLOAT TO WS-PROGRESS
                 MOVE WS-PROGRESS TO HX-BB-START(WS-ROW) HX-BB-TARGET(WS-ROW)
                 MOVE CL-NOW-MS TO HX-BB-SET-MS(WS-ROW)
                 MOVE WS-COLOUR TO HX-BB-COLOUR(WS-ROW)
                 MOVE WS-OVERLAY TO HX-BB-OVERLAY(WS-ROW)
                 MOVE WS-FLAGS TO HX-BB-FLAGS(WS-ROW)
             END-IF
         WHEN 1
             IF WS-ROW > 0
                 PERFORM VARYING WS-I FROM WS-ROW BY 1 UNTIL WS-I >= HX-BB-COUNT
                     MOVE HX-BB(WS-I + 1) TO HX-BB(WS-I)
                 END-PERFORM
                 INITIALIZE HX-BB(HX-BB-COUNT)
                 SUBTRACT 1 FROM HX-BB-COUNT
             END-IF
         WHEN 2
             CALL "PB-GET-FLOAT" USING PB-BUFFER WS-FLOAT
             IF PB-ERROR = 0
                 CALL "BOSS-DISPLAYED" USING CLIENT-STATE WS-ROW WS-PROGRESS
                 MOVE WS-PROGRESS TO HX-BB-START(WS-ROW)
                 MOVE WS-FLOAT TO HX-BB-TARGET(WS-ROW)
                 MOVE CL-NOW-MS TO HX-BB-SET-MS(WS-ROW)
             END-IF
         WHEN 3
             CALL "PB-GET-TEXT" USING PB-BUFFER TX-TEXT
             IF PB-ERROR = 0
                 CALL "TEXT-RENDER" USING CLIENT-STATE TX-TEXT WS-TEXT WS-LENGTH
                 MOVE WS-TEXT(1:256) TO HX-BB-TITLE(WS-ROW)
                 MOVE FUNCTION MIN(WS-LENGTH, 256) TO HX-BB-LENGTH(WS-ROW)
             END-IF
         WHEN 4
             CALL "PB-GET-VARINT" USING PB-BUFFER WS-COLOUR
             CALL "PB-GET-VARINT" USING PB-BUFFER WS-OVERLAY
             IF PB-ERROR = 0
                 MOVE WS-COLOUR TO HX-BB-COLOUR(WS-ROW)
                 MOVE WS-OVERLAY TO HX-BB-OVERLAY(WS-ROW)
             END-IF
         WHEN 5
             CALL "PB-GET-UBYTE" USING PB-BUFFER WS-FLAGS
             IF PB-ERROR = 0
                 MOVE WS-FLAGS TO HX-BB-FLAGS(WS-ROW)
             END-IF
         WHEN OTHER
             CONTINUE
     END-EVALUATE
     GOBACK.
 END PROGRAM BOSS-READ.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BOSS-TICK.
*> USING CLIENT-STATE: one client tick of the darkening factor (57-5 section 4.4): the previous value is kept; with a bar that has the darken flag (bit 0) the value rises by 0.05
*> to 1, else, while it is above 0, it falls by 0.0125 (no lower limit: a residue above 0 takes one step below it, open question 7).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-I                   BINARY-LONG.
 01 WS-ANY                 BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 PROCEDURE DIVISION USING CLIENT-STATE.
     MOVE HX-BB-DARK TO HX-BB-DARK-O
     MOVE 0 TO WS-ANY
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > HX-BB-COUNT
         IF FUNCTION MOD(HX-BB-FLAGS(WS-I), 2) = 1
             MOVE 1 TO WS-ANY
         END-IF
     END-PERFORM
     IF WS-ANY = 1
         COMPUTE HX-BB-DARK = FUNCTION MIN(1, HX-BB-DARK + 0.05)
     ELSE
         IF HX-BB-DARK > 0
             COMPUTE HX-BB-DARK = HX-BB-DARK - 0.0125
         END-IF
     END-IF
     GOBACK.
 END PROGRAM BOSS-TICK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BOSS-MUSIC.
*> USING CLIENT-STATE, flag out: 1 when Minecraft.getSituationalMusic would choose the boss track (57-5 section 4.4): the local player is in the End and a bar has the music flag
*> (bit 1).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-I                   BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-FLAG                 BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-FLAG.
     MOVE 0 TO L-FLAG
     IF PL-DIM-NAME = "minecraft:the_end"
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > HX-BB-COUNT
             IF FUNCTION MOD(FUNCTION INTEGER(HX-BB-FLAGS(WS-I) / 2), 2) = 1
                 MOVE 1 TO L-FLAG
             END-IF
         END-PERFORM
     END-IF
     GOBACK.
 END PROGRAM BOSS-MUSIC.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BOSS-HUD-ADD.
*> USING CLIENT-STATE, GUI width, GUI height: BossHealthOverlay.extractRenderState (57-5 section 4.3). In map order, from y = 12, 19 pixels lower for each next bar: the bar left at
*> W / 2 - 91, 182 x 5: the colour background sprite, the overlay background over it when the overlay is not 0 (progress), the progress sprites cropped to w = floor(progress x 181) +
*> (1 when progress > 0) columns (w > 0 only), then the title in white with the shadow at x = W / 2 - width / 2 (integer), y = bar top - 9. The first bar is always drawn; drawing
*> stops once y reaches floor(H / 3) after a bar, so the count is max(1, ceil((floor(H / 3) - 12) / 19)).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLCONST.
 01 WS-I                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-LIMIT               BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-PROGRESS            FLOAT-LONG.
 01 WS-FILL                BINARY-LONG.
 01 WS-COLOUR              BINARY-LONG.
 01 WS-OVERLAY             BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-W                   BINARY-LONG.
 01 WS-H                   BINARY-LONG.
 01 WS-WIDTH               BINARY-LONG.
 01 WS-HALF                BINARY-LONG.
 01 WS-KIND                BINARY-LONG.
 01 WS-ACTION              BINARY-LONG VALUE 0.
 01 WS-Z                   BINARY-LONG VALUE 0.
 01 WS-Z2                  BINARY-LONG VALUE 0.
 01 WS-TEXT                PIC X(512).
 01 WS-TEXT256             PIC X(256).
 01 WS-LENGTH              BINARY-LONG.
 01 WS-EMPTY               PIC X(512) VALUE SPACES.
 01 WS-WHITE               BINARY-LONG VALUE 16777215.
 01 WS-ALPHA               BINARY-LONG VALUE 255.
 01 WS-TITLE-Y             BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-GW                   BINARY-LONG.
 01 L-GH                   BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-GW L-GH.
     IF HX-BB-COUNT = 0
         GOBACK
     END-IF
     MOVE 12 TO WS-Y
     COMPUTE WS-LIMIT = L-GH / 3
     COMPUTE WS-X = L-GW / 2 - 91
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > HX-BB-COUNT OR (WS-I > 1 AND WS-Y >= WS-LIMIT)
         CALL "BOSS-DISPLAYED" USING CLIENT-STATE WS-I WS-PROGRESS
         MOVE HX-BB-COLOUR(WS-I) TO WS-COLOUR
         IF WS-COLOUR < 0 OR WS-COLOUR > 6
             MOVE 0 TO WS-COLOUR
         END-IF
         MOVE HX-BB-OVERLAY(WS-I) TO WS-OVERLAY
         MOVE 182 TO WS-W
         MOVE 5 TO WS-H
         MOVE WK-SPRITE TO WS-KIND
         COMPUTE WS-ROW = GSP-BOSS-BG-0 + WS-COLOUR
         CALL "WIDGET-ADD" USING CLIENT-STATE WS-KIND WS-ACTION WS-ROW WS-X WS-Y WS-W WS-H WS-EMPTY WS-Z WS-Z2
         IF WS-OVERLAY >= 1 AND WS-OVERLAY <= 4
             COMPUTE WS-ROW = GSP-BOSS-NOTCH-BG-0 + WS-OVERLAY - 1
             CALL "WIDGET-ADD" USING CLIENT-STATE WS-KIND WS-ACTION WS-ROW WS-X WS-Y WS-W WS-H WS-EMPTY WS-Z WS-Z2
         END-IF
         COMPUTE WS-FILL = FUNCTION INTEGER(WS-PROGRESS * 181)
         IF WS-PROGRESS > 0
             ADD 1 TO WS-FILL
         END-IF
         IF WS-FILL > 0
             MOVE WK-CLIP TO WS-KIND
             MOVE WS-FILL TO WS-W
             COMPUTE WS-ROW = GSP-BOSS-PROGRESS-0 + WS-COLOUR
             CALL "WIDGET-ADD" USING CLIENT-STATE WS-KIND WS-ACTION WS-ROW WS-X WS-Y WS-W WS-H WS-EMPTY WS-Z WS-Z2
             IF WS-OVERLAY >= 1 AND WS-OVERLAY <= 4
                 COMPUTE WS-ROW = GSP-BOSS-NOTCH-PROGRESS-0 + WS-OVERLAY - 1
                 CALL "WIDGET-ADD" USING CLIENT-STATE WS-KIND WS-ACTION WS-ROW WS-X WS-Y WS-W WS-H WS-EMPTY WS-Z WS-Z2
             END-IF
         END-IF
         MOVE SPACES TO WS-TEXT
         MOVE HX-BB-TITLE(WS-I) TO WS-TEXT
         MOVE HX-BB-LENGTH(WS-I) TO WS-LENGTH
         MOVE HX-BB-TITLE(WS-I) TO WS-TEXT256
         CALL "UI-TEXT-WIDTH" USING CLIENT-STATE WS-TEXT256 WS-LENGTH WS-WIDTH
         COMPUTE WS-HALF = WS-WIDTH / 2
         COMPUTE WS-ROW = L-GW / 2 - WS-HALF
         COMPUTE WS-TITLE-Y = WS-Y - 9
         MOVE WK-LABEL TO WS-KIND
         MOVE WS-WIDTH TO WS-W
         MOVE 9 TO WS-H
         CALL "WIDGET-ADD" USING CLIENT-STATE WS-KIND WS-ACTION WS-Z WS-ROW WS-TITLE-Y WS-W WS-H WS-TEXT WS-LENGTH WS-Z2
         CALL "WIDGET-COLOUR" USING CLIENT-STATE WS-WHITE
         CALL "WIDGET-ALPHA" USING CLIENT-STATE WS-ALPHA
         ADD 19 TO WS-Y
     END-PERFORM
     GOBACK.
 END PROGRAM BOSS-HUD-ADD.
