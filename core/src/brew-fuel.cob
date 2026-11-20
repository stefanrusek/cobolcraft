*> The brewing fuel (docs/protocol/57-client-closures-2 section 5; 25-5 section 2.4, 31-2 section 4): the data component brewing_fuel (id 86) is set on blaze_powder only. Its two members are
*> references to data providers: the uses (a charge is one brew start) to context_int_provider brewing/uses_default (the constant 20) and the speed multiplier to context_float_provider
*> brewing/speed_default (the constant 1.0). The providers are the entries loaded by FURN-PROVIDERS-LOAD; a missing one leaves 0 charges and the speed 1.0.
*>
*>   BREW-FUEL USING item id, fast (1 or 0, as FURN-FUEL), charges out (0 for an item that is no brewing fuel), speed multiplier out (FLOAT-LONG)
*>   BREW-FLOAT-LOOKUP USING key (X(112), without namespace), payload out (X(2048)), length out, found out: the text of an entry of context_float_provider

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BREW-FLOAT-LOOKUP.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CTSHAPE.
 01 B-TEXT                 PIC X(2048) BASED.
 01 WS-REGISTRY            PIC X(48) VALUE "context_float_provider".
 01 WS-WANT                PIC X(112).
 01 WS-ROW                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-KEY                  PIC X(112).
 01 L-PAYLOAD              PIC X(2048).
 01 L-LENGTH               BINARY-LONG.
 01 L-FOUND                BINARY-LONG.
 PROCEDURE DIVISION USING L-KEY L-PAYLOAD L-LENGTH L-FOUND.
     MOVE 0 TO L-FOUND L-LENGTH
     MOVE SPACES TO L-PAYLOAD
     MOVE SPACES TO WS-WANT
     STRING "minecraft:" FUNCTION TRIM(L-KEY) DELIMITED BY SIZE INTO WS-WANT
     CALL "SHAPE-FIND" USING WS-REGISTRY WS-WANT WS-ROW
     IF WS-ROW > 0 AND SH-E-LENGTH(WS-ROW) <= 2048
         SET ADDRESS OF B-TEXT TO SH-E-ADDR(WS-ROW)
         MOVE SH-E-LENGTH(WS-ROW) TO L-LENGTH
         MOVE B-TEXT(1:L-LENGTH) TO L-PAYLOAD(1:L-LENGTH)
         MOVE 1 TO L-FOUND
     END-IF
     GOBACK.
 END PROGRAM BREW-FLOAT-LOOKUP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BREW-FUEL.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CONTENT.
 01 WS-NAME                PIC X(32) VALUE "brewing_fuel".
 01 WS-VALUE               PIC X(100).
 01 WS-STATUS              BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-PAYLOAD             PIC X(2048).
 01 WS-LENGTH              BINARY-LONG.
 01 WS-FOUND               BINARY-LONG.
 01 WS-OK                  BINARY-LONG.
 01 WS-NUMBER              FLOAT-LONG.
 LINKAGE SECTION.
 01 L-ITEM                 BINARY-LONG.
 01 L-FAST                 BINARY-LONG.
 01 L-USES                 BINARY-LONG.
 01 L-SPEED                FLOAT-LONG.
 PROCEDURE DIVISION USING L-ITEM L-FAST L-USES L-SPEED.
     MOVE 0 TO L-USES
     MOVE 1 TO L-SPEED
     CALL "CONTENT-ITEM-COMPONENT" USING L-ITEM WS-NAME WS-VALUE WS-STATUS
     IF WS-STATUS NOT = CT-OK
         GOBACK
     END-IF
     MOVE "brewing/uses_default" TO WS-KEY
     CALL "BE2-PROVIDER-LOOKUP" USING WS-KEY WS-PAYLOAD WS-LENGTH WS-FOUND
     IF WS-FOUND = 1
         CALL "BE2-PROVIDER-EVAL" USING WS-PAYLOAD WS-LENGTH L-FAST WS-NUMBER WS-OK
         IF WS-OK = 1
             COMPUTE L-USES = FUNCTION INTEGER(WS-NUMBER)
         END-IF
     END-IF
     MOVE "brewing/speed_default" TO WS-KEY
     CALL "BREW-FLOAT-LOOKUP" USING WS-KEY WS-PAYLOAD WS-LENGTH WS-FOUND
     IF WS-FOUND = 1
         CALL "BE2-PROVIDER-EVAL" USING WS-PAYLOAD WS-LENGTH L-FAST WS-NUMBER WS-OK
         IF WS-OK = 1
             MOVE WS-NUMBER TO L-SPEED
         END-IF
     END-IF
     GOBACK.
 END PROGRAM BREW-FUEL.
