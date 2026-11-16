*> Test of the crafting rules that read the components of the grid stacks (core/src/crafting-special.cob, CRAFT-MATCH-X of crafting-match.cob;
*> docs/protocol/27 sections 2.4 to 2.13; lane itemcomp2, T10101): dye mixing of leather armour (target + dyes, the mix of 43 section 7.4 over the
*> target's own dyed_color), the tipped arrow (potion_contents of the centre lingering potion), the firework rocket (fireworks: flight duration and the
*> explosions of the stars), the firework star (shape, colours, trail, twinkle) and its fade, the banner duplicate (source layers copied, source stays),
*> the shield decoration (banner_patterns and base_color) and the repair of two tools (damage, a new stack); a transmute result keeps the input's patch.
*> Standard world: the items are the real ones; RC-STORE is emptied and filled with the rows under test.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-CRAFT-SPECIAL.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY COREAPI.
 COPY CITEMS.
 COPY CTRECIPE.
 COPY EXPREC.
 01 WS-W                   BINARY-LONG VALUE 3.
 01 WS-H                   BINARY-LONG VALUE 3.
 01 WS-GRID.
    05 WS-G                BINARY-LONG OCCURS 9 TIMES.
 01 WS-COUNTS.
    05 WS-C                BINARY-LONG OCCURS 9 TIMES.
 01 WS-VARS.
    05 WS-V                BINARY-LONG OCCURS 9 TIMES.
 01 WS-ROW                 BINARY-LONG.
 01 WS-ITEM                BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-RVAR                BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-ITEM-ROW            PIC X(270).
 01 WS-STATUS              BINARY-LONG.
 01 WS-ID                  BINARY-LONG.
 01 WS-HANDLE              BINARY-LONG.
 01 WS-TMP                 BINARY-LONG.
 01 WS-RGB                 BINARY-LONG.
 01 WS-HAS                 BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-DYES.
    05 WS-DYE              BINARY-LONG OCCURS 16 TIMES.
 01 WS-FOUND               BINARY-LONG.
 01 WS-A                   BINARY-LONG.
 01 WS-B                   BINARY-LONG.
 01 WS-T                   BINARY-LONG.
 01 WS-VALUE               PIC X(2048).
 01 WS-LENGTH              BINARY-LONG.
 01 WS-E1                  PIC -(9)9.
 01 WS-E2                  PIC -(9)9.
 01 WS-E3                  PIC -(9)9.
 01 WS-E4                  PIC -(9)9.
 01 WS-E5                  PIC -(9)9.
 01 WS-LOOP                BINARY-LONG.
 01 WS-PTR                 BINARY-LONG.
 01 WS-E6                  PIC -(9)9.
 01 WS-DYE-ROW             BINARY-LONG.
 01 WS-IMBUE-ROW           BINARY-LONG.
 01 WS-ROCKET-ROW          BINARY-LONG.
 01 WS-STAR-ROW            BINARY-LONG.
 01 WS-FADE-ROW            BINARY-LONG.
 01 WS-BANNER-ROW          BINARY-LONG.
 01 WS-SHIELD-ROW          BINARY-LONG.
 01 WS-REPAIR-ROW          BINARY-LONG.
 01 WS-TRANS-ROW           BINARY-LONG.
 01 WS-HELMET              BINARY-LONG.
 01 WS-RED                 BINARY-LONG.
 01 WS-BLUE                BINARY-LONG.
 01 WS-STICK               BINARY-LONG.
 PROCEDURE DIVISION.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     CALL "TEST-STANDARD-TABLES"
     MOVE 0 TO RC-COUNT
     MOVE "T" TO TL-MODE
     PERFORM MAKE-ROWS

*>   Dye mixing.
     MOVE "test craft special dye: a leather helmet with a red and a blue dye is dyed with the mixed colour, an undyed target carries the mix of the dyes only" TO TL-CASE
     PERFORM CLEAR-GRID
     MOVE "leather_helmet" TO WS-KEY
     PERFORM LOOKUP-ID
     MOVE WS-ID TO WS-HELMET WS-G(1)
     MOVE "red_dye" TO WS-KEY
     PERFORM LOOKUP-ID
     MOVE WS-ID TO WS-RED WS-G(2)
     MOVE "blue_dye" TO WS-KEY
     PERFORM LOOKUP-ID
     MOVE WS-ID TO WS-BLUE WS-G(3)
     PERFORM MATCH
     MOVE WS-RVAR TO WS-TMP
     CALL "SC-DYE-GET" USING WS-TMP WS-RGB WS-HAS
     MOVE 0 TO WS-HANDLE
     MOVE 14 TO WS-DYE(1)
     MOVE 11 TO WS-DYE(2)
     MOVE 2 TO WS-N
     CALL "SC-DYE-MIX" USING WS-HANDLE WS-N WS-DYES
     CALL "SC-DYE-GET" USING WS-HANDLE WS-A WS-FOUND
     MOVE WS-RGB TO WS-E1
     MOVE WS-A TO WS-E2
     MOVE WS-ROW TO WS-E3
     MOVE WS-ITEM TO WS-E4
     MOVE WS-HELMET TO WS-E5
     MOVE SPACES TO TL-OBSERVED
     MOVE SPACES TO TL-EXPECTED
     STRING "row " FUNCTION TRIM(WS-E3) " item " FUNCTION TRIM(WS-E4) " rgb " FUNCTION TRIM(WS-E1) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE WS-DYE-ROW TO WS-E3
     STRING "row " FUNCTION TRIM(WS-E3) " item " FUNCTION TRIM(WS-E5) " rgb " FUNCTION TRIM(WS-E2) DELIMITED BY SIZE INTO TL-EXPECTED
     PERFORM CHECK

     MOVE "test craft special dye: a dyed helmet counts its own colour as one more in the mix" TO TL-CASE
     MOVE 0 TO WS-HANDLE
     MOVE 11546150 TO WS-RGB
     CALL "SC-DYE-SET" USING WS-HANDLE WS-RGB
     PERFORM CLEAR-GRID
     MOVE WS-HELMET TO WS-G(1)
     MOVE WS-HANDLE TO WS-V(1)
     MOVE WS-BLUE TO WS-G(2)
     PERFORM MATCH
     MOVE WS-RVAR TO WS-TMP
     CALL "SC-DYE-GET" USING WS-TMP WS-RGB WS-HAS
     MOVE 11 TO WS-DYE(1)
     MOVE 1 TO WS-N
     CALL "SC-DYE-MIX" USING WS-HANDLE WS-N WS-DYES
     CALL "SC-DYE-GET" USING WS-HANDLE WS-A WS-FOUND
     MOVE WS-RGB TO WS-E1
     MOVE WS-A TO WS-E2
     MOVE FUNCTION TRIM(WS-E1) TO TL-OBSERVED
     MOVE FUNCTION TRIM(WS-E2) TO TL-EXPECTED
     PERFORM CHECK

     MOVE "test craft special dye: a second helmet beside a dye, a lone helmet or a foreign item matches nothing; the result keeps the helmet's other components" TO TL-CASE
     PERFORM CLEAR-GRID
     MOVE WS-HELMET TO WS-G(1)
     MOVE WS-HELMET TO WS-G(2)
     MOVE WS-RED TO WS-G(3)
     PERFORM MATCH
     MOVE WS-ROW TO WS-E1
     PERFORM CLEAR-GRID
     MOVE WS-HELMET TO WS-G(1)
     PERFORM MATCH
     MOVE WS-ROW TO WS-E2
     MOVE "stick" TO WS-KEY
     PERFORM LOOKUP-ID
     MOVE WS-ID TO WS-STICK
     PERFORM CLEAR-GRID
     MOVE WS-HELMET TO WS-G(1)
     MOVE WS-RED TO WS-G(2)
     MOVE WS-STICK TO WS-G(3)
     PERFORM MATCH
     MOVE WS-ROW TO WS-E3
     MOVE 0 TO WS-HANDLE
     MOVE 3 TO WS-T
     MOVE 5 TO WS-A
     CALL "SP-ADD-ENCHANT" USING WS-HANDLE WS-T WS-A
     PERFORM CLEAR-GRID
     MOVE WS-HELMET TO WS-G(1)
     MOVE WS-HANDLE TO WS-V(1)
     MOVE WS-RED TO WS-G(2)
     PERFORM MATCH
     MOVE WS-RVAR TO WS-TMP
     CALL "SP-ENCHANT-LEVEL" USING WS-TMP WS-T WS-B
     MOVE WS-B TO WS-E4
     MOVE SPACES TO TL-OBSERVED
     STRING FUNCTION TRIM(WS-E1) " " FUNCTION TRIM(WS-E2) " " FUNCTION TRIM(WS-E3) " ench " FUNCTION TRIM(WS-E4) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "0 0 0 ench 5" TO TL-EXPECTED
     PERFORM CHECK

*>   Tipped arrow.
     MOVE "test craft special imbue: eight arrows around a lingering potion give eight tipped arrows with the potion of the centre" TO TL-CASE
     PERFORM CLEAR-GRID
     MOVE "arrow" TO WS-KEY
     PERFORM LOOKUP-ID
     PERFORM VARYING WS-N FROM 1 BY 1 UNTIL WS-N > 9
         MOVE WS-ID TO WS-G(WS-N)
     END-PERFORM
     MOVE "lingering_potion" TO WS-KEY
     PERFORM LOOKUP-ID
     MOVE WS-ID TO WS-G(5)
     MOVE 0 TO WS-HANDLE
     MOVE 11 TO WS-A
     CALL "SC-POTION-SET" USING WS-HANDLE WS-A
     MOVE WS-HANDLE TO WS-V(5)
     PERFORM MATCH
     MOVE WS-RVAR TO WS-TMP
     CALL "SC-POTION-GET" USING WS-TMP WS-A WS-HAS WS-RGB WS-N
     MOVE "tipped_arrow" TO WS-KEY
     PERFORM LOOKUP-ID
     MOVE WS-ROW TO WS-E1
     MOVE WS-ITEM TO WS-E2
     MOVE WS-COUNT TO WS-E3
     MOVE WS-A TO WS-E4
     MOVE SPACES TO TL-OBSERVED TL-EXPECTED
     STRING FUNCTION TRIM(WS-E1) " " FUNCTION TRIM(WS-E2) " x" FUNCTION TRIM(WS-E3) " potion " FUNCTION TRIM(WS-E4) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE WS-IMBUE-ROW TO WS-E1
     MOVE WS-ID TO WS-E2
     STRING FUNCTION TRIM(WS-E1) " " FUNCTION TRIM(WS-E2) " x8 potion 11" DELIMITED BY SIZE INTO TL-EXPECTED
     PERFORM CHECK

*>   Firework star, fade, rocket.
     MOVE "test craft special firework star: gunpowder, a red dye, glowstone dust, a diamond and a gold nugget give a star shaped star, red, with trail and twinkle" TO TL-CASE
     PERFORM CLEAR-GRID
     MOVE "gunpowder" TO WS-KEY
     PERFORM LOOKUP-ID
     MOVE WS-ID TO WS-G(1)
     MOVE WS-RED TO WS-G(2)
     MOVE "glowstone_dust" TO WS-KEY
     PERFORM LOOKUP-ID
     MOVE WS-ID TO WS-G(3)
     MOVE "diamond" TO WS-KEY
     PERFORM LOOKUP-ID
     MOVE WS-ID TO WS-G(4)
     MOVE "gold_nugget" TO WS-KEY
     PERFORM LOOKUP-ID
     MOVE WS-ID TO WS-G(5)
     PERFORM MATCH
     MOVE WS-RVAR TO WS-TMP
     CALL "SC-EXPLOSION-GET" USING WS-TMP EX-REC WS-FOUND
     MOVE WS-ROW TO WS-E1
     MOVE EX-SHAPE TO WS-E2
     MOVE EX-N TO WS-E3
     MOVE EX-COLOR(1) TO WS-E4
     MOVE EX-TRAIL TO WS-E5
     MOVE EX-TWINKLE TO WS-E6
     MOVE SPACES TO TL-OBSERVED TL-EXPECTED
     STRING FUNCTION TRIM(WS-E1) " shape " FUNCTION TRIM(WS-E2) " n " FUNCTION TRIM(WS-E3) " colour " FUNCTION TRIM(WS-E4)
         " trail " FUNCTION TRIM(WS-E5) " twinkle " FUNCTION TRIM(WS-E6) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE WS-STAR-ROW TO WS-E1
     STRING FUNCTION TRIM(WS-E1) " shape 2 n 1 colour 11743532 trail 1 twinkle 1" DELIMITED BY SIZE INTO TL-EXPECTED
     PERFORM CHECK

     MOVE "test craft special firework star: gunpowder and a dye alone give the small ball; two shapes, two fuels or no dye match nothing" TO TL-CASE
     PERFORM CLEAR-GRID
     MOVE "gunpowder" TO WS-KEY
     PERFORM LOOKUP-ID
     MOVE WS-ID TO WS-G(1)
     MOVE WS-BLUE TO WS-G(2)
     PERFORM MATCH
     MOVE WS-RVAR TO WS-TMP
     CALL "SC-EXPLOSION-GET" USING WS-TMP EX-REC WS-FOUND
     MOVE EX-SHAPE TO WS-E1
     MOVE EX-TRAIL TO WS-E2
     PERFORM CLEAR-GRID
     MOVE WS-ID TO WS-G(1) WS-G(3)
     MOVE WS-BLUE TO WS-G(2)
     PERFORM MATCH
     MOVE WS-ROW TO WS-E3
     PERFORM CLEAR-GRID
     MOVE WS-ID TO WS-G(1)
     MOVE "gold_nugget" TO WS-KEY
     PERFORM LOOKUP-ID
     MOVE WS-ID TO WS-G(2)
     MOVE "feather" TO WS-KEY
     PERFORM LOOKUP-ID
     MOVE WS-ID TO WS-G(3)
     MOVE WS-BLUE TO WS-G(4)
     PERFORM MATCH
     MOVE WS-ROW TO WS-E4
     PERFORM CLEAR-GRID
     MOVE WS-ID TO WS-G(1)
     MOVE "gunpowder" TO WS-KEY
     PERFORM LOOKUP-ID
     MOVE WS-ID TO WS-G(1)
     MOVE WS-ID TO WS-G(2)
     PERFORM MATCH
     MOVE WS-ROW TO WS-E5
     MOVE SPACES TO TL-OBSERVED
     STRING "shape " FUNCTION TRIM(WS-E1) " trail " FUNCTION TRIM(WS-E2) " fuels " FUNCTION TRIM(WS-E3) " shapes " FUNCTION TRIM(WS-E4)
         " nodye " FUNCTION TRIM(WS-E5) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "shape 0 trail 0 fuels 0 shapes 0 nodye 0" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "test craft special firework fade: a star and a blue dye give the star with the blue firework colour as fade colour, the other fields kept" TO TL-CASE
     INITIALIZE EX-REC
     MOVE 3 TO EX-SHAPE
     MOVE 1 TO EX-N
     MOVE 16711680 TO EX-COLOR(1)
     MOVE 1 TO EX-TWINKLE
     MOVE 0 TO WS-HANDLE
     CALL "SC-EXPLOSION-SET" USING WS-HANDLE EX-REC
     PERFORM CLEAR-GRID
     MOVE "firework_star" TO WS-KEY
     PERFORM LOOKUP-ID
     MOVE WS-ID TO WS-G(1)
     MOVE WS-HANDLE TO WS-V(1)
     MOVE WS-BLUE TO WS-G(2)
     PERFORM MATCH
     MOVE WS-RVAR TO WS-TMP
     INITIALIZE EX-REC
     CALL "SC-EXPLOSION-GET" USING WS-TMP EX-REC WS-FOUND
     MOVE WS-ROW TO WS-E1
     MOVE EX-SHAPE TO WS-E2
     MOVE EX-FN TO WS-E3
     MOVE EX-FADE(1) TO WS-E4
     MOVE EX-TWINKLE TO WS-E5
     MOVE SPACES TO TL-OBSERVED TL-EXPECTED
     STRING FUNCTION TRIM(WS-E1) " " FUNCTION TRIM(WS-E2) " " FUNCTION TRIM(WS-E3) " " FUNCTION TRIM(WS-E4) " " FUNCTION TRIM(WS-E5) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE WS-FADE-ROW TO WS-E1
     STRING FUNCTION TRIM(WS-E1) " 3 1 2437522 1" DELIMITED BY SIZE INTO TL-EXPECTED
     PERFORM CHECK

     MOVE "test craft special firework rocket: paper, two gunpowder and a star give three rockets of flight 2 carrying the star's explosion" TO TL-CASE
     MOVE 0 TO WS-HANDLE
     INITIALIZE EX-REC
     MOVE 2 TO EX-SHAPE
     MOVE 1 TO EX-N
     MOVE 255 TO EX-COLOR(1)
     CALL "SC-EXPLOSION-SET" USING WS-HANDLE EX-REC
     PERFORM CLEAR-GRID
     MOVE "paper" TO WS-KEY
     PERFORM LOOKUP-ID
     MOVE WS-ID TO WS-G(1)
     MOVE "gunpowder" TO WS-KEY
     PERFORM LOOKUP-ID
     MOVE WS-ID TO WS-G(2) WS-G(3)
     MOVE "firework_star" TO WS-KEY
     PERFORM LOOKUP-ID
     MOVE WS-ID TO WS-G(4)
     MOVE WS-HANDLE TO WS-V(4)
     PERFORM MATCH
     MOVE WS-RVAR TO WS-TMP
     MOVE 71 TO WS-T
     CALL "SP-GET-COMPONENT-X" USING WS-TMP WS-T WS-VALUE WS-LENGTH WS-FOUND
     MOVE 1 TO WS-N
     CALL "SC-VGET" USING WS-VALUE WS-N WS-A
     CALL "SC-VGET" USING WS-VALUE WS-N WS-B
     MOVE 70 TO WS-T
     CALL "SP-GET-COMPONENT-X" USING WS-HANDLE WS-T WS-VALUE WS-LENGTH WS-FOUND
     COMPUTE WS-T = WS-LENGTH + 2
     MOVE WS-ROW TO WS-E1
     MOVE WS-COUNT TO WS-E2
     MOVE WS-A TO WS-E3
     MOVE WS-B TO WS-E4
     MOVE WS-T TO WS-E5
     MOVE SPACES TO TL-OBSERVED TL-EXPECTED
     STRING FUNCTION TRIM(WS-E1) " x" FUNCTION TRIM(WS-E2) " flight " FUNCTION TRIM(WS-E3) " explosions " FUNCTION TRIM(WS-E4) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE WS-ROCKET-ROW TO WS-E1
     STRING FUNCTION TRIM(WS-E1) " x3 flight 2 explosions 1" DELIMITED BY SIZE INTO TL-EXPECTED
     PERFORM CHECK

*>   Banner duplicate and shield.
     MOVE "test craft special banner duplicate: a patterned banner and a blank banner of one colour give the patterned one; another colour, two patterned or two blank match nothing" TO TL-CASE
     MOVE 0 TO WS-HANDLE
     MOVE 3 TO WS-A
     MOVE 14 TO WS-B
     CALL "SC-BANNER-ADD" USING WS-HANDLE WS-A WS-B
     MOVE 9 TO WS-A
     MOVE 11 TO WS-B
     CALL "SC-BANNER-ADD" USING WS-HANDLE WS-A WS-B
     PERFORM CLEAR-GRID
     MOVE "white_banner" TO WS-KEY
     PERFORM LOOKUP-ID
     MOVE WS-ID TO WS-G(1) WS-G(2)
     MOVE WS-HANDLE TO WS-V(2)
     PERFORM MATCH
     MOVE WS-RVAR TO WS-TMP
     CALL "SC-BANNER-COUNT" USING WS-TMP WS-N
     MOVE WS-ROW TO WS-E1
     MOVE WS-N TO WS-E2
     MOVE "red_banner" TO WS-KEY
     PERFORM LOOKUP-ID
     MOVE WS-ID TO WS-G(1)
     PERFORM MATCH
     MOVE WS-ROW TO WS-E3
     MOVE "white_banner" TO WS-KEY
     PERFORM LOOKUP-ID
     MOVE WS-ID TO WS-G(1)
     MOVE WS-HANDLE TO WS-V(1)
     PERFORM MATCH
     MOVE WS-ROW TO WS-E4
     MOVE 0 TO WS-V(1) WS-V(2)
     PERFORM MATCH
     MOVE WS-ROW TO WS-E5
     MOVE SPACES TO TL-OBSERVED TL-EXPECTED
     STRING FUNCTION TRIM(WS-E1) " layers " FUNCTION TRIM(WS-E2) " other " FUNCTION TRIM(WS-E3) " both " FUNCTION TRIM(WS-E4)
         " none " FUNCTION TRIM(WS-E5) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE WS-BANNER-ROW TO WS-E1
     STRING FUNCTION TRIM(WS-E1) " layers 2 other 0 both 0 none 0" DELIMITED BY SIZE INTO TL-EXPECTED
     PERFORM CHECK

     MOVE "test craft special banner duplicate: taking the result leaves the patterned banner in the grid and uses the blank one" TO TL-CASE
     PERFORM CLEAR-GRID
     MOVE WS-ID TO WS-G(1) WS-G(2)
     MOVE WS-HANDLE TO WS-V(2)
     MOVE 1 TO WS-C(1) WS-C(2)
     PERFORM TAKE
     MOVE WS-G(1) TO WS-E1
     MOVE WS-G(2) TO WS-E2
     MOVE WS-C(2) TO WS-E3
     MOVE WS-V(2) TO WS-E4
     MOVE SPACES TO TL-OBSERVED TL-EXPECTED
     STRING "slot1 " FUNCTION TRIM(WS-E1) " slot2 " FUNCTION TRIM(WS-E2) "/" FUNCTION TRIM(WS-E3) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE WS-ID TO WS-E5
     STRING "slot1 0 slot2 " FUNCTION TRIM(WS-E5) "/1" DELIMITED BY SIZE INTO TL-EXPECTED
     PERFORM CHECK

     MOVE "test craft special shield decoration: a banner and a plain shield give the shield with the banner's layers and its colour as base_color" TO TL-CASE
     PERFORM CLEAR-GRID
     MOVE "red_banner" TO WS-KEY
     PERFORM LOOKUP-ID
     MOVE WS-ID TO WS-G(1)
     MOVE WS-HANDLE TO WS-V(1)
     MOVE "shield" TO WS-KEY
     PERFORM LOOKUP-ID
     MOVE WS-ID TO WS-G(2)
     PERFORM MATCH
     MOVE WS-RVAR TO WS-TMP
     CALL "SC-BANNER-COUNT" USING WS-TMP WS-N
     MOVE 75 TO WS-T
     CALL "SP-GET-COMPONENT-X" USING WS-TMP WS-T WS-VALUE WS-LENGTH WS-FOUND
     MOVE 1 TO WS-B
     CALL "SC-VGET" USING WS-VALUE WS-B WS-A
     MOVE WS-ROW TO WS-E1
     MOVE WS-N TO WS-E2
     MOVE WS-A TO WS-E3
     MOVE WS-FOUND TO WS-E4
     MOVE WS-HANDLE TO WS-TMP
     MOVE SPACES TO TL-OBSERVED TL-EXPECTED
     STRING FUNCTION TRIM(WS-E1) " layers " FUNCTION TRIM(WS-E2) " base " FUNCTION TRIM(WS-E3) " found " FUNCTION TRIM(WS-E4) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE WS-SHIELD-ROW TO WS-E1
     STRING FUNCTION TRIM(WS-E1) " layers 2 base 14 found 1" DELIMITED BY SIZE INTO TL-EXPECTED
     PERFORM CHECK

     MOVE "test craft special shield decoration: an already decorated shield or a banner without layers still decorates only a blank shield" TO TL-CASE
     PERFORM CLEAR-GRID
     MOVE "red_banner" TO WS-KEY
     PERFORM LOOKUP-ID
     MOVE WS-ID TO WS-G(1)
     MOVE "shield" TO WS-KEY
     PERFORM LOOKUP-ID
     MOVE WS-ID TO WS-G(2)
     MOVE WS-HANDLE TO WS-V(2)
     PERFORM MATCH
     MOVE WS-ROW TO WS-E1
     MOVE 0 TO WS-V(2)
     PERFORM MATCH
     MOVE WS-ROW TO WS-E2
     MOVE SPACES TO TL-OBSERVED
     STRING "decorated " FUNCTION TRIM(WS-E1) " plain-banner " FUNCTION TRIM(WS-E2) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE WS-SHIELD-ROW TO WS-E3
     MOVE SPACES TO TL-EXPECTED
     STRING "decorated 0 plain-banner " FUNCTION TRIM(WS-E3) DELIMITED BY SIZE INTO TL-EXPECTED
     PERFORM CHECK

*>   Repair.
     MOVE "test craft special repair: two pickaxes of count one with damage 1000 and 900 of 1561 give a new pickaxe with damage 1561 - (561 + 661 + 78) = 261" TO TL-CASE
     PERFORM CLEAR-GRID
     MOVE "diamond_pickaxe" TO WS-KEY
     PERFORM LOOKUP-ID
     MOVE WS-ID TO WS-G(1) WS-G(2)
     MOVE 0 TO WS-HANDLE
     MOVE 1000 TO WS-A
     CALL "SP-SET-DAMAGE" USING WS-HANDLE WS-A
     MOVE WS-HANDLE TO WS-V(1)
     MOVE 0 TO WS-HANDLE
     MOVE 900 TO WS-A
     CALL "SP-SET-DAMAGE" USING WS-HANDLE WS-A
     MOVE WS-HANDLE TO WS-V(2)
     PERFORM MATCH
     MOVE WS-RVAR TO WS-TMP
     CALL "SP-GET-DAMAGE" USING WS-ITEM WS-TMP WS-A
     MOVE WS-ROW TO WS-E1
     MOVE WS-ITEM TO WS-E2
     MOVE WS-COUNT TO WS-E3
     MOVE WS-A TO WS-E4
     MOVE SPACES TO TL-OBSERVED TL-EXPECTED
     STRING FUNCTION TRIM(WS-E1) " " FUNCTION TRIM(WS-E2) " x" FUNCTION TRIM(WS-E3) " damage " FUNCTION TRIM(WS-E4) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE WS-REPAIR-ROW TO WS-E1
     MOVE WS-ID TO WS-E2
     STRING FUNCTION TRIM(WS-E1) " " FUNCTION TRIM(WS-E2) " x1 damage 261" DELIMITED BY SIZE INTO TL-EXPECTED
     PERFORM CHECK

     MOVE "test craft special repair: two different tools or an undamaged-undamageable item do not combine; a stack of two does not" TO TL-CASE
     PERFORM CLEAR-GRID
     MOVE WS-ID TO WS-G(1)
     MOVE "diamond_shovel" TO WS-KEY
     PERFORM LOOKUP-ID
     MOVE WS-ID TO WS-G(2)
     PERFORM MATCH
     MOVE WS-ROW TO WS-E1
     PERFORM CLEAR-GRID
     MOVE WS-STICK TO WS-G(1) WS-G(2)
     PERFORM MATCH
     MOVE WS-ROW TO WS-E2
     MOVE SPACES TO TL-OBSERVED
     STRING "mixed " FUNCTION TRIM(WS-E1) " sticks " FUNCTION TRIM(WS-E2) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "mixed 0 sticks 0" TO TL-EXPECTED
     PERFORM CHECK

*>   Transmute keeps the input's patch.
     MOVE "test craft special transmute: the result of a transmute recipe carries the patch of the input stack" TO TL-CASE
     PERFORM CLEAR-GRID
     MOVE "shield" TO WS-KEY
     PERFORM LOOKUP-ID
     MOVE WS-ID TO WS-G(1)
     MOVE 0 TO WS-HANDLE
     MOVE 7 TO WS-A
     MOVE 2 TO WS-T
     CALL "SP-ADD-ENCHANT" USING WS-HANDLE WS-T WS-A
     MOVE WS-HANDLE TO WS-V(1)
     MOVE "stick" TO WS-KEY
     MOVE WS-STICK TO WS-G(2)
     PERFORM MATCH
     MOVE WS-RVAR TO WS-TMP
     CALL "SP-ENCHANT-LEVEL" USING WS-TMP WS-T WS-B
     MOVE WS-ROW TO WS-E1
     MOVE WS-B TO WS-E2
     MOVE SPACES TO TL-OBSERVED TL-EXPECTED
     STRING FUNCTION TRIM(WS-E1) " level " FUNCTION TRIM(WS-E2) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE WS-TRANS-ROW TO WS-E1
     STRING FUNCTION TRIM(WS-E1) " level 7" DELIMITED BY SIZE INTO TL-EXPECTED
     PERFORM CHECK

*>   Edges that complete the rule coverage.
     MOVE "test craft special star shapes: a fire charge gives the large ball, a skull the creeper, a feather the burst; a foreign item spoils the star and the fade" TO TL-CASE
     MOVE SPACES TO TL-OBSERVED
     MOVE 1 TO WS-PTR
     PERFORM VARYING WS-LOOP FROM 1 BY 1 UNTIL WS-LOOP > 3
         EVALUATE WS-LOOP
             WHEN 1 MOVE "fire_charge" TO WS-KEY
             WHEN 2 MOVE "skeleton_skull" TO WS-KEY
             WHEN 3 MOVE "feather" TO WS-KEY
         END-EVALUATE
         PERFORM LOOKUP-ID
         PERFORM CLEAR-GRID
         MOVE WS-ID TO WS-G(3)
         MOVE "gunpowder" TO WS-KEY
         PERFORM LOOKUP-ID
         MOVE WS-ID TO WS-G(1)
         MOVE WS-BLUE TO WS-G(2)
         PERFORM MATCH
         MOVE WS-RVAR TO WS-TMP
         CALL "SC-EXPLOSION-GET" USING WS-TMP EX-REC WS-FOUND
         MOVE EX-SHAPE TO WS-E1
         STRING FUNCTION TRIM(WS-E1) " " DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-PTR
     END-PERFORM
     MOVE WS-STICK TO WS-G(3)
     PERFORM MATCH
     MOVE WS-ROW TO WS-E2
     MOVE "firework_star" TO WS-KEY
     PERFORM LOOKUP-ID
     PERFORM CLEAR-GRID
     MOVE WS-ID TO WS-G(1)
     MOVE WS-BLUE TO WS-G(2)
     MOVE WS-STICK TO WS-G(3)
     PERFORM MATCH
     MOVE WS-ROW TO WS-E3
     STRING " spoiled " FUNCTION TRIM(WS-E2) " " FUNCTION TRIM(WS-E3) DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-PTR
     MOVE "1 3 4  spoiled 0 0" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "test craft special banner duplicate: a banner with seven layers does not duplicate; the dye colour of an index past the table or an item 0 is -1" TO TL-CASE
     MOVE 0 TO WS-HANDLE
     MOVE 3 TO WS-A
     MOVE 14 TO WS-B
     PERFORM 7 TIMES
         CALL "SC-BANNER-ADD" USING WS-HANDLE WS-A WS-B
     END-PERFORM
     PERFORM CLEAR-GRID
     MOVE "white_banner" TO WS-KEY
     PERFORM LOOKUP-ID
     MOVE WS-ID TO WS-G(1) WS-G(2)
     MOVE WS-HANDLE TO WS-V(2)
     PERFORM MATCH
     MOVE WS-ROW TO WS-E1
     MOVE 0 TO WS-T
     MOVE "_dye" TO WS-KEY
     CALL "CRAFT-COLOR-OF" USING WS-T WS-KEY WS-A
     MOVE WS-A TO WS-E2
     MOVE SPACES TO TL-OBSERVED
     STRING "row " FUNCTION TRIM(WS-E1) " colour " FUNCTION TRIM(WS-E2) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "row 0 colour -1" TO TL-EXPECTED
     PERFORM CHECK
     STOP RUN.

 MAKE-ROWS.
     MOVE "crafting_dye" TO WS-KEY
     PERFORM NEW-ROW
     MOVE WS-ROW TO WS-DYE-ROW
     MOVE 2 TO RR-SERIALIZER(WS-ROW)
     MOVE "minecraft:leather_helmet" TO RR-ING(WS-ROW, 1)
     MOVE "minecraft:white_dye minecraft:orange_dye minecraft:magenta_dye minecraft:light_blue_dye minecraft:yellow_dye minecraft:lime_dye minecraft:pink_dye minecraft:gray_dye minecraft:light_gray_dye minecraft:cyan_dye minecraft:purple_dye minecraft:blue_dye minecraft:brown_dye minecraft:green_dye minecraft:red_dye minecraft:black_dye" TO RR-ING(WS-ROW, 2)
     MOVE "minecraft:leather_helmet" TO RR-RESULT-ID(WS-ROW)
     MOVE 1 TO RR-RESULT-COUNT(WS-ROW)
     MOVE "crafting_imbue" TO WS-KEY
     PERFORM NEW-ROW
     MOVE WS-ROW TO WS-IMBUE-ROW
     MOVE 3 TO RR-SERIALIZER(WS-ROW)
     MOVE "minecraft:lingering_potion" TO RR-ING(WS-ROW, 1)
     MOVE "minecraft:arrow" TO RR-ING(WS-ROW, 2)
     MOVE "minecraft:tipped_arrow" TO RR-RESULT-ID(WS-ROW)
     MOVE 8 TO RR-RESULT-COUNT(WS-ROW)
     MOVE "crafting_special_firework_rocket" TO WS-KEY
     PERFORM NEW-ROW
     MOVE WS-ROW TO WS-ROCKET-ROW
     MOVE 8 TO RR-SERIALIZER(WS-ROW)
     MOVE "minecraft:paper" TO RR-ING(WS-ROW, 1)
     MOVE "minecraft:gunpowder" TO RR-ING(WS-ROW, 2)
     MOVE "minecraft:firework_star" TO RR-ING(WS-ROW, 3)
     MOVE "minecraft:firework_rocket" TO RR-RESULT-ID(WS-ROW)
     MOVE 3 TO RR-RESULT-COUNT(WS-ROW)
     MOVE "crafting_special_firework_star" TO WS-KEY
     PERFORM NEW-ROW
     MOVE WS-ROW TO WS-STAR-ROW
     MOVE 9 TO RR-SERIALIZER(WS-ROW)
     MOVE "minecraft:diamond" TO RR-ING(WS-ROW, 1)
     MOVE "minecraft:glowstone_dust" TO RR-ING(WS-ROW, 2)
     MOVE "minecraft:gunpowder" TO RR-ING(WS-ROW, 3)
     MOVE "minecraft:white_dye minecraft:orange_dye minecraft:magenta_dye minecraft:light_blue_dye minecraft:yellow_dye minecraft:lime_dye minecraft:pink_dye minecraft:gray_dye minecraft:light_gray_dye minecraft:cyan_dye minecraft:purple_dye minecraft:blue_dye minecraft:brown_dye minecraft:green_dye minecraft:red_dye minecraft:black_dye" TO RR-ING(WS-ROW, 4)
     MOVE "minecraft:firework_star" TO RR-RESULT-ID(WS-ROW)
     MOVE 1 TO RR-RESULT-COUNT(WS-ROW)
     MOVE "crafting_special_firework_star_fade" TO WS-KEY
     PERFORM NEW-ROW
     MOVE WS-ROW TO WS-FADE-ROW
     MOVE 10 TO RR-SERIALIZER(WS-ROW)
     MOVE "minecraft:firework_star" TO RR-ING(WS-ROW, 1)
     MOVE "minecraft:white_dye minecraft:orange_dye minecraft:magenta_dye minecraft:light_blue_dye minecraft:yellow_dye minecraft:lime_dye minecraft:pink_dye minecraft:gray_dye minecraft:light_gray_dye minecraft:cyan_dye minecraft:purple_dye minecraft:blue_dye minecraft:brown_dye minecraft:green_dye minecraft:red_dye minecraft:black_dye" TO RR-ING(WS-ROW, 2)
     MOVE "minecraft:firework_star" TO RR-RESULT-ID(WS-ROW)
     MOVE 1 TO RR-RESULT-COUNT(WS-ROW)
     MOVE "crafting_special_bannerduplicate" TO WS-KEY
     PERFORM NEW-ROW
     MOVE WS-ROW TO WS-BANNER-ROW
     MOVE 11 TO RR-SERIALIZER(WS-ROW)
     MOVE "minecraft:white_banner" TO RR-ING(WS-ROW, 1)
     MOVE "minecraft:white_banner" TO RR-RESULT-ID(WS-ROW)
     MOVE 1 TO RR-RESULT-COUNT(WS-ROW)
     MOVE "crafting_special_shielddecoration" TO WS-KEY
     PERFORM NEW-ROW
     MOVE WS-ROW TO WS-SHIELD-ROW
     MOVE 12 TO RR-SERIALIZER(WS-ROW)
     MOVE "minecraft:red_banner minecraft:white_banner" TO RR-ING(WS-ROW, 1)
     MOVE "minecraft:shield" TO RR-ING(WS-ROW, 2)
     MOVE "minecraft:shield" TO RR-RESULT-ID(WS-ROW)
     MOVE 1 TO RR-RESULT-COUNT(WS-ROW)
     MOVE "crafting_special_repairitem" TO WS-KEY
     PERFORM NEW-ROW
     MOVE WS-ROW TO WS-REPAIR-ROW
     MOVE 13 TO RR-SERIALIZER(WS-ROW)
     MOVE 1 TO RR-RESULT-COUNT(WS-ROW)
     MOVE "crafting_transmute" TO WS-KEY
     PERFORM NEW-ROW
     MOVE WS-ROW TO WS-TRANS-ROW
     MOVE 4 TO RR-SERIALIZER(WS-ROW)
     MOVE "minecraft:shield" TO RR-ING(WS-ROW, 1)
     MOVE "minecraft:stick" TO RR-ING(WS-ROW, 2)
     MOVE 1 TO RR-MATERIAL-MIN(WS-ROW) RR-MATERIAL-MAX(WS-ROW) RR-RESULT-COUNT(WS-ROW)
     MOVE "minecraft:bow" TO RR-RESULT-ID(WS-ROW)
     MOVE 0 TO WS-ROW.

 NEW-ROW.
     ADD 1 TO RC-COUNT
     MOVE RC-COUNT TO WS-ROW
     INITIALIZE RC-ROW(WS-ROW)
     MOVE WS-KEY TO RR-KEY(WS-ROW).

 LOOKUP-ID.
     MOVE SPACES TO WS-ITEM-ROW
     STRING "minecraft:" FUNCTION TRIM(WS-KEY) DELIMITED BY SIZE INTO WS-ITEM-ROW
     MOVE WS-ITEM-ROW TO WS-KEY
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-ID WS-ITEM-ROW WS-STATUS.

 CLEAR-GRID.
     PERFORM VARYING WS-N FROM 1 BY 1 UNTIL WS-N > 9
         MOVE 0 TO WS-G(WS-N) WS-V(WS-N) WS-C(WS-N)
     END-PERFORM.

 MATCH.
     CALL "CRAFT-MATCH-X" USING WS-W WS-H WS-GRID WS-VARS WS-ROW WS-ITEM WS-COUNT WS-RVAR.

 TAKE.
     CALL "CRAFT-TAKE-X" USING WS-W WS-H WS-GRID WS-COUNTS WS-VARS.

 CHECK.
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-CRAFT-SPECIAL.
 COPY CORETEST.
