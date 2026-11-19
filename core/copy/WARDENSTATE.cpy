*> The state of wardens (002-lane-p49b; docs/protocol/20 section 15; core/src/mob-20-15.cob), EXTERNAL.
*> WD-ENTRY: one per warden entity id (WD-ID 0 = free). WD-ANGER: the anger value per player row (the anger manager, capped at 150); WD-SONIC-CD the ticks left of the sonic
*> boom cooldown memory (0 = absent); WD-BOOM the tick of the sonic boom behaviour (0 = not running, 1 at its start, 60 total); WD-DIG-CD the ticks left of the dig cooldown memory.
 78 WD-MAX                VALUE 8.
*> WD-ANGER is indexed by a suspect code (lane p49w): 1 to 64 a player row, 65 to 1088 a non-player entity (64 + its tracker row, so up to the 1024 rows of CORE-ENTITIES).
 78 WD-CODES              VALUE 1088.
 01 WD-STATE EXTERNAL.
    05 WD-ENTRY              OCCURS 8 TIMES.
       10 WD-ID              BINARY-LONG.
       10 WD-SONIC-CD        BINARY-LONG.
       10 WD-BOOM            BINARY-LONG.
       10 WD-DIG-CD          BINARY-LONG.
       10 WD-ANGER           BINARY-LONG OCCURS WD-CODES TIMES.
*> The brain (lane 002-lane-p49r; 20 section 15.4; core/src/mob-20-15b.cob): WD-ACT the active activity (0 not chosen yet; 1 EMERGE, 2 DIG, 3 ROAR, 4 FIGHT, 5 INVESTIGATE, 6 SNIFF, 7 IDLE), the
*> memories with their ticks left (0 = absent): WD-EMERGE is_emerging, WD-DISTURB disturbance_location (its block WD-DX/DY/DZ), WD-SNIFF-CD sniff_cooldown, WD-VIB-CD vibration_cooldown,
*> WD-PROJ-CD recent_projectile; WD-ROAR-TARGET the player row of roar_target (0 absent), WD-SNIFFING is_sniffing (0/1), WD-NEAR the player row of nearest_attackable, WD-SENSOR the ticks to the
*> sensor's next scan (a draw of 0 to 19 at the start), WD-WALK-ON / WD-WALK-X / WD-WALK-Z the walk target of the investigation (a block column), and the running behaviours'
*> counters (0 = not running): WD-ROAR (Roar, 84), WD-SNIFF (Sniffing, 84), WD-DIGGING (Digging, 100). WD-V-* is the vibration in flight: WD-V-DUE the game tick it arrives (0 none), WD-V-SRC
*> the source player row (0 none), WD-V-OWNER the projectile owner's player row (0 none), WD-V-X/Y/Z the position.
       10 WD-ACT              BINARY-LONG.
       10 WD-EMERGE           BINARY-LONG.
       10 WD-DISTURB          BINARY-LONG.
       10 WD-DX               BINARY-LONG.
       10 WD-DY               BINARY-LONG.
       10 WD-DZ               BINARY-LONG.
       10 WD-SNIFF-CD         BINARY-LONG.
       10 WD-VIB-CD           BINARY-LONG.
       10 WD-PROJ-CD          BINARY-LONG.
       10 WD-ROAR-TARGET      BINARY-LONG.
       10 WD-SNIFFING         BINARY-LONG.
       10 WD-NEAR             BINARY-LONG.
       10 WD-SENSOR           BINARY-LONG.
       10 WD-WALK-ON          BINARY-LONG.
       10 WD-WALK-X           BINARY-LONG.
       10 WD-WALK-Z           BINARY-LONG.
       10 WD-ROAR             BINARY-LONG.
       10 WD-SNIFF            BINARY-LONG.
       10 WD-DIGGING          BINARY-LONG.
       10 WD-V-DUE            BINARY-DOUBLE.
       10 WD-V-SRC            BINARY-LONG.
       10 WD-V-OWNER          BINARY-LONG.
       10 WD-V-X              FLOAT-LONG.
       10 WD-V-Y              FLOAT-LONG.
       10 WD-V-Z              FLOAT-LONG.
*> Touch and pose (lane p49w; core/src/mob-20-15c.cob): WD-TOUCH-CD the ticks left of the touch_cooldown memory (0 = absent), WD-POSE the Pose id last sent to the viewers (0 STANDING, 11 ROARING,
*> 12 SNIFFING, 13 EMERGING, 14 DIGGING; 53 section 1).
       10 WD-TOUCH-CD         BINARY-LONG.
       10 WD-POSE             BINARY-LONG.
