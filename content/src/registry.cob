*> The registry loader of the content library (content-api section 2; docs/protocol/23-registry-loading.md sections 1, 2.1, 3 and 3.2).
*> REGISTRY-LOAD-ALL loads the 51 world registries (23 2.1, in WORLD_REGISTRIES order) of a standard set from
*> <generated directory>/vanilla-data/data/<namespace>/<registry path>/**/*.json: every file is read whole,
*> checked by the strict JSON reader (JSON-STRICT, 23 3.2), its identifier checked (23 1), and kept as the
*> payload of an entry; entries get their ids in the sorted order of the element id (path first, then
*> namespace, 23 3.4 and 1); the 13 registries with the non-empty validator (23 2.1, 04 3.2) must hold at
*> least one entry. Every error is printed on standard error as "ERROR registry: <detail>"; any error fails
*> the whole load (23 3.5): the status is CT-BAD-DATA and nothing stays loaded. Registries are frozen by
*> construction (nothing is added after the load). The element codecs are not run: a payload is the
*> file's own text. Not done here (owed to later rounds): the world's datapacks/ folder, feature packs
*> and the timeline marker validator of 23 9.2.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS-ERROR.
*> USING text (PIC X(200)): counts one load error and prints "ERROR registry: " and the text on standard
*> error.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CTLOAD.
 LINKAGE SECTION.
 01 L-TEXT                 PIC X(200).
 PROCEDURE DIVISION USING L-TEXT.
     ADD 1 TO RS-ERRORS
     DISPLAY "ERROR registry: " FUNCTION TRIM(L-TEXT TRAILING) UPON SYSERR
     GOBACK.
 END PROGRAM RS-ERROR.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. REGISTRY-NAME-AT.
*> USING index (BINARY-LONG, 1 to 51), registry path out (PIC X(48), space padded), validator out (PIC X: "E" the
*> registry must be non-empty, space none): the 51 WORLD registries of 23 section 2.1 in WORLD_REGISTRIES
*> order.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-REGISTRIES.
    05 FILLER PIC X(49) VALUE "dimension_type                                   ".
    05 FILLER PIC X(49) VALUE "worldgen/biome                                   ".
    05 FILLER PIC X(49) VALUE "chat_type                                        ".
    05 FILLER PIC X(49) VALUE "worldgen/carver                                  ".
    05 FILLER PIC X(49) VALUE "worldgen/feature                                 ".
    05 FILLER PIC X(49) VALUE "worldgen/placed_feature                          ".
    05 FILLER PIC X(49) VALUE "worldgen/structure                               ".
    05 FILLER PIC X(49) VALUE "worldgen/structure_set                           ".
    05 FILLER PIC X(49) VALUE "worldgen/processor_list                          ".
    05 FILLER PIC X(49) VALUE "worldgen/template_pool                           ".
    05 FILLER PIC X(49) VALUE "worldgen/noise_settings                          ".
    05 FILLER PIC X(49) VALUE "worldgen/noise                                   ".
    05 FILLER PIC X(49) VALUE "worldgen/density_function                        ".
    05 FILLER PIC X(49) VALUE "worldgen/material_rule                           ".
    05 FILLER PIC X(49) VALUE "worldgen/material_condition                      ".
    05 FILLER PIC X(49) VALUE "worldgen/world_preset                            ".
    05 FILLER PIC X(49) VALUE "worldgen/flat_level_generator_preset             ".
    05 FILLER PIC X(49) VALUE "trim_pattern                                     ".
    05 FILLER PIC X(49) VALUE "trim_material                                    ".
    05 FILLER PIC X(49) VALUE "trial_spawner                                    ".
    05 FILLER PIC X(49) VALUE "wolf_variant                                    E".
    05 FILLER PIC X(49) VALUE "wolf_sound_variant                              E".
    05 FILLER PIC X(49) VALUE "pig_variant                                     E".
    05 FILLER PIC X(49) VALUE "pig_sound_variant                               E".
    05 FILLER PIC X(49) VALUE "frog_variant                                    E".
    05 FILLER PIC X(49) VALUE "cat_variant                                     E".
    05 FILLER PIC X(49) VALUE "cat_sound_variant                               E".
    05 FILLER PIC X(49) VALUE "cow_variant                                     E".
    05 FILLER PIC X(49) VALUE "cow_sound_variant                               E".
    05 FILLER PIC X(49) VALUE "sulfur_cube_archetype                            ".
    05 FILLER PIC X(49) VALUE "chicken_variant                                 E".
    05 FILLER PIC X(49) VALUE "chicken_sound_variant                           E".
    05 FILLER PIC X(49) VALUE "zombie_nautilus_variant                         E".
    05 FILLER PIC X(49) VALUE "painting_variant                                E".
    05 FILLER PIC X(49) VALUE "damage_type                                      ".
    05 FILLER PIC X(49) VALUE "worldgen/multi_noise_biome_source_parameter_list ".
    05 FILLER PIC X(49) VALUE "banner_pattern                                   ".
    05 FILLER PIC X(49) VALUE "enchantment                                      ".
    05 FILLER PIC X(49) VALUE "enchantment_provider                             ".
    05 FILLER PIC X(49) VALUE "jukebox_song                                     ".
    05 FILLER PIC X(49) VALUE "instrument                                       ".
    05 FILLER PIC X(49) VALUE "test_environment                                 ".
    05 FILLER PIC X(49) VALUE "test_instance                                    ".
    05 FILLER PIC X(49) VALUE "dialog                                           ".
    05 FILLER PIC X(49) VALUE "world_clock                                      ".
    05 FILLER PIC X(49) VALUE "timeline                                         ".
    05 FILLER PIC X(49) VALUE "villager_trade                                   ".
    05 FILLER PIC X(49) VALUE "trade_set                                        ".
    05 FILLER PIC X(49) VALUE "decorated_pot_pattern                            ".
    05 FILLER PIC X(49) VALUE "block_transformer                                ".
    05 FILLER PIC X(49) VALUE "worldgen/block_state_provider                    ".
 01 WS-REGISTRY-TABLE REDEFINES WS-REGISTRIES.
    05 WS-REG OCCURS 51 TIMES.
       10 WS-REG-NAME        PIC X(48).
       10 WS-REG-FLAG        PIC X.
 LINKAGE SECTION.
 01 L-INDEX                BINARY-LONG.
 01 L-NAME                 PIC X(48).
 01 L-FLAG                 PIC X.
 PROCEDURE DIVISION USING L-INDEX L-NAME L-FLAG.
     MOVE WS-REG-NAME(L-INDEX) TO L-NAME
     MOVE WS-REG-FLAG(L-INDEX) TO L-FLAG
     GOBACK.
 END PROGRAM REGISTRY-NAME-AT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. REGISTRY-LOAD-ALL.
*> USING generated directory (PIC X(1100), z-string or space padded), status out (CT-OK, CT-BAD-DATA).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CONTENT.
 COPY CTSTORE.
 COPY CTLOAD.
 COPY FORMATS.
 01 WS-DIR-Z               PIC X(1101).
 01 WS-DIR-LENGTH          BINARY-LONG.
 01 WS-PATH-STATUS         BINARY-LONG.
 01 WS-BASE                PIC X(1101).
 01 WS-ADDR                USAGE POINTER.
 01 WS-I                   BINARY-LONG.
 01 WS-NAME-LENGTH         BINARY-LONG.
 01 WS-MESSAGE             PIC X(200).
 01 WS-NAME                PIC X(48).
 01 WS-FLAG                PIC X.
 01 WS-FLAGS               PIC X(51).
 LINKAGE SECTION.
 01 L-DIR                  PIC X(1100).
 01 L-STATUS               BINARY-LONG.
 PROCEDURE DIVISION USING L-DIR L-STATUS.
     CALL "REGISTRY-FREE"
     MOVE 0 TO RS-ERRORS RS-COUNT
     CALL "FILE-PATH-Z" USING L-DIR WS-DIR-Z WS-DIR-LENGTH WS-PATH-STATUS
     IF WS-PATH-STATUS NOT = FM-OK
         MOVE "the generated directory path is too long" TO WS-MESSAGE
         CALL "RS-ERROR" USING WS-MESSAGE
         MOVE CT-BAD-DATA TO L-STATUS
         GOBACK
     END-IF
     MOVE LOW-VALUES TO WS-BASE
     STRING WS-DIR-Z(1:WS-DIR-LENGTH) "/vanilla-data/data" DELIMITED BY SIZE INTO WS-BASE
     ALLOCATE LENGTH OF B-REGISTRIES CHARACTERS RETURNING WS-ADDR
     SET CT-REGISTRY-ADDR TO WS-ADDR
     SET ADDRESS OF B-REGISTRIES TO CT-REGISTRY-ADDR
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 51
         CALL "REGISTRY-NAME-AT" USING WS-I WS-NAME WS-FLAG
         MOVE WS-FLAG TO WS-FLAGS(WS-I:1)
         MOVE SPACES TO BR-KEY(WS-I)
         MOVE 0 TO WS-NAME-LENGTH
         INSPECT WS-NAME TALLYING WS-NAME-LENGTH FOR CHARACTERS BEFORE INITIAL SPACE
         STRING "minecraft:" WS-NAME(1:WS-NAME-LENGTH) DELIMITED BY SIZE INTO BR-KEY(WS-I)
         COMPUTE BR-KEY-LENGTH(WS-I) = WS-NAME-LENGTH + 10
         MOVE 0 TO BR-ENTRY-COUNT(WS-I) BR-PAYLOAD-LENGTH(WS-I)
         SET BR-ENTRY-ADDR(WS-I) TO NULL
         SET BR-PAYLOAD-ADDR(WS-I) TO NULL
     END-PERFORM
     MOVE 51 TO CT-REGISTRY-COUNT
     MOVE 0 TO RS-MODE
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 51
         CALL "REGISTRY-NAME-AT" USING WS-I WS-NAME WS-FLAG
         CALL "REGISTRY-LOAD-ONE" USING WS-BASE WS-NAME WS-I
     END-PERFORM
*>   Validators (23 2.1): the non-empty registries.
     SET ADDRESS OF B-REGISTRIES TO CT-REGISTRY-ADDR
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 51
         IF WS-FLAGS(WS-I:1) = "E" AND BR-ENTRY-COUNT(WS-I) = 0
             MOVE SPACES TO WS-MESSAGE
             STRING "Registry must be non-empty: " FUNCTION TRIM(BR-KEY(WS-I)) DELIMITED BY SIZE
                 INTO WS-MESSAGE
             CALL "RS-ERROR" USING WS-MESSAGE
         END-IF
     END-PERFORM
     IF RS-ERRORS > 0
         CALL "REGISTRY-FREE"
         MOVE CT-BAD-DATA TO L-STATUS
     ELSE
         MOVE CT-OK TO L-STATUS
     END-IF
     GOBACK.
 END PROGRAM REGISTRY-LOAD-ALL.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. REGISTRY-LOAD-ONE.
*> USING base (z-string path of <generated>/vanilla-data/data, PIC X(1101)), registry path (PIC X(48), space
*> padded), slot (BINARY-LONG: the 1-based row of the registry table): collects the elements of every
*> namespace folder and builds the registry's entries. With RS-MODE 1 it reads the tag files of the
*> registry (data/<namespace>/tags/<registry path>/) into TAG-ADD-FILE instead and builds nothing.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CTLOAD.
 COPY FORMATS.
 01 B-LIST                 PIC X(16777216) BASED.
 01 WS-LIST-ADDR           USAGE POINTER.
 01 WS-LIST-COUNT          BINARY-LONG.
 01 WS-LIST-STATUS         BINARY-LONG.
 01 WS-POS                 BINARY-LONG.
 01 WS-END                 BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-NAME-LENGTH         BINARY-LONG.
 01 WS-BASE-LENGTH         BINARY-LONG.
 01 WS-REGISTRY-LENGTH     BINARY-LONG.
 01 WS-NS                  PIC X(64).
 01 WS-OK                  BINARY-LONG.
 01 WS-DIR                 PIC X(1101).
 01 WS-PREFIX              PIC X(64).
 01 WS-MESSAGE             PIC X(200).
 LINKAGE SECTION.
 01 L-BASE                 PIC X(1101).
 01 L-NAME                 PIC X(48).
 01 L-SLOT                 BINARY-LONG.
 PROCEDURE DIVISION USING L-BASE L-NAME L-SLOT.
     MOVE 0 TO RS-COUNT RS-PAYLOAD-LENGTH RS-PAYLOAD-CAPACITY
     SET RS-PAYLOAD-ADDR TO NULL
     MOVE L-NAME TO RS-REGISTRY
     MOVE 0 TO WS-BASE-LENGTH WS-REGISTRY-LENGTH
     INSPECT L-BASE TALLYING WS-BASE-LENGTH FOR CHARACTERS BEFORE INITIAL LOW-VALUE
     INSPECT L-NAME TALLYING WS-REGISTRY-LENGTH FOR CHARACTERS BEFORE INITIAL SPACE
     CALL "RS-LIST-DIR" USING L-BASE WS-LIST-ADDR WS-LIST-COUNT WS-LIST-STATUS
     IF WS-LIST-STATUS = 0
         MOVE 1 TO WS-POS
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-LIST-COUNT
             SET ADDRESS OF B-LIST TO WS-LIST-ADDR
             MOVE WS-POS TO WS-END
             PERFORM UNTIL B-LIST(WS-END:1) = X"0A"
                 ADD 1 TO WS-END
             END-PERFORM
             COMPUTE WS-NAME-LENGTH = WS-END - WS-POS - 1
*>           Only folders are namespaces; a file in data/ is not looked at.
             IF B-LIST(WS-POS:1) = "D"
                 MOVE SPACES TO WS-NS
                 MOVE 0 TO WS-OK
                 IF WS-NAME-LENGTH <= 32
                     MOVE B-LIST(WS-POS + 1:WS-NAME-LENGTH) TO WS-NS
                     MOVE 1 TO WS-OK
                     CALL "RS-ID-VALID" USING WS-NS WS-NAME-LENGTH WS-OK
                 END-IF
                 IF WS-OK = 1
                     MOVE SPACES TO RS-NS
                     MOVE WS-NS TO RS-NS
                     MOVE LOW-VALUES TO WS-DIR
                     IF RS-MODE = 1
                         STRING L-BASE(1:WS-BASE-LENGTH) "/" WS-NS(1:WS-NAME-LENGTH) "/tags/"
                             L-NAME(1:WS-REGISTRY-LENGTH) DELIMITED BY SIZE INTO WS-DIR
                     ELSE
                         STRING L-BASE(1:WS-BASE-LENGTH) "/" WS-NS(1:WS-NAME-LENGTH) "/"
                             L-NAME(1:WS-REGISTRY-LENGTH) DELIMITED BY SIZE INTO WS-DIR
                     END-IF
                     MOVE SPACES TO WS-PREFIX
                     CALL "REGISTRY-SCAN-DIR" USING WS-DIR WS-PREFIX WS-OK
                 ELSE
                     MOVE SPACES TO WS-MESSAGE
                     MOVE B-LIST(WS-POS + 1:FUNCTION MIN(WS-NAME-LENGTH, 64)) TO WS-NS
                     STRING "invalid namespace folder " FUNCTION TRIM(WS-NS) DELIMITED BY SIZE
                         INTO WS-MESSAGE
                     CALL "RS-ERROR" USING WS-MESSAGE
                 END-IF
             END-IF
             COMPUTE WS-POS = WS-END + 1
         END-PERFORM
         FREE WS-LIST-ADDR
     END-IF
     IF RS-MODE = 0
         CALL "REGISTRY-BUILD" USING L-SLOT
     END-IF
     GOBACK.
 END PROGRAM REGISTRY-LOAD-ONE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. REGISTRY-SCAN-DIR IS RECURSIVE.
*> USING folder (z-string, PIC X(1101)), prefix (PIC X(64): the element path of the folder with its closing
*> "/", spaces for the registry's own folder), a scratch word (BINARY-LONG, not used by the caller): reads
*> every ".json" file below the folder as an element of RS-NS and enters the subfolders; other files are
*> not elements. A folder that cannot be listed is not a folder (a file of the registry's name): nothing.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CTLOAD.
 COPY FORMATS.
 COPY JSONDOC.
 01 WS-FILE                PIC X(4194304).
 01 WS-FILE-CAPACITY       BINARY-LONG VALUE 4194304.
 01 WS-FILE-LENGTH         BINARY-LONG.
 01 WS-FILE-STATUS         BINARY-LONG.
 01 WS-TAG-STATUS          BINARY-LONG.
 01 WS-PACK                PIC X(32) VALUE "vanilla-data".
 01 WS-OFFSET              BINARY-LONG.
 01 WS-REASON              BINARY-LONG.
 01 WS-REASON-TEXT         PIC Z(8)9.
 01 WS-OFFSET-TEXT         PIC Z(8)9.
 01 B-LIST                 PIC X(16777216) BASED.
 LOCAL-STORAGE SECTION.
 01 LS-LIST-ADDR           USAGE POINTER.
 01 LS-COUNT               BINARY-LONG.
 01 LS-STATUS              BINARY-LONG.
 01 LS-POS                 BINARY-LONG.
 01 LS-END                 BINARY-LONG.
 01 LS-I                   BINARY-LONG.
 01 LS-DIR-LENGTH          BINARY-LONG.
 01 LS-NAME-LENGTH         BINARY-LONG.
 01 LS-STEM-LENGTH         BINARY-LONG.
 01 LS-PREFIX-LENGTH       BINARY-LONG.
 01 LS-NS-LENGTH           BINARY-LONG.
 01 LS-OK                  BINARY-LONG.
 01 LS-MODE                BINARY-LONG.
 01 LS-PATH-LENGTH         BINARY-LONG.
 01 LS-FULL-LENGTH         BINARY-LONG.
 01 LS-SHOW-LENGTH         BINARY-LONG.
 01 LS-CHILD               PIC X(1101).
 01 LS-CHILD-PATH          PIC X(1100).
 01 LS-CHILD-PREFIX        PIC X(64).
 01 LS-PATH                PIC X(64).
 01 LS-TAG-KEY             PIC X(64).
 01 LS-NAME                PIC X(64).
 01 LS-MESSAGE             PIC X(200).
 LINKAGE SECTION.
 01 L-DIR                  PIC X(1101).
 01 L-PREFIX               PIC X(64).
 01 L-SCRATCH              BINARY-LONG.
 PROCEDURE DIVISION USING L-DIR L-PREFIX L-SCRATCH.
     CALL "RS-LIST-DIR" USING L-DIR LS-LIST-ADDR LS-COUNT LS-STATUS
     IF LS-STATUS NOT = 0
         GOBACK
     END-IF
     MOVE 0 TO LS-DIR-LENGTH LS-PREFIX-LENGTH LS-NS-LENGTH
     INSPECT L-DIR TALLYING LS-DIR-LENGTH FOR CHARACTERS BEFORE INITIAL LOW-VALUE
     INSPECT L-PREFIX TALLYING LS-PREFIX-LENGTH FOR CHARACTERS BEFORE INITIAL SPACE
     INSPECT RS-NS TALLYING LS-NS-LENGTH FOR CHARACTERS BEFORE INITIAL SPACE
     MOVE 1 TO LS-POS
     PERFORM VARYING LS-I FROM 1 BY 1 UNTIL LS-I > LS-COUNT
         SET ADDRESS OF B-LIST TO LS-LIST-ADDR
         MOVE LS-POS TO LS-END
         PERFORM UNTIL B-LIST(LS-END:1) = X"0A"
             ADD 1 TO LS-END
         END-PERFORM
         COMPUTE LS-NAME-LENGTH = LS-END - LS-POS - 1
         MOVE SPACES TO LS-NAME
         MOVE FUNCTION MIN(LS-NAME-LENGTH, 64) TO LS-SHOW-LENGTH
         MOVE B-LIST(LS-POS + 1:LS-SHOW-LENGTH) TO LS-NAME
         EVALUATE TRUE
             WHEN B-LIST(LS-POS:1) = "D"
*>               A subfolder: its names are path segments (23 1: a-z 0-9 _ - . and /).
                 COMPUTE LS-STEM-LENGTH = LS-PREFIX-LENGTH + LS-NAME-LENGTH + 1
                 MOVE 0 TO LS-OK
                 IF LS-STEM-LENGTH <= 63
                     MOVE SPACES TO LS-CHILD-PREFIX
                     IF LS-PREFIX-LENGTH > 0
                         MOVE L-PREFIX(1:LS-PREFIX-LENGTH) TO LS-CHILD-PREFIX(1:LS-PREFIX-LENGTH)
                     END-IF
                     MOVE LS-NAME(1:LS-NAME-LENGTH) TO LS-CHILD-PREFIX(LS-PREFIX-LENGTH + 1:LS-NAME-LENGTH)
                     MOVE "/" TO LS-CHILD-PREFIX(LS-STEM-LENGTH:1)
                     MOVE 2 TO LS-OK
                     CALL "RS-ID-VALID" USING LS-NAME LS-NAME-LENGTH LS-OK
                 END-IF
                 IF LS-OK = 1
                     MOVE LOW-VALUES TO LS-CHILD
                     STRING L-DIR(1:LS-DIR-LENGTH) "/" LS-NAME(1:LS-NAME-LENGTH) DELIMITED BY SIZE INTO LS-CHILD
                     CALL "REGISTRY-SCAN-DIR" USING LS-CHILD LS-CHILD-PREFIX LS-OK
                 ELSE
                     MOVE SPACES TO LS-MESSAGE
                     STRING FUNCTION TRIM(RS-REGISTRY) " " FUNCTION TRIM(RS-NS) ": invalid folder name "
                         LS-NAME(1:LS-SHOW-LENGTH) DELIMITED BY SIZE INTO LS-MESSAGE
                     CALL "RS-ERROR" USING LS-MESSAGE
                 END-IF
             WHEN B-LIST(LS-POS:1) = "F" AND LS-NAME-LENGTH > 5
                  AND B-LIST(LS-END - 5:5) = ".json"
                 COMPUTE LS-STEM-LENGTH = LS-NAME-LENGTH - 5
            *>   The element path is the folder prefix and the file name without ".json".
                 MOVE SPACES TO LS-PATH
                 MOVE SPACES TO LS-MESSAGE
                 COMPUTE LS-PATH-LENGTH = LS-PREFIX-LENGTH + LS-STEM-LENGTH
                 IF LS-PATH-LENGTH + LS-NS-LENGTH + 1 > 64
                     STRING FUNCTION TRIM(RS-REGISTRY) " " FUNCTION TRIM(RS-NS) ": the key of " LS-NAME(1:LS-SHOW-LENGTH)
                         " is over 64 bytes" DELIMITED BY SIZE INTO LS-MESSAGE
                     CALL "RS-ERROR" USING LS-MESSAGE
                 ELSE
                     IF LS-PREFIX-LENGTH > 0
                         MOVE L-PREFIX(1:LS-PREFIX-LENGTH) TO LS-PATH(1:LS-PREFIX-LENGTH)
                     END-IF
                     MOVE LS-NAME(1:LS-STEM-LENGTH) TO LS-PATH(LS-PREFIX-LENGTH + 1:LS-STEM-LENGTH)
                     MOVE 2 TO LS-MODE
                     CALL "RS-ID-VALID" USING LS-PATH LS-PATH-LENGTH LS-MODE
                     IF LS-MODE = 0
                         STRING FUNCTION TRIM(RS-REGISTRY) " " FUNCTION TRIM(RS-NS) ": Non [a-z0-9/._-] character in path of location: "
                             FUNCTION TRIM(LS-PATH) DELIMITED BY SIZE INTO LS-MESSAGE
                         CALL "RS-ERROR" USING LS-MESSAGE
                     ELSE
                         MOVE LOW-VALUES TO LS-CHILD-PATH
                         STRING L-DIR(1:LS-DIR-LENGTH) "/" LS-NAME(1:LS-NAME-LENGTH) DELIMITED BY SIZE INTO LS-CHILD-PATH
                         COMPUTE LS-FULL-LENGTH = LS-DIR-LENGTH + LS-NAME-LENGTH + 1
                         CALL "FILE-READ-ALL" USING LS-CHILD-PATH LS-FULL-LENGTH WS-FILE WS-FILE-CAPACITY WS-FILE-LENGTH WS-FILE-STATUS
                         IF WS-FILE-STATUS NOT = 0
                             STRING FUNCTION TRIM(RS-REGISTRY) " " FUNCTION TRIM(RS-NS) ": cannot read " LS-NAME(1:LS-SHOW-LENGTH)
                                 DELIMITED BY SIZE INTO LS-MESSAGE
                             CALL "RS-ERROR" USING LS-MESSAGE
                         ELSE
                           IF RS-MODE = 1
                             MOVE SPACES TO LS-TAG-KEY
                             STRING FUNCTION TRIM(RS-NS) ":" FUNCTION TRIM(LS-PATH) DELIMITED BY SIZE INTO LS-TAG-KEY
                             CALL "TAG-ADD-FILE" USING RS-REGISTRY LS-TAG-KEY WS-PACK WS-FILE WS-FILE-LENGTH WS-TAG-STATUS
                           ELSE
                             CALL "JSON-STRICT" USING WS-FILE WS-FILE-LENGTH JSON-DOC WS-OFFSET WS-REASON
                             IF WS-REASON NOT = FM-JS-OK
                                 MOVE WS-REASON TO WS-REASON-TEXT
                                 MOVE WS-OFFSET TO WS-OFFSET-TEXT
                                 STRING FUNCTION TRIM(RS-REGISTRY) " " FUNCTION TRIM(RS-NS) ":" FUNCTION TRIM(LS-PATH)
                                     ": not strict JSON (reason " FUNCTION TRIM(WS-REASON-TEXT) " at byte "
                                     FUNCTION TRIM(WS-OFFSET-TEXT) ")" DELIMITED BY SIZE INTO LS-MESSAGE
                                 CALL "RS-ERROR" USING LS-MESSAGE
                             ELSE
                                 IF RS-COUNT >= RS-MAX-ELEMENTS
                                     STRING FUNCTION TRIM(RS-REGISTRY) ": more than 8192 elements" DELIMITED BY SIZE INTO LS-MESSAGE
                                     CALL "RS-ERROR" USING LS-MESSAGE
                                 ELSE
                                     CALL "RS-PAYLOAD-APPEND" USING WS-FILE WS-FILE-LENGTH WS-OFFSET
                                     ADD 1 TO RS-COUNT
                                     MOVE LS-PATH TO RS-E-PATH(RS-COUNT)
                                     MOVE RS-NS TO RS-E-NS(RS-COUNT)
                                     MOVE WS-OFFSET TO RS-E-OFFSET(RS-COUNT)
                                     MOVE WS-FILE-LENGTH TO RS-E-LENGTH(RS-COUNT)
                                 END-IF
                             END-IF
                           END-IF
                         END-IF
                     END-IF
                 END-IF
         END-EVALUATE
         COMPUTE LS-POS = LS-END + 1
     END-PERFORM
     FREE LS-LIST-ADDR
     GOBACK.

 END PROGRAM REGISTRY-SCAN-DIR.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS-LIST-DIR.
*> USING folder (z-string, PIC X(1101)), list address out (POINTER: ALLOCATEd, the caller FREEs it when the
*> status is 0), entry count out (BINARY-LONG), status out (0 listed, 1 the folder cannot be listed). The
*> listing is cc_fs_list's "<type><name>" lines, each ended by LF, in byte order (contracts shim-abi 7).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 B-LIST                 PIC X(16777216) BASED.
 01 WS-CAPACITY            BINARY-LONG.
 01 WS-RC                  BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIR                  PIC X(1101).
 01 L-ADDR                 USAGE POINTER.
 01 L-COUNT                BINARY-LONG.
 01 L-STATUS               BINARY-LONG.
 PROCEDURE DIVISION USING L-DIR L-ADDR L-COUNT L-STATUS.
     MOVE 4096 TO WS-CAPACITY
     MOVE 5 TO WS-RC
     PERFORM UNTIL WS-RC NOT = 5
         ALLOCATE WS-CAPACITY CHARACTERS RETURNING L-ADDR
         SET ADDRESS OF B-LIST TO L-ADDR
         MOVE 0 TO L-COUNT
         CALL STATIC "cc_fs_list" USING BY REFERENCE L-DIR BY REFERENCE B-LIST
             BY VALUE WS-CAPACITY BY REFERENCE L-COUNT RETURNING WS-RC
         IF WS-RC = 5
             FREE L-ADDR
             COMPUTE WS-CAPACITY = WS-CAPACITY * 2
         END-IF
     END-PERFORM
     MOVE 0 TO L-STATUS
     IF WS-RC NOT = 0
         FREE L-ADDR
         MOVE 0 TO L-COUNT
         MOVE 1 TO L-STATUS
     END-IF
     GOBACK.
 END PROGRAM RS-LIST-DIR.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS-ID-VALID.
*> USING text (PIC X(64)), length (BINARY-LONG), mode and result (BINARY-LONG, one word: in 1 namespace, 2
*> path; out 1 valid, 0 not): 23 section 1: a namespace holds a-z 0-9 _ - . and is not ".."; a path holds
*> those and "/"; neither is empty.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-I                   BINARY-LONG.
 01 WS-C                   PIC X.
 01 WS-MODE                BINARY-LONG.
 LINKAGE SECTION.
 01 L-TEXT                 PIC X(64).
 01 L-LENGTH               BINARY-LONG.
 01 L-MODE                 BINARY-LONG.
 PROCEDURE DIVISION USING L-TEXT L-LENGTH L-MODE.
     MOVE L-MODE TO WS-MODE
     MOVE 1 TO L-MODE
     IF L-LENGTH < 1
         MOVE 0 TO L-MODE
         GOBACK
     END-IF
     IF WS-MODE = 1 AND L-TEXT(1:L-LENGTH) = ".."
         MOVE 0 TO L-MODE
         GOBACK
     END-IF
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > L-LENGTH OR L-MODE = 0
         MOVE L-TEXT(WS-I:1) TO WS-C
         IF NOT ((WS-C >= "a" AND WS-C <= "z") OR (WS-C >= "0" AND WS-C <= "9")
                 OR WS-C = "_" OR WS-C = "-" OR WS-C = "." OR (WS-C = "/" AND WS-MODE = 2))
             MOVE 0 TO L-MODE
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM RS-ID-VALID.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS-PAYLOAD-APPEND.
*> USING area (any size), length (BINARY-LONG, at least 1), offset out (BINARY-LONG: where the bytes start in
*> the payload buffer): appends the bytes to the payload buffer of RS-STATE, doubling its capacity as needed.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CTLOAD.
 01 B-MEM                  PIC X(268435456) BASED.
 01 B-NEW                  PIC X(268435456) BASED.
 01 B-SRC                  PIC X(268435456) BASED.
 01 WS-CAPACITY            BINARY-LONG.
 01 WS-NEW-ADDR            USAGE POINTER.
 LINKAGE SECTION.
 01 L-AREA                 PIC X.
 01 L-LENGTH               BINARY-LONG.
 01 L-OFFSET               BINARY-LONG.
 PROCEDURE DIVISION USING L-AREA L-LENGTH L-OFFSET.
     MOVE RS-PAYLOAD-LENGTH TO L-OFFSET
     IF RS-PAYLOAD-LENGTH + L-LENGTH > RS-PAYLOAD-CAPACITY
         MOVE RS-PAYLOAD-CAPACITY TO WS-CAPACITY
         IF WS-CAPACITY < 65536
             MOVE 65536 TO WS-CAPACITY
         END-IF
         PERFORM UNTIL WS-CAPACITY >= RS-PAYLOAD-LENGTH + L-LENGTH
             COMPUTE WS-CAPACITY = WS-CAPACITY * 2
         END-PERFORM
         ALLOCATE WS-CAPACITY CHARACTERS RETURNING WS-NEW-ADDR
         IF RS-PAYLOAD-ADDR NOT = NULL
             SET ADDRESS OF B-NEW TO WS-NEW-ADDR
             SET ADDRESS OF B-MEM TO RS-PAYLOAD-ADDR
             MOVE B-MEM(1:RS-PAYLOAD-LENGTH) TO B-NEW(1:RS-PAYLOAD-LENGTH)
             FREE RS-PAYLOAD-ADDR
         END-IF
         SET RS-PAYLOAD-ADDR TO WS-NEW-ADDR
         MOVE WS-CAPACITY TO RS-PAYLOAD-CAPACITY
     END-IF
     SET ADDRESS OF B-MEM TO RS-PAYLOAD-ADDR
     SET ADDRESS OF B-SRC TO ADDRESS OF L-AREA
     MOVE B-SRC(1:L-LENGTH) TO B-MEM(RS-PAYLOAD-LENGTH + 1:L-LENGTH)
     ADD L-LENGTH TO RS-PAYLOAD-LENGTH
     GOBACK.
 END PROGRAM RS-PAYLOAD-APPEND.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. REGISTRY-BUILD.
*> USING slot (BINARY-LONG): sorts the collected elements by element id (path first, then namespace), builds the
*> entries of the registry at that row in that order (the id of an entry is its index) and hands the payload
*> buffer to the registry. With no elements the registry stays empty.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CONTENT.
 COPY CTSTORE.
 COPY CTLOAD.
 01 WS-ADDR                USAGE POINTER.
 01 WS-I                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-HELD                BINARY-LONG.
 01 WS-PATH-A              PIC X(64).
 01 WS-NS-A                PIC X(32).
 01 WS-PATH-B              PIC X(64).
 01 WS-NS-B                PIC X(32).
 01 WS-AFTER               BINARY-LONG.
 01 WS-PATH-LENGTH         BINARY-LONG.
 01 WS-NS-LENGTH           BINARY-LONG.
 LINKAGE SECTION.
 01 L-SLOT                 BINARY-LONG.
 PROCEDURE DIVISION USING L-SLOT.
     IF RS-COUNT = 0
         GOBACK
     END-IF
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > RS-COUNT
         MOVE WS-I TO RS-ORDER(WS-I)
     END-PERFORM
*>   Insertion sort of the order table: the held element moves left past every element sorting after it.
     PERFORM VARYING WS-I FROM 2 BY 1 UNTIL WS-I > RS-COUNT
         MOVE RS-ORDER(WS-I) TO WS-HELD
         MOVE RS-E-PATH(WS-HELD) TO WS-PATH-A
         MOVE RS-E-NS(WS-HELD) TO WS-NS-A
         COMPUTE WS-J = WS-I - 1
         MOVE 1 TO WS-AFTER
         PERFORM UNTIL WS-J < 1 OR WS-AFTER = 0
             MOVE RS-ORDER(WS-J) TO WS-K
             MOVE RS-E-PATH(WS-K) TO WS-PATH-B
             MOVE RS-E-NS(WS-K) TO WS-NS-B
             MOVE 0 TO WS-AFTER
             IF WS-PATH-B > WS-PATH-A OR (WS-PATH-B = WS-PATH-A AND WS-NS-B > WS-NS-A)
                 MOVE 1 TO WS-AFTER
                 MOVE RS-ORDER(WS-J) TO RS-ORDER(WS-J + 1)
                 SUBTRACT 1 FROM WS-J
             END-IF
         END-PERFORM
         MOVE WS-HELD TO RS-ORDER(WS-J + 1)
     END-PERFORM
     ALLOCATE RS-COUNT * LENGTH OF BE-ROW(1) CHARACTERS RETURNING WS-ADDR
     SET ADDRESS OF B-ENTRIES TO WS-ADDR
     SET ADDRESS OF B-REGISTRIES TO CT-REGISTRY-ADDR
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > RS-COUNT
         MOVE RS-ORDER(WS-I) TO WS-K
         MOVE 0 TO WS-PATH-LENGTH WS-NS-LENGTH
         INSPECT RS-E-PATH(WS-K) TALLYING WS-PATH-LENGTH FOR CHARACTERS BEFORE INITIAL SPACE
         INSPECT RS-E-NS(WS-K) TALLYING WS-NS-LENGTH FOR CHARACTERS BEFORE INITIAL SPACE
         MOVE SPACES TO BE-KEY(WS-I)
         STRING RS-E-NS(WS-K)(1:WS-NS-LENGTH) ":" RS-E-PATH(WS-K)(1:WS-PATH-LENGTH) DELIMITED BY SIZE
             INTO BE-KEY(WS-I)
         COMPUTE BE-KEY-LENGTH(WS-I) = WS-NS-LENGTH + 1 + WS-PATH-LENGTH
         MOVE RS-E-OFFSET(WS-K) TO BE-PAYLOAD-OFFSET(WS-I)
         MOVE RS-E-LENGTH(WS-K) TO BE-PAYLOAD-LENGTH(WS-I)
     END-PERFORM
     SET BR-ENTRY-ADDR(L-SLOT) TO WS-ADDR
     MOVE RS-COUNT TO BR-ENTRY-COUNT(L-SLOT)
     SET BR-PAYLOAD-ADDR(L-SLOT) TO RS-PAYLOAD-ADDR
     MOVE RS-PAYLOAD-LENGTH TO BR-PAYLOAD-LENGTH(L-SLOT)
     SET RS-PAYLOAD-ADDR TO NULL
     GOBACK.
 END PROGRAM REGISTRY-BUILD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. REGISTRY-FREE.
*> No parameters: releases the registry table of the set, every registry's entries and payload, and zeroes
*> CT-REGISTRY-COUNT and CT-REGISTRY-ADDR. Safe with nothing loaded.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CONTENT.
 COPY CTSTORE.
 01 WS-I                   BINARY-LONG.
 PROCEDURE DIVISION.
     IF CT-REGISTRY-ADDR NOT = NULL
         SET ADDRESS OF B-REGISTRIES TO CT-REGISTRY-ADDR
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > CT-REGISTRY-COUNT
             IF BR-ENTRY-ADDR(WS-I) NOT = NULL
                 FREE BR-ENTRY-ADDR(WS-I)
             END-IF
             IF BR-PAYLOAD-ADDR(WS-I) NOT = NULL
                 FREE BR-PAYLOAD-ADDR(WS-I)
             END-IF
         END-PERFORM
         FREE CT-REGISTRY-ADDR
     END-IF
     SET CT-REGISTRY-ADDR TO NULL
     MOVE 0 TO CT-REGISTRY-COUNT
     GOBACK.
 END PROGRAM REGISTRY-FREE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CONTENT-REGISTRY-COUNT.
*> USING registry (PIC X(64), the key with or without "minecraft:"), count out (BINARY-LONG: the entries of the
*> registry, 0 when it is not found), status out (CT-OK; CT-NOT-FOUND for a registry the set has not loaded;
*> CT-NOT-OPEN).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CONTENT.
 COPY CTSTORE.
 01 WS-KEY                 PIC X(64).
 01 WS-I                   BINARY-LONG.
 01 WS-HAS-NAMESPACE       BINARY-LONG.
 LINKAGE SECTION.
 01 L-REGISTRY             PIC X(64).
 01 L-COUNT                BINARY-LONG.
 01 L-STATUS               BINARY-LONG.
 PROCEDURE DIVISION USING L-REGISTRY L-COUNT L-STATUS.
     MOVE 0 TO L-COUNT
     IF CT-OPEN = 0
         MOVE CT-NOT-OPEN TO L-STATUS
         GOBACK
     END-IF
     MOVE CT-NOT-FOUND TO L-STATUS
     IF CT-REGISTRY-ADDR = NULL
         GOBACK
     END-IF
     MOVE 0 TO WS-HAS-NAMESPACE
     INSPECT L-REGISTRY TALLYING WS-HAS-NAMESPACE FOR ALL ":"
     MOVE SPACES TO WS-KEY
     IF WS-HAS-NAMESPACE = 0
         STRING "minecraft:" FUNCTION TRIM(L-REGISTRY) DELIMITED BY SIZE INTO WS-KEY
     ELSE
         MOVE L-REGISTRY TO WS-KEY
     END-IF
     SET ADDRESS OF B-REGISTRIES TO CT-REGISTRY-ADDR
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > CT-REGISTRY-COUNT OR L-STATUS = CT-OK
         IF BR-KEY(WS-I) = WS-KEY
             MOVE BR-ENTRY-COUNT(WS-I) TO L-COUNT
             MOVE CT-OK TO L-STATUS
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM CONTENT-REGISTRY-COUNT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CONTENT-REGISTRY-ENTRY.
*> USING registry (PIC X(64)), entry id (BINARY-LONG), key out (PIC X(64), with namespace), key length out
*> (BINARY-LONG), payload area out (any size: the entry's strict JSON, or the network NBT tag bytes of a
*> client set), capacity (BINARY-LONG bytes of the area), payload length out (BINARY-LONG), status out (CT-OK;
*> CT-NOT-FOUND for an unknown registry or an id outside 0 to count - 1; CT-TOO-SMALL when the area is
*> smaller than the payload, the length still given and the area left alone; CT-NOT-OPEN).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CONTENT.
 COPY CTSTORE.
 01 B-DST                  PIC X(268435456) BASED.
 01 WS-KEY                 PIC X(64).
 01 WS-I                   BINARY-LONG.
 01 WS-FOUND               BINARY-LONG.
 01 WS-HAS-NAMESPACE       BINARY-LONG.
 LINKAGE SECTION.
 01 L-REGISTRY             PIC X(64).
 01 L-ID                   BINARY-LONG.
 01 L-KEY                  PIC X(64).
 01 L-KEY-LENGTH           BINARY-LONG.
 01 L-PAYLOAD              PIC X.
 01 L-CAPACITY             BINARY-LONG.
 01 L-LENGTH               BINARY-LONG.
 01 L-STATUS               BINARY-LONG.
 PROCEDURE DIVISION USING L-REGISTRY L-ID L-KEY L-KEY-LENGTH L-PAYLOAD L-CAPACITY L-LENGTH L-STATUS.
     MOVE 0 TO L-KEY-LENGTH L-LENGTH
     IF CT-OPEN = 0
         MOVE CT-NOT-OPEN TO L-STATUS
         GOBACK
     END-IF
     MOVE CT-NOT-FOUND TO L-STATUS
     IF CT-REGISTRY-ADDR = NULL
         GOBACK
     END-IF
     MOVE 0 TO WS-HAS-NAMESPACE
     INSPECT L-REGISTRY TALLYING WS-HAS-NAMESPACE FOR ALL ":"
     MOVE SPACES TO WS-KEY
     IF WS-HAS-NAMESPACE = 0
         STRING "minecraft:" FUNCTION TRIM(L-REGISTRY) DELIMITED BY SIZE INTO WS-KEY
     ELSE
         MOVE L-REGISTRY TO WS-KEY
     END-IF
     SET ADDRESS OF B-REGISTRIES TO CT-REGISTRY-ADDR
     MOVE 0 TO WS-FOUND
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > CT-REGISTRY-COUNT OR WS-FOUND > 0
         IF BR-KEY(WS-I) = WS-KEY
             MOVE WS-I TO WS-FOUND
         END-IF
     END-PERFORM
     IF WS-FOUND = 0 OR L-ID < 0
         GOBACK
     END-IF
     IF L-ID >= BR-ENTRY-COUNT(WS-FOUND)
         GOBACK
     END-IF
     SET ADDRESS OF B-ENTRIES TO BR-ENTRY-ADDR(WS-FOUND)
     COMPUTE WS-I = L-ID + 1
     MOVE BE-KEY(WS-I) TO L-KEY
     MOVE BE-KEY-LENGTH(WS-I) TO L-KEY-LENGTH
     MOVE BE-PAYLOAD-LENGTH(WS-I) TO L-LENGTH
     IF BE-PAYLOAD-LENGTH(WS-I) > L-CAPACITY
         MOVE CT-TOO-SMALL TO L-STATUS
         GOBACK
     END-IF
     SET ADDRESS OF B-PAYLOAD TO BR-PAYLOAD-ADDR(WS-FOUND)
     SET ADDRESS OF B-DST TO ADDRESS OF L-PAYLOAD
     MOVE B-PAYLOAD(BE-PAYLOAD-OFFSET(WS-I) + 1:BE-PAYLOAD-LENGTH(WS-I)) TO B-DST(1:BE-PAYLOAD-LENGTH(WS-I))
     MOVE CT-OK TO L-STATUS
     GOBACK.
 END PROGRAM CONTENT-REGISTRY-ENTRY.
