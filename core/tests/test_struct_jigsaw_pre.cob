*> Acceptance test of the prerequisites of the jigsaw assembly (docs/protocol/36-structures-2 sections 1.5, 3.4, 3.5 and 9.6; 36-structures-3 section 4): the jigsaw_replacement processor
*> (a jigsaw becomes its final_state, nothing for structure_void or a state that does not parse, a jigsaw without block entity data and every other block are kept), the jigsaw records of a
*> placed template (getJigsaws: position, rotated orientation, joint with its default, names and priorities, in block order) and calculateConnectedPosition. Runs over the standard content
*> set of the generated packs (skipped as a pass without them) and the template fixtures of core/tests/fixtures/tpl.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-STRUCT-JIGSAW-PRE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CONTENT.
 COPY CBLOCKS.
 COPY STRUCTTPL.
 COPY STRUCTPLACE.
 COPY STRUCTPROC.
 COPY STRUCTSET.
 COPY STRUCTJIG.
 01 WS-TPL-DIR             PIC X(1100) VALUE "core/tests/fixtures/tpl".
 01 WS-GEN-DIR             PIC X(1100).
 01 WS-ENV                 PIC X(1100).
 01 WS-FILE                PIC X(1200).
 01 WS-FILE-INFO           PIC X(16).
 01 WS-TYPE                BINARY-LONG.
 01 WS-STATUS              BINARY-LONG.
 01 WS-ID                  PIC X(96).
 01 WS-ROW                 BINARY-LONG.
 01 WS-KEY                 PIC X(80) VALUE "cobolcraft:inline/jigsaw_replacement".
 01 WS-LIST                BINARY-LONG.
 01 WS-FLAG                BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-R                   BINARY-LONG.
 01 WS-OX                  BINARY-LONG.
 01 WS-OY                  BINARY-LONG.
 01 WS-OZ                  BINARY-LONG.
 01 WS-AX                  BINARY-LONG.
 01 WS-AY                  BINARY-LONG.
 01 WS-AZ                  BINARY-LONG.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
 01 WS-ROT                 BINARY-LONG.
 01 WS-TAG                 BINARY-LONG.
 01 WS-NAMES               PIC X(60).
 01 WS-ST                  BINARY-LONG.
 01 WS-A-MIR               BINARY-LONG.
 01 WS-A-ROT               BINARY-LONG.
 01 WS-A-PX                BINARY-LONG.
 01 WS-A-PZ                BINARY-LONG.
 01 WS-A-X                 BINARY-LONG.
 01 WS-A-Y                 BINARY-LONG.
 01 WS-A-Z                 BINARY-LONG.
 01 WS-B-MIR               BINARY-LONG.
 01 WS-B-ROT               BINARY-LONG.
 01 WS-B-PX                BINARY-LONG.
 01 WS-B-PZ                BINARY-LONG.
 01 WS-B-X                 BINARY-LONG.
 01 WS-B-Y                 BINARY-LONG.
 01 WS-B-Z                 BINARY-LONG.
 01 WS-C-X                 BINARY-LONG.
 01 WS-C-Y                 BINARY-LONG.
 01 WS-C-Z                 BINARY-LONG.
 01 WS-LABEL               PIC X(150).
 01 WS-ROT-D               PIC 9.
 01 WS-TEXT                PIC X(160).
 01 WS-STATE               BINARY-LONG.
 01 WS-FRONT               BINARY-LONG.
 01 WS-TOP                 BINARY-LONG.
 01 WS-DIRNAME             PIC X(8).
 01 WS-J-D                 PIC 9.
*> the expected jigsaws of test:jigs per rotation (x, z relative; front and top of the three records in block order): rotation 0 to 3
 01 WS-WANT-DATA.
    05 FILLER PIC X(33) VALUE "+00+00 2 1 +01+02 4 1 +03+00 1 5 ".
    05 FILLER PIC X(33) VALUE "+00+00 5 1 -02+01 2 1 +00+03 1 3 ".
    05 FILLER PIC X(33) VALUE "+00+00 3 1 -01-02 5 1 -03+00 1 4 ".
    05 FILLER PIC X(33) VALUE "+00+00 4 1 +02-01 3 1 +00-03 1 2 ".
 01 WS-WANT-T REDEFINES WS-WANT-DATA.
    05 WS-WANT-ROT OCCURS 4 TIMES.
       10 WS-WANT-REC OCCURS 3 TIMES.
          15 WW-X          PIC S99 SIGN LEADING SEPARATE.
          15 WW-Z          PIC S99 SIGN LEADING SEPARATE.
          15 FILLER        PIC X.
          15 WW-FRONT      PIC 9.
          15 FILLER        PIC X.
          15 WW-TOP        PIC 9.
          15 FILLER        PIC X.
 PROCEDURE DIVISION.
     MOVE "N" TO TL-MODE
     MOVE SPACES TO WS-ENV
     ACCEPT WS-ENV FROM ENVIRONMENT "CC_GENERATED_DIR"
     IF WS-ENV = SPACES
         MOVE "/tmp/cc-test/generated" TO WS-GEN-DIR
     ELSE
         MOVE WS-ENV TO WS-GEN-DIR
     END-IF
     MOVE SPACES TO WS-FILE
     STRING FUNCTION TRIM(WS-GEN-DIR TRAILING) "/vanilla-data/pack.mcmeta" X"00" DELIMITED BY SIZE INTO WS-FILE
     CALL "CBL_CHECK_FILE_EXIST" USING WS-FILE WS-FILE-INFO
     IF RETURN-CODE NOT = 0
         MOVE "test struct jigsaw pre no generated packs here, skipped" TO TL-CASE
         MOVE 1 TO TL-EXPECTED-N
         MOVE 1 TO TL-OBSERVED-N
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
         STOP RUN
     END-IF
     MOVE CT-TYPE-STANDARD TO WS-TYPE
     CALL "CONTENT-OPEN" USING WS-TYPE WS-GEN-DIR WS-STATUS
     CALL "BLOCKS-OPEN"
     CALL "STRUCT-TPL-RESET"
     PERFORM REPLACEMENT-CASES
     PERFORM JIGSAW-CASES
     PERFORM CONNECTED-CASES
     STOP RUN.

 CHECK.
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-FLAG TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

*> 9.6: the processor is code-defined here as the list cobolcraft:inline/jigsaw_replacement
 REPLACEMENT-CASES.
     MOVE "test:jigrep" TO WS-ID
     CALL "STRUCT-TPL-LOAD" USING WS-TPL-DIR WS-ID WS-ROW
     CALL "STRUCT-PROC-LOAD" USING WS-KEY WS-LIST
     MOVE "test struct jigsaw pre given the jigsaw_replacement list when it is loaded then it is one processor of type 6" TO TL-CASE
     MOVE 0 TO WS-FLAG
     IF WS-LIST > 0
         IF SPL-N(WS-LIST) = 1 AND SPP-TYPE(SPL-FIRST(WS-LIST)) = 6
             MOVE 1 TO WS-FLAG
         END-IF
     END-IF
     PERFORM CHECK
     INITIALIZE STRUCT-SETTINGS
     MOVE WS-LIST TO PS-PROCESSORS
     MOVE 0 TO WS-OX
     MOVE 70 TO WS-OY
     MOVE 0 TO WS-OZ
     MOVE 0 TO WS-AX
     MOVE 70 TO WS-AY
     MOVE 0 TO WS-AZ
     CALL "STRUCT-PROCESS" USING WS-ROW WS-ZERO WS-OX WS-OY WS-OZ WS-AX WS-AY WS-AZ STRUCT-SETTINGS
     MOVE "test struct jigsaw pre given a template of eight blocks when it is processed then six records remain (structure_void and the unparsable state drop theirs)" TO TL-CASE
     MOVE 6 TO TL-EXPECTED-N
     MOVE PW-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "stone" TO WS-NAMES
     MOVE 0 TO WS-X
     PERFORM RECORD-KEY
     MOVE "test struct jigsaw pre given a jigsaw with final_state stone when it is processed then it is stone without a tag" TO TL-CASE
     MOVE 0 TO WS-FLAG
     IF WS-NAMES = "stone" AND PW-NBT(WS-R) = 0
         MOVE 1 TO WS-FLAG
     END-IF
     PERFORM CHECK
     MOVE 1 TO WS-X
     PERFORM RECORD-KEY
     MOVE "test struct jigsaw pre given a jigsaw with final_state structure_void when it is processed then nothing is placed there" TO TL-CASE
     MOVE 0 TO WS-FLAG
     IF WS-R = 0
         MOVE 1 TO WS-FLAG
     END-IF
     PERFORM CHECK
     MOVE 2 TO WS-X
     PERFORM RECORD-KEY
     MOVE "test struct jigsaw pre given a jigsaw with a state with properties when it is processed then it is that state" TO TL-CASE
     MOVE 0 TO WS-FLAG
     IF WS-NAMES = "oak_stairs"
         MOVE 1 TO WS-FLAG
     END-IF
     PERFORM CHECK
     MOVE 3 TO WS-X
     PERFORM RECORD-KEY
     MOVE "test struct jigsaw pre given a jigsaw without final_state when it is processed then it is air" TO TL-CASE
     MOVE 0 TO WS-FLAG
     IF WS-NAMES = "air"
         MOVE 1 TO WS-FLAG
     END-IF
     PERFORM CHECK
     MOVE 4 TO WS-X
     PERFORM RECORD-KEY
     MOVE "test struct jigsaw pre given a jigsaw without block entity data when it is processed then it is kept" TO TL-CASE
     MOVE 0 TO WS-FLAG
     IF WS-NAMES = "jigsaw"
         MOVE 1 TO WS-FLAG
     END-IF
     PERFORM CHECK
     MOVE 5 TO WS-X
     PERFORM RECORD-KEY
     MOVE "test struct jigsaw pre given another block when it is processed then it is kept" TO TL-CASE
     MOVE 0 TO WS-FLAG
     IF WS-NAMES = "stone"
         MOVE 1 TO WS-FLAG
     END-IF
     PERFORM CHECK
     MOVE 6 TO WS-X
     PERFORM RECORD-KEY
     MOVE "test struct jigsaw pre given a final_state with block entity data when it is processed then the data is dropped" TO TL-CASE
     MOVE 0 TO WS-FLAG
     IF WS-NAMES = "chest" AND PW-NBT(WS-R) = 0
         MOVE 1 TO WS-FLAG
     END-IF
     PERFORM CHECK
     MOVE 7 TO WS-X
     PERFORM RECORD-KEY
     MOVE "test struct jigsaw pre given a final_state that does not parse when it is processed then the block is dropped" TO TL-CASE
     MOVE 0 TO WS-FLAG
     IF WS-R = 0
         MOVE 1 TO WS-FLAG
     END-IF
     PERFORM CHECK.

*> WS-R the record at (WS-X, 70, 0) of the processed list (0 none), WS-NAMES its block key
 RECORD-KEY.
     MOVE 0 TO WS-R
     MOVE SPACES TO WS-NAMES
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > PW-COUNT
         IF PW-X(WS-I) = WS-X
             MOVE WS-I TO WS-R
             MOVE PW-STATE(WS-I) TO WS-ST
             MOVE CB-S-BLOCK(WS-ST + 1) TO WS-BLOCK
             MOVE CB-KEY(WS-BLOCK + 1) TO WS-NAMES
         END-IF
     END-PERFORM.

*> 3.5 getJigsaws(origin, rotation) of test:jigs (origin (10, 20, 30)): the records in block order with the rotated position and orientation, 4.3 the joint (default by the front)
 JIGSAW-CASES.
     MOVE "test:jigs" TO WS-ID
     CALL "STRUCT-TPL-LOAD" USING WS-TPL-DIR WS-ID WS-ROW
     PERFORM VARYING WS-ROT FROM 0 BY 1 UNTIL WS-ROT > 3
         MOVE 10 TO WS-OX
         MOVE 20 TO WS-OY
         MOVE 30 TO WS-OZ
         CALL "STRUCT-GET-JIGSAWS" USING WS-ROW WS-OX WS-OY WS-OZ WS-ROT
         MOVE WS-ROT TO WS-ROT-D
         MOVE SPACES TO TL-CASE
         STRING "test struct jigsaw pre given test:jigs at rotation " WS-ROT-D " when its jigsaws are listed then there are three" DELIMITED BY SIZE INTO TL-CASE
         MOVE 3 TO TL-EXPECTED-N
         MOVE JG-COUNT TO TL-OBSERVED-N
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
         PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > 3
             MOVE WS-J TO WS-J-D
             MOVE SPACES TO TL-CASE
             STRING "test struct jigsaw pre given test:jigs at rotation " WS-ROT-D " when its jigsaws are listed then record " WS-J-D " is at the rotated position with the rotated orientation" DELIMITED BY SIZE INTO TL-CASE
             MOVE 0 TO WS-FLAG
             IF JG-X(WS-J) = 10 + WW-X(WS-ROT + 1, WS-J) AND JG-Y(WS-J) = 20 AND JG-Z(WS-J) = 30 + WW-Z(WS-ROT + 1, WS-J)
                AND JG-FRONT(WS-J) = WW-FRONT(WS-ROT + 1, WS-J) AND JG-TOP(WS-J) = WW-TOP(WS-ROT + 1, WS-J)
                 MOVE 1 TO WS-FLAG
             END-IF
             PERFORM CHECK
         END-PERFORM
         MOVE SPACES TO TL-CASE
         STRING "test struct jigsaw pre given test:jigs at rotation " WS-ROT-D " when its jigsaws are listed then the joints are aligned (default of a horizontal front), rollable (given), rollable (default of a vertical front)" DELIMITED BY SIZE INTO TL-CASE
         MOVE 0 TO WS-FLAG
         IF JG-JOINT(1) = 1 AND JG-JOINT(2) = 2 AND JG-JOINT(3) = 2
             MOVE 1 TO WS-FLAG
         END-IF
         PERFORM CHECK
     END-PERFORM
     MOVE JG-TAG(1) TO WS-TAG
     MOVE "test struct jigsaw pre given the first jigsaw of test:jigs when its record is read then the name, pool, target and priorities are the file's" TO TL-CASE
     MOVE 0 TO WS-FLAG
     IF TN-NAME(WS-TAG) = "minecraft:a" AND TN-POOL(WS-TAG) = "minecraft:p1" AND TN-TARGET(WS-TAG) = "minecraft:b"
        AND TN-PRIO-PLACE(WS-TAG) = 2 AND TN-PRIO-SELECT(WS-TAG) = 5
         MOVE 1 TO WS-FLAG
     END-IF
     PERFORM CHECK
     MOVE "test struct jigsaw pre given a template with no jigsaw when its jigsaws are listed then there are none" TO TL-CASE
     MOVE "test:cube" TO WS-ID
     CALL "STRUCT-TPL-LOAD" USING WS-TPL-DIR WS-ID WS-ROW
     CALL "STRUCT-GET-JIGSAWS" USING WS-ROW WS-OX WS-OY WS-OZ WS-ZERO
     MOVE 0 TO TL-EXPECTED-N
     MOVE JG-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "test struct jigsaw pre given a template that is not loaded when its jigsaws are listed then there are none" TO TL-CASE
     MOVE 0 TO WS-ROW
     CALL "STRUCT-GET-JIGSAWS" USING WS-ROW WS-OX WS-OY WS-OZ WS-ZERO
     MOVE 0 TO TL-EXPECTED-N
     MOVE JG-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "test:no_such_template" TO WS-ID
     CALL "STRUCT-TPL-LOAD" USING WS-TPL-DIR WS-ID WS-ROW
     CALL "STRUCT-GET-JIGSAWS" USING WS-ROW WS-OX WS-OY WS-OZ WS-ZERO
     MOVE "test struct jigsaw pre given an absent template file when its jigsaws are listed then there are none" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE JG-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "minecraft:empty" TO WS-ID
     CALL "STRUCT-TPL-LOAD" USING WS-TPL-DIR WS-ID WS-ROW
     CALL "STRUCT-GET-JIGSAWS" USING WS-ROW WS-OX WS-OY WS-OZ WS-ZERO
     MOVE "test struct jigsaw pre given a template with no palette when its jigsaws are listed then there are none" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE JG-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   the orientation of a state: all six directions of a front and a top, and no orientation for a block that has none
     MOVE "minecraft:jigsaw[orientation=down_south]" TO WS-TEXT
     CALL "STRUCT-BLOCK-TEXT" USING WS-TEXT WS-STATE WS-STATUS
     CALL "STRUCT-JIG-DIRS" USING WS-STATE WS-FRONT WS-TOP
     MOVE "test struct jigsaw pre given down_south when its directions are read then the front is down (0) and the top south (3)" TO TL-CASE
     MOVE 0 TO WS-FLAG
     IF WS-FRONT = 0 AND WS-TOP = 3
         MOVE 1 TO WS-FLAG
     END-IF
     PERFORM CHECK
     MOVE "minecraft:stone" TO WS-TEXT
     CALL "STRUCT-BLOCK-TEXT" USING WS-TEXT WS-STATE WS-STATUS
     CALL "STRUCT-JIG-DIRS" USING WS-STATE WS-FRONT WS-TOP
     MOVE "test struct jigsaw pre given a block without orientation when its directions are read then they are -1" TO TL-CASE
     MOVE 0 TO WS-FLAG
     IF WS-FRONT = -1 AND WS-TOP = -1
         MOVE 1 TO WS-FLAG
     END-IF
     PERFORM CHECK
     MOVE "bogus" TO WS-DIRNAME
     CALL "STRUCT-JIG-DIR" USING WS-DIRNAME WS-FRONT
     MOVE "test struct jigsaw pre given a name that is no direction when it is read then it is -1" TO TL-CASE
     MOVE 0 TO WS-FLAG
     IF WS-FRONT = -1
         MOVE 1 TO WS-FLAG
     END-IF
     PERFORM CHECK.

*> 3.4 calculateConnectedPosition = relative(A, posA) - relative(B, posB), relative = the transform of 3.1 (mirror, then rotation about the pivot)
 CONNECTED-CASES.
*>   the doc's base plate and tower (36-3 18.3): rotation 1 and pivot 0 at (7, 1, 14) against rotation 0 at (7, 1, 13): (-14, 1, 7) - (7, 1, 13) = (-21, 0, -6)
     MOVE 0 TO WS-A-MIR
     MOVE 1 TO WS-A-ROT
     MOVE 0 TO WS-A-PX
     MOVE 0 TO WS-A-PZ
     MOVE 7 TO WS-A-X
     MOVE 1 TO WS-A-Y
     MOVE 14 TO WS-A-Z
     MOVE 0 TO WS-B-MIR
     MOVE 0 TO WS-B-ROT
     MOVE 0 TO WS-B-PX
     MOVE 0 TO WS-B-PZ
     MOVE 7 TO WS-B-X
     MOVE 1 TO WS-B-Y
     MOVE 13 TO WS-B-Z
     PERFORM ONE-CONNECTED
     MOVE "test struct jigsaw pre given rotation 1 and rotation 0 when the connected position is taken then it is the difference of the relative positions" TO TL-CASE
     MOVE 0 TO WS-FLAG
     IF WS-C-X = -21 AND WS-C-Y = 0 AND WS-C-Z = -6
         MOVE 1 TO WS-FLAG
     END-IF
     PERFORM CHECK
*>   mirror left-right (z -> -z) with rotation 2 about the pivot (4, 15) against a mirrored rotation 3: relative A = rot180 about (4, 15) of (2, 5, -3) = (6, 5, 33); relative B = rot270 of (1, 0, 2) about 0 = (2, 0, -1)
     MOVE 1 TO WS-A-MIR
     MOVE 2 TO WS-A-ROT
     MOVE 4 TO WS-A-PX
     MOVE 15 TO WS-A-PZ
     MOVE 2 TO WS-A-X
     MOVE 5 TO WS-A-Y
     MOVE 3 TO WS-A-Z
     MOVE 0 TO WS-B-MIR
     MOVE 3 TO WS-B-ROT
     MOVE 0 TO WS-B-PX
     MOVE 0 TO WS-B-PZ
     MOVE 1 TO WS-B-X
     MOVE 0 TO WS-B-Y
     MOVE 2 TO WS-B-Z
     PERFORM ONE-CONNECTED
     MOVE "test struct jigsaw pre given a mirrored rotation 2 about a pivot and rotation 3 when the connected position is taken then it is the difference of the relative positions" TO TL-CASE
     MOVE 0 TO WS-FLAG
     IF WS-C-X = 4 AND WS-C-Y = 5 AND WS-C-Z = 34
         MOVE 1 TO WS-FLAG
     END-IF
     PERFORM CHECK.

 ONE-CONNECTED.
     CALL "STRUCT-CONNECTED-POS" USING WS-A-MIR WS-A-ROT WS-A-PX WS-A-PZ WS-A-X WS-A-Y WS-A-Z WS-B-MIR WS-B-ROT WS-B-PX WS-B-PZ WS-B-X WS-B-Y WS-B-Z
         WS-C-X WS-C-Y WS-C-Z.
 END PROGRAM TEST-STRUCT-JIGSAW-PRE.

 COPY CORETEST.
