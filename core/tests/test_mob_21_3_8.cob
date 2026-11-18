*> Acceptance test (US15, FR-036, SC-008; docs/protocol/21 sections 3.6 and 3.8): the entity type tags and block tags the mobs of this document use. GENERATED from the two doc tables by a script that
*> reads only the markdown (lane 002-lane-p49d): one case per tag compares the members the content set resolves (CONTENT-TAG-HAS over every entity type or block the doc names) with the
*> doc's literal list, nested #tags expanded. A tag the doc lists a nested tag of (dragon_transparent, bats_spawnable_on) is checked for its literal members only. Needs CC_GENERATED_DIR.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-MOB-21-3-8.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CONTENT.
 78 CASES VALUE 8.
 01 WS-CASE-DATA.
    05 FILLER.
       10 FILLER PIC X(12) VALUE "block".
       10 FILLER PIC X(48) VALUE "dragon_immune".
       10 FILLER PIC X(2000) VALUE "barrier bedrock end_portal end_portal_frame end_gateway comm" &
          "and_block repeating_command_block chain_command_block struct" &
          "ure_block jigsaw moving_piston obsidian crying_obsidian end_" &
          "stone iron_bars respawn_anchor reinforced_deepslate test_blo" &
          "ck test_instance_block light soul_sand soul_soil lava soul_f" &
          "ire soul_torch soul_lantern soul_wall_torch soul_campfire wa" &
          "rped_fungus potted_warped_fungus nether_portal ".
       10 FILLER PIC X(1000) VALUE "barrier bedrock end_portal end_portal_frame end_gateway comm" &
          "and_block repeating_command_block chain_command_block struct" &
          "ure_block jigsaw moving_piston obsidian crying_obsidian end_" &
          "stone iron_bars respawn_anchor reinforced_deepslate test_blo" &
          "ck test_instance_block ".
    05 FILLER.
       10 FILLER PIC X(12) VALUE "block".
       10 FILLER PIC X(48) VALUE "wither_immune".
       10 FILLER PIC X(2000) VALUE "barrier bedrock end_portal end_portal_frame end_gateway comm" &
          "and_block repeating_command_block chain_command_block struct" &
          "ure_block jigsaw moving_piston obsidian crying_obsidian end_" &
          "stone iron_bars respawn_anchor reinforced_deepslate test_blo" &
          "ck test_instance_block light soul_sand soul_soil lava soul_f" &
          "ire soul_torch soul_lantern soul_wall_torch soul_campfire wa" &
          "rped_fungus potted_warped_fungus nether_portal ".
       10 FILLER PIC X(1000) VALUE "barrier bedrock end_portal end_portal_frame end_gateway comm" &
          "and_block repeating_command_block chain_command_block struct" &
          "ure_block jigsaw moving_piston reinforced_deepslate test_blo" &
          "ck test_instance_block light ".
    05 FILLER.
       10 FILLER PIC X(12) VALUE "block".
       10 FILLER PIC X(48) VALUE "dragon_transparent".
       10 FILLER PIC X(2000) VALUE "light ".
       10 FILLER PIC X(1000) VALUE "light ".
    05 FILLER.
       10 FILLER PIC X(12) VALUE "block".
       10 FILLER PIC X(48) VALUE "wither_summon_base_blocks".
       10 FILLER PIC X(2000) VALUE "barrier bedrock end_portal end_portal_frame end_gateway comm" &
          "and_block repeating_command_block chain_command_block struct" &
          "ure_block jigsaw moving_piston obsidian crying_obsidian end_" &
          "stone iron_bars respawn_anchor reinforced_deepslate test_blo" &
          "ck test_instance_block light soul_sand soul_soil lava soul_f" &
          "ire soul_torch soul_lantern soul_wall_torch soul_campfire wa" &
          "rped_fungus potted_warped_fungus nether_portal ".
       10 FILLER PIC X(1000) VALUE "soul_sand soul_soil ".
    05 FILLER.
       10 FILLER PIC X(12) VALUE "block".
       10 FILLER PIC X(48) VALUE "strider_warm_blocks".
       10 FILLER PIC X(2000) VALUE "barrier bedrock end_portal end_portal_frame end_gateway comm" &
          "and_block repeating_command_block chain_command_block struct" &
          "ure_block jigsaw moving_piston obsidian crying_obsidian end_" &
          "stone iron_bars respawn_anchor reinforced_deepslate test_blo" &
          "ck test_instance_block light soul_sand soul_soil lava soul_f" &
          "ire soul_torch soul_lantern soul_wall_torch soul_campfire wa" &
          "rped_fungus potted_warped_fungus nether_portal ".
       10 FILLER PIC X(1000) VALUE "lava ".
    05 FILLER.
       10 FILLER PIC X(12) VALUE "block".
       10 FILLER PIC X(48) VALUE "piglin_repellents".
       10 FILLER PIC X(2000) VALUE "barrier bedrock end_portal end_portal_frame end_gateway comm" &
          "and_block repeating_command_block chain_command_block struct" &
          "ure_block jigsaw moving_piston obsidian crying_obsidian end_" &
          "stone iron_bars respawn_anchor reinforced_deepslate test_blo" &
          "ck test_instance_block light soul_sand soul_soil lava soul_f" &
          "ire soul_torch soul_lantern soul_wall_torch soul_campfire wa" &
          "rped_fungus potted_warped_fungus nether_portal ".
       10 FILLER PIC X(1000) VALUE "soul_fire soul_torch soul_lantern soul_wall_torch soul_campf" &
          "ire ".
    05 FILLER.
       10 FILLER PIC X(12) VALUE "block".
       10 FILLER PIC X(48) VALUE "hoglin_repellents".
       10 FILLER PIC X(2000) VALUE "barrier bedrock end_portal end_portal_frame end_gateway comm" &
          "and_block repeating_command_block chain_command_block struct" &
          "ure_block jigsaw moving_piston obsidian crying_obsidian end_" &
          "stone iron_bars respawn_anchor reinforced_deepslate test_blo" &
          "ck test_instance_block light soul_sand soul_soil lava soul_f" &
          "ire soul_torch soul_lantern soul_wall_torch soul_campfire wa" &
          "rped_fungus potted_warped_fungus nether_portal ".
       10 FILLER PIC X(1000) VALUE "respawn_anchor warped_fungus potted_warped_fungus nether_por" &
          "tal ".
    05 FILLER.
       10 FILLER PIC X(12) VALUE "block".
       10 FILLER PIC X(48) VALUE "bats_spawnable_on".
       10 FILLER PIC X(2000) VALUE " ".
       10 FILLER PIC X(1000) VALUE "".
 01 WS-CASE-TABLE REDEFINES WS-CASE-DATA.
    05 WS-C OCCURS CASES TIMES.
       10 WS-C-REGISTRY      PIC X(12).
       10 WS-C-TAG           PIC X(48).
       10 WS-C-SCOPE         PIC X(2000).
       10 WS-C-EXPECTED      PIC X(1000).
 01 WS-I                   BINARY-LONG.
 01 WS-DIR                 PIC X(1100).
 01 WS-ENV                 PIC X(1100).
 01 WS-FILE                PIC X(1200).
 01 WS-FILE-INFO           PIC X(16).
 01 WS-TYPE                BINARY-LONG.
 01 WS-PTR                 BINARY-LONG.
 01 WS-OUT                 BINARY-LONG.
 01 WS-WORD                PIC X(48).
 01 WS-KEY                 PIC X(112).
 01 WS-TAGKEY              PIC X(112).
 01 WS-REGISTRY            PIC X(48).
 01 WS-ID                  BINARY-LONG.
 01 WS-ROW                 PIC X(819).
 01 WS-STATUS              BINARY-LONG.
 01 WS-HAS                 BINARY-LONG.
 01 WS-LIST                PIC X(1024).
 PROCEDURE DIVISION.
     MOVE "T" TO TL-MODE
     MOVE SPACES TO WS-ENV
     ACCEPT WS-ENV FROM ENVIRONMENT "CC_GENERATED_DIR"
     IF WS-ENV = SPACES
         MOVE "/tmp/cc-test/generated" TO WS-DIR
     ELSE
         MOVE WS-ENV TO WS-DIR
     END-IF
     MOVE SPACES TO WS-FILE
     STRING FUNCTION TRIM(WS-DIR TRAILING) "/vanilla-data/pack.mcmeta" X"00" DELIMITED BY SIZE INTO WS-FILE
     CALL "CBL_CHECK_FILE_EXIST" USING WS-FILE WS-FILE-INFO
     IF RETURN-CODE NOT = 0
         MOVE "tags 21 3.6 no generated packs here, skipped" TO TL-CASE
         MOVE "ok" TO TL-EXPECTED
         MOVE "ok" TO TL-OBSERVED
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
         STOP RUN
     END-IF
     MOVE CT-TYPE-STANDARD TO WS-TYPE
     CALL "CONTENT-OPEN" USING WS-TYPE WS-DIR WS-STATUS
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > CASES
         MOVE SPACES TO WS-LIST
         MOVE 1 TO WS-OUT
         MOVE 1 TO WS-PTR
         MOVE SPACES TO WS-REGISTRY WS-TAGKEY
         MOVE WS-C-REGISTRY(WS-I) TO WS-REGISTRY
         STRING "minecraft:" DELIMITED BY SIZE FUNCTION TRIM(WS-C-TAG(WS-I)) DELIMITED BY SIZE INTO WS-TAGKEY
         PERFORM UNTIL WS-PTR > 2000 OR WS-C-SCOPE(WS-I)(WS-PTR:1) = SPACE
             MOVE SPACES TO WS-WORD
             UNSTRING WS-C-SCOPE(WS-I) DELIMITED BY SPACE INTO WS-WORD WITH POINTER WS-PTR
             MOVE SPACES TO WS-KEY
             STRING "minecraft:" DELIMITED BY SIZE FUNCTION TRIM(WS-WORD) DELIMITED BY SIZE INTO WS-KEY
             MOVE 0 TO WS-ID
             IF WS-C-REGISTRY(WS-I) = "entity_type"
                 CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-ID WS-ROW WS-STATUS
             ELSE
                 CALL "CONTENT-BLOCK-BY-KEY" USING WS-KEY WS-ID WS-ROW WS-STATUS
             END-IF
             MOVE 0 TO WS-HAS
             IF WS-STATUS = CT-OK
                 CALL "CONTENT-TAG-HAS" USING WS-REGISTRY WS-TAGKEY WS-ID WS-HAS
             END-IF
             IF WS-HAS = 1
                 STRING FUNCTION TRIM(WS-WORD) DELIMITED BY SIZE " " DELIMITED BY SIZE INTO WS-LIST WITH POINTER WS-OUT
             END-IF
         END-PERFORM
         MOVE SPACES TO TL-CASE
         IF WS-C-REGISTRY(WS-I) = "entity_type"
             STRING "acceptance US15 21§3.6 entity tag " DELIMITED BY SIZE FUNCTION TRIM(WS-C-TAG(WS-I)) DELIMITED BY SIZE INTO TL-CASE
         ELSE
             STRING "acceptance US15 21§3.8 block tag " DELIMITED BY SIZE FUNCTION TRIM(WS-C-TAG(WS-I)) DELIMITED BY SIZE INTO TL-CASE
         END-IF
         MOVE WS-C-EXPECTED(WS-I) TO TL-EXPECTED
         MOVE WS-LIST TO TL-OBSERVED
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     END-PERFORM
     STOP RUN.
 END PROGRAM TEST-MOB-21-3-8.
