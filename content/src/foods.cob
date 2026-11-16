*> The food of an item row (docs/protocol/25 part 1 section 8.2, part 5 section 4.1, 17 section 4.9): the components summary of an item
*> row of a standard set names its food component as "food apple" or "food Foods.COOKED_BEEF" (a constant of Foods) or as "food {6,1.2,true}"
*> (nutrition, saturation, can_always_eat), and the stand-in rows hold "food <nutrition>". CONTENT-FOOD turns the text into the numbers
*> that eating needs; the saturation of a Foods constant is nutrition x modifier x 2.
*> USING components (PIC X(160)), nutrition out (0 for no food), saturation out (thousandths), always out (1 when it can be eaten at food 20),
*>   ticks out (the use time: 32 for 1.6 s, 16 for dried kelp, 40 for the honey bottle; 0 for a number only, the core's default).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. CONTENT-FOOD.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-FOODS.
    05 FILLER PIC X(30) VALUE "apple                 04024000".
    05 FILLER PIC X(30) VALUE "baked_potato          05060000".
    05 FILLER PIC X(30) VALUE "beef                  03018000".
    05 FILLER PIC X(30) VALUE "beetroot              01012000".
    05 FILLER PIC X(30) VALUE "beetroot_soup         06072000".
    05 FILLER PIC X(30) VALUE "bread                 05060000".
    05 FILLER PIC X(30) VALUE "carrot                03036000".
    05 FILLER PIC X(30) VALUE "chicken               02012000".
    05 FILLER PIC X(30) VALUE "chorus_fruit          04024001".
    05 FILLER PIC X(30) VALUE "cod                   02004000".
    05 FILLER PIC X(30) VALUE "cooked_beef           08128000".
    05 FILLER PIC X(30) VALUE "cooked_chicken        06072000".
    05 FILLER PIC X(30) VALUE "cooked_cod            05060000".
    05 FILLER PIC X(30) VALUE "cooked_mutton         06096000".
    05 FILLER PIC X(30) VALUE "cooked_porkchop       08128000".
    05 FILLER PIC X(30) VALUE "cooked_rabbit         05060000".
    05 FILLER PIC X(30) VALUE "cooked_salmon         06096000".
    05 FILLER PIC X(30) VALUE "cookie                02004000".
    05 FILLER PIC X(30) VALUE "dried_kelp            01006000".
    05 FILLER PIC X(30) VALUE "enchanted_golden_apple04096001".
    05 FILLER PIC X(30) VALUE "glow_berries          02004000".
    05 FILLER PIC X(30) VALUE "golden_apple          04096001".
    05 FILLER PIC X(30) VALUE "golden_carrot         06144000".
    05 FILLER PIC X(30) VALUE "honey_bottle          06012001".
    05 FILLER PIC X(30) VALUE "melon_slice           02012000".
    05 FILLER PIC X(30) VALUE "mushroom_stew         06072000".
    05 FILLER PIC X(30) VALUE "mutton                02012000".
    05 FILLER PIC X(30) VALUE "poisonous_potato      02012000".
    05 FILLER PIC X(30) VALUE "porkchop              03018000".
    05 FILLER PIC X(30) VALUE "potato                01006000".
    05 FILLER PIC X(30) VALUE "pufferfish            01002000".
    05 FILLER PIC X(30) VALUE "pumpkin_pie           08048000".
    05 FILLER PIC X(30) VALUE "rabbit                03018000".
    05 FILLER PIC X(30) VALUE "rabbit_stew           10120000".
    05 FILLER PIC X(30) VALUE "rotten_flesh          04008000".
    05 FILLER PIC X(30) VALUE "salmon                02004000".
    05 FILLER PIC X(30) VALUE "spider_eye            02032000".
    05 FILLER PIC X(30) VALUE "suspicious_stew       06072001".
    05 FILLER PIC X(30) VALUE "sweet_berries         02004000".
    05 FILLER PIC X(30) VALUE "tropical_fish         01002000".
 01 WS-TABLE REDEFINES WS-FOODS.
    05 WS-ROW OCCURS 40 TIMES.
       10 WS-NAME            PIC X(22).
       10 WS-NUTRITION       PIC 99.
       10 WS-SATURATION      PIC 9(5).
       10 WS-ALWAYS          PIC 9.
 01 WS-POS                 BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-TOKEN               PIC X(40).
 01 WS-KEY                 PIC X(40).
 01 WS-KEY-REST            PIC X(40).
 01 WS-N                   PIC X(8).
 01 WS-S                   PIC X(8).
 01 WS-A                   PIC X(8).
 01 WS-HITS                BINARY-LONG.
 LINKAGE SECTION.
 01 L-TEXT                 PIC X(160).
 01 L-NUTRITION            BINARY-LONG.
 01 L-SATURATION           BINARY-LONG.
 01 L-ALWAYS               BINARY-LONG.
 01 L-TICKS                BINARY-LONG.
 PROCEDURE DIVISION USING L-TEXT L-NUTRITION L-SATURATION L-ALWAYS L-TICKS.
     MOVE 0 TO L-NUTRITION L-SATURATION L-ALWAYS L-TICKS WS-POS
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 150 OR WS-POS > 0
         IF L-TEXT(WS-I:5) = "food " AND (WS-I = 1 OR L-TEXT(WS-I - 1:1) = SPACE)
             MOVE WS-I TO WS-POS
         END-IF
     END-PERFORM
     IF WS-POS = 0
         GOBACK
     END-IF
     ADD 5 TO WS-POS
     MOVE SPACES TO WS-TOKEN
     EVALUATE TRUE
         WHEN L-TEXT(WS-POS:1) = "{"
             ADD 1 TO WS-POS
             UNSTRING L-TEXT(WS-POS:) DELIMITED BY "}" INTO WS-TOKEN
             MOVE SPACES TO WS-N WS-S WS-A
             UNSTRING WS-TOKEN DELIMITED BY "," INTO WS-N WS-S WS-A
             COMPUTE L-NUTRITION = FUNCTION NUMVAL(WS-N)
             COMPUTE L-SATURATION = FUNCTION NUMVAL(WS-S) * 1000
             IF WS-A = "true"
                 MOVE 1 TO L-ALWAYS
             END-IF
             MOVE 32 TO L-TICKS
             MOVE 0 TO WS-HITS
             INSPECT L-TEXT TALLYING WS-HITS FOR ALL "consumable honey"
             IF WS-HITS > 0
                 MOVE 40 TO L-TICKS
             END-IF
         WHEN L-TEXT(WS-POS:1) >= "0" AND L-TEXT(WS-POS:1) <= "9"
             UNSTRING L-TEXT(WS-POS:) DELIMITED BY "," OR SPACE INTO WS-TOKEN
             COMPUTE L-NUTRITION = FUNCTION NUMVAL(WS-TOKEN)
         WHEN OTHER
             UNSTRING L-TEXT(WS-POS:) DELIMITED BY "," OR SPACE INTO WS-TOKEN
             MOVE FUNCTION LOWER-CASE(WS-TOKEN) TO WS-KEY
             IF WS-KEY(1:6) = "foods."
                 MOVE WS-KEY(7:) TO WS-KEY-REST
                MOVE WS-KEY-REST TO WS-KEY
             END-IF
             PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 40
                 IF WS-NAME(WS-I) = WS-KEY
                     MOVE WS-NUTRITION(WS-I) TO L-NUTRITION
                     MOVE WS-SATURATION(WS-I) TO L-SATURATION
                     MOVE WS-ALWAYS(WS-I) TO L-ALWAYS
                     MOVE 32 TO L-TICKS
                     IF WS-KEY = "dried_kelp"
                         MOVE 16 TO L-TICKS
                     END-IF
                     IF WS-KEY = "honey_bottle"
                         MOVE 40 TO L-TICKS
                     END-IF
                 END-IF
             END-PERFORM
     END-EVALUATE
     GOBACK.
 END PROGRAM CONTENT-FOOD.
