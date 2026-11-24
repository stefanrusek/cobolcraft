*> The accepted-jar accessor (22 §4.1, data-model §1): the one table of accepted jars, read from the generated
*> copybook content/copy/gen/acceptedjar.cpy. `extract` and the packs check both read it through this program;
*> neither keeps a second copy of the row.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CONTENT-ACCEPTED-JAR.
*> USING row number (BINARY-LONG, 1-based), row out (PIC X(92): GEN-ACCEPTEDJAR-ROW-WIDTH bytes of text
*> columns: version id 4, size 8, SHA-256 64, world version 4, protocol version 3, resource format 4,
*> data format 5, each left-justified and space padded), status out (BINARY-LONG: CT-OK, or CT-NOT-FOUND
*> for a row outside 1 to GEN-ACCEPTEDJAR-ROWS, the area then left as it was).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CONTENT.
 COPY ACCEPTEDJAR.
 01 WS-START               BINARY-LONG.
 LINKAGE SECTION.
 01 L-NUMBER               BINARY-LONG.
 01 L-ROW                  PIC X(92).
 01 L-STATUS               BINARY-LONG.
 PROCEDURE DIVISION USING L-NUMBER L-ROW L-STATUS.
     IF L-NUMBER < 1 OR L-NUMBER > GEN-ACCEPTEDJAR-ROWS
         MOVE CT-NOT-FOUND TO L-STATUS
         GOBACK
     END-IF
     COMPUTE WS-START = (L-NUMBER - 1) * GEN-ACCEPTEDJAR-ROW-WIDTH + 1
     MOVE GEN-ACCEPTEDJAR-DATA(WS-START:GEN-ACCEPTEDJAR-ROW-WIDTH) TO L-ROW
     MOVE CT-OK TO L-STATUS
     GOBACK.
 END PROGRAM CONTENT-ACCEPTED-JAR.
