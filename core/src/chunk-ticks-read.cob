*> The saved fluid ticks of a chunk read back from disk (docs/protocol/29 sections 4.2 and 4.5, 07 section 9; task T43521). CHUNK-NBT-READ hands the `fluid_ticks` list of the chunk to CHUNK-TICKS-READ,
*> which reads every compound {x, y, z (ints, the absolute position), i (the fluid's registry name), t (the delay in ticks), p (the priority value)} into BT-SAVED and gives the list to BT-UNPACK: the ticks
*> whose position is outside the chunk are dropped (filterTickListForChunk) and the others become pending fluid ticks of the dimension at game time + delay, ordered before every later tick (sub-tick orders
*> -size to -1 in list order). The core keeps one fluid id for each family (FLUID-SCHEDULE: 1 water, 2 lava), so `minecraft:water` and `minecraft:flowing_water` are fluid 1 and `minecraft:lava` and
*> `minecraft:flowing_lava` fluid 2; a tick of another type (an empty, unknown or mod fluid) is dropped; a list whose elements are not compounds is skipped; at most 256 ticks of a chunk are kept (BT-SAVED).
*> The block ticks (`block_ticks`) are not read, and the write side keeps the empty lists on purpose (the core does not own the saved ticks of a standard world yet: an old chunk's lists travel through
*> VFMT-COPY-OTHERS).
*> Entry points:
*>   CHUNK-TICKS-READ USING PB-BUFFER (at the first element of the list), element type, element count, dimension row, chunk x, chunk z    PB-POS is left after the list; a malformed list keeps no tick

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CHUNK-TICKS-READ.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BTSAVED.
 01 WN                     PIC X(32).
 01 WL                     BINARY-LONG.
 01 WS-CAPACITY            BINARY-LONG VALUE 32.
 01 WS-NAME                PIC X(112).
 01 WS-NAME-CAPACITY       BINARY-LONG VALUE 112.
 01 WS-NAME-LENGTH         BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-DELAY               BINARY-LONG.
 01 WS-PRIO                BINARY-LONG.
 01 WS-ID                  BINARY-LONG.
 01 WS-KIND-FLUID          BINARY-LONG VALUE 2.
 LINKAGE SECTION.
 COPY PROTO.
 01 L-ELEMENT-TYPE         BINARY-LONG.
 01 L-COUNT                BINARY-LONG.
 01 L-DIM                  BINARY-LONG.
 01 L-CX                   BINARY-LONG.
 01 L-CZ                   BINARY-LONG.
 PROCEDURE DIVISION USING PB-BUFFER L-ELEMENT-TYPE L-COUNT L-DIM L-CX L-CZ.
     MOVE 0 TO BT-SV-COUNT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > L-COUNT OR PB-ERROR = 1
         IF L-ELEMENT-TYPE NOT = 10
             CALL "NBT-READ-SKIP" USING PB-BUFFER L-ELEMENT-TYPE
         ELSE
             MOVE 0 TO WS-X WS-Y WS-Z WS-DELAY WS-PRIO WS-ID
             PERFORM UNTIL PB-ERROR = 1
                 MOVE SPACES TO WN
                 CALL "NBT-READ-COMPOUND-NEXT" USING PB-BUFFER WS-TYPE WN WS-CAPACITY WL
                 IF WS-TYPE = 0
                     EXIT PERFORM
                 END-IF
                 EVALUATE TRUE
                     WHEN WN = "x" AND WS-TYPE = 3
                         CALL "PB-GET-INT" USING PB-BUFFER WS-X
                     WHEN WN = "y" AND WS-TYPE = 3
                         CALL "PB-GET-INT" USING PB-BUFFER WS-Y
                     WHEN WN = "z" AND WS-TYPE = 3
                         CALL "PB-GET-INT" USING PB-BUFFER WS-Z
                     WHEN WN = "t" AND WS-TYPE = 3
                         CALL "PB-GET-INT" USING PB-BUFFER WS-DELAY
                     WHEN WN = "p" AND WS-TYPE = 3
                         CALL "PB-GET-INT" USING PB-BUFFER WS-PRIO
                     WHEN WN = "i" AND WS-TYPE = 8
                         MOVE SPACES TO WS-NAME
                         CALL "NBT-READ-STRING" USING PB-BUFFER WS-NAME WS-NAME-CAPACITY WS-NAME-LENGTH
                         EVALUATE TRUE
                             WHEN WS-NAME = "minecraft:water" OR WS-NAME = "minecraft:flowing_water"
                                 MOVE 1 TO WS-ID
                             WHEN WS-NAME = "minecraft:lava" OR WS-NAME = "minecraft:flowing_lava"
                                 MOVE 2 TO WS-ID
                         END-EVALUATE
                     WHEN OTHER
                         CALL "NBT-READ-SKIP" USING PB-BUFFER WS-TYPE
                 END-EVALUATE
             END-PERFORM
             IF WS-ID > 0 AND PB-ERROR = 0 AND BT-SV-COUNT < 256
                 ADD 1 TO BT-SV-COUNT
                 MOVE WS-X TO BT-SV-X(BT-SV-COUNT)
                 MOVE WS-Y TO BT-SV-Y(BT-SV-COUNT)
                 MOVE WS-Z TO BT-SV-Z(BT-SV-COUNT)
                 MOVE WS-ID TO BT-SV-ID(BT-SV-COUNT)
                 MOVE WS-DELAY TO BT-SV-DELAY(BT-SV-COUNT)
                 MOVE WS-PRIO TO BT-SV-PRIO(BT-SV-COUNT)
             END-IF
         END-IF
     END-PERFORM
     IF BT-SV-COUNT > 0 AND PB-ERROR = 0
         CALL "BT-UNPACK" USING L-DIM L-CX L-CZ WS-KIND-FLUID BT-SAVED
     END-IF
     GOBACK.
 END PROGRAM CHUNK-TICKS-READ.
