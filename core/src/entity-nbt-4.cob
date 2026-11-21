*> Entity NBT, part 4 (docs/protocol/45-entity-nbt-4-land-animals.md sections 5 to 10; lane 002-lane-p49k, T24520): the species keys of the land animals
*> that the core holds state for and that MOB-NBT-WRITE does not already write.
*>   SPECIES4-NBT-WRITE USING row, species key (PIC X(24)), PB-BUFFER   goat (IsScreamingGoat, HasLeftHorn, HasRightHorn), fox (Trusted, Sleeping,
*>        Sitting, Crouching), armadillo (state, scute_time), turtle (home_pos, has_egg), bee (hive_pos, flower_pos, HasNectar, HasStung,
*>        TicksSincePollination, CannotEnterHiveTicks, CropsGrownSincePollination), chicken (IsChickenJockey), allay (Inventory, DuplicationCooldown),
*>        camel (LastPoseTick), the horses (EatingHaystack, Bred), iron golem (PlayerCreated), snow golem (Pumpkin)
*>   SPECIES4-NBT-KEY USING PB-BUFFER, tag type, name, SP-DATA, handled   one tag of these
*>   SPECIES4-NBT-APPLY USING row, species key, SP-DATA   puts them into the new mob
*> A fox's Sitting is read with the pets' (MQ-SIT of MOB-NBT-KEY); ENTITY-NBT-ONE hands it to SP-SIT.
*> No state in the core, written at the default: EatingHaystack, Bred, PlayerCreated 0, Pumpkin 1 (the horse and golem keys are read and ignored).
*> Not modelled (no field): rabbit RabbitType and MoreCarrotTicks, the allay listener, panda and sniffer keys beyond MainGene and HiddenGene, bat BatFlags.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SPECIES4-NBT-WRITE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CITEMS.
 01 WN                     PIC X(32).
 01 WL                     BINARY-LONG.
 01 WS-ELEMENT             BINARY-LONG VALUE -1.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-THREE               BINARY-LONG VALUE 3.
 01 WS-FOUR                BINARY-LONG VALUE 4.
 01 WS-T-INT-ARRAY         BINARY-LONG VALUE 11.
 01 WS-T-COMPOUND          BINARY-LONG VALUE 10.
 01 WS-DIRECTION           BINARY-LONG VALUE 0.
 01 WS-COUNT               BINARY-LONG.
 01 WS-VALUE               BINARY-LONG.
 01 WS-TEXT                PIC X(16).
 01 WS-TEXT-LENGTH         BINARY-LONG.
 01 WS-LONG                BINARY-DOUBLE.
 01 WS-NS-KEY              PIC X(64).
 01 WS-NS-LENGTH           BINARY-LONG.
 01 WS-INTS.
    05 WS-INT              BINARY-LONG OCCURS 4 TIMES.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-KEY                  PIC X(24).
 COPY PROTO.
 PROCEDURE DIVISION USING L-ROW L-KEY PB-BUFFER.
     EVALUATE TRUE
         WHEN L-KEY = "goat"
             MOVE "IsScreamingGoat" TO WN MOVE 15 TO WL
             COMPUTE WS-VALUE = FUNCTION MOD(EN-WOOL(L-ROW), 2)
             CALL "NBT-WRITE-BYTE" USING PB-BUFFER WN WL WS-VALUE
             MOVE "HasLeftHorn" TO WN MOVE 11 TO WL
             COMPUTE WS-VALUE = 1 - FUNCTION MOD(FUNCTION INTEGER(EN-WOOL(L-ROW) / 2), 2)
             CALL "NBT-WRITE-BYTE" USING PB-BUFFER WN WL WS-VALUE
             MOVE "HasRightHorn" TO WN MOVE 12 TO WL
             COMPUTE WS-VALUE = 1 - FUNCTION MOD(FUNCTION INTEGER(EN-WOOL(L-ROW) / 4), 2)
             CALL "NBT-WRITE-BYTE" USING PB-BUFFER WN WL WS-VALUE
         WHEN L-KEY = "fox"
             MOVE 0 TO WS-COUNT
             IF EN-FOX-TRUST-A(L-ROW) NOT = SPACES
                 ADD 1 TO WS-COUNT
             END-IF
             IF EN-FOX-TRUST-B(L-ROW) NOT = SPACES
                 ADD 1 TO WS-COUNT
             END-IF
             MOVE "Trusted" TO WN MOVE 7 TO WL
             CALL "NBT-WRITE-LIST-BEGIN" USING PB-BUFFER WN WL WS-T-INT-ARRAY WS-COUNT
             IF EN-FOX-TRUST-A(L-ROW) NOT = SPACES
                 CALL "PERSIST-UUID-INTS" USING WS-DIRECTION EN-FOX-TRUST-A(L-ROW) WS-INTS
                 CALL "NBT-WRITE-INT-ARRAY" USING PB-BUFFER WN WS-ELEMENT WS-FOUR WS-INTS
             END-IF
             IF EN-FOX-TRUST-B(L-ROW) NOT = SPACES
                 CALL "PERSIST-UUID-INTS" USING WS-DIRECTION EN-FOX-TRUST-B(L-ROW) WS-INTS
                 CALL "NBT-WRITE-INT-ARRAY" USING PB-BUFFER WN WS-ELEMENT WS-FOUR WS-INTS
             END-IF
             MOVE "Sleeping" TO WN MOVE 8 TO WL
             COMPUTE WS-VALUE = FUNCTION MOD(FUNCTION INTEGER(EN-FOX-FLAGS(L-ROW) / 32), 2)
             CALL "NBT-WRITE-BYTE" USING PB-BUFFER WN WL WS-VALUE
             MOVE "Sitting" TO WN MOVE 7 TO WL
             COMPUTE WS-VALUE = FUNCTION MOD(EN-FOX-FLAGS(L-ROW), 2)
             CALL "NBT-WRITE-BYTE" USING PB-BUFFER WN WL WS-VALUE
             MOVE "Crouching" TO WN MOVE 9 TO WL
             COMPUTE WS-VALUE = FUNCTION MOD(FUNCTION INTEGER(EN-FOX-FLAGS(L-ROW) / 4), 2)
             CALL "NBT-WRITE-BYTE" USING PB-BUFFER WN WL WS-VALUE
         WHEN L-KEY = "armadillo"
             MOVE "state" TO WN MOVE 5 TO WL
             EVALUATE EN-ARMA(L-ROW)
                 WHEN 1 MOVE "rolling" TO WS-TEXT MOVE 7 TO WS-TEXT-LENGTH
                 WHEN 2 MOVE "scared" TO WS-TEXT MOVE 6 TO WS-TEXT-LENGTH
                 WHEN 3 MOVE "unrolling" TO WS-TEXT MOVE 9 TO WS-TEXT-LENGTH
                 WHEN OTHER MOVE "idle" TO WS-TEXT MOVE 4 TO WS-TEXT-LENGTH
             END-EVALUATE
             CALL "NBT-WRITE-STRING" USING PB-BUFFER WN WL WS-TEXT WS-TEXT-LENGTH
             MOVE "scute_time" TO WN MOVE 10 TO WL
             CALL "NBT-WRITE-INT" USING PB-BUFFER WN WL EN-SCUTE(L-ROW)
         WHEN L-KEY = "turtle"
             MOVE "home_pos" TO WN MOVE 8 TO WL
             IF EN-HOME-SET(L-ROW) = 1
                 MOVE EN-HOME-X(L-ROW) TO WS-INT(1)
                 MOVE EN-HOME-Y(L-ROW) TO WS-INT(2)
                 MOVE EN-HOME-Z(L-ROW) TO WS-INT(3)
             ELSE
                 COMPUTE WS-INT(1) = FUNCTION INTEGER(EN-X(L-ROW))
                 COMPUTE WS-INT(2) = FUNCTION INTEGER(EN-Y(L-ROW))
                 COMPUTE WS-INT(3) = FUNCTION INTEGER(EN-Z(L-ROW))
             END-IF
             CALL "NBT-WRITE-INT-ARRAY" USING PB-BUFFER WN WL WS-THREE WS-INTS
             MOVE "has_egg" TO WN MOVE 7 TO WL
             CALL "NBT-WRITE-BYTE" USING PB-BUFFER WN WL EN-TURTLE-EGG(L-ROW)
         WHEN L-KEY = "bee"
             IF EN-BEE-HV-ON(L-ROW) = 1
                 MOVE "hive_pos" TO WN MOVE 8 TO WL
                 MOVE EN-BEE-HV-X(L-ROW) TO WS-INT(1)
                 MOVE EN-BEE-HV-Y(L-ROW) TO WS-INT(2)
                 MOVE EN-BEE-HV-Z(L-ROW) TO WS-INT(3)
                 CALL "NBT-WRITE-INT-ARRAY" USING PB-BUFFER WN WL WS-THREE WS-INTS
             END-IF
             IF EN-BEE-FL-ON(L-ROW) = 1
                 MOVE "flower_pos" TO WN MOVE 10 TO WL
                 MOVE EN-BEE-FL-X(L-ROW) TO WS-INT(1)
                 MOVE EN-BEE-FL-Y(L-ROW) TO WS-INT(2)
                 MOVE EN-BEE-FL-Z(L-ROW) TO WS-INT(3)
                 CALL "NBT-WRITE-INT-ARRAY" USING PB-BUFFER WN WL WS-THREE WS-INTS
             END-IF
             MOVE "HasNectar" TO WN MOVE 9 TO WL
             CALL "NBT-WRITE-BYTE" USING PB-BUFFER WN WL EN-BEE-NECTAR(L-ROW)
             MOVE "HasStung" TO WN MOVE 8 TO WL
             CALL "NBT-WRITE-BYTE" USING PB-BUFFER WN WL EN-BEE-STUNG(L-ROW)
             MOVE "TicksSincePollination" TO WN MOVE 21 TO WL
             CALL "NBT-WRITE-INT" USING PB-BUFFER WN WL EN-BEE-NONECT(L-ROW)
             MOVE "CannotEnterHiveTicks" TO WN MOVE 20 TO WL
             CALL "NBT-WRITE-INT" USING PB-BUFFER WN WL EN-BEE-STAY(L-ROW)
             MOVE "CropsGrownSincePollination" TO WN MOVE 26 TO WL
             CALL "NBT-WRITE-INT" USING PB-BUFFER WN WL EN-BEE-CROPS(L-ROW)
         WHEN L-KEY = "chicken"
             MOVE "IsChickenJockey" TO WN MOVE 15 TO WL
             CALL "NBT-WRITE-BYTE" USING PB-BUFFER WN WL EN-JOCKEY(L-ROW)
         WHEN L-KEY = "allay"
             IF EN-ALLAY-ITEM(L-ROW) > 0 AND EN-ALLAY-COUNT(L-ROW) > 0
                 MOVE 1 TO WS-COUNT
             ELSE
                 MOVE 0 TO WS-COUNT
             END-IF
             MOVE "Inventory" TO WN MOVE 9 TO WL
             CALL "NBT-WRITE-LIST-BEGIN" USING PB-BUFFER WN WL WS-T-COMPOUND WS-COUNT
             IF WS-COUNT = 1
                 CALL "NBT-WRITE-COMPOUND-BEGIN" USING PB-BUFFER WN WS-ELEMENT
                 MOVE "id" TO WN MOVE 2 TO WL
                 COMPUTE WS-VALUE = EN-ALLAY-ITEM(L-ROW) + 1
                 CALL "PERSIST-NAMESPACED" USING IT-KEY(WS-VALUE) IT-KEY-LENGTH(WS-VALUE) WS-NS-KEY WS-NS-LENGTH
                 CALL "NBT-WRITE-STRING" USING PB-BUFFER WN WL WS-NS-KEY WS-NS-LENGTH
                 MOVE "count" TO WN MOVE 5 TO WL
                 CALL "NBT-WRITE-INT" USING PB-BUFFER WN WL EN-ALLAY-COUNT(L-ROW)
                 CALL "NBT-WRITE-COMPOUND-END" USING PB-BUFFER
             END-IF
             MOVE "DuplicationCooldown" TO WN MOVE 19 TO WL
             MOVE EN-ALLAY-DUP(L-ROW) TO WS-LONG
             CALL "NBT-WRITE-LONG" USING PB-BUFFER WN WL WS-LONG
         WHEN L-KEY = "camel"
             MOVE "LastPoseTick" TO WN MOVE 12 TO WL
             MOVE EN-CAMEL-POSE-T(L-ROW) TO WS-LONG
             IF EN-CAMEL-POSE(L-ROW) = 1
                 COMPUTE WS-LONG = 0 - FUNCTION MAX(EN-CAMEL-POSE-T(L-ROW), 1)
             END-IF
             CALL "NBT-WRITE-LONG" USING PB-BUFFER WN WL WS-LONG
         WHEN L-KEY = "iron_golem"
             MOVE "PlayerCreated" TO WN MOVE 13 TO WL
             CALL "NBT-WRITE-BYTE" USING PB-BUFFER WN WL WS-ZERO
         WHEN L-KEY = "snow_golem"
             MOVE "Pumpkin" TO WN MOVE 7 TO WL
             CALL "NBT-WRITE-BYTE" USING PB-BUFFER WN WL WS-ONE
     END-EVALUATE
     IF L-KEY = "horse" OR "donkey" OR "mule" OR "skeleton_horse" OR "zombie_horse" OR "camel"
         MOVE "EatingHaystack" TO WN MOVE 14 TO WL
         CALL "NBT-WRITE-BYTE" USING PB-BUFFER WN WL WS-ZERO
         MOVE "Bred" TO WN MOVE 4 TO WL
         CALL "NBT-WRITE-BYTE" USING PB-BUFFER WN WL WS-ZERO
     END-IF
     GOBACK.
 END PROGRAM SPECIES4-NBT-WRITE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SPECIES4-NBT-KEY.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-TO-UUID             BINARY-LONG VALUE 1.
 01 WS-INT-CAPACITY        BINARY-LONG VALUE 4.
 01 WS-INT-COUNT           BINARY-LONG.
 01 WS-ELEMENT-TYPE        BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-UUID                PIC X(16).
 01 WS-TEXT-CAPACITY       BINARY-LONG VALUE 16.
 01 WS-TEXT-LENGTH         BINARY-LONG.
 01 WS-START               BINARY-LONG.
 01 WS-CONTAINER           BINARY-LONG VALUE 10.
 01 WS-FOUND               BINARY-LONG.
 01 WS-PATH                PIC X(8).
 01 WS-PATH-LENGTH         BINARY-LONG.
 01 WS-KEY                 PIC X(64).
 01 WS-KEY-CAPACITY        BINARY-LONG VALUE 64.
 01 WS-KEY-LENGTH          BINARY-LONG.
 01 WS-LOCAL               PIC X(48).
 01 WS-BARE                PIC X(48).
 01 WS-J                   BINARY-LONG.
 01 WS-INTS.
    05 WS-INT              BINARY-LONG OCCURS 4 TIMES.
 COPY CITEMS.
 LINKAGE SECTION.
 COPY PROTO.
 01 L-TYPE                 BINARY-LONG.
 01 L-NAME                 PIC X(32).
 COPY SPDATA.
 01 L-HANDLED              BINARY-LONG.
 PROCEDURE DIVISION USING PB-BUFFER L-TYPE L-NAME SP-DATA L-HANDLED.
     MOVE 1 TO L-HANDLED
     EVALUATE TRUE
         WHEN L-NAME = "IsScreamingGoat" AND L-TYPE = 1
             CALL "PB-GET-BYTE" USING PB-BUFFER SP-SCREAM
         WHEN L-NAME = "HasLeftHorn" AND L-TYPE = 1
             CALL "PB-GET-BYTE" USING PB-BUFFER SP-LEFT
         WHEN L-NAME = "HasRightHorn" AND L-TYPE = 1
             CALL "PB-GET-BYTE" USING PB-BUFFER SP-RIGHT
         WHEN L-NAME = "Trusted" AND L-TYPE = 9
             CALL "NBT-READ-LIST-BEGIN" USING PB-BUFFER WS-ELEMENT-TYPE WS-COUNT
             PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-COUNT OR PB-ERROR = 1
                 CALL "NBT-READ-INT-ARRAY" USING PB-BUFFER WS-INT-CAPACITY WS-INT-COUNT WS-INTS
                 IF WS-INT-COUNT = 4
                     CALL "PERSIST-UUID-INTS" USING WS-TO-UUID WS-UUID WS-INTS
                     IF SP-TRUST-A = SPACES
                         MOVE WS-UUID TO SP-TRUST-A
                     ELSE
                         IF SP-TRUST-B = SPACES
                             MOVE WS-UUID TO SP-TRUST-B
                         END-IF
                     END-IF
                 END-IF
             END-PERFORM
         WHEN L-NAME = "Sleeping" AND L-TYPE = 1
             CALL "PB-GET-BYTE" USING PB-BUFFER SP-SLEEP
         WHEN L-NAME = "Crouching" AND L-TYPE = 1
             CALL "PB-GET-BYTE" USING PB-BUFFER SP-CROUCH
         WHEN L-NAME = "state" AND L-TYPE = 8
             MOVE SPACES TO SP-STATE
             CALL "NBT-READ-STRING" USING PB-BUFFER SP-STATE WS-TEXT-CAPACITY WS-TEXT-LENGTH
         WHEN L-NAME = "scute_time" AND L-TYPE = 3
             CALL "PB-GET-INT" USING PB-BUFFER SP-SCUTE
         WHEN L-NAME = "home_pos" AND L-TYPE = 11
             CALL "NBT-READ-INT-ARRAY" USING PB-BUFFER WS-INT-CAPACITY WS-INT-COUNT WS-INTS
             IF WS-INT-COUNT = 3
                 MOVE 1 TO SP-HOME-ON
                 MOVE WS-INT(1) TO SP-HOME-X
                 MOVE WS-INT(2) TO SP-HOME-Y
                 MOVE WS-INT(3) TO SP-HOME-Z
             END-IF
         WHEN L-NAME = "has_egg" AND L-TYPE = 1
             CALL "PB-GET-BYTE" USING PB-BUFFER SP-TURTLE-EGG
         WHEN L-NAME = "hive_pos" AND L-TYPE = 11
             CALL "NBT-READ-INT-ARRAY" USING PB-BUFFER WS-INT-CAPACITY WS-INT-COUNT WS-INTS
             IF WS-INT-COUNT = 3
                 MOVE 1 TO SP-HIVE-ON
                 MOVE WS-INT(1) TO SP-HIVE-X
                 MOVE WS-INT(2) TO SP-HIVE-Y
                 MOVE WS-INT(3) TO SP-HIVE-Z
             END-IF
         WHEN L-NAME = "flower_pos" AND L-TYPE = 11
             CALL "NBT-READ-INT-ARRAY" USING PB-BUFFER WS-INT-CAPACITY WS-INT-COUNT WS-INTS
             IF WS-INT-COUNT = 3
                 MOVE 1 TO SP-FLOWER-ON
                 MOVE WS-INT(1) TO SP-FLOWER-X
                 MOVE WS-INT(2) TO SP-FLOWER-Y
                 MOVE WS-INT(3) TO SP-FLOWER-Z
             END-IF
         WHEN L-NAME = "HasNectar" AND L-TYPE = 1
             CALL "PB-GET-BYTE" USING PB-BUFFER SP-NECTAR
         WHEN L-NAME = "HasStung" AND L-TYPE = 1
             CALL "PB-GET-BYTE" USING PB-BUFFER SP-STUNG
         WHEN L-NAME = "TicksSincePollination" AND L-TYPE = 3
             CALL "PB-GET-INT" USING PB-BUFFER SP-NONECTAR
         WHEN L-NAME = "CannotEnterHiveTicks" AND L-TYPE = 3
             CALL "PB-GET-INT" USING PB-BUFFER SP-CANNOT
         WHEN L-NAME = "CropsGrownSincePollination" AND L-TYPE = 3
             CALL "PB-GET-INT" USING PB-BUFFER SP-CROPS
         WHEN L-NAME = "IsChickenJockey" AND L-TYPE = 1
             CALL "PB-GET-BYTE" USING PB-BUFFER SP-JOCKEY
         WHEN L-NAME = "DuplicationCooldown" AND L-TYPE = 4
             CALL "PB-GET-LONG" USING PB-BUFFER SP-DUP
         WHEN L-NAME = "LastPoseTick" AND L-TYPE = 4
             CALL "PB-GET-LONG" USING PB-BUFFER SP-POSE
         WHEN L-NAME = "Inventory" AND L-TYPE = 9
*>           The first stack: its id and count are found in the element; the element is then skipped.
             CALL "NBT-READ-LIST-BEGIN" USING PB-BUFFER WS-ELEMENT-TYPE WS-COUNT
             PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-COUNT OR PB-ERROR = 1
                 MOVE PB-POS TO WS-START
                 MOVE "id" TO WS-PATH
                 MOVE 2 TO WS-PATH-LENGTH
                 CALL "NBT-READ-FIND" USING PB-BUFFER WS-CONTAINER WS-PATH WS-PATH-LENGTH WS-FOUND
                 IF WS-FOUND = 8 AND WS-I = 1
                     MOVE SPACES TO WS-KEY
                     CALL "NBT-READ-STRING" USING PB-BUFFER WS-KEY WS-KEY-CAPACITY WS-KEY-LENGTH
                     CALL "PERSIST-LOCAL-KEY" USING WS-KEY WS-LOCAL
                     CALL "KEY-BARE" USING WS-LOCAL WS-BARE
                     PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > IT-COUNT
                         IF SP-INV-ITEM = 0 AND (IT-KEY(WS-J) = WS-LOCAL OR IT-KEY(WS-J) = WS-BARE)
                             COMPUTE SP-INV-ITEM = WS-J - 1
                         END-IF
                     END-PERFORM
                 END-IF
                 MOVE WS-START TO PB-POS
                 MOVE "count" TO WS-PATH
                 MOVE 5 TO WS-PATH-LENGTH
                 CALL "NBT-READ-FIND" USING PB-BUFFER WS-CONTAINER WS-PATH WS-PATH-LENGTH WS-FOUND
                 IF WS-FOUND = 3 AND WS-I = 1
                     CALL "PB-GET-INT" USING PB-BUFFER SP-INV-COUNT
                 END-IF
                 MOVE WS-START TO PB-POS
                 CALL "NBT-READ-SKIP" USING PB-BUFFER WS-ELEMENT-TYPE
             END-PERFORM
         WHEN OTHER
             MOVE 0 TO L-HANDLED
     END-EVALUATE
     GOBACK.
 END PROGRAM SPECIES4-NBT-KEY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SPECIES4-NBT-APPLY.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-KEY                  PIC X(24).
 COPY SPDATA.
 PROCEDURE DIVISION USING L-ROW L-KEY SP-DATA.
     EVALUATE TRUE
         WHEN L-KEY = "goat"
             MOVE 0 TO EN-WOOL(L-ROW)
             IF SP-SCREAM NOT = 0
                 ADD 1 TO EN-WOOL(L-ROW)
             END-IF
             IF SP-LEFT = 0
                 ADD 2 TO EN-WOOL(L-ROW)
             END-IF
             IF SP-RIGHT = 0
                 ADD 4 TO EN-WOOL(L-ROW)
             END-IF
         WHEN L-KEY = "fox"
             MOVE SP-TRUST-A TO EN-FOX-TRUST-A(L-ROW)
             MOVE SP-TRUST-B TO EN-FOX-TRUST-B(L-ROW)
             MOVE 0 TO EN-FOX-FLAGS(L-ROW)
             IF SP-SIT NOT = 0
                 ADD 1 TO EN-FOX-FLAGS(L-ROW)
             END-IF
             IF SP-CROUCH NOT = 0
                 ADD 4 TO EN-FOX-FLAGS(L-ROW)
             END-IF
             IF SP-SLEEP NOT = 0
                 ADD 32 TO EN-FOX-FLAGS(L-ROW)
             END-IF
         WHEN L-KEY = "armadillo"
             MOVE 0 TO EN-ARMA(L-ROW) EN-ARMA-T(L-ROW)
             EVALUATE SP-STATE
                 WHEN "rolling"
                     MOVE 1 TO EN-ARMA(L-ROW)
                     MOVE 10 TO EN-ARMA-T(L-ROW)
                 WHEN "scared"
                     MOVE 2 TO EN-ARMA(L-ROW)
                     MOVE 50 TO EN-ARMA-T(L-ROW)
                 WHEN "unrolling"
                     MOVE 3 TO EN-ARMA(L-ROW)
                     MOVE 30 TO EN-ARMA-T(L-ROW)
             END-EVALUATE
             IF SP-SCUTE >= 0
                 MOVE SP-SCUTE TO EN-SCUTE(L-ROW)
             END-IF
         WHEN L-KEY = "turtle"
             MOVE SP-TURTLE-EGG TO EN-TURTLE-EGG(L-ROW)
             IF SP-HOME-ON = 1
                 MOVE 1 TO EN-HOME-SET(L-ROW)
                 MOVE SP-HOME-X TO EN-HOME-X(L-ROW)
                 MOVE SP-HOME-Y TO EN-HOME-Y(L-ROW)
                 MOVE SP-HOME-Z TO EN-HOME-Z(L-ROW)
             END-IF
         WHEN L-KEY = "bee"
             MOVE SP-HIVE-ON TO EN-BEE-HV-ON(L-ROW)
             MOVE SP-HIVE-X TO EN-BEE-HV-X(L-ROW)
             MOVE SP-HIVE-Y TO EN-BEE-HV-Y(L-ROW)
             MOVE SP-HIVE-Z TO EN-BEE-HV-Z(L-ROW)
             MOVE SP-FLOWER-ON TO EN-BEE-FL-ON(L-ROW)
             MOVE SP-FLOWER-X TO EN-BEE-FL-X(L-ROW)
             MOVE SP-FLOWER-Y TO EN-BEE-FL-Y(L-ROW)
             MOVE SP-FLOWER-Z TO EN-BEE-FL-Z(L-ROW)
             MOVE 0 TO EN-BEE-NECTAR(L-ROW) EN-BEE-STUNG(L-ROW)
             IF SP-NECTAR NOT = 0
                 MOVE 1 TO EN-BEE-NECTAR(L-ROW)
             END-IF
             IF SP-STUNG NOT = 0
                 MOVE 1 TO EN-BEE-STUNG(L-ROW)
             END-IF
             MOVE SP-NONECTAR TO EN-BEE-NONECT(L-ROW)
             MOVE SP-CANNOT TO EN-BEE-STAY(L-ROW)
             MOVE SP-CROPS TO EN-BEE-CROPS(L-ROW)
         WHEN L-KEY = "chicken"
             MOVE 0 TO EN-JOCKEY(L-ROW)
             IF SP-JOCKEY NOT = 0
                 MOVE 1 TO EN-JOCKEY(L-ROW)
             END-IF
         WHEN L-KEY = "allay"
             MOVE SP-INV-ITEM TO EN-ALLAY-ITEM(L-ROW)
             MOVE SP-INV-COUNT TO EN-ALLAY-COUNT(L-ROW)
             MOVE SP-DUP TO EN-ALLAY-DUP(L-ROW)
         WHEN L-KEY = "camel"
             MOVE 0 TO EN-CAMEL-POSE(L-ROW)
             IF SP-POSE < 0
                 MOVE 1 TO EN-CAMEL-POSE(L-ROW)
                 COMPUTE EN-CAMEL-POSE-T(L-ROW) = 0 - SP-POSE
             ELSE
                 MOVE SP-POSE TO EN-CAMEL-POSE-T(L-ROW)
             END-IF
         WHEN OTHER
             CONTINUE
     END-EVALUATE
     GOBACK.
 END PROGRAM SPECIES4-NBT-APPLY.
