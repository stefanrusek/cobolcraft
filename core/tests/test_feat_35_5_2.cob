*> Test of the feature types of the water and surface document (docs/protocol/35-worldgen-features-5-water-and-surface.md section 2; core/src/feat-35-5.cob; T1218): every type id of the class table
*> is a registered feature type (35-1 registry), the gameplay names that are data (seagrass, sea pickle, kelp, desert well, coral mushroom) are not, and the configuration limits and defaults.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-FEAT-35-5-2.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 01 WS-REG                 BINARY-LONG VALUE 1.
 01 WS-NAME                PIC X(48).
 01 WS-ID                  BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-BAD                 BINARY-LONG.
 01 WS-LO                  BINARY-LONG.
 01 WS-HI                  BINARY-LONG.
 01 WS-DEFAULT             BINARY-LONG.
 01 WS-FOUND               BINARY-LONG.
 01 WS-TYPES.
    05 FILLER              PIC X(24) VALUE "lake".
    05 FILLER              PIC X(24) VALUE "spring_feature".
    05 FILLER              PIC X(24) VALUE "disk".
    05 FILLER              PIC X(24) VALUE "block_blob".
    05 FILLER              PIC X(24) VALUE "netherrack_replace_blobs".
    05 FILLER              PIC X(24) VALUE "freeze_top_layer".
    05 FILLER              PIC X(24) VALUE "iceberg".
    05 FILLER              PIC X(24) VALUE "blue_ice".
    05 FILLER              PIC X(24) VALUE "fill_layer".
    05 FILLER              PIC X(24) VALUE "block_pile".
    05 FILLER              PIC X(24) VALUE "coral_tree".
    05 FILLER              PIC X(24) VALUE "coral_claw".
    05 FILLER              PIC X(24) VALUE "underwater_magma".
    05 FILLER              PIC X(24) VALUE "spike".
    05 FILLER              PIC X(24) VALUE "bonus_chest".
    05 FILLER              PIC X(24) VALUE "overlay".
    05 FILLER              PIC X(24) VALUE "sequence".
    05 FILLER              PIC X(24) VALUE "simple_random_selector".
    05 FILLER              PIC X(24) VALUE "weighted_random_selector".
    05 FILLER              PIC X(24) VALUE "simple_block".
    05 FILLER              PIC X(24) VALUE "block_column".
    05 FILLER              PIC X(24) VALUE "template".
    05 FILLER              PIC X(24) VALUE "no_op".
 01 WS-TYPE-TAB REDEFINES WS-TYPES.
    05 WS-TYPE             PIC X(24) OCCURS 23 TIMES.
 01 WS-DATA-NAMES.
    05 FILLER              PIC X(24) VALUE "seagrass".
    05 FILLER              PIC X(24) VALUE "sea_pickle".
    05 FILLER              PIC X(24) VALUE "kelp".
    05 FILLER              PIC X(24) VALUE "desert_well".
    05 FILLER              PIC X(24) VALUE "coral_mushroom".
 01 WS-DATA-TAB REDEFINES WS-DATA-NAMES.
    05 WS-DATA             PIC X(24) OCCURS 5 TIMES.
 PROCEDURE DIVISION.
     MOVE "N" TO TL-MODE
     MOVE 0 TO WS-BAD
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 23
         MOVE SPACES TO WS-NAME
         MOVE WS-TYPE(WS-I) TO WS-NAME
         CALL "F351-REGISTRY-ID" USING WS-REG WS-NAME WS-ID
         IF WS-ID < 0
             ADD 1 TO WS-BAD
         END-IF
     END-PERFORM
     MOVE "acceptance US12 35-5§2.1 every type id of the class table is a registered feature type" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-BAD TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-BAD
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 5
         MOVE SPACES TO WS-NAME
         MOVE WS-DATA(WS-I) TO WS-NAME
         CALL "F351-REGISTRY-ID" USING WS-REG WS-NAME WS-ID
         IF WS-ID >= 0
             ADD 1 TO WS-BAD
         END-IF
     END-PERFORM
     MOVE "acceptance US12 35-5§2.2 seagrass, sea pickle, kelp, desert well and coral mushroom are data or absent, not feature types" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-BAD TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   the limits and defaults of the configuration fields
     MOVE "disk.radius" TO WS-NAME
     CALL "F355-LIMITS" USING WS-NAME WS-LO WS-HI WS-DEFAULT WS-FOUND
     MOVE "acceptance US12 35-5§2.1 disk radius is limited to 0 to 8" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-FOUND * 10000 + WS-LO * 100 + WS-HI
     MOVE 10008 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "disk.half_height" TO WS-NAME
     CALL "F355-LIMITS" USING WS-NAME WS-LO WS-HI WS-DEFAULT WS-FOUND
     MOVE "acceptance US12 35-5§2.1 disk half_height is 0 to 4" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-FOUND * 10000 + WS-LO * 100 + WS-HI
     MOVE 10004 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "netherrack_replace_blobs.radius" TO WS-NAME
     CALL "F355-LIMITS" USING WS-NAME WS-LO WS-HI WS-DEFAULT WS-FOUND
     MOVE "acceptance US12 35-5§2.1 replace blobs radius is 0 to 12" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-FOUND * 10000 + WS-LO * 100 + WS-HI
     MOVE 10012 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "fill_layer.height" TO WS-NAME
     CALL "F355-LIMITS" USING WS-NAME WS-LO WS-HI WS-DEFAULT WS-FOUND
     MOVE "acceptance US12 35-5§2.1 fill_layer height is 0 to the build height span 384" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-FOUND * 10000 + WS-LO * 1000 + WS-HI
     MOVE 10384 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "underwater_magma.floor_search_range" TO WS-NAME
     CALL "F355-LIMITS" USING WS-NAME WS-LO WS-HI WS-DEFAULT WS-FOUND
     MOVE "acceptance US12 35-5§2.1 underwater_magma floor_search_range is 0 to 512" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-FOUND * 10000 + WS-LO * 1000 + WS-HI
     MOVE 10512 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "underwater_magma.placement_radius_around_floor" TO WS-NAME
     CALL "F355-LIMITS" USING WS-NAME WS-LO WS-HI WS-DEFAULT WS-FOUND
     MOVE "acceptance US12 35-5§2.1 underwater_magma placement radius is 0 to 64" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-FOUND * 10000 + WS-LO * 100 + WS-HI
     MOVE 10064 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "spring_feature.rock_count" TO WS-NAME
     CALL "F355-LIMITS" USING WS-NAME WS-LO WS-HI WS-DEFAULT WS-FOUND
     MOVE "acceptance US12 35-5§2.1 spring rock_count defaults to 4" TO TL-CASE
     MOVE 4 TO TL-EXPECTED-N
     MOVE WS-DEFAULT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "spring_feature.hole_count" TO WS-NAME
     CALL "F355-LIMITS" USING WS-NAME WS-LO WS-HI WS-DEFAULT WS-FOUND
     MOVE "acceptance US12 35-5§2.1 spring hole_count defaults to 1" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-DEFAULT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "lake.fluid" TO WS-NAME
     CALL "F355-LIMITS" USING WS-NAME WS-LO WS-HI WS-DEFAULT WS-FOUND
     MOVE "acceptance US12 35-5§2.1 a field without a numeric limit is not found" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-FOUND TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM TEST-FEAT-35-5-2.
