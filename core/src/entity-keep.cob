*> Entity NBT state of lane 002-lane-p49m (docs/protocol/45-entity-nbt-1 section 5 and 45-2 sections 2 and 3): the keys whose state is in ENKEEP.cpy
*> (fields in ENKFIELDS.cpy), read into KD-DATA by ENTITY-KEEP-KEY while ENTITY-NBT-ONE reads a compound, applied by ENTITY-KEEP-APPLY, written back by
*> ENTITY-KEEP-WRITE (the Entity base: CustomName, Tags, data) and by the LivingEntity and Mob writers of entity-nbt-2.cob and MOBKEEP-NBT-WRITE.
*>   ENTITY-KEEP-SLICE USING PB-BUFFER, tag type, capacity, length out, bytes out   the payload of the tag at PB-POS (skipped) when it fits capacity
*>   ENTITY-TAGS-READ USING PB-BUFFER, count out, length out, bytes out             a Tags list as a set of the strings that fit 1024 bytes
*>   ENTITY-KEEP-APPEND USING PB-BUFFER, start, size, capacity, length in/out, bytes out   appends the bytes of the buffer at start when they fit
*>   ENTITY-FX-READ USING PB-BUFFER, KD-DATA                                        the amplifier and flags of the effects of an active_effects list
*>   ENTITY-KEEP-KEY USING PB-BUFFER, tag type, name, KD-DATA, handled              reads one key into KD-DATA (handled 1; 0 for active_effects, which the
*>                                                                                  LivingEntity reader reads again for the durations, and for other keys)
*>   ENTITY-KEEP-APPLY USING row, KD-GROUP                                          puts the state into the row
*>   ENTITY-KEEP-WRITE USING row, PB-BUFFER, which                                  which 1: CustomName (after UUID); 2: Tags then data (after HasVisualFire)
*> The text component of CustomName and the custom data are kept as the tag the file had (no state of the game reads them); the Team of a saved entity
*> names a scoreboard team and the core has no scoreboard, so the doc's "the team is missing" outcome applies: it is dropped. A data given as an SNBT
*> String (45-1 section 5) is not parsed and not kept. Tags: a list longer than 1024 leaves the set empty (45-1 section 5), duplicates collapse.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ENTITY-FX-READ.
*> The effects of an active_effects list at its payload (45-2 section 2.3): of an effect the core holds (speed, strength, regeneration, invisibility,
*> fire_resistance, water_breathing: slots 1 to 6) the amplifier (an unsigned byte), ambient, show_particles (default true), show_icon (default: the
*> value of show_particles) and the hidden_effect compound; of any other effect the whole element, kept as a compound payload. The list is left read.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WN                     PIC X(32).
 01 WL                     BINARY-LONG.
 01 WS-CAPACITY            BINARY-LONG VALUE 32.
 01 WS-HID-CAPACITY        BINARY-LONG VALUE 160.
 01 WS-OTHER-CAPACITY      BINARY-LONG VALUE 1024.
 01 WS-TYPE                BINARY-LONG.
 01 WS-ELEMENT-TYPE        BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-START               BINARY-LONG.
 01 WS-SIZE                BINARY-LONG.
 01 WS-ID                  PIC X(48).
 01 WS-ID-CAPACITY         BINARY-LONG VALUE 48.
 01 WS-ID-LENGTH           BINARY-LONG.
 01 WS-SLOT                BINARY-LONG.
 01 WS-AMP                 BINARY-LONG.
 01 WS-AMBIENT             BINARY-LONG.
 01 WS-PARTICLES           BINARY-LONG.
 01 WS-ICON                BINARY-LONG.
 01 WS-HID                 PIC X(160).
 01 WS-HID-LENGTH          BINARY-LONG.
 01 WS-BEFORE              BINARY-LONG.
 LINKAGE SECTION.
 COPY PROTO.
 COPY ENKSTAGE.
 PROCEDURE DIVISION USING PB-BUFFER KD-DATA.
     CALL "NBT-READ-LIST-BEGIN" USING PB-BUFFER WS-ELEMENT-TYPE WS-COUNT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-COUNT OR PB-ERROR = 1 OR WS-ELEMENT-TYPE NOT = 10
         MOVE PB-POS TO WS-START
         MOVE SPACES TO WS-ID
         MOVE 0 TO WS-AMP WS-AMBIENT WS-HID-LENGTH
         MOVE 1 TO WS-PARTICLES
         MOVE -1 TO WS-ICON
         PERFORM UNTIL PB-ERROR = 1
             MOVE SPACES TO WN
             CALL "NBT-READ-COMPOUND-NEXT" USING PB-BUFFER WS-TYPE WN WS-CAPACITY WL
             IF WS-TYPE = 0
                 EXIT PERFORM
             END-IF
             EVALUATE TRUE
                 WHEN WN = "id" AND WS-TYPE = 8
                     CALL "NBT-READ-STRING" USING PB-BUFFER WS-ID WS-ID-CAPACITY WS-ID-LENGTH
                 WHEN WN = "amplifier" AND WS-TYPE = 1
                     CALL "PB-GET-BYTE" USING PB-BUFFER WS-AMP
                     COMPUTE WS-AMP = FUNCTION MOD(WS-AMP + 256, 256)
                 WHEN WN = "amplifier" AND WS-TYPE = 3
                     CALL "PB-GET-INT" USING PB-BUFFER WS-AMP
                     COMPUTE WS-AMP = FUNCTION MOD(WS-AMP, 256)
                 WHEN WN = "ambient" AND WS-TYPE = 1
                     CALL "PB-GET-BYTE" USING PB-BUFFER WS-AMBIENT
                 WHEN WN = "show_particles" AND WS-TYPE = 1
                     CALL "PB-GET-BYTE" USING PB-BUFFER WS-PARTICLES
                 WHEN WN = "show_icon" AND WS-TYPE = 1
                     CALL "PB-GET-BYTE" USING PB-BUFFER WS-ICON
                 WHEN WN = "hidden_effect" AND WS-TYPE = 10
                     CALL "ENTITY-KEEP-SLICE" USING PB-BUFFER WS-TYPE WS-HID-CAPACITY WS-HID-LENGTH WS-HID
                 WHEN OTHER
                     CALL "NBT-READ-SKIP" USING PB-BUFFER WS-TYPE
             END-EVALUATE
         END-PERFORM
         COMPUTE WS-SIZE = PB-POS - WS-START
         MOVE 0 TO WS-SLOT
         EVALUATE WS-ID
             WHEN "minecraft:speed" MOVE 1 TO WS-SLOT
             WHEN "minecraft:strength" MOVE 2 TO WS-SLOT
             WHEN "minecraft:regeneration" MOVE 3 TO WS-SLOT
             WHEN "minecraft:invisibility" MOVE 4 TO WS-SLOT
             WHEN "minecraft:fire_resistance" MOVE 5 TO WS-SLOT
             WHEN "minecraft:water_breathing" MOVE 6 TO WS-SLOT
         END-EVALUATE
         IF WS-SLOT = 0
             MOVE KD-FXO-LEN TO WS-BEFORE
             CALL "ENTITY-KEEP-APPEND" USING PB-BUFFER WS-START WS-SIZE WS-OTHER-CAPACITY KD-FXO-LEN KD-FXO-RAW
             IF KD-FXO-LEN > WS-BEFORE
                 ADD 1 TO KD-FXO-COUNT
             END-IF
         ELSE
             MOVE WS-AMP TO KD-FX-AMP(WS-SLOT)
             MOVE WS-AMBIENT TO KD-FX-AMBIENT(WS-SLOT)
             MOVE 0 TO KD-FX-NOPART(WS-SLOT) KD-FX-NOICON(WS-SLOT)
             IF WS-PARTICLES = 0
                 MOVE 1 TO KD-FX-NOPART(WS-SLOT)
             END-IF
             IF WS-ICON = 0 OR (WS-ICON < 0 AND WS-PARTICLES = 0)
                 MOVE 1 TO KD-FX-NOICON(WS-SLOT)
             END-IF
             MOVE WS-HID-LENGTH TO KD-FX-HID-LEN(WS-SLOT)
             MOVE WS-HID TO KD-FX-HID-RAW(WS-SLOT)
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM ENTITY-FX-READ.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ENTITY-DROPS-READ.
*> A drop_chances compound at its payload (45-2 section 3.1): slot name to Float; a negative value is a decode error (no map: every slot at the default).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WN                     PIC X(32).
 01 WL                     BINARY-LONG.
 01 WS-CAPACITY            BINARY-LONG VALUE 32.
 01 WS-TYPE                BINARY-LONG.
 01 WS-SLOT                BINARY-LONG.
 01 WS-VALUE               FLOAT-SHORT.
 01 WS-BAD                 BINARY-LONG.
 LINKAGE SECTION.
 COPY PROTO.
 COPY ENKSTAGE.
 PROCEDURE DIVISION USING PB-BUFFER KD-DATA.
     MOVE 0 TO WS-BAD
     PERFORM UNTIL PB-ERROR = 1
         MOVE SPACES TO WN
         CALL "NBT-READ-COMPOUND-NEXT" USING PB-BUFFER WS-TYPE WN WS-CAPACITY WL
         IF WS-TYPE = 0
             EXIT PERFORM
         END-IF
         MOVE 0 TO WS-SLOT
         EVALUATE WN
             WHEN "mainhand" MOVE 1 TO WS-SLOT
             WHEN "offhand" MOVE 2 TO WS-SLOT
             WHEN "feet" MOVE 3 TO WS-SLOT
             WHEN "legs" MOVE 4 TO WS-SLOT
             WHEN "chest" MOVE 5 TO WS-SLOT
             WHEN "head" MOVE 6 TO WS-SLOT
             WHEN "body" MOVE 7 TO WS-SLOT
             WHEN "saddle" MOVE 8 TO WS-SLOT
         END-EVALUATE
         IF WS-SLOT > 0 AND WS-TYPE = 5
             CALL "PB-GET-FLOAT" USING PB-BUFFER WS-VALUE
             IF WS-VALUE < 0
                 MOVE 1 TO WS-BAD
             ELSE
                 MOVE 1 TO KD-DROP-SET(WS-SLOT)
                 MOVE WS-VALUE TO KD-DROP(WS-SLOT)
             END-IF
         ELSE
             CALL "NBT-READ-SKIP" USING PB-BUFFER WS-TYPE
         END-IF
     END-PERFORM
     IF WS-BAD = 1
         PERFORM VARYING WS-SLOT FROM 1 BY 1 UNTIL WS-SLOT > 8
             MOVE 0 TO KD-DROP-SET(WS-SLOT)
         END-PERFORM
     END-IF
     GOBACK.
 END PROGRAM ENTITY-DROPS-READ.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ENTITY-KEEP-KEY.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-NAME-CAPACITY       BINARY-LONG VALUE 256.
 01 WS-DATA-CAPACITY       BINARY-LONG VALUE 1024.
 01 WS-BRAIN-CAPACITY      BINARY-LONG VALUE 1024.
 01 WS-LOCATOR-CAPACITY    BINARY-LONG VALUE 128.
 01 WS-ELEMENT-TYPE        BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-HOLD                BINARY-LONG.
 01 WS-INT-CAPACITY        BINARY-LONG VALUE 4.
 01 WS-INT-COUNT           BINARY-LONG.
 01 WS-INTS.
    05 WS-INT              BINARY-LONG OCCURS 4 TIMES.
 01 WS-TO-UUID             BINARY-LONG VALUE 1.
 01 WS-LOOT-CAPACITY       BINARY-LONG VALUE 64.
 01 WS-DEFAULT-ICON.
    05 FILLER              PIC X(11) VALUE "minecraft:d".
 01 WS-HITS                BINARY-LONG.
 LINKAGE SECTION.
 COPY PROTO.
 01 L-TYPE                 BINARY-LONG.
 01 L-NAME                 PIC X(64).
 COPY ENKSTAGE.
 01 L-HANDLED              BINARY-LONG.
 PROCEDURE DIVISION USING PB-BUFFER L-TYPE L-NAME KD-DATA L-HANDLED.
     MOVE 1 TO L-HANDLED
     EVALUATE TRUE
         WHEN L-NAME = "CustomName" AND (L-TYPE = 8 OR L-TYPE = 9 OR L-TYPE = 10)
             MOVE L-TYPE TO KD-NAME-TYPE
             CALL "ENTITY-KEEP-SLICE" USING PB-BUFFER L-TYPE WS-NAME-CAPACITY KD-NAME-LEN KD-NAME-RAW
         WHEN L-NAME = "Tags" AND L-TYPE = 9
             CALL "ENTITY-TAGS-READ" USING PB-BUFFER KD-TAG-COUNT KD-TAG-LEN KD-TAG-RAW
         WHEN L-NAME = "data" AND L-TYPE = 10
             CALL "ENTITY-KEEP-SLICE" USING PB-BUFFER L-TYPE WS-DATA-CAPACITY KD-DATA-LEN KD-DATA-RAW
             IF KD-DATA-LEN = 1
                 MOVE 0 TO KD-DATA-LEN
             END-IF
         WHEN L-NAME = "Team"
             CALL "NBT-READ-SKIP" USING PB-BUFFER L-TYPE
         WHEN L-NAME = "attributes" AND L-TYPE = 9
             CALL "ENTITY-KEEP-SLICE" USING PB-BUFFER L-TYPE WS-DATA-CAPACITY KD-ATTR-LEN KD-ATTR-RAW
             IF KD-ATTR-LEN = 5
                 MOVE 0 TO KD-ATTR-LEN
             END-IF
         WHEN L-NAME = "active_effects" AND L-TYPE = 9
             MOVE PB-POS TO WS-HOLD
             CALL "ENTITY-FX-READ" USING PB-BUFFER KD-DATA
             MOVE WS-HOLD TO PB-POS
             MOVE 0 TO PB-ERROR L-HANDLED
         WHEN L-NAME = "current_impulse_context_reset_grace_time" AND L-TYPE = 3
             CALL "PB-GET-INT" USING PB-BUFFER KD-GRACE
         WHEN L-NAME = "current_explosion_impact_pos" AND L-TYPE = 9
             CALL "NBT-READ-LIST-BEGIN" USING PB-BUFFER WS-ELEMENT-TYPE WS-COUNT
             IF WS-ELEMENT-TYPE = 6 AND WS-COUNT = 3
                 CALL "PB-GET-DOUBLE" USING PB-BUFFER KD-IMPACT-X
                 CALL "PB-GET-DOUBLE" USING PB-BUFFER KD-IMPACT-Y
                 CALL "PB-GET-DOUBLE" USING PB-BUFFER KD-IMPACT-Z
                 MOVE 1 TO KD-IMPACT-ON
             ELSE
                 PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-COUNT OR PB-ERROR = 1
                     CALL "NBT-READ-SKIP" USING PB-BUFFER WS-ELEMENT-TYPE
                 END-PERFORM
             END-IF
         WHEN L-NAME = "AbsorptionAmount" AND L-TYPE = 5
             CALL "PB-GET-FLOAT" USING PB-BUFFER KD-ABSORB
         WHEN L-NAME = "FallFlying" AND L-TYPE = 1
             CALL "PB-GET-BYTE" USING PB-BUFFER KD-FALLFLY
             IF KD-FALLFLY NOT = 0
                 MOVE 1 TO KD-FALLFLY
             END-IF
         WHEN L-NAME = "sleeping_pos" AND L-TYPE = 11
             CALL "NBT-READ-INT-ARRAY" USING PB-BUFFER WS-INT-CAPACITY WS-INT-COUNT WS-INTS
             IF WS-INT-COUNT = 3
                 MOVE 1 TO KD-SLEEP-ON
                 MOVE WS-INT(1) TO KD-SLEEP-X
                 MOVE WS-INT(2) TO KD-SLEEP-Y
                 MOVE WS-INT(3) TO KD-SLEEP-Z
             END-IF
         WHEN L-NAME = "Brain" AND L-TYPE = 10
             CALL "ENTITY-KEEP-SLICE" USING PB-BUFFER L-TYPE WS-BRAIN-CAPACITY KD-BRAIN-LEN KD-BRAIN-RAW
         WHEN L-NAME = "last_hurt_by_mob" AND L-TYPE = 11
             CALL "NBT-READ-INT-ARRAY" USING PB-BUFFER WS-INT-CAPACITY WS-INT-COUNT WS-INTS
             IF WS-INT-COUNT = 4
                 CALL "PERSIST-UUID-INTS" USING WS-TO-UUID KD-HURTMOB WS-INTS
             END-IF
         WHEN L-NAME = "ticks_since_last_hurt_by_mob" AND L-TYPE = 3
             CALL "PB-GET-INT" USING PB-BUFFER KD-HURTMOB-TICKS
         WHEN L-NAME = "locator_bar_icon" AND L-TYPE = 10
             CALL "ENTITY-KEEP-SLICE" USING PB-BUFFER L-TYPE WS-LOCATOR-CAPACITY KD-LOCATOR-LEN KD-LOCATOR-RAW
*>           The default icon ({style: "minecraft:default"}, 28 bytes) is no data (written only when it differs).
             MOVE 0 TO WS-HITS
             IF KD-LOCATOR-LEN = 28
                 INSPECT KD-LOCATOR-RAW(1:28) TALLYING WS-HITS FOR ALL "minecraft:default"
             END-IF
             IF WS-HITS > 0
                 MOVE 0 TO KD-LOCATOR-LEN
             END-IF
         WHEN L-NAME = "drop_chances" AND L-TYPE = 10
             CALL "ENTITY-DROPS-READ" USING PB-BUFFER KD-DATA
         WHEN L-NAME = "home_radius" AND L-TYPE = 3
             CALL "PB-GET-INT" USING PB-BUFFER KD-HOME-RADIUS
             MOVE 0 TO KD-HOME-ON
             IF KD-HOME-RADIUS NOT = -1
                 MOVE 1 TO KD-HOME-ON
             END-IF
         WHEN L-NAME = "home_pos" AND L-TYPE = 11
*>           The turtle's own home_pos (45-4 section 9.4) has this name too: the species reader reads it again.
             MOVE PB-POS TO WS-HOLD
             CALL "NBT-READ-INT-ARRAY" USING PB-BUFFER WS-INT-CAPACITY WS-INT-COUNT WS-INTS
             IF WS-INT-COUNT = 3
                 MOVE WS-INT(1) TO KD-HOME-X
                 MOVE WS-INT(2) TO KD-HOME-Y
                 MOVE WS-INT(3) TO KD-HOME-Z
             END-IF
             MOVE WS-HOLD TO PB-POS
             MOVE 0 TO PB-ERROR L-HANDLED
         WHEN L-NAME = "DeathLootTable" AND L-TYPE = 8
             MOVE SPACES TO KD-LOOT
             CALL "NBT-READ-STRING" USING PB-BUFFER KD-LOOT WS-LOOT-CAPACITY KD-LOOT-LEN
         WHEN L-NAME = "DeathLootTableSeed" AND L-TYPE = 4
             CALL "PB-GET-LONG" USING PB-BUFFER KD-LOOT-SEED
         WHEN L-NAME = "LoveCause" AND L-TYPE = 11
             CALL "NBT-READ-INT-ARRAY" USING PB-BUFFER WS-INT-CAPACITY WS-INT-COUNT WS-INTS
             IF WS-INT-COUNT = 4
                 CALL "PERSIST-UUID-INTS" USING WS-TO-UUID KD-LOVE-UUID WS-INTS
             END-IF
         WHEN OTHER
             MOVE 0 TO L-HANDLED
     END-EVALUATE
     GOBACK.
 END PROGRAM ENTITY-KEEP-KEY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ENTITY-KEEP-APPLY.
*> USING row, KD-GROUP: the state read goes to the row; the feeder of LoveCause is the player of that UUID in the mob's dimension (EN-LOVE-CAUSE).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY ENKEEP.
 01 WS-P                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 COPY ENKSTAGE.
 PROCEDURE DIVISION USING L-ROW KD-DATA.
     MOVE KD-GROUP TO EK-ENTRY(L-ROW)
     IF KD-LOVE-UUID NOT = SPACES
         PERFORM VARYING WS-P FROM 1 BY 1 UNTIL WS-P > CORE-MAX-PLAYERS
             IF PL-USED(WS-P) = 1 AND PL-DIM(WS-P) = EN-DIM(L-ROW) AND PL-UUID(WS-P) = KD-LOVE-UUID
                 MOVE WS-P TO EN-LOVE-CAUSE(L-ROW)
             END-IF
         END-PERFORM
     END-IF
     GOBACK.
 END PROGRAM ENTITY-KEEP-APPLY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ENTITY-KEEP-WRITE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY ENKEEP.
 01 WN                     PIC X(32).
 01 WL                     BINARY-LONG.
 01 WS-T-STRING            BINARY-LONG VALUE 8.
 01 WS-T-COMPOUND          BINARY-LONG VALUE 10.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 COPY PROTO.
 01 L-WHICH                BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW PB-BUFFER L-WHICH.
     IF L-WHICH = 1
         IF EK-NAME-LEN(L-ROW) > 0
             MOVE "CustomName" TO WN MOVE 10 TO WL
             CALL "NBT-WRITE-HEADER" USING PB-BUFFER EK-NAME-TYPE(L-ROW) WN WL
             CALL "PB-APPEND-BYTES" USING PB-BUFFER EK-NAME-RAW(L-ROW) EK-NAME-LEN(L-ROW)
         END-IF
     ELSE
         IF EK-TAG-COUNT(L-ROW) > 0
             MOVE "Tags" TO WN MOVE 4 TO WL
             CALL "NBT-WRITE-LIST-BEGIN" USING PB-BUFFER WN WL WS-T-STRING EK-TAG-COUNT(L-ROW)
             CALL "PB-APPEND-BYTES" USING PB-BUFFER EK-TAG-RAW(L-ROW) EK-TAG-LEN(L-ROW)
         END-IF
         IF EK-DATA-LEN(L-ROW) > 0
             MOVE "data" TO WN MOVE 4 TO WL
             CALL "NBT-WRITE-HEADER" USING PB-BUFFER WS-T-COMPOUND WN WL
             CALL "PB-APPEND-BYTES" USING PB-BUFFER EK-DATA-RAW(L-ROW) EK-DATA-LEN(L-ROW)
         END-IF
     END-IF
     GOBACK.
 END PROGRAM ENTITY-KEEP-WRITE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MOBKEEP-NBT-WRITE.
*> USING row, PB-BUFFER: the Mob keys of 45-2 section 3 that have state, in the table order after the LivingEntity keys: drop_chances (only when a slot
*> differs from 0.085), home_radius and home_pos (only with a home), DeathLootTable and DeathLootTableSeed (only when set; the seed when not 0); then the
*> Animal key LoveCause (only when the feeder is known: the player in the world, else the UUID kept from the file).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY ENKEEP.
 01 WN                     PIC X(32).
 01 WL                     BINARY-LONG.
 01 WS-SLOT                BINARY-LONG.
 01 WS-ANY                 BINARY-LONG.
 01 WS-VALUE               FLOAT-SHORT.
 01 WS-DEFAULT             FLOAT-SHORT VALUE 0.085.
 01 WS-DIRECTION           BINARY-LONG VALUE 0.
 01 WS-FOUR                BINARY-LONG VALUE 4.
 01 WS-THREE               BINARY-LONG VALUE 3.
 01 WS-INTS.
    05 WS-INT              BINARY-LONG OCCURS 4 TIMES.
 01 WS-UUID                PIC X(16).
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 COPY PROTO.
 PROCEDURE DIVISION USING L-ROW PB-BUFFER.
     MOVE 0 TO WS-ANY
     PERFORM VARYING WS-SLOT FROM 1 BY 1 UNTIL WS-SLOT > 8
         IF EK-DROP-SET(L-ROW, WS-SLOT) = 1 AND EK-DROP(L-ROW, WS-SLOT) NOT = WS-DEFAULT
             MOVE 1 TO WS-ANY
         END-IF
     END-PERFORM
     IF WS-ANY = 1
         MOVE "drop_chances" TO WN MOVE 12 TO WL
         CALL "NBT-WRITE-COMPOUND-BEGIN" USING PB-BUFFER WN WL
         PERFORM VARYING WS-SLOT FROM 1 BY 1 UNTIL WS-SLOT > 8
             IF EK-DROP-SET(L-ROW, WS-SLOT) = 1 AND EK-DROP(L-ROW, WS-SLOT) NOT = WS-DEFAULT
                 EVALUATE WS-SLOT
                     WHEN 1 MOVE "mainhand" TO WN MOVE 8 TO WL
                     WHEN 2 MOVE "offhand" TO WN MOVE 7 TO WL
                     WHEN 3 MOVE "feet" TO WN MOVE 4 TO WL
                     WHEN 4 MOVE "legs" TO WN MOVE 4 TO WL
                     WHEN 5 MOVE "chest" TO WN MOVE 5 TO WL
                     WHEN 6 MOVE "head" TO WN MOVE 4 TO WL
                     WHEN 7 MOVE "body" TO WN MOVE 4 TO WL
                     WHEN OTHER MOVE "saddle" TO WN MOVE 6 TO WL
                 END-EVALUATE
                 MOVE EK-DROP(L-ROW, WS-SLOT) TO WS-VALUE
                 CALL "NBT-WRITE-FLOAT" USING PB-BUFFER WN WL WS-VALUE
             END-IF
         END-PERFORM
         CALL "NBT-WRITE-COMPOUND-END" USING PB-BUFFER
     END-IF
     IF EK-HOME-ON(L-ROW) = 1
         MOVE "home_radius" TO WN MOVE 11 TO WL
         CALL "NBT-WRITE-INT" USING PB-BUFFER WN WL EK-HOME-RADIUS(L-ROW)
         MOVE "home_pos" TO WN MOVE 8 TO WL
         MOVE EK-HOME-X(L-ROW) TO WS-INT(1)
         MOVE EK-HOME-Y(L-ROW) TO WS-INT(2)
         MOVE EK-HOME-Z(L-ROW) TO WS-INT(3)
         CALL "NBT-WRITE-INT-ARRAY" USING PB-BUFFER WN WL WS-THREE WS-INTS
     END-IF
     IF EK-LOOT-LEN(L-ROW) > 0
         MOVE "DeathLootTable" TO WN MOVE 14 TO WL
         CALL "NBT-WRITE-STRING" USING PB-BUFFER WN WL EK-LOOT(L-ROW) EK-LOOT-LEN(L-ROW)
         IF EK-LOOT-SEED(L-ROW) NOT = 0
             MOVE "DeathLootTableSeed" TO WN MOVE 18 TO WL
             CALL "NBT-WRITE-LONG" USING PB-BUFFER WN WL EK-LOOT-SEED(L-ROW)
         END-IF
     END-IF
     MOVE EK-LOVE-UUID(L-ROW) TO WS-UUID
     IF EN-LOVE-CAUSE(L-ROW) > 0
         IF PL-USED(EN-LOVE-CAUSE(L-ROW)) = 1
             MOVE PL-UUID(EN-LOVE-CAUSE(L-ROW)) TO WS-UUID
         END-IF
     END-IF
     IF WS-UUID NOT = SPACES
         MOVE "LoveCause" TO WN MOVE 9 TO WL
         CALL "PERSIST-UUID-INTS" USING WS-DIRECTION WS-UUID WS-INTS
         CALL "NBT-WRITE-INT-ARRAY" USING PB-BUFFER WN WL WS-FOUR WS-INTS
     END-IF
     GOBACK.
 END PROGRAM MOBKEEP-NBT-WRITE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ENTITY-KEEP-SLICE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-START               BINARY-LONG.
 01 WS-SIZE                BINARY-LONG.
 01 WS-POINTER             USAGE POINTER.
 01 B-SLICE                PIC X(2048) BASED.
 01 B-OUT                  PIC X(2048) BASED.
 LINKAGE SECTION.
 COPY PROTO.
 01 L-TYPE                 BINARY-LONG.
 01 L-CAPACITY             BINARY-LONG.
 01 L-LENGTH               BINARY-LONG.
 01 L-OUT                  PIC X.
 PROCEDURE DIVISION USING PB-BUFFER L-TYPE L-CAPACITY L-LENGTH L-OUT.
     MOVE 0 TO L-LENGTH
     MOVE PB-POS TO WS-START
     CALL "NBT-READ-SKIP" USING PB-BUFFER L-TYPE
     COMPUTE WS-SIZE = PB-POS - WS-START
     IF PB-ERROR = 0 AND WS-SIZE > 0 AND WS-SIZE <= L-CAPACITY
         SET WS-POINTER TO PB-ADDR
         SET WS-POINTER UP BY WS-START
         SET ADDRESS OF B-SLICE TO WS-POINTER
         SET ADDRESS OF B-OUT TO ADDRESS OF L-OUT
         MOVE B-SLICE(1:WS-SIZE) TO B-OUT(1:WS-SIZE)
         MOVE WS-SIZE TO L-LENGTH
     END-IF
     GOBACK.
 END PROGRAM ENTITY-KEEP-SLICE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ENTITY-KEEP-APPEND.
*> USING PB-BUFFER, start (BINARY-LONG offset), size, capacity of the area, length (in and out: the bytes held), area: the size bytes of the buffer after
*> offset start are appended to the area when they fit its capacity; else nothing changes.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-POINTER             USAGE POINTER.
 01 B-SLICE                PIC X(2048) BASED.
 01 B-OUT                  PIC X(2048) BASED.
 LINKAGE SECTION.
 COPY PROTO.
 01 L-START                BINARY-LONG.
 01 L-SIZE                 BINARY-LONG.
 01 L-CAPACITY             BINARY-LONG.
 01 L-LENGTH               BINARY-LONG.
 01 L-OUT                  PIC X.
 PROCEDURE DIVISION USING PB-BUFFER L-START L-SIZE L-CAPACITY L-LENGTH L-OUT.
     IF L-SIZE > 0 AND L-SIZE <= 2048 AND L-LENGTH + L-SIZE <= L-CAPACITY
         SET WS-POINTER TO PB-ADDR
         SET WS-POINTER UP BY L-START
         SET ADDRESS OF B-SLICE TO WS-POINTER
         SET ADDRESS OF B-OUT TO ADDRESS OF L-OUT
         MOVE B-SLICE(1:L-SIZE) TO B-OUT(L-LENGTH + 1:L-SIZE)
         ADD L-SIZE TO L-LENGTH
     END-IF
     GOBACK.
 END PROGRAM ENTITY-KEEP-APPEND.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ENTITY-TAGS-READ.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-ELEMENT-TYPE        BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-START               BINARY-LONG.
 01 WS-SIZE                BINARY-LONG.
 01 WS-ELEMENT-LENGTH      BINARY-LONG.
 01 WS-DUPLICATE           BINARY-LONG.
 01 WS-ENTRY               PIC X(1024).
 01 WS-POINTER             USAGE POINTER.
 01 B-ENTRY                PIC X(2048) BASED.
 01 B-OUT                  PIC X(1024) BASED.
 LINKAGE SECTION.
 COPY PROTO.
 01 L-COUNT                BINARY-LONG.
 01 L-LENGTH               BINARY-LONG.
 01 L-OUT                  PIC X.
 PROCEDURE DIVISION USING PB-BUFFER L-COUNT L-LENGTH L-OUT.
     MOVE 0 TO L-COUNT L-LENGTH
     SET ADDRESS OF B-OUT TO ADDRESS OF L-OUT
     CALL "NBT-READ-LIST-BEGIN" USING PB-BUFFER WS-ELEMENT-TYPE WS-N
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-N OR PB-ERROR = 1
         MOVE PB-POS TO WS-START
         CALL "NBT-READ-SKIP" USING PB-BUFFER WS-ELEMENT-TYPE
         COMPUTE WS-SIZE = PB-POS - WS-START
         IF PB-ERROR = 0 AND WS-ELEMENT-TYPE = 8 AND WS-SIZE <= 1024
             SET WS-POINTER TO PB-ADDR
             SET WS-POINTER UP BY WS-START
             SET ADDRESS OF B-ENTRY TO WS-POINTER
             MOVE B-ENTRY(1:WS-SIZE) TO WS-ENTRY(1:WS-SIZE)
             MOVE 0 TO WS-DUPLICATE
             MOVE 1 TO WS-J
             PERFORM UNTIL WS-J > L-LENGTH OR WS-DUPLICATE = 1
                 COMPUTE WS-ELEMENT-LENGTH = 2 + (FUNCTION ORD(B-OUT(WS-J:1)) - 1) * 256 + FUNCTION ORD(B-OUT(WS-J + 1:1)) - 1
                 IF WS-ELEMENT-LENGTH = WS-SIZE AND B-OUT(WS-J:WS-SIZE) = WS-ENTRY(1:WS-SIZE)
                     MOVE 1 TO WS-DUPLICATE
                 END-IF
                 ADD WS-ELEMENT-LENGTH TO WS-J
             END-PERFORM
             IF WS-DUPLICATE = 0 AND L-LENGTH + WS-SIZE <= 1024
                 MOVE WS-ENTRY(1:WS-SIZE) TO B-OUT(L-LENGTH + 1:WS-SIZE)
                 ADD WS-SIZE TO L-LENGTH
                 ADD 1 TO L-COUNT
             END-IF
         END-IF
     END-PERFORM
     IF WS-N > 1024
         MOVE 0 TO L-COUNT L-LENGTH
     END-IF
     GOBACK.
 END PROGRAM ENTITY-TAGS-READ.
