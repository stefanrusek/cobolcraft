*> Implementation test of FLUID-FAST-KEY and FLUID-FAST (core/src/fluids-world-29a.cob; 29a sections 2.1 and 8.3): the dimension attribute gameplay/fast_lava
*> is true for the key minecraft:the_nether and false for every other dimension; the rows of the dimension table (cobolcraft:main, cobolcraft:subroutine, the
*> standard overworld) are all false. With it set, lava's push on an entity is 0.007 (EF-STRENGTH) instead of 0.007 / 3.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-FLUID-FAST.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 01 WS-KEY                 PIC X(32).
 01 WS-FLAG                BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-TEXT                PIC X(16).
 PROCEDURE DIVISION.
     MOVE "T" TO TL-MODE
     MOVE SPACES TO TL-OBSERVED
     MOVE "minecraft:the_nether" TO WS-KEY
     CALL "FLUID-FAST-KEY" USING WS-KEY WS-FLAG
     MOVE FUNCTION CHAR(WS-FLAG + 49) TO TL-OBSERVED(1:1)
     MOVE "minecraft:overworld" TO WS-KEY
     CALL "FLUID-FAST-KEY" USING WS-KEY WS-FLAG
     MOVE FUNCTION CHAR(WS-FLAG + 49) TO TL-OBSERVED(2:1)
     PERFORM VARYING WS-ROW FROM 1 BY 1 UNTIL WS-ROW > 3
         CALL "FLUID-FAST" USING WS-ROW WS-FLAG
         MOVE FUNCTION CHAR(WS-FLAG + 49) TO TL-OBSERVED(WS-ROW + 2:1)
     END-PERFORM
     MOVE "test fluid fast_lava is true for minecraft:the_nether only and false for the three dimensions of the table" TO TL-CASE
     MOVE "10000" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM TEST-FLUID-FAST.
