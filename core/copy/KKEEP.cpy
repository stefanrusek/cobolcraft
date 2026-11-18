*> Stored player state of lane 002-lane-p49m (docs/protocol/45-entity-nbt-3 sections 2.1, 3 and 6; core/src/player-keep.cob): EXTERNAL, one KK-ROW per CORE-KNOWN row
*> (cleared with the row by KX-ROW-FREE). A separate record so that a new field does not rebuild every core program.
*>   KK-DEATH-*: LastDeathLocation (the dimension key as text and the block position; set when the player dies, never cleared; 45-3 section 6.2).
*>   KK-PREV-*: previousPlayerGameType (the mode before the last change; 3.4). KK-WARD-*: warden_spawn_tracker (6.3). KK-NETHER-*, KK-IMPACT-*: entered_nether_pos and
*>   last_explosion_impact_pos (Vec3). KK-RAID-*: raid_omen_position. KK-RESPAWN-*: respawn (6.1), RootVehicle (3.3), ender_pearls (3.7) and the two shoulder entities (3.6):
*>   the tag payload as the file has it, kept when it fits (an empty list or compound is none).
 78 KK-MAX                VALUE 4096.
 01 CORE-KNOWN-KEEP EXTERNAL.
    05 KK-ROW OCCURS 4096 TIMES.
       10 KK-DEATH-ON        BINARY-LONG.
       10 KK-DEATH-DIM-LEN   BINARY-LONG.
       10 KK-DEATH-DIM       PIC X(48).
       10 KK-DEATH-X         BINARY-LONG.
       10 KK-DEATH-Y         BINARY-LONG.
       10 KK-DEATH-Z         BINARY-LONG.
       10 KK-PREV-ON         BINARY-LONG.
       10 KK-PREV-MODE       BINARY-LONG.
       10 KK-WARD-TICKS      BINARY-LONG.
       10 KK-WARD-LEVEL      BINARY-LONG.
       10 KK-WARD-COOL       BINARY-LONG.
       10 KK-NETHER-ON       BINARY-LONG.
       10 KK-NETHER-X        FLOAT-LONG.
       10 KK-NETHER-Y        FLOAT-LONG.
       10 KK-NETHER-Z        FLOAT-LONG.
       10 KK-IMPACT-ON       BINARY-LONG.
       10 KK-IMPACT-X        FLOAT-LONG.
       10 KK-IMPACT-Y        FLOAT-LONG.
       10 KK-IMPACT-Z        FLOAT-LONG.
       10 KK-RAID-ON         BINARY-LONG.
       10 KK-RAID-X          BINARY-LONG.
       10 KK-RAID-Y          BINARY-LONG.
       10 KK-RAID-Z          BINARY-LONG.
       10 KK-RESPAWN-LEN     BINARY-LONG.
       10 KK-RESPAWN-RAW     PIC X(256).
       10 KK-ROOT-LEN        BINARY-LONG.
       10 KK-ROOT-RAW        PIC X(1024).
       10 KK-PEARL-LEN       BINARY-LONG.
       10 KK-PEARL-RAW       PIC X(1024).
       10 KK-SHL-LEN         BINARY-LONG.
       10 KK-SHL-RAW         PIC X(512).
       10 KK-SHR-LEN         BINARY-LONG.
       10 KK-SHR-RAW         PIC X(512).
