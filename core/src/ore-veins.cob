*> The large ore veins of the material rule (docs/protocol/11 section 3; T0434): the ore_vein rule of the material rule
*> minecraft:overworld (copper and iron, the members density, richness, filler_gap, ore_block, raw_ore_block, filler_block,
*> raw_ore_chance of the content's rule node: CHILD 1 to 3 the three functions, TEXT 1 to 3 the three block states, NUM 1 the
*> raw ore chance).
*>   ORE-VEIN-ROOTS USING job: adds to the job's interpolation grids the interpolated nodes the vein functions reach (the toggle and
*>     the two vein noises; the richness and the gap are read through the grids too where they have interpolated nodes), found from the
*>     ore_vein nodes of the material rule, wherever they sit in it (GEN-JOB-START).
*>   ORE-VEIN-RULE USING job, rule node (an ore_vein), state out (-1: no block, the next rule runs): 11 section 3.2 at the block
*>     position SC-X, SC-Y, SC-Z of the surface context. d = density at the block; d <= 0: nothing. The random source is the positional
*>     factory P.fromHashOf("minecraft:ore").forkPositional() at the block: float f1; f1 > d: nothing. Float f2; richness R and the gap G are
*>     read; f2 < R and G < 0: float f3, f3 < raw_ore_chance (a float) the raw ore block else the ore block; else the filler block.
*>     What a node remembers (SURFACE.cpy, per node): SF-N-STATE the ore block (-2 until the three states are looked up), SF-N-BIOME the
*>     raw ore block, SF-N-ANSWER the filler block, SF-N-VG-READY and SF-N-VG-LO/HI the positional factory.
*> The caller (SURFACE-RULE in surface.cob) keeps the evaluation of the grids: GEN-STAGE-SURFACE turns the grid mode on for the stage.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ORE-VEIN-ROOTS RECURSIVE.
*> USING job, rule node (0: the root of minecraft:overworld is looked up), depth (BINARY-LONG, 0 from the caller).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CTWORLDGEN.
 01 WS-KIND-RULE           BINARY-LONG VALUE 2.
 01 WS-DOMAIN              BINARY-LONG VALUE 2.
 01 WS-KEY-ROOT            PIC X(112) VALUE "minecraft:overworld".
 01 WS-READY               BINARY-LONG VALUE 0.
 01 WS-ROWS.
    05 WS-R-SEQUENCE       BINARY-LONG.
    05 WS-R-CONDITION      BINARY-LONG.
    05 WS-R-ORE-VEIN       BINARY-LONG.
 01 WS-NAME                PIC X(32).
 LOCAL-STORAGE SECTION.
 01 LS-NODE                BINARY-LONG.
 01 LS-I                   BINARY-LONG.
 01 LS-KEY                 PIC X(112).
 01 LS-ROOT                BINARY-LONG.
 01 LS-DEPTH               BINARY-LONG.
 LINKAGE SECTION.
 01 L-JOB.
    COPY GENJOB REPLACING LEADING ==GJ-== BY ==J-==.
 01 L-NODE                 BINARY-LONG.
 01 L-DEPTH                BINARY-LONG.
 PROCEDURE DIVISION USING L-JOB L-NODE L-DEPTH.
     IF WS-READY = 0
         MOVE "sequence" TO WS-NAME
         CALL "WG-TYPE-FIND" USING WS-DOMAIN WS-NAME WS-R-SEQUENCE
         MOVE "condition" TO WS-NAME
         CALL "WG-TYPE-FIND" USING WS-DOMAIN WS-NAME WS-R-CONDITION
         MOVE "ore_vein" TO WS-NAME
         CALL "WG-TYPE-FIND" USING WS-DOMAIN WS-NAME WS-R-ORE-VEIN
         MOVE 1 TO WS-READY
     END-IF
     MOVE L-NODE TO LS-NODE
     IF LS-NODE = 0
         CALL "WG-FIND" USING WS-KIND-RULE WS-KEY-ROOT LS-NODE
     END-IF
     IF LS-NODE = 0 OR L-DEPTH > 32
         GOBACK
     END-IF
     COMPUTE LS-DEPTH = L-DEPTH + 1
     EVALUATE TRUE
         WHEN WGN-TYPE(LS-NODE) = 0
             MOVE WGN-TEXT-1(LS-NODE)(1:112) TO LS-KEY
             CALL "WG-FIND" USING WS-KIND-RULE LS-KEY LS-ROOT
             IF LS-ROOT > 0
                 CALL "ORE-VEIN-ROOTS" USING L-JOB LS-ROOT LS-DEPTH
             END-IF
         WHEN WGN-TYPE(LS-NODE) = WS-R-SEQUENCE
             MOVE WGN-CHILD(LS-NODE, 1) TO LS-I
             PERFORM UNTIL LS-I = 0
                 CALL "ORE-VEIN-ROOTS" USING L-JOB LS-I LS-DEPTH
                 MOVE WGN-NEXT(LS-I) TO LS-I
             END-PERFORM
         WHEN WGN-TYPE(LS-NODE) = WS-R-CONDITION
             IF WGN-CHILD(LS-NODE, 2) > 0
                 CALL "ORE-VEIN-ROOTS" USING L-JOB WGN-CHILD(LS-NODE, 2) LS-DEPTH
             END-IF
         WHEN WGN-TYPE(LS-NODE) = WS-R-ORE-VEIN
             PERFORM VARYING LS-I FROM 1 BY 1 UNTIL LS-I > 3
                 IF WGN-CHILD(LS-NODE, LS-I) > 0
                     CALL "GEN-FIND-INTERP" USING WGN-CHILD(LS-NODE, LS-I) L-JOB
                 END-IF
             END-PERFORM
     END-EVALUATE
     GOBACK.
 END PROGRAM ORE-VEIN-ROOTS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ORE-VEIN-RULE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CTWORLDGEN.
 COPY DENSITY.
 COPY SURFACE.
 COPY XORO REPLACING ==XR-STATE== BY ==WS-FAC== LEADING ==XR-== BY ==WS-F-==.
 COPY XORO REPLACING ==XR-STATE== BY ==WS-R== LEADING ==XR-== BY ==WS-R-==.
 COPY XORO REPLACING ==XR-STATE== BY ==WS-HASHED== LEADING ==XR-== BY ==WS-H-==.
 01 WS-NAME                PIC X(64) VALUE "minecraft:ore".
 01 WS-NAME-LENGTH         BINARY-LONG VALUE 13.
 01 WS-KEY48               PIC X(48).
 01 WS-IGNORE              PIC X(160).
 01 WS-D                   FLOAT-LONG.
 01 WS-F1                  FLOAT-LONG.
 01 WS-F2                  FLOAT-LONG.
 01 WS-F3                  FLOAT-LONG.
 01 WS-RICH                FLOAT-LONG.
 01 WS-GAP                 FLOAT-LONG.
 01 WS-CHANCE              FLOAT-LONG.
 LINKAGE SECTION.
 01 L-JOB.
    COPY GENJOB REPLACING LEADING ==GJ-== BY ==J-==.
 01 L-NODE                 BINARY-LONG.
 01 L-STATE                BINARY-LONG.
 PROCEDURE DIVISION USING L-JOB L-NODE L-STATE.
     MOVE -1 TO L-STATE
     CALL "DENSITY-NODE" USING WGN-CHILD(L-NODE, 1) SC-X SC-Y SC-Z WS-D
     IF WS-D <= 0
         GOBACK
     END-IF
     IF SF-N-STATE(L-NODE) = -2
         UNSTRING WGN-TEXT-1(L-NODE) DELIMITED BY SPACE INTO WS-KEY48 WS-IGNORE
         CALL "GEN-BLOCK-STATE" USING WS-KEY48 SF-N-STATE(L-NODE)
         UNSTRING WGN-TEXT-2(L-NODE) DELIMITED BY SPACE INTO WS-KEY48 WS-IGNORE
         CALL "GEN-BLOCK-STATE" USING WS-KEY48 SF-N-BIOME(L-NODE)
         UNSTRING WGN-TEXT-3(L-NODE) DELIMITED BY SPACE INTO WS-KEY48 WS-IGNORE
         CALL "GEN-BLOCK-STATE" USING WS-KEY48 SF-N-ANSWER(L-NODE)
     END-IF
     IF SF-N-VG-READY(L-NODE) = 0
         CALL "XORO-FROM-HASH" USING DN-FACTORY WS-NAME WS-NAME-LENGTH WS-HASHED
         CALL "XORO-FORK-POSITIONAL" USING WS-HASHED WS-FAC
         MOVE WS-F-LO TO SF-N-VG-LO(L-NODE)
         MOVE WS-F-HI TO SF-N-VG-HI(L-NODE)
         MOVE 1 TO SF-N-VG-READY(L-NODE)
     END-IF
     MOVE SF-N-VG-LO(L-NODE) TO WS-F-LO
     MOVE SF-N-VG-HI(L-NODE) TO WS-F-HI
     CALL "XORO-AT" USING WS-FAC SC-X SC-Y SC-Z WS-R
     CALL "XORO-NEXT-FLOAT" USING WS-R WS-F1
     IF WS-F1 > WS-D
         GOBACK
     END-IF
     CALL "XORO-NEXT-FLOAT" USING WS-R WS-F2
     CALL "DENSITY-NODE" USING WGN-CHILD(L-NODE, 2) SC-X SC-Y SC-Z WS-RICH
     CALL "DENSITY-NODE" USING WGN-CHILD(L-NODE, 3) SC-X SC-Y SC-Z WS-GAP
     IF WS-F2 < WS-RICH AND WS-GAP < 0
         CALL "XORO-NEXT-FLOAT" USING WS-R WS-F3
         CALL STATIC "cc_f64_f32_round" USING BY REFERENCE WGN-NUM(L-NODE, 1) WS-CHANCE
         IF WS-F3 < WS-CHANCE
             MOVE SF-N-BIOME(L-NODE) TO L-STATE
         ELSE
             MOVE SF-N-STATE(L-NODE) TO L-STATE
         END-IF
     ELSE
         MOVE SF-N-ANSWER(L-NODE) TO L-STATE
     END-IF
     GOBACK.
 END PROGRAM ORE-VEIN-RULE.
