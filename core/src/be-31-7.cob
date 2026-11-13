*> Block entities, part 7: mob spawner, trial spawner and vault (docs/protocol/31-block-entities-7-spawners-trial-vaults.md; US12 phase 44). The data of the types lives in the BE-XI,
*> BE-XT, BE-XD, BE-SEED, BE-TIME2, BE-UUID and BE-SLOT-COUNT cells of the entity (roles in BESTATE.cpy). The programs are the rules of the sections; what needs the world (players, mobs, rays,
*> loot rolls, the block state, packets) is done by the caller from the results. Not here: the spawning engine itself (44-2), the item spawner entity, the client display, the 28 trial spawner
*> configurations (data; only references are kept, an inline configuration compound is skipped), entity keys of a spawn data other than id (and the equipment table), the custom spawn rules of
*> a potentials entry, item components of the vault stacks, more than 8 potentials entries, 16 detected players or 64 tracked mobs.
*> The trial spawner state (trial_spawner_state, 0 to 5) is kept in BE-STATUS by the caller for the update tag.
*>
*>   BE7-REGISTRATION, BE7-LIGHT, BE7-DEFAULTS, BE7-SAVE, BE7-LOAD-KEY (BEX-DEFAULTS, BEX-SAVE and BEX-LOAD-KEY of be-31-3.cob; BE-TAG-ENTRIES calls the three tag programs)       2
*>   BE7-SP-SAVE, BE7-SP-LOAD, BE7-SPAWNER-TAG, BE7-WEIGHT-TOTAL, BE7-WEIGHT-PICK, BE7-NEARBY, BE7-CUSTOM-RULES, BE7-DELAY, BE7-SPAWN-POS, BE7-BREAK-XP, BE7-SET-ENTITY-ID,
*>        BE7-SPAWNER-EVENT                                                                                                                                              3
*>   BE7-TS-SAVE, BE7-TS-LOAD, BE7-TRIAL-TAG, BE7-TRIAL-TOTALS, BE7-TRIAL-DEFAULT, BE7-UNTRACKED, BE7-PACK-POS, BE7-DETECT-THROTTLE, BE7-DETECT-PLAN, BE7-DETECT-ADDED,
*>        BE7-PLAYER-DETECT, BE7-EJECT-TICK, BE7-EJECT-EVENT, BE7-CAN-SPAWN, BE7-HAS-MOB, BE7-ITEM-SEED                                                                  4
*>   BE7-VAULT-SAVE, BE7-VAULT-LOAD, BE7-VAULT-TAG, BE7-VAULT-CAN-EJECT, BE7-VAULT-SET-DISPLAY, BE7-VAULT-NEXT, BE7-VAULT-PITCH, BE7-VAULT-GATE, BE7-VAULT-DUE, BE7-VAULT-SYNC,
*>        BE7-VAULT-HOOK, BE7-VAULT-KEY, BE7-VAULT-REWARD, BE7-VAULT-CONNECT, BE7-VAULT-RANGE                                                                           5

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BE7-REGISTRATION.
*> USING type, server ticker out, client ticker out (1 and 2 spawner, 3 and 4 trial spawner, 5 and 6 vault, 0 none): 2.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-TYPE                 BINARY-LONG.
 01 L-SERVER               BINARY-LONG.
 01 L-CLIENT               BINARY-LONG.
 PROCEDURE DIVISION USING L-TYPE L-SERVER L-CLIENT.
     MOVE 0 TO L-SERVER L-CLIENT
     EVALUATE L-TYPE
         WHEN 9
             MOVE 1 TO L-SERVER
             MOVE 2 TO L-CLIENT
         WHEN 43
             MOVE 3 TO L-SERVER
             MOVE 4 TO L-CLIENT
         WHEN 44
             MOVE 5 TO L-SERVER
             MOVE 6 TO L-CLIENT
     END-EVALUATE
     GOBACK.
 END PROGRAM BE7-REGISTRATION.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BE7-LIGHT.
*> USING type, state, light level out: the trial spawner 0, 4, 8, 8, 8, 0 and the vault 6 (inactive) or 12 (2).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-TYPE                 BINARY-LONG.
 01 L-STATE                BINARY-LONG.
 01 L-LIGHT                BINARY-LONG.
 PROCEDURE DIVISION USING L-TYPE L-STATE L-LIGHT.
     MOVE 0 TO L-LIGHT
     EVALUATE L-TYPE
         WHEN 43
             EVALUATE L-STATE
                 WHEN 1
                     MOVE 4 TO L-LIGHT
                 WHEN 2 WHEN 3 WHEN 4
                     MOVE 8 TO L-LIGHT
             END-EVALUATE
         WHEN 44
             MOVE 12 TO L-LIGHT
             IF L-STATE = 0
                 MOVE 6 TO L-LIGHT
             END-IF
     END-EVALUATE
     GOBACK.
 END PROGRAM BE7-LIGHT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BE7-SHORT.
*> USING value, value narrowed to a signed short out.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-VALUE                BINARY-LONG.
 01 L-SHORT                BINARY-LONG.
 PROCEDURE DIVISION USING L-VALUE L-SHORT.
     COMPUTE L-SHORT = FUNCTION MOD(L-VALUE + 32768, 65536) - 32768
     GOBACK.
 END PROGRAM BE7-SHORT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BE7-DEFAULTS.
*> USING index: the defaults of a new entity of the types 9, 43 and 44 (3.1, 4.1, 5.2); BEX-DEFAULTS has cleared the cells.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BESTATE.
 LINKAGE SECTION.
 01 L-INDEX                BINARY-LONG.
 PROCEDURE DIVISION USING L-INDEX.
     EVALUATE BE-TYPE(L-INDEX)
         WHEN 9
             MOVE 20 TO BE-XI(L-INDEX, 1)
             MOVE 200 TO BE-XI(L-INDEX, 2)
             MOVE 800 TO BE-XI(L-INDEX, 3)
             MOVE 4 TO BE-XI(L-INDEX, 4)
             MOVE 6 TO BE-XI(L-INDEX, 5)
             MOVE 16 TO BE-XI(L-INDEX, 6)
             MOVE 4 TO BE-XI(L-INDEX, 7)
             MOVE 15 TO BE-XI(L-INDEX, 11) BE-XI(L-INDEX, 13)
             MOVE 0 TO BE-TIME2(L-INDEX)
         WHEN 43
             MOVE 36000 TO BE-XI(L-INDEX, 9)
             MOVE 14 TO BE-XI(L-INDEX, 10)
             MOVE 0 TO BE-TIME2(L-INDEX)
         WHEN 44
             CALL "BE7-VAULT-CONFIG-DEFAULT" USING L-INDEX
             MOVE 0 TO BE-TIME2(L-INDEX)
             MOVE 4.5 TO BE-XD(L-INDEX, 3)
     END-EVALUATE
     GOBACK.
 END PROGRAM BE7-DEFAULTS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BE7-W-LONG.
*> USING PB-BUFFER, key name (X(32)), value (BINARY-DOUBLE): a Long tag named by the trimmed key.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WL                     BINARY-LONG.
 LINKAGE SECTION.
 COPY PROTO.
 01 L-NAME                 PIC X(32).
 01 L-VALUE                BINARY-DOUBLE.
 PROCEDURE DIVISION USING PB-BUFFER L-NAME L-VALUE.
     MOVE FUNCTION LENGTH(FUNCTION TRIM(L-NAME)) TO WL
     CALL "NBT-WRITE-LONG" USING PB-BUFFER L-NAME WL L-VALUE
     GOBACK.
 END PROGRAM BE7-W-LONG.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BE7-W-DOUBLE.
*> USING PB-BUFFER, key name (X(32)), value (FLOAT-LONG): a Double tag.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WL                     BINARY-LONG.
 LINKAGE SECTION.
 COPY PROTO.
 01 L-NAME                 PIC X(32).
 01 L-VALUE                FLOAT-LONG.
 PROCEDURE DIVISION USING PB-BUFFER L-NAME L-VALUE.
     MOVE FUNCTION LENGTH(FUNCTION TRIM(L-NAME)) TO WL
     CALL "NBT-WRITE-DOUBLE" USING PB-BUFFER L-NAME WL L-VALUE
     GOBACK.
 END PROGRAM BE7-W-DOUBLE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BE7-W-SHORT.
*> USING PB-BUFFER, key name (X(32)), value: a Short tag with the value narrowed to a short.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WL                     BINARY-LONG.
 01 WS-SHORT               BINARY-LONG.
 LINKAGE SECTION.
 COPY PROTO.
 01 L-NAME                 PIC X(32).
 01 L-VALUE                BINARY-LONG.
 PROCEDURE DIVISION USING PB-BUFFER L-NAME L-VALUE.
     MOVE FUNCTION LENGTH(FUNCTION TRIM(L-NAME)) TO WL
     CALL "BE7-SHORT" USING L-VALUE WS-SHORT
     CALL "NBT-WRITE-SHORT" USING PB-BUFFER L-NAME WL WS-SHORT
     GOBACK.
 END PROGRAM BE7-W-SHORT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BE7-W-UUIDS.
*> USING PB-BUFFER, key name (X(32)), index, first cell of BE-UUID, number of UUIDs: a list of int arrays of 4 (an empty list has no element type).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BESTATE.
 01 WL                     BINARY-LONG.
 01 WS-T-INTS              BINARY-LONG VALUE 11.
 01 WS-T-NONE              BINARY-LONG VALUE 0.
 01 WS-FOUR                BINARY-LONG VALUE 4.
 01 WS-NONAME              BINARY-LONG VALUE -1.
 01 WS-DUMMY               PIC X.
 01 WS-I                   BINARY-LONG.
 01 WS-CELL                BINARY-LONG.
 LINKAGE SECTION.
 COPY PROTO.
 01 L-NAME                 PIC X(32).
 01 L-INDEX                BINARY-LONG.
 01 L-BASE                 BINARY-LONG.
 01 L-COUNT                BINARY-LONG.
 PROCEDURE DIVISION USING PB-BUFFER L-NAME L-INDEX L-BASE L-COUNT.
     MOVE FUNCTION LENGTH(FUNCTION TRIM(L-NAME)) TO WL
     IF L-COUNT = 0
         CALL "NBT-WRITE-LIST-BEGIN" USING PB-BUFFER L-NAME WL WS-T-NONE L-COUNT
     ELSE
         CALL "NBT-WRITE-LIST-BEGIN" USING PB-BUFFER L-NAME WL WS-T-INTS L-COUNT
     END-IF
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > L-COUNT
         COMPUTE WS-CELL = L-BASE + (WS-I - 1) * 4
         CALL "NBT-WRITE-INT-ARRAY" USING PB-BUFFER WS-DUMMY WS-NONAME WS-FOUR BE-UUID(L-INDEX, WS-CELL)
     END-PERFORM
     GOBACK.
 END PROGRAM BE7-W-UUIDS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BE7-R-UUIDS.
*> USING PB-BUFFER, index, first cell of BE-UUID, capacity in UUIDs, count out: reads a list of int arrays of 4 (the UUIDs beyond the capacity are dropped).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BESTATE.
 01 WS-CAP4                BINARY-LONG VALUE 4.
 01 WS-ETYPE               BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-ICOUNT              BINARY-LONG.
 01 WS-INTS.
    05 WS-INT              BINARY-LONG OCCURS 4 TIMES.
 LINKAGE SECTION.
 COPY PROTO.
 01 L-INDEX                BINARY-LONG.
 01 L-BASE                 BINARY-LONG.
 01 L-CAPACITY             BINARY-LONG.
 01 L-COUNT                BINARY-LONG.
 PROCEDURE DIVISION USING PB-BUFFER L-INDEX L-BASE L-CAPACITY L-COUNT.
     MOVE 0 TO L-COUNT
     CALL "NBT-READ-LIST-BEGIN" USING PB-BUFFER WS-ETYPE WS-N
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-N OR PB-ERROR = 1
         IF WS-ETYPE NOT = 11
             CALL "NBT-READ-SKIP" USING PB-BUFFER WS-ETYPE
         ELSE
             CALL "NBT-READ-INT-ARRAY" USING PB-BUFFER WS-CAP4 WS-ICOUNT WS-INTS
             IF WS-ICOUNT = 4 AND L-COUNT < L-CAPACITY
                 ADD 1 TO L-COUNT
                 PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 4
                     MOVE WS-INT(WS-K) TO BE-UUID(L-INDEX, L-BASE + (L-COUNT - 1) * 4 + WS-K - 1)
                 END-PERFORM
             END-IF
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM BE7-R-UUIDS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BE7-LIMIT-READ.
*> USING PB-BUFFER, minimum out, maximum out: the compound payload of an inclusive int range {min_inclusive, max_inclusive} (defaults 0 and 15).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WN                     PIC X(32).
 01 WL                     BINARY-LONG.
 01 WS-C32                 BINARY-LONG VALUE 32.
 01 WS-TYPE                BINARY-LONG.
 LINKAGE SECTION.
 COPY PROTO.
 01 L-MIN                  BINARY-LONG.
 01 L-MAX                  BINARY-LONG.
 PROCEDURE DIVISION USING PB-BUFFER L-MIN L-MAX.
     MOVE 0 TO L-MIN
     MOVE 15 TO L-MAX
     PERFORM UNTIL PB-ERROR = 1
         MOVE SPACES TO WN
         CALL "NBT-READ-COMPOUND-NEXT" USING PB-BUFFER WS-TYPE WN WS-C32 WL
         IF WS-TYPE = 0
             EXIT PERFORM
         END-IF
         EVALUATE TRUE
             WHEN WN = "min_inclusive" AND WS-TYPE = 3
                 CALL "PB-GET-INT" USING PB-BUFFER L-MIN
             WHEN WN = "max_inclusive" AND WS-TYPE = 3
                 CALL "PB-GET-INT" USING PB-BUFFER L-MAX
             WHEN OTHER
                 CALL "NBT-READ-SKIP" USING PB-BUFFER WS-TYPE
         END-EVALUATE
     END-PERFORM
     GOBACK.
 END PROGRAM BE7-LIMIT-READ.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BE7-SD-READ.
*> USING PB-BUFFER, id out (X(64), canonical), id length out, rules out (4 BINARY-LONG: block light min, max, sky light min, max), rules set out: the compound payload of a spawn data
*> (3.1): entity.id (an invalid id is removed), custom_spawn_rules (dropped when a limit is outside 0 to 15). Other keys of the entity compound are not kept.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WN1                    PIC X(32).
 01 WN2                    PIC X(32).
 01 WL                     BINARY-LONG.
 01 WS-C32                 BINARY-LONG VALUE 32.
 01 WS-C64                 BINARY-LONG VALUE 64.
 01 WS-T1                  BINARY-LONG.
 01 WS-T2                  BINARY-LONG.
 01 WS-VALID               BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-MIN                 BINARY-LONG.
 01 WS-MAX                 BINARY-LONG.
 LINKAGE SECTION.
 COPY PROTO.
 01 L-ID                   PIC X(64).
 01 L-ID-LENGTH            BINARY-LONG.
 01 L-RULES.
    05 L-R                 BINARY-LONG OCCURS 4 TIMES.
 01 L-RSET                 BINARY-LONG.
 PROCEDURE DIVISION USING PB-BUFFER L-ID L-ID-LENGTH L-RULES L-RSET.
     MOVE SPACES TO L-ID
     MOVE 0 TO L-ID-LENGTH L-RSET
     MOVE 0 TO L-R(1) L-R(3)
     MOVE 15 TO L-R(2) L-R(4)
     PERFORM UNTIL PB-ERROR = 1
         MOVE SPACES TO WN1
         CALL "NBT-READ-COMPOUND-NEXT" USING PB-BUFFER WS-T1 WN1 WS-C32 WL
         IF WS-T1 = 0
             EXIT PERFORM
         END-IF
         EVALUATE TRUE
             WHEN WN1 = "entity" AND WS-T1 = 10
                 PERFORM UNTIL PB-ERROR = 1
                     MOVE SPACES TO WN2
                     CALL "NBT-READ-COMPOUND-NEXT" USING PB-BUFFER WS-T2 WN2 WS-C32 WL
                     IF WS-T2 = 0
                         EXIT PERFORM
                     END-IF
                     IF WN2 = "id" AND WS-T2 = 8
                         CALL "BE6-READ-TEXT" USING PB-BUFFER L-ID WS-C64 L-ID-LENGTH
                         CALL "BE6-IDENT-NORM" USING L-ID L-ID-LENGTH WS-VALID
                         IF WS-VALID = 0
                             MOVE SPACES TO L-ID
                             MOVE 0 TO L-ID-LENGTH
                         END-IF
                     ELSE
                         CALL "NBT-READ-SKIP" USING PB-BUFFER WS-T2
                     END-IF
                 END-PERFORM
             WHEN WN1 = "custom_spawn_rules" AND WS-T1 = 10
                 MOVE 1 TO L-RSET
                 PERFORM UNTIL PB-ERROR = 1
                     MOVE SPACES TO WN2
                     CALL "NBT-READ-COMPOUND-NEXT" USING PB-BUFFER WS-T2 WN2 WS-C32 WL
                     IF WS-T2 = 0
                         EXIT PERFORM
                     END-IF
                     EVALUATE TRUE
                         WHEN WN2 = "block_light_limit" AND WS-T2 = 10
                             CALL "BE7-LIMIT-READ" USING PB-BUFFER WS-MIN WS-MAX
                             MOVE WS-MIN TO L-R(1)
                             MOVE WS-MAX TO L-R(2)
                         WHEN WN2 = "sky_light_limit" AND WS-T2 = 10
                             CALL "BE7-LIMIT-READ" USING PB-BUFFER WS-MIN WS-MAX
                             MOVE WS-MIN TO L-R(3)
                             MOVE WS-MAX TO L-R(4)
                         WHEN OTHER
                             CALL "NBT-READ-SKIP" USING PB-BUFFER WS-T2
                     END-EVALUATE
                 END-PERFORM
                 PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 4
                     IF L-R(WS-I) < 0 OR L-R(WS-I) > 15
                         MOVE 0 TO L-RSET
                     END-IF
                 END-PERFORM
                 IF L-RSET = 0
                     MOVE 0 TO L-R(1) L-R(3)
                     MOVE 15 TO L-R(2) L-R(4)
                 END-IF
             WHEN OTHER
                 CALL "NBT-READ-SKIP" USING PB-BUFFER WS-T1
         END-EVALUATE
     END-PERFORM
     GOBACK.
 END PROGRAM BE7-SD-READ.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BE7-SD-WRITE.
*> USING PB-BUFFER, id (X(64)), id length, rules (4 BINARY-LONG), rules set: the entries of a spawn data compound (the caller opens and closes it): entity {id}, custom_spawn_rules.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WN                     PIC X(32).
 01 WL                     BINARY-LONG.
 LINKAGE SECTION.
 COPY PROTO.
 01 L-ID                   PIC X(64).
 01 L-ID-LENGTH            BINARY-LONG.
 01 L-RULES.
    05 L-R                 BINARY-LONG OCCURS 4 TIMES.
 01 L-RSET                 BINARY-LONG.
 PROCEDURE DIVISION USING PB-BUFFER L-ID L-ID-LENGTH L-RULES L-RSET.
     MOVE "entity" TO WN
     MOVE 6 TO WL
     CALL "NBT-WRITE-COMPOUND-BEGIN" USING PB-BUFFER WN WL
     IF L-ID-LENGTH > 0
         MOVE "id" TO WN
         CALL "BE6-W-STR" USING PB-BUFFER WN L-ID L-ID-LENGTH
     END-IF
     CALL "NBT-WRITE-COMPOUND-END" USING PB-BUFFER
     IF L-RSET = 1
         MOVE "custom_spawn_rules" TO WN
         MOVE 18 TO WL
         CALL "NBT-WRITE-COMPOUND-BEGIN" USING PB-BUFFER WN WL
         MOVE "block_light_limit" TO WN
         MOVE 17 TO WL
         CALL "NBT-WRITE-COMPOUND-BEGIN" USING PB-BUFFER WN WL
         MOVE "min_inclusive" TO WN
         CALL "BE6-W-INT" USING PB-BUFFER WN L-R(1)
         MOVE "max_inclusive" TO WN
         CALL "BE6-W-INT" USING PB-BUFFER WN L-R(2)
         CALL "NBT-WRITE-COMPOUND-END" USING PB-BUFFER
         MOVE "sky_light_limit" TO WN
         MOVE 15 TO WL
         CALL "NBT-WRITE-COMPOUND-BEGIN" USING PB-BUFFER WN WL
         MOVE "min_inclusive" TO WN
         CALL "BE6-W-INT" USING PB-BUFFER WN L-R(3)
         MOVE "max_inclusive" TO WN
         CALL "BE6-W-INT" USING PB-BUFFER WN L-R(4)
         CALL "NBT-WRITE-COMPOUND-END" USING PB-BUFFER
         CALL "NBT-WRITE-COMPOUND-END" USING PB-BUFFER
     END-IF
     GOBACK.
 END PROGRAM BE7-SD-WRITE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BE7-SP-SAVE.
*> USING index, PB-BUFFER, with potentials (1 for the saved form, 0 for the update tag): 3.1 in write order.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BESTATE.
 01 WN                     PIC X(32).
 01 WL                     BINARY-LONG.
 01 WS-T-COMPOUND          BINARY-LONG VALUE 10.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-I                   BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-RULES.
    05 WS-R                BINARY-LONG OCCURS 4 TIMES.
 01 WS-EMPTY               PIC X(64).
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-ZERO2               BINARY-LONG VALUE 0.
 01 WS-IDLEN               BINARY-LONG.
 01 WS-RSET                BINARY-LONG.
 LINKAGE SECTION.
 COPY PROTO.
 01 L-INDEX                BINARY-LONG.
 01 L-POTENTIALS           BINARY-LONG.
 PROCEDURE DIVISION USING L-INDEX PB-BUFFER L-POTENTIALS.
     MOVE "Delay" TO WN
     CALL "BE7-W-SHORT" USING PB-BUFFER WN BE-XI(L-INDEX, 1)
     MOVE "MinSpawnDelay" TO WN
     CALL "BE7-W-SHORT" USING PB-BUFFER WN BE-XI(L-INDEX, 2)
     MOVE "MaxSpawnDelay" TO WN
     CALL "BE7-W-SHORT" USING PB-BUFFER WN BE-XI(L-INDEX, 3)
     MOVE "SpawnCount" TO WN
     CALL "BE7-W-SHORT" USING PB-BUFFER WN BE-XI(L-INDEX, 4)
     MOVE "MaxNearbyEntities" TO WN
     CALL "BE7-W-SHORT" USING PB-BUFFER WN BE-XI(L-INDEX, 5)
     MOVE "RequiredPlayerRange" TO WN
     CALL "BE7-W-SHORT" USING PB-BUFFER WN BE-XI(L-INDEX, 6)
     MOVE "SpawnRange" TO WN
     CALL "BE7-W-SHORT" USING PB-BUFFER WN BE-XI(L-INDEX, 7)
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 4
         MOVE BE-XI(L-INDEX, 9 + WS-I) TO WS-R(WS-I)
     END-PERFORM
     MOVE BE-XI(L-INDEX, 9) TO WS-IDLEN
     MOVE BE-XI(L-INDEX, 14) TO WS-RSET
     IF BE-XI(L-INDEX, 8) = 1
         MOVE "SpawnData" TO WN
         MOVE 9 TO WL
         CALL "NBT-WRITE-COMPOUND-BEGIN" USING PB-BUFFER WN WL
         CALL "BE7-SD-WRITE" USING PB-BUFFER BE-XT(L-INDEX, 1) WS-IDLEN WS-RULES WS-RSET
         CALL "NBT-WRITE-COMPOUND-END" USING PB-BUFFER
     END-IF
     IF L-POTENTIALS = 1
         MOVE "SpawnPotentials" TO WN
         MOVE 15 TO WL
         MOVE BE-XI(L-INDEX, 15) TO WS-COUNT
         IF WS-COUNT = 0
             MOVE 1 TO WS-COUNT
         END-IF
         CALL "NBT-WRITE-LIST-BEGIN" USING PB-BUFFER WN WL WS-T-COMPOUND WS-COUNT
         IF BE-XI(L-INDEX, 15) = 0
             MOVE "data" TO WN
             MOVE 4 TO WL
             CALL "NBT-WRITE-COMPOUND-BEGIN" USING PB-BUFFER WN WL
             MOVE SPACES TO WS-EMPTY
             IF BE-XI(L-INDEX, 8) = 1
                 CALL "BE7-SD-WRITE" USING PB-BUFFER BE-XT(L-INDEX, 1) WS-IDLEN WS-RULES WS-RSET
             ELSE
                 CALL "BE7-SD-WRITE" USING PB-BUFFER WS-EMPTY WS-ZERO WS-RULES WS-ZERO2
             END-IF
             CALL "NBT-WRITE-COMPOUND-END" USING PB-BUFFER
             MOVE "weight" TO WN
             CALL "BE6-W-INT" USING PB-BUFFER WN WS-ONE
             CALL "NBT-WRITE-COMPOUND-END" USING PB-BUFFER
         ELSE
             PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-COUNT
                 MOVE "data" TO WN
                 MOVE 4 TO WL
                 CALL "NBT-WRITE-COMPOUND-BEGIN" USING PB-BUFFER WN WL
                 MOVE 0 TO WS-R(1) WS-R(3)
                 MOVE 15 TO WS-R(2) WS-R(4)
                 CALL "BE7-SD-WRITE" USING PB-BUFFER BE-XT(L-INDEX, 1 + WS-I) BE-XI(L-INDEX, 19 + WS-I) WS-RULES WS-ZERO2
                 CALL "NBT-WRITE-COMPOUND-END" USING PB-BUFFER
                 MOVE "weight" TO WN
                 CALL "BE6-W-INT" USING PB-BUFFER WN BE-XI(L-INDEX, 29 + WS-I)
                 CALL "NBT-WRITE-COMPOUND-END" USING PB-BUFFER
             END-PERFORM
         END-IF
     END-IF
     GOBACK.
 END PROGRAM BE7-SP-SAVE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BE7-SPAWNER-TAG.
*> USING index, PB-BUFFER: the update tag entries of 3.2, the saved keys without SpawnPotentials.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-NONE                BINARY-LONG VALUE 0.
 LINKAGE SECTION.
 COPY PROTO.
 01 L-INDEX                BINARY-LONG.
 PROCEDURE DIVISION USING L-INDEX PB-BUFFER.
     CALL "BE7-SP-SAVE" USING L-INDEX PB-BUFFER WS-NONE
     GOBACK.
 END PROGRAM BE7-SPAWNER-TAG.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BE7-SP-LOAD.
*> USING index, key name (X(32)), tag, PB-BUFFER, handled out: 3.1. The six numbers read from a short or an int, Delay only from a short; a potentials list with an entry that has no data,
*> no weight or a negative weight fails as a whole (the default list); more than 8 entries keep the first 8.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BESTATE.
 01 WS-KEYS.
    05 FILLER              PIC X(19) VALUE "MinSpawnDelay".
    05 FILLER              PIC X(19) VALUE "MaxSpawnDelay".
    05 FILLER              PIC X(19) VALUE "SpawnCount".
    05 FILLER              PIC X(19) VALUE "MaxNearbyEntities".
    05 FILLER              PIC X(19) VALUE "RequiredPlayerRange".
    05 FILLER              PIC X(19) VALUE "SpawnRange".
 01 FILLER REDEFINES WS-KEYS.
    05 WS-KEY              PIC X(19) OCCURS 6 TIMES.
 01 WN                     PIC X(32).
 01 WL                     BINARY-LONG.
 01 WS-C32                 BINARY-LONG VALUE 32.
 01 WS-I                   BINARY-LONG.
 01 WS-ETYPE               BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-E                   BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-FAILED              BINARY-LONG.
 01 WS-HAS-DATA            BINARY-LONG.
 01 WS-HAS-WEIGHT          BINARY-LONG.
 01 WS-WEIGHT              BINARY-LONG.
 01 WS-ID                  PIC X(64).
 01 WS-ID-LENGTH           BINARY-LONG.
 01 WS-RULES.
    05 WS-R                BINARY-LONG OCCURS 4 TIMES.
 01 WS-RSET                BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-TEMP.
    05 WS-T-ENTRY OCCURS 8 TIMES.
       10 WS-T-ID          PIC X(64).
       10 WS-T-LENGTH      BINARY-LONG.
       10 WS-T-WEIGHT      BINARY-LONG.
 LINKAGE SECTION.
 COPY PROTO.
 01 L-INDEX                BINARY-LONG.
 01 L-NAME                 PIC X(32).
 01 L-TAG                  BINARY-LONG.
 01 L-HANDLED              BINARY-LONG.
 PROCEDURE DIVISION USING L-INDEX L-NAME L-TAG PB-BUFFER L-HANDLED.
     MOVE 0 TO L-HANDLED
     IF L-NAME = "Delay" AND L-TAG = 2
         MOVE 1 TO L-HANDLED
         CALL "PB-GET-SHORT" USING PB-BUFFER BE-XI(L-INDEX, 1)
     END-IF
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 6
         IF L-NAME = WS-KEY(WS-I) AND L-TAG = 2
             MOVE 1 TO L-HANDLED
             CALL "PB-GET-SHORT" USING PB-BUFFER BE-XI(L-INDEX, WS-I + 1)
         END-IF
         IF L-NAME = WS-KEY(WS-I) AND L-TAG = 3
             MOVE 1 TO L-HANDLED
             CALL "PB-GET-INT" USING PB-BUFFER BE-XI(L-INDEX, WS-I + 1)
         END-IF
     END-PERFORM
     IF L-NAME = "SpawnData" AND L-TAG = 10
         MOVE 1 TO L-HANDLED
         CALL "BE7-SD-READ" USING PB-BUFFER BE-XT(L-INDEX, 1) BE-XI(L-INDEX, 9) WS-RULES WS-RSET
         MOVE 1 TO BE-XI(L-INDEX, 8)
         MOVE WS-RSET TO BE-XI(L-INDEX, 14)
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 4
             MOVE WS-R(WS-I) TO BE-XI(L-INDEX, 9 + WS-I)
         END-PERFORM
     END-IF
     IF L-NAME = "SpawnPotentials" AND L-TAG = 9
         MOVE 1 TO L-HANDLED
         MOVE 0 TO WS-FAILED WS-N
         CALL "NBT-READ-LIST-BEGIN" USING PB-BUFFER WS-ETYPE WS-COUNT
         PERFORM VARYING WS-E FROM 1 BY 1 UNTIL WS-E > WS-COUNT OR PB-ERROR = 1
             IF WS-ETYPE NOT = 10
                 CALL "NBT-READ-SKIP" USING PB-BUFFER WS-ETYPE
                 MOVE 1 TO WS-FAILED
             ELSE
                 MOVE 0 TO WS-HAS-DATA WS-HAS-WEIGHT
                 MOVE 0 TO WS-WEIGHT
                 MOVE SPACES TO WS-ID
                 MOVE 0 TO WS-ID-LENGTH
                 PERFORM UNTIL PB-ERROR = 1
                     MOVE SPACES TO WN
                     CALL "NBT-READ-COMPOUND-NEXT" USING PB-BUFFER WS-TYPE WN WS-C32 WL
                     IF WS-TYPE = 0
                         EXIT PERFORM
                     END-IF
                     EVALUATE TRUE
                         WHEN WN = "data" AND WS-TYPE = 10
                             MOVE 1 TO WS-HAS-DATA
                             CALL "BE7-SD-READ" USING PB-BUFFER WS-ID WS-ID-LENGTH WS-RULES WS-RSET
                         WHEN WN = "weight" AND WS-TYPE = 3
                             MOVE 1 TO WS-HAS-WEIGHT
                             CALL "PB-GET-INT" USING PB-BUFFER WS-WEIGHT
                         WHEN OTHER
                             CALL "NBT-READ-SKIP" USING PB-BUFFER WS-TYPE
                     END-EVALUATE
                 END-PERFORM
                 IF WS-HAS-DATA = 0 OR WS-HAS-WEIGHT = 0 OR WS-WEIGHT < 0
                     MOVE 1 TO WS-FAILED
                 END-IF
                 IF WS-N < 8
                     ADD 1 TO WS-N
                     MOVE WS-ID TO WS-T-ID(WS-N)
                     MOVE WS-ID-LENGTH TO WS-T-LENGTH(WS-N)
                     MOVE WS-WEIGHT TO WS-T-WEIGHT(WS-N)
                 END-IF
             END-IF
         END-PERFORM
         MOVE 0 TO BE-XI(L-INDEX, 15)
         IF WS-FAILED = 0
             MOVE WS-N TO BE-XI(L-INDEX, 15)
             PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-N
                 MOVE WS-T-ID(WS-I) TO BE-XT(L-INDEX, 1 + WS-I)
                 MOVE WS-T-LENGTH(WS-I) TO BE-XI(L-INDEX, 19 + WS-I)
                 MOVE WS-T-WEIGHT(WS-I) TO BE-XI(L-INDEX, 29 + WS-I)
             END-PERFORM
         END-IF
     END-IF
     GOBACK.
 END PROGRAM BE7-SP-LOAD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BE7-WEIGHT-TOTAL.
*> USING weights (BINARY-LONG table), count, total out: the sum of 3.1.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-I                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-WEIGHTS.
    05 L-W                 BINARY-LONG OCCURS 64 TIMES.
 01 L-COUNT                BINARY-LONG.
 01 L-TOTAL                BINARY-LONG.
 PROCEDURE DIVISION USING L-WEIGHTS L-COUNT L-TOTAL.
     MOVE 0 TO L-TOTAL
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > L-COUNT
         ADD L-W(WS-I) TO L-TOTAL
     END-PERFORM
     GOBACK.
 END PROGRAM BE7-WEIGHT-TOTAL.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BE7-WEIGHT-PICK.
*> USING weights, count, draw (nextInt(total), made by the caller only when the total is above 0), entry out (1 based, 0 none): WeightedList.getRandom of 3.1.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-I                   BINARY-LONG.
 01 WS-R                   BINARY-LONG.
 01 WS-TOTAL               BINARY-LONG.
 LINKAGE SECTION.
 01 L-WEIGHTS.
    05 L-W                 BINARY-LONG OCCURS 64 TIMES.
 01 L-COUNT                BINARY-LONG.
 01 L-DRAW                 BINARY-LONG.
 01 L-ENTRY                BINARY-LONG.
 PROCEDURE DIVISION USING L-WEIGHTS L-COUNT L-DRAW L-ENTRY.
     MOVE 0 TO L-ENTRY
     CALL "BE7-WEIGHT-TOTAL" USING L-WEIGHTS L-COUNT WS-TOTAL
     IF WS-TOTAL > 0
         MOVE L-DRAW TO WS-R
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > L-COUNT
             SUBTRACT L-W(WS-I) FROM WS-R
             IF WS-R < 0 AND L-ENTRY = 0
                 MOVE WS-I TO L-ENTRY
             END-IF
         END-PERFORM
     END-IF
     GOBACK.
 END PROGRAM BE7-WEIGHT-PICK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BE7-NEARBY.
*> USING squared distance, range, result out: Level.hasNearbyAlivePlayer of 3.4 item 1 (a negative range accepts any player).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-DISTANCE             BINARY-LONG.
 01 L-RANGE                BINARY-LONG.
 01 L-RESULT               BINARY-LONG.
 PROCEDURE DIVISION USING L-DISTANCE L-RANGE L-RESULT.
     MOVE 0 TO L-RESULT
     IF L-RANGE < 0 OR L-DISTANCE < L-RANGE * L-RANGE
         MOVE 1 TO L-RESULT
     END-IF
     GOBACK.
 END PROGRAM BE7-NEARBY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BE7-CUSTOM-RULES.
*> USING index, block light, sky light, mob category is friendly, difficulty is Peaceful, ok out: the custom spawn rule test of 3.4 item 2.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BESTATE.
 LINKAGE SECTION.
 01 L-INDEX                BINARY-LONG.
 01 L-BLOCK                BINARY-LONG.
 01 L-SKY                  BINARY-LONG.
 01 L-FRIENDLY             BINARY-LONG.
 01 L-PEACEFUL             BINARY-LONG.
 01 L-OK                   BINARY-LONG.
 PROCEDURE DIVISION USING L-INDEX L-BLOCK L-SKY L-FRIENDLY L-PEACEFUL L-OK.
     MOVE 0 TO L-OK
     IF L-BLOCK >= BE-XI(L-INDEX, 10) AND L-BLOCK <= BE-XI(L-INDEX, 11) AND L-SKY >= BE-XI(L-INDEX, 12) AND L-SKY <= BE-XI(L-INDEX, 13)
             AND (L-FRIENDLY = 1 OR L-PEACEFUL = 0)
         MOVE 1 TO L-OK
     END-IF
     GOBACK.
 END PROGRAM BE7-CUSTOM-RULES.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BE7-DELAY.
*> USING MinSpawnDelay, MaxSpawnDelay, draw (nextInt(max - min), only used when max is above min), delay out: 7.2.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-MIN                  BINARY-LONG.
 01 L-MAX                  BINARY-LONG.
 01 L-DRAW                 BINARY-LONG.
 01 L-DELAY                BINARY-LONG.
 PROCEDURE DIVISION USING L-MIN L-MAX L-DRAW L-DELAY.
     MOVE L-MIN TO L-DELAY
     IF L-MAX > L-MIN
         ADD L-DRAW TO L-DELAY
     END-IF
     GOBACK.
 END PROGRAM BE7-DELAY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BE7-SPAWN-POS.
*> USING index, the two doubles of x, the nextInt(3) draw, the two doubles of z, x, y, z out (FLOAT-LONG), box out (6 BINARY-LONG: min x, y, z, max x, y, z of the count box): 7.1.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BESTATE.
 LINKAGE SECTION.
 01 L-INDEX                BINARY-LONG.
 01 L-D1                   FLOAT-LONG.
 01 L-D2                   FLOAT-LONG.
 01 L-DY                   BINARY-LONG.
 01 L-D4                   FLOAT-LONG.
 01 L-D5                   FLOAT-LONG.
 01 L-X                    FLOAT-LONG.
 01 L-Y                    FLOAT-LONG.
 01 L-Z                    FLOAT-LONG.
 01 L-BOX.
    05 L-B                 BINARY-LONG OCCURS 6 TIMES.
 PROCEDURE DIVISION USING L-INDEX L-D1 L-D2 L-DY L-D4 L-D5 L-X L-Y L-Z L-BOX.
     COMPUTE L-X = BE-X(L-INDEX) + (L-D1 - L-D2) * BE-XI(L-INDEX, 7) + 0.5
     COMPUTE L-Y = BE-Y(L-INDEX) + L-DY - 1
     COMPUTE L-Z = BE-Z(L-INDEX) + (L-D4 - L-D5) * BE-XI(L-INDEX, 7) + 0.5
     COMPUTE L-B(1) = BE-X(L-INDEX) - BE-XI(L-INDEX, 7)
     COMPUTE L-B(2) = BE-Y(L-INDEX) - BE-XI(L-INDEX, 7)
     COMPUTE L-B(3) = BE-Z(L-INDEX) - BE-XI(L-INDEX, 7)
     COMPUTE L-B(4) = BE-X(L-INDEX) + 1 + BE-XI(L-INDEX, 7)
     COMPUTE L-B(5) = BE-Y(L-INDEX) + 1 + BE-XI(L-INDEX, 7)
     COMPUTE L-B(6) = BE-Z(L-INDEX) + 1 + BE-XI(L-INDEX, 7)
     GOBACK.
 END PROGRAM BE7-SPAWN-POS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BE7-BREAK-XP.
*> USING the two nextInt(15) draws, experience out: SpawnerBlock.spawnAfterBreak of 3.5.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-D1                   BINARY-LONG.
 01 L-D2                   BINARY-LONG.
 01 L-XP                   BINARY-LONG.
 PROCEDURE DIVISION USING L-D1 L-D2 L-XP.
     COMPUTE L-XP = 15 + L-D1 + L-D2
     GOBACK.
 END PROGRAM BE7-BREAK-XP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BE7-SET-ENTITY-ID.
*> USING index, entity id (X(64)), length: setEntityId of 3.3, only the id of the current spawn data changes (one is created when there is none).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BESTATE.
 01 WS-VALID               BINARY-LONG.
 LINKAGE SECTION.
 01 L-INDEX                BINARY-LONG.
 01 L-ID                   PIC X(64).
 01 L-LENGTH               BINARY-LONG.
 PROCEDURE DIVISION USING L-INDEX L-ID L-LENGTH.
     MOVE L-ID TO BE-XT(L-INDEX, 1)
     MOVE L-LENGTH TO BE-XI(L-INDEX, 9)
     CALL "BE6-IDENT-NORM" USING BE-XT(L-INDEX, 1) BE-XI(L-INDEX, 9) WS-VALID
     IF WS-VALID = 0
         MOVE SPACES TO BE-XT(L-INDEX, 1)
         MOVE 0 TO BE-XI(L-INDEX, 9)
     END-IF
     MOVE 1 TO BE-XI(L-INDEX, 8)
     GOBACK.
 END PROGRAM BE7-SET-ENTITY-ID.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BE7-SPAWNER-EVENT.
*> USING index, event id, side (0 server, 1 client), handled out: SpawnerBlockEntity.triggerEvent of 3.2 (id 1; the client delay becomes MinSpawnDelay).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BESTATE.
 LINKAGE SECTION.
 01 L-INDEX                BINARY-LONG.
 01 L-EVENT                BINARY-LONG.
 01 L-SIDE                 BINARY-LONG.
 01 L-HANDLED              BINARY-LONG.
 PROCEDURE DIVISION USING L-INDEX L-EVENT L-SIDE L-HANDLED.
     MOVE 0 TO L-HANDLED
     IF L-EVENT = 1
         MOVE 1 TO L-HANDLED
         IF L-SIDE = 1
             MOVE BE-XI(L-INDEX, 2) TO BE-XI(L-INDEX, 1)
         END-IF
     END-IF
     GOBACK.
 END PROGRAM BE7-SPAWNER-EVENT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BE7-TS-SAVE.
*> USING index, PB-BUFFER: 4.1, the state data keys then the configuration keys.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BESTATE.
 01 WN                     PIC X(32).
 01 WL                     BINARY-LONG.
 01 WS-LONG                BINARY-DOUBLE.
 01 WS-RULES.
    05 WS-R                BINARY-LONG OCCURS 4 TIMES.
 01 WS-I                   BINARY-LONG.
 01 WS-IDLEN               BINARY-LONG.
 01 WS-RSET                BINARY-LONG.
 LINKAGE SECTION.
 COPY PROTO.
 01 L-INDEX                BINARY-LONG.
 PROCEDURE DIVISION USING L-INDEX PB-BUFFER.
     MOVE "registered_players" TO WN
     CALL "BE7-W-UUIDS" USING PB-BUFFER WN L-INDEX 1 BE-XI(L-INDEX, 1)
     MOVE "current_mobs" TO WN
     CALL "BE7-W-UUIDS" USING PB-BUFFER WN L-INDEX 65 BE-XI(L-INDEX, 2)
     MOVE "cooldown_ends_at" TO WN
     MOVE BE-SEED(L-INDEX) TO WS-LONG
     CALL "BE7-W-LONG" USING PB-BUFFER WN WS-LONG
     MOVE "next_mob_spawns_at" TO WN
     MOVE BE-TIME2(L-INDEX) TO WS-LONG
     CALL "BE7-W-LONG" USING PB-BUFFER WN WS-LONG
     MOVE "total_mobs_spawned" TO WN
     CALL "BE6-W-INT" USING PB-BUFFER WN BE-XI(L-INDEX, 3)
     IF BE-XI(L-INDEX, 4) = 1
         MOVE "spawn_data" TO WN
         MOVE 10 TO WL
         CALL "NBT-WRITE-COMPOUND-BEGIN" USING PB-BUFFER WN WL
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 4
             MOVE BE-XI(L-INDEX, 11 + WS-I) TO WS-R(WS-I)
         END-PERFORM
         MOVE BE-XI(L-INDEX, 5) TO WS-IDLEN
         MOVE BE-XI(L-INDEX, 16) TO WS-RSET
         CALL "BE7-SD-WRITE" USING PB-BUFFER BE-XT(L-INDEX, 1) WS-IDLEN WS-RULES WS-RSET
         CALL "NBT-WRITE-COMPOUND-END" USING PB-BUFFER
     END-IF
     IF BE-XI(L-INDEX, 6) > 0
         MOVE "ejecting_loot_table" TO WN
         CALL "BE6-W-STR" USING PB-BUFFER WN BE-XT(L-INDEX, 2) BE-XI(L-INDEX, 6)
     END-IF
     IF BE-XI(L-INDEX, 7) > 0
         MOVE "normal_config" TO WN
         CALL "BE6-W-STR" USING PB-BUFFER WN BE-XT(L-INDEX, 3) BE-XI(L-INDEX, 7)
     END-IF
     IF BE-XI(L-INDEX, 8) > 0
         MOVE "ominous_config" TO WN
         CALL "BE6-W-STR" USING PB-BUFFER WN BE-XT(L-INDEX, 4) BE-XI(L-INDEX, 8)
     END-IF
     MOVE "target_cooldown_length" TO WN
     CALL "BE6-W-INT" USING PB-BUFFER WN BE-XI(L-INDEX, 9)
     MOVE "required_player_range" TO WN
     CALL "BE6-W-INT" USING PB-BUFFER WN BE-XI(L-INDEX, 10)
     GOBACK.
 END PROGRAM BE7-TS-SAVE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BE7-TRIAL-TAG.
*> USING index, PB-BUFFER: the update tag of 4.5 for the state held in BE-STATUS (2 is active).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BESTATE.
 01 WN                     PIC X(32).
 01 WL                     BINARY-LONG.
 01 WS-LONG                BINARY-DOUBLE.
 01 WS-RULES.
    05 WS-R                BINARY-LONG OCCURS 4 TIMES.
 01 WS-I                   BINARY-LONG.
 01 WS-IDLEN               BINARY-LONG.
 01 WS-RSET                BINARY-LONG.
 LINKAGE SECTION.
 COPY PROTO.
 01 L-INDEX                BINARY-LONG.
 PROCEDURE DIVISION USING L-INDEX PB-BUFFER.
     IF BE-STATUS(L-INDEX) = 2
         MOVE "next_mob_spawns_at" TO WN
         MOVE BE-TIME2(L-INDEX) TO WS-LONG
         CALL "BE7-W-LONG" USING PB-BUFFER WN WS-LONG
     END-IF
     IF BE-XI(L-INDEX, 4) = 1
         MOVE "spawn_data" TO WN
         MOVE 10 TO WL
         CALL "NBT-WRITE-COMPOUND-BEGIN" USING PB-BUFFER WN WL
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 4
             MOVE BE-XI(L-INDEX, 11 + WS-I) TO WS-R(WS-I)
         END-PERFORM
         MOVE BE-XI(L-INDEX, 5) TO WS-IDLEN
         MOVE BE-XI(L-INDEX, 16) TO WS-RSET
         CALL "BE7-SD-WRITE" USING PB-BUFFER BE-XT(L-INDEX, 1) WS-IDLEN WS-RULES WS-RSET
         CALL "NBT-WRITE-COMPOUND-END" USING PB-BUFFER
     END-IF
     GOBACK.
 END PROGRAM BE7-TRIAL-TAG.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BE7-TS-LOAD.
*> USING index, key name (X(32)), tag, PB-BUFFER, handled out: 4.1. BE-LOAD has reset every cell, so a tag lacking keys gives the defaults (applying a packed value overwrites every field). The
*> four configuration keys are read all or nothing: a key that is present and out of range or of the wrong tag type makes the whole configuration the default.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BESTATE.
 01 WS-C64                 BINARY-LONG VALUE 64.
 01 WS-VALUE               BINARY-LONG.
 01 WS-RULES.
    05 WS-R                BINARY-LONG OCCURS 4 TIMES.
 01 WS-RSET                BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-FAIL                BINARY-LONG.
 LINKAGE SECTION.
 COPY PROTO.
 01 L-INDEX                BINARY-LONG.
 01 L-NAME                 PIC X(32).
 01 L-TAG                  BINARY-LONG.
 01 L-HANDLED              BINARY-LONG.
 PROCEDURE DIVISION USING L-INDEX L-NAME L-TAG PB-BUFFER L-HANDLED.
     MOVE 0 TO L-HANDLED WS-FAIL
     IF L-NAME = "registered_players" AND L-TAG = 9
         MOVE 1 TO L-HANDLED
         CALL "BE7-R-UUIDS" USING PB-BUFFER L-INDEX 1 16 BE-XI(L-INDEX, 1)
     END-IF
     IF L-NAME = "current_mobs" AND L-TAG = 9
         MOVE 1 TO L-HANDLED
         CALL "BE7-R-UUIDS" USING PB-BUFFER L-INDEX 65 64 BE-XI(L-INDEX, 2)
     END-IF
     IF L-NAME = "cooldown_ends_at" AND L-TAG = 4
         MOVE 1 TO L-HANDLED
         CALL "PB-GET-LONG" USING PB-BUFFER BE-SEED(L-INDEX)
     END-IF
     IF L-NAME = "next_mob_spawns_at" AND L-TAG = 4
         MOVE 1 TO L-HANDLED
         CALL "PB-GET-LONG" USING PB-BUFFER BE-TIME2(L-INDEX)
     END-IF
     IF L-NAME = "total_mobs_spawned" AND L-TAG = 3
         MOVE 1 TO L-HANDLED
         CALL "PB-GET-INT" USING PB-BUFFER WS-VALUE
         IF WS-VALUE >= 0
             MOVE WS-VALUE TO BE-XI(L-INDEX, 3)
         END-IF
     END-IF
     IF L-NAME = "spawn_data" AND L-TAG = 10
         MOVE 1 TO L-HANDLED
         CALL "BE7-SD-READ" USING PB-BUFFER BE-XT(L-INDEX, 1) BE-XI(L-INDEX, 5) WS-RULES WS-RSET
         MOVE 1 TO BE-XI(L-INDEX, 4)
         MOVE WS-RSET TO BE-XI(L-INDEX, 16)
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 4
             MOVE WS-R(WS-I) TO BE-XI(L-INDEX, 11 + WS-I)
         END-PERFORM
     END-IF
     IF L-NAME = "ejecting_loot_table" AND L-TAG = 8
         MOVE 1 TO L-HANDLED
         CALL "BE6-READ-TEXT" USING PB-BUFFER BE-XT(L-INDEX, 2) WS-C64 BE-XI(L-INDEX, 6)
     END-IF
     IF L-NAME = "normal_config" OR L-NAME = "ominous_config"
         MOVE 1 TO L-HANDLED
         EVALUATE TRUE
             WHEN L-TAG = 8 AND BE-XI(L-INDEX, 11) = 0 AND L-NAME = "normal_config"
                 CALL "BE6-READ-TEXT" USING PB-BUFFER BE-XT(L-INDEX, 3) WS-C64 BE-XI(L-INDEX, 7)
             WHEN L-TAG = 8 AND BE-XI(L-INDEX, 11) = 0
                 CALL "BE6-READ-TEXT" USING PB-BUFFER BE-XT(L-INDEX, 4) WS-C64 BE-XI(L-INDEX, 8)
             WHEN L-TAG = 8 OR L-TAG = 10
                 CALL "NBT-READ-SKIP" USING PB-BUFFER L-TAG
             WHEN OTHER
                 CALL "NBT-READ-SKIP" USING PB-BUFFER L-TAG
                 MOVE 1 TO WS-FAIL
         END-EVALUATE
     END-IF
     IF L-NAME = "target_cooldown_length" OR L-NAME = "required_player_range"
         MOVE 1 TO L-HANDLED
         IF L-TAG = 3
             CALL "PB-GET-INT" USING PB-BUFFER WS-VALUE
             IF L-NAME = "target_cooldown_length"
                 IF WS-VALUE < 0
                     MOVE 1 TO WS-FAIL
                 ELSE
                     MOVE WS-VALUE TO BE-XI(L-INDEX, 9)
                 END-IF
             ELSE
                 IF WS-VALUE < 1 OR WS-VALUE > 128
                     MOVE 1 TO WS-FAIL
                 ELSE
                     MOVE WS-VALUE TO BE-XI(L-INDEX, 10)
                 END-IF
             END-IF
         ELSE
             CALL "NBT-READ-SKIP" USING PB-BUFFER L-TAG
             MOVE 1 TO WS-FAIL
         END-IF
     END-IF
     IF WS-FAIL = 1 OR BE-XI(L-INDEX, 11) = 1
         MOVE 1 TO BE-XI(L-INDEX, 11)
         MOVE 0 TO BE-XI(L-INDEX, 7) BE-XI(L-INDEX, 8)
         MOVE SPACES TO BE-XT(L-INDEX, 3) BE-XT(L-INDEX, 4)
         MOVE 36000 TO BE-XI(L-INDEX, 9)
         MOVE 14 TO BE-XI(L-INDEX, 10)
     END-IF
     GOBACK.
 END PROGRAM BE7-TS-LOAD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BE7-TRIAL-TOTALS.
*> USING total_mobs, total_mobs_added_per_player, simultaneous_mobs, simultaneous_mobs_added_per_player (FLOAT-SHORT), extra players, target total out, target simultaneous out: 4.2.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-TOTAL                FLOAT-SHORT.
 01 L-TOTAL-PER            FLOAT-SHORT.
 01 L-SIMULTANEOUS         FLOAT-SHORT.
 01 L-SIMULTANEOUS-PER     FLOAT-SHORT.
 01 L-EXTRA                BINARY-LONG.
 01 L-TARGET-TOTAL         BINARY-LONG.
 01 L-TARGET-SIMULTANEOUS  BINARY-LONG.
 PROCEDURE DIVISION USING L-TOTAL L-TOTAL-PER L-SIMULTANEOUS L-SIMULTANEOUS-PER L-EXTRA L-TARGET-TOTAL L-TARGET-SIMULTANEOUS.
     COMPUTE L-TARGET-TOTAL = FUNCTION INTEGER(L-TOTAL + L-TOTAL-PER * L-EXTRA)
     COMPUTE L-TARGET-SIMULTANEOUS = FUNCTION INTEGER(L-SIMULTANEOUS + L-SIMULTANEOUS-PER * L-EXTRA)
     GOBACK.
 END PROGRAM BE7-TRIAL-TOTALS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BE7-TRIAL-DEFAULT.
*> USING spawn_range out, total_mobs, simultaneous_mobs, total_mobs_added_per_player, simultaneous_mobs_added_per_player (FLOAT-SHORT out), ticks_between_spawn out,
*> ticksBetweenItemSpawners out: TrialSpawnerConfig.DEFAULT of 4.2.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-RANGE                BINARY-LONG.
 01 L-TOTAL                FLOAT-SHORT.
 01 L-SIMULTANEOUS         FLOAT-SHORT.
 01 L-TOTAL-PER            FLOAT-SHORT.
 01 L-SIMULTANEOUS-PER     FLOAT-SHORT.
 01 L-TICKS                BINARY-LONG.
 01 L-ITEM-TICKS           BINARY-LONG.
 PROCEDURE DIVISION USING L-RANGE L-TOTAL L-SIMULTANEOUS L-TOTAL-PER L-SIMULTANEOUS-PER L-TICKS L-ITEM-TICKS.
     MOVE 4 TO L-RANGE
     MOVE 6.0 TO L-TOTAL
     MOVE 2.0 TO L-SIMULTANEOUS
     MOVE 2.0 TO L-TOTAL-PER
     MOVE 1.0 TO L-SIMULTANEOUS-PER
     MOVE 40 TO L-TICKS
     MOVE 160 TO L-ITEM-TICKS
     GOBACK.
 END PROGRAM BE7-TRIAL-DEFAULT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BE7-UNTRACKED.
*> USING entity found by UUID, alive, same dimension, squared distance of the block positions, untracked out: shouldMobBeUntracked of 4.3 item 2 (above 2209 strictly).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-FOUND                BINARY-LONG.
 01 L-ALIVE                BINARY-LONG.
 01 L-SAME                 BINARY-LONG.
 01 L-DISTANCE             BINARY-LONG.
 01 L-UNTRACKED            BINARY-LONG.
 PROCEDURE DIVISION USING L-FOUND L-ALIVE L-SAME L-DISTANCE L-UNTRACKED.
     MOVE 0 TO L-UNTRACKED
     IF L-FOUND = 0 OR L-ALIVE = 0 OR L-SAME = 0 OR L-DISTANCE > 2209
         MOVE 1 TO L-UNTRACKED
     END-IF
     GOBACK.
 END PROGRAM BE7-UNTRACKED.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BE7-PACK-POS.
*> USING x, y, z, packed out (BINARY-DOUBLE): BlockPos.asLong, x in 26 bits at bit 38, z in 26 bits at bit 12, y in 12 bits, as a signed 64 bit value.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-T                   PIC 9(20).
 01 WS-H63                 PIC 9(20) VALUE 9223372036854775808.
 01 WS-M64                 PIC 9(20) VALUE 18446744073709551616.
 LINKAGE SECTION.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-PACKED               BINARY-DOUBLE.
 PROCEDURE DIVISION USING L-X L-Y L-Z L-PACKED.
     COMPUTE WS-T = FUNCTION MOD(L-X, 67108864) * 274877906944 + FUNCTION MOD(L-Z, 67108864) * 4096 + FUNCTION MOD(L-Y, 4096)
     IF WS-T >= WS-H63
         COMPUTE L-PACKED = WS-T - WS-M64
     ELSE
         MOVE WS-T TO L-PACKED
     END-IF
     GOBACK.
 END PROGRAM BE7-PACK-POS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BE7-DETECT-THROTTLE.
*> USING packed position (BINARY-DOUBLE), game time (BINARY-DOUBLE), run out: tryDetectPlayers runs only when (packed position + game time) mod 20 is 0 (4.3 item 6).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-PACKED               BINARY-DOUBLE.
 01 L-TIME                 BINARY-DOUBLE.
 01 L-RUN                  BINARY-LONG.
 PROCEDURE DIVISION USING L-PACKED L-TIME L-RUN.
     MOVE 0 TO L-RUN
     IF FUNCTION MOD(L-PACKED + L-TIME, 20) = 0
         MOVE 1 TO L-RUN
     END-IF
     GOBACK.
 END PROGRAM BE7-DETECT-THROTTLE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BE7-DETECT-PLAN.
*> USING state (5 cooldown), ominous, players of the first detection (line of sight), one of them has the trial_omen effect, players stored, early return out, apply ominous out, stop out,
*> source out (1 the first list, 2 a second detection without line of sight): 4.3 item 6.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-STATE                BINARY-LONG.
 01 L-OMINOUS              BINARY-LONG.
 01 L-LIST                 BINARY-LONG.
 01 L-OMEN                 BINARY-LONG.
 01 L-STORED               BINARY-LONG.
 01 L-EARLY                BINARY-LONG.
 01 L-APPLY                BINARY-LONG.
 01 L-STOP                 BINARY-LONG.
 01 L-SOURCE               BINARY-LONG.
 PROCEDURE DIVISION USING L-STATE L-OMINOUS L-LIST L-OMEN L-STORED L-EARLY L-APPLY L-STOP L-SOURCE.
     MOVE 0 TO L-EARLY L-APPLY L-STOP L-SOURCE
     IF L-STATE = 5 AND L-OMINOUS = 1
         MOVE 1 TO L-EARLY
         GOBACK
     END-IF
     MOVE 1 TO L-SOURCE
     IF L-OMINOUS = 0 AND L-LIST > 0 AND L-OMEN = 1
         MOVE 1 TO L-APPLY
     END-IF
     IF L-STATE = 5 AND L-APPLY = 0
         MOVE 1 TO L-STOP
     END-IF
     IF L-STORED > 0
         MOVE 2 TO L-SOURCE
     END-IF
     GOBACK.
 END PROGRAM BE7-DETECT-PLAN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BE7-DETECT-ADDED.
*> USING index, game time (BINARY-DOUBLE), players added, omen flag, ominous, level event out: 4.3 item 6, next_mob_spawns_at becomes max(game time + 40, itself).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BESTATE.
 01 WS-LATER               BINARY-DOUBLE.
 LINKAGE SECTION.
 01 L-INDEX                BINARY-LONG.
 01 L-TIME                 BINARY-DOUBLE.
 01 L-ADDED                BINARY-LONG.
 01 L-OMEN                 BINARY-LONG.
 01 L-OMINOUS              BINARY-LONG.
 01 L-EVENT                BINARY-LONG.
 PROCEDURE DIVISION USING L-INDEX L-TIME L-ADDED L-OMEN L-OMINOUS L-EVENT.
     MOVE 0 TO L-EVENT
     IF L-ADDED > 0
         COMPUTE WS-LATER = L-TIME + 40
         IF WS-LATER > BE-TIME2(L-INDEX)
             MOVE WS-LATER TO BE-TIME2(L-INDEX)
         END-IF
         IF L-OMEN = 0
             MOVE 3013 TO L-EVENT
             IF L-OMINOUS = 1
                 MOVE 3019 TO L-EVENT
             END-IF
         END-IF
     END-IF
     GOBACK.
 END PROGRAM BE7-DETECT-ADDED.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BE7-PLAYER-DETECT.
*> USING squared distance, range, creative, spectator, the detector includes creative players, line of sight needed, the ray is clear, detected out: 4.3 item 7.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-DISTANCE             BINARY-LONG.
 01 L-RANGE                BINARY-LONG.
 01 L-CREATIVE             BINARY-LONG.
 01 L-SPECTATOR            BINARY-LONG.
 01 L-INCLUDING            BINARY-LONG.
 01 L-SIGHT                BINARY-LONG.
 01 L-CLEAR                BINARY-LONG.
 01 L-DETECTED             BINARY-LONG.
 PROCEDURE DIVISION USING L-DISTANCE L-RANGE L-CREATIVE L-SPECTATOR L-INCLUDING L-SIGHT L-CLEAR L-DETECTED.
     MOVE 0 TO L-DETECTED
     IF L-DISTANCE < L-RANGE * L-RANGE AND L-SPECTATOR = 0 AND (L-INCLUDING = 1 OR L-CREATIVE = 0) AND (L-SIGHT = 0 OR L-CLEAR = 1)
         MOVE 1 TO L-DETECTED
     END-IF
     GOBACK.
 END PROGRAM BE7-PLAYER-DETECT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BE7-EJECT-TICK.
*> USING game time, cooldown_ends_at (BINARY-DOUBLE), target_cooldown_length, detected players, eject out: one reward per detected player every 30 ticks from the start of the cooldown (4.3 item 10).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-TIME                 BINARY-DOUBLE.
 01 L-COOLDOWN-END         BINARY-DOUBLE.
 01 L-LENGTH               BINARY-LONG.
 01 L-DETECTED             BINARY-LONG.
 01 L-EJECT                BINARY-LONG.
 PROCEDURE DIVISION USING L-TIME L-COOLDOWN-END L-LENGTH L-DETECTED L-EJECT.
     MOVE 0 TO L-EJECT
     IF L-DETECTED > 0 AND FUNCTION MOD(L-TIME - (L-COOLDOWN-END - L-LENGTH), 30) = 0
         MOVE 1 TO L-EJECT
     END-IF
     GOBACK.
 END PROGRAM BE7-EJECT-TICK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BE7-EJECT-EVENT.
*> USING stacks rolled, level event out (3014 only when at least one stack was rolled): 4.3 item 10.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-STACKS               BINARY-LONG.
 01 L-EVENT                BINARY-LONG.
 PROCEDURE DIVISION USING L-STACKS L-EVENT.
     MOVE 0 TO L-EVENT
     IF L-STACKS > 0
         MOVE 3014 TO L-EVENT
     END-IF
     GOBACK.
 END PROGRAM BE7-EJECT-EVENT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BE7-CAN-SPAWN.
*> USING spawner_blocks_work, override flag, difficulty is Peaceful, spawn_mobs, result out: canSpawnInLevel of 4.3 item 5.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-WORK                 BINARY-LONG.
 01 L-OVERRIDE             BINARY-LONG.
 01 L-PEACEFUL             BINARY-LONG.
 01 L-SPAWN-MOBS           BINARY-LONG.
 01 L-RESULT               BINARY-LONG.
 PROCEDURE DIVISION USING L-WORK L-OVERRIDE L-PEACEFUL L-SPAWN-MOBS L-RESULT.
     MOVE 0 TO L-RESULT
     IF L-WORK = 1
         IF L-OVERRIDE = 1
             MOVE 1 TO L-RESULT
         ELSE
             IF L-PEACEFUL = 0
                 MOVE L-SPAWN-MOBS TO L-RESULT
             END-IF
         END-IF
     END-IF
     GOBACK.
 END PROGRAM BE7-CAN-SPAWN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BE7-HAS-MOB.
*> USING index, potentials of the active config, result out: hasMobToSpawn of 4.3 item 9 (the stored entity has an id, or the potentials list is not empty).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BESTATE.
 LINKAGE SECTION.
 01 L-INDEX                BINARY-LONG.
 01 L-POTENTIALS           BINARY-LONG.
 01 L-RESULT               BINARY-LONG.
 PROCEDURE DIVISION USING L-INDEX L-POTENTIALS L-RESULT.
     MOVE 0 TO L-RESULT
     IF BE-XI(L-INDEX, 5) > 0 OR L-POTENTIALS > 0
         MOVE 1 TO L-RESULT
     END-IF
     GOBACK.
 END PROGRAM BE7-HAS-MOB.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BE7-ITEM-SEED.
*> USING level seed (BINARY-DOUBLE), x, y, z of the spawner, loot seed out (BINARY-DOUBLE): the seed of the ominous item list (4.3 item 11).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-F                   FLOAT-SHORT.
 01 WS-BX                  BINARY-LONG.
 01 WS-BY                  BINARY-LONG.
 01 WS-BZ                  BINARY-LONG.
 01 WS-PACKED              BINARY-DOUBLE.
 01 WS-SUM                 PIC S9(20).
 01 WS-MAX                 PIC S9(20) VALUE 9223372036854775807.
 01 WS-MIN                 PIC S9(20) VALUE -9223372036854775808.
 01 WS-M64                 PIC S9(20) VALUE 18446744073709551616.
 LINKAGE SECTION.
 01 L-SEED                 BINARY-DOUBLE.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-RESULT               BINARY-DOUBLE.
 PROCEDURE DIVISION USING L-SEED L-X L-Y L-Z L-RESULT.
     COMPUTE WS-F = L-X / 30
     COMPUTE WS-BX = FUNCTION INTEGER(WS-F)
     COMPUTE WS-F = L-Y / 20
     COMPUTE WS-BY = FUNCTION INTEGER(WS-F)
     COMPUTE WS-F = L-Z / 30
     COMPUTE WS-BZ = FUNCTION INTEGER(WS-F)
     CALL "BE7-PACK-POS" USING WS-BX WS-BY WS-BZ WS-PACKED
     COMPUTE WS-SUM = L-SEED + WS-PACKED
     IF WS-SUM > WS-MAX
         COMPUTE WS-SUM = WS-SUM - WS-M64
     END-IF
     IF WS-SUM < WS-MIN
         COMPUTE WS-SUM = WS-SUM + WS-M64
     END-IF
     MOVE WS-SUM TO L-RESULT
     GOBACK.
 END PROGRAM BE7-ITEM-SEED.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BE7-VAULT-CONFIG-DEFAULT.
*> USING index: VaultConfig.DEFAULT (5.2): loot table minecraft:chests/trial_chambers/reward, ranges 4.0 and 4.5, key item minecraft:trial_key x 1, no display override.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BESTATE.
 LINKAGE SECTION.
 01 L-INDEX                BINARY-LONG.
 PROCEDURE DIVISION USING L-INDEX.
     MOVE "minecraft:chests/trial_chambers/reward" TO BE-XT(L-INDEX, 2)
     MOVE 38 TO BE-XI(L-INDEX, 4)
     MOVE SPACES TO BE-XT(L-INDEX, 3)
     MOVE 0 TO BE-XI(L-INDEX, 5)
     MOVE 4.0 TO BE-XD(L-INDEX, 1)
     MOVE 4.5 TO BE-XD(L-INDEX, 2)
     MOVE "minecraft:trial_key" TO BE-XT(L-INDEX, 1)
     MOVE 19 TO BE-XI(L-INDEX, 1)
     MOVE 1 TO BE-XI(L-INDEX, 2)
     GOBACK.
 END PROGRAM BE7-VAULT-CONFIG-DEFAULT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BE7-W-ITEM.
*> USING PB-BUFFER, key name (X(32), empty for a list element), item id (X(64)), length, count: an item stack compound {id, count}.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WN                     PIC X(32).
 01 WL                     BINARY-LONG.
 LINKAGE SECTION.
 COPY PROTO.
 01 L-NAME                 PIC X(32).
 01 L-ID                   PIC X(64).
 01 L-LENGTH               BINARY-LONG.
 01 L-COUNT                BINARY-LONG.
 PROCEDURE DIVISION USING PB-BUFFER L-NAME L-ID L-LENGTH L-COUNT.
     IF L-NAME NOT = SPACES
         MOVE FUNCTION LENGTH(FUNCTION TRIM(L-NAME)) TO WL
         CALL "NBT-WRITE-COMPOUND-BEGIN" USING PB-BUFFER L-NAME WL
     END-IF
     MOVE "id" TO WN
     CALL "BE6-W-STR" USING PB-BUFFER WN L-ID L-LENGTH
     MOVE "count" TO WN
     CALL "BE6-W-INT" USING PB-BUFFER WN L-COUNT
     CALL "NBT-WRITE-COMPOUND-END" USING PB-BUFFER
     GOBACK.
 END PROGRAM BE7-W-ITEM.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BE7-R-ITEM.
*> USING PB-BUFFER, id out (X(64)), length out, count out: the compound payload of an item stack (a missing count is 1, a missing id the empty stack).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WN                     PIC X(32).
 01 WL                     BINARY-LONG.
 01 WS-C32                 BINARY-LONG VALUE 32.
 01 WS-C64                 BINARY-LONG VALUE 64.
 01 WS-TYPE                BINARY-LONG.
 LINKAGE SECTION.
 COPY PROTO.
 01 L-ID                   PIC X(64).
 01 L-LENGTH               BINARY-LONG.
 01 L-COUNT                BINARY-LONG.
 PROCEDURE DIVISION USING PB-BUFFER L-ID L-LENGTH L-COUNT.
     MOVE SPACES TO L-ID
     MOVE 0 TO L-LENGTH
     MOVE 1 TO L-COUNT
     PERFORM UNTIL PB-ERROR = 1
         MOVE SPACES TO WN
         CALL "NBT-READ-COMPOUND-NEXT" USING PB-BUFFER WS-TYPE WN WS-C32 WL
         IF WS-TYPE = 0
             EXIT PERFORM
         END-IF
         EVALUATE TRUE
             WHEN WN = "id" AND WS-TYPE = 8
                 CALL "BE6-READ-TEXT" USING PB-BUFFER L-ID WS-C64 L-LENGTH
             WHEN WN = "count" AND WS-TYPE = 3
                 CALL "PB-GET-INT" USING PB-BUFFER L-COUNT
             WHEN OTHER
                 CALL "NBT-READ-SKIP" USING PB-BUFFER WS-TYPE
         END-EVALUATE
     END-PERFORM
     GOBACK.
 END PROGRAM BE7-R-ITEM.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BE7-VAULT-SAVE.
*> USING index, PB-BUFFER, shared only (1 writes just shared_data, the update tag of 5.4): config, shared_data, server_data of 5.3.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BESTATE.
 01 WN                     PIC X(32).
 01 WL                     BINARY-LONG.
 01 WS-LONG                BINARY-DOUBLE.
 01 WS-I                   BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-T-COMPOUND          BINARY-LONG VALUE 10.
 01 WS-NONE                PIC X(32) VALUE SPACES.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-LEN                 BINARY-LONG.
 01 WS-CNT                 BINARY-LONG.
 LINKAGE SECTION.
 COPY PROTO.
 01 L-INDEX                BINARY-LONG.
 01 L-SHARED-ONLY          BINARY-LONG.
 PROCEDURE DIVISION USING L-INDEX PB-BUFFER L-SHARED-ONLY.
     IF L-SHARED-ONLY = 0
         MOVE "config" TO WN
         MOVE 6 TO WL
         CALL "NBT-WRITE-COMPOUND-BEGIN" USING PB-BUFFER WN WL
         MOVE "loot_table" TO WN
         CALL "BE6-W-STR" USING PB-BUFFER WN BE-XT(L-INDEX, 2) BE-XI(L-INDEX, 4)
         MOVE "activation_range" TO WN
         CALL "BE7-W-DOUBLE" USING PB-BUFFER WN BE-XD(L-INDEX, 1)
         MOVE "deactivation_range" TO WN
         CALL "BE7-W-DOUBLE" USING PB-BUFFER WN BE-XD(L-INDEX, 2)
         IF BE-XI(L-INDEX, 1) > 0
             MOVE "key_item" TO WN
             MOVE BE-XI(L-INDEX, 1) TO WS-LEN
             MOVE BE-XI(L-INDEX, 2) TO WS-CNT
             CALL "BE7-W-ITEM" USING PB-BUFFER WN BE-XT(L-INDEX, 1) WS-LEN WS-CNT
         END-IF
         IF BE-XI(L-INDEX, 5) > 0
             MOVE "override_loot_table_to_display" TO WN
             CALL "BE6-W-STR" USING PB-BUFFER WN BE-XT(L-INDEX, 3) BE-XI(L-INDEX, 5)
         END-IF
         CALL "NBT-WRITE-COMPOUND-END" USING PB-BUFFER
     END-IF
     MOVE "shared_data" TO WN
     MOVE 11 TO WL
     CALL "NBT-WRITE-COMPOUND-BEGIN" USING PB-BUFFER WN WL
     IF BE-XI(L-INDEX, 6) > 0
         MOVE "display_item" TO WN
         MOVE BE-XI(L-INDEX, 6) TO WS-LEN
         MOVE BE-XI(L-INDEX, 7) TO WS-CNT
         CALL "BE7-W-ITEM" USING PB-BUFFER WN BE-XT(L-INDEX, 4) WS-LEN WS-CNT
     END-IF
     MOVE "connected_players" TO WN
     CALL "BE7-W-UUIDS" USING PB-BUFFER WN L-INDEX 513 BE-XI(L-INDEX, 8)
     MOVE "connected_particles_range" TO WN
     CALL "BE7-W-DOUBLE" USING PB-BUFFER WN BE-XD(L-INDEX, 3)
     CALL "NBT-WRITE-COMPOUND-END" USING PB-BUFFER
     IF L-SHARED-ONLY = 0
         MOVE "server_data" TO WN
         MOVE 11 TO WL
         CALL "NBT-WRITE-COMPOUND-BEGIN" USING PB-BUFFER WN WL
         MOVE "rewarded_players" TO WN
         CALL "BE7-W-UUIDS" USING PB-BUFFER WN L-INDEX 1 BE-XI(L-INDEX, 25)
         MOVE "state_updating_resumes_at" TO WN
         MOVE BE-SEED(L-INDEX) TO WS-LONG
         CALL "BE7-W-LONG" USING PB-BUFFER WN WS-LONG
         MOVE "items_to_eject" TO WN
         MOVE 14 TO WL
         MOVE BE-XI(L-INDEX, 59) TO WS-COUNT
         IF WS-COUNT = 0
             CALL "NBT-WRITE-LIST-BEGIN" USING PB-BUFFER WN WL WS-ZERO WS-COUNT
         ELSE
             CALL "NBT-WRITE-LIST-BEGIN" USING PB-BUFFER WN WL WS-T-COMPOUND WS-COUNT
         END-IF
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-COUNT
             MOVE FUNCTION LENGTH(FUNCTION TRIM(BE-XT(L-INDEX, 4 + WS-I))) TO WL
             CALL "BE7-W-ITEM" USING PB-BUFFER WS-NONE BE-XT(L-INDEX, 4 + WS-I) WL BE-SLOT-COUNT(L-INDEX, WS-I)
         END-PERFORM
         MOVE "total_ejections_needed" TO WN
         CALL "BE6-W-INT" USING PB-BUFFER WN BE-XI(L-INDEX, 60)
         CALL "NBT-WRITE-COMPOUND-END" USING PB-BUFFER
     END-IF
     GOBACK.
 END PROGRAM BE7-VAULT-SAVE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BE7-VAULT-TAG.
*> USING index, PB-BUFFER: the update tag of 5.4, the single key shared_data.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-SHARED              BINARY-LONG VALUE 1.
 LINKAGE SECTION.
 COPY PROTO.
 01 L-INDEX                BINARY-LONG.
 PROCEDURE DIVISION USING L-INDEX PB-BUFFER.
     CALL "BE7-VAULT-SAVE" USING L-INDEX PB-BUFFER WS-SHARED
     GOBACK.
 END PROGRAM BE7-VAULT-TAG.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BE7-VAULT-LOAD.
*> USING index, key name (X(32)), tag, PB-BUFFER, handled out: 5.3. A config starts from the default with no key item (an absent key_item is the empty stack) and is rejected as a whole
*> (back to the default config) when activation_range is above deactivation_range; total_ejections_needed is read nowhere (the quirk of 5.3).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BESTATE.
 01 WN                     PIC X(32).
 01 WL                     BINARY-LONG.
 01 WS-C32                 BINARY-LONG VALUE 32.
 01 WS-C64                 BINARY-LONG VALUE 64.
 01 WS-TYPE                BINARY-LONG.
 01 WS-ETYPE               BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-E                   BINARY-LONG.
 01 WS-ID                  PIC X(64).
 01 WS-ID-LENGTH           BINARY-LONG.
 01 WS-ITEM-COUNT          BINARY-LONG.
 01 WS-KEY-ID              PIC X(64).
 01 WS-KEY-LENGTH          BINARY-LONG.
 01 WS-KEY-COUNT           BINARY-LONG.
 LINKAGE SECTION.
 COPY PROTO.
 01 L-INDEX                BINARY-LONG.
 01 L-NAME                 PIC X(32).
 01 L-TAG                  BINARY-LONG.
 01 L-HANDLED              BINARY-LONG.
 PROCEDURE DIVISION USING L-INDEX L-NAME L-TAG PB-BUFFER L-HANDLED.
     MOVE 0 TO L-HANDLED
     IF L-NAME = "config" AND L-TAG = 10
         MOVE 1 TO L-HANDLED
         CALL "BE7-VAULT-CONFIG-DEFAULT" USING L-INDEX
         MOVE SPACES TO BE-XT(L-INDEX, 1)
         MOVE 0 TO BE-XI(L-INDEX, 1) BE-XI(L-INDEX, 2)
         PERFORM UNTIL PB-ERROR = 1
             MOVE SPACES TO WN
             CALL "NBT-READ-COMPOUND-NEXT" USING PB-BUFFER WS-TYPE WN WS-C32 WL
             IF WS-TYPE = 0
                 EXIT PERFORM
             END-IF
             EVALUATE TRUE
                 WHEN WN = "loot_table" AND WS-TYPE = 8
                     CALL "BE6-READ-TEXT" USING PB-BUFFER BE-XT(L-INDEX, 2) WS-C64 BE-XI(L-INDEX, 4)
                 WHEN WN = "activation_range" AND WS-TYPE = 6
                     CALL "PB-GET-DOUBLE" USING PB-BUFFER BE-XD(L-INDEX, 1)
                 WHEN WN = "deactivation_range" AND WS-TYPE = 6
                     CALL "PB-GET-DOUBLE" USING PB-BUFFER BE-XD(L-INDEX, 2)
                 WHEN WN = "key_item" AND WS-TYPE = 10
                     CALL "BE7-R-ITEM" USING PB-BUFFER WS-KEY-ID WS-KEY-LENGTH WS-KEY-COUNT
                     MOVE WS-KEY-ID TO BE-XT(L-INDEX, 1)
                     MOVE WS-KEY-LENGTH TO BE-XI(L-INDEX, 1)
                     MOVE WS-KEY-COUNT TO BE-XI(L-INDEX, 2)
                 WHEN WN = "override_loot_table_to_display" AND WS-TYPE = 8
                     CALL "BE6-READ-TEXT" USING PB-BUFFER BE-XT(L-INDEX, 3) WS-C64 BE-XI(L-INDEX, 5)
                 WHEN OTHER
                     CALL "NBT-READ-SKIP" USING PB-BUFFER WS-TYPE
             END-EVALUATE
         END-PERFORM
         IF BE-XD(L-INDEX, 1) > BE-XD(L-INDEX, 2)
             CALL "BE7-VAULT-CONFIG-DEFAULT" USING L-INDEX
         END-IF
     END-IF
     IF L-NAME = "shared_data" AND L-TAG = 10
         MOVE 1 TO L-HANDLED
         PERFORM UNTIL PB-ERROR = 1
             MOVE SPACES TO WN
             CALL "NBT-READ-COMPOUND-NEXT" USING PB-BUFFER WS-TYPE WN WS-C32 WL
             IF WS-TYPE = 0
                 EXIT PERFORM
             END-IF
             EVALUATE TRUE
                 WHEN WN = "display_item" AND WS-TYPE = 10
                     CALL "BE7-R-ITEM" USING PB-BUFFER WS-KEY-ID WS-KEY-LENGTH WS-KEY-COUNT
                     MOVE WS-KEY-ID TO BE-XT(L-INDEX, 4)
                     MOVE WS-KEY-LENGTH TO BE-XI(L-INDEX, 6)
                     MOVE WS-KEY-COUNT TO BE-XI(L-INDEX, 7)
                 WHEN WN = "connected_players" AND WS-TYPE = 9
                     CALL "BE7-R-UUIDS" USING PB-BUFFER L-INDEX 513 32 BE-XI(L-INDEX, 8)
                 WHEN WN = "connected_particles_range" AND WS-TYPE = 6
                     CALL "PB-GET-DOUBLE" USING PB-BUFFER BE-XD(L-INDEX, 3)
                 WHEN OTHER
                     CALL "NBT-READ-SKIP" USING PB-BUFFER WS-TYPE
             END-EVALUATE
         END-PERFORM
     END-IF
     IF L-NAME = "server_data" AND L-TAG = 10
         MOVE 1 TO L-HANDLED
         PERFORM UNTIL PB-ERROR = 1
             MOVE SPACES TO WN
             CALL "NBT-READ-COMPOUND-NEXT" USING PB-BUFFER WS-TYPE WN WS-C32 WL
             IF WS-TYPE = 0
                 EXIT PERFORM
             END-IF
             EVALUATE TRUE
                 WHEN WN = "rewarded_players" AND WS-TYPE = 9
                     CALL "BE7-R-UUIDS" USING PB-BUFFER L-INDEX 1 128 BE-XI(L-INDEX, 25)
                 WHEN WN = "state_updating_resumes_at" AND WS-TYPE = 4
                     CALL "PB-GET-LONG" USING PB-BUFFER BE-SEED(L-INDEX)
                 WHEN WN = "items_to_eject" AND WS-TYPE = 9
                     MOVE 0 TO BE-XI(L-INDEX, 59)
                     CALL "NBT-READ-LIST-BEGIN" USING PB-BUFFER WS-ETYPE WS-COUNT
                     PERFORM VARYING WS-E FROM 1 BY 1 UNTIL WS-E > WS-COUNT OR PB-ERROR = 1
                         IF WS-ETYPE NOT = 10
                             CALL "NBT-READ-SKIP" USING PB-BUFFER WS-ETYPE
                         ELSE
                             CALL "BE7-R-ITEM" USING PB-BUFFER WS-ID WS-ID-LENGTH WS-ITEM-COUNT
                             IF BE-XI(L-INDEX, 59) < 8
                                 ADD 1 TO BE-XI(L-INDEX, 59)
                                 MOVE WS-ID TO BE-XT(L-INDEX, 4 + BE-XI(L-INDEX, 59))
                                 MOVE WS-ITEM-COUNT TO BE-SLOT-COUNT(L-INDEX, BE-XI(L-INDEX, 59))
                             END-IF
                         END-IF
                     END-PERFORM
                 WHEN OTHER
                     CALL "NBT-READ-SKIP" USING PB-BUFFER WS-TYPE
             END-EVALUATE
         END-PERFORM
     END-IF
     GOBACK.
 END PROGRAM BE7-VAULT-LOAD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BE7-VAULT-CAN-EJECT.
*> USING index, vault state (0 inactive, 1 active, 2 unlocking, 3 ejecting), can out: canEjectReward of 5.7 (a non-empty key item and a state other than inactive).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BESTATE.
 LINKAGE SECTION.
 01 L-INDEX                BINARY-LONG.
 01 L-STATE                BINARY-LONG.
 01 L-CAN                  BINARY-LONG.
 PROCEDURE DIVISION USING L-INDEX L-STATE L-CAN.
     MOVE 0 TO L-CAN
     IF BE-XI(L-INDEX, 1) > 0 AND L-STATE NOT = 0
         MOVE 1 TO L-CAN
     END-IF
     GOBACK.
 END PROGRAM BE7-VAULT-CAN-EJECT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BE7-VAULT-SET-DISPLAY.
*> USING index, item id (X(64)), length, count, changed out: setDisplayItem of 5.7, no change when the stack matches, else it is stored and the shared data is dirty.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BESTATE.
 LINKAGE SECTION.
 01 L-INDEX                BINARY-LONG.
 01 L-ID                   PIC X(64).
 01 L-LENGTH               BINARY-LONG.
 01 L-COUNT                BINARY-LONG.
 01 L-CHANGED              BINARY-LONG.
 PROCEDURE DIVISION USING L-INDEX L-ID L-LENGTH L-COUNT L-CHANGED.
     MOVE 0 TO L-CHANGED
     IF L-ID NOT = BE-XT(L-INDEX, 4) OR L-COUNT NOT = BE-XI(L-INDEX, 7)
         MOVE L-ID TO BE-XT(L-INDEX, 4)
         MOVE L-LENGTH TO BE-XI(L-INDEX, 6)
         MOVE L-COUNT TO BE-XI(L-INDEX, 7)
         MOVE 1 TO BE-XI(L-INDEX, 61)
         MOVE 1 TO L-CHANGED
     END-IF
     GOBACK.
 END PROGRAM BE7-VAULT-SET-DISPLAY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BE7-VAULT-NEXT.
*> USING index, game time (BINARY-DOUBLE), vault state, any connected player after the update of the range, next state out, an item was ejected out, eject progress out (FLOAT-SHORT):
*> VaultState.tickAndGetNext of 5.5 with updateStateForConnectedPlayers (the caller updates the players first). Items leave the list from its end and the new last item is the display item.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BESTATE.
 01 WS-K                   BINARY-LONG.
 01 WS-TOTAL               BINARY-LONG.
 LINKAGE SECTION.
 01 L-INDEX                BINARY-LONG.
 01 L-TIME                 BINARY-DOUBLE.
 01 L-STATE                BINARY-LONG.
 01 L-ANY                  BINARY-LONG.
 01 L-NEXT                 BINARY-LONG.
 01 L-EJECTED              BINARY-LONG.
 01 L-PROGRESS             FLOAT-SHORT.
 PROCEDURE DIVISION USING L-INDEX L-TIME L-STATE L-ANY L-NEXT L-EJECTED L-PROGRESS.
     MOVE 0 TO L-EJECTED
     MOVE 0 TO L-PROGRESS
     COMPUTE BE-SEED(L-INDEX) = L-TIME + 20
     MOVE 0 TO L-NEXT
     IF L-ANY = 1
         MOVE 1 TO L-NEXT
     END-IF
     EVALUATE L-STATE
         WHEN 2
             MOVE 3 TO L-NEXT
         WHEN 3
             MOVE BE-XI(L-INDEX, 59) TO WS-K
             MOVE BE-XI(L-INDEX, 60) TO WS-TOTAL
             IF WS-K = 0
                 MOVE 0 TO BE-XI(L-INDEX, 60)
             ELSE
                 MOVE 3 TO L-NEXT
                 MOVE 1 TO L-EJECTED
                 MOVE 1.0 TO L-PROGRESS
                 IF WS-TOTAL NOT = 1
                     COMPUTE L-PROGRESS = 1 - (WS-K - 1) / (WS-TOTAL - 1)
                 END-IF
                 SUBTRACT 1 FROM WS-K
                 MOVE WS-K TO BE-XI(L-INDEX, 59)
                 MOVE SPACES TO BE-XT(L-INDEX, 4)
                 MOVE 0 TO BE-XI(L-INDEX, 6) BE-XI(L-INDEX, 7)
                 IF WS-K > 0
                     MOVE BE-XT(L-INDEX, 4 + WS-K) TO BE-XT(L-INDEX, 4)
                     MOVE FUNCTION LENGTH(FUNCTION TRIM(BE-XT(L-INDEX, 4))) TO BE-XI(L-INDEX, 6)
                     MOVE BE-SLOT-COUNT(L-INDEX, WS-K) TO BE-XI(L-INDEX, 7)
                 END-IF
                 MOVE 1 TO BE-XI(L-INDEX, 61) BE-XI(L-INDEX, 62)
             END-IF
     END-EVALUATE
     GOBACK.
 END PROGRAM BE7-VAULT-NEXT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BE7-VAULT-PITCH.
*> USING progress, pitch out (FLOAT-SHORT): the pitch of vault.eject_item, 0.8 + 0.4 * progress (5.7).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-PROGRESS             FLOAT-SHORT.
 01 L-PITCH                FLOAT-SHORT.
 PROCEDURE DIVISION USING L-PROGRESS L-PITCH.
     COMPUTE L-PITCH = 0.8 + 0.4 * L-PROGRESS
     GOBACK.
 END PROGRAM BE7-VAULT-PITCH.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BE7-VAULT-GATE.
*> USING game time (BINARY-DOUBLE), vault state, run out: the display cycle runs on every 20th tick while active (5.5 step 2).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-TIME                 BINARY-DOUBLE.
 01 L-STATE                BINARY-LONG.
 01 L-RUN                  BINARY-LONG.
 PROCEDURE DIVISION USING L-TIME L-STATE L-RUN.
     MOVE 0 TO L-RUN
     IF FUNCTION MOD(L-TIME, 20) = 0 AND L-STATE = 1
         MOVE 1 TO L-RUN
     END-IF
     GOBACK.
 END PROGRAM BE7-VAULT-GATE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BE7-VAULT-DUE.
*> USING game time, state_updating_resumes_at (BINARY-DOUBLE), due out: 5.5 step 3.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-TIME                 BINARY-DOUBLE.
 01 L-RESUME               BINARY-DOUBLE.
 01 L-DUE                  BINARY-LONG.
 PROCEDURE DIVISION USING L-TIME L-RESUME L-DUE.
     MOVE 0 TO L-DUE
     IF L-TIME >= L-RESUME
         MOVE 1 TO L-DUE
     END-IF
     GOBACK.
 END PROGRAM BE7-VAULT-DUE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BE7-VAULT-SYNC.
*> USING index, set changed out, send block update out: 5.4, the dirty flags (XI 61 shared, XI 62 server) are cleared.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BESTATE.
 LINKAGE SECTION.
 01 L-INDEX                BINARY-LONG.
 01 L-CHANGED              BINARY-LONG.
 01 L-SEND                 BINARY-LONG.
 PROCEDURE DIVISION USING L-INDEX L-CHANGED L-SEND.
     MOVE 0 TO L-CHANGED L-SEND
     IF BE-XI(L-INDEX, 61) = 1 OR BE-XI(L-INDEX, 62) = 1
         MOVE 1 TO L-CHANGED
     END-IF
     IF BE-XI(L-INDEX, 61) = 1
         MOVE 1 TO L-SEND
     END-IF
     MOVE 0 TO BE-XI(L-INDEX, 61) BE-XI(L-INDEX, 62)
     GOBACK.
 END PROGRAM BE7-VAULT-SYNC.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BE7-VAULT-HOOK.
*> USING index, old state, new state, ominous, level event out, its data out, enter sound out (1 insert_item, 2 open_shutter), exit sound out (3 close_shutter), display cycle out: onTransition of 5.5.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BESTATE.
 LINKAGE SECTION.
 01 L-INDEX                BINARY-LONG.
 01 L-OLD                  BINARY-LONG.
 01 L-NEW                  BINARY-LONG.
 01 L-OMINOUS              BINARY-LONG.
 01 L-EVENT                BINARY-LONG.
 01 L-DATA                 BINARY-LONG.
 01 L-ENTER                BINARY-LONG.
 01 L-EXIT                 BINARY-LONG.
 01 L-CYCLE                BINARY-LONG.
 PROCEDURE DIVISION USING L-INDEX L-OLD L-NEW L-OMINOUS L-EVENT L-DATA L-ENTER L-EXIT L-CYCLE.
     MOVE 0 TO L-EVENT L-DATA L-ENTER L-EXIT L-CYCLE
     IF L-OLD = 3
         MOVE 3 TO L-EXIT
     END-IF
     EVALUATE L-NEW
         WHEN 0
             MOVE 3016 TO L-EVENT
             MOVE L-OMINOUS TO L-DATA
             MOVE SPACES TO BE-XT(L-INDEX, 4)
             MOVE 0 TO BE-XI(L-INDEX, 6) BE-XI(L-INDEX, 7)
         WHEN 1
             MOVE 3015 TO L-EVENT
             MOVE L-OMINOUS TO L-DATA
             IF BE-XI(L-INDEX, 6) = 0
                 MOVE 1 TO L-CYCLE
             END-IF
         WHEN 2
             MOVE 1 TO L-ENTER
         WHEN 3
             MOVE 2 TO L-ENTER
     END-EVALUATE
     GOBACK.
 END PROGRAM BE7-VAULT-HOOK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BE7-UUID-IN.
*> USING index, first cell of BE-UUID, number of UUIDs, a UUID (4 BINARY-LONG), found out.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BESTATE.
 01 WS-I                   BINARY-LONG.
 01 WS-B                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-INDEX                BINARY-LONG.
 01 L-BASE                 BINARY-LONG.
 01 L-COUNT                BINARY-LONG.
 01 L-UUID.
    05 L-U                 BINARY-LONG OCCURS 4 TIMES.
 01 L-FOUND                BINARY-LONG.
 PROCEDURE DIVISION USING L-INDEX L-BASE L-COUNT L-UUID L-FOUND.
     MOVE 0 TO L-FOUND
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > L-COUNT
         COMPUTE WS-B = L-BASE + (WS-I - 1) * 4
         IF BE-UUID(L-INDEX, WS-B) = L-U(1) AND BE-UUID(L-INDEX, WS-B + 1) = L-U(2) AND BE-UUID(L-INDEX, WS-B + 2) = L-U(3)
                 AND BE-UUID(L-INDEX, WS-B + 3) = L-U(4)
             MOVE 1 TO L-FOUND
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM BE7-UUID-IN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BE7-VAULT-REWARD.
*> USING index, a UUID (4 BINARY-LONG): adds the player to rewarded_players, an insertion-ordered set of at most 128 whose oldest member leaves first (5.6 step 8).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BESTATE.
 01 WS-FOUND               BINARY-LONG.
 01 WS-BASE                BINARY-LONG VALUE 1.
 01 WS-I                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-INDEX                BINARY-LONG.
 01 L-UUID.
    05 L-U                 BINARY-LONG OCCURS 4 TIMES.
 PROCEDURE DIVISION USING L-INDEX L-UUID.
     CALL "BE7-UUID-IN" USING L-INDEX WS-BASE BE-XI(L-INDEX, 25) L-UUID WS-FOUND
     IF WS-FOUND = 0
         IF BE-XI(L-INDEX, 25) = 128
             PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 508
                 MOVE BE-UUID(L-INDEX, WS-I + 4) TO BE-UUID(L-INDEX, WS-I)
             END-PERFORM
             SUBTRACT 1 FROM BE-XI(L-INDEX, 25)
         END-IF
         ADD 1 TO BE-XI(L-INDEX, 25)
         COMPUTE WS-I = (BE-XI(L-INDEX, 25) - 1) * 4
         PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 4
             MOVE L-U(WS-K) TO BE-UUID(L-INDEX, WS-I + WS-K)
         END-PERFORM
         MOVE 1 TO BE-XI(L-INDEX, 62)
     END-IF
     GOBACK.
 END PROGRAM BE7-VAULT-REWARD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BE7-VAULT-FAIL-SOUND.
*> USING index, game time (BINARY-DOUBLE), play out: playInsertFailSound of 5.6, at most one failure sound per 15 ticks (kept in BE-TIME2, not saved).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BESTATE.
 LINKAGE SECTION.
 01 L-INDEX                BINARY-LONG.
 01 L-TIME                 BINARY-DOUBLE.
 01 L-PLAY                 BINARY-LONG.
 PROCEDURE DIVISION USING L-INDEX L-TIME L-PLAY.
     MOVE 0 TO L-PLAY
     IF L-TIME >= BE-TIME2(L-INDEX) + 15
         MOVE 1 TO L-PLAY
         MOVE L-TIME TO BE-TIME2(L-INDEX)
     END-IF
     GOBACK.
 END PROGRAM BE7-VAULT-FAIL-SOUND.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BE7-VAULT-KEY.
*> USING index, vault state, game time (BINARY-DOUBLE), held item id (X(64)), its length, held count, creative, the player UUID (4 BINARY-LONG), items rolled, action out (0 nothing,
*> 1 insert failure, 2 rewarded player, 3 empty roll, 4 unlocked), sound plays out, key items consumed out: tryInsertKey of 5.6 (the roll is the caller's, the display item the last of the roll).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BESTATE.
 01 WS-CAN                 BINARY-LONG.
 01 WS-BASE                BINARY-LONG VALUE 1.
 01 WS-FOUND               BINARY-LONG.
 LINKAGE SECTION.
 01 L-INDEX                BINARY-LONG.
 01 L-STATE                BINARY-LONG.
 01 L-TIME                 BINARY-DOUBLE.
 01 L-HELD                 PIC X(64).
 01 L-HELD-LENGTH          BINARY-LONG.
 01 L-HELD-COUNT           BINARY-LONG.
 01 L-CREATIVE             BINARY-LONG.
 01 L-UUID.
    05 L-U                 BINARY-LONG OCCURS 4 TIMES.
 01 L-ROLLED               BINARY-LONG.
 01 L-ACTION               BINARY-LONG.
 01 L-PLAY                 BINARY-LONG.
 01 L-CONSUME              BINARY-LONG.
 PROCEDURE DIVISION USING L-INDEX L-STATE L-TIME L-HELD L-HELD-LENGTH L-HELD-COUNT L-CREATIVE L-UUID L-ROLLED L-ACTION L-PLAY L-CONSUME.
     MOVE 0 TO L-ACTION L-PLAY L-CONSUME
     CALL "BE7-VAULT-CAN-EJECT" USING L-INDEX L-STATE WS-CAN
     IF WS-CAN = 0
         GOBACK
     END-IF
     IF L-HELD-LENGTH NOT = BE-XI(L-INDEX, 1) OR L-HELD NOT = BE-XT(L-INDEX, 1) OR L-HELD-COUNT < BE-XI(L-INDEX, 2)
         MOVE 1 TO L-ACTION
         CALL "BE7-VAULT-FAIL-SOUND" USING L-INDEX L-TIME L-PLAY
         GOBACK
     END-IF
     CALL "BE7-UUID-IN" USING L-INDEX WS-BASE BE-XI(L-INDEX, 25) L-UUID WS-FOUND
     IF WS-FOUND = 1
         MOVE 2 TO L-ACTION
         CALL "BE7-VAULT-FAIL-SOUND" USING L-INDEX L-TIME L-PLAY
         GOBACK
     END-IF
     IF L-ROLLED = 0
         MOVE 3 TO L-ACTION
         GOBACK
     END-IF
     MOVE 4 TO L-ACTION
     IF L-CREATIVE = 0
         MOVE BE-XI(L-INDEX, 2) TO L-CONSUME
     END-IF
     MOVE L-ROLLED TO BE-XI(L-INDEX, 59) BE-XI(L-INDEX, 60)
     COMPUTE BE-SEED(L-INDEX) = L-TIME + 14
     CALL "BE7-VAULT-REWARD" USING L-INDEX L-UUID
     GOBACK.
 END PROGRAM BE7-VAULT-KEY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BE7-VAULT-CONNECT.
*> USING index, candidate UUIDs (BINARY-LONG table of 4 per player, at most 16), their number, changed out, any connected out: updateConnectedPlayersWithinRange of 5.5, the candidates that
*> are not rewarded replace the stored set when it differs and the shared data is marked dirty.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BESTATE.
 01 WS-KEEP.
    05 WS-K                BINARY-LONG OCCURS 128 TIMES.
 01 WS-N                   BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-B                   BINARY-LONG.
 01 WS-FOUND               BINARY-LONG.
 01 WS-BASE                BINARY-LONG VALUE 1.
 01 WS-STORED              BINARY-LONG VALUE 513.
 01 WS-CAND.
    05 WS-C                BINARY-LONG OCCURS 4 TIMES.
 01 WS-SAME                BINARY-LONG.
 LINKAGE SECTION.
 01 L-INDEX                BINARY-LONG.
 01 L-CANDIDATES.
    05 L-C                 BINARY-LONG OCCURS 64 TIMES.
 01 L-COUNT                BINARY-LONG.
 01 L-CHANGED              BINARY-LONG.
 01 L-ANY                  BINARY-LONG.
 PROCEDURE DIVISION USING L-INDEX L-CANDIDATES L-COUNT L-CHANGED L-ANY.
     MOVE 0 TO L-CHANGED WS-N
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > L-COUNT
         COMPUTE WS-B = (WS-I - 1) * 4
         PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > 4
             MOVE L-C(WS-B + WS-J) TO WS-C(WS-J)
         END-PERFORM
         CALL "BE7-UUID-IN" USING L-INDEX WS-BASE BE-XI(L-INDEX, 25) WS-CAND WS-FOUND
         IF WS-FOUND = 0
             PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > 4
                 MOVE WS-C(WS-J) TO WS-K(WS-N * 4 + WS-J)
             END-PERFORM
             ADD 1 TO WS-N
         END-IF
     END-PERFORM
     MOVE 1 TO WS-SAME
     IF WS-N NOT = BE-XI(L-INDEX, 8)
         MOVE 0 TO WS-SAME
     END-IF
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-N
         COMPUTE WS-B = (WS-I - 1) * 4
         PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > 4
             MOVE WS-K(WS-B + WS-J) TO WS-C(WS-J)
         END-PERFORM
         CALL "BE7-UUID-IN" USING L-INDEX WS-STORED BE-XI(L-INDEX, 8) WS-CAND WS-FOUND
         IF WS-FOUND = 0
             MOVE 0 TO WS-SAME
         END-IF
     END-PERFORM
     IF WS-SAME = 0
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-N * 4
             MOVE WS-K(WS-I) TO BE-UUID(L-INDEX, 512 + WS-I)
         END-PERFORM
         MOVE WS-N TO BE-XI(L-INDEX, 8)
         MOVE 1 TO BE-XI(L-INDEX, 61)
         MOVE 1 TO L-CHANGED
     END-IF
     MOVE 0 TO L-ANY
     IF BE-XI(L-INDEX, 8) > 0
         MOVE 1 TO L-ANY
     END-IF
     GOBACK.
 END PROGRAM BE7-VAULT-CONNECT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BE7-VAULT-RANGE.
*> USING squared distance, range (FLOAT-LONG), in range out: the detector test of 4.3 item 7 for the vault (5.5, example 7.10).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-DISTANCE             BINARY-LONG.
 01 L-RANGE                FLOAT-LONG.
 01 L-IN                   BINARY-LONG.
 PROCEDURE DIVISION USING L-DISTANCE L-RANGE L-IN.
     MOVE 0 TO L-IN
     IF L-DISTANCE < L-RANGE * L-RANGE
         MOVE 1 TO L-IN
     END-IF
     GOBACK.
 END PROGRAM BE7-VAULT-RANGE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BE7-SAVE.
*> USING index, type, PB-BUFFER: the custom keys of the types 9, 43 and 44 (BEX-SAVE of be-31-3.cob).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-NONE                BINARY-LONG VALUE 0.
 LINKAGE SECTION.
 COPY PROTO.
 01 L-INDEX                BINARY-LONG.
 01 L-TYPE                 BINARY-LONG.
 PROCEDURE DIVISION USING L-INDEX L-TYPE PB-BUFFER.
     EVALUATE L-TYPE
         WHEN 9
             CALL "BE7-SP-SAVE" USING L-INDEX PB-BUFFER WS-ONE
         WHEN 43
             CALL "BE7-TS-SAVE" USING L-INDEX PB-BUFFER
         WHEN 44
             CALL "BE7-VAULT-SAVE" USING L-INDEX PB-BUFFER WS-NONE
     END-EVALUATE
     GOBACK.
 END PROGRAM BE7-SAVE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BE7-LOAD-KEY.
*> USING index, key name (X(32)), tag, PB-BUFFER, handled out (BEX-LOAD-KEY of be-31-3.cob).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BESTATE.
 LINKAGE SECTION.
 COPY PROTO.
 01 L-INDEX                BINARY-LONG.
 01 L-NAME                 PIC X(32).
 01 L-TAG                  BINARY-LONG.
 01 L-HANDLED              BINARY-LONG.
 PROCEDURE DIVISION USING L-INDEX L-NAME L-TAG PB-BUFFER L-HANDLED.
     MOVE 0 TO L-HANDLED
     EVALUATE BE-TYPE(L-INDEX)
         WHEN 9
             CALL "BE7-SP-LOAD" USING L-INDEX L-NAME L-TAG PB-BUFFER L-HANDLED
         WHEN 43
             CALL "BE7-TS-LOAD" USING L-INDEX L-NAME L-TAG PB-BUFFER L-HANDLED
         WHEN 44
             CALL "BE7-VAULT-LOAD" USING L-INDEX L-NAME L-TAG PB-BUFFER L-HANDLED
     END-EVALUATE
     GOBACK.
 END PROGRAM BE7-LOAD-KEY.
