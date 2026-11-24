*> Acceptance test of the serialization and regeneration of the ocean monument (docs/protocol/36-structures-6-ocean.md section 5.11; core/src/struct-mon-build.cob MON-REGEN, MON-POST): only the building piece is in the
*> start (the builder holds one piece; the children are never in it and are not saved, so they are rebuilt from the building's box, its orientation and the level seed); regeneratePiecesAfterLoad draws one nextInt(4)
*> always, takes the orientation of the piece when it has one (else the drawn direction) and builds the whole child list again with the same draws as at generation (the child list of MON-START for the drawn direction,
*> the list of MON-LAYOUT for another one after the same draw); a monument whose child list is lost places like a fresh one (the window of the start chunk is the model's of core/tests/MONCASES.cpy).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-STRUCT-36-6-5-11.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY STRUCTMON.
 COPY STRUCTPIECE.
 COPY MTDATA.
 COPY MONCASES.
 COPY GENENT.
 01 WS-I                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-CASE                BINARY-LONG.
 01 WS-RNG                 BINARY-DOUBLE UNSIGNED.
 01 WS-SEED                BINARY-DOUBLE UNSIGNED.
 01 WS-CX                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-DIR                 BINARY-LONG.
 01 WS-DRAWN               BINARY-LONG.
 01 WS-X0                  BINARY-LONG.
 01 WS-Z0                  BINARY-LONG.
 01 WS-4                   BINARY-LONG VALUE 4.
 01 WS-NONE                BINARY-LONG VALUE -1.
 01 WS-OVER                BINARY-LONG.
 01 WS-BAD                 BINARY-LONG.
 01 WS-NAME                PIC X(160).
 01 WS-CS                  PIC -999.
 01 WS-CS2                 PIC -999.
 01 WS-SNAP.
    05 WS-S-COUNT          BINARY-LONG.
    05 WS-S-DIR            BINARY-LONG.
    05 WS-S-CHILD OCCURS 64 TIMES.
       10 WS-S-V           BINARY-LONG OCCURS 9 TIMES.
 01 WS-CASES.
    05 FILLER              PIC X(14) VALUE "00000+000+0000".
    05 FILLER              PIC X(14) VALUE "12345-003+0052".
    05 FILLER              PIC X(14) VALUE "12345+004-0061".
    05 FILLER              PIC X(14) VALUE "00777-007-0090".
 01 WS-CASE-TAB REDEFINES WS-CASES.
    05 WS-C OCCURS 4 TIMES.
       10 WS-C-SEED        PIC 9(5).
       10 WS-C-CX          PIC S999 SIGN LEADING SEPARATE.
       10 WS-C-CZ          PIC S999 SIGN LEADING SEPARATE.
       10 WS-C-DIR         PIC 9.
 01 WS-ORIENT              BINARY-LONG.
 01 WS-Y0                  BINARY-LONG VALUE 39.
 01 WS-Y1                  BINARY-LONG VALUE 61.
 01 WS-X1                  BINARY-LONG.
 01 WS-Z1                  BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-ZERO2               BINARY-LONG VALUE 0.
 01 WS-TYPE                BINARY-LONG VALUE 38.
 01 WS-BOX.
    COPY STRUCTBOX REPLACING LEADING ==BX-== BY ==B-==.
 01 WS-HASH                BINARY-DOUBLE.
 01 WS-WANT                BINARY-DOUBLE.
 01 WS-WX                  BINARY-LONG VALUE 0.
 01 WS-WZ                  BINARY-LONG VALUE 0.
 01 WS-MTS                 BINARY-LONG VALUE 1112.
 PROCEDURE DIVISION.
     MOVE "N" TO TL-MODE
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE "standard" TO CS-WORLD-TYPE
     MOVE "content/tests/fixtures/std" TO CS-GENERATED-DIR
     MOVE "12345" TO CS-SEED-TEXT
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     CALL "MT-SETUP"
     PERFORM VARYING WS-CASE FROM 1 BY 1 UNTIL WS-CASE > 4
         PERFORM CASE-RUN
     END-PERFORM
     PERFORM POST-CASE
     GOBACK.

*> one start: the child list of MON-START (the drawn direction), then MON-REGEN with the piece's orientation equal to it, with another one and with none
 CASE-RUN.
     MOVE WS-C-SEED(WS-CASE) TO WS-SEED
     MOVE WS-C-CX(WS-CASE) TO WS-CX
     MOVE WS-C-CZ(WS-CASE) TO WS-CZ
     MOVE WS-CX TO WS-CS
     MOVE WS-CZ TO WS-CS2
     COMPUTE WS-X0 = WS-CX * 16 - 29
     COMPUTE WS-Z0 = WS-CZ * 16 - 29
     CALL "MON-START" USING WS-RNG WS-SEED WS-CX WS-CZ
     PERFORM SNAP
     MOVE MO-DIR TO WS-DRAWN
     CALL "MON-REGEN" USING WS-RNG WS-SEED WS-CX WS-CZ WS-DRAWN WS-X0 WS-Z0
     PERFORM COMPARE
     MOVE SPACES TO WS-NAME
     STRING "acceptance US12 36-6§5.11 Serialization and regeneration: seed " WS-C-SEED(WS-CASE) " chunk " WS-CS "," WS-CS2 " a regenerated child list with the piece's orientation is the generated one" DELIMITED BY SIZE INTO WS-NAME
     MOVE WS-NAME TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-BAD TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   no orientation: the drawn direction
     CALL "MON-REGEN" USING WS-RNG WS-SEED WS-CX WS-CZ WS-NONE WS-X0 WS-Z0
     PERFORM COMPARE
     MOVE SPACES TO WS-NAME
     STRING "acceptance US12 36-6§5.11 Serialization and regeneration: seed " WS-C-SEED(WS-CASE) " chunk " WS-CS "," WS-CS2 " a piece without an orientation takes the direction of the one nextInt(4) it draws" DELIMITED BY SIZE INTO WS-NAME
     MOVE WS-NAME TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-BAD TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   another orientation: the direction draw is made and dropped, the layout is that of the piece's direction with the draws that follow
     COMPUTE WS-OVER = FUNCTION MOD(WS-DRAWN + 1, 4)
     CALL "MON-REGEN" USING WS-RNG WS-SEED WS-CX WS-CZ WS-OVER WS-X0 WS-Z0
     PERFORM SNAP
     CALL "JRAND-LARGE-FEATURE-SEED" USING WS-RNG WS-SEED WS-CX WS-CZ
     CALL "JRAND-NEXT-INT-BOUND" USING WS-RNG WS-4 WS-J
     CALL "MON-LAYOUT" USING WS-RNG WS-OVER WS-X0 WS-Z0
     PERFORM COMPARE
     MOVE SPACES TO WS-NAME
     STRING "acceptance US12 36-6§5.11 Serialization and regeneration: seed " WS-C-SEED(WS-CASE) " chunk " WS-CS "," WS-CS2 " the piece's own direction replaces the drawn one after the one draw" DELIMITED BY SIZE INTO WS-NAME
     MOVE WS-NAME TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-BAD TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE SPACES TO WS-NAME
     STRING "acceptance US12 36-6§5.11 Serialization and regeneration: seed " WS-C-SEED(WS-CASE) " chunk " WS-CS "," WS-CS2 " the regenerated building has the piece's direction" DELIMITED BY SIZE INTO WS-NAME
     MOVE WS-NAME TO TL-CASE
     MOVE WS-OVER TO TL-EXPECTED-N
     MOVE WS-S-DIR TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

*> the child list now in STRUCT-MONUMENT into WS-SNAP
 SNAP.
     MOVE MO-COUNT TO WS-S-COUNT
     MOVE MO-DIR TO WS-S-DIR
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > MO-COUNT
         MOVE MC-KIND(WS-I) TO WS-S-V(WS-I, 1)
         MOVE MC-INDEX(WS-I) TO WS-S-V(WS-I, 2)
         MOVE MC-DESIGN(WS-I) TO WS-S-V(WS-I, 3)
         MOVE MC-X0(WS-I) TO WS-S-V(WS-I, 4)
         MOVE MC-Y0(WS-I) TO WS-S-V(WS-I, 5)
         MOVE MC-Z0(WS-I) TO WS-S-V(WS-I, 6)
         MOVE MC-X1(WS-I) TO WS-S-V(WS-I, 7)
         MOVE MC-Y1(WS-I) TO WS-S-V(WS-I, 8)
         MOVE MC-Z1(WS-I) TO WS-S-V(WS-I, 9)
     END-PERFORM.
*> WS-BAD: the differences between the child list in STRUCT-MONUMENT and WS-SNAP (the count, the direction and every field of every child)
 COMPARE.
     MOVE 0 TO WS-BAD
     IF MO-COUNT NOT = WS-S-COUNT OR MO-DIR NOT = WS-S-DIR
         ADD 1 TO WS-BAD
     END-IF
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > MO-COUNT
         IF MC-KIND(WS-I) NOT = WS-S-V(WS-I, 1) OR MC-INDEX(WS-I) NOT = WS-S-V(WS-I, 2) OR MC-DESIGN(WS-I) NOT = WS-S-V(WS-I, 3)
            OR MC-X0(WS-I) NOT = WS-S-V(WS-I, 4) OR MC-Y0(WS-I) NOT = WS-S-V(WS-I, 5) OR MC-Z0(WS-I) NOT = WS-S-V(WS-I, 6)
            OR MC-X1(WS-I) NOT = WS-S-V(WS-I, 7) OR MC-Y1(WS-I) NOT = WS-S-V(WS-I, 8) OR MC-Z1(WS-I) NOT = WS-S-V(WS-I, 9)
             ADD 1 TO WS-BAD
         END-IF
     END-PERFORM.

*> a monument that lost its child list (and holds no other state of a start) places like a fresh one: the building piece alone is in the builder, the window of start chunk (0, 0), seed 12345, direction 1
 POST-CASE.
     MOVE 0 TO WS-X0 WS-Z0
     MOVE -29 TO WS-X0 WS-Z0
     COMPUTE WS-X1 = WS-X0 + 57
     COMPUTE WS-Z1 = WS-Z0 + 57
     COMPUTE WS-ORIENT = FUNCTION MOD(1 + 2, 4)
     CALL "SPB-BOX-NEW" USING WS-X0 WS-Y0 WS-Z0 WS-X1 WS-Y1 WS-Z1 WS-BOX
     CALL "SPB-RESET"
     CALL "SPB-ADD" USING WS-TYPE WS-ORIENT WS-ZERO WS-ZERO2 WS-BOX WS-ROW
     MOVE 12345 TO SP-SEED
     MOVE 0 TO MO-COUNT MO-DIR
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 64
         MOVE 77 TO MC-KIND(WS-I)
     END-PERFORM
     CALL "MT-WINDOW" USING WS-WX WS-WZ
     CALL "MT-SEED" USING WS-MTS
     MOVE 0 TO GEL-COUNT GEL-LOST
     CALL "MON-POST" USING WS-ROW
     CALL "MT-HASH" USING WS-WX WS-WZ WS-HASH
     MOVE MC-B-HASH(2, 13) TO WS-WANT
     MOVE "acceptance US12 36-6§5.11 Serialization and regeneration: a loaded monument (no child list) places identically to the model's fresh one" TO TL-CASE
     MOVE WS-WANT TO TL-EXPECTED-N
     MOVE WS-HASH TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 36-6§5.11 Serialization and regeneration: only the building piece is in the start, the children are not (one piece after the pass)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE SP-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

 END PROGRAM TEST-STRUCT-36-6-5-11.
 COPY MONTEST.
 COPY NOSPAWN.
 COPY CORETEST.
