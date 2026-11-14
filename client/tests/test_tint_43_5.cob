*> Acceptance test of docs/protocol/43-tint-sources.md section 5 (biome JSON fields that carry
*> colours): the four colour field syntaxes (STRING_RGB_COLOR, RGB_COLOR_CODEC, ARGB_COLOR_CODEC,
*> STRING_ARGB_COLOR), the attribute defaults, and the shipped biome values of 5.1 as biome
*> table rows (overrides, the modifier names, the water colour).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-TINT-43-5.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLSTATE.
 COPY CLTINT.
 COPY TESTLIB.
 01 WS-CASE                PIC X(240).
 01 WS-EXPECT              PIC X(8).
 01 WS-KIND                BINARY-LONG.
 01 WS-TEXT                PIC X(64).
 01 WS-LENGTH              BINARY-LONG.
 01 WS-COLOUR              BINARY-DOUBLE.
 01 WS-OK                  BINARY-LONG.
 01 WS-NAME                PIC X(64).
 01 WS-MOD                 PIC X(16).
 01 WS-COL                 BINARY-DOUBLE.
 01 WS-G                   BINARY-DOUBLE.
 01 WS-F                   BINARY-DOUBLE.
 01 WS-D                   BINARY-DOUBLE.
 01 WS-W                   BINARY-DOUBLE.
 01 WS-T                   COMP-2.
 01 WS-DN                  COMP-2.
 01 WS-BIOME               BINARY-LONG.
 01 WS-RES                 BINARY-LONG.
 01 WS-X                   BINARY-LONG VALUE 0.
 01 WS-Z                   BINARY-LONG VALUE 0.
 PROCEDURE DIVISION.
*>   STRING_RGB_COLOR: "#RRGGBB" made opaque, an integer kept as written, three floats floor(v x 255).
     MOVE 1 TO WS-KIND
     MOVE "#3F76E4" TO WS-TEXT
     MOVE "acceptance US11 43§5 Biome JSON fields that carry colours: hex string is opaque"
         TO WS-CASE
     MOVE "FF3F76E4" TO WS-EXPECT
     PERFORM CHECK-PARSE
     MOVE "#3f76e4" TO WS-TEXT
     MOVE "acceptance US11 43§5 Biome JSON fields that carry colours: lower-case digits" TO WS-CASE
     PERFORM CHECK-PARSE
     MOVE "-12012264" TO WS-TEXT
     MOVE "acceptance US11 43§5 Biome JSON fields that carry colours: negative integer is kept"
         TO WS-CASE
     MOVE "FF48B518" TO WS-EXPECT
     PERFORM CHECK-PARSE
     MOVE "4194303" TO WS-TEXT
     MOVE "acceptance US11 43§5 Biome JSON fields that carry colours: integer without alpha is kept"
         TO WS-CASE
     MOVE "003FFFFF" TO WS-EXPECT
     PERFORM CHECK-PARSE
     MOVE "[0.5,1.0,0.2]" TO WS-TEXT
     MOVE "acceptance US11 43§5 Biome JSON fields that carry colours: three floats floor x 255"
         TO WS-CASE
     MOVE "FF7FFF33" TO WS-EXPECT
     PERFORM CHECK-PARSE
     MOVE "[0.5, 1.0, 0.2]" TO WS-TEXT
     MOVE "acceptance US11 43§5 Biome JSON fields that carry colours: spaces in a float list"
         TO WS-CASE
     PERFORM CHECK-PARSE
*>   Rejected forms.
     MOVE "3F76E4" TO WS-TEXT
     MOVE "acceptance US11 43§5 Biome JSON fields that carry colours: hex without hash rejected"
         TO WS-CASE
     PERFORM CHECK-REJECT
     MOVE "#3F76E" TO WS-TEXT
     MOVE "acceptance US11 43§5 Biome JSON fields that carry colours: five hex digits rejected"
         TO WS-CASE
     PERFORM CHECK-REJECT
     MOVE "#3F76EG" TO WS-TEXT
     MOVE "acceptance US11 43§5 Biome JSON fields that carry colours: bad hex digit rejected"
         TO WS-CASE
     PERFORM CHECK-REJECT
     MOVE "[0.5,1.0]" TO WS-TEXT
     MOVE "acceptance US11 43§5 Biome JSON fields that carry colours: two floats rejected"
         TO WS-CASE
     PERFORM CHECK-REJECT
     MOVE "[a,b,c]" TO WS-TEXT
     MOVE "acceptance US11 43§5 Biome JSON fields that carry colours: non-numeric float rejected"
         TO WS-CASE
     PERFORM CHECK-REJECT
     MOVE "12ab" TO WS-TEXT
     MOVE "acceptance US11 43§5 Biome JSON fields that carry colours: word rejected" TO WS-CASE
     PERFORM CHECK-REJECT
*>   RGB_COLOR_CODEC (item tint colours): an integer or three floats, no string.
     MOVE 2 TO WS-KIND
     MOVE "-12012264" TO WS-TEXT
     MOVE "acceptance US11 43§5 Biome JSON fields that carry colours: item colour integer"
         TO WS-CASE
     MOVE "FF48B518" TO WS-EXPECT
     PERFORM CHECK-PARSE
     MOVE "[1.0,0.0,1.0]" TO WS-TEXT
     MOVE "acceptance US11 43§5 Biome JSON fields that carry colours: item colour floats"
         TO WS-CASE
     MOVE "FFFF00FF" TO WS-EXPECT
     PERFORM CHECK-PARSE
     MOVE "#3F76E4" TO WS-TEXT
     MOVE "acceptance US11 43§5 Biome JSON fields that carry colours: item colour string rejected"
         TO WS-CASE
     PERFORM CHECK-REJECT
*>   ARGB_COLOR_CODEC: an integer or four floats, alpha from the fourth.
     MOVE 3 TO WS-KIND
     MOVE "[1.0,0.0,0.0,0.5]" TO WS-TEXT
     MOVE "acceptance US11 43§5 Biome JSON fields that carry colours: four floats carry alpha"
         TO WS-CASE
     MOVE "7FFF0000" TO WS-EXPECT
     PERFORM CHECK-PARSE
     MOVE "[1.0,0.0,0.0]" TO WS-TEXT
     MOVE "acceptance US11 43§5 Biome JSON fields that carry colours: argb three floats rejected"
         TO WS-CASE
     PERFORM CHECK-REJECT
     MOVE "-16776961" TO WS-TEXT
     MOVE "acceptance US11 43§5 Biome JSON fields that carry colours: argb integer" TO WS-CASE
     MOVE "FF0000FF" TO WS-EXPECT
     PERFORM CHECK-PARSE
*>   STRING_ARGB_COLOR: "#AARRGGBB" or an integer.
     MOVE 4 TO WS-KIND
     MOVE "#80FF0000" TO WS-TEXT
     MOVE "acceptance US11 43§5 Biome JSON fields that carry colours: argb string" TO WS-CASE
     MOVE "80FF0000" TO WS-EXPECT
     PERFORM CHECK-PARSE
     MOVE "#FF0000" TO WS-TEXT
     MOVE "acceptance US11 43§5 Biome JSON fields that carry colours: argb string needs eight digits"
         TO WS-CASE
     PERFORM CHECK-REJECT
     MOVE "-16776961" TO WS-TEXT
     MOVE "acceptance US11 43§5 Biome JSON fields that carry colours: argb string takes an integer"
         TO WS-CASE
     MOVE "FF0000FF" TO WS-EXPECT
     PERFORM CHECK-PARSE
*>   Attribute defaults of 12 §3.1: fog #000000, water fog #050533, sky #000000.
     MOVE "minecraft:visual/fog_color" TO WS-NAME
     CALL "TINT-ATTRIBUTE-DEFAULT" USING WS-NAME WS-COLOUR
     MOVE "acceptance US11 43§5 Biome JSON fields that carry colours: fog default" TO WS-CASE
     MOVE "FF000000" TO WS-EXPECT
     CALL "TINT-CHECK" USING WS-CASE WS-EXPECT WS-COLOUR
     MOVE "minecraft:visual/water_fog_color" TO WS-NAME
     CALL "TINT-ATTRIBUTE-DEFAULT" USING WS-NAME WS-COLOUR
     MOVE "acceptance US11 43§5 Biome JSON fields that carry colours: water fog default" TO WS-CASE
     MOVE "FF050533" TO WS-EXPECT
     CALL "TINT-CHECK" USING WS-CASE WS-EXPECT WS-COLOUR
     MOVE "minecraft:visual/sky_color" TO WS-NAME
     CALL "TINT-ATTRIBUTE-DEFAULT" USING WS-NAME WS-COLOUR
     MOVE "acceptance US11 43§5 Biome JSON fields that carry colours: sky default" TO WS-CASE
     MOVE "FF000000" TO WS-EXPECT
     CALL "TINT-CHECK" USING WS-CASE WS-EXPECT WS-COLOUR
     MOVE "minecraft:other" TO WS-NAME
     CALL "TINT-ATTRIBUTE-DEFAULT" USING WS-NAME WS-COLOUR
     MOVE "acceptance US11 43§5 Biome JSON fields that carry colours: unknown attribute is 0"
         TO WS-CASE
     MOVE "00000000" TO WS-EXPECT
     CALL "TINT-CHECK" USING WS-CASE WS-EXPECT WS-COLOUR
*>   TINT-BIOME-SET fills one biome row from the parsed fields (5.1: swamp, grass modifier by name,
*>   absent overrides -1); the swamp row has foliage 6A7039 and water 617B64.
     MOVE 0.8 TO WS-T
     MOVE 0.9 TO WS-DN
     MOVE 6388580 TO WS-W
     MOVE -1 TO WS-G
     MOVE 6975545 TO WS-F
     MOVE -1 TO WS-D
     MOVE "swamp" TO WS-MOD
     MOVE 3 TO WS-BIOME
     CALL "TINT-BIOME-SET" USING WS-BIOME WS-T WS-DN WS-W WS-G WS-F WS-D WS-MOD
     MOVE 2 TO WS-RES
     CALL "TINT-BIOME-COLOR" USING WS-RES WS-BIOME WS-X WS-Z WS-COLOUR
     MOVE "acceptance US11 43§5 Biome JSON fields that carry colours: swamp foliage override"
         TO WS-CASE
     MOVE "006A7039" TO WS-EXPECT
     CALL "TINT-CHECK" USING WS-CASE WS-EXPECT WS-COLOUR
     MOVE 4 TO WS-RES
     CALL "TINT-BIOME-COLOR" USING WS-RES WS-BIOME WS-X WS-Z WS-COLOUR
     MOVE "acceptance US11 43§5 Biome JSON fields that carry colours: swamp water" TO WS-CASE
     MOVE "00617B64" TO WS-EXPECT
     CALL "TINT-CHECK" USING WS-CASE WS-EXPECT WS-COLOUR
     MOVE "acceptance US11 43§5 Biome JSON fields that carry colours: swamp modifier is 2"
         TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 2 TO TL-EXPECTED-N
     MOVE TB-MOD(4) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "dark_forest" TO WS-MOD
     CALL "TINT-BIOME-SET" USING WS-BIOME WS-T WS-DN WS-W WS-G WS-F WS-D WS-MOD
     MOVE "acceptance US11 43§5 Biome JSON fields that carry colours: dark_forest modifier is 1"
         TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE TB-MOD(4) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "none" TO WS-MOD
     CALL "TINT-BIOME-SET" USING WS-BIOME WS-T WS-DN WS-W WS-G WS-F WS-D WS-MOD
     MOVE "acceptance US11 43§5 Biome JSON fields that carry colours: none modifier is 0"
         TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE TB-MOD(4) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US11 43§5 Biome JSON fields that carry colours: row count follows the id"
         TO TL-CASE
     MOVE 4 TO TL-EXPECTED-N
     MOVE TT-BIOMES TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.

 CHECK-PARSE.
     MOVE FUNCTION LENGTH(FUNCTION TRIM(WS-TEXT)) TO WS-LENGTH
     CALL "TINT-COLOR-PARSE" USING WS-KIND WS-TEXT WS-LENGTH WS-COLOUR WS-OK
     IF WS-OK = 1
         CALL "TINT-CHECK" USING WS-CASE WS-EXPECT WS-COLOUR
     ELSE
         MOVE WS-CASE TO TL-CASE
         MOVE "T" TO TL-MODE
         MOVE WS-EXPECT TO TL-EXPECTED
         MOVE "rejected" TO TL-OBSERVED
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     END-IF.

 CHECK-REJECT.
     MOVE FUNCTION LENGTH(FUNCTION TRIM(WS-TEXT)) TO WS-LENGTH
     CALL "TINT-COLOR-PARSE" USING WS-KIND WS-TEXT WS-LENGTH WS-COLOUR WS-OK
     MOVE WS-CASE TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-OK TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-TINT-43-5.
 COPY TINTTEST.
