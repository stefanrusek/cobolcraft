*> Entity NBT, part 7 (docs/protocol/45-entity-nbt-7-aquatic-and-misc-mobs.md sections 3, 4 and 6; lane 002-lane-p49k, T24550): the keys of the fish, the glow squid, the
*> dolphin and the tadpole after the chain keys.
*>   AQUATIC7-NBT-WRITE USING row, species key (PIC X(24)), PB-BUFFER   FromBucket (cod, salmon, pufferfish, tropical fish, tadpole), salmon type, pufferfish PuffState,
*>        tropical fish Variant, glow squid DarkTicksRemaining, dolphin GotFish and Moistness, tadpole Age and AgeLocked
*>   AQUATIC7-NBT-KEY USING PB-BUFFER, tag type, name, A7-DATA, handled   one tag of these
*>   AQUATIC7-NBT-APPLY USING row, species key, A7-DATA   puts them into the new mob (EN-VARIANT of a salmon and a tropical fish is 1 + the saved value)
*> A tropical fish's Variant is the key llamas and parrots use: MOB-NBT-KEY reads it (MQ-VARIANT-INT) and ENTITY-NBT-ONE hands it to A7-TROP.
*> No state in the core, written at the default: FromBucket 0, GotFish 0. The tadpole has no Age block of the chain (it is not an AgeableMob): its own Age and AgeLocked replace it.
*> Not modelled (no row): axolotl, nautilus, zombie nautilus variant; the squid and the strider keep the Age keys of MOB-NBT-WRITE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. AQUATIC7-NBT-WRITE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WN                     PIC X(32).
 01 WL                     BINARY-LONG.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-VALUE               BINARY-LONG.
 01 WS-TEXT                PIC X(8).
 01 WS-TEXT-LENGTH         BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-KEY                  PIC X(24).
 COPY PROTO.
 PROCEDURE DIVISION USING L-ROW L-KEY PB-BUFFER.
     IF L-KEY = "cod" OR "salmon" OR "pufferfish" OR "tropical_fish" OR "tadpole"
         MOVE "FromBucket" TO WN MOVE 10 TO WL
         CALL "NBT-WRITE-BYTE" USING PB-BUFFER WN WL WS-ZERO
     END-IF
     EVALUATE TRUE
         WHEN L-KEY = "salmon"
             MOVE "type" TO WN MOVE 4 TO WL
             MOVE "medium" TO WS-TEXT MOVE 6 TO WS-TEXT-LENGTH
             IF EN-VARIANT(L-ROW) = 1
                 MOVE "small" TO WS-TEXT MOVE 5 TO WS-TEXT-LENGTH
             END-IF
             IF EN-VARIANT(L-ROW) = 3
                 MOVE "large" TO WS-TEXT MOVE 5 TO WS-TEXT-LENGTH
             END-IF
             CALL "NBT-WRITE-STRING" USING PB-BUFFER WN WL WS-TEXT WS-TEXT-LENGTH
         WHEN L-KEY = "pufferfish"
             MOVE "PuffState" TO WN MOVE 9 TO WL
             CALL "NBT-WRITE-INT" USING PB-BUFFER WN WL EN-VARIANT(L-ROW)
         WHEN L-KEY = "tropical_fish"
             MOVE "Variant" TO WN MOVE 7 TO WL
             COMPUTE WS-VALUE = FUNCTION MAX(EN-VARIANT(L-ROW) - 1, 0)
             CALL "NBT-WRITE-INT" USING PB-BUFFER WN WL WS-VALUE
         WHEN L-KEY = "glow_squid"
             MOVE "DarkTicksRemaining" TO WN MOVE 18 TO WL
             CALL "NBT-WRITE-INT" USING PB-BUFFER WN WL EN-DARK(L-ROW)
         WHEN L-KEY = "dolphin"
             MOVE "GotFish" TO WN MOVE 7 TO WL
             CALL "NBT-WRITE-BYTE" USING PB-BUFFER WN WL WS-ZERO
             MOVE "Moistness" TO WN MOVE 9 TO WL
             COMPUTE WS-VALUE = 2400 - EN-DRY(L-ROW)
             CALL "NBT-WRITE-INT" USING PB-BUFFER WN WL WS-VALUE
         WHEN L-KEY = "tadpole"
             MOVE "Age" TO WN MOVE 3 TO WL
             CALL "NBT-WRITE-INT" USING PB-BUFFER WN WL EN-TAD-AGE(L-ROW)
             MOVE "AgeLocked" TO WN MOVE 9 TO WL
             CALL "NBT-WRITE-BYTE" USING PB-BUFFER WN WL EN-LOCKED(L-ROW)
     END-EVALUATE
     GOBACK.
 END PROGRAM AQUATIC7-NBT-WRITE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. AQUATIC7-NBT-KEY.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-TEXT-CAPACITY       BINARY-LONG VALUE 8.
 01 WS-TEXT-LENGTH         BINARY-LONG.
 LINKAGE SECTION.
 COPY PROTO.
 01 L-TYPE                 BINARY-LONG.
 01 L-NAME                 PIC X(32).
 COPY A7DATA.
 01 L-HANDLED              BINARY-LONG.
 PROCEDURE DIVISION USING PB-BUFFER L-TYPE L-NAME A7-DATA L-HANDLED.
     MOVE 1 TO L-HANDLED
     EVALUATE TRUE
         WHEN L-NAME = "type" AND L-TYPE = 8
             MOVE SPACES TO A7-SALMON
             CALL "NBT-READ-STRING" USING PB-BUFFER A7-SALMON WS-TEXT-CAPACITY WS-TEXT-LENGTH
         WHEN L-NAME = "PuffState" AND L-TYPE = 3
             CALL "PB-GET-INT" USING PB-BUFFER A7-PUFF
         WHEN L-NAME = "DarkTicksRemaining" AND L-TYPE = 3
             CALL "PB-GET-INT" USING PB-BUFFER A7-DARK
         WHEN L-NAME = "Moistness" AND L-TYPE = 3
             CALL "PB-GET-INT" USING PB-BUFFER A7-MOIST
         WHEN OTHER
             MOVE 0 TO L-HANDLED
     END-EVALUATE
     GOBACK.
 END PROGRAM AQUATIC7-NBT-KEY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. AQUATIC7-NBT-APPLY.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-KEY                  PIC X(24).
 COPY A7DATA.
 PROCEDURE DIVISION USING L-ROW L-KEY A7-DATA.
     EVALUATE TRUE
         WHEN L-KEY = "salmon"
             MOVE 2 TO EN-VARIANT(L-ROW)
             IF A7-SALMON = "small"
                 MOVE 1 TO EN-VARIANT(L-ROW)
             END-IF
             IF A7-SALMON = "large"
                 MOVE 3 TO EN-VARIANT(L-ROW)
             END-IF
         WHEN L-KEY = "pufferfish"
             COMPUTE EN-VARIANT(L-ROW) = FUNCTION MIN(A7-PUFF, 2)
         WHEN L-KEY = "tropical_fish"
             COMPUTE EN-VARIANT(L-ROW) = A7-TROP + 1
         WHEN L-KEY = "glow_squid"
             MOVE A7-DARK TO EN-DARK(L-ROW)
         WHEN L-KEY = "dolphin"
             COMPUTE EN-DRY(L-ROW) = FUNCTION MAX(2400 - A7-MOIST, 0)
         WHEN L-KEY = "tadpole"
             MOVE A7-AGE TO EN-TAD-AGE(L-ROW)
             MOVE A7-LOCKED TO EN-LOCKED(L-ROW)
         WHEN OTHER
             CONTINUE
     END-EVALUATE
     GOBACK.
 END PROGRAM AQUATIC7-NBT-APPLY.
