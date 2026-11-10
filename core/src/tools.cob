*> Tool speed, correct tool for drops and the per-item stats of the tools (docs/protocol/17 section 1.3, 1.4 and 2; US14; T2017).
*>
*> The tool component of an item is read from the item's default components (CONTENT-ITEM-COMPONENT): tool_rule_1 to tool_rule_4,
*> each "deny <set>" (a rule with correct_for_drops false), "mine <set> <speed>" (a speed and correct_for_drops true) or "speed <set>
*> <speed>" (a speed only), the set being a block key or a "#" and a tag of the block registry; and tool_default_speed. The two lookups
*> of 17 section 1.3 scan the rules in order and stop at the first matching rule that carries the wanted field: the mining speed (else the
*> default speed, 1.0 for an item without tool rules) and correct_for_drops (no match: false). The speed text "3.4028235E38" (the instant
*> mining of bamboo) is capped at 2000000000 thousandths. Whether the block needs a tool at all is the caller's (CB-TOOL-REQ): the speed
*> and the answer feed BREAK-RATE (breaking.cob) as its speed and correct inputs.
*>
*> Entry points:
*>   TOOL-SET-MATCH USING set (PIC X(100): a block key or "#" and a tag; blank matches nothing), block key (PIC X(48)), block id
*>     (BINARY-LONG), matched out (1 or 0)
*>   TOOL-RULE-EVAL USING item id (BINARY-LONG; a negative or unknown id has no tool), block key (PIC X(48)), block id, speed out
*>     (thousandths), correct out (1 or 0: the first matching rule that carries correct_for_drops says true)
*>   TOOL-BLOCK-SPEED USING item id, block id, speed out, correct out: TOOL-RULE-EVAL with the key of the block table
*>   TOOL-ITEM-STATS USING item key (PIC X(48), the "minecraft:" optional), found out, durability, attack damage (1 + the modifier, in
*>     1/10000), attack speed (4 + the modifier, 1/10000), full-charge cooldown (20 / speed ticks, 1/10000; the swing ticks of an item with
*>     an attack animation), mining speed of the material (thousandths) out; found is 1 for an item with an attack_damage component
*>   TOOL-IS-WATER USING block key (PIC X(48)), result out (1 for minecraft:water, else 0)
*>   TOOL-ENCHANT-ID USING enchantment key (PIC X(112), "minecraft:efficiency"), id out (the registry id of the enchantment registry, -1 none)
*>   TOOL-BREAK-MODS USING player row, efficiency out (the Efficiency level of the held stack), haste out, fatigue out (amplifier + 1; 0: none, the
*>     effect store of effects.cob), water out (1 with the eyes, 1.62 above the feet, in water): the four extra inputs of
*>     BREAK-RATE (breaking.cob)
*>   TOOL-KIND-STATS USING wanted kind (PIC X(12): sword, pickaxe, axe, shovel, hoe, spear), then the arguments of TOOL-ITEM-STATS: the same,
*>     found only when the key is "<material>_<kind>" (tools-swords.cob and the files of the other kinds call it)

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TOOL-SET-MATCH.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-REGISTRY            PIC X(48) VALUE "block".
 01 WS-TAG                 PIC X(112).
 01 WS-TAGGED              BINARY-LONG.
 LINKAGE SECTION.
 01 L-SET                  PIC X(100).
 01 L-KEY                  PIC X(48).
 01 L-ID                   BINARY-LONG.
 01 L-MATCHED              BINARY-LONG.
 PROCEDURE DIVISION USING L-SET L-KEY L-ID L-MATCHED.
     MOVE 0 TO L-MATCHED
     EVALUATE TRUE
         WHEN L-SET = SPACES
             CONTINUE
         WHEN L-SET(1:1) = "#"
             MOVE SPACES TO WS-TAG
             MOVE L-SET(2:99) TO WS-TAG
             CALL "CONTENT-TAG-HAS" USING WS-REGISTRY WS-TAG L-ID WS-TAGGED
             MOVE WS-TAGGED TO L-MATCHED
         WHEN FUNCTION TRIM(L-SET) = FUNCTION TRIM(L-KEY)
             MOVE 1 TO L-MATCHED
     END-EVALUATE
     GOBACK.
 END PROGRAM TOOL-SET-MATCH.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TOOL-RULE-APPLY.
*> USING rule kind (PIC X(8): deny, mine or speed), speed text (PIC X(24)), got speed, got correct (BINARY-LONG, in and out: 1 once a
*> matching rule gave the answer), speed (thousandths, in and out), correct (in and out): one matching rule of TOOL-RULE-EVAL.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-EXPONENT            BINARY-LONG.
 LINKAGE SECTION.
 01 L-KIND                 PIC X(8).
 01 L-SPEED-TEXT           PIC X(24).
 01 L-GOT-SPEED            BINARY-LONG.
 01 L-GOT-CORRECT          BINARY-LONG.
 01 L-SPEED                BINARY-LONG.
 01 L-CORRECT              BINARY-LONG.
 PROCEDURE DIVISION USING L-KIND L-SPEED-TEXT L-GOT-SPEED L-GOT-CORRECT L-SPEED L-CORRECT.
     IF L-KIND NOT = "deny" AND L-GOT-SPEED = 0
         MOVE 1 TO L-GOT-SPEED
         MOVE 0 TO WS-EXPONENT
         INSPECT L-SPEED-TEXT TALLYING WS-EXPONENT FOR ALL "E"
         IF WS-EXPONENT > 0
             MOVE 2000000000 TO L-SPEED
         ELSE
             COMPUTE L-SPEED ROUNDED = FUNCTION NUMVAL(L-SPEED-TEXT) * 1000
         END-IF
     END-IF
     IF L-KIND NOT = "speed" AND L-GOT-CORRECT = 0
         MOVE 1 TO L-GOT-CORRECT
         IF L-KIND = "mine"
             MOVE 1 TO L-CORRECT
         ELSE
             MOVE 0 TO L-CORRECT
         END-IF
     END-IF
     GOBACK.
 END PROGRAM TOOL-RULE-APPLY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TOOL-RULE-EVAL.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CONTENT.
 01 WS-N                   BINARY-LONG.
 01 WS-NAME                PIC X(32).
 01 WS-VALUE               PIC X(100).
 01 WS-STATUS              BINARY-LONG.
 01 WS-KIND                PIC X(8).
 01 WS-SET                 PIC X(100).
 01 WS-SPEED-TEXT          PIC X(24).
 01 WS-MATCHED             BINARY-LONG.
 01 WS-GOT-SPEED           BINARY-LONG.
 01 WS-GOT-CORRECT         BINARY-LONG.
 01 WS-E                   PIC 9.
 LINKAGE SECTION.
 01 L-ITEM                 BINARY-LONG.
 01 L-KEY                  PIC X(48).
 01 L-BLOCK                BINARY-LONG.
 01 L-SPEED                BINARY-LONG.
 01 L-CORRECT              BINARY-LONG.
 PROCEDURE DIVISION USING L-ITEM L-KEY L-BLOCK L-SPEED L-CORRECT.
     MOVE 1000 TO L-SPEED
     MOVE 0 TO L-CORRECT WS-GOT-SPEED WS-GOT-CORRECT
     MOVE "tool_default_speed" TO WS-NAME
     CALL "CONTENT-ITEM-COMPONENT" USING L-ITEM WS-NAME WS-VALUE WS-STATUS
     IF WS-STATUS = CT-OK
         COMPUTE L-SPEED ROUNDED = FUNCTION NUMVAL(WS-VALUE) * 1000
     END-IF
     PERFORM VARYING WS-N FROM 1 BY 1 UNTIL WS-N > 4
         MOVE SPACES TO WS-NAME
         MOVE WS-N TO WS-E
         STRING "tool_rule_" WS-E DELIMITED BY SIZE INTO WS-NAME
         CALL "CONTENT-ITEM-COMPONENT" USING L-ITEM WS-NAME WS-VALUE WS-STATUS
         IF WS-STATUS = CT-OK
             MOVE SPACES TO WS-KIND WS-SET WS-SPEED-TEXT
             UNSTRING WS-VALUE DELIMITED BY SPACE INTO WS-KIND WS-SET WS-SPEED-TEXT
             CALL "TOOL-SET-MATCH" USING WS-SET L-KEY L-BLOCK WS-MATCHED
             IF WS-MATCHED = 1
                 CALL "TOOL-RULE-APPLY" USING WS-KIND WS-SPEED-TEXT WS-GOT-SPEED WS-GOT-CORRECT L-SPEED L-CORRECT
             END-IF
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM TOOL-RULE-EVAL.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TOOL-BLOCK-SPEED.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CBLOCKS.
 01 WS-KEY                 PIC X(48).
 LINKAGE SECTION.
 01 L-ITEM                 BINARY-LONG.
 01 L-BLOCK                BINARY-LONG.
 01 L-SPEED                BINARY-LONG.
 01 L-CORRECT              BINARY-LONG.
 PROCEDURE DIVISION USING L-ITEM L-BLOCK L-SPEED L-CORRECT.
     MOVE CB-KEY(L-BLOCK + 1) TO WS-KEY
     CALL "TOOL-RULE-EVAL" USING L-ITEM WS-KEY L-BLOCK L-SPEED L-CORRECT
     GOBACK.
 END PROGRAM TOOL-BLOCK-SPEED.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TOOL-ITEM-STATS.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CONTENT.
 01 WS-KEY                 PIC X(112).
 01 WS-SHORT               PIC X(48).
 01 WS-ID                  BINARY-LONG.
 01 WS-ROW                 PIC X(270).
 01 WS-STATUS              BINARY-LONG.
 01 WS-NAME                PIC X(32).
 01 WS-VALUE               PIC X(100).
 01 WS-MATERIAL            PIC X(12).
 01 WS-KIND                PIC X(24).
 01 WS-DUR                 BINARY-LONG.
 01 WS-BONUS               BINARY-LONG.
 01 WS-ENCHANT             BINARY-LONG.
 01 WS-REPAIR              PIC X(40).
 01 WS-DENY                PIC X(48).
 01 WS-TIERS               PIC X(24).
 01 WS-MATERIAL-FOUND      BINARY-LONG.
 01 WS-STAB                PIC X(8).
 01 WS-TICKS               PIC X(8).
 01 WS-WIDE                FLOAT-LONG.
 LINKAGE SECTION.
 01 L-KEY                  PIC X(48).
 01 L-FOUND                BINARY-LONG.
 01 L-DURABILITY           BINARY-LONG.
 01 L-DAMAGE               BINARY-LONG.
 01 L-SPEED                BINARY-LONG.
 01 L-COOLDOWN             BINARY-LONG.
 01 L-MINING               BINARY-LONG.
 PROCEDURE DIVISION USING L-KEY L-FOUND L-DURABILITY L-DAMAGE L-SPEED L-COOLDOWN L-MINING.
     MOVE 0 TO L-FOUND L-DURABILITY L-DAMAGE L-SPEED L-COOLDOWN L-MINING
     MOVE SPACES TO WS-KEY WS-SHORT
     IF L-KEY(1:10) = "minecraft:"
         MOVE L-KEY(11:38) TO WS-SHORT
     ELSE
         MOVE L-KEY TO WS-SHORT
     END-IF
     MOVE WS-SHORT TO WS-KEY
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-ID WS-ROW WS-STATUS
     IF WS-STATUS NOT = CT-OK
         GOBACK
     END-IF
     MOVE "attack_damage" TO WS-NAME
     CALL "CONTENT-ITEM-COMPONENT" USING WS-ID WS-NAME WS-VALUE WS-STATUS
     IF WS-STATUS NOT = CT-OK
         GOBACK
     END-IF
     MOVE 1 TO L-FOUND
     COMPUTE L-DAMAGE ROUNDED = 10000 + FUNCTION NUMVAL(WS-VALUE) * 10000
     MOVE "attack_speed" TO WS-NAME
     CALL "CONTENT-ITEM-COMPONENT" USING WS-ID WS-NAME WS-VALUE WS-STATUS
     COMPUTE L-SPEED ROUNDED = 40000 + FUNCTION NUMVAL(WS-VALUE) * 10000
     MOVE "max_damage" TO WS-NAME
     CALL "CONTENT-ITEM-COMPONENT" USING WS-ID WS-NAME WS-VALUE WS-STATUS
     COMPUTE L-DURABILITY = FUNCTION NUMVAL(WS-VALUE)
     COMPUTE WS-WIDE = 2000000000 / L-SPEED
     COMPUTE L-COOLDOWN ROUNDED = WS-WIDE
     MOVE "attack_animation" TO WS-NAME
     CALL "CONTENT-ITEM-COMPONENT" USING WS-ID WS-NAME WS-VALUE WS-STATUS
     IF WS-STATUS = CT-OK
         MOVE SPACES TO WS-STAB WS-TICKS
         UNSTRING WS-VALUE DELIMITED BY SPACE INTO WS-STAB WS-TICKS
         COMPUTE L-COOLDOWN = FUNCTION NUMVAL(WS-TICKS) * 10000
     END-IF
     MOVE SPACES TO WS-MATERIAL WS-KIND
     UNSTRING WS-SHORT DELIMITED BY "_" INTO WS-MATERIAL WS-KIND
     CALL "TOOL-MATERIAL" USING WS-MATERIAL WS-DUR L-MINING WS-BONUS WS-ENCHANT WS-REPAIR WS-DENY WS-TIERS
         WS-MATERIAL-FOUND
     COMPUTE L-MINING = L-MINING * 1000
     GOBACK.
 END PROGRAM TOOL-ITEM-STATS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TOOL-KIND-STATS.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-SHORT               PIC X(48).
 01 WS-MATERIAL            PIC X(12).
 01 WS-KIND                PIC X(24).
 LINKAGE SECTION.
 01 L-WANTED               PIC X(12).
 01 L-KEY                  PIC X(48).
 01 L-FOUND                BINARY-LONG.
 01 L-DURABILITY           BINARY-LONG.
 01 L-DAMAGE               BINARY-LONG.
 01 L-SPEED                BINARY-LONG.
 01 L-COOLDOWN             BINARY-LONG.
 01 L-MINING               BINARY-LONG.
 PROCEDURE DIVISION USING L-WANTED L-KEY L-FOUND L-DURABILITY L-DAMAGE L-SPEED L-COOLDOWN L-MINING.
     MOVE 0 TO L-FOUND L-DURABILITY L-DAMAGE L-SPEED L-COOLDOWN L-MINING
     MOVE SPACES TO WS-SHORT WS-MATERIAL WS-KIND
     IF L-KEY(1:10) = "minecraft:"
         MOVE L-KEY(11:38) TO WS-SHORT
     ELSE
         MOVE L-KEY TO WS-SHORT
     END-IF
     UNSTRING WS-SHORT DELIMITED BY "_" INTO WS-MATERIAL WS-KIND
     IF WS-KIND = L-WANTED
         CALL "TOOL-ITEM-STATS" USING L-KEY L-FOUND L-DURABILITY L-DAMAGE L-SPEED L-COOLDOWN L-MINING
     END-IF
     GOBACK.
 END PROGRAM TOOL-KIND-STATS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TOOL-IS-WATER.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-HITS                BINARY-LONG.
 LINKAGE SECTION.
 01 L-KEY                  PIC X(48).
 01 L-WATER                BINARY-LONG.
 PROCEDURE DIVISION USING L-KEY L-WATER.
     MOVE 0 TO WS-HITS
     INSPECT L-KEY TALLYING WS-HITS FOR ALL "minecraft:water "
     MOVE WS-HITS TO L-WATER
     GOBACK.
 END PROGRAM TOOL-IS-WATER.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TOOL-ENCHANT-ID.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CONTENT.
 01 WS-REGISTRY            PIC X(112) VALUE "enchantment".
 01 WS-COUNT               BINARY-LONG.
 01 WS-STATUS              BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-ENTRY               PIC X(112).
 01 WS-ENTRY-LENGTH        BINARY-LONG.
 01 WS-AREA                PIC X.
 01 WS-CAPACITY            BINARY-LONG VALUE 0.
 01 WS-LENGTH              BINARY-LONG.
 LINKAGE SECTION.
 01 L-KEY                  PIC X(112).
 01 L-ID                   BINARY-LONG.
 PROCEDURE DIVISION USING L-KEY L-ID.
     MOVE -1 TO L-ID
     CALL "CONTENT-REGISTRY-COUNT" USING WS-REGISTRY WS-COUNT WS-STATUS
     PERFORM VARYING WS-I FROM 0 BY 1 UNTIL WS-I >= WS-COUNT
         CALL "CONTENT-REGISTRY-ENTRY" USING WS-REGISTRY WS-I WS-ENTRY WS-ENTRY-LENGTH WS-AREA WS-CAPACITY
             WS-LENGTH WS-STATUS
         IF WS-ENTRY = L-KEY
             MOVE WS-I TO L-ID
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM TOOL-ENCHANT-ID.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TOOL-BREAK-MODS.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CBLOCKS.
 01 WS-KEY                 PIC X(112) VALUE "minecraft:efficiency".
 01 WS-ID                  BINARY-LONG.
 01 WS-HANDLE              BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-BLOCK-KEY           PIC X(48).
 01 WS-HASTE-ID            BINARY-LONG VALUE 2.
 01 WS-FATIGUE-ID          BINARY-LONG VALUE 3.
 01 WS-TICKS               BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-EFFICIENCY           BINARY-LONG.
 01 L-HASTE                BINARY-LONG.
 01 L-FATIGUE              BINARY-LONG.
 01 L-WATER                BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-EFFICIENCY L-HASTE L-FATIGUE L-WATER.
     MOVE 0 TO L-EFFICIENCY L-HASTE L-FATIGUE
     CALL "TOOL-ENCHANT-ID" USING WS-KEY WS-ID
     MOVE PL-SLOT-VAR(L-ROW, PL-HELD(L-ROW) + 1) TO WS-HANDLE
     CALL "SP-ENCHANT-LEVEL" USING WS-HANDLE WS-ID L-EFFICIENCY
     COMPUTE WS-X = FUNCTION INTEGER(PL-X(L-ROW))
     COMPUTE WS-Y = FUNCTION INTEGER(PL-Y(L-ROW) + 1.62)
     COMPUTE WS-Z = FUNCTION INTEGER(PL-Z(L-ROW))
     CALL "WORLD-GET-BLOCK" USING PL-DIM(L-ROW) WS-X WS-Y WS-Z WS-STATE
     MOVE CB-KEY(CB-S-BLOCK(WS-STATE + 1) + 1) TO WS-BLOCK-KEY
     CALL "TOOL-IS-WATER" USING WS-BLOCK-KEY L-WATER
     CALL "EFFECT-LEVEL" USING L-ROW WS-HASTE-ID L-HASTE WS-TICKS
     CALL "EFFECT-LEVEL" USING L-ROW WS-FATIGUE-ID L-FATIGUE WS-TICKS
     GOBACK.
 END PROGRAM TOOL-BREAK-MODS.
