*> Explosions (002-lane-mobs2, T4110; docs/protocol/20 section 6.2 ServerExplosion, 05a 0x24 Explode, 29 section 2 for block changes).
*> EXPLODE-RUN makes one explosion: the exploded block positions (EXPLODE-BLOCKS: 1352 rays from the centre, each with the strength power x (0.7 +
*> 0.6 r), reduced by (blast resistance + 0.3) x 0.3 in every block it crosses and by 0.225 per 0.3 step), damage and knockback of the players and
*> mobs within twice the power (EXPLODE-SEEN: the share of sample points of the entity's box that see the centre), the Explode packet to the players
*> within 64 blocks, and, with block destruction, the blocks replaced by air with their drops (each stack survives with probability 1 / power).
*> Approximations (open): the sight test of EXPLODE-SEEN steps along the ray by 0.1 block instead of an exact voxel walk; the random draws are the
*> deterministic hash of xp.cob, not the level's random source; mobs are hurt in whole points and pushed through EN-VX, EN-VY and EN-VZ (spent by STDMOB-STEP); item entities and fire are left out.
*>
*> Entry points:
*>   EXPLODE-RUN USING dim, x, y, z, power (FLOAT-LONG), destroy blocks (BINARY-LONG 0/1), source tracker row (BINARY-LONG, 0 none)
*>   EXPLODE-SEEN USING dim, x, y, z (the centre), minx, miny, minz, maxx, maxy, maxz (the box), seen out (FLOAT-LONG, 0 to 1)
*>   EXPLODE-RESIST USING block id (0 based), resistance in thousandths out (-1 for air)
*>   EXPLODE-BLOCKS USING dim, x, y, z, power, table of positions, count out
*>   EXPLODE-BUILD USING x, y, z, power, block count, knockback flag, kx, ky, kz, PB-BUFFER   the Explode packet

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EXPLODE-RESIST.
*> USING block id (BINARY-LONG, 0 based), resistance out (BINARY-LONG, thousandths; -1 for air, cave air and void air): the blast resistance of
*> the block's content row, found once per block.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CBLOCKS.
 COPY CONTENT.
 01 WS-CACHE.
    05 WS-RES              BINARY-LONG OCCURS 1400 TIMES VALUE -2.
 01 WS-EPOCH               BINARY-LONG VALUE -1.
 01 WS-I                   BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-ID                  BINARY-LONG.
 01 WS-ROW                 PIC X(819).
 01 WS-STATUS              BINARY-LONG.
 01 WS-BLAST               FLOAT-LONG.
 LINKAGE SECTION.
 01 L-BLOCK                BINARY-LONG.
 01 L-MILLI                BINARY-LONG.
 PROCEDURE DIVISION USING L-BLOCK L-MILLI.
     IF WS-EPOCH NOT = CB-EPOCH
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 1400
             MOVE -2 TO WS-RES(WS-I)
         END-PERFORM
         MOVE CB-EPOCH TO WS-EPOCH
     END-IF
     IF WS-RES(L-BLOCK + 1) = -2
         MOVE SPACES TO WS-KEY
         MOVE CB-KEY(L-BLOCK + 1) TO WS-KEY
         IF WS-KEY = "air" OR WS-KEY = "cave_air" OR WS-KEY = "void_air" OR WS-KEY = "minecraft:air"
                 OR WS-KEY = "minecraft:cave_air" OR WS-KEY = "minecraft:void_air"
             MOVE -1 TO WS-RES(L-BLOCK + 1)
         ELSE
             CALL "CONTENT-BLOCK-BY-KEY" USING WS-KEY WS-ID WS-ROW WS-STATUS
             MOVE WS-ROW(1 + 4 + 35 + 32 + 288 + 4 + 5 + 5 + 21:9) TO CT-BR-BLAST
             COMPUTE WS-BLAST = FUNCTION NUMVAL(CT-BR-BLAST)
             COMPUTE WS-RES(L-BLOCK + 1) ROUNDED = WS-BLAST * 1000
         END-IF
     END-IF
     MOVE WS-RES(L-BLOCK + 1) TO L-MILLI
     GOBACK.
 END PROGRAM EXPLODE-RESIST.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EXPLODE-BLOCKS.
*> USING dim, x, y, z (the centre), power (FLOAT-LONG), positions (a table of 4096 x, y, z triples), count out: calculateExplodedPositions.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CBLOCKS.
 01 WS-MARKS.
    05 WS-MARK             PIC 9 OCCURS 35937 TIMES.
 01 WS-I                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-DX                  FLOAT-LONG.
 01 WS-DY                  FLOAT-LONG.
 01 WS-DZ                  FLOAT-LONG.
 01 WS-LEN                 FLOAT-LONG.
 01 WS-PX                  FLOAT-LONG.
 01 WS-PY                  FLOAT-LONG.
 01 WS-PZ                  FLOAT-LONG.
 01 WS-STRENGTH            FLOAT-LONG.
 01 WS-SALT                BINARY-LONG VALUE 5.
 01 WS-BOUND               BINARY-LONG VALUE 1000.
 01 WS-R                   BINARY-LONG.
 01 WS-CELL-X              BINARY-LONG.
 01 WS-CELL-Y              BINARY-LONG.
 01 WS-CELL-Z              BINARY-LONG.
 01 WS-HOME-X              BINARY-LONG.
 01 WS-HOME-Y              BINARY-LONG.
 01 WS-HOME-Z              BINARY-LONG.
 01 WS-CHUNK-X             BINARY-LONG.
 01 WS-CHUNK-Z             BINARY-LONG.
 01 WS-CHUNK               BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
 01 WS-RES                 BINARY-LONG.
 01 WS-INDEX               BINARY-LONG.
 01 WS-ALIVE               BINARY-LONG.
 01 WS-MIN-Y               BINARY-LONG VALUE -64.
 01 WS-MAX-Y               BINARY-LONG VALUE 319.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    FLOAT-LONG.
 01 L-Y                    FLOAT-LONG.
 01 L-Z                    FLOAT-LONG.
 01 L-POWER                FLOAT-LONG.
 01 L-TABLE.
    05 L-POS OCCURS 4096 TIMES.
       10 L-POS-X          BINARY-LONG.
       10 L-POS-Y          BINARY-LONG.
       10 L-POS-Z          BINARY-LONG.
 01 L-COUNT                BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z L-POWER L-TABLE L-COUNT.
     MOVE 0 TO L-COUNT
     INITIALIZE WS-MARKS
     COMPUTE WS-HOME-X = FUNCTION INTEGER(L-X)
     COMPUTE WS-HOME-Y = FUNCTION INTEGER(L-Y)
     COMPUTE WS-HOME-Z = FUNCTION INTEGER(L-Z)
     PERFORM VARYING WS-I FROM 0 BY 1 UNTIL WS-I > 15
         PERFORM VARYING WS-J FROM 0 BY 1 UNTIL WS-J > 15
             PERFORM VARYING WS-K FROM 0 BY 1 UNTIL WS-K > 15
                 IF WS-I = 0 OR WS-I = 15 OR WS-J = 0 OR WS-J = 15 OR WS-K = 0 OR WS-K = 15
                     COMPUTE WS-DX = WS-I / 15 * 2 - 1
                     COMPUTE WS-DY = WS-J / 15 * 2 - 1
                     COMPUTE WS-DZ = WS-K / 15 * 2 - 1
                     COMPUTE WS-LEN = FUNCTION SQRT(WS-DX * WS-DX + WS-DY * WS-DY + WS-DZ * WS-DZ)
                     COMPUTE WS-DX = WS-DX / WS-LEN * 0.3
                     COMPUTE WS-DY = WS-DY / WS-LEN * 0.3
                     COMPUTE WS-DZ = WS-DZ / WS-LEN * 0.3
                     CALL "XP-RANDOM" USING WS-SALT WS-BOUND WS-R
                     COMPUTE WS-STRENGTH = L-POWER * (0.7 + WS-R / 1000 * 0.6)
                     MOVE L-X TO WS-PX
                     MOVE L-Y TO WS-PY
                     MOVE L-Z TO WS-PZ
                     MOVE 1 TO WS-ALIVE
                     PERFORM UNTIL WS-STRENGTH <= 0 OR WS-ALIVE = 0
                         COMPUTE WS-CELL-X = FUNCTION INTEGER(WS-PX)
                         COMPUTE WS-CELL-Y = FUNCTION INTEGER(WS-PY)
                         COMPUTE WS-CELL-Z = FUNCTION INTEGER(WS-PZ)
                         COMPUTE WS-CHUNK-X = FUNCTION INTEGER(WS-CELL-X / 16)
                         COMPUTE WS-CHUNK-Z = FUNCTION INTEGER(WS-CELL-Z / 16)
                         CALL "WORLD-FIND" USING L-DIM WS-CHUNK-X WS-CHUNK-Z WS-CHUNK
                         IF WS-CHUNK = 0 OR WS-CELL-Y < WS-MIN-Y OR WS-CELL-Y > WS-MAX-Y
                             MOVE 0 TO WS-ALIVE
                         ELSE
                             CALL "WORLD-GET-BLOCK" USING L-DIM WS-CELL-X WS-CELL-Y WS-CELL-Z WS-STATE
                             COMPUTE WS-BLOCK = CB-S-BLOCK(WS-STATE + 1)
                             CALL "EXPLODE-RESIST" USING WS-BLOCK WS-RES
                             IF WS-RES >= 0
                                 COMPUTE WS-STRENGTH = WS-STRENGTH - (WS-RES / 1000 + 0.3) * 0.3
                                 COMPUTE WS-INDEX = (WS-CELL-X - WS-HOME-X + 16) * 1089 + (WS-CELL-Z - WS-HOME-Z + 16) * 33
                                     + (WS-CELL-Y - WS-HOME-Y + 16) + 1
                                 IF WS-STRENGTH > 0 AND WS-INDEX >= 1 AND WS-INDEX <= 35937 AND L-COUNT < 4096
                                     IF WS-MARK(WS-INDEX) = 0
                                         MOVE 1 TO WS-MARK(WS-INDEX)
                                         ADD 1 TO L-COUNT
                                         MOVE WS-CELL-X TO L-POS-X(L-COUNT)
                                         MOVE WS-CELL-Y TO L-POS-Y(L-COUNT)
                                         MOVE WS-CELL-Z TO L-POS-Z(L-COUNT)
                                     END-IF
                                 END-IF
                             END-IF
                             COMPUTE WS-PX = WS-PX + WS-DX
                             COMPUTE WS-PY = WS-PY + WS-DY
                             COMPUTE WS-PZ = WS-PZ + WS-DZ
                             COMPUTE WS-STRENGTH = WS-STRENGTH - 0.225
                         END-IF
                     END-PERFORM
                 END-IF
             END-PERFORM
         END-PERFORM
     END-PERFORM
     GOBACK.
 END PROGRAM EXPLODE-BLOCKS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EXPLODE-SEEN.
*> USING dim, centre x, y, z, box minx, miny, minz, maxx, maxy, maxz (FLOAT-LONG each), seen out (FLOAT-LONG): getSeenPercent (20 section 6.2): the
*> steps 1 / (2 extent + 1) per axis, the horizontal offsets (1 - floor(1 / step) x step) / 2, sample parameters from 0 to 1 inclusive; a sample is
*> unobstructed when the segment to the centre meets no solid cell (stepped by 0.1 block).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-SX                  FLOAT-LONG.
 01 WS-SY                  FLOAT-LONG.
 01 WS-SZ                  FLOAT-LONG.
 01 WS-OX                  FLOAT-LONG.
 01 WS-OZ                  FLOAT-LONG.
 01 WS-NX                  BINARY-LONG.
 01 WS-NY                  BINARY-LONG.
 01 WS-NZ                  BINARY-LONG.
 01 WS-A                   BINARY-LONG.
 01 WS-B                   BINARY-LONG.
 01 WS-C                   BINARY-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-DX                  FLOAT-LONG.
 01 WS-DY                  FLOAT-LONG.
 01 WS-DZ                  FLOAT-LONG.
 01 WS-LEN                 FLOAT-LONG.
 01 WS-STEPS               BINARY-LONG.
 01 WS-S                   BINARY-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CY                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-SOLID               BINARY-LONG.
 01 WS-HIT                 BINARY-LONG.
 01 WS-FREE                BINARY-LONG.
 01 WS-TOTAL               BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-CX                   FLOAT-LONG.
 01 L-CY                   FLOAT-LONG.
 01 L-CZ                   FLOAT-LONG.
 01 L-MINX                 FLOAT-LONG.
 01 L-MINY                 FLOAT-LONG.
 01 L-MINZ                 FLOAT-LONG.
 01 L-MAXX                 FLOAT-LONG.
 01 L-MAXY                 FLOAT-LONG.
 01 L-MAXZ                 FLOAT-LONG.
 01 L-SEEN                 FLOAT-LONG.
 PROCEDURE DIVISION USING L-DIM L-CX L-CY L-CZ L-MINX L-MINY L-MINZ L-MAXX L-MAXY L-MAXZ L-SEEN.
     COMPUTE WS-SX = 1 / (2 * (L-MAXX - L-MINX) + 1)
     COMPUTE WS-SY = 1 / (2 * (L-MAXY - L-MINY) + 1)
     COMPUTE WS-SZ = 1 / (2 * (L-MAXZ - L-MINZ) + 1)
     COMPUTE WS-NX = FUNCTION INTEGER(1 / WS-SX + 0.000001)
     COMPUTE WS-NY = FUNCTION INTEGER(1 / WS-SY + 0.000001)
     COMPUTE WS-NZ = FUNCTION INTEGER(1 / WS-SZ + 0.000001)
     COMPUTE WS-OX = (1 - WS-NX * WS-SX) / 2
     COMPUTE WS-OZ = (1 - WS-NZ * WS-SZ) / 2
     MOVE 0 TO WS-FREE WS-TOTAL
     PERFORM VARYING WS-A FROM 0 BY 1 UNTIL WS-A > WS-NX
         PERFORM VARYING WS-B FROM 0 BY 1 UNTIL WS-B > WS-NY
             PERFORM VARYING WS-C FROM 0 BY 1 UNTIL WS-C > WS-NZ
                 ADD 1 TO WS-TOTAL
                 COMPUTE WS-X = L-MINX + WS-A * WS-SX * (L-MAXX - L-MINX) + WS-OX
                 COMPUTE WS-Y = L-MINY + WS-B * WS-SY * (L-MAXY - L-MINY)
                 COMPUTE WS-Z = L-MINZ + WS-C * WS-SZ * (L-MAXZ - L-MINZ) + WS-OZ
                 COMPUTE WS-DX = L-CX - WS-X
                 COMPUTE WS-DY = L-CY - WS-Y
                 COMPUTE WS-DZ = L-CZ - WS-Z
                 COMPUTE WS-LEN = FUNCTION SQRT(WS-DX * WS-DX + WS-DY * WS-DY + WS-DZ * WS-DZ)
                 COMPUTE WS-STEPS = FUNCTION INTEGER(WS-LEN / 0.1) + 1
                 MOVE 0 TO WS-HIT
                 PERFORM VARYING WS-S FROM 0 BY 1 UNTIL WS-S > WS-STEPS OR WS-HIT = 1
                     COMPUTE WS-CX = FUNCTION INTEGER(WS-X + WS-DX * WS-S / WS-STEPS)
                     COMPUTE WS-CY = FUNCTION INTEGER(WS-Y + WS-DY * WS-S / WS-STEPS)
                     COMPUTE WS-CZ = FUNCTION INTEGER(WS-Z + WS-DZ * WS-S / WS-STEPS)
                     CALL "GI-SOLID-CELL" USING L-DIM WS-CX WS-CY WS-CZ WS-SOLID
                     IF WS-SOLID = 1
                         MOVE 1 TO WS-HIT
                     END-IF
                 END-PERFORM
                 IF WS-HIT = 0
                     ADD 1 TO WS-FREE
                 END-IF
             END-PERFORM
         END-PERFORM
     END-PERFORM
     COMPUTE L-SEEN = WS-FREE / WS-TOTAL
     GOBACK.
 END PROGRAM EXPLODE-SEEN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EXPLODE-BUILD.
*> USING x, y, z, power (FLOAT-LONG), block count (BINARY-LONG), knockback present (BINARY-LONG 0/1), kx, ky, kz (FLOAT-LONG), PB-BUFFER:
*> Explode 0x24 (05a): centre, radius, block count (Int), the optional knockback, the explosion particle (explosion_emitter 29 from power 2,
*> else explosion 30), the inline sound minecraft:entity.generic.explode, no block particles, play sound true.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-PACKET-ID           BINARY-LONG VALUE 36.
 01 WS-RADIUS              FLOAT-SHORT.
 01 WS-PARTICLE            BINARY-LONG.
 01 WS-NONE                BINARY-LONG VALUE 0.
 01 WS-DATA                PIC X(64).
 01 WS-SOUND               PIC X(32) VALUE "minecraft:entity.generic.explode".
 01 WS-SOUND-LENGTH        BINARY-LONG VALUE 32.
 01 WS-TRUE                BINARY-LONG VALUE 1.
 01 WS-FALSE               BINARY-LONG VALUE 0.
 LINKAGE SECTION.
 COPY PROTO.
 01 L-X                    FLOAT-LONG.
 01 L-Y                    FLOAT-LONG.
 01 L-Z                    FLOAT-LONG.
 01 L-POWER                FLOAT-LONG.
 01 L-BLOCKS               BINARY-LONG.
 01 L-KNOCK                BINARY-LONG.
 01 L-KX                   FLOAT-LONG.
 01 L-KY                   FLOAT-LONG.
 01 L-KZ                   FLOAT-LONG.
 PROCEDURE DIVISION USING L-X L-Y L-Z L-POWER L-BLOCKS L-KNOCK L-KX L-KY L-KZ PB-BUFFER.
     MOVE L-POWER TO WS-RADIUS
     MOVE 30 TO WS-PARTICLE
     IF L-POWER >= 2
         MOVE 29 TO WS-PARTICLE
     END-IF
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-PACKET-ID
     CALL "PB-PUT-DOUBLE" USING PB-BUFFER L-X
     CALL "PB-PUT-DOUBLE" USING PB-BUFFER L-Y
     CALL "PB-PUT-DOUBLE" USING PB-BUFFER L-Z
     CALL "PB-PUT-FLOAT" USING PB-BUFFER WS-RADIUS
     CALL "PB-PUT-INT" USING PB-BUFFER L-BLOCKS
     IF L-KNOCK = 1
         CALL "PB-PUT-BOOL" USING PB-BUFFER WS-TRUE
         CALL "PB-PUT-DOUBLE" USING PB-BUFFER L-KX
         CALL "PB-PUT-DOUBLE" USING PB-BUFFER L-KY
         CALL "PB-PUT-DOUBLE" USING PB-BUFFER L-KZ
     ELSE
         CALL "PB-PUT-BOOL" USING PB-BUFFER WS-FALSE
     END-IF
     CALL "PB-PUT-PARTICLE" USING PB-BUFFER WS-PARTICLE WS-NONE WS-DATA
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-NONE
     CALL "PB-PUT-IDENTIFIER" USING PB-BUFFER WS-SOUND WS-SOUND-LENGTH
     CALL "PB-PUT-BOOL" USING PB-BUFFER WS-FALSE
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-NONE
     CALL "PB-PUT-BOOL" USING PB-BUFFER WS-TRUE
     GOBACK.
 END PROGRAM EXPLODE-BUILD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EXPLODE-RUN.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CITEMS.
 COPY RULES.
 COPY PROTO.
 01 WS-CAPACITY            BINARY-LONG VALUE 256.
 01 WS-TABLE.
    05 WS-POS OCCURS 4096 TIMES.
       10 WS-POS-X         BINARY-LONG.
       10 WS-POS-Y         BINARY-LONG.
       10 WS-POS-Z         BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-REACH               FLOAT-LONG.
 01 WS-P                   BINARY-LONG.
 01 WS-E                   BINARY-LONG.
 01 WS-M                   BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-DX                  FLOAT-LONG.
 01 WS-DY                  FLOAT-LONG.
 01 WS-DZ                  FLOAT-LONG.
 01 WS-DIST                FLOAT-LONG.
 01 WS-LEN                 FLOAT-LONG.
 01 WS-WIDTH               FLOAT-LONG.
 01 WS-HEIGHT              FLOAT-LONG.
 01 WS-SEEN                FLOAT-LONG.
 01 WS-MINX                FLOAT-LONG.
 01 WS-MINY                FLOAT-LONG.
 01 WS-MINZ                FLOAT-LONG.
 01 WS-MAXX                FLOAT-LONG.
 01 WS-MAXY                FLOAT-LONG.
 01 WS-MAXZ                FLOAT-LONG.
 01 WS-S                   FLOAT-LONG.
 01 WS-DAMAGE              FLOAT-LONG.
 01 WS-MILLI               BINARY-LONG.
 01 WS-POINTS              BINARY-LONG.
 01 WS-RESULT              BINARY-LONG.
 01 WS-CAUSE               BINARY-LONG VALUE CAUSE-EXPLOSION.
 01 WS-SOURCE-ID           BINARY-LONG.
 01 WS-NONE                BINARY-LONG VALUE 0.
 01 WS-NONE2               BINARY-LONG VALUE 0.
 01 WS-STATE               BINARY-LONG.
 01 WS-AIR                 BINARY-LONG VALUE 0.
 01 WS-FOUND               BINARY-LONG.
 01 WS-DROP-TOOL           BINARY-LONG VALUE 0.
 01 WS-DROP-SET            BINARY-LONG VALUE 1.
 01 WS-DECAY-RULE           PIC X(40) VALUE "mob_explosion_drop_decay".
 01 WS-DECAY                BINARY-DOUBLE.
 01 WS-KNOCK.
    05 WS-KN OCCURS 64 TIMES.
       10 WS-KN-SET        BINARY-LONG.
       10 WS-KN-X          FLOAT-LONG.
       10 WS-KN-Y          FLOAT-LONG.
       10 WS-KN-Z          FLOAT-LONG.
 01 WS-NAME                PIC X(16).
 01 WS-NAME-LENGTH         BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-BLOCKS-SENT         BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    FLOAT-LONG.
 01 L-Y                    FLOAT-LONG.
 01 L-Z                    FLOAT-LONG.
 01 L-POWER                FLOAT-LONG.
 01 L-DESTROY              BINARY-LONG.
 01 L-SOURCE               BINARY-LONG.
*> USING dim, x, y, z (FLOAT-LONG), power (FLOAT-LONG), destroy blocks (0/1), source tracker row (0 none): one explosion; the damage of an entity
*> is ((s x s + s) / 2 x 7 x 2 power + 1) with s = (1 - distance / 2 power) x seen (a player in thousandths of a point, a mob in whole points),
*> and a hit survival player's knockback is s x the direction from the centre to its eyes (sent in the Explode packet).
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z L-POWER L-DESTROY L-SOURCE.
     INITIALIZE WS-KNOCK
     MOVE 0 TO WS-SOURCE-ID
     IF L-SOURCE > 0
         MOVE EN-ID(L-SOURCE) TO WS-SOURCE-ID
     END-IF
     CALL "EXPLODE-BLOCKS" USING L-DIM L-X L-Y L-Z L-POWER WS-TABLE WS-COUNT
     COMPUTE WS-REACH = 2 * L-POWER
*>   Players.
     PERFORM VARYING WS-P FROM 1 BY 1 UNTIL WS-P > CORE-MAX-PLAYERS
         IF PL-USED(WS-P) = 1 AND PL-ENTITY-ROW(WS-P) > 0 AND PL-STATE(WS-P) = PS-ALIVE AND PL-DIM(WS-P) = L-DIM
                 AND PL-MODE(WS-P) < 3
             COMPUTE WS-DX = PL-X(WS-P) - L-X
             COMPUTE WS-DY = PL-Y(WS-P) - L-Y
             COMPUTE WS-DZ = PL-Z(WS-P) - L-Z
             COMPUTE WS-DIST = FUNCTION SQRT(WS-DX * WS-DX + WS-DY * WS-DY + WS-DZ * WS-DZ) / WS-REACH
             IF WS-DIST <= 1
                 COMPUTE WS-MINX = PL-X(WS-P) - 0.3
                 COMPUTE WS-MAXX = PL-X(WS-P) + 0.3
                 MOVE PL-Y(WS-P) TO WS-MINY
                 COMPUTE WS-MAXY = PL-Y(WS-P) + 1.8
                 COMPUTE WS-MINZ = PL-Z(WS-P) - 0.3
                 COMPUTE WS-MAXZ = PL-Z(WS-P) + 0.3
                 CALL "EXPLODE-SEEN" USING L-DIM L-X L-Y L-Z WS-MINX WS-MINY WS-MINZ WS-MAXX WS-MAXY WS-MAXZ WS-SEEN
                 COMPUTE WS-S = (1 - WS-DIST) * WS-SEEN
                 COMPUTE WS-DAMAGE = (WS-S * WS-S + WS-S) / 2 * 7 * WS-REACH + 1
                 COMPUTE WS-MILLI = WS-DAMAGE * 1000
                 MOVE SPACES TO PL-KILLER-NAME(WS-P)
                 MOVE 0 TO PL-KILLER-LENGTH(WS-P)
                 IF L-SOURCE > 0
                     CALL "STDMOB-NAME" USING EN-TYPE(L-SOURCE) WS-NAME WS-NAME-LENGTH
                     MOVE WS-NAME TO PL-KILLER-NAME(WS-P)
                     MOVE WS-NAME-LENGTH TO PL-KILLER-LENGTH(WS-P)
                 END-IF
                 CALL "HEALTH-HURT" USING WS-P WS-MILLI WS-CAUSE WS-SOURCE-ID WS-NONE WS-RESULT
                 IF PL-MODE(WS-P) = 0 OR PL-FLYING(WS-P) = 0
                     COMPUTE WS-DY = PL-Y(WS-P) + 1.62 - L-Y
                     COMPUTE WS-DX = PL-X(WS-P) - L-X
                     COMPUTE WS-DZ = PL-Z(WS-P) - L-Z
                     COMPUTE WS-LEN = FUNCTION SQRT(WS-DX * WS-DX + WS-DY * WS-DY + WS-DZ * WS-DZ)
                     IF WS-LEN > 0
                         MOVE 1 TO WS-KN-SET(WS-P)
                         COMPUTE WS-KN-X(WS-P) = WS-DX / WS-LEN * WS-S
                         COMPUTE WS-KN-Y(WS-P) = WS-DY / WS-LEN * WS-S
                         COMPUTE WS-KN-Z(WS-P) = WS-DZ / WS-LEN * WS-S
                     END-IF
                 END-IF
             END-IF
         END-IF
     END-PERFORM
*>   Standard mobs that are alive.
     PERFORM VARYING WS-E FROM 1 BY 1 UNTIL WS-E > EN-COUNT
         IF EN-USED(WS-E) = 1 AND EN-DIM(WS-E) = L-DIM AND EN-HEALTH(WS-E) > 0 AND WS-E NOT = L-SOURCE
             CALL "STDMOB-INDEX" USING EN-TYPE(WS-E) WS-M
             IF WS-M > 0
                 COMPUTE WS-DX = EN-X(WS-E) - L-X
                 COMPUTE WS-DY = EN-Y(WS-E) - L-Y
                 COMPUTE WS-DZ = EN-Z(WS-E) - L-Z
                 COMPUTE WS-DIST = FUNCTION SQRT(WS-DX * WS-DX + WS-DY * WS-DY + WS-DZ * WS-DZ) / WS-REACH
                 IF WS-DIST <= 1
                     COMPUTE WS-WIDTH = ET-WIDTH-MILLI(EN-TYPE(WS-E) + 1) / 1000
                     COMPUTE WS-HEIGHT = ET-HEIGHT-MILLI(EN-TYPE(WS-E) + 1) / 1000
                     COMPUTE WS-MINX = EN-X(WS-E) - WS-WIDTH / 2
                     COMPUTE WS-MAXX = EN-X(WS-E) + WS-WIDTH / 2
                     MOVE EN-Y(WS-E) TO WS-MINY
                     COMPUTE WS-MAXY = EN-Y(WS-E) + WS-HEIGHT
                     COMPUTE WS-MINZ = EN-Z(WS-E) - WS-WIDTH / 2
                     COMPUTE WS-MAXZ = EN-Z(WS-E) + WS-WIDTH / 2
                     CALL "EXPLODE-SEEN" USING L-DIM L-X L-Y L-Z WS-MINX WS-MINY WS-MINZ WS-MAXX WS-MAXY WS-MAXZ WS-SEEN
                     COMPUTE WS-S = (1 - WS-DIST) * WS-SEEN
                     COMPUTE WS-DAMAGE = (WS-S * WS-S + WS-S) / 2 * 7 * WS-REACH + 1
                     COMPUTE WS-POINTS = FUNCTION INTEGER(WS-DAMAGE)
                     MOVE 0 TO EN-HURT(WS-E)
                     CALL "HEALTH-MOB-DAMAGE" USING WS-E WS-POINTS WS-CAUSE WS-NONE
*>                   The push: s x the direction from the centre to the mob's eyes (0.85 of its height), carried by STDMOB-STEP.
                     IF EN-HEALTH(WS-E) > 0
                         COMPUTE WS-DY = EN-Y(WS-E) + WS-HEIGHT * 0.85 - L-Y
                         COMPUTE WS-DX = EN-X(WS-E) - L-X
                         COMPUTE WS-DZ = EN-Z(WS-E) - L-Z
                         COMPUTE WS-LEN = FUNCTION SQRT(WS-DX * WS-DX + WS-DY * WS-DY + WS-DZ * WS-DZ)
                         IF WS-LEN > 0
                             COMPUTE EN-VX(WS-E) = EN-VX(WS-E) + WS-DX / WS-LEN * WS-S
                             COMPUTE EN-VY(WS-E) = EN-VY(WS-E) + WS-DY / WS-LEN * WS-S
                             COMPUTE EN-VZ(WS-E) = EN-VZ(WS-E) + WS-DZ / WS-LEN * WS-S
                         END-IF
                     END-IF
                 END-IF
             END-IF
         END-IF
     END-PERFORM
*>   The blocks: replaced by air, each drop kept with probability 1 / power.
     MOVE 0 TO WS-BLOCKS-SENT
*>   The drops of a mob's blast decay only while mob_explosion_drop_decay is true (20 section 6.2); a blast without a source always decays.
     MOVE 1 TO WS-DROP-SET
     IF L-SOURCE > 0
         CALL "BR-RULE-GET" USING WS-DECAY-RULE WS-DECAY
         MOVE WS-DECAY TO WS-DROP-SET
     END-IF
     IF L-DESTROY = 1
         MOVE WS-COUNT TO WS-BLOCKS-SENT
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-COUNT
             CALL "WORLD-GET-BLOCK" USING L-DIM WS-POS-X(WS-I) WS-POS-Y(WS-I) WS-POS-Z(WS-I) WS-STATE
             CALL "BLOCK-CHANGE" USING L-DIM WS-POS-X(WS-I) WS-POS-Y(WS-I) WS-POS-Z(WS-I) WS-AIR
             CALL "BLOCK-DROPS-SPAWN" USING L-DIM WS-POS-X(WS-I) WS-POS-Y(WS-I) WS-POS-Z(WS-I) WS-STATE WS-DROP-TOOL
                 WS-NONE WS-NONE2 WS-DROP-SET L-POWER WS-FOUND
         END-PERFORM
     END-IF
*>   The Explode packet to every player within 64 blocks.
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     PERFORM VARYING WS-P FROM 1 BY 1 UNTIL WS-P > CORE-MAX-PLAYERS
         IF PL-USED(WS-P) = 1 AND PL-ENTITY-ROW(WS-P) > 0 AND PL-DIM(WS-P) = L-DIM
             COMPUTE WS-DX = PL-X(WS-P) - L-X
             COMPUTE WS-DY = PL-Y(WS-P) - L-Y
             COMPUTE WS-DZ = PL-Z(WS-P) - L-Z
             IF WS-DX * WS-DX + WS-DY * WS-DY + WS-DZ * WS-DZ < 4096
                 CALL "PB-RESET" USING PB-BUFFER
                 CALL "EXPLODE-BUILD" USING L-X L-Y L-Z L-POWER WS-BLOCKS-SENT WS-KN-SET(WS-P) WS-KN-X(WS-P) WS-KN-Y(WS-P)
                     WS-KN-Z(WS-P) PB-BUFFER
                 CALL "CORE-SEND" USING PL-CONN(WS-P) PB-BUFFER
             END-IF
         END-IF
     END-PERFORM
     CALL "PB-FREE" USING PB-BUFFER
     GOBACK.
 END PROGRAM EXPLODE-RUN.
