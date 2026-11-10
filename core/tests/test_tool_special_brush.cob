*> Test of the special item brush (17 section 2.6; core/src/tools-special.cob TOOL-SPECIAL-STATS, TOOL-SPECIAL-COMPONENT): its stack size,
*> durability (0 none), rarity (common by default), enchantability (-1: no enchantable component), repair ingredient (an item key or a #tag,
*> without the namespace; none) and the listed components and stats.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-TOOL-SPECIAL-BRUSH.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY COREAPI.
 COPY CONTENT.
 01 WS-KEY                 PIC X(48).
 01 WS-FOUND               BINARY-LONG.
 01 WS-STACK               BINARY-LONG.
 01 WS-DURABILITY          BINARY-LONG.
 01 WS-ENCHANT             BINARY-LONG.
 01 WS-RARITY              PIC X(12).
 01 WS-REPAIR              PIC X(40).
 01 WS-NAME                PIC X(32).
 01 WS-VALUE               PIC X(100).
 01 WS-E1                  PIC -(9)9.
 01 WS-E2                  PIC -(9)9.
 01 WS-E3                  PIC -(9)9.
 PROCEDURE DIVISION.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     MOVE CT-TYPE-STANDARD TO CT-SET-TYPE

     MOVE "acceptance US14 brush stack size 1, durability 64, rarity common, enchantability -1, repair none" TO TL-CASE
     MOVE "brush" TO WS-KEY
     CALL "TOOL-SPECIAL-STATS" USING WS-KEY WS-FOUND WS-STACK WS-DURABILITY WS-ENCHANT WS-RARITY WS-REPAIR
     MOVE WS-FOUND TO WS-E1
     MOVE WS-STACK TO WS-E2
     MOVE WS-DURABILITY TO WS-E3
     MOVE SPACES TO TL-OBSERVED
     STRING "found " FUNCTION TRIM(WS-E1) " stack " FUNCTION TRIM(WS-E2) " durability " FUNCTION TRIM(WS-E3) " rarity "
         FUNCTION TRIM(WS-RARITY) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE WS-ENCHANT TO WS-E1
     STRING FUNCTION TRIM(TL-OBSERVED) " enchantability " FUNCTION TRIM(WS-E1) " repair " FUNCTION TRIM(WS-REPAIR)
         DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "found 1 stack 1 durability 64 rarity common enchantability -1 repair none" TO TL-EXPECTED
     PERFORM CHECK-DONE

     MOVE "acceptance US14 brush component use_duration is 200" TO TL-CASE
     MOVE "use_duration" TO WS-NAME
     PERFORM COMPONENT
     MOVE "found 1 200" TO TL-EXPECTED
     PERFORM CHECK-DONE

     STOP RUN.

 COMPONENT.
     CALL "TOOL-SPECIAL-COMPONENT" USING WS-KEY WS-NAME WS-VALUE WS-FOUND
     MOVE WS-FOUND TO WS-E1
     MOVE SPACES TO TL-OBSERVED
     STRING "found " FUNCTION TRIM(WS-E1) " " FUNCTION TRIM(WS-VALUE) DELIMITED BY SIZE INTO TL-OBSERVED.

 CHECK-DONE.
     MOVE "T" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-TOOL-SPECIAL-BRUSH.

 COPY CORETEST.
