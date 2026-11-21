*> The start-up check of the generated packs (spec 002 US1; docs/protocol/22-extraction-tool.md §8.2, §9.2):
*> PACKS-STATUS-CHECK asks the core (CORE-PACKS-STATUS, which reads no jar and hashes nothing) about the
*> generated directory CL-GENERATED-DIR and keeps the answer in CL-PACKS-STATUS (CT-PACKS-OK, -ABSENT,
*> -INCOMPLETE, -STALE or -DAMAGED) and CL-PACKS-REASON. The title screen shows the banner for any status
*> but ok (screens/title.cob); the create-world screen and the world list refuse a standard world on it.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PACKS-STATUS-CHECK.
*> USING CLIENT-STATE (CL-GENERATED-DIR set; empty means <game directory>/generated).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-DIR                 PIC X(1100).
 LINKAGE SECTION.
 COPY CLSTATE.
 PROCEDURE DIVISION USING CLIENT-STATE.
     IF CL-GENERATED-DIR-LENGTH = 0
         STRING CL-GAME-DIR(1:CL-GAME-DIR-LENGTH) "/generated" DELIMITED BY SIZE
             INTO CL-GENERATED-DIR
         COMPUTE CL-GENERATED-DIR-LENGTH = CL-GAME-DIR-LENGTH + 10
     END-IF
     MOVE SPACES TO WS-DIR
     MOVE CL-GENERATED-DIR(1:CL-GENERATED-DIR-LENGTH) TO WS-DIR
     MOVE SPACES TO CL-PACKS-REASON
     CALL "CORE-PACKS-STATUS" USING WS-DIR CL-PACKS-STATUS CL-PACKS-REASON
     GOBACK.
 END PROGRAM PACKS-STATUS-CHECK.
