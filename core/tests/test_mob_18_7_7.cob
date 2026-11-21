*> Acceptance test (lane p49a; docs/protocol/18-mob-framework.md section 7.7 Status events): Entity Event (0x22) is an Int entity id and a Byte event id; every id of the
*> section's table is carried unchanged (1 jump, 3 death, 4 start attacking, 6 and 7 taming, 8 shake, 9 use item complete, 10 eat grass, 11 offer flower, 12 and 18 love hearts,
*> 13 and 14 villager, 15 witch magic, 16 zombie converting, 20 silverfish, 34 stop offer flower, 35 totem, 38 dolphin, 39 ravager stunned, 40 and 41 trusting, 42 villager sweat,
*> 45 fox eat, 46 teleport, 47 to 52 break item, 53 and 54 honey, 55 swap hands, 56 cancel shake, 58 and 59 ram, 60 poof, 61 tendrils, 62 sonic charge, 63 sniffer digging,
*> 64 armadillo peek, 65 and 68 break item, 66 shake, 67 drown particles, 69 ravager roared, 70 TNT prime, 71 boat sink, 72 boat launch). Which mob sends which event is asserted in the
*> tests of the mob's section (death 3 and 60 in test_stdmob_death, hearts 18 in acc_us15_breeding, drown 67 in test_mob_18_2_5).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-MOB-18-7-7.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY PROTO.
 01 WS-CAPACITY           BINARY-LONG VALUE 64.
 01 WS-ENTITY             BINARY-LONG VALUE 305419896.
 01 WS-EVENT              BINARY-LONG.
 01 WS-I                  BINARY-LONG.
 01 WS-BAD                BINARY-LONG.
 01 WS-LIST.
    05 WS-ID              BINARY-LONG OCCURS 60 TIMES.
 01 WS-COUNT              BINARY-LONG VALUE 0.
 01 WS-VIEW BASED.
    05 WS-BYTE             PIC X OCCURS 64 TIMES.
 PROCEDURE DIVISION.
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 72
         EVALUATE WS-I
             WHEN 1 THRU 21 WHEN 31 THRU 32 WHEN 34 THRU 35 WHEN 38 THRU 42 WHEN 45 THRU 56 WHEN 58 THRU 72
                 ADD 1 TO WS-COUNT
                 MOVE WS-I TO WS-ID(WS-COUNT)
         END-EVALUATE
     END-PERFORM
     MOVE 0 TO WS-BAD
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-COUNT
         MOVE WS-ID(WS-I) TO WS-EVENT
         CALL "PB-RESET" USING PB-BUFFER
         CALL "ENTITY-EVENT-BUILD" USING WS-ENTITY WS-EVENT PB-BUFFER
         SET ADDRESS OF WS-VIEW TO PB-ADDR
         IF PB-LENGTH NOT = 6 OR WS-BYTE(1) NOT = X"22" OR FUNCTION ORD(WS-BYTE(6)) NOT = WS-EVENT + 1
                 OR FUNCTION ORD(WS-BYTE(2)) NOT = 19 OR FUNCTION ORD(WS-BYTE(5)) NOT = 121
             ADD 1 TO WS-BAD
         END-IF
     END-PERFORM
     CALL "PB-FREE" USING PB-BUFFER
     MOVE "N" TO TL-MODE
     MOVE "acceptance US15 18§7.7 Status events: every event id of the table is carried as Int entity id and Byte event (0x22, 6 bytes)" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-BAD TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§7.7 Status events: the table has 57 ids in 1 to 72 (22 to 28 are player-only; 29, 30, 33, 36, 37, 43, 44 and 57 are not in it)" TO TL-CASE
     MOVE 57 TO TL-EXPECTED-N
     MOVE WS-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM TEST-MOB-18-7-7.
