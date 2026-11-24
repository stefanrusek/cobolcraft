*> Implementation test (lane p49v; docs/protocol/20-mobs-overworld-hostile.md section 3.7 and the metadata rows of 4.1, 4.3, 6.1 and 10): the own fields of a mob class start at index 16 (Entity 0 to 7,
*> LivingEntity 8 to 14, Mob 15), so the first entry the core sends for a zombie or husk (baby) is index 16 BOOLEAN, a powered creeper index 17 BOOLEAN, a slime its size at index 18 INT (the cube adds ID_SIZE
*> after the baby flag and the age lock); every entry is followed by the end marker 0xFF.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-MOB-20-3-7.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY CONTENT.
 COPY PROTO.
 COPY STDMOBS.
 01 WS-CASE                PIC X(240).
 01 WS-E                   BINARY-DOUBLE.
 01 WS-O                   BINARY-DOUBLE.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-ENTITY-ROW          PIC X(66).
 01 WS-STATUS              BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-POS                 BINARY-LONG.
 01 WS-CAPACITY            BINARY-LONG VALUE 256.
 01 WS-FX                  FLOAT-LONG.
 01 WS-FY                  FLOAT-LONG.
 01 WS-FZ                  FLOAT-LONG.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 01 WS-INDEX               BINARY-LONG.
 01 WS-SERIALIZER          BINARY-LONG.
 01 WS-LAST                BINARY-LONG.
 01 WS-CASES.
    05 FILLER              PIC X(29) VALUE "minecraft:zombie        11608".
    05 FILLER              PIC X(29) VALUE "minecraft:husk          11608".
    05 FILLER              PIC X(29) VALUE "minecraft:creeper       11708".
    05 FILLER              PIC X(29) VALUE "minecraft:slime         41801".
 01 WS-CASE-TABLE REDEFINES WS-CASES.
    05 WS-CASE-ROW         OCCURS 4 TIMES.
       10 WS-CASE-KEY      PIC X(24).
       10 WS-CASE-VARIANT  PIC 9.
       10 WS-CASE-INDEX    PIC 99.
       10 WS-CASE-SER      PIC 99.
 01 WS-VIEW BASED.
    05 WS-BYTE             PIC X OCCURS 64 TIMES.
 PROCEDURE DIVISION.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     MOVE PL-X(WS-PLAYER) TO WS-FX
     MOVE PL-Y(WS-PLAYER) TO WS-FY
     MOVE PL-Z(WS-PLAYER) TO WS-FZ
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 4
         MOVE SPACES TO WS-KEY
         MOVE WS-CASE-KEY(WS-I) TO WS-KEY
         CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE WS-ENTITY-ROW WS-STATUS
         CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-FX WS-FY WS-FZ WS-YAW WS-ROW
         MOVE WS-CASE-VARIANT(WS-I) TO EN-VARIANT(WS-ROW)
         CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
         CALL "STDMOB-VARIANT-BUILD" USING WS-ROW PB-BUFFER
         SET ADDRESS OF WS-VIEW TO PB-ADDR
         COMPUTE WS-POS = 2
         IF EN-ID(WS-ROW) < 128
             ADD 1 TO WS-POS
         ELSE
             ADD 2 TO WS-POS
         END-IF
         COMPUTE WS-INDEX = FUNCTION ORD(WS-BYTE(WS-POS)) - 1
         COMPUTE WS-SERIALIZER = FUNCTION ORD(WS-BYTE(WS-POS + 1)) - 1
         MOVE "acceptance US15 20§3.7 Common entity metadata base indices: the first own entry is at the index of its class (16, 17 or 18, never below 16)" TO WS-CASE
         COMPUTE WS-E = WS-CASE-INDEX(WS-I)
         MOVE WS-INDEX TO WS-O
         PERFORM CHECK-N
         MOVE "acceptance US15 20§3.7 Common entity metadata base indices: and its serializer (8 BOOLEAN, 1 INT)" TO WS-CASE
         COMPUTE WS-E = WS-CASE-SER(WS-I)
         MOVE WS-SERIALIZER TO WS-O
         PERFORM CHECK-N
         COMPUTE WS-LAST = FUNCTION ORD(WS-BYTE(PB-LENGTH)) - 1
         MOVE "acceptance US15 20§3.7 Common entity metadata base indices: the list ends with the marker 255" TO WS-CASE
         MOVE 255 TO WS-E
         MOVE WS-LAST TO WS-O
         PERFORM CHECK-N
         CALL "PB-FREE" USING PB-BUFFER
     END-PERFORM
     STOP RUN.

 CHECK-N.
     MOVE "N" TO TL-MODE
     MOVE WS-CASE TO TL-CASE
     MOVE WS-E TO TL-EXPECTED-N
     MOVE WS-O TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-MOB-20-3-7.
 COPY CORETEST.
 COPY MOBSPTEST.
