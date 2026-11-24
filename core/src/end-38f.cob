*> The saved state of the ender dragon fight (docs/protocol/45-entity-nbt-9 section 3; 38 section 1 has_ender_dragon_fight): the record ENDFIGHT.cpy, its write into and read from a
*> named-root NBT stream (the file <world>/dimensions/minecraft/the_end/data/minecraft/ender_dragon_fight.dat is the gzip of that stream: NBT-FILE-WRITE / PERSIST-READ-FILE with the
*> caller's path) and the gateway order of a new End. Boss behaviour is not here.
*>
*> Entry points:
*>   END-FIGHT-DEFAULT USING record: createDefault (needs_state_scanning true, everything else empty).
*>   END-FIGHT-WRITE USING PB-BUFFER (initialised), record: {DataVersion 5023, data {needs_state_scanning, dragon_killed, previously_killed, [respawn_stage], respawn_time,
*>     [dragon_uuid], [exit_portal_location], gateways, respawn_crystals}}.
*>   END-FIGHT-READ USING PB-BUFFER (PB-POS 0), record out: lenient: absent keys take the defaults, a UUID or portal array of the wrong length is absent, unknown keys are skipped.
*>   END-FIGHT-INIT USING world seed (signed), record: an empty gateway list becomes 0 to 19 shuffled by the Java LCG seeded with the seed (Util.shuffle: for i from 20 down to 2 swap
*>     the elements i - 1 and nextInt(i)); a list that is not empty keeps its order.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. END-FIGHT-DEFAULT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 LINKAGE SECTION.
 COPY ENDFIGHT REPLACING LEADING ==EF-== BY ==L-==.
 PROCEDURE DIVISION USING END-FIGHT.
     INITIALIZE END-FIGHT
     MOVE 1 TO L-SCAN
     GOBACK.
 END PROGRAM END-FIGHT-DEFAULT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. END-FIGHT-WRITE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WN                     PIC X(32).
 01 WL                     BINARY-LONG.
 01 WS-MINUS-ONE           BINARY-LONG VALUE -1.
 01 WS-VERSION             BINARY-LONG VALUE 5023.
 01 WS-T-NONE              BINARY-LONG VALUE 0.
 01 WS-T-INT               BINARY-LONG VALUE 3.
 01 WS-T-INTS              BINARY-LONG VALUE 11.
 01 WS-FOUR                BINARY-LONG VALUE 4.
 01 WS-THREE               BINARY-LONG VALUE 3.
 01 WS-I                   BINARY-LONG.
 01 WS-LEN                 BINARY-LONG.
 01 WS-STAGE-TEXT          PIC X(32).
 LINKAGE SECTION.
 COPY PROTO.
 COPY ENDFIGHT REPLACING LEADING ==EF-== BY ==L-==.
 PROCEDURE DIVISION USING PB-BUFFER END-FIGHT.
     CALL "PB-RESET" USING PB-BUFFER
     MOVE SPACES TO WN
     MOVE 0 TO WL
     CALL "NBT-WRITE-COMPOUND-BEGIN" USING PB-BUFFER WN WL
     MOVE "DataVersion" TO WN
     MOVE 11 TO WL
     CALL "NBT-WRITE-INT" USING PB-BUFFER WN WL WS-VERSION
     MOVE "data" TO WN
     MOVE 4 TO WL
     CALL "NBT-WRITE-COMPOUND-BEGIN" USING PB-BUFFER WN WL
     MOVE "needs_state_scanning" TO WN
     MOVE 20 TO WL
     CALL "NBT-WRITE-BYTE" USING PB-BUFFER WN WL L-SCAN
     MOVE "dragon_killed" TO WN
     MOVE 13 TO WL
     CALL "NBT-WRITE-BYTE" USING PB-BUFFER WN WL L-KILLED
     MOVE "previously_killed" TO WN
     MOVE 17 TO WL
     CALL "NBT-WRITE-BYTE" USING PB-BUFFER WN WL L-PREVIOUS
     IF L-STAGE > 0
         MOVE SPACES TO WS-STAGE-TEXT
         EVALUATE L-STAGE
             WHEN 1
                 MOVE "start" TO WS-STAGE-TEXT
                 MOVE 5 TO WS-LEN
             WHEN 2
                 MOVE "preparing_to_summon_pillars" TO WS-STAGE-TEXT
                 MOVE 27 TO WS-LEN
             WHEN 3
                 MOVE "summoning_pillars" TO WS-STAGE-TEXT
                 MOVE 17 TO WS-LEN
             WHEN 4
                 MOVE "summoning_dragon" TO WS-STAGE-TEXT
                 MOVE 16 TO WS-LEN
             WHEN OTHER
                 MOVE "end" TO WS-STAGE-TEXT
                 MOVE 3 TO WS-LEN
         END-EVALUATE
         MOVE "respawn_stage" TO WN
         MOVE 13 TO WL
         CALL "NBT-WRITE-STRING" USING PB-BUFFER WN WL WS-STAGE-TEXT WS-LEN
     END-IF
     MOVE "respawn_time" TO WN
     MOVE 12 TO WL
     CALL "NBT-WRITE-INT" USING PB-BUFFER WN WL L-TIME
     IF L-HAS-UUID = 1
         MOVE "dragon_uuid" TO WN
         MOVE 11 TO WL
         CALL "NBT-WRITE-INT-ARRAY" USING PB-BUFFER WN WL WS-FOUR L-UUID(1)
     END-IF
     IF L-HAS-PORTAL = 1
         MOVE "exit_portal_location" TO WN
         MOVE 20 TO WL
         CALL "NBT-WRITE-INT-ARRAY" USING PB-BUFFER WN WL WS-THREE L-PORTAL(1)
     END-IF
     MOVE "gateways" TO WN
     MOVE 8 TO WL
     IF L-GATEWAY-COUNT = 0
         CALL "NBT-WRITE-LIST-BEGIN" USING PB-BUFFER WN WL WS-T-NONE L-GATEWAY-COUNT
     ELSE
         CALL "NBT-WRITE-LIST-BEGIN" USING PB-BUFFER WN WL WS-T-INT L-GATEWAY-COUNT
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > L-GATEWAY-COUNT
             CALL "NBT-WRITE-INT" USING PB-BUFFER WN WS-MINUS-ONE L-GATEWAY(WS-I)
         END-PERFORM
     END-IF
     MOVE "respawn_crystals" TO WN
     MOVE 16 TO WL
     IF L-CRYSTAL-COUNT = 0
         CALL "NBT-WRITE-LIST-BEGIN" USING PB-BUFFER WN WL WS-T-NONE L-CRYSTAL-COUNT
     ELSE
         CALL "NBT-WRITE-LIST-BEGIN" USING PB-BUFFER WN WL WS-T-INTS L-CRYSTAL-COUNT
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > L-CRYSTAL-COUNT
             CALL "NBT-WRITE-INT-ARRAY" USING PB-BUFFER WN WS-MINUS-ONE WS-FOUR L-CRYSTAL(WS-I)
         END-PERFORM
     END-IF
     CALL "NBT-WRITE-COMPOUND-END" USING PB-BUFFER
     CALL "NBT-WRITE-COMPOUND-END" USING PB-BUFFER
     GOBACK.
 END PROGRAM END-FIGHT-WRITE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. END-FIGHT-READ-DATA.
*> USING PB-BUFFER (at the payload of the data compound), record: the keys of the data compound.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WN                     PIC X(32).
 01 WL                     BINARY-LONG.
 01 WS-NAME-CAPACITY       BINARY-LONG VALUE 32.
 01 WS-TEXT-CAPACITY       BINARY-LONG VALUE 32.
 01 WS-TYPE                BINARY-LONG.
 01 WS-TEXT                PIC X(32).
 01 WS-LEN                 BINARY-LONG.
 01 WS-VALUE               BINARY-LONG.
 01 WS-ET                  BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-INTS.
    05 WS-INT              BINARY-LONG OCCURS 4 TIMES.
 01 WS-CAP4                BINARY-LONG VALUE 4.
 01 WS-I                   BINARY-LONG.
 01 WS-C                   BINARY-LONG.
 LINKAGE SECTION.
 COPY PROTO.
 COPY ENDFIGHT REPLACING LEADING ==EF-== BY ==L-==.
 PROCEDURE DIVISION USING PB-BUFFER END-FIGHT.
     PERFORM UNTIL PB-ERROR = 1
         MOVE SPACES TO WN
         CALL "NBT-READ-COMPOUND-NEXT" USING PB-BUFFER WS-TYPE WN WS-NAME-CAPACITY WL
         IF WS-TYPE = 0
             EXIT PERFORM
         END-IF
         EVALUATE TRUE
             WHEN WN = "needs_state_scanning" AND WS-TYPE = 1
                 CALL "PB-GET-BYTE" USING PB-BUFFER L-SCAN
             WHEN WN = "dragon_killed" AND WS-TYPE = 1
                 CALL "PB-GET-BYTE" USING PB-BUFFER L-KILLED
             WHEN WN = "previously_killed" AND WS-TYPE = 1
                 CALL "PB-GET-BYTE" USING PB-BUFFER L-PREVIOUS
             WHEN WN = "respawn_time" AND WS-TYPE = 3
                 CALL "PB-GET-INT" USING PB-BUFFER L-TIME
             WHEN WN = "respawn_stage" AND WS-TYPE = 8
                 MOVE SPACES TO WS-TEXT
                 CALL "NBT-READ-STRING" USING PB-BUFFER WS-TEXT WS-TEXT-CAPACITY WS-LEN
                 MOVE 0 TO L-STAGE
                 EVALUATE WS-TEXT
                     WHEN "start"
                         MOVE 1 TO L-STAGE
                     WHEN "preparing_to_summon_pillars"
                         MOVE 2 TO L-STAGE
                     WHEN "summoning_pillars"
                         MOVE 3 TO L-STAGE
                     WHEN "summoning_dragon"
                         MOVE 4 TO L-STAGE
                     WHEN "end"
                         MOVE 5 TO L-STAGE
                 END-EVALUATE
             WHEN WN = "dragon_uuid" AND WS-TYPE = 11
                 CALL "NBT-READ-INT-ARRAY" USING PB-BUFFER WS-CAP4 WS-COUNT WS-INTS
                 IF WS-COUNT = 4
                     MOVE 1 TO L-HAS-UUID
                     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 4
                         MOVE WS-INT(WS-I) TO L-UUID(WS-I)
                     END-PERFORM
                 END-IF
             WHEN WN = "exit_portal_location" AND WS-TYPE = 11
                 CALL "NBT-READ-INT-ARRAY" USING PB-BUFFER WS-CAP4 WS-COUNT WS-INTS
                 IF WS-COUNT = 3
                     MOVE 1 TO L-HAS-PORTAL
                     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 3
                         MOVE WS-INT(WS-I) TO L-PORTAL(WS-I)
                     END-PERFORM
                 END-IF
             WHEN WN = "gateways" AND WS-TYPE = 9
                 CALL "NBT-READ-LIST-BEGIN" USING PB-BUFFER WS-ET WS-COUNT
                 MOVE 0 TO L-GATEWAY-COUNT
                 PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-COUNT OR PB-ERROR = 1
                     IF WS-ET = 3
                         CALL "PB-GET-INT" USING PB-BUFFER WS-VALUE
                         IF L-GATEWAY-COUNT < 20
                             ADD 1 TO L-GATEWAY-COUNT
                             MOVE WS-VALUE TO L-GATEWAY(L-GATEWAY-COUNT)
                         END-IF
                     ELSE
                         CALL "NBT-READ-SKIP" USING PB-BUFFER WS-ET
                     END-IF
                 END-PERFORM
             WHEN WN = "respawn_crystals" AND WS-TYPE = 9
                 CALL "NBT-READ-LIST-BEGIN" USING PB-BUFFER WS-ET WS-COUNT
                 MOVE 0 TO L-CRYSTAL-COUNT
                 PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-COUNT OR PB-ERROR = 1
                     IF WS-ET = 11
                         CALL "NBT-READ-INT-ARRAY" USING PB-BUFFER WS-CAP4 WS-C WS-INTS
                         IF WS-C = 4 AND L-CRYSTAL-COUNT < 8
                             ADD 1 TO L-CRYSTAL-COUNT
                             PERFORM VARYING WS-VALUE FROM 1 BY 1 UNTIL WS-VALUE > 4
                                 MOVE WS-INT(WS-VALUE) TO L-CRYSTAL-UUID(L-CRYSTAL-COUNT, WS-VALUE)
                             END-PERFORM
                         END-IF
                     ELSE
                         CALL "NBT-READ-SKIP" USING PB-BUFFER WS-ET
                     END-IF
                 END-PERFORM
             WHEN OTHER
                 CALL "NBT-READ-SKIP" USING PB-BUFFER WS-TYPE
         END-EVALUATE
     END-PERFORM
     GOBACK.
 END PROGRAM END-FIGHT-READ-DATA.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. END-FIGHT-READ.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WN                     PIC X(32).
 01 WL                     BINARY-LONG.
 01 WS-NAME-CAPACITY       BINARY-LONG VALUE 32.
 01 WS-FRAMING             BINARY-LONG VALUE 1.
 01 WS-TYPE                BINARY-LONG.
 LINKAGE SECTION.
 COPY PROTO.
 COPY ENDFIGHT REPLACING LEADING ==EF-== BY ==L-==.
 PROCEDURE DIVISION USING PB-BUFFER END-FIGHT.
     CALL "END-FIGHT-DEFAULT" USING END-FIGHT
     MOVE 0 TO PB-POS
     CALL "NBT-READ-ROOT" USING PB-BUFFER WS-FRAMING WS-TYPE
     PERFORM UNTIL PB-ERROR = 1
         MOVE SPACES TO WN
         CALL "NBT-READ-COMPOUND-NEXT" USING PB-BUFFER WS-TYPE WN WS-NAME-CAPACITY WL
         IF WS-TYPE = 0
             EXIT PERFORM
         END-IF
         IF WN = "data" AND WS-TYPE = 10
             CALL "END-FIGHT-READ-DATA" USING PB-BUFFER END-FIGHT
         ELSE
             CALL "NBT-READ-SKIP" USING PB-BUFFER WS-TYPE
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM END-FIGHT-READ.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. END-FIGHT-INIT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-U                   BINARY-DOUBLE UNSIGNED.
 01 WS-R                   BINARY-DOUBLE UNSIGNED.
 01 WS-I                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-T                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-SEED                 BINARY-DOUBLE.
 COPY ENDFIGHT REPLACING LEADING ==EF-== BY ==L-==.
 PROCEDURE DIVISION USING L-SEED END-FIGHT.
     IF L-GATEWAY-COUNT = 0
         IF L-SEED < 0
             COMPUTE WS-U = L-SEED + 18446744073709551616
         ELSE
             MOVE L-SEED TO WS-U
         END-IF
         CALL "JRAND-SET-SEED" USING WS-R WS-U
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 20
             COMPUTE L-GATEWAY(WS-I) = WS-I - 1
         END-PERFORM
         MOVE 20 TO L-GATEWAY-COUNT
         PERFORM VARYING WS-I FROM 20 BY -1 UNTIL WS-I < 2
             CALL "JRAND-NEXT-INT-BOUND" USING WS-R WS-I WS-J
             COMPUTE WS-K = WS-J + 1
             MOVE L-GATEWAY(WS-I) TO WS-T
             MOVE L-GATEWAY(WS-K) TO L-GATEWAY(WS-I)
             MOVE WS-T TO L-GATEWAY(WS-K)
         END-PERFORM
     END-IF
     GOBACK.
 END PROGRAM END-FIGHT-INIT.
