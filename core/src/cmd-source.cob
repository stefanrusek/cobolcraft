*> The command source (docs/protocol/15-commands-framework.md §2.2, §10.3; core/copy/BRRUN.cpy BR-SRC): who runs a command,
*> with which permission level, where and facing which way.
*>
*> Entry point:
*>   BR-SOURCE-OF USING sender (player row, 0 = the console): fills BR-SRC: the console holds level 4 (15 §2.2) and stands at the
*>     world spawn of the first enabled dimension facing 0, 0 (its name is Server); a player holds the level of
*>     BR-SOURCE-LEVEL and stands at their feet, facing their yaw and pitch (their name is the player's), silent 0, feet anchor

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BR-SOURCE-OF.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY BRRUN.
 01 WS-CONSOLE-NAME        PIC X(16) VALUE "Server".
 LINKAGE SECTION.
 01 L-SENDER               BINARY-LONG.
 PROCEDURE DIVISION USING L-SENDER.
     INITIALIZE BR-SRC
     MOVE L-SENDER TO BS-ROW
     IF L-SENDER = 0
         MOVE 4 TO BS-LEVEL
         MOVE CW-DIM(1) TO BS-DIM
         MOVE CW-SPAWN-X TO BS-X
         MOVE CW-SPAWN-Y TO BS-Y
         MOVE CW-SPAWN-Z TO BS-Z
         MOVE WS-CONSOLE-NAME TO BS-NAME
         MOVE 6 TO BS-NAME-LENGTH
     ELSE
         CALL "BR-SOURCE-LEVEL" USING L-SENDER BS-LEVEL
         MOVE PL-DIM(L-SENDER) TO BS-DIM
         MOVE PL-X(L-SENDER) TO BS-X
         MOVE PL-Y(L-SENDER) TO BS-Y
         MOVE PL-Z(L-SENDER) TO BS-Z
         MOVE PL-YAW(L-SENDER) TO BS-YAW
         MOVE PL-PITCH(L-SENDER) TO BS-PITCH
         MOVE PL-NAME(L-SENDER) TO BS-NAME
         MOVE PL-NAME-LENGTH(L-SENDER) TO BS-NAME-LENGTH
     END-IF
     GOBACK.
 END PROGRAM BR-SOURCE-OF.
