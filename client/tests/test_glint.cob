*> Implementation test of client/src/glint.cob (54 section 19.3, 19.4): GLINT-TEXTURES-BUILD loads the item and the armour glint textures of the pack stack
*> (textures/misc/enchanted_glint_item.png and enchanted_glint_armor.png) into GT-ITEM and GT-ARMOR and marks textures 5 and 6 (AT-UPLOAD 6 and 7) for upload; with
*> no pack giving them nothing is loaded or marked (the glint is not drawn). GLINT-OFFSET: the translation of the texture matrix of 12 section 8.3 for the frame
*> clock CL-NOW-MS and the glint speed option (default 0.5): t = ms x speed x 8; u = -(t mod 110000) / 110000, v = (t mod 30000) / 30000. GLINT-STRENGTH: the glint
*> strength option (default 0.75).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-GLINT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLSTATE.
 COPY CLCONST.
 COPY PROTO.
 COPY TESTLIB.
 01 WS-DIR                 PIC X(64) VALUE "build/client-test-glint".
 01 WS-DIR-LENGTH          BINARY-LONG VALUE 23.
 01 WS-NAMES               PIC X(256) VALUE "glint".
 01 WS-IDS                 PIC X(256) VALUE "file/glint".
 01 WS-U                   FLOAT-LONG.
 01 WS-V                   FLOAT-LONG.
 01 WS-S                   FLOAT-LONG.
 01 WS-UI                  PIC -(5)9.
 01 WS-VI                  PIC -(5)9.
 01 WS-A                   BINARY-LONG.
 01 WS-B                   BINARY-LONG.
 01 WS-C                   BINARY-LONG.
 01 WS-D                   BINARY-LONG.
 01 WS-E                   PIC -(5)9.
 01 WS-P1                  PIC 9(4).
 01 WS-P2                  PIC 9(4).
 01 WS-P3                  PIC 9(4).
 01 WS-P4                  PIC 9(4).
 01 WS-NAME                PIC X(40).
 01 WS-VALUE               PIC X(4096).
 01 WS-LEN                 BINARY-LONG VALUE 3.
 01 WS-SPRITE              BINARY-LONG VALUE 1.
 01 WS-X0                  FLOAT-SHORT VALUE 100.
 01 WS-Y0                  FLOAT-SHORT VALUE 200.
 01 WS-X1                  FLOAT-SHORT VALUE 132.
 01 WS-Y1                  FLOAT-SHORT VALUE 232.
 01 WS-FOIL                BINARY-LONG.
 01 WS-OBS                 PIC X(40).
 01 B-IMG                  PIC X(1024) BASED.
 PROCEDURE DIVISION.
     CALL "CL-INIT" USING CLIENT-STATE
     MOVE 0 TO PK-COUNT
     CALL "GLINT-TEXTURES-BUILD" USING CLIENT-STATE
     MOVE "T" TO TL-MODE
     MOVE "glint textures: no pack gives them, nothing is loaded" TO TL-CASE
     MOVE GT-ITEM-W TO WS-E
     MOVE SPACES TO TL-OBSERVED
     STRING FUNCTION TRIM(WS-E) " " AT-UPLOAD(6) AT-UPLOAD(7) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "0 00" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "TEST-PACK-START" USING CLIENT-STATE WS-DIR WS-DIR-LENGTH WS-NAMES
     CALL "TEST-PACK-ENABLE" USING CLIENT-STATE WS-IDS
     CALL "GLINT-TEXTURES-BUILD" USING CLIENT-STATE
     MOVE "glint textures: the item glint is 8 x 8, the armour glint 4 x 4, both marked for upload" TO TL-CASE
     MOVE SPACES TO TL-OBSERVED
     MOVE GT-ITEM-W TO WS-P1
     MOVE GT-ITEM-H TO WS-P2
     MOVE GT-ARMOR-W TO WS-P3
     MOVE GT-ARMOR-H TO WS-P4
     STRING WS-P1 "x" WS-P2 " " WS-P3 "x" WS-P4 " " AT-UPLOAD(6) AT-UPLOAD(7)
         DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "0008x0008 0004x0004 11" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     SET ADDRESS OF B-IMG TO GT-ITEM-ADDR
     MOVE "glint textures: the item glint's pixel (1, 2) is 30, 60, 90, 255" TO TL-CASE
     COMPUTE WS-P1 = FUNCTION ORD(B-IMG((2 * 8 + 1) * 4 + 1:1)) - 1
     COMPUTE WS-P2 = FUNCTION ORD(B-IMG((2 * 8 + 1) * 4 + 2:1)) - 1
     COMPUTE WS-P3 = FUNCTION ORD(B-IMG((2 * 8 + 1) * 4 + 3:1)) - 1
     COMPUTE WS-P4 = FUNCTION ORD(B-IMG((2 * 8 + 1) * 4 + 4:1)) - 1
     MOVE SPACES TO TL-OBSERVED
     STRING WS-P1 "," WS-P2 "," WS-P3 "," WS-P4 DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "0030,0060,0090,0255" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     SET ADDRESS OF B-IMG TO GT-ARMOR-ADDR
     MOVE "glint textures: the armour glint's pixel (3, 1) is 200, 120, 40, 255" TO TL-CASE
     COMPUTE WS-P1 = FUNCTION ORD(B-IMG((1 * 4 + 3) * 4 + 1:1)) - 1
     COMPUTE WS-P2 = FUNCTION ORD(B-IMG((1 * 4 + 3) * 4 + 2:1)) - 1
     COMPUTE WS-P3 = FUNCTION ORD(B-IMG((1 * 4 + 3) * 4 + 3:1)) - 1
     COMPUTE WS-P4 = FUNCTION ORD(B-IMG((1 * 4 + 3) * 4 + 4:1)) - 1
     MOVE SPACES TO TL-OBSERVED
     STRING WS-P1 "," WS-P2 "," WS-P3 "," WS-P4 DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "0200,0120,0040,0255" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Built again: the old images are freed and the new ones loaded (no leak, same result).
     CALL "GLINT-TEXTURES-BUILD" USING CLIENT-STATE
     MOVE "glint textures: built again the sizes stay" TO TL-CASE
     MOVE SPACES TO TL-OBSERVED
     MOVE GT-ITEM-W TO WS-P1
     MOVE GT-ARMOR-W TO WS-P3
     STRING WS-P1 "x" WS-P3 DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "0008x0004" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   The offset: default speed 0.5.
     CALL "OPTIONS-DEFAULTS" USING CLIENT-STATE
     MOVE 0 TO CL-NOW-MS
     CALL "GLINT-OFFSET" USING CLIENT-STATE WS-U WS-V
     MOVE "glint offset at ms 0 is (0, 0)" TO TL-CASE
     PERFORM SHOW-UV
     MOVE "0 0" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 10000 TO CL-NOW-MS
     CALL "GLINT-OFFSET" USING CLIENT-STATE WS-U WS-V
     MOVE "glint offset at ms 10000, speed 0.5 (t 40000): u -0.364, v 0.333" TO TL-CASE
     PERFORM SHOW-UV
     MOVE "-364 333" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 70000 TO CL-NOW-MS
     CALL "GLINT-OFFSET" USING CLIENT-STATE WS-U WS-V
     MOVE "glint offset at ms 70000 (t 280000, mod 110000 = 60000): u -0.545, v 0.333" TO TL-CASE
     PERFORM SHOW-UV
     MOVE "-545 333" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "glintSpeed" TO WS-NAME
     MOVE "1.0" TO WS-VALUE
     CALL "OPTIONS-SET" USING CLIENT-STATE WS-NAME WS-VALUE WS-LEN WS-B
     MOVE 10000 TO CL-NOW-MS
     CALL "GLINT-OFFSET" USING CLIENT-STATE WS-U WS-V
     MOVE "glint offset at ms 10000, speed 1.0 (t 80000): u -0.727, v 0.667" TO TL-CASE
     PERFORM SHOW-UV
     MOVE "-727 667" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "GLINT-STRENGTH" USING CLIENT-STATE WS-S
     COMPUTE WS-A = WS-S * 1000
     MOVE WS-A TO WS-E
     MOVE "glint strength defaults to 0.75" TO TL-CASE
     MOVE FUNCTION TRIM(WS-E) TO TL-OBSERVED
     MOVE "750" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   STACK-FOIL (54 section 19.2): the override when present, else a non-empty enchantments component.
     MOVE 1 TO PB-ISX-COUNT
     MOVE 0 TO PB-ISX-ADDED-COUNT
     CALL "STACK-FOIL" USING PB-ITEMSTACK-X WS-FOIL
     MOVE "stack foil: no components is no foil" TO TL-CASE
     MOVE WS-FOIL TO WS-E
     MOVE FUNCTION TRIM(WS-E) TO TL-OBSERVED
     MOVE "0" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO PB-ISX-ADDED-COUNT
     MOVE 13 TO PB-ISX-TYPE(1)
     MOVE 1 TO PB-ISX-VALUE-LENGTH(1)
     MOVE X"02" TO PB-ISX-VALUE(1)(1:1)
     CALL "STACK-FOIL" USING PB-ITEMSTACK-X WS-FOIL
     MOVE "stack foil: a non-empty enchantments component is foil" TO TL-CASE
     MOVE WS-FOIL TO WS-E
     MOVE FUNCTION TRIM(WS-E) TO TL-OBSERVED
     MOVE "1" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE X"00" TO PB-ISX-VALUE(1)(1:1)
     CALL "STACK-FOIL" USING PB-ITEMSTACK-X WS-FOIL
     MOVE "stack foil: an empty enchantments component is no foil" TO TL-CASE
     MOVE WS-FOIL TO WS-E
     MOVE FUNCTION TRIM(WS-E) TO TL-OBSERVED
     MOVE "0" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 2 TO PB-ISX-ADDED-COUNT
     MOVE 21 TO PB-ISX-TYPE(2)
     MOVE 1 TO PB-ISX-VALUE-LENGTH(2)
     MOVE X"01" TO PB-ISX-VALUE(2)(1:1)
     CALL "STACK-FOIL" USING PB-ITEMSTACK-X WS-FOIL
     MOVE "stack foil: the override true forces the glint" TO TL-CASE
     MOVE WS-FOIL TO WS-E
     MOVE FUNCTION TRIM(WS-E) TO TL-OBSERVED
     MOVE "1" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE X"02" TO PB-ISX-VALUE(1)(1:1)
     MOVE X"00" TO PB-ISX-VALUE(2)(1:1)
     CALL "STACK-FOIL" USING PB-ITEMSTACK-X WS-FOIL
     MOVE "stack foil: the override false suppresses the glint of an enchanted item" TO TL-CASE
     MOVE WS-FOIL TO WS-E
     MOVE FUNCTION TRIM(WS-E) TO TL-OBSERVED
     MOVE "0" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   GLINT-ICON: the icon's opaque texels (alpha 26 and up, 0.1) covered by quads, one per run of a row: a 4 x 4 sprite with row 1 opaque at columns 1 and 2 and row 2
*>   opaque at columns 0 and 3 gives three runs (18 vertices); the first quad is x 108 to 124, y 208 to 216 (8 pixels a texel), its first vertex's glint coordinate the
*>   atlas coordinate (0.25, 0.25) at scale 8 through GLINT-UV (1.62, 2.32).
     MOVE 4 TO AT-W AT-H
     ALLOCATE 64 CHARACTERS INITIALIZED RETURNING AT-ADDR
     SET ADDRESS OF B-IMG TO AT-ADDR
     MOVE X"FF" TO B-IMG((1 * 4 + 1) * 4 + 4:1)
     MOVE X"FF" TO B-IMG((1 * 4 + 2) * 4 + 4:1)
     MOVE X"FF" TO B-IMG((2 * 4 + 0) * 4 + 4:1)
     MOVE X"FF" TO B-IMG((2 * 4 + 3) * 4 + 4:1)
     MOVE X"19" TO B-IMG((3 * 4 + 1) * 4 + 4:1)
     MOVE 1 TO AT-SPRITE-COUNT
     MOVE 0 TO AT-X(1) AT-Y(1)
     MOVE 4 TO AT-SW(1) AT-SH(1)
     MOVE 0 TO RL-GC-COUNT
     CALL "GLINT-ICON" USING CLIENT-STATE WS-SPRITE WS-X0 WS-Y0 WS-X1 WS-Y1
     MOVE "glint icon: three runs of opaque texels are 18 vertices (alpha 25 is under 0.1)" TO TL-CASE
     MOVE RL-GC-COUNT TO WS-E
     MOVE FUNCTION TRIM(WS-E) TO TL-OBSERVED
     MOVE "18" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "glint icon: the first quad's top-left corner is (108, 208)" TO TL-CASE
     COMPUTE WS-A = RL-GC-X(1)
     COMPUTE WS-B = RL-GC-Y(1)
     MOVE WS-A TO WS-UI
     MOVE WS-B TO WS-VI
     MOVE SPACES TO TL-OBSERVED
     STRING FUNCTION TRIM(WS-UI) " " FUNCTION TRIM(WS-VI) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "108 208" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "glint icon: the first quad's third corner is (124, 216)" TO TL-CASE
     COMPUTE WS-A = RL-GC-X(3)
     COMPUTE WS-B = RL-GC-Y(3)
     MOVE WS-A TO WS-UI
     MOVE WS-B TO WS-VI
     MOVE SPACES TO TL-OBSERVED
     STRING FUNCTION TRIM(WS-UI) " " FUNCTION TRIM(WS-VI) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "124 216" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "glint icon: the first vertex's glint coordinate is (1.62, 2.32) hundredths" TO TL-CASE
     COMPUTE WS-A ROUNDED = RL-GC-U(1) * 100
     COMPUTE WS-B ROUNDED = RL-GC-V(1) * 100
     MOVE WS-A TO WS-UI
     MOVE WS-B TO WS-VI
     MOVE SPACES TO TL-OBSERVED
     STRING FUNCTION TRIM(WS-UI) " " FUNCTION TRIM(WS-VI) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "162 232" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "glint icon: brightness is the glint strength (default 0.75), alpha 1" TO TL-CASE
     COMPUTE WS-A = RL-GC-B(1) * 100
     COMPUTE WS-B = RL-GC-A(1) * 100
     MOVE WS-A TO WS-UI
     MOVE WS-B TO WS-VI
     MOVE SPACES TO TL-OBSERVED
     STRING FUNCTION TRIM(WS-UI) " " FUNCTION TRIM(WS-VI) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "75 100" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   A full mesh takes no more quads.
     MOVE 12288 TO RL-GC-COUNT
     CALL "GLINT-ICON" USING CLIENT-STATE WS-SPRITE WS-X0 WS-Y0 WS-X1 WS-Y1
     MOVE "glint icon: a full glint icon mesh stays full" TO TL-CASE
     MOVE RL-GC-COUNT TO WS-E
     MOVE FUNCTION TRIM(WS-E) TO TL-OBSERVED
     MOVE "12288" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.

 SHOW-UV.
     COMPUTE WS-A ROUNDED = WS-U * 1000
     COMPUTE WS-B ROUNDED = WS-V * 1000
     MOVE WS-A TO WS-UI
     MOVE WS-B TO WS-VI
     MOVE SPACES TO TL-OBSERVED
     STRING FUNCTION TRIM(WS-UI) " " FUNCTION TRIM(WS-VI) DELIMITED BY SIZE INTO TL-OBSERVED.
 END PROGRAM TEST-GLINT.
 COPY CLTEST.
 COPY PACKTEST.
