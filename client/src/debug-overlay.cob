*> The F3 debug overlay (US17; 13 §5; FR-018). F3 pressed toggles it (the release rule, the F3 + key combinations and the entry profile of
*> 13 §5.1 and 5.2 are not modelled: every entry listed below is on while the overlay is). DEBUG-OVERLAY-INPUT runs every frame: the toggle, and
*> the frame rate (frames counted over each second). DEBUG-OVERLAY-ADD adds the lines to the world screen as labels, 2 GUI pixels from the
*> edge, 9 pixels apart: on the left the game version, a blank line, then XYZ, Block, Chunk (with the region file), Facing, Section-relative and
*> Speed (13 §5.4 formulas); on the right, right-aligned, the frame rate, a blank line, Day, Client Light and the targeted block (its
*> position and state id; the registered name needs the block registry, which the client does not read here).

 IDENTIFICATION DIVISION.
 PROGRAM-ID. DEBUG-OVERLAY-INPUT.
*> USING CLIENT-STATE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CCSHIM.
 01 WS-ELAPSED             BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 PROCEDURE DIVISION USING CLIENT-STATE.
     IF IN-KEY-PRESSED(CC-KEY-F3 + 1) = 1
         COMPUTE CL-DEBUG = 1 - CL-DEBUG
     END-IF
     COMPUTE WS-ELAPSED = CL-NOW-MS - CL-FPS-AT
     IF WS-ELAPSED >= 1000
         COMPUTE CL-FPS = (CL-FRAMES - CL-FPS-FRAMES) * 1000 / WS-ELAPSED
         MOVE CL-FRAMES TO CL-FPS-FRAMES
         MOVE CL-NOW-MS TO CL-FPS-AT
     END-IF
     GOBACK.
 END PROGRAM DEBUG-OVERLAY-INPUT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. DEBUG-OVERLAY-ADD.
*> USING CLIENT-STATE, GUI width, GUI height: nothing unless the overlay is on.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLCONST.
 01 WS-LINES.
    05 WS-LEFT-LINE        PIC X(100) OCCURS 10 TIMES.
    05 WS-RIGHT-LINE       PIC X(100) OCCURS 10 TIMES.
 01 WS-LEFT-N              BINARY-LONG.
 01 WS-RIGHT-N             BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-KIND                BINARY-LONG VALUE WK-LABEL.
 01 WS-ACTION              BINARY-LONG VALUE ACT-NONE.
 01 WS-ARG                 BINARY-LONG VALUE 0.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-W                   BINARY-LONG VALUE 0.
 01 WS-H                   BINARY-LONG VALUE 9.
 01 WS-STATE               BINARY-LONG VALUE 0.
 01 WS-TEXT                PIC X(512).
 01 WS-LENGTH              BINARY-LONG.
 01 WS-WIDTH               BINARY-LONG.
 01 WS-BX                  BINARY-LONG.
 01 WS-BY                  BINARY-LONG.
 01 WS-BZ                  BINARY-LONG.
 01 WS-SX                  BINARY-LONG.
 01 WS-SY                  BINARY-LONG.
 01 WS-SZ                  BINARY-LONG.
 01 WS-RX                  BINARY-LONG.
 01 WS-RZ                  BINARY-LONG.
 01 WS-LX                  BINARY-LONG.
 01 WS-LZ                  BINARY-LONG.
 01 WS-REX                 BINARY-LONG.
 01 WS-REZ                 BINARY-LONG.
 01 WS-E1                  PIC -(7)9.999.
 01 WS-E2                  PIC -(7)9.99999.
 01 WS-E3                  PIC -(7)9.999.
 01 WS-E4                  PIC -(7)9.9.
 01 WS-E5                  PIC -(7)9.9.
 01 WS-I1                  PIC -(9)9.
 01 WS-I2                  PIC -(9)9.
 01 WS-I3                  PIC -(9)9.
 01 WS-I4                  PIC -(9)9.
 01 WS-I5                  PIC -(9)9.
 01 WS-I6                  PIC -(9)9.
 01 WS-S1                  PIC 99.
 01 WS-S2                  PIC 99.
 01 WS-S3                  PIC 99.
 01 WS-YAW                 FLOAT-LONG.
 01 WS-CARDINAL            PIC X(5).
 01 WS-TOWARDS             PIC X(20).
 01 WS-STATE-ID            BINARY-LONG.
 01 WS-SKY                 BINARY-LONG.
 01 WS-BLK                 BINARY-LONG.
 01 WS-DAY                 BINARY-LONG.
 01 WS-PTR                 BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-GW                   BINARY-LONG.
 01 L-GH                   BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-GW L-GH.
     IF CL-DEBUG = 1
         MOVE SPACES TO WS-LINES
         MOVE 0 TO WS-LEFT-N WS-RIGHT-N
         ADD 1 TO WS-LEFT-N
         MOVE "CobolCraft (Minecraft 26.3)" TO WS-LEFT-LINE(WS-LEFT-N)
         ADD 1 TO WS-LEFT-N
*>       Position group.
         COMPUTE WS-BX = FUNCTION INTEGER(PL-X)
         COMPUTE WS-BY = FUNCTION INTEGER(PL-Y)
         COMPUTE WS-BZ = FUNCTION INTEGER(PL-Z)
         COMPUTE WS-SX = FUNCTION INTEGER(WS-BX / 16)
         COMPUTE WS-SY = FUNCTION INTEGER((WS-BY - PL-MIN-Y) / 16)
         COMPUTE WS-SZ = FUNCTION INTEGER(WS-BZ / 16)
         COMPUTE WS-REX = FUNCTION INTEGER(WS-SX / 32)
         COMPUTE WS-REZ = FUNCTION INTEGER(WS-SZ / 32)
         COMPUTE WS-RX = WS-SX - WS-REX * 32
         COMPUTE WS-RZ = WS-SZ - WS-REZ * 32
         MOVE PL-X TO WS-E1
         MOVE PL-Y TO WS-E2
         MOVE PL-Z TO WS-E3
         ADD 1 TO WS-LEFT-N
         STRING "XYZ: " FUNCTION TRIM(WS-E1) " / " FUNCTION TRIM(WS-E2) " / " FUNCTION TRIM(WS-E3)
             DELIMITED BY SIZE INTO WS-LEFT-LINE(WS-LEFT-N)
         MOVE WS-BX TO WS-I1
         MOVE WS-BY TO WS-I2
         MOVE WS-BZ TO WS-I3
         ADD 1 TO WS-LEFT-N
         STRING "Block: " FUNCTION TRIM(WS-I1) " " FUNCTION TRIM(WS-I2) " " FUNCTION TRIM(WS-I3)
             DELIMITED BY SIZE INTO WS-LEFT-LINE(WS-LEFT-N)
         MOVE WS-SX TO WS-I1
         MOVE WS-SY TO WS-I2
         MOVE WS-SZ TO WS-I3
         MOVE WS-RX TO WS-I4
         MOVE WS-RZ TO WS-I5
         ADD 1 TO WS-LEFT-N
         MOVE 1 TO WS-PTR
         STRING "Chunk: " FUNCTION TRIM(WS-I1) " " FUNCTION TRIM(WS-I2) " " FUNCTION TRIM(WS-I3) " ["
             FUNCTION TRIM(WS-I4) " " FUNCTION TRIM(WS-I5) " in r." DELIMITED BY SIZE
             INTO WS-LEFT-LINE(WS-LEFT-N) WITH POINTER WS-PTR
         MOVE WS-REX TO WS-I1
         MOVE WS-REZ TO WS-I2
         STRING FUNCTION TRIM(WS-I1) "." FUNCTION TRIM(WS-I2) ".mca]" DELIMITED BY SIZE
             INTO WS-LEFT-LINE(WS-LEFT-N) WITH POINTER WS-PTR
*>       Facing: yaw 0 faces +Z (south), 90 -X (west), 180 -Z (north), 270 +X (east); the yaw shown is wrapped to -180 .. 180.
         COMPUTE WS-YAW = FUNCTION MOD(PL-YAW, 360)
         EVALUATE TRUE
             WHEN WS-YAW < 45 OR WS-YAW >= 315
                 MOVE "south" TO WS-CARDINAL
                 MOVE "Towards positive Z" TO WS-TOWARDS
             WHEN WS-YAW < 135
                 MOVE "west" TO WS-CARDINAL
                 MOVE "Towards negative X" TO WS-TOWARDS
             WHEN WS-YAW < 225
                 MOVE "north" TO WS-CARDINAL
                 MOVE "Towards negative Z" TO WS-TOWARDS
             WHEN OTHER
                 MOVE "east" TO WS-CARDINAL
                 MOVE "Towards positive X" TO WS-TOWARDS
         END-EVALUATE
         IF WS-YAW >= 180
             SUBTRACT 360 FROM WS-YAW
         END-IF
         MOVE WS-YAW TO WS-E4
         MOVE PL-PITCH TO WS-E5
         ADD 1 TO WS-LEFT-N
         STRING "Facing: " FUNCTION TRIM(WS-CARDINAL) " (" FUNCTION TRIM(WS-TOWARDS) ") ("
             FUNCTION TRIM(WS-E4) " / " FUNCTION TRIM(WS-E5) ")" DELIMITED BY SIZE
             INTO WS-LEFT-LINE(WS-LEFT-N)
         COMPUTE WS-LX = FUNCTION MOD(WS-BX, 16)
         COMPUTE WS-LZ = FUNCTION MOD(WS-BZ, 16)
         COMPUTE WS-S2 = FUNCTION MOD(WS-BY - PL-MIN-Y, 16)
         MOVE WS-LX TO WS-S1
         MOVE WS-LZ TO WS-S3
         ADD 1 TO WS-LEFT-N
         STRING "Section-relative: " WS-S1 " " WS-S2 " " WS-S3 DELIMITED BY SIZE INTO WS-LEFT-LINE(WS-LEFT-N)
         MOVE CL-SPEED TO WS-E1
         ADD 1 TO WS-LEFT-N
         STRING "Speed: " FUNCTION TRIM(WS-E1) " blocks/tick" DELIMITED BY SIZE INTO WS-LEFT-LINE(WS-LEFT-N)
*>       Right column.
         MOVE CL-FPS TO WS-I1
         ADD 1 TO WS-RIGHT-N
         STRING FUNCTION TRIM(WS-I1) " fps" DELIMITED BY SIZE INTO WS-RIGHT-LINE(WS-RIGHT-N)
         ADD 1 TO WS-RIGHT-N
         COMPUTE WS-DAY = FUNCTION INTEGER(PL-TIME / 24000)
         MOVE WS-DAY TO WS-I1
         ADD 1 TO WS-RIGHT-N
         STRING "Day #" FUNCTION TRIM(WS-I1) DELIMITED BY SIZE INTO WS-RIGHT-LINE(WS-RIGHT-N)
         CALL "WORLD-CELL" USING CLIENT-STATE WS-BX WS-BY WS-BZ WS-STATE-ID WS-SKY WS-BLK
         MOVE FUNCTION MAX(WS-SKY, WS-BLK) TO WS-I1
         MOVE WS-SKY TO WS-I2
         MOVE WS-BLK TO WS-I3
         ADD 1 TO WS-RIGHT-N
         STRING "Client Light: " FUNCTION TRIM(WS-I1) " (" FUNCTION TRIM(WS-I2) " sky, " FUNCTION TRIM(WS-I3)
             " block)" DELIMITED BY SIZE INTO WS-RIGHT-LINE(WS-RIGHT-N)
         IF TG-HIT = 1
             CALL "WORLD-CELL" USING CLIENT-STATE TG-X TG-Y TG-Z WS-STATE-ID WS-SKY WS-BLK
             MOVE TG-X TO WS-I1
             MOVE TG-Y TO WS-I2
             MOVE TG-Z TO WS-I3
             ADD 1 TO WS-RIGHT-N
             STRING "Targeted Block: " FUNCTION TRIM(WS-I1) ", " FUNCTION TRIM(WS-I2) ", " FUNCTION TRIM(WS-I3)
                 DELIMITED BY SIZE INTO WS-RIGHT-LINE(WS-RIGHT-N)
             MOVE WS-STATE-ID TO WS-I1
             ADD 1 TO WS-RIGHT-N
             STRING "Block state: " FUNCTION TRIM(WS-I1) DELIMITED BY SIZE INTO WS-RIGHT-LINE(WS-RIGHT-N)
         END-IF
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-LEFT-N
             IF WS-LEFT-LINE(WS-I) NOT = SPACES
                 MOVE SPACES TO WS-TEXT
                 MOVE WS-LEFT-LINE(WS-I) TO WS-TEXT
                 MOVE FUNCTION LENGTH(FUNCTION TRIM(WS-LEFT-LINE(WS-I) TRAILING)) TO WS-LENGTH
                 MOVE 2 TO WS-X
                 COMPUTE WS-Y = 2 + 9 * (WS-I - 1)
                 CALL "WIDGET-ADD" USING CLIENT-STATE WS-KIND WS-ACTION WS-ARG WS-X WS-Y WS-W WS-H WS-TEXT
                     WS-LENGTH WS-STATE
             END-IF
         END-PERFORM
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-RIGHT-N
             MOVE SPACES TO WS-TEXT
             MOVE WS-RIGHT-LINE(WS-I) TO WS-TEXT
             MOVE FUNCTION LENGTH(FUNCTION TRIM(WS-RIGHT-LINE(WS-I) TRAILING)) TO WS-LENGTH
             CALL "UI-TEXT-WIDTH" USING CLIENT-STATE WS-TEXT WS-LENGTH WS-WIDTH
             COMPUTE WS-X = L-GW - 2 - WS-WIDTH
             COMPUTE WS-Y = 2 + 9 * (WS-I - 1)
             CALL "WIDGET-ADD" USING CLIENT-STATE WS-KIND WS-ACTION WS-ARG WS-X WS-Y WS-W WS-H WS-TEXT
                 WS-LENGTH WS-STATE
         END-PERFORM
     END-IF
     GOBACK.
 END PROGRAM DEBUG-OVERLAY-ADD.
