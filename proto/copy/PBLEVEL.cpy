*> Records of the level packets of proto/src/level-events.cob (package-private: the argument lists of
*> the simple packets are plain fields, only the three composites below are records). Documents:
*> 05a 0x30 Level Particles and Particle, 0x32 Login, 05b CommonPlayerSpawnInfo and Respawn 0x54.
*> Identifier texts keep an explicit byte length next to a 64-byte area.

 78 PB-PT-DATA-MAX          VALUE 64.     *> bytes of the option data of one particle
 78 PB-LG-MAX-DIMENSIONS    VALUE 16.     *> names in the Login dimension list
 78 PB-ID-MAX               VALUE 64.     *> bytes of an identifier text

*> CommonPlayerSpawnInfo. Previous game mode -1 = none (wire VarInt 0), 0 to 3 otherwise (wire +1).
 01 PB-SPAWN-INFO.
    05 PB-SI-DIM-TYPE        BINARY-LONG.   *> RegistryId<dimension_type>
    05 PB-SI-DIM-LENGTH      BINARY-LONG.
    05 PB-SI-DIM             PIC X(64).
    05 PB-SI-SEED            BINARY-DOUBLE. *> hashed seed, signed Long
    05 PB-SI-GAME-MODE       BINARY-LONG.   *> 0 to 3
    05 PB-SI-PREVIOUS-MODE   BINARY-LONG.   *> -1 to 3
    05 PB-SI-DEBUG           BINARY-LONG.   *> 0 or 1
    05 PB-SI-FLAT            BINARY-LONG.   *> 0 or 1
    05 PB-SI-DEATH-PRESENT   BINARY-LONG.   *> 0 or 1
    05 PB-SI-DEATH-LENGTH    BINARY-LONG.
    05 PB-SI-DEATH-DIM       PIC X(64).
    05 PB-SI-DEATH-X         BINARY-LONG.
    05 PB-SI-DEATH-Y         BINARY-LONG.
    05 PB-SI-DEATH-Z         BINARY-LONG.
    05 PB-SI-PORTAL-COOLDOWN BINARY-LONG.
    05 PB-SI-SEA-LEVEL       BINARY-LONG.

*> The Login packet apart from its spawn info (which is the second argument of PB-PUT-LOGIN).
 01 PB-LOGIN.
    05 PB-LG-ENTITY          BINARY-LONG.
    05 PB-LG-HARDCORE        BINARY-LONG.
    05 PB-LG-DIM-COUNT       BINARY-LONG.   *> 0 to PB-LG-MAX-DIMENSIONS
    05 PB-LG-DIMENSION       OCCURS 16 TIMES.
       10 PB-LG-DIM-LENGTH     BINARY-LONG.
       10 PB-LG-DIM-NAME       PIC X(64).
    05 PB-LG-MAX-PLAYERS     BINARY-LONG.
    05 PB-LG-VIEW-DISTANCE   BINARY-LONG.
    05 PB-LG-SIM-DISTANCE    BINARY-LONG.
    05 PB-LG-REDUCED-DEBUG   BINARY-LONG.
    05 PB-LG-DEATH-SCREEN    BINARY-LONG.
    05 PB-LG-LIMITED-CRAFT   BINARY-LONG.
    05 PB-LG-ONLINE-MODE     BINARY-LONG.
    05 PB-LG-SECURE-CHAT     BINARY-LONG.

*> Level Particles: the particle (type and option bytes as PB-PUT-PARTICLE takes them), then the
*> fixed fields in wire order.
 01 PB-LEVEL-PARTICLES.
    05 PB-LP-TYPE            BINARY-LONG.
    05 PB-LP-DATA-LENGTH     BINARY-LONG.
    05 PB-LP-DATA            PIC X(64).
    05 PB-LP-OVERRIDE        BINARY-LONG.   *> 0 or 1
    05 PB-LP-ALWAYS          BINARY-LONG.   *> 0 or 1
    05 PB-LP-X               FLOAT-LONG.
    05 PB-LP-Y               FLOAT-LONG.
    05 PB-LP-Z               FLOAT-LONG.
    05 PB-LP-DIST            FLOAT-SHORT OCCURS 3 TIMES.
    05 PB-LP-SPEED           FLOAT-SHORT OCCURS 3 TIMES.
    05 PB-LP-COUNT           BINARY-LONG.
    05 PB-LP-RANDOMIZATION   BINARY-LONG.   *> 0, 1 or 2 (a decoded value outside is 0)
