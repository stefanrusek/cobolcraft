*> Growable byte buffer of the protocol codec (contracts/proto-api.md §1, §2 "Buffer").
*> PB-ADDR points to PB-CAPACITY bytes obtained with ALLOCATE. Bytes 1 to PB-LENGTH hold data;
*> reads start after PB-POS bytes. A read that would pass PB-LENGTH sets PB-ERROR, leaves PB-POS and
*> yields zero bytes. PB-ERROR is sticky: once set, every read yields zero bytes until PB-RESET.
*> Caller areas of any size are taken as a one-byte LINKAGE item and addressed through a BASED
*> view, so -debug bounds checks apply to the count the caller passes, not to a declared size.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PB-INIT.
*> PB-INIT USING PB-BUFFER, capacity (BINARY-LONG; at least 16 bytes are allocated).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-CAPACITY            BINARY-LONG.
 LINKAGE SECTION.
 COPY PROTO.
 01 L-CAPACITY             BINARY-LONG.
 PROCEDURE DIVISION USING PB-BUFFER L-CAPACITY.
     COMPUTE WS-CAPACITY = FUNCTION MAX(L-CAPACITY, 16)
     ALLOCATE WS-CAPACITY CHARACTERS RETURNING PB-ADDR
     MOVE WS-CAPACITY TO PB-CAPACITY
     MOVE 0 TO PB-LENGTH PB-POS PB-ERROR
     GOBACK.
 END PROGRAM PB-INIT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PB-FREE.
*> PB-FREE USING PB-BUFFER: releases the memory; the buffer must be initialised again before use.
 DATA DIVISION.
 LINKAGE SECTION.
 COPY PROTO.
 PROCEDURE DIVISION USING PB-BUFFER.
     FREE PB-ADDR
     SET PB-ADDR TO NULL
     MOVE 0 TO PB-CAPACITY PB-LENGTH PB-POS PB-ERROR
     GOBACK.
 END PROGRAM PB-FREE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PB-RESET.
*> PB-RESET USING PB-BUFFER: empties the buffer and clears PB-ERROR; the memory is kept.
 DATA DIVISION.
 LINKAGE SECTION.
 COPY PROTO.
 PROCEDURE DIVISION USING PB-BUFFER.
     MOVE 0 TO PB-LENGTH PB-POS PB-ERROR
     GOBACK.
 END PROGRAM PB-RESET.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PB-APPEND-BYTES.
*> PB-APPEND-BYTES USING PB-BUFFER, bytes (any area), count (BINARY-LONG): appends the first count
*> bytes of the area, growing the buffer (at least doubling) when they do not fit.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-NEW-CAPACITY        BINARY-LONG.
 01 WS-NEW-ADDR            USAGE POINTER.
 01 B-MEM                  PIC X(1073741824) BASED.
 01 B-NEW                  PIC X(1073741824) BASED.
 01 B-SRC                  PIC X(1073741824) BASED.
 LINKAGE SECTION.
 COPY PROTO.
 01 L-BYTES                PIC X.
 01 L-COUNT                BINARY-LONG.
 PROCEDURE DIVISION USING PB-BUFFER L-BYTES L-COUNT.
     IF L-COUNT > 0
         IF PB-LENGTH + L-COUNT > PB-CAPACITY
             COMPUTE WS-NEW-CAPACITY = FUNCTION MAX(PB-CAPACITY * 2, PB-LENGTH + L-COUNT)
             ALLOCATE WS-NEW-CAPACITY CHARACTERS RETURNING WS-NEW-ADDR
             SET ADDRESS OF B-NEW TO WS-NEW-ADDR
             SET ADDRESS OF B-MEM TO PB-ADDR
             IF PB-LENGTH > 0
                 MOVE B-MEM(1:PB-LENGTH) TO B-NEW(1:PB-LENGTH)
             END-IF
             FREE PB-ADDR
             SET PB-ADDR TO WS-NEW-ADDR
             MOVE WS-NEW-CAPACITY TO PB-CAPACITY
         END-IF
         SET ADDRESS OF B-MEM TO PB-ADDR
         SET ADDRESS OF B-SRC TO ADDRESS OF L-BYTES
         MOVE B-SRC(1:L-COUNT) TO B-MEM(PB-LENGTH + 1:L-COUNT)
         ADD L-COUNT TO PB-LENGTH
     END-IF
     GOBACK.
 END PROGRAM PB-APPEND-BYTES.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PB-GET-BYTES.
*> PB-GET-BYTES USING PB-BUFFER, area, count (BINARY-LONG): copies the next count bytes into the area
*> and advances PB-POS. Past PB-LENGTH (or with PB-ERROR already set): PB-ERROR = 1, PB-POS stays,
*> the area receives count zero bytes.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 B-MEM                  PIC X(1073741824) BASED.
 01 B-DST                  PIC X(1073741824) BASED.
 LINKAGE SECTION.
 COPY PROTO.
 01 L-BYTES                PIC X.
 01 L-COUNT                BINARY-LONG.
 PROCEDURE DIVISION USING PB-BUFFER L-BYTES L-COUNT.
     IF L-COUNT > 0
         SET ADDRESS OF B-DST TO ADDRESS OF L-BYTES
         IF PB-ERROR = 1 OR L-COUNT > PB-LENGTH - PB-POS
             MOVE 1 TO PB-ERROR
             MOVE LOW-VALUES TO B-DST(1:L-COUNT)
         ELSE
             SET ADDRESS OF B-MEM TO PB-ADDR
             MOVE B-MEM(PB-POS + 1:L-COUNT) TO B-DST(1:L-COUNT)
             ADD L-COUNT TO PB-POS
         END-IF
     END-IF
     GOBACK.
 END PROGRAM PB-GET-BYTES.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PB-SKIP.
*> PB-SKIP USING PB-BUFFER, count (BINARY-LONG): advances PB-POS by count bytes. A negative count, one
*> that passes PB-LENGTH, or PB-ERROR already set: PB-ERROR = 1 and PB-POS stays.
 DATA DIVISION.
 LINKAGE SECTION.
 COPY PROTO.
 01 L-COUNT                BINARY-LONG.
 PROCEDURE DIVISION USING PB-BUFFER L-COUNT.
     IF PB-ERROR = 1 OR L-COUNT < 0 OR L-COUNT > PB-LENGTH - PB-POS
         MOVE 1 TO PB-ERROR
     ELSE
         ADD L-COUNT TO PB-POS
     END-IF
     GOBACK.
 END PROGRAM PB-SKIP.
