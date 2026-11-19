*> The client's copy of the text of signs (docs/protocol/31-block-entities-3-signs-banners-skulls-pots-shelves.md sections 2.2, 2.10; 40-menus-8 section 1.2): the update tag of a sign or hanging sign
*> (Block Entity Data 05a 0x06 with type 7 or 8, and the block entities of a Level Chunk) is kept by position in SN-ENTRY of the client state (CLSTATE.cpy), so that the sign editor starts from the
*> text on the sign (SIGN-OPEN) and a renderer can read it. Lines are plain strings (the lines a compound component would carry are not kept) of at most 64 bytes. A changed block drops its
*> entry (WORLD-BLOCK-SET), a loaded chunk replaces those of its columns (REPLICA-CHUNK-LOAD), a cleared world drops all (WORLD-CLEAR).
*>
*>   SIGN-TEXT-FIND USING CLIENT-STATE, x, y, z, create (1 makes a blank row when there is none), row out (0 none)
*>   SIGN-TEXT-DROP USING CLIENT-STATE, x, y, z                     the row of that position is forgotten
*>   SIGN-TEXT-DROP-CHUNK USING CLIENT-STATE, chunk x, chunk z      every row of the chunk's columns
*>   SIGN-TEXT-SIDE USING CLIENT-STATE, row, side index (1 back, 2 front), PB-BUFFER   the SignText compound at PB-POS (messages, color, has_glowing_text)
*>   SIGN-TEXT-TAG USING CLIENT-STATE, x, y, z, PB-BUFFER           the network NBT update tag at PB-POS: front_text, back_text, is_waxed
*>   SIGN-TEXT-CHUNK USING CLIENT-STATE, chunk x, chunk z, count, heads, data    the sign entries of a Level Chunk's block entity list (the heads of PB-GET-CHUNK-24)

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SIGN-TEXT-FIND.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-I                   BINARY-LONG.
 01 WS-S                   BINARY-LONG.
 01 WS-L                   BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-CREATE               BINARY-LONG.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-X L-Y L-Z L-CREATE L-ROW.
     MOVE 0 TO L-ROW
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 256 OR L-ROW > 0
         IF SN-USED(WS-I) = 1 AND SN-X(WS-I) = L-X AND SN-Y(WS-I) = L-Y AND SN-Z(WS-I) = L-Z
             MOVE WS-I TO L-ROW
         END-IF
     END-PERFORM
     IF L-ROW = 0 AND L-CREATE = 1
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 256 OR L-ROW > 0
             IF SN-USED(WS-I) = 0
                 MOVE WS-I TO L-ROW
             END-IF
         END-PERFORM
         IF L-ROW > 0
             MOVE 1 TO SN-USED(L-ROW)
             MOVE L-X TO SN-X(L-ROW)
             MOVE L-Y TO SN-Y(L-ROW)
             MOVE L-Z TO SN-Z(L-ROW)
             MOVE 0 TO SN-WAXED(L-ROW)
             PERFORM VARYING WS-S FROM 1 BY 1 UNTIL WS-S > 2
                 MOVE 15 TO SN-COLOR(L-ROW, WS-S)
                 MOVE 0 TO SN-GLOW(L-ROW, WS-S)
                 PERFORM VARYING WS-L FROM 1 BY 1 UNTIL WS-L > 4
                     MOVE 0 TO SN-LEN(L-ROW, WS-S, WS-L)
                     MOVE SPACES TO SN-TEXT(L-ROW, WS-S, WS-L)
                 END-PERFORM
             END-PERFORM
         END-IF
     END-IF
     GOBACK.
 END PROGRAM SIGN-TEXT-FIND.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SIGN-TEXT-DROP.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-ROW                 BINARY-LONG.
 01 WS-NO                  BINARY-LONG VALUE 0.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-X L-Y L-Z.
     CALL "SIGN-TEXT-FIND" USING CLIENT-STATE L-X L-Y L-Z WS-NO WS-ROW
     IF WS-ROW > 0
         MOVE 0 TO SN-USED(WS-ROW)
     END-IF
     GOBACK.
 END PROGRAM SIGN-TEXT-DROP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SIGN-TEXT-DROP-CHUNK.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-I                   BINARY-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-CX                   BINARY-LONG.
 01 L-CZ                   BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-CX L-CZ.
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 256
         COMPUTE WS-CX = FUNCTION INTEGER(SN-X(WS-I) / 16)
         COMPUTE WS-CZ = FUNCTION INTEGER(SN-Z(WS-I) / 16)
         IF SN-USED(WS-I) = 1 AND WS-CX = L-CX AND WS-CZ = L-CZ
             MOVE 0 TO SN-USED(WS-I)
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM SIGN-TEXT-DROP-CHUNK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SIGN-TEXT-SIDE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WN                     PIC X(64).
 01 WN-CAP                 BINARY-LONG VALUE 64.
 01 WL                     BINARY-LONG.
 01 WS-ETYPE               BINARY-LONG.
 01 WS-LIST-TYPE           BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-STR                 PIC X(1100).
 01 WS-STR-CAP             BINARY-LONG VALUE 1100.
 01 WS-STR-LEN             BINARY-LONG.
 01 WS-BYTE                BINARY-LONG.
 01 WS-NAME                PIC X(32).
 01 WS-DYE                 BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 COPY PROTO.
 01 L-ROW                  BINARY-LONG.
 01 L-SIDE                 BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-ROW L-SIDE PB-BUFFER.
     MOVE 15 TO SN-COLOR(L-ROW, L-SIDE)
     MOVE 0 TO SN-GLOW(L-ROW, L-SIDE)
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 4
         MOVE 0 TO SN-LEN(L-ROW, L-SIDE, WS-I)
         MOVE SPACES TO SN-TEXT(L-ROW, L-SIDE, WS-I)
     END-PERFORM
     MOVE 1 TO WS-ETYPE
     PERFORM UNTIL WS-ETYPE = 0 OR PB-ERROR = 1
         MOVE SPACES TO WN
         CALL "NBT-READ-COMPOUND-NEXT" USING PB-BUFFER WS-ETYPE WN WN-CAP WL
         EVALUATE TRUE
             WHEN WS-ETYPE = 0
                 CONTINUE
             WHEN WN = "messages" AND WS-ETYPE = 9
                 CALL "NBT-READ-LIST-BEGIN" USING PB-BUFFER WS-LIST-TYPE WS-COUNT
                 PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-COUNT OR PB-ERROR = 1
                     IF WS-LIST-TYPE = 8
                         MOVE SPACES TO WS-STR
                         CALL "NBT-READ-STRING" USING PB-BUFFER WS-STR WS-STR-CAP WS-STR-LEN
                         IF WS-I <= 4 AND PB-ERROR = 0
                             MOVE FUNCTION MIN(WS-STR-LEN, 64) TO SN-LEN(L-ROW, L-SIDE, WS-I)
                             MOVE WS-STR(1:64) TO SN-TEXT(L-ROW, L-SIDE, WS-I)
                         END-IF
                     ELSE
                         CALL "NBT-READ-SKIP" USING PB-BUFFER WS-LIST-TYPE
                     END-IF
                 END-PERFORM
             WHEN WN = "color" AND WS-ETYPE = 8
                 MOVE SPACES TO WS-STR
                 CALL "NBT-READ-STRING" USING PB-BUFFER WS-STR WS-STR-CAP WS-STR-LEN
                 IF PB-ERROR = 0 AND WS-STR-LEN > 0 AND WS-STR-LEN <= 32
                     MOVE SPACES TO WS-NAME
                     MOVE WS-STR(1:WS-STR-LEN) TO WS-NAME
                     CALL "BE3-DYE-ID" USING WS-NAME WS-STR-LEN WS-DYE
                     IF WS-DYE >= 0
                         MOVE WS-DYE TO SN-COLOR(L-ROW, L-SIDE)
                     END-IF
                 END-IF
             WHEN WN = "has_glowing_text" AND WS-ETYPE = 1
                 CALL "PB-GET-BYTE" USING PB-BUFFER WS-BYTE
                 IF PB-ERROR = 0 AND WS-BYTE NOT = 0
                     MOVE 1 TO SN-GLOW(L-ROW, L-SIDE)
                 END-IF
             WHEN OTHER
                 CALL "NBT-READ-SKIP" USING PB-BUFFER WS-ETYPE
         END-EVALUATE
     END-PERFORM
     GOBACK.
 END PROGRAM SIGN-TEXT-SIDE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SIGN-TEXT-TAG.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WN                     PIC X(64).
 01 WN-CAP                 BINARY-LONG VALUE 64.
 01 WL                     BINARY-LONG.
 01 WS-FRAMING             BINARY-LONG VALUE 0.
 01 WS-TYPE                BINARY-LONG.
 01 WS-ETYPE               BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-YES                 BINARY-LONG VALUE 1.
 01 WS-SIDE                BINARY-LONG.
 01 WS-BYTE                BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 COPY PROTO.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-X L-Y L-Z PB-BUFFER.
     CALL "NBT-READ-ROOT" USING PB-BUFFER WS-FRAMING WS-TYPE
     IF PB-ERROR = 0 AND WS-TYPE = 10
         CALL "SIGN-TEXT-FIND" USING CLIENT-STATE L-X L-Y L-Z WS-YES WS-ROW
         MOVE 1 TO WS-ETYPE
         PERFORM UNTIL WS-ETYPE = 0 OR PB-ERROR = 1
             MOVE SPACES TO WN
             CALL "NBT-READ-COMPOUND-NEXT" USING PB-BUFFER WS-ETYPE WN WN-CAP WL
             EVALUATE TRUE
                 WHEN WS-ETYPE = 0
                     CONTINUE
                 WHEN WS-ROW > 0 AND (WN = "front_text" OR WN = "back_text") AND WS-ETYPE = 10
                     MOVE 1 TO WS-SIDE
                     IF WN = "front_text"
                         MOVE 2 TO WS-SIDE
                     END-IF
                     CALL "SIGN-TEXT-SIDE" USING CLIENT-STATE WS-ROW WS-SIDE PB-BUFFER
                 WHEN WS-ROW > 0 AND WN = "is_waxed" AND WS-ETYPE = 1
                     CALL "PB-GET-BYTE" USING PB-BUFFER WS-BYTE
                     MOVE 0 TO SN-WAXED(WS-ROW)
                     IF PB-ERROR = 0 AND WS-BYTE NOT = 0
                         MOVE 1 TO SN-WAXED(WS-ROW)
                     END-IF
                 WHEN OTHER
                     CALL "NBT-READ-SKIP" USING PB-BUFFER WS-ETYPE
             END-EVALUATE
         END-PERFORM
     END-IF
     GOBACK.
 END PROGRAM SIGN-TEXT-TAG.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SIGN-TEXT-CHUNK.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY PROTO REPLACING LEADING ==PB-== BY ==WK-==.
 01 WS-I                   BINARY-LONG.
 01 WS-HEAD                BINARY-LONG.
 01 WS-OFFSET              BINARY-LONG.
 01 WS-LENGTH              BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-CAPACITY            BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-CX                   BINARY-LONG.
 01 L-CZ                   BINARY-LONG.
 01 L-COUNT                BINARY-LONG.
 01 L-HEADS.
    05 L-HEAD              BINARY-LONG OCCURS 2560 TIMES.
 01 L-DATA                 PIC X(262144).
 PROCEDURE DIVISION USING CLIENT-STATE L-CX L-CZ L-COUNT L-HEADS L-DATA.
     CALL "SIGN-TEXT-DROP-CHUNK" USING CLIENT-STATE L-CX L-CZ
     MOVE 0 TO WS-OFFSET
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > L-COUNT
         COMPUTE WS-HEAD = (WS-I - 1) * 5
         MOVE L-HEAD(WS-HEAD + 4) TO WS-TYPE
         MOVE L-HEAD(WS-HEAD + 5) TO WS-LENGTH
         IF (WS-TYPE = 7 OR WS-TYPE = 8) AND WS-LENGTH > 0
             COMPUTE WS-X = L-CX * 16 + L-HEAD(WS-HEAD + 1)
             MOVE L-HEAD(WS-HEAD + 2) TO WS-Y
             COMPUTE WS-Z = L-CZ * 16 + L-HEAD(WS-HEAD + 3)
             MOVE WS-LENGTH TO WS-CAPACITY
             CALL "PB-INIT" USING WK-BUFFER WS-CAPACITY
             CALL "PB-APPEND-BYTES" USING WK-BUFFER L-DATA(WS-OFFSET + 1:WS-LENGTH) WS-LENGTH
             MOVE 0 TO WK-POS
             CALL "SIGN-TEXT-TAG" USING CLIENT-STATE WS-X WS-Y WS-Z WK-BUFFER
             CALL "PB-FREE" USING WK-BUFFER
         END-IF
         ADD WS-LENGTH TO WS-OFFSET
     END-PERFORM
     GOBACK.
 END PROGRAM SIGN-TEXT-CHUNK.
