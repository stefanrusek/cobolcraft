*> Requirements and loot contexts (docs/protocol/28 section 7; US14; T2173). Sets: 1 ITEM, 2 ENTITY, 3 LOCATION, 4 DAMAGE, 5 HIT_BLOCK.
*>   TOOL-CTX-COUNT USING set, required parameters out, optional parameters out
*>   TOOL-CTX-HAS USING set, parameter (PIC X(48)), presence out (0 absent, 1 required, 2 optional)
*>   TOOL-CTX-RUNTIME USING component key, parameter, can match out (the run-time context of the component: post_piercing_attack runs in an ENTITY context)
*>   TOOL-REQ-LEVEL-CHANCE USING base, per level above the first, level, chance out (thousandths: the enchantment_level provider, as Thorns 0.15 + 0.15 (L - 1))
*>   TOOL-REQ-LIST USING requirement results (PIC X(200): 1 or 0 per conditional effect in list order), effects applied out, mask out ("-" for none)
*>   TOOL-SLOT-ACTIVE USING slots group (any, mainhand, offhand, hand, feet, legs, chest, head, armor, body, saddle), slot, active out

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TOOL-CTX-COUNT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 CTX-ROWS.
    05 FILLER              PIC X(34) VALUE "1tool                            1".
    05 FILLER              PIC X(34) VALUE "1enchantment_level               1".
    05 FILLER              PIC X(34) VALUE "2this_entity                     1".
    05 FILLER              PIC X(34) VALUE "2enchantment_level               1".
    05 FILLER              PIC X(34) VALUE "2origin                          1".
    05 FILLER              PIC X(34) VALUE "3this_entity                     1".
    05 FILLER              PIC X(34) VALUE "3enchantment_level               1".
    05 FILLER              PIC X(34) VALUE "3origin                          1".
    05 FILLER              PIC X(34) VALUE "3enchantment_active              1".
    05 FILLER              PIC X(34) VALUE "4this_entity                     1".
    05 FILLER              PIC X(34) VALUE "4enchantment_level               1".
    05 FILLER              PIC X(34) VALUE "4origin                          1".
    05 FILLER              PIC X(34) VALUE "4damage_source                   1".
    05 FILLER              PIC X(34) VALUE "4attacking_entity                2".
    05 FILLER              PIC X(34) VALUE "4direct_attacking_entity         2".
    05 FILLER              PIC X(34) VALUE "5this_entity                     1".
    05 FILLER              PIC X(34) VALUE "5enchantment_level               1".
    05 FILLER              PIC X(34) VALUE "5origin                          1".
    05 FILLER              PIC X(34) VALUE "5block_state                     1".
 01 CTX-R REDEFINES CTX-ROWS.
    05 CTX-ROW OCCURS 19 TIMES.
       10 CTX-SET          PIC 9.
       10 CTX-NAME         PIC X(32).
       10 CTX-KIND         PIC 9.
 01 WS-I                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-SET                  BINARY-LONG.
 01 L-REQUIRED             BINARY-LONG.
 01 L-OPTIONAL             BINARY-LONG.
 PROCEDURE DIVISION USING L-SET L-REQUIRED L-OPTIONAL.
     MOVE 0 TO L-REQUIRED L-OPTIONAL
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 19
         IF CTX-SET(WS-I) = L-SET
             IF CTX-KIND(WS-I) = 1
                 ADD 1 TO L-REQUIRED
             ELSE
                 ADD 1 TO L-OPTIONAL
             END-IF
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM TOOL-CTX-COUNT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TOOL-CTX-HAS.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 CTX-ROWS.
    05 FILLER              PIC X(34) VALUE "1tool                            1".
    05 FILLER              PIC X(34) VALUE "1enchantment_level               1".
    05 FILLER              PIC X(34) VALUE "2this_entity                     1".
    05 FILLER              PIC X(34) VALUE "2enchantment_level               1".
    05 FILLER              PIC X(34) VALUE "2origin                          1".
    05 FILLER              PIC X(34) VALUE "3this_entity                     1".
    05 FILLER              PIC X(34) VALUE "3enchantment_level               1".
    05 FILLER              PIC X(34) VALUE "3origin                          1".
    05 FILLER              PIC X(34) VALUE "3enchantment_active              1".
    05 FILLER              PIC X(34) VALUE "4this_entity                     1".
    05 FILLER              PIC X(34) VALUE "4enchantment_level               1".
    05 FILLER              PIC X(34) VALUE "4origin                          1".
    05 FILLER              PIC X(34) VALUE "4damage_source                   1".
    05 FILLER              PIC X(34) VALUE "4attacking_entity                2".
    05 FILLER              PIC X(34) VALUE "4direct_attacking_entity         2".
    05 FILLER              PIC X(34) VALUE "5this_entity                     1".
    05 FILLER              PIC X(34) VALUE "5enchantment_level               1".
    05 FILLER              PIC X(34) VALUE "5origin                          1".
    05 FILLER              PIC X(34) VALUE "5block_state                     1".
 01 CTX-R REDEFINES CTX-ROWS.
    05 CTX-ROW OCCURS 19 TIMES.
       10 CTX-SET          PIC 9.
       10 CTX-NAME         PIC X(32).
       10 CTX-KIND         PIC 9.
 01 WS-I                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-SET                  BINARY-LONG.
 01 L-PARAM                PIC X(48).
 01 L-PRESENCE             BINARY-LONG.
 PROCEDURE DIVISION USING L-SET L-PARAM L-PRESENCE.
     MOVE 0 TO L-PRESENCE
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 19
         IF CTX-SET(WS-I) = L-SET AND CTX-NAME(WS-I) = L-PARAM
             MOVE CTX-KIND(WS-I) TO L-PRESENCE
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM TOOL-CTX-HAS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TOOL-CTX-RUNTIME.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-LOAD                BINARY-LONG.
 01 WS-RUN                 BINARY-LONG.
 01 WS-PRESENCE            BINARY-LONG.
 LINKAGE SECTION.
 01 L-KEY                  PIC X(48).
 01 L-PARAM                PIC X(48).
 01 L-CAN                  BINARY-LONG.
 PROCEDURE DIVISION USING L-KEY L-PARAM L-CAN.
     CALL "TOOL-EFFECT-RUNTIME-SET" USING L-KEY WS-LOAD WS-RUN
     CALL "TOOL-CTX-HAS" USING WS-RUN L-PARAM WS-PRESENCE
     MOVE 0 TO L-CAN
     IF WS-PRESENCE > 0
         MOVE 1 TO L-CAN
     END-IF
     GOBACK.
 END PROGRAM TOOL-CTX-RUNTIME.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TOOL-REQ-LEVEL-CHANCE.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-BASE                 BINARY-LONG.
 01 L-PER-LEVEL            BINARY-LONG.
 01 L-LEVEL                BINARY-LONG.
 01 L-CHANCE               BINARY-LONG.
 PROCEDURE DIVISION USING L-BASE L-PER-LEVEL L-LEVEL L-CHANCE.
     COMPUTE L-CHANCE = L-BASE + L-PER-LEVEL * (L-LEVEL - 1)
     GOBACK.
 END PROGRAM TOOL-REQ-LEVEL-CHANCE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TOOL-REQ-LIST.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-TOKENS.
    05 WS-TOKEN            PIC X(16) OCCURS 60 TIMES.
 01 WS-COUNT               BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-POINTER             BINARY-LONG.
 LINKAGE SECTION.
 01 L-RESULTS              PIC X(200).
 01 L-APPLIED              BINARY-LONG.
 01 L-MASK                 PIC X(48).
 PROCEDURE DIVISION USING L-RESULTS L-APPLIED L-MASK.
     MOVE 0 TO L-APPLIED
     MOVE SPACES TO L-MASK
     CALL "TOOL-LBV-TOKENS" USING L-RESULTS WS-TOKENS WS-COUNT
     MOVE 1 TO WS-POINTER
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-COUNT
         IF WS-TOKEN(WS-I)(1:1) = "1"
             ADD 1 TO L-APPLIED
         END-IF
         STRING WS-TOKEN(WS-I)(1:1) DELIMITED BY SIZE INTO L-MASK WITH POINTER WS-POINTER
     END-PERFORM
     IF WS-COUNT = 0
         MOVE "-" TO L-MASK
     END-IF
     GOBACK.
 END PROGRAM TOOL-REQ-LIST.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TOOL-SLOT-ACTIVE.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-GROUP                PIC X(48).
 01 L-SLOT                 PIC X(48).
 01 L-ACTIVE               BINARY-LONG.
 PROCEDURE DIVISION USING L-GROUP L-SLOT L-ACTIVE.
     MOVE 0 TO L-ACTIVE
     EVALUATE TRUE
         WHEN L-GROUP = "any"
             MOVE 1 TO L-ACTIVE
         WHEN L-GROUP = "armor"
             IF L-SLOT = "feet" OR "legs" OR "chest" OR "head"
                 MOVE 1 TO L-ACTIVE
             END-IF
         WHEN L-GROUP = "hand"
             IF L-SLOT = "mainhand" OR "offhand"
                 MOVE 1 TO L-ACTIVE
             END-IF
         WHEN L-GROUP = L-SLOT
             MOVE 1 TO L-ACTIVE
     END-EVALUATE
     GOBACK.
 END PROGRAM TOOL-SLOT-ACTIVE.
