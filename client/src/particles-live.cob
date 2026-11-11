*> The live particles of the client (docs/protocol/42-particles-1 sections 4 to 7, 42-particles-2): the
*> glue between the particle library (particles-42-*.cob, which holds the per-class constructors and ticks
*> as pure programs) and the client. A Level Particles packet (05a 0x30; PROTO-PACKET) is read by
*> PARTICLES-READ (PENTRY-PACKET: fields; PENTRY-SPAWNS: the spawns of count, spread and speed, chunked by 32;
*> PENTRY-FLAGS, PENTRY-STATUS, PENTRY-DECIDE: the override, status and 32-block tests of 42-1 section 7.1),
*> each created particle is built by its class constructor (PARTICLE-SPAWN, the type to class table of
*> PARTICLE-CLASS) and queued in the engine (PENG-ADD); PARTICLES-TICK, called from CL-STEP at the client
*> tick rate, ticks the quad group's particles in insertion order and then runs the engine's insert and
*> remove step (PENG-REAP: 42-1 section 5.5: a particle created outside the tick is inserted in the next tick
*> and drawn after that); PARTICLES-MESH turns the quad group into the frame's particle vertices (six per
*> particle, eye-relative, camera-facing; texture 4, translucent); PARTICLE-ATLAS-BUILD loads the sprites
*> of the wired types from the pack stack into the particle atlas (texture 4).
*> The store (CLPSTORE.cpy) is an EXTERNAL block: the engine record is about 800 KB, too big for CLIENT-STATE.
*> Wired provider classes (the others of the 128 types stay unwired, see tasks.md and scratchpad notes):
*>   1 HeartParticle (angry_villager, heart)            4 PlayerCloudParticle (cloud, sneeze)
*>   2 CritParticle (crit, enchanted_hit, damage_indicator)   5 HugeExplosionParticle (explosion)
*>   3 ExplodeParticle and SpitParticle (poof, spit)    6 AttackSweepParticle (sweep_attack)
*>   7 smoke family BaseAshSmokeParticle (smoke, large_smoke, white_smoke)
*> Block collision is not asked of the replica (the collider list is empty), light is full bright, and the
*> view-frustum cull and the opaque/translucent layer split of 42-1 sections 4.3 and 5.6 are not applied.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PARTICLE-CLASS.
*> USING registry id, class out (0 = not wired), kind out: the provider class of a particle type and the
*> kind argument of its constructor (the table of 42-1 section 2, "Provider" column).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-ROWS-DATA.
    05 FILLER              PIC X(5) VALUE "00011".
    05 FILLER              PIC X(5) VALUE "05510".
    05 FILLER              PIC X(5) VALUE "01320".
    05 FILLER              PIC X(5) VALUE "02521".
    05 FILLER              PIC X(5) VALUE "01422".
    05 FILLER              PIC X(5) VALUE "06930".
    05 FILLER              PIC X(5) VALUE "07531".
    05 FILLER              PIC X(5) VALUE "01140".
    05 FILLER              PIC X(5) VALUE "07441".
    05 FILLER              PIC X(5) VALUE "03050".
    05 FILLER              PIC X(5) VALUE "07760".
    05 FILLER              PIC X(5) VALUE "07270".
    05 FILLER              PIC X(5) VALUE "06571".
    05 FILLER              PIC X(5) VALUE "07372".
 01 WS-ROWS REDEFINES WS-ROWS-DATA.
    05 WS-ROW OCCURS 14 TIMES.
       10 WS-R-TYPE        PIC 999.
       10 WS-R-CLASS       PIC 9.
       10 WS-R-KIND        PIC 9.
 01 WS-I                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-TYPE                 BINARY-LONG.
 01 L-CLASS                BINARY-LONG.
 01 L-KIND                 BINARY-LONG.
 PROCEDURE DIVISION USING L-TYPE L-CLASS L-KIND.
     MOVE 0 TO L-CLASS L-KIND
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 14
         IF WS-R-TYPE(WS-I) = L-TYPE
             MOVE WS-R-CLASS(WS-I) TO L-CLASS
             MOVE WS-R-KIND(WS-I) TO L-KIND
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM PARTICLE-CLASS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PARTICLE-RANDOM.
*> USING value out (FLOAT-LONG): the next uniform draw in [0, 1) of the particle random source, seeded from
*> the clock on first use (42-1 section 1.1: particle behaviour is statistical, no seeded generator).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-SEEDED              BINARY-LONG VALUE 0.
 01 WS-SEED                BINARY-LONG.
 LINKAGE SECTION.
 01 L-R                    FLOAT-LONG.
 PROCEDURE DIVISION USING L-R.
     IF WS-SEEDED = 0
         COMPUTE WS-SEED = FUNCTION INTEGER(FUNCTION SECONDS-PAST-MIDNIGHT * 100) + 1
         COMPUTE L-R = FUNCTION RANDOM(WS-SEED)
         MOVE 1 TO WS-SEEDED
         GOBACK
     END-IF
     COMPUTE L-R = FUNCTION RANDOM
     GOBACK.
 END PROGRAM PARTICLE-RANDOM.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PARTICLE-DRAWS.
*> USING randomisation (0 DEFAULT: standard normal draws, Box-Muller from two uniforms; else uniform
*> [0, 1)), draws out (192 FLOAT-LONG): the draw table PENTRY-SPAWNS consumes in order.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-I                   BINARY-LONG.
 01 WS-U1                  FLOAT-LONG.
 01 WS-U2                  FLOAT-LONG.
 LINKAGE SECTION.
 01 L-MODE                 BINARY-LONG.
 01 L-DRAWS.
    05 L-DRAW              FLOAT-LONG OCCURS 192 TIMES.
 PROCEDURE DIVISION USING L-MODE L-DRAWS.
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 192
         CALL "PARTICLE-RANDOM" USING WS-U1
         IF L-MODE = 0
             CALL "PARTICLE-RANDOM" USING WS-U2
             COMPUTE L-DRAW(WS-I) = FUNCTION SQRT(0 - 2 * FUNCTION LOG(1 - WS-U1))
                 * FUNCTION COS(2 * FUNCTION PI * WS-U2)
         ELSE
             MOVE WS-U1 TO L-DRAW(WS-I)
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM PARTICLE-DRAWS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PARTICLES-CLEAR.
*> USING CLIENT-STATE: no particles: the engine's groups, add queue and counters and the store are empty
*> (42-1 section 5.2 setLevel / clearParticles). Called by CL-INIT and DIMENSION-ENTER.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLPSTORE.
 LINKAGE SECTION.
 COPY CLSTATE.
 PROCEDURE DIVISION USING CLIENT-STATE.
     CALL "PENG-INIT" USING ENGINE
     INITIALIZE PQ-STORE
     GOBACK.
 END PROGRAM PARTICLES-CLEAR.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PARTICLE-SPAWN.
*> USING CLIENT-STATE, registry id, x, y, z, vx, vy, vz (FLOAT-LONG): builds the particle of a wired type
*> with its class constructor (random draws from PARTICLE-RANDOM in the document's order) and queues it in
*> the engine's quad group (inserted in the next tick); a type without a class, or a full store (2048),
*> spawns nothing. Explosion and sweep attack take vx as their scale (42-2 sections 3.4, 3.12).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLPCL.
 COPY CLPSTORE.
 01 WS-CLASS               BINARY-LONG.
 01 WS-KIND                BINARY-LONG.
 01 WS-SLOT                BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-DRAWS.
    05 WS-DRAW             FLOAT-LONG OCCURS 16 TIMES.
 01 WS-GROUP               BINARY-LONG VALUE 1.
 01 WS-LIMITED             BINARY-LONG VALUE 0.
 01 WS-OK                  BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-TYPE                 BINARY-LONG.
 01 L-X                    FLOAT-LONG.
 01 L-Y                    FLOAT-LONG.
 01 L-Z                    FLOAT-LONG.
 01 L-VX                   FLOAT-LONG.
 01 L-VY                   FLOAT-LONG.
 01 L-VZ                   FLOAT-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-TYPE L-X L-Y L-Z L-VX L-VY L-VZ.
     CALL "PARTICLE-CLASS" USING L-TYPE WS-CLASS WS-KIND
     IF WS-CLASS = 0
         GOBACK
     END-IF
     PERFORM VARYING WS-SLOT FROM 1 BY 1 UNTIL WS-SLOT > PQ-MAX OR PQ-USED(WS-SLOT) = 0
         CONTINUE
     END-PERFORM
     IF WS-SLOT > PQ-MAX
         GOBACK
     END-IF
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 16
         CALL "PARTICLE-RANDOM" USING WS-DRAW(WS-I)
     END-PERFORM
     INITIALIZE PCL PCL-COLLIDERS
     EVALUATE WS-CLASS
         WHEN 1
             CALL "P2-HEART-NEW" USING PCL L-X L-Y L-Z WS-KIND WS-DRAWS
         WHEN 2
             CALL "P2-CRIT-NEW" USING PCL L-X L-Y L-Z L-VX L-VY L-VZ WS-KIND WS-DRAWS PCL-COLLIDERS
         WHEN 3
             CALL "P2-POOF-NEW" USING PCL L-X L-Y L-Z L-VX L-VY L-VZ WS-KIND WS-DRAWS
         WHEN 4
             CALL "P2-CLOUD-NEW" USING PCL L-X L-Y L-Z L-VX L-VY L-VZ WS-KIND WS-DRAWS
         WHEN 5
             CALL "P2-EXPLOSION-NEW" USING PCL L-X L-Y L-Z L-VX WS-DRAWS
         WHEN 6
             CALL "P2-SWEEP-NEW" USING PCL L-X L-Y L-Z L-VX WS-DRAWS
         WHEN OTHER
             CALL "P2-SMOKE-NEW" USING PCL L-X L-Y L-Z L-VX L-VY L-VZ WS-KIND WS-DRAWS
     END-EVALUATE
     MOVE PCL TO PQ-DATA(WS-SLOT)
     MOVE 1 TO PQ-USED(WS-SLOT)
     MOVE WS-CLASS TO PQ-CLASS(WS-SLOT)
     MOVE L-TYPE TO PQ-TYPE(WS-SLOT)
     ADD 1 TO PQ-LIVE
     CALL "PENG-ADD" USING ENGINE WS-SLOT WS-GROUP WS-LIMITED WS-OK
     GOBACK.
 END PROGRAM PARTICLE-SPAWN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PARTICLES-TICK.
*> USING CLIENT-STATE: one particle engine tick (42-1 section 5.5): every particle of the quad group is
*> ticked by its class in insertion order; those no longer alive are marked, then PENG-REAP removes them and
*> inserts the queued ones. Called by CL-STEP once per client tick.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLPCL.
 COPY CLPCLX.
 COPY CLPSTORE.
 01 WS-I                   BINARY-LONG.
 01 WS-H                   BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-T                   BINARY-LONG.
 01 WS-NO-PLAYER           BINARY-LONG VALUE 0.
 01 WS-PLAYER-Y            FLOAT-LONG VALUE 0.
 01 WS-PLAYER-YD           FLOAT-LONG VALUE 0.
 01 WS-DRAWS.
    05 WS-DRAW             FLOAT-LONG OCCURS 48 TIMES.
 LINKAGE SECTION.
 COPY CLSTATE.
 PROCEDURE DIVISION USING CLIENT-STATE.
     INITIALIZE WS-DRAWS PCLX PCL-COLLIDERS
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > EN-G-COUNT(1)
         MOVE EN-G-HANDLE(1, WS-I) TO WS-H
         MOVE PQ-DATA(WS-H)(1:240) TO PCL
         COMPUTE WS-T = PQ-TYPE(WS-H) + 1
         COMPUTE WS-N = FUNCTION MAX(PRA-COUNT(WS-T), 1)
         EVALUATE PQ-CLASS(WS-H)
             WHEN 1
                 CALL "PCL-TICK" USING PCL PCL-COLLIDERS
             WHEN 2
                 CALL "P2-CRIT-TICK" USING PCL PCL-COLLIDERS
             WHEN 3
                 CALL "P2-POOF-TICK" USING PCL PCL-COLLIDERS
             WHEN 4
                 CALL "P2-CLOUD-TICK" USING PCL PCL-COLLIDERS WS-NO-PLAYER WS-PLAYER-Y WS-PLAYER-YD
             WHEN 5
                 CALL "P2-EXPLOSION-TICK" USING PCL
             WHEN 6
                 CALL "P2-SWEEP-TICK" USING PCL
             WHEN OTHER
                 CALL "PASH-TICK" USING PCL PCLX PCL-COLLIDERS WS-N
         END-EVALUATE
         MOVE PCL TO PQ-DATA(WS-H)
         IF PC-REMOVED = 1
             MOVE 1 TO EN-G-DEAD(1, WS-I)
             MOVE 0 TO PQ-USED(WS-H)
             SUBTRACT 1 FROM PQ-LIVE
         END-IF
     END-PERFORM
     CALL "PENG-REAP" USING ENGINE WS-DRAWS
     GOBACK.
 END PROGRAM PARTICLES-TICK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PARTICLES-READ.
*> USING CLIENT-STATE, PB-BUFFER (at the packet body): Level Particles (05a 0x30, 42-1 section 7.2). The
*> spawns of the packet (count 0: one; else count, in chunks of 32) each go through the tests of section 7.1
*> (the type's override limiter and the packet's two flags, the Particles option, the 32-block camera
*> distance) and then PARTICLE-SPAWN. A short or malformed packet spawns nothing.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLPKT.
 COPY CLPART.
 01 WS-DRAWS.
    05 WS-DRAW             FLOAT-LONG OCCURS 192 TIMES.
 01 WS-ID                  BINARY-LONG.
 01 WS-NAME                PIC X(32).
 01 WS-OPTIONS             PIC X(16).
 01 WS-TYPE-OVERRIDE       BINARY-LONG.
 01 WS-PROVIDER            PIC X(56).
 01 WS-SPRITES             BINARY-LONG.
 01 WS-PART                BINARY-LONG.
 01 WS-OPTION-NAME         PIC X(40) VALUE "particles".
 01 WS-OPTION-VALUE        PIC X(64).
 01 WS-OPTION-LENGTH       BINARY-LONG.
 01 WS-OPTION-FOUND        BINARY-LONG.
 01 WS-STATUS-IN           BINARY-LONG.
 01 WS-STATUS              BINARY-LONG.
 01 WS-USED                BINARY-LONG.
 01 WS-ENTRY               BINARY-LONG VALUE 2.
 01 WS-FORCE               BINARY-LONG.
 01 WS-VISIBLE             BINARY-LONG.
 01 WS-D10                 BINARY-LONG.
 01 WS-D3                  BINARY-LONG.
 01 WS-R                   FLOAT-LONG.
 01 WS-CREATE              BINARY-LONG.
 01 WS-DIST2               FLOAT-LONG.
 01 WS-YAW                 FLOAT-LONG.
 01 WS-PITCH               FLOAT-LONG.
 01 WS-EYE-TABLE.
    05 WS-EYE              FLOAT-LONG OCCURS 3 TIMES.
 01 WS-REMAIN              BINARY-LONG.
 01 WS-MORE                BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-SX                  FLOAT-LONG.
 01 WS-SY                  FLOAT-LONG.
 01 WS-SZ                  FLOAT-LONG.
 01 WS-SVX                 FLOAT-LONG.
 01 WS-SVY                 FLOAT-LONG.
 01 WS-SVZ                 FLOAT-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 COPY PROTO.
 PROCEDURE DIVISION USING CLIENT-STATE PB-BUFFER.
     CALL "PENTRY-PACKET" USING PB-BUFFER PART-PACKET PART-OPTIONS
     IF PP-ERROR = 1
         GOBACK
     END-IF
     MOVE PP-TYPE TO WS-ID
     CALL "PART-TYPE" USING WS-ID WS-NAME WS-OPTIONS WS-TYPE-OVERRIDE WS-PROVIDER WS-SPRITES WS-PART
     MOVE 0 TO WS-STATUS-IN
     CALL "OPTIONS-GET" USING CLIENT-STATE WS-OPTION-NAME WS-OPTION-VALUE WS-OPTION-LENGTH
         WS-OPTION-FOUND
     IF WS-OPTION-FOUND = 1
         COMPUTE WS-STATUS-IN = FUNCTION NUMVAL(WS-OPTION-VALUE(1:WS-OPTION-LENGTH))
     END-IF
     CALL "CAMERA-PLACE" USING CLIENT-STATE WS-YAW WS-PITCH WS-EYE-TABLE
     CALL "PENTRY-FLAGS" USING WS-ENTRY WS-TYPE-OVERRIDE PP-OVERRIDE PP-ALWAYS WS-FORCE WS-VISIBLE
     MOVE PP-COUNT TO WS-REMAIN
     MOVE 1 TO WS-MORE
     PERFORM UNTIL WS-MORE = 0
         IF WS-REMAIN > PP-MAX-SPAWNS
             MOVE PP-MAX-SPAWNS TO PP-COUNT
         ELSE
             MOVE WS-REMAIN TO PP-COUNT
         END-IF
         SUBTRACT PP-COUNT FROM WS-REMAIN
         CALL "PARTICLE-DRAWS" USING PP-RANDOM WS-DRAWS
         CALL "PENTRY-SPAWNS" USING PART-PACKET WS-DRAWS PART-SPAWNS
         PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > PS-N
             CALL "PARTICLE-RANDOM" USING WS-R
             COMPUTE WS-D10 = FUNCTION INTEGER-PART(WS-R * 10)
             CALL "PARTICLE-RANDOM" USING WS-R
             COMPUTE WS-D3 = FUNCTION INTEGER-PART(WS-R * 3)
             CALL "PENTRY-STATUS" USING WS-VISIBLE WS-STATUS-IN WS-D10 WS-D3 WS-STATUS WS-USED
             MOVE PS-V(WS-K, 1) TO WS-SX
             MOVE PS-V(WS-K, 2) TO WS-SY
             MOVE PS-V(WS-K, 3) TO WS-SZ
             MOVE PS-V(WS-K, 4) TO WS-SVX
             MOVE PS-V(WS-K, 5) TO WS-SVY
             MOVE PS-V(WS-K, 6) TO WS-SVZ
             COMPUTE WS-DIST2 = (WS-SX - WS-EYE(1)) ** 2 + (WS-SY - WS-EYE(2)) ** 2
                 + (WS-SZ - WS-EYE(3)) ** 2
             CALL "PENTRY-DECIDE" USING WS-FORCE WS-STATUS WS-DIST2 WS-CREATE
             IF WS-CREATE = 1
                 CALL "PARTICLE-SPAWN" USING CLIENT-STATE WS-ID WS-SX WS-SY WS-SZ WS-SVX WS-SVY
                     WS-SVZ
             END-IF
         END-PERFORM
         IF WS-REMAIN <= 0
             MOVE 0 TO WS-MORE
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM PARTICLES-READ.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PARTICLES-MESH.
*> USING CLIENT-STATE, eye (3 FLOAT-LONG), view yaw, view pitch (FLOAT-LONG, degrees): RL-PT-VERTEX and
*> RL-PT-COUNT for this frame. Each particle of the quad group (PENG-RENDER-ORDER) is a camera-facing
*> square (42-1 section 4.3: LOOKAT_XYZ, the vertices at the position plus and minus the camera's right and
*> up vectors times the size; the position is lerp(partial, old, current), the partial tick taken from
*> the clock between client ticks), eye-relative, corners (+right, -up), (+right, +up), (-right, +up),
*> (-right, -down) with the sprite's u1,v1, u1,v0, u0,v0, u0,v1, drawn as the triangles 1 2 3, 1 3 4. The
*> size is quadSize (the smoke family's growth rule of 42-1 section 8.5), the colour is the particle's
*> colour times the texel, alpha the particle's, brightness 1 (full bright, sky 0). The sprite is the
*> particle's sprite index within its type's sprites of the atlas.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLCONST.
 COPY CLPCL.
 COPY CLPSTORE.
 01 WS-ORDER-TABLE.
    05 WS-ORDER            BINARY-LONG OCCURS 4 TIMES.
 01 WS-N                   BINARY-LONG.
 01 WS-G                   BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-H                   BINARY-LONG.
 01 WS-T                   BINARY-LONG.
 01 WS-C                   BINARY-LONG.
 01 WS-S                   BINARY-LONG.
 01 WS-SPRITE              BINARY-LONG.
 01 WS-INDEX               BINARY-LONG.
 01 WS-LAST                BINARY-LONG.
 01 WS-PARTIAL             FLOAT-LONG.
 01 WS-SIZE                FLOAT-LONG.
 01 WS-YAW                 FLOAT-LONG.
 01 WS-PITCH               FLOAT-LONG.
 01 WS-RIGHT               FLOAT-LONG OCCURS 3 TIMES.
 01 WS-UP                  FLOAT-LONG OCCURS 3 TIMES.
 01 WS-FWD                 FLOAT-LONG OCCURS 3 TIMES.
 01 WS-POS                 FLOAT-LONG OCCURS 3 TIMES.
 01 WS-U0                  FLOAT-LONG.
 01 WS-U1                  FLOAT-LONG.
 01 WS-V0                  FLOAT-LONG.
 01 WS-V1                  FLOAT-LONG.
 01 WS-ORDER-DATA          PIC X(6) VALUE "123134".
 01 WS-ORD REDEFINES WS-ORDER-DATA.
    05 WS-O                PIC 9 OCCURS 6 TIMES.
 01 WS-SR-DATA             PIC X(4) VALUE "++--".
 01 WS-SR REDEFINES WS-SR-DATA.
    05 WS-SIGN-R           PIC X OCCURS 4 TIMES.
 01 WS-SU-DATA             PIC X(4) VALUE "-++-".
 01 WS-SU REDEFINES WS-SU-DATA.
    05 WS-SIGN-U           PIC X OCCURS 4 TIMES.
 01 WS-SELU-DATA           PIC X(4) VALUE "1100".
 01 WS-SELU REDEFINES WS-SELU-DATA.
    05 WS-U-SEL            PIC 9 OCCURS 4 TIMES.
 01 WS-SELV-DATA           PIC X(4) VALUE "1001".
 01 WS-SELV REDEFINES WS-SELV-DATA.
    05 WS-V-SEL            PIC 9 OCCURS 4 TIMES.
 01 WS-CX                  FLOAT-LONG OCCURS 4 TIMES.
 01 WS-CY                  FLOAT-LONG OCCURS 4 TIMES.
 01 WS-CZ                  FLOAT-LONG OCCURS 4 TIMES.
 01 WS-CU                  FLOAT-LONG OCCURS 4 TIMES.
 01 WS-CV                  FLOAT-LONG OCCURS 4 TIMES.
 01 WS-SR-VALUE            FLOAT-LONG.
 01 WS-SU-VALUE            FLOAT-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-EYE-TABLE.
    05 L-EYE               FLOAT-LONG OCCURS 3 TIMES.
 01 L-YAW                  FLOAT-LONG.
 01 L-PITCH                FLOAT-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-EYE-TABLE L-YAW L-PITCH.
     MOVE 0 TO RL-PT-COUNT
     CALL "PENG-RENDER-ORDER" USING ENGINE WS-ORDER-TABLE WS-N
*>   The camera's right and up vectors (the view of RENDER-LIST-BUILD).
     COMPUTE WS-YAW = L-YAW * FUNCTION PI / 180
     COMPUTE WS-PITCH = L-PITCH * FUNCTION PI / 180
     COMPUTE WS-FWD(1) = 0 - FUNCTION SIN(WS-YAW) * FUNCTION COS(WS-PITCH)
     COMPUTE WS-FWD(2) = 0 - FUNCTION SIN(WS-PITCH)
     COMPUTE WS-FWD(3) = FUNCTION COS(WS-YAW) * FUNCTION COS(WS-PITCH)
     COMPUTE WS-RIGHT(1) = 0 - FUNCTION COS(WS-YAW)
     MOVE 0 TO WS-RIGHT(2)
     COMPUTE WS-RIGHT(3) = 0 - FUNCTION SIN(WS-YAW)
     COMPUTE WS-UP(1) = WS-RIGHT(2) * WS-FWD(3) - WS-RIGHT(3) * WS-FWD(2)
     COMPUTE WS-UP(2) = WS-RIGHT(3) * WS-FWD(1) - WS-RIGHT(1) * WS-FWD(3)
     COMPUTE WS-UP(3) = WS-RIGHT(1) * WS-FWD(2) - WS-RIGHT(2) * WS-FWD(1)
     COMPUTE WS-PARTIAL = 1 - (CL-NEXT-TICK - CL-NOW-MS) / CL-TICK-MS
     COMPUTE WS-PARTIAL = FUNCTION MAX(0, FUNCTION MIN(1, WS-PARTIAL))
     PERFORM VARYING WS-G FROM 1 BY 1 UNTIL WS-G > WS-N
         IF WS-ORDER(WS-G) = 1
             PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > EN-G-COUNT(1)
                 MOVE EN-G-HANDLE(1, WS-I) TO WS-H
                 MOVE PQ-DATA(WS-H)(1:240) TO PCL
                 COMPUTE WS-T = PQ-TYPE(WS-H) + 1
                 IF PRA-COUNT(WS-T) > 0
                     COMPUTE WS-LAST = PRA-COUNT(WS-T) - 1
                     COMPUTE WS-INDEX = FUNCTION MAX(0, FUNCTION MIN(PC-SPRITE, WS-LAST))
                     COMPUTE WS-SPRITE = PRA-FIRST(WS-T) + WS-INDEX
                     COMPUTE WS-U0 = 0
                     COMPUTE WS-U1 = PRA-S-W(WS-SPRITE) / PRA-W
                     COMPUTE WS-V0 = PRA-S-Y(WS-SPRITE) / PRA-H
                     COMPUTE WS-V1 = (PRA-S-Y(WS-SPRITE) + PRA-S-H(WS-SPRITE)) / PRA-H
                     MOVE PC-QUAD-SIZE TO WS-SIZE
                     IF PQ-CLASS(WS-H) = 7
                         CALL "PASH-QUAD-SIZE" USING PCL WS-PARTIAL WS-SIZE
                     END-IF
                     COMPUTE WS-POS(1) = PC-XO + (PC-X - PC-XO) * WS-PARTIAL - L-EYE(1)
                     COMPUTE WS-POS(2) = PC-YO + (PC-Y - PC-YO) * WS-PARTIAL - L-EYE(2)
                     COMPUTE WS-POS(3) = PC-ZO + (PC-Z - PC-ZO) * WS-PARTIAL - L-EYE(3)
                     PERFORM VARYING WS-C FROM 1 BY 1 UNTIL WS-C > 4
                         MOVE 1 TO WS-SR-VALUE
                         IF WS-SIGN-R(WS-C) = "-"
                             MOVE -1 TO WS-SR-VALUE
                         END-IF
                         MOVE 1 TO WS-SU-VALUE
                         IF WS-SIGN-U(WS-C) = "-"
                             MOVE -1 TO WS-SU-VALUE
                         END-IF
                         COMPUTE WS-CX(WS-C) = WS-POS(1) + (WS-RIGHT(1) * WS-SR-VALUE
                             + WS-UP(1) * WS-SU-VALUE) * WS-SIZE
                         COMPUTE WS-CY(WS-C) = WS-POS(2) + (WS-RIGHT(2) * WS-SR-VALUE
                             + WS-UP(2) * WS-SU-VALUE) * WS-SIZE
                         COMPUTE WS-CZ(WS-C) = WS-POS(3) + (WS-RIGHT(3) * WS-SR-VALUE
                             + WS-UP(3) * WS-SU-VALUE) * WS-SIZE
                         COMPUTE WS-CU(WS-C) = WS-U0 + (WS-U1 - WS-U0) * WS-U-SEL(WS-C)
                         COMPUTE WS-CV(WS-C) = WS-V0 + (WS-V1 - WS-V0) * WS-V-SEL(WS-C)
                     END-PERFORM
                     PERFORM VARYING WS-C FROM 1 BY 1 UNTIL WS-C > 6
                         MOVE WS-O(WS-C) TO WS-S
                         ADD 1 TO RL-PT-COUNT
                         MOVE WS-CX(WS-S) TO RL-PT-X(RL-PT-COUNT)
                         MOVE WS-CY(WS-S) TO RL-PT-Y(RL-PT-COUNT)
                         MOVE WS-CZ(WS-S) TO RL-PT-Z(RL-PT-COUNT)
                         MOVE WS-CU(WS-S) TO RL-PT-U(RL-PT-COUNT)
                         MOVE WS-CV(WS-S) TO RL-PT-V(RL-PT-COUNT)
                         MOVE 1 TO RL-PT-B(RL-PT-COUNT)
                         MOVE PC-ALPHA TO RL-PT-A(RL-PT-COUNT)
                         MOVE 0 TO RL-PT-SKY(RL-PT-COUNT)
                         MOVE PC-RCOL TO RL-PT-R(RL-PT-COUNT)
                         MOVE PC-GCOL TO RL-PT-G(RL-PT-COUNT)
                         MOVE PC-BCOL TO RL-PT-BLUE(RL-PT-COUNT)
                     END-PERFORM
                 END-IF
             END-PERFORM
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM PARTICLES-MESH.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PARTICLE-SPRITE-IMAGE.
*> USING CLIENT-STATE, registry id, sprite number (1 up), image area (RGBA), sprite count out, width out,
*> height out: the n-th sprite of a particle type from the pack stack (42-1 sections 6.1 and 6.2): the
*> definition assets/minecraft/particles/<name>.json names the sprite ids (minecraft:heart is
*> assets/minecraft/textures/particle/heart.png); the top-most pack that has a file wins. A type without a
*> definition, with an empty list or a missing image gets the missing-texture rule (one 16 x 16 sprite).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLPDEF.
 01 WS-NAME                PIC X(32).
 01 WS-OPTIONS             PIC X(16).
 01 WS-OVERRIDE            BINARY-LONG.
 01 WS-PROVIDER            PIC X(56).
 01 WS-SPRITES             BINARY-LONG.
 01 WS-PART                BINARY-LONG.
 01 WS-PATH                PIC X(256).
 01 WS-PATH-LENGTH         BINARY-LONG.
 01 WS-JSON                PIC X(32767).
 01 WS-JSON-CAP            BINARY-LONG VALUE 32767.
 01 WS-JSON-LENGTH         BINARY-LONG.
 01 WS-FOUND               BINARY-LONG.
 01 WS-CAPACITY            BINARY-LONG VALUE 1048576.
 01 WS-NS                  PIC X(64).
 01 WS-REST                PIC X(64).
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-TYPE                 BINARY-LONG.
 01 L-INDEX                BINARY-LONG.
 01 L-IMAGE                PIC X(1048576).
 01 L-COUNT                BINARY-LONG.
 01 L-W                    BINARY-LONG.
 01 L-H                    BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-TYPE L-INDEX L-IMAGE L-COUNT L-W L-H.
     CALL "PART-TYPE" USING L-TYPE WS-NAME WS-OPTIONS WS-OVERRIDE WS-PROVIDER WS-SPRITES WS-PART
     MOVE 0 TO L-COUNT PD-COUNT
     MOVE SPACES TO WS-PATH
     STRING "assets/minecraft/particles/" FUNCTION TRIM(WS-NAME) ".json" DELIMITED BY SIZE
         INTO WS-PATH
     MOVE FUNCTION LENGTH(FUNCTION TRIM(WS-PATH)) TO WS-PATH-LENGTH
     CALL "PACK-READ" USING CLIENT-STATE WS-PATH WS-PATH-LENGTH WS-JSON WS-JSON-CAP WS-JSON-LENGTH
         WS-FOUND
     IF WS-FOUND = 1
         CALL "PDEF-PARSE" USING WS-JSON WS-JSON-LENGTH PDEF
         IF PD-ERROR = 0
             MOVE PD-COUNT TO L-COUNT
         END-IF
     END-IF
     MOVE 0 TO WS-FOUND
     IF L-COUNT > 0
         MOVE SPACES TO WS-NS WS-REST
         UNSTRING PD-TEXTURE(L-INDEX) DELIMITED BY ":" INTO WS-NS WS-REST
         MOVE SPACES TO WS-PATH
         STRING "assets/" FUNCTION TRIM(WS-NS) "/textures/particle/" FUNCTION TRIM(WS-REST) ".png"
             DELIMITED BY SIZE INTO WS-PATH
         MOVE FUNCTION LENGTH(FUNCTION TRIM(WS-PATH)) TO WS-PATH-LENGTH
         CALL "PACK-IMAGE" USING CLIENT-STATE WS-PATH WS-PATH-LENGTH L-IMAGE WS-CAPACITY L-W L-H
             WS-FOUND
     END-IF
     IF L-COUNT = 0
         MOVE 1 TO L-COUNT
     END-IF
     IF WS-FOUND = 0
         MOVE 16 TO L-W L-H
         CALL "MISSING-TEXTURE" USING L-W L-H L-IMAGE
     END-IF
     GOBACK.
 END PROGRAM PARTICLE-SPRITE-IMAGE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PARTICLE-ATLAS-BUILD.
*> USING CLIENT-STATE: fills PRA-* and marks texture 4 for upload: the sprites of every wired type
*> (PARTICLE-CLASS), type by type in registry order and each type's sprites in its definition's order,
*> stacked from the top and left-aligned, the atlas as wide as the widest sprite. Two passes (sizes,
*> then pixels), reading each image from the stack again.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-IMAGE               PIC X(1048576).
 01 WS-PASS                BINARY-LONG.
 01 WS-T                   BINARY-LONG.
 01 WS-CLASS               BINARY-LONG.
 01 WS-KIND                BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-W                   BINARY-LONG.
 01 WS-H                   BINARY-LONG.
 01 WS-SPRITE              BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-R                   BINARY-LONG.
 01 WS-FROM                BINARY-LONG.
 01 WS-TO                  BINARY-LONG.
 01 WS-ROW-BYTES           BINARY-LONG.
 01 WS-BYTES               BINARY-LONG.
 01 B-ATLAS                PIC X(1073741824) BASED.
 LINKAGE SECTION.
 COPY CLSTATE.
 PROCEDURE DIVISION USING CLIENT-STATE.
     MOVE 0 TO PRA-W PRA-H PRA-SPRITES
     PERFORM VARYING WS-T FROM 1 BY 1 UNTIL WS-T > 128
         MOVE 0 TO PRA-FIRST(WS-T) PRA-COUNT(WS-T)
     END-PERFORM
     PERFORM VARYING WS-PASS FROM 1 BY 1 UNTIL WS-PASS > 2
         MOVE 0 TO WS-SPRITE WS-Y
         PERFORM VARYING WS-T FROM 0 BY 1 UNTIL WS-T > 127
             CALL "PARTICLE-CLASS" USING WS-T WS-CLASS WS-KIND
             IF WS-CLASS > 0
                 MOVE 1 TO WS-K
                 MOVE 1 TO WS-COUNT
                 PERFORM UNTIL WS-K > WS-COUNT
                     CALL "PARTICLE-SPRITE-IMAGE" USING CLIENT-STATE WS-T WS-K WS-IMAGE WS-COUNT
                         WS-W WS-H
                     ADD 1 TO WS-SPRITE
                     IF WS-K = 1
                         MOVE WS-SPRITE TO PRA-FIRST(WS-T + 1)
                         MOVE WS-COUNT TO PRA-COUNT(WS-T + 1)
                     END-IF
                     IF WS-PASS = 1
                         MOVE WS-Y TO PRA-S-Y(WS-SPRITE)
                         MOVE WS-W TO PRA-S-W(WS-SPRITE)
                         MOVE WS-H TO PRA-S-H(WS-SPRITE)
                         MOVE FUNCTION MAX(PRA-W, WS-W) TO PRA-W
                     END-IF
                     IF WS-PASS = 2
                         COMPUTE WS-ROW-BYTES = WS-W * 4
                         PERFORM VARYING WS-R FROM 0 BY 1 UNTIL WS-R >= WS-H
                             COMPUTE WS-TO = ((WS-Y + WS-R) * PRA-W) * 4 + 1
                             COMPUTE WS-FROM = WS-R * WS-ROW-BYTES + 1
                             MOVE WS-IMAGE(WS-FROM:WS-ROW-BYTES) TO B-ATLAS(WS-TO:WS-ROW-BYTES)
                         END-PERFORM
                     END-IF
                     ADD WS-H TO WS-Y
                     ADD 1 TO WS-K
                 END-PERFORM
             END-IF
         END-PERFORM
         IF WS-PASS = 1
             MOVE WS-SPRITE TO PRA-SPRITES
             MOVE WS-Y TO PRA-H
             IF PRA-ADDR NOT = NULL
                 FREE PRA-ADDR
             END-IF
             COMPUTE WS-BYTES = PRA-W * PRA-H * 4
             ALLOCATE WS-BYTES CHARACTERS RETURNING PRA-ADDR
             SET ADDRESS OF B-ATLAS TO PRA-ADDR
             MOVE LOW-VALUES TO B-ATLAS(1:WS-BYTES)
         END-IF
     END-PERFORM
     MOVE 1 TO AT-UPLOAD(5)
     GOBACK.
 END PROGRAM PARTICLE-ATLAS-BUILD.
