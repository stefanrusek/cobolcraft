*> Implementation test of content/src/packs-check.cob (CONTENT-PACKS-CHECK, 22 §8.2): the branches the
*> fixture trees of acc_f2us1_packs_check do not reach. Scratch: build/content-test/paths/t, a copy of the
*> valid fixture whose manifest, marker and sentinels each case alters. Manifest cases: unreadable (a
*> directory in its place, a file without read permission), too large, a line without "=", fewer than 13
*> lines, a blank line, an over-long line, an empty value, a value too long, a wrong key, a non-numeric
*> number, a pack format with two dots or a dot at an end, a control character: all damaged; a missing last
*> LF and keys after the 13th: ok. Stale: format 2 and each of the seven facts. Every sentinel removed:
*> damaged. No manifest and no marker: absent. A path of 1050 bytes: absent. An unterminated 1100-byte path:
*> absent.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-PACKS-CHECK-PATHS.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CONTENT.
 01 WS-DIR                 PIC X(1100).
 01 WS-STATUS              BINARY-LONG.
 01 WS-REASON              PIC X(128).
 01 WS-COMMAND             PIC X(1200).
 01 WS-SCRIPT              PIC X(400).
 01 WS-EXPECT              BINARY-LONG.
 01 WS-INDEX               BINARY-LONG.
 01 WS-SHOWN               PIC 9.
 01 WS-SENTINELS.
    05 FILLER PIC X(80) VALUE "vanilla-resources/pack.mcmeta".
    05 FILLER PIC X(80) VALUE "vanilla-resources/assets/minecraft/lang/en_us.json".
    05 FILLER PIC X(80) VALUE "vanilla-resources/assets/minecraft/atlases/blocks.json".
    05 FILLER PIC X(80) VALUE "vanilla-resources/assets/minecraft/textures/misc/unknown_pack.png".
    05 FILLER PIC X(80) VALUE "vanilla-data/pack.mcmeta".
    05 FILLER PIC X(80) VALUE "vanilla-data/data/minecraft/worldgen/biome/plains.json".
    05 FILLER PIC X(80) VALUE "vanilla-data/data/minecraft/dimension_type/overworld.json".
    05 FILLER PIC X(80) VALUE "vanilla-data/data/minecraft/damage_type/generic.json".
    05 FILLER PIC X(80) VALUE "vanilla-data/data/minecraft/recipe/stick.json".
 01 WS-SENTINEL-TABLE REDEFINES WS-SENTINELS.
    05 WS-SENTINEL         PIC X(80) OCCURS 9 TIMES.
 01 WS-ONE                 PIC X(80).
 PROCEDURE DIVISION.
     MOVE SPACES TO WS-DIR
     MOVE "build/content-test/paths/t" TO WS-DIR

*>   Manifest unreadable or too large.
     PERFORM FRESH-TREE
     CALL "SYSTEM" USING "rm build/content-test/paths/t/manifest.txt && mkdir build/content-test/paths/t/manifest.txt"
     MOVE CT-PACKS-DAMAGED TO WS-EXPECT
     MOVE "paths: a directory in place of the manifest is damaged" TO TL-CASE
     PERFORM CHECK-CASE
     PERFORM FRESH-TREE
     CALL "SYSTEM" USING "chmod 000 build/content-test/paths/t/manifest.txt"
     MOVE "paths: an unreadable manifest is damaged" TO TL-CASE
     PERFORM CHECK-CASE
     CALL "SYSTEM" USING "chmod 600 build/content-test/paths/t/manifest.txt"
     PERFORM FRESH-TREE
     CALL "SYSTEM" USING "head -c 5000 /dev/zero | tr '\0' 'a' > build/content-test/paths/t/manifest.txt"
     MOVE "paths: a manifest over 4096 bytes is damaged" TO TL-CASE
     PERFORM CHECK-CASE

*>   Invalid manifest lines.
     MOVE "sed 's/^tool=.*/tool/'" TO WS-SCRIPT
     MOVE "paths: a line without = is damaged" TO TL-CASE
     PERFORM EDIT-CASE
     MOVE "head -n 5" TO WS-SCRIPT
     MOVE "paths: fewer than 13 lines is damaged" TO TL-CASE
     PERFORM EDIT-CASE
     MOVE "sed d" TO WS-SCRIPT
     MOVE "paths: an empty manifest is damaged" TO TL-CASE
     PERFORM EDIT-CASE
     MOVE "sed 's/^tool=.*//'" TO WS-SCRIPT
     MOVE "paths: a blank line is damaged" TO TL-CASE
     PERFORM EDIT-CASE
     MOVE "sed 's/^tool=.*/tool=aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa/'"
         TO WS-SCRIPT
     MOVE "paths: a line of 200 bytes or more is damaged" TO TL-CASE
     PERFORM EDIT-CASE
     MOVE "sed 's/^tool=.*/tool=/'" TO WS-SCRIPT
     MOVE "paths: an empty value is damaged" TO TL-CASE
     PERFORM EDIT-CASE
     MOVE "sed 's/^tool=.*/tool=aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa/'"
         TO WS-SCRIPT
     MOVE "paths: a value of 81 bytes is damaged" TO TL-CASE
     PERFORM EDIT-CASE
     MOVE "sed 's/^tool=/tools=/'" TO WS-SCRIPT
     MOVE "paths: a key that is not the expected one is damaged" TO TL-CASE
     PERFORM EDIT-CASE
     MOVE "sed 's/^=.*//;s/^format=1/=1/'" TO WS-SCRIPT
     MOVE "paths: a line with an empty key is damaged" TO TL-CASE
     PERFORM EDIT-CASE
     MOVE "sed 's/^jar-size=.*/jar-size=41x83720/'" TO WS-SCRIPT
     MOVE "paths: a number with a letter is damaged" TO TL-CASE
     PERFORM EDIT-CASE
     MOVE "sed 's/^resource-format=.*/resource-format=9.7.1/'" TO WS-SCRIPT
     MOVE "paths: a pack format with two dots is damaged" TO TL-CASE
     PERFORM EDIT-CASE
     MOVE "sed 's/^resource-format=.*/resource-format=.971/'" TO WS-SCRIPT
     MOVE "paths: a pack format starting with a dot is damaged" TO TL-CASE
     PERFORM EDIT-CASE
     MOVE "sed 's/^resource-format=.*/resource-format=971./'" TO WS-SCRIPT
     MOVE "paths: a pack format ending with a dot is damaged" TO TL-CASE
     PERFORM EDIT-CASE
     MOVE "sed 's/$/'$(printf '\r')'/'" TO WS-SCRIPT
     MOVE "paths: a CRLF manifest (control character) is damaged" TO TL-CASE
     PERFORM EDIT-CASE
     MOVE "sed 's/^files-total=.*/files-total=-24/'" TO WS-SCRIPT
     MOVE "paths: a negative number is damaged" TO TL-CASE
     PERFORM EDIT-CASE

*>   Valid variants.
     MOVE CT-PACKS-OK TO WS-EXPECT
     MOVE "perl -pe 'chomp if eof'" TO WS-SCRIPT
     MOVE "paths: a manifest without its last LF is ok" TO TL-CASE
     PERFORM EDIT-CASE
     MOVE "(cat; echo future-key=1; echo format=7)" TO WS-SCRIPT
     MOVE "paths: keys after the 13th are ignored" TO TL-CASE
     PERFORM EDIT-CASE

*>   Stale: format and each fact of the row.
     MOVE CT-PACKS-STALE TO WS-EXPECT
     MOVE "sed 's/^format=1/format=2/'" TO WS-SCRIPT
     MOVE "paths: format 2 is stale" TO TL-CASE
     PERFORM EDIT-CASE
     MOVE "sed 's/^jar-version=.*/jar-version=26.4/'" TO WS-SCRIPT
     MOVE "paths: another jar version is stale" TO TL-CASE
     PERFORM EDIT-CASE
     MOVE "sed 's/^jar-size=.*/jar-size=41483721/'" TO WS-SCRIPT
     MOVE "paths: another jar size is stale" TO TL-CASE
     PERFORM EDIT-CASE
     MOVE "sed 's/^world-version=.*/world-version=5024/'" TO WS-SCRIPT
     MOVE "paths: another world version is stale" TO TL-CASE
     PERFORM EDIT-CASE
     MOVE "sed 's/^protocol-version=.*/protocol-version=778/'" TO WS-SCRIPT
     MOVE "paths: another protocol version is stale" TO TL-CASE
     PERFORM EDIT-CASE
     MOVE "sed 's/^resource-format=.*/resource-format=97.2/'" TO WS-SCRIPT
     MOVE "paths: another resource format is stale" TO TL-CASE
     PERFORM EDIT-CASE
     MOVE "sed 's/^data-format=.*/data-format=121.1/'" TO WS-SCRIPT
     MOVE "paths: another data format is stale" TO TL-CASE
     PERFORM EDIT-CASE

*>   Sentinels, one at a time.
     MOVE CT-PACKS-DAMAGED TO WS-EXPECT
     PERFORM VARYING WS-INDEX FROM 1 BY 1 UNTIL WS-INDEX > 9
         PERFORM FRESH-TREE
         MOVE WS-SENTINEL(WS-INDEX) TO WS-ONE
         MOVE SPACES TO WS-COMMAND
         STRING "rm build/content-test/paths/t/" FUNCTION TRIM(WS-ONE) DELIMITED BY SIZE INTO WS-COMMAND
         CALL "SYSTEM" USING WS-COMMAND
         MOVE WS-INDEX TO WS-SHOWN
         MOVE SPACES TO TL-CASE
         STRING "paths: sentinel " WS-SHOWN " missing is damaged" DELIMITED BY SIZE INTO TL-CASE
         PERFORM CHECK-CASE
     END-PERFORM

*>   No manifest: absent without the marker, incomplete with it.
     PERFORM FRESH-TREE
     CALL "SYSTEM" USING "rm build/content-test/paths/t/manifest.txt build/content-test/paths/t/.cobolcraft-generated"
     MOVE CT-PACKS-ABSENT TO WS-EXPECT
     MOVE "paths: no manifest and no marker is absent" TO TL-CASE
     PERFORM CHECK-CASE
     CALL "SYSTEM" USING "touch build/content-test/paths/t/.cobolcraft-generated"
     MOVE CT-PACKS-INCOMPLETE TO WS-EXPECT
     MOVE "paths: no manifest with the marker is incomplete" TO TL-CASE
     PERFORM CHECK-CASE

*>   Paths: 1050 bytes is too long for a child name; an unterminated 1100-byte path has no end.
     MOVE ALL "a" TO WS-DIR(1:1050)
     MOVE SPACES TO WS-DIR(1051:50)
     MOVE CT-PACKS-ABSENT TO WS-EXPECT
     MOVE "paths: a directory path of 1050 bytes is absent" TO TL-CASE
     PERFORM CHECK-CASE
     MOVE ALL "a" TO WS-DIR
     MOVE "paths: a path without an end is absent" TO TL-CASE
     PERFORM CHECK-CASE
*>   A real directory 1007 bytes deep (four 200-byte names and one of 180): too long for a child name.
     MOVE SPACES TO WS-DIR
     MOVE "build/content-test/lp" TO WS-DIR
     MOVE 22 TO WS-INDEX
     PERFORM 4 TIMES
         MOVE "/" TO WS-DIR(WS-INDEX:1)
         MOVE ALL "b" TO WS-DIR(WS-INDEX + 1:200)
         ADD 201 TO WS-INDEX
     END-PERFORM
     MOVE "/" TO WS-DIR(WS-INDEX:1)
     MOVE ALL "c" TO WS-DIR(WS-INDEX + 1:180)
     MOVE SPACES TO WS-COMMAND
     STRING "mkdir -p " FUNCTION TRIM(WS-DIR) DELIMITED BY SIZE INTO WS-COMMAND
     CALL "SYSTEM" USING WS-COMMAND
     MOVE "paths: an existing directory path over 1000 bytes is absent" TO TL-CASE
     PERFORM CHECK-CASE
     CALL "SYSTEM" USING "rm -rf build/content-test/lp"
     STOP RUN.

 FRESH-TREE.
     CALL "SYSTEM" USING "chmod -R u+rwx build/content-test/paths 2>/dev/null; rm -rf build/content-test/paths; mkdir -p build/content-test/paths && cp -R contract/fixtures/content/valid build/content-test/paths/t".

 EDIT-CASE.
*>   A fresh tree whose manifest is the valid one passed through the filter in WS-SCRIPT.
     PERFORM FRESH-TREE
     MOVE SPACES TO WS-COMMAND
     STRING FUNCTION TRIM(WS-SCRIPT) " < contract/fixtures/content/valid/manifest.txt > build/content-test/paths/manifest.new"
         " && mv build/content-test/paths/manifest.new build/content-test/paths/t/manifest.txt"
         DELIMITED BY SIZE INTO WS-COMMAND
     CALL "SYSTEM" USING WS-COMMAND
     PERFORM CHECK-CASE.

 CHECK-CASE.
     MOVE SPACES TO WS-REASON
     MOVE -1 TO WS-STATUS
     CALL "CONTENT-PACKS-CHECK" USING WS-DIR WS-STATUS WS-REASON
     MOVE "N" TO TL-MODE
     MOVE WS-EXPECT TO TL-EXPECTED-N
     MOVE WS-STATUS TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
