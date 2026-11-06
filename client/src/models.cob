*> Block models (08 §5): MODEL-RESOLVE walks a model's parent chain (elements from the nearest model
*> that has them; texture slots merged, child entries winning; a model id naming no file, or a chain
*> deeper than 16 (a cycle), makes the model missing); ELEMENT-BAKE turns one face of an element into
*> a quad with CobolCraft's face UV rule (§5.5.1) and element rotation rule (§5.4.1);
*> VARIANT-ROTATE applies a block state Variant rotation (§4.3: clockwise quarter turns about the
*> block centre, x then y then z) to a quad and its directions; MODELS-BAKE bakes the quads of every
*> block state (BM-STATE). A state without a model, or with a missing one, gets the missing model:
*> a full cube with the missing texture on every face.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MODELS-BAKE.
*> USING CLIENT-STATE: fills BM-STATE for the block states of standin-content §1.2 (void: none):
*> each state's block state file selects its models (BLOCKSTATE-SELECT), STATE-BAKE bakes them.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLCONST.
 COPY JSONDOC.
 COPY CLMODEL.
 01 WS-S                   BINARY-LONG.
 01 WS-BLOCK               PIC X(32).
 01 WS-PROPS               PIC X(62).
 01 WS-PROPS-LENGTH        BINARY-LONG.
 01 WS-PATH                PIC X(256).
 01 WS-PATH-LENGTH         BINARY-LONG.
 01 WS-TEXT                PIC X(16384).
 01 WS-CAPACITY            BINARY-LONG VALUE 16384.
 01 WS-LENGTH              BINARY-LONG.
 01 WS-FOUND               BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 PROCEDURE DIVISION USING CLIENT-STATE.
     MOVE 0 TO BM-QUAD-COUNT(1)
     PERFORM VARYING WS-S FROM 2 BY 1 UNTIL WS-S > CL-MAX-STATES
         MOVE SPACES TO WS-BLOCK WS-PROPS WS-PATH
         UNSTRING CL-BS-TEXT(WS-S) DELIMITED BY SPACE INTO WS-BLOCK WS-PROPS
         MOVE FUNCTION LENGTH(FUNCTION TRIM(WS-PROPS)) TO WS-PROPS-LENGTH
         IF WS-PROPS = SPACES
             MOVE 0 TO WS-PROPS-LENGTH
         END-IF
         STRING "assets/cobolcraft/blockstates/" FUNCTION TRIM(WS-BLOCK) ".json"
             DELIMITED BY SIZE INTO WS-PATH
         MOVE FUNCTION LENGTH(FUNCTION TRIM(WS-PATH)) TO WS-PATH-LENGTH
         CALL "PACK-READ" USING CLIENT-STATE WS-PATH WS-PATH-LENGTH WS-TEXT WS-CAPACITY
             WS-LENGTH WS-FOUND
         CALL "JSON-PARSE" USING JSON-DOC WS-TEXT WS-LENGTH
         CALL "BLOCKSTATE-SELECT" USING JSON-DOC WS-PROPS WS-PROPS-LENGTH STATE-MODELS
         CALL "STATE-BAKE" USING CLIENT-STATE WS-S STATE-MODELS
     END-PERFORM
     GOBACK.
 END PROGRAM MODELS-BAKE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. STATE-BAKE.
*> USING CLIENT-STATE, state row (state id + 1), STATE-MODELS: bakes the faces of every element of
*> each selected model, turned by its Variant rotation, into BM-STATE of the row (at most
*> CL-MAX-QUADS). No model selected, or a missing model: the missing model.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLCONST.
 COPY CLMODEL REPLACING ==STATE-MODELS== BY ==WS-UNUSED-MODELS==
     ==SX-COUNT== BY ==WS-UNUSED-COUNT== ==SX-MODEL== BY ==WS-UNUSED-MODEL==
     ==SX-ID== BY ==WS-UNUSED-ID== ==SX-X== BY ==WS-UNUSED-X== ==SX-Y== BY ==WS-UNUSED-Y==
     ==SX-Z== BY ==WS-UNUSED-Z== ==SX-UVLOCK== BY ==WS-UNUSED-UVLOCK==.
 COPY CLQUAD.
 01 WS-M                   BINARY-LONG.
 01 WS-E                   BINARY-LONG.
 01 WS-F                   BINARY-LONG.
 01 WS-SPRITE              BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-ID-LENGTH           BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-S                    BINARY-LONG.
 01 STATE-MODELS.
    05 SX-COUNT            BINARY-LONG.
    05 SX-MODEL OCCURS 8 TIMES.
       10 SX-ID            PIC X(80).
       10 SX-X             BINARY-LONG.
       10 SX-Y             BINARY-LONG.
       10 SX-Z             BINARY-LONG.
       10 SX-UVLOCK        PIC 9.
 PROCEDURE DIVISION USING CLIENT-STATE L-S STATE-MODELS.
     MOVE 0 TO BM-QUAD-COUNT(L-S)
     MOVE SX-COUNT TO WS-COUNT
     IF WS-COUNT = 0
         MOVE 1 TO WS-COUNT
         MOVE SPACES TO SX-ID(1)
         MOVE 0 TO SX-X(1) SX-Y(1) SX-Z(1)
     END-IF
     PERFORM VARYING WS-M FROM 1 BY 1 UNTIL WS-M > WS-COUNT
         MOVE FUNCTION LENGTH(FUNCTION TRIM(SX-ID(WS-M))) TO WS-ID-LENGTH
         CALL "MODEL-RESOLVE" USING CLIENT-STATE SX-ID(WS-M) WS-ID-LENGTH MODEL-RESOLVED
         IF MR-MISSING = 1 OR SX-ID(WS-M) = SPACES
             CALL "MODEL-MISSING" USING MODEL-RESOLVED
         END-IF
         PERFORM VARYING WS-E FROM 1 BY 1 UNTIL WS-E > MR-ELEMENT-COUNT
             PERFORM VARYING WS-F FROM 1 BY 1 UNTIL WS-F > 6
                 IF MF-PRESENT(WS-E, WS-F) = 1 AND BM-QUAD-COUNT(L-S) < CL-MAX-QUADS
                     CALL "MODEL-SPRITE" USING CLIENT-STATE MODEL-RESOLVED
                         MF-TEXTURE(WS-E, WS-F) WS-SPRITE
                     CALL "ELEMENT-BAKE" USING MODEL-RESOLVED WS-E WS-F WS-SPRITE QUAD
                     CALL "VARIANT-ROTATE" USING QUAD SX-X(WS-M) SX-Y(WS-M) SX-Z(WS-M)
                     ADD 1 TO BM-QUAD-COUNT(L-S)
                     MOVE QUAD TO BM-QUAD(L-S, BM-QUAD-COUNT(L-S))
                 END-IF
             END-PERFORM
         END-PERFORM
     END-PERFORM
     GOBACK.
 END PROGRAM STATE-BAKE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MODEL-MISSING.
*> USING MODEL-RESOLVED: the missing model, a full cube whose faces each cull against their own
*> neighbour and name no texture (so they draw sprite 1, the missing texture).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-F                   BINARY-LONG.
 01 WS-A                   BINARY-LONG.
 LINKAGE SECTION.
 COPY CLMODEL.
 PROCEDURE DIVISION USING MODEL-RESOLVED.
     INITIALIZE MODEL-RESOLVED
     MOVE 1 TO MR-ELEMENT-COUNT
     PERFORM VARYING WS-A FROM 1 BY 1 UNTIL WS-A > 3
         MOVE 16 TO ME-TO(1, WS-A)
     END-PERFORM
     PERFORM VARYING WS-F FROM 1 BY 1 UNTIL WS-F > 6
         MOVE 1 TO MF-PRESENT(1, WS-F)
         MOVE WS-F TO MF-CULL(1, WS-F)
     END-PERFORM
     GOBACK.
 END PROGRAM MODEL-MISSING.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MODEL-RESOLVE.
*> USING CLIENT-STATE, model id (PIC X(80), "ns:path", namespace minecraft by default), id length,
*> MODEL-RESOLVED out.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY JSONDOC.
 01 WS-ID                  PIC X(80).
 01 WS-ID-LENGTH           BINARY-LONG.
 01 WS-DEPTH               BINARY-LONG.
 01 WS-COLON               BINARY-LONG.
 01 WS-PATH                PIC X(256).
 01 WS-PATH-LENGTH         BINARY-LONG.
 01 WS-TEXT                PIC X(65536).
 01 WS-CAPACITY            BINARY-LONG VALUE 65536.
 01 WS-LENGTH              BINARY-LONG.
 01 WS-FOUND               BINARY-LONG.
 01 WS-ROOT                BINARY-LONG VALUE 1.
 01 WS-NODE                BINARY-LONG.
 01 WS-ELEMENT             BINARY-LONG.
 01 WS-NAME                PIC X(16).
 01 WS-NAME-LENGTH         BINARY-LONG.
 01 WS-CAP                 BINARY-LONG VALUE 80.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-ID                   PIC X(80).
 01 L-ID-LENGTH            BINARY-LONG.
 COPY CLMODEL.
 PROCEDURE DIVISION USING CLIENT-STATE L-ID L-ID-LENGTH MODEL-RESOLVED.
     INITIALIZE MODEL-RESOLVED
     MOVE -1 TO MR-ELEMENT-COUNT
     MOVE L-ID TO WS-ID
     MOVE L-ID-LENGTH TO WS-ID-LENGTH
     MOVE 0 TO WS-DEPTH
     PERFORM UNTIL WS-ID-LENGTH = 0 OR MR-MISSING = 1 OR WS-DEPTH = 16
         ADD 1 TO WS-DEPTH
         MOVE 0 TO WS-COLON
         INSPECT WS-ID(1:WS-ID-LENGTH) TALLYING WS-COLON FOR CHARACTERS BEFORE INITIAL ":"
         MOVE SPACES TO WS-PATH
         IF WS-COLON < WS-ID-LENGTH
             STRING "assets/" WS-ID(1:WS-COLON) "/models/"
                 WS-ID(WS-COLON + 2:WS-ID-LENGTH - WS-COLON - 1) ".json" DELIMITED BY SIZE
                 INTO WS-PATH
         ELSE
             STRING "assets/minecraft/models/" WS-ID(1:WS-ID-LENGTH) ".json" DELIMITED BY SIZE
                 INTO WS-PATH
         END-IF
         MOVE FUNCTION LENGTH(FUNCTION TRIM(WS-PATH)) TO WS-PATH-LENGTH
         CALL "PACK-READ" USING CLIENT-STATE WS-PATH WS-PATH-LENGTH WS-TEXT WS-CAPACITY WS-LENGTH
             WS-FOUND
         MOVE 0 TO WS-ID-LENGTH
         IF WS-FOUND = 0
             MOVE 1 TO MR-MISSING
         ELSE
             CALL "JSON-PARSE" USING JSON-DOC WS-TEXT WS-LENGTH
             MOVE "textures" TO WS-NAME
             MOVE 8 TO WS-NAME-LENGTH
             CALL "JSON-MEMBER" USING JSON-DOC WS-ROOT WS-NAME WS-NAME-LENGTH WS-NODE
             CALL "MODEL-TEXTURES-PARSE" USING JSON-DOC WS-NODE MODEL-RESOLVED
             MOVE "elements" TO WS-NAME
             CALL "JSON-MEMBER" USING JSON-DOC WS-ROOT WS-NAME WS-NAME-LENGTH WS-NODE
             IF WS-NODE > 0 AND MR-ELEMENT-COUNT < 0
                 MOVE 0 TO MR-ELEMENT-COUNT
                 MOVE JN-FIRST(WS-NODE) TO WS-ELEMENT
                 PERFORM UNTIL WS-ELEMENT = 0 OR MR-ELEMENT-COUNT = 8
                     ADD 1 TO MR-ELEMENT-COUNT
                     CALL "MODEL-ELEMENT-PARSE" USING JSON-DOC WS-ELEMENT MODEL-RESOLVED
                         MR-ELEMENT-COUNT
                     MOVE JN-NEXT(WS-ELEMENT) TO WS-ELEMENT
                 END-PERFORM
             END-IF
             MOVE "parent" TO WS-NAME
             MOVE 6 TO WS-NAME-LENGTH
             CALL "JSON-MEMBER" USING JSON-DOC WS-ROOT WS-NAME WS-NAME-LENGTH WS-NODE
             MOVE SPACES TO WS-ID
             CALL "JSON-STRING" USING JSON-DOC WS-NODE WS-ID WS-CAP WS-ID-LENGTH
         END-IF
     END-PERFORM
*>   A chain still going after 16 models is a cycle: the model is unusable (08 §5.2).
     COMPUTE MR-MISSING = FUNCTION MAX(MR-MISSING, FUNCTION MIN(WS-ID-LENGTH, 1))
     MOVE FUNCTION MAX(MR-ELEMENT-COUNT, 0) TO MR-ELEMENT-COUNT
     GOBACK.
 END PROGRAM MODEL-RESOLVE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MODEL-TEXTURES-PARSE.
*> USING JSON-DOC, textures object node (0 = none), MODEL-RESOLVED: adds each slot not yet set
*> (the chain is walked from the child up, so the child wins). A value is a string ("#slot" or a
*> sprite id) or an object {"sprite": id}.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-NODE                BINARY-LONG.
 01 WS-VALUE               BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-SET                 BINARY-LONG.
 01 WS-SLOT                PIC X(32).
 01 WS-SLOT-CAP            BINARY-LONG VALUE 32.
 01 WS-SLOT-LENGTH         BINARY-LONG.
 01 WS-CAP                 BINARY-LONG VALUE 80.
 01 WS-LENGTH              BINARY-LONG.
 01 WS-NAME                PIC X(8) VALUE "sprite".
 01 WS-NAME-LENGTH         BINARY-LONG VALUE 6.
 LINKAGE SECTION.
 COPY JSONDOC.
 01 L-NODE                 BINARY-LONG.
 COPY CLMODEL.
 PROCEDURE DIVISION USING JSON-DOC L-NODE MODEL-RESOLVED.
     MOVE 0 TO WS-NODE
     IF L-NODE > 0
         MOVE JN-FIRST(L-NODE) TO WS-NODE
     END-IF
     PERFORM UNTIL WS-NODE = 0
         MOVE SPACES TO WS-SLOT
         CALL "JSON-KEY" USING JSON-DOC WS-NODE WS-SLOT WS-SLOT-CAP WS-SLOT-LENGTH
         MOVE 0 TO WS-SET
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > MR-SLOT-COUNT
             IF MS-NAME(WS-I) = WS-SLOT
                 MOVE 1 TO WS-SET
             END-IF
         END-PERFORM
         IF WS-SET = 0 AND MR-SLOT-COUNT < 16
             ADD 1 TO MR-SLOT-COUNT
             MOVE WS-SLOT TO MS-NAME(MR-SLOT-COUNT)
             MOVE SPACES TO MS-VALUE(MR-SLOT-COUNT)
             MOVE WS-NODE TO WS-VALUE
             IF JN-TYPE(WS-NODE) = JT-OBJECT
                 CALL "JSON-MEMBER" USING JSON-DOC WS-NODE WS-NAME WS-NAME-LENGTH WS-VALUE
             END-IF
             CALL "JSON-STRING" USING JSON-DOC WS-VALUE MS-VALUE(MR-SLOT-COUNT) WS-CAP WS-LENGTH
         END-IF
         MOVE JN-NEXT(WS-NODE) TO WS-NODE
     END-PERFORM
     GOBACK.
 END PROGRAM MODEL-TEXTURES-PARSE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MODEL-ELEMENT-PARSE.
*> USING JSON-DOC, element node, MODEL-RESOLVED, element index: from, to, rotation (origin with
*> axis and angle, or x, y, z; rescale), shade_direction_override and the faces (texture, uv,
*> cullface, rotation modulo 360).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLCONST.
 01 WS-FIELD               BINARY-LONG.
 01 WS-ROT                 BINARY-LONG.
 01 WS-FACES               BINARY-LONG.
 01 WS-FACE                BINARY-LONG.
 01 WS-A                   BINARY-LONG.
 01 WS-F                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-E                   BINARY-LONG.
 01 WS-NODE                BINARY-LONG.
 01 WS-NAME                PIC X(32).
 01 WS-NAME-LENGTH         BINARY-LONG.
 01 WS-VALUE               PIC X(80).
 01 WS-CAP                 BINARY-LONG VALUE 80.
 01 WS-LENGTH              BINARY-LONG.
 01 WS-AXES                PIC X(3) VALUE "xyz".
 01 WS-DIRS.
    05 FILLER PIC X(6) VALUE "down".
    05 FILLER PIC X(6) VALUE "up".
    05 FILLER PIC X(6) VALUE "north".
    05 FILLER PIC X(6) VALUE "south".
    05 FILLER PIC X(6) VALUE "west".
    05 FILLER PIC X(6) VALUE "east".
 01 WS-DIR-TABLE REDEFINES WS-DIRS.
    05 WS-DIR              PIC X(6) OCCURS 6 TIMES.
 LINKAGE SECTION.
 COPY JSONDOC.
 01 L-NODE                 BINARY-LONG.
 COPY CLMODEL.
 01 L-INDEX                BINARY-LONG.
 PROCEDURE DIVISION USING JSON-DOC L-NODE MODEL-RESOLVED L-INDEX.
     MOVE L-INDEX TO WS-E
     INITIALIZE MR-ELEMENT(WS-E)
     MOVE "from" TO WS-NAME
     MOVE 4 TO WS-NAME-LENGTH
     CALL "JSON-MEMBER" USING JSON-DOC L-NODE WS-NAME WS-NAME-LENGTH WS-FIELD
     PERFORM VARYING WS-A FROM 1 BY 1 UNTIL WS-A > 3
         COMPUTE WS-K = WS-A - 1
         CALL "JSON-ELEMENT" USING JSON-DOC WS-FIELD WS-K WS-NODE
         MOVE JN-NUM(WS-NODE) TO ME-FROM(WS-E, WS-A)
     END-PERFORM
     MOVE "to" TO WS-NAME
     MOVE 2 TO WS-NAME-LENGTH
     CALL "JSON-MEMBER" USING JSON-DOC L-NODE WS-NAME WS-NAME-LENGTH WS-FIELD
     PERFORM VARYING WS-A FROM 1 BY 1 UNTIL WS-A > 3
         COMPUTE WS-K = WS-A - 1
         CALL "JSON-ELEMENT" USING JSON-DOC WS-FIELD WS-K WS-NODE
         MOVE JN-NUM(WS-NODE) TO ME-TO(WS-E, WS-A)
     END-PERFORM
     MOVE "rotation" TO WS-NAME
     MOVE 8 TO WS-NAME-LENGTH
     CALL "JSON-MEMBER" USING JSON-DOC L-NODE WS-NAME WS-NAME-LENGTH WS-ROT
     IF WS-ROT > 0
         MOVE 2 TO ME-ROT-KIND(WS-E)
         MOVE "origin" TO WS-NAME
         MOVE 6 TO WS-NAME-LENGTH
         CALL "JSON-MEMBER" USING JSON-DOC WS-ROT WS-NAME WS-NAME-LENGTH WS-FIELD
         MOVE 1 TO WS-NAME-LENGTH
         PERFORM VARYING WS-A FROM 1 BY 1 UNTIL WS-A > 3
             COMPUTE WS-K = WS-A - 1
             CALL "JSON-ELEMENT" USING JSON-DOC WS-FIELD WS-K WS-NODE
             MOVE JN-NUM(WS-NODE) TO ME-ROT-ORIGIN(WS-E, WS-A)
             MOVE WS-AXES(WS-A:1) TO WS-NAME
             CALL "JSON-MEMBER" USING JSON-DOC WS-ROT WS-NAME WS-NAME-LENGTH WS-NODE
             IF WS-NODE > 0
                 MOVE JN-NUM(WS-NODE) TO ME-ROT-ANGLE(WS-E, WS-A)
             END-IF
         END-PERFORM
         MOVE "axis" TO WS-NAME
         MOVE 4 TO WS-NAME-LENGTH
         CALL "JSON-MEMBER" USING JSON-DOC WS-ROT WS-NAME WS-NAME-LENGTH WS-FIELD
         IF WS-FIELD > 0
             MOVE 1 TO ME-ROT-KIND(WS-E)
             MOVE SPACES TO WS-VALUE
             CALL "JSON-STRING" USING JSON-DOC WS-FIELD WS-VALUE WS-CAP WS-LENGTH
             MOVE 0 TO ME-ROT-AXIS(WS-E)
             INSPECT WS-AXES TALLYING ME-ROT-AXIS(WS-E) FOR CHARACTERS BEFORE INITIAL WS-VALUE(1:1)
             ADD 1 TO ME-ROT-AXIS(WS-E)
             MOVE "angle" TO WS-NAME
             MOVE 5 TO WS-NAME-LENGTH
             CALL "JSON-MEMBER" USING JSON-DOC WS-ROT WS-NAME WS-NAME-LENGTH WS-FIELD
             MOVE JN-NUM(WS-FIELD) TO ME-ROT-ANGLE(WS-E, 1)
         END-IF
         MOVE "rescale" TO WS-NAME
         MOVE 7 TO WS-NAME-LENGTH
         CALL "JSON-MEMBER" USING JSON-DOC WS-ROT WS-NAME WS-NAME-LENGTH WS-FIELD
         IF WS-FIELD > 0
             IF JN-TYPE(WS-FIELD) = JT-TRUE
                 MOVE 1 TO ME-RESCALE(WS-E)
             END-IF
         END-IF
     END-IF
     MOVE "shade_direction_override" TO WS-NAME
     MOVE 24 TO WS-NAME-LENGTH
     CALL "JSON-MEMBER" USING JSON-DOC L-NODE WS-NAME WS-NAME-LENGTH WS-FIELD
     MOVE SPACES TO WS-VALUE
     CALL "JSON-STRING" USING JSON-DOC WS-FIELD WS-VALUE WS-CAP WS-LENGTH
     PERFORM VARYING WS-F FROM 1 BY 1 UNTIL WS-F > 6
         IF WS-VALUE = WS-DIR(WS-F)
             MOVE WS-F TO ME-SHADE(WS-E)
         END-IF
     END-PERFORM
     MOVE "faces" TO WS-NAME
     MOVE 5 TO WS-NAME-LENGTH
     CALL "JSON-MEMBER" USING JSON-DOC L-NODE WS-NAME WS-NAME-LENGTH WS-FACES
     PERFORM VARYING WS-F FROM 1 BY 1 UNTIL WS-F > 6
         MOVE WS-DIR(WS-F) TO WS-NAME
         MOVE FUNCTION LENGTH(FUNCTION TRIM(WS-DIR(WS-F))) TO WS-NAME-LENGTH
         CALL "JSON-MEMBER" USING JSON-DOC WS-FACES WS-NAME WS-NAME-LENGTH WS-FACE
         IF WS-FACE > 0
             MOVE 1 TO MF-PRESENT(WS-E, WS-F)
             MOVE "texture" TO WS-NAME
             MOVE 7 TO WS-NAME-LENGTH
             CALL "JSON-MEMBER" USING JSON-DOC WS-FACE WS-NAME WS-NAME-LENGTH WS-FIELD
             CALL "JSON-STRING" USING JSON-DOC WS-FIELD MF-TEXTURE(WS-E, WS-F) WS-CAP WS-LENGTH
             MOVE "uv" TO WS-NAME
             MOVE 2 TO WS-NAME-LENGTH
             CALL "JSON-MEMBER" USING JSON-DOC WS-FACE WS-NAME WS-NAME-LENGTH WS-FIELD
             IF WS-FIELD > 0
                 MOVE 1 TO MF-UV-GIVEN(WS-E, WS-F)
                 PERFORM VARYING WS-A FROM 1 BY 1 UNTIL WS-A > 4
                     COMPUTE WS-K = WS-A - 1
                     CALL "JSON-ELEMENT" USING JSON-DOC WS-FIELD WS-K WS-NODE
                     MOVE JN-NUM(WS-NODE) TO MF-UV(WS-E, WS-F, WS-A)
                 END-PERFORM
             END-IF
             MOVE "cullface" TO WS-NAME
             MOVE 8 TO WS-NAME-LENGTH
             CALL "JSON-MEMBER" USING JSON-DOC WS-FACE WS-NAME WS-NAME-LENGTH WS-FIELD
             MOVE SPACES TO WS-VALUE
             CALL "JSON-STRING" USING JSON-DOC WS-FIELD WS-VALUE WS-CAP WS-LENGTH
             PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 6
                 IF WS-VALUE = WS-DIR(WS-K)
                     MOVE WS-K TO MF-CULL(WS-E, WS-F)
                 END-IF
             END-PERFORM
             MOVE "rotation" TO WS-NAME
             MOVE 8 TO WS-NAME-LENGTH
             CALL "JSON-MEMBER" USING JSON-DOC WS-FACE WS-NAME WS-NAME-LENGTH WS-FIELD
             IF WS-FIELD > 0
                 COMPUTE MF-ROTATION(WS-E, WS-F) = FUNCTION MOD(JN-NUM(WS-FIELD), 360)
             END-IF
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM MODEL-ELEMENT-PARSE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MODEL-SPRITE.
*> USING CLIENT-STATE, MODEL-RESOLVED, texture (PIC X(80): "#slot" or a sprite id), sprite out:
*> follows "#" references through the slots (at most 8 steps) to a sprite id ("ns:path", namespace
*> minecraft by default) and looks it up in the atlas; unresolved: sprite 1 (missing texture).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-VALUE               PIC X(80).
 01 WS-I                   BINARY-LONG.
 01 WS-STEP                BINARY-LONG.
 01 WS-NEXT                PIC X(80).
 01 WS-ID                  PIC X(80).
 01 WS-LENGTH              BINARY-LONG.
 01 WS-COLON               BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 COPY CLMODEL.
 01 L-TEXTURE              PIC X(80).
 01 L-SPRITE               BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE MODEL-RESOLVED L-TEXTURE L-SPRITE.
     MOVE L-TEXTURE TO WS-VALUE
     PERFORM VARYING WS-STEP FROM 1 BY 1 UNTIL WS-STEP > 8 OR WS-VALUE(1:1) NOT = "#"
         MOVE SPACES TO WS-NEXT
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > MR-SLOT-COUNT
             IF MS-NAME(WS-I) = WS-VALUE(2:)
                 MOVE MS-VALUE(WS-I) TO WS-NEXT
             END-IF
         END-PERFORM
         MOVE WS-NEXT TO WS-VALUE
     END-PERFORM
     MOVE 0 TO L-SPRITE
     MOVE FUNCTION LENGTH(FUNCTION TRIM(WS-VALUE)) TO WS-LENGTH
     MOVE 0 TO WS-COLON
     INSPECT WS-VALUE TALLYING WS-COLON FOR CHARACTERS BEFORE INITIAL ":"
     MOVE WS-VALUE TO WS-ID
     IF WS-COLON >= WS-LENGTH
         MOVE SPACES TO WS-ID
         STRING "minecraft:" WS-VALUE(1:WS-LENGTH) DELIMITED BY SIZE INTO WS-ID
         ADD 10 TO WS-LENGTH
     END-IF
     IF WS-VALUE NOT = SPACES AND WS-VALUE(1:1) NOT = "#"
         CALL "ATLAS-FIND" USING CLIENT-STATE WS-ID WS-LENGTH L-SPRITE
     END-IF
     MOVE FUNCTION MAX(L-SPRITE, 1) TO L-SPRITE
     GOBACK.
 END PROGRAM MODEL-SPRITE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ELEMENT-BAKE.
*> USING MODEL-RESOLVED, element index, face (DIR-*), sprite, QUAD out. Corners (sixteenths) as seen
*> from outside the element: for the side faces top is +y; for up the top edge is north and the
*> right edge east; for down the top edge is south and the right edge east. UVs: the face's uv or
*> the default of 08 §5.5.1; a face rotation of r moves each corner's UV r / 90 corners clockwise.
*> Then the element rotation (§5.4.1, right-handed, about the origin; Euler x, then y, then z;
*> single-axis rescale) and the division by 16.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLCONST.
 01 FX                     FLOAT-LONG.
 01 FY                     FLOAT-LONG.
 01 FZ                     FLOAT-LONG.
 01 TX                     FLOAT-LONG.
 01 TY                     FLOAT-LONG.
 01 TZ                     FLOAT-LONG.
 01 WS-P OCCURS 4 TIMES.
    05 WS-PX               FLOAT-LONG.
    05 WS-PY               FLOAT-LONG.
    05 WS-PZ               FLOAT-LONG.
 01 WS-UV                  FLOAT-LONG OCCURS 4 TIMES.
 01 WS-CU                  FLOAT-LONG OCCURS 4 TIMES.
 01 WS-CV                  FLOAT-LONG OCCURS 4 TIMES.
 01 WS-K                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-A                   BINARY-LONG.
 01 WS-SHIFT               BINARY-LONG.
 01 WS-AXIS                BINARY-LONG.
 01 WS-RAD                 FLOAT-LONG.
 01 WS-C                   FLOAT-LONG.
 01 WS-S                   FLOAT-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-T                   FLOAT-LONG.
 01 WS-SCALE               FLOAT-LONG.
 LINKAGE SECTION.
 COPY CLMODEL.
 01 L-E                    BINARY-LONG.
 01 L-FACE                 BINARY-LONG.
 01 L-SPRITE               BINARY-LONG.
 COPY CLQUAD.
 PROCEDURE DIVISION USING MODEL-RESOLVED L-E L-FACE L-SPRITE QUAD.
     MOVE ME-FROM(L-E, 1) TO FX
     MOVE ME-FROM(L-E, 2) TO FY
     MOVE ME-FROM(L-E, 3) TO FZ
     MOVE ME-TO(L-E, 1) TO TX
     MOVE ME-TO(L-E, 2) TO TY
     MOVE ME-TO(L-E, 3) TO TZ
*>   Corners top-left, top-right, bottom-right, bottom-left and the default uv [u1, v1, u2, v2].
     EVALUATE L-FACE
         WHEN DIR-DOWN
             MOVE FX TO WS-PX(1) WS-PX(4)
             MOVE TX TO WS-PX(2) WS-PX(3)
             MOVE FY TO WS-PY(1) WS-PY(2) WS-PY(3) WS-PY(4)
             MOVE TZ TO WS-PZ(1) WS-PZ(2)
             MOVE FZ TO WS-PZ(3) WS-PZ(4)
             MOVE FX TO WS-UV(1)
             COMPUTE WS-UV(2) = 16 - TZ
             MOVE TX TO WS-UV(3)
             COMPUTE WS-UV(4) = 16 - FZ
         WHEN DIR-UP
             MOVE FX TO WS-PX(1) WS-PX(4)
             MOVE TX TO WS-PX(2) WS-PX(3)
             MOVE TY TO WS-PY(1) WS-PY(2) WS-PY(3) WS-PY(4)
             MOVE FZ TO WS-PZ(1) WS-PZ(2)
             MOVE TZ TO WS-PZ(3) WS-PZ(4)
             MOVE FX TO WS-UV(1)
             MOVE FZ TO WS-UV(2)
             MOVE TX TO WS-UV(3)
             MOVE TZ TO WS-UV(4)
         WHEN DIR-NORTH
             MOVE TX TO WS-PX(1) WS-PX(4)
             MOVE FX TO WS-PX(2) WS-PX(3)
             MOVE TY TO WS-PY(1) WS-PY(2)
             MOVE FY TO WS-PY(3) WS-PY(4)
             MOVE FZ TO WS-PZ(1) WS-PZ(2) WS-PZ(3) WS-PZ(4)
             COMPUTE WS-UV(1) = 16 - TX
             COMPUTE WS-UV(2) = 16 - TY
             COMPUTE WS-UV(3) = 16 - FX
             COMPUTE WS-UV(4) = 16 - FY
         WHEN DIR-SOUTH
             MOVE FX TO WS-PX(1) WS-PX(4)
             MOVE TX TO WS-PX(2) WS-PX(3)
             MOVE TY TO WS-PY(1) WS-PY(2)
             MOVE FY TO WS-PY(3) WS-PY(4)
             MOVE TZ TO WS-PZ(1) WS-PZ(2) WS-PZ(3) WS-PZ(4)
             MOVE FX TO WS-UV(1)
             COMPUTE WS-UV(2) = 16 - TY
             MOVE TX TO WS-UV(3)
             COMPUTE WS-UV(4) = 16 - FY
         WHEN DIR-WEST
             MOVE FX TO WS-PX(1) WS-PX(2) WS-PX(3) WS-PX(4)
             MOVE TY TO WS-PY(1) WS-PY(2)
             MOVE FY TO WS-PY(3) WS-PY(4)
             MOVE FZ TO WS-PZ(1) WS-PZ(4)
             MOVE TZ TO WS-PZ(2) WS-PZ(3)
             MOVE FZ TO WS-UV(1)
             COMPUTE WS-UV(2) = 16 - TY
             MOVE TZ TO WS-UV(3)
             COMPUTE WS-UV(4) = 16 - FY
         WHEN DIR-EAST
             MOVE TX TO WS-PX(1) WS-PX(2) WS-PX(3) WS-PX(4)
             MOVE TY TO WS-PY(1) WS-PY(2)
             MOVE FY TO WS-PY(3) WS-PY(4)
             MOVE TZ TO WS-PZ(1) WS-PZ(4)
             MOVE FZ TO WS-PZ(2) WS-PZ(3)
             COMPUTE WS-UV(1) = 16 - TZ
             COMPUTE WS-UV(2) = 16 - TY
             COMPUTE WS-UV(3) = 16 - FZ
             COMPUTE WS-UV(4) = 16 - FY
     END-EVALUATE
     IF MF-UV-GIVEN(L-E, L-FACE) = 1
         PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 4
             MOVE MF-UV(L-E, L-FACE, WS-K) TO WS-UV(WS-K)
         END-PERFORM
     END-IF
*>   Corner UVs with rotation 0, then shifted clockwise by the face rotation.
     MOVE WS-UV(1) TO WS-CU(1) WS-CU(4)
     MOVE WS-UV(3) TO WS-CU(2) WS-CU(3)
     MOVE WS-UV(2) TO WS-CV(1) WS-CV(2)
     MOVE WS-UV(4) TO WS-CV(3) WS-CV(4)
     COMPUTE WS-SHIFT = MF-ROTATION(L-E, L-FACE) / 90
     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 4
         COMPUTE WS-J = FUNCTION MOD(WS-K - 1 + WS-SHIFT, 4) + 1
         MOVE WS-CU(WS-K) TO QD-U(WS-J)
         MOVE WS-CV(WS-K) TO QD-V(WS-J)
     END-PERFORM
*>   Element rotation about the origin (each step about a fixed model axis).
     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 4
         COMPUTE WS-X = WS-PX(WS-K) - ME-ROT-ORIGIN(L-E, 1)
         COMPUTE WS-Y = WS-PY(WS-K) - ME-ROT-ORIGIN(L-E, 2)
         COMPUTE WS-Z = WS-PZ(WS-K) - ME-ROT-ORIGIN(L-E, 3)
         PERFORM VARYING WS-A FROM 1 BY 1 UNTIL WS-A > 3
             MOVE 0 TO WS-RAD
             MOVE WS-A TO WS-AXIS
             IF ME-ROT-KIND(L-E) = 2
                 COMPUTE WS-RAD = ME-ROT-ANGLE(L-E, WS-A) * FUNCTION PI / 180
             END-IF
             IF ME-ROT-KIND(L-E) = 1 AND WS-A = 1
                 COMPUTE WS-RAD = ME-ROT-ANGLE(L-E, 1) * FUNCTION PI / 180
                 MOVE ME-ROT-AXIS(L-E) TO WS-AXIS
             END-IF
             COMPUTE WS-C = FUNCTION COS(WS-RAD)
             COMPUTE WS-S = FUNCTION SIN(WS-RAD)
             MOVE 1 TO WS-SCALE
             IF ME-ROT-KIND(L-E) = 1 AND ME-RESCALE(L-E) = 1
                 COMPUTE WS-SCALE = 1 / FUNCTION MAX(FUNCTION ABS(WS-C), FUNCTION ABS(WS-S))
             END-IF
             EVALUATE WS-AXIS
                 WHEN 1
                     COMPUTE WS-T = (WS-Y * WS-C - WS-Z * WS-S) * WS-SCALE
                     COMPUTE WS-Z = (WS-Y * WS-S + WS-Z * WS-C) * WS-SCALE
                     MOVE WS-T TO WS-Y
                 WHEN 2
                     COMPUTE WS-T = (WS-X * WS-C + WS-Z * WS-S) * WS-SCALE
                     COMPUTE WS-Z = (WS-Z * WS-C - WS-X * WS-S) * WS-SCALE
                     MOVE WS-T TO WS-X
                 WHEN 3
                     COMPUTE WS-T = (WS-X * WS-C - WS-Y * WS-S) * WS-SCALE
                     COMPUTE WS-Y = (WS-X * WS-S + WS-Y * WS-C) * WS-SCALE
                     MOVE WS-T TO WS-X
             END-EVALUATE
         END-PERFORM
         COMPUTE QD-X(WS-K) = (WS-X + ME-ROT-ORIGIN(L-E, 1)) / 16
         COMPUTE QD-Y(WS-K) = (WS-Y + ME-ROT-ORIGIN(L-E, 2)) / 16
         COMPUTE QD-Z(WS-K) = (WS-Z + ME-ROT-ORIGIN(L-E, 3)) / 16
     END-PERFORM
     MOVE L-SPRITE TO QD-SPRITE
     MOVE MF-CULL(L-E, L-FACE) TO QD-CULL
     MOVE L-FACE TO QD-SHADE
     IF ME-SHADE(L-E) > 0
         MOVE ME-SHADE(L-E) TO QD-SHADE
     END-IF
     GOBACK.
 END PROGRAM ELEMENT-BAKE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. VARIANT-ROTATE.
*> USING QUAD, x, y, z (0, 90, 180 or 270): turns the corners about the block centre and the cull
*> and shade directions: x quarter turns first (up to north), then y (north to east), then z
*> (down to west), each clockwise as seen from the positive end of its axis.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLCONST.
 01 WS-VECTORS.
    05 FILLER PIC X(3) VALUE "101".   *> down  (0, -1, 0) as digits + 1
    05 FILLER PIC X(3) VALUE "121".   *> up    (0, 1, 0)
    05 FILLER PIC X(3) VALUE "110".   *> north (0, 0, -1)
    05 FILLER PIC X(3) VALUE "112".   *> south (0, 0, 1)
    05 FILLER PIC X(3) VALUE "011".   *> west  (-1, 0, 0)
    05 FILLER PIC X(3) VALUE "211".   *> east  (1, 0, 0)
 01 WS-VECTOR-TABLE REDEFINES WS-VECTORS.
    05 WS-VECTOR OCCURS 6 TIMES.
       10 WS-VX            PIC 9.
       10 WS-VY            PIC 9.
       10 WS-VZ            PIC 9.
 01 WS-POINT OCCURS 6 TIMES.          *> corners 1 to 4, the cull vector (5), the shade vector (6)
    05 WS-X                FLOAT-SHORT.
    05 WS-Y                FLOAT-SHORT.
    05 WS-Z                FLOAT-SHORT.
 01 WS-T                   FLOAT-SHORT.
 01 WS-K                   BINARY-LONG.
 01 WS-D                   BINARY-LONG.
 01 WS-A                   BINARY-LONG.
 01 WS-TURN                BINARY-LONG.
 01 WS-TURNS               BINARY-LONG.
 LINKAGE SECTION.
 COPY CLQUAD.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 PROCEDURE DIVISION USING QUAD L-X L-Y L-Z.
     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 4
         COMPUTE WS-X(WS-K) = QD-X(WS-K) - 0.5
         COMPUTE WS-Y(WS-K) = QD-Y(WS-K) - 0.5
         COMPUTE WS-Z(WS-K) = QD-Z(WS-K) - 0.5
     END-PERFORM
     MOVE 0 TO WS-X(5) WS-Y(5) WS-Z(5) WS-X(6) WS-Y(6) WS-Z(6)
     IF QD-CULL > 0
         COMPUTE WS-X(5) = WS-VX(QD-CULL) - 1
         COMPUTE WS-Y(5) = WS-VY(QD-CULL) - 1
         COMPUTE WS-Z(5) = WS-VZ(QD-CULL) - 1
     END-IF
     COMPUTE WS-X(6) = WS-VX(QD-SHADE) - 1
     COMPUTE WS-Y(6) = WS-VY(QD-SHADE) - 1
     COMPUTE WS-Z(6) = WS-VZ(QD-SHADE) - 1
     PERFORM VARYING WS-A FROM 1 BY 1 UNTIL WS-A > 3
         EVALUATE WS-A
             WHEN 1
                 COMPUTE WS-TURNS = L-X / 90
             WHEN 2
                 COMPUTE WS-TURNS = L-Y / 90
             WHEN 3
                 COMPUTE WS-TURNS = L-Z / 90
         END-EVALUATE
         PERFORM VARYING WS-TURN FROM 1 BY 1 UNTIL WS-TURN > WS-TURNS
             PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 6
                 EVALUATE WS-A
                     WHEN 1
                         MOVE WS-Z(WS-K) TO WS-T
                         COMPUTE WS-Z(WS-K) = 0 - WS-Y(WS-K)
                         MOVE WS-T TO WS-Y(WS-K)
                     WHEN 2
                         MOVE WS-X(WS-K) TO WS-T
                         COMPUTE WS-X(WS-K) = 0 - WS-Z(WS-K)
                         MOVE WS-T TO WS-Z(WS-K)
                     WHEN 3
                         MOVE WS-Y(WS-K) TO WS-T
                         COMPUTE WS-Y(WS-K) = 0 - WS-X(WS-K)
                         MOVE WS-T TO WS-X(WS-K)
                 END-EVALUATE
             END-PERFORM
         END-PERFORM
     END-PERFORM
     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 4
         COMPUTE QD-X(WS-K) = WS-X(WS-K) + 0.5
         COMPUTE QD-Y(WS-K) = WS-Y(WS-K) + 0.5
         COMPUTE QD-Z(WS-K) = WS-Z(WS-K) + 0.5
     END-PERFORM
     PERFORM VARYING WS-D FROM 1 BY 1 UNTIL WS-D > 6
         IF QD-CULL > 0 AND WS-VX(WS-D) - 1 = WS-X(5) AND WS-VY(WS-D) - 1 = WS-Y(5)
                 AND WS-VZ(WS-D) - 1 = WS-Z(5)
             MOVE WS-D TO WS-K
         END-IF
         IF WS-VX(WS-D) - 1 = WS-X(6) AND WS-VY(WS-D) - 1 = WS-Y(6) AND WS-VZ(WS-D) - 1 = WS-Z(6)
             MOVE WS-D TO QD-SHADE
         END-IF
     END-PERFORM
     IF QD-CULL > 0
         MOVE WS-K TO QD-CULL
     END-IF
     GOBACK.
 END PROGRAM VARIANT-ROTATE.
