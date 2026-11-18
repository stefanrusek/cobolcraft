*> Acceptance test (002-lane-p49b; docs/protocol/21 section 1): the metadata index conventions in the Set Entity Data (0x65) a viewer is sent. Every entity has indexes 0 to 7, every
*> living entity 8 to 14, every Mob 15, so mob-specific indexes start at 16 (zombie baby flag 16, ghast charging 16, blaze flags 16); ageable mobs add 16 and 17, so their own fields
*> start at 18 (slime and magma cube size 18); fish add 16 = from bucket, so their own fields start at 17 (salmon, tropical fish and pufferfish variant 17). A Creeper has 16 swell
*> direction, so powered is 17 and ignited 18. Per mob: the first entry is packet id 0x65, entity id, then the index byte and the serializer byte (Boolean 8, Byte 0, Int 1), the end 0xFF;
*> a mob in its default state sends nothing.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-MOB-21-1.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY CONTENT.
 COPY PROTO.
 01 WS-CAPACITY            BINARY-LONG VALUE 4096.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-ENTITY-ROW          PIC X(66).
 01 WS-STATUS              BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 01 WS-I                   BINARY-LONG.
 01 WS-IDX                 BINARY-LONG.

 01 WS-LEN                 BINARY-LONG.
 01 WS-VALUE               BINARY-LONG.
 01 WS-SER                 BINARY-LONG.
*> mob, variant to set, expected index, expected serializer id.
 01 WS-DATA.
    05 FILLER              PIC X(28) VALUE "zombie         1 16 8".
    05 FILLER              PIC X(28) VALUE "husk           1 16 8".
    05 FILLER              PIC X(28) VALUE "ghast          1 16 8".
    05 FILLER              PIC X(28) VALUE "blaze          1 16 0".
    05 FILLER              PIC X(28) VALUE "creeper        1 17 8".
    05 FILLER              PIC X(28) VALUE "slime          2 18 1".
    05 FILLER              PIC X(28) VALUE "magma_cube     2 18 1".
    05 FILLER              PIC X(28) VALUE "pufferfish     1 17 1".
    05 FILLER              PIC X(28) VALUE "salmon         2 17 1".
    05 FILLER              PIC X(28) VALUE "tropical_fish  2 17 1".
 01 WS-TABLE REDEFINES WS-DATA.
    05 WS-LINE OCCURS 10 TIMES.
       10 WS-L-NAME        PIC X(14).
       10 FILLER           PIC X.
       10 WS-L-VARIANT     PIC 9.
       10 FILLER           PIC X.
       10 WS-L-INDEX       PIC 99.
       10 FILLER           PIC X.
       10 WS-L-SER         PIC 9.
       10 FILLER           PIC X(7).
 01 WS-VIEW BASED.
    05 WS-BYTE             PIC X OCCURS 64 TIMES.
 PROCEDURE DIVISION.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     MOVE PL-X(WS-PLAYER) TO WS-X
     MOVE PL-Y(WS-PLAYER) TO WS-Y
     COMPUTE WS-Z = PL-Z(WS-PLAYER) + 6
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 10
         MOVE SPACES TO WS-KEY
         STRING "minecraft:" DELIMITED BY SIZE WS-L-NAME(WS-I) DELIMITED BY SPACE INTO WS-KEY
         CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE WS-ENTITY-ROW WS-STATUS
         CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-X WS-Y WS-Z WS-YAW WS-ROW
         MOVE WS-L-VARIANT(WS-I) TO EN-VARIANT(WS-ROW)
         CALL "PB-RESET" USING PB-BUFFER
         CALL "STDMOB-VARIANT-BUILD" USING WS-ROW PB-BUFFER
         SET ADDRESS OF WS-VIEW TO PB-ADDR
         MOVE PB-LENGTH TO WS-LEN
         MOVE "N" TO TL-MODE
         MOVE SPACES TO TL-CASE
         STRING "acceptance US15 21§1 " DELIMITED BY SIZE WS-L-NAME(WS-I) DELIMITED BY SPACE
             " metadata: packet 0x65, index and serializer, end 0xFF" DELIMITED BY SIZE INTO TL-CASE
         COMPUTE TL-EXPECTED-N = 101 * 10000 + WS-L-INDEX(WS-I) * 100 + WS-L-SER(WS-I)
         MOVE 0 TO TL-OBSERVED-N
         IF WS-LEN >= 6 AND WS-BYTE(WS-LEN) = X"FF"
             COMPUTE TL-OBSERVED-N = (FUNCTION ORD(WS-BYTE(1)) - 1) * 10000 + (FUNCTION ORD(WS-BYTE(3)) - 1) * 100
                 + FUNCTION ORD(WS-BYTE(4)) - 1
         END-IF
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
         MOVE 0 TO EN-VARIANT(WS-ROW)
*>       A ghast and a blaze send their flag for either value (21 sections 5.1, 5.2); every other mob sends nothing in its default state.
         IF WS-L-NAME(WS-I) NOT = "ghast" AND WS-L-NAME(WS-I) NOT = "blaze"
             CALL "PB-RESET" USING PB-BUFFER
             CALL "STDMOB-VARIANT-BUILD" USING WS-ROW PB-BUFFER
             MOVE SPACES TO TL-CASE
             STRING "acceptance US15 21§1 " DELIMITED BY SIZE WS-L-NAME(WS-I) DELIMITED BY SPACE
                 " in its default state sends nothing" DELIMITED BY SIZE INTO TL-CASE
             MOVE 0 TO TL-EXPECTED-N
             MOVE PB-LENGTH TO TL-OBSERVED-N
             CALL "TEST-ASSERT" USING TESTLIB-ASSERT
         END-IF
         CALL "ENTITY-REMOVE" USING WS-ROW
     END-PERFORM
     STOP RUN.
 END PROGRAM TEST-MOB-21-1.
 COPY CORETEST.
 COPY MOBSPTEST.
