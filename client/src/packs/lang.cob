*> Language (08 §8, §10.8): LANG-LOAD merges lang/en_us.json of every namespace of every pack,
*> bottom pack first, so a higher pack replaces single texts; LANG-GET looks a key up (a key no pack
*> defines is shown as the key itself); LANG-FORMAT and LANG-FORMAT-TEXT fill the %s and %n$s
*> placeholders with the arguments (%% is a percent sign).

 IDENTIFICATION DIVISION.
 PROGRAM-ID. LANG-LOAD.
*> USING CLIENT-STATE: fills LG-ENTRY (at most CL-MAX-LANG keys; longer keys and texts are cut).
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
 01 WS-TEXT                PIC X(262144).
 01 WS-CAPACITY            BINARY-LONG VALUE 262144.
 01 WS-LENGTH              BINARY-LONG.
 01 WS-NODE                BINARY-LONG.
 01 WS-KEY                 PIC X(80).
 01 WS-KEY-CAP             BINARY-LONG VALUE 80.
 01 WS-KEY-LENGTH          BINARY-LONG.
 01 WS-ENTRY               BINARY-LONG.
 01 WS-TEXT-CAP            BINARY-LONG VALUE 200.
 LINKAGE SECTION.
 COPY CLSTATE.
 PROCEDURE DIVISION USING CLIENT-STATE.
     MOVE 0 TO LG-COUNT
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
                 CALL "JSON-PARSE" USING JSON-DOC WS-TEXT WS-LENGTH
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
                         IF LG-KEY(WS-K) = WS-KEY AND LG-KEY-LENGTH(WS-K) = WS-KEY-LENGTH
                             MOVE WS-K TO WS-ENTRY
                         END-IF
                     END-PERFORM
                     IF WS-ENTRY = 0 AND LG-COUNT < CL-MAX-LANG
                         ADD 1 TO LG-COUNT
                         MOVE LG-COUNT TO WS-ENTRY
                     END-IF
                     IF WS-ENTRY > 0
                         MOVE WS-KEY TO LG-KEY(WS-ENTRY)
                         MOVE WS-KEY-LENGTH TO LG-KEY-LENGTH(WS-ENTRY)
                         MOVE SPACES TO LG-TEXT(WS-ENTRY)
                         CALL "JSON-STRING" USING JSON-DOC WS-NODE LG-TEXT(WS-ENTRY) WS-TEXT-CAP
                             LG-TEXT-LENGTH(WS-ENTRY)
                     END-IF
                     MOVE JN-NEXT(WS-NODE) TO WS-NODE
                 END-PERFORM
                 MOVE 1 TO WS-FOUND
             END-IF
         END-PERFORM
     END-PERFORM
     GOBACK.
 END PROGRAM LANG-LOAD.

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
