*> Acceptance test of docs/protocol/34-entity-models-1-shared-model-and-framework.md section 4 (Model layers, ids and the layer registry): 4.1 the
*> id text form, 4.2 the counts (292 fields, 269 single layers, 23 armor sets, 361 layers) and naming rules, 4.3 lookup of an unknown layer, 4.4 the
*> animation definition ids and the sixteen definition classes, with Appendix A rows spot-checked by hand.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-ENTMODEL-34-1-4.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 01 WS-NAME                PIC X(120).
 01 WS-E                   BINARY-LONG.
 01 WS-O                   BINARY-LONG.
 01 WS-FIELDS              BINARY-LONG.
 01 WS-SINGLE              BINARY-LONG.
 01 WS-SETS                BINARY-LONG.
 01 WS-LAYERS              BINARY-LONG.
 01 WS-IDX                 BINARY-LONG.
 01 WS-ID                  PIC X(60).
 01 WS-FIELD               PIC X(28).
 01 WS-FIRST               BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-DUPS                BINARY-LONG.
 01 WS-CLASS               PIC X(28).
 01 WS-ANIM-FIELD          PIC X(28).
 01 WS-ANIM-ID             PIC X(60).
 01 WS-KNOWN               BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-ID2                 PIC X(60).
 01 WS-SAME                BINARY-LONG.
 PROCEDURE DIVISION.
     CALL "EM4-LAYER-COUNTS" USING WS-FIELDS WS-SINGLE WS-SETS WS-LAYERS
     MOVE "292 public fields" TO WS-NAME
     MOVE 292 TO WS-E
     MOVE WS-FIELDS TO WS-O
     PERFORM CHECK-NUM
     MOVE "269 single layers" TO WS-NAME
     MOVE 269 TO WS-E
     MOVE WS-SINGLE TO WS-O
     PERFORM CHECK-NUM
     MOVE "23 armor sets" TO WS-NAME
     MOVE 23 TO WS-E
     MOVE WS-SETS TO WS-O
     PERFORM CHECK-NUM
     MOVE "361 layers = 269 + 23 x 4" TO WS-NAME
     MOVE 361 TO WS-E
     MOVE WS-LAYERS TO WS-O
     PERFORM CHECK-NUM
*>   ids in table order
     MOVE 1 TO WS-IDX
     CALL "EM4-LAYER-ID" USING WS-IDX WS-ID
     MOVE "first layer id" TO WS-NAME
     MOVE "minecraft:boat/acacia#main" TO TL-EXPECTED
     MOVE WS-ID TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE 7 TO WS-IDX
     CALL "EM4-LAYER-ID" USING WS-IDX WS-ID
     MOVE "armor set layer 1 is the helmet" TO WS-NAME
     MOVE "minecraft:armor_stand#helmet" TO TL-EXPECTED
     MOVE WS-ID TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE 10 TO WS-IDX
     CALL "EM4-LAYER-ID" USING WS-IDX WS-ID
     MOVE "armor set layer 4 is the boots" TO WS-NAME
     MOVE "minecraft:armor_stand#boots" TO TL-EXPECTED
     MOVE WS-ID TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE 9 TO WS-IDX
     CALL "EM4-LAYER-ID" USING WS-IDX WS-ID
     MOVE "armor set layer 3 is the leggings" TO WS-NAME
     MOVE "minecraft:armor_stand#leggings" TO TL-EXPECTED
     MOVE WS-ID TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE 8 TO WS-IDX
     CALL "EM4-LAYER-ID" USING WS-IDX WS-ID
     MOVE "armor set layer 2 is the chestplate" TO WS-NAME
     MOVE "minecraft:armor_stand#chestplate" TO TL-EXPECTED
     MOVE WS-ID TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE 22 TO WS-IDX
     CALL "EM4-LAYER-ID" USING WS-IDX WS-ID
     MOVE "the banner flag layer string is flag" TO WS-NAME
     MOVE "minecraft:standing_banner#flag" TO TL-EXPECTED
     MOVE WS-ID TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE 361 TO WS-IDX
     CALL "EM4-LAYER-ID" USING WS-IDX WS-ID
     MOVE "last layer id" TO WS-NAME
     MOVE "minecraft:zombie_nautilus#main" TO TL-EXPECTED
     MOVE WS-ID TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE 362 TO WS-IDX
     CALL "EM4-LAYER-ID" USING WS-IDX WS-ID
     MOVE "an index past the end is empty" TO WS-NAME
     MOVE SPACES TO TL-EXPECTED
     MOVE WS-ID TO TL-OBSERVED
     PERFORM CHECK-TEXT
*>   lookups (bakeLayer of an unknown location is an error: index 0).
     MOVE "minecraft:allay#main" TO WS-ID
     CALL "EM4-LAYER-FIND" USING WS-ID WS-IDX
     MOVE "find allay#main (the third layer)" TO WS-NAME
     MOVE 3 TO WS-E
     MOVE WS-IDX TO WS-O
     PERFORM CHECK-NUM
     MOVE "minecraft:armor_stand#leggings" TO WS-ID
     CALL "EM4-LAYER-FIND" USING WS-ID WS-IDX
     MOVE "find a set layer" TO WS-NAME
     MOVE 9 TO WS-E
     MOVE WS-IDX TO WS-O
     PERFORM CHECK-NUM
     MOVE "minecraft:allay#flag" TO WS-ID
     CALL "EM4-LAYER-FIND" USING WS-ID WS-IDX
     MOVE "an unknown layer string is unknown" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-IDX TO WS-O
     PERFORM CHECK-NUM
     MOVE "minecraft:nope#main" TO WS-ID
     CALL "EM4-LAYER-FIND" USING WS-ID WS-IDX
     MOVE "an unknown model is unknown" TO WS-NAME
     MOVE WS-IDX TO WS-O
     PERFORM CHECK-NUM
*>   fields: armor sets take four layers, others one; the field name keys the set.
     MOVE "ARMOR_STAND_SMALL_ARMOR" TO WS-FIELD
     CALL "EM4-FIELD-LAYERS" USING WS-FIELD WS-FIRST WS-COUNT
     MOVE "armor set field: first layer 12 and four layers" TO WS-NAME
     COMPUTE WS-O = WS-FIRST * 10 + WS-COUNT
     MOVE 124 TO WS-E
     PERFORM CHECK-NUM
     MOVE "BREEZE_WIND" TO WS-FIELD
     CALL "EM4-FIELD-LAYERS" USING WS-FIELD WS-FIRST WS-COUNT
     MOVE "single field: one layer" TO WS-NAME
     MOVE WS-COUNT TO WS-O
     MOVE 1 TO WS-E
     PERFORM CHECK-NUM
     MOVE "NO_SUCH_FIELD" TO WS-FIELD
     CALL "EM4-FIELD-LAYERS" USING WS-FIELD WS-FIRST WS-COUNT
     MOVE "unknown field: no layers" TO WS-NAME
     MOVE WS-COUNT TO WS-O
     MOVE 0 TO WS-E
     PERFORM CHECK-NUM
*>   registering the same location twice throws: no two ids are equal.
     CALL "EM4-LAYER-DUPLICATES" USING WS-DUPS
     MOVE "no duplicate layer ids" TO WS-NAME
     MOVE WS-DUPS TO WS-O
     MOVE 0 TO WS-E
     PERFORM CHECK-NUM
*>   every id has the text form <namespace:model>#<layer>.
     MOVE 0 TO WS-J
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 361
         CALL "EM4-LAYER-ID" USING WS-I WS-ID
         IF WS-ID(1:10) NOT = "minecraft:"
             ADD 1 TO WS-J
         END-IF
         MOVE 0 TO WS-SAME
         INSPECT WS-ID TALLYING WS-SAME FOR ALL "#"
         IF WS-SAME NOT = 1
             ADD 1 TO WS-J
         END-IF
         CALL "EM4-LAYER-FIND" USING WS-ID WS-IDX
         IF WS-IDX NOT = WS-I
             ADD 1 TO WS-J
         END-IF
     END-PERFORM
     MOVE "every id has the text form and finds itself" TO WS-NAME
     MOVE WS-J TO WS-O
     MOVE 0 TO WS-E
     PERFORM CHECK-NUM
*> 4.4 animation ids.
     MOVE "CamelAnimation" TO WS-CLASS
     MOVE "CAMEL_WALK" TO WS-ANIM-FIELD
     CALL "EM4-ANIM-ID" USING WS-CLASS WS-ANIM-FIELD WS-ANIM-ID WS-KNOWN
     MOVE "animation id is Class.FIELD" TO WS-NAME
     MOVE "CamelAnimation.CAMEL_WALK" TO TL-EXPECTED
     MOVE WS-ANIM-ID TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE "a known definition class" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-KNOWN TO WS-O
     PERFORM CHECK-NUM
     MOVE "ParrotAnimation" TO WS-CLASS
     CALL "EM4-ANIM-ID" USING WS-CLASS WS-ANIM-FIELD WS-ANIM-ID WS-KNOWN
     MOVE "an unknown definition class" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-KNOWN TO WS-O
     PERFORM CHECK-NUM
     CALL "EM4-ANIM-CLASS-COUNT" USING WS-COUNT
     MOVE "sixteen definition classes" TO WS-NAME
     MOVE 16 TO WS-E
     MOVE WS-COUNT TO WS-O
     PERFORM CHECK-NUM
     MOVE "BabyRabbitAnimation" TO WS-CLASS
     CALL "EM4-ANIM-ID" USING WS-CLASS WS-ANIM-FIELD WS-ANIM-ID WS-KNOWN
     MOVE "BabyRabbitAnimation is a class" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-KNOWN TO WS-O
     PERFORM CHECK-NUM
     MOVE "WardenAnimation" TO WS-CLASS
     CALL "EM4-ANIM-ID" USING WS-CLASS WS-ANIM-FIELD WS-ANIM-ID WS-KNOWN
     MOVE "WardenAnimation is a class" TO WS-NAME
     MOVE WS-KNOWN TO WS-O
     PERFORM CHECK-NUM
     STOP RUN.

 CHECK-NUM.
     MOVE SPACES TO TL-CASE
     STRING "acceptance US15 34-1§4 Model layers, ids and the layer registry: " FUNCTION TRIM(WS-NAME) DELIMITED BY SIZE INTO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE WS-E TO TL-EXPECTED-N
     MOVE WS-O TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

 CHECK-TEXT.
     MOVE SPACES TO TL-CASE
     STRING "acceptance US15 34-1§4 Model layers, ids and the layer registry: " FUNCTION TRIM(WS-NAME) DELIMITED BY SIZE INTO TL-CASE
     MOVE "T" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-ENTMODEL-34-1-4.
