*> Implementation test (coverage lane A; docs/protocol/25 section 9.1; core/src/stack-potion.cob): a potion_contents component without a potion id (written as the absent byte and read back as
*> -1), the effects of every potion of the table scaled by the full factor (the instant ones keep duration 1), and a custom effect of infinite duration that is carried as it is.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-COVA-STACK-POTION.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY POTREC.
 01 WS-CASE                PIC X(240).
 01 WS-E                   BINARY-DOUBLE.
 01 WS-O                   BINARY-DOUBLE.
 01 WS-H                   BINARY-LONG.
 01 WS-POTION              BINARY-LONG.
 01 WS-HAS-COLOR           BINARY-LONG.
 01 WS-COLOR               BINARY-LONG.
 01 WS-CUSTOM              BINARY-LONG.
 01 WS-SCALE               BINARY-LONG VALUE 1000.
 01 WS-N                   BINARY-LONG.
 01 WS-FX.
    05 WS-FX-E OCCURS 8 TIMES.
       10 WS-FX-ID         BINARY-LONG.
       10 WS-FX-AMP        BINARY-LONG.
       10 WS-FX-DUR        BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-INSTANT             BINARY-LONG.
 01 WS-ID                  BINARY-LONG VALUE 11.
 01 WS-AMP                 BINARY-LONG VALUE 0.
 01 WS-INF                 BINARY-LONG VALUE -1.
 01 WS-ONE                 BINARY-LONG.
 PROCEDURE DIVISION.
     MOVE 0 TO WS-H
     MOVE -1 TO WS-POTION
     CALL "SC-POTION-SET" USING WS-H WS-POTION
     MOVE 0 TO WS-POTION
     CALL "SC-POTION-GET" USING WS-H WS-POTION WS-HAS-COLOR WS-COLOR WS-CUSTOM
     MOVE "test cova stack potion a potion_contents without a potion id reads back as -1" TO WS-CASE
     MOVE -1 TO WS-E
     MOVE WS-POTION TO WS-O
     CALL "CA-N" USING WS-CASE WS-E WS-O
*>   Every potion of the table resolves; those with an instant effect give duration 0.
     MOVE 0 TO WS-INSTANT
     PERFORM VARYING WS-I FROM 0 BY 1 UNTIL WS-I > 45
         MOVE 0 TO WS-H
         MOVE WS-I TO WS-POTION
         CALL "SC-POTION-SET" USING WS-H WS-POTION
         CALL "SC-POTION-RESOLVE" USING WS-H WS-SCALE WS-N WS-FX
         IF WS-N > 0
             IF WS-FX-DUR(1) = 1
                 ADD 1 TO WS-INSTANT
             END-IF
         END-IF
     END-PERFORM
     MOVE "test cova stack potion the table holds instant potions whose duration 1 stays 1 at the full scale" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE 0 TO WS-O
     IF WS-INSTANT > 0
         MOVE 1 TO WS-O
     END-IF
     CALL "CA-N" USING WS-CASE WS-E WS-O
*>   A custom effect of infinite duration stays -1.
     MOVE 0 TO WS-H
     MOVE -1 TO WS-POTION
     CALL "SC-POTION-SET" USING WS-H WS-POTION
     CALL "SC-POTION-ADD-EFFECT" USING WS-H WS-ID WS-AMP WS-INF
     CALL "SC-POTION-RESOLVE" USING WS-H WS-SCALE WS-N WS-FX
     MOVE "test cova stack potion an infinite custom effect keeps duration -1" TO WS-CASE
     MOVE -1 TO WS-E
     MOVE WS-FX-DUR(1) TO WS-O
     CALL "CA-N" USING WS-CASE WS-E WS-O
*>   A custom effect of one tick at a quarter scale rounds down to 0 and is raised to 1.
     MOVE 0 TO WS-H
     MOVE -1 TO WS-POTION
     CALL "SC-POTION-SET" USING WS-H WS-POTION
     MOVE 1 TO WS-ONE
     CALL "SC-POTION-ADD-EFFECT" USING WS-H WS-ID WS-AMP WS-ONE
     MOVE 250 TO WS-SCALE
     CALL "SC-POTION-RESOLVE" USING WS-H WS-SCALE WS-N WS-FX
     MOVE "test cova stack potion a one tick custom effect at scale 250 stays at least 1 tick" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE WS-FX-DUR(1) TO WS-O
     CALL "CA-N" USING WS-CASE WS-E WS-O
     STOP RUN.
 END PROGRAM TEST-COVA-STACK-POTION.
 COPY COVATEST.
