*> Entity NBT, part 9 (docs/protocol/45-entity-nbt-9-bosses-and-decorations.md section 11; lane 002-lane-p49k, T24580): the armor stand.
*>   ARMORSTAND9-NBT-WRITE USING row, PB-BUFFER   after the LivingEntity keys: Invisible, Small, ShowArms, DisabledSlots, NoBasePlate (all 0: the core's armor stand has no such state) and
*>        an empty Pose compound (every limb at its default; whether a default limb is written is Open question 12 of the document, the empty form is the one chosen)
*> An armor stand is a LivingEntity and no Mob: ENTITY-IS-LIVING answers 2 for it and the writer leaves out the Mob keys. Not modelled: Marker, the limb poses, the equipment slots, the ender
*> dragon entity keys (DragonPhase, DragonDeathTime, sitting_damage_received: the fight is in end-38f.cob, the phase is not stored), the wither, painting, item frames, leash knot, cushion,
*> mannequin (no entity state in the core), custom boss events.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ARMORSTAND9-NBT-WRITE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WN                     PIC X(32).
 01 WL                     BINARY-LONG.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 COPY PROTO.
 PROCEDURE DIVISION USING L-ROW PB-BUFFER.
     MOVE "Invisible" TO WN MOVE 9 TO WL
     CALL "NBT-WRITE-BYTE" USING PB-BUFFER WN WL WS-ZERO
     MOVE "Small" TO WN MOVE 5 TO WL
     CALL "NBT-WRITE-BYTE" USING PB-BUFFER WN WL WS-ZERO
     MOVE "ShowArms" TO WN MOVE 8 TO WL
     CALL "NBT-WRITE-BYTE" USING PB-BUFFER WN WL WS-ZERO
     MOVE "DisabledSlots" TO WN MOVE 13 TO WL
     CALL "NBT-WRITE-INT" USING PB-BUFFER WN WL WS-ZERO
     MOVE "NoBasePlate" TO WN MOVE 11 TO WL
     CALL "NBT-WRITE-BYTE" USING PB-BUFFER WN WL WS-ZERO
     MOVE "Pose" TO WN MOVE 4 TO WL
     CALL "NBT-WRITE-COMPOUND-BEGIN" USING PB-BUFFER WN WL
     CALL "NBT-WRITE-COMPOUND-END" USING PB-BUFFER
     GOBACK.
 END PROGRAM ARMORSTAND9-NBT-WRITE.
