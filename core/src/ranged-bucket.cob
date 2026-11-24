*> Mob buckets (docs/protocol/17 section 3.8, 25 part 5 section 5.5, 29a section 7.4, 45 part 7 sections 8 and 9; lane 002-lane-p46e, T27015).
*> Picking up: Interact (0x1A) with a water_bucket on a living cod, salmon, pufferfish, tropical fish, axolotl or tadpole (MOB-BUCKET-PICKUP, from MOB-INTERACT) puts the mob into the
*> bucket item of its kind and removes it. The stack carries the mob's custom name (custom_name) and the compound bucket_entity_data (component 61, a network NBT compound): Health (Float,
*> always), PersistenceRequired (Byte, only when set), and a tadpole's Age (Int) and AgeLocked (Byte, only when locked). A survival player's water bucket is replaced (one of a stack is taken and the
*> filled bucket added, MOB-SWAP's rule but with the patch), a creative player keeps the water bucket and gets the filled one as well.
*> Releasing: Use Item with a mob bucket empties its water like a water bucket (BUCKET-USE) and spawns the mob in that cell (MOB-BUCKET-RELEASE): Health (clamped to 0 and the mob's own),
*> persistence, Age and the custom name come back, fromBucket (EN-FROM-BUCKET) is set; the bucket becomes an empty one (a creative player keeps it).
*> Not done: the type-specific stack components (salmon size, tropical fish pattern and colours, axolotl variant: the mobs here keep no such state), NoAI, Silent, NoGravity, Glowing and
*> Invulnerable (no mob field), the Axolotl's Age and HuntingCooldown, the sounds and the filled_bucket advancement, the sulfur cube bucket (no such mob), dropping a leash.
*>
*>   BUCKET-MOB-ITEM USING species (PIC X(24)), bucket item key out (PIC X(48), spaces for a mob no bucket holds)
*>   BUCKET-MOB-SPECIES USING bucket item key (PIC X(48)), species out (PIC X(48)), found out
*>   BUCKET-MOB-DATA USING mob row, handle in and out: the bucket stack's patch of the mob
*>   MOB-BUCKET-PICKUP USING player row, mob row, done out
*>   BUCKET-MOB-RELEASE USING player row, species (PIC X(48)), cell x, y, z, held slot (1 based)

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BUCKET-MOB-ITEM.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-KINDS.
    05 FILLER              PIC X(48) VALUE "cod                     cod_bucket              ".
    05 FILLER              PIC X(48) VALUE "salmon                  salmon_bucket           ".
    05 FILLER              PIC X(48) VALUE "pufferfish              pufferfish_bucket       ".
    05 FILLER              PIC X(48) VALUE "tropical_fish           tropical_fish_bucket    ".
    05 FILLER              PIC X(48) VALUE "axolotl                 axolotl_bucket          ".
    05 FILLER              PIC X(48) VALUE "tadpole                 tadpole_bucket          ".
 01 WS-TABLE REDEFINES WS-KINDS.
    05 WS-KIND               OCCURS 6 TIMES.
       10 WS-SPECIES         PIC X(24).
       10 WS-BUCKET          PIC X(24).
 01 WS-I                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-SPECIES              PIC X(24).
 01 L-BUCKET               PIC X(48).
 PROCEDURE DIVISION USING L-SPECIES L-BUCKET.
     MOVE SPACES TO L-BUCKET
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 6
         IF WS-SPECIES(WS-I) = L-SPECIES
             MOVE WS-BUCKET(WS-I) TO L-BUCKET
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM BUCKET-MOB-ITEM.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BUCKET-MOB-SPECIES.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-KINDS.
    05 FILLER              PIC X(48) VALUE "cod                     cod_bucket              ".
    05 FILLER              PIC X(48) VALUE "salmon                  salmon_bucket           ".
    05 FILLER              PIC X(48) VALUE "pufferfish              pufferfish_bucket       ".
    05 FILLER              PIC X(48) VALUE "tropical_fish           tropical_fish_bucket    ".
    05 FILLER              PIC X(48) VALUE "axolotl                 axolotl_bucket          ".
    05 FILLER              PIC X(48) VALUE "tadpole                 tadpole_bucket          ".
 01 WS-TABLE REDEFINES WS-KINDS.
    05 WS-KIND               OCCURS 6 TIMES.
       10 WS-SPECIES         PIC X(24).
       10 WS-BUCKET          PIC X(24).
 01 WS-I                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-BUCKET               PIC X(48).
 01 L-SPECIES              PIC X(48).
 01 L-FOUND                BINARY-LONG.
 PROCEDURE DIVISION USING L-BUCKET L-SPECIES L-FOUND.
     MOVE 0 TO L-FOUND
     MOVE SPACES TO L-SPECIES
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 6
         IF WS-BUCKET(WS-I) = L-BUCKET
             MOVE WS-SPECIES(WS-I) TO L-SPECIES
             MOVE 1 TO L-FOUND
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM BUCKET-MOB-SPECIES.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BUCKET-MOB-DATA.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY PROTO REPLACING LEADING ==PB-== BY ==BK-==.
 01 WS-CAPACITY            BINARY-LONG VALUE 128.
 01 WS-NAME                PIC X(64).
 01 WS-NAME-LENGTH         BINARY-LONG.
 01 WS-KEY                 PIC X(24).
 01 WN                     PIC X(32).
 01 WL                     BINARY-LONG.
 01 WS-ROOT                BINARY-LONG VALUE -2.
 01 WS-HEALTH              FLOAT-SHORT.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-TYPE                BINARY-LONG VALUE 61.
 01 WS-VALUE               PIC X(64).
 01 WS-AREA                PIC X(1073741824) BASED.
 01 WS-LENGTH              BINARY-LONG.
 01 WS-AGE                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-HANDLE               BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-HANDLE.
     MOVE 0 TO L-HANDLE
     IF EN-CNAME-LEN(L-ROW) > 0 AND EN-CNAME-LEN(L-ROW) <= 60
         MOVE EN-CNAME(L-ROW) TO WS-NAME
         MOVE EN-CNAME-LEN(L-ROW) TO WS-NAME-LENGTH
         CALL "SP-SET-NAME" USING L-HANDLE WS-NAME WS-NAME-LENGTH
     END-IF
     CALL "PB-INIT" USING BK-BUFFER WS-CAPACITY
     CALL "NBT-WRITE-COMPOUND-BEGIN" USING BK-BUFFER WN WS-ROOT
     MOVE "Health" TO WN
     MOVE 6 TO WL
     MOVE EN-HEALTH(L-ROW) TO WS-HEALTH
     CALL "NBT-WRITE-FLOAT" USING BK-BUFFER WN WL WS-HEALTH
     IF EN-PERSISTENT(L-ROW) = 1
         MOVE "PersistenceRequired" TO WN
         MOVE 19 TO WL
         CALL "NBT-WRITE-BYTE" USING BK-BUFFER WN WL WS-ONE
     END-IF
     CALL "MOB-SPECIES-KEY" USING L-ROW WS-KEY
     IF WS-KEY = "tadpole"
         MOVE "Age" TO WN
         MOVE 3 TO WL
         MOVE EN-TAD-AGE(L-ROW) TO WS-AGE
         CALL "NBT-WRITE-INT" USING BK-BUFFER WN WL WS-AGE
         IF EN-LOCKED(L-ROW) = 1
             MOVE "AgeLocked" TO WN
             MOVE 9 TO WL
             CALL "NBT-WRITE-BYTE" USING BK-BUFFER WN WL WS-ONE
         END-IF
     END-IF
     CALL "NBT-WRITE-COMPOUND-END" USING BK-BUFFER
     MOVE SPACES TO WS-VALUE
     SET ADDRESS OF WS-AREA TO BK-ADDR
     MOVE BK-LENGTH TO WS-LENGTH
     MOVE WS-AREA(1:WS-LENGTH) TO WS-VALUE(1:WS-LENGTH)
     CALL "PB-FREE" USING BK-BUFFER
     CALL "SP-SET-COMPONENT" USING L-HANDLE WS-TYPE WS-VALUE WS-LENGTH
     GOBACK.
 END PROGRAM BUCKET-MOB-DATA.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MOB-BUCKET-PICKUP.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-SPECIES             PIC X(24).
 01 WS-BUCKET-KEY          PIC X(48).
 01 WS-ITEM-KEY            PIC X(112).
 01 WS-ITEM-ROW            PIC X(270).
 01 WS-STATUS              BINARY-LONG.
 01 WS-ITEM                BINARY-LONG.
 01 WS-HANDLE              BINARY-LONG.
 01 WS-SLOT                BINARY-LONG.
 01 WS-HELD                BINARY-LONG.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-COUNT               BINARY-LONG.
 01 WS-RESULT              BINARY-LONG.
 01 WS-OFFSET              FLOAT-LONG VALUE 0.
 01 WS-DROPPED             BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-MOB                  BINARY-LONG.
 01 L-DONE                 BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-MOB L-DONE.
     MOVE 0 TO L-DONE
*>   MOB-INTERACT calls this for a living mob of the six species only.
     CALL "MOB-SPECIES-KEY" USING L-MOB WS-SPECIES
     CALL "BUCKET-MOB-ITEM" USING WS-SPECIES WS-BUCKET-KEY
     MOVE SPACES TO WS-ITEM-KEY
     STRING "minecraft:" DELIMITED BY SIZE FUNCTION TRIM(WS-BUCKET-KEY) DELIMITED BY SIZE INTO WS-ITEM-KEY
     CALL "CONTENT-ITEM-BY-KEY" USING WS-ITEM-KEY WS-ITEM WS-ITEM-ROW WS-STATUS
     CALL "BUCKET-MOB-DATA" USING L-MOB WS-HANDLE
*>   createFilledResult: a stack of one water bucket becomes the filled bucket, else one is taken and the filled bucket added (what does not fit lands on the ground);
*>   a creative player keeps the water bucket and has the filled bucket added.
     MOVE PL-HELD(L-ROW) TO WS-HELD
     COMPUTE WS-SLOT = WS-HELD + 1
     IF PL-MODE(L-ROW) NOT = 1 AND PL-SLOT-COUNT(L-ROW, WS-SLOT) = 1
         MOVE WS-ITEM TO PL-SLOT-ITEM(L-ROW, WS-SLOT)
         MOVE WS-HANDLE TO PL-SLOT-VAR(L-ROW, WS-SLOT)
         CALL "INV-SLOT-SEND" USING PL-CONN(L-ROW) WS-HELD
     ELSE
         IF PL-MODE(L-ROW) NOT = 1
             CALL "MOB-TAKE" USING L-ROW
         END-IF
         MOVE 1 TO WS-COUNT
         CALL "IP-INV-ADD" USING L-ROW WS-ITEM WS-COUNT WS-HANDLE WS-RESULT
         PERFORM VARYING WS-SLOT FROM 0 BY 1 UNTIL WS-SLOT > 35
             CALL "INV-SLOT-SEND" USING PL-CONN(L-ROW) WS-SLOT
         END-PERFORM
         IF WS-RESULT = 0
             MOVE 1 TO WS-COUNT
             CALL "IP-AT-LOCATION" USING PL-DIM(L-ROW) PL-X(L-ROW) PL-Y(L-ROW) PL-Z(L-ROW) WS-OFFSET WS-ITEM WS-COUNT
                 WS-HANDLE WS-DROPPED
         END-IF
     END-IF
     CALL "ENTITY-REMOVE" USING L-MOB
     MOVE 1 TO L-DONE
     GOBACK.
 END PROGRAM MOB-BUCKET-PICKUP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BUCKET-MOB-RELEASE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY PROTO REPLACING LEADING ==PB-== BY ==BR-==.
 01 WS-KEY                 PIC X(112).
 01 WS-ROW                 PIC X(66).
 01 WS-STATUS              BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 01 WS-MOB                 BINARY-LONG.
 01 WS-DATA-TYPE           BINARY-LONG VALUE 61.
 01 WS-VALUE               PIC X(64).
 01 WS-LENGTH              BINARY-LONG.
 01 WS-FOUND               BINARY-LONG.
 01 WS-NAME                PIC X(64).
 01 WS-NAME-LENGTH         BINARY-LONG.
 01 WS-CAPACITY            BINARY-LONG VALUE 128.
 01 WS-AREA                PIC X(1073741824) BASED.
 01 WS-ROOT                BINARY-LONG VALUE 0.
 01 WS-TAG                 BINARY-LONG.
 01 WN                     PIC X(32).
 01 WL                     BINARY-LONG.
 01 WS-CAP                 BINARY-LONG VALUE 32.
 01 WS-HEALTH              FLOAT-SHORT.
 01 WS-INT                 BINARY-LONG.
 01 WS-BYTE                BINARY-LONG.
 01 WS-SPECIES-KEY         PIC X(24).
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-SPECIES              PIC X(48).
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-SLOT                 BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-SPECIES L-X L-Y L-Z L-SLOT.
     MOVE SPACES TO WS-KEY
     STRING "minecraft:" DELIMITED BY SIZE FUNCTION TRIM(L-SPECIES) DELIMITED BY SIZE INTO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE WS-ROW WS-STATUS
     COMPUTE WS-X = L-X + 0.5
     MOVE L-Y TO WS-Y
     COMPUTE WS-Z = L-Z + 0.5
     CALL "MOB-SPAWN" USING PL-DIM(L-ROW) WS-TYPE WS-X WS-Y WS-Z WS-YAW WS-MOB
     MOVE 1 TO EN-FROM-BUCKET(WS-MOB)
     IF FUNCTION TRIM(L-SPECIES) = "axolotl"
         CALL "AXOLOTL-DATA-SEND" USING WS-MOB
     END-IF
     CALL "SP-GET-NAME" USING PL-SLOT-VAR(L-ROW, L-SLOT) WS-NAME WS-NAME-LENGTH
     IF WS-NAME-LENGTH > 0
         MOVE SPACES TO EN-CNAME(WS-MOB)
         MOVE WS-NAME(1:WS-NAME-LENGTH) TO EN-CNAME(WS-MOB)(1:WS-NAME-LENGTH)
         MOVE WS-NAME-LENGTH TO EN-CNAME-LEN(WS-MOB)
         CALL "NAME-DATA-SEND" USING WS-MOB
     END-IF
*>   bucket_entity_data: Health clamped to 0 and the mob's own, PersistenceRequired only when true, a tadpole's Age and AgeLocked.
     CALL "SP-GET-COMPONENT" USING PL-SLOT-VAR(L-ROW, L-SLOT) WS-DATA-TYPE WS-VALUE WS-LENGTH WS-FOUND
     IF WS-FOUND = 1
         CALL "PB-INIT" USING BR-BUFFER WS-CAPACITY
         CALL "PB-APPEND-BYTES" USING BR-BUFFER WS-VALUE WS-LENGTH
         CALL "NBT-READ-ROOT" USING BR-BUFFER WS-ROOT WS-TAG
         MOVE SPACES TO WN
         CALL "NBT-READ-COMPOUND-NEXT" USING BR-BUFFER WS-TAG WN WS-CAP WL
         PERFORM UNTIL WS-TAG = 0
             EVALUATE TRUE
                 WHEN WN = "Health" AND WS-TAG = 5
                     CALL "PB-GET-FLOAT" USING BR-BUFFER WS-HEALTH
                     COMPUTE EN-HEALTH(WS-MOB) = FUNCTION MAX(0, FUNCTION MIN(EN-HEALTH(WS-MOB), WS-HEALTH))
                 WHEN WN = "PersistenceRequired" AND WS-TAG = 1
                     CALL "PB-GET-BYTE" USING BR-BUFFER WS-BYTE
                     IF WS-BYTE = 1
                         MOVE 1 TO EN-PERSISTENT(WS-MOB)
                     END-IF
                 WHEN WN = "Age" AND WS-TAG = 3
                     CALL "PB-GET-INT" USING BR-BUFFER WS-INT
                     MOVE WS-INT TO EN-TAD-AGE(WS-MOB)
                 WHEN WN = "AgeLocked" AND WS-TAG = 1
                     CALL "PB-GET-BYTE" USING BR-BUFFER WS-BYTE
                     MOVE WS-BYTE TO EN-LOCKED(WS-MOB)
                 WHEN OTHER
                     CALL "NBT-READ-SKIP" USING BR-BUFFER WS-TAG
             END-EVALUATE
             MOVE SPACES TO WN
             CALL "NBT-READ-COMPOUND-NEXT" USING BR-BUFFER WS-TAG WN WS-CAP WL
         END-PERFORM
         CALL "PB-FREE" USING BR-BUFFER
     END-IF
*>   A survival player's bucket becomes an empty one: the patch goes with the water.
     IF PL-MODE(L-ROW) NOT = 1
         MOVE 0 TO PL-SLOT-VAR(L-ROW, L-SLOT)
     END-IF
     GOBACK.
 END PROGRAM BUCKET-MOB-RELEASE.
