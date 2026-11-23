*> Implementation test (wrap I3, T2380/T2381; docs/protocol/19 section 18 with the table of section 1.3): the entity data of an axolotl, index 18 variant (INT 0 lucy, 1 wild, 2 gold, 3 cyan, 4 blue),
*> 19 playing dead (BOOLEAN) and 20 from bucket (BOOLEAN). They are sent after Add Entity (ENTITY-EXTRA-NEEDED / ENTITY-EXTRA-DATA), and the playing dead flag again when the play dead starts and
*> when it ends.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-MOB-AXOLOTL-DATA.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY CONTENT.
 COPY STDMOBS.
 COPY XORO.
 COPY PROTO REPLACING LEADING ==PB-== BY ==MQ-==.
 01 WS-CAPACITY            BINARY-LONG VALUE 65536.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-CONN                BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-X0                  BINARY-LONG.
 01 WS-Y0                  BINARY-LONG.
 01 WS-Z0                  BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-STATUS              BINARY-LONG.
 01 WS-ENTITY-ROW          PIC X(66).
 01 WS-AXOLOTL             BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-M                   BINARY-LONG.
 01 WS-NEEDED              BINARY-LONG.
 01 WS-WET                 BINARY-LONG VALUE 1.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 01 WS-IDS                 PIC X(1024).
 01 WS-PADDED              PIC X(1030).
 01 WS-TALLY               BINARY-LONG.
 01 WS-MDI                 BINARY-LONG.
 01 WS-MDV                 BINARY-LONG.
 01 WS-PK                  BINARY-LONG.
 01 WS-SEED                BINARY-DOUBLE UNSIGNED VALUE 7.
 01 WS-SPECIES             PIC X(48).
 01 WS-BX                  BINARY-LONG.
 01 WS-BY                  BINARY-LONG.
 01 WS-BZ                  BINARY-LONG.
 01 WS-SLOT                BINARY-LONG VALUE 1.
 01 WS-I                   BINARY-LONG.
 01 WS-DONE                BINARY-LONG.
 PROCEDURE DIVISION.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     CALL "AQ-TEST-TANK" USING WS-PLAYER WS-DIM WS-X0 WS-Y0 WS-Z0
     MOVE "N" TO TL-MODE
     MOVE PL-CONN(WS-PLAYER) TO WS-CONN
     CALL "PB-INIT" USING MQ-BUFFER WS-CAPACITY
     MOVE SPACES TO WS-KEY
     MOVE "minecraft:axolotl" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-AXOLOTL WS-ENTITY-ROW WS-STATUS
     CALL "STDMOB-INDEX" USING WS-AXOLOTL WS-M
     COMPUTE WS-X = WS-X0 + 2.5
     COMPUTE WS-Y = WS-Y0 + 3.5
     COMPUTE WS-Z = WS-Z0 + 4.5
     CALL "MOB-SPAWN" USING WS-DIM WS-AXOLOTL WS-X WS-Y WS-Z WS-YAW WS-ROW
     MOVE 4 TO EN-VARIANT(WS-ROW)
     CALL "ENTITY-EXTRA-NEEDED" USING WS-ROW WS-NEEDED
     MOVE "implementation 19 18 an axolotl always has entity data to send after Add Entity" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-NEEDED TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 18 TO WS-MDI
     PERFORM FIND-DATA
     MOVE "implementation 19 18 metadata 18 is the variant: cyan (EN-VARIANT 4) is 3" TO TL-CASE
     MOVE 3 TO TL-EXPECTED-N
     MOVE WS-MDV TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 19 TO WS-MDI
     PERFORM FIND-DATA
     MOVE "implementation 19 18 metadata 19 playing dead is false for a live axolotl" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-MDV TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 20 TO WS-MDI
     PERFORM FIND-DATA
     MOVE "implementation 19 18 metadata 20 from bucket is false for a spawned axolotl" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-MDV TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO EN-FROM-BUCKET(WS-ROW)
     PERFORM FIND-DATA
     MOVE "implementation 19 18 metadata 20 from bucket is true for an axolotl released from a bucket" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-MDV TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO EN-FROM-BUCKET(WS-ROW)
     MOVE 1 TO EN-VARIANT(WS-ROW)
     MOVE 18 TO WS-MDI
     PERFORM FIND-DATA
     MOVE "implementation 19 18 metadata 18 of the first variant (EN-VARIANT 1, lucy) is 0" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-MDV TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 17 TO WS-MDI
     PERFORM FIND-DATA
     MOVE "implementation 19 18 metadata 17 (age locked) is not sent while the age is not locked" TO TL-CASE
     MOVE -1 TO TL-EXPECTED-N
     MOVE WS-MDV TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO EN-LOCKED(WS-ROW)
     PERFORM FIND-DATA
     MOVE "implementation 19 18 metadata 17 (age locked) is true for a locked axolotl" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-MDV TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO EN-LOCKED(WS-ROW)
     MOVE 200 TO EN-IDLE(WS-ROW)
     MOVE 19 TO WS-MDI
     PERFORM FIND-DATA
     MOVE "implementation 19 18 metadata 19 playing dead is true while the play dead counter runs" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-MDV TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO EN-IDLE(WS-ROW)

*>   A viewer is sent Add Entity and the data at the spawn (the default entries), then the variant after the spawn's finalize, the play dead flag when it starts and when it ends, and the
*>   bucket flag when a bucket releases the mob (one Set Entity Data, 101, each).
     CALL "ENTITY-REMOVE" USING WS-ROW
     CALL "TEST-DRAIN-IDS" USING WS-CONN WS-IDS
     CALL "MOB-SPAWN" USING WS-DIM WS-AXOLOTL WS-X WS-Y WS-Z WS-YAW WS-ROW
     CALL "TEST-DRAIN-IDS" USING WS-CONN WS-IDS
     MOVE "T" TO TL-MODE
     MOVE "implementation 19 18 a viewer is sent Add Entity and the axolotl's entity data at the spawn (and the health pair, 101)" TO TL-CASE
     MOVE "1 101x2" TO TL-EXPECTED
     MOVE FUNCTION TRIM(WS-IDS) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "N" TO TL-MODE
     CALL "XORO-SEED" USING WS-SEED XR-STATE
     CALL "STDMOB-FINALIZE" USING XR-STATE WS-ROW
     CALL "TEST-DRAIN-IDS" USING WS-CONN WS-IDS
     MOVE "T" TO TL-MODE
     MOVE "implementation 19 18 the finalize sends the picked variant (one Set Entity Data)" TO TL-CASE
     MOVE "101" TO TL-EXPECTED
     MOVE FUNCTION TRIM(WS-IDS) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "N" TO TL-MODE
     CALL "AXOLOTL-PLAY-DEAD" USING WS-ROW
     CALL "TEST-DRAIN-IDS" USING WS-CONN WS-IDS
     MOVE "T" TO TL-MODE
     MOVE "implementation 19 18 starting to play dead sends metadata 19 to the viewers" TO TL-CASE
     MOVE "101" TO TL-EXPECTED
     MOVE FUNCTION TRIM(WS-IDS) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "N" TO TL-MODE
     MOVE 1 TO EN-IDLE(WS-ROW)
     CALL "AXOLOTL-TICK" USING WS-ROW WS-M WS-WET
     CALL "TEST-DRAIN-IDS" USING WS-CONN WS-IDS
     MOVE "T" TO TL-MODE
     MOVE "implementation 19 18 the end of the play dead counter sends metadata 19 false" TO TL-CASE
     MOVE "101" TO TL-EXPECTED
     MOVE FUNCTION TRIM(WS-IDS) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "N" TO TL-MODE
     MOVE 0 TO EN-IDLE(WS-ROW)
     CALL "AXOLOTL-PLAYING-DEAD" USING WS-ROW WS-NEEDED
     MOVE "implementation 19 18 the play dead counter is over" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-NEEDED TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "ENTITY-REMOVE" USING WS-ROW

*>   A bucket releases an axolotl into the water: Add Entity, the spawn data and the data again with the bucket flag.
     CALL "TEST-DRAIN-IDS" USING WS-CONN WS-IDS
     MOVE SPACES TO WS-SPECIES
     MOVE "axolotl" TO WS-SPECIES
     COMPUTE WS-BX = WS-X0 + 3
     COMPUTE WS-BY = WS-Y0 + 3
     COMPUTE WS-BZ = WS-Z0 + 3
     CALL "BUCKET-MOB-RELEASE" USING WS-PLAYER WS-SPECIES WS-BX WS-BY WS-BZ WS-SLOT
     CALL "TEST-DRAIN-IDS" USING WS-CONN WS-IDS
     MOVE "T" TO TL-MODE
     MOVE "implementation 19 18 a released axolotl is added, sent its data and sent the data again with the bucket flag" TO TL-CASE
     MOVE "1 101x3" TO TL-EXPECTED
     MOVE FUNCTION TRIM(WS-IDS) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "N" TO TL-MODE
     MOVE 0 TO WS-ROW
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > EN-COUNT
         IF EN-USED(WS-I) = 1 AND EN-TYPE(WS-I) = WS-AXOLOTL AND EN-FROM-BUCKET(WS-I) = 1
             MOVE WS-I TO WS-ROW
         END-IF
     END-PERFORM
     MOVE "implementation 19 18 the released axolotl is a mob with fromBucket set" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-ROW > 0
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 20 TO WS-MDI
     PERFORM FIND-DATA
     MOVE "implementation 19 18 the released axolotl's metadata 20 from bucket is true" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-MDV TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "ENTITY-REMOVE" USING WS-ROW
     STOP RUN.
 FIND-DATA.
     CALL "PB-RESET" USING MQ-BUFFER
     CALL "ENTITY-EXTRA-DATA" USING WS-ROW MQ-BUFFER
     CALL "PB-GET-VARINT" USING MQ-BUFFER WS-PK
     CALL "PB-GET-VARINT" USING MQ-BUFFER WS-PK
     MOVE -1 TO WS-MDV
     MOVE 0 TO WS-DONE
     PERFORM UNTIL WS-DONE = 1
         INITIALIZE MQ-METADATA-ENTRY-X
         CALL "PB-GET-METADATA-ENTRY-X" USING MQ-BUFFER MQ-METADATA-ENTRY-X
         IF MQ-MX-INDEX = MQ-MD-END OR MQ-ERROR = 1
             MOVE 1 TO WS-DONE
         ELSE
             IF MQ-MX-INDEX = WS-MDI
                 MOVE MQ-MX-INT TO WS-MDV
             END-IF
         END-IF
     END-PERFORM.
 END PROGRAM TEST-MOB-AXOLOTL-DATA.
 COPY CORETEST.
 COPY MOBSPTEST.
 COPY AQUATEST.
