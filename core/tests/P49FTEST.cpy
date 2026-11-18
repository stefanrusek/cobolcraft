*> Helper of the lane p49f entity data tests (COPY after the test program, touch the test after changing it).
*>   P49-DRAIN-DATA USING connection id, text out (PIC X(1024)): drains the connection; each packet is its id, a Set Entity Data (0x65) is "101(entity;index=value,...)" with the value
*>     written "R<a>/<b>/<c>" for Rotations, "I<n>" for a VarInt, byte, enum or block state, "F<x.xx>" for a float, "Z<0 or 1>" for a boolean, "S<item>x<count>" for an item stack and "V<a>/<b>/<c>" for a Vector3.
*>     Set Time (0x73) and Recipe Book Add (0x4B) are left out; packets are separated by one space.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. P49-DRAIN-DATA.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY PROTO.
 COPY PROTO REPLACING LEADING ==PB-== BY ==PK-==.
 01 WS-CAPACITY            BINARY-LONG VALUE 65536.
 01 WS-CLOSE               BINARY-LONG.
 01 WS-THRESHOLD           BINARY-LONG VALUE -1.
 01 WS-PACKET-ID           BINARY-LONG.
 01 WS-OUTCOME             BINARY-LONG.
 01 WS-PTR                 BINARY-LONG.
 01 WS-A                   BINARY-LONG.
 01 WS-FIRST               BINARY-LONG.
 01 WS-E1                  PIC -(9)9.
 01 WS-E2                  PIC -(9)9.
 01 WS-F1                  PIC -(6)9.99.
 01 WS-F2                  PIC -(6)9.99.
 01 WS-F3                  PIC -(6)9.99.
 01 WS-FL                  FLOAT-LONG.
 LINKAGE SECTION.
 01 L-ID                   BINARY-LONG.
 01 L-TEXT                 PIC X(1024).
 PROCEDURE DIVISION USING L-ID L-TEXT.
     MOVE SPACES TO L-TEXT
     MOVE 1 TO WS-PTR
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "PB-INIT" USING PK-BUFFER WS-CAPACITY
     CALL "TEST-DRAIN" USING L-ID PB-BUFFER WS-CLOSE
     MOVE 0 TO WS-OUTCOME
     PERFORM UNTIL WS-OUTCOME NOT = 0
         CALL "PB-RESET" USING PK-BUFFER
         CALL "TEST-NEXT-PACKET" USING PB-BUFFER PK-BUFFER WS-THRESHOLD WS-PACKET-ID WS-OUTCOME
         IF WS-OUTCOME = 0 AND WS-PACKET-ID NOT = 115 AND WS-PACKET-ID NOT = 75
             IF WS-PTR > 1
                 STRING " " DELIMITED BY SIZE INTO L-TEXT POINTER WS-PTR
             END-IF
             MOVE WS-PACKET-ID TO WS-E1
             STRING FUNCTION TRIM(WS-E1) DELIMITED BY SIZE INTO L-TEXT POINTER WS-PTR
             IF WS-PACKET-ID = 101
                 CALL "PB-GET-VARINT" USING PK-BUFFER WS-A
                 MOVE WS-A TO WS-E1
                 STRING "(" FUNCTION TRIM(WS-E1) ";" DELIMITED BY SIZE INTO L-TEXT POINTER WS-PTR
                 MOVE 1 TO WS-FIRST
                 MOVE 0 TO PK-ERROR
                 PERFORM UNTIL PK-ERROR = 1
                     CALL "PB-GET-METADATA-ENTRY-X" USING PK-BUFFER PK-METADATA-ENTRY-X
                     IF PK-ERROR = 1 OR PK-MX-INDEX = PK-MD-END
                         EXIT PERFORM
                     END-IF
                     IF WS-FIRST = 0
                         STRING "," DELIMITED BY SIZE INTO L-TEXT POINTER WS-PTR
                     END-IF
                     MOVE 0 TO WS-FIRST
                     MOVE PK-MX-INDEX TO WS-E1
                     STRING FUNCTION TRIM(WS-E1) "=" DELIMITED BY SIZE INTO L-TEXT POINTER WS-PTR
                     EVALUATE PK-MX-SERIALIZER
                         WHEN 3
                             MOVE PK-MX-FLOAT(1) TO WS-FL
                             COMPUTE WS-F1 ROUNDED = WS-FL
                             STRING "F" FUNCTION TRIM(WS-F1) DELIMITED BY SIZE INTO L-TEXT POINTER WS-PTR
                         WHEN 8
                             MOVE PK-MX-INT TO WS-E2
                             STRING "Z" FUNCTION TRIM(WS-E2) DELIMITED BY SIZE INTO L-TEXT POINTER WS-PTR
                         WHEN 7
                             MOVE PK-MX-IS-ITEM TO WS-E1
                             MOVE PK-MX-IS-COUNT TO WS-E2
                             STRING "S" FUNCTION TRIM(WS-E1) "x" FUNCTION TRIM(WS-E2) DELIMITED BY SIZE INTO L-TEXT POINTER WS-PTR
                         WHEN 9
                             MOVE PK-MX-FLOAT(1) TO WS-FL
                             COMPUTE WS-F1 ROUNDED = WS-FL
                             MOVE PK-MX-FLOAT(2) TO WS-FL
                             COMPUTE WS-F2 ROUNDED = WS-FL
                             MOVE PK-MX-FLOAT(3) TO WS-FL
                             COMPUTE WS-F3 ROUNDED = WS-FL
                             STRING "R" FUNCTION TRIM(WS-F1) "/" FUNCTION TRIM(WS-F2) "/" FUNCTION TRIM(WS-F3)
                                 DELIMITED BY SIZE INTO L-TEXT POINTER WS-PTR
                         WHEN 39
                             MOVE PK-MX-FLOAT(1) TO WS-FL
                             COMPUTE WS-F1 ROUNDED = WS-FL
                             MOVE PK-MX-FLOAT(2) TO WS-FL
                             COMPUTE WS-F2 ROUNDED = WS-FL
                             MOVE PK-MX-FLOAT(3) TO WS-FL
                             COMPUTE WS-F3 ROUNDED = WS-FL
                             STRING "V" FUNCTION TRIM(WS-F1) "/" FUNCTION TRIM(WS-F2) "/" FUNCTION TRIM(WS-F3)
                                 DELIMITED BY SIZE INTO L-TEXT POINTER WS-PTR
                         WHEN OTHER
                             MOVE PK-MX-INT TO WS-E2
                             STRING "I" FUNCTION TRIM(WS-E2) DELIMITED BY SIZE INTO L-TEXT POINTER WS-PTR
                     END-EVALUATE
                 END-PERFORM
                 STRING ")" DELIMITED BY SIZE INTO L-TEXT POINTER WS-PTR
             END-IF
         END-IF
     END-PERFORM
     CALL "PB-FREE" USING PB-BUFFER
     CALL "PB-FREE" USING PK-BUFFER
     GOBACK.
 END PROGRAM P49-DRAIN-DATA.
