*> Test of 31-8 section 2, Game events as seen by block-entity listeners (core/src/be-31-8.cob; T0969): notification radius, the section box, the listener radius test, the delivery order and the registration lifecycle.
*> Each case runs its statements and shows the items joined by single spaces ("n" integers, "f" floats x 1e6, "t" text up to a stored length).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-BE-31-8-2.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY BESTATE.
 COPY PROTO.
 COPY COREAPI.
 COPY CITEMS.
 01 WS-SHOW                PIC -(10)9.
 01 WS-PTR                 BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-IDX                 BINARY-LONG.
 01 WS-LEN                 BINARY-LONG.
 01 WS-OUT                 PIC X(8192).
 01 WS-CAPACITY            BINARY-LONG VALUE 8192.
 01 WS-T10                 BINARY-LONG VALUE 10.
 01 WS-FORM                BINARY-LONG VALUE 1.
 01 WS-D                   BINARY-LONG VALUE 1.
 01 WS-KEY                 PIC X(48).
 01 WS-NM                  PIC X(32).
 01 WS-NML                 BINARY-LONG.
 01 WS-SV                  PIC X(256).
 01 WS-SVL                 BINARY-LONG.
 01 WS-NV                  BINARY-LONG.
 01 WS-LV                  BINARY-DOUBLE.
 01 WS-FV                  FLOAT-SHORT.
 01 WS-IA.
    05 WS-IAV              BINARY-LONG OCCURS 8 TIMES.
 01 WS-LT                  BINARY-LONG.
 01 WS-LC                  BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-ITEM                BINARY-LONG.
 01 WS-KP                  BINARY-LONG VALUE 0.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-A                 BINARY-LONG.
 01 WS-B                 BINARY-LONG.
 01 WS-C                 BINARY-LONG.
 01 WS-E                 BINARY-LONG.
 01 WS-F                 BINARY-LONG.
 01 WS-G                 BINARY-LONG.
 01 WS-H                 BINARY-LONG.
 01 WS-P                 BINARY-LONG.
 01 WS-Q                 BINARY-LONG.
 01 WS-R                 BINARY-LONG.
 01 WS-S                 BINARY-LONG.
 01 WS-U                 BINARY-LONG.
 01 WS-V                 BINARY-LONG.
 01 WS-W                 BINARY-LONG.
 01 WS-EV                BINARY-LONG.
 01 WS-O1                 BINARY-LONG.
 01 WS-O2                 BINARY-LONG.
 01 WS-O3                 BINARY-LONG.
 01 WS-O4                 BINARY-LONG.
 01 WS-O5                 BINARY-LONG.
 01 WS-O6                 BINARY-LONG.
 01 WS-O7                 BINARY-LONG.
 01 WS-FA                FLOAT-LONG.
 01 WS-FB                FLOAT-LONG.
 01 WS-FC                FLOAT-LONG.
 01 WS-FD                FLOAT-LONG.
 01 WS-FE                FLOAT-LONG.
 01 WS-FF                FLOAT-LONG.
 01 WS-FG                FLOAT-LONG.
 01 WS-FH                FLOAT-LONG.
 01 WS-FS1                FLOAT-SHORT.
 01 WS-FS2                FLOAT-SHORT.
 01 WS-FS3                FLOAT-SHORT.
 01 WS-FS4                FLOAT-SHORT.
 01 WS-N24                PIC X(24).
 01 WS-N48                PIC X(48).
 01 WS-T64                PIC X(64).
 01 WS-T256               PIC X(256).
 01 WS-T2                 PIC X(64).
 01 WS-TAB.
    05 WS-TV              BINARY-LONG OCCURS 64 TIMES.
 01 WS-TAB2.
    05 WS-TV2            BINARY-LONG OCCURS 64 TIMES.
 01 WS-TAB3.
    05 WS-TV3            BINARY-LONG OCCURS 192 TIMES.
 01 WS-LONG1              BINARY-DOUBLE.
 01 WS-LONG2              BINARY-DOUBLE.
 PROCEDURE DIVISION.
     MOVE "T" TO TL-MODE
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     MOVE "acceptance US12 31-8§2 Game events as seen by block-entity listeners: notification radius (2.1): 58 of the 61 events use 16, jukebox_play and jukebox_stop_play 10, shriek 32 (counts of 16, 10, 32)" TO TL-CASE
     PERFORM BEGIN-CASE
     MOVE 0 TO WS-E WS-F WS-G
     MOVE SPACES TO WS-N48
     MOVE "step" TO WS-N48
     MOVE 4 TO WS-SVL
     CALL "BE8-EVENT-RADIUS" USING WS-N48 WS-SVL WS-B
     IF WS-B = 16
     ADD 1 TO WS-E
     END-IF
     IF WS-B = 10
     ADD 1 TO WS-F
     END-IF
     IF WS-B = 32
     ADD 1 TO WS-G
     END-IF
     MOVE SPACES TO WS-N48
     MOVE "swim" TO WS-N48
     MOVE 4 TO WS-SVL
     CALL "BE8-EVENT-RADIUS" USING WS-N48 WS-SVL WS-B
     IF WS-B = 16
     ADD 1 TO WS-E
     END-IF
     IF WS-B = 10
     ADD 1 TO WS-F
     END-IF
     IF WS-B = 32
     ADD 1 TO WS-G
     END-IF
     MOVE SPACES TO WS-N48
     MOVE "flap" TO WS-N48
     MOVE 4 TO WS-SVL
     CALL "BE8-EVENT-RADIUS" USING WS-N48 WS-SVL WS-B
     IF WS-B = 16
     ADD 1 TO WS-E
     END-IF
     IF WS-B = 10
     ADD 1 TO WS-F
     END-IF
     IF WS-B = 32
     ADD 1 TO WS-G
     END-IF
     MOVE SPACES TO WS-N48
     MOVE "projectile_land" TO WS-N48
     MOVE 15 TO WS-SVL
     CALL "BE8-EVENT-RADIUS" USING WS-N48 WS-SVL WS-B
     IF WS-B = 16
     ADD 1 TO WS-E
     END-IF
     IF WS-B = 10
     ADD 1 TO WS-F
     END-IF
     IF WS-B = 32
     ADD 1 TO WS-G
     END-IF
     MOVE SPACES TO WS-N48
     MOVE "hit_ground" TO WS-N48
     MOVE 10 TO WS-SVL
     CALL "BE8-EVENT-RADIUS" USING WS-N48 WS-SVL WS-B
     IF WS-B = 16
     ADD 1 TO WS-E
     END-IF
     IF WS-B = 10
     ADD 1 TO WS-F
     END-IF
     IF WS-B = 32
     ADD 1 TO WS-G
     END-IF
     MOVE SPACES TO WS-N48
     MOVE "splash" TO WS-N48
     MOVE 6 TO WS-SVL
     CALL "BE8-EVENT-RADIUS" USING WS-N48 WS-SVL WS-B
     IF WS-B = 16
     ADD 1 TO WS-E
     END-IF
     IF WS-B = 10
     ADD 1 TO WS-F
     END-IF
     IF WS-B = 32
     ADD 1 TO WS-G
     END-IF
     MOVE SPACES TO WS-N48
     MOVE "bounce" TO WS-N48
     MOVE 6 TO WS-SVL
     CALL "BE8-EVENT-RADIUS" USING WS-N48 WS-SVL WS-B
     IF WS-B = 16
     ADD 1 TO WS-E
     END-IF
     IF WS-B = 10
     ADD 1 TO WS-F
     END-IF
     IF WS-B = 32
     ADD 1 TO WS-G
     END-IF
     MOVE SPACES TO WS-N48
     MOVE "item_interact_finish" TO WS-N48
     MOVE 20 TO WS-SVL
     CALL "BE8-EVENT-RADIUS" USING WS-N48 WS-SVL WS-B
     IF WS-B = 16
     ADD 1 TO WS-E
     END-IF
     IF WS-B = 10
     ADD 1 TO WS-F
     END-IF
     IF WS-B = 32
     ADD 1 TO WS-G
     END-IF
     MOVE SPACES TO WS-N48
     MOVE "projectile_shoot" TO WS-N48
     MOVE 16 TO WS-SVL
     CALL "BE8-EVENT-RADIUS" USING WS-N48 WS-SVL WS-B
     IF WS-B = 16
     ADD 1 TO WS-E
     END-IF
     IF WS-B = 10
     ADD 1 TO WS-F
     END-IF
     IF WS-B = 32
     ADD 1 TO WS-G
     END-IF
     MOVE SPACES TO WS-N48
     MOVE "instrument_play" TO WS-N48
     MOVE 15 TO WS-SVL
     CALL "BE8-EVENT-RADIUS" USING WS-N48 WS-SVL WS-B
     IF WS-B = 16
     ADD 1 TO WS-E
     END-IF
     IF WS-B = 10
     ADD 1 TO WS-F
     END-IF
     IF WS-B = 32
     ADD 1 TO WS-G
     END-IF
     MOVE SPACES TO WS-N48
     MOVE "entity_action" TO WS-N48
     MOVE 13 TO WS-SVL
     CALL "BE8-EVENT-RADIUS" USING WS-N48 WS-SVL WS-B
     IF WS-B = 16
     ADD 1 TO WS-E
     END-IF
     IF WS-B = 10
     ADD 1 TO WS-F
     END-IF
     IF WS-B = 32
     ADD 1 TO WS-G
     END-IF
     MOVE SPACES TO WS-N48
     MOVE "elytra_glide" TO WS-N48
     MOVE 12 TO WS-SVL
     CALL "BE8-EVENT-RADIUS" USING WS-N48 WS-SVL WS-B
     IF WS-B = 16
     ADD 1 TO WS-E
     END-IF
     IF WS-B = 10
     ADD 1 TO WS-F
     END-IF
     IF WS-B = 32
     ADD 1 TO WS-G
     END-IF
     MOVE SPACES TO WS-N48
     MOVE "unequip" TO WS-N48
     MOVE 7 TO WS-SVL
     CALL "BE8-EVENT-RADIUS" USING WS-N48 WS-SVL WS-B
     IF WS-B = 16
     ADD 1 TO WS-E
     END-IF
     IF WS-B = 10
     ADD 1 TO WS-F
     END-IF
     IF WS-B = 32
     ADD 1 TO WS-G
     END-IF
     MOVE SPACES TO WS-N48
     MOVE "entity_dismount" TO WS-N48
     MOVE 15 TO WS-SVL
     CALL "BE8-EVENT-RADIUS" USING WS-N48 WS-SVL WS-B
     IF WS-B = 16
     ADD 1 TO WS-E
     END-IF
     IF WS-B = 10
     ADD 1 TO WS-F
     END-IF
     IF WS-B = 32
     ADD 1 TO WS-G
     END-IF
     MOVE SPACES TO WS-N48
     MOVE "equip" TO WS-N48
     MOVE 5 TO WS-SVL
     CALL "BE8-EVENT-RADIUS" USING WS-N48 WS-SVL WS-B
     IF WS-B = 16
     ADD 1 TO WS-E
     END-IF
     IF WS-B = 10
     ADD 1 TO WS-F
     END-IF
     IF WS-B = 32
     ADD 1 TO WS-G
     END-IF
     MOVE SPACES TO WS-N48
     MOVE "entity_interact" TO WS-N48
     MOVE 15 TO WS-SVL
     CALL "BE8-EVENT-RADIUS" USING WS-N48 WS-SVL WS-B
     IF WS-B = 16
     ADD 1 TO WS-E
     END-IF
     IF WS-B = 10
     ADD 1 TO WS-F
     END-IF
     IF WS-B = 32
     ADD 1 TO WS-G
     END-IF
     MOVE SPACES TO WS-N48
     MOVE "shear" TO WS-N48
     MOVE 5 TO WS-SVL
     CALL "BE8-EVENT-RADIUS" USING WS-N48 WS-SVL WS-B
     IF WS-B = 16
     ADD 1 TO WS-E
     END-IF
     IF WS-B = 10
     ADD 1 TO WS-F
     END-IF
     IF WS-B = 32
     ADD 1 TO WS-G
     END-IF
     MOVE SPACES TO WS-N48
     MOVE "entity_mount" TO WS-N48
     MOVE 12 TO WS-SVL
     CALL "BE8-EVENT-RADIUS" USING WS-N48 WS-SVL WS-B
     IF WS-B = 16
     ADD 1 TO WS-E
     END-IF
     IF WS-B = 10
     ADD 1 TO WS-F
     END-IF
     IF WS-B = 32
     ADD 1 TO WS-G
     END-IF
     MOVE SPACES TO WS-N48
     MOVE "entity_damage" TO WS-N48
     MOVE 13 TO WS-SVL
     CALL "BE8-EVENT-RADIUS" USING WS-N48 WS-SVL WS-B
     IF WS-B = 16
     ADD 1 TO WS-E
     END-IF
     IF WS-B = 10
     ADD 1 TO WS-F
     END-IF
     IF WS-B = 32
     ADD 1 TO WS-G
     END-IF
     MOVE SPACES TO WS-N48
     MOVE "drink" TO WS-N48
     MOVE 5 TO WS-SVL
     CALL "BE8-EVENT-RADIUS" USING WS-N48 WS-SVL WS-B
     IF WS-B = 16
     ADD 1 TO WS-E
     END-IF
     IF WS-B = 10
     ADD 1 TO WS-F
     END-IF
     IF WS-B = 32
     ADD 1 TO WS-G
     END-IF
     MOVE SPACES TO WS-N48
     MOVE "eat" TO WS-N48
     MOVE 3 TO WS-SVL
     CALL "BE8-EVENT-RADIUS" USING WS-N48 WS-SVL WS-B
     IF WS-B = 16
     ADD 1 TO WS-E
     END-IF
     IF WS-B = 10
     ADD 1 TO WS-F
     END-IF
     IF WS-B = 32
     ADD 1 TO WS-G
     END-IF
     MOVE SPACES TO WS-N48
     MOVE "container_close" TO WS-N48
     MOVE 15 TO WS-SVL
     CALL "BE8-EVENT-RADIUS" USING WS-N48 WS-SVL WS-B
     IF WS-B = 16
     ADD 1 TO WS-E
     END-IF
     IF WS-B = 10
     ADD 1 TO WS-F
     END-IF
     IF WS-B = 32
     ADD 1 TO WS-G
     END-IF
     MOVE SPACES TO WS-N48
     MOVE "block_close" TO WS-N48
     MOVE 11 TO WS-SVL
     CALL "BE8-EVENT-RADIUS" USING WS-N48 WS-SVL WS-B
     IF WS-B = 16
     ADD 1 TO WS-E
     END-IF
     IF WS-B = 10
     ADD 1 TO WS-F
     END-IF
     IF WS-B = 32
     ADD 1 TO WS-G
     END-IF
     MOVE SPACES TO WS-N48
     MOVE "block_deactivate" TO WS-N48
     MOVE 16 TO WS-SVL
     CALL "BE8-EVENT-RADIUS" USING WS-N48 WS-SVL WS-B
     IF WS-B = 16
     ADD 1 TO WS-E
     END-IF
     IF WS-B = 10
     ADD 1 TO WS-F
     END-IF
     IF WS-B = 32
     ADD 1 TO WS-G
     END-IF
     MOVE SPACES TO WS-N48
     MOVE "block_detach" TO WS-N48
     MOVE 12 TO WS-SVL
     CALL "BE8-EVENT-RADIUS" USING WS-N48 WS-SVL WS-B
     IF WS-B = 16
     ADD 1 TO WS-E
     END-IF
     IF WS-B = 10
     ADD 1 TO WS-F
     END-IF
     IF WS-B = 32
     ADD 1 TO WS-G
     END-IF
     MOVE SPACES TO WS-N48
     MOVE "container_open" TO WS-N48
     MOVE 14 TO WS-SVL
     CALL "BE8-EVENT-RADIUS" USING WS-N48 WS-SVL WS-B
     IF WS-B = 16
     ADD 1 TO WS-E
     END-IF
     IF WS-B = 10
     ADD 1 TO WS-F
     END-IF
     IF WS-B = 32
     ADD 1 TO WS-G
     END-IF
     MOVE SPACES TO WS-N48
     MOVE "block_open" TO WS-N48
     MOVE 10 TO WS-SVL
     CALL "BE8-EVENT-RADIUS" USING WS-N48 WS-SVL WS-B
     IF WS-B = 16
     ADD 1 TO WS-E
     END-IF
     IF WS-B = 10
     ADD 1 TO WS-F
     END-IF
     IF WS-B = 32
     ADD 1 TO WS-G
     END-IF
     MOVE SPACES TO WS-N48
     MOVE "block_activate" TO WS-N48
     MOVE 14 TO WS-SVL
     CALL "BE8-EVENT-RADIUS" USING WS-N48 WS-SVL WS-B
     IF WS-B = 16
     ADD 1 TO WS-E
     END-IF
     IF WS-B = 10
     ADD 1 TO WS-F
     END-IF
     IF WS-B = 32
     ADD 1 TO WS-G
     END-IF
     MOVE SPACES TO WS-N48
     MOVE "block_attach" TO WS-N48
     MOVE 12 TO WS-SVL
     CALL "BE8-EVENT-RADIUS" USING WS-N48 WS-SVL WS-B
     IF WS-B = 16
     ADD 1 TO WS-E
     END-IF
     IF WS-B = 10
     ADD 1 TO WS-F
     END-IF
     IF WS-B = 32
     ADD 1 TO WS-G
     END-IF
     MOVE SPACES TO WS-N48
     MOVE "prime_fuse" TO WS-N48
     MOVE 10 TO WS-SVL
     CALL "BE8-EVENT-RADIUS" USING WS-N48 WS-SVL WS-B
     IF WS-B = 16
     ADD 1 TO WS-E
     END-IF
     IF WS-B = 10
     ADD 1 TO WS-F
     END-IF
     IF WS-B = 32
     ADD 1 TO WS-G
     END-IF
     MOVE SPACES TO WS-N48
     MOVE "note_block_play" TO WS-N48
     MOVE 15 TO WS-SVL
     CALL "BE8-EVENT-RADIUS" USING WS-N48 WS-SVL WS-B
     IF WS-B = 16
     ADD 1 TO WS-E
     END-IF
     IF WS-B = 10
     ADD 1 TO WS-F
     END-IF
     IF WS-B = 32
     ADD 1 TO WS-G
     END-IF
     MOVE SPACES TO WS-N48
     MOVE "block_change" TO WS-N48
     MOVE 12 TO WS-SVL
     CALL "BE8-EVENT-RADIUS" USING WS-N48 WS-SVL WS-B
     IF WS-B = 16
     ADD 1 TO WS-E
     END-IF
     IF WS-B = 10
     ADD 1 TO WS-F
     END-IF
     IF WS-B = 32
     ADD 1 TO WS-G
     END-IF
     MOVE SPACES TO WS-N48
     MOVE "block_destroy" TO WS-N48
     MOVE 13 TO WS-SVL
     CALL "BE8-EVENT-RADIUS" USING WS-N48 WS-SVL WS-B
     IF WS-B = 16
     ADD 1 TO WS-E
     END-IF
     IF WS-B = 10
     ADD 1 TO WS-F
     END-IF
     IF WS-B = 32
     ADD 1 TO WS-G
     END-IF
     MOVE SPACES TO WS-N48
     MOVE "fluid_pickup" TO WS-N48
     MOVE 12 TO WS-SVL
     CALL "BE8-EVENT-RADIUS" USING WS-N48 WS-SVL WS-B
     IF WS-B = 16
     ADD 1 TO WS-E
     END-IF
     IF WS-B = 10
     ADD 1 TO WS-F
     END-IF
     IF WS-B = 32
     ADD 1 TO WS-G
     END-IF
     MOVE SPACES TO WS-N48
     MOVE "block_place" TO WS-N48
     MOVE 11 TO WS-SVL
     CALL "BE8-EVENT-RADIUS" USING WS-N48 WS-SVL WS-B
     IF WS-B = 16
     ADD 1 TO WS-E
     END-IF
     IF WS-B = 10
     ADD 1 TO WS-F
     END-IF
     IF WS-B = 32
     ADD 1 TO WS-G
     END-IF
     MOVE SPACES TO WS-N48
     MOVE "fluid_place" TO WS-N48
     MOVE 11 TO WS-SVL
     CALL "BE8-EVENT-RADIUS" USING WS-N48 WS-SVL WS-B
     IF WS-B = 16
     ADD 1 TO WS-E
     END-IF
     IF WS-B = 10
     ADD 1 TO WS-F
     END-IF
     IF WS-B = 32
     ADD 1 TO WS-G
     END-IF
     MOVE SPACES TO WS-N48
     MOVE "entity_place" TO WS-N48
     MOVE 12 TO WS-SVL
     CALL "BE8-EVENT-RADIUS" USING WS-N48 WS-SVL WS-B
     IF WS-B = 16
     ADD 1 TO WS-E
     END-IF
     IF WS-B = 10
     ADD 1 TO WS-F
     END-IF
     IF WS-B = 32
     ADD 1 TO WS-G
     END-IF
     MOVE SPACES TO WS-N48
     MOVE "lightning_strike" TO WS-N48
     MOVE 16 TO WS-SVL
     CALL "BE8-EVENT-RADIUS" USING WS-N48 WS-SVL WS-B
     IF WS-B = 16
     ADD 1 TO WS-E
     END-IF
     IF WS-B = 10
     ADD 1 TO WS-F
     END-IF
     IF WS-B = 32
     ADD 1 TO WS-G
     END-IF
     MOVE SPACES TO WS-N48
     MOVE "teleport" TO WS-N48
     MOVE 8 TO WS-SVL
     CALL "BE8-EVENT-RADIUS" USING WS-N48 WS-SVL WS-B
     IF WS-B = 16
     ADD 1 TO WS-E
     END-IF
     IF WS-B = 10
     ADD 1 TO WS-F
     END-IF
     IF WS-B = 32
     ADD 1 TO WS-G
     END-IF
     MOVE SPACES TO WS-N48
     MOVE "entity_die" TO WS-N48
     MOVE 10 TO WS-SVL
     CALL "BE8-EVENT-RADIUS" USING WS-N48 WS-SVL WS-B
     IF WS-B = 16
     ADD 1 TO WS-E
     END-IF
     IF WS-B = 10
     ADD 1 TO WS-F
     END-IF
     IF WS-B = 32
     ADD 1 TO WS-G
     END-IF
     MOVE SPACES TO WS-N48
     MOVE "explode" TO WS-N48
     MOVE 7 TO WS-SVL
     CALL "BE8-EVENT-RADIUS" USING WS-N48 WS-SVL WS-B
     IF WS-B = 16
     ADD 1 TO WS-E
     END-IF
     IF WS-B = 10
     ADD 1 TO WS-F
     END-IF
     IF WS-B = 32
     ADD 1 TO WS-G
     END-IF
     MOVE SPACES TO WS-N48
     MOVE "resonate_1" TO WS-N48
     MOVE 10 TO WS-SVL
     CALL "BE8-EVENT-RADIUS" USING WS-N48 WS-SVL WS-B
     IF WS-B = 16
     ADD 1 TO WS-E
     END-IF
     IF WS-B = 10
     ADD 1 TO WS-F
     END-IF
     IF WS-B = 32
     ADD 1 TO WS-G
     END-IF
     MOVE SPACES TO WS-N48
     MOVE "resonate_2" TO WS-N48
     MOVE 10 TO WS-SVL
     CALL "BE8-EVENT-RADIUS" USING WS-N48 WS-SVL WS-B
     IF WS-B = 16
     ADD 1 TO WS-E
     END-IF
     IF WS-B = 10
     ADD 1 TO WS-F
     END-IF
     IF WS-B = 32
     ADD 1 TO WS-G
     END-IF
     MOVE SPACES TO WS-N48
     MOVE "resonate_3" TO WS-N48
     MOVE 10 TO WS-SVL
     CALL "BE8-EVENT-RADIUS" USING WS-N48 WS-SVL WS-B
     IF WS-B = 16
     ADD 1 TO WS-E
     END-IF
     IF WS-B = 10
     ADD 1 TO WS-F
     END-IF
     IF WS-B = 32
     ADD 1 TO WS-G
     END-IF
     MOVE SPACES TO WS-N48
     MOVE "resonate_4" TO WS-N48
     MOVE 10 TO WS-SVL
     CALL "BE8-EVENT-RADIUS" USING WS-N48 WS-SVL WS-B
     IF WS-B = 16
     ADD 1 TO WS-E
     END-IF
     IF WS-B = 10
     ADD 1 TO WS-F
     END-IF
     IF WS-B = 32
     ADD 1 TO WS-G
     END-IF
     MOVE SPACES TO WS-N48
     MOVE "resonate_5" TO WS-N48
     MOVE 10 TO WS-SVL
     CALL "BE8-EVENT-RADIUS" USING WS-N48 WS-SVL WS-B
     IF WS-B = 16
     ADD 1 TO WS-E
     END-IF
     IF WS-B = 10
     ADD 1 TO WS-F
     END-IF
     IF WS-B = 32
     ADD 1 TO WS-G
     END-IF
     MOVE SPACES TO WS-N48
     MOVE "resonate_6" TO WS-N48
     MOVE 10 TO WS-SVL
     CALL "BE8-EVENT-RADIUS" USING WS-N48 WS-SVL WS-B
     IF WS-B = 16
     ADD 1 TO WS-E
     END-IF
     IF WS-B = 10
     ADD 1 TO WS-F
     END-IF
     IF WS-B = 32
     ADD 1 TO WS-G
     END-IF
     MOVE SPACES TO WS-N48
     MOVE "resonate_7" TO WS-N48
     MOVE 10 TO WS-SVL
     CALL "BE8-EVENT-RADIUS" USING WS-N48 WS-SVL WS-B
     IF WS-B = 16
     ADD 1 TO WS-E
     END-IF
     IF WS-B = 10
     ADD 1 TO WS-F
     END-IF
     IF WS-B = 32
     ADD 1 TO WS-G
     END-IF
     MOVE SPACES TO WS-N48
     MOVE "resonate_8" TO WS-N48
     MOVE 10 TO WS-SVL
     CALL "BE8-EVENT-RADIUS" USING WS-N48 WS-SVL WS-B
     IF WS-B = 16
     ADD 1 TO WS-E
     END-IF
     IF WS-B = 10
     ADD 1 TO WS-F
     END-IF
     IF WS-B = 32
     ADD 1 TO WS-G
     END-IF
     MOVE SPACES TO WS-N48
     MOVE "resonate_9" TO WS-N48
     MOVE 10 TO WS-SVL
     CALL "BE8-EVENT-RADIUS" USING WS-N48 WS-SVL WS-B
     IF WS-B = 16
     ADD 1 TO WS-E
     END-IF
     IF WS-B = 10
     ADD 1 TO WS-F
     END-IF
     IF WS-B = 32
     ADD 1 TO WS-G
     END-IF
     MOVE SPACES TO WS-N48
     MOVE "resonate_10" TO WS-N48
     MOVE 11 TO WS-SVL
     CALL "BE8-EVENT-RADIUS" USING WS-N48 WS-SVL WS-B
     IF WS-B = 16
     ADD 1 TO WS-E
     END-IF
     IF WS-B = 10
     ADD 1 TO WS-F
     END-IF
     IF WS-B = 32
     ADD 1 TO WS-G
     END-IF
     MOVE SPACES TO WS-N48
     MOVE "resonate_11" TO WS-N48
     MOVE 11 TO WS-SVL
     CALL "BE8-EVENT-RADIUS" USING WS-N48 WS-SVL WS-B
     IF WS-B = 16
     ADD 1 TO WS-E
     END-IF
     IF WS-B = 10
     ADD 1 TO WS-F
     END-IF
     IF WS-B = 32
     ADD 1 TO WS-G
     END-IF
     MOVE SPACES TO WS-N48
     MOVE "resonate_12" TO WS-N48
     MOVE 11 TO WS-SVL
     CALL "BE8-EVENT-RADIUS" USING WS-N48 WS-SVL WS-B
     IF WS-B = 16
     ADD 1 TO WS-E
     END-IF
     IF WS-B = 10
     ADD 1 TO WS-F
     END-IF
     IF WS-B = 32
     ADD 1 TO WS-G
     END-IF
     MOVE SPACES TO WS-N48
     MOVE "resonate_13" TO WS-N48
     MOVE 11 TO WS-SVL
     CALL "BE8-EVENT-RADIUS" USING WS-N48 WS-SVL WS-B
     IF WS-B = 16
     ADD 1 TO WS-E
     END-IF
     IF WS-B = 10
     ADD 1 TO WS-F
     END-IF
     IF WS-B = 32
     ADD 1 TO WS-G
     END-IF
     MOVE SPACES TO WS-N48
     MOVE "resonate_14" TO WS-N48
     MOVE 11 TO WS-SVL
     CALL "BE8-EVENT-RADIUS" USING WS-N48 WS-SVL WS-B
     IF WS-B = 16
     ADD 1 TO WS-E
     END-IF
     IF WS-B = 10
     ADD 1 TO WS-F
     END-IF
     IF WS-B = 32
     ADD 1 TO WS-G
     END-IF
     MOVE SPACES TO WS-N48
     MOVE "resonate_15" TO WS-N48
     MOVE 11 TO WS-SVL
     CALL "BE8-EVENT-RADIUS" USING WS-N48 WS-SVL WS-B
     IF WS-B = 16
     ADD 1 TO WS-E
     END-IF
     IF WS-B = 10
     ADD 1 TO WS-F
     END-IF
     IF WS-B = 32
     ADD 1 TO WS-G
     END-IF
     MOVE SPACES TO WS-N48
     MOVE "item_interact_start" TO WS-N48
     MOVE 19 TO WS-SVL
     CALL "BE8-EVENT-RADIUS" USING WS-N48 WS-SVL WS-B
     IF WS-B = 16
     ADD 1 TO WS-E
     END-IF
     IF WS-B = 10
     ADD 1 TO WS-F
     END-IF
     IF WS-B = 32
     ADD 1 TO WS-G
     END-IF
     MOVE SPACES TO WS-N48
     MOVE "jukebox_play" TO WS-N48
     MOVE 12 TO WS-SVL
     CALL "BE8-EVENT-RADIUS" USING WS-N48 WS-SVL WS-B
     IF WS-B = 16
     ADD 1 TO WS-E
     END-IF
     IF WS-B = 10
     ADD 1 TO WS-F
     END-IF
     IF WS-B = 32
     ADD 1 TO WS-G
     END-IF
     MOVE SPACES TO WS-N48
     MOVE "jukebox_stop_play" TO WS-N48
     MOVE 17 TO WS-SVL
     CALL "BE8-EVENT-RADIUS" USING WS-N48 WS-SVL WS-B
     IF WS-B = 16
     ADD 1 TO WS-E
     END-IF
     IF WS-B = 10
     ADD 1 TO WS-F
     END-IF
     IF WS-B = 32
     ADD 1 TO WS-G
     END-IF
     MOVE SPACES TO WS-N48
     MOVE "sculk_sensor_tendrils_clicking" TO WS-N48
     MOVE 30 TO WS-SVL
     CALL "BE8-EVENT-RADIUS" USING WS-N48 WS-SVL WS-B
     IF WS-B = 16
     ADD 1 TO WS-E
     END-IF
     IF WS-B = 10
     ADD 1 TO WS-F
     END-IF
     IF WS-B = 32
     ADD 1 TO WS-G
     END-IF
     MOVE SPACES TO WS-N48
     MOVE "shriek" TO WS-N48
     MOVE 6 TO WS-SVL
     CALL "BE8-EVENT-RADIUS" USING WS-N48 WS-SVL WS-B
     IF WS-B = 16
     ADD 1 TO WS-E
     END-IF
     IF WS-B = 10
     ADD 1 TO WS-F
     END-IF
     IF WS-B = 32
     ADD 1 TO WS-G
     END-IF
     MOVE WS-E TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-F TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-G TO WS-SHOW
     PERFORM ADD-N
     MOVE "58 2 1" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "acceptance US12 31-8§2 Game events as seen by block-entity listeners: event names (2.1): the minecraft: prefix of a registry key is ignored" TO TL-CASE
     PERFORM BEGIN-CASE
     MOVE SPACES TO WS-N48
     MOVE "minecraft:shriek" TO WS-N48
     MOVE 16 TO WS-SVL
     CALL "BE8-EVENT-RADIUS" USING WS-N48 WS-SVL WS-B
     MOVE WS-B TO WS-SHOW
     PERFORM ADD-N
     MOVE SPACES TO WS-N48
     MOVE "minecraft:jukebox_play" TO WS-N48
     MOVE 22 TO WS-SVL
     CALL "BE8-EVENT-RADIUS" USING WS-N48 WS-SVL WS-B
     MOVE WS-B TO WS-SHOW
     PERFORM ADD-N
     MOVE SPACES TO WS-N48
     MOVE "minecraft:step" TO WS-N48
     MOVE 14 TO WS-SVL
     CALL "BE8-EVENT-RADIUS" USING WS-N48 WS-SVL WS-B
     MOVE WS-B TO WS-SHOW
     PERFORM ADD-N
     MOVE "32 10 16" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "acceptance US12 31-8§2 Game events as seen by block-entity listeners: section box (2.2): the sections from (coordinate - radius) >> 4 to (coordinate + radius) >> 4 on each axis (coordinate, radius in)" TO TL-CASE
     PERFORM BEGIN-CASE
     MOVE 0 TO WS-A
     MOVE 16 TO WS-B
     CALL "BE8-SECTION-RANGE" USING WS-A WS-B WS-C WS-E
     MOVE WS-C TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-E TO WS-SHOW
     PERFORM ADD-N
     MOVE 5 TO WS-A
     MOVE 8 TO WS-B
     CALL "BE8-SECTION-RANGE" USING WS-A WS-B WS-C WS-E
     MOVE WS-C TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-E TO WS-SHOW
     PERFORM ADD-N
     MOVE -1 TO WS-A
     MOVE 16 TO WS-B
     CALL "BE8-SECTION-RANGE" USING WS-A WS-B WS-C WS-E
     MOVE WS-C TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-E TO WS-SHOW
     PERFORM ADD-N
     MOVE -17 TO WS-A
     MOVE 16 TO WS-B
     CALL "BE8-SECTION-RANGE" USING WS-A WS-B WS-C WS-E
     MOVE WS-C TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-E TO WS-SHOW
     PERFORM ADD-N
     MOVE 100 TO WS-A
     MOVE 32 TO WS-B
     CALL "BE8-SECTION-RANGE" USING WS-A WS-B WS-C WS-E
     MOVE WS-C TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-E TO WS-SHOW
     PERFORM ADD-N
     MOVE 15 TO WS-A
     MOVE 1 TO WS-B
     CALL "BE8-SECTION-RANGE" USING WS-A WS-B WS-C WS-E
     MOVE WS-C TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-E TO WS-SHOW
     PERFORM ADD-N
     MOVE 16 TO WS-A
     MOVE 1 TO WS-B
     CALL "BE8-SECTION-RANGE" USING WS-A WS-B WS-C WS-E
     MOVE WS-C TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-E TO WS-SHOW
     PERFORM ADD-N
     MOVE "-1 1 -1 0 -2 0 -3 -1 4 8 0 1 0 1" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "acceptance US12 31-8§2 Game events as seen by block-entity listeners: listener radius (2.3): the squared block distance between listener and event must be <= radius * radius (only the listener radius filters) (listener block," TO TL-CASE
     PERFORM BEGIN-CASE
     MOVE 0 TO WS-A
     MOVE 0 TO WS-B
     MOVE 0 TO WS-C
     MOVE 3 TO WS-E
     MOVE 4 TO WS-F
     MOVE 0 TO WS-G
     MOVE 5 TO WS-H
     CALL "BE8-LISTENER-IN" USING WS-A WS-B WS-C WS-E WS-F WS-G WS-H WS-P
     MOVE WS-P TO WS-SHOW
     PERFORM ADD-N
     MOVE 0 TO WS-A
     MOVE 0 TO WS-B
     MOVE 0 TO WS-C
     MOVE 3 TO WS-E
     MOVE 4 TO WS-F
     MOVE 1 TO WS-G
     MOVE 5 TO WS-H
     CALL "BE8-LISTENER-IN" USING WS-A WS-B WS-C WS-E WS-F WS-G WS-H WS-P
     MOVE WS-P TO WS-SHOW
     PERFORM ADD-N
     MOVE 0 TO WS-A
     MOVE 0 TO WS-B
     MOVE 0 TO WS-C
     MOVE 8 TO WS-E
     MOVE 0 TO WS-F
     MOVE 0 TO WS-G
     MOVE 8 TO WS-H
     CALL "BE8-LISTENER-IN" USING WS-A WS-B WS-C WS-E WS-F WS-G WS-H WS-P
     MOVE WS-P TO WS-SHOW
     PERFORM ADD-N
     MOVE 0 TO WS-A
     MOVE 0 TO WS-B
     MOVE 0 TO WS-C
     MOVE 9 TO WS-E
     MOVE 0 TO WS-F
     MOVE 0 TO WS-G
     MOVE 8 TO WS-H
     CALL "BE8-LISTENER-IN" USING WS-A WS-B WS-C WS-E WS-F WS-G WS-H WS-P
     MOVE WS-P TO WS-SHOW
     PERFORM ADD-N
     MOVE 10 TO WS-A
     MOVE 64 TO WS-B
     MOVE 10 TO WS-C
     MOVE 10 TO WS-E
     MOVE 64 TO WS-F
     MOVE 10 TO WS-G
     MOVE 0 TO WS-H
     CALL "BE8-LISTENER-IN" USING WS-A WS-B WS-C WS-E WS-F WS-G WS-H WS-P
     MOVE WS-P TO WS-SHOW
     PERFORM ADD-N
     MOVE 5 TO WS-A
     MOVE 5 TO WS-B
     MOVE 5 TO WS-C
     MOVE 5 TO WS-E
     MOVE 5 TO WS-F
     MOVE 6 TO WS-G
     MOVE 0 TO WS-H
     CALL "BE8-LISTENER-IN" USING WS-A WS-B WS-C WS-E WS-F WS-G WS-H WS-P
     MOVE WS-P TO WS-SHOW
     PERFORM ADD-N
     MOVE "1 0 1 0 1 0" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "acceptance US12 31-8§2 Game events as seen by block-entity listeners: delivery order (2.2): UNSPECIFIED listeners (mode 0) run at once in visit order, BY_DISTANCE listeners (mode 1) after the whole visit sorted by squared" TO TL-CASE
     PERFORM BEGIN-CASE
     MOVE 1 TO WS-TV(1)
     MOVE 9 TO WS-TV(2)
     MOVE 0 TO WS-TV(3)
     MOVE 50 TO WS-TV(4)
     MOVE 1 TO WS-TV(5)
     MOVE 4 TO WS-TV(6)
     MOVE 0 TO WS-TV(7)
     MOVE 1 TO WS-TV(8)
     MOVE 4 TO WS-A
     CALL "BE8-ORDER" USING WS-TAB WS-A WS-TAB2
     MOVE WS-TV2(1) TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-TV2(2) TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-TV2(3) TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-TV2(4) TO WS-SHOW
     PERFORM ADD-N
     MOVE 1 TO WS-TV(1)
     MOVE 5 TO WS-TV(2)
     MOVE 1 TO WS-TV(3)
     MOVE 5 TO WS-TV(4)
     MOVE 1 TO WS-TV(5)
     MOVE 2 TO WS-TV(6)
     MOVE 3 TO WS-A
     CALL "BE8-ORDER" USING WS-TAB WS-A WS-TAB2
     MOVE WS-TV2(1) TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-TV2(2) TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-TV2(3) TO WS-SHOW
     PERFORM ADD-N
     MOVE 0 TO WS-TV(1)
     MOVE 3 TO WS-TV(2)
     MOVE 1 TO WS-A
     CALL "BE8-ORDER" USING WS-TAB WS-A WS-TAB2
     MOVE WS-TV2(1) TO WS-SHOW
     PERFORM ADD-N
     MOVE 1 TO WS-TV(1)
     MOVE 7 TO WS-TV(2)
     MOVE 0 TO WS-TV(3)
     MOVE 2 TO WS-TV(4)
     MOVE 1 TO WS-TV(5)
     MOVE 7 TO WS-TV(6)
     MOVE 1 TO WS-TV(7)
     MOVE 1 TO WS-TV(8)
     MOVE 0 TO WS-TV(9)
     MOVE 9 TO WS-TV(10)
     MOVE 5 TO WS-A
     CALL "BE8-ORDER" USING WS-TAB WS-A WS-TAB2
     MOVE WS-TV2(1) TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-TV2(2) TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-TV2(3) TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-TV2(4) TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-TV2(5) TO WS-SHOW
     PERFORM ADD-N
     MOVE "2 4 3 1 3 1 2 1 2 5 4 1 3" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "acceptance US12 31-8§2 Game events as seen by block-entity listeners: registration (2.4): a listener is registered when the entity is in a level, the level is a server level, the block is an EntityBlock and the entity provides a" TO TL-CASE
     PERFORM BEGIN-CASE
     MOVE 1 TO WS-A
     MOVE 1 TO WS-B
     MOVE 1 TO WS-C
     MOVE 1 TO WS-E
     CALL "BE8-REGISTER" USING WS-A WS-B WS-C WS-E WS-F
     MOVE WS-F TO WS-SHOW
     PERFORM ADD-N
     MOVE 1 TO WS-A
     MOVE 0 TO WS-B
     MOVE 1 TO WS-C
     MOVE 1 TO WS-E
     CALL "BE8-REGISTER" USING WS-A WS-B WS-C WS-E WS-F
     MOVE WS-F TO WS-SHOW
     PERFORM ADD-N
     MOVE 0 TO WS-A
     MOVE 1 TO WS-B
     MOVE 1 TO WS-C
     MOVE 1 TO WS-E
     CALL "BE8-REGISTER" USING WS-A WS-B WS-C WS-E WS-F
     MOVE WS-F TO WS-SHOW
     PERFORM ADD-N
     MOVE 1 TO WS-A
     MOVE 1 TO WS-B
     MOVE 0 TO WS-C
     MOVE 1 TO WS-E
     CALL "BE8-REGISTER" USING WS-A WS-B WS-C WS-E WS-F
     MOVE WS-F TO WS-SHOW
     PERFORM ADD-N
     MOVE 1 TO WS-A
     MOVE 1 TO WS-B
     MOVE 1 TO WS-C
     MOVE 0 TO WS-E
     CALL "BE8-REGISTER" USING WS-A WS-B WS-C WS-E WS-F
     MOVE WS-F TO WS-SHOW
     PERFORM ADD-N
     MOVE "1 0 0 0 0" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     STOP RUN.

 BEGIN-CASE.
     MOVE SPACES TO TL-OBSERVED
     MOVE 1 TO WS-PTR
     .

 ADD-N.
     STRING FUNCTION TRIM(WS-SHOW) " " DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-PTR
     .

*> Saves entity WS-IDX in form WS-FORM, renders the compound and appends it to TL-OBSERVED.
 SAVE-RENDER.
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "BE-SAVE" USING WS-IDX WS-FORM PB-BUFFER
     CALL "NBT-WRITE-COMPOUND-END" USING PB-BUFFER
     MOVE 0 TO PB-POS
     MOVE 0 TO WS-LEN
     MOVE SPACES TO WS-OUT
     CALL "TEST-NBT-RENDER" USING PB-BUFFER WS-T10 WS-OUT WS-LEN
     CALL "PB-FREE" USING PB-BUFFER
     STRING WS-OUT(1:WS-LEN) " " DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-PTR
     .

*> The NBT builders of the cases (name WS-NM and length WS-NML, text WS-SV and length WS-SVL, number WS-NV, list type WS-LT and count WS-LC).
 NB-S.
     CALL "NBT-WRITE-STRING" USING PB-BUFFER WS-NM WS-NML WS-SV WS-SVL
     .
 NB-I.
     CALL "NBT-WRITE-INT" USING PB-BUFFER WS-NM WS-NML WS-NV
     .
 NB-LONG.
     CALL "NBT-WRITE-LONG" USING PB-BUFFER WS-NM WS-NML WS-LV
     .
 NB-IA.
     CALL "NBT-WRITE-INT-ARRAY" USING PB-BUFFER WS-NM WS-NML WS-LC WS-IA
     .
 NB-FLOAT.
     CALL "NBT-WRITE-FLOAT" USING PB-BUFFER WS-NM WS-NML WS-FV
     .
 NB-B.
     CALL "NBT-WRITE-BYTE" USING PB-BUFFER WS-NM WS-NML WS-NV
     .
 NB-C.
     CALL "NBT-WRITE-COMPOUND-BEGIN" USING PB-BUFFER WS-NM WS-NML
     .
 NB-E.
     CALL "NBT-WRITE-COMPOUND-END" USING PB-BUFFER
     .
 NB-STACK.
     MOVE 0 TO WS-KP
     CALL "PNBT-STACK-WRITE" USING PB-BUFFER WS-ITEM WS-NV WS-KP
     .
 NB-L.
     CALL "NBT-WRITE-LIST-BEGIN" USING PB-BUFFER WS-NM WS-NML WS-LT WS-LC
     .

*> Loads entity WS-IDX from the compound the case built in PB-BUFFER (the closing End tag is written here).
 LOAD-BUFFER.
     CALL "NBT-WRITE-COMPOUND-END" USING PB-BUFFER
     MOVE 0 TO PB-POS
     CALL "BE-LOAD" USING WS-IDX PB-BUFFER
     CALL "PB-FREE" USING PB-BUFFER
     .
 END PROGRAM TEST-BE-31-8-2.

 COPY CORETEST.
