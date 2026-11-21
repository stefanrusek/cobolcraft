*> Implementation test, lane bugsign (client/src/screens/signtext.cob, editblocks.cob BLOCK-ENTITY-DATA, world-replica.cob, signscreen.cob SIGN-OPEN; docs/protocol/31 part 3 sections 2.2, 2.10, 40 part 8 section 1.2):
*> the client keeps the text of signs. Block Entity Data of a sign (type 7) or hanging sign (8) is stored by position: four lines, colour, glow and is_waxed of each side (a second packet replaces the first, lines
*> that are not strings and an unknown colour leave the defaults, other types are not kept); a changed block drops the row, an unchanged state keeps it, a cleared world drops all; the sign entries of a Level
*> Chunk replace the rows of that chunk and leave the others; Open Sign Editor starts the editor from the text of the side it names (an out-of-range side is the back, a sign unknown to the client is empty).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-SIGN-TEXT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLSTATE.
 COPY CLCONST.
 COPY PROTO.
 COPY TESTLIB.
 01 WS-SERVER              BINARY-LONG.
 01 WS-CAPACITY            BINARY-LONG VALUE 4096.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-ROOT                BINARY-LONG VALUE -2.
 01 WS-ELEMENT             BINARY-LONG VALUE -1.
 01 WS-NO                  BINARY-LONG VALUE 0.
 01 WS-ROW                 BINARY-LONG.
 01 WS-ROW-A               BINARY-LONG.
 01 WS-SHAPE               BINARY-LONG.
 01 WS-GLOW                BINARY-LONG.
 01 WS-WAXED               BINARY-LONG.
 01 WS-COLOR               PIC X(16).
 01 WS-COLOR-LENGTH        BINARY-LONG.
 01 WS-TEXT-1              PIC X(80).
 01 WS-LEN-1               BINARY-LONG.
 01 WS-TEXT-2              PIC X(80).
 01 WS-LEN-2               BINARY-LONG.
 01 WS-TEXT-3              PIC X(80).
 01 WS-LEN-3               BINARY-LONG.
 01 WS-TEXT-4              PIC X(80).
 01 WS-LEN-4               BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-FOUR                BINARY-LONG VALUE 4.
 01 WS-T-STRING            BINARY-LONG VALUE 8.
 01 WS-T-COMPOUND          BINARY-LONG VALUE 10.
 01 WN                     PIC X(32).
 01 WL                     BINARY-LONG.
 01 WS-SIDE-PASS           BINARY-LONG.
 01 WS-FRONT-FLAG          BINARY-LONG.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-HEADS.
    05 WS-HEAD             BINARY-LONG OCCURS 2560 TIMES.
 01 WS-DATA                PIC X(262144).
 01 WS-REST                BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-E1                  PIC -(9)9.
 01 WS-E2                  PIC -(9)9.
 01 WS-E3                  PIC -(9)9.
 01 WS-E4                  PIC -(9)9.
 PROCEDURE DIVISION.
     CALL "TEST-PLAY" USING CLIENT-STATE WS-SERVER
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     MOVE "T" TO TL-MODE

*>   A sign: front Hello / empty / x / Bye, red, glowing, waxed; back B1 only.
     MOVE 5 TO WS-X
     MOVE 4 TO WS-Y
     MOVE 6 TO WS-Z
     MOVE 7 TO WS-TYPE
     MOVE 1 TO WS-SHAPE
     MOVE 1 TO WS-GLOW
     MOVE 1 TO WS-WAXED
     MOVE "red" TO WS-COLOR
     MOVE 3 TO WS-COLOR-LENGTH
     MOVE "Hello" TO WS-TEXT-1
     MOVE 5 TO WS-LEN-1
     MOVE SPACES TO WS-TEXT-2
     MOVE 0 TO WS-LEN-2
     MOVE "x" TO WS-TEXT-3
     MOVE 1 TO WS-LEN-3
     MOVE "Bye" TO WS-TEXT-4
     MOVE 3 TO WS-LEN-4
     PERFORM FEED-TAG
     CALL "SIGN-TEXT-FIND" USING CLIENT-STATE WS-X WS-Y WS-Z WS-NO WS-ROW-A
     MOVE "implementation sign text: Block Entity Data of a sign stores the front lines Hello, empty, x, Bye" TO TL-CASE
     MOVE "Hello||x|Bye" TO TL-EXPECTED
     MOVE SPACES TO TL-OBSERVED
     IF WS-ROW-A > 0
         STRING SN-TEXT(WS-ROW-A, 2, 1)(1:SN-LEN(WS-ROW-A, 2, 1)) "|" "|" SN-TEXT(WS-ROW-A, 2, 3)(1:1) "|"
             SN-TEXT(WS-ROW-A, 2, 4)(1:3) DELIMITED BY SIZE INTO TL-OBSERVED
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "implementation sign text: the front colour red (dye id 14), glowing, and the sign is waxed" TO TL-CASE
     MOVE "14 1 1" TO TL-EXPECTED
     MOVE SN-COLOR(WS-ROW-A, 2) TO WS-E1
     MOVE SN-GLOW(WS-ROW-A, 2) TO WS-E2
     MOVE SN-WAXED(WS-ROW-A) TO WS-E3
     MOVE SPACES TO TL-OBSERVED
     STRING FUNCTION TRIM(WS-E1) " " FUNCTION TRIM(WS-E2) " " FUNCTION TRIM(WS-E3) DELIMITED BY SIZE INTO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "implementation sign text: the back (the same strings are its lines here) has the default colour black (15) and no glow of its own" TO TL-CASE
     MOVE "15 0" TO TL-EXPECTED
     MOVE SN-COLOR(WS-ROW-A, 1) TO WS-E1
     MOVE SN-GLOW(WS-ROW-A, 1) TO WS-E2
     MOVE SPACES TO TL-OBSERVED
     STRING FUNCTION TRIM(WS-E1) " " FUNCTION TRIM(WS-E2) DELIMITED BY SIZE INTO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   A second packet for the same position replaces the text in the same row.
     MOVE "New" TO WS-TEXT-1
     MOVE 3 TO WS-LEN-1
     MOVE SPACES TO WS-TEXT-3 WS-TEXT-4
     MOVE 0 TO WS-LEN-3 WS-LEN-4
     MOVE 0 TO WS-GLOW WS-WAXED
     MOVE "bogus" TO WS-COLOR
     MOVE 5 TO WS-COLOR-LENGTH
     PERFORM FEED-TAG
     CALL "SIGN-TEXT-FIND" USING CLIENT-STATE WS-X WS-Y WS-Z WS-NO WS-ROW
     MOVE "implementation sign text: a second packet replaces the lines in the same row, an unknown colour name keeps black, is_waxed 0 clears the wax" TO TL-CASE
     MOVE "same row New 0 15 0" TO TL-EXPECTED
     MOVE SN-LEN(WS-ROW, 2, 3) TO WS-E1
     MOVE SN-COLOR(WS-ROW, 2) TO WS-E2
     MOVE SN-WAXED(WS-ROW) TO WS-E3
     MOVE SPACES TO TL-OBSERVED
     IF WS-ROW = WS-ROW-A
         STRING "same row " SN-TEXT(WS-ROW, 2, 1)(1:3) " " FUNCTION TRIM(WS-E1) " " FUNCTION TRIM(WS-E2) " " FUNCTION TRIM(WS-E3)
             DELIMITED BY SIZE INTO TL-OBSERVED
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   A hanging sign whose lines are compounds and whose tag has other keys: kept, lines empty, defaults.
     MOVE 7 TO WS-X
     MOVE 8 TO WS-TYPE
     MOVE 2 TO WS-SHAPE
     PERFORM FEED-TAG
     CALL "SIGN-TEXT-FIND" USING CLIENT-STATE WS-X WS-Y WS-Z WS-NO WS-ROW
     MOVE "implementation sign text: a hanging sign (8) with compound lines and other keys is kept with empty lines" TO TL-CASE
     MOVE "0 0 0 0 15" TO TL-EXPECTED
     MOVE SPACES TO TL-OBSERVED
     IF WS-ROW > 0
         MOVE SN-COLOR(WS-ROW, 2) TO WS-E1
         IF SN-LEN(WS-ROW, 2, 1) = 0 AND SN-LEN(WS-ROW, 2, 2) = 0 AND SN-LEN(WS-ROW, 2, 3) = 0 AND SN-LEN(WS-ROW, 2, 4) = 0
             STRING "0 0 0 0 " FUNCTION TRIM(WS-E1) DELIMITED BY SIZE INTO TL-OBSERVED
         END-IF
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   A chest (type 1) is no sign.
     MOVE 9 TO WS-X
     MOVE 1 TO WS-TYPE
     MOVE 1 TO WS-SHAPE
     PERFORM FEED-TAG
     CALL "SIGN-TEXT-FIND" USING CLIENT-STATE WS-X WS-Y WS-Z WS-NO WS-ROW
     MOVE "implementation sign text: Block Entity Data of another type keeps no sign row" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-ROW TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "T" TO TL-MODE

*>   A cell that becomes another state drops the row, the same state keeps it.
     MOVE 5 TO WS-X
     MOVE 6 TO WS-Z
     MOVE 2 TO WS-STATE
     CALL "WORLD-BLOCK-SET" USING CLIENT-STATE WS-X WS-Y WS-Z WS-STATE
     CALL "SIGN-TEXT-FIND" USING CLIENT-STATE WS-X WS-Y WS-Z WS-NO WS-ROW
     MOVE "implementation sign text: a block update to the state the cell has keeps the row" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE WS-ROW-A TO TL-EXPECTED-N
     MOVE WS-ROW TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-STATE
     CALL "WORLD-BLOCK-SET" USING CLIENT-STATE WS-X WS-Y WS-Z WS-STATE
     CALL "SIGN-TEXT-FIND" USING CLIENT-STATE WS-X WS-Y WS-Z WS-NO WS-ROW
     MOVE "implementation sign text: the cell becoming air drops the row" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-ROW TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "T" TO TL-MODE

*>   The block entities of a Level Chunk: a sign of chunk (0, 0) at local (3, 4, 3) replaces the rows of the chunk, a sign of chunk (1, 0) stays.
     MOVE 5 TO WS-X
     MOVE 6 TO WS-Z
     MOVE 7 TO WS-TYPE
     MOVE 1 TO WS-SHAPE
     MOVE "Hello" TO WS-TEXT-1
     MOVE 5 TO WS-LEN-1
     PERFORM FEED-TAG
     MOVE 20 TO WS-X
     MOVE 3 TO WS-Z
     MOVE "Other" TO WS-TEXT-1
     MOVE 5 TO WS-LEN-1
     PERFORM FEED-TAG
     MOVE "Chunk" TO WS-TEXT-1
     MOVE 5 TO WS-LEN-1
     MOVE 3 TO WS-X
     MOVE 3 TO WS-Z
     PERFORM BUILD-PACKET
     MOVE 0 TO PB-POS
     CALL "PB-GET-POSITION" USING PB-BUFFER WS-CX WS-CZ WS-STATE
     CALL "PB-GET-VARINT" USING PB-BUFFER WS-STATE
     COMPUTE WS-REST = PB-LENGTH - PB-POS
     CALL "PB-GET-BYTES" USING PB-BUFFER WS-DATA WS-REST
     INITIALIZE WS-HEADS
*>   Entry 1: a sign (local x 3, y 4, local z 3) with the tag; entry 2: a chest without data.
     MOVE 3 TO WS-HEAD(1)
     MOVE 4 TO WS-HEAD(2)
     MOVE 3 TO WS-HEAD(3)
     MOVE 7 TO WS-HEAD(4)
     MOVE WS-REST TO WS-HEAD(5)
     MOVE 9 TO WS-HEAD(6)
     MOVE 4 TO WS-HEAD(7)
     MOVE 9 TO WS-HEAD(8)
     MOVE 1 TO WS-HEAD(9)
     MOVE 0 TO WS-HEAD(10)
     MOVE 2 TO WS-COUNT
     MOVE 0 TO WS-CX WS-CZ
     CALL "SIGN-TEXT-CHUNK" USING CLIENT-STATE WS-CX WS-CZ WS-COUNT WS-HEADS WS-DATA
     MOVE 3 TO WS-X
     MOVE 3 TO WS-Z
     CALL "SIGN-TEXT-FIND" USING CLIENT-STATE WS-X WS-Y WS-Z WS-NO WS-ROW
     MOVE "implementation sign text: the sign entry of a chunk's block entity list is stored at its position (chunk coordinates plus local x and z)" TO TL-CASE
     MOVE "Chunk" TO TL-EXPECTED
     MOVE SPACES TO TL-OBSERVED
     IF WS-ROW > 0
         MOVE SN-TEXT(WS-ROW, 2, 1)(1:5) TO TL-OBSERVED
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 20 TO WS-X
     MOVE "implementation sign text: a sign of another chunk keeps its row" TO TL-CASE
     MOVE "Other" TO TL-EXPECTED
     MOVE SPACES TO TL-OBSERVED
     CALL "SIGN-TEXT-FIND" USING CLIENT-STATE WS-X WS-Y WS-Z WS-NO WS-ROW
     IF WS-ROW > 0
         MOVE SN-TEXT(WS-ROW, 2, 1)(1:5) TO TL-OBSERVED
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-COUNT
     CALL "SIGN-TEXT-CHUNK" USING CLIENT-STATE WS-CX WS-CZ WS-COUNT WS-HEADS WS-DATA
     MOVE 3 TO WS-X
     CALL "SIGN-TEXT-FIND" USING CLIENT-STATE WS-X WS-Y WS-Z WS-NO WS-ROW
     MOVE "implementation sign text: a chunk without sign entries drops the rows of that chunk" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-ROW TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "T" TO TL-MODE

*>   The editor starts from the text: the sign at (20, 4, 3) holds Other on its front; its back lines are the same strings.
     MOVE 20 TO WS-X
     MOVE 1 TO WS-SIDE-PASS
     PERFORM OPEN-EDITOR
     MOVE "implementation sign text: Open Sign Editor for the front opens the editor with Other on line 1, the cursor at its end" TO TL-CASE
     MOVE "screen sign Other 5 5" TO TL-EXPECTED
     MOVE SPACES TO TL-OBSERVED
     MOVE SM-SCREEN TO WS-E1
     MOVE SG-CURSOR TO WS-E2
     MOVE SG-LEN(1) TO WS-E3
     IF SM-SCREEN = SCR-SIGN
         STRING "screen sign " SG-LINE-TEXT(1)(1:5) " " FUNCTION TRIM(WS-E2) " " FUNCTION TRIM(WS-E3) DELIMITED BY SIZE INTO TL-OBSERVED
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE SCR-WORLD TO WS-STATE
     CALL "SCREEN-OPEN" USING CLIENT-STATE WS-STATE
     MOVE 7 TO WS-SIDE-PASS
     PERFORM OPEN-EDITOR
     MOVE "implementation sign text: a side out of range (7) is the back: line 1 is the back text (the packet gave the back the same strings)" TO TL-CASE
     MOVE "screen sign 5 back" TO TL-EXPECTED
     MOVE SPACES TO TL-OBSERVED
     IF SM-SCREEN = SCR-SIGN
         MOVE SG-LEN(1) TO WS-E1
         IF SG-SIDE = 0
             STRING "screen sign " FUNCTION TRIM(WS-E1) " back" DELIMITED BY SIZE INTO TL-OBSERVED
         END-IF
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE SCR-WORLD TO WS-STATE
     CALL "SCREEN-OPEN" USING CLIENT-STATE WS-STATE
     MOVE 40 TO WS-X
     MOVE 1 TO WS-SIDE-PASS
     PERFORM OPEN-EDITOR
     MOVE "implementation sign text: a sign the client holds no text for opens the editor empty" TO TL-CASE
     MOVE "screen sign 0 0" TO TL-EXPECTED
     MOVE SPACES TO TL-OBSERVED
     IF SM-SCREEN = SCR-SIGN
         MOVE SG-LEN(1) TO WS-E1
         MOVE SG-CURSOR TO WS-E2
         STRING "screen sign " FUNCTION TRIM(WS-E1) " " FUNCTION TRIM(WS-E2) DELIMITED BY SIZE INTO TL-OBSERVED
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   WORLD-CLEAR forgets every sign.
     MOVE 20 TO WS-X
     CALL "SIGN-TEXT-FIND" USING CLIENT-STATE WS-X WS-Y WS-Z WS-NO WS-ROW
     MOVE WS-ROW TO WS-ROW-A
     CALL "WORLD-CLEAR" USING CLIENT-STATE
     CALL "SIGN-TEXT-FIND" USING CLIENT-STATE WS-X WS-Y WS-Z WS-NO WS-ROW
     MOVE "implementation sign text: clearing the world (dimension change) forgets the signs" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-ROW TO TL-OBSERVED-N
     IF WS-ROW-A = 0
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.

*> Block Entity Data for the position WS-X, WS-Y, WS-Z of the type WS-TYPE (shape 1: strings; 2: compound lines and other keys) into BLOCK-ENTITY-DATA.
 FEED-TAG.
     PERFORM BUILD-PACKET
     MOVE 0 TO PB-POS
     CALL "BLOCK-ENTITY-DATA" USING CLIENT-STATE PB-BUFFER.

*> Builds the packet body (position, type, update tag) in PB-BUFFER: front_text with the four lines WS-TEXT-n, the colour WS-COLOR, glow WS-GLOW; back_text the same lines; is_waxed WS-WAXED.
 BUILD-PACKET.
     CALL "PB-RESET" USING PB-BUFFER
     CALL "PB-PUT-POSITION" USING PB-BUFFER WS-X WS-Y WS-Z
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-TYPE
     MOVE SPACES TO WN
     CALL "NBT-WRITE-COMPOUND-BEGIN" USING PB-BUFFER WN WS-ROOT
     MOVE "front_text" TO WN
     MOVE 10 TO WL
     CALL "NBT-WRITE-COMPOUND-BEGIN" USING PB-BUFFER WN WL
     PERFORM WRITE-SIDE
     CALL "NBT-WRITE-COMPOUND-END" USING PB-BUFFER
     IF WS-SHAPE = 1
         MOVE "back_text" TO WN
         MOVE 9 TO WL
         CALL "NBT-WRITE-COMPOUND-BEGIN" USING PB-BUFFER WN WL
         MOVE "messages" TO WN
         MOVE 8 TO WL
         CALL "NBT-WRITE-LIST-BEGIN" USING PB-BUFFER WN WL WS-T-STRING WS-FOUR
         PERFORM WRITE-STRING-LINES
         CALL "NBT-WRITE-COMPOUND-END" USING PB-BUFFER
     ELSE
         MOVE "back_text" TO WN
         MOVE 9 TO WL
         CALL "NBT-WRITE-INT" USING PB-BUFFER WN WL WS-ZERO
         MOVE "custom" TO WN
         MOVE 6 TO WL
         CALL "NBT-WRITE-INT" USING PB-BUFFER WN WL WS-ZERO
     END-IF
     MOVE "is_waxed" TO WN
     MOVE 8 TO WL
     CALL "NBT-WRITE-BYTE" USING PB-BUFFER WN WL WS-WAXED
     CALL "NBT-WRITE-COMPOUND-END" USING PB-BUFFER.

 WRITE-SIDE.
     MOVE "messages" TO WN
     MOVE 8 TO WL
     IF WS-SHAPE = 1
         CALL "NBT-WRITE-LIST-BEGIN" USING PB-BUFFER WN WL WS-T-STRING WS-FOUR
         PERFORM WRITE-STRING-LINES
     ELSE
         CALL "NBT-WRITE-LIST-BEGIN" USING PB-BUFFER WN WL WS-T-COMPOUND WS-FOUR
         PERFORM 4 TIMES
             CALL "NBT-WRITE-COMPOUND-BEGIN" USING PB-BUFFER WN WS-ELEMENT
             MOVE "text" TO WN
             MOVE 4 TO WL
             CALL "NBT-WRITE-STRING" USING PB-BUFFER WN WL WS-TEXT-1 WS-LEN-1
             CALL "NBT-WRITE-COMPOUND-END" USING PB-BUFFER
         END-PERFORM
         MOVE "filtered_messages" TO WN
         MOVE 17 TO WL
         CALL "NBT-WRITE-LIST-BEGIN" USING PB-BUFFER WN WL WS-T-STRING WS-FOUR
         PERFORM WRITE-STRING-LINES
         MOVE "zz" TO WN
         MOVE 2 TO WL
         CALL "NBT-WRITE-INT" USING PB-BUFFER WN WL WS-ZERO
     END-IF
     MOVE "color" TO WN
     MOVE 5 TO WL
     CALL "NBT-WRITE-STRING" USING PB-BUFFER WN WL WS-COLOR WS-COLOR-LENGTH
     MOVE "has_glowing_text" TO WN
     MOVE 16 TO WL
     CALL "NBT-WRITE-BYTE" USING PB-BUFFER WN WL WS-GLOW.

 WRITE-STRING-LINES.
     MOVE -1 TO WL
     CALL "NBT-WRITE-STRING" USING PB-BUFFER WN WL WS-TEXT-1 WS-LEN-1
     CALL "NBT-WRITE-STRING" USING PB-BUFFER WN WL WS-TEXT-2 WS-LEN-2
     CALL "NBT-WRITE-STRING" USING PB-BUFFER WN WL WS-TEXT-3 WS-LEN-3
     CALL "NBT-WRITE-STRING" USING PB-BUFFER WN WL WS-TEXT-4 WS-LEN-4.

*> Open Sign Editor (05a 0x3D) for WS-X, WS-Y, WS-Z and the side WS-SIDE-PASS (VarInt).
 OPEN-EDITOR.
     CALL "PB-RESET" USING PB-BUFFER
     CALL "PB-PUT-POSITION" USING PB-BUFFER WS-X WS-Y WS-Z
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-SIDE-PASS
     MOVE 0 TO PB-POS
     CALL "SIGN-OPEN" USING CLIENT-STATE PB-BUFFER.
 END PROGRAM TEST-SIGN-TEXT.
 COPY CLTEST.
