*> Frames and paintings by /summon (docs/protocol/45-9 section 6.3, 21 section 8.9.1, 44-9 section 5.3 and 5.4; lane p49t, T39060): the final position derives from the block position (the floor of Pos), the
*> direction and the size, never from Pos itself: a frame stands at its cell's centre moved 0.46875 against the facing, a painting also 0.5 along the counter-clockwise direction for an even width and 0.5 up
*> for an even height. A painting takes the variant of its `variant` key (an unknown or absent key: the first entry of the painting_variant registry) and sends it as metadata 9 (a Holder: registry id + 1).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-P49T-HANGING.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY PROTO.
 COPY CONTENT.
 COPY PROJSTATE.
 COPY CITEMS.
 COPY BRWORLD.
 01 WS-ID-OPAL             BINARY-LONG.
 01 WS-NAME                PIC X(16).
 01 WS-NAME-LENGTH         BINARY-LONG.
 01 WS-LINE                PIC X(768).
 01 WS-TEXT                PIC X(4096).
 01 WS-DATA                PIC X(1024).
 01 WS-DISCARD             PIC X(4096).
 01 WS-EXPECTED            PIC X(1024).
 01 WS-EXPECTED-N          BINARY-DOUBLE.
 01 WS-NUM                 BINARY-DOUBLE.
 01 WS-CASE                PIC X(240).
 01 WS-J                   BINARY-LONG.
 01 WS-KEEP                BINARY-LONG.
 01 WS-KEY-TEXT            PIC X(48).
 01 WS-KEY-LENGTH          BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-SLOT                BINARY-LONG.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-BX                  BINARY-LONG.
 01 WS-BY                  BINARY-LONG.
 01 WS-BZ                  BINARY-LONG.
 01 WS-CX                  FLOAT-LONG.
 01 WS-CY                  FLOAT-LONG.
 01 WS-CZ                  FLOAT-LONG.
 01 WS-DIR                 BINARY-LONG.
 01 WS-W                   BINARY-LONG.
 01 WS-H                   BINARY-LONG.
 01 WS-VKEY                PIC X(48).
 01 WS-VID                 BINARY-LONG.
 01 WS-VW                  BINARY-LONG.
 01 WS-VH                  BINARY-LONG.
 01 WS-ENTITY-ID           PIC Z(8)9.
 01 WS-HOLDER              PIC Z(8)9.
 01 WS-SKIP                BINARY-LONG.
 01 WS-REGN                PIC X(112).
 01 WS-TOTAL               BINARY-LONG.
 01 WS-STATUS              BINARY-LONG.
 01 WS-REGKEY              PIC X(112).
 01 WS-REGKL               BINARY-LONG.
 01 WS-PAY                 PIC X(4096).
 01 WS-CAPN                BINARY-LONG VALUE 4096.
 01 WS-PAYLEN              BINARY-LONG.
 01 WS-MICRO               BINARY-DOUBLE.
 PROCEDURE DIVISION.
     CALL "PT-OPEN" USING WS-SKIP
     IF WS-SKIP = 1
         STOP RUN
     END-IF
     MOVE "Opal" TO WS-NAME
     MOVE 4 TO WS-NAME-LENGTH
     CALL "TEST-JOIN-OP" USING WS-NAME WS-NAME-LENGTH WS-ID-OPAL
     MOVE CN-PLAYER(WS-ID-OPAL) TO WS-PLAYER
     CALL "TEST-DRAIN-CHAT" USING WS-ID-OPAL WS-DISCARD
*>   HANGING-CENTRE by itself: the four horizontal facings of a 2 x 2 painting in cell (10, 64, 10), a frame facing down and up.
     MOVE 10 TO WS-BX WS-BZ
     MOVE 64 TO WS-BY
     MOVE 2 TO WS-W WS-H
     MOVE 2 TO WS-DIR
     CALL "HANGING-CENTRE" USING WS-DIR WS-BX WS-BY WS-BZ WS-W WS-H WS-CX WS-CY WS-CZ
     MOVE "centre of a 2 x 2 painting facing north (x 10.0, y 65.0, z 10.96875), micro" TO WS-CASE
     COMPUTE WS-EXPECTED-N = 10000000 + 65000000 * 1000 + 10968750 * 1000000
     COMPUTE WS-NUM = FUNCTION INTEGER(WS-CX * 1000000 + 0.5) + FUNCTION INTEGER(WS-CY * 1000000 + 0.5) * 1000 + FUNCTION INTEGER(WS-CZ * 1000000 + 0.5) * 1000000
     PERFORM ASSERT-NUM
     MOVE 3 TO WS-DIR
     CALL "HANGING-CENTRE" USING WS-DIR WS-BX WS-BY WS-BZ WS-W WS-H WS-CX WS-CY WS-CZ
     MOVE "2 x 2 facing south: x 11.0 (counter-clockwise is east), z 10.03125" TO WS-CASE
     COMPUTE WS-EXPECTED-N = 11000000 + 10031250 * 1000000
     COMPUTE WS-NUM = FUNCTION INTEGER(WS-CX * 1000000 + 0.5) + FUNCTION INTEGER(WS-CZ * 1000000 + 0.5) * 1000000
     PERFORM ASSERT-NUM
     MOVE 4 TO WS-DIR
     CALL "HANGING-CENTRE" USING WS-DIR WS-BX WS-BY WS-BZ WS-W WS-H WS-CX WS-CY WS-CZ
     MOVE "2 x 2 facing west: x 10.96875, z 11.0 (counter-clockwise is south)" TO WS-CASE
     COMPUTE WS-EXPECTED-N = 10968750 + 11000000 * 1000000
     COMPUTE WS-NUM = FUNCTION INTEGER(WS-CX * 1000000 + 0.5) + FUNCTION INTEGER(WS-CZ * 1000000 + 0.5) * 1000000
     PERFORM ASSERT-NUM
     MOVE 5 TO WS-DIR
     CALL "HANGING-CENTRE" USING WS-DIR WS-BX WS-BY WS-BZ WS-W WS-H WS-CX WS-CY WS-CZ
     MOVE "2 x 2 facing east: x 10.03125, z 10.0 (counter-clockwise is north)" TO WS-CASE
     COMPUTE WS-EXPECTED-N = 10031250 + 10000000 * 1000000
     COMPUTE WS-NUM = FUNCTION INTEGER(WS-CX * 1000000 + 0.5) + FUNCTION INTEGER(WS-CZ * 1000000 + 0.5) * 1000000
     PERFORM ASSERT-NUM
     MOVE 1 TO WS-W WS-H
     MOVE 0 TO WS-DIR
     CALL "HANGING-CENTRE" USING WS-DIR WS-BX WS-BY WS-BZ WS-W WS-H WS-CX WS-CY WS-CZ
     MOVE "a frame facing down hangs at the top of its cell: y 64.96875" TO WS-CASE
     COMPUTE WS-EXPECTED-N = 64968750
     COMPUTE WS-NUM = FUNCTION INTEGER(WS-CY * 1000000 + 0.5)
     PERFORM ASSERT-NUM
     MOVE 1 TO WS-DIR
     CALL "HANGING-CENTRE" USING WS-DIR WS-BX WS-BY WS-BZ WS-W WS-H WS-CX WS-CY WS-CZ
     MOVE "a frame facing up lies at the bottom of its cell: y 64.03125" TO WS-CASE
     COMPUTE WS-EXPECTED-N = 64031250
     COMPUTE WS-NUM = FUNCTION INTEGER(WS-CY * 1000000 + 0.5)
     PERFORM ASSERT-NUM
*>   The variants: kebab is 1 x 1 (21 section 8.9.1); another is bigger than 1 x 1; an unknown key gives the first entry (id 0).
     MOVE "kebab" TO WS-VKEY
     CALL "PAINTING-VARIANT-OF" USING WS-VKEY WS-VID WS-VW WS-VH
     MOVE "kebab is 1 x 1" TO WS-CASE
     MOVE 11 TO WS-EXPECTED-N
     COMPUTE WS-NUM = WS-VW * 10 + WS-VH
     PERFORM ASSERT-NUM
     MOVE "minecraft:fighters" TO WS-VKEY
     CALL "PAINTING-VARIANT-OF" USING WS-VKEY WS-VID WS-VW WS-VH
     MOVE "painting_variant" TO WS-REGN
     CALL "CONTENT-REGISTRY-COUNT" USING WS-REGN WS-TOTAL WS-STATUS
     MOVE "the painting_variant registry of the data pack has the 51 entries of 21 section 8.9.1" TO WS-CASE
     MOVE 51 TO WS-EXPECTED-N
     MOVE WS-TOTAL TO WS-NUM
     PERFORM ASSERT-NUM
     MOVE "fighters (a 4 x 2 painting of the placeable tag) has a larger area than kebab" TO WS-CASE
     MOVE 1 TO WS-EXPECTED-N
     MOVE 0 TO WS-NUM
     IF WS-VW * WS-VH > 1 AND WS-VID > 0
         MOVE 1 TO WS-NUM
     END-IF
     PERFORM ASSERT-NUM
     MOVE "no_such_variant" TO WS-VKEY
     CALL "PAINTING-VARIANT-OF" USING WS-VKEY WS-VID WS-VW WS-VH
     MOVE "an unknown variant key gives registry id 0" TO WS-CASE
     MOVE 0 TO WS-EXPECTED-N
     MOVE WS-VID TO WS-NUM
     PERFORM ASSERT-NUM
*>   /summon: Pos is ~0.7 ~0.3 ~0.2 of the operator; the block is the floor of it.
     COMPUTE WS-BX = FUNCTION INTEGER(PL-X(WS-PLAYER) + 0.7)
     COMPUTE WS-BY = FUNCTION INTEGER(PL-Y(WS-PLAYER) + 0.3)
     COMPUTE WS-BZ = FUNCTION INTEGER(PL-Z(WS-PLAYER) + 0.2)
     MOVE "painting" TO WS-KEY-TEXT
     MOVE "summon minecraft:painting ~0.7 ~0.3 ~0.2 {variant:'minecraft:fighters',facing:0b}" TO WS-LINE
     PERFORM DO-SUMMON
     PERFORM FIND-SLOT
     MOVE "fighters" TO WS-VKEY
     CALL "PAINTING-VARIANT-OF" USING WS-VKEY WS-VID WS-VW WS-VH
     MOVE 3 TO WS-DIR
     CALL "HANGING-CENTRE" USING WS-DIR WS-BX WS-BY WS-BZ WS-VW WS-VH WS-CX WS-CY WS-CZ
     MOVE "summoned painting: the entity stands at the centre derived from the block position and the size (x, millionths)" TO WS-CASE
     COMPUTE WS-EXPECTED-N = FUNCTION INTEGER(WS-CX * 1000000 + 0.5)
     COMPUTE WS-NUM = FUNCTION INTEGER(EN-X(WS-ROW) * 1000000 + 0.5)
     PERFORM ASSERT-NUM
     MOVE "summoned painting: y (millionths)" TO WS-CASE
     COMPUTE WS-EXPECTED-N = FUNCTION INTEGER(WS-CY * 1000000 + 0.5)
     COMPUTE WS-NUM = FUNCTION INTEGER(EN-Y(WS-ROW) * 1000000 + 0.5)
     PERFORM ASSERT-NUM
     MOVE "summoned painting: z (millionths)" TO WS-CASE
     COMPUTE WS-EXPECTED-N = FUNCTION INTEGER(WS-CZ * 1000000 + 0.5)
     COMPUTE WS-NUM = FUNCTION INTEGER(EN-Z(WS-ROW) * 1000000 + 0.5)
     PERFORM ASSERT-NUM
     MOVE "summoned painting: width and height of the variant" TO WS-CASE
     COMPUTE WS-EXPECTED-N = WS-VW * 10 + WS-VH
     COMPUTE WS-NUM = PJ-I2(WS-SLOT) * 10 + PJ-I3(WS-SLOT)
     PERFORM ASSERT-NUM
     MOVE "summoned painting: the variant's registry id" TO WS-CASE
     MOVE WS-VID TO WS-EXPECTED-N
     MOVE PJ-I4(WS-SLOT) TO WS-NUM
     PERFORM ASSERT-NUM
*>   The viewer got metadata 9 = registry id + 1.
     MOVE EN-ID(WS-ROW) TO WS-ENTITY-ID
     COMPUTE WS-HOLDER = WS-VID + 1
*>   (TEST-RUN drained the packets: the state is announced again.)
     MOVE 0 TO PJ-I8(WS-SLOT)
     CALL "DECOR-DATA-SYNC" USING WS-ROW
     CALL "P49-DRAIN-DATA" USING WS-ID-OPAL WS-DATA
     MOVE SPACES TO WS-EXPECTED
     STRING "101(" FUNCTION TRIM(WS-ENTITY-ID) ";8=I3,9=P" FUNCTION TRIM(WS-HOLDER) ")" DELIMITED BY SIZE INTO WS-EXPECTED
     MOVE 0 TO WS-NUM
     INSPECT WS-DATA TALLYING WS-NUM FOR ALL FUNCTION TRIM(WS-EXPECTED)
     MOVE "summoned painting: Set Entity Data holds the direction (8) and the variant holder (9)" TO WS-CASE
     MOVE 1 TO WS-EXPECTED-N
     PERFORM ASSERT-NUM
*>   Without a variant: registry id 0, the size of the first entry; the holder is 1.
     MOVE "summon minecraft:painting ~0.7 ~0.3 ~0.2" TO WS-LINE
     PERFORM DO-SUMMON
     PERFORM FIND-SLOT
     MOVE "summoned painting without a variant: registry id 0" TO WS-CASE
     MOVE 0 TO WS-EXPECTED-N
     MOVE PJ-I4(WS-SLOT) TO WS-NUM
     PERFORM ASSERT-NUM
     MOVE SPACES TO WS-VKEY
     CALL "PAINTING-VARIANT-OF" USING WS-VKEY WS-VID WS-VW WS-VH
     MOVE "summoned painting without a variant: the size of the first entry" TO WS-CASE
     COMPUTE WS-EXPECTED-N = WS-VW * 10 + WS-VH
     COMPUTE WS-NUM = PJ-I2(WS-SLOT) * 10 + PJ-I3(WS-SLOT)
     PERFORM ASSERT-NUM
*>   A frame facing north (Facing 2): the cell's centre moved 0.46875 south... against the facing: z + 0.5 + 0.46875; the default Facing is down.
     MOVE "item_frame" TO WS-KEY-TEXT
     MOVE "summon minecraft:item_frame ~0.7 ~0.3 ~0.2 {Facing:2b}" TO WS-LINE
     PERFORM DO-SUMMON
     MOVE "summoned frame facing north: z is the cell's centre + 0.46875 (millionths)" TO WS-CASE
     COMPUTE WS-EXPECTED-N = FUNCTION INTEGER((WS-BZ + 0.96875) * 1000000 + 0.5)
     COMPUTE WS-NUM = FUNCTION INTEGER(EN-Z(WS-ROW) * 1000000 + 0.5)
     PERFORM ASSERT-NUM
     MOVE "summoned frame facing north: x is the cell's centre (millionths)" TO WS-CASE
     COMPUTE WS-EXPECTED-N = FUNCTION INTEGER((WS-BX + 0.5) * 1000000 + 0.5)
     COMPUTE WS-NUM = FUNCTION INTEGER(EN-X(WS-ROW) * 1000000 + 0.5)
     PERFORM ASSERT-NUM
     MOVE "summoned frame facing north: y is the cell's centre (millionths)" TO WS-CASE
     COMPUTE WS-EXPECTED-N = FUNCTION INTEGER((WS-BY + 0.5) * 1000000 + 0.5)
     COMPUTE WS-NUM = FUNCTION INTEGER(EN-Y(WS-ROW) * 1000000 + 0.5)
     PERFORM ASSERT-NUM
     MOVE "summon minecraft:item_frame ~0.7 ~0.3 ~0.2" TO WS-LINE
     PERFORM DO-SUMMON
     MOVE "summoned frame without Facing hangs down: y is the top of the cell - 0.03125 (millionths)" TO WS-CASE
     COMPUTE WS-EXPECTED-N = FUNCTION INTEGER((WS-BY + 0.96875) * 1000000 + 0.5)
     COMPUTE WS-NUM = FUNCTION INTEGER(EN-Y(WS-ROW) * 1000000 + 0.5)
     PERFORM ASSERT-NUM
     STOP RUN.

 DO-SUMMON.
     COMPUTE WS-KEY-LENGTH = FUNCTION LENGTH(FUNCTION TRIM(WS-KEY-TEXT))
     MOVE SPACES TO WS-EXPECTED WS-CASE
     STRING "commands.summon.success(minecraft:" WS-KEY-TEXT(1:WS-KEY-LENGTH) ")" DELIMITED BY SIZE INTO WS-EXPECTED
     STRING "summon succeeds: " FUNCTION TRIM(WS-LINE) DELIMITED BY SIZE INTO WS-CASE
     CALL "TEST-DRAIN-CHAT" USING WS-ID-OPAL WS-DISCARD
     CALL "P49-DRAIN-DATA" USING WS-ID-OPAL WS-DATA
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING WS-CASE WS-EXPECTED WS-TEXT
     MOVE 0 TO WS-ROW
     PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > EN-COUNT
         IF EN-USED(WS-J) = 1 AND EN-PLAYER(WS-J) = 0
             COMPUTE WS-KEEP = EN-TYPE(WS-J) + 1
             IF ET-KEY(WS-KEEP) = WS-KEY-TEXT
                 MOVE WS-J TO WS-ROW
             END-IF
         END-IF
     END-PERFORM.

 FIND-SLOT.
     CALL "PJ-FIND" USING EN-ID(WS-ROW) WS-SLOT.

 ASSERT-NUM.
     MOVE WS-CASE TO TL-CASE
     CALL "TEST-EXPECT-NUMBER" USING TL-CASE WS-EXPECTED-N WS-NUM.
 END PROGRAM TEST-P49T-HANGING.

 COPY CORETEST.
 COPY CMDTEST.
 COPY P49FTEST.
 COPY PORTALTEST.
