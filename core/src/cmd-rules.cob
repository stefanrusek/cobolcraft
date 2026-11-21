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

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RULES-RESET.
*> No arguments: every game rule back at its default (a world that is opened starts from its own saved values).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BRRULES.
 01 WS-NAME                PIC X(40) VALUE "advance_time".
 01 WS-INDEX               BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 PROCEDURE DIVISION.
     CALL "BR-RULE-FIND" USING WS-NAME WS-INDEX
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > GR-COUNT
         CALL "BR-RULE-SET" USING WS-I GR-D-VALUE(WS-I)
     END-PERFORM
     GOBACK.
 END PROGRAM RULES-RESET.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RULES-NBT-WRITE.
*> USING PB-BUFFER: the compound GameRules of level.dat (07 §9.2): one entry for each rule that is not at its default, a Byte for a boolean rule and an Int for an
*> integer rule (an absent entry is the default of 16 §13).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BRRULES.
 01 WN                     PIC X(64).
 01 WL                     BINARY-LONG.
 01 WS-NAME                PIC X(40) VALUE "advance_time".
 01 WS-INDEX               BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-INT                 BINARY-LONG.
 LINKAGE SECTION.
 COPY PROTO.
 PROCEDURE DIVISION USING PB-BUFFER.
     CALL "BR-RULE-FIND" USING WS-NAME WS-INDEX
     MOVE "GameRules" TO WN
     MOVE 9 TO WL
     CALL "NBT-WRITE-COMPOUND-BEGIN" USING PB-BUFFER WN WL
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > GR-COUNT
         IF GR-VALUE(WS-I) NOT = GR-D-VALUE(WS-I)
             MOVE SPACES TO WN
             MOVE GR-D-NAME(WS-I) TO WN
             MOVE FUNCTION LENGTH(FUNCTION TRIM(GR-D-NAME(WS-I))) TO WL
             MOVE GR-VALUE(WS-I) TO WS-INT
             IF GR-D-TYPE(WS-I) = "B"
                 CALL "NBT-WRITE-BYTE" USING PB-BUFFER WN WL WS-INT
             ELSE
                 CALL "NBT-WRITE-INT" USING PB-BUFFER WN WL WS-INT
             END-IF
         END-IF
     END-PERFORM
     CALL "NBT-WRITE-COMPOUND-END" USING PB-BUFFER
     GOBACK.
 END PROGRAM RULES-NBT-WRITE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RULES-NBT-READ.
*> USING PB-BUFFER (after the name of the compound GameRules): the entries set the rules they name (a Byte or an Int); an entry the game does not know is skipped.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BRRULES.
 01 WN                     PIC X(64).
 01 WL                     BINARY-LONG.
 01 WS-CAPACITY            BINARY-LONG VALUE 64.
 01 WS-TYPE                BINARY-LONG.
 01 WS-INDEX               BINARY-LONG.
 01 WS-VALUE               BINARY-DOUBLE.
 01 WS-INT                 BINARY-LONG.
 01 WS-RULE                PIC X(40).
 LINKAGE SECTION.
 COPY PROTO.
 PROCEDURE DIVISION USING PB-BUFFER.
     PERFORM UNTIL PB-ERROR = 1
         MOVE SPACES TO WN
         CALL "NBT-READ-COMPOUND-NEXT" USING PB-BUFFER WS-TYPE WN WS-CAPACITY WL
         IF WS-TYPE = 0
             EXIT PERFORM
         END-IF
         MOVE SPACES TO WS-RULE
         IF WL <= 40
             MOVE WN(1:WL) TO WS-RULE
         END-IF
         CALL "BR-RULE-FIND" USING WS-RULE WS-INDEX
         EVALUATE TRUE
             WHEN WS-INDEX > 0 AND WS-TYPE = 1
                 CALL "PB-GET-BYTE" USING PB-BUFFER WS-INT
                 MOVE 0 TO WS-VALUE
                 IF WS-INT NOT = 0
                     MOVE 1 TO WS-VALUE
                 END-IF
                 CALL "BR-RULE-SET" USING WS-INDEX WS-VALUE
             WHEN WS-INDEX > 0 AND WS-TYPE = 3
                 CALL "PB-GET-INT" USING PB-BUFFER WS-INT
                 MOVE WS-INT TO WS-VALUE
                 CALL "BR-RULE-SET" USING WS-INDEX WS-VALUE
             WHEN OTHER
                 CALL "NBT-READ-SKIP" USING PB-BUFFER WS-TYPE
         END-EVALUATE
     END-PERFORM
     GOBACK.
 END PROGRAM RULES-NBT-READ.
