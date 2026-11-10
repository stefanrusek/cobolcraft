*> Acceptance test of US12-1, the client half (standin-content §15.1, §15.3, §15.5, §4.6; docs/protocol/
*> 09-cobolcraft-profile.md §3.3 Respawn 0x54, Level Chunk With Light 0x2E; client/src/protocol-client.cob,
*> world-replica.cob, render-list.cob, sky.cob): the Player stands in cobolcraft:main with the spawn chunk
*> (0, 0) meshed and drawn, 12 greystone in hotbar slot 0, health 17 and food 9. Respawn into
*> cobolcraft:subroutine (type cobolcraft:sunless: y 0 to 127, no sky light) arrives, and the server's
*> first chunk of the new dimension, (0, 0) again, follows in the same read, before the next frame. The
*> next frame draws none of the old dimension's section meshes and frees every mesh slot of the row
*> (an upload with no vertices for each of its 48 slots), although the new chunk took the same row.
*> Once the new chunk is meshed, only sections below y 128 are drawn, the sky is the fixed #100C12
*> (16, 12, 18), and the HUD still shows the 12 greystone, health 17 and food 9 in survival.
*> The Subroutine chunk is built here with the proto encoders: baseplate at y 0, greystone 1 to 28, slag
*> 29 to 31 (state 17), void above; biome ash_flats (2); no sky light, block light all 0 (empty).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-US12-DIMENSION-CHANGE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLSTATE.
 COPY CLCONST.
 COPY CCSHIM.
 COPY TESTLIB.
 01 WS-CONN                BINARY-LONG VALUE 1.
 01 WS-PATH                PIC X(256).
 01 WS-TEXT                PIC X(1024).
 01 WS-BUDGET              BINARY-LONG VALUE 1000.
 01 WS-HEALTH              FLOAT-SHORT VALUE 17.
 01 WS-FOOD                BINARY-LONG VALUE 9.
 01 WS-I                   BINARY-LONG.
 01 WS-DRAWS               BINARY-LONG.
 01 WS-TOP                 BINARY-LONG.
 01 WS-S                   BINARY-LONG.
 01 WS-FREES               BINARY-LONG.
 01 WS-E1                  PIC Z(4)9.
 01 WS-E2                  PIC Z(4)9.
 01 WS-E3                  PIC Z(4)9.
 01 WS-E4                  PIC Z(4)9.
 01 WS-SKY-EDIT            PIC ZZ9.
 01 WS-SKY-VALUE           BINARY-LONG.
 PROCEDURE DIVISION.
     CALL "CL-INIT" USING CLIENT-STATE
     CALL "PACK-STACK-INIT" USING CLIENT-STATE
     CALL "LANG-LOAD" USING CLIENT-STATE
     CALL "ATLAS-BUILD" USING CLIENT-STATE
     CALL "MODELS-BAKE" USING CLIENT-STATE
     CALL "NET-BUFFERS-INIT" USING CLIENT-STATE WS-CONN
     MOVE PH-CONFIG TO CN-PHASE(WS-CONN)
     MOVE "contract/fixtures/wire/config-s2c-07-registry-data-worldgen-biome.hex" TO WS-PATH
     CALL "TEST-FEED" USING CLIENT-STATE WS-CONN WS-PATH
     MOVE "contract/fixtures/wire/config-s2c-07-registry-data-dimension-type.hex" TO WS-PATH
     CALL "TEST-FEED" USING CLIENT-STATE WS-CONN WS-PATH
     MOVE PH-PLAY TO CN-PHASE(WS-CONN)
     MOVE "contract/fixtures/wire/play-s2c-32-login-all-dimensions.hex" TO WS-PATH
     CALL "TEST-FEED" USING CLIENT-STATE WS-CONN WS-PATH
     MOVE "contract/fixtures/wire/play-s2c-2e-level-chunk-with-light-spawn.hex" TO WS-PATH
     CALL "TEST-FEED" USING CLIENT-STATE WS-CONN WS-PATH
     CALL "TEST-SET-HEALTH" USING CLIENT-STATE WS-CONN WS-HEALTH WS-FOOD
     MOVE 12 TO PL-SLOT-COUNT(1)
     MOVE 2 TO PL-SLOT-ITEM(1)
     MOVE 0 TO PL-HELD
     MOVE 8.5 TO PL-X PL-Z
     MOVE 57 TO PL-Y
     MOVE 0 TO PL-YAW PL-PITCH
     MOVE 6000 TO PL-TIME
     CALL "SKY-UPDATE" USING CLIENT-STATE
     CALL "MESH-DIRTY" USING CLIENT-STATE WS-BUDGET
     CALL "RENDER-LIST-BUILD" USING CLIENT-STATE
     PERFORM COUNT-DRAWS
     MOVE "US12-1 client half: given the Player in cobolcraft:main then the spawn chunk's "
         & "sections that hold blocks are drawn: 5 draws, up to section 4 (y 48 to 63)" TO TL-CASE
     MOVE "T" TO TL-MODE
     PERFORM DRAWS-TEXT
     MOVE "draws 5 top 4" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Respawn into cobolcraft:subroutine and its chunk (0, 0), before the next frame.
     MOVE "contract/fixtures/wire/play-s2c-54-respawn-subroutine.hex" TO WS-PATH
     CALL "TEST-FEED" USING CLIENT-STATE WS-CONN WS-PATH
     CALL "TEST-SUB-CHUNK" USING CLIENT-STATE WS-CONN
     CALL "RENDER-LIST-BUILD" USING CLIENT-STATE
     PERFORM COUNT-DRAWS
     MOVE "acceptance US12-1 client half: given the spawn chunk drawn when Respawn into "
         & "cobolcraft:subroutine and its chunk (0, 0) arrive before a frame then that frame "
         & "draws no old mesh and frees the row's 48 slots" TO TL-CASE
     PERFORM DRAWS-TEXT
     MOVE WS-FREES TO WS-E4
     STRING FUNCTION TRIM(TL-OBSERVED) " frees " FUNCTION TRIM(WS-E4) DELIMITED BY SIZE
         INTO TL-OBSERVED
     MOVE "draws 0 top 0 frees 48" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE 8.5 TO PL-X PL-Z
     MOVE 32 TO PL-Y
     CALL "SKY-UPDATE" USING CLIENT-STATE
     CALL "MESH-DIRTY" USING CLIENT-STATE WS-BUDGET
     CALL "RENDER-LIST-BUILD" USING CLIENT-STATE
     PERFORM COUNT-DRAWS
     CALL "SCREEN-BUILD" USING CLIENT-STATE
     CALL "TEST-SCREEN-TEXTS" USING CLIENT-STATE WS-TEXT
     MOVE "acceptance US12-1 client half: then the new chunk's sections 1 and 2 are drawn, y 0 "
         & "to 127 without sky light, sky #100C12, and the HUD keeps the inventory (12 in slot "
         & "0), health 17, food 9 and survival" TO TL-CASE
     PERFORM DRAWS-TEXT
     MOVE PL-MIN-Y TO WS-E1
     MOVE PL-HEIGHT TO WS-E2
     MOVE PL-MODE TO WS-E3
     STRING FUNCTION TRIM(TL-OBSERVED) " y " FUNCTION TRIM(WS-E1) "/" FUNCTION TRIM(WS-E2)
         " sky-light " PL-HAS-SKY " sky" DELIMITED BY SIZE INTO TL-OBSERVED
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 3
         COMPUTE WS-SKY-VALUE ROUNDED = RL-CLEAR(WS-I) * 255
         MOVE WS-SKY-VALUE TO WS-SKY-EDIT
         STRING FUNCTION TRIM(TL-OBSERVED) " " FUNCTION TRIM(WS-SKY-EDIT) DELIMITED BY SIZE
             INTO TL-OBSERVED
     END-PERFORM
     STRING FUNCTION TRIM(TL-OBSERVED) " mode " FUNCTION TRIM(WS-E3) " hud "
         FUNCTION TRIM(WS-TEXT) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "draws 2 top 2 y 0/128 sky-light 0 sky 16 12 18 mode 0 hud "
         & "12|||||||||Health 17/20|Food 9/20" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.

*> Section draws of the frame (slots of the chunk rows), the highest section drawn, and the uploads
*> with no vertices to the slots of row 1 (frees; an empty section's mesh is uploaded so too).
 COUNT-DRAWS.
     MOVE 0 TO WS-DRAWS WS-TOP WS-FREES
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > RL-DRAW-COUNT
         IF RL-D-SLOT(WS-I) >= MESH-SLOT-BASE AND RL-D-SLOT(WS-I) < MESH-SLOT-ENTITIES
             ADD 1 TO WS-DRAWS
             COMPUTE WS-S = FUNCTION MOD(RL-D-SLOT(WS-I) - MESH-SLOT-BASE, 48)
             DIVIDE WS-S BY 2 GIVING WS-S
             ADD 1 TO WS-S
             IF WS-S > WS-TOP
                 MOVE WS-S TO WS-TOP
             END-IF
         END-IF
     END-PERFORM
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > RL-UPLOAD-COUNT
         IF RL-U-SLOT(WS-I) >= MESH-SLOT-BASE AND RL-U-SLOT(WS-I) < MESH-SLOT-BASE + 48
                 AND RL-U-COUNT(WS-I) = 0
             ADD 1 TO WS-FREES
         END-IF
     END-PERFORM
     .

 DRAWS-TEXT.
     MOVE WS-DRAWS TO WS-E1
     MOVE WS-TOP TO WS-E2
     MOVE SPACES TO TL-OBSERVED
     STRING "draws " FUNCTION TRIM(WS-E1) " top " FUNCTION TRIM(WS-E2) DELIMITED BY SIZE
         INTO TL-OBSERVED
     .
 END PROGRAM ACC-US12-DIMENSION-CHANGE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-SUB-CHUNK.
*> USING CLIENT-STATE, connection: hands PROTO-PACKET a Level Chunk With Light (0x2E) of chunk (0, 0)
*> in cobolcraft:subroutine (8 sections, 10 light sections), built with the proto encoders.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY PROTO.
 COPY PROTO REPLACING LEADING ==PB-== BY ==SB-==.
 01 WS-READY               BINARY-LONG VALUE 0.
 01 WS-CAPACITY            BINARY-LONG VALUE 65536.
 01 WS-PACKET              BINARY-LONG VALUE 46.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-ZERO2               BINARY-LONG VALUE 0.
 01 WS-BLOCK-BITS          BINARY-LONG VALUE 5.
 01 WS-BIOME-BITS          BINARY-LONG VALUE 2.
 01 WS-LIGHTS              BINARY-LONG VALUE 10.
 01 WS-S                   BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-NON-EMPTY           BINARY-LONG.
 01 WS-STATES.
    05 WS-STATE            BINARY-LONG OCCURS 4096 TIMES.
 01 WS-BIOMES.
    05 WS-BIOME            BINARY-LONG OCCURS 64 TIMES.
 01 WS-SKY-STATES.
    05 WS-SKY-STATE        BINARY-LONG OCCURS 10 TIMES.
 01 WS-BLOCK-STATES.
    05 WS-BLOCK-STATE      BINARY-LONG OCCURS 10 TIMES.
 01 WS-SKY-ARRAYS.
    05 WS-SKY-ARRAY        PIC X(2048) OCCURS 10 TIMES.
 01 WS-BLOCK-ARRAYS.
    05 WS-BLOCK-ARRAY      PIC X(2048) OCCURS 10 TIMES.
 01 B-BYTES                PIC X(65536) BASED.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-CONN                 BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-CONN.
     IF WS-READY = 0
         CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
         CALL "PB-INIT" USING SB-BUFFER WS-CAPACITY
         MOVE 1 TO WS-READY
     END-IF
     CALL "PB-RESET" USING PB-BUFFER
     CALL "PB-RESET" USING SB-BUFFER
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 64
         MOVE 2 TO WS-BIOME(WS-I)
     END-PERFORM
*>   Index (y * 16 + z) * 16 + x + 1 within a section: y-major, so whole layers are runs.
     PERFORM VARYING WS-S FROM 0 BY 1 UNTIL WS-S > 7
         MOVE 0 TO WS-NON-EMPTY
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 4096
             COMPUTE WS-Y = WS-S * 16 + (WS-I - 1) / 256
             EVALUATE TRUE
                 WHEN WS-Y = 0
                     MOVE 1 TO WS-STATE(WS-I)
                 WHEN WS-Y <= 28
                     MOVE 2 TO WS-STATE(WS-I)
                 WHEN WS-Y <= 31
                     MOVE 17 TO WS-STATE(WS-I)
                 WHEN OTHER
                     MOVE 0 TO WS-STATE(WS-I)
             END-EVALUATE
             IF WS-STATE(WS-I) NOT = 0
                 ADD 1 TO WS-NON-EMPTY
             END-IF
         END-PERFORM
         CALL "CHUNK-SECTION-ENCODE" USING SB-BUFFER WS-NON-EMPTY WS-ZERO WS-STATES WS-BIOMES
             WS-BLOCK-BITS WS-BIOME-BITS
     END-PERFORM
     CALL "PB-PUT-INT" USING PB-BUFFER WS-ZERO
     CALL "PB-PUT-INT" USING PB-BUFFER WS-ZERO2
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-ZERO
     CALL "PB-PUT-VARINT" USING PB-BUFFER SB-LENGTH
     SET ADDRESS OF B-BYTES TO SB-ADDR
     CALL "PB-APPEND-BYTES" USING PB-BUFFER B-BYTES SB-LENGTH
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-ZERO
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 10
         MOVE 0 TO WS-SKY-STATE(WS-I)
         MOVE 1 TO WS-BLOCK-STATE(WS-I)
     END-PERFORM
     CALL "LIGHT-ENCODE" USING PB-BUFFER WS-LIGHTS WS-SKY-STATES WS-SKY-ARRAYS WS-BLOCK-STATES
         WS-BLOCK-ARRAYS
     MOVE 0 TO PB-POS
     CALL "PROTO-PACKET" USING CLIENT-STATE L-CONN PB-BUFFER WS-PACKET
     GOBACK.
 END PROGRAM TEST-SUB-CHUNK.
 COPY CLTEST.
