*> The crafting rules that read the components of the grid stacks (lane itemcomp2, T10101; docs/protocol/27 sections 2.5, 2.6, 2.8, 2.9, 2.12 and 2.13, 54 sections 17, 21 and 22,
*> 43 section 7.4 and 8): the recipe rows of serializers 2 (dye), 3 (imbue, the tipped arrow), 8 (firework rocket), 9 (firework star), 10 (firework star fade), 11 (banner duplicate),
*> 12 (shield decoration) and 13 (repair item). The grid is a table of 9 item ids (0 = empty) with a table of 9 patch handles (CSTACK.cpy); a handle is immutable and interned, so a
*> result that keeps the original components of a stack starts from that stack's handle and changes one component of it.
*> Gaps: the curse enchantments of a repaired pair are not carried over (no table names the curse tag members here), and the max_damage of a patched tool is not combined (the
*> prototype's value is used).
*>
*>   CRAFT-COLOR-OF USING item, suffix (PIC X(8): "_dye" or "_banner"), dye id out (0 to 15 in the order of 43 section 8, -1 when the item is not "<colour><suffix>")
*>   CRAFT-SPECIAL USING recipe row, items (9), handles (9), matched out (1 or 0), result item out (0: the recipe's), result handle out
*>     the match and the result patch of one special crafting row; the result item and count of the row are the caller's (CRAFT-MATCH-X)

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CRAFT-COLOR-OF.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CITEMS.
 01 WS-NAMES-DATA.
    05 FILLER PIC X(12) VALUE "white".
    05 FILLER PIC X(12) VALUE "orange".
    05 FILLER PIC X(12) VALUE "magenta".
    05 FILLER PIC X(12) VALUE "light_blue".
    05 FILLER PIC X(12) VALUE "yellow".
    05 FILLER PIC X(12) VALUE "lime".
    05 FILLER PIC X(12) VALUE "pink".
    05 FILLER PIC X(12) VALUE "gray".
    05 FILLER PIC X(12) VALUE "light_gray".
    05 FILLER PIC X(12) VALUE "cyan".
    05 FILLER PIC X(12) VALUE "purple".
    05 FILLER PIC X(12) VALUE "blue".
    05 FILLER PIC X(12) VALUE "brown".
    05 FILLER PIC X(12) VALUE "green".
    05 FILLER PIC X(12) VALUE "red".
    05 FILLER PIC X(12) VALUE "black".
 01 WS-NAMES REDEFINES WS-NAMES-DATA.
    05 WS-NAME             PIC X(12) OCCURS 16 TIMES.
 01 WS-KEY                 PIC X(48).
 01 WS-REST                PIC X(48).
 01 WS-WANT                PIC X(48).
 01 WS-I                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-ITEM                 BINARY-LONG.
 01 L-SUFFIX               PIC X(8).
 01 L-ID                   BINARY-LONG.
 PROCEDURE DIVISION USING L-ITEM L-SUFFIX L-ID.
     MOVE -1 TO L-ID
     IF L-ITEM <= 0 OR L-ITEM >= IT-COUNT
         GOBACK
     END-IF
     MOVE IT-KEY(L-ITEM + 1) TO WS-KEY
     IF WS-KEY(1:10) = "minecraft:"
         MOVE WS-KEY(11:38) TO WS-REST
         MOVE WS-REST TO WS-KEY
     END-IF
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 16
         MOVE SPACES TO WS-WANT
         STRING FUNCTION TRIM(WS-NAME(WS-I)) FUNCTION TRIM(L-SUFFIX) DELIMITED BY SIZE INTO WS-WANT
         IF WS-KEY = WS-WANT
             COMPUTE L-ID = WS-I - 1
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM CRAFT-COLOR-OF.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CRAFT-SPECIAL.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CTRECIPE.
 COPY EXPREC.
 COPY DYES.
 01 WS-DYE-TABLE REDEFINES DYE-DATA.
    05 WS-DYE-ROW OCCURS 16 TIMES.
       10 WS-DIFFUSE       BINARY-LONG.
       10 WS-FIREWORK      BINARY-LONG.
 01 WS-SUFFIX-DYE          PIC X(8) VALUE "_dye".
 01 WS-SUFFIX-BANNER       PIC X(8) VALUE "_banner".
 01 WS-ING-1               PIC X(800).
 01 WS-ING-2               PIC X(800).
 01 WS-ING-3               PIC X(800).
 01 WS-S                   BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-PASS                BINARY-LONG.
 01 WS-BAD                 BINARY-LONG.
 01 WS-TARGETS             BINARY-LONG.
 01 WS-TARGET-SLOT         BINARY-LONG.
 01 WS-DYES.
    05 WS-DYE              BINARY-LONG OCCURS 16 TIMES.
 01 WS-DYE-COUNT           BINARY-LONG.
 01 WS-COLOR               BINARY-LONG.
 01 WS-FUELS               BINARY-LONG.
 01 WS-TRAILS              BINARY-LONG.
 01 WS-TWINKLES            BINARY-LONG.
 01 WS-SHAPES              BINARY-LONG.
 01 WS-SHAPE               BINARY-LONG.
 01 WS-KEY                 PIC X(800).
 01 WS-STARS               BINARY-LONG.
 01 WS-FLIGHT              BINARY-LONG.
 01 WS-VALUE               PIC X(2048).
 01 WS-PIECE               PIC X(2048).
 01 WS-LENGTH              BINARY-LONG.
 01 WS-PIECE-LENGTH        BINARY-LONG.
 01 WS-FOUND               BINARY-LONG.
 01 WS-POS                 BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-LAYERS              BINARY-LONG.
 01 WS-SOURCE-SLOT         BINARY-LONG.
 01 WS-BLANKS              BINARY-LONG.
 01 WS-SOURCES             BINARY-LONG.
 01 WS-BANNER-SLOT         BINARY-LONG.
 01 WS-SHIELD-SLOT         BINARY-LONG.
 01 WS-BANNERS             BINARY-LONG.
 01 WS-MAX-A               BINARY-LONG.
 01 WS-MAX-B               BINARY-LONG.
 01 WS-DMG-A               BINARY-LONG.
 01 WS-DMG-B               BINARY-LONG.
 01 WS-MAX                 BINARY-LONG.
 01 WS-DMG                 BINARY-LONG.
 01 WS-SLOT-A              BINARY-LONG.
 01 WS-SLOT-B              BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-ITEMS.
    05 L-ITEM              BINARY-LONG OCCURS 9 TIMES.
 01 L-VARS.
    05 L-VAR               BINARY-LONG OCCURS 9 TIMES.
 01 L-MATCHED              BINARY-LONG.
 01 L-RESULT-ITEM          BINARY-LONG.
 01 L-RESULT-VAR           BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-ITEMS L-VARS L-MATCHED L-RESULT-ITEM L-RESULT-VAR.
     GO TO MAIN-LINE.
*> 27 2.5: one target, at least one dye (an item "<colour>_dye" that passes the dye ingredient); the target's dyed_color is mixed with the dyes.
 DYE-RULE.
     MOVE 0 TO WS-TARGETS WS-DYE-COUNT WS-BAD WS-TARGET-SLOT
     PERFORM VARYING WS-S FROM 1 BY 1 UNTIL WS-S > 9
         IF L-ITEM(WS-S) NOT = 0
             CALL "CRAFT-ING-TEST" USING L-ITEM(WS-S) RR-ING(L-ROW, 1) WS-PASS
             IF WS-PASS = 1
                 ADD 1 TO WS-TARGETS
                 MOVE WS-S TO WS-TARGET-SLOT
             ELSE
                 PERFORM TEST-DYE
                 IF WS-COLOR >= 0
                     ADD 1 TO WS-DYE-COUNT
                     IF WS-DYE-COUNT <= 16
                         MOVE WS-COLOR TO WS-DYE(WS-DYE-COUNT)
                     END-IF
                 ELSE
                     ADD 1 TO WS-BAD
                 END-IF
             END-IF
         END-IF
     END-PERFORM
     IF WS-N >= 2 AND WS-TARGETS = 1 AND WS-DYE-COUNT >= 1 AND WS-DYE-COUNT <= 16 AND WS-BAD = 0
         MOVE 1 TO L-MATCHED
         MOVE L-VAR(WS-TARGET-SLOT) TO L-RESULT-VAR
         CALL "SC-DYE-MIX" USING L-RESULT-VAR WS-DYE-COUNT WS-DYES
     END-IF.

*> The dye colour of the item of slot WS-S when it passes the recipe's dye ingredient (the second ingredient of dye and of fade), -1 otherwise.
 TEST-DYE.
     MOVE -1 TO WS-COLOR
     CALL "CRAFT-ING-TEST" USING L-ITEM(WS-S) RR-ING(L-ROW, 2) WS-PASS
     IF WS-PASS = 1
         CALL "CRAFT-COLOR-OF" USING L-ITEM(WS-S) WS-SUFFIX-DYE WS-COLOR
     END-IF.

*> 27 2.9: the centre passes the source, the other eight the material; potion_contents (53) of the centre goes on the result.
 IMBUE-RULE.
     MOVE RR-ING(L-ROW, 1) TO WS-ING-1
     MOVE RR-ING(L-ROW, 2) TO WS-ING-2
     CALL "RECIPE-CENTRE-MATCH" USING L-ITEMS WS-ING-1 WS-ING-2 L-MATCHED
     IF L-MATCHED = 1
         MOVE 53 TO WS-TYPE
         CALL "SP-GET-COMPONENT-X" USING L-VAR(5) WS-TYPE WS-VALUE WS-LENGTH WS-FOUND
         IF WS-FOUND = 1
             CALL "SP-SET-COMPONENT-X" USING L-RESULT-VAR WS-TYPE WS-VALUE WS-LENGTH
         END-IF
     END-IF.

*> 27 2.12 rocket: flight duration = the number of fuels, the explosions of the stars that have one, in slot order.
 ROCKET-RULE.
     MOVE RR-ING(L-ROW, 1) TO WS-ING-1
     MOVE RR-ING(L-ROW, 2) TO WS-ING-2
     MOVE RR-ING(L-ROW, 3) TO WS-ING-3
     CALL "RECIPE-ROCKET-MATCH" USING L-ITEMS WS-ING-1 WS-ING-2 WS-ING-3 L-MATCHED WS-FLIGHT
     IF L-MATCHED = 1
         MOVE SPACES TO WS-VALUE
         MOVE 1 TO WS-POS
         MOVE 0 TO WS-STARS
         MOVE SPACES TO WS-PIECE
         MOVE 0 TO WS-PIECE-LENGTH
         MOVE 70 TO WS-TYPE
         PERFORM VARYING WS-S FROM 1 BY 1 UNTIL WS-S > 9
             IF L-ITEM(WS-S) NOT = 0
                 CALL "CRAFT-ING-TEST" USING L-ITEM(WS-S) RR-ING(L-ROW, 3) WS-PASS
                 IF WS-PASS = 1
                     CALL "SP-GET-COMPONENT-X" USING L-VAR(WS-S) WS-TYPE WS-VALUE WS-LENGTH WS-FOUND
                     IF WS-FOUND = 1 AND WS-STARS < 256
                         ADD 1 TO WS-STARS
                         MOVE WS-VALUE(1:WS-LENGTH) TO WS-PIECE(WS-PIECE-LENGTH + 1:WS-LENGTH)
                         ADD WS-LENGTH TO WS-PIECE-LENGTH
                     END-IF
                 END-IF
             END-IF
         END-PERFORM
         MOVE SPACES TO WS-VALUE
         MOVE 1 TO WS-POS
         CALL "SC-VPUT" USING WS-VALUE WS-POS WS-FLIGHT
         CALL "SC-VPUT" USING WS-VALUE WS-POS WS-STARS
         IF WS-PIECE-LENGTH > 0
             MOVE WS-PIECE(1:WS-PIECE-LENGTH) TO WS-VALUE(WS-POS:WS-PIECE-LENGTH)
             ADD WS-PIECE-LENGTH TO WS-POS
         END-IF
         COMPUTE WS-LENGTH = WS-POS - 1
         MOVE 71 TO WS-TYPE
         CALL "SP-SET-COMPONENT-X" USING L-RESULT-VAR WS-TYPE WS-VALUE WS-LENGTH
     END-IF.

*> 27 2.12 star: one fuel, at least one dye, at most one shape item, one twinkle and one trail; the explosion holds the dyes' firework colours.
 STAR-RULE.
     MOVE 0 TO WS-FUELS WS-DYE-COUNT WS-SHAPES WS-TWINKLES WS-TRAILS WS-BAD WS-SHAPE
     PERFORM VARYING WS-S FROM 1 BY 1 UNTIL WS-S > 9
         IF L-ITEM(WS-S) NOT = 0
             PERFORM STAR-SLOT
         END-IF
     END-PERFORM
     IF WS-N >= 2 AND WS-FUELS = 1 AND WS-DYE-COUNT >= 1 AND WS-DYE-COUNT <= 8 AND WS-SHAPES <= 1 AND WS-TWINKLES <= 1
             AND WS-TRAILS <= 1 AND WS-BAD = 0
         MOVE 1 TO L-MATCHED
         INITIALIZE EX-REC
         MOVE WS-SHAPE TO EX-SHAPE
         MOVE WS-DYE-COUNT TO EX-N
         PERFORM VARYING WS-S FROM 1 BY 1 UNTIL WS-S > WS-DYE-COUNT
             MOVE WS-FIREWORK(WS-DYE(WS-S) + 1) TO EX-COLOR(WS-S)
         END-PERFORM
         MOVE WS-TRAILS TO EX-TRAIL
         MOVE WS-TWINKLES TO EX-TWINKLE
         CALL "SC-EXPLOSION-SET" USING L-RESULT-VAR EX-REC
     END-IF.

*> Sorts the item of slot WS-S into fuel (3), trail (1), twinkle (2), a dye (4) or one of the four shapes of the data file; anything else is bad.
 STAR-SLOT.
     CALL "CRAFT-ING-TEST" USING L-ITEM(WS-S) RR-ING(L-ROW, 3) WS-PASS
     IF WS-PASS = 1
         ADD 1 TO WS-FUELS
         EXIT PARAGRAPH
     END-IF
     CALL "CRAFT-ING-TEST" USING L-ITEM(WS-S) RR-ING(L-ROW, 1) WS-PASS
     IF WS-PASS = 1
         ADD 1 TO WS-TRAILS
         EXIT PARAGRAPH
     END-IF
     CALL "CRAFT-ING-TEST" USING L-ITEM(WS-S) RR-ING(L-ROW, 2) WS-PASS
     IF WS-PASS = 1
         ADD 1 TO WS-TWINKLES
         EXIT PARAGRAPH
     END-IF
     CALL "CRAFT-ING-TEST" USING L-ITEM(WS-S) RR-ING(L-ROW, 4) WS-PASS
     IF WS-PASS = 1
         CALL "CRAFT-COLOR-OF" USING L-ITEM(WS-S) WS-SUFFIX-DYE WS-COLOR
         IF WS-COLOR >= 0
             ADD 1 TO WS-DYE-COUNT
             IF WS-DYE-COUNT <= 8
                 MOVE WS-COLOR TO WS-DYE(WS-DYE-COUNT)
             END-IF
         ELSE
             ADD 1 TO WS-BAD
         END-IF
         EXIT PARAGRAPH
     END-IF
*>   The shapes of the data file: burst (feather) 4, creeper (a skull or head, the members of #minecraft:skulls) 3, large_ball (fire charge) 1, star (gold nugget) 2.
     MOVE -1 TO WS-COLOR
     MOVE SPACES TO WS-KEY
     MOVE "minecraft:feather" TO WS-KEY
     CALL "CRAFT-ING-TEST" USING L-ITEM(WS-S) WS-KEY WS-PASS
     IF WS-PASS = 1
         MOVE 4 TO WS-COLOR
     END-IF
     MOVE "minecraft:skeleton_skull minecraft:wither_skeleton_skull minecraft:player_head minecraft:zombie_head minecraft:creeper_head minecraft:dragon_head minecraft:piglin_head" TO WS-KEY
     CALL "CRAFT-ING-TEST" USING L-ITEM(WS-S) WS-KEY WS-PASS
     IF WS-PASS = 1
         MOVE 3 TO WS-COLOR
     END-IF
     MOVE "minecraft:fire_charge" TO WS-KEY
     CALL "CRAFT-ING-TEST" USING L-ITEM(WS-S) WS-KEY WS-PASS
     IF WS-PASS = 1
         MOVE 1 TO WS-COLOR
     END-IF
     MOVE "minecraft:gold_nugget" TO WS-KEY
     CALL "CRAFT-ING-TEST" USING L-ITEM(WS-S) WS-KEY WS-PASS
     IF WS-PASS = 1
         MOVE 2 TO WS-COLOR
     END-IF
     IF WS-COLOR >= 0
         ADD 1 TO WS-SHAPES
         MOVE WS-COLOR TO WS-SHAPE
     ELSE
         ADD 1 TO WS-BAD
     END-IF.

*> 27 2.12 fade: one star and at least one dye; the star's explosion gets the dyes' firework colours as fade colours.
 FADE-RULE.
     MOVE 0 TO WS-TARGETS WS-DYE-COUNT WS-BAD WS-TARGET-SLOT
     PERFORM VARYING WS-S FROM 1 BY 1 UNTIL WS-S > 9
         IF L-ITEM(WS-S) NOT = 0
             CALL "CRAFT-ING-TEST" USING L-ITEM(WS-S) RR-ING(L-ROW, 1) WS-PASS
             IF WS-PASS = 1
                 ADD 1 TO WS-TARGETS
                 MOVE WS-S TO WS-TARGET-SLOT
             ELSE
                 PERFORM TEST-DYE
                 IF WS-COLOR >= 0
                     ADD 1 TO WS-DYE-COUNT
                     IF WS-DYE-COUNT <= 8
                         MOVE WS-COLOR TO WS-DYE(WS-DYE-COUNT)
                     END-IF
                 ELSE
                     ADD 1 TO WS-BAD
                 END-IF
             END-IF
         END-IF
     END-PERFORM
     IF WS-N >= 2 AND WS-TARGETS = 1 AND WS-DYE-COUNT >= 1 AND WS-DYE-COUNT <= 8 AND WS-BAD = 0
         MOVE 1 TO L-MATCHED
         MOVE L-VAR(WS-TARGET-SLOT) TO L-RESULT-VAR
         CALL "SC-EXPLOSION-GET" USING L-RESULT-VAR EX-REC WS-FOUND
         MOVE WS-DYE-COUNT TO EX-FN
         PERFORM VARYING WS-S FROM 1 BY 1 UNTIL WS-S > WS-DYE-COUNT
             MOVE WS-FIREWORK(WS-DYE(WS-S) + 1) TO EX-FADE(WS-S)
         END-PERFORM
         CALL "SC-EXPLOSION-SET" USING L-RESULT-VAR EX-REC
     END-IF.

*> 27 2.6: two banners of one colour, one with 1 to 6 layers (the source) and one with none; the result is the source's patch.
 BANNER-RULE.
     MOVE 0 TO WS-SOURCES WS-BLANKS WS-BAD WS-SOURCE-SLOT
     PERFORM VARYING WS-S FROM 1 BY 1 UNTIL WS-S > 9
         IF L-ITEM(WS-S) NOT = 0
             CALL "CRAFT-ING-TEST" USING L-ITEM(WS-S) RR-ING(L-ROW, 1) WS-PASS
             IF WS-PASS = 0
                 ADD 1 TO WS-BAD
             ELSE
                 CALL "SC-BANNER-COUNT" USING L-VAR(WS-S) WS-LAYERS
                 EVALUATE TRUE
                     WHEN WS-LAYERS = 0
                         ADD 1 TO WS-BLANKS
                     WHEN WS-LAYERS <= 6
                         ADD 1 TO WS-SOURCES
                         MOVE WS-S TO WS-SOURCE-SLOT
                     WHEN OTHER
                         ADD 1 TO WS-BAD
                 END-EVALUATE
             END-IF
         END-IF
     END-PERFORM
     IF WS-N = 2 AND WS-SOURCES = 1 AND WS-BLANKS = 1 AND WS-BAD = 0
         MOVE 1 TO L-MATCHED
         MOVE L-VAR(WS-SOURCE-SLOT) TO L-RESULT-VAR
     END-IF.

*> 27 2.8: one banner (any colour) and one shield without layers; the shield gets the banner's layers and its colour as base_color (75).
 SHIELD-RULE.
     MOVE 0 TO WS-BANNERS WS-TARGETS WS-BAD WS-BANNER-SLOT WS-SHIELD-SLOT
     PERFORM VARYING WS-S FROM 1 BY 1 UNTIL WS-S > 9
         IF L-ITEM(WS-S) NOT = 0
             CALL "CRAFT-ING-TEST" USING L-ITEM(WS-S) RR-ING(L-ROW, 1) WS-PASS
             IF WS-PASS = 1
                 ADD 1 TO WS-BANNERS
                 MOVE WS-S TO WS-BANNER-SLOT
             ELSE
                 CALL "CRAFT-ING-TEST" USING L-ITEM(WS-S) RR-ING(L-ROW, 2) WS-PASS
                 CALL "SC-BANNER-COUNT" USING L-VAR(WS-S) WS-LAYERS
                 IF WS-PASS = 1 AND WS-LAYERS = 0
                     ADD 1 TO WS-TARGETS
                     MOVE WS-S TO WS-SHIELD-SLOT
                 ELSE
                     ADD 1 TO WS-BAD
                 END-IF
             END-IF
         END-IF
     END-PERFORM
     IF WS-N = 2 AND WS-BANNERS = 1 AND WS-TARGETS = 1 AND WS-BAD = 0
         MOVE 1 TO L-MATCHED
         MOVE L-VAR(WS-SHIELD-SLOT) TO L-RESULT-VAR
         MOVE 74 TO WS-TYPE
         CALL "SP-GET-COMPONENT-X" USING L-VAR(WS-BANNER-SLOT) WS-TYPE WS-VALUE WS-LENGTH WS-FOUND
         IF WS-FOUND = 1
             CALL "SP-SET-COMPONENT-X" USING L-RESULT-VAR WS-TYPE WS-VALUE WS-LENGTH
         END-IF
         CALL "CRAFT-COLOR-OF" USING L-ITEM(WS-BANNER-SLOT) WS-SUFFIX-BANNER WS-COLOR
         MOVE FUNCTION MAX(WS-COLOR, 0) TO WS-COLOR
         MOVE 75 TO WS-TYPE
         MOVE SPACES TO WS-VALUE
         MOVE 1 TO WS-POS
         CALL "SC-VPUT" USING WS-VALUE WS-POS WS-COLOR
         COMPUTE WS-LENGTH = WS-POS - 1
         CALL "SP-SET-COMPONENT-X" USING L-RESULT-VAR WS-TYPE WS-VALUE WS-LENGTH
     END-IF.

*> 27 2.13: two stacks of one damageable item; the result is a new stack of it with damage max(M - (remA + remB + M * 5 / 100), 0).
 REPAIR-RULE.
     MOVE 0 TO WS-SLOT-A WS-SLOT-B
     PERFORM VARYING WS-S FROM 1 BY 1 UNTIL WS-S > 9
         IF L-ITEM(WS-S) NOT = 0
             IF WS-SLOT-A = 0
                 MOVE WS-S TO WS-SLOT-A
             ELSE
                 MOVE WS-S TO WS-SLOT-B
             END-IF
         END-IF
     END-PERFORM
     IF WS-N = 2 AND WS-SLOT-B > 0 AND L-ITEM(WS-SLOT-A) = L-ITEM(WS-SLOT-B)
         CALL "SP-GET-MAX-DAMAGE" USING L-ITEM(WS-SLOT-A) L-VAR(WS-SLOT-A) WS-MAX-A
         CALL "SP-GET-MAX-DAMAGE" USING L-ITEM(WS-SLOT-B) L-VAR(WS-SLOT-B) WS-MAX-B
         IF WS-MAX-A > 0 AND WS-MAX-B > 0
             CALL "SP-GET-DAMAGE" USING L-ITEM(WS-SLOT-A) L-VAR(WS-SLOT-A) WS-DMG-A
             CALL "SP-GET-DAMAGE" USING L-ITEM(WS-SLOT-B) L-VAR(WS-SLOT-B) WS-DMG-B
             CALL "RECIPE-REPAIR" USING WS-MAX-A WS-DMG-A WS-MAX-B WS-DMG-B WS-MAX WS-DMG
             MOVE 1 TO L-MATCHED
             MOVE L-ITEM(WS-SLOT-A) TO L-RESULT-ITEM
             IF WS-DMG > 0
                 CALL "SP-SET-DAMAGE" USING L-RESULT-VAR WS-DMG
             END-IF
         END-IF
     END-IF.
 MAIN-LINE.
     MOVE 0 TO L-MATCHED L-RESULT-ITEM L-RESULT-VAR WS-N
     PERFORM VARYING WS-S FROM 1 BY 1 UNTIL WS-S > 9
         IF L-ITEM(WS-S) NOT = 0
             ADD 1 TO WS-N
         END-IF
     END-PERFORM
     EVALUATE RR-SERIALIZER(L-ROW)
         WHEN 2
             PERFORM DYE-RULE
         WHEN 3
             PERFORM IMBUE-RULE
         WHEN 8
             PERFORM ROCKET-RULE
         WHEN 9
             PERFORM STAR-RULE
         WHEN 10
             PERFORM FADE-RULE
         WHEN 11
             PERFORM BANNER-RULE
         WHEN 12
             PERFORM SHIELD-RULE
         WHEN 13
             PERFORM REPAIR-RULE
     END-EVALUATE
     CONTINUE.
 END PROGRAM CRAFT-SPECIAL.
