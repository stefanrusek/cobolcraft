*> Live pistons, part 5: saving and loading the moving block entity (docs/protocol/30-redstone-3-pistons.md section 7.6, 31-5 section 5; the block state codec of 07 section 7.3; task T29571). The entity (type 11, the cells
*> of piston-live-b.cob: BE-XI 1 the moved state id, 2 the direction, 3 extending, 4 source) is saved with the keys of saveCustomOnly: `blockState` (the block state codec: the key as a string when it is the default
*> state of its block, else a compound {id, properties}), `facing` (byte, the direction's 3D data value), `progress` (float, the value of progressO), `extending` (byte) and `source` (byte). On load `blockState` is
*> read in either form (an unknown block or a missing key is air), `facing` wraps as abs(n mod 6), and `progress` sets the progress and progressO both. A moving block that is saved in the middle of its move therefore
*> goes on from the saved progress when the chunk is read. Doc conflict, recorded: 30-3 section 7.6 names the compound keys `Name` and `Properties`; 07 section 7.3 says this version uses the lowercase `id` and
*> `properties` (as the chunk palettes of the core do), and that is followed.
*> Entry points:
*>   PISTON-BE-SAVE USING block entity index, PB-BUFFER                                   the type's own keys
*>   PISTON-BE-LOAD-KEY USING block entity index, key name (PIC X(32)), tag type, PB-BUFFER, handled out    one key of the saved compound

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PISTON-BE-SAVE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BESTATE.
 COPY CBLOCKS.
 01 WN                     PIC X(32).
 01 WL                     BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
 01 WS-NS-KEY              PIC X(64).
 01 WS-NS-LENGTH           BINARY-LONG.
 01 WS-PROPS               PIC X(160).
 01 WS-PTR                 BINARY-LONG.
 01 WS-PNAME               PIC X(24).
 01 WS-PNAME-LENGTH        BINARY-LONG.
 01 WS-PVALUE              PIC X(24).
 01 WS-PVALUE-LENGTH       BINARY-LONG.
 LINKAGE SECTION.
 COPY PROTO.
 01 L-INDEX                BINARY-LONG.
 PROCEDURE DIVISION USING L-INDEX PB-BUFFER.
     MOVE BE-XI(L-INDEX, 1) TO WS-STATE
     MOVE CB-S-BLOCK(WS-STATE + 1) TO WS-BLOCK
     CALL "PERSIST-NAMESPACED" USING CB-KEY(WS-BLOCK + 1) CB-KEY-LENGTH(WS-BLOCK + 1) WS-NS-KEY WS-NS-LENGTH
     MOVE "blockState" TO WN MOVE 10 TO WL
     IF CB-DEFAULT-STATE(WS-BLOCK + 1) = WS-STATE
         CALL "NBT-WRITE-STRING" USING PB-BUFFER WN WL WS-NS-KEY WS-NS-LENGTH
     ELSE
         CALL "NBT-WRITE-COMPOUND-BEGIN" USING PB-BUFFER WN WL
         MOVE "id" TO WN MOVE 2 TO WL
         CALL "NBT-WRITE-STRING" USING PB-BUFFER WN WL WS-NS-KEY WS-NS-LENGTH
         MOVE "properties" TO WN MOVE 10 TO WL
         CALL "NBT-WRITE-COMPOUND-BEGIN" USING PB-BUFFER WN WL
         CALL "BLOCKS-STATE-PROPS" USING WS-STATE WS-PROPS
         MOVE 1 TO WS-PTR
         PERFORM UNTIL WS-PTR > 160
             MOVE SPACES TO WS-PNAME WS-PVALUE
             MOVE 0 TO WS-PNAME-LENGTH WS-PVALUE-LENGTH
             UNSTRING WS-PROPS DELIMITED BY "=" OR "," OR SPACE
                 INTO WS-PNAME COUNT WS-PNAME-LENGTH
                      WS-PVALUE COUNT WS-PVALUE-LENGTH
                 WITH POINTER WS-PTR
             END-UNSTRING
             IF WS-PNAME-LENGTH = 0
                 EXIT PERFORM
             END-IF
             CALL "NBT-WRITE-STRING" USING PB-BUFFER WS-PNAME WS-PNAME-LENGTH WS-PVALUE WS-PVALUE-LENGTH
         END-PERFORM
         CALL "NBT-WRITE-COMPOUND-END" USING PB-BUFFER
         CALL "NBT-WRITE-COMPOUND-END" USING PB-BUFFER
     END-IF
     MOVE "facing" TO WN MOVE 6 TO WL
     CALL "NBT-WRITE-BYTE" USING PB-BUFFER WN WL BE-XI(L-INDEX, 2)
     MOVE "progress" TO WN MOVE 8 TO WL
     CALL "NBT-WRITE-FLOAT" USING PB-BUFFER WN WL BE-PROGRESS-OLD(L-INDEX)
     MOVE "extending" TO WN MOVE 9 TO WL
     CALL "NBT-WRITE-BYTE" USING PB-BUFFER WN WL BE-XI(L-INDEX, 3)
     MOVE "source" TO WN MOVE 6 TO WL
     CALL "NBT-WRITE-BYTE" USING PB-BUFFER WN WL BE-XI(L-INDEX, 4)
     GOBACK.
 END PROGRAM PISTON-BE-SAVE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PISTON-BE-LOAD-KEY.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BESTATE.
 01 WS-KEY                 PIC X(64).
 01 WS-KEY-LENGTH          BINARY-LONG.
 01 WS-KEY-CAPACITY        BINARY-LONG VALUE 64.
 01 WS-PAIRS               PIC X(160).
 01 WS-PAIR-COUNT          BINARY-LONG.
 01 WS-ELEMENT-TYPE        BINARY-LONG VALUE 10.
 01 WS-STATE               BINARY-LONG.
 01 WS-VALUE               BINARY-LONG.
 LINKAGE SECTION.
 COPY PROTO.
 01 L-INDEX                BINARY-LONG.
 01 L-NAME                 PIC X(32).
 01 L-TAG                  BINARY-LONG.
 01 L-HANDLED              BINARY-LONG.
 PROCEDURE DIVISION USING L-INDEX L-NAME L-TAG PB-BUFFER L-HANDLED.
     MOVE 0 TO L-HANDLED
     EVALUATE TRUE
         WHEN L-NAME = "blockState" AND (L-TAG = 8 OR L-TAG = 10)
             MOVE 1 TO L-HANDLED
             MOVE SPACES TO WS-KEY WS-PAIRS
             MOVE 0 TO WS-KEY-LENGTH WS-PAIR-COUNT
             IF L-TAG = 8
                 CALL "NBT-READ-STRING" USING PB-BUFFER WS-KEY WS-KEY-CAPACITY WS-KEY-LENGTH
             ELSE
                 CALL "CHUNK-NBT-PALETTE-ENTRY" USING PB-BUFFER WS-ELEMENT-TYPE WS-KEY WS-KEY-LENGTH WS-PAIRS WS-PAIR-COUNT
             END-IF
             CALL "CHUNK-NBT-BLOCK-STATE" USING WS-KEY WS-PAIRS WS-PAIR-COUNT WS-STATE
*>           an unknown block is air (setLevel: a registry that no longer holds the block)
             IF WS-STATE < 0
                 MOVE 0 TO WS-STATE
             END-IF
             MOVE WS-STATE TO BE-XI(L-INDEX, 1)
         WHEN L-NAME = "facing" AND L-TAG = 1
             MOVE 1 TO L-HANDLED
             CALL "PB-GET-BYTE" USING PB-BUFFER WS-VALUE
*>           Direction.from3DDataValue indexes the six directions with abs(n mod 6)
             COMPUTE BE-XI(L-INDEX, 2) = FUNCTION ABS(FUNCTION REM(WS-VALUE, 6))
         WHEN L-NAME = "progress" AND L-TAG = 5
             MOVE 1 TO L-HANDLED
             CALL "PB-GET-FLOAT" USING PB-BUFFER BE-PROGRESS(L-INDEX)
             MOVE BE-PROGRESS(L-INDEX) TO BE-PROGRESS-OLD(L-INDEX)
         WHEN L-NAME = "extending" AND L-TAG = 1
             MOVE 1 TO L-HANDLED
             CALL "PB-GET-BYTE" USING PB-BUFFER BE-XI(L-INDEX, 3)
         WHEN L-NAME = "source" AND L-TAG = 1
             MOVE 1 TO L-HANDLED
             CALL "PB-GET-BYTE" USING PB-BUFFER BE-XI(L-INDEX, 4)
     END-EVALUATE
     GOBACK.
 END PROGRAM PISTON-BE-LOAD-KEY.
