*> Acceptance test of the lava_submerged_block processor (docs/protocol/36-structures-2 section 9.7; core/src/struct-portal.cob STRUCT-PROC-LAVA): over lava in the world a template block that
*> is not a full block becomes lava (the template's tag is kept), a full block and any block over something else stay. "Full block" is the content set's solid and opaque flags
*> (CB-SOLID and CB-OPAQUE: the block tables carry no collision shapes, so a full cube is a solid opaque block; a stair, a slab, a fence, glass and a chest are not).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-STRUCT-PORTAL-LAVA.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CONTENT.
 COPY CBLOCKS.
 COPY CELLS.
 COPY STRUCTPROC.
 COPY STRUCTCUR.
 COPY STRUCTPPOS.
 COPY STRUCTSET.
 COPY FEATDATA.
 COPY FEATLEVEL.
 01 WS-GEN-DIR             PIC X(1100).
 01 WS-ENV                 PIC X(1100).
 01 WS-FILE                PIC X(1200).
 01 WS-FILE-INFO           PIC X(16).
 01 WS-TYPE                BINARY-LONG.
 01 WS-STATUS              BINARY-LONG.
 01 WS-FLAG                BINARY-LONG.
 01 WS-KEY                 PIC X(80) VALUE "test:lava".
 01 WS-LIST                BINARY-LONG.
 01 WS-KEEP                BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-PTR                 USAGE POINTER.
 01 WS-MIN-Y               BINARY-LONG VALUE -64.
 01 WS-HEIGHT              BINARY-LONG VALUE 384.
 01 WS-SEA                 BINARY-LONG VALUE 63.
 01 WS-WCX                 BINARY-LONG VALUE 0.
 01 WS-WCZ                 BINARY-LONG VALUE 0.
 01 WS-LAVA                BINARY-LONG.
 01 WS-STONE               BINARY-LONG.
 01 WS-STAIRS              BINARY-LONG.
 01 WS-GLASS               BINARY-LONG.
 01 WS-CHEST               BINARY-LONG.
 01 WS-GRASS               BINARY-LONG.
 01 WS-TORCH               BINARY-LONG.
 01 WS-NAME                PIC X(48).
 01 WS-POOL-DIR            PIC X(1100) VALUE "core/tests/fixtures/jigpool".
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-OK                  BINARY-LONG.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-BLOCK               BINARY-LONG.
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
         MOVE "test struct portal lava no generated packs here, skipped" TO TL-CASE
         MOVE 1 TO TL-EXPECTED-N
         MOVE 1 TO TL-OBSERVED-N
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
         STOP RUN
     END-IF
     MOVE CT-TYPE-STANDARD TO WS-TYPE
     CALL "CONTENT-OPEN" USING WS-TYPE WS-GEN-DIR WS-STATUS
     CALL "BLOCKS-OPEN"
     CALL "STRUCT-PROC-RESET"
     MOVE WS-POOL-DIR TO FD-DIR
     ALLOCATE CE-CHUNK-BYTES CHARACTERS INITIALIZED RETURNING WS-PTR
     CALL "FL-OPEN" USING WS-PTR WS-WCX WS-WCZ WS-MIN-Y WS-HEIGHT WS-SEA
     SET ADDRESS OF CE-CHUNK TO WS-PTR
     MOVE "minecraft:lava" TO WS-NAME
     CALL "GEN-BLOCK-STATE" USING WS-NAME WS-LAVA
     MOVE "minecraft:stone" TO WS-NAME
     CALL "GEN-BLOCK-STATE" USING WS-NAME WS-STONE
     MOVE "minecraft:oak_stairs" TO WS-NAME
     CALL "GEN-BLOCK-STATE" USING WS-NAME WS-STAIRS
     MOVE "minecraft:glass" TO WS-NAME
     CALL "GEN-BLOCK-STATE" USING WS-NAME WS-GLASS
     MOVE "minecraft:chest" TO WS-NAME
     CALL "GEN-BLOCK-STATE" USING WS-NAME WS-CHEST
     MOVE "minecraft:short_grass" TO WS-NAME
     CALL "GEN-BLOCK-STATE" USING WS-NAME WS-GRASS
     MOVE "minecraft:torch" TO WS-NAME
     CALL "GEN-BLOCK-STATE" USING WS-NAME WS-TORCH
     MOVE 5 TO WS-X
     MOVE 40 TO WS-Y
     MOVE 5 TO WS-Z
     CALL "FL-SET-STATE" USING WS-X WS-Y WS-Z WS-LAVA WS-ONE WS-OK
     CALL "STRUCT-PROC-LOAD" USING WS-KEY WS-LIST
     MOVE "test struct portal lava given the list lava_submerged_block when it is loaded then it is one processor of type 7" TO TL-CASE
     MOVE 0 TO WS-FLAG
     IF WS-LIST > 0
         IF SPL-N(WS-LIST) = 1 AND SPP-TYPE(SPL-FIRST(WS-LIST)) = 7
             MOVE 1 TO WS-FLAG
         END-IF
     END-IF
     PERFORM CHECK
     INITIALIZE STRUCT-SETTINGS
     MOVE 0 TO CU-STATE
     MOVE 3 TO CU-NBT
     PERFORM RUN-ONE
     MOVE "test struct portal lava given air over lava when it is processed then it is lava and keeps its tag" TO TL-CASE
     MOVE 0 TO WS-FLAG
     IF CU-STATE = WS-LAVA AND CU-NBT = 3 AND WS-KEEP = 1
         MOVE 1 TO WS-FLAG
     END-IF
     PERFORM CHECK
     MOVE WS-STONE TO CU-STATE
     PERFORM RUN-ONE
     MOVE "test struct portal lava given a full block over lava when it is processed then it stays" TO TL-CASE
     MOVE 0 TO WS-FLAG
     IF CU-STATE = WS-STONE
         MOVE 1 TO WS-FLAG
     END-IF
     PERFORM CHECK
     MOVE WS-STAIRS TO CU-STATE
     PERFORM RUN-ONE
     MOVE "test struct portal lava given a stair or a chest over lava they stay, and glass (not opaque), a plant and a torch (not solid) become lava (solid and opaque flags: the documented approximation)" TO TL-CASE
     MOVE 0 TO WS-FLAG
     MOVE 0 TO WS-I
     IF CU-STATE = WS-STAIRS
         ADD 1 TO WS-I
     END-IF
*>   Glass does not occlude (T5501: its flags hold noOcclusion), so it is not opaque and the approximation turns it into lava.
     MOVE WS-GLASS TO CU-STATE
     PERFORM RUN-ONE
     IF CU-STATE = WS-LAVA
         ADD 1 TO WS-I
     END-IF
     MOVE WS-CHEST TO CU-STATE
     PERFORM RUN-ONE
     IF CU-STATE = WS-CHEST
         ADD 1 TO WS-I
     END-IF
*>   A plant and a torch have no collision (noCollision, now read from the registry's other-settings columns: T5501), so they are not solid and become lava too.
     MOVE WS-GRASS TO CU-STATE
     PERFORM RUN-ONE
     IF CU-STATE = WS-LAVA
         ADD 1 TO WS-I
     END-IF
     MOVE WS-TORCH TO CU-STATE
     PERFORM RUN-ONE
     IF CU-STATE = WS-LAVA
         ADD 1 TO WS-I
     END-IF
     IF WS-I = 5
         MOVE 1 TO WS-FLAG
     END-IF
     PERFORM CHECK
     MOVE WS-STAIRS TO CU-STATE
     MOVE 6 TO CU-X
     PERFORM RUN-ONE
     MOVE "test struct portal lava given a stair over air when it is processed then it stays" TO TL-CASE
     MOVE 0 TO WS-FLAG
     IF CU-STATE = WS-STAIRS
         MOVE 1 TO WS-FLAG
     END-IF
     PERFORM CHECK
     STOP RUN.

 CHECK.
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-FLAG TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

*> the processor over the record at (CU-X, CU-Y, CU-Z) (default (5, 40, 5), the lava)
 RUN-ONE.
     IF CU-X NOT = 6
         MOVE 5 TO CU-X
     END-IF
     MOVE 40 TO CU-Y
     MOVE 5 TO CU-Z
     CALL "STRUCT-PROC-BLOCK" USING SPL-FIRST(WS-LIST) STRUCT-PPOS STRUCT-CUR WS-KEEP STRUCT-SETTINGS.
 END PROGRAM TEST-STRUCT-PORTAL-LAVA.

 COPY CORETEST.
