*> The game rule store of the command framework (docs/protocol/16-commands-catalog.md §4.4, §13; core/copy/BRRULES.cpy): the
*> 59 rules with their defaults, read and set by name. The values live in the EXTERNAL GR-STATE (not persisted yet).
*>
*> Entry points:
*>   BR-RULE-FIND USING name (PIC X(40), space padded), index out (1 to GR-COUNT, 0 = no such rule): makes the store ready
*>     (every rule at its default) the first time
*>   BR-RULE-GET USING name, value out (BINARY-DOUBLE: 1 or 0 for a boolean, the integer for an integer rule; the default of
*>     a rule that does not exist is 0)
*>   BR-RULE-SET USING index, value (BINARY-DOUBLE): stores the value

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BR-RULE-FIND.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BRRULES.
 01 WS-I                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-NAME                 PIC X(40).
 01 L-INDEX                BINARY-LONG.
 PROCEDURE DIVISION USING L-NAME L-INDEX.
     IF GR-READY = 0
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > GR-COUNT
             MOVE GR-D-VALUE(WS-I) TO GR-VALUE(WS-I)
         END-PERFORM
         MOVE 1 TO GR-READY
     END-IF
     MOVE 0 TO L-INDEX
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > GR-COUNT OR L-INDEX > 0
         IF GR-D-NAME(WS-I) = L-NAME
             MOVE WS-I TO L-INDEX
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM BR-RULE-FIND.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BR-RULE-GET.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BRRULES.
 01 WS-INDEX               BINARY-LONG.
 LINKAGE SECTION.
 01 L-NAME                 PIC X(40).
 01 L-VALUE                BINARY-DOUBLE.
 PROCEDURE DIVISION USING L-NAME L-VALUE.
     CALL "BR-RULE-FIND" USING L-NAME WS-INDEX
     MOVE 0 TO L-VALUE
     IF WS-INDEX > 0
         MOVE GR-VALUE(WS-INDEX) TO L-VALUE
     END-IF
     GOBACK.
 END PROGRAM BR-RULE-GET.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BR-RULE-SET.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BRRULES.
 01 WS-ADVANCE-RULE        PIC X(40) VALUE "advance_time".
 01 WS-ADVANCE             BINARY-LONG.
 01 WS-PAUSED              BINARY-LONG.
 01 WS-RATE                FLOAT-LONG.
 LINKAGE SECTION.
 01 L-INDEX                BINARY-LONG.
 01 L-VALUE                BINARY-DOUBLE.
 PROCEDURE DIVISION USING L-INDEX L-VALUE.
     MOVE L-VALUE TO GR-VALUE(L-INDEX)
     IF GR-D-NAME(L-INDEX) = WS-ADVANCE-RULE
         CALL "BR-CLOCK-STATE" USING WS-PAUSED WS-RATE
         MOVE L-VALUE TO WS-ADVANCE
         CALL "WORLDSIM-CLOCK-SET" USING WS-ADVANCE WS-PAUSED WS-RATE
     END-IF
     GOBACK.
 END PROGRAM BR-RULE-SET.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BR-WORLD-READY.
*> No arguments: makes BR-WORLD (core/copy/BRWORLD.cpy) ready the first time: the difficulty is normal
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BRWORLD.
 PROCEDURE DIVISION.
     IF BW-READY = 0
         MOVE 1 TO BW-READY
         MOVE 6000 TO BW-AUTOSAVE-LEFT
         MOVE 2 TO BW-DIFFICULTY
     END-IF
     GOBACK.
 END PROGRAM BR-WORLD-READY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. WORLD-AUTOSAVE-TICK.
*> No arguments: once per tick (CORE-TICK): the countdown to the automatic save falls by 1; at 0 it restarts at 6000 (WT-AUTOSAVE, 33 §1.1 step 6, at 20
*> ticks a second) and the world is saved unless save-off switched the automatic saving off (BW-SAVE-OFF).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BRWORLD.
 01 WS-RATE                FLOAT-LONG VALUE 20.0.
 01 WS-SAVE                BINARY-LONG.
 PROCEDURE DIVISION.
     CALL "BR-WORLD-READY"
     CALL "WT-AUTOSAVE" USING BW-AUTOSAVE-LEFT WS-RATE WS-SAVE
     IF WS-SAVE = 1 AND BW-SAVE-OFF = 0
         CALL "WORLD-SAVE"
     END-IF
     GOBACK.
 END PROGRAM WORLD-AUTOSAVE-TICK.
