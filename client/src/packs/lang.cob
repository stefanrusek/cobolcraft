*> Language (08 §8, §10.8): LANG-LOAD merges lang/en_us.json of every namespace of every pack,
*> bottom pack first, so a higher pack replaces single texts; LANG-GET looks a key up (a key no pack
*> defines is shown as the key itself); LANG-FORMAT and LANG-FORMAT-TEXT fill the %s and %n$s
*> placeholders with the arguments (%% is a percent sign).

 IDENTIFICATION DIVISION.
 PROGRAM-ID. LANG-LOAD.
*> USING CLIENT-STATE: fills LG-ENTRY (at most CL-MAX-LANG keys; longer keys and texts are cut).
*> The generated vanilla en_us.json is over 500 KB with about 8,500 keys, more than one JSON-DOC holds
*> (JD-MAX-NODES): the text is cut at the top-level commas into slices of at most WS-SLICE-ENTRIES
*> members, each parsed as an object of its own (the comma before a slice, or the opening brace,
*> is overwritten by "{" and the comma that ends it by "}"), and a key reached again replaces its text.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLCONST.
 COPY JSONDOC.
 01 WS-PACK                BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-FOUND               BINARY-LONG.
 01 WS-SLASH               BINARY-LONG.
 01 WS-PATH                PIC X(256).
 01 WS-PATH-LENGTH         BINARY-LONG.
 01 WS-TEXT                PIC X(1048576).
 01 WS-CAPACITY            BINARY-LONG VALUE 1048576.
 01 WS-LENGTH              BINARY-LONG.
 01 WS-NODE                BINARY-LONG.
 01 WS-KEY                 PIC X(80).
 01 WS-KEY-CAP             BINARY-LONG VALUE 80.
 01 WS-KEY-LENGTH          BINARY-LONG.
 01 WS-ENTRY               BINARY-LONG.
 01 WS-TEXT-CAP            BINARY-LONG VALUE 200.
 01 WS-SLICE-ENTRIES       BINARY-LONG VALUE 1000.
 01 WS-POS                 BINARY-LONG.
 01 WS-START               BINARY-LONG.
 01 WS-DEPTH               BINARY-LONG.
 01 WS-MEMBERS             BINARY-LONG.
 01 WS-IN-STRING           BINARY-LONG.
 01 WS-DONE                BINARY-LONG.
 01 WS-SLICE-LENGTH        BINARY-LONG.
 01 WS-CHAR                PIC X.
 01 WS-LINE                PIC X(160).
 01 WS-LINE-LENGTH         BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 PROCEDURE DIVISION USING CLIENT-STATE.
     MOVE 0 TO LG-COUNT LG-FILES LG-FAILED LG-OVERFLOW
     PERFORM VARYING WS-PACK FROM 1 BY 1 UNTIL WS-PACK > PK-COUNT
         MOVE 1 TO WS-FOUND
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-FOUND = 0
             CALL "PACK-SOURCE-PATH" USING CLIENT-STATE WS-PACK WS-I WS-PATH WS-PATH-LENGTH
                 WS-FOUND
*>           assets/<namespace>/lang/en_us.json: the namespace has no "/".
             MOVE 0 TO WS-SLASH
             IF WS-FOUND = 1 AND WS-PATH(1:7) = "assets/" AND WS-PATH-LENGTH > 25
                 INSPECT WS-PATH(8:WS-PATH-LENGTH - 7) TALLYING WS-SLASH FOR ALL "/"
             END-IF
             IF WS-SLASH = 2 AND WS-PATH(WS-PATH-LENGTH - 15:16) = "/lang/en_us.json"
                 CALL "PACK-SOURCE-READ" USING CLIENT-STATE WS-PACK WS-PATH WS-PATH-LENGTH
                     WS-TEXT WS-CAPACITY WS-LENGTH WS-FOUND
                 IF WS-FOUND = 1
                     ADD 1 TO LG-FILES
                     PERFORM LANG-SLICES
                 ELSE
                     ADD 1 TO LG-FAILED
                 END-IF
                 MOVE 1 TO WS-FOUND
             END-IF
         END-PERFORM
     END-PERFORM
     CALL "LANG-REPORT" USING CLIENT-STATE WS-LINE WS-LINE-LENGTH
     DISPLAY WS-LINE(1:WS-LINE-LENGTH)
     GOBACK.

*> Walks WS-TEXT(1:WS-LENGTH): the first "{" starts the first slice; outside strings the nesting depth
*> follows the braces and brackets, and at depth 1 every comma is the end of a member.
 LANG-SLICES.
     MOVE 0 TO WS-START WS-DEPTH WS-MEMBERS WS-IN-STRING WS-DONE
     PERFORM VARYING WS-POS FROM 1 BY 1 UNTIL WS-POS > WS-LENGTH OR WS-DONE = 1
         MOVE WS-TEXT(WS-POS:1) TO WS-CHAR
         EVALUATE TRUE
             WHEN WS-IN-STRING = 1 AND WS-CHAR = X"5C"
                 ADD 1 TO WS-POS
             WHEN WS-CHAR = '"'
                 COMPUTE WS-IN-STRING = 1 - WS-IN-STRING
             WHEN WS-IN-STRING = 1
                 CONTINUE
             WHEN WS-CHAR = "{" OR WS-CHAR = "["
                 IF WS-START = 0
                     MOVE WS-POS TO WS-START
                 END-IF
                 ADD 1 TO WS-DEPTH
             WHEN WS-CHAR = "}" OR WS-CHAR = "]"
                 SUBTRACT 1 FROM WS-DEPTH
                 IF WS-DEPTH = 0
                     MOVE 1 TO WS-DONE
                     PERFORM LANG-SLICE-LOAD
                 END-IF
             WHEN WS-CHAR = "," AND WS-DEPTH = 1
                 ADD 1 TO WS-MEMBERS
                 IF WS-MEMBERS >= WS-SLICE-ENTRIES
                     MOVE "}" TO WS-TEXT(WS-POS:1)
                     PERFORM LANG-SLICE-LOAD
                     MOVE "{" TO WS-TEXT(WS-POS:1)
                     MOVE WS-POS TO WS-START
                     MOVE 0 TO WS-MEMBERS
                 END-IF
         END-EVALUATE
     END-PERFORM.

*> Parses WS-TEXT(WS-START:WS-POS - WS-START + 1) and merges its members.
 LANG-SLICE-LOAD.
     COMPUTE WS-SLICE-LENGTH = WS-POS - WS-START + 1
     CALL "JSON-PARSE" USING JSON-DOC WS-TEXT(WS-START:WS-SLICE-LENGTH) WS-SLICE-LENGTH
     MOVE 0 TO WS-NODE
     IF JD-COUNT > 0
         IF JN-TYPE(1) = JT-OBJECT
             MOVE JN-FIRST(1) TO WS-NODE
         END-IF
     END-IF
     PERFORM UNTIL WS-NODE = 0
         MOVE SPACES TO WS-KEY
         CALL "JSON-KEY" USING JSON-DOC WS-NODE WS-KEY WS-KEY-CAP WS-KEY-LENGTH
         MOVE 0 TO WS-ENTRY
         PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > LG-COUNT OR WS-ENTRY > 0
             IF LG-KEY-LENGTH(WS-K) = WS-KEY-LENGTH AND LG-KEY(WS-K) = WS-KEY
                 MOVE WS-K TO WS-ENTRY
             END-IF
         END-PERFORM
         IF WS-ENTRY = 0 AND LG-COUNT < CL-MAX-LANG
             ADD 1 TO LG-COUNT
             MOVE LG-COUNT TO WS-ENTRY
         END-IF
         IF WS-ENTRY = 0
             MOVE 1 TO LG-OVERFLOW
         END-IF
         IF WS-ENTRY > 0
             MOVE WS-KEY TO LG-KEY(WS-ENTRY)
             MOVE WS-KEY-LENGTH TO LG-KEY-LENGTH(WS-ENTRY)
             MOVE SPACES TO LG-TEXT(WS-ENTRY)
             CALL "JSON-STRING" USING JSON-DOC WS-NODE LG-TEXT(WS-ENTRY) WS-TEXT-CAP
                 LG-TEXT-LENGTH(WS-ENTRY)
         END-IF
         MOVE JN-NEXT(WS-NODE) TO WS-NODE
     END-PERFORM.
 END PROGRAM LANG-LOAD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. LANG-REPORT.
*> USING CLIENT-STATE, line out (PIC X(160)), length out: what the last LANG-LOAD did, as a console line: a
*> WARNING for no lang file at all (every text then shows as its key), for lang files that could not be
*> read and for more keys than the table holds; else the number of files merged.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLCONST.
 01 WS-FILES               PIC Z(5)9.
 01 WS-MAX                 PIC Z(5)9.
 01 WS-FAILED              PIC Z(5)9.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-LINE                 PIC X(160).
 01 L-LENGTH               BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-LINE L-LENGTH.
     MOVE SPACES TO L-LINE
     MOVE LG-FILES TO WS-FILES
     MOVE LG-FAILED TO WS-FAILED
     MOVE CL-MAX-LANG TO WS-MAX
     EVALUATE TRUE
         WHEN LG-FILES = 0 AND LG-FAILED = 0
             MOVE "WARNING language: no lang/en_us.json in any pack, texts show as their keys"
                 TO L-LINE
         WHEN LG-FAILED > 0
             STRING "WARNING language: " FUNCTION TRIM(WS-FAILED) " lang files could not be read"
                 DELIMITED BY SIZE INTO L-LINE
         WHEN LG-OVERFLOW = 1
             STRING "WARNING language: more keys than the table holds (" FUNCTION TRIM(WS-MAX)
                 "), the rest are not loaded" DELIMITED BY SIZE INTO L-LINE
         WHEN OTHER
             STRING "language: " FUNCTION TRIM(WS-FILES) " lang files, no problem"
                 DELIMITED BY SIZE INTO L-LINE
     END-EVALUATE
     MOVE FUNCTION LENGTH(FUNCTION TRIM(L-LINE)) TO L-LENGTH
     GOBACK.
 END PROGRAM LANG-REPORT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. LANG-GET.
*> USING CLIENT-STATE, key (PIC X(80)), key length, text out (PIC X(512)), text length out.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-K                   BINARY-LONG.
 01 WS-ENTRY               BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-KEY                  PIC X(80).
 01 L-KEY-LENGTH           BINARY-LONG.
 01 L-TEXT                 PIC X(512).
 01 L-TEXT-LENGTH          BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-KEY L-KEY-LENGTH L-TEXT L-TEXT-LENGTH.
     MOVE 0 TO WS-ENTRY
     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > LG-COUNT OR WS-ENTRY > 0
         IF LG-KEY-LENGTH(WS-K) = L-KEY-LENGTH AND LG-KEY(WS-K) = L-KEY
             MOVE WS-K TO WS-ENTRY
         END-IF
     END-PERFORM
     MOVE SPACES TO L-TEXT
     IF WS-ENTRY > 0
         MOVE LG-TEXT(WS-ENTRY) TO L-TEXT
         MOVE LG-TEXT-LENGTH(WS-ENTRY) TO L-TEXT-LENGTH
     ELSE
         MOVE L-KEY TO L-TEXT
         MOVE L-KEY-LENGTH TO L-TEXT-LENGTH
     END-IF
     GOBACK.
 END PROGRAM LANG-GET.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. LANG-FORMAT.
*> USING CLIENT-STATE, key (PIC X(80)), key length, LANG-ARGS, text out (PIC X(512)), length out.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-TEMPLATE            PIC X(512).
 01 WS-LENGTH              BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 COPY CLARGS.
 01 L-KEY                  PIC X(80).
 01 L-KEY-LENGTH           BINARY-LONG.
 01 L-TEXT                 PIC X(512).
 01 L-TEXT-LENGTH          BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-KEY L-KEY-LENGTH LANG-ARGS L-TEXT L-TEXT-LENGTH.
     CALL "LANG-GET" USING CLIENT-STATE L-KEY L-KEY-LENGTH WS-TEMPLATE WS-LENGTH
     CALL "LANG-FORMAT-TEXT" USING WS-TEMPLATE WS-LENGTH LANG-ARGS L-TEXT L-TEXT-LENGTH
     GOBACK.
 END PROGRAM LANG-FORMAT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. LANG-FORMAT-TEXT.
*> USING template area, template length, LANG-ARGS, text out (PIC X(512)), length out: %s takes
*> the next argument, %n$s the n-th (1 to 9), %% gives %; a placeholder past the arguments is
*> empty; the text is cut at 512 bytes.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-I                   BINARY-LONG.
 01 WS-NEXT                BINARY-LONG.
 01 WS-ARG                 BINARY-LONG.
 01 WS-PIECE               PIC X(256).
 01 WS-PIECE-LENGTH        BINARY-LONG.
 01 B-TEMPLATE             PIC X(512) BASED.
 LINKAGE SECTION.
 01 L-TEMPLATE             PIC X.
 01 L-TEMPLATE-LENGTH      BINARY-LONG.
 01 LANG-ARGS.
    05 LA-COUNT            BINARY-LONG.
    05 LA-ARG OCCURS 8 TIMES.
       10 LA-LENGTH        BINARY-LONG.
       10 LA-TEXT          PIC X(256).
 01 L-TEXT                 PIC X(512).
 01 L-TEXT-LENGTH          BINARY-LONG.
 PROCEDURE DIVISION USING L-TEMPLATE L-TEMPLATE-LENGTH LANG-ARGS L-TEXT L-TEXT-LENGTH.
     SET ADDRESS OF B-TEMPLATE TO ADDRESS OF L-TEMPLATE
     MOVE SPACES TO L-TEXT
     MOVE 0 TO L-TEXT-LENGTH
     MOVE 1 TO WS-NEXT WS-I
     PERFORM UNTIL WS-I > L-TEMPLATE-LENGTH
         MOVE B-TEMPLATE(WS-I:1) TO WS-PIECE
         MOVE 1 TO WS-PIECE-LENGTH
         MOVE 0 TO WS-ARG
         EVALUATE TRUE
             WHEN B-TEMPLATE(WS-I:2) = "%%"
                 ADD 1 TO WS-I
             WHEN B-TEMPLATE(WS-I:2) = "%s"
                 MOVE WS-NEXT TO WS-ARG
                 ADD 1 TO WS-NEXT
                 ADD 1 TO WS-I
             WHEN B-TEMPLATE(WS-I:1) = "%" AND B-TEMPLATE(WS-I + 1:1) IS NUMERIC
                     AND B-TEMPLATE(WS-I + 2:2) = "$s"
                 MOVE FUNCTION NUMVAL(B-TEMPLATE(WS-I + 1:1)) TO WS-ARG
                 ADD 3 TO WS-I
         END-EVALUATE
         IF WS-ARG > 0
             MOVE 0 TO WS-PIECE-LENGTH
             IF WS-ARG <= LA-COUNT
                 MOVE LA-TEXT(WS-ARG) TO WS-PIECE
                 MOVE LA-LENGTH(WS-ARG) TO WS-PIECE-LENGTH
             END-IF
         END-IF
         MOVE FUNCTION MIN(WS-PIECE-LENGTH, 512 - L-TEXT-LENGTH) TO WS-PIECE-LENGTH
         IF WS-PIECE-LENGTH > 0
             MOVE WS-PIECE(1:WS-PIECE-LENGTH) TO L-TEXT(L-TEXT-LENGTH + 1:WS-PIECE-LENGTH)
             ADD WS-PIECE-LENGTH TO L-TEXT-LENGTH
         END-IF
         ADD 1 TO WS-I
     END-PERFORM
     GOBACK.
 END PROGRAM LANG-FORMAT-TEXT.
