*> The loaders of the noise definitions and the density functions (docs/protocol/10-world-generation-terrain.md sections 3.3
*> and 4; 23 section 3) and the load driver all the worldgen loaders share. WG-LOAD reads the files of the worldgen
*> registries of a data tree (data/<namespace>/<registry path>/**/*.json, through the registry loader of registry.cob:
*> listing order, identifier rules) and turns each into a function row (CTWORLDGEN.cpy) over a tree of nodes
*> (worldgen-nodes.cob). Every error is printed on standard error as "ERROR registry: <label> <key>: <detail>"; any
*> error fails the load (23 section 3.5): the status is CT-BAD-DATA and the rows and nodes the load made are taken
*> back. The registries of a set that is open are not touched: the registry loader's table is a private one of the
*> load. Loads add to the store: load a registry once, WORLDGEN-FREE empties it. Not done here (owed to the engines):
*> the resolution of a reference to the element it names, the checks of an element against another registry.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. WORLDGEN-FREE.
*> No parameters: empties the store (no function, node, spline or point). Safe with nothing loaded.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CTWORLDGEN.
 PROCEDURE DIVISION.
     INITIALIZE WG-COUNTS
     GOBACK.
 END PROGRAM WORLDGEN-FREE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. WG-FIND.
*> USING kind (BINARY-LONG, 1 to 10: CTWORLDGEN.cpy), key (PIC X(64), "namespace:path"), root out (BINARY-LONG: the root
*> node of the element, 0 when there is none).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CTWORLDGEN.
 01 WS-I                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-KIND                 BINARY-LONG.
 01 L-KEY                  PIC X(64).
 01 L-ROOT                 BINARY-LONG.
 PROCEDURE DIVISION USING L-KIND L-KEY L-ROOT.
     MOVE 0 TO L-ROOT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WG-COUNT(WGK-FUNCTION) OR L-ROOT > 0
         IF WGF-KIND(WS-I) = L-KIND AND WGF-KEY(WS-I) = L-KEY
             MOVE WGF-ROOT(WS-I) TO L-ROOT
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM WG-FIND.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. WG-CHECK.
*> USING kind (BINARY-LONG), key (PIC X(64)), root node (BINARY-LONG), status out (BINARY-LONG: 0, or 1 after an error was
*> reported): the checks a file's values must pass once read. Noise (10 3.3): octave_count 1 to 32, as many modifiers
*> as octaves when there are any, each 0 to 1000000. Noise settings (37-2 2.1): noise.min_y and noise.height multiples of
*> 16, min_y from -2032 to 2031, height from 0 to 4064, min_y + height at most 2032. Dimension type (04 section 6,
*> 23 9.5): height at least 16 and at most 4064 and a multiple of 16, min_y a multiple of 16 from -2032 to 2031, min_y
*> + height at most 2032, logical_height from 0 to height, coordinate_scale from 0.00001 to 30000000,
*> monster_spawn_block_light_limit 0 to 15.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CTWORLDGEN.
 01 WS-M                   BINARY-LONG.
 01 WS-BAD                 BINARY-LONG.
 01 WS-DETAIL              PIC X(120).
 LINKAGE SECTION.
 01 L-KIND                 BINARY-LONG.
 01 L-KEY                  PIC X(64).
 01 L-ROOT                 BINARY-LONG.
 01 L-STATUS               BINARY-LONG.
 PROCEDURE DIVISION USING L-KIND L-KEY L-ROOT L-STATUS.
     MOVE 0 TO L-STATUS
     MOVE SPACES TO WS-DETAIL
     EVALUATE L-KIND
         WHEN 8
             IF WGN-INT(L-ROOT, 2) < 1 OR WGN-INT(L-ROOT, 2) > 32
                 MOVE "octave_count must be from 1 to 32" TO WS-DETAIL
             END-IF
             IF WGN-INT(L-ROOT, 3) NOT = 0 AND WGN-INT(L-ROOT, 3) NOT = WGN-INT(L-ROOT, 2)
                 MOVE "there must be one amplitude modifier for each octave" TO WS-DETAIL
             END-IF
             MOVE 0 TO WS-BAD
             MOVE WGN-CHILD(L-ROOT, 1) TO WS-M
             PERFORM UNTIL WS-M = 0
                 IF WGN-NUM(WS-M, 1) < 0 OR WGN-NUM(WS-M, 1) > 1000000
                     MOVE 1 TO WS-BAD
                 END-IF
                 MOVE WGN-NEXT(WS-M) TO WS-M
             END-PERFORM
             IF WS-BAD = 1
                 MOVE "an amplitude modifier must be from 0 to 1000000" TO WS-DETAIL
             END-IF
         WHEN 6
             IF FUNCTION MOD(WGN-INT(L-ROOT, 2), 16) NOT = 0 OR FUNCTION MOD(WGN-INT(L-ROOT, 3), 16) NOT = 0
                     OR WGN-INT(L-ROOT, 2) < -2032 OR WGN-INT(L-ROOT, 2) > 2031
                     OR WGN-INT(L-ROOT, 3) < 0 OR WGN-INT(L-ROOT, 3) > 4064
                     OR WGN-INT(L-ROOT, 2) + WGN-INT(L-ROOT, 3) > 2032
                 MOVE "noise.min_y and noise.height are out of range or not multiples of 16" TO WS-DETAIL
             END-IF
         WHEN 10
             IF WGN-INT(L-ROOT, 6) < 16 OR WGN-INT(L-ROOT, 6) > 4064 OR FUNCTION MOD(WGN-INT(L-ROOT, 6), 16) NOT = 0
                     OR FUNCTION MOD(WGN-INT(L-ROOT, 5), 16) NOT = 0
                     OR WGN-INT(L-ROOT, 5) < -2032 OR WGN-INT(L-ROOT, 5) > 2031
                     OR WGN-INT(L-ROOT, 5) + WGN-INT(L-ROOT, 6) > 2032
                 MOVE "min_y and height are out of range or not multiples of 16" TO WS-DETAIL
             END-IF
             IF WGN-INT(L-ROOT, 7) < 0 OR WGN-INT(L-ROOT, 7) > WGN-INT(L-ROOT, 6)
                 MOVE "logical_height must be from 0 to the height" TO WS-DETAIL
             END-IF
             IF WGN-NUM(L-ROOT, 1) < 0.00001 OR WGN-NUM(L-ROOT, 1) > 30000000
                 MOVE "coordinate_scale must be from 0.00001 to 30000000" TO WS-DETAIL
             END-IF
             IF WGN-INT(L-ROOT, 8) < 0 OR WGN-INT(L-ROOT, 8) > 15
                 MOVE "monster_spawn_block_light_limit must be from 0 to 15" TO WS-DETAIL
             END-IF
     END-EVALUATE
     IF WS-DETAIL NOT = SPACES
         CALL "WG-FAIL" USING L-KEY WS-DETAIL
         MOVE 1 TO L-STATUS
     END-IF
     GOBACK.
 END PROGRAM WG-CHECK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. WG-FILE-ADD.
*> USING JSON-DOC, kind (BINARY-LONG), key (PIC X(64)), text address (POINTER), length (BINARY-LONG), status out
*> (BINARY-LONG: 0, or 1 after an error was reported): reads one file that the strict reader accepted into the
*> store as a function row of the kind. A configured feature of a type other than minecraft:ore is left out (kind
*> 5 keeps the ore features only).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CTWORLDGEN.
 01 WS-PARSE               BINARY-LONG.
 01 WS-SKIP                BINARY-LONG.
 01 WS-NAME                PIC X(32).
 01 WS-TEXT                PIC X(200).
 01 WS-FOUND               BINARY-LONG.
 01 WS-DOMAIN              BINARY-LONG.
 01 WS-REGISTRY            PIC X(48).
 01 WS-LABEL               PIC X(32).
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-FUNCTION-TABLE      BINARY-LONG VALUE 4.
 01 WS-ROOT                BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-DETAIL              PIC X(120).
 LINKAGE SECTION.
 COPY JSONDOC.
 01 L-KIND                 BINARY-LONG.
 01 L-KEY                  PIC X(64).
 01 L-ADDR                 USAGE POINTER.
 01 L-LENGTH               BINARY-LONG.
 01 L-STATUS               BINARY-LONG.
 PROCEDURE DIVISION USING JSON-DOC L-KIND L-KEY L-ADDR L-LENGTH L-STATUS.
     MOVE 0 TO L-STATUS WS-SKIP
     CALL "WG-PARSE-DOC" USING JSON-DOC L-ADDR L-LENGTH WS-PARSE
     IF WS-PARSE NOT = 0
         MOVE "the file does not parse or holds a number of more than 63 bytes" TO WS-DETAIL
         CALL "WG-FAIL" USING L-KEY WS-DETAIL
         MOVE 1 TO L-STATUS
     ELSE
         IF L-KIND = 5 AND JN-TYPE(1) = JT-OBJECT
             MOVE "type" TO WS-NAME
             CALL "RECIPE-GET-TEXT" USING JSON-DOC WS-ONE WS-NAME WS-TEXT WS-FOUND
             IF WS-FOUND = 1 AND WS-TEXT NOT = "minecraft:ore"
                 MOVE 1 TO WS-SKIP
             END-IF
         END-IF
         IF WS-SKIP = 0
             CALL "WG-KIND-AT" USING L-KIND WS-REGISTRY WS-LABEL WS-DOMAIN
             CALL "WG-READ-NODE" USING JSON-DOC WS-ONE WS-DOMAIN L-KEY WS-ROOT L-STATUS
             IF L-STATUS = 0
                 CALL "WG-CHECK" USING L-KIND L-KEY WS-ROOT L-STATUS
             END-IF
             IF L-STATUS = 0
                 CALL "WG-ALLOC" USING WS-FUNCTION-TABLE WS-ONE L-KEY WS-ROW L-STATUS
             END-IF
             IF L-STATUS = 0
                 MOVE L-KIND TO WGF-KIND(WS-ROW)
                 MOVE L-KEY TO WGF-KEY(WS-ROW)
                 MOVE WS-ROOT TO WGF-ROOT(WS-ROW)
             END-IF
         END-IF
     END-IF
     GOBACK.
 END PROGRAM WG-FILE-ADD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. WG-LOAD.
*> USING root (PIC X(1100), z-string or space padded: the folder that holds data/), first kind and last kind (BINARY-LONG,
*> 1 to 10: the registries of CTWORLDGEN.cpy's function kinds, in this order), status out (CT-OK, CT-BAD-DATA).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CONTENT.
 COPY CTSTORE.
 COPY CTLOAD.
 COPY CTWORLDGEN.
 COPY FORMATS.
 COPY JSONDOC.
 01 WS-DIR-Z               PIC X(1101).
 01 WS-DIR-LENGTH          BINARY-LONG.
 01 WS-PATH-STATUS         BINARY-LONG.
 01 WS-BASE                PIC X(1101).
 01 WS-MESSAGE             PIC X(200).
 01 WS-TABLE               USAGE POINTER.
 01 WS-SAVED-ADDR          USAGE POINTER.
 01 WS-SAVED-COUNT         BINARY-LONG.
 01 WS-SAVED-COUNTS.
    05 WS-SAVED-ROWS       BINARY-LONG OCCURS 4 TIMES.
 01 WS-KIND                BINARY-LONG.
 01 WS-NAME                PIC X(48).
 01 WS-DOMAIN              BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-SLOT                BINARY-LONG.
 01 WS-KEY                 PIC X(64).
 01 WS-PAYLOAD             USAGE POINTER.
 01 WS-LENGTH              BINARY-LONG.
 01 WS-STATUS              BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIR                  PIC X(1100).
 01 L-FROM                 BINARY-LONG.
 01 L-TO                   BINARY-LONG.
 01 L-STATUS               BINARY-LONG.
 PROCEDURE DIVISION USING L-DIR L-FROM L-TO L-STATUS.
     MOVE 0 TO RS-ERRORS
     MOVE WG-COUNTS TO WS-SAVED-COUNTS
     CALL "FILE-PATH-Z" USING L-DIR WS-DIR-Z WS-DIR-LENGTH WS-PATH-STATUS
     IF WS-PATH-STATUS NOT = FM-OK
         MOVE "the data directory path is too long" TO WS-MESSAGE
         CALL "RS-ERROR" USING WS-MESSAGE
     ELSE
         MOVE LOW-VALUES TO WS-BASE
         STRING WS-DIR-Z(1:WS-DIR-LENGTH) "/data" DELIMITED BY SIZE INTO WS-BASE
*>       A private one-row registry table stands in for the set's (the set's own is put back afterwards).
         SET WS-SAVED-ADDR TO CT-REGISTRY-ADDR
         MOVE CT-REGISTRY-COUNT TO WS-SAVED-COUNT
         PERFORM VARYING WS-KIND FROM L-FROM BY 1 UNTIL WS-KIND > L-TO
             CALL "WG-KIND-AT" USING WS-KIND WS-NAME WG-LABEL WS-DOMAIN
             ALLOCATE LENGTH OF B-REGISTRIES CHARACTERS RETURNING WS-TABLE
             SET CT-REGISTRY-ADDR TO WS-TABLE
             SET ADDRESS OF B-REGISTRIES TO CT-REGISTRY-ADDR
             MOVE SPACES TO BR-KEY(1)
             MOVE 0 TO BR-KEY-LENGTH(1) BR-ENTRY-COUNT(1) BR-PAYLOAD-LENGTH(1)
             SET BR-ENTRY-ADDR(1) TO NULL
             SET BR-PAYLOAD-ADDR(1) TO NULL
             MOVE 1 TO CT-REGISTRY-COUNT WS-SLOT
             MOVE 0 TO RS-MODE
             CALL "REGISTRY-LOAD-ONE" USING WS-BASE WS-NAME WS-SLOT
             SET ADDRESS OF B-REGISTRIES TO CT-REGISTRY-ADDR
             PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > BR-ENTRY-COUNT(1)
                 SET ADDRESS OF B-ENTRIES TO BR-ENTRY-ADDR(1)
                 MOVE BE-KEY(WS-I) TO WS-KEY
                 MOVE BE-PAYLOAD-LENGTH(WS-I) TO WS-LENGTH
                 SET WS-PAYLOAD TO BR-PAYLOAD-ADDR(1)
                 SET WS-PAYLOAD UP BY BE-PAYLOAD-OFFSET(WS-I)
                 CALL "WG-FILE-ADD" USING JSON-DOC WS-KIND WS-KEY WS-PAYLOAD WS-LENGTH WS-STATUS
             END-PERFORM
             CALL "REGISTRY-FREE"
         END-PERFORM
         SET CT-REGISTRY-ADDR TO WS-SAVED-ADDR
         MOVE WS-SAVED-COUNT TO CT-REGISTRY-COUNT
     END-IF
     IF RS-ERRORS > 0
         MOVE WS-SAVED-COUNTS TO WG-COUNTS
         MOVE CT-BAD-DATA TO L-STATUS
     ELSE
         MOVE CT-OK TO L-STATUS
     END-IF
     GOBACK.
 END PROGRAM WG-LOAD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. NOISES-LOAD.
*> USING root (PIC X(1100)), status out (CT-OK, CT-BAD-DATA): the noise definitions of data/<namespace>/worldgen/noise
*> (function kind 8, domain 15 nodes: WGN-INT 1 base_octave, 2 octave_count, 3 the number of amplitude modifiers, 4
*> normalize (0 enabled, 1 disabled, 2 legacy); WGN-NUM(1) base_amplitude; WGN-CHILD(1) the chain of modifiers).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-KIND                BINARY-LONG VALUE 8.
 01 WS-LAST                BINARY-LONG VALUE 8.
 LINKAGE SECTION.
 01 L-DIR                  PIC X(1100).
 01 L-STATUS               BINARY-LONG.
 PROCEDURE DIVISION USING L-DIR L-STATUS.
     CALL "WG-LOAD" USING L-DIR WS-KIND WS-LAST L-STATUS
     GOBACK.
 END PROGRAM NOISES-LOAD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. DENSITY-FUNCTIONS-LOAD.
*> USING root (PIC X(1100)), status out (CT-OK, CT-BAD-DATA): the density functions of data/<namespace>/worldgen/
*> density_function (function kind 1, domain 1 nodes of the types of worldgen-types.cob; an element may be a bare
*> number, a reference string or an object).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-KIND                BINARY-LONG VALUE 1.
 01 WS-LAST                BINARY-LONG VALUE 1.
 LINKAGE SECTION.
 01 L-DIR                  PIC X(1100).
 01 L-STATUS               BINARY-LONG.
 PROCEDURE DIVISION USING L-DIR L-STATUS.
     CALL "WG-LOAD" USING L-DIR WS-KIND WS-LAST L-STATUS
     GOBACK.
 END PROGRAM DENSITY-FUNCTIONS-LOAD.
