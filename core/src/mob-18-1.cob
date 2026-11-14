*> The entity model of the mob framework (docs/protocol/18-mob-framework.md section 1; lane 002-lane-mobsfull-h13). The tables are copybooks generated from the
*> tables of the document (MOB181.cpy registry, MOB181ATTR.cpy attributes, MOB181SLOT.cpy base metadata slots, MOB181SEAT.cpy passenger seats; MOBCATS.cpy categories).
*>
*>   M181-FIND USING key (PIC X(24), no namespace), row out (BINARY-LONG, id + 1, 0 not found)     1.1 the registry row of an entity type
*>   M181-SEAT-FIND USING key, row out                                                              1.1.1 the row of MOB181SEAT (0 = no declared attachments)
*>   M181-RIDER-Y USING vehicle key, seat (1 to 4), rider key, y out (millionths)                    1.1.1 the rider's y above the vehicle's position: seat y + the rider's riding offset
*>   M181-CAT-NAME USING category (1 to 8), serialized name out (PIC X(32))                          1.2 the serialized name of a MobCategory
*>   M181-CAT-SPAWNING USING category, natural spawning 1/0 out                                      1.2 every category but MISC takes part in natural spawning
*>   M181-NO-DESPAWN USING distance out                                                             1.2 the no-despawn distance of every category (32)
*>   M181-ATTR-FIND USING name (PIC X(32)), row out                                                  1.3 the row of MOB181ATTR (0 not found)
*>   M181-ATTR-SET USING set (1 living entity base, 2 mob base), name, in set out, base out (millionths)   1.3 the attributes of the shared base sets and their base values
*>   M181-ATTR-VALUE USING attribute row, base, M181-MODS record, value out                           1.3 AttributeInstance.calculateValue, clamped to the attribute's range
*>   M181-FLAG-MASK USING group (1 shared flags, 2 living flags, 3 mob flags), name (PIC X(16)), mask out   1.4 the bit of a flag in its metadata byte (0 not found)

 IDENTIFICATION DIVISION.
 PROGRAM-ID. M181-FIND.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY MOB181.
 01 WS-I                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-KEY                  PIC X(24).
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-KEY L-ROW.
     MOVE 0 TO L-ROW
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > M1-COUNT OR L-ROW > 0
         IF M1-KEY(WS-I) = L-KEY
             MOVE WS-I TO L-ROW
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM M181-FIND.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. M181-SEAT-FIND.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY MOB181SEAT.
 01 WS-I                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-KEY                  PIC X(24).
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-KEY L-ROW.
     MOVE 0 TO L-ROW
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > MR-COUNT OR L-ROW > 0
         IF MR-KEY(WS-I) = L-KEY
             MOVE WS-I TO L-ROW
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM M181-SEAT-FIND.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. M181-RIDER-Y.
*> A vehicle that declares no seat has its seat at the top of its box (the document's inferred default); an unknown vehicle has the seat at 0.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY MOB181.
 COPY MOB181SEAT.
 01 WS-V                   BINARY-LONG.
 01 WS-R                   BINARY-LONG.
 01 WS-T                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-VEHICLE              PIC X(24).
 01 L-SEAT                 BINARY-LONG.
 01 L-RIDER                PIC X(24).
 01 L-Y                    BINARY-LONG.
 PROCEDURE DIVISION USING L-VEHICLE L-SEAT L-RIDER L-Y.
     MOVE 0 TO L-Y
     CALL "M181-SEAT-FIND" USING L-VEHICLE WS-V
     IF WS-V > 0 AND MR-SEATS(WS-V) >= L-SEAT
         MOVE MR-SEAT-Y(WS-V, L-SEAT) TO L-Y
     ELSE
         CALL "M181-FIND" USING L-VEHICLE WS-T
         IF WS-T > 0
             MOVE M1-H(WS-T) TO L-Y
         END-IF
     END-IF
     CALL "M181-SEAT-FIND" USING L-RIDER WS-R
     IF WS-R > 0 AND MR-RIDE-SET(WS-R) = 1
         ADD MR-RIDE(WS-R) TO L-Y
     END-IF
     GOBACK.
 END PROGRAM M181-RIDER-Y.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. M181-CAT-NAME.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-CAT                  BINARY-LONG.
 01 L-NAME                 PIC X(32).
 PROCEDURE DIVISION USING L-CAT L-NAME.
     MOVE SPACES TO L-NAME
     EVALUATE L-CAT
         WHEN 1 MOVE "monster" TO L-NAME
         WHEN 2 MOVE "creature" TO L-NAME
         WHEN 3 MOVE "ambient" TO L-NAME
         WHEN 4 MOVE "axolotls" TO L-NAME
         WHEN 5 MOVE "underground_water_creature" TO L-NAME
         WHEN 6 MOVE "water_creature" TO L-NAME
         WHEN 7 MOVE "water_ambient" TO L-NAME
         WHEN 8 MOVE "misc" TO L-NAME
     END-EVALUATE
     GOBACK.
 END PROGRAM M181-CAT-NAME.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. M181-CAT-SPAWNING.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-CAT                  BINARY-LONG.
 01 L-SPAWNING             BINARY-LONG.
 PROCEDURE DIVISION USING L-CAT L-SPAWNING.
     MOVE 0 TO L-SPAWNING
     IF L-CAT >= 1 AND L-CAT <= 7
         MOVE 1 TO L-SPAWNING
     END-IF
     GOBACK.
 END PROGRAM M181-CAT-SPAWNING.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. M181-NO-DESPAWN.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-DISTANCE             BINARY-LONG.
 PROCEDURE DIVISION USING L-DISTANCE.
     MOVE 32 TO L-DISTANCE
     GOBACK.
 END PROGRAM M181-NO-DESPAWN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. M181-ATTR-FIND.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY MOB181ATTR.
 01 WS-I                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-NAME                 PIC X(32).
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-NAME L-ROW.
     MOVE 0 TO L-ROW
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > MA-COUNT OR L-ROW > 0
         IF MA-NAME(WS-I) = L-NAME
             MOVE WS-I TO L-ROW
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM M181-ATTR-FIND.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. M181-ATTR-SET.
*> The living entity base set has 26 attributes (the names below); the mob base adds follow_range with the base value 16; every base value is the registry default.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY MOB181ATTR.
 01 WS-ROW                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-SET                  BINARY-LONG.
 01 L-NAME                 PIC X(32).
 01 L-IN                   BINARY-LONG.
 01 L-BASE                 BINARY-DOUBLE.
 PROCEDURE DIVISION USING L-SET L-NAME L-IN L-BASE.
     MOVE 0 TO L-IN L-BASE
     EVALUATE L-NAME
         WHEN "max_health" WHEN "knockback_resistance" WHEN "movement_speed" WHEN "armor" WHEN "armor_toughness"
         WHEN "max_absorption" WHEN "step_height" WHEN "scale" WHEN "gravity" WHEN "safe_fall_distance"
         WHEN "fall_damage_multiplier" WHEN "jump_strength" WHEN "entity_interaction_range" WHEN "oxygen_bonus"
         WHEN "burning_time" WHEN "explosion_knockback_resistance" WHEN "water_movement_efficiency"
         WHEN "movement_efficiency" WHEN "attack_knockback" WHEN "camera_distance" WHEN "waypoint_transmit_range"
         WHEN "bounciness" WHEN "air_drag_modifier" WHEN "friction_modifier" WHEN "name_tag_distance"
         WHEN "below_name_distance"
             MOVE 1 TO L-IN
         WHEN "follow_range"
             IF L-SET = 2
                 MOVE 1 TO L-IN
             END-IF
     END-EVALUATE
     IF L-IN = 1
         CALL "M181-ATTR-FIND" USING L-NAME WS-ROW
         MOVE MA-DEFAULT(WS-ROW) TO L-BASE
         IF L-NAME = "follow_range"
             MOVE 16000000 TO L-BASE
         END-IF
     END-IF
     GOBACK.
 END PROGRAM M181-ATTR-SET.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. M181-ATTR-VALUE.
*> USING attribute row, base (FLOAT-LONG), M181-MODS (counts and amounts of the modifiers, up to 8 of each operation), value out (FLOAT-LONG): v = base + the ADD_VALUE
*> amounts; r = v + v x (the sum of the ADD_MULTIPLIED_BASE amounts); then r x (1 + amount) for each ADD_MULTIPLIED_TOTAL modifier in turn; the result is limited
*> to the attribute's range.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY MOB181ATTR.
 01 WS-I                   BINARY-LONG.
 01 WS-V                   FLOAT-LONG.
 01 WS-R                   FLOAT-LONG.
 01 WS-MB                  FLOAT-LONG.
 01 WS-MIN                 FLOAT-LONG.
 01 WS-MAX                 FLOAT-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-BASE                 FLOAT-LONG.
 01 L-MODS.
    05 L-N-ADD             BINARY-LONG.
    05 L-N-BASE            BINARY-LONG.
    05 L-N-TOTAL           BINARY-LONG.
    05 L-ADD               FLOAT-LONG OCCURS 8 TIMES.
    05 L-MULT-BASE         FLOAT-LONG OCCURS 8 TIMES.
    05 L-MULT-TOTAL        FLOAT-LONG OCCURS 8 TIMES.
 01 L-VALUE                FLOAT-LONG.
 PROCEDURE DIVISION USING L-ROW L-BASE L-MODS L-VALUE.
     MOVE L-BASE TO WS-V
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > L-N-ADD
         ADD L-ADD(WS-I) TO WS-V
     END-PERFORM
     MOVE 0 TO WS-MB
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > L-N-BASE
         ADD L-MULT-BASE(WS-I) TO WS-MB
     END-PERFORM
     COMPUTE WS-R = WS-V + WS-V * WS-MB
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > L-N-TOTAL
         COMPUTE WS-R = WS-R * (1 + L-MULT-TOTAL(WS-I))
     END-PERFORM
     COMPUTE WS-MIN = MA-MIN(L-ROW) / 1000000
     COMPUTE WS-MAX = MA-MAX(L-ROW) / 1000000
     COMPUTE L-VALUE = FUNCTION MIN(WS-MAX, FUNCTION MAX(WS-MIN, WS-R))
     GOBACK.
 END PROGRAM M181-ATTR-VALUE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. M181-FLAG-MASK.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-GROUP                BINARY-LONG.
 01 L-NAME                 PIC X(16).
 01 L-MASK                 BINARY-LONG.
 PROCEDURE DIVISION USING L-GROUP L-NAME L-MASK.
     MOVE 0 TO L-MASK
     EVALUATE L-GROUP ALSO L-NAME
         WHEN 1 ALSO "on_fire"
             MOVE 1 TO L-MASK
         WHEN 1 ALSO "crouching"
             MOVE 2 TO L-MASK
         WHEN 1 ALSO "sprinting"
             MOVE 8 TO L-MASK
         WHEN 1 ALSO "swimming"
             MOVE 16 TO L-MASK
         WHEN 1 ALSO "invisible"
             MOVE 32 TO L-MASK
         WHEN 1 ALSO "glowing"
             MOVE 64 TO L-MASK
         WHEN 1 ALSO "fall_flying"
             MOVE 128 TO L-MASK
         WHEN 2 ALSO "using_item"
             MOVE 1 TO L-MASK
         WHEN 2 ALSO "off_hand"
             MOVE 2 TO L-MASK
         WHEN 2 ALSO "spin_attack"
             MOVE 4 TO L-MASK
         WHEN 3 ALSO "no_ai"
             MOVE 1 TO L-MASK
         WHEN 3 ALSO "left_handed"
             MOVE 2 TO L-MASK
         WHEN 3 ALSO "aggressive"
             MOVE 4 TO L-MASK
     END-EVALUATE
     GOBACK.
 END PROGRAM M181-FLAG-MASK.
