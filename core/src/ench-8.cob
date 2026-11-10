*> The enchantment engine (docs/protocol/28 sections 8 and 9; US14; T2175): how levels, iteration and hook results combine. Thousandths where a
*> value is passed. The folding of the effects of one component is TOOL-VALUE-FOLD (ench-5.cob), the evaluation of the numbers TOOL-LBV-EVAL.
*>   TOOL-ENGINE-SLOT USING index (1 to 8), slot name out (mainhand, offhand, feet, legs, chest, head, body, saddle)
*>   TOOL-ENGINE-MAX-LEVEL USING levels (PIC X(200): one per slot where the enchantment is active), maximum out (getEnchantmentLevel)
*>   TOOL-ENGINE-HIGHEST USING levels (one per enchantment defining the component), index out (1-based, first on ties; 0 when none)
*>   TOOL-ENGINE-PICK USING level, list size, index out (min(level, size) - 1; -1 for no level) (pickHighestLevel)
*>   TOOL-HOOK-FINAL USING hook (the H number), folded value, result out (the clamp or conversion of section 9)
*>   TOOL-HOOK-RANDOM USING hook, source out (0 the level's random, 1 the enchanted entity's, 2 the wielder's)
*>   TOOL-ENGINE-ANY USING matching effects, any out (damage_immunity and the has tests)
*>   TOOL-AMMO-USE USING iteration (0 first), ammo_use value, shooter has infinite materials, ammo count, ammo consumed out, result out (0 empty,
*>     1 split off, 2 intangible copy)
*>   TOOL-MENDING-CANDIDATES USING item is damaged, repair_with_xp enchantments, candidates out
*>   TOOL-POST-ATTACK-PASS USING victim living, weapon given, attacker living, onBreak given, victim pass out, attacker pass out, item-only pass out

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TOOL-ENGINE-SLOT.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-INDEX                BINARY-LONG.
 01 L-SLOT                 PIC X(48).
 PROCEDURE DIVISION USING L-INDEX L-SLOT.
     EVALUATE L-INDEX
         WHEN 1
             MOVE "mainhand" TO L-SLOT
         WHEN 2
             MOVE "offhand" TO L-SLOT
         WHEN 3
             MOVE "feet" TO L-SLOT
         WHEN 4
             MOVE "legs" TO L-SLOT
         WHEN 5
             MOVE "chest" TO L-SLOT
         WHEN 6
             MOVE "head" TO L-SLOT
         WHEN 7
             MOVE "body" TO L-SLOT
         WHEN OTHER
             MOVE "saddle" TO L-SLOT
     END-EVALUATE
     GOBACK.
 END PROGRAM TOOL-ENGINE-SLOT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TOOL-ENGINE-MAX-LEVEL.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-TOKENS.
    05 WS-TOKEN            PIC X(16) OCCURS 60 TIMES.
 01 WS-COUNT               BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-V                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-LEVELS               PIC X(200).
 01 L-MAX                  BINARY-LONG.
 PROCEDURE DIVISION USING L-LEVELS L-MAX.
     MOVE 0 TO L-MAX
     CALL "TOOL-LBV-TOKENS" USING L-LEVELS WS-TOKENS WS-COUNT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-COUNT
         COMPUTE WS-V = FUNCTION NUMVAL(WS-TOKEN(WS-I))
         IF WS-V > L-MAX
             MOVE WS-V TO L-MAX
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM TOOL-ENGINE-MAX-LEVEL.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TOOL-ENGINE-HIGHEST.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-TOKENS.
    05 WS-TOKEN            PIC X(16) OCCURS 60 TIMES.
 01 WS-COUNT               BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-V                   BINARY-LONG.
 01 WS-BEST                BINARY-LONG.
 LINKAGE SECTION.
 01 L-LEVELS               PIC X(200).
 01 L-INDEX                BINARY-LONG.
 PROCEDURE DIVISION USING L-LEVELS L-INDEX.
     MOVE 0 TO L-INDEX WS-BEST
     CALL "TOOL-LBV-TOKENS" USING L-LEVELS WS-TOKENS WS-COUNT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-COUNT
         COMPUTE WS-V = FUNCTION NUMVAL(WS-TOKEN(WS-I))
         IF WS-V > WS-BEST
             MOVE WS-V TO WS-BEST
             MOVE WS-I TO L-INDEX
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM TOOL-ENGINE-HIGHEST.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TOOL-ENGINE-PICK.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-LEVEL                BINARY-LONG.
 01 L-SIZE                 BINARY-LONG.
 01 L-INDEX                BINARY-LONG.
 PROCEDURE DIVISION USING L-LEVEL L-SIZE L-INDEX.
     IF L-LEVEL < 1
         MOVE -1 TO L-INDEX
     ELSE
         IF L-LEVEL < L-SIZE
             COMPUTE L-INDEX = L-LEVEL - 1
         ELSE
             COMPUTE L-INDEX = L-SIZE - 1
         END-IF
     END-IF
     GOBACK.
 END PROGRAM TOOL-ENGINE-PICK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TOOL-HOOK-FINAL.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-INT                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-HOOK                 BINARY-LONG.
 01 L-VALUE                BINARY-LONG.
 01 L-RESULT               BINARY-LONG.
 PROCEDURE DIVISION USING L-HOOK L-VALUE L-RESULT.
     MOVE L-VALUE TO L-RESULT
     EVALUATE L-HOOK
         WHEN 10 WHEN 14 WHEN 22 WHEN 23
             COMPUTE WS-INT = L-VALUE / 1000
             COMPUTE L-RESULT = WS-INT * 1000
         WHEN 15 WHEN 18 WHEN 19 WHEN 21 WHEN 24
             COMPUTE WS-INT = L-VALUE / 1000
             COMPUTE L-RESULT = WS-INT * 1000
             IF L-RESULT < 0
                 MOVE 0 TO L-RESULT
             END-IF
         WHEN 17 WHEN 20 WHEN 26
             IF L-RESULT < 0
                 MOVE 0 TO L-RESULT
             END-IF
     END-EVALUATE
     GOBACK.
 END PROGRAM TOOL-HOOK-FINAL.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TOOL-HOOK-RANDOM.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-HOOK                 BINARY-LONG.
 01 L-SOURCE               BINARY-LONG.
 PROCEDURE DIVISION USING L-HOOK L-SOURCE.
     EVALUATE L-HOOK
         WHEN 10 WHEN 14 WHEN 15 WHEN 22 WHEN 24
             MOVE 0 TO L-SOURCE
         WHEN 26 WHEN 31
             MOVE 2 TO L-SOURCE
         WHEN OTHER
             MOVE 1 TO L-SOURCE
     END-EVALUATE
     GOBACK.
 END PROGRAM TOOL-HOOK-RANDOM.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TOOL-ENGINE-ANY.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-MATCHES              BINARY-LONG.
 01 L-ANY                  BINARY-LONG.
 PROCEDURE DIVISION USING L-MATCHES L-ANY.
     MOVE 0 TO L-ANY
     IF L-MATCHES > 0
         MOVE 1 TO L-ANY
     END-IF
     GOBACK.
 END PROGRAM TOOL-ENGINE-ANY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TOOL-AMMO-USE.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-ITERATION            BINARY-LONG.
 01 L-USE                  BINARY-LONG.
 01 L-INFINITE             BINARY-LONG.
 01 L-COUNT                BINARY-LONG.
 01 L-CONSUMED             BINARY-LONG.
 01 L-RESULT               BINARY-LONG.
 PROCEDURE DIVISION USING L-ITERATION L-USE L-INFINITE L-COUNT L-CONSUMED L-RESULT.
     MOVE L-USE TO L-CONSUMED
     IF L-ITERATION > 0 OR L-INFINITE = 1
         MOVE 0 TO L-CONSUMED
     END-IF
     EVALUATE TRUE
         WHEN L-CONSUMED > L-COUNT
             MOVE 0 TO L-RESULT
         WHEN L-CONSUMED = 0
             MOVE 2 TO L-RESULT
         WHEN OTHER
             MOVE 1 TO L-RESULT
     END-EVALUATE
     GOBACK.
 END PROGRAM TOOL-AMMO-USE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TOOL-MENDING-CANDIDATES.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-DAMAGED              BINARY-LONG.
 01 L-ENCHANTMENTS         BINARY-LONG.
 01 L-CANDIDATES           BINARY-LONG.
 PROCEDURE DIVISION USING L-DAMAGED L-ENCHANTMENTS L-CANDIDATES.
     MOVE 0 TO L-CANDIDATES
     IF L-DAMAGED = 1
         MOVE L-ENCHANTMENTS TO L-CANDIDATES
     END-IF
     GOBACK.
 END PROGRAM TOOL-MENDING-CANDIDATES.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TOOL-POST-ATTACK-PASS.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-VICTIM               BINARY-LONG.
 01 L-WEAPON               BINARY-LONG.
 01 L-ATTACKER             BINARY-LONG.
 01 L-ON-BREAK             BINARY-LONG.
 01 L-PASS-VICTIM          BINARY-LONG.
 01 L-PASS-ATTACKER        BINARY-LONG.
 01 L-PASS-ITEM            BINARY-LONG.
 PROCEDURE DIVISION USING L-VICTIM L-WEAPON L-ATTACKER L-ON-BREAK L-PASS-VICTIM L-PASS-ATTACKER L-PASS-ITEM.
     MOVE L-VICTIM TO L-PASS-VICTIM
     MOVE 0 TO L-PASS-ATTACKER L-PASS-ITEM
     IF L-WEAPON = 1
         IF L-ATTACKER = 1
             MOVE 1 TO L-PASS-ATTACKER
         ELSE
             MOVE L-ON-BREAK TO L-PASS-ITEM
         END-IF
     END-IF
     GOBACK.
 END PROGRAM TOOL-POST-ATTACK-PASS.
