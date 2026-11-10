*> Reply text helpers of the command framework (docs/protocol/09-cobolcraft-profile.md §1: server-sent messages are `translate` components
*> whose arguments are plain literal text components): a text is built from a key, then each argument is added in order.
*>
*> Entry points (PB-TEXT of contract/copy/PROTO.cpy):
*>   BX-KEY USING PB-TEXT, key (PIC X(72), space padded): the text becomes that translate key with no arguments yet
*>   CMD-TEXT-KEY USING PB-TEXT, message (MESSAGES.cpy MK-* index): the same for a key of the system messages
*>   CMD-TEXT-ARG USING PB-TEXT, area (UTF-8), byte length: adds a literal argument (at most 1024 bytes)
*>   CMD-TEXT-INT USING PB-TEXT, integer (BINARY-LONG): adds it in decimal, `-` when negative
*>   CMD-TEXT-DOUBLE USING PB-TEXT, double (FLOAT-LONG): adds it with two digits after the point, rounded half away from zero

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BX-KEY.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 LINKAGE SECTION.
 COPY PROTO.
 01 L-KEY                  PIC X(72).
 PROCEDURE DIVISION USING PB-TEXT L-KEY.
     INITIALIZE PB-TEXT
     MOVE PB-TEXT-TRANSLATE TO PB-TX-KIND
     MOVE FUNCTION LENGTH(FUNCTION TRIM(L-KEY TRAILING)) TO PB-TX-LENGTH
     MOVE L-KEY TO PB-TX-VALUE
     GOBACK.
 END PROGRAM BX-KEY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CMD-TEXT-KEY.
*> USING PB-TEXT, message (MESSAGES.cpy MK-* index): the text becomes that translate key with no
*> arguments yet.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY MESSAGES.
 LINKAGE SECTION.
 COPY PROTO.
 01 L-MESSAGE              BINARY-LONG.
 PROCEDURE DIVISION USING PB-TEXT L-MESSAGE.
     INITIALIZE PB-TEXT
     MOVE PB-TEXT-TRANSLATE TO PB-TX-KIND
     MOVE MKEY-KEY(L-MESSAGE) TO PB-TX-VALUE
     MOVE MKEY-KEY-LENGTH(L-MESSAGE) TO PB-TX-LENGTH
     GOBACK.
 END PROGRAM CMD-TEXT-KEY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CMD-TEXT-INT.
*> USING PB-TEXT, integer (BINARY-LONG): adds it in decimal, without leading zeros, `-` when
*> negative.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-EDIT                PIC -(10)9.
 01 WS-TEXT                PIC X(16).
 01 WS-LENGTH              BINARY-LONG.
 LINKAGE SECTION.
 COPY PROTO.
 01 L-VALUE                BINARY-LONG.
 PROCEDURE DIVISION USING PB-TEXT L-VALUE.
     MOVE L-VALUE TO WS-EDIT
     MOVE FUNCTION TRIM(WS-EDIT) TO WS-TEXT
     COMPUTE WS-LENGTH = FUNCTION LENGTH(FUNCTION TRIM(WS-EDIT))
     CALL "CMD-TEXT-ARG" USING PB-TEXT WS-TEXT WS-LENGTH
     GOBACK.
 END PROGRAM CMD-TEXT-INT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CMD-TEXT-DOUBLE.
*> USING PB-TEXT, double (FLOAT-LONG): adds it with exactly two digits after the point, rounded half
*> away from zero, `-` when negative (§16.1).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-EDIT                PIC -(10)9.99.
 01 WS-TEXT                PIC X(16).
 01 WS-LENGTH              BINARY-LONG.
 LINKAGE SECTION.
 COPY PROTO.
 01 L-VALUE                FLOAT-LONG.
 PROCEDURE DIVISION USING PB-TEXT L-VALUE.
     COMPUTE WS-EDIT ROUNDED = L-VALUE
     MOVE FUNCTION TRIM(WS-EDIT) TO WS-TEXT
     COMPUTE WS-LENGTH = FUNCTION LENGTH(FUNCTION TRIM(WS-EDIT))
     CALL "CMD-TEXT-ARG" USING PB-TEXT WS-TEXT WS-LENGTH
     GOBACK.
 END PROGRAM CMD-TEXT-DOUBLE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CMD-TEXT-ARG.
*> USING PB-TEXT, area (UTF-8), byte length: adds a literal argument with the bytes (at most 1024,
*> PB-TX-ARG-VALUE's size).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-LENGTH              BINARY-LONG.
 01 B-AREA                 PIC X(1024) BASED.
 LINKAGE SECTION.
 COPY PROTO.
 01 L-AREA                 PIC X.
 01 L-LENGTH               BINARY-LONG.
 PROCEDURE DIVISION USING PB-TEXT L-AREA L-LENGTH.
     SET ADDRESS OF B-AREA TO ADDRESS OF L-AREA
     COMPUTE WS-LENGTH = FUNCTION MIN(L-LENGTH, 1024)
     ADD 1 TO PB-TX-ARG-COUNT
     MOVE SPACES TO PB-TX-ARG-VALUE(PB-TX-ARG-COUNT)
     MOVE WS-LENGTH TO PB-TX-ARG-LENGTH(PB-TX-ARG-COUNT)
     IF WS-LENGTH > 0
         MOVE B-AREA(1:WS-LENGTH) TO PB-TX-ARG-VALUE(PB-TX-ARG-COUNT)(1:WS-LENGTH)
     END-IF
     GOBACK.
 END PROGRAM CMD-TEXT-ARG.

