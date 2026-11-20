*> The custom suggestion providers of the command nodes (docs/protocol/57-client-closures-4 sections 2.3 and 7; core/copy/BRSUG.cpy): the Commands packet marks an argument node
*> with the Identifier of the provider the client asks for its suggestions (flag 0x10): minecraft:ask_server, minecraft:available_sounds, minecraft:summonable_entities or
*> minecraft:post_effects. BRSUG.cpy lists the nodes of the standard tree by their path of names; BR-SUGGEST-APPLY sets BR-N-SUGGEST (1 to 4) of each.
*>
*>   BR-SUGGEST-APPLY USING applied out, missing out: the rows whose path exists in the tree (applied), and the rows marked strict that do not (missing; 0 when every
*>     command the core builds like the document has its provider nodes)

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BR-SUGGEST-APPLY.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BRIGADIER.
 COPY BRSUG.
 01 WS-I                   BINARY-LONG.
 01 WS-PATH                PIC X(78).
 01 WS-POINTER             BINARY-LONG.
 01 WS-WORD                PIC X(64).
 01 WS-WORD-LENGTH         BINARY-LONG.
 01 WS-NODE                BINARY-LONG.
 01 WS-CHILD               BINARY-LONG.
 01 WS-FOUND               BINARY-LONG.
 01 WS-KIND                BINARY-LONG.
 LINKAGE SECTION.
 01 L-APPLIED              BINARY-LONG.
 01 L-MISSING              BINARY-LONG.
 PROCEDURE DIVISION USING L-APPLIED L-MISSING.
     MOVE 0 TO L-APPLIED L-MISSING
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > BRSUG-ROWS
         MOVE BRSUG-ROW(WS-I)(3:78) TO WS-PATH
         MOVE 1 TO WS-POINTER WS-NODE
         PERFORM UNTIL WS-POINTER > 78 OR WS-PATH(WS-POINTER:1) = SPACE OR WS-NODE = 0
             MOVE SPACES TO WS-WORD
             UNSTRING WS-PATH DELIMITED BY SPACE INTO WS-WORD WITH POINTER WS-POINTER
             MOVE FUNCTION LENGTH(FUNCTION TRIM(WS-WORD TRAILING)) TO WS-WORD-LENGTH
             MOVE 0 TO WS-FOUND
             MOVE BR-N-FIRST(WS-NODE) TO WS-CHILD
             PERFORM UNTIL WS-CHILD = 0 OR WS-FOUND > 0
                 IF BR-N-NAME-LENGTH(WS-CHILD) = WS-WORD-LENGTH
                         AND BR-N-NAME(WS-CHILD)(1:WS-WORD-LENGTH) = WS-WORD(1:WS-WORD-LENGTH)
                     MOVE WS-CHILD TO WS-FOUND
                 ELSE
                     MOVE BR-N-NEXT(WS-CHILD) TO WS-CHILD
                 END-IF
             END-PERFORM
             MOVE WS-FOUND TO WS-NODE
         END-PERFORM
         IF WS-NODE > 0
             COMPUTE WS-KIND = FUNCTION NUMVAL(BRSUG-ROW(WS-I)(1:1))
             MOVE WS-KIND TO BR-N-SUGGEST(WS-NODE)
             ADD 1 TO L-APPLIED
         ELSE
             IF BRSUG-ROW(WS-I)(2:1) = "1"
                 ADD 1 TO L-MISSING
             END-IF
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM BR-SUGGEST-APPLY.
