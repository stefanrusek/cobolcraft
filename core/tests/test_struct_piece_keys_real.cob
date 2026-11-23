*> Real-data test of the saved piece keys of the families beyond 36-4 section 10 and 36-5 section 3.9 (skipped as a pass without the generated packs): on the generated vanilla-data (CC_GENERATED_DIR, read
*> only) of a fixed seed the first real start of the mineshaft, the shipwreck and the beached shipwreck, the cold and the warm ocean ruin and the woodland mansion (a scan of the overworld by
*> STRUCT-CHUNK-STARTS with that structure alone on), the end city (a scan of the outer End by STRUCT-IS-CHUNK) and the nether fortress (a scan of the nether set) is built by STRUCT-FIND-POINT and captured by
*> STRUCT-START-CAPTURE. Each start is written (STRUCT-STARTS-WRITE): every piece is there with the keys its family has (the key lists of 36-5 sections 2.5, 2.6, 2.11 and 2.12, 36-6 sections 2.4 and 4.3,
*> 36-7 section 3, 36-8 sections 3.5 and 9.1), the values agree with the builder's fields and with the documents (the ocean ruin's Integrity 0.8 or 0.9, 0.7 and 0.5 by its order, BiomeType and IsLarge by
*> the template; the end city's OW 0 for the floors and the second roof of the house tower, 1 for the rest; isBeached by the structure), a piece without a required key (Rot, BiomeType) does not load, and the
*> start read back into an empty store equals the captured one piece by piece (type, orientation, depth, box, key slots, template, entrance boxes). The PROBE lines show what the real starts hit.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-STRUCT-PIECE-KEYS-REAL.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY STRUCTDATA.
 COPY STRUCTSTART.
 COPY STRUCTPIECE.
 COPY STRUCTTPL.
 COPY STRUCTPROC.
 COPY PROTO.
 01 WS-SEEDENV             PIC X(20) VALUE SPACES.
 01 WS-DIR                 PIC X(1024).
 01 WS-ENV                 PIC X(1024).
 01 WS-FILE                PIC X(1100).
 01 WS-FILE-INFO           PIC X(16).
*> the structures, with the way their real start is looked for: O scans the overworld by STRUCT-CHUNK-STARTS with the structure alone on, S asks STRUCT-IS-CHUNK of the structure's set
 01 WS-TARGETS.
    05 FILLER              PIC X(81) VALUE "Ominecraft:mineshaft".
    05 FILLER              PIC X(81) VALUE "Ominecraft:shipwreck".
    05 FILLER              PIC X(81) VALUE "Ominecraft:shipwreck_beached".
    05 FILLER              PIC X(81) VALUE "Ominecraft:ocean_ruin_cold".
    05 FILLER              PIC X(81) VALUE "Ominecraft:ocean_ruin_warm".
    05 FILLER              PIC X(81) VALUE "Ominecraft:mansion".
    05 FILLER              PIC X(81) VALUE "Sminecraft:end_city".
    05 FILLER              PIC X(81) VALUE "Sminecraft:fortress".
 01 WS-TARGET-TABLE REDEFINES WS-TARGETS.
    05 WS-TG               OCCURS 8 TIMES.
       10 TG-MODE          PIC X.
       10 TG-KEY           PIC X(80).
*> the keys of a piece id (the lists of the documents named above); a piece id not listed has none beyond id, BB, O and GD
 01 WS-EXPECTS.
    05 FILLER              PIC X(80) VALUE "mscorridor  hr,sc,hps,Num,MST".
    05 FILLER              PIC X(80) VALUE "mscrossing  tf,D,MST".
    05 FILLER              PIC X(80) VALUE "msroom      Entrances,MST".
    05 FILLER              PIC X(80) VALUE "msstairs    MST".
    05 FILLER              PIC X(80) VALUE "shipwreck   Template,TPX,TPY,TPZ,isBeached,Rot,height_adjusted".
    05 FILLER              PIC X(80) VALUE "orp         Template,TPX,TPY,TPZ,Rot,Integrity,BiomeType,IsLarge".
    05 FILLER              PIC X(80) VALUE "wmp         Template,TPX,TPY,TPZ,Rot,Mi".
    05 FILLER              PIC X(80) VALUE "ecp         Template,TPX,TPY,TPZ,Rot,OW".
    05 FILLER              PIC X(80) VALUE "nebef       Seed".
    05 FILLER              PIC X(80) VALUE "nesclt      Chest".
    05 FILLER              PIC X(80) VALUE "nescrt      Chest".
    05 FILLER              PIC X(80) VALUE "nemt        Mob".
 01 WS-EXPECT-TABLE REDEFINES WS-EXPECTS.
    05 WS-EX               OCCURS 12 TIMES.
       10 EX-NAME          PIC X(12).
       10 EX-LIST          PIC X(68).
*> what the captured start held, piece by piece
 01 WS-SNAPS.
    05 WS-SN               OCCURS 1024 TIMES.
       10 SN-TYPE          BINARY-LONG.
       10 SN-ORIENT        BINARY-LONG.
       10 SN-DEPTH         BINARY-LONG.
       10 SN-BOX           BINARY-LONG OCCURS 6 TIMES.
       10 SN-K             BINARY-LONG OCCURS 8 TIMES.
       10 SN-TPL           PIC X(64).
       10 SN-ENT-FIRST     BINARY-LONG.
       10 SN-ENT-N         BINARY-LONG.
 01 WS-SNAP-ENTS.
    05 WS-SE               OCCURS 1024 TIMES.
       10 SNE-B            BINARY-LONG OCCURS 6 TIMES.
 01 WS-SNAP-N              BINARY-LONG.
 01 WS-SNAP-ENT-N          BINARY-LONG.
 01 WS-CAPACITY            BINARY-LONG VALUE 262144.
 01 WS-FRAMING             BINARY-LONG VALUE 1.
 01 WS-ROOT                BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-OUTCOME             BINARY-LONG.
 01 WS-STRLEN              BINARY-LONG.
 01 WN                     PIC X(32).
 01 WL                     BINARY-LONG.
 01 WS-PATH                PIC X(128).
 01 WS-TEXT                PIC X(8192).
 01 WS-LIST                PIC X(68).
 01 WS-ONE                 PIC X(24).
 01 WS-PAT                 PIC X(30).
 01 WS-PNAME               PIC X(40).
 01 WS-SHORT               PIC X(64).
 01 WS-TKEY                PIC X(96).
 01 WS-LABEL               PIC X(120).
 01 WS-IDX                 PIC Z(3)9.
 01 WS-T                   BINARY-LONG.
 01 WS-KEY                 PIC X(80).
 01 WS-ROW-S               BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-ROW2                BINARY-LONG.
 01 WS-SET                 BINARY-LONG.
 01 WS-S                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-E                   BINARY-LONG.
 01 WS-P                   BINARY-LONG.
 01 WS-Q                   BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-EN                  BINARY-LONG.
 01 WS-PTR                 BINARY-LONG.
 01 WS-KL                  BINARY-LONG.
 01 WS-PL                  BINARY-LONG.
 01 WS-OFF                 BINARY-LONG.
 01 WS-LO-X                BINARY-LONG.
 01 WS-HI-X                BINARY-LONG.
 01 WS-LO-Z                BINARY-LONG.
 01 WS-HI-Z                BINARY-LONG.
 01 WS-SX                  BINARY-LONG.
 01 WS-SZ                  BINARY-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-FOUND               BINARY-LONG.
 01 WS-FLAG                BINARY-LONG.
 01 WS-VALID               BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-MISSING             BINARY-LONG.
 01 WS-BAD                 BINARY-LONG.
 01 WS-DIFF                BINARY-LONG.
 01 WS-LOADED              BINARY-LONG.
 01 WS-SLASH               BINARY-LONG.
 01 WS-START               BINARY-LONG.
 01 WS-WANT                BINARY-LONG.
 01 WS-NOPROC              BINARY-LONG.
 01 WS-ENTS                BINARY-LONG.
 01 WS-LAST                BINARY-LONG.
 01 WS-ED-N                PIC -(7)9.
 01 WS-ED-CX               PIC -(7)9.
 01 WS-ED-CZ               PIC -(7)9.
 01 WS-VIEW                PIC X(16777216) BASED.
 01 WS-PAT-ROT.
    05 FILLER              PIC X VALUE X"08".
    05 FILLER              PIC X(2) VALUE X"0003".
    05 FILLER              PIC X(3) VALUE "Rot".
 01 WS-PAT-BIOME.
    05 FILLER              PIC X VALUE X"08".
    05 FILLER              PIC X(2) VALUE X"0009".
    05 FILLER              PIC X(9) VALUE "BiomeType".
 PROCEDURE DIVISION.
     MOVE "N" TO TL-MODE
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
         MOVE "test struct piece keys real no generated packs here, skipped" TO TL-CASE
         MOVE 1 TO TL-EXPECTED-N
         MOVE 1 TO TL-OBSERVED-N
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
         STOP RUN
     END-IF
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE "standard" TO CS-WORLD-TYPE
     MOVE WS-DIR TO CS-GENERATED-DIR
     MOVE 2 TO CS-VIEW-DISTANCE
     MOVE "12345" TO CS-SEED-TEXT
     ACCEPT WS-SEEDENV FROM ENVIRONMENT "CC_TEST_SEED"
     IF WS-SEEDENV NOT = SPACES
         MOVE WS-SEEDENV TO CS-SEED-TEXT
     END-IF
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     SET ADDRESS OF WS-VIEW TO PB-ADDR
     PERFORM VARYING WS-T FROM 1 BY 1 UNTIL WS-T > 8
         PERFORM RUN-TARGET
     END-PERFORM
     STOP RUN.

*> one structure: find its start, capture it, write it, check the keys, read it back
 RUN-TARGET.
     MOVE TG-KEY(WS-T) TO WS-KEY
     MOVE SPACES TO WS-LABEL
     STRING "real piece keys " FUNCTION TRIM(WS-KEY) ": " DELIMITED BY SIZE INTO WS-LABEL
     MOVE 0 TO WS-ROW-S
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > SD-ST-COUNT
         IF SDT-KEY(WS-I) = WS-KEY
             MOVE WS-I TO WS-ROW-S
         END-IF
     END-PERFORM
     PERFORM SET-WINDOW
     MOVE 0 TO WS-FOUND
     IF WS-ROW-S > 0
         IF TG-MODE(WS-T) = "O"
             PERFORM FIND-CHUNK-O
         ELSE
             PERFORM FIND-CHUNK-S
         END-IF
     END-IF
     MOVE WS-CX TO WS-ED-CX
     MOVE WS-CZ TO WS-ED-CZ
     DISPLAY "PROBE " FUNCTION TRIM(WS-KEY) ": first real start at chunk (" FUNCTION TRIM(WS-ED-CX) "," FUNCTION TRIM(WS-ED-CZ) ") found = " WS-FOUND
     MOVE SPACES TO TL-CASE
     STRING FUNCTION TRIM(WS-LABEL) "a real start is found" DELIMITED BY SIZE INTO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-FOUND TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     IF WS-FOUND = 1
         PERFORM CAPTURE-START
     END-IF.

 SET-WINDOW.
     EVALUATE WS-T
         WHEN 1
             MOVE -60 TO WS-LO-X WS-LO-Z
             MOVE 59 TO WS-HI-X WS-HI-Z
         WHEN 2 THRU 5
             MOVE -150 TO WS-LO-X WS-LO-Z
             MOVE 149 TO WS-HI-X WS-HI-Z
         WHEN 6
             MOVE -600 TO WS-LO-X WS-LO-Z
             MOVE 599 TO WS-HI-X WS-HI-Z
         WHEN 7
             MOVE 60 TO WS-LO-X
             MOVE 240 TO WS-HI-X
             MOVE -60 TO WS-LO-Z
             MOVE 60 TO WS-HI-Z
         WHEN OTHER
             MOVE -40 TO WS-LO-X WS-LO-Z
             MOVE 40 TO WS-HI-X WS-HI-Z
     END-EVALUATE.

*> the structure's set: the set that has the structure among its entries (0 when none)
 FIND-SET.
     MOVE 0 TO WS-SET
     PERFORM VARYING WS-S FROM 1 BY 1 UNTIL WS-S > SD-SET-COUNT
         PERFORM VARYING WS-K FROM 0 BY 1 UNTIL WS-K >= SS-EN-COUNT(WS-S)
             COMPUTE WS-Q = SS-EN-FIRST(WS-S) + WS-K
             IF SE-STRUCT(WS-Q) = WS-ROW-S
                 MOVE WS-S TO WS-SET
             END-IF
         END-PERFORM
     END-PERFORM.

*> the first chunk of the window in scan order that the structure's set holds and where STRUCT-CHUNK-STARTS makes a start of the structure (the structure alone on, the biome rules of the data apply)
 FIND-CHUNK-O.
     PERFORM FIND-SET
     CALL "STRUCT-GATE-RESET"
     CALL "STRUCT-GATE-ON" USING WS-KEY
     IF WS-SET > 0
         PERFORM VARYING WS-SX FROM WS-LO-X BY 1 UNTIL WS-SX > WS-HI-X OR WS-FOUND = 1
             PERFORM VARYING WS-SZ FROM WS-LO-Z BY 1 UNTIL WS-SZ > WS-HI-Z OR WS-FOUND = 1
                 CALL "STRUCT-IS-CHUNK" USING WS-SET CW-SEED WS-SX WS-SZ WS-FLAG
                 IF WS-FLAG = 1
                     CALL "STRUCT-CHUNK-STARTS" USING CW-SEED WS-SX WS-SZ WS-COUNT
                     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-COUNT
                         IF SC-STRUCT(WS-I) = WS-ROW-S AND WS-FOUND = 0
                             MOVE 1 TO WS-FOUND
                             MOVE WS-SX TO WS-CX
                             MOVE WS-SZ TO WS-CZ
                         END-IF
                     END-PERFORM
                 END-IF
             END-PERFORM
         END-PERFORM
     END-IF.

*> the first chunk of the window that the structure's set holds and whose start is valid (the structure's own generator decides: the End and the nether have no biome check here)
 FIND-CHUNK-S.
     PERFORM FIND-SET
     IF WS-SET > 0
         PERFORM VARYING WS-SX FROM WS-LO-X BY 1 UNTIL WS-SX > WS-HI-X OR WS-FOUND = 1
             PERFORM VARYING WS-SZ FROM WS-LO-Z BY 1 UNTIL WS-SZ > WS-HI-Z OR WS-FOUND = 1
                 CALL "STRUCT-IS-CHUNK" USING WS-SET CW-SEED WS-SX WS-SZ WS-FLAG
                 IF WS-FLAG = 1
                     CALL "STRUCT-FIND-POINT" USING WS-ROW-S CW-SEED WS-SX WS-SZ WS-X WS-Y WS-Z WS-VALID
                     IF WS-VALID = 1
                         MOVE 1 TO WS-FOUND
                         MOVE WS-SX TO WS-CX
                         MOVE WS-SZ TO WS-CZ
                     END-IF
                 END-IF
             END-PERFORM
         END-PERFORM
     END-IF.

 CAPTURE-START.
     CALL "STRUCT-STORE-RESET"
     CALL "STRUCT-FIND-POINT" USING WS-ROW-S CW-SEED WS-CX WS-CZ WS-X WS-Y WS-Z WS-VALID
     MOVE SP-COUNT TO WS-ED-N
     DISPLAY "PROBE " FUNCTION TRIM(WS-KEY) ": " FUNCTION TRIM(WS-ED-N) " pieces, valid " WS-VALID
     MOVE SPACES TO TL-CASE
     STRING FUNCTION TRIM(WS-LABEL) "the start builds between 1 and 1024 pieces" DELIMITED BY SIZE INTO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-VALID = 1 AND SP-COUNT >= 1 AND SP-COUNT <= 1024
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     IF TL-OBSERVED-N = 1
         CALL "STRUCT-START-CAPTURE" USING WS-ROW-S WS-CX WS-CZ WS-ROW
         MOVE SPACES TO TL-CASE
         STRING FUNCTION TRIM(WS-LABEL) "the capture holds every piece of the builder" DELIMITED BY SIZE INTO TL-CASE
         MOVE SP-COUNT TO TL-EXPECTED-N
         MOVE 0 TO TL-OBSERVED-N
         IF WS-ROW > 0
             MOVE SST-N(WS-ROW) TO TL-OBSERVED-N
         END-IF
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
         IF WS-ROW > 0 AND SST-N(WS-ROW) = SP-COUNT
             PERFORM SNAPSHOT
             PERFORM WRITE-START
             PERFORM CHECK-KEYS-WRITTEN
             PERFORM FAMILY-CHECKS
             PERFORM REQUIRED-KEY-CHECKS
             PERFORM RELOAD-CHECKS
         END-IF
     END-IF.

 SNAPSHOT.
     MOVE SST-N(WS-ROW) TO WS-SNAP-N
     MOVE 0 TO WS-SNAP-ENT-N
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-SNAP-N
         COMPUTE WS-P = SST-FIRST(WS-ROW) + WS-I - 1
         MOVE SPC-TYPE(WS-P) TO SN-TYPE(WS-I)
         MOVE SPC-ORIENT(WS-P) TO SN-ORIENT(WS-I)
         MOVE SPC-DEPTH(WS-P) TO SN-DEPTH(WS-I)
         MOVE SPC-X0(WS-P) TO SN-BOX(WS-I, 1)
         MOVE SPC-Y0(WS-P) TO SN-BOX(WS-I, 2)
         MOVE SPC-Z0(WS-P) TO SN-BOX(WS-I, 3)
         MOVE SPC-X1(WS-P) TO SN-BOX(WS-I, 4)
         MOVE SPC-Y1(WS-P) TO SN-BOX(WS-I, 5)
         MOVE SPC-Z1(WS-P) TO SN-BOX(WS-I, 6)
         PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 8
             MOVE SPC-K(WS-P, WS-K) TO SN-K(WS-I, WS-K)
         END-PERFORM
         MOVE SPC-TPL(WS-P) TO SN-TPL(WS-I)
         MOVE SPC-ENT-N(WS-P) TO SN-ENT-N(WS-I)
         COMPUTE SN-ENT-FIRST(WS-I) = WS-SNAP-ENT-N + 1
         PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > SPC-ENT-N(WS-P)
             COMPUTE WS-Q = SPC-ENT-FIRST(WS-P) + WS-K - 1
             ADD 1 TO WS-SNAP-ENT-N
             MOVE SSE-X0(WS-Q) TO SNE-B(WS-SNAP-ENT-N, 1)
             MOVE SSE-Y0(WS-Q) TO SNE-B(WS-SNAP-ENT-N, 2)
             MOVE SSE-Z0(WS-Q) TO SNE-B(WS-SNAP-ENT-N, 3)
             MOVE SSE-X1(WS-Q) TO SNE-B(WS-SNAP-ENT-N, 4)
             MOVE SSE-Y1(WS-Q) TO SNE-B(WS-SNAP-ENT-N, 5)
             MOVE SSE-Z1(WS-Q) TO SNE-B(WS-SNAP-ENT-N, 6)
         END-PERFORM
     END-PERFORM.

*> the chunk compound of the captured start, as the region file holds it
 WRITE-START.
     CALL "PB-RESET" USING PB-BUFFER
     MOVE 0 TO WL
     CALL "NBT-WRITE-COMPOUND-BEGIN" USING PB-BUFFER WN WL
     CALL "STRUCT-STARTS-WRITE" USING PB-BUFFER WS-CX WS-CZ
     CALL "NBT-WRITE-COMPOUND-END" USING PB-BUFFER
     MOVE 0 TO PB-POS
     CALL "NBT-READ-ROOT" USING PB-BUFFER WS-FRAMING WS-TYPE
     MOVE PB-POS TO WS-ROOT
     SET ADDRESS OF WS-VIEW TO PB-ADDR.

*> the tag at WS-PATH of the written chunk, rendered into WS-TEXT
 GET-PATH.
     CALL "TEST-NBT-GET" USING PB-BUFFER WS-ROOT WS-PATH WS-TEXT.

*> Children[WS-I - 1] of the start, rendered into WS-TEXT
 GET-PIECE.
     COMPUTE WS-N = WS-I - 1
     MOVE WS-N TO WS-IDX
     MOVE SPACES TO WS-PATH
     STRING "structures.starts." FUNCTION TRIM(WS-KEY) ".Children[" FUNCTION TRIM(WS-IDX) "]" DELIMITED BY SIZE INTO WS-PATH
     PERFORM GET-PATH.

*> every piece of the start was written (the list has as many compounds as the store held), with the keys that the family has
 CHECK-KEYS-WRITTEN.
     MOVE 0 TO WS-MISSING
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-SNAP-N
         PERFORM GET-PIECE
         IF WS-TEXT(1:6) = "absent"
             ADD 1 TO WS-MISSING
         ELSE
             COMPUTE WS-P = SST-FIRST(WS-ROW) + WS-I - 1
             CALL "STRUCT-PIECE-NAME" USING SPC-TYPE(WS-P) WS-PNAME
             PERFORM CHECK-NAME-KEYS
         END-IF
     END-PERFORM
     COMPUTE WS-I = WS-SNAP-N + 1
     PERFORM GET-PIECE
     IF WS-TEXT(1:6) NOT = "absent"
         ADD 1 TO WS-MISSING
     END-IF
     MOVE SPACES TO TL-CASE
     STRING FUNCTION TRIM(WS-LABEL) "every written piece holds the keys of its family and the list has no other piece" DELIMITED BY SIZE INTO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-MISSING TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

*> the keys that the table lists for the piece id WS-PNAME must be in the rendered piece WS-TEXT
 CHECK-NAME-KEYS.
     MOVE SPACES TO WS-LIST
     PERFORM VARYING WS-E FROM 1 BY 1 UNTIL WS-E > 12
         IF EX-NAME(WS-E) = WS-PNAME
             MOVE EX-LIST(WS-E) TO WS-LIST
         END-IF
     END-PERFORM
     MOVE 1 TO WS-PTR
     PERFORM UNTIL WS-PTR > 68
         IF WS-LIST(WS-PTR:1) = SPACE
             EXIT PERFORM
         END-IF
         MOVE SPACES TO WS-ONE
         UNSTRING WS-LIST DELIMITED BY "," OR SPACE INTO WS-ONE WITH POINTER WS-PTR
         MOVE FUNCTION LENGTH(FUNCTION TRIM(WS-ONE)) TO WS-KL
         MOVE SPACES TO WS-PAT
         STRING "," FUNCTION TRIM(WS-ONE) ":" DELIMITED BY SIZE INTO WS-PAT
         COMPUTE WS-PL = WS-KL + 2
         MOVE 0 TO WS-N
         INSPECT WS-TEXT TALLYING WS-N FOR ALL WS-PAT(1:WS-PL)
         IF WS-N = 0
             ADD 1 TO WS-MISSING
         END-IF
     END-PERFORM.

*> the values of the keys against the builder and the documents, piece by piece (the builder's piece i is the store's piece i)
 FAMILY-CHECKS.
     MOVE 0 TO WS-BAD WS-NOPROC WS-ENTS
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-SNAP-N
         COMPUTE WS-P = SST-FIRST(WS-ROW) + WS-I - 1
         CALL "STRUCT-PIECE-NAME" USING SPC-TYPE(WS-P) WS-PNAME
         EVALUATE WS-PNAME
             WHEN "mscorridor"
                 PERFORM CHECK-CORRIDOR
             WHEN "mscrossing"
                 PERFORM CHECK-CROSSING
             WHEN "msroom"
                 PERFORM CHECK-ROOM
             WHEN "msstairs"
                 PERFORM CHECK-STAIRS
             WHEN "shipwreck"
                 PERFORM CHECK-SHIPWRECK
             WHEN "orp"
                 PERFORM CHECK-RUIN
             WHEN "wmp"
                 PERFORM CHECK-MANSION
             WHEN "ecp"
                 PERFORM CHECK-CITY
             WHEN "nebef"
                 IF SPC-K(WS-P, 1) NOT = SP-F1(WS-I)
                     ADD 1 TO WS-BAD
                 END-IF
             WHEN "nesclt"
                 IF SPC-K(WS-P, 1) NOT = SP-F2(WS-I)
                     ADD 1 TO WS-BAD
                 END-IF
             WHEN "nescrt"
                 IF SPC-K(WS-P, 1) NOT = SP-F2(WS-I)
                     ADD 1 TO WS-BAD
                 END-IF
             WHEN "nemt"
                 IF SPC-K(WS-P, 1) NOT = SP-F1(WS-I)
                     ADD 1 TO WS-BAD
                 END-IF
         END-EVALUATE
     END-PERFORM
     DISPLAY "PROBE " FUNCTION TRIM(WS-KEY) ": pieces without a compiled processor list " WS-NOPROC ", entrance boxes of the rooms " WS-ENTS
     MOVE SPACES TO TL-CASE
     STRING FUNCTION TRIM(WS-LABEL) "the key values agree with the builder and the documents" DELIMITED BY SIZE INTO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-BAD TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

*> corridor: hr, sc, hps (booleans), Num, MST (36-5 2.6)
 CHECK-CORRIDOR.
     IF SPC-K(WS-P, 1) NOT = SP-F1(WS-I) OR SPC-K(WS-P, 2) NOT = SP-F2(WS-I) OR SPC-K(WS-P, 3) NOT = SP-F3(WS-I)
             OR SPC-K(WS-P, 4) NOT = SP-F4(WS-I) OR SPC-K(WS-P, 5) NOT = SP-MST(WS-I)
         ADD 1 TO WS-BAD
     END-IF
     IF SPC-K(WS-P, 1) > 1 OR SPC-K(WS-P, 2) > 1 OR SPC-K(WS-P, 3) > 1 OR SPC-K(WS-P, 4) < 1 OR SPC-K(WS-P, 5) > 1
         ADD 1 TO WS-BAD
     END-IF.

*> crossing: tf, D (the legacy direction value), MST (36-5 2.11)
 CHECK-CROSSING.
     IF SPC-K(WS-P, 1) NOT = SP-F1(WS-I) OR SPC-K(WS-P, 2) NOT = SP-F2(WS-I) OR SPC-K(WS-P, 3) NOT = SP-MST(WS-I)
         ADD 1 TO WS-BAD
     END-IF
     IF SPC-K(WS-P, 1) > 1 OR SPC-K(WS-P, 2) > 3 OR SPC-K(WS-P, 3) > 1
         ADD 1 TO WS-BAD
     END-IF.

*> room: MST and the entrance boxes of the builder (36-5 2.5)
 CHECK-ROOM.
     IF SPC-K(WS-P, 1) NOT = SP-MST(WS-I) OR SPC-ENT-N(WS-P) NOT = SP-ENT-N(WS-I)
         ADD 1 TO WS-BAD
     ELSE
         ADD SPC-ENT-N(WS-P) TO WS-ENTS
         PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > SPC-ENT-N(WS-P)
             COMPUTE WS-Q = SPC-ENT-FIRST(WS-P) + WS-K - 1
             COMPUTE WS-EN = SP-ENT-FIRST(WS-I) + WS-K - 1
             IF SSE-X0(WS-Q) NOT = SE-X0(WS-EN) OR SSE-Y0(WS-Q) NOT = SE-Y0(WS-EN) OR SSE-Z0(WS-Q) NOT = SE-Z0(WS-EN)
                     OR SSE-X1(WS-Q) NOT = SE-X1(WS-EN) OR SSE-Y1(WS-Q) NOT = SE-Y1(WS-EN) OR SSE-Z1(WS-Q) NOT = SE-Z1(WS-EN)
                 ADD 1 TO WS-BAD
             END-IF
         END-PERFORM
     END-IF.

 CHECK-STAIRS.
     IF SPC-K(WS-P, 1) NOT = SP-MST(WS-I)
         ADD 1 TO WS-BAD
     END-IF.

*> shipwreck (36-6 4.3): the template and its position and rotation as the builder holds them, isBeached by the structure, the height final (1)
 CHECK-SHIPWRECK.
     MOVE TP-KEY(SP-T-ROW(WS-I)) TO WS-TKEY
     IF SPC-TPL(WS-P) NOT = WS-TKEY
         ADD 1 TO WS-BAD
     END-IF
     IF SPC-K(WS-P, 1) NOT = SP-T-X(WS-I) OR SPC-K(WS-P, 2) NOT = SP-T-Y(WS-I) OR SPC-K(WS-P, 3) NOT = SP-T-Z(WS-I)
             OR SPC-K(WS-P, 4) NOT = SP-T-ROT(WS-I) OR SPC-K(WS-P, 6) NOT = 1
         ADD 1 TO WS-BAD
     END-IF
     MOVE 0 TO WS-WANT
     IF WS-KEY = "minecraft:shipwreck_beached"
         MOVE 1 TO WS-WANT
     END-IF
     IF SPC-K(WS-P, 5) NOT = WS-WANT
         ADD 1 TO WS-BAD
     END-IF.

*> ocean ruin (36-6 2.4, 3.4): Integrity 0.8 or 0.9 for the first piece of a ruin (warm: the only one), 0.7 for the second and 0.5 for the third of a cold one, BiomeType by the structure, IsLarge by the template
 CHECK-RUIN.
     MOVE TP-KEY(SP-T-ROW(WS-I)) TO WS-TKEY
     IF SPC-TPL(WS-P) NOT = WS-TKEY
         ADD 1 TO WS-BAD
     END-IF
     IF SP-T-PROC(WS-I) = 0
         ADD 1 TO WS-NOPROC
     END-IF
     IF SPC-K(WS-P, 1) NOT = SP-T-X(WS-I) OR SPC-K(WS-P, 2) NOT = SP-T-Y(WS-I) OR SPC-K(WS-P, 3) NOT = SP-T-Z(WS-I)
             OR SPC-K(WS-P, 4) NOT = SP-T-ROT(WS-I)
         ADD 1 TO WS-BAD
     END-IF
     MOVE 0 TO WS-WANT
     IF WS-KEY = "minecraft:ocean_ruin_cold"
         MOVE 1 TO WS-WANT
     END-IF
     IF SPC-K(WS-P, 6) NOT = WS-WANT
         ADD 1 TO WS-BAD
     END-IF
     EVALUATE TRUE
         WHEN WS-I = 1
             IF SPC-K(WS-P, 5) NOT = 8 AND SPC-K(WS-P, 5) NOT = 9
                 ADD 1 TO WS-BAD
             END-IF
         WHEN WS-I = 2 AND WS-WANT = 1
             IF SPC-K(WS-P, 5) NOT = 7
                 ADD 1 TO WS-BAD
             END-IF
         WHEN WS-I = 3 AND WS-WANT = 1
             IF SPC-K(WS-P, 5) NOT = 5
                 ADD 1 TO WS-BAD
             END-IF
         WHEN OTHER
             ADD 1 TO WS-BAD
     END-EVALUATE
     MOVE 0 TO WS-N
     INSPECT WS-TKEY TALLYING WS-N FOR ALL "/big_"
     IF WS-N > 0
         MOVE 1 TO WS-WANT
     ELSE
         MOVE 0 TO WS-WANT
     END-IF
     IF SPC-K(WS-P, 7) NOT = WS-WANT
         ADD 1 TO WS-BAD
     END-IF.

*> the part of WS-TKEY after its last slash, into WS-SHORT
 SHORT-NAME.
     MOVE 0 TO WS-SLASH
     PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > 96
         IF WS-TKEY(WS-J:1) = "/"
             MOVE WS-J TO WS-SLASH
         END-IF
     END-PERFORM
     COMPUTE WS-START = WS-SLASH + 1
     MOVE SPACES TO WS-SHORT
     MOVE WS-TKEY(WS-START:) TO WS-SHORT.

*> woodland mansion (36-7 3): the short template name, the position, Rot and Mi as the builder holds them
 CHECK-MANSION.
     MOVE TP-KEY(SP-T-ROW(WS-I)) TO WS-TKEY
     PERFORM SHORT-NAME
     IF SPC-TPL(WS-P) NOT = WS-SHORT
         ADD 1 TO WS-BAD
     END-IF
     IF SPC-K(WS-P, 1) NOT = SP-T-X(WS-I) OR SPC-K(WS-P, 2) NOT = SP-T-Y(WS-I) OR SPC-K(WS-P, 3) NOT = SP-T-Z(WS-I)
             OR SPC-K(WS-P, 4) NOT = SP-T-ROT(WS-I) OR SPC-K(WS-P, 5) NOT = SP-T-MIR(WS-I)
         ADD 1 TO WS-BAD
     END-IF.

*> end city (36-8 9.1, 10.2): the short template name, the position and Rot as the builder holds them, OW 0 for the floors and the second roof of the house towers, 1 for every other piece
 CHECK-CITY.
     MOVE TP-KEY(SP-T-ROW(WS-I)) TO WS-TKEY
     PERFORM SHORT-NAME
     IF SPC-TPL(WS-P) NOT = WS-SHORT
         ADD 1 TO WS-BAD
     END-IF
     IF SPC-K(WS-P, 1) NOT = SP-T-X(WS-I) OR SPC-K(WS-P, 2) NOT = SP-T-Y(WS-I) OR SPC-K(WS-P, 3) NOT = SP-T-Z(WS-I)
             OR SPC-K(WS-P, 4) NOT = SP-T-ROT(WS-I)
         ADD 1 TO WS-BAD
     END-IF
     MOVE 1 TO WS-WANT
     IF WS-SHORT = "second_floor_1" OR WS-SHORT = "second_floor_2" OR WS-SHORT = "third_floor_1" OR WS-SHORT = "third_floor_2"
             OR WS-SHORT = "second_roof"
         MOVE 0 TO WS-WANT
     END-IF
     IF SPC-K(WS-P, 5) NOT = WS-WANT
         ADD 1 TO WS-BAD
     END-IF.

*> a piece without a required key does not load: the first piece's Rot (and its BiomeType for a ruin) is renamed in the written bytes (a tag of another name is no key), the start is read into an empty
*> store and one piece is missing; the bytes are put back after each
 REQUIRED-KEY-CHECKS.
     IF WS-T >= 2 AND WS-T <= 5
         MOVE WS-PAT-ROT TO WS-PAT
         MOVE 6 TO WS-PL
         PERFORM FIND-PATTERN
         MOVE WS-SNAP-N TO WS-WANT
         SUBTRACT 1 FROM WS-WANT
         IF WS-OFF < PB-LENGTH
             COMPUTE WS-START = WS-OFF + 4
             MOVE "Rox" TO WS-VIEW(WS-START:3)
             CALL "STRUCT-STORE-RESET"
             PERFORM READ-STRUCTURES
             MOVE "Rot" TO WS-VIEW(WS-START:3)
         ELSE
             MOVE -1 TO WS-LOADED
         END-IF
         PERFORM REPORT-REQUIRED
     END-IF
     IF WS-T = 4 OR WS-T = 5
         MOVE WS-PAT-BIOME TO WS-PAT
         MOVE 12 TO WS-PL
         PERFORM FIND-PATTERN
         IF WS-OFF < PB-LENGTH
             COMPUTE WS-START = WS-OFF + 4
             MOVE "BiomeTypX" TO WS-VIEW(WS-START:9)
             CALL "STRUCT-STORE-RESET"
             PERFORM READ-STRUCTURES
             MOVE "BiomeType" TO WS-VIEW(WS-START:9)
         ELSE
             MOVE -1 TO WS-LOADED
         END-IF
         PERFORM REPORT-REQUIRED
     END-IF.

 REPORT-REQUIRED.
     MOVE SPACES TO TL-CASE
     STRING FUNCTION TRIM(WS-LABEL) "a piece that lacks a required key does not load (one piece fewer)" DELIMITED BY SIZE INTO TL-CASE
     MOVE WS-WANT TO TL-EXPECTED-N
     MOVE WS-LOADED TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

*> WS-OFF = the offset (0-based) of the first WS-PAT(1:WS-PL) (a tag header and its name) in the written bytes, PB-LENGTH when there is none
 FIND-PATTERN.
     MOVE 0 TO WS-OFF
     INSPECT WS-VIEW(1:PB-LENGTH) TALLYING WS-OFF FOR CHARACTERS BEFORE INITIAL WS-PAT(1:WS-PL).

*> the written chunk compound read into the store (the store is emptied first), WS-LOADED the number of pieces the start of the captured chunk has afterwards
 READ-STRUCTURES.
     MOVE 0 TO PB-POS
     CALL "NBT-READ-ROOT" USING PB-BUFFER WS-FRAMING WS-TYPE
     MOVE SPACES TO WN
     MOVE 32 TO WS-STRLEN
     CALL "NBT-READ-COMPOUND-NEXT" USING PB-BUFFER WS-TYPE WN WS-STRLEN WL
     CALL "STRUCT-STARTS-READ" USING PB-BUFFER WS-CX WS-CZ WS-OUTCOME
     CALL "STRUCT-START-FIND" USING WS-ROW-S WS-CX WS-CZ WS-ROW2
     MOVE 0 TO WS-LOADED
     IF WS-ROW2 > 0
         MOVE SST-N(WS-ROW2) TO WS-LOADED
     END-IF.

*> the start read from the written bytes into an empty store equals the captured one piece by piece
 RELOAD-CHECKS.
     CALL "STRUCT-STORE-RESET"
     PERFORM READ-STRUCTURES
     MOVE SPACES TO TL-CASE
     STRING FUNCTION TRIM(WS-LABEL) "the reloaded start has every piece" DELIMITED BY SIZE INTO TL-CASE
     MOVE WS-SNAP-N TO TL-EXPECTED-N
     MOVE WS-LOADED TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-DIFF
     IF WS-LOADED = WS-SNAP-N
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-SNAP-N
             COMPUTE WS-P = SST-FIRST(WS-ROW2) + WS-I - 1
             PERFORM COMPARE-PIECE
         END-PERFORM
     ELSE
         MOVE 1 TO WS-DIFF
     END-IF
     MOVE SPACES TO TL-CASE
     STRING FUNCTION TRIM(WS-LABEL) "the reloaded pieces equal the captured ones (type, orientation, depth, box, keys, template, entrances)" DELIMITED BY SIZE INTO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-DIFF TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

 COMPARE-PIECE.
     IF SPC-TYPE(WS-P) NOT = SN-TYPE(WS-I) OR SPC-ORIENT(WS-P) NOT = SN-ORIENT(WS-I) OR SPC-DEPTH(WS-P) NOT = SN-DEPTH(WS-I)
         ADD 1 TO WS-DIFF
     END-IF
     IF SPC-X0(WS-P) NOT = SN-BOX(WS-I, 1) OR SPC-Y0(WS-P) NOT = SN-BOX(WS-I, 2) OR SPC-Z0(WS-P) NOT = SN-BOX(WS-I, 3)
             OR SPC-X1(WS-P) NOT = SN-BOX(WS-I, 4) OR SPC-Y1(WS-P) NOT = SN-BOX(WS-I, 5) OR SPC-Z1(WS-P) NOT = SN-BOX(WS-I, 6)
         ADD 1 TO WS-DIFF
     END-IF
     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 8
         IF SPC-K(WS-P, WS-K) NOT = SN-K(WS-I, WS-K)
             ADD 1 TO WS-DIFF
         END-IF
     END-PERFORM
     IF SPC-TPL(WS-P) NOT = SN-TPL(WS-I)
         ADD 1 TO WS-DIFF
     END-IF
     IF SPC-ENT-N(WS-P) NOT = SN-ENT-N(WS-I)
         ADD 1 TO WS-DIFF
     ELSE
         PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > SPC-ENT-N(WS-P)
             COMPUTE WS-Q = SPC-ENT-FIRST(WS-P) + WS-K - 1
             COMPUTE WS-EN = SN-ENT-FIRST(WS-I) + WS-K - 1
             IF SSE-X0(WS-Q) NOT = SNE-B(WS-EN, 1) OR SSE-Y0(WS-Q) NOT = SNE-B(WS-EN, 2) OR SSE-Z0(WS-Q) NOT = SNE-B(WS-EN, 3)
                     OR SSE-X1(WS-Q) NOT = SNE-B(WS-EN, 4) OR SSE-Y1(WS-Q) NOT = SNE-B(WS-EN, 5) OR SSE-Z1(WS-Q) NOT = SNE-B(WS-EN, 6)
                 ADD 1 TO WS-DIFF
             END-IF
         END-PERFORM
     END-IF.
 END PROGRAM TEST-STRUCT-PIECE-KEYS-REAL.

 COPY NOSPAWN.
 COPY CORETEST.
