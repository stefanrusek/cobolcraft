*> Implementation test (002-lane-fire, T11104; docs/protocol/34-entity-models-1 section 7.4, 18 section 1.4): a burning entity is drawn with flames. An entity whose shared flags
*> byte (entry 0) has bit 0 set shows two layers of the block atlas sprites fire_0 and fire_1: width 0.6 and height 1.8 give s = 0.84 and five quads (EM7-FIRE) of six vertices,
*> each quad billboarded to the camera yaw, the sprite alternating fire_0 and fire_1 and the u coordinate mirrored for quads 0, 1 and 4; an entity without the bit draws none;
*> the local player's own figure burns in the third-person modes only; the player's flag comes from Set Entity Data entry 0 of its own entity id.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-ENTITY-FIRE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLSTATE.
 COPY CLCONST.
 COPY TESTLIB.
 01 WS-EYE-TABLE.
    05 WS-EYE              FLOAT-LONG OCCURS 3 TIMES.
 01 WS-CASE                PIC X(120).
 01 WS-EXP                 BINARY-LONG.
 01 WS-OBS                 BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-ENTITY              BINARY-LONG.
 01 WS-SLOT                BINARY-LONG.
 01 WS-SERIALIZER          BINARY-LONG.
 01 WS-INT                 BINARY-LONG.
 01 WS-FLOAT               FLOAT-SHORT VALUE 0.
 PROCEDURE DIVISION.
     CALL "CL-INIT" USING CLIENT-STATE
     MOVE 0 TO SK-U
     MOVE 0 TO CL-NOW-MS
     MOVE 0 TO WS-EYE(1) WS-EYE(2) WS-EYE(3)
     MOVE 32 TO AT-W
     MOVE 16 TO AT-H
     MOVE 3 TO AT-SPRITE-COUNT
     MOVE "minecraft:block/fire_0" TO AT-NAME(2)
     MOVE 22 TO AT-NAME-LENGTH(2)
     MOVE 0 TO AT-X(2) AT-Y(2)
     MOVE 16 TO AT-SW(2) AT-SH(2)
     MOVE "minecraft:block/fire_1" TO AT-NAME(3)
     MOVE 22 TO AT-NAME-LENGTH(3)
     MOVE 16 TO AT-X(3)
     MOVE 0 TO AT-Y(3)
     MOVE 16 TO AT-SW(3) AT-SH(3)
*>   A burning cow of 0.6 x 1.8 at (0, 0, 5): the camera yaw 0 looks along +z.
     MOVE 1 TO EN-COUNT
     MOVE 1 TO EN-USED(1) EN-VANILLA(1)
     MOVE "cow" TO EN-KEY(1)
     MOVE 0 TO EN-X(1) EN-Y(1)
     MOVE 5 TO EN-Z(1)
     MOVE 0.3 TO EN-BOX-HALF(1)
     MOVE 1.8 TO EN-BOX-HEIGHT(1)
     MOVE 1 TO EN-FLAGS(1)
     MOVE 0 TO PL-YAW
     PERFORM RUN-FIRE
     MOVE "acceptance US15 34-1§7.4 a burning 0.6 x 1.8 entity draws five flame quads of six vertices" TO WS-CASE
     MOVE 30 TO WS-EXP
     MOVE RL-GI-COUNT TO WS-OBS
     PERFORM CHK
*>   Quad 0 (fire_0, mirrored): corners TL, TR, BR; the sprite is the left half of the atlas (u 0 to 0.5), so the mirrored left corner takes u1 = 0.5.
     MOVE "acceptance US15 34-1§7.4 quad 0 is fire_0 mirrored: its top-left u is the sprite's u1 (500 thousandths)" TO WS-CASE
     MOVE 500 TO WS-EXP
     COMPUTE WS-OBS = FUNCTION INTEGER(RL-GI-U(1) * 1000 + 0.5)
     PERFORM CHK
     MOVE "acceptance US15 34-1§7.4 quad 0 top-right u is the sprite's u0" TO WS-CASE
     MOVE 0 TO WS-EXP
     COMPUTE WS-OBS = FUNCTION INTEGER(RL-GI-U(2) * 1000 + 0.5)
     PERFORM CHK
     MOVE "acceptance US15 34-1§7.4 the top edge is at v0 and the bottom edge at v1" TO WS-CASE
     MOVE 1000 TO WS-EXP
     COMPUTE WS-OBS = FUNCTION INTEGER(RL-GI-V(3) * 1000 + 0.5) - FUNCTION INTEGER(RL-GI-V(1) * 1000 + 0.5)
     PERFORM CHK
     MOVE "acceptance US15 34-1§7.4 quad 1 is fire_1 mirrored: its top-left u is 1000 thousandths" TO WS-CASE
     MOVE 1000 TO WS-EXP
     COMPUTE WS-OBS = FUNCTION INTEGER(RL-GI-U(7) * 1000 + 0.5)
     PERFORM CHK
     MOVE "acceptance US15 34-1§7.4 quad 2 is fire_0 not mirrored: top-left u 0" TO WS-CASE
     MOVE 0 TO WS-EXP
     COMPUTE WS-OBS = FUNCTION INTEGER(RL-GI-U(13) * 1000 + 0.5)
     PERFORM CHK
     MOVE "acceptance US15 34-1§7.4 quad 3 is fire_1 not mirrored: top-left u 500" TO WS-CASE
     MOVE 500 TO WS-EXP
     COMPUTE WS-OBS = FUNCTION INTEGER(RL-GI-U(19) * 1000 + 0.5)
     PERFORM CHK
*>   Geometry of quad 0: bottom at y 0, top at 1.4 x 0.84 = 1.176; width 2 x 0.5 x 0.84 = 0.84 across the camera.
     MOVE "acceptance US15 34-1§7.4 quad 0 top edge is 1.4 s = 1176 thousandths above the feet" TO WS-CASE
     MOVE 1176 TO WS-EXP
     COMPUTE WS-OBS = FUNCTION INTEGER(RL-GI-Y(1) * 1000 + 0.5)
     PERFORM CHK
     MOVE "acceptance US15 34-1§7.4 quad 0 bottom edge is at the feet" TO WS-CASE
     MOVE 0 TO WS-EXP
     COMPUTE WS-OBS = FUNCTION INTEGER(RL-GI-Y(3) * 1000 + 0.5)
     PERFORM CHK
     MOVE "acceptance US15 34-1§7.4 quad 0 is 2 x 0.5 x 0.84 = 840 thousandths wide" TO WS-CASE
     MOVE 840 TO WS-EXP
     COMPUTE WS-OBS = FUNCTION INTEGER(FUNCTION ABS(RL-GI-X(1) - RL-GI-X(2)) * 1000 + 0.5)
     PERFORM CHK
     MOVE "acceptance US15 34-1§7.4 quad 1 sits 0.45 s = 378 thousandths higher" TO WS-CASE
     MOVE 378 TO WS-EXP
     COMPUTE WS-OBS = FUNCTION INTEGER(RL-GI-Y(9) * 1000 + 0.5)
     PERFORM CHK
     MOVE "acceptance US15 34-1§7.4 quad 1 is 0.9 times as wide: 756 thousandths" TO WS-CASE
     MOVE 756 TO WS-EXP
     COMPUTE WS-OBS = FUNCTION INTEGER(FUNCTION ABS(RL-GI-X(7) - RL-GI-X(8)) * 1000 + 0.5)
     PERFORM CHK
     MOVE "acceptance US15 34-1§7.4 the flames are full bright" TO WS-CASE
     MOVE 1000 TO WS-EXP
     COMPUTE WS-OBS = FUNCTION INTEGER(RL-GI-B(1) * 1000 + 0.5)
     PERFORM CHK
*>   Quad 0 stands along the camera's look direction: z = 5 + 0.84 x (0.3 - int(2.1429) x 0.02) = 5.2184 (V13 of 34-1: initial z translate 0.26).
     MOVE "acceptance US15 34-1§7.4 quad 0 is shifted along the look direction by s (0.3 - int(h) 0.02) = 218 thousandths" TO WS-CASE
     MOVE 5218 TO WS-EXP
     COMPUTE WS-OBS = FUNCTION INTEGER(RL-GI-Z(1) * 1000 + 0.5)
     PERFORM CHK
*>   The flag byte with other bits still burns; without bit 0 it does not.
     MOVE 3 TO EN-FLAGS(1)
     PERFORM RUN-FIRE
     MOVE "acceptance US15 18-1.4 flags 3 (sneaking and on fire) still burn" TO WS-CASE
     MOVE 30 TO WS-EXP
     MOVE RL-GI-COUNT TO WS-OBS
     PERFORM CHK
     MOVE 2 TO EN-FLAGS(1)
     PERFORM RUN-FIRE
     MOVE "acceptance US15 18-1.4 flags 2 (sneaking only) draw no flame" TO WS-CASE
     MOVE 0 TO WS-EXP
     MOVE RL-GI-COUNT TO WS-OBS
     PERFORM CHK
*>   A row of a stand-in world (no attack box) is 0.6 x 1.8.
     MOVE 1 TO EN-FLAGS(1)
     MOVE 0 TO EN-BOX-HEIGHT(1) EN-BOX-HALF(1)
     PERFORM RUN-FIRE
     MOVE "acceptance US15 34-1§7.4 a row with no box is taken as 0.6 x 1.8 (five quads)" TO WS-CASE
     MOVE 30 TO WS-EXP
     MOVE RL-GI-COUNT TO WS-OBS
     PERFORM CHK
*>   A small entity (0.3 x 0.3: s = 0.42, h = 0.714 then 0.264) has two quads.
     MOVE 0.15 TO EN-BOX-HALF(1)
     MOVE 0.3 TO EN-BOX-HEIGHT(1)
     PERFORM RUN-FIRE
     MOVE "acceptance US15 34-1§7.4 a 0.3 x 0.3 entity draws two quads" TO WS-CASE
     MOVE 12 TO WS-EXP
     MOVE RL-GI-COUNT TO WS-OBS
     PERFORM CHK
*>   Unused rows and unburning rows draw nothing; a missing sprite draws nothing.
     MOVE 0 TO EN-USED(1)
     PERFORM RUN-FIRE
     MOVE "acceptance US15 34-1§7.4 an unused row draws no flame" TO WS-CASE
     MOVE 0 TO WS-EXP
     MOVE RL-GI-COUNT TO WS-OBS
     PERFORM CHK
     MOVE 1 TO EN-USED(1)
     MOVE 0.3 TO EN-BOX-HALF(1)
     MOVE 1.8 TO EN-BOX-HEIGHT(1)
     MOVE "minecraft:block/nope_0" TO AT-NAME(2)
     MOVE "minecraft:block/nope_1" TO AT-NAME(3)
     PERFORM RUN-FIRE
     MOVE "acceptance US15 34-1§7.4 without the fire sprites in the atlas no flame is drawn" TO WS-CASE
     MOVE 0 TO WS-EXP
     MOVE RL-GI-COUNT TO WS-OBS
     PERFORM CHK
     MOVE "minecraft:block/fire_0" TO AT-NAME(2)
     MOVE "minecraft:block/nope_1" TO AT-NAME(3)
     PERFORM RUN-FIRE
     MOVE "acceptance US15 34-1§7.4 with only fire_0 in the atlas both layers use it" TO WS-CASE
     MOVE 30 TO WS-EXP
     MOVE RL-GI-COUNT TO WS-OBS
     PERFORM CHK
     MOVE "minecraft:block/nope_0" TO AT-NAME(2)
     MOVE "minecraft:block/fire_1" TO AT-NAME(3)
     PERFORM RUN-FIRE
     MOVE "acceptance US15 34-1§7.4 with only fire_1 in the atlas both layers use it" TO WS-CASE
     MOVE 30 TO WS-EXP
     MOVE RL-GI-COUNT TO WS-OBS
     PERFORM CHK
     MOVE "minecraft:block/fire_0" TO AT-NAME(2)
*>   The vertex capacity bounds the mesh.
     MOVE 256 TO EN-COUNT
     PERFORM VARYING WS-I FROM 2 BY 1 UNTIL WS-I > 256
         MOVE EN-ENTITY(1) TO EN-ENTITY(WS-I)
     END-PERFORM
     PERFORM RUN-FIRE
     MOVE "acceptance US15 34-1§7.4 the flame mesh stops at the vertex capacity (204 entities of 30)" TO WS-CASE
     MOVE 6120 TO WS-EXP
     MOVE RL-GI-COUNT TO WS-OBS
     PERFORM CHK
*>   The local player: third-person modes only.
     MOVE 0 TO EN-COUNT
     MOVE 1 TO PL-ON-FIRE
     MOVE 0 TO CL-CAMERA
     PERFORM RUN-FIRE
     MOVE "acceptance US15 34-1§7.4 the local player is not drawn burning in first person" TO WS-CASE
     MOVE 0 TO WS-EXP
     MOVE RL-GI-COUNT TO WS-OBS
     PERFORM CHK
     MOVE 1 TO CL-CAMERA
     PERFORM RUN-FIRE
     MOVE "acceptance US15 34-1§7.4 the local player burns in the third-person view (0.6 x 1.8: five quads)" TO WS-CASE
     MOVE 30 TO WS-EXP
     MOVE RL-GI-COUNT TO WS-OBS
     PERFORM CHK
     MOVE 0 TO PL-ON-FIRE
     PERFORM RUN-FIRE
     MOVE "acceptance US15 34-1§7.4 the local player not on fire draws no flame" TO WS-CASE
     MOVE 0 TO WS-EXP
     MOVE RL-GI-COUNT TO WS-OBS
     PERFORM CHK
*>   GROUND-ITEMS-MESH carries the flames into the frame's block-atlas mesh.
     MOVE 1 TO PL-ON-FIRE
     MOVE 1 TO WS-I
     MOVE 1 TO CL-CAMERA
     CALL "GROUND-ITEMS-MESH" USING CLIENT-STATE WS-EYE-TABLE
     MOVE "acceptance US15 34-1§7.4 the frame's mesh of the block atlas holds the flames" TO WS-CASE
     MOVE 30 TO WS-EXP
     MOVE RL-GI-COUNT TO WS-OBS
     PERFORM CHK
*>   Set Entity Data entry 0 (a Byte) of the local player's id sets the flag.
     MOVE 0 TO PL-ON-FIRE
     MOVE 77 TO PL-ENTITY-ID
     MOVE 77 TO WS-ENTITY
     MOVE 0 TO WS-SLOT WS-SERIALIZER
     MOVE 1 TO WS-INT
     CALL "HUD-ENTITY-DATA" USING CLIENT-STATE WS-ENTITY WS-SLOT WS-SERIALIZER WS-INT WS-FLOAT
     MOVE "acceptance US15 18-1.4 Set Entity Data entry 0 bit 0 of the local player sets PL-ON-FIRE" TO WS-CASE
     MOVE 1 TO WS-EXP
     MOVE PL-ON-FIRE TO WS-OBS
     PERFORM CHK
     MOVE 2 TO WS-INT
     CALL "HUD-ENTITY-DATA" USING CLIENT-STATE WS-ENTITY WS-SLOT WS-SERIALIZER WS-INT WS-FLOAT
     MOVE "acceptance US15 18-1.4 flags without bit 0 clear PL-ON-FIRE" TO WS-CASE
     MOVE 0 TO WS-EXP
     MOVE PL-ON-FIRE TO WS-OBS
     PERFORM CHK
     STOP RUN.
 RUN-FIRE.
     MOVE 0 TO RL-GI-COUNT
     CALL "ENTITY-FIRE-MESH" USING CLIENT-STATE WS-EYE-TABLE.
 CHK.
     MOVE "N" TO TL-MODE
     MOVE WS-CASE TO TL-CASE
     MOVE WS-EXP TO TL-EXPECTED-N
     MOVE WS-OBS TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-ENTITY-FIRE.
