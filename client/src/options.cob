*> The options (US16; docs/protocol/13-client-gameplay-and-controls.md 7.1 to 7.4): options.txt in the game directory, "version:5023"
*> then "<name>:<value>" lines in the order of the table CLOPTS.cpy (the lines of contract/fixtures/client/options-default.txt). The
*> table gives each option's kind, range and default; the value is kept in its stored form (OP-OPT-VALUE: a quoted name, a decimal
*> number, true or false, a key name such as key.keyboard.w, or raw text), so a file written back is the file read. A line without a
*> colon, an unknown name, or a value the option's kind does not accept is skipped and the option keeps its value (the default after
*> OPTIONS-DEFAULTS). resourcePacks (lowest priority first in the file, top first in OP-ENABLED), incompatibleResourcePacks (the JSON
*> list text) and fullscreenResolution are handled apart from the table.
*>   OPTIONS-DEFAULTS, OPTIONS-VALID, OPTIONS-GET, OPTIONS-SET, OPTIONS-KEY-CODE: the option values;
*>   OPTIONS-LIST-PARSE, OPTIONS-LINE, OPTIONS-READ, OPTIONS-WRITE: the file;
*>   OPTIONS-LOAD, OPTIONS-SAVE: the file of the game directory, with the one-time read of the legacy options.dat (R8);
*>   OPTIONS-DAT-READ: the EnabledPacks list of options.dat.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. OPTIONS-DEFAULTS.
*> USING CLIENT-STATE: every option at its default, no enabled pack, no incompatible pack, no fullscreen mode.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLOPTS.
 01 WS-I                   BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 PROCEDURE DIVISION USING CLIENT-STATE.
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > OT-COUNT
         MOVE SPACES TO OP-OPT-VALUE(WS-I)
         MOVE OT-DEFAULT(WS-I) TO OP-OPT-VALUE(WS-I)
         MOVE FUNCTION LENGTH(FUNCTION TRIM(OT-DEFAULT(WS-I))) TO OP-OPT-LEN(WS-I)
         IF OT-DEFAULT(WS-I) = SPACES
             MOVE 0 TO OP-OPT-LEN(WS-I)
         END-IF
     END-PERFORM
     MOVE 0 TO OP-COUNT OP-FULLSCREEN-LEN
     MOVE SPACES TO OP-INCOMPAT OP-FULLSCREEN
     MOVE "[]" TO OP-INCOMPAT
     MOVE 2 TO OP-INCOMPAT-LEN
     GOBACK.
 END PROGRAM OPTIONS-DEFAULTS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. OPTIONS-VALID.
*> USING row (1 to OT-COUNT), value (PIC X(64)), value length, valid out (1 = the option's kind accepts the value, and its range).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLOPTS.
 01 WS-I                   BINARY-LONG.
 01 WS-C                   PIC X.
 01 WS-DIGITS              BINARY-LONG.
 01 WS-DOTS                BINARY-LONG.
 01 WS-BAD                 BINARY-LONG.
 01 WS-N                   PIC S9(9)V9(6).
 01 WS-MIN                 PIC S9(9)V9(6).
 01 WS-MAX                 PIC S9(9)V9(6).
 01 WS-LIST                PIC X(64).
 01 WS-NEEDLE              PIC X(66).
 01 WS-HITS                BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-VALUE                PIC X(64).
 01 L-LENGTH               BINARY-LONG.
 01 L-VALID                BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-VALUE L-LENGTH L-VALID.
     MOVE 0 TO L-VALID
     EVALUATE OT-KIND(L-ROW)
         WHEN "B"
             IF (L-LENGTH = 4 AND L-VALUE(1:4) = "true") OR (L-LENGTH = 5 AND L-VALUE(1:5) = "false")
                 MOVE 1 TO L-VALID
             END-IF
         WHEN "S"
             IF L-LENGTH >= 0
                 MOVE 1 TO L-VALID
             END-IF
         WHEN "J"
             MOVE SPACES TO WS-LIST WS-NEEDLE
             STRING "|" FUNCTION TRIM(OT-ENUM(L-ROW)) "|" DELIMITED BY SIZE INTO WS-LIST
             IF L-LENGTH >= 2 AND L-LENGTH <= 64
                 STRING "|" L-VALUE(1:L-LENGTH) "|" DELIMITED BY SIZE INTO WS-NEEDLE
                 MOVE 0 TO WS-HITS
                 INSPECT WS-LIST TALLYING WS-HITS FOR ALL FUNCTION TRIM(WS-NEEDLE)
                 IF WS-HITS > 0
                     MOVE 1 TO L-VALID
                 END-IF
             END-IF
         WHEN "K"
             IF L-LENGTH > 0
                 PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > KT-COUNT OR L-VALID = 1
                     IF FUNCTION TRIM(KT-NAME(WS-I)) = L-VALUE(1:L-LENGTH)
                         MOVE 1 TO L-VALID
                     END-IF
                 END-PERFORM
             END-IF
         WHEN OTHER
*>           I and F: an optional minus, digits, for F one dot; at most 10 characters; within the row's range.
             MOVE 0 TO WS-DIGITS WS-DOTS WS-BAD
             IF L-LENGTH < 1 OR L-LENGTH > 10
                 MOVE 1 TO WS-BAD
             END-IF
             PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > L-LENGTH OR WS-BAD = 1
                 MOVE L-VALUE(WS-I:1) TO WS-C
                 EVALUATE TRUE
                     WHEN WS-C >= "0" AND WS-C <= "9"
                         ADD 1 TO WS-DIGITS
                     WHEN WS-C = "-" AND WS-I = 1
                         CONTINUE
                     WHEN WS-C = "." AND OT-KIND(L-ROW) = "F"
                         ADD 1 TO WS-DOTS
                     WHEN OTHER
                         MOVE 1 TO WS-BAD
                 END-EVALUATE
             END-PERFORM
             IF WS-BAD = 0 AND WS-DIGITS > 0 AND WS-DOTS <= 1
                 COMPUTE WS-N = FUNCTION NUMVAL(L-VALUE(1:L-LENGTH))
                 COMPUTE WS-MIN = FUNCTION NUMVAL(OT-MIN(L-ROW))
                 COMPUTE WS-MAX = FUNCTION NUMVAL(OT-MAX(L-ROW))
                 IF WS-N >= WS-MIN AND WS-N <= WS-MAX
                     MOVE 1 TO L-VALID
                 END-IF
             END-IF
     END-EVALUATE
     GOBACK.
 END PROGRAM OPTIONS-VALID.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. OPTIONS-LIST-PARSE.
*> USING CLIENT-STATE, text (PIC X(4096)), length, mode (1 resourcePacks: the ids replace OP-ENABLED, reversed so that the top comes
*> first; 2 incompatibleResourcePacks: only checked), ok out: a JSON array of strings without escapes, such as ["vanilla","file/a.zip"].
*> A list that is not that (an unterminated one, a non-string) is not ok and changes nothing.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLCONST.
 01 WS-IDS.
    05 WS-ID               PIC X(80) OCCURS 32 TIMES.
 01 WS-LENGTHS.
    05 WS-ID-LENGTH        BINARY-LONG OCCURS 32 TIMES.
 01 WS-COUNT               BINARY-LONG.
 01 WS-POS                 BINARY-LONG.
 01 WS-START               BINARY-LONG.
 01 WS-DONE                BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-TEXT                 PIC X(4096).
 01 L-LENGTH               BINARY-LONG.
 01 L-MODE                 BINARY-LONG.
 01 L-OK                   BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-TEXT L-LENGTH L-MODE L-OK.
     MOVE 0 TO L-OK WS-COUNT WS-DONE
     IF L-LENGTH < 2 OR L-TEXT(1:1) NOT = "[" OR L-TEXT(L-LENGTH:1) NOT = "]"
         GOBACK
     END-IF
     MOVE 2 TO WS-POS
     IF L-LENGTH = 2
         MOVE 1 TO WS-DONE
     END-IF
     PERFORM UNTIL WS-DONE NOT = 0
         IF WS-POS >= L-LENGTH OR L-TEXT(WS-POS:1) NOT = '"'
             MOVE 2 TO WS-DONE
         ELSE
             COMPUTE WS-START = WS-POS + 1
             MOVE WS-START TO WS-POS
             PERFORM UNTIL WS-POS > L-LENGTH OR L-TEXT(WS-POS:1) = '"'
                 ADD 1 TO WS-POS
             END-PERFORM
             IF WS-POS >= L-LENGTH OR WS-POS - WS-START > 80
                 MOVE 2 TO WS-DONE
             ELSE
                 IF WS-COUNT < CL-MAX-LOCAL-PACKS
                     ADD 1 TO WS-COUNT
                     MOVE SPACES TO WS-ID(WS-COUNT)
                     COMPUTE WS-ID-LENGTH(WS-COUNT) = WS-POS - WS-START
                     MOVE L-TEXT(WS-START:WS-ID-LENGTH(WS-COUNT)) TO WS-ID(WS-COUNT)
                 END-IF
                 ADD 1 TO WS-POS
                 EVALUATE TRUE
                     WHEN L-TEXT(WS-POS:1) = "," AND WS-POS < L-LENGTH
                         ADD 1 TO WS-POS
                     WHEN WS-POS = L-LENGTH
                         MOVE 1 TO WS-DONE
                     WHEN OTHER
                         MOVE 2 TO WS-DONE
                 END-EVALUATE
             END-IF
         END-IF
     END-PERFORM
     IF WS-DONE = 1
         MOVE 1 TO L-OK
         IF L-MODE = 1
             MOVE WS-COUNT TO OP-COUNT
             PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > WS-COUNT
                 MOVE WS-ID(WS-COUNT - WS-K + 1) TO OP-ID(WS-K)
                 MOVE WS-ID-LENGTH(WS-COUNT - WS-K + 1) TO OP-ID-LENGTH(WS-K)
             END-PERFORM
         END-IF
     END-IF
     GOBACK.
 END PROGRAM OPTIONS-LIST-PARSE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. OPTIONS-SET.
*> USING CLIENT-STATE, name (PIC X(40)), value (PIC X(4096)), value length, ok out (1 = set): sets one option by its file name from
*> its stored form. The two pack lists and fullscreenResolution are set from their text; "version" is accepted and ignored; an unknown
*> name, or a value the kind and range refuse, sets nothing.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLOPTS.
 01 WS-I                   BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-VALID               BINARY-LONG.
 01 WS-SMALL               PIC X(64).
 01 WS-MODE1               BINARY-LONG VALUE 1.
 01 WS-MODE2               BINARY-LONG VALUE 2.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-NAME                 PIC X(40).
 01 L-VALUE                PIC X(4096).
 01 L-LENGTH               BINARY-LONG.
 01 L-OK                   BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-NAME L-VALUE L-LENGTH L-OK.
     MOVE 0 TO L-OK
     EVALUATE TRUE
         WHEN L-NAME = "version"
             MOVE 1 TO L-OK
         WHEN L-NAME = "resourcePacks"
             CALL "OPTIONS-LIST-PARSE" USING CLIENT-STATE L-VALUE L-LENGTH WS-MODE1 L-OK
         WHEN L-NAME = "incompatibleResourcePacks"
             CALL "OPTIONS-LIST-PARSE" USING CLIENT-STATE L-VALUE L-LENGTH WS-MODE2 L-OK
             IF L-OK = 1 AND L-LENGTH <= 512
                 MOVE SPACES TO OP-INCOMPAT
                 MOVE L-VALUE(1:L-LENGTH) TO OP-INCOMPAT
                 MOVE L-LENGTH TO OP-INCOMPAT-LEN
             ELSE
                 MOVE 0 TO L-OK
             END-IF
         WHEN L-NAME = "fullscreenResolution"
             IF L-LENGTH > 0 AND L-LENGTH <= 64
                 MOVE SPACES TO OP-FULLSCREEN
                 MOVE L-VALUE(1:L-LENGTH) TO OP-FULLSCREEN
                 MOVE L-LENGTH TO OP-FULLSCREEN-LEN
                 MOVE 1 TO L-OK
             END-IF
         WHEN OTHER
             MOVE 0 TO WS-ROW
             PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > OT-COUNT OR WS-ROW > 0
                 IF OT-NAME(WS-I) = L-NAME
                     MOVE WS-I TO WS-ROW
                 END-IF
             END-PERFORM
             IF WS-ROW > 0 AND L-LENGTH <= 64
                 MOVE SPACES TO WS-SMALL
                 IF L-LENGTH > 0
                     MOVE L-VALUE(1:L-LENGTH) TO WS-SMALL
                 END-IF
                 CALL "OPTIONS-VALID" USING WS-ROW WS-SMALL L-LENGTH WS-VALID
                 IF WS-VALID = 1
                     MOVE WS-SMALL TO OP-OPT-VALUE(WS-ROW)
                     MOVE L-LENGTH TO OP-OPT-LEN(WS-ROW)
                     MOVE 1 TO L-OK
                 END-IF
             END-IF
     END-EVALUATE
     GOBACK.
 END PROGRAM OPTIONS-SET.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. OPTIONS-GET.
*> USING CLIENT-STATE, name (PIC X(40)), value out (PIC X(64)), value length out, found out: the stored form of one option
*> (resourcePacks as the JSON list text, lowest priority first; incompatibleResourcePacks; version 5023).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLOPTS.
 01 WS-I                   BINARY-LONG.
 01 WS-PTR                 BINARY-LONG.
 01 WS-TEXT                PIC X(4096).
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-NAME                 PIC X(40).
 01 L-VALUE                PIC X(64).
 01 L-LENGTH               BINARY-LONG.
 01 L-FOUND                BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-NAME L-VALUE L-LENGTH L-FOUND.
     MOVE SPACES TO L-VALUE
     MOVE 0 TO L-LENGTH L-FOUND
     EVALUATE TRUE
         WHEN L-NAME = "version"
             MOVE "5023" TO L-VALUE
             MOVE 4 TO L-LENGTH
             MOVE 1 TO L-FOUND
         WHEN L-NAME = "resourcePacks"
             MOVE 1 TO L-FOUND WS-PTR
             MOVE "[" TO WS-TEXT
             MOVE 2 TO WS-PTR
             PERFORM VARYING WS-I FROM OP-COUNT BY -1 UNTIL WS-I < 1
                 IF WS-I < OP-COUNT
                     STRING "," DELIMITED BY SIZE INTO WS-TEXT WITH POINTER WS-PTR
                 END-IF
                 STRING '"' OP-ID(WS-I)(1:OP-ID-LENGTH(WS-I)) '"' DELIMITED BY SIZE INTO WS-TEXT WITH POINTER WS-PTR
             END-PERFORM
             STRING "]" DELIMITED BY SIZE INTO WS-TEXT WITH POINTER WS-PTR
             COMPUTE L-LENGTH = WS-PTR - 1
             MOVE WS-TEXT(1:FUNCTION MIN(L-LENGTH, 64)) TO L-VALUE
         WHEN L-NAME = "incompatibleResourcePacks"
             MOVE 1 TO L-FOUND
             MOVE OP-INCOMPAT-LEN TO L-LENGTH
             MOVE OP-INCOMPAT(1:64) TO L-VALUE
         WHEN OTHER
             PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > OT-COUNT OR L-FOUND = 1
                 IF OT-NAME(WS-I) = L-NAME
                     MOVE 1 TO L-FOUND
                     MOVE OP-OPT-VALUE(WS-I) TO L-VALUE
                     MOVE OP-OPT-LEN(WS-I) TO L-LENGTH
                 END-IF
             END-PERFORM
     END-EVALUATE
     GOBACK.
 END PROGRAM OPTIONS-GET.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. OPTIONS-KEY-CODE.
*> USING CLIENT-STATE, key mapping name such as "key.forward" (PIC X(40)), code out: the GLFW key code of the key bound to it
*> (mouse buttons 1000 + the button: left 1000, right 1001, middle 1002); 0 when unbound or unknown.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLOPTS.
 01 WS-NAME                PIC X(40).
 01 WS-VALUE               PIC X(64).
 01 WS-LENGTH              BINARY-LONG.
 01 WS-FOUND               BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-ACTION               PIC X(40).
 01 L-CODE                 BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-ACTION L-CODE.
     MOVE 0 TO L-CODE
     MOVE SPACES TO WS-NAME
     STRING "key_" FUNCTION TRIM(L-ACTION) DELIMITED BY SIZE INTO WS-NAME
     CALL "OPTIONS-GET" USING CLIENT-STATE WS-NAME WS-VALUE WS-LENGTH WS-FOUND
     IF WS-FOUND = 1 AND WS-LENGTH > 0
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > KT-COUNT
             IF FUNCTION TRIM(KT-NAME(WS-I)) = WS-VALUE(1:WS-LENGTH)
                 MOVE KT-GLFW(WS-I) TO L-CODE
             END-IF
         END-PERFORM
     END-IF
     GOBACK.
 END PROGRAM OPTIONS-KEY-CODE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. OPTIONS-LINE.
*> USING CLIENT-STATE, line (PIC X(4096)), line length: one line "<name>:<value>" of options.txt, split at the first colon; a
*> line without one, or an empty name, is skipped.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-LENGTH              BINARY-LONG.
 01 WS-COLON               BINARY-LONG.
 01 WS-NAME                PIC X(40).
 01 WS-VALUE               PIC X(4096).
 01 WS-VALUE-LENGTH        BINARY-LONG.
 01 WS-OK                  BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-LINE                 PIC X(4096).
 01 L-LENGTH               BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-LINE L-LENGTH.
     MOVE L-LENGTH TO WS-LENGTH
     IF WS-LENGTH > 0 AND L-LINE(WS-LENGTH:1) = X"0D"
         SUBTRACT 1 FROM WS-LENGTH
     END-IF
     MOVE 0 TO WS-COLON
     INSPECT L-LINE(1:WS-LENGTH) TALLYING WS-COLON FOR CHARACTERS BEFORE INITIAL ":"
     IF WS-COLON > 0 AND WS-COLON < WS-LENGTH AND WS-COLON <= 40
         MOVE SPACES TO WS-NAME WS-VALUE
         MOVE L-LINE(1:WS-COLON) TO WS-NAME
         COMPUTE WS-VALUE-LENGTH = WS-LENGTH - WS-COLON - 1
         IF WS-VALUE-LENGTH > 0
             MOVE L-LINE(WS-COLON + 2:WS-VALUE-LENGTH) TO WS-VALUE
         END-IF
         CALL "OPTIONS-SET" USING CLIENT-STATE WS-NAME WS-VALUE WS-VALUE-LENGTH WS-OK
     END-IF
     GOBACK.
 END PROGRAM OPTIONS-LINE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. OPTIONS-READ.
*> USING CLIENT-STATE, path (PIC X(1100)), path length, found out (1 = the file opened and was read to its end): applies every
*> line of the file over the current values. A file that cannot be opened or read is not found and changes nothing further.
 ENVIRONMENT DIVISION.
 INPUT-OUTPUT SECTION.
 FILE-CONTROL.
     SELECT OPT-FILE ASSIGN TO WS-FILE-NAME
         ORGANIZATION LINE SEQUENTIAL
         FILE STATUS WS-STATUS.
 DATA DIVISION.
 FILE SECTION.
 FD OPT-FILE.
 01 OPT-LINE               PIC X(4096).
 WORKING-STORAGE SECTION.
 01 WS-FILE-NAME           PIC X(1100).
 01 WS-STATUS              PIC XX.
 01 WS-LINE                PIC X(4096).
 01 WS-LINE-LENGTH         BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-PATH                 PIC X(1100).
 01 L-LENGTH               BINARY-LONG.
 01 L-FOUND                BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-PATH L-LENGTH L-FOUND.
     MOVE 0 TO L-FOUND
     MOVE SPACES TO WS-FILE-NAME
     MOVE L-PATH(1:L-LENGTH) TO WS-FILE-NAME
     OPEN INPUT OPT-FILE
     IF WS-STATUS = "00"
         MOVE 1 TO L-FOUND
         PERFORM UNTIL WS-STATUS NOT = "00"
             READ OPT-FILE INTO WS-LINE
             IF WS-STATUS = "00"
                 MOVE FUNCTION LENGTH(FUNCTION TRIM(WS-LINE TRAILING)) TO WS-LINE-LENGTH
                 IF WS-LINE = SPACES
                     MOVE 0 TO WS-LINE-LENGTH
                 END-IF
                 CALL "OPTIONS-LINE" USING CLIENT-STATE WS-LINE WS-LINE-LENGTH
             END-IF
         END-PERFORM
         CLOSE OPT-FILE
     END-IF
     GOBACK.
 END PROGRAM OPTIONS-READ.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. OPTIONS-WRITE.
*> USING CLIENT-STATE, path (PIC X(1100)), path length, ok out (1 = written): the whole file, "version:5023", the pack lists,
*> every table option in order, and the fullscreen mode line when one is set.
 ENVIRONMENT DIVISION.
 INPUT-OUTPUT SECTION.
 FILE-CONTROL.
     SELECT OPT-FILE ASSIGN TO WS-FILE-NAME
         ORGANIZATION LINE SEQUENTIAL
         FILE STATUS WS-STATUS.
 DATA DIVISION.
 FILE SECTION.
 FD OPT-FILE.
 01 OPT-LINE               PIC X(4096).
 WORKING-STORAGE SECTION.
 COPY CLOPTS.
 01 WS-FILE-NAME           PIC X(1100).
 01 WS-STATUS              PIC XX.
 01 WS-I                   BINARY-LONG.
 01 WS-NAME                PIC X(40).
 01 WS-VALUE               PIC X(64).
 01 WS-VALUE-LENGTH        BINARY-LONG.
 01 WS-FOUND               BINARY-LONG.
 01 WS-PTR                 BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-PATH                 PIC X(1100).
 01 L-LENGTH               BINARY-LONG.
 01 L-OK                   BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-PATH L-LENGTH L-OK.
     MOVE 0 TO L-OK
     MOVE SPACES TO WS-FILE-NAME
     MOVE L-PATH(1:L-LENGTH) TO WS-FILE-NAME
     OPEN OUTPUT OPT-FILE
     IF WS-STATUS = "00"
         MOVE 1 TO L-OK
         MOVE "version:5023" TO OPT-LINE
         WRITE OPT-LINE
         MOVE SPACES TO OPT-LINE
         MOVE "resourcePacks:[" TO OPT-LINE
         MOVE 16 TO WS-PTR
         PERFORM VARYING WS-I FROM OP-COUNT BY -1 UNTIL WS-I < 1
             IF WS-I < OP-COUNT
                 STRING "," DELIMITED BY SIZE INTO OPT-LINE WITH POINTER WS-PTR
             END-IF
             STRING '"' OP-ID(WS-I)(1:OP-ID-LENGTH(WS-I)) '"' DELIMITED BY SIZE INTO OPT-LINE WITH POINTER WS-PTR
         END-PERFORM
         STRING "]" DELIMITED BY SIZE INTO OPT-LINE WITH POINTER WS-PTR
         WRITE OPT-LINE
         MOVE SPACES TO OPT-LINE
         STRING "incompatibleResourcePacks:" OP-INCOMPAT(1:OP-INCOMPAT-LEN) DELIMITED BY SIZE INTO OPT-LINE
         WRITE OPT-LINE
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > OT-COUNT
             MOVE SPACES TO OPT-LINE
             IF OP-OPT-LEN(WS-I) > 0
                 STRING FUNCTION TRIM(OT-NAME(WS-I)) ":" OP-OPT-VALUE(WS-I)(1:OP-OPT-LEN(WS-I))
                     DELIMITED BY SIZE INTO OPT-LINE
             ELSE
                 STRING FUNCTION TRIM(OT-NAME(WS-I)) ":" DELIMITED BY SIZE INTO OPT-LINE
             END-IF
             WRITE OPT-LINE
         END-PERFORM
         IF OP-FULLSCREEN-LEN > 0
             MOVE SPACES TO OPT-LINE
             STRING "fullscreenResolution:" OP-FULLSCREEN(1:OP-FULLSCREEN-LEN) DELIMITED BY SIZE INTO OPT-LINE
             WRITE OPT-LINE
         END-IF
         CLOSE OPT-FILE
     END-IF
     GOBACK.
 END PROGRAM OPTIONS-WRITE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. OPTIONS-DAT-READ.
*> USING CLIENT-STATE, path (PIC X(1100)), path length: the enabled pack ids (OP-ENABLED, top first) of the legacy options.dat
*> (gzip NBT: List "EnabledPacks" of strings; at most CL-MAX-LOCAL-PACKS; other tags skipped). Read once at the first start
*> after the change to options.txt and never written again (R8); a file that cannot be read gives no packs.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY PROTO.
 COPY CLCONST.
 01 WS-CAPACITY            BINARY-LONG VALUE 4096.
 01 WS-OUTCOME             BINARY-LONG.
 01 WS-FILE-FRAMING        BINARY-LONG VALUE 1.
 01 WS-TYPE                BINARY-LONG.
 01 WS-ETYPE               BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WN                     PIC X(64).
 01 WN-CAP                 BINARY-LONG VALUE 64.
 01 WL                     BINARY-LONG.
 01 WS-TEXT                PIC X(80).
 01 WS-TEXT-CAP            BINARY-LONG VALUE 80.
 01 WS-TEXT-LENGTH         BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-PATH                 PIC X(1100).
 01 L-LENGTH               BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-PATH L-LENGTH.
     MOVE 0 TO OP-COUNT
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "NBT-FILE-READ" USING L-PATH L-LENGTH PB-BUFFER WS-OUTCOME
     IF WS-OUTCOME = 0
         CALL "NBT-READ-ROOT" USING PB-BUFFER WS-FILE-FRAMING WS-TYPE
         MOVE 1 TO WS-TYPE
         PERFORM UNTIL WS-TYPE = 0
             MOVE SPACES TO WN
             CALL "NBT-READ-COMPOUND-NEXT" USING PB-BUFFER WS-TYPE WN WN-CAP WL
             EVALUATE TRUE
                 WHEN WS-TYPE = 0
                     CONTINUE
                 WHEN WN = "EnabledPacks" AND WS-TYPE = 9
                     CALL "NBT-READ-LIST-BEGIN" USING PB-BUFFER WS-ETYPE WS-COUNT
                     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-COUNT
                         IF WS-ETYPE = 8 AND OP-COUNT < CL-MAX-LOCAL-PACKS
                             MOVE SPACES TO WS-TEXT
                             CALL "NBT-READ-STRING" USING PB-BUFFER WS-TEXT WS-TEXT-CAP
                                 WS-TEXT-LENGTH
                             ADD 1 TO OP-COUNT
                             MOVE WS-TEXT TO OP-ID(OP-COUNT)
                             MOVE WS-TEXT-LENGTH TO OP-ID-LENGTH(OP-COUNT)
                         ELSE
                             CALL "NBT-READ-SKIP" USING PB-BUFFER WS-ETYPE
                         END-IF
                     END-PERFORM
                 WHEN OTHER
                     CALL "NBT-READ-SKIP" USING PB-BUFFER WS-TYPE
             END-EVALUATE
         END-PERFORM
     END-IF
     CALL "PB-FREE" USING PB-BUFFER
     GOBACK.
 END PROGRAM OPTIONS-DAT-READ.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. OPTIONS-LOAD.
*> USING CLIENT-STATE: the defaults, then options.txt of the game directory over them; without an options.txt, the legacy
*> options.dat EnabledPacks list (OPTIONS-DAT-READ). Neither readable: the defaults, and the game starts.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-TXT                 PIC X(32) VALUE "options.txt".
 01 WS-DAT                 PIC X(32) VALUE "options.dat".
 01 WS-PATH                PIC X(1100).
 01 WS-LENGTH              BINARY-LONG.
 01 WS-INFO                PIC X(16).
 01 WS-FOUND               BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 PROCEDURE DIVISION USING CLIENT-STATE.
     CALL "OPTIONS-DEFAULTS" USING CLIENT-STATE
     CALL "GAME-DATA-PATH" USING CLIENT-STATE WS-TXT WS-PATH WS-LENGTH
     CALL "OPTIONS-READ" USING CLIENT-STATE WS-PATH WS-LENGTH WS-FOUND
     IF WS-FOUND = 0
         CALL "GAME-DATA-PATH" USING CLIENT-STATE WS-DAT WS-PATH WS-LENGTH
         CALL "CBL_CHECK_FILE_EXIST" USING WS-PATH WS-INFO
         IF RETURN-CODE = 0
             CALL "OPTIONS-DAT-READ" USING CLIENT-STATE WS-PATH WS-LENGTH
         END-IF
         MOVE 0 TO RETURN-CODE
     END-IF
     GOBACK.
 END PROGRAM OPTIONS-LOAD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. OPTIONS-SAVE.
*> USING CLIENT-STATE: writes options.txt of the game directory in full. A file that cannot be written is reported on the
*> console as one ERROR line and the game goes on.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-FILE                PIC X(32) VALUE "options.txt".
 01 WS-PATH                PIC X(1100).
 01 WS-LENGTH              BINARY-LONG.
 01 WS-OK                  BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 PROCEDURE DIVISION USING CLIENT-STATE.
     CALL "GAME-DATA-PATH" USING CLIENT-STATE WS-FILE WS-PATH WS-LENGTH
     CALL "OPTIONS-WRITE" USING CLIENT-STATE WS-PATH WS-LENGTH WS-OK
     IF WS-OK = 0
         DISPLAY "ERROR options: cannot write options.txt"
     END-IF
     GOBACK.
 END PROGRAM OPTIONS-SAVE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. OPTIONS-APPLY.
*> USING CLIENT-STATE: what the options change in the running client, at once: the key codes of the bindings (KB-CODE, 13 §7.3),
*> the field of view (fov is stored as (degrees - 70) / 40), the degrees of turn per mouse pixel (13 §7.2:
*> 0.15 x (sensitivity x 0.6 + 0.2)^3 x 8, so the default 0.5 turns 0.15) and the guiScale option.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLCONST.
 01 WS-NAMES.
    05 FILLER PIC X(40) VALUE "key.forward".
    05 FILLER PIC X(40) VALUE "key.left".
    05 FILLER PIC X(40) VALUE "key.back".
    05 FILLER PIC X(40) VALUE "key.right".
    05 FILLER PIC X(40) VALUE "key.jump".
    05 FILLER PIC X(40) VALUE "key.sneak".
    05 FILLER PIC X(40) VALUE "key.sprint".
    05 FILLER PIC X(40) VALUE "key.inventory".
    05 FILLER PIC X(40) VALUE "key.swapOffhand".
    05 FILLER PIC X(40) VALUE "key.drop".
    05 FILLER PIC X(40) VALUE "key.hotbar.1".
    05 FILLER PIC X(40) VALUE "key.hotbar.2".
    05 FILLER PIC X(40) VALUE "key.hotbar.3".
    05 FILLER PIC X(40) VALUE "key.hotbar.4".
    05 FILLER PIC X(40) VALUE "key.hotbar.5".
    05 FILLER PIC X(40) VALUE "key.hotbar.6".
    05 FILLER PIC X(40) VALUE "key.hotbar.7".
    05 FILLER PIC X(40) VALUE "key.hotbar.8".
    05 FILLER PIC X(40) VALUE "key.hotbar.9".
    05 FILLER PIC X(40) VALUE "key.chat".
    05 FILLER PIC X(40) VALUE "key.command".
    05 FILLER PIC X(40) VALUE "key.togglePerspective".
 01 WS-NAME-TABLE REDEFINES WS-NAMES.
    05 KB-NAME             PIC X(40) OCCURS 22 TIMES.
 01 WS-I                   BINARY-LONG.
 01 WS-CODE                BINARY-LONG.
 01 WS-KEY                 PIC X(40).
 01 WS-VALUE               PIC X(64).
 01 WS-LENGTH              BINARY-LONG.
 01 WS-FOUND               BINARY-LONG.
 01 WS-S                   FLOAT-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 PROCEDURE DIVISION USING CLIENT-STATE.
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > KB-COUNT
         CALL "OPTIONS-KEY-CODE" USING CLIENT-STATE KB-NAME(WS-I) WS-CODE
         IF WS-CODE >= 400
*>           A mouse button is no keyboard key: the keyboard queries find nothing.
             MOVE 0 TO WS-CODE
         END-IF
         MOVE WS-CODE TO KB-CODE(WS-I)
     END-PERFORM
     MOVE "fov" TO WS-KEY
     CALL "OPTIONS-GET" USING CLIENT-STATE WS-KEY WS-VALUE WS-LENGTH WS-FOUND
     COMPUTE CL-FOV-DEG = 70 + 40 * FUNCTION NUMVAL(WS-VALUE(1:WS-LENGTH))
     MOVE "mouseSensitivity" TO WS-KEY
     CALL "OPTIONS-GET" USING CLIENT-STATE WS-KEY WS-VALUE WS-LENGTH WS-FOUND
     COMPUTE WS-S = FUNCTION NUMVAL(WS-VALUE(1:WS-LENGTH)) * 0.6 + 0.2
     COMPUTE CL-TURN = 0.15 * WS-S * WS-S * WS-S * 8
     MOVE "guiScale" TO WS-KEY
     CALL "OPTIONS-GET" USING CLIENT-STATE WS-KEY WS-VALUE WS-LENGTH WS-FOUND
     COMPUTE CL-GUI-OPTION = FUNCTION NUMVAL(WS-VALUE(1:WS-LENGTH))
     GOBACK.
 END PROGRAM OPTIONS-APPLY.
