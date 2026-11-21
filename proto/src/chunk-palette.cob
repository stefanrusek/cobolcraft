*> Paletted containers of the chunk format (docs/protocol/06-chunk-format.md §5 and §6), additive to
*> the 001 functions of chunk.cob. The container is the PB-PALETTE-CONTAINER record: the kind the bits
*> byte selects (single value, indirect, direct), the bits byte itself, the palette and the entry
*> values. PB-PC-ENTRIES (4096 block states or 64 biomes) tells the strategy of 06 §5.3; an indirect
*> container's entries are palette indexes, a direct container's are global ids. The caller passes the
*> global width ceillog2(registry size) (06 §5.3): a direct container's bits byte is that width, and
*> it must be at least 9 for blocks and 4 for biomes or the receiver would read it as another kind.
*> Widths are at most 31 because ids are BINARY-LONG. The packing of 06 §6 (floor(64 / bits) entries
*> per Long, entry 0 lowest, none spanning two Longs) is shared by PB-PUT-PACKED-LONGS and
*> PB-GET-PACKED-LONGS, which the chunk packet also uses for heightmaps.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PB-PUT-PALETTE-CONTAINER.
*> USING PB-BUFFER, PB-PALETTE-CONTAINER, global bits (BINARY-LONG): bits byte, palette and Longs.
*> Single value: palette of one id, byte 0, no Longs. Indirect: byte 1 to 8 (blocks) or 1 to 3 (biomes),
*> 2 ** max(byte, 4 or 1) palette entries at most, data at max(byte, 4) bits for blocks. A value the
*> receiver would misread (06 §5.3), an entry index outside the palette or an id that is negative or
*> does not fit the width: PB-ERROR and nothing appended.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-I                   BINARY-LONG.
 01 WS-OK                  BINARY-LONG.
 01 WS-LIMIT               BINARY-LONG.
 01 WS-MINIMUM             BINARY-LONG.
 01 WS-DIRECT              BINARY-LONG.
 01 WS-DATA-BITS           BINARY-LONG.
 01 WS-CAPACITY            BINARY-LONG.
 01 WS-LARGEST             BINARY-LONG.
 01 WS-BYTE                BINARY-LONG.
 LINKAGE SECTION.
 COPY PROTO.
 01 L-GLOBAL-BITS          BINARY-LONG.
 PROCEDURE DIVISION USING PB-BUFFER PB-PALETTE-CONTAINER L-GLOBAL-BITS.
     MOVE 1 TO WS-OK
     MOVE 0 TO WS-DATA-BITS
     EVALUATE PB-PC-ENTRIES
         WHEN PB-PC-BLOCK-ENTRIES
             MOVE 8 TO WS-LIMIT
             MOVE 4 TO WS-MINIMUM
             MOVE 9 TO WS-DIRECT
         WHEN PB-PC-BIOME-ENTRIES
             MOVE 3 TO WS-LIMIT
             MOVE 1 TO WS-MINIMUM
             MOVE 4 TO WS-DIRECT
         WHEN OTHER
             MOVE 0 TO WS-OK
     END-EVALUATE
     IF WS-OK = 1
         EVALUATE PB-PC-KIND
             WHEN PB-PC-SINGLE
                 IF PB-PC-PALETTE-COUNT NOT = 1 OR PB-PC-PALETTE(1) < 0
                     MOVE 0 TO WS-OK
                 END-IF
             WHEN PB-PC-INDIRECT
                 IF PB-PC-BITS < 1 OR PB-PC-BITS > WS-LIMIT
                     MOVE 0 TO WS-OK
                 ELSE
                     COMPUTE WS-DATA-BITS = FUNCTION MAX(PB-PC-BITS, WS-MINIMUM)
                     COMPUTE WS-CAPACITY = 2 ** WS-DATA-BITS
                     IF PB-PC-PALETTE-COUNT < 1 OR PB-PC-PALETTE-COUNT > WS-CAPACITY
                         MOVE 0 TO WS-OK
                     END-IF
                 END-IF
                 PERFORM VARYING WS-I FROM 1 BY 1
                         UNTIL WS-I > PB-PC-PALETTE-COUNT OR WS-OK = 0
                     IF PB-PC-PALETTE(WS-I) < 0
                         MOVE 0 TO WS-OK
                     END-IF
                 END-PERFORM
                 PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > PB-PC-ENTRIES OR WS-OK = 0
                     IF PB-PC-VALUE(WS-I) < 0 OR PB-PC-VALUE(WS-I) >= PB-PC-PALETTE-COUNT
                         MOVE 0 TO WS-OK
                     END-IF
                 END-PERFORM
             WHEN PB-PC-DIRECT
                 IF PB-PC-BITS NOT = L-GLOBAL-BITS OR PB-PC-BITS < WS-DIRECT OR PB-PC-BITS > 31
                     MOVE 0 TO WS-OK
                 ELSE
                     MOVE PB-PC-BITS TO WS-DATA-BITS
                     COMPUTE WS-LARGEST = 2 ** WS-DATA-BITS - 1
                 END-IF
                 PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > PB-PC-ENTRIES OR WS-OK = 0
                     IF PB-PC-VALUE(WS-I) < 0 OR PB-PC-VALUE(WS-I) > WS-LARGEST
                         MOVE 0 TO WS-OK
                     END-IF
                 END-PERFORM
             WHEN OTHER
                 MOVE 0 TO WS-OK
         END-EVALUATE
     END-IF
     IF WS-OK = 0
         MOVE 1 TO PB-ERROR
         GOBACK
     END-IF
     MOVE PB-PC-BITS TO WS-BYTE
     IF PB-PC-KIND = PB-PC-SINGLE
         MOVE 0 TO WS-BYTE
     END-IF
     CALL "PB-PUT-UBYTE" USING PB-BUFFER WS-BYTE
     IF PB-PC-KIND = PB-PC-SINGLE
         CALL "PB-PUT-VARINT" USING PB-BUFFER PB-PC-PALETTE(1)
     END-IF
     IF PB-PC-KIND = PB-PC-INDIRECT
         CALL "PB-PUT-VARINT" USING PB-BUFFER PB-PC-PALETTE-COUNT
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > PB-PC-PALETTE-COUNT
             CALL "PB-PUT-VARINT" USING PB-BUFFER PB-PC-PALETTE(WS-I)
         END-PERFORM
     END-IF
     IF WS-DATA-BITS > 0
         CALL "PB-PUT-PACKED-LONGS" USING PB-BUFFER PB-PC-VALUE(1) PB-PC-ENTRIES WS-DATA-BITS
     END-IF
     GOBACK.
 END PROGRAM PB-PUT-PALETTE-CONTAINER.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PB-GET-PALETTE-CONTAINER.
*> USING PB-BUFFER, PB-PALETTE-CONTAINER (PB-PC-ENTRIES set by the caller: 4096 or 64), global bits
*> (BINARY-LONG): reads a container. The bits byte picks the kind (06 §5.3): 0 single value; 1 to 8
*> (blocks) or 1 to 3 (biomes) indirect, data at max(byte, 4) bits for blocks; above that Global at the
*> global bits whatever the byte says. The record keeps the byte in PB-PC-BITS. A negative or oversized
*> palette, a palette index past the palette, a global width outside 1 to 31, an entry count that is
*> neither 4096 nor 64 or a short read: PB-ERROR, PB-POS back at the start and a cleared record.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-START               BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-ENTRIES             BINARY-LONG.
 01 WS-WIRE                BINARY-LONG.
 01 WS-LIMIT               BINARY-LONG.
 01 WS-MINIMUM             BINARY-LONG.
 01 WS-DATA-BITS           BINARY-LONG.
 01 WS-SIZE                BINARY-LONG.
 01 WS-CAPACITY            BINARY-LONG.
 LINKAGE SECTION.
 COPY PROTO.
 01 L-GLOBAL-BITS          BINARY-LONG.
 PROCEDURE DIVISION USING PB-BUFFER PB-PALETTE-CONTAINER L-GLOBAL-BITS.
     MOVE PB-POS TO WS-START
     MOVE PB-PC-ENTRIES TO WS-ENTRIES
     MOVE 0 TO WS-DATA-BITS
     EVALUATE WS-ENTRIES
         WHEN PB-PC-BLOCK-ENTRIES
             MOVE 8 TO WS-LIMIT
             MOVE 4 TO WS-MINIMUM
         WHEN PB-PC-BIOME-ENTRIES
             MOVE 3 TO WS-LIMIT
             MOVE 1 TO WS-MINIMUM
         WHEN OTHER
             MOVE 1 TO PB-ERROR
     END-EVALUATE
     INITIALIZE PB-PALETTE-CONTAINER
     MOVE WS-ENTRIES TO PB-PC-ENTRIES
     IF PB-ERROR = 0
         CALL "PB-GET-UBYTE" USING PB-BUFFER WS-WIRE
         MOVE WS-WIRE TO PB-PC-BITS
         EVALUATE TRUE
             WHEN WS-WIRE = 0
                 MOVE PB-PC-SINGLE TO PB-PC-KIND
                 MOVE 1 TO PB-PC-PALETTE-COUNT
                 CALL "PB-GET-VARINT" USING PB-BUFFER PB-PC-PALETTE(1)
                 IF PB-PC-PALETTE(1) < 0
                     MOVE 1 TO PB-ERROR
                 END-IF
             WHEN WS-WIRE <= WS-LIMIT
                 MOVE PB-PC-INDIRECT TO PB-PC-KIND
                 COMPUTE WS-DATA-BITS = FUNCTION MAX(WS-WIRE, WS-MINIMUM)
                 COMPUTE WS-CAPACITY = 2 ** WS-DATA-BITS
                 CALL "PB-GET-VARINT" USING PB-BUFFER WS-SIZE
                 IF WS-SIZE < 1 OR WS-SIZE > WS-CAPACITY
                     MOVE 1 TO PB-ERROR
                 ELSE
                     MOVE WS-SIZE TO PB-PC-PALETTE-COUNT
                 END-IF
                 PERFORM VARYING WS-I FROM 1 BY 1
                         UNTIL WS-I > PB-PC-PALETTE-COUNT OR PB-ERROR = 1
                     CALL "PB-GET-VARINT" USING PB-BUFFER PB-PC-PALETTE(WS-I)
                     IF PB-PC-PALETTE(WS-I) < 0
                         MOVE 1 TO PB-ERROR
                     END-IF
                 END-PERFORM
             WHEN OTHER
                 MOVE PB-PC-DIRECT TO PB-PC-KIND
                 IF L-GLOBAL-BITS < 1 OR L-GLOBAL-BITS > 31
                     MOVE 1 TO PB-ERROR
                 ELSE
                     MOVE L-GLOBAL-BITS TO WS-DATA-BITS
                 END-IF
         END-EVALUATE
     END-IF
     IF PB-ERROR = 0 AND WS-DATA-BITS > 0
         CALL "PB-GET-PACKED-LONGS" USING PB-BUFFER PB-PC-VALUE(1) WS-ENTRIES WS-DATA-BITS
     END-IF
     IF PB-ERROR = 0 AND PB-PC-KIND = PB-PC-INDIRECT
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-ENTRIES OR PB-ERROR = 1
             IF PB-PC-VALUE(WS-I) >= PB-PC-PALETTE-COUNT
                 MOVE 1 TO PB-ERROR
             END-IF
         END-PERFORM
     END-IF
     IF PB-ERROR = 1
         MOVE WS-START TO PB-POS
         INITIALIZE PB-PALETTE-CONTAINER
         MOVE WS-ENTRIES TO PB-PC-ENTRIES
     END-IF
     GOBACK.
 END PROGRAM PB-GET-PALETTE-CONTAINER.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PB-PUT-PACKED-LONGS.
*> USING PB-BUFFER, values (a table of BINARY-LONG, each below 2 ** bits), count (BINARY-LONG), bits
*> (BINARY-LONG, 1 to 31): ceil(count / floor(64 / bits)) big-endian Longs, no length prefix (06 §6).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-I                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-PER-LONG            BINARY-LONG.
 01 WS-LONGS               BINARY-LONG.
 01 WS-READY               BINARY-LONG VALUE 0.
 01 WS-POW-TABLE.
    05 WS-POW              PIC 9(20) OCCURS 64 TIMES.   *> WS-POW(k) = 2 ** (k - 1)
 01 WS-WORD                PIC X(8).
 01 WS-SIGNED REDEFINES WS-WORD BINARY-DOUBLE SIGNED.
 01 WS-UNSIGNED REDEFINES WS-WORD BINARY-DOUBLE UNSIGNED.
 01 B-VALUES BASED.
    05 B-VALUE             BINARY-LONG OCCURS 4096 TIMES.
 LINKAGE SECTION.
 COPY PROTO.
 01 L-VALUES               PIC X.
 01 L-COUNT                BINARY-LONG.
 01 L-BITS                 BINARY-LONG.
 PROCEDURE DIVISION USING PB-BUFFER L-VALUES L-COUNT L-BITS.
     SET ADDRESS OF B-VALUES TO ADDRESS OF L-VALUES
     IF WS-READY = 0
         MOVE 1 TO WS-POW(1)
         PERFORM VARYING WS-J FROM 2 BY 1 UNTIL WS-J > 64
             COMPUTE WS-POW(WS-J) = WS-POW(WS-J - 1) * 2
         END-PERFORM
         MOVE 1 TO WS-READY
     END-IF
     COMPUTE WS-PER-LONG = 64 / L-BITS
     COMPUTE WS-LONGS = (L-COUNT + WS-PER-LONG - 1) / WS-PER-LONG
     MOVE 1 TO WS-I
     PERFORM WS-LONGS TIMES
         MOVE 0 TO WS-UNSIGNED
         PERFORM VARYING WS-J FROM 0 BY 1 UNTIL WS-J = WS-PER-LONG OR WS-I > L-COUNT
             COMPUTE WS-UNSIGNED = WS-UNSIGNED + B-VALUE(WS-I) * WS-POW(WS-J * L-BITS + 1)
             ADD 1 TO WS-I
         END-PERFORM
         CALL "PB-PUT-LONG" USING PB-BUFFER WS-SIGNED
     END-PERFORM
     GOBACK.
 END PROGRAM PB-PUT-PACKED-LONGS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PB-GET-PACKED-LONGS.
*> USING PB-BUFFER, values out (a table of BINARY-LONG), count, bits: reads the Longs of PB-PUT-PACKED-
*> LONGS. Fewer bytes than the Longs need: PB-ERROR and PB-POS unchanged. Padding bits are ignored.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-I                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-PER-LONG            BINARY-LONG.
 01 WS-LONGS               BINARY-LONG.
 01 WS-DIVISOR             PIC 9(20).
 01 WS-WORD                PIC X(8).
 01 WS-SIGNED REDEFINES WS-WORD BINARY-DOUBLE SIGNED.
 01 WS-UNSIGNED REDEFINES WS-WORD BINARY-DOUBLE UNSIGNED.
 01 B-VALUES BASED.
    05 B-VALUE             BINARY-LONG OCCURS 4096 TIMES.
 LINKAGE SECTION.
 COPY PROTO.
 01 L-VALUES               PIC X.
 01 L-COUNT                BINARY-LONG.
 01 L-BITS                 BINARY-LONG.
 PROCEDURE DIVISION USING PB-BUFFER L-VALUES L-COUNT L-BITS.
     SET ADDRESS OF B-VALUES TO ADDRESS OF L-VALUES
     COMPUTE WS-DIVISOR = 2 ** L-BITS
     COMPUTE WS-PER-LONG = 64 / L-BITS
     COMPUTE WS-LONGS = (L-COUNT + WS-PER-LONG - 1) / WS-PER-LONG
     IF PB-ERROR = 1 OR WS-LONGS * 8 > PB-LENGTH - PB-POS
         MOVE 1 TO PB-ERROR
         GOBACK
     END-IF
     MOVE 1 TO WS-I
     PERFORM WS-LONGS TIMES
         CALL "PB-GET-LONG" USING PB-BUFFER WS-SIGNED
         PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > WS-PER-LONG OR WS-I > L-COUNT
             DIVIDE WS-UNSIGNED BY WS-DIVISOR GIVING WS-UNSIGNED REMAINDER B-VALUE(WS-I)
             ADD 1 TO WS-I
         END-PERFORM
     END-PERFORM
     GOBACK.
 END PROGRAM PB-GET-PACKED-LONGS.
