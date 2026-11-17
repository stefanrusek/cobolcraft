*> The end of a nameless network NBT value inside the bytes of an item component (the text component of an inline holder, 54 section 18.1: a trim material or
*> pattern sent in full). ITEM-NBT-SKIP walks the tags with an explicit stack of 16 levels (no recursion): tag types 1 to 12, a compound's entries until its end tag, a
*> list's elements; the lengths are checked against the value, so a truncated or malformed value gives ok 0 and moves the position nowhere useful.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ITEM-NBT-SKIP.
*> USING value (PIC X(2048)), length, position (BINARY-LONG, 1-based, in: the first byte of the root tag type, out: the byte after the value), ok out (1 = skipped).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-TYPE                BINARY-LONG.
 01 WS-DEPTH               BINARY-LONG.
 01 WS-STACK.
    05 WS-FRAME OCCURS 16 TIMES.
       10 WS-KIND          BINARY-LONG.
       10 WS-REM           BINARY-LONG.
       10 WS-ETYPE         BINARY-LONG.
 01 WS-FAIL                BINARY-LONG.
 01 WS-DONE                BINARY-LONG.
 01 WS-NEED                BINARY-DOUBLE.
 01 WS-N                   BINARY-DOUBLE.
 01 WS-B                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-T                   BINARY-LONG.
 01 WS-ET                  BINARY-LONG.
 LINKAGE SECTION.
 01 L-V                    PIC X(2048).
 01 L-LEN                  BINARY-LONG.
 01 L-POS                  BINARY-LONG.
 01 L-OK                   BINARY-LONG.
 PROCEDURE DIVISION USING L-V L-LEN L-POS L-OK.
     MOVE 0 TO L-OK WS-DEPTH WS-FAIL WS-DONE
     IF L-POS > L-LEN OR L-POS < 1
         GOBACK
     END-IF
     COMPUTE WS-TYPE = FUNCTION ORD(L-V(L-POS:1)) - 1
     ADD 1 TO L-POS
     IF WS-TYPE < 1
         GOBACK
     END-IF
     PERFORM UNTIL WS-DONE = 1 OR WS-FAIL = 1
         IF WS-TYPE > 0
             PERFORM SKIP-PAYLOAD
         ELSE
             PERFORM NEXT-ITEM
         END-IF
     END-PERFORM
     IF WS-FAIL = 0
         MOVE 1 TO L-OK
     END-IF
     GOBACK.

*> Skips the payload of a tag of type WS-TYPE (a list or compound is entered), WS-TYPE becomes 0.
 SKIP-PAYLOAD.
     MOVE 0 TO WS-NEED
     EVALUATE WS-TYPE
         WHEN 1
             MOVE 1 TO WS-NEED
         WHEN 2
             MOVE 2 TO WS-NEED
         WHEN 3
             MOVE 4 TO WS-NEED
         WHEN 4
             MOVE 8 TO WS-NEED
         WHEN 5
             MOVE 4 TO WS-NEED
         WHEN 6
             MOVE 8 TO WS-NEED
         WHEN 7
             MOVE 4 TO WS-K
             PERFORM READ-COUNT
             IF WS-FAIL = 0
                 COMPUTE WS-NEED = 4 + WS-N
             END-IF
         WHEN 8
             MOVE 2 TO WS-K
             PERFORM READ-COUNT
             IF WS-FAIL = 0
                 COMPUTE WS-NEED = 2 + WS-N
             END-IF
         WHEN 11
             MOVE 4 TO WS-K
             PERFORM READ-COUNT
             IF WS-FAIL = 0
                 COMPUTE WS-NEED = 4 + 4 * WS-N
             END-IF
         WHEN 12
             MOVE 4 TO WS-K
             PERFORM READ-COUNT
             IF WS-FAIL = 0
                 COMPUTE WS-NEED = 4 + 8 * WS-N
             END-IF
         WHEN 9
             PERFORM ENTER-LIST
         WHEN 10
             PERFORM PUSH-FRAME
             MOVE 1 TO WS-KIND(WS-DEPTH)
         WHEN OTHER
             MOVE 1 TO WS-FAIL
     END-EVALUATE
     IF WS-FAIL = 0 AND WS-NEED > 0
         PERFORM TAKE
     END-IF
     MOVE 0 TO WS-TYPE.

*> WS-N the big-endian count of WS-K bytes (2 or 4) at the position, without moving it (a length of 4 bytes is signed: negative is a failure).
 READ-COUNT.
     MOVE 0 TO WS-N
     IF L-POS + WS-K - 1 > L-LEN
         MOVE 1 TO WS-FAIL
     ELSE
         PERFORM VARYING WS-T FROM 0 BY 1 UNTIL WS-T >= WS-K
             COMPUTE WS-B = FUNCTION ORD(L-V(L-POS + WS-T:1)) - 1
             COMPUTE WS-N = WS-N * 256 + WS-B
         END-PERFORM
         IF WS-K = 4 AND WS-N >= 2147483648
             MOVE 1 TO WS-FAIL
         END-IF
     END-IF.

*> Moves the position past WS-NEED bytes, or fails when the value ends sooner.
 TAKE.
     IF L-POS + WS-NEED - 1 > L-LEN
         MOVE 1 TO WS-FAIL
     ELSE
         ADD WS-NEED TO L-POS
     END-IF.

 PUSH-FRAME.
     IF WS-DEPTH >= 16
         MOVE 1 TO WS-FAIL
         MOVE 16 TO WS-DEPTH
     ELSE
         ADD 1 TO WS-DEPTH
     END-IF.

*> A list: the element type byte and the count; elements follow when the count is above 0 (their type must be 1 to 12).
 ENTER-LIST.
     IF L-POS + 4 > L-LEN
         MOVE 1 TO WS-FAIL
     ELSE
         COMPUTE WS-ET = FUNCTION ORD(L-V(L-POS:1)) - 1
         ADD 1 TO L-POS
         MOVE 4 TO WS-K
         PERFORM READ-COUNT
         ADD 4 TO L-POS
         IF WS-FAIL = 0 AND WS-N > 0
             IF WS-ET < 1 OR WS-ET > 12
                 MOVE 1 TO WS-FAIL
             ELSE
                 PERFORM PUSH-FRAME
                 IF WS-FAIL = 0
                     MOVE 2 TO WS-KIND(WS-DEPTH)
                     MOVE WS-N TO WS-REM(WS-DEPTH)
                     MOVE WS-ET TO WS-ETYPE(WS-DEPTH)
                 END-IF
             END-IF
         END-IF
     END-IF.

*> No payload is pending: the next entry of the innermost compound or list, or the end of the value.
 NEXT-ITEM.
     IF WS-DEPTH = 0
         MOVE 1 TO WS-DONE
     ELSE
         IF WS-KIND(WS-DEPTH) = 1
             IF L-POS > L-LEN
                 MOVE 1 TO WS-FAIL
             ELSE
                 COMPUTE WS-TYPE = FUNCTION ORD(L-V(L-POS:1)) - 1
                 ADD 1 TO L-POS
                 IF WS-TYPE = 0
                     SUBTRACT 1 FROM WS-DEPTH
                 ELSE
*>                   The entry's name: a two-byte length and the bytes.
                     MOVE 2 TO WS-K
                     PERFORM READ-COUNT
                     IF WS-FAIL = 0
                         COMPUTE WS-NEED = 2 + WS-N
                         PERFORM TAKE
                     END-IF
                 END-IF
             END-IF
         ELSE
             IF WS-REM(WS-DEPTH) = 0
                 SUBTRACT 1 FROM WS-DEPTH
             ELSE
                 SUBTRACT 1 FROM WS-REM(WS-DEPTH)
                 MOVE WS-ETYPE(WS-DEPTH) TO WS-TYPE
             END-IF
         END-IF
     END-IF.
 END PROGRAM ITEM-NBT-SKIP.
