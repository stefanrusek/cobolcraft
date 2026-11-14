*> Record of the Spawn Entity packet of proto/src/entity-packets.cob (05a 0x01 Add Entity; the Entity
*> Event packet 0x22 takes plain fields). Angles are degrees as PB-PUT-ANGLE takes them; the wire
*> keeps 8 bits each (00 §4.4), so a decoded angle is a multiple of 360/256 in [-180, 180). The
*> movement is the LpVec3 of 00 §4.6, in blocks per tick.

 01 PB-SPAWN.
    05 PB-SP-ENTITY          BINARY-LONG.   *> network entity id VarInt, not negative
    05 PB-SP-UUID            PIC X(16).     *> the 16 bytes most significant first
    05 PB-SP-TYPE            BINARY-LONG.   *> RegistryId<entity_type>, not negative
    05 PB-SP-X               FLOAT-LONG.
    05 PB-SP-Y               FLOAT-LONG.
    05 PB-SP-Z               FLOAT-LONG.
    05 PB-SP-MOVE-X          FLOAT-LONG.
    05 PB-SP-MOVE-Y          FLOAT-LONG.
    05 PB-SP-MOVE-Z          FLOAT-LONG.
    05 PB-SP-PITCH           FLOAT-SHORT.
    05 PB-SP-YAW             FLOAT-SHORT.
    05 PB-SP-HEAD-YAW        FLOAT-SHORT.
    05 PB-SP-DATA            BINARY-LONG.   *> type-specific VarInt (a block state for falling blocks)
