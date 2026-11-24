*> The built-in registry entries of the cobolcraft set (docs/design/cobolcraft-standard-core.md section 3; content-api
*> section 2). The document writes each entry as strict JSON; the generated text of builtin-registry-text.cob holds
*> that JSON and BUILTIN-REGISTRY-NBT turns it into the network NBT the Registry Data packet carries (07 section 3: the
*> root is the compound's type byte and body, no name). Types follow the form of the JSON value, the rule of the
*> fixtures of section 3.2: an integer literal is an Int, a literal with a decimal point or exponent a Float, a
*> string a String, true and false a Byte, an array a List of its first element's type (an empty one has element type
*> 0), an object a Compound in the order of the text.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BUILTIN-JSON-TYPE.
*> USING text (PIC X(4096)), position of a value (BINARY-LONG), NBT tag type out (BINARY-LONG: 1 Byte for true and
*> false, 3 Int, 5 Float, 8 String, 9 List, 10 Compound).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-I                   BINARY-LONG.
 01 WS-C                   PIC X.
 01 WS-DONE                PIC 9.
 LINKAGE SECTION.
 01 L-TEXT                 PIC X(4096).
 01 L-POS                  BINARY-LONG.
 01 L-TYPE                 BINARY-LONG.
 PROCEDURE DIVISION USING L-TEXT L-POS L-TYPE.
     MOVE L-TEXT(L-POS:1) TO WS-C
     EVALUATE TRUE
         WHEN WS-C = "{"
             MOVE 10 TO L-TYPE
         WHEN WS-C = "["
             MOVE 9 TO L-TYPE
         WHEN WS-C = '"'
             MOVE 8 TO L-TYPE
         WHEN WS-C = "t" OR WS-C = "f"
             MOVE 1 TO L-TYPE
         WHEN OTHER
             MOVE 3 TO L-TYPE
             MOVE L-POS TO WS-I
             MOVE 0 TO WS-DONE
             PERFORM UNTIL WS-DONE = 1
                 MOVE L-TEXT(WS-I:1) TO WS-C
                 EVALUATE TRUE
                     WHEN WS-C = "," OR WS-C = "]" OR WS-C = "}"
                         MOVE 1 TO WS-DONE
                     WHEN WS-C = "." OR WS-C = "e" OR WS-C = "E"
                         MOVE 5 TO L-TYPE
                         ADD 1 TO WS-I
                     WHEN OTHER
                         ADD 1 TO WS-I
                 END-EVALUATE
             END-PERFORM
     END-EVALUATE
     GOBACK.
 END PROGRAM BUILTIN-JSON-TYPE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BUILTIN-JSON-SKIP.
*> USING text, position of a value (BINARY-LONG, in and out): moves the position to the first character after the value
*> (strings, arrays and objects are skipped whole, nesting and quotes respected).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-DEPTH               BINARY-LONG.
 01 WS-C                   PIC X.
 01 WS-DONE                PIC 9.
 LINKAGE SECTION.
 01 L-TEXT                 PIC X(4096).
 01 L-POS                  BINARY-LONG.
 PROCEDURE DIVISION USING L-TEXT L-POS.
     MOVE L-TEXT(L-POS:1) TO WS-C
     MOVE 0 TO WS-DEPTH WS-DONE
     EVALUATE TRUE
         WHEN WS-C = '"'
             ADD 1 TO L-POS
             PERFORM UNTIL L-TEXT(L-POS:1) = '"'
                 ADD 1 TO L-POS
             END-PERFORM
             ADD 1 TO L-POS
         WHEN WS-C = "{" OR WS-C = "["
             PERFORM UNTIL WS-DONE = 1
                 MOVE L-TEXT(L-POS:1) TO WS-C
                 EVALUATE TRUE
                     WHEN WS-C = '"'
                         ADD 1 TO L-POS
                         PERFORM UNTIL L-TEXT(L-POS:1) = '"'
                             ADD 1 TO L-POS
                         END-PERFORM
                     WHEN WS-C = "{" OR WS-C = "["
                         ADD 1 TO WS-DEPTH
                     WHEN WS-C = "}" OR WS-C = "]"
                         SUBTRACT 1 FROM WS-DEPTH
                         IF WS-DEPTH = 0
                             MOVE 1 TO WS-DONE
                         END-IF
                 END-EVALUATE
                 ADD 1 TO L-POS
             END-PERFORM
         WHEN OTHER
             PERFORM UNTIL L-TEXT(L-POS:1) = "," OR L-TEXT(L-POS:1) = "]" OR L-TEXT(L-POS:1) = "}"
                 ADD 1 TO L-POS
             END-PERFORM
     END-EVALUATE
     GOBACK.
 END PROGRAM BUILTIN-JSON-SKIP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BUILTIN-JSON-COUNT.
*> USING text, position of a "[" (BINARY-LONG), count out, element type out (BINARY-LONG; 0 when empty): the number
*> of elements of the array and the NBT type of the first.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-POS                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-TEXT                 PIC X(4096).
 01 L-POS                  BINARY-LONG.
 01 L-COUNT                BINARY-LONG.
 01 L-TYPE                 BINARY-LONG.
 PROCEDURE DIVISION USING L-TEXT L-POS L-COUNT L-TYPE.
     MOVE 0 TO L-COUNT L-TYPE
     COMPUTE WS-POS = L-POS + 1
     PERFORM UNTIL L-TEXT(WS-POS:1) = "]"
         IF L-COUNT = 0
             CALL "BUILTIN-JSON-TYPE" USING L-TEXT WS-POS L-TYPE
         END-IF
         ADD 1 TO L-COUNT
         CALL "BUILTIN-JSON-SKIP" USING L-TEXT WS-POS
         IF L-TEXT(WS-POS:1) = ","
             ADD 1 TO WS-POS
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM BUILTIN-JSON-COUNT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BUILTIN-JSON-WRITE IS RECURSIVE.
*> USING text, position of a value (BINARY-LONG, in and out), name (PIC X(64)), name length (BINARY-LONG: 0 or more
*> for a member, -1 for a list element, -2 for the network root), PB-BUFFER: writes the value as an NBT tag.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 LOCAL-STORAGE SECTION.
 01 LS-TYPE                BINARY-LONG.
 01 LS-KEY                 PIC X(64).
 01 LS-KEY-LENGTH          BINARY-LONG.
 01 LS-COUNT               BINARY-LONG.
 01 LS-ELEMENT             BINARY-LONG.
 01 LS-I                   BINARY-LONG.
 01 LS-START               BINARY-LONG.
 01 LS-LENGTH              BINARY-LONG.
 01 LS-INT                 BINARY-LONG.
 01 LS-FLOAT               FLOAT-SHORT.
 01 LS-DOUBLE              FLOAT-LONG.
 01 LS-TOKEN               PIC X(32).
 01 LS-NO-NAME             PIC X(64).
 LINKAGE SECTION.
 COPY PROTO.
 01 L-TEXT                 PIC X(4096).
 01 L-POS                  BINARY-LONG.
 01 L-NAME                 PIC X(64).
 01 L-NAME-LENGTH          BINARY-LONG.
 PROCEDURE DIVISION USING L-TEXT L-POS L-NAME L-NAME-LENGTH PB-BUFFER.
     CALL "BUILTIN-JSON-TYPE" USING L-TEXT L-POS LS-TYPE
     EVALUATE LS-TYPE
         WHEN 10
             CALL "NBT-WRITE-COMPOUND-BEGIN" USING PB-BUFFER L-NAME L-NAME-LENGTH
             ADD 1 TO L-POS
             PERFORM UNTIL L-TEXT(L-POS:1) = "}"
                 IF L-TEXT(L-POS:1) = ","
                     ADD 1 TO L-POS
                 END-IF
*>               "key":  the key is the text between the quotes
                 COMPUTE LS-START = L-POS + 1
                 MOVE LS-START TO LS-I
                 PERFORM UNTIL L-TEXT(LS-I:1) = '"'
                     ADD 1 TO LS-I
                 END-PERFORM
                 COMPUTE LS-KEY-LENGTH = LS-I - LS-START
                 MOVE SPACES TO LS-KEY
                 MOVE L-TEXT(LS-START:LS-KEY-LENGTH) TO LS-KEY
                 COMPUTE L-POS = LS-I + 2
                 CALL "BUILTIN-JSON-WRITE" USING L-TEXT L-POS LS-KEY LS-KEY-LENGTH PB-BUFFER
             END-PERFORM
             ADD 1 TO L-POS
             CALL "NBT-WRITE-COMPOUND-END" USING PB-BUFFER
         WHEN 9
             CALL "BUILTIN-JSON-COUNT" USING L-TEXT L-POS LS-COUNT LS-ELEMENT
             CALL "NBT-WRITE-LIST-BEGIN" USING PB-BUFFER L-NAME L-NAME-LENGTH LS-ELEMENT LS-COUNT
             ADD 1 TO L-POS
             MOVE -1 TO LS-LENGTH
             PERFORM UNTIL L-TEXT(L-POS:1) = "]"
                 IF L-TEXT(L-POS:1) = ","
                     ADD 1 TO L-POS
                 END-IF
                 CALL "BUILTIN-JSON-WRITE" USING L-TEXT L-POS LS-NO-NAME LS-LENGTH PB-BUFFER
             END-PERFORM
             ADD 1 TO L-POS
             CALL "NBT-WRITE-LIST-END" USING PB-BUFFER
         WHEN 8
             COMPUTE LS-START = L-POS + 1
             MOVE LS-START TO LS-I
             PERFORM UNTIL L-TEXT(LS-I:1) = '"'
                 ADD 1 TO LS-I
             END-PERFORM
             COMPUTE LS-LENGTH = LS-I - LS-START
             CALL "NBT-WRITE-STRING" USING PB-BUFFER L-NAME L-NAME-LENGTH L-TEXT(LS-START:1) LS-LENGTH
             COMPUTE L-POS = LS-I + 1
         WHEN 1
             MOVE 0 TO LS-INT
             IF L-TEXT(L-POS:1) = "t"
                 MOVE 1 TO LS-INT
                 ADD 4 TO L-POS
             ELSE
                 ADD 5 TO L-POS
             END-IF
             CALL "NBT-WRITE-BYTE" USING PB-BUFFER L-NAME L-NAME-LENGTH LS-INT
         WHEN OTHER
             MOVE L-POS TO LS-START
             MOVE L-POS TO LS-I
             PERFORM UNTIL L-TEXT(LS-I:1) = "," OR L-TEXT(LS-I:1) = "]" OR L-TEXT(LS-I:1) = "}"
                 ADD 1 TO LS-I
             END-PERFORM
             COMPUTE LS-LENGTH = LS-I - LS-START
             MOVE SPACES TO LS-TOKEN
             MOVE L-TEXT(LS-START:LS-LENGTH) TO LS-TOKEN
             MOVE LS-I TO L-POS
             EVALUATE TRUE
                 WHEN LS-TYPE = 5 AND L-NAME-LENGTH = 16 AND L-NAME(1:16) = "coordinate_scale"
                     COMPUTE LS-DOUBLE = FUNCTION NUMVAL(LS-TOKEN)
                     CALL "NBT-WRITE-DOUBLE" USING PB-BUFFER L-NAME L-NAME-LENGTH LS-DOUBLE
                 WHEN LS-TYPE = 5
                     COMPUTE LS-FLOAT = FUNCTION NUMVAL(LS-TOKEN)
                     CALL "NBT-WRITE-FLOAT" USING PB-BUFFER L-NAME L-NAME-LENGTH LS-FLOAT
                 WHEN OTHER
                     COMPUTE LS-INT = FUNCTION NUMVAL(LS-TOKEN)
                     CALL "NBT-WRITE-INT" USING PB-BUFFER L-NAME L-NAME-LENGTH LS-INT
             END-EVALUATE
     END-EVALUATE
     GOBACK.
 END PROGRAM BUILTIN-JSON-WRITE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BUILTIN-REGISTRY-ENTRY.
*> USING registry (PIC X(48), without namespace), entry id (BINARY-LONG), key out (PIC X(112)), payload area (any
*> size), capacity (BINARY-LONG), payload length out (BINARY-LONG), status out (CT-OK; CT-NOT-FOUND for an entry with
*> no built-in text; CT-TOO-SMALL when the area is smaller than the payload, the length still given): the entry as
*> network NBT (the root compound's type byte and body).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CONTENT.
 COPY PROTO.
 01 WS-CAPACITY            BINARY-LONG VALUE 65536.
 01 WS-TEXT                PIC X(4096).
 01 WS-TEXT-LENGTH         BINARY-LONG.
 01 WS-AREA                BINARY-LONG.
 01 WS-POS                 BINARY-LONG.
 01 WS-NAME                PIC X(64).
 01 WS-ROOT                BINARY-LONG VALUE -2.
 01 B-SRC                  PIC X(65536) BASED.
 01 B-DST                  PIC X(268435456) BASED.
 LINKAGE SECTION.
 01 L-REGISTRY             PIC X(48).
 01 L-ID                   BINARY-LONG.
 01 L-KEY                  PIC X(112).
 01 L-PAYLOAD              PIC X.
 01 L-CAPACITY             BINARY-LONG.
 01 L-LENGTH               BINARY-LONG.
 01 L-STATUS               BINARY-LONG.
 PROCEDURE DIVISION USING L-REGISTRY L-ID L-KEY L-PAYLOAD L-CAPACITY L-LENGTH L-STATUS.
     MOVE 0 TO L-LENGTH
     MOVE CT-NOT-FOUND TO L-STATUS
     CALL "BUILTIN-REGISTRY-TEXT" USING L-REGISTRY L-ID L-KEY WS-TEXT WS-TEXT-LENGTH
     IF WS-TEXT-LENGTH = 0
         GOBACK
     END-IF
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     MOVE 1 TO WS-POS
     MOVE SPACES TO WS-NAME
     CALL "BUILTIN-JSON-WRITE" USING WS-TEXT WS-POS WS-NAME WS-ROOT PB-BUFFER
     MOVE L-CAPACITY TO WS-AREA
     MOVE PB-LENGTH TO L-LENGTH
     IF PB-LENGTH > WS-AREA
         MOVE CT-TOO-SMALL TO L-STATUS
     ELSE
         SET ADDRESS OF B-SRC TO PB-ADDR
         SET ADDRESS OF B-DST TO ADDRESS OF L-PAYLOAD
         MOVE B-SRC(1:PB-LENGTH) TO B-DST(1:PB-LENGTH)
         MOVE CT-OK TO L-STATUS
     END-IF
     CALL "PB-FREE" USING PB-BUFFER
     GOBACK.
 END PROGRAM BUILTIN-REGISTRY-ENTRY.
