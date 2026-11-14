*> The Nether's dimension rules that act in the world (docs/protocol/37-nether-1 section 3). The pure rules are in nether-37-1.cob; the engines call these.
*>
*> Entry points:
*>   NETHER-EVAPORATE USING dimension row, x, y, z (BINARY-LONG): 3.1 BucketItem.emptyContents with water_evaporates true: no water is placed, the Sound
*>     block.fire.extinguish (source blocks, volume 0.5, pitch 2.6 + (r1 - r2) x 0.8 from two draws) plays at the centre of the cell and 8 large_smoke particles
*>     (the integer corner, spread 1.0 on each axis, speed 0, randomisation ALTERNATIVE) are sent. The two draws are FUNCTION RANDOM, not the level's random source.
*>
*> Rules not wired (open items, the docs do not give the numbers or the engine part is missing): the bed that explodes (33 section 12 item 12: the explosion size of
*> destroy_on_use is not in the docs), respawn anchors (no block behaviour in the core), the infiniburn fire rule (no fire spreading engine), ice melting into water,
*> wet sponge, dripstone, piglin zombification, raids, snow golems. Fast lava (fluids-world-29a.cob FLUID-FAST) and the weather rule are in place already.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. NETHER-EVAPORATE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY PROTO.
 01 WS-REGISTRY            PIC X(48) VALUE "minecraft:sound_event".
 01 WS-PARTICLES           PIC X(48) VALUE "minecraft:particle_type".
 01 WS-KEY                 PIC X(112).
 01 WS-STATUS              BINARY-LONG.
 01 WS-ID                  BINARY-LONG.
 01 WS-HOLDER              BINARY-LONG.
 01 WS-PACKET-ID           BINARY-LONG VALUE 119.
 01 WS-CAPACITY            BINARY-LONG VALUE 64.
 01 WS-SOURCE              BINARY-LONG VALUE 4.
 01 WS-FX                  BINARY-LONG.
 01 WS-FY                  BINARY-LONG.
 01 WS-FZ                  BINARY-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-NONE                BINARY-LONG VALUE 0.
 01 WS-VOLUME              FLOAT-SHORT VALUE 0.5.
 01 WS-PITCH               FLOAT-SHORT.
 01 WS-R1                  FLOAT-LONG.
 01 WS-R2                  FLOAT-LONG.
 01 WS-SEED                BINARY-DOUBLE VALUE 0.
 01 WS-OPTION              BINARY-LONG VALUE -1.
 01 WS-OVERRIDE            BINARY-LONG VALUE 0.
 01 WS-ALWAYS              BINARY-LONG VALUE 0.
 01 WS-COUNT               BINARY-LONG VALUE 8.
 01 WS-ALTERNATIVE         BINARY-LONG VALUE 1.
 01 WS-PX                  FLOAT-LONG.
 01 WS-PY                  FLOAT-LONG.
 01 WS-PZ                  FLOAT-LONG.
 01 WS-SPREAD-TABLE.
    05 WS-SPREAD           FLOAT-SHORT OCCURS 6 TIMES.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z.
     MOVE "minecraft:block.fire.extinguish" TO WS-KEY
     CALL "CONTENT-STATIC-ID" USING WS-REGISTRY WS-KEY WS-ID WS-STATUS
     COMPUTE WS-HOLDER = WS-ID + 1
     COMPUTE WS-R1 = FUNCTION RANDOM
     COMPUTE WS-R2 = FUNCTION RANDOM
     COMPUTE WS-PITCH = 2.6 + (WS-R1 - WS-R2) * 0.8
     COMPUTE WS-FX = L-X * 8 + 4
     COMPUTE WS-FY = L-Y * 8 + 4
     COMPUTE WS-FZ = L-Z * 8 + 4
     COMPUTE WS-CX = (L-X - FUNCTION MOD(L-X, 16)) / 16
     COMPUTE WS-CZ = (L-Z - FUNCTION MOD(L-Z, 16)) / 16
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-PACKET-ID
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-HOLDER
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-SOURCE
     CALL "PB-PUT-INT" USING PB-BUFFER WS-FX
     CALL "PB-PUT-INT" USING PB-BUFFER WS-FY
     CALL "PB-PUT-INT" USING PB-BUFFER WS-FZ
     CALL "PB-PUT-FLOAT" USING PB-BUFFER WS-VOLUME
     CALL "PB-PUT-FLOAT" USING PB-BUFFER WS-PITCH
     CALL "PB-PUT-LONG" USING PB-BUFFER WS-SEED
     CALL "VIEWERS-SEND" USING L-DIM WS-CX WS-CZ WS-NONE PB-BUFFER
     CALL "PB-FREE" USING PB-BUFFER
     MOVE "minecraft:large_smoke" TO WS-KEY
     CALL "CONTENT-STATIC-ID" USING WS-PARTICLES WS-KEY WS-ID WS-STATUS
     MOVE L-X TO WS-PX
     MOVE L-Y TO WS-PY
     MOVE L-Z TO WS-PZ
     MOVE 1.0 TO WS-SPREAD(1) WS-SPREAD(2) WS-SPREAD(3)
     MOVE 0 TO WS-SPREAD(4) WS-SPREAD(5) WS-SPREAD(6)
     CALL "PARTICLE-SEND" USING L-DIM WS-ID WS-OPTION WS-OVERRIDE WS-ALWAYS WS-PX WS-PY WS-PZ
         WS-SPREAD-TABLE WS-COUNT WS-ALTERNATIVE
     GOBACK.
 END PROGRAM NETHER-EVAPORATE.
