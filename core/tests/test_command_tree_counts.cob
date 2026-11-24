*> Test of the Commands packet the core sends per permission level (docs/protocol/57-client-closures-4 sections 4, 5 and 10; T2014): the node count of a dedicated
*> server's tree at levels 0 and 1 (26, with the totals of 5.2 by kind: literal and argument nodes, executable, redirect, executable and redirect, restricted and
*> custom-suggestion nodes; one more than the document's since lane buglocate3 gives /locate structure the ask_server provider, see gen_command_tree.py) and of the integrated host's (28), the byte-exact level 0 packets of 10.1 and 10.2, the byte-exact packets of the dedicated levels 2, 3 and 4 (wire fixtures made from the listings), and the sizes and totals by kind of the levels 2 to 4: dedicated
*> 2333, 2385 and 2396 nodes (the integrated host's 2333, 2353 and 2360), equal to 5.1 and 5.2, and the 131 custom suggestion providers of 2.3 by Identifier (114, 13, 2, 2).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-COMMAND-TREE-COUNTS.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY PROTO.
 COPY BRIGADIER.
 01 WS-CAPACITY            BINARY-LONG VALUE 262144.
 01 WS-LEVEL               BINARY-LONG.
 01 WS-HOST                BINARY-LONG.
 01 WS-ID                  BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-LITERALS            BINARY-LONG.
 01 WS-ARGUMENTS           BINARY-LONG.
 01 WS-EXEC                BINARY-LONG.
 01 WS-REDIRECT            BINARY-LONG.
 01 WS-BOTH                BINARY-LONG.
 01 WS-RESTRICTED          BINARY-LONG.
 01 WS-SUGGEST             BINARY-LONG.
 01 WS-BITS                BINARY-LONG.
 01 WS-Q                   BINARY-LONG.
 01 WS-EXEC-BIT            BINARY-LONG.
 01 WS-REDIRECT-BIT        BINARY-LONG.
 01 WS-SUGGEST-BIT         BINARY-LONG.
 01 WS-RESTRICTED-BIT      BINARY-LONG.
 01 WS-E1                  PIC -(9)9.
 01 WS-E2                  PIC -(9)9.
 01 WS-E3                  PIC -(9)9.
 01 WS-E4                  PIC -(9)9.
 01 WS-E5                  PIC -(9)9.
 01 WS-E6                  PIC -(9)9.
 01 WS-E7                  PIC -(9)9.
 01 WS-E8                  PIC -(9)9.
 01 WS-EXPECT-TABLE.
    05 FILLER              PIC X(60) VALUE "0 0 26 15 10 12 3 0 0 1".
    05 FILLER              PIC X(60) VALUE "0 1 26 15 10 12 3 0 0 1".
    05 FILLER              PIC X(60) VALUE "0 2 2333 1116 1216 1371 78 44 66 122".
    05 FILLER              PIC X(60) VALUE "0 3 2385 1148 1236 1406 78 44 80 132".
    05 FILLER              PIC X(60) VALUE "0 4 2396 1157 1238 1414 78 44 86 132".
    05 FILLER              PIC X(60) VALUE "1 0 28 17 10 14 3 0 0 1".
    05 FILLER              PIC X(60) VALUE "1 1 28 17 10 14 3 0 0 1".
    05 FILLER              PIC X(60) VALUE "1 2 2333".
    05 FILLER              PIC X(60) VALUE "1 3 2353".
    05 FILLER              PIC X(60) VALUE "1 4 2360".
    05 FILLER              PIC X(60) VALUE "0 0 26 15 10 12 3 0 0 1".
 01 WS-EXPECTS REDEFINES WS-EXPECT-TABLE.
    05 WS-EXPECT           PIC X(60) OCCURS 11 TIMES.
 01 WS-ROW                 BINARY-LONG.
 01 WS-PATH                PIC X(256).
 01 WS-ROW-TEXT            PIC 99.
 01 WS-APPLIED             BINARY-LONG.
 01 WS-MISSING             BINARY-LONG.
 01 WS-PROV-ASK            BINARY-LONG.
 01 WS-PROV-SOUNDS         BINARY-LONG.
 01 WS-PROV-SUMMON         BINARY-LONG.
 01 WS-PROV-POST           BINARY-LONG.
 PROCEDURE DIVISION.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     MOVE "T" TO TL-MODE
     PERFORM VARYING WS-ROW FROM 1 BY 1 UNTIL WS-ROW > 11
         COMPUTE WS-LEVEL = FUNCTION NUMVAL(WS-EXPECT(WS-ROW)(3:1))
         COMPUTE WS-HOST = FUNCTION NUMVAL(WS-EXPECT(WS-ROW)(1:1))
         MOVE WS-HOST TO CS-HOST-KIND
         MOVE CORE-SETTINGS TO CW-SETTINGS
         CALL "BR-TREE-RESET"
         CALL "BR-STD-TREE"
         PERFORM COUNT-TREE
         MOVE WS-ROW TO WS-ROW-TEXT
         MOVE WS-COUNT TO WS-E1
         MOVE WS-LITERALS TO WS-E2
         MOVE WS-ARGUMENTS TO WS-E3
         MOVE WS-EXEC TO WS-E4
         MOVE WS-REDIRECT TO WS-E5
         MOVE WS-BOTH TO WS-E6
         MOVE WS-RESTRICTED TO WS-E7
         MOVE SPACES TO TL-CASE TL-OBSERVED
         STRING "test command tree counts host " WS-EXPECT(WS-ROW)(1:1) " level " WS-EXPECT(WS-ROW)(3:1)
             " nodes and kinds (nodes literals arguments executable redirect both restricted suggest) of tree build " WS-ROW-TEXT
             DELIMITED BY SIZE INTO TL-CASE
         MOVE WS-SUGGEST TO WS-E8
         IF WS-EXPECT(WS-ROW)(9:) = SPACES
             MOVE FUNCTION TRIM(WS-E1) TO TL-OBSERVED
         ELSE
             STRING FUNCTION TRIM(WS-E1) " " FUNCTION TRIM(WS-E2) " " FUNCTION TRIM(WS-E3) " " FUNCTION TRIM(WS-E4) " "
                 FUNCTION TRIM(WS-E5) " " FUNCTION TRIM(WS-E6) " " FUNCTION TRIM(WS-E7) " " FUNCTION TRIM(WS-E8)
                 DELIMITED BY SIZE INTO TL-OBSERVED
         END-IF
         MOVE SPACES TO TL-EXPECTED
         MOVE WS-EXPECT(WS-ROW)(5:) TO TL-EXPECTED
         MOVE FUNCTION TRIM(TL-EXPECTED) TO TL-EXPECTED
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     END-PERFORM
*>   The level 0 packets of 57-4 section 10 byte for byte (wire fixtures built from its tables; T2014).
     MOVE 0 TO WS-LEVEL
     PERFORM VARYING WS-HOST FROM 0 BY 1 UNTIL WS-HOST > 1
         MOVE WS-HOST TO CS-HOST-KIND
         MOVE CORE-SETTINGS TO CW-SETTINGS
         CALL "BR-TREE-RESET"
         CALL "BR-STD-TREE"
         CALL "PB-RESET" USING PB-BUFFER
         CALL "BR-TREE-BUILD" USING WS-LEVEL PB-BUFFER
         MOVE SPACES TO WS-PATH TL-CASE
         IF WS-HOST = 0
             MOVE "contract/fixtures/wire/play-s2c-10-commands-level0-dedicated.hex" TO WS-PATH
             MOVE "test command tree counts contract wire server play-s2c-10-commands-level0-dedicated equals the core's level 0 tree of a dedicated server" TO TL-CASE
         ELSE
             MOVE "contract/fixtures/wire/play-s2c-10-commands-level0-integrated.hex" TO WS-PATH
             MOVE "test command tree counts contract wire server play-s2c-10-commands-level0-integrated equals the core's level 0 tree of the integrated host" TO TL-CASE
         END-IF
         CALL "TEST-SAME-AS-FIXTURE" USING PB-BUFFER WS-PATH TESTLIB-ASSERT
     END-PERFORM
*>   The custom suggestion providers of 2.3 at level 4 of a dedicated tree: every strict row of BRSUG.cpy exists in the tree, and the nodes by Identifier.
     MOVE 0 TO CS-HOST-KIND
     MOVE CORE-SETTINGS TO CW-SETTINGS
     CALL "BR-TREE-RESET"
     CALL "BR-STD-TREE"
     CALL "BR-SUGGEST-APPLY" USING WS-APPLIED WS-MISSING
     MOVE "N" TO TL-MODE
     MOVE "test command tree counts every document node with a custom suggestion provider of a command built like the document exists in the tree" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-MISSING TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "test command tree counts the provider rows applied to the core's tree (the 131 rows of 2.3: every command is built like the document)" TO TL-CASE
     MOVE 131 TO TL-EXPECTED-N
     MOVE WS-APPLIED TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 4 TO WS-LEVEL
     PERFORM COUNT-TREE
     MOVE "T" TO TL-MODE
     MOVE WS-PROV-ASK TO WS-E1
     MOVE WS-PROV-SOUNDS TO WS-E2
     MOVE WS-PROV-SUMMON TO WS-E3
     MOVE WS-PROV-POST TO WS-E4
     MOVE SPACES TO TL-OBSERVED TL-EXPECTED
     STRING FUNCTION TRIM(WS-E1) " " FUNCTION TRIM(WS-E2) " " FUNCTION TRIM(WS-E3) " " FUNCTION TRIM(WS-E4) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "test command tree counts level 4 nodes by provider: ask_server, available_sounds, summonable_entities, post_effects" TO TL-CASE
     MOVE "115 13 2 2" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   The packets of the dedicated levels 2, 3 and 4 byte for byte (the wire fixtures made from the listings of section 7 by core/tests/fixtures/gen_command_tree.py:
*>   argument names, parser ids, registries, child order and executable marks of all 91 commands).
     PERFORM VARYING WS-LEVEL FROM 2 BY 1 UNTIL WS-LEVEL > 4
         CALL "PB-RESET" USING PB-BUFFER
         CALL "BR-TREE-BUILD" USING WS-LEVEL PB-BUFFER
         MOVE SPACES TO WS-PATH TL-CASE
         EVALUATE WS-LEVEL
             WHEN 2
                 MOVE "contract/fixtures/wire/play-s2c-10-commands-level2-dedicated.hex" TO WS-PATH
                 MOVE "test command tree counts contract wire server play-s2c-10-commands-level2-dedicated equals the core's level 2 tree of a dedicated server" TO TL-CASE
             WHEN 3
                 MOVE "contract/fixtures/wire/play-s2c-10-commands-level3-dedicated.hex" TO WS-PATH
                 MOVE "test command tree counts contract wire server play-s2c-10-commands-level3-dedicated equals the core's level 3 tree of a dedicated server" TO TL-CASE
             WHEN OTHER
                 MOVE "contract/fixtures/wire/play-s2c-10-commands-operator.hex" TO WS-PATH
                 MOVE "test command tree counts contract wire server play-s2c-10-commands-operator equals the core's level 4 tree of a dedicated server" TO TL-CASE
         END-EVALUATE
         CALL "TEST-SAME-AS-FIXTURE" USING PB-BUFFER WS-PATH TESTLIB-ASSERT
     END-PERFORM
     STOP RUN.

 COUNT-TREE.
     CALL "PB-RESET" USING PB-BUFFER
     CALL "BR-TREE-BUILD" USING WS-LEVEL PB-BUFFER
     MOVE 0 TO PB-POS
     CALL "PB-GET-VARINT" USING PB-BUFFER WS-ID
     CALL "PB-GET-VARINT" USING PB-BUFFER WS-COUNT
     MOVE 0 TO WS-LITERALS WS-ARGUMENTS WS-EXEC WS-REDIRECT WS-BOTH WS-RESTRICTED WS-SUGGEST
     MOVE 0 TO WS-PROV-ASK WS-PROV-SOUNDS WS-PROV-SUMMON WS-PROV-POST
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-COUNT
         CALL "PB-GET-COMMAND-NODE-X" USING PB-BUFFER PB-COMMAND-NODE-X
         COMPUTE WS-BITS = FUNCTION MOD(PB-CX-FLAGS, 4)
         IF WS-BITS = 1
             ADD 1 TO WS-LITERALS
         END-IF
         IF WS-BITS = 2
             ADD 1 TO WS-ARGUMENTS
         END-IF
         COMPUTE WS-Q = PB-CX-FLAGS / 4
         COMPUTE WS-EXEC-BIT = FUNCTION MOD(WS-Q, 2)
         COMPUTE WS-Q = PB-CX-FLAGS / 8
         COMPUTE WS-REDIRECT-BIT = FUNCTION MOD(WS-Q, 2)
         COMPUTE WS-Q = PB-CX-FLAGS / 16
         COMPUTE WS-SUGGEST-BIT = FUNCTION MOD(WS-Q, 2)
         COMPUTE WS-Q = PB-CX-FLAGS / 32
         COMPUTE WS-RESTRICTED-BIT = FUNCTION MOD(WS-Q, 2)
         ADD WS-EXEC-BIT TO WS-EXEC
         ADD WS-REDIRECT-BIT TO WS-REDIRECT
         ADD WS-SUGGEST-BIT TO WS-SUGGEST
         IF WS-SUGGEST-BIT = 1
             EVALUATE PB-CX-SUGGEST(1:PB-CX-SUGGEST-LENGTH)
                 WHEN "minecraft:ask_server"
                     ADD 1 TO WS-PROV-ASK
                 WHEN "minecraft:available_sounds"
                     ADD 1 TO WS-PROV-SOUNDS
                 WHEN "minecraft:summonable_entities"
                     ADD 1 TO WS-PROV-SUMMON
                 WHEN "minecraft:post_effects"
                     ADD 1 TO WS-PROV-POST
             END-EVALUATE
         END-IF
         ADD WS-RESTRICTED-BIT TO WS-RESTRICTED
         IF WS-EXEC-BIT = 1 AND WS-REDIRECT-BIT = 1
             ADD 1 TO WS-BOTH
         END-IF
     END-PERFORM.
 END PROGRAM TEST-COMMAND-TREE-COUNTS.

 COPY CORETEST.
