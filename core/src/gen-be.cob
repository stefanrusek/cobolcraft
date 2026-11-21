*> The worldgen block-entity channel (GENBE.cpy; docs/design/world-types.md "Block entities of generated structures"): a structure placed by a generation job asks for the block entity
*> of the chest or spawner it wrote, because the chunk window holds block states only. The requests travel with the job like the overflow list (OV-KEEP, GEN-OVERFLOW) and are applied
*> to the installed chunk by WORLD-CHUNK-LOAD, through BE-BLOCK-SET (the path of a block a player places).
*>
*> Entry points:
*>   GBE-ADD USING x, y, z, kind (1 chest with a loot table, 2 spawner, 5 a scheduled fluid tick of the fluid at the position (delay 0: the second tick of the fortress's lava well, 36 part 8 5.7), 3 end gateway: the seed carries the flags 1 exit present and 2 exact, the text the exit as three signed numbers of 10 characters), loot table key (PIC X(48)), seed (BINARY-DOUBLE), text (PIC X(32), the spawner's entity id): appends a request
*>     to GEN-BE-LEVEL (at most GB-MAX; GBL-LOST counts the rest)
*>   GBE-KEEP USING job: appends the level's requests to the job's list (GJ-BE, bounded) and empties the level's list
*>   GBE-APPLY USING dimension row, chunk row: for each request of GEN-BE (GB-DATA) the entity of the block now at the position is made (a position that holds no block with an entity
*>     makes none); a chest gets its loot table and seed (rolled at the first open, 31-1 9.3), a spawner its entity id as the SpawnData key kept with the entity's other keys (EXTRAS.cpy);
*>     the list is emptied

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GBE-ADD.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY GENBE.
 LINKAGE SECTION.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-KIND                 BINARY-LONG.
 01 L-LOOT                 PIC X(48).
 01 L-SEED                 BINARY-DOUBLE.
 01 L-TEXT                 PIC X(32).
 PROCEDURE DIVISION USING L-X L-Y L-Z L-KIND L-LOOT L-SEED L-TEXT.
     IF GBL-COUNT >= GB-MAX
         ADD 1 TO GBL-LOST
         GOBACK
     END-IF
     ADD 1 TO GBL-COUNT
     MOVE L-X TO GBL-X(GBL-COUNT)
     MOVE L-Y TO GBL-Y(GBL-COUNT)
     MOVE L-Z TO GBL-Z(GBL-COUNT)
     MOVE L-KIND TO GBL-KIND(GBL-COUNT)
     MOVE L-LOOT TO GBL-LOOT(GBL-COUNT)
     MOVE L-SEED TO GBL-SEED(GBL-COUNT)
     MOVE L-TEXT TO GBL-TEXT(GBL-COUNT)
     GOBACK.
 END PROGRAM GBE-ADD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GBE-KEEP.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY GENBE.
 01 WS-I                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-JOB.
    COPY GENJOB REPLACING LEADING ==GJ-== BY ==J-==.
 PROCEDURE DIVISION USING L-JOB.
     ADD GBL-LOST TO J-BE-LOST
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > GBL-COUNT
         IF J-BE-COUNT < GB-MAX
             ADD 1 TO J-BE-COUNT
             MOVE GBL-ENTRY(WS-I) TO J-BE-ENTRY(J-BE-COUNT)
         ELSE
             ADD 1 TO J-BE-LOST
         END-IF
     END-PERFORM
     MOVE 0 TO GBL-COUNT GBL-LOST
     GOBACK.
 END PROGRAM GBE-KEEP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GBE-APPLY.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY DIMENSIONS.
 COPY CELLS.
 COPY BESTATE.
 COPY EXTRAS.
 COPY GENBE.
 01 WS-I                   BINARY-LONG.
 01 WS-INDEX               BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-AIR                 BINARY-LONG VALUE 0.
 01 WS-DELAY               BINARY-LONG VALUE 0.
 01 WS-FLUID               BINARY-LONG.
 01 WS-FKIND               BINARY-LONG.
 01 WS-FAMOUNT             BINARY-LONG.
 01 WS-FFALLING            BINARY-LONG.
 01 WS-CELL                BINARY-LONG.
 01 WS-LEN                 BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-TEXT                PIC X(160).
 01 WS-PTR                 BINARY-LONG.
 01 WS-CODE                PIC X.
 01 WS-FLAGS               BINARY-LONG.
 01 WS-EX                  BINARY-LONG.
 01 WS-EY                  BINARY-LONG.
 01 WS-EZ                  BINARY-LONG.
 01 WS-GNUMS.
    05 WS-GNUM             PIC S9(9) SIGN LEADING SEPARATE OCCURS 3 TIMES.
    05 FILLER              PIC X(2).
 01 WS-J                   BINARY-LONG.
 01 WS-REST                BINARY-DOUBLE.
 01 WS-DIV                 BINARY-LONG.
 01 WS-TICKS               BINARY-LONG.
 01 WS-BASE                BINARY-LONG.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-ZERO2               BINARY-LONG VALUE 0.
 01 WS-ZERO3               BINARY-LONG VALUE 0.
 01 WS-ADDED               BINARY-LONG.
 01 WS-ADOPTED             BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-ROW.
     SET ADDRESS OF CE-CHUNK TO CK-ADDR(L-ROW)
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > GB-COUNT
         COMPUTE WS-CELL = (GB-Y(WS-I) - DM-MIN-Y(L-DIM)) * 256 + (GB-Z(WS-I) - CK-Z(L-ROW) * 16) * 16
             + GB-X(WS-I) - CK-X(L-ROW) * 16 + 1
         MOVE CE-STATE(WS-CELL) TO WS-STATE
         EVALUATE GB-KIND(WS-I)
             WHEN 3
*>               kind 3: an end gateway the generator placed: GB-SEED the flags (1 exit present, 2 exact), GB-TEXT the exit as three 10-character signed numbers; the entity is of the
*>               gateway table (end-gateway.cob); the chunk's entity (type 22, only its Age) is made as well so that the chunk packet lists the gateway
                 MOVE GB-TEXT(WS-I) TO WS-GNUMS
                 MOVE GB-SEED(WS-I) TO WS-FLAGS
                 MOVE WS-GNUM(1) TO WS-EX
                 MOVE WS-GNUM(2) TO WS-EY
                 MOVE WS-GNUM(3) TO WS-EZ
                 CALL "END-GATEWAY-SET" USING L-DIM GB-X(WS-I) GB-Y(WS-I) GB-Z(WS-I) WS-FLAGS WS-EX WS-EY WS-EZ
*>               The block entity of the chunk too (type 22: its Age tag): a client creates the entity only from the chunk packet's list, and draws the gateway from it (52 section 8.1).
                 CALL "BE-BLOCK-SET" USING L-DIM GB-X(WS-I) GB-Y(WS-I) GB-Z(WS-I) WS-AIR WS-STATE
                 MOVE 0 TO WS-INDEX
             WHEN 5
*>               kind 5: a scheduled fluid tick (delay 0) of the fluid now at the position, the second tick of the lava well (36 part 8 5.7); none for a cell that holds no fluid
                 CALL "FLUID-OF-STATE" USING WS-STATE WS-FLUID WS-FKIND WS-FAMOUNT WS-FFALLING
                 IF WS-FLUID > 0
                     CALL "FLUID-SCHEDULE" USING L-DIM GB-X(WS-I) GB-Y(WS-I) GB-Z(WS-I) WS-FLUID WS-DELAY
                 END-IF
                 MOVE 0 TO WS-INDEX
             WHEN OTHER
                 CALL "BE-BLOCK-SET" USING L-DIM GB-X(WS-I) GB-Y(WS-I) GB-Z(WS-I) WS-AIR WS-STATE
                 CALL "BE-FIND" USING L-DIM GB-X(WS-I) GB-Y(WS-I) GB-Z(WS-I) WS-INDEX
         END-EVALUATE
         IF WS-INDEX > 0
             IF GB-KIND(WS-I) = 1
                 MOVE GB-LOOT(WS-I) TO BE-LOOT(WS-INDEX)
                 MOVE FUNCTION LENGTH(FUNCTION TRIM(GB-LOOT(WS-I))) TO BE-LOOT-LENGTH(WS-INDEX)
                 MOVE GB-SEED(WS-I) TO BE-SEED(WS-INDEX)
             ELSE
             IF GB-KIND(WS-I) = 4
*>               kind 4: a bee nest: n occupants (GB-SEED / 10^9) made as Occupant.create(ticks) (a bee with an empty tag, minimum 600, 31-4 section 8.3), their ticks in the hive
*>               from the three 3-digit groups of the seed
                 COMPUTE WS-N = GB-SEED(WS-I) / 1000000000
                 MOVE GB-SEED(WS-I) TO WS-REST
                 COMPUTE WS-REST = WS-REST - WS-N * 1000000000
                 PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > WS-N
                     CALL "BE4-HIVE-ENTER" USING WS-INDEX WS-ZERO WS-ZERO2 WS-ZERO3 WS-ADDED WS-ADOPTED
                     COMPUTE WS-DIV = 1000 ** (3 - WS-J)
                     COMPUTE WS-TICKS = WS-REST / WS-DIV
                     COMPUTE WS-REST = WS-REST - WS-TICKS * WS-DIV
                     COMPUTE WS-BASE = 6 + 4 * (WS-J - 1)
                     MOVE WS-TICKS TO BE-XI(WS-INDEX, WS-BASE)
                 END-PERFORM
             ELSE
*>               SpawnData: {entity: {id: "<id>"}} as the children of the entity's compound, the End tag last (7 section 10.7)
                 MOVE FUNCTION LENGTH(FUNCTION TRIM(GB-TEXT(WS-I))) TO WS-LEN
                 MOVE FUNCTION CHAR(WS-LEN + 1) TO WS-CODE
                 MOVE SPACES TO WS-TEXT
                 MOVE 1 TO WS-PTR
                 STRING X"0A0009" "SpawnData" X"0A0006" "entity" X"080002" "id" X"00" WS-CODE
                     GB-TEXT(WS-I)(1:WS-LEN) X"000000" DELIMITED BY SIZE INTO WS-TEXT POINTER WS-PTR
                 COMPUTE WS-N = WS-PTR - 1
                 MOVE WS-N TO EX-B-LEN(WS-INDEX)
                 MOVE WS-TEXT(1:WS-N) TO EX-B-DATA(WS-INDEX)
             END-IF
             END-IF
         END-IF
     END-PERFORM
     MOVE 0 TO GB-COUNT GB-LOST
     GOBACK.
 END PROGRAM GBE-APPLY.
