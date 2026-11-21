*> Test of the enchantment definitions (core/src/ench-def.cob; lane itemcomp2, T10102) over the built-in network NBT entry of the cobolcraft set (efficiency: max level 5, anvil cost 1, weight 10,
*> supported items #minecraft:enchantable/mining): ENCH-DEF, the unknown id of ENCH-CAN, ENCH-COMPATIBLE of an enchantment with itself and ENCH-IS-CURSE.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-ENCH-DEF.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY COREAPI.
 01 WS-ID                  BINARY-LONG VALUE 0.
 01 WS-ID2                 BINARY-LONG VALUE 0.
 01 WS-MAX                 BINARY-LONG.
 01 WS-ANVIL               BINARY-LONG.
 01 WS-WEIGHT              BINARY-LONG.
 01 WS-TAG                 PIC X(112).
 01 WS-EXCL                PIC X(112).
 01 WS-FOUND               BINARY-LONG.
 01 WS-BAD                 BINARY-LONG VALUE 999.
 01 WS-ITEM                BINARY-LONG VALUE 1.
 01 WS-CAN                 BINARY-LONG.
 01 WS-OK                  BINARY-LONG.
 01 WS-CURSE               BINARY-LONG.
 01 WS-E1                  PIC -(9)9.
 01 WS-E2                  PIC -(9)9.
 01 WS-E3                  PIC -(9)9.
 01 WS-E4                  PIC -(9)9.
 01 WS-MINB                BINARY-LONG.
 01 WS-MINP                BINARY-LONG.
 01 WS-MAXB                BINARY-LONG.
 01 WS-MAXP                BINARY-LONG.
 PROCEDURE DIVISION.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     MOVE "T" TO TL-MODE
     MOVE "test ench def the built-in efficiency entry: max level 5, anvil cost 1, weight 10 and its supported tag" TO TL-CASE
     CALL "ENCH-DEF" USING WS-ID WS-MAX WS-ANVIL WS-WEIGHT WS-TAG WS-EXCL WS-FOUND
     MOVE WS-MAX TO WS-E1
     MOVE WS-ANVIL TO WS-E2
     MOVE WS-WEIGHT TO WS-E3
     MOVE WS-FOUND TO WS-E4
     MOVE SPACES TO TL-OBSERVED
     STRING FUNCTION TRIM(WS-E1) " " FUNCTION TRIM(WS-E2) " " FUNCTION TRIM(WS-E3) " " FUNCTION TRIM(WS-E4) " " FUNCTION TRIM(WS-TAG) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "5 1 10 1 minecraft:enchantable/mining" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "test ench def an unknown id is not found and supports nothing; an enchantment is compatible with itself; none is a curse here" TO TL-CASE
     CALL "ENCH-DEF" USING WS-BAD WS-MAX WS-ANVIL WS-WEIGHT WS-TAG WS-EXCL WS-FOUND
     MOVE WS-FOUND TO WS-E1
     CALL "ENCH-CAN" USING WS-BAD WS-ITEM WS-CAN
     MOVE WS-CAN TO WS-E2
     CALL "ENCH-COMPATIBLE" USING WS-ID WS-ID2 WS-OK
     MOVE WS-OK TO WS-E3
     CALL "ENCH-IS-CURSE" USING WS-ID WS-CURSE
     MOVE WS-CURSE TO WS-E4
     MOVE SPACES TO TL-OBSERVED
     STRING FUNCTION TRIM(WS-E1) " " FUNCTION TRIM(WS-E2) " " FUNCTION TRIM(WS-E3) " " FUNCTION TRIM(WS-E4) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "0 0 1 0" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "test ench def costs: the built-in network NBT entry has no cost fields (0 0 0 0) and its primary items are its supported tag" TO TL-CASE
     CALL "ENCH-COST-DEF" USING WS-ID WS-MINB WS-MINP WS-MAXB WS-MAXP WS-TAG WS-FOUND
     MOVE WS-MINB TO WS-E1
     MOVE WS-MAXB TO WS-E2
     MOVE WS-FOUND TO WS-E3
     MOVE SPACES TO TL-OBSERVED
     STRING FUNCTION TRIM(WS-E1) " " FUNCTION TRIM(WS-E2) " " FUNCTION TRIM(WS-E3) " " FUNCTION TRIM(WS-TAG) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "0 0 1 minecraft:enchantable/mining" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM TEST-ENCH-DEF.
 COPY CORETEST.
