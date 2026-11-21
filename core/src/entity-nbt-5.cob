*> Entity NBT, part 5 (docs/protocol/45-entity-nbt-5-hostile-mobs.md sections 4 to 6; lane 002-lane-p49k, T24530): the keys of the hostile species after the chain keys.
*>   HOSTILE5-NBT-WRITE USING row, species key (PIC X(24)), PB-BUFFER   zombie family (CanBreakDoors, InWaterTime, DrownedConversionTime), skeleton
*>        (FreezingTime, StrayConversionTime), creeper (Fuse, ExplosionRadius, ignited), ghast (ExplosionPower), phantom (anchor_pos, size), shulker
*>        (AttachFace, Peek, Color), slime and magma cube (wasOnGround), zoglin (IsBaby), hoglin (IsImmuneToZombification, TimeInOverworld,
*>        CannotBeHunted), the raiders (PatrolLeader, Patrolling, Wave, CanJoinRaid), ravager (AttackTick, StunTick, RoarTick)
*>   HOSTILE5-NBT-KEY USING PB-BUFFER, tag type, name, H5-DATA, handled   one tag of these
*>   HOSTILE5-NBT-APPLY USING row, species key, H5-DATA   puts them into the new mob (a creeper's ignited, a phantom's anchor and size, a hoglin's immunity
*>        and time in the overworld, a zoglin's baby flag, a shulker's peek)
*> No state in the core, written at the default (read and ignored): the conversion timers, CanBreakDoors, the creeper's Fuse 30 and ExplosionRadius 3 (constants of the
*> core), ghast ExplosionPower 1, shulker AttachFace 0 and Color 16, wasOnGround, CannotBeHunted, the raid keys, the ravager timers.
*> Not modelled (no field): the enderman's carriedBlockState, endermite Lifetime, vex bound_pos, life_ticks and owner, the warden's anger and listener, creaking
*> home_pos, the sulfur cube, the zombie villager's villager data, offers, gossips and cure, bogged sheared.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. HOSTILE5-NBT-WRITE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WN                     PIC X(32).
 01 WL                     BINARY-LONG.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-MINUS-ONE           BINARY-LONG VALUE -1.
 01 WS-THREE               BINARY-LONG VALUE 3.
 01 WS-FUSE                BINARY-LONG VALUE 30.
 01 WS-RADIUS              BINARY-LONG VALUE 3.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-COLOR               BINARY-LONG VALUE 16.
 01 WS-VALUE               BINARY-LONG.
 01 WS-INTS.
    05 WS-INT              BINARY-LONG OCCURS 3 TIMES.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-KEY                  PIC X(24).
 COPY PROTO.
 PROCEDURE DIVISION USING L-ROW L-KEY PB-BUFFER.
     EVALUATE TRUE
         WHEN L-KEY = "zombie" OR "husk" OR "drowned" OR "zombie_villager" OR "zombified_piglin"
             MOVE "CanBreakDoors" TO WN MOVE 13 TO WL
             CALL "NBT-WRITE-BYTE" USING PB-BUFFER WN WL WS-ZERO
             MOVE "InWaterTime" TO WN MOVE 11 TO WL
             CALL "NBT-WRITE-INT" USING PB-BUFFER WN WL WS-MINUS-ONE
             MOVE "DrownedConversionTime" TO WN MOVE 21 TO WL
             CALL "NBT-WRITE-INT" USING PB-BUFFER WN WL WS-MINUS-ONE
         WHEN L-KEY = "skeleton"
             MOVE "FreezingTime" TO WN MOVE 12 TO WL
             CALL "NBT-WRITE-INT" USING PB-BUFFER WN WL WS-MINUS-ONE
             MOVE "StrayConversionTime" TO WN MOVE 19 TO WL
             CALL "NBT-WRITE-INT" USING PB-BUFFER WN WL WS-MINUS-ONE
         WHEN L-KEY = "creeper"
             MOVE "Fuse" TO WN MOVE 4 TO WL
             CALL "NBT-WRITE-SHORT" USING PB-BUFFER WN WL WS-FUSE
             MOVE "ExplosionRadius" TO WN MOVE 15 TO WL
             CALL "NBT-WRITE-BYTE" USING PB-BUFFER WN WL WS-RADIUS
             MOVE "ignited" TO WN MOVE 7 TO WL
             CALL "NBT-WRITE-BYTE" USING PB-BUFFER WN WL EN-IGNITED(L-ROW)
         WHEN L-KEY = "ghast"
             MOVE "ExplosionPower" TO WN MOVE 14 TO WL
             CALL "NBT-WRITE-BYTE" USING PB-BUFFER WN WL WS-ONE
         WHEN L-KEY = "phantom"
             IF EN-PH-SET(L-ROW) = 1
                 MOVE "anchor_pos" TO WN MOVE 10 TO WL
                 COMPUTE WS-INT(1) = FUNCTION INTEGER(EN-PH-AX(L-ROW))
                 COMPUTE WS-INT(2) = FUNCTION INTEGER(EN-PH-AY(L-ROW))
                 COMPUTE WS-INT(3) = FUNCTION INTEGER(EN-PH-AZ(L-ROW))
                 CALL "NBT-WRITE-INT-ARRAY" USING PB-BUFFER WN WL WS-THREE WS-INTS
             END-IF
             MOVE "size" TO WN MOVE 4 TO WL
             COMPUTE WS-VALUE = FUNCTION MIN(FUNCTION MAX(EN-VARIANT(L-ROW), 0), 64)
             CALL "NBT-WRITE-INT" USING PB-BUFFER WN WL WS-VALUE
         WHEN L-KEY = "shulker"
             MOVE "AttachFace" TO WN MOVE 10 TO WL
             CALL "NBT-WRITE-BYTE" USING PB-BUFFER WN WL WS-ZERO
             MOVE "Peek" TO WN MOVE 4 TO WL
             CALL "NBT-WRITE-BYTE" USING PB-BUFFER WN WL EN-VARIANT(L-ROW)
             MOVE "Color" TO WN MOVE 5 TO WL
             CALL "NBT-WRITE-BYTE" USING PB-BUFFER WN WL WS-COLOR
         WHEN L-KEY = "slime" OR "magma_cube"
             MOVE "wasOnGround" TO WN MOVE 11 TO WL
             CALL "NBT-WRITE-BYTE" USING PB-BUFFER WN WL WS-ZERO
         WHEN L-KEY = "zoglin"
             MOVE "IsBaby" TO WN MOVE 6 TO WL
             CALL "NBT-WRITE-BYTE" USING PB-BUFFER WN WL EN-VARIANT(L-ROW)
         WHEN L-KEY = "hoglin"
             MOVE "IsImmuneToZombification" TO WN MOVE 23 TO WL
             CALL "NBT-WRITE-BYTE" USING PB-BUFFER WN WL EN-PIG-IMMUNE(L-ROW)
             MOVE "TimeInOverworld" TO WN MOVE 15 TO WL
             CALL "NBT-WRITE-INT" USING PB-BUFFER WN WL EN-ZOMBIFY(L-ROW)
             MOVE "CannotBeHunted" TO WN MOVE 14 TO WL
             CALL "NBT-WRITE-BYTE" USING PB-BUFFER WN WL WS-ZERO
     END-EVALUATE
     IF L-KEY = "witch" OR "ravager" OR "pillager" OR "vindicator" OR "evoker" OR "illusioner"
         MOVE "PatrolLeader" TO WN MOVE 12 TO WL
         CALL "NBT-WRITE-BYTE" USING PB-BUFFER WN WL WS-ZERO
         MOVE "Patrolling" TO WN MOVE 10 TO WL
         CALL "NBT-WRITE-BYTE" USING PB-BUFFER WN WL WS-ZERO
         MOVE "Wave" TO WN MOVE 4 TO WL
         CALL "NBT-WRITE-INT" USING PB-BUFFER WN WL WS-ZERO
         MOVE "CanJoinRaid" TO WN MOVE 11 TO WL
         CALL "NBT-WRITE-BYTE" USING PB-BUFFER WN WL WS-ZERO
     END-IF
     IF L-KEY = "ravager"
         MOVE "AttackTick" TO WN MOVE 10 TO WL
         CALL "NBT-WRITE-INT" USING PB-BUFFER WN WL WS-ZERO
         MOVE "StunTick" TO WN MOVE 8 TO WL
         CALL "NBT-WRITE-INT" USING PB-BUFFER WN WL WS-ZERO
         MOVE "RoarTick" TO WN MOVE 8 TO WL
         CALL "NBT-WRITE-INT" USING PB-BUFFER WN WL WS-ZERO
     END-IF
     GOBACK.
 END PROGRAM HOSTILE5-NBT-WRITE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. HOSTILE5-NBT-KEY.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-INT-CAPACITY        BINARY-LONG VALUE 4.
 01 WS-INT-COUNT           BINARY-LONG.
 01 WS-INTS.
    05 WS-INT              BINARY-LONG OCCURS 4 TIMES.
 LINKAGE SECTION.
 COPY PROTO.
 01 L-TYPE                 BINARY-LONG.
 01 L-NAME                 PIC X(32).
 COPY H5DATA.
 01 L-HANDLED              BINARY-LONG.
 PROCEDURE DIVISION USING PB-BUFFER L-TYPE L-NAME H5-DATA L-HANDLED.
     MOVE 1 TO L-HANDLED
     EVALUATE TRUE
         WHEN L-NAME = "ignited" AND L-TYPE = 1
             CALL "PB-GET-BYTE" USING PB-BUFFER H5-IGNITED
         WHEN L-NAME = "size" AND L-TYPE = 3
             CALL "PB-GET-INT" USING PB-BUFFER H5-SIZE
         WHEN L-NAME = "anchor_pos" AND L-TYPE = 11
             CALL "NBT-READ-INT-ARRAY" USING PB-BUFFER WS-INT-CAPACITY WS-INT-COUNT WS-INTS
             IF WS-INT-COUNT = 3
                 MOVE 1 TO H5-ANCHOR-ON
                 MOVE WS-INT(1) TO H5-ANCHOR-X
                 MOVE WS-INT(2) TO H5-ANCHOR-Y
                 MOVE WS-INT(3) TO H5-ANCHOR-Z
             END-IF
         WHEN L-NAME = "IsImmuneToZombification" AND L-TYPE = 1
             CALL "PB-GET-BYTE" USING PB-BUFFER H5-IMMUNE
         WHEN L-NAME = "TimeInOverworld" AND L-TYPE = 3
             CALL "PB-GET-INT" USING PB-BUFFER H5-TIME
         WHEN L-NAME = "Peek" AND L-TYPE = 1
             CALL "PB-GET-BYTE" USING PB-BUFFER H5-PEEK
         WHEN OTHER
             MOVE 0 TO L-HANDLED
     END-EVALUATE
     GOBACK.
 END PROGRAM HOSTILE5-NBT-KEY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. HOSTILE5-NBT-APPLY.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-KEY                  PIC X(24).
 COPY H5DATA.
 PROCEDURE DIVISION USING L-ROW L-KEY H5-DATA.
     EVALUATE TRUE
         WHEN L-KEY = "creeper"
             MOVE 0 TO EN-IGNITED(L-ROW)
             IF H5-IGNITED NOT = 0
                 MOVE 1 TO EN-IGNITED(L-ROW)
             END-IF
         WHEN L-KEY = "phantom"
             COMPUTE EN-VARIANT(L-ROW) = FUNCTION MIN(FUNCTION MAX(H5-SIZE, 0), 64)
             IF H5-ANCHOR-ON = 1
                 MOVE 1 TO EN-PH-SET(L-ROW)
                 MOVE H5-ANCHOR-X TO EN-PH-AX(L-ROW)
                 MOVE H5-ANCHOR-Y TO EN-PH-AY(L-ROW)
                 MOVE H5-ANCHOR-Z TO EN-PH-AZ(L-ROW)
             END-IF
         WHEN L-KEY = "hoglin"
             MOVE 0 TO EN-PIG-IMMUNE(L-ROW)
             IF H5-IMMUNE NOT = 0
                 MOVE 1 TO EN-PIG-IMMUNE(L-ROW)
             END-IF
             MOVE H5-TIME TO EN-ZOMBIFY(L-ROW)
         WHEN L-KEY = "zoglin"
             MOVE 0 TO EN-VARIANT(L-ROW)
             IF H5-BABY NOT = 0
                 MOVE 1 TO EN-VARIANT(L-ROW)
             END-IF
         WHEN L-KEY = "shulker"
             MOVE H5-PEEK TO EN-VARIANT(L-ROW)
         WHEN OTHER
             CONTINUE
     END-EVALUATE
     GOBACK.
 END PROGRAM HOSTILE5-NBT-APPLY.
