*> Entity models in the render path (docs/protocol/34-entity-models-1-shared-model-and-framework.md section 1.5 and 6, 34-7 sections
*> 1.1, 1.2 and 1.6; the model library client/src/entmodel-34-*.cob; the table is client/copy/CLMODELS.cpy).
*> ENTITY-MODEL-FIND maps an entity type key to its row of CL-MODELS (0 = no model). ENTITY-MODEL-BUILD builds the layer of a row
*> into an EMM-MODEL (client/copy/CLEMM.cpy) through the library of its family. ENTITY-MODEL-SLOTS gives every model the replica
*> shows a slot in the entity atlas (EA-MT, entities-render.cob ENTITY-ATLAS-BUILD) before the frame's vertices are made.
*> ENTITY-MODEL-EMIT appends the model of one replica row to RL-EN-VERTEX, eye-relative, 36 vertices (6 faces x 2 triangles) per
*> cuboid: the cached rest model is copied, the row's setupAnim program runs on the state the replica has (head pitch EN-PITCH,
*> head yaw relative to the body EN-HEAD-YAW - EN-YAW wrapped to -180..180; age and every other state are 0; the walk position and speed, the swing and the aggressive flag are the replica's, 54 sections 1 and 2), then every visible part (itself and all its ancestors visible) with cuboids is drawn: a corner of a cuboid (EF7-BOX-CORNERS
*> of 34-7 1.2: origin, size, grow, mirror) is carried up the part chain (scale, rotate X then Y then Z, translate by the part's
*> current pose, each ancestor in turn, then / 16: 34-7 1.1) and through the render sequence of 34-7 1.6 as EF7-SETUP-ROTATIONS lists
*> it (rotate about Y by 180 - body yaw degrees, scale (-1, -1, 1), translate (0, -1.501, 0); the last listed acts first), then moved
*> to the entity position. Each face takes its four corners from EF7-FACE-VERTS and its four texels from EF7-BOX-RECTS and
*> EF7-VERTEX-UV (the box unwrap of 34-7 1.2), mapped onto the model's atlas rectangle: u = (rect x + u x rect w) / atlas w. The quad
*> is the triangles 1 2 3 and 1 3 4 of the slots. Brightness as the stand-in boxes: the face's direction factor in world space (the model
*> flips y, so DOWN is the visible top 1.0, UP the bottom 0.5, WEST and EAST 0.6, NORTH and SOUTH 0.8) times max(sky light x daylight,
*> block light) / 15 of the entity's cell, at least 0.1; tint 1, 1, 1 and alpha 1. A cuboid that no longer fits the entity vertex
*> capacity is left out. The tilt of a dying entity (deathTime) is not drawn: the replica holds no death time.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ENTITY-MODEL-FIND.
*> USING entity type key (PIC X(24)), row of CL-MODELS out (BINARY-LONG, 0 = none).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLMODELS.
 01 WS-I                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-KEY                  PIC X(24).
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-KEY L-ROW.
     MOVE 0 TO L-ROW
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > CL-MODEL-COUNT
         IF CL-MD-KEY(WS-I) = L-KEY
             MOVE WS-I TO L-ROW
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM ENTITY-MODEL-FIND.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ENTITY-MODEL-BUILD.
*> USING model (EMM-MODEL), row of CL-MODELS, ok out (1 when the family's library built the layer).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLMODELS.
 01 WS-LAYER               PIC X(32).
 LINKAGE SECTION.
 COPY CLEMM.
 01 L-ROW                  BINARY-LONG.
 01 L-OK                   BINARY-LONG.
 PROCEDURE DIVISION USING EMM-MODEL L-ROW L-OK.
     MOVE CL-MD-LAYER(L-ROW) TO WS-LAYER
     MOVE 0 TO L-OK
     EVALUATE CL-MD-FAMILY(L-ROW)
         WHEN 2
             CALL "EMD-LAYER" USING EMM-MODEL WS-LAYER L-OK
         WHEN 3
             CALL "EM3-LAYER" USING EMM-MODEL WS-LAYER L-OK
         WHEN 4
             CALL "EF4-LAYER" USING EMM-MODEL WS-LAYER L-OK
         WHEN 5
             CALL "EF5-LAYER" USING EMM-MODEL WS-LAYER L-OK
         WHEN 6
             CALL "EF6-LAYER" USING EMM-MODEL WS-LAYER L-OK
         WHEN 7
             CALL "EF7-LAYER" USING EMM-MODEL WS-LAYER L-OK
         WHEN 9
             CALL "EF9-LAYER" USING EMM-MODEL WS-LAYER L-OK
         WHEN OTHER
             CALL "EF8-LAYER" USING EMM-MODEL WS-LAYER L-OK
     END-EVALUATE
     GOBACK.
 END PROGRAM ENTITY-MODEL-BUILD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CREEPER-SWELL.
*> USING CLIENT-STATE, replica row, swell out (FLOAT-LONG): the creeper's swell counter now (20 section 6.1: it runs 1 a tick, 50 ms, in the direction
*> EN-SWELL-DIR from its value EN-SWELL-BASE when the direction was set at EN-SWELL-MS; at least 0, at most 30 = maxSwell).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-ROW                  BINARY-LONG.
 01 L-SWELL                FLOAT-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-ROW L-SWELL.
     COMPUTE L-SWELL = EN-SWELL-BASE(L-ROW) + EN-SWELL-DIR(L-ROW) * (CL-NOW-MS - EN-SWELL-MS(L-ROW)) / 50
     COMPUTE L-SWELL = FUNCTION MAX(0, FUNCTION MIN(30, L-SWELL))
     GOBACK.
 END PROGRAM CREEPER-SWELL.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ENTITY-SLOT-ENSURE.
*> USING CLIENT-STATE, model row, texture code, new out (BINARY-LONG, set to 1 when a slot's image changed; never reset here): the atlas slot of the pair gets the
*> stamp of this pass; a pair that has none takes a free slot, or when the 64 are in use the slot least recently used (the lowest index of equal age) that no mob
*> drew in this pass; when every slot was drawn in this pass the pair is not given one (its mob is not drawn).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-S                   BINARY-LONG.
 01 WS-FOUND               BINARY-LONG.
 01 WS-OLD                 BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-MODEL                BINARY-LONG.
 01 L-TEX                  BINARY-LONG.
 01 L-NEW                  BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-MODEL L-TEX L-NEW.
     MOVE 0 TO WS-FOUND
     PERFORM VARYING WS-S FROM 1 BY 1 UNTIL WS-S > EA-MT-COUNT
         IF EA-MT-MODEL(WS-S) = L-MODEL AND EA-MT-TEX(WS-S) = L-TEX
             MOVE WS-S TO WS-FOUND
         END-IF
     END-PERFORM
     IF WS-FOUND > 0
         MOVE EA-MT-STAMP TO EA-MT-USED(WS-FOUND)
         GOBACK
     END-IF
     IF EA-MT-COUNT < 64
         ADD 1 TO EA-MT-COUNT
         MOVE EA-MT-COUNT TO WS-FOUND
     ELSE
         MOVE 0 TO WS-OLD
         PERFORM VARYING WS-S FROM 1 BY 1 UNTIL WS-S > 64
             IF EA-MT-USED(WS-S) < EA-MT-STAMP AND (WS-OLD = 0 OR EA-MT-USED(WS-S) < EA-MT-USED(WS-OLD))
                 MOVE WS-S TO WS-OLD
             END-IF
         END-PERFORM
         MOVE WS-OLD TO WS-FOUND
     END-IF
     IF WS-FOUND > 0
         MOVE L-MODEL TO EA-MT-MODEL(WS-FOUND)
         MOVE L-TEX TO EA-MT-TEX(WS-FOUND)
         MOVE EA-MT-STAMP TO EA-MT-USED(WS-FOUND)
         MOVE 1 TO L-NEW
     END-IF
     GOBACK.
 END PROGRAM ENTITY-SLOT-ENSURE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ENTITY-MODEL-SLOTS.
*> USING CLIENT-STATE: every used replica row with a model gets an atlas slot for its model and texture code, for its extra layer and for each overlay layer
*> (EA-MT, at most 64: ENTITY-SLOT-ENSURE; an overlay with a model of its own, the armor pieces, takes its slot for that model); the atlas is rebuilt once when a slot's image changed.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLMODELS.
 01 WS-R                   BINARY-LONG.
 01 WS-NEW                 BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-EM                  BINARY-LONG.
 01 WS-TEX                 BINARY-LONG.
 01 WS-OV                  BINARY-LONG.
 01 WS-OVR                 FLOAT-LONG.
 01 WS-OVG                 FLOAT-LONG.
 01 WS-OVB                 FLOAT-LONG.
 01 WS-OVM                 BINARY-LONG.
 01 WS-PLAYER-KEY          PIC X(24).
 COPY CLCONST.
 COPY CONTENT.
 LINKAGE SECTION.
 COPY CLSTATE.
 PROCEDURE DIVISION USING CLIENT-STATE.
     MOVE 0 TO WS-NEW
     ADD 1 TO EA-MT-STAMP
     PERFORM VARYING WS-R FROM 1 BY 1 UNTIL WS-R > EN-COUNT
         IF EN-USED(WS-R) = 1 AND EN-MODEL(WS-R) > 0 AND CL-MD-ANIM(EN-MODEL(WS-R)) NOT = "F"
*>           A baby of a type with a baby row is drawn from that row (CL-MD-BABY).
             CALL "ENTITY-MODEL-ROW" USING CLIENT-STATE WS-R WS-EM
             CALL "ENTITY-TEX-CODE" USING CLIENT-STATE WS-R WS-EM WS-TEX
             CALL "ENTITY-SLOT-ENSURE" USING CLIENT-STATE WS-EM WS-TEX WS-NEW
*>           The extra layer of the row's model (the sheep's wool) has its own slot.
             MOVE CL-MD-EXTRA(WS-EM) TO WS-X
             IF WS-X > 0
                 CALL "ENTITY-TEX-CODE" USING CLIENT-STATE WS-R WS-X WS-TEX
                 CALL "ENTITY-SLOT-ENSURE" USING CLIENT-STATE WS-X WS-TEX WS-NEW
             END-IF
*>           The banners the mob holds (hand-banner.cob).
             CALL "ENTITY-BANNER-SLOTS" USING CLIENT-STATE WS-R WS-NEW
             CALL "ENTITY-SHIELD-SLOTS" USING CLIENT-STATE WS-R WS-NEW
*>           The overlay layers (ENTITY-OVERLAY) draw the model again with a texture of their own.
             PERFORM VARYING WS-OV FROM 1 BY 1 UNTIL WS-OV > 12
                 CALL "ENTITY-OVERLAY" USING CLIENT-STATE WS-R WS-OV WS-TEX WS-OVR WS-OVG WS-OVB WS-OVM
                 IF WS-TEX > 0 AND WS-OVM = 0
                     CALL "ENTITY-SLOT-ENSURE" USING CLIENT-STATE WS-EM WS-TEX WS-NEW
                 END-IF
                 IF WS-TEX > 0 AND WS-OVM > 0
                     CALL "ENTITY-SLOT-ENSURE" USING CLIENT-STATE WS-OVM WS-TEX WS-NEW
                 END-IF
             END-PERFORM
         END-IF
     END-PERFORM
*>   The images of the shulker boxes in the replica (shulker-box.cob).
     CALL "SHULKER-SLOTS" USING CLIENT-STATE WS-NEW
*>   The image of the crystal beam (34-7 8.7) for a crystal with a beam target and a dragon with a nearest crystal.
     PERFORM VARYING WS-R FROM 1 BY 1 UNTIL WS-R > EN-COUNT
         IF EN-USED(WS-R) = 1 AND ((EN-KEY(WS-R) = "end_crystal" AND EN-BP(WS-R) = 1) OR (EN-KEY(WS-R) = "ender_dragon" AND EN-NCI(WS-R) NOT = 0))
             MOVE "end_crystal_beam" TO WS-PLAYER-KEY
             CALL "ENTITY-MODEL-FIND" USING WS-PLAYER-KEY WS-EM
             MOVE 0 TO WS-TEX
             CALL "ENTITY-SLOT-ENSURE" USING CLIENT-STATE WS-EM WS-TEX WS-NEW
         END-IF
     END-PERFORM
*>   The image of a guardian's beam (34-6 11.6, entities-beam.cob) for every guardian that has an attack target.
     PERFORM VARYING WS-R FROM 1 BY 1 UNTIL WS-R > EN-COUNT
         IF EN-USED(WS-R) = 1 AND (EN-KEY(WS-R) = "guardian" OR "elder_guardian") AND EN-TGT(WS-R) NOT = 0
             MOVE "guardian_beam" TO WS-PLAYER-KEY
             CALL "ENTITY-MODEL-FIND" USING WS-PLAYER-KEY WS-EM
             MOVE 0 TO WS-TEX
             CALL "ENTITY-SLOT-ENSURE" USING CLIENT-STATE WS-EM WS-TEX WS-NEW
         END-IF
     END-PERFORM
*>   The first-person arm of an empty main hand (12 section 6.5, hand-arm.cob) wears the model row "player" with its own image: its slot, in a standard world on the world screen.
     IF CL-CAMERA = 0 AND SM-SCREEN = SCR-WORLD AND CT-OPEN = 1 AND CT-SET-TYPE NOT = CT-TYPE-COBOLCRAFT
         MOVE "player" TO WS-PLAYER-KEY
         CALL "ENTITY-MODEL-FIND" USING WS-PLAYER-KEY WS-EM
         MOVE 0 TO WS-TEX
         CALL "ENTITY-SLOT-ENSURE" USING CLIENT-STATE WS-EM WS-TEX WS-NEW
         CALL "HAND-BANNER-SLOTS" USING CLIENT-STATE WS-NEW
         CALL "HAND-SHIELD-SLOTS" USING CLIENT-STATE WS-NEW
     END-IF
     IF WS-NEW = 1
         CALL "ENTITY-ATLAS-BUILD" USING CLIENT-STATE
     END-IF
     GOBACK.
 END PROGRAM ENTITY-MODEL-SLOTS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ENTITY-MODEL-EMIT.
*> USING CLIENT-STATE, replica row (with EN-MODEL > 0), eye (3 FLOAT-LONG): appends the row's model to RL-EN-VERTEX.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLCONST.
 COPY CLMODELS.
 COPY CLEMM.
*> The models built so far, one per row of CL-MODELS (EMM-MODEL is 36660 bytes).
 01 WS-CACHE.
    05 WS-CM               PIC X(36700) OCCURS 260 TIMES.
 01 WS-HAVE-TABLE.
    05 WS-HAVE             PIC 9 OCCURS 260 TIMES VALUE 0.
 01 WS-ROW                 BINARY-LONG.
 01 WS-TEXC                BINARY-LONG.
 01 WS-TR                  FLOAT-LONG.
 01 WS-TG                  FLOAT-LONG.
 01 WS-TB                  FLOAT-LONG.
 01 WS-VCOUNT               BINARY-LONG.
 01 WS-VLIMIT               BINARY-LONG.
 01 WS-TRS                 FLOAT-SHORT.
 01 WS-TGS                 FLOAT-SHORT.
 01 WS-TBS                 FLOAT-SHORT.
 01 WS-OK                  BINARY-LONG.
 01 WS-SLOT                BINARY-LONG.
 01 WS-S                   BINARY-LONG.
 01 WS-IN.
    05 WS-I                FLOAT-LONG OCCURS 16 TIMES.
 01 WS-STATE.
    05 WS-ST               FLOAT-LONG OCCURS 48 TIMES.
 01 WS-VARIANT             BINARY-LONG.
 01 WS-D                   FLOAT-LONG.
*> The render sequence (EF7-SETUP-ROTATIONS) and its rotations' sines and cosines.
 01 WS-SR-IN.
    05 WS-SRI              FLOAT-LONG OCCURS 16 TIMES.
 01 WS-SR-OUT.
    05 WS-SRO              FLOAT-LONG OCCURS 64 TIMES.
 01 WS-OPS.
    05 WS-OP OCCURS 8 TIMES.
       10 WS-OP-SIN        FLOAT-LONG.
       10 WS-OP-COS        FLOAT-LONG.
 01 WS-NOPS                BINARY-LONG.
 01 WS-OB                  BINARY-LONG.
 01 WS-OD                  BINARY-LONG.
 01 WS-Q-SWIM              BINARY-LONG.
*> Per part: visibility and the sines and cosines of its current rotation about x, y, z.
 01 WS-PARTS.
    05 WS-PT OCCURS 40 TIMES.
       10 WS-SA            FLOAT-LONG OCCURS 3 TIMES.
       10 WS-CA            FLOAT-LONG OCCURS 3 TIMES.
 01 WS-VIS-TABLE.
    05 WS-VIS              PIC 9 OCCURS 41 TIMES.
 01 WS-PART-NO             BINARY-LONG.
 01 WS-ANG                 FLOAT-LONG OCCURS 3 TIMES.
 01 WS-P                   BINARY-LONG.
 01 WS-C                   BINARY-LONG.
 01 WS-A                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-F                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-NODE                BINARY-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-T                   FLOAT-LONG.
 01 WS-LIGHT               FLOAT-LONG.
 01 WS-DARK                BINARY-LONG.
 01 WS-GL-INS.
    05 WS-GL-IN            FLOAT-LONG OCCURS 16 TIMES.
 01 WS-GL-OUTS.
    05 WS-GL-OUT           FLOAT-LONG OCCURS 64 TIMES.
 01 WS-BRIGHT              FLOAT-LONG.
 01 WS-SWELL               FLOAT-LONG.
 01 WS-KSWELL              FLOAT-LONG.
 01 WS-FSW                 FLOAT-LONG.
 01 WS-C4                  FLOAT-LONG.
 01 WS-HOOK-X              FLOAT-LONG.
 01 WS-HOOK-Y              FLOAT-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CY                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-STATE-ID            BINARY-LONG.
 01 WS-SKY                 BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
*> A cuboid: its box (EF7-BOX-CORNERS IN/OUT), unwrap rectangles (EF7-BOX-RECTS), face corners and texel pick.
 01 WS-BOX-IN.
    05 WS-BI               FLOAT-LONG OCCURS 16 TIMES.
 01 WS-BOX-OUT.
    05 WS-BO               FLOAT-LONG OCCURS 64 TIMES.
 01 WS-RC-IN.
    05 WS-RI               FLOAT-LONG OCCURS 16 TIMES.
 01 WS-RC-OUT.
    05 WS-RO               FLOAT-LONG OCCURS 64 TIMES.
 01 WS-FV-IN.
    05 WS-FI               FLOAT-LONG OCCURS 16 TIMES.
 01 WS-FV-OUT.
    05 WS-FO               FLOAT-LONG OCCURS 64 TIMES.
 01 WS-UV-IN.
    05 WS-UI               FLOAT-LONG OCCURS 16 TIMES.
 01 WS-UV-OUT.
    05 WS-UO               FLOAT-LONG OCCURS 64 TIMES.
*> The eight corners A..H in the eye-relative world, the four vertices of the face being made.
 01 WS-WORLD.
    05 WS-WC OCCURS 8 TIMES.
       10 WS-WX            FLOAT-SHORT.
       10 WS-WY            FLOAT-SHORT.
       10 WS-WZ            FLOAT-SHORT.
 01 WS-QUAD.
    05 WS-Q OCCURS 4 TIMES.
       10 WS-QX            FLOAT-SHORT.
       10 WS-QY            FLOAT-SHORT.
       10 WS-QZ            FLOAT-SHORT.
       10 WS-QU            FLOAT-SHORT.
       10 WS-QV            FLOAT-SHORT.
 01 WS-FACTOR-DATA.
    05 FILLER PIC 9V9 VALUE 1.0.
    05 FILLER PIC 9V9 VALUE 0.5.
    05 FILLER PIC 9V9 VALUE 0.6.
    05 FILLER PIC 9V9 VALUE 0.8.
    05 FILLER PIC 9V9 VALUE 0.6.
    05 FILLER PIC 9V9 VALUE 0.8.
 01 WS-FACTOR-TABLE REDEFINES WS-FACTOR-DATA.
    05 WS-FACTOR           PIC 9V9 OCCURS 6 TIMES.
 01 WS-ORDER-DATA          PIC X(6) VALUE "123134".
 01 WS-ORDER REDEFINES WS-ORDER-DATA.
    05 WS-ORD              PIC 9 OCCURS 6 TIMES.
 01 WS-N                   BINARY-LONG.
*> What EF7-FACE-VERTS and EF7-VERTEX-UV answer, as binary tables made by calling them once (a float compared with a literal or turned into an integer costs a
*> quarter of a microsecond in libcob, and a cuboid asks 6 and 24 times): the corner of each of the 4 slots of a face (face 0 to 5, mirror 0 or 1) and, for each
*> slot of the quad (0 to 3), which of the rectangle's four numbers is its u and which its v.
 01 WS-TABLES-READY        BINARY-LONG VALUE 0.
 01 WS-FACE-CORNER-TABLE.
    05 WS-FCF OCCURS 6 TIMES.
       10 WS-FCM OCCURS 2 TIMES.
          15 WS-FC         BINARY-LONG OCCURS 4 TIMES.
 01 WS-UV-PICK-TABLE.
    05 WS-UVP OCCURS 4 TIMES.
       10 WS-UVP-U         BINARY-LONG.
       10 WS-UVP-V         BINARY-LONG.
 01 WS-FZERO               FLOAT-LONG VALUE 0.
 01 WS-FAR-SQUARED         FLOAT-LONG VALUE 4096.
 01 WS-OPCODES.
    05 WS-OPC              BINARY-LONG OCCURS 8 TIMES.
 01 WS-SLOT-INDEX          BINARY-LONG.
 01 WS-MIRROR              BINARY-LONG.
 01 WS-PICK                BINARY-LONG.
*> The baked mesh of each replica row, entity-relative (the pose changes with the walk state, the swing and the aggressive flag, which are in the key), kept with the key it was baked for: the cost of a frame is then a copy of the vertices with the offset to the eye
*> (lane resume T5820: baking 70 mobs each frame took 340 ms in a debug build).
 01 WS-BAKED.
    05 WS-BK OCCURS 768 TIMES.
       10 WS-BK-KEY.
          15 WS-BK-KF          FLOAT-LONG OCCURS 37 TIMES VALUE 0.
       10 WS-BK-N             BINARY-LONG VALUE 0.
       10 WS-BK-NC            BINARY-LONG VALUE 0.
       10 WS-BK-HR            BINARY-LONG VALUE 0.
       10 WS-BK-HL            BINARY-LONG VALUE 0.
       10 WS-BK-HFR.
          15 WS-BK-HFRV        FLOAT-LONG OCCURS 6 TIMES VALUE 0.
       10 WS-BK-HFL.
          15 WS-BK-HFLV        FLOAT-LONG OCCURS 6 TIMES VALUE 0.
       10 WS-BK-OK            BINARY-LONG VALUE 0.
       10 WS-BK-OFX           FLOAT-LONG VALUE 0.
       10 WS-BK-OFY           FLOAT-LONG VALUE 0.
       10 WS-BK-OFZ           FLOAT-LONG VALUE 0.
       10 WS-BK-EC OCCURS 40 TIMES.
          15 WS-BK-ECP OCCURS 8 TIMES.
             20 WS-BK-ECX     FLOAT-SHORT.
             20 WS-BK-ECY     FLOAT-SHORT.
             20 WS-BK-ECZ     FLOAT-SHORT.
       10 WS-BK-CORNER OCCURS 40 TIMES.
          15 WS-BK-CP OCCURS 8 TIMES.
             20 WS-BK-CX      FLOAT-SHORT.
             20 WS-BK-CY      FLOAT-SHORT.
             20 WS-BK-CZ      FLOAT-SHORT.
       10 WS-BK-VK            BINARY-LONG OCCURS 1440 TIMES.
       10 WS-BK-V OCCURS 1440 TIMES.
          15 WS-BK-X          FLOAT-SHORT.
          15 WS-BK-Y          FLOAT-SHORT.
          15 WS-BK-Z          FLOAT-SHORT.
          15 WS-BK-U          FLOAT-SHORT.
          15 WS-BK-W          FLOAT-SHORT.
          15 WS-BK-B          FLOAT-SHORT.
          15 WS-BK-A          FLOAT-SHORT VALUE 1.
          15 WS-BK-SKY        FLOAT-SHORT VALUE 0.
          15 WS-BK-R          FLOAT-SHORT VALUE 1.
          15 WS-BK-G          FLOAT-SHORT VALUE 1.
          15 WS-BK-BLUE       FLOAT-SHORT VALUE 1.
 01 WS-POOL.
    05 WS-POOL-ROW         BINARY-LONG OCCURS 768 TIMES VALUE 0.
    05 WS-POOL-LAYER       BINARY-LONG OCCURS 768 TIMES VALUE 0.
 01 WS-INDEX-TABLE.
    05 WS-IX-ROW OCCURS 256 TIMES.
       10 WS-IX            BINARY-LONG OCCURS 10 TIMES VALUE 0.
 01 WS-NEXT                BINARY-LONG VALUE 0.
 01 WS-LA                  BINARY-LONG.
 01 WS-LB                  BINARY-LONG.
 01 WS-LC                  BINARY-LONG.
 01 WS-REUSE               BINARY-LONG.
 01 WS-KEY-NOW.
    05 WS-KN                  FLOAT-LONG OCCURS 37 TIMES.
 01 WS-HIT                 BINARY-LONG.
 01 WS-E                   BINARY-LONG.
 01 WS-E2                  BINARY-LONG.
 01 WS-BN                  BINARY-LONG.
 01 WS-V                   BINARY-LONG.
 01 WS-VW                  BINARY-LONG.
 01 WS-VA                  BINARY-LONG.
 01 WS-NC                  BINARY-LONG.
 01 WS-QJ                  BINARY-LONG OCCURS 4 TIMES.
 01 WS-EC.
    05 WS-ECP OCCURS 8 TIMES.
       10 WS-ECX           FLOAT-SHORT.
       10 WS-ECY           FLOAT-SHORT.
       10 WS-ECZ           FLOAT-SHORT.
 01 WS-WPOS                FLOAT-LONG.
 01 WS-WSPEED              FLOAT-LONG.
 01 WS-SWP                 FLOAT-LONG.
 01 WS-AGE                 FLOAT-LONG.
 01 WS-AH-IN.
    05 WS-AHI              FLOAT-LONG OCCURS 16 TIMES.
 01 WS-AH-OUT.
    05 WS-AHO              FLOAT-LONG OCCURS 64 TIMES.
 01 WS-CARRIED             BINARY-LONG.
 01 WS-CREEPY              BINARY-LONG.
 01 WS-SWT                 BINARY-LONG.
 01 WS-SWARM               BINARY-LONG.
 01 WS-AGG                 BINARY-LONG.
 01 WS-MAINARM             BINARY-LONG.
 01 WS-HSL                 BINARY-LONG.
 01 WS-BLOCKING            BINARY-LONG.
 01 WS-ANIM                PIC X.
 01 WS-POSE-KEY            PIC X(20).
 01 WS-FK                  PIC X(24).
 01 WS-FM                  BINARY-LONG.
 01 WS-HK                  BINARY-LONG.
 01 WS-HI                  BINARY-LONG.
 01 WS-HP.
    05 WS-HPV               FLOAT-LONG OCCURS 3 TIMES.
 01 WS-HA.
    05 WS-HAV               FLOAT-LONG OCCURS 3 TIMES.
 01 WS-FP                  FLOAT-LONG.
 01 WS-DOT                 FLOAT-LONG.
 01 WS-DY                  FLOAT-LONG.
 01 WS-OX                  FLOAT-LONG.
 01 WS-OY                  FLOAT-LONG.
 01 WS-OZ                  FLOAT-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-ROW                  BINARY-LONG.
 01 L-EYE-TABLE.
    05 L-EYE               FLOAT-LONG OCCURS 3 TIMES.
 PROCEDURE DIVISION USING CLIENT-STATE L-ROW L-EYE-TABLE.
     MOVE L-ROW TO WS-ROW
*>   Evoker fangs are not drawn before the bite (34-3 4.8: progress 0).
     IF EN-KEY(WS-ROW) = "evoker_fangs"
         CALL "ENTITY-FANGS-PROGRESS" USING CLIENT-STATE WS-ROW WS-FP
         IF WS-FP = 0
             GOBACK
         END-IF
     END-IF
     MOVE 0 TO WS-SLOT
     CALL "ENTITY-TEX-CODE" USING CLIENT-STATE WS-ROW EN-MODEL(WS-ROW) WS-TEXC
     PERFORM VARYING WS-S FROM 1 BY 1 UNTIL WS-S > EA-MT-COUNT
         IF EA-MT-MODEL(WS-S) = EN-MODEL(WS-ROW) AND EA-MT-TEX(WS-S) = WS-TEXC
             MOVE WS-S TO WS-SLOT
         END-IF
     END-PERFORM
     IF WS-SLOT = 0
         GOBACK
     END-IF
*>   Entities beyond 64 blocks (horizontally) are not drawn: a cap standing in for the entity distance rule (13 section 9.2 Entity Distance option, 34-1 7.1 shadow fade 16 blocks), which the docs do not give as a number (open).
     COMPUTE WS-D = (EN-X(WS-ROW) - L-EYE(1)) * (EN-X(WS-ROW) - L-EYE(1))
         + (EN-Z(WS-ROW) - L-EYE(3)) * (EN-Z(WS-ROW) - L-EYE(3))
     IF WS-D > WS-FAR-SQUARED
         GOBACK
     END-IF
*>   The light of the entity's cell.
     COMPUTE WS-CX = FUNCTION INTEGER(EN-X(WS-ROW))
     COMPUTE WS-CY = FUNCTION INTEGER(EN-Y(WS-ROW))
     COMPUTE WS-CZ = FUNCTION INTEGER(EN-Z(WS-ROW))
     CALL "WORLD-CELL" USING CLIENT-STATE WS-CX WS-CY WS-CZ WS-STATE-ID WS-SKY WS-BLOCK
*>   A glow squid's block light (34-8 section 2.2, EF8-GLOW-LIGHT): from its dark ticks remaining, which fall 1 a tick from the value last set (a hit sets 100).
     IF EN-KEY(WS-ROW) = "glow_squid"
         COMPUTE WS-DARK = FUNCTION MAX(0, EN-DARK(WS-ROW) - FUNCTION INTEGER((CL-NOW-MS - EN-DARK-MS(WS-ROW)) / 50))
         MOVE WS-DARK TO WS-GL-IN(1)
         MOVE WS-BLOCK TO WS-GL-IN(2)
         CALL "EF8-GLOW-LIGHT" USING WS-GL-INS WS-GL-OUTS
         MOVE WS-GL-OUT(1) TO WS-BLOCK
     END-IF
     COMPUTE WS-LIGHT = FUNCTION MAX(WS-SKY * SK-U / 1000, WS-BLOCK) / 15
*>   The creeper's swell scale (34-6 2): k = swell / 28, f = 1 + sin(100 k) k / 100, c = clamp(k, 0, 1): x and z (1 + c^4 0.4) f, y (1 + c^4 0.1) / f.
     MOVE 1 TO WS-HOOK-X WS-HOOK-Y
*>   The setupAnim program of the row; an armor row (code A) is posed as the mob that wears it (its own row, or the baby row of a baby).
     MOVE CL-MD-ANIM(EN-MODEL(WS-ROW)) TO WS-ANIM
     IF WS-ANIM = "A" OR "E"
         MOVE EN-KEY(WS-ROW) TO WS-FK
         CALL "ENTITY-MODEL-FIND" USING WS-FK WS-FM
         IF WS-FM > 0 AND EN-BABY(WS-ROW) = 1 AND CL-MD-BABY(WS-FM) > 0
             MOVE CL-MD-BABY(WS-FM) TO WS-FM
         END-IF
         MOVE "-" TO WS-ANIM
         IF WS-FM > 0
             MOVE CL-MD-ANIM(WS-FM) TO WS-ANIM
         END-IF
     END-IF
*>   The key the pose program picks the mob by: the row's own, or the wearer's for an armor row.
     MOVE CL-MD-KEY(EN-MODEL(WS-ROW)) TO WS-POSE-KEY
     IF (CL-MD-ANIM(EN-MODEL(WS-ROW)) = "A" OR "E") AND WS-FM > 0
         MOVE CL-MD-KEY(WS-FM) TO WS-POSE-KEY
     END-IF
     IF CL-MD-ANIM(EN-MODEL(WS-ROW)) = "C"
         CALL "CREEPER-SWELL" USING CLIENT-STATE WS-ROW WS-SWELL
         COMPUTE WS-KSWELL = WS-SWELL / 28
         COMPUTE WS-FSW = 1 + FUNCTION SIN(WS-KSWELL * 100) * WS-KSWELL / 100
         COMPUTE WS-C4 = FUNCTION MIN(FUNCTION MAX(WS-KSWELL, 0), 1)
         COMPUTE WS-C4 = WS-C4 * WS-C4 * WS-C4 * WS-C4
         COMPUTE WS-HOOK-X = (1 + WS-C4 * 0.4) * WS-FSW
         COMPUTE WS-HOOK-Y = (1 + WS-C4 * 0.1) / WS-FSW
     END-IF
*>   The size of a slime or magma cube (Set Entity Data entry 18, 34-6 section 7: the scale (r x n, n / r, r x n) with squish 0 is n on every axis).
     IF EN-KEY(WS-ROW) = "slime" OR "magma_cube"
         CALL "ENTITY-CUBE-SCALE" USING CLIENT-STATE WS-ROW WS-HOOK-X WS-HOOK-Y
     END-IF
*>   An eyes layer (CL-MD-ANIM "Y": spider, cave spider and enderman eyes, 34-1 8.5): the posed model of its entity drawn once more with the eyes
*>   texture, full bright (brightness 1, no face shading). The eyes pipeline draws over its own body (depth GREATER_THAN_OR_EQUAL, no depth write, 34-1
*>   6.7); the opaque entity mesh has no such test, so the layer is enlarged by 0.3 percent about the entity origin to lie just outside the body.
     IF CL-MD-ANIM(EN-MODEL(WS-ROW)) = "Y" OR "E"
         MOVE 1.003 TO WS-HOOK-X WS-HOOK-Y
         MOVE 1 TO WS-LIGHT
     END-IF
*>   An overlay layer (ENTITY-OVERLAY, EN-OVL > 0): the model of the mob again, enlarged by 0.3 percent about the entity origin for each layer so that it
*>   lies over the body and the layers before it.
     IF EN-OVL(WS-ROW) > 0 AND EN-OVN(WS-ROW) <= 4
         COMPUTE WS-HOOK-X = WS-HOOK-X * (1 + 0.003 * EN-OVN(WS-ROW))
         COMPUTE WS-HOOK-Y = WS-HOOK-Y * (1 + 0.003 * EN-OVN(WS-ROW))
     END-IF
*>   The trim layers (9 to 12) lie over the armor piece (layers 5 to 8): the same enlargement by the layer's distance from the piece's own.
     IF EN-OVL(WS-ROW) > 0 AND EN-OVN(WS-ROW) >= 9
         COMPUTE WS-HOOK-X = WS-HOOK-X * (1 + 0.003 * (EN-OVN(WS-ROW) - 8))
         COMPUTE WS-HOOK-Y = WS-HOOK-Y * (1 + 0.003 * (EN-OVN(WS-ROW) - 8))
     END-IF
*>   The scale attribute (34-1 6.3 state.scale, Update Attributes): the whole model about the entity origin (a row nobody set has 0: no scale). A slime or magma cube takes its size from entry 18 instead.
     IF EN-ATTR-SCALE(WS-ROW) > 0 AND EN-ATTR-SCALE(WS-ROW) NOT = 1 AND NOT (EN-KEY(WS-ROW) = "slime" OR "magma_cube")
         COMPUTE WS-HOOK-X = WS-HOOK-X * EN-ATTR-SCALE(WS-ROW)
         COMPUTE WS-HOOK-Y = WS-HOOK-Y * EN-ATTR-SCALE(WS-ROW)
     END-IF
*>   The key of the bake: everything the mesh depends on besides the position.
     MOVE EN-MODEL(WS-ROW) TO WS-KN(1)
     MOVE WS-SLOT TO WS-KN(2)
     MOVE EN-YAW(WS-ROW) TO WS-KN(3)
     MOVE EN-HEAD-YAW(WS-ROW) TO WS-KN(4)
     MOVE EN-PITCH(WS-ROW) TO WS-KN(5)
     MOVE WS-HOOK-X TO WS-KN(6)
     MOVE WS-HOOK-Y TO WS-KN(7)
     MOVE WS-LIGHT TO WS-KN(8)
     MOVE EA-W TO WS-KN(9)
     MOVE EA-H TO WS-KN(10)
     MOVE EA-MT-X(WS-SLOT) TO WS-KN(11)
     MOVE EA-MT-Y(WS-SLOT) TO WS-KN(12)
     MOVE EA-MT-W(WS-SLOT) TO WS-KN(13)
     MOVE EA-MT-H(WS-SLOT) TO WS-KN(14)
     MOVE EN-POSE(WS-ROW) TO WS-KN(15)
     MOVE EN-SWIM(WS-ROW) TO WS-KN(16)
     COMPUTE WS-KN(24) = EN-SQ(WS-ROW) + EN-TA(WS-ROW) + EN-ARMA(WS-ROW)
     MOVE EN-TM(WS-ROW) TO WS-KN(29)
     COMPUTE WS-KN(34) = EN-CARRY(WS-ROW) * 10 + EN-CREEPY(WS-ROW)
     COMPUTE WS-KN(35) = EN-ATK(WS-ROW) * 1000 + EN-FLW(WS-ROW)
     MOVE 0 TO WS-KN(33)
     IF EN-KEY(WS-ROW) = "ender_dragon"
         MOVE EN-DR-HEAD TO WS-KN(33)
     END-IF
*>   A minecart's shift (34-9 3.2) is a function of its entity id.
     IF WS-ANIM = "M"
         MOVE EN-ID(WS-ROW) TO WS-KN(33)
     END-IF
*>   A player's skin parts decide which overlay cuboids the mesh holds.
     IF EN-KEY(WS-ROW) = "player"
         MOVE EN-PARTS(WS-ROW) TO WS-KN(33)
     END-IF
     COMPUTE WS-KN(36) = EN-AX-T(WS-ROW, 1) + EN-AX-T(WS-ROW, 2) * 11 + EN-AX-T(WS-ROW, 3) * 121 + EN-AX-T(WS-ROW, 4) * 1331
         + EN-AX-BS(WS-ROW) * 20000 + EN-AX-BT(WS-ROW) * 200000
     MOVE EN-XR(WS-ROW) TO WS-KN(25)
     MOVE EN-ZR(WS-ROW) TO WS-KN(26)
     MOVE EN-DRY(WS-ROW) TO WS-KN(27)
     COMPUTE WS-KN(28) = EN-FL(WS-ROW) * 2 + EN-FA(WS-ROW)
     COMPUTE WS-KN(30) = EN-BHT(WS-ROW) * 3 + EN-BHD(WS-ROW)
     MOVE EN-BDM(WS-ROW) TO WS-KN(31)
     COMPUTE WS-KN(32) = EN-BBA(WS-ROW) + EN-BUW(WS-ROW) * 100
*>   The walk animation, the swing and the aggressive pose of the models that read them (54 sections 1 and 2; the animation programs of the
*>   table's codes Q, C, Z, K, D, P, G and H): the walk position and speed as the renderer reads them, the swing progress, its type and arm, the
*>   aggressive flag (bit 4 of the mob flags) and the main arm (bit 2: left-handed). Models of another code do not depend on them.
     MOVE 0 TO WS-WPOS WS-WSPEED WS-SWP WS-AGE
     MOVE 0 TO WS-SWT WS-SWARM WS-AGG
     MOVE 1 TO WS-MAINARM
     IF WS-ANIM = "Q" OR "C" OR "Z" OR "K" OR "D" OR "P" OR "G" OR "H" OR "N"
             OR CL-MD-KEY(EN-MODEL(WS-ROW)) = "spider" OR "cave_spider" OR "spider_eyes" OR "cave_spider_eyes" OR "wolf" OR "chicken"
             OR "blaze" OR "enderman" OR "enderman_eyes"
             OR WS-ANIM = "W" OR "V" OR "R"
         CALL "ENTITY-WALK-VALUES" USING CLIENT-STATE WS-ROW WS-WPOS WS-WSPEED
*>       ageInTicks only matters to the humanoids (arm bob, zombie arm sway): the others keep a constant key.
         IF WS-ANIM = "Z" OR "K" OR "D" OR "P" OR "G" OR "H"
                 OR CL-MD-KEY(EN-MODEL(WS-ROW)) = "blaze" OR "enderman" OR "enderman_eyes"
                 OR WS-ANIM = "V" OR "N" OR "R"
             MOVE EN-AGE(WS-ROW) TO WS-AGE
         END-IF
         DIVIDE EN-MOB-FLAGS(WS-ROW) BY 4 GIVING WS-OB
         IF FUNCTION MOD(WS-OB, 2) = 1
             MOVE 1 TO WS-AGG
         END-IF
         DIVIDE EN-MOB-FLAGS(WS-ROW) BY 2 GIVING WS-OB
         IF FUNCTION MOD(WS-OB, 2) = 1
             MOVE 2 TO WS-MAINARM
         END-IF
         IF EN-SW-ACTIVE(WS-ROW) = 1 AND EN-SW-TYPE(WS-ROW) > 0 AND EN-SW-ANIM(WS-ROW) > 0
             MOVE EN-SW-ANIM(WS-ROW) TO WS-SWP
             MOVE EN-SW-TYPE(WS-ROW) TO WS-SWT
             IF EN-SW-HAND(WS-ROW) = 0
                 MOVE WS-MAINARM TO WS-SWARM
             ELSE
                 COMPUTE WS-SWARM = 3 - WS-MAINARM
             END-IF
         END-IF
     END-IF
*>   An armadillo that is not idle animates with its age (34-5 10.3: roll-up, roll-out and peek start ticks count from it).
     IF EN-KEY(WS-ROW) = "armadillo" AND EN-ARMA(WS-ROW) > 0
         MOVE EN-AGE(WS-ROW) TO WS-AGE
     END-IF
*>   A boat (code B): the rowing time of each paddle (7.3 getRowingTime at partial 1): the paddle position while the paddle is held, else 0 (the replica keeps the
*>   left position in EN-WALK-POS, the right in EN-WALK-SPEED, the held flags in EN-X1 and EN-X2).
     IF WS-ANIM = "B"
         MOVE 0 TO WS-WPOS WS-WSPEED
         IF EN-X1(WS-ROW) = 1
             MOVE EN-WALK-POS(WS-ROW) TO WS-WPOS
         END-IF
         IF EN-X2(WS-ROW) = 1
             MOVE EN-WALK-SPEED(WS-ROW) TO WS-WSPEED
         END-IF
     END-IF
     MOVE WS-WPOS TO WS-KN(17)
     MOVE WS-WSPEED TO WS-KN(18)
     MOVE WS-SWP TO WS-KN(19)
     MOVE WS-AGE TO WS-KN(22)
*>   The corals of the warm zombie nautilus are hidden under body armor (34-8 6.4): the key holds whether body armor is worn.
     MOVE 0 TO WS-KN(23)
     IF EN-EQ(WS-ROW, 7) > 0
         MOVE 1 TO WS-KN(23)
     END-IF
     COMPUTE WS-KN(20) = WS-SWT * 10 + WS-SWARM
     COMPUTE WS-KN(21) = WS-AGG * 10 + WS-MAINARM
*>   What the hands hold decides the arm poses of a player and whether the arm frames are kept for the held items (a shield blocking is another pose): empty or not per hand, blocking per hand.
     MOVE 0 TO WS-KN(37)
     PERFORM VARYING WS-HSL FROM 1 BY 1 UNTIL WS-HSL > 2
         IF EN-EQ(WS-ROW, WS-HSL) > 0
             COMPUTE WS-KN(37) = WS-KN(37) + WS-HSL
             CALL "ENTITY-BLOCKING" USING CLIENT-STATE WS-ROW WS-HSL WS-BLOCKING
             IF WS-BLOCKING = 1
                 COMPUTE WS-KN(37) = WS-KN(37) + 4 * WS-HSL
             END-IF
         END-IF
     END-PERFORM
*>   Every layer of a row keeps its own baked mesh in a pool (768 entries, recycled in turn when it is full): layer 1 the model, 2 the extra layer (the second
*>   model of the same entity), 2 + n the overlay layer n. The entry whose key is the key is used; else the layer's own entry is baked again.
     MOVE 0 TO WS-HIT WS-E
     IF EN-OVL(WS-ROW) > 0 AND EN-OVN(WS-ROW) >= 1 AND EN-OVN(WS-ROW) <= 8
         COMPUTE WS-LA = EN-OVN(WS-ROW) + 2
         MOVE WS-LA TO WS-LB WS-LC
     ELSE
         MOVE 1 TO WS-LA
         MOVE 2 TO WS-LB
         MOVE 1 TO WS-LC
     END-IF
     IF WS-IX(WS-ROW, WS-LA) > 0
         IF WS-BK-KEY(WS-IX(WS-ROW, WS-LA)) = WS-KEY-NOW AND WS-BK-N(WS-IX(WS-ROW, WS-LA)) > 0
             MOVE 1 TO WS-HIT
             MOVE WS-IX(WS-ROW, WS-LA) TO WS-E
         END-IF
     END-IF
     IF WS-HIT = 0 AND WS-LB NOT = WS-LA AND WS-IX(WS-ROW, WS-LB) > 0
         IF WS-BK-KEY(WS-IX(WS-ROW, WS-LB)) = WS-KEY-NOW AND WS-BK-N(WS-IX(WS-ROW, WS-LB)) > 0
             MOVE 1 TO WS-HIT
             MOVE WS-IX(WS-ROW, WS-LB) TO WS-E
         END-IF
     END-IF
     IF WS-HIT = 0
*>       The model of the row's entry 1 is the model's; another model (the extra layer) takes entry 2.
         IF WS-LA = 1 AND WS-IX(WS-ROW, 1) > 0
             IF WS-BK-KF(WS-IX(WS-ROW, 1), 1) NOT = WS-KN(1) AND WS-BK-N(WS-IX(WS-ROW, 1)) > 0
                 MOVE 2 TO WS-LC
             END-IF
         END-IF
         IF WS-IX(WS-ROW, WS-LC) = 0
             ADD 1 TO WS-NEXT
             IF WS-NEXT > 768
                 MOVE 1 TO WS-NEXT
             END-IF
             IF WS-POOL-ROW(WS-NEXT) > 0
                 MOVE 0 TO WS-IX(WS-POOL-ROW(WS-NEXT), WS-POOL-LAYER(WS-NEXT))
             END-IF
             MOVE WS-ROW TO WS-POOL-ROW(WS-NEXT)
             MOVE WS-LC TO WS-POOL-LAYER(WS-NEXT)
             MOVE WS-NEXT TO WS-IX(WS-ROW, WS-LC)
             MOVE 0 TO WS-BK-N(WS-NEXT)
         END-IF
         MOVE WS-IX(WS-ROW, WS-LC) TO WS-E
     END-IF
     IF WS-HIT = 0 AND WS-TABLES-READY = 0
         PERFORM VARYING WS-F FROM 0 BY 1 UNTIL WS-F > 5
             PERFORM VARYING WS-MIRROR FROM 0 BY 1 UNTIL WS-MIRROR > 1
                 MOVE WS-F TO WS-FI(1)
                 MOVE WS-MIRROR TO WS-FI(2)
                 CALL "EF7-FACE-VERTS" USING WS-FV-IN WS-FV-OUT
                 PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 4
                     COMPUTE WS-FC(WS-F + 1, WS-MIRROR + 1, WS-K) = WS-FO(WS-K)
                 END-PERFORM
             END-PERFORM
         END-PERFORM
         PERFORM VARYING WS-SLOT-INDEX FROM 0 BY 1 UNTIL WS-SLOT-INDEX > 3
             MOVE WS-SLOT-INDEX TO WS-UI(1)
             MOVE 1 TO WS-UI(2)
             MOVE 2 TO WS-UI(3)
             MOVE 3 TO WS-UI(4)
             MOVE 4 TO WS-UI(5)
             CALL "EF7-VERTEX-UV" USING WS-UV-IN WS-UV-OUT
             COMPUTE WS-UVP-U(WS-SLOT-INDEX + 1) = WS-UO(1)
             COMPUTE WS-UVP-V(WS-SLOT-INDEX + 1) = WS-UO(2)
         END-PERFORM
         MOVE 1 TO WS-TABLES-READY
     END-IF
     IF WS-HIT = 0
         ADD 1 TO RL-EN-BAKES
         MOVE 0 TO WS-BN WS-NC
         MOVE 0 TO WS-BK-OK(WS-E)
         MOVE 0 TO WS-BK-HR(WS-E) WS-BK-HL(WS-E)
*>   The model: built once per row of the table, then copied.
     MOVE EN-MODEL(WS-ROW) TO WS-K
     IF WS-HAVE(WS-K) = 0
         CALL "ENTITY-MODEL-BUILD" USING EMM-MODEL WS-K WS-OK
         MOVE EMM-MODEL TO WS-CM(WS-K)
         MOVE 1 TO WS-HAVE(WS-K)
     ELSE
         MOVE WS-CM(WS-K)(1:36660) TO EMM-MODEL
     END-IF
*>   setupAnim with the replica's state: x rotation = pitch, y rotation = head yaw relative to the body, wrapped.
     MOVE 0 TO WS-J
     PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > 16
         MOVE 0 TO WS-I(WS-J)
     END-PERFORM
     PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > 48
         MOVE 0 TO WS-ST(WS-J)
     END-PERFORM
     COMPUTE WS-D = EN-HEAD-YAW(WS-ROW) - EN-YAW(WS-ROW)
     COMPUTE WS-D = WS-D - 360 * FUNCTION INTEGER((WS-D + 180) / 360)
     MOVE EN-PITCH(WS-ROW) TO WS-I(1) WS-ST(1)
     MOVE WS-D TO WS-I(2) WS-ST(2)
     MOVE 1 TO WS-ST(5) WS-ST(12) WS-ST(13) WS-ST(22)
     MOVE WS-WPOS TO WS-I(3) WS-ST(3)
     MOVE WS-WSPEED TO WS-I(4) WS-ST(4)
     MOVE WS-SWP TO WS-ST(7)
     MOVE WS-AGE TO WS-ST(6)
     MOVE WS-SWT TO WS-ST(20)
     MOVE WS-SWARM TO WS-ST(21)
     MOVE WS-AGG TO WS-ST(18)
     MOVE WS-MAINARM TO WS-ST(13)
*>   Extra inputs of ENTITY-POSE-MORE: 16 the squid's tentacle angle, 15 the dry flag of an aquatic mob.
     MOVE EN-TA(WS-ROW) TO WS-I(16)
     MOVE EN-DRY(WS-ROW) TO WS-I(15)
     MOVE EN-TM(WS-ROW) TO WS-I(14)
     MOVE EN-ATK(WS-ROW) TO WS-I(13)
     MOVE EN-FLW(WS-ROW) TO WS-I(12)
*>   The armadillo's inputs of ENTITY-POSE-MORE: 12 hiding in the shell (shouldHideInShell of the state and inStateTicks), 13 the roll-out, 14 the roll-up and
*>   15 the peek start tick (-2147483648 is stopped).
     IF EN-KEY(WS-ROW) = "armadillo"
         MOVE EN-ARMA(WS-ROW) TO WS-AHI(1)
         MOVE EN-ARMA-TICKS(WS-ROW) TO WS-AHI(2)
         CALL "EF5-ARMADILLO-HIDE" USING WS-AH-IN WS-AH-OUT
         MOVE WS-AHO(1) TO WS-I(12)
         MOVE EN-ARMA-OUT(WS-ROW) TO WS-I(13)
         MOVE EN-ARMA-UP(WS-ROW) TO WS-I(14)
         MOVE EN-ARMA-PEEK(WS-ROW) TO WS-I(15)
     END-IF
*>   An axolotl's animator factors at the partial tick 1 (34-8 4.5): 8 playing dead, 9 in water, 10 on the ground, 11 moving.
     IF EN-KEY(WS-ROW) = "axolotl"
         MOVE EN-AX-BS(WS-ROW) TO WS-I(5)
         MOVE EN-AX-BT(WS-ROW) TO WS-I(6)
         MOVE 1 TO WS-FP
         PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > 4
             CALL "EF8-BINARY-FACTOR" USING EN-AX-T(WS-ROW, WS-J) EN-AX-O(WS-ROW, WS-J) WS-FP WS-I(WS-J + 7)
         END-PERFORM
     END-IF
     EVALUATE WS-ANIM
         WHEN "Q"
             CALL "EF4-COW-ANIM" USING EMM-MODEL WS-IN
         WHEN "C"
             CALL "EF6-CREEPER-ANIM" USING EMM-MODEL WS-IN
         WHEN "Z"
             MOVE 1 TO WS-VARIANT
             CALL "EMD-ANIM" USING EMM-MODEL WS-STATE WS-VARIANT
         WHEN "K"
             MOVE 2 TO WS-VARIANT
             CALL "EMD-ANIM" USING EMM-MODEL WS-STATE WS-VARIANT
*>       Drowned (5), piglin and piglin brute (3), zombified piglin (4): the variants of 34-2 4.
         WHEN "D"
             MOVE 5 TO WS-VARIANT
             CALL "EMD-ANIM" USING EMM-MODEL WS-STATE WS-VARIANT
         WHEN "P"
             MOVE 3 TO WS-VARIANT
             MOVE 5 TO WS-ST(25)
             CALL "EMD-ANIM" USING EMM-MODEL WS-STATE WS-VARIANT
         WHEN "G"
             MOVE 4 TO WS-VARIANT
             CALL "EMD-ANIM" USING EMM-MODEL WS-STATE WS-VARIANT
*>       A player (the humanoid, variant 0): crouching in the pose 5 (53 section 1; 12 section 7.5 offsets).
         WHEN "N"
             MOVE WS-WPOS TO WS-I(3)
             MOVE WS-WSPEED TO WS-I(4)
             MOVE WS-AGE TO WS-I(5)
             MOVE 0 TO WS-I(6)
             IF EN-EQ(WS-ROW, 7) > 0
                 MOVE 1 TO WS-I(6)
             END-IF
             CALL "EF8-NAUTILUS-ANIM" USING EMM-MODEL WS-IN
         WHEN "B"
             MOVE WS-WPOS TO WS-I(3)
             MOVE WS-WSPEED TO WS-I(4)
             CALL "EF8-BOAT-ANIM" USING EMM-MODEL WS-IN
*>       The wind charge (34-9 6.1): the models turn with the age in ticks.
         WHEN "R"
             MOVE WS-AGE TO WS-I(1)
             CALL "EF9-WIND-ANIM" USING EMM-MODEL WS-IN
         WHEN "W"
         WHEN "V"
             CALL "ENTITY-POSE-MORE" USING EMM-MODEL WS-POSE-KEY WS-IN WS-AGE
         WHEN "H"
             MOVE 0 TO WS-VARIANT
             IF EN-POSE(WS-ROW) = 5
                 MOVE 1 TO WS-ST(10)
             END-IF
             MOVE EN-SWIM(WS-ROW) TO WS-ST(11)
*>           The arm poses (12 section 7.5): an arm that holds an item has the ITEM pose (1), a hand that blocks with a shield the BLOCK pose (2); the main hand is the main arm's.
             PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > 2
                 MOVE WS-J TO WS-HSL
                 IF WS-MAINARM = 2
                     COMPUTE WS-HSL = 3 - WS-J
                 END-IF
                 IF EN-EQ(WS-ROW, WS-HSL) > 0
                     MOVE 1 TO WS-ST(13 + WS-J)
                     CALL "ENTITY-BLOCKING" USING CLIENT-STATE WS-ROW WS-HSL WS-BLOCKING
                     IF WS-BLOCKING = 1
                         MOVE 2 TO WS-ST(13 + WS-J)
                     END-IF
                 END-IF
             END-PERFORM
             CALL "EMD-ANIM" USING EMM-MODEL WS-STATE WS-VARIANT
*>       The models of the codes - and Y whose animation takes only the walk state (a spider's eyes layer is posed like the spider): wolf (age scale 1),
*>       spider and cave spider, chicken (no flap), blaze (age), enderman and its eyes (the humanoid state, nothing carried, not creepy).
         WHEN OTHER
             EVALUATE CL-MD-KEY(WS-K)
                 WHEN "spider"
                 WHEN "cave_spider"
                 WHEN "spider_eyes"
                 WHEN "cave_spider_eyes"
                     CALL "EF6-SPIDER-ANIM" USING EMM-MODEL WS-IN
                 WHEN "wolf"
                     MOVE 1 TO WS-I(5)
                     CALL "EF5-WOLF-ANIM" USING EMM-MODEL WS-IN
                 WHEN "chicken"
                     CALL "EF4-CHICKEN-ANIM" USING EMM-MODEL WS-IN
*>               The ender dragon: flap time, the flight history at partial tick 1; not landing, not sitting.
                 WHEN "ender_dragon"
                 WHEN "ender_dragon_eyes"
                     MOVE EN-TM(WS-ROW) TO WS-I(1)
                     MOVE 1 TO WS-I(2)
                     CALL "EF7-DRAGON-ANIM" USING EMM-MODEL EN-DR-HIST WS-IN
                 WHEN "evoker_fangs"
                     CALL "ENTITY-FANGS-PROGRESS" USING CLIENT-STATE WS-ROW WS-FP
                     MOVE WS-FP TO WS-I(1)
                     CALL "EM3-FANGS-ANIM" USING EMM-MODEL WS-IN
*>               The magma cube's slices spread with the squish (34-6 7.2).
                 WHEN "magma_cube"
                     MOVE EN-SQ(WS-ROW) TO WS-I(1)
                     CALL "EF6-MAGMA-ANIM" USING EMM-MODEL WS-IN
                 WHEN "blaze"
                     MOVE WS-AGE TO WS-I(3)
                     CALL "EF7-BLAZE-ANIM" USING EMM-MODEL WS-IN
                 WHEN "enderman"
                 WHEN "enderman_eyes"
                     MOVE 0 TO WS-CARRIED
                     IF EN-CARRY(WS-ROW) > 0
                         MOVE 1 TO WS-CARRIED
                     END-IF
                     MOVE EN-CREEPY(WS-ROW) TO WS-CREEPY
                     CALL "EF6-ENDERMAN-ANIM" USING EMM-MODEL WS-STATE WS-CARRIED WS-CREEPY
                 WHEN OTHER
                     CONTINUE
             END-EVALUATE
     END-EVALUATE
*>   The render sequence of the body yaw (the replica's yaw): operations in the order EF7-SETUP-ROTATIONS lists them.
     MOVE 0 TO WS-SRI(1) WS-SRI(2) WS-SRI(4) WS-SRI(5)
     MOVE EN-YAW(WS-ROW) TO WS-SRI(3)
     EVALUATE TRUE
         WHEN WS-ANIM = "B"
             CALL "ENTITY-BOAT-SEQUENCE" USING CLIENT-STATE WS-ROW WS-SR-OUT
         WHEN WS-ANIM = "M"
             CALL "ENTITY-MINECART-SEQUENCE" USING CLIENT-STATE WS-ROW WS-SR-OUT
         WHEN WS-ANIM = "T" OR "R" OR "X" OR "S"
             CALL "ENTITY-NONLIVING-SEQUENCE" USING CLIENT-STATE WS-ROW WS-SR-OUT
         WHEN EN-KEY(WS-ROW) = "ender_dragon"
             CALL "ENTITY-DRAGON-SEQUENCE" USING CLIENT-STATE WS-ROW WS-SR-OUT
         WHEN EN-KEY(WS-ROW) = "evoker_fangs"
             CALL "ENTITY-FANGS-SEQUENCE" USING CLIENT-STATE WS-ROW WS-SR-OUT
         WHEN EN-KEY(WS-ROW) = "squid" OR "glow_squid"
             CALL "ENTITY-SQUID-SEQUENCE" USING CLIENT-STATE WS-ROW WS-SR-OUT
         WHEN EN-KEY(WS-ROW) = "cod" OR "salmon" OR "tropical_fish" OR "pufferfish"
             CALL "ENTITY-FISH-SEQUENCE" USING CLIENT-STATE WS-ROW WS-SR-OUT
         WHEN OTHER
             CALL "EF7-SETUP-ROTATIONS" USING WS-SR-IN WS-SR-OUT
     END-EVALUATE
     MOVE WS-SRO(1) TO WS-NOPS
*>   A player lying flat (swim amount above 0, 53 section 13): after the body yaw, the rotation about X by amount x T (T = -90 - pitch in water, -90 on
*>   land) and the translation (0, -1, 0.3) that the pose SWIMMING adds before it (the vertex is moved first, then rotated, then yawed).
     IF WS-ANIM = "H" AND EN-SWIM(WS-ROW) > 0
         PERFORM VARYING WS-J FROM WS-NOPS BY -1 UNTIL WS-J < 2
             COMPUTE WS-OB = WS-J * 4 - 2
             COMPUTE WS-OD = WS-OB + 8
             MOVE WS-SRO(WS-OB) TO WS-SRO(WS-OD)
             MOVE WS-SRO(WS-OB + 1) TO WS-SRO(WS-OD + 1)
             MOVE WS-SRO(WS-OB + 2) TO WS-SRO(WS-OD + 2)
             MOVE WS-SRO(WS-OB + 3) TO WS-SRO(WS-OD + 3)
         END-PERFORM
         DIVIDE EN-FLAGS(WS-ROW) BY 16 GIVING WS-Q-SWIM
         MOVE -90 TO WS-T
         IF FUNCTION MOD(WS-Q-SWIM, 2) = 1
             COMPUTE WS-T = -90 - EN-PITCH(WS-ROW)
         END-IF
         MOVE 5 TO WS-SRO(6)
         COMPUTE WS-SRO(7) = EN-SWIM(WS-ROW) * WS-T
         MOVE 0 TO WS-SRO(8) WS-SRO(9)
         MOVE 1 TO WS-SRO(10)
         MOVE 0 TO WS-SRO(11)
         MOVE -1 TO WS-SRO(12)
         MOVE 0.3 TO WS-SRO(13)
         ADD 2 TO WS-NOPS
     END-IF
*>   A crouching player is drawn 0.125 lower, outermost (53 section 14.1).
     IF WS-ANIM = "H" AND EN-POSE(WS-ROW) = 5
         PERFORM VARYING WS-J FROM WS-NOPS BY -1 UNTIL WS-J < 1
             COMPUTE WS-OB = WS-J * 4 - 2
             COMPUTE WS-OD = WS-OB + 4
             MOVE WS-SRO(WS-OB) TO WS-SRO(WS-OD)
             MOVE WS-SRO(WS-OB + 1) TO WS-SRO(WS-OD + 1)
             MOVE WS-SRO(WS-OB + 2) TO WS-SRO(WS-OD + 2)
             MOVE WS-SRO(WS-OB + 3) TO WS-SRO(WS-OD + 3)
         END-PERFORM
         MOVE 1 TO WS-SRO(2)
         MOVE 0 TO WS-SRO(3) WS-SRO(5)
         MOVE -0.125 TO WS-SRO(4)
         ADD 1 TO WS-NOPS
     END-IF
     PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > WS-NOPS
         COMPUTE WS-OB = WS-J * 4 - 2
         COMPUTE WS-T = WS-SRO(WS-OB + 1) * FUNCTION PI / 180
         COMPUTE WS-OP-SIN(WS-J) = FUNCTION SIN(WS-T)
         COMPUTE WS-OP-COS(WS-J) = FUNCTION COS(WS-T)
         COMPUTE WS-OPC(WS-J) = WS-SRO(WS-OB)
     END-PERFORM
*>   Per part: visibility (WS-VIS(p + 1); entry 1 is the visible root's parent, so a hidden part hides its children, whose parents come
*>   first) and the trigonometry of its rotation.
*>   A player's overlay layers (the hat, jacket, sleeves and pants of 12 section 7.4) show only for the skin parts of Set Entity Data entry 16 (47 section 5.3).
     IF CL-MD-KEY(EN-MODEL(WS-ROW)) = "player" OR "player_slim"
         PERFORM VARYING WS-P FROM 1 BY 1 UNTIL WS-P > MM-COUNT
             MOVE -1 TO WS-PART-NO
             EVALUATE MM-NAME(WS-P)
                 WHEN "jacket" MOVE 1 TO WS-PART-NO
                 WHEN "left_sleeve" MOVE 2 TO WS-PART-NO
                 WHEN "right_sleeve" MOVE 3 TO WS-PART-NO
                 WHEN "left_pants" MOVE 4 TO WS-PART-NO
                 WHEN "right_pants" MOVE 5 TO WS-PART-NO
                 WHEN "hat" MOVE 6 TO WS-PART-NO
                 WHEN OTHER CONTINUE
             END-EVALUATE
             IF WS-PART-NO >= 0
                 CALL "PLAYER-PART-SHOWN" USING EN-PARTS(WS-ROW) WS-PART-NO MM-VISIBLE(WS-P)
             END-IF
         END-PERFORM
     END-IF
     MOVE 1 TO WS-VIS(1)
     PERFORM VARYING WS-P FROM 1 BY 1 UNTIL WS-P > MM-COUNT
         COMPUTE WS-VIS(WS-P + 1) = MM-VISIBLE(WS-P) * WS-VIS(MM-PARENT(WS-P) + 1)
         MOVE MM-CXROT(WS-P) TO WS-ANG(1)
         MOVE MM-CYROT(WS-P) TO WS-ANG(2)
         MOVE MM-CZROT(WS-P) TO WS-ANG(3)
         PERFORM VARYING WS-A FROM 1 BY 1 UNTIL WS-A > 3
             MOVE 0 TO WS-SA(WS-P, WS-A)
             MOVE 1 TO WS-CA(WS-P, WS-A)
             IF WS-ANG(WS-A) NOT = WS-FZERO
                 COMPUTE WS-SA(WS-P, WS-A) = FUNCTION SIN(WS-ANG(WS-A))
                 COMPUTE WS-CA(WS-P, WS-A) = FUNCTION COS(WS-ANG(WS-A))
             END-IF
         END-PERFORM
     END-PERFORM
     MOVE MM-TEXW TO WS-RI(6)
     MOVE MM-TEXH TO WS-RI(7)
     PERFORM VARYING WS-P FROM 1 BY 1 UNTIL WS-P > MM-COUNT
         PERFORM VARYING WS-C FROM 1 BY 1 UNTIL WS-C > MM-NCUBES(WS-P) OR WS-VIS(WS-P + 1) = 0
             IF WS-BN + 36 <= 1440
                 MOVE MC-OX(WS-P, WS-C) TO WS-BI(1)
                 MOVE MC-OY(WS-P, WS-C) TO WS-BI(2)
                 MOVE MC-OZ(WS-P, WS-C) TO WS-BI(3)
                 MOVE MC-W(WS-P, WS-C) TO WS-BI(4)
                 MOVE MC-H(WS-P, WS-C) TO WS-BI(5)
                 MOVE MC-D(WS-P, WS-C) TO WS-BI(6)
                 MOVE MC-GX(WS-P, WS-C) TO WS-BI(7)
                 MOVE MC-GY(WS-P, WS-C) TO WS-BI(8)
                 MOVE MC-GZ(WS-P, WS-C) TO WS-BI(9)
                 MOVE MC-MIRROR(WS-P, WS-C) TO WS-BI(10)
                 CALL "EF7-BOX-CORNERS" USING WS-BOX-IN WS-BOX-OUT
                 MOVE MC-U(WS-P, WS-C) TO WS-RI(1)
                 MOVE MC-V(WS-P, WS-C) TO WS-RI(2)
                 MOVE MC-W(WS-P, WS-C) TO WS-RI(3)
                 MOVE MC-H(WS-P, WS-C) TO WS-RI(4)
                 MOVE MC-D(WS-P, WS-C) TO WS-RI(5)
                 CALL "EF7-BOX-RECTS" USING WS-RC-IN WS-RC-OUT
*>               The eight corners through the part chain and the render sequence, eye-relative.
                 PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 8
                     COMPUTE WS-A = WS-K * 3 - 2
                     MOVE WS-BO(WS-A) TO WS-X
                     MOVE WS-BO(WS-A + 1) TO WS-Y
                     MOVE WS-BO(WS-A + 2) TO WS-Z
                     MOVE WS-P TO WS-NODE
                     PERFORM UNTIL WS-NODE < 1
                         COMPUTE WS-X = WS-X * MM-CXSCALE(WS-NODE)
                         COMPUTE WS-Y = WS-Y * MM-CYSCALE(WS-NODE)
                         COMPUTE WS-Z = WS-Z * MM-CZSCALE(WS-NODE)
                         COMPUTE WS-T = WS-Y * WS-CA(WS-NODE, 1) - WS-Z * WS-SA(WS-NODE, 1)
                         COMPUTE WS-Z = WS-Y * WS-SA(WS-NODE, 1) + WS-Z * WS-CA(WS-NODE, 1)
                         MOVE WS-T TO WS-Y
                         COMPUTE WS-T = WS-X * WS-CA(WS-NODE, 2) + WS-Z * WS-SA(WS-NODE, 2)
                         COMPUTE WS-Z = WS-Z * WS-CA(WS-NODE, 2) - WS-X * WS-SA(WS-NODE, 2)
                         MOVE WS-T TO WS-X
                         COMPUTE WS-T = WS-X * WS-CA(WS-NODE, 3) - WS-Y * WS-SA(WS-NODE, 3)
                         COMPUTE WS-Y = WS-X * WS-SA(WS-NODE, 3) + WS-Y * WS-CA(WS-NODE, 3)
                         MOVE WS-T TO WS-X
                         COMPUTE WS-X = WS-X + MM-CX(WS-NODE)
                         COMPUTE WS-Y = WS-Y + MM-CY(WS-NODE)
                         COMPUTE WS-Z = WS-Z + MM-CZ(WS-NODE)
                         MOVE MM-PARENT(WS-NODE) TO WS-NODE
                     END-PERFORM
                     COMPUTE WS-X = WS-X / 16
                     COMPUTE WS-Y = WS-Y / 16
                     COMPUTE WS-Z = WS-Z / 16
                     PERFORM VARYING WS-J FROM WS-NOPS BY -1 UNTIL WS-J < 1
                         COMPUTE WS-OB = WS-J * 4 - 2
                         EVALUATE WS-OPC(WS-J)
                             WHEN 1
                                 COMPUTE WS-X = WS-X + WS-SRO(WS-OB + 1)
                                 COMPUTE WS-Y = WS-Y + WS-SRO(WS-OB + 2)
                                 COMPUTE WS-Z = WS-Z + WS-SRO(WS-OB + 3)
                             WHEN 2
*>                               The renderer's own scale (the creeper's swell, 34-6 2) acts after the translate and before this one.
                                 COMPUTE WS-X = WS-X * WS-HOOK-X
                                 COMPUTE WS-Y = WS-Y * WS-HOOK-Y
                                 COMPUTE WS-Z = WS-Z * WS-HOOK-X
                                 COMPUTE WS-X = WS-X * WS-SRO(WS-OB + 1)
                                 COMPUTE WS-Y = WS-Y * WS-SRO(WS-OB + 2)
                                 COMPUTE WS-Z = WS-Z * WS-SRO(WS-OB + 3)
                             WHEN 5
*>                               rotation about X by the listed degrees (right-handed)
                                 COMPUTE WS-T = WS-Y * WS-OP-COS(WS-J) - WS-Z * WS-OP-SIN(WS-J)
                                 COMPUTE WS-Z = WS-Y * WS-OP-SIN(WS-J) + WS-Z * WS-OP-COS(WS-J)
                                 MOVE WS-T TO WS-Y
                             WHEN 8
*>                               rotation by the listed degrees about the axis (1, 0, 1) / sqrt 2 (Rodrigues' formula)
                                 COMPUTE WS-DOT = 0.70710678 * (WS-X + WS-Z)
                                 COMPUTE WS-T = WS-X * WS-OP-COS(WS-J) - 0.70710678 * WS-Y * WS-OP-SIN(WS-J) + 0.70710678 * WS-DOT * (1 - WS-OP-COS(WS-J))
                                 COMPUTE WS-DY = WS-Y * WS-OP-COS(WS-J) + 0.70710678 * (WS-X - WS-Z) * WS-OP-SIN(WS-J)
                                 COMPUTE WS-Z = WS-Z * WS-OP-COS(WS-J) + 0.70710678 * WS-Y * WS-OP-SIN(WS-J) + 0.70710678 * WS-DOT * (1 - WS-OP-COS(WS-J))
                                 MOVE WS-T TO WS-X
                                 MOVE WS-DY TO WS-Y
                             WHEN 7
*>                               rotation about Z by the listed degrees
                                 COMPUTE WS-T = WS-X * WS-OP-COS(WS-J) - WS-Y * WS-OP-SIN(WS-J)
                                 COMPUTE WS-Y = WS-X * WS-OP-SIN(WS-J) + WS-Y * WS-OP-COS(WS-J)
                                 MOVE WS-T TO WS-X
                             WHEN OTHER
*>                               rotation about Y by the listed degrees
                                 COMPUTE WS-T = WS-X * WS-OP-COS(WS-J) + WS-Z * WS-OP-SIN(WS-J)
                                 COMPUTE WS-Z = WS-Z * WS-OP-COS(WS-J) - WS-X * WS-OP-SIN(WS-J)
                                 MOVE WS-T TO WS-X
                         END-EVALUATE
                     END-PERFORM
                     COMPUTE WS-WX(WS-K) = WS-X
                     COMPUTE WS-WY(WS-K) = WS-Y
                     COMPUTE WS-WZ(WS-K) = WS-Z
                 END-PERFORM
                 ADD 1 TO WS-NC
                 PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 8
                     MOVE WS-WX(WS-K) TO WS-BK-CX(WS-E, WS-NC, WS-K)
                     MOVE WS-WY(WS-K) TO WS-BK-CY(WS-E, WS-NC, WS-K)
                     MOVE WS-WZ(WS-K) TO WS-BK-CZ(WS-E, WS-NC, WS-K)
                 END-PERFORM
*>               The cuboid of an arm (the first of a part named right_arm, left_arm, or the crossed arms, kept as a negative index): where the held item goes.
                 IF MM-NAME(WS-P) = "right_arm" AND WS-BK-HR(WS-E) = 0
                     MOVE WS-NC TO WS-BK-HR(WS-E)
                     CALL "ENTITY-ARM-LOCAL" USING WS-BOX-IN WS-BK-HFR(WS-E)
                 END-IF
                 IF MM-NAME(WS-P) = "left_arm" AND WS-BK-HL(WS-E) = 0
                     MOVE WS-NC TO WS-BK-HL(WS-E)
                     CALL "ENTITY-ARM-LOCAL" USING WS-BOX-IN WS-BK-HFL(WS-E)
                 END-IF
                 IF MM-NAME(WS-P) = "arms" AND WS-BK-HR(WS-E) = 0
                     COMPUTE WS-BK-HR(WS-E) = 0 - WS-NC
                 END-IF
*>               The six faces: down, up, west, north, east, south.
                 PERFORM VARYING WS-F FROM 0 BY 1 UNTIL WS-F > 5
                     COMPUTE WS-A = WS-F * 4
                     MOVE MC-MIRROR(WS-P, WS-C) TO WS-MIRROR
                     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 4
                         MOVE WS-FC(WS-F + 1, WS-MIRROR + 1, WS-K) TO WS-J
                         MOVE WS-J TO WS-QJ(WS-K)
*>                       A mirrored cuboid reverses the order of the corners but each corner keeps its own texel (34-1 1.3 step 7: the vertices carry their texture
*>                       coordinates when they are reversed), so the texel of slot k is that of the unmirrored slot 5 - k: the image is flipped left to right only.
                         IF WS-MIRROR = 0
                             COMPUTE WS-SLOT-INDEX = WS-K - 1
                         ELSE
                             COMPUTE WS-SLOT-INDEX = 4 - WS-K
                         END-IF
                         MOVE WS-UVP-U(WS-SLOT-INDEX + 1) TO WS-PICK
                         COMPUTE WS-PICK = WS-A + WS-PICK
                         COMPUTE WS-QU(WS-K) = (EA-MT-X(WS-SLOT) + WS-RO(WS-PICK) * EA-MT-W(WS-SLOT)) / EA-W
                         MOVE WS-UVP-V(WS-SLOT-INDEX + 1) TO WS-PICK
                         COMPUTE WS-PICK = WS-A + WS-PICK
                         COMPUTE WS-QV(WS-K) = (EA-MT-Y(WS-SLOT) + WS-RO(WS-PICK) * EA-MT-H(WS-SLOT)) / EA-H
                     END-PERFORM
                     COMPUTE WS-BRIGHT = FUNCTION MAX(WS-FACTOR(WS-F + 1) * WS-LIGHT, 0.1)
                     IF CL-MD-ANIM(EN-MODEL(WS-ROW)) = "Y" OR "E"
                         MOVE 1 TO WS-BRIGHT
                     END-IF
                     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 6
                         MOVE WS-ORD(WS-K) TO WS-N
                         ADD 1 TO WS-BN
                         MOVE WS-QJ(WS-N) TO WS-BK-VK(WS-E, WS-BN)
                         MOVE WS-QU(WS-N) TO WS-BK-U(WS-E, WS-BN)
                         MOVE WS-QV(WS-N) TO WS-BK-W(WS-E, WS-BN)
                         MOVE WS-BRIGHT TO WS-BK-B(WS-E, WS-BN)
                     END-PERFORM
                 END-PERFORM
             END-IF
         END-PERFORM
     END-PERFORM
         MOVE WS-BN TO WS-BK-N(WS-E)
         MOVE WS-NC TO WS-BK-NC(WS-E)
         MOVE WS-KEY-NOW TO WS-BK-KEY(WS-E)
     END-IF
*>   Copy the baked cuboids (36 vertices each) to the frame, eye-relative: the eight corners of a cuboid get the offset to the eye, the 36 vertices
*>   take their corner; one that no longer fits the vertex capacity is left out.
     COMPUTE WS-OX = EN-X(WS-ROW) - L-EYE(1)
     COMPUTE WS-OY = EN-Y(WS-ROW) - L-EYE(2)
     COMPUTE WS-OZ = EN-Z(WS-ROW) - L-EYE(3)
     CALL "ENTITY-TINT" USING CLIENT-STATE WS-ROW EN-MODEL(WS-ROW) WS-TR WS-TG WS-TB
*>   The tint as the vertex fields' own type once, not converted for each of the 36 vertices of a cuboid.
     MOVE WS-TR TO WS-TRS
     MOVE WS-TG TO WS-TGS
     MOVE WS-TB TO WS-TBS
*>   The corners shifted last time are kept with the offset they were shifted by: a mob and an eye that did not move need no shifting (a float addition costs
*>   half a microsecond: 24 of them a cuboid were two thirds of a frame of 70 mobs).
     MOVE 0 TO WS-REUSE
     IF WS-BK-OK(WS-E) = 1 AND WS-BK-OFX(WS-E) = WS-OX AND WS-BK-OFY(WS-E) = WS-OY AND WS-BK-OFZ(WS-E) = WS-OZ
         MOVE 1 TO WS-REUSE
     END-IF
*>   The vertex count is kept in a field of this program while the cuboids are copied: a field of the client record costs a call to read each time it is a
*>   subscript, and a vertex has eight such uses.
     MOVE RL-EN-COUNT TO WS-VCOUNT
     COMPUTE WS-VLIMIT = CL-MAX-ENTITY-VERTICES - 36
     PERFORM VARYING WS-C FROM 1 BY 1 UNTIL WS-C > WS-BK-NC(WS-E) OR WS-VCOUNT > WS-VLIMIT
         IF WS-REUSE = 1
             MOVE WS-BK-EC(WS-E, WS-C) TO WS-EC
         ELSE
             ADD 1 TO RL-EN-SHIFTS
             PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 8
                 COMPUTE WS-ECX(WS-K) = WS-BK-CX(WS-E, WS-C, WS-K) + WS-OX
                 COMPUTE WS-ECY(WS-K) = WS-BK-CY(WS-E, WS-C, WS-K) + WS-OY
                 COMPUTE WS-ECZ(WS-K) = WS-BK-CZ(WS-E, WS-C, WS-K) + WS-OZ
             END-PERFORM
             MOVE WS-EC TO WS-BK-EC(WS-E, WS-C)
         END-IF
         COMPUTE WS-VA = WS-C * 36 - 35
         PERFORM VARYING WS-VW FROM 0 BY 1 UNTIL WS-VW > 35
             ADD 1 TO WS-VCOUNT
             MOVE WS-BK-V(WS-E, WS-VA) TO RL-EN-VERTEX(WS-VCOUNT)
             MOVE WS-BK-VK(WS-E, WS-VA) TO WS-J
             MOVE WS-ECX(WS-J) TO RL-EN-X(WS-VCOUNT)
             MOVE WS-ECY(WS-J) TO RL-EN-Y(WS-VCOUNT)
             MOVE WS-ECZ(WS-J) TO RL-EN-Z(WS-VCOUNT)
             MOVE WS-TRS TO RL-EN-R(WS-VCOUNT)
             MOVE WS-TGS TO RL-EN-G(WS-VCOUNT)
             MOVE WS-TBS TO RL-EN-BLUE(WS-VCOUNT)
             ADD 1 TO WS-VA
         END-PERFORM
     END-PERFORM
     MOVE WS-VCOUNT TO RL-EN-COUNT
     IF WS-REUSE = 0 AND WS-C > WS-BK-NC(WS-E)
         MOVE 1 TO WS-BK-OK(WS-E)
         MOVE WS-OX TO WS-BK-OFX(WS-E)
         MOVE WS-OY TO WS-BK-OFY(WS-E)
         MOVE WS-OZ TO WS-BK-OFZ(WS-E)
     END-IF
*>   The hands of a mob that holds an item (the base model only): where GROUND-ITEMS-MESH draws what the mob holds (ENTITY-HAND-FIND).
     IF EN-OVL(WS-ROW) = 0 AND (EN-EQ(WS-ROW, 1) > 0 OR EN-EQ(WS-ROW, 2) > 0)
         IF WS-BK-HR(WS-E) NOT = 0
             MOVE 1 TO WS-HK
             MOVE WS-BK-HR(WS-E) TO WS-HI
             IF WS-HI < 0
                 MOVE 2 TO WS-HK
                 COMPUTE WS-HI = 0 - WS-HI
             END-IF
             CALL "ENTITY-HAND-FIND" USING WS-BK-CORNER(WS-E, WS-HI) WS-HK WS-HP WS-HA EN-HAND-OK(WS-ROW, 1)
             PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 3
                 MOVE WS-HPV(WS-K) TO EN-HAND-V(WS-ROW, 1, WS-K)
                 MOVE WS-HAV(WS-K) TO EN-HAND-V(WS-ROW, 1, WS-K + 3)
             END-PERFORM
*>           The frame of an arm part (not of the crossed arms): where the item of 34-1 section 8.3 is placed.
             IF WS-BK-HR(WS-E) > 0
                 CALL "ENTITY-HAND-FRAME" USING WS-BK-CORNER(WS-E, WS-HI) WS-BK-HFR(WS-E) EN-HAND-FG(WS-ROW, 1)
                 MOVE 1 TO EN-HAND-FOK(WS-ROW, 1)
             END-IF
         END-IF
         IF WS-BK-HL(WS-E) > 0
             CALL "ENTITY-HAND-FIND" USING WS-BK-CORNER(WS-E, WS-BK-HL(WS-E)) 1 WS-HP WS-HA EN-HAND-OK(WS-ROW, 2)
             PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 3
                 MOVE WS-HPV(WS-K) TO EN-HAND-V(WS-ROW, 2, WS-K)
                 MOVE WS-HAV(WS-K) TO EN-HAND-V(WS-ROW, 2, WS-K + 3)
             END-PERFORM
             CALL "ENTITY-HAND-FRAME" USING WS-BK-CORNER(WS-E, WS-BK-HL(WS-E)) WS-BK-HFL(WS-E) EN-HAND-FG(WS-ROW, 2)
             MOVE 1 TO EN-HAND-FOK(WS-ROW, 2)
         END-IF
     END-IF
     GOBACK.
 END PROGRAM ENTITY-MODEL-EMIT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ENTITY-ORB-EMIT.
*> USING CLIENT-STATE, replica row (an experience_orb with its CL-MODELS slot), eye (3 FLOAT-LONG): appends the orb's quad to RL-EN-VERTEX
*> (34-9 section 14): 0.3 wide from y + 0.025 to y + 0.325, across the camera's right, on the icon of its value (tiers 3, 7, 17, 37, 73, 149, 307, 617, 1237,
*> 2477 give icons 1 to 10, below 3 icon 0) of the 4 x 4 sheet of 16-pixel icons of the 64 x 64 image; tint r = (sin t + 1) / 2, g = 1,
*> b = (sin (t + 4.1887903) + 1) / 10 with t = ageInTicks / 2 (ticks from the clock, CL-NOW-MS / 50); lit by max(sky x daylight, min(block + 7, 15)) / 15.
*> The orb is opaque here and alpha 128 in the game (the entity pipeline has no blending): open.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLCONST.
 COPY CLMODELS.
 01 WS-I.
    05 WS-IV               FLOAT-LONG OCCURS 32 TIMES.
 01 WS-O.
    05 WS-OV               FLOAT-LONG OCCURS 64 TIMES.
 01 WS-SLOT                BINARY-LONG.
 01 WS-S                   BINARY-LONG.
 01 WS-ICON                BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-RX                  FLOAT-LONG.
 01 WS-RZ                  FLOAT-LONG.
 01 WS-SIDE                FLOAT-LONG.
 01 WS-T                   FLOAT-LONG.
 01 WS-LIGHT               FLOAT-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CY                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-SKY                 BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
 01 WS-U64                 FLOAT-LONG.
 01 WS-V64                 FLOAT-LONG.
 01 WS-CORNERS.
    05 WS-C OCCURS 4 TIMES.
       10 WS-C-X           FLOAT-SHORT.
       10 WS-C-Y           FLOAT-SHORT.
       10 WS-C-Z           FLOAT-SHORT.
       10 WS-C-U           FLOAT-SHORT.
       10 WS-C-V           FLOAT-SHORT.
 01 WS-ORDER-DATA          PIC X(6) VALUE "123134".
 01 WS-ORDER REDEFINES WS-ORDER-DATA.
    05 WS-ORD              PIC 9 OCCURS 6 TIMES.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-ROW                  BINARY-LONG.
 01 L-EYE-TABLE.
    05 L-EYE               FLOAT-LONG OCCURS 3 TIMES.
 PROCEDURE DIVISION USING CLIENT-STATE L-ROW L-EYE-TABLE.
     MOVE 0 TO WS-SLOT
     PERFORM VARYING WS-S FROM 1 BY 1 UNTIL WS-S > EA-MT-COUNT
         IF EA-MT-MODEL(WS-S) = EN-MODEL(L-ROW)
             MOVE WS-S TO WS-SLOT
         END-IF
     END-PERFORM
     IF WS-SLOT = 0 OR RL-EN-COUNT + 6 > CL-MAX-ENTITY-VERTICES
         GOBACK
     END-IF
     MOVE EN-VALUE(L-ROW) TO WS-IV(1)
     CALL "EF9-ORB-ICON" USING WS-I WS-O
     MOVE WS-OV(1) TO WS-ICON
     COMPUTE WS-RX = - FUNCTION COS(PL-YAW * FUNCTION PI / 180)
     COMPUTE WS-RZ = - FUNCTION SIN(PL-YAW * FUNCTION PI / 180)
     COMPUTE WS-CX = FUNCTION INTEGER(EN-X(L-ROW))
     COMPUTE WS-CY = FUNCTION INTEGER(EN-Y(L-ROW))
     COMPUTE WS-CZ = FUNCTION INTEGER(EN-Z(L-ROW))
     CALL "WORLD-CELL" USING CLIENT-STATE WS-CX WS-CY WS-CZ WS-STATE WS-SKY WS-BLOCK
     MOVE WS-BLOCK TO WS-IV(1)
     CALL "EF9-ORB-LIGHT" USING WS-I WS-O
     COMPUTE WS-LIGHT = FUNCTION MAX(WS-SKY * SK-U / 1000, WS-OV(1)) / 15
     COMPUTE WS-T = CL-NOW-MS / 50
     MOVE WS-T TO WS-IV(1)
     CALL "EF9-ORB-COLOR" USING WS-I WS-O
*>   Corner k: left (-0.15) for 1 and 4, right (+0.15) for 2 and 3; top (y + 0.325) for 1 and 2, bottom (y + 0.025) for 3 and 4.
     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 4
         MOVE -0.15 TO WS-SIDE
         MOVE 0 TO WS-U64
         IF WS-K = 2 OR WS-K = 3
             MOVE 0.15 TO WS-SIDE
             MOVE 1 TO WS-U64
         END-IF
         COMPUTE WS-C-X(WS-K) = EN-X(L-ROW) - L-EYE(1) + WS-SIDE * WS-RX
         COMPUTE WS-C-Z(WS-K) = EN-Z(L-ROW) - L-EYE(3) + WS-SIDE * WS-RZ
         COMPUTE WS-C-Y(WS-K) = EN-Y(L-ROW) - L-EYE(2) + 0.325
         MOVE 0 TO WS-V64
         IF WS-K >= 3
             COMPUTE WS-C-Y(WS-K) = EN-Y(L-ROW) - L-EYE(2) + 0.025
             MOVE 1 TO WS-V64
         END-IF
*>       The icon's rectangle in the image, in fractions of 64: x (icon mod 4) / 4, y (icon div 4) / 4, 1/4 each.
         COMPUTE WS-C-U(WS-K) = (EA-MT-X(WS-SLOT) + (FUNCTION MOD(WS-ICON, 4) / 4 + WS-U64 / 4) * EA-MT-W(WS-SLOT)) / EA-W
         COMPUTE WS-C-V(WS-K) = (EA-MT-Y(WS-SLOT) + (FUNCTION INTEGER(WS-ICON / 4) / 4 + WS-V64 / 4) * EA-MT-H(WS-SLOT)) / EA-H
     END-PERFORM
     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 6
         MOVE WS-ORD(WS-K) TO WS-N
         ADD 1 TO RL-EN-COUNT
         MOVE WS-C-X(WS-N) TO RL-EN-X(RL-EN-COUNT)
         MOVE WS-C-Y(WS-N) TO RL-EN-Y(RL-EN-COUNT)
         MOVE WS-C-Z(WS-N) TO RL-EN-Z(RL-EN-COUNT)
         MOVE WS-C-U(WS-N) TO RL-EN-U(RL-EN-COUNT)
         MOVE WS-C-V(WS-N) TO RL-EN-V(RL-EN-COUNT)
         MOVE WS-LIGHT TO RL-EN-B(RL-EN-COUNT)
         MOVE 1 TO RL-EN-A(RL-EN-COUNT)
         MOVE 0 TO RL-EN-SKY(RL-EN-COUNT)
         COMPUTE RL-EN-R(RL-EN-COUNT) = WS-OV(1) / 255
         MOVE 1 TO RL-EN-G(RL-EN-COUNT)
         COMPUTE RL-EN-BLUE(RL-EN-COUNT) = WS-OV(3) / 255
     END-PERFORM
     GOBACK.
 END PROGRAM ENTITY-ORB-EMIT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ENTITY-ARROW-EMIT.
*> USING CLIENT-STATE, replica row (an arrow with its CL-MODELS slot), eye (3 FLOAT-LONG): appends the arrow's six quads (34-9 section 4): the shaft
*> planes cross_1 and cross_2 (16 x 4 pixels, x from -12 to 4, turned about x by 45 and 135 degrees; texels u 0 to 16 on the front, 16 to 32 on the
*> back, v 0 to 4 of 25.6) and the fletching plane (5 x 5 pixels at x = -11, turned 45 degrees, scale 0.8; texels 0 to 5 by 5 to 10), each drawn from
*> both sides (the pipeline culls no face); the model's own scale 0.9 / 16 a pixel; turned about z by the pitch EN-PITCH and about y by yaw - 90
*> (the tip along +x before the turns; the server gives yaw = atan2(vx, vz), pitch = atan(vy / horizontal speed)); a stuck arrow keeps its angles.
*> The shake of a fresh hit (34-9 4.1 setupAnim) is not drawn: the client is told no shake time (open).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLCONST.
 COPY CLMODELS.
 01 WS-SLOT                BINARY-LONG.
 01 WS-S                   BINARY-LONG.
 01 WS-Q                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-LIGHT               FLOAT-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CY                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-SKY                 BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
 01 WS-PI                  FLOAT-LONG.
 01 WS-SPITCH              FLOAT-LONG.
 01 WS-CPITCH              FLOAT-LONG.
 01 WS-SYAW                FLOAT-LONG.
 01 WS-CYAW                FLOAT-LONG.
 01 WS-SX                  FLOAT-LONG.
 01 WS-CPL                 FLOAT-LONG.
 01 WS-SPL                 FLOAT-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-T                   FLOAT-LONG.
 01 WS-U                   FLOAT-LONG.
 01 WS-V                   FLOAT-LONG.
 01 WS-CORNERS.
    05 WS-C OCCURS 4 TIMES.
       10 WS-C-X           FLOAT-SHORT.
       10 WS-C-Y           FLOAT-SHORT.
       10 WS-C-Z           FLOAT-SHORT.
       10 WS-C-U           FLOAT-SHORT.
       10 WS-C-V           FLOAT-SHORT.
 01 WS-ORDER-DATA          PIC X(6) VALUE "123134".
 01 WS-ORDER REDEFINES WS-ORDER-DATA.
    05 WS-ORD              PIC 9 OCCURS 6 TIMES.
 01 WS-TILT                FLOAT-LONG.
 01 WS-LENGTH-A            FLOAT-LONG.
 01 WS-MODEL-X             FLOAT-LONG.
 01 WS-MODEL-Y             FLOAT-LONG.
 01 WS-MODEL-Z             FLOAT-LONG.
 01 WS-CORNER-X            FLOAT-LONG OCCURS 4 TIMES.
 01 WS-CORNER-Y            FLOAT-LONG OCCURS 4 TIMES.
 01 WS-CORNER-U            FLOAT-LONG OCCURS 4 TIMES.
 01 WS-CORNER-V            FLOAT-LONG OCCURS 4 TIMES.
 01 WS-SIDE                BINARY-LONG.
 01 WS-KIND                BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-ROW                  BINARY-LONG.
 01 L-EYE-TABLE.
    05 L-EYE               FLOAT-LONG OCCURS 3 TIMES.
 PROCEDURE DIVISION USING CLIENT-STATE L-ROW L-EYE-TABLE.
     MOVE 0 TO WS-SLOT
     PERFORM VARYING WS-S FROM 1 BY 1 UNTIL WS-S > EA-MT-COUNT
         IF EA-MT-MODEL(WS-S) = EN-MODEL(L-ROW)
             MOVE WS-S TO WS-SLOT
         END-IF
     END-PERFORM
     IF WS-SLOT = 0 OR RL-EN-COUNT + 36 > CL-MAX-ENTITY-VERTICES
         GOBACK
     END-IF
     MOVE FUNCTION PI TO WS-PI
     COMPUTE WS-SPITCH = FUNCTION SIN(EN-PITCH(L-ROW) * WS-PI / 180)
     COMPUTE WS-CPITCH = FUNCTION COS(EN-PITCH(L-ROW) * WS-PI / 180)
     COMPUTE WS-SYAW = FUNCTION SIN((EN-YAW(L-ROW) - 90) * WS-PI / 180)
     COMPUTE WS-CYAW = FUNCTION COS((EN-YAW(L-ROW) - 90) * WS-PI / 180)
     COMPUTE WS-CX = FUNCTION INTEGER(EN-X(L-ROW))
     COMPUTE WS-CY = FUNCTION INTEGER(EN-Y(L-ROW))
     COMPUTE WS-CZ = FUNCTION INTEGER(EN-Z(L-ROW))
     CALL "WORLD-CELL" USING CLIENT-STATE WS-CX WS-CY WS-CZ WS-STATE WS-SKY WS-BLOCK
     COMPUTE WS-LIGHT = FUNCTION MAX(FUNCTION MAX(WS-SKY * SK-U / 1000, WS-BLOCK) / 15, 0.1)
*>   Quads 1 to 6: shaft plane 1 (front, back), shaft plane 2 (front, back), fletching (front, back).
     PERFORM VARYING WS-Q FROM 1 BY 1 UNTIL WS-Q > 6
         COMPUTE WS-KIND = FUNCTION INTEGER((WS-Q + 1) / 2)
         COMPUTE WS-SIDE = FUNCTION MOD(WS-Q - 1, 2)
         IF WS-KIND = 3
*>           The fletching plane: 5 x 5 at x = -11 (scaled 0.8: 4 x 4), tilted 45 degrees about x, corners (y, z) = (+-2, +-2) before the tilt.
             MOVE 45 TO WS-TILT
             MOVE -11 TO WS-MODEL-X
         ELSE
             IF WS-KIND = 1
                 MOVE 45 TO WS-TILT
             ELSE
                 MOVE 135 TO WS-TILT
             END-IF
         END-IF
         PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 4
             IF WS-KIND = 3
*>               Corner k in the plane x = -11: 1 (y 2, z -2), 2 (y 2, z 2), 3 (y -2, z 2), 4 (y -2, z -2) of the 4 x 4 plane, seen from +x for the front.
                 MOVE -11 TO WS-MODEL-X
                 MOVE 2 TO WS-MODEL-Y
                 MOVE -2 TO WS-MODEL-Z
                 IF WS-K = 2 OR WS-K = 3
                     MOVE 2 TO WS-MODEL-Z
                 END-IF
                 IF WS-K >= 3
                     MOVE -2 TO WS-MODEL-Y
                 END-IF
                 MOVE 0 TO WS-U
                 IF WS-K = 2 OR WS-K = 3
                     MOVE 5 TO WS-U
                 END-IF
                 MOVE 5 TO WS-V
                 IF WS-K >= 3
                     MOVE 10 TO WS-V
                 END-IF
                 COMPUTE WS-T = WS-MODEL-Y * FUNCTION COS(WS-TILT * WS-PI / 180) - WS-MODEL-Z * FUNCTION SIN(WS-TILT * WS-PI / 180)
                 COMPUTE WS-Z = WS-MODEL-Y * FUNCTION SIN(WS-TILT * WS-PI / 180) + WS-MODEL-Z * FUNCTION COS(WS-TILT * WS-PI / 180)
                 MOVE WS-T TO WS-Y
                 MOVE WS-MODEL-X TO WS-X
                 COMPUTE WS-U = WS-U / 32
                 COMPUTE WS-V = WS-V / 32
             ELSE
*>               Corner k of the shaft plane: 1 (-12, 2), 2 (4, 2), 3 (4, -2), 4 (-12, -2); u 0 to 16 (front) or 16 to 32 (back), v 0 to 4 of 25.6.
                 MOVE -12 TO WS-X
                 MOVE 0 TO WS-U
                 IF WS-K = 2 OR WS-K = 3
                     MOVE 4 TO WS-X
                     MOVE 16 TO WS-U
                 END-IF
                 MOVE 2 TO WS-MODEL-Y
                 MOVE 0 TO WS-V
                 IF WS-K >= 3
                     MOVE -2 TO WS-MODEL-Y
                     MOVE 4 TO WS-V
                 END-IF
                 COMPUTE WS-Y = WS-MODEL-Y * FUNCTION COS(WS-TILT * WS-PI / 180)
                 COMPUTE WS-Z = WS-MODEL-Y * FUNCTION SIN(WS-TILT * WS-PI / 180)
                 COMPUTE WS-U = (WS-U + WS-SIDE * 16) / 32
                 COMPUTE WS-V = WS-V / 25.6
             END-IF
*>           The model's scale: 0.9 / 16 a pixel; then about z by the pitch, then about y by yaw - 90, then to the entity.
             COMPUTE WS-X = WS-X * 0.9 / 16
             COMPUTE WS-Y = WS-Y * 0.9 / 16
             COMPUTE WS-Z = WS-Z * 0.9 / 16
             COMPUTE WS-T = WS-X * WS-CPITCH - WS-Y * WS-SPITCH
             COMPUTE WS-Y = WS-X * WS-SPITCH + WS-Y * WS-CPITCH
             MOVE WS-T TO WS-X
             COMPUTE WS-T = WS-X * WS-CYAW + WS-Z * WS-SYAW
             COMPUTE WS-Z = WS-Z * WS-CYAW - WS-X * WS-SYAW
             MOVE WS-T TO WS-X
             COMPUTE WS-C-X(WS-K) = EN-X(L-ROW) - L-EYE(1) + WS-X
             COMPUTE WS-C-Y(WS-K) = EN-Y(L-ROW) - L-EYE(2) + WS-Y
             COMPUTE WS-C-Z(WS-K) = EN-Z(L-ROW) - L-EYE(3) + WS-Z
             COMPUTE WS-C-U(WS-K) = (EA-MT-X(WS-SLOT) + WS-U * EA-MT-W(WS-SLOT)) / EA-W
             COMPUTE WS-C-V(WS-K) = (EA-MT-Y(WS-SLOT) + WS-V * EA-MT-H(WS-SLOT)) / EA-H
         END-PERFORM
         PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 6
             MOVE WS-ORD(WS-K) TO WS-N
             ADD 1 TO RL-EN-COUNT
             MOVE WS-C-X(WS-N) TO RL-EN-X(RL-EN-COUNT)
             MOVE WS-C-Y(WS-N) TO RL-EN-Y(RL-EN-COUNT)
             MOVE WS-C-Z(WS-N) TO RL-EN-Z(RL-EN-COUNT)
             MOVE WS-C-U(WS-N) TO RL-EN-U(RL-EN-COUNT)
             MOVE WS-C-V(WS-N) TO RL-EN-V(RL-EN-COUNT)
             MOVE WS-LIGHT TO RL-EN-B(RL-EN-COUNT)
             MOVE 1 TO RL-EN-A(RL-EN-COUNT)
             MOVE 0 TO RL-EN-SKY(RL-EN-COUNT)
             MOVE 1 TO RL-EN-R(RL-EN-COUNT) RL-EN-G(RL-EN-COUNT) RL-EN-BLUE(RL-EN-COUNT)
         END-PERFORM
     END-PERFORM
     GOBACK.
 END PROGRAM ENTITY-ARROW-EMIT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ENTITIES-SWIM-TICK.
*> USING CLIENT-STATE: one client tick of the swim amount of every replica row (docs/protocol/53 section 12.2): up by 0.09 to 1 while the pose is
*> swimming (3), else down by 0.09 to 0.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-R                   BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 PROCEDURE DIVISION USING CLIENT-STATE.
     PERFORM VARYING WS-R FROM 1 BY 1 UNTIL WS-R > EN-COUNT
         IF EN-USED(WS-R) = 1
             IF EN-POSE(WS-R) = 3
                 COMPUTE EN-SWIM(WS-R) = FUNCTION MIN(1, EN-SWIM(WS-R) + 0.09)
             ELSE
                 COMPUTE EN-SWIM(WS-R) = FUNCTION MAX(0, EN-SWIM(WS-R) - 0.09)
             END-IF
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM ENTITIES-SWIM-TICK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ENTITY-WALK-VALUES.
*> USING CLIENT-STATE, replica row, position out, speed out (FLOAT-LONG): what the renderer reads of the walk animation at the end of the tick (partial tick 1;
*> 54 section 1.4): position x positionScale and the speed limited to 1.
 DATA DIVISION.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-ROW                  BINARY-LONG.
 01 L-POS                  FLOAT-LONG.
 01 L-SPEED                FLOAT-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-ROW L-POS L-SPEED.
     COMPUTE L-POS = EN-WALK-POS(L-ROW) * EN-WALK-SCALE(L-ROW)
     COMPUTE L-SPEED = FUNCTION MIN(EN-WALK-SPEED(L-ROW), 1)
     GOBACK.
 END PROGRAM ENTITY-WALK-VALUES.
