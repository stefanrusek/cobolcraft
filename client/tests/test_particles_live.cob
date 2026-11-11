*> Implementation test of client/src/particles-live.cob (docs/protocol/42-particles-1 sections 4 to 7,
*> 42-particles-2): the Level Particles packet (0x30) read by PROTO-PACKET spawns particles of the wired
*> types into the live store, CL-STEP ticks them from the client tick and meshes them into the frame's
*> particle vertex list (texture 4, translucent), and the particle atlas holds one sprite per type.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-PARTICLES-LIVE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLSTATE.
 COPY CLCONST.
 COPY CCSHIM.
 COPY CLPCL.
 COPY CLPSTORE.
 COPY TESTLIB.
 01 WS-SERVER              BINARY-LONG.
 01 WS-CONN                BINARY-LONG VALUE 1.
 01 WS-PATH                PIC X(256).
 01 WS-TYPE                BINARY-LONG.
 01 WS-CLASS               BINARY-LONG.
 01 WS-KIND                BINARY-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-SPREAD-TABLE.
    05 WS-SPREAD           FLOAT-SHORT OCCURS 6 TIMES.
 01 WS-COUNT               BINARY-LONG.
 01 WS-RANDOM              BINARY-LONG.
 01 WS-OVERRIDE            BINARY-LONG.
 01 WS-ALWAYS              BINARY-LONG.
 01 WS-NAME                PIC X(40).
 01 WS-VALUE               PIC X(4096).
 01 WS-LENGTH              BINARY-LONG.
 01 WS-OK                  BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-H                   BINARY-LONG.
 01 WS-LIVE                BINARY-LONG.
 01 WS-DRAWS               BINARY-LONG.
 01 WS-SUM                 FLOAT-LONG.
 01 WS-V0                  FLOAT-LONG.
 01 WS-V1                  FLOAT-LONG.
 01 WS-TYPES-DATA          PIC X(56) VALUE "00000055001300250014006900750011007400300077007200650073".
 01 WS-TYPES REDEFINES WS-TYPES-DATA.
    05 WS-T                PIC 9(4) OCCURS 14 TIMES.
 PROCEDURE DIVISION.
     MOVE "test particles live the particle record fits the 256-byte store field (240 bytes)"
         TO TL-CASE
     MOVE 240 TO TL-EXPECTED-N
     MOVE FUNCTION LENGTH(PCL) TO TL-OBSERVED-N
     MOVE "N" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE 13 TO WS-TYPE
     CALL "PARTICLE-CLASS" USING WS-TYPE WS-CLASS WS-KIND
     MOVE "test particles live crit (13) is class 2 kind 0" TO TL-CASE
     MOVE 20 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = WS-CLASS * 10 + WS-KIND
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 25 TO WS-TYPE
     CALL "PARTICLE-CLASS" USING WS-TYPE WS-CLASS WS-KIND
     MOVE "test particles live enchanted_hit (25) is class 2 kind 1" TO TL-CASE
     MOVE 21 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = WS-CLASS * 10 + WS-KIND
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO WS-TYPE
     CALL "PARTICLE-CLASS" USING WS-TYPE WS-CLASS WS-KIND
     MOVE "test particles live block (1) has no class" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-CLASS TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   The atlas: the built-in pack has no particle files, so each wired type is one 16 x 16 missing
*>   texture, stacked (14 types).
     CALL "CL-INIT" USING CLIENT-STATE
     CALL "PACK-STACK-INIT" USING CLIENT-STATE
     CALL "PARTICLE-ATLAS-BUILD" USING CLIENT-STATE
     MOVE "test particles live the atlas holds 14 types of one 16 x 16 sprite: 16 x 224, upload marked"
         TO TL-CASE
     MOVE 1622414 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = PRA-W * 100000 + PRA-H * 100 + PRA-SPRITES
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "test particles live the atlas upload of texture 4 is marked" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE AT-UPLOAD(5) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "test particles live a wired type has one sprite and an unwired type none" TO TL-CASE
     MOVE 10 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = PRA-COUNT(14) * 10 + PRA-COUNT(2)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   A started client in play over loopback; the world screen.
     CALL "TEST-PLAY" USING CLIENT-STATE WS-SERVER
     CALL "PARTICLE-ATLAS-BUILD" USING CLIENT-STATE
     CALL "TEST-STEP" USING CLIENT-STATE
     INITIALIZE WS-SPREAD-TABLE
     MOVE 3.0 TO WS-X
     MOVE 10.0 TO WS-Y
     MOVE 4.0 TO WS-Z
     MOVE 0 TO WS-COUNT WS-RANDOM WS-OVERRIDE WS-ALWAYS
     MOVE 13 TO WS-TYPE
     CALL "TEST-LEVEL-PARTICLE" USING CLIENT-STATE WS-CONN WS-TYPE WS-X WS-Y WS-Z WS-SPREAD-TABLE
         WS-COUNT WS-RANDOM WS-OVERRIDE WS-ALWAYS
     MOVE "test particles live a crit packet queues one particle, in no group before the next tick"
         TO TL-CASE
     MOVE 100 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = PQ-LIVE * 100 + EN-G-COUNT(1) * 10 + EN-ADD-COUNT - 1
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "TEST-TICKS" USING CLIENT-STATE 1
     MOVE "test particles live the next client tick inserts it into the quad group at age 1 (the constructor ticked once)" TO TL-CASE
     MOVE 11 TO TL-EXPECTED-N
     MOVE PQ-DATA(1)(1:240) TO PCL
     COMPUTE TL-OBSERVED-N = EN-G-COUNT(1) * 10 + PC-AGE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE PC-Y TO WS-V0
     MOVE PC-X TO WS-V1
     CALL "TEST-TICKS" USING CLIENT-STATE 2
     MOVE PQ-DATA(1)(1:240) TO PCL
     MOVE "test particles live two more ticks age it to 3 and move it" TO TL-CASE
     MOVE 31 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF PC-AGE = 3
         ADD 30 TO TL-OBSERVED-N
     END-IF
     IF PC-Y NOT = WS-V0 OR PC-X NOT = WS-V1
         ADD 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   The frame's vertex list: six vertices, the crit grey (0.6 to 0.9) with green and blue darker,
*>   alpha 1, a UV inside the type's atlas rectangle, drawn translucent with texture 4.
     MOVE "test particles live the frame holds the crit quad: six vertices" TO TL-CASE
     MOVE 6 TO TL-EXPECTED-N
     MOVE RL-PT-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "test particles live the quad's colour is a grey of 0.6 to 0.9, green and blue below red, alpha 1"
         TO TL-CASE
     MOVE 111 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF RL-PT-R(1) >= 0.59 AND RL-PT-R(1) <= 0.91
         ADD 100 TO TL-OBSERVED-N
     END-IF
     IF RL-PT-G(1) < RL-PT-R(1) AND RL-PT-BLUE(1) < RL-PT-G(1)
         ADD 10 TO TL-OBSERVED-N
     END-IF
     IF RL-PT-A(1) = 1
         ADD 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "test particles live every vertex's UV is inside the crit sprite's atlas rectangle" TO TL-CASE
     MOVE 6 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     COMPUTE WS-V0 = PRA-S-Y(PRA-FIRST(14)) / PRA-H
     COMPUTE WS-V1 = (PRA-S-Y(PRA-FIRST(14)) + PRA-S-H(PRA-FIRST(14))) / PRA-H
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 6
         IF RL-PT-U(WS-I) >= 0 AND RL-PT-U(WS-I) <= 1 AND RL-PT-V(WS-I) >= WS-V0 - 0.0001
                 AND RL-PT-V(WS-I) <= WS-V1 + 0.0001
             ADD 1 TO TL-OBSERVED-N
         END-IF
     END-PERFORM
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "test particles live the quad is centred on the particle, eye-relative" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO WS-SUM
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 6
         ADD RL-PT-Z(WS-I) TO WS-SUM
     END-PERFORM
     COMPUTE WS-SUM = WS-SUM / 6
     MOVE 0 TO TL-OBSERVED-N
     IF WS-SUM > 3.0 AND WS-SUM < 4.0
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-J
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > RL-DRAW-COUNT
         IF RL-D-TEX(WS-I) = CC-TEX-PARTICLES AND RL-D-SLOT(WS-I) = MESH-SLOT-PARTICLES
                 AND RL-D-PIPELINE(WS-I) = CC-PIPE-TRANSLUCENT
             ADD 1 TO WS-J
         END-IF
     END-PERFORM
     MOVE "test particles live the render list draws the particle mesh once, translucent, texture 4"
         TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-J TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   A type without a class (block, the fixture) spawns nothing.
     MOVE PQ-LIVE TO WS-LIVE
     MOVE "contract/fixtures/wire/play-s2c-30-level-particles.hex" TO WS-PATH
     CALL "TEST-FEED" USING CLIENT-STATE WS-CONN WS-PATH
     MOVE "test particles live a block particle packet (no class wired) adds nothing" TO TL-CASE
     MOVE WS-LIVE TO TL-EXPECTED-N
     MOVE PQ-LIVE TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   A packet cut short is dropped.
     MOVE 13 TO WS-TYPE
     CALL "PARTICLES-READ-BAD" USING CLIENT-STATE WS-CONN
     MOVE "test particles live a short Level Particles body adds nothing" TO TL-CASE
     MOVE WS-LIVE TO TL-EXPECTED-N
     MOVE PQ-LIVE TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Every wired type, then ticks: the classes tick and the short-lived ones end.
     CALL "PARTICLES-CLEAR" USING CLIENT-STATE
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 14
         MOVE WS-T(WS-I) TO WS-TYPE
         CALL "TEST-LEVEL-PARTICLE" USING CLIENT-STATE WS-CONN WS-TYPE WS-X WS-Y WS-Z WS-SPREAD-TABLE
             WS-COUNT WS-RANDOM WS-OVERRIDE WS-ALWAYS
     END-PERFORM
     MOVE "test particles live the 14 wired types each queue one particle" TO TL-CASE
     MOVE 14 TO TL-EXPECTED-N
     MOVE PQ-LIVE TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "TEST-TICKS" USING CLIENT-STATE 3
     MOVE "test particles live after three ticks all 14 are in the quad group" TO TL-CASE
     MOVE 14 TO TL-EXPECTED-N
     MOVE EN-G-COUNT(1) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "test particles live the frame holds six vertices for each of the 14" TO TL-CASE
     MOVE 84 TO TL-EXPECTED-N
     MOVE RL-PT-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "TEST-TICKS" USING CLIENT-STATE 12
     MOVE "test particles live after fifteen ticks the sweep attack and the explosion have ended"
         TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF PQ-LIVE < 14 AND PQ-LIVE = EN-G-COUNT(1)
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Count above 32 (alternative randomisation, no spread): 40 particles, chunked.
     CALL "PARTICLES-CLEAR" USING CLIENT-STATE
     MOVE 40 TO WS-COUNT
     MOVE 1 TO WS-RANDOM
     MOVE 13 TO WS-TYPE
     CALL "TEST-LEVEL-PARTICLE" USING CLIENT-STATE WS-CONN WS-TYPE WS-X WS-Y WS-Z WS-SPREAD-TABLE
         WS-COUNT WS-RANDOM WS-OVERRIDE WS-ALWAYS
     MOVE "test particles live count 40 spawns 40 particles" TO TL-CASE
     MOVE 40 TO TL-EXPECTED-N
     MOVE PQ-LIVE TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Default randomisation (gaussian draws) with a spread.
     CALL "PARTICLES-CLEAR" USING CLIENT-STATE
     MOVE 5 TO WS-COUNT
     MOVE 0 TO WS-RANDOM
     MOVE 1.0 TO WS-SPREAD(1) WS-SPREAD(2) WS-SPREAD(3)
     MOVE 0.1 TO WS-SPREAD(4) WS-SPREAD(5) WS-SPREAD(6)
     CALL "TEST-LEVEL-PARTICLE" USING CLIENT-STATE WS-CONN WS-TYPE WS-X WS-Y WS-Z WS-SPREAD-TABLE
         WS-COUNT WS-RANDOM WS-OVERRIDE WS-ALWAYS
     MOVE "test particles live five gaussian-spread particles" TO TL-CASE
     MOVE 5 TO TL-EXPECTED-N
     MOVE PQ-LIVE TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     INITIALIZE WS-SPREAD-TABLE

*>   Culling at creation: 32 blocks from the camera drops a non-forced particle, a forced one stays.
     CALL "PARTICLES-CLEAR" USING CLIENT-STATE
     MOVE 0 TO WS-COUNT
     MOVE 100.0 TO WS-X WS-Z
     CALL "TEST-LEVEL-PARTICLE" USING CLIENT-STATE WS-CONN WS-TYPE WS-X WS-Y WS-Z WS-SPREAD-TABLE
         WS-COUNT WS-RANDOM WS-OVERRIDE WS-ALWAYS
     MOVE "test particles live a crit 100 blocks away is dropped" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE PQ-LIVE TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO WS-OVERRIDE
     CALL "TEST-LEVEL-PARTICLE" USING CLIENT-STATE WS-CONN WS-TYPE WS-X WS-Y WS-Z WS-SPREAD-TABLE
         WS-COUNT WS-RANDOM WS-OVERRIDE WS-ALWAYS
     MOVE "test particles live the same packet with the override limiter is created" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE PQ-LIVE TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-OVERRIDE
     MOVE 3.0 TO WS-X
     MOVE 4.0 TO WS-Z
*>   The Particles option MINIMAL drops a non-forced particle.
     CALL "PARTICLES-CLEAR" USING CLIENT-STATE
     MOVE "particles" TO WS-NAME
     MOVE "2" TO WS-VALUE
     MOVE 1 TO WS-LENGTH
     CALL "OPTIONS-SET" USING CLIENT-STATE WS-NAME WS-VALUE WS-LENGTH WS-OK
     CALL "TEST-LEVEL-PARTICLE" USING CLIENT-STATE WS-CONN WS-TYPE WS-X WS-Y WS-Z WS-SPREAD-TABLE
         WS-COUNT WS-RANDOM WS-OVERRIDE WS-ALWAYS
     MOVE "test particles live with the Particles option minimal a nearby crit is dropped" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE PQ-LIVE TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "0" TO WS-VALUE
     CALL "OPTIONS-SET" USING CLIENT-STATE WS-NAME WS-VALUE WS-LENGTH WS-OK

*>   The store holds 2048 particles; more are dropped.
     CALL "PARTICLES-CLEAR" USING CLIENT-STATE
     MOVE 2100 TO WS-COUNT
     MOVE 1 TO WS-RANDOM
     CALL "TEST-LEVEL-PARTICLE" USING CLIENT-STATE WS-CONN WS-TYPE WS-X WS-Y WS-Z WS-SPREAD-TABLE
         WS-COUNT WS-RANDOM WS-OVERRIDE WS-ALWAYS
     MOVE "test particles live a count of 2100 fills the store to 2048 and drops the rest" TO TL-CASE
     MOVE 2048 TO TL-EXPECTED-N
     MOVE PQ-LIVE TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "TEST-TICKS" USING CLIENT-STATE 2
     MOVE "test particles live 2048 particles in the group mesh to 12288 vertices" TO TL-CASE
     MOVE 12288 TO TL-EXPECTED-N
     MOVE RL-PT-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Entering a dimension clears the store.
     CALL "DIMENSION-ENTER" USING CLIENT-STATE
     MOVE "test particles live entering a dimension clears the particles and the groups" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = PQ-LIVE + EN-G-COUNT(1) + EN-ADD-COUNT
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM TEST-PARTICLES-LIVE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PARTICLES-READ-BAD.
*> USING CLIENT-STATE, connection: hands PROTO-PACKET a Level Particles body of two bytes.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY PROTO.
 01 WS-CAPACITY            BINARY-LONG VALUE 16.
 01 WS-PACKET              BINARY-LONG VALUE 48.
 01 WS-TYPE                BINARY-LONG VALUE 13.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-CONN                 BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-CONN.
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-TYPE
     MOVE 0 TO PB-POS
     CALL "PROTO-PACKET" USING CLIENT-STATE L-CONN PB-BUFFER WS-PACKET
     CALL "PB-FREE" USING PB-BUFFER
     GOBACK.
 END PROGRAM PARTICLES-READ-BAD.

 COPY CLTEST.
