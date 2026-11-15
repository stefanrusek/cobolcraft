*> Test of 31-3 section 2, Signs and hanging signs (core/src/be-31-3.cob; T0891): state, SignText and its codec, the slot ids, the facing side, the use with an item and an empty hand, click commands, the edit packet, the editor lock, persistence and the text rendering rules.
*> Each case runs its statements and shows the items joined by single spaces ("n" integers, "f" floats x 1e6, "t" text up to a stored length).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-BE-31-3-2.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY BESTATE.
 COPY PROTO.
 COPY COREAPI.
 COPY CITEMS.
 01 WS-SHOW                PIC -(9)9.
 01 WS-PTR                 BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-IDX                 BINARY-LONG.
 01 WS-LEN                 BINARY-LONG.
 01 WS-OUT                 PIC X(8192).
 01 WS-CAPACITY            BINARY-LONG VALUE 8192.
 01 WS-T10                 BINARY-LONG VALUE 10.
 01 WS-FORM                BINARY-LONG VALUE 1.
 01 WS-D                   BINARY-LONG VALUE 1.
 01 WS-KEY                 PIC X(48).
 01 WS-NM                  PIC X(32).
 01 WS-NML                 BINARY-LONG.
 01 WS-SV                  PIC X(256).
 01 WS-SVL                 BINARY-LONG.
 01 WS-NV                  BINARY-LONG.
 01 WS-LV                  BINARY-DOUBLE.
 01 WS-LT                  BINARY-LONG.
 01 WS-LC                  BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-ITEM                BINARY-LONG.
 01 WS-KP                  BINARY-LONG VALUE 0.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-A                 BINARY-LONG.
 01 WS-B                 BINARY-LONG.
 01 WS-C                 BINARY-LONG.
 01 WS-E                 BINARY-LONG.
 01 WS-F                 BINARY-LONG.
 01 WS-G                 BINARY-LONG.
 01 WS-H                 BINARY-LONG.
 01 WS-FA                FLOAT-LONG.
 01 WS-FB                FLOAT-LONG.
 01 WS-FC                FLOAT-LONG.
 01 WS-FD                FLOAT-LONG.
 01 WS-FE                FLOAT-LONG.
 01 WS-FF                FLOAT-LONG.
 01 WS-U16                PIC X(16) VALUE "0123456789abcdef".
 01 WS-V16                PIC X(16) VALUE "fedcba9876543210".
 01 WS-N24                PIC X(24).
 01 WS-N32                PIC X(32).
 01 WS-TX                 PIC X(384).
 01 WS-LINES.
    05 WS-LINE            OCCURS 4 TIMES.
       10 WS-LINE-LEN     BINARY-LONG.
       10 WS-LINE-TEXT    PIC X(384).
 PROCEDURE DIVISION.
     MOVE "T" TO TL-MODE
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     MOVE "acceptance US12 31-3§2 Signs and hanging signs: state (2.1): a new sign has empty black unglowing text on both sides and is not waxed; the saved form (2.10) writes front_text, back_text and is_waxed, and allow_op_features only" TO TL-CASE
     PERFORM BEGIN-CASE
     MOVE "minecraft:oak_sign" TO WS-KEY
     MOVE 18 TO WS-SVL
     MOVE 7 TO WS-NV
     MOVE 5 TO WS-X
     MOVE 70 TO WS-Y
     MOVE 5 TO WS-Z
     CALL "BE-CREATE" USING WS-D WS-X WS-Y WS-Z WS-NV WS-KEY WS-SVL WS-IDX
     MOVE WS-IDX TO WS-SVL
     MOVE 2 TO WS-FORM
     PERFORM SAVE-RENDER
     MOVE "{front_text:{messages:[,,,],color:black,has_glowing_text:0},back_text:{messages:[,,,],color:black,ha" &
         "s_glowing_text:0},is_waxed:0}" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "acceptance US12 31-3§2 Signs and hanging signs: chunk form (2.10): id, x, y, z and components follow the sign keys; a hanging sign saves the same keys under its own type id" TO TL-CASE
     PERFORM BEGIN-CASE
     MOVE "minecraft:oak_sign" TO WS-KEY
     MOVE 18 TO WS-SVL
     MOVE 7 TO WS-NV
     MOVE 5 TO WS-X
     MOVE 70 TO WS-Y
     MOVE 5 TO WS-Z
     CALL "BE-CREATE" USING WS-D WS-X WS-Y WS-Z WS-NV WS-KEY WS-SVL WS-IDX
     MOVE 1 TO WS-FORM
     PERFORM SAVE-RENDER
     MOVE "{front_text:{messages:[,,,],color:black,has_glowing_text:0},back_text:{messages:[,,,],color:black,ha" &
         "s_glowing_text:0},is_waxed:0,components:{},id:minecraft:sign,x:5,y:70,z:5}" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "acceptance US12 31-3§2 Signs and hanging signs: round trip (2.2, 2.10): messages, a filtered list that differs, colour, glow, waxed and allow_op_features load and save again; filtered_messages is written only when it differs;" TO TL-CASE
     PERFORM BEGIN-CASE
     MOVE "minecraft:oak_sign" TO WS-KEY
     MOVE 18 TO WS-SVL
     MOVE 7 TO WS-NV
     MOVE 5 TO WS-X
     MOVE 70 TO WS-Y
     MOVE 5 TO WS-Z
     CALL "BE-CREATE" USING WS-D WS-X WS-Y WS-Z WS-NV WS-KEY WS-SVL WS-IDX
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     MOVE "allow_op_features" TO WS-NM
     MOVE 17 TO WS-NML
     MOVE 1 TO WS-NV
     PERFORM NB-B
     MOVE "front_text" TO WS-NM
     MOVE 10 TO WS-NML
     PERFORM NB-C
     MOVE "messages" TO WS-NM
     MOVE 8 TO WS-NML
     MOVE 8 TO WS-LT
     MOVE 4 TO WS-LC
     PERFORM NB-L
     MOVE SPACES TO WS-NM
     MOVE -1 TO WS-NML
     MOVE "Hi" TO WS-SV
     MOVE 2 TO WS-SVL
     PERFORM NB-S
     MOVE SPACES TO WS-NM
     MOVE -1 TO WS-NML
     MOVE SPACES TO WS-SV
     MOVE 0 TO WS-SVL
     PERFORM NB-S
     MOVE SPACES TO WS-NM
     MOVE -1 TO WS-NML
     MOVE SPACES TO WS-SV
     MOVE 0 TO WS-SVL
     PERFORM NB-S
     MOVE SPACES TO WS-NM
     MOVE -1 TO WS-NML
     MOVE SPACES TO WS-SV
     MOVE 0 TO WS-SVL
     PERFORM NB-S
     MOVE "filtered_messages" TO WS-NM
     MOVE 17 TO WS-NML
     MOVE 8 TO WS-LT
     MOVE 4 TO WS-LC
     PERFORM NB-L
     MOVE SPACES TO WS-NM
     MOVE -1 TO WS-NML
     MOVE "H" TO WS-SV
     MOVE 1 TO WS-SVL
     PERFORM NB-S
     MOVE SPACES TO WS-NM
     MOVE -1 TO WS-NML
     MOVE SPACES TO WS-SV
     MOVE 0 TO WS-SVL
     PERFORM NB-S
     MOVE SPACES TO WS-NM
     MOVE -1 TO WS-NML
     MOVE SPACES TO WS-SV
     MOVE 0 TO WS-SVL
     PERFORM NB-S
     MOVE SPACES TO WS-NM
     MOVE -1 TO WS-NML
     MOVE SPACES TO WS-SV
     MOVE 0 TO WS-SVL
     PERFORM NB-S
     MOVE "color" TO WS-NM
     MOVE 5 TO WS-NML
     MOVE "red" TO WS-SV
     MOVE 3 TO WS-SVL
     PERFORM NB-S
     MOVE "has_glowing_text" TO WS-NM
     MOVE 16 TO WS-NML
     MOVE 1 TO WS-NV
     PERFORM NB-B
     PERFORM NB-E
     MOVE "back_text" TO WS-NM
     MOVE 9 TO WS-NML
     PERFORM NB-C
     MOVE "messages" TO WS-NM
     MOVE 8 TO WS-NML
     MOVE 8 TO WS-LT
     MOVE 4 TO WS-LC
     PERFORM NB-L
     MOVE SPACES TO WS-NM
     MOVE -1 TO WS-NML
     MOVE "a" TO WS-SV
     MOVE 1 TO WS-SVL
     PERFORM NB-S
     MOVE SPACES TO WS-NM
     MOVE -1 TO WS-NML
     MOVE "b" TO WS-SV
     MOVE 1 TO WS-SVL
     PERFORM NB-S
     MOVE SPACES TO WS-NM
     MOVE -1 TO WS-NML
     MOVE "c" TO WS-SV
     MOVE 1 TO WS-SVL
     PERFORM NB-S
     MOVE SPACES TO WS-NM
     MOVE -1 TO WS-NML
     MOVE "d" TO WS-SV
     MOVE 1 TO WS-SVL
     PERFORM NB-S
     MOVE "color" TO WS-NM
     MOVE 5 TO WS-NML
     MOVE "blue" TO WS-SV
     MOVE 4 TO WS-SVL
     PERFORM NB-S
     PERFORM NB-E
     MOVE "is_waxed" TO WS-NM
     MOVE 8 TO WS-NML
     MOVE 1 TO WS-NV
     PERFORM NB-B
     PERFORM LOAD-BUFFER
     MOVE 2 TO WS-FORM
     PERFORM SAVE-RENDER
     MOVE "{allow_op_features:1,front_text:{messages:[Hi,,,],filtered_messages:[H,,,],color:red,has_glowing_tex" &
         "t:1},back_text:{messages:[a,b,c,d],color:blue,has_glowing_text:0},is_waxed:1}" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "acceptance US12 31-3§2 Signs and hanging signs: decode failures (2.2): a messages list of 3 and a filtered list whose size differs from the messages both give SignText.EMPTY for that side" TO TL-CASE
     PERFORM BEGIN-CASE
     MOVE "minecraft:oak_sign" TO WS-KEY
     MOVE 18 TO WS-SVL
     MOVE 7 TO WS-NV
     MOVE 5 TO WS-X
     MOVE 70 TO WS-Y
     MOVE 5 TO WS-Z
     CALL "BE-CREATE" USING WS-D WS-X WS-Y WS-Z WS-NV WS-KEY WS-SVL WS-IDX
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     MOVE "front_text" TO WS-NM
     MOVE 10 TO WS-NML
     PERFORM NB-C
     MOVE "messages" TO WS-NM
     MOVE 8 TO WS-NML
     MOVE 8 TO WS-LT
     MOVE 3 TO WS-LC
     PERFORM NB-L
     MOVE SPACES TO WS-NM
     MOVE -1 TO WS-NML
     MOVE "a" TO WS-SV
     MOVE 1 TO WS-SVL
     PERFORM NB-S
     MOVE SPACES TO WS-NM
     MOVE -1 TO WS-NML
     MOVE "b" TO WS-SV
     MOVE 1 TO WS-SVL
     PERFORM NB-S
     MOVE SPACES TO WS-NM
     MOVE -1 TO WS-NML
     MOVE "c" TO WS-SV
     MOVE 1 TO WS-SVL
     PERFORM NB-S
     MOVE "color" TO WS-NM
     MOVE 5 TO WS-NML
     MOVE "red" TO WS-SV
     MOVE 3 TO WS-SVL
     PERFORM NB-S
     PERFORM NB-E
     MOVE "back_text" TO WS-NM
     MOVE 9 TO WS-NML
     PERFORM NB-C
     MOVE "messages" TO WS-NM
     MOVE 8 TO WS-NML
     MOVE 8 TO WS-LT
     MOVE 4 TO WS-LC
     PERFORM NB-L
     MOVE SPACES TO WS-NM
     MOVE -1 TO WS-NML
     MOVE "a" TO WS-SV
     MOVE 1 TO WS-SVL
     PERFORM NB-S
     MOVE SPACES TO WS-NM
     MOVE -1 TO WS-NML
     MOVE "b" TO WS-SV
     MOVE 1 TO WS-SVL
     PERFORM NB-S
     MOVE SPACES TO WS-NM
     MOVE -1 TO WS-NML
     MOVE "c" TO WS-SV
     MOVE 1 TO WS-SVL
     PERFORM NB-S
     MOVE SPACES TO WS-NM
     MOVE -1 TO WS-NML
     MOVE "d" TO WS-SV
     MOVE 1 TO WS-SVL
     PERFORM NB-S
     MOVE "filtered_messages" TO WS-NM
     MOVE 17 TO WS-NML
     MOVE 8 TO WS-LT
     MOVE 3 TO WS-LC
     PERFORM NB-L
     MOVE SPACES TO WS-NM
     MOVE -1 TO WS-NML
     MOVE "a" TO WS-SV
     MOVE 1 TO WS-SVL
     PERFORM NB-S
     MOVE SPACES TO WS-NM
     MOVE -1 TO WS-NML
     MOVE "b" TO WS-SV
     MOVE 1 TO WS-SVL
     PERFORM NB-S
     MOVE SPACES TO WS-NM
     MOVE -1 TO WS-NML
     MOVE "c" TO WS-SV
     MOVE 1 TO WS-SVL
     PERFORM NB-S
     PERFORM NB-E
     PERFORM LOAD-BUFFER
     MOVE 2 TO WS-FORM
     PERFORM SAVE-RENDER
     MOVE "{front_text:{messages:[,,,],color:black,has_glowing_text:0},back_text:{messages:[,,,],color:black,ha" &
         "s_glowing_text:0},is_waxed:0}" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "acceptance US12 31-3§2 Signs and hanging signs: colour and filtered defaults (2.2): an absent filtered_messages equals messages (not written back); the colour name is by DyeColor.CODEC" TO TL-CASE
     PERFORM BEGIN-CASE
     MOVE "minecraft:oak_sign" TO WS-KEY
     MOVE 18 TO WS-SVL
     MOVE 7 TO WS-NV
     MOVE 5 TO WS-X
     MOVE 70 TO WS-Y
     MOVE 5 TO WS-Z
     CALL "BE-CREATE" USING WS-D WS-X WS-Y WS-Z WS-NV WS-KEY WS-SVL WS-IDX
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     MOVE "front_text" TO WS-NM
     MOVE 10 TO WS-NML
     PERFORM NB-C
     MOVE "messages" TO WS-NM
     MOVE 8 TO WS-NML
     MOVE 8 TO WS-LT
     MOVE 4 TO WS-LC
     PERFORM NB-L
     MOVE SPACES TO WS-NM
     MOVE -1 TO WS-NML
     MOVE "x" TO WS-SV
     MOVE 1 TO WS-SVL
     PERFORM NB-S
     MOVE SPACES TO WS-NM
     MOVE -1 TO WS-NML
     MOVE SPACES TO WS-SV
     MOVE 0 TO WS-SVL
     PERFORM NB-S
     MOVE SPACES TO WS-NM
     MOVE -1 TO WS-NML
     MOVE SPACES TO WS-SV
     MOVE 0 TO WS-SVL
     PERFORM NB-S
     MOVE SPACES TO WS-NM
     MOVE -1 TO WS-NML
     MOVE SPACES TO WS-SV
     MOVE 0 TO WS-SVL
     PERFORM NB-S
     MOVE "color" TO WS-NM
     MOVE 5 TO WS-NML
     MOVE "lime" TO WS-SV
     MOVE 4 TO WS-SVL
     PERFORM NB-S
     PERFORM NB-E
     PERFORM LOAD-BUFFER
     MOVE 2 TO WS-FORM
     PERFORM SAVE-RENDER
     MOVE "{front_text:{messages:[x,,,],color:lime,has_glowing_text:0},back_text:{messages:[,,,],color:black,ha" &
         "s_glowing_text:0},is_waxed:0}" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "acceptance US12 31-3§2 Signs and hanging signs: decode failure by colour (2.2): a colour that is no dye name fails the SignText (EMPTY), and so does a side without messages" TO TL-CASE
     PERFORM BEGIN-CASE
     MOVE "minecraft:oak_sign" TO WS-KEY
     MOVE 18 TO WS-SVL
     MOVE 7 TO WS-NV
     MOVE 5 TO WS-X
     MOVE 70 TO WS-Y
     MOVE 5 TO WS-Z
     CALL "BE-CREATE" USING WS-D WS-X WS-Y WS-Z WS-NV WS-KEY WS-SVL WS-IDX
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     MOVE "front_text" TO WS-NM
     MOVE 10 TO WS-NML
     PERFORM NB-C
     MOVE "messages" TO WS-NM
     MOVE 8 TO WS-NML
     MOVE 8 TO WS-LT
     MOVE 4 TO WS-LC
     PERFORM NB-L
     MOVE SPACES TO WS-NM
     MOVE -1 TO WS-NML
     MOVE "x" TO WS-SV
     MOVE 1 TO WS-SVL
     PERFORM NB-S
     MOVE SPACES TO WS-NM
     MOVE -1 TO WS-NML
     MOVE SPACES TO WS-SV
     MOVE 0 TO WS-SVL
     PERFORM NB-S
     MOVE SPACES TO WS-NM
     MOVE -1 TO WS-NML
     MOVE SPACES TO WS-SV
     MOVE 0 TO WS-SVL
     PERFORM NB-S
     MOVE SPACES TO WS-NM
     MOVE -1 TO WS-NML
     MOVE SPACES TO WS-SV
     MOVE 0 TO WS-SVL
     PERFORM NB-S
     MOVE "color" TO WS-NM
     MOVE 5 TO WS-NML
     MOVE "nope" TO WS-SV
     MOVE 4 TO WS-SVL
     PERFORM NB-S
     PERFORM NB-E
     MOVE "back_text" TO WS-NM
     MOVE 9 TO WS-NML
     PERFORM NB-C
     MOVE "color" TO WS-NM
     MOVE 5 TO WS-NML
     MOVE "red" TO WS-SV
     MOVE 3 TO WS-SVL
     PERFORM NB-S
     PERFORM NB-E
     PERFORM LOAD-BUFFER
     MOVE 2 TO WS-FORM
     PERFORM SAVE-RENDER
     MOVE "{front_text:{messages:[,,,],color:black,has_glowing_text:0},back_text:{messages:[,,,],color:black,ha" &
         "s_glowing_text:0},is_waxed:0}" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "acceptance US12 31-3§2 Signs and hanging signs: SignTextSlot (2.3): BACK is 0 and FRONT is 1; a VarInt out of range reads as BACK" TO TL-CASE
     PERFORM BEGIN-CASE
     MOVE 0 TO WS-NV
     CALL "BE3-SLOT-DECODE" USING WS-NV WS-A
     MOVE WS-A TO WS-B
     MOVE 1 TO WS-NV
     CALL "BE3-SLOT-DECODE" USING WS-NV WS-A
     MOVE WS-A TO WS-C
     MOVE 2 TO WS-NV
     CALL "BE3-SLOT-DECODE" USING WS-NV WS-A
     MOVE WS-A TO WS-E
     MOVE 7 TO WS-NV
     CALL "BE3-SLOT-DECODE" USING WS-NV WS-A
     MOVE WS-A TO WS-F
     MOVE -1 TO WS-NV
     CALL "BE3-SLOT-DECODE" USING WS-NV WS-A
     MOVE WS-A TO WS-G
     MOVE 100 TO WS-NV
     CALL "BE3-SLOT-DECODE" USING WS-NV WS-A
     MOVE WS-A TO WS-H
     MOVE WS-B TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-C TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-E TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-F TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-G TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-H TO WS-SHOW
     PERFORM ADD-N
     MOVE "0 1 0 0 0 0" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "acceptance US12 31-3§2 Signs and hanging signs: predicates (2.2): hasMessage is true when any line has text; a side of four empty lines has none" TO TL-CASE
     PERFORM BEGIN-CASE
     MOVE "minecraft:oak_sign" TO WS-KEY
     MOVE 18 TO WS-SVL
     MOVE 7 TO WS-NV
     MOVE 5 TO WS-X
     MOVE 70 TO WS-Y
     MOVE 5 TO WS-Z
     CALL "BE-CREATE" USING WS-D WS-X WS-Y WS-Z WS-NV WS-KEY WS-SVL WS-IDX
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     MOVE "front_text" TO WS-NM
     MOVE 10 TO WS-NML
     PERFORM NB-C
     MOVE "messages" TO WS-NM
     MOVE 8 TO WS-NML
     MOVE 8 TO WS-LT
     MOVE 4 TO WS-LC
     PERFORM NB-L
     MOVE SPACES TO WS-NM
     MOVE -1 TO WS-NML
     MOVE SPACES TO WS-SV
     MOVE 0 TO WS-SVL
     PERFORM NB-S
     MOVE SPACES TO WS-NM
     MOVE -1 TO WS-NML
     MOVE SPACES TO WS-SV
     MOVE 0 TO WS-SVL
     PERFORM NB-S
     MOVE SPACES TO WS-NM
     MOVE -1 TO WS-NML
     MOVE "Z" TO WS-SV
     MOVE 1 TO WS-SVL
     PERFORM NB-S
     MOVE SPACES TO WS-NM
     MOVE -1 TO WS-NML
     MOVE SPACES TO WS-SV
     MOVE 0 TO WS-SVL
     PERFORM NB-S
     MOVE "color" TO WS-NM
     MOVE 5 TO WS-NML
     MOVE "black" TO WS-SV
     MOVE 5 TO WS-SVL
     PERFORM NB-S
     PERFORM NB-E
     MOVE "back_text" TO WS-NM
     MOVE 9 TO WS-NML
     PERFORM NB-C
     MOVE "messages" TO WS-NM
     MOVE 8 TO WS-NML
     MOVE 8 TO WS-LT
     MOVE 4 TO WS-LC
     PERFORM NB-L
     MOVE SPACES TO WS-NM
     MOVE -1 TO WS-NML
     MOVE SPACES TO WS-SV
     MOVE 0 TO WS-SVL
     PERFORM NB-S
     MOVE SPACES TO WS-NM
     MOVE -1 TO WS-NML
     MOVE SPACES TO WS-SV
     MOVE 0 TO WS-SVL
     PERFORM NB-S
     MOVE SPACES TO WS-NM
     MOVE -1 TO WS-NML
     MOVE SPACES TO WS-SV
     MOVE 0 TO WS-SVL
     PERFORM NB-S
     MOVE SPACES TO WS-NM
     MOVE -1 TO WS-NML
     MOVE SPACES TO WS-SV
     MOVE 0 TO WS-SVL
     PERFORM NB-S
     PERFORM NB-E
     PERFORM LOAD-BUFFER
     MOVE 1 TO WS-A
     CALL "BE3-SIGN-HAS-MESSAGE" USING WS-IDX WS-A WS-B
     MOVE 0 TO WS-A
     CALL "BE3-SIGN-HAS-MESSAGE" USING WS-IDX WS-A WS-C
     MOVE WS-B TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-C TO WS-SHOW
     PERFORM ADD-N
     MOVE "1 0" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "acceptance US12 31-3§2 Signs and hanging signs: side a player faces (2.4): only for a sign block (else FRONT); angle atan2(dz, dx) in degrees minus 90 against the sign yaw, FRONT when the wrapped difference is at most 90 (the" TO TL-CASE
     PERFORM BEGIN-CASE
     MOVE 1 TO WS-A
     COMPUTE WS-FA = 0.5
     COMPUTE WS-FB = 5.5
     MOVE 0 TO WS-B
     MOVE 0 TO WS-C
     COMPUTE WS-FC = 0.5
     COMPUTE WS-FD = 0.5
     COMPUTE WS-FE = 0.0
     CALL "BE3-SIGN-FACING" USING WS-A WS-FA WS-FB WS-B WS-C WS-FC WS-FD WS-FE WS-E
     MOVE WS-E TO WS-SHOW
     PERFORM ADD-N
     MOVE 1 TO WS-A
     COMPUTE WS-FA = 0.5
     COMPUTE WS-FB = -5.5
     MOVE 0 TO WS-B
     MOVE 0 TO WS-C
     COMPUTE WS-FC = 0.5
     COMPUTE WS-FD = 0.5
     COMPUTE WS-FE = 0.0
     CALL "BE3-SIGN-FACING" USING WS-A WS-FA WS-FB WS-B WS-C WS-FC WS-FD WS-FE WS-E
     MOVE WS-E TO WS-SHOW
     PERFORM ADD-N
     MOVE 1 TO WS-A
     COMPUTE WS-FA = 10.5
     COMPUTE WS-FB = 0.5
     MOVE 0 TO WS-B
     MOVE 0 TO WS-C
     COMPUTE WS-FC = 0.5
     COMPUTE WS-FD = 0.5
     COMPUTE WS-FE = 90.0
     CALL "BE3-SIGN-FACING" USING WS-A WS-FA WS-FB WS-B WS-C WS-FC WS-FD WS-FE WS-E
     MOVE WS-E TO WS-SHOW
     PERFORM ADD-N
     MOVE 1 TO WS-A
     COMPUTE WS-FA = 10.5
     COMPUTE WS-FB = 0.5
     MOVE 0 TO WS-B
     MOVE 0 TO WS-C
     COMPUTE WS-FC = 0.5
     COMPUTE WS-FD = 0.5
     COMPUTE WS-FE = -90.0
     CALL "BE3-SIGN-FACING" USING WS-A WS-FA WS-FB WS-B WS-C WS-FC WS-FD WS-FE WS-E
     MOVE WS-E TO WS-SHOW
     PERFORM ADD-N
     MOVE 1 TO WS-A
     COMPUTE WS-FA = 0.5
     COMPUTE WS-FB = 0.5
     MOVE 0 TO WS-B
     MOVE 0 TO WS-C
     COMPUTE WS-FC = 0.5
     COMPUTE WS-FD = 0.5
     COMPUTE WS-FE = 0.0
     CALL "BE3-SIGN-FACING" USING WS-A WS-FA WS-FB WS-B WS-C WS-FC WS-FD WS-FE WS-E
     MOVE WS-E TO WS-SHOW
     PERFORM ADD-N
     MOVE 1 TO WS-A
     COMPUTE WS-FA = 5.5
     COMPUTE WS-FB = 0.5
     MOVE 0 TO WS-B
     MOVE 0 TO WS-C
     COMPUTE WS-FC = 0.5
     COMPUTE WS-FD = 0.5
     COMPUTE WS-FE = 0.0
     CALL "BE3-SIGN-FACING" USING WS-A WS-FA WS-FB WS-B WS-C WS-FC WS-FD WS-FE WS-E
     MOVE WS-E TO WS-SHOW
     PERFORM ADD-N
     MOVE 1 TO WS-A
     COMPUTE WS-FA = 0.5
     COMPUTE WS-FB = 2.0
     MOVE 3 TO WS-B
     MOVE 4 TO WS-C
     COMPUTE WS-FC = 0.5
     COMPUTE WS-FD = 0.9375
     COMPUTE WS-FE = 180.0
     CALL "BE3-SIGN-FACING" USING WS-A WS-FA WS-FB WS-B WS-C WS-FC WS-FD WS-FE WS-E
     MOVE WS-E TO WS-SHOW
     PERFORM ADD-N
     MOVE 1 TO WS-A
     COMPUTE WS-FA = 0.5
     COMPUTE WS-FB = 9.0
     MOVE 3 TO WS-B
     MOVE 4 TO WS-C
     COMPUTE WS-FC = 0.5
     COMPUTE WS-FD = 0.5
     COMPUTE WS-FE = 90.0
     CALL "BE3-SIGN-FACING" USING WS-A WS-FA WS-FB WS-B WS-C WS-FC WS-FD WS-FE WS-E
     MOVE WS-E TO WS-SHOW
     PERFORM ADD-N
     MOVE 1 TO WS-A
     COMPUTE WS-FA = 0.5
     COMPUTE WS-FB = 9.0
     MOVE 3 TO WS-B
     MOVE 4 TO WS-C
     COMPUTE WS-FC = 0.5
     COMPUTE WS-FD = 0.5
     COMPUTE WS-FE = 0.0
     CALL "BE3-SIGN-FACING" USING WS-A WS-FA WS-FB WS-B WS-C WS-FC WS-FD WS-FE WS-E
     MOVE WS-E TO WS-SHOW
     PERFORM ADD-N
     MOVE 0 TO WS-A
     COMPUTE WS-FA = 0.5
     COMPUTE WS-FB = -5.5
     MOVE 0 TO WS-B
     MOVE 0 TO WS-C
     COMPUTE WS-FC = 0.5
     COMPUTE WS-FD = 0.5
     COMPUTE WS-FE = 0.0
     CALL "BE3-SIGN-FACING" USING WS-A WS-FA WS-FB WS-B WS-C WS-FC WS-FD WS-FE WS-E
     MOVE WS-E TO WS-SHOW
     PERFORM ADD-N
     MOVE "1 0 0 1 1 1 1 1 1 1" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "acceptance US12 31-3§2 Signs and hanging signs: use with an item (2.5): dyes, ink sac, glow ink sac and honeycomb change the faced side only when the action changes it (honeycomb also works on blank text and raises level event" TO TL-CASE
     PERFORM BEGIN-CASE
     MOVE "minecraft:oak_sign" TO WS-KEY
     MOVE 18 TO WS-SVL
     MOVE 7 TO WS-NV
     MOVE 5 TO WS-X
     MOVE 70 TO WS-Y
     MOVE 5 TO WS-Z
     CALL "BE-CREATE" USING WS-D WS-X WS-Y WS-Z WS-NV WS-KEY WS-SVL WS-IDX
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     MOVE "front_text" TO WS-NM
     MOVE 10 TO WS-NML
     PERFORM NB-C
     MOVE "messages" TO WS-NM
     MOVE 8 TO WS-NML
     MOVE 8 TO WS-LT
     MOVE 4 TO WS-LC
     PERFORM NB-L
     MOVE SPACES TO WS-NM
     MOVE -1 TO WS-NML
     MOVE "Hi" TO WS-SV
     MOVE 2 TO WS-SVL
     PERFORM NB-S
     MOVE SPACES TO WS-NM
     MOVE -1 TO WS-NML
     MOVE SPACES TO WS-SV
     MOVE 0 TO WS-SVL
     PERFORM NB-S
     MOVE SPACES TO WS-NM
     MOVE -1 TO WS-NML
     MOVE SPACES TO WS-SV
     MOVE 0 TO WS-SVL
     PERFORM NB-S
     MOVE SPACES TO WS-NM
     MOVE -1 TO WS-NML
     MOVE SPACES TO WS-SV
     MOVE 0 TO WS-SVL
     PERFORM NB-S
     MOVE "color" TO WS-NM
     MOVE 5 TO WS-NML
     MOVE "black" TO WS-SV
     MOVE 5 TO WS-SVL
     PERFORM NB-S
     MOVE "has_glowing_text" TO WS-NM
     MOVE 16 TO WS-NML
     MOVE 0 TO WS-NV
     PERFORM NB-B
     PERFORM NB-E
     MOVE "is_waxed" TO WS-NM
     MOVE 8 TO WS-NML
     MOVE 0 TO WS-NV
     PERFORM NB-B
     PERFORM LOAD-BUFFER
     MOVE 1 TO WS-A
     MOVE 14 TO WS-B
     MOVE 1 TO WS-C
     MOVE 1 TO WS-E
     MOVE 0 TO WS-F
     IF WS-F = 1
     MOVE "0123456789abcdef" TO WS-U16
     ELSE
     MOVE "0123456789abcdef" TO WS-U16
     END-IF
     CALL "BE3-SIGN-USE-ITEM" USING WS-IDX WS-A WS-B WS-C WS-E WS-U16 WS-G WS-H
     MOVE WS-G TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-H TO WS-SHOW
     PERFORM ADD-N
     MOVE BE-XI(WS-IDX, 1) TO WS-SHOW
     PERFORM ADD-N
     MOVE BE-XI(WS-IDX, 5) TO WS-SHOW
     PERFORM ADD-N
     MOVE BE-XI(WS-IDX, 4) TO WS-SHOW
     PERFORM ADD-N
     MOVE "minecraft:oak_sign" TO WS-KEY
     MOVE 18 TO WS-SVL
     MOVE 7 TO WS-NV
     MOVE 5 TO WS-X
     MOVE 70 TO WS-Y
     MOVE 5 TO WS-Z
     CALL "BE-CREATE" USING WS-D WS-X WS-Y WS-Z WS-NV WS-KEY WS-SVL WS-IDX
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     MOVE "front_text" TO WS-NM
     MOVE 10 TO WS-NML
     PERFORM NB-C
     MOVE "messages" TO WS-NM
     MOVE 8 TO WS-NML
     MOVE 8 TO WS-LT
     MOVE 4 TO WS-LC
     PERFORM NB-L
     MOVE SPACES TO WS-NM
     MOVE -1 TO WS-NML
     MOVE "Hi" TO WS-SV
     MOVE 2 TO WS-SVL
     PERFORM NB-S
     MOVE SPACES TO WS-NM
     MOVE -1 TO WS-NML
     MOVE SPACES TO WS-SV
     MOVE 0 TO WS-SVL
     PERFORM NB-S
     MOVE SPACES TO WS-NM
     MOVE -1 TO WS-NML
     MOVE SPACES TO WS-SV
     MOVE 0 TO WS-SVL
     PERFORM NB-S
     MOVE SPACES TO WS-NM
     MOVE -1 TO WS-NML
     MOVE SPACES TO WS-SV
     MOVE 0 TO WS-SVL
     PERFORM NB-S
     MOVE "color" TO WS-NM
     MOVE 5 TO WS-NML
     MOVE "red" TO WS-SV
     MOVE 3 TO WS-SVL
     PERFORM NB-S
     MOVE "has_glowing_text" TO WS-NM
     MOVE 16 TO WS-NML
     MOVE 0 TO WS-NV
     PERFORM NB-B
     PERFORM NB-E
     MOVE "is_waxed" TO WS-NM
     MOVE 8 TO WS-NML
     MOVE 0 TO WS-NV
     PERFORM NB-B
     PERFORM LOAD-BUFFER
     MOVE 1 TO WS-A
     MOVE 14 TO WS-B
     MOVE 1 TO WS-C
     MOVE 1 TO WS-E
     MOVE 0 TO WS-F
     IF WS-F = 1
     MOVE "0123456789abcdef" TO WS-U16
     ELSE
     MOVE "0123456789abcdef" TO WS-U16
     END-IF
     CALL "BE3-SIGN-USE-ITEM" USING WS-IDX WS-A WS-B WS-C WS-E WS-U16 WS-G WS-H
     MOVE WS-G TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-H TO WS-SHOW
     PERFORM ADD-N
     MOVE BE-XI(WS-IDX, 1) TO WS-SHOW
     PERFORM ADD-N
     MOVE BE-XI(WS-IDX, 5) TO WS-SHOW
     PERFORM ADD-N
     MOVE BE-XI(WS-IDX, 4) TO WS-SHOW
     PERFORM ADD-N
     MOVE "minecraft:oak_sign" TO WS-KEY
     MOVE 18 TO WS-SVL
     MOVE 7 TO WS-NV
     MOVE 5 TO WS-X
     MOVE 70 TO WS-Y
     MOVE 5 TO WS-Z
     CALL "BE-CREATE" USING WS-D WS-X WS-Y WS-Z WS-NV WS-KEY WS-SVL WS-IDX
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     MOVE "front_text" TO WS-NM
     MOVE 10 TO WS-NML
     PERFORM NB-C
     MOVE "messages" TO WS-NM
     MOVE 8 TO WS-NML
     MOVE 8 TO WS-LT
     MOVE 4 TO WS-LC
     PERFORM NB-L
     MOVE SPACES TO WS-NM
     MOVE -1 TO WS-NML
     MOVE "Hi" TO WS-SV
     MOVE 2 TO WS-SVL
     PERFORM NB-S
     MOVE SPACES TO WS-NM
     MOVE -1 TO WS-NML
     MOVE SPACES TO WS-SV
     MOVE 0 TO WS-SVL
     PERFORM NB-S
     MOVE SPACES TO WS-NM
     MOVE -1 TO WS-NML
     MOVE SPACES TO WS-SV
     MOVE 0 TO WS-SVL
     PERFORM NB-S
     MOVE SPACES TO WS-NM
     MOVE -1 TO WS-NML
     MOVE SPACES TO WS-SV
     MOVE 0 TO WS-SVL
     PERFORM NB-S
     MOVE "color" TO WS-NM
     MOVE 5 TO WS-NML
     MOVE "black" TO WS-SV
     MOVE 5 TO WS-SVL
     PERFORM NB-S
     MOVE "has_glowing_text" TO WS-NM
     MOVE 16 TO WS-NML
     MOVE 0 TO WS-NV
     PERFORM NB-B
     PERFORM NB-E
     MOVE "is_waxed" TO WS-NM
     MOVE 8 TO WS-NML
     MOVE 0 TO WS-NV
     PERFORM NB-B
     PERFORM LOAD-BUFFER
     MOVE 1 TO WS-A
     MOVE -1 TO WS-B
     MOVE 1 TO WS-C
     MOVE 1 TO WS-E
     MOVE 0 TO WS-F
     IF WS-F = 1
     MOVE "0123456789abcdef" TO WS-U16
     ELSE
     MOVE "0123456789abcdef" TO WS-U16
     END-IF
     CALL "BE3-SIGN-USE-ITEM" USING WS-IDX WS-A WS-B WS-C WS-E WS-U16 WS-G WS-H
     MOVE WS-G TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-H TO WS-SHOW
     PERFORM ADD-N
     MOVE BE-XI(WS-IDX, 1) TO WS-SHOW
     PERFORM ADD-N
     MOVE BE-XI(WS-IDX, 5) TO WS-SHOW
     PERFORM ADD-N
     MOVE BE-XI(WS-IDX, 4) TO WS-SHOW
     PERFORM ADD-N
     MOVE "minecraft:oak_sign" TO WS-KEY
     MOVE 18 TO WS-SVL
     MOVE 7 TO WS-NV
     MOVE 5 TO WS-X
     MOVE 70 TO WS-Y
     MOVE 5 TO WS-Z
     CALL "BE-CREATE" USING WS-D WS-X WS-Y WS-Z WS-NV WS-KEY WS-SVL WS-IDX
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     MOVE "front_text" TO WS-NM
     MOVE 10 TO WS-NML
     PERFORM NB-C
     MOVE "messages" TO WS-NM
     MOVE 8 TO WS-NML
     MOVE 8 TO WS-LT
     MOVE 4 TO WS-LC
     PERFORM NB-L
     MOVE SPACES TO WS-NM
     MOVE -1 TO WS-NML
     MOVE SPACES TO WS-SV
     MOVE 0 TO WS-SVL
     PERFORM NB-S
     MOVE SPACES TO WS-NM
     MOVE -1 TO WS-NML
     MOVE SPACES TO WS-SV
     MOVE 0 TO WS-SVL
     PERFORM NB-S
     MOVE SPACES TO WS-NM
     MOVE -1 TO WS-NML
     MOVE SPACES TO WS-SV
     MOVE 0 TO WS-SVL
     PERFORM NB-S
     MOVE SPACES TO WS-NM
     MOVE -1 TO WS-NML
     MOVE SPACES TO WS-SV
     MOVE 0 TO WS-SVL
     PERFORM NB-S
     MOVE "color" TO WS-NM
     MOVE 5 TO WS-NML
     MOVE "black" TO WS-SV
     MOVE 5 TO WS-SVL
     PERFORM NB-S
     MOVE "has_glowing_text" TO WS-NM
     MOVE 16 TO WS-NML
     MOVE 0 TO WS-NV
     PERFORM NB-B
     PERFORM NB-E
     MOVE "is_waxed" TO WS-NM
     MOVE 8 TO WS-NML
     MOVE 0 TO WS-NV
     PERFORM NB-B
     PERFORM LOAD-BUFFER
     MOVE 1 TO WS-A
     MOVE 14 TO WS-B
     MOVE 1 TO WS-C
     MOVE 1 TO WS-E
     MOVE 0 TO WS-F
     IF WS-F = 1
     MOVE "0123456789abcdef" TO WS-U16
     ELSE
     MOVE "0123456789abcdef" TO WS-U16
     END-IF
     CALL "BE3-SIGN-USE-ITEM" USING WS-IDX WS-A WS-B WS-C WS-E WS-U16 WS-G WS-H
     MOVE WS-G TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-H TO WS-SHOW
     PERFORM ADD-N
     MOVE BE-XI(WS-IDX, 1) TO WS-SHOW
     PERFORM ADD-N
     MOVE BE-XI(WS-IDX, 5) TO WS-SHOW
     PERFORM ADD-N
     MOVE BE-XI(WS-IDX, 4) TO WS-SHOW
     PERFORM ADD-N
     MOVE "minecraft:oak_sign" TO WS-KEY
     MOVE 18 TO WS-SVL
     MOVE 7 TO WS-NV
     MOVE 5 TO WS-X
     MOVE 70 TO WS-Y
     MOVE 5 TO WS-Z
     CALL "BE-CREATE" USING WS-D WS-X WS-Y WS-Z WS-NV WS-KEY WS-SVL WS-IDX
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     MOVE "front_text" TO WS-NM
     MOVE 10 TO WS-NML
     PERFORM NB-C
     MOVE "messages" TO WS-NM
     MOVE 8 TO WS-NML
     MOVE 8 TO WS-LT
     MOVE 4 TO WS-LC
     PERFORM NB-L
     MOVE SPACES TO WS-NM
     MOVE -1 TO WS-NML
     MOVE "Hi" TO WS-SV
     MOVE 2 TO WS-SVL
     PERFORM NB-S
     MOVE SPACES TO WS-NM
     MOVE -1 TO WS-NML
     MOVE SPACES TO WS-SV
     MOVE 0 TO WS-SVL
     PERFORM NB-S
     MOVE SPACES TO WS-NM
     MOVE -1 TO WS-NML
     MOVE SPACES TO WS-SV
     MOVE 0 TO WS-SVL
     PERFORM NB-S
     MOVE SPACES TO WS-NM
     MOVE -1 TO WS-NML
     MOVE SPACES TO WS-SV
     MOVE 0 TO WS-SVL
     PERFORM NB-S
     MOVE "color" TO WS-NM
     MOVE 5 TO WS-NML
     MOVE "black" TO WS-SV
     MOVE 5 TO WS-SVL
     PERFORM NB-S
     MOVE "has_glowing_text" TO WS-NM
     MOVE 16 TO WS-NML
     MOVE 0 TO WS-NV
     PERFORM NB-B
     PERFORM NB-E
     MOVE "is_waxed" TO WS-NM
     MOVE 8 TO WS-NML
     MOVE 0 TO WS-NV
     PERFORM NB-B
     PERFORM LOAD-BUFFER
     MOVE 1 TO WS-A
     MOVE 14 TO WS-B
     MOVE 1 TO WS-C
     MOVE 0 TO WS-E
     MOVE 0 TO WS-F
     IF WS-F = 1
     MOVE "0123456789abcdef" TO WS-U16
     ELSE
     MOVE "0123456789abcdef" TO WS-U16
     END-IF
     CALL "BE3-SIGN-USE-ITEM" USING WS-IDX WS-A WS-B WS-C WS-E WS-U16 WS-G WS-H
     MOVE WS-G TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-H TO WS-SHOW
     PERFORM ADD-N
     MOVE BE-XI(WS-IDX, 1) TO WS-SHOW
     PERFORM ADD-N
     MOVE BE-XI(WS-IDX, 5) TO WS-SHOW
     PERFORM ADD-N
     MOVE BE-XI(WS-IDX, 4) TO WS-SHOW
     PERFORM ADD-N
     MOVE "minecraft:oak_sign" TO WS-KEY
     MOVE 18 TO WS-SVL
     MOVE 7 TO WS-NV
     MOVE 5 TO WS-X
     MOVE 70 TO WS-Y
     MOVE 5 TO WS-Z
     CALL "BE-CREATE" USING WS-D WS-X WS-Y WS-Z WS-NV WS-KEY WS-SVL WS-IDX
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     MOVE "front_text" TO WS-NM
     MOVE 10 TO WS-NML
     PERFORM NB-C
     MOVE "messages" TO WS-NM
     MOVE 8 TO WS-NML
     MOVE 8 TO WS-LT
     MOVE 4 TO WS-LC
     PERFORM NB-L
     MOVE SPACES TO WS-NM
     MOVE -1 TO WS-NML
     MOVE "Hi" TO WS-SV
     MOVE 2 TO WS-SVL
     PERFORM NB-S
     MOVE SPACES TO WS-NM
     MOVE -1 TO WS-NML
     MOVE SPACES TO WS-SV
     MOVE 0 TO WS-SVL
     PERFORM NB-S
     MOVE SPACES TO WS-NM
     MOVE -1 TO WS-NML
     MOVE SPACES TO WS-SV
     MOVE 0 TO WS-SVL
     PERFORM NB-S
     MOVE SPACES TO WS-NM
     MOVE -1 TO WS-NML
     MOVE SPACES TO WS-SV
     MOVE 0 TO WS-SVL
     PERFORM NB-S
     MOVE "color" TO WS-NM
     MOVE 5 TO WS-NML
     MOVE "black" TO WS-SV
     MOVE 5 TO WS-SVL
     PERFORM NB-S
     MOVE "has_glowing_text" TO WS-NM
     MOVE 16 TO WS-NML
     MOVE 0 TO WS-NV
     PERFORM NB-B
     PERFORM NB-E
     MOVE "is_waxed" TO WS-NM
     MOVE 8 TO WS-NML
     MOVE 1 TO WS-NV
     PERFORM NB-B
     PERFORM LOAD-BUFFER
     MOVE 1 TO WS-A
     MOVE 14 TO WS-B
     MOVE 1 TO WS-C
     MOVE 1 TO WS-E
     MOVE 0 TO WS-F
     IF WS-F = 1
     MOVE "0123456789abcdef" TO WS-U16
     ELSE
     MOVE "0123456789abcdef" TO WS-U16
     END-IF
     CALL "BE3-SIGN-USE-ITEM" USING WS-IDX WS-A WS-B WS-C WS-E WS-U16 WS-G WS-H
     MOVE WS-G TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-H TO WS-SHOW
     PERFORM ADD-N
     MOVE BE-XI(WS-IDX, 1) TO WS-SHOW
     PERFORM ADD-N
     MOVE BE-XI(WS-IDX, 5) TO WS-SHOW
     PERFORM ADD-N
     MOVE BE-XI(WS-IDX, 4) TO WS-SHOW
     PERFORM ADD-N
     MOVE "minecraft:oak_sign" TO WS-KEY
     MOVE 18 TO WS-SVL
     MOVE 7 TO WS-NV
     MOVE 5 TO WS-X
     MOVE 70 TO WS-Y
     MOVE 5 TO WS-Z
     CALL "BE-CREATE" USING WS-D WS-X WS-Y WS-Z WS-NV WS-KEY WS-SVL WS-IDX
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     MOVE "front_text" TO WS-NM
     MOVE 10 TO WS-NML
     PERFORM NB-C
     MOVE "messages" TO WS-NM
     MOVE 8 TO WS-NML
     MOVE 8 TO WS-LT
     MOVE 4 TO WS-LC
     PERFORM NB-L
     MOVE SPACES TO WS-NM
     MOVE -1 TO WS-NML
     MOVE "Hi" TO WS-SV
     MOVE 2 TO WS-SVL
     PERFORM NB-S
     MOVE SPACES TO WS-NM
     MOVE -1 TO WS-NML
     MOVE SPACES TO WS-SV
     MOVE 0 TO WS-SVL
     PERFORM NB-S
     MOVE SPACES TO WS-NM
     MOVE -1 TO WS-NML
     MOVE SPACES TO WS-SV
     MOVE 0 TO WS-SVL
     PERFORM NB-S
     MOVE SPACES TO WS-NM
     MOVE -1 TO WS-NML
     MOVE SPACES TO WS-SV
     MOVE 0 TO WS-SVL
     PERFORM NB-S
     MOVE "color" TO WS-NM
     MOVE 5 TO WS-NML
     MOVE "black" TO WS-SV
     MOVE 5 TO WS-SVL
     PERFORM NB-S
     MOVE "has_glowing_text" TO WS-NM
     MOVE 16 TO WS-NML
     MOVE 0 TO WS-NV
     PERFORM NB-B
     PERFORM NB-E
     MOVE "is_waxed" TO WS-NM
     MOVE 8 TO WS-NML
     MOVE 0 TO WS-NV
     PERFORM NB-B
     PERFORM LOAD-BUFFER
     MOVE 1 TO WS-A
     MOVE 14 TO WS-B
     MOVE 1 TO WS-C
     MOVE 1 TO WS-E
     MOVE 1 TO WS-F
     IF WS-F = 1
     MOVE "fedcba9876543210" TO WS-U16
     ELSE
     MOVE "0123456789abcdef" TO WS-U16
     END-IF
     MOVE 1 TO BE-XI(WS-IDX, 3)
     MOVE "0123456789abcdef" TO BE-XT(WS-IDX, 17)
     CALL "BE3-SIGN-USE-ITEM" USING WS-IDX WS-A WS-B WS-C WS-E WS-U16 WS-G WS-H
     MOVE WS-G TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-H TO WS-SHOW
     PERFORM ADD-N
     MOVE BE-XI(WS-IDX, 1) TO WS-SHOW
     PERFORM ADD-N
     MOVE BE-XI(WS-IDX, 5) TO WS-SHOW
     PERFORM ADD-N
     MOVE BE-XI(WS-IDX, 4) TO WS-SHOW
     PERFORM ADD-N
     MOVE "minecraft:oak_sign" TO WS-KEY
     MOVE 18 TO WS-SVL
     MOVE 7 TO WS-NV
     MOVE 5 TO WS-X
     MOVE 70 TO WS-Y
     MOVE 5 TO WS-Z
     CALL "BE-CREATE" USING WS-D WS-X WS-Y WS-Z WS-NV WS-KEY WS-SVL WS-IDX
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     MOVE "front_text" TO WS-NM
     MOVE 10 TO WS-NML
     PERFORM NB-C
     MOVE "messages" TO WS-NM
     MOVE 8 TO WS-NML
     MOVE 8 TO WS-LT
     MOVE 4 TO WS-LC
     PERFORM NB-L
     MOVE SPACES TO WS-NM
     MOVE -1 TO WS-NML
     MOVE "Hi" TO WS-SV
     MOVE 2 TO WS-SVL
     PERFORM NB-S
     MOVE SPACES TO WS-NM
     MOVE -1 TO WS-NML
     MOVE SPACES TO WS-SV
     MOVE 0 TO WS-SVL
     PERFORM NB-S
     MOVE SPACES TO WS-NM
     MOVE -1 TO WS-NML
     MOVE SPACES TO WS-SV
     MOVE 0 TO WS-SVL
     PERFORM NB-S
     MOVE SPACES TO WS-NM
     MOVE -1 TO WS-NML
     MOVE SPACES TO WS-SV
     MOVE 0 TO WS-SVL
     PERFORM NB-S
     MOVE "color" TO WS-NM
     MOVE 5 TO WS-NML
     MOVE "black" TO WS-SV
     MOVE 5 TO WS-SVL
     PERFORM NB-S
     MOVE "has_glowing_text" TO WS-NM
     MOVE 16 TO WS-NML
     MOVE 1 TO WS-NV
     PERFORM NB-B
     PERFORM NB-E
     MOVE "is_waxed" TO WS-NM
     MOVE 8 TO WS-NML
     MOVE 0 TO WS-NV
     PERFORM NB-B
     PERFORM LOAD-BUFFER
     MOVE 2 TO WS-A
     MOVE 0 TO WS-B
     MOVE 1 TO WS-C
     MOVE 1 TO WS-E
     MOVE 0 TO WS-F
     IF WS-F = 1
     MOVE "0123456789abcdef" TO WS-U16
     ELSE
     MOVE "0123456789abcdef" TO WS-U16
     END-IF
     CALL "BE3-SIGN-USE-ITEM" USING WS-IDX WS-A WS-B WS-C WS-E WS-U16 WS-G WS-H
     MOVE WS-G TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-H TO WS-SHOW
     PERFORM ADD-N
     MOVE BE-XI(WS-IDX, 1) TO WS-SHOW
     PERFORM ADD-N
     MOVE BE-XI(WS-IDX, 5) TO WS-SHOW
     PERFORM ADD-N
     MOVE BE-XI(WS-IDX, 4) TO WS-SHOW
     PERFORM ADD-N
     MOVE "minecraft:oak_sign" TO WS-KEY
     MOVE 18 TO WS-SVL
     MOVE 7 TO WS-NV
     MOVE 5 TO WS-X
     MOVE 70 TO WS-Y
     MOVE 5 TO WS-Z
     CALL "BE-CREATE" USING WS-D WS-X WS-Y WS-Z WS-NV WS-KEY WS-SVL WS-IDX
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     MOVE "front_text" TO WS-NM
     MOVE 10 TO WS-NML
     PERFORM NB-C
     MOVE "messages" TO WS-NM
     MOVE 8 TO WS-NML
     MOVE 8 TO WS-LT
     MOVE 4 TO WS-LC
     PERFORM NB-L
     MOVE SPACES TO WS-NM
     MOVE -1 TO WS-NML
     MOVE "Hi" TO WS-SV
     MOVE 2 TO WS-SVL
     PERFORM NB-S
     MOVE SPACES TO WS-NM
     MOVE -1 TO WS-NML
     MOVE SPACES TO WS-SV
     MOVE 0 TO WS-SVL
     PERFORM NB-S
     MOVE SPACES TO WS-NM
     MOVE -1 TO WS-NML
     MOVE SPACES TO WS-SV
     MOVE 0 TO WS-SVL
     PERFORM NB-S
     MOVE SPACES TO WS-NM
     MOVE -1 TO WS-NML
     MOVE SPACES TO WS-SV
     MOVE 0 TO WS-SVL
     PERFORM NB-S
     MOVE "color" TO WS-NM
     MOVE 5 TO WS-NML
     MOVE "black" TO WS-SV
     MOVE 5 TO WS-SVL
     PERFORM NB-S
     MOVE "has_glowing_text" TO WS-NM
     MOVE 16 TO WS-NML
     MOVE 0 TO WS-NV
     PERFORM NB-B
     PERFORM NB-E
     MOVE "is_waxed" TO WS-NM
     MOVE 8 TO WS-NML
     MOVE 0 TO WS-NV
     PERFORM NB-B
     PERFORM LOAD-BUFFER
     MOVE 2 TO WS-A
     MOVE 0 TO WS-B
     MOVE 1 TO WS-C
     MOVE 1 TO WS-E
     MOVE 0 TO WS-F
     IF WS-F = 1
     MOVE "0123456789abcdef" TO WS-U16
     ELSE
     MOVE "0123456789abcdef" TO WS-U16
     END-IF
     CALL "BE3-SIGN-USE-ITEM" USING WS-IDX WS-A WS-B WS-C WS-E WS-U16 WS-G WS-H
     MOVE WS-G TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-H TO WS-SHOW
     PERFORM ADD-N
     MOVE BE-XI(WS-IDX, 1) TO WS-SHOW
     PERFORM ADD-N
     MOVE BE-XI(WS-IDX, 5) TO WS-SHOW
     PERFORM ADD-N
     MOVE BE-XI(WS-IDX, 4) TO WS-SHOW
     PERFORM ADD-N
     MOVE "minecraft:oak_sign" TO WS-KEY
     MOVE 18 TO WS-SVL
     MOVE 7 TO WS-NV
     MOVE 5 TO WS-X
     MOVE 70 TO WS-Y
     MOVE 5 TO WS-Z
     CALL "BE-CREATE" USING WS-D WS-X WS-Y WS-Z WS-NV WS-KEY WS-SVL WS-IDX
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     MOVE "front_text" TO WS-NM
     MOVE 10 TO WS-NML
     PERFORM NB-C
     MOVE "messages" TO WS-NM
     MOVE 8 TO WS-NML
     MOVE 8 TO WS-LT
     MOVE 4 TO WS-LC
     PERFORM NB-L
     MOVE SPACES TO WS-NM
     MOVE -1 TO WS-NML
     MOVE "Hi" TO WS-SV
     MOVE 2 TO WS-SVL
     PERFORM NB-S
     MOVE SPACES TO WS-NM
     MOVE -1 TO WS-NML
     MOVE SPACES TO WS-SV
     MOVE 0 TO WS-SVL
     PERFORM NB-S
     MOVE SPACES TO WS-NM
     MOVE -1 TO WS-NML
     MOVE SPACES TO WS-SV
     MOVE 0 TO WS-SVL
     PERFORM NB-S
     MOVE SPACES TO WS-NM
     MOVE -1 TO WS-NML
     MOVE SPACES TO WS-SV
     MOVE 0 TO WS-SVL
     PERFORM NB-S
     MOVE "color" TO WS-NM
     MOVE 5 TO WS-NML
     MOVE "black" TO WS-SV
     MOVE 5 TO WS-SVL
     PERFORM NB-S
     MOVE "has_glowing_text" TO WS-NM
     MOVE 16 TO WS-NML
     MOVE 0 TO WS-NV
     PERFORM NB-B
     PERFORM NB-E
     MOVE "is_waxed" TO WS-NM
     MOVE 8 TO WS-NML
     MOVE 0 TO WS-NV
     PERFORM NB-B
     PERFORM LOAD-BUFFER
     MOVE 3 TO WS-A
     MOVE 0 TO WS-B
     MOVE 1 TO WS-C
     MOVE 1 TO WS-E
     MOVE 0 TO WS-F
     IF WS-F = 1
     MOVE "0123456789abcdef" TO WS-U16
     ELSE
     MOVE "0123456789abcdef" TO WS-U16
     END-IF
     CALL "BE3-SIGN-USE-ITEM" USING WS-IDX WS-A WS-B WS-C WS-E WS-U16 WS-G WS-H
     MOVE WS-G TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-H TO WS-SHOW
     PERFORM ADD-N
     MOVE BE-XI(WS-IDX, 1) TO WS-SHOW
     PERFORM ADD-N
     MOVE BE-XI(WS-IDX, 5) TO WS-SHOW
     PERFORM ADD-N
     MOVE BE-XI(WS-IDX, 4) TO WS-SHOW
     PERFORM ADD-N
     MOVE "minecraft:oak_sign" TO WS-KEY
     MOVE 18 TO WS-SVL
     MOVE 7 TO WS-NV
     MOVE 5 TO WS-X
     MOVE 70 TO WS-Y
     MOVE 5 TO WS-Z
     CALL "BE-CREATE" USING WS-D WS-X WS-Y WS-Z WS-NV WS-KEY WS-SVL WS-IDX
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     MOVE "front_text" TO WS-NM
     MOVE 10 TO WS-NML
     PERFORM NB-C
     MOVE "messages" TO WS-NM
     MOVE 8 TO WS-NML
     MOVE 8 TO WS-LT
     MOVE 4 TO WS-LC
     PERFORM NB-L
     MOVE SPACES TO WS-NM
     MOVE -1 TO WS-NML
     MOVE "Hi" TO WS-SV
     MOVE 2 TO WS-SVL
     PERFORM NB-S
     MOVE SPACES TO WS-NM
     MOVE -1 TO WS-NML
     MOVE SPACES TO WS-SV
     MOVE 0 TO WS-SVL
     PERFORM NB-S
     MOVE SPACES TO WS-NM
     MOVE -1 TO WS-NML
     MOVE SPACES TO WS-SV
     MOVE 0 TO WS-SVL
     PERFORM NB-S
     MOVE SPACES TO WS-NM
     MOVE -1 TO WS-NML
     MOVE SPACES TO WS-SV
     MOVE 0 TO WS-SVL
     PERFORM NB-S
     MOVE "color" TO WS-NM
     MOVE 5 TO WS-NML
     MOVE "black" TO WS-SV
     MOVE 5 TO WS-SVL
     PERFORM NB-S
     MOVE "has_glowing_text" TO WS-NM
     MOVE 16 TO WS-NML
     MOVE 1 TO WS-NV
     PERFORM NB-B
     PERFORM NB-E
     MOVE "is_waxed" TO WS-NM
     MOVE 8 TO WS-NML
     MOVE 0 TO WS-NV
     PERFORM NB-B
     PERFORM LOAD-BUFFER
     MOVE 3 TO WS-A
     MOVE 0 TO WS-B
     MOVE 1 TO WS-C
     MOVE 1 TO WS-E
     MOVE 0 TO WS-F
     IF WS-F = 1
     MOVE "0123456789abcdef" TO WS-U16
     ELSE
     MOVE "0123456789abcdef" TO WS-U16
     END-IF
     CALL "BE3-SIGN-USE-ITEM" USING WS-IDX WS-A WS-B WS-C WS-E WS-U16 WS-G WS-H
     MOVE WS-G TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-H TO WS-SHOW
     PERFORM ADD-N
     MOVE BE-XI(WS-IDX, 1) TO WS-SHOW
     PERFORM ADD-N
     MOVE BE-XI(WS-IDX, 5) TO WS-SHOW
     PERFORM ADD-N
     MOVE BE-XI(WS-IDX, 4) TO WS-SHOW
     PERFORM ADD-N
     MOVE "minecraft:oak_sign" TO WS-KEY
     MOVE 18 TO WS-SVL
     MOVE 7 TO WS-NV
     MOVE 5 TO WS-X
     MOVE 70 TO WS-Y
     MOVE 5 TO WS-Z
     CALL "BE-CREATE" USING WS-D WS-X WS-Y WS-Z WS-NV WS-KEY WS-SVL WS-IDX
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     MOVE "front_text" TO WS-NM
     MOVE 10 TO WS-NML
     PERFORM NB-C
     MOVE "messages" TO WS-NM
     MOVE 8 TO WS-NML
     MOVE 8 TO WS-LT
     MOVE 4 TO WS-LC
     PERFORM NB-L
     MOVE SPACES TO WS-NM
     MOVE -1 TO WS-NML
     MOVE SPACES TO WS-SV
     MOVE 0 TO WS-SVL
     PERFORM NB-S
     MOVE SPACES TO WS-NM
     MOVE -1 TO WS-NML
     MOVE SPACES TO WS-SV
     MOVE 0 TO WS-SVL
     PERFORM NB-S
     MOVE SPACES TO WS-NM
     MOVE -1 TO WS-NML
     MOVE SPACES TO WS-SV
     MOVE 0 TO WS-SVL
     PERFORM NB-S
     MOVE SPACES TO WS-NM
     MOVE -1 TO WS-NML
     MOVE SPACES TO WS-SV
     MOVE 0 TO WS-SVL
     PERFORM NB-S
     MOVE "color" TO WS-NM
     MOVE 5 TO WS-NML
     MOVE "black" TO WS-SV
     MOVE 5 TO WS-SVL
     PERFORM NB-S
     MOVE "has_glowing_text" TO WS-NM
     MOVE 16 TO WS-NML
     MOVE 0 TO WS-NV
     PERFORM NB-B
     PERFORM NB-E
     MOVE "is_waxed" TO WS-NM
     MOVE 8 TO WS-NML
     MOVE 0 TO WS-NV
     PERFORM NB-B
     PERFORM LOAD-BUFFER
     MOVE 4 TO WS-A
     MOVE 0 TO WS-B
     MOVE 1 TO WS-C
     MOVE 1 TO WS-E
     MOVE 0 TO WS-F
     IF WS-F = 1
     MOVE "0123456789abcdef" TO WS-U16
     ELSE
     MOVE "0123456789abcdef" TO WS-U16
     END-IF
     CALL "BE3-SIGN-USE-ITEM" USING WS-IDX WS-A WS-B WS-C WS-E WS-U16 WS-G WS-H
     MOVE WS-G TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-H TO WS-SHOW
     PERFORM ADD-N
     MOVE BE-XI(WS-IDX, 1) TO WS-SHOW
     PERFORM ADD-N
     MOVE BE-XI(WS-IDX, 5) TO WS-SHOW
     PERFORM ADD-N
     MOVE BE-XI(WS-IDX, 4) TO WS-SHOW
     PERFORM ADD-N
     MOVE "minecraft:oak_sign" TO WS-KEY
     MOVE 18 TO WS-SVL
     MOVE 7 TO WS-NV
     MOVE 5 TO WS-X
     MOVE 70 TO WS-Y
     MOVE 5 TO WS-Z
     CALL "BE-CREATE" USING WS-D WS-X WS-Y WS-Z WS-NV WS-KEY WS-SVL WS-IDX
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     MOVE "front_text" TO WS-NM
     MOVE 10 TO WS-NML
     PERFORM NB-C
     MOVE "messages" TO WS-NM
     MOVE 8 TO WS-NML
     MOVE 8 TO WS-LT
     MOVE 4 TO WS-LC
     PERFORM NB-L
     MOVE SPACES TO WS-NM
     MOVE -1 TO WS-NML
     MOVE "Hi" TO WS-SV
     MOVE 2 TO WS-SVL
     PERFORM NB-S
     MOVE SPACES TO WS-NM
     MOVE -1 TO WS-NML
     MOVE SPACES TO WS-SV
     MOVE 0 TO WS-SVL
     PERFORM NB-S
     MOVE SPACES TO WS-NM
     MOVE -1 TO WS-NML
     MOVE SPACES TO WS-SV
     MOVE 0 TO WS-SVL
     PERFORM NB-S
     MOVE SPACES TO WS-NM
     MOVE -1 TO WS-NML
     MOVE SPACES TO WS-SV
     MOVE 0 TO WS-SVL
     PERFORM NB-S
     MOVE "color" TO WS-NM
     MOVE 5 TO WS-NML
     MOVE "black" TO WS-SV
     MOVE 5 TO WS-SVL
     PERFORM NB-S
     MOVE "has_glowing_text" TO WS-NM
     MOVE 16 TO WS-NML
     MOVE 0 TO WS-NV
     PERFORM NB-B
     PERFORM NB-E
     MOVE "is_waxed" TO WS-NM
     MOVE 8 TO WS-NML
     MOVE 0 TO WS-NV
     PERFORM NB-B
     PERFORM LOAD-BUFFER
     MOVE 4 TO WS-A
     MOVE 0 TO WS-B
     MOVE 1 TO WS-C
     MOVE 1 TO WS-E
     MOVE 0 TO WS-F
     IF WS-F = 1
     MOVE "0123456789abcdef" TO WS-U16
     ELSE
     MOVE "0123456789abcdef" TO WS-U16
     END-IF
     CALL "BE3-SIGN-USE-ITEM" USING WS-IDX WS-A WS-B WS-C WS-E WS-U16 WS-G WS-H
     MOVE WS-G TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-H TO WS-SHOW
     PERFORM ADD-N
     MOVE BE-XI(WS-IDX, 1) TO WS-SHOW
     PERFORM ADD-N
     MOVE BE-XI(WS-IDX, 5) TO WS-SHOW
     PERFORM ADD-N
     MOVE BE-XI(WS-IDX, 4) TO WS-SHOW
     PERFORM ADD-N
     MOVE "minecraft:oak_sign" TO WS-KEY
     MOVE 18 TO WS-SVL
     MOVE 7 TO WS-NV
     MOVE 5 TO WS-X
     MOVE 70 TO WS-Y
     MOVE 5 TO WS-Z
     CALL "BE-CREATE" USING WS-D WS-X WS-Y WS-Z WS-NV WS-KEY WS-SVL WS-IDX
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     MOVE "front_text" TO WS-NM
     MOVE 10 TO WS-NML
     PERFORM NB-C
     MOVE "messages" TO WS-NM
     MOVE 8 TO WS-NML
     MOVE 8 TO WS-LT
     MOVE 4 TO WS-LC
     PERFORM NB-L
     MOVE SPACES TO WS-NM
     MOVE -1 TO WS-NML
     MOVE SPACES TO WS-SV
     MOVE 0 TO WS-SVL
     PERFORM NB-S
     MOVE SPACES TO WS-NM
     MOVE -1 TO WS-NML
     MOVE SPACES TO WS-SV
     MOVE 0 TO WS-SVL
     PERFORM NB-S
     MOVE SPACES TO WS-NM
     MOVE -1 TO WS-NML
     MOVE SPACES TO WS-SV
     MOVE 0 TO WS-SVL
     PERFORM NB-S
     MOVE SPACES TO WS-NM
     MOVE -1 TO WS-NML
     MOVE SPACES TO WS-SV
     MOVE 0 TO WS-SVL
     PERFORM NB-S
     MOVE "color" TO WS-NM
     MOVE 5 TO WS-NML
     MOVE "black" TO WS-SV
     MOVE 5 TO WS-SVL
     PERFORM NB-S
     MOVE "has_glowing_text" TO WS-NM
     MOVE 16 TO WS-NML
     MOVE 0 TO WS-NV
     PERFORM NB-B
     PERFORM NB-E
     MOVE "is_waxed" TO WS-NM
     MOVE 8 TO WS-NML
     MOVE 0 TO WS-NV
     PERFORM NB-B
     PERFORM LOAD-BUFFER
     MOVE 3 TO WS-A
     MOVE 0 TO WS-B
     MOVE 1 TO WS-C
     MOVE 1 TO WS-E
     MOVE 0 TO WS-F
     IF WS-F = 1
     MOVE "0123456789abcdef" TO WS-U16
     ELSE
     MOVE "0123456789abcdef" TO WS-U16
     END-IF
     CALL "BE3-SIGN-USE-ITEM" USING WS-IDX WS-A WS-B WS-C WS-E WS-U16 WS-G WS-H
     MOVE WS-G TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-H TO WS-SHOW
     PERFORM ADD-N
     MOVE BE-XI(WS-IDX, 1) TO WS-SHOW
     PERFORM ADD-N
     MOVE BE-XI(WS-IDX, 5) TO WS-SHOW
     PERFORM ADD-N
     MOVE BE-XI(WS-IDX, 4) TO WS-SHOW
     PERFORM ADD-N
     MOVE "1 0 0 0 14 2 0 0 0 14 2 0 0 0 15 2 0 0 0 15 2 0 0 0 15 2 0 1 0 15 2 0 0 0 15 1 0 0 0 15 2 0 0 0 15 1" &
         " 0 0 1 15 2 0 0 1 15 1 3003 1 0 15 1 3003 1 0 15 2 0 0 0 15" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "acceptance US12 31-3§2 Signs and hanging signs: use with an empty hand (2.6): a waxed sign plays the interaction-failed sound (action 1); a click command ran gives SUCCESS (1) with no editor; otherwise the editor opens (action 2," TO TL-CASE
     PERFORM BEGIN-CASE
     MOVE "minecraft:oak_sign" TO WS-KEY
     MOVE 18 TO WS-SVL
     MOVE 7 TO WS-NV
     MOVE 5 TO WS-X
     MOVE 70 TO WS-Y
     MOVE 5 TO WS-Z
     CALL "BE-CREATE" USING WS-D WS-X WS-Y WS-Z WS-NV WS-KEY WS-SVL WS-IDX
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     MOVE "front_text" TO WS-NM
     MOVE 10 TO WS-NML
     PERFORM NB-C
     MOVE "messages" TO WS-NM
     MOVE 8 TO WS-NML
     MOVE 8 TO WS-LT
     MOVE 4 TO WS-LC
     PERFORM NB-L
     MOVE SPACES TO WS-NM
     MOVE -1 TO WS-NML
     MOVE "Hi" TO WS-SV
     MOVE 2 TO WS-SVL
     PERFORM NB-S
     MOVE SPACES TO WS-NM
     MOVE -1 TO WS-NML
     MOVE SPACES TO WS-SV
     MOVE 0 TO WS-SVL
     PERFORM NB-S
     MOVE SPACES TO WS-NM
     MOVE -1 TO WS-NML
     MOVE SPACES TO WS-SV
     MOVE 0 TO WS-SVL
     PERFORM NB-S
     MOVE SPACES TO WS-NM
     MOVE -1 TO WS-NML
     MOVE SPACES TO WS-SV
     MOVE 0 TO WS-SVL
     PERFORM NB-S
     MOVE "color" TO WS-NM
     MOVE 5 TO WS-NML
     MOVE "black" TO WS-SV
     MOVE 5 TO WS-SVL
     PERFORM NB-S
     MOVE "has_glowing_text" TO WS-NM
     MOVE 16 TO WS-NML
     MOVE 0 TO WS-NV
     PERFORM NB-B
     PERFORM NB-E
     MOVE "is_waxed" TO WS-NM
     MOVE 8 TO WS-NML
     MOVE 1 TO WS-NV
     PERFORM NB-B
     PERFORM LOAD-BUFFER
     MOVE 1 TO WS-A
     MOVE 1 TO WS-B
     MOVE 0 TO WS-C
     CALL "BE3-SIGN-USE-EMPTY" USING WS-IDX WS-A WS-U16 WS-B WS-C WS-G WS-H
     MOVE WS-G TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-H TO WS-SHOW
     PERFORM ADD-N
     MOVE BE-XI(WS-IDX, 3) TO WS-SHOW
     PERFORM ADD-N
     MOVE "minecraft:oak_sign" TO WS-KEY
     MOVE 18 TO WS-SVL
     MOVE 7 TO WS-NV
     MOVE 5 TO WS-X
     MOVE 70 TO WS-Y
     MOVE 5 TO WS-Z
     CALL "BE-CREATE" USING WS-D WS-X WS-Y WS-Z WS-NV WS-KEY WS-SVL WS-IDX
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     MOVE "front_text" TO WS-NM
     MOVE 10 TO WS-NML
     PERFORM NB-C
     MOVE "messages" TO WS-NM
     MOVE 8 TO WS-NML
     MOVE 8 TO WS-LT
     MOVE 4 TO WS-LC
     PERFORM NB-L
     MOVE SPACES TO WS-NM
     MOVE -1 TO WS-NML
     MOVE "Hi" TO WS-SV
     MOVE 2 TO WS-SVL
     PERFORM NB-S
     MOVE SPACES TO WS-NM
     MOVE -1 TO WS-NML
     MOVE SPACES TO WS-SV
     MOVE 0 TO WS-SVL
     PERFORM NB-S
     MOVE SPACES TO WS-NM
     MOVE -1 TO WS-NML
     MOVE SPACES TO WS-SV
     MOVE 0 TO WS-SVL
     PERFORM NB-S
     MOVE SPACES TO WS-NM
     MOVE -1 TO WS-NML
     MOVE SPACES TO WS-SV
     MOVE 0 TO WS-SVL
     PERFORM NB-S
     MOVE "color" TO WS-NM
     MOVE 5 TO WS-NML
     MOVE "black" TO WS-SV
     MOVE 5 TO WS-SVL
     PERFORM NB-S
     MOVE "has_glowing_text" TO WS-NM
     MOVE 16 TO WS-NML
     MOVE 0 TO WS-NV
     PERFORM NB-B
     PERFORM NB-E
     MOVE "is_waxed" TO WS-NM
     MOVE 8 TO WS-NML
     MOVE 1 TO WS-NV
     PERFORM NB-B
     PERFORM LOAD-BUFFER
     MOVE 1 TO WS-A
     MOVE 1 TO WS-B
     MOVE 1 TO WS-C
     CALL "BE3-SIGN-USE-EMPTY" USING WS-IDX WS-A WS-U16 WS-B WS-C WS-G WS-H
     MOVE WS-G TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-H TO WS-SHOW
     PERFORM ADD-N
     MOVE BE-XI(WS-IDX, 3) TO WS-SHOW
     PERFORM ADD-N
     MOVE "minecraft:oak_sign" TO WS-KEY
     MOVE 18 TO WS-SVL
     MOVE 7 TO WS-NV
     MOVE 5 TO WS-X
     MOVE 70 TO WS-Y
     MOVE 5 TO WS-Z
     CALL "BE-CREATE" USING WS-D WS-X WS-Y WS-Z WS-NV WS-KEY WS-SVL WS-IDX
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     MOVE "front_text" TO WS-NM
     MOVE 10 TO WS-NML
     PERFORM NB-C
     MOVE "messages" TO WS-NM
     MOVE 8 TO WS-NML
     MOVE 8 TO WS-LT
     MOVE 4 TO WS-LC
     PERFORM NB-L
     MOVE SPACES TO WS-NM
     MOVE -1 TO WS-NML
     MOVE "Hi" TO WS-SV
     MOVE 2 TO WS-SVL
     PERFORM NB-S
     MOVE SPACES TO WS-NM
     MOVE -1 TO WS-NML
     MOVE SPACES TO WS-SV
     MOVE 0 TO WS-SVL
     PERFORM NB-S
     MOVE SPACES TO WS-NM
     MOVE -1 TO WS-NML
     MOVE SPACES TO WS-SV
     MOVE 0 TO WS-SVL
     PERFORM NB-S
     MOVE SPACES TO WS-NM
     MOVE -1 TO WS-NML
     MOVE SPACES TO WS-SV
     MOVE 0 TO WS-SVL
     PERFORM NB-S
     MOVE "color" TO WS-NM
     MOVE 5 TO WS-NML
     MOVE "black" TO WS-SV
     MOVE 5 TO WS-SVL
     PERFORM NB-S
     MOVE "has_glowing_text" TO WS-NM
     MOVE 16 TO WS-NML
     MOVE 0 TO WS-NV
     PERFORM NB-B
     PERFORM NB-E
     MOVE "is_waxed" TO WS-NM
     MOVE 8 TO WS-NML
     MOVE 0 TO WS-NV
     PERFORM NB-B
     PERFORM LOAD-BUFFER
     MOVE 1 TO WS-A
     MOVE 1 TO WS-B
     MOVE 1 TO WS-C
     CALL "BE3-SIGN-USE-EMPTY" USING WS-IDX WS-A WS-U16 WS-B WS-C WS-G WS-H
     MOVE WS-G TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-H TO WS-SHOW
     PERFORM ADD-N
     MOVE BE-XI(WS-IDX, 3) TO WS-SHOW
     PERFORM ADD-N
     MOVE "minecraft:oak_sign" TO WS-KEY
     MOVE 18 TO WS-SVL
     MOVE 7 TO WS-NV
     MOVE 5 TO WS-X
     MOVE 70 TO WS-Y
     MOVE 5 TO WS-Z
     CALL "BE-CREATE" USING WS-D WS-X WS-Y WS-Z WS-NV WS-KEY WS-SVL WS-IDX
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     MOVE "front_text" TO WS-NM
     MOVE 10 TO WS-NML
     PERFORM NB-C
     MOVE "messages" TO WS-NM
     MOVE 8 TO WS-NML
     MOVE 8 TO WS-LT
     MOVE 4 TO WS-LC
     PERFORM NB-L
     MOVE SPACES TO WS-NM
     MOVE -1 TO WS-NML
     MOVE "Hi" TO WS-SV
     MOVE 2 TO WS-SVL
     PERFORM NB-S
     MOVE SPACES TO WS-NM
     MOVE -1 TO WS-NML
     MOVE SPACES TO WS-SV
     MOVE 0 TO WS-SVL
     PERFORM NB-S
     MOVE SPACES TO WS-NM
     MOVE -1 TO WS-NML
     MOVE SPACES TO WS-SV
     MOVE 0 TO WS-SVL
     PERFORM NB-S
     MOVE SPACES TO WS-NM
     MOVE -1 TO WS-NML
     MOVE SPACES TO WS-SV
     MOVE 0 TO WS-SVL
     PERFORM NB-S
     MOVE "color" TO WS-NM
     MOVE 5 TO WS-NML
     MOVE "black" TO WS-SV
     MOVE 5 TO WS-SVL
     PERFORM NB-S
     MOVE "has_glowing_text" TO WS-NM
     MOVE 16 TO WS-NML
     MOVE 0 TO WS-NV
     PERFORM NB-B
     PERFORM NB-E
     MOVE "is_waxed" TO WS-NM
     MOVE 8 TO WS-NML
     MOVE 0 TO WS-NV
     PERFORM NB-B
     PERFORM LOAD-BUFFER
     MOVE 1 TO WS-A
     MOVE 1 TO WS-B
     MOVE 0 TO WS-C
     CALL "BE3-SIGN-USE-EMPTY" USING WS-IDX WS-A WS-U16 WS-B WS-C WS-G WS-H
     MOVE WS-G TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-H TO WS-SHOW
     PERFORM ADD-N
     MOVE BE-XI(WS-IDX, 3) TO WS-SHOW
     PERFORM ADD-N
     MOVE "minecraft:oak_sign" TO WS-KEY
     MOVE 18 TO WS-SVL
     MOVE 7 TO WS-NV
     MOVE 5 TO WS-X
     MOVE 70 TO WS-Y
     MOVE 5 TO WS-Z
     CALL "BE-CREATE" USING WS-D WS-X WS-Y WS-Z WS-NV WS-KEY WS-SVL WS-IDX
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     MOVE "front_text" TO WS-NM
     MOVE 10 TO WS-NML
     PERFORM NB-C
     MOVE "messages" TO WS-NM
     MOVE 8 TO WS-NML
     MOVE 8 TO WS-LT
     MOVE 4 TO WS-LC
     PERFORM NB-L
     MOVE SPACES TO WS-NM
     MOVE -1 TO WS-NML
     MOVE "Hi" TO WS-SV
     MOVE 2 TO WS-SVL
     PERFORM NB-S
     MOVE SPACES TO WS-NM
     MOVE -1 TO WS-NML
     MOVE SPACES TO WS-SV
     MOVE 0 TO WS-SVL
     PERFORM NB-S
     MOVE SPACES TO WS-NM
     MOVE -1 TO WS-NML
     MOVE SPACES TO WS-SV
     MOVE 0 TO WS-SVL
     PERFORM NB-S
     MOVE SPACES TO WS-NM
     MOVE -1 TO WS-NML
     MOVE SPACES TO WS-SV
     MOVE 0 TO WS-SVL
     PERFORM NB-S
     MOVE "color" TO WS-NM
     MOVE 5 TO WS-NML
     MOVE "black" TO WS-SV
     MOVE 5 TO WS-SVL
     PERFORM NB-S
     MOVE "has_glowing_text" TO WS-NM
     MOVE 16 TO WS-NML
     MOVE 0 TO WS-NV
     PERFORM NB-B
     PERFORM NB-E
     MOVE "is_waxed" TO WS-NM
     MOVE 8 TO WS-NML
     MOVE 0 TO WS-NV
     PERFORM NB-B
     PERFORM LOAD-BUFFER
     MOVE 1 TO BE-XI(WS-IDX, 3)
     MOVE "fedcba9876543210" TO BE-XT(WS-IDX, 17)
     MOVE 1 TO WS-A
     MOVE 1 TO WS-B
     MOVE 0 TO WS-C
     CALL "BE3-SIGN-USE-EMPTY" USING WS-IDX WS-A WS-U16 WS-B WS-C WS-G WS-H
     MOVE WS-G TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-H TO WS-SHOW
     PERFORM ADD-N
     MOVE BE-XI(WS-IDX, 3) TO WS-SHOW
     PERFORM ADD-N
     MOVE "minecraft:oak_sign" TO WS-KEY
     MOVE 18 TO WS-SVL
     MOVE 7 TO WS-NV
     MOVE 5 TO WS-X
     MOVE 70 TO WS-Y
     MOVE 5 TO WS-Z
     CALL "BE-CREATE" USING WS-D WS-X WS-Y WS-Z WS-NV WS-KEY WS-SVL WS-IDX
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     MOVE "front_text" TO WS-NM
     MOVE 10 TO WS-NML
     PERFORM NB-C
     MOVE "messages" TO WS-NM
     MOVE 8 TO WS-NML
     MOVE 8 TO WS-LT
     MOVE 4 TO WS-LC
     PERFORM NB-L
     MOVE SPACES TO WS-NM
     MOVE -1 TO WS-NML
     MOVE "Hi" TO WS-SV
     MOVE 2 TO WS-SVL
     PERFORM NB-S
     MOVE SPACES TO WS-NM
     MOVE -1 TO WS-NML
     MOVE SPACES TO WS-SV
     MOVE 0 TO WS-SVL
     PERFORM NB-S
     MOVE SPACES TO WS-NM
     MOVE -1 TO WS-NML
     MOVE SPACES TO WS-SV
     MOVE 0 TO WS-SVL
     PERFORM NB-S
     MOVE SPACES TO WS-NM
     MOVE -1 TO WS-NML
     MOVE SPACES TO WS-SV
     MOVE 0 TO WS-SVL
     PERFORM NB-S
     MOVE "color" TO WS-NM
     MOVE 5 TO WS-NML
     MOVE "black" TO WS-SV
     MOVE 5 TO WS-SVL
     PERFORM NB-S
     MOVE "has_glowing_text" TO WS-NM
     MOVE 16 TO WS-NML
     MOVE 0 TO WS-NV
     PERFORM NB-B
     PERFORM NB-E
     MOVE "is_waxed" TO WS-NM
     MOVE 8 TO WS-NML
     MOVE 0 TO WS-NV
     PERFORM NB-B
     PERFORM LOAD-BUFFER
     MOVE 1 TO WS-A
     MOVE 0 TO WS-B
     MOVE 0 TO WS-C
     CALL "BE3-SIGN-USE-EMPTY" USING WS-IDX WS-A WS-U16 WS-B WS-C WS-G WS-H
     MOVE WS-G TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-H TO WS-SHOW
     PERFORM ADD-N
     MOVE BE-XI(WS-IDX, 3) TO WS-SHOW
     PERFORM ADD-N
     MOVE "minecraft:oak_sign" TO WS-KEY
     MOVE 18 TO WS-SVL
     MOVE 7 TO WS-NV
     MOVE 5 TO WS-X
     MOVE 70 TO WS-Y
     MOVE 5 TO WS-Z
     CALL "BE-CREATE" USING WS-D WS-X WS-Y WS-Z WS-NV WS-KEY WS-SVL WS-IDX
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     MOVE "front_text" TO WS-NM
     MOVE 10 TO WS-NML
     PERFORM NB-C
     MOVE "messages" TO WS-NM
     MOVE 8 TO WS-NML
     MOVE 8 TO WS-LT
     MOVE 4 TO WS-LC
     PERFORM NB-L
     MOVE SPACES TO WS-NM
     MOVE -1 TO WS-NML
     MOVE "Hi" TO WS-SV
     MOVE 2 TO WS-SVL
     PERFORM NB-S
     MOVE SPACES TO WS-NM
     MOVE -1 TO WS-NML
     MOVE SPACES TO WS-SV
     MOVE 0 TO WS-SVL
     PERFORM NB-S
     MOVE SPACES TO WS-NM
     MOVE -1 TO WS-NML
     MOVE SPACES TO WS-SV
     MOVE 0 TO WS-SVL
     PERFORM NB-S
     MOVE SPACES TO WS-NM
     MOVE -1 TO WS-NML
     MOVE SPACES TO WS-SV
     MOVE 0 TO WS-SVL
     PERFORM NB-S
     MOVE "color" TO WS-NM
     MOVE 5 TO WS-NML
     MOVE "black" TO WS-SV
     MOVE 5 TO WS-SVL
     PERFORM NB-S
     MOVE "has_glowing_text" TO WS-NM
     MOVE 16 TO WS-NML
     MOVE 0 TO WS-NV
     PERFORM NB-B
     PERFORM NB-E
     MOVE "is_waxed" TO WS-NM
     MOVE 8 TO WS-NML
     MOVE 1 TO WS-NV
     PERFORM NB-B
     PERFORM LOAD-BUFFER
     MOVE 1 TO BE-XI(WS-IDX, 3)
     MOVE "fedcba9876543210" TO BE-XT(WS-IDX, 17)
     MOVE 1 TO WS-A
     MOVE 0 TO WS-B
     MOVE 0 TO WS-C
     CALL "BE3-SIGN-USE-EMPTY" USING WS-IDX WS-A WS-U16 WS-B WS-C WS-G WS-H
     MOVE WS-G TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-H TO WS-SHOW
     PERFORM ADD-N
     MOVE BE-XI(WS-IDX, 3) TO WS-SHOW
     PERFORM ADD-N
     MOVE "1 1 0 1 1 0 1 0 0 1 2 1 0 0 1 0 0 0 1 1 1" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "acceptance US12 31-3§2 Signs and hanging signs: click commands (2.7): run_command, show_dialog and custom clicks count (run only when allow_op_features is true; the red overlay sign.click_actions_disabled follows when something" TO TL-CASE
     PERFORM BEGIN-CASE
     MOVE 0 TO WS-A
     MOVE 0 TO WS-B
     CALL "BE3-CLICK-ACTION" USING WS-A WS-B WS-C WS-E
     CALL "BE3-CLICK-SUMMARY" USING WS-B WS-E WS-F
     MOVE WS-C TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-E TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-F TO WS-SHOW
     PERFORM ADD-N
     MOVE 0 TO WS-A
     MOVE 1 TO WS-B
     CALL "BE3-CLICK-ACTION" USING WS-A WS-B WS-C WS-E
     CALL "BE3-CLICK-SUMMARY" USING WS-B WS-E WS-F
     MOVE WS-C TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-E TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-F TO WS-SHOW
     PERFORM ADD-N
     MOVE 1 TO WS-A
     MOVE 0 TO WS-B
     CALL "BE3-CLICK-ACTION" USING WS-A WS-B WS-C WS-E
     CALL "BE3-CLICK-SUMMARY" USING WS-B WS-E WS-F
     MOVE WS-C TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-E TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-F TO WS-SHOW
     PERFORM ADD-N
     MOVE 1 TO WS-A
     MOVE 1 TO WS-B
     CALL "BE3-CLICK-ACTION" USING WS-A WS-B WS-C WS-E
     CALL "BE3-CLICK-SUMMARY" USING WS-B WS-E WS-F
     MOVE WS-C TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-E TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-F TO WS-SHOW
     PERFORM ADD-N
     MOVE 2 TO WS-A
     MOVE 0 TO WS-B
     CALL "BE3-CLICK-ACTION" USING WS-A WS-B WS-C WS-E
     CALL "BE3-CLICK-SUMMARY" USING WS-B WS-E WS-F
     MOVE WS-C TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-E TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-F TO WS-SHOW
     PERFORM ADD-N
     MOVE 2 TO WS-A
     MOVE 1 TO WS-B
     CALL "BE3-CLICK-ACTION" USING WS-A WS-B WS-C WS-E
     CALL "BE3-CLICK-SUMMARY" USING WS-B WS-E WS-F
     MOVE WS-C TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-E TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-F TO WS-SHOW
     PERFORM ADD-N
     MOVE 3 TO WS-A
     MOVE 0 TO WS-B
     CALL "BE3-CLICK-ACTION" USING WS-A WS-B WS-C WS-E
     CALL "BE3-CLICK-SUMMARY" USING WS-B WS-E WS-F
     MOVE WS-C TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-E TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-F TO WS-SHOW
     PERFORM ADD-N
     MOVE 3 TO WS-A
     MOVE 1 TO WS-B
     CALL "BE3-CLICK-ACTION" USING WS-A WS-B WS-C WS-E
     CALL "BE3-CLICK-SUMMARY" USING WS-B WS-E WS-F
     MOVE WS-C TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-E TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-F TO WS-SHOW
     PERFORM ADD-N
     MOVE 4 TO WS-A
     MOVE 0 TO WS-B
     CALL "BE3-CLICK-ACTION" USING WS-A WS-B WS-C WS-E
     CALL "BE3-CLICK-SUMMARY" USING WS-B WS-E WS-F
     MOVE WS-C TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-E TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-F TO WS-SHOW
     PERFORM ADD-N
     MOVE 4 TO WS-A
     MOVE 1 TO WS-B
     CALL "BE3-CLICK-ACTION" USING WS-A WS-B WS-C WS-E
     CALL "BE3-CLICK-SUMMARY" USING WS-B WS-E WS-F
     MOVE WS-C TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-E TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-F TO WS-SHOW
     PERFORM ADD-N
     MOVE 0 TO WS-A
     MOVE 0 TO WS-B
     CALL "BE3-CLICK-CAN" USING WS-A WS-B WS-C
     MOVE WS-C TO WS-SHOW
     PERFORM ADD-N
     MOVE 0 TO WS-A
     MOVE 1 TO WS-B
     CALL "BE3-CLICK-CAN" USING WS-A WS-B WS-C
     MOVE WS-C TO WS-SHOW
     PERFORM ADD-N
     MOVE 1 TO WS-A
     MOVE 0 TO WS-B
     CALL "BE3-CLICK-CAN" USING WS-A WS-B WS-C
     MOVE WS-C TO WS-SHOW
     PERFORM ADD-N
     MOVE 1 TO WS-A
     MOVE 1 TO WS-B
     CALL "BE3-CLICK-CAN" USING WS-A WS-B WS-C
     MOVE WS-C TO WS-SHOW
     PERFORM ADD-N
     MOVE "0 0 0 0 0 0 0 1 1 1 1 0 0 1 1 1 1 0 0 1 1 1 1 0 0 0 0 0 0 0 0 0 0 1" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "acceptance US12 31-3§2 Signs and hanging signs: edit packet strings (2.8 step 1): every section sign followed by 0-9, a-f, k-o or r (either case) is removed with its character; other section signs stay" TO TL-CASE
     PERFORM BEGIN-CASE
     MOVE SPACES TO WS-TX
     MOVE "§aGreen" TO WS-TX
     MOVE 8 TO WS-A
     CALL "BE3-SIGN-STRIP" USING WS-TX WS-A
     MOVE WS-A TO WS-SHOW
     PERFORM ADD-N
     STRING WS-TX(1:WS-A) " " DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-PTR
     MOVE SPACES TO WS-TX
     MOVE "plain" TO WS-TX
     MOVE 5 TO WS-A
     CALL "BE3-SIGN-STRIP" USING WS-TX WS-A
     MOVE WS-A TO WS-SHOW
     PERFORM ADD-N
     STRING WS-TX(1:WS-A) " " DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-PTR
     MOVE SPACES TO WS-TX
     MOVE SPACES TO WS-TX
     MOVE 0 TO WS-A
     CALL "BE3-SIGN-STRIP" USING WS-TX WS-A
     MOVE WS-A TO WS-SHOW
     PERFORM ADD-N
     MOVE 0 TO WS-SHOW
     PERFORM ADD-N
     MOVE SPACES TO WS-TX
     MOVE "x§r" TO WS-TX
     MOVE 4 TO WS-A
     CALL "BE3-SIGN-STRIP" USING WS-TX WS-A
     MOVE WS-A TO WS-SHOW
     PERFORM ADD-N
     STRING WS-TX(1:WS-A) " " DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-PTR
     MOVE SPACES TO WS-TX
     MOVE "§§1y" TO WS-TX
     MOVE 6 TO WS-A
     CALL "BE3-SIGN-STRIP" USING WS-TX WS-A
     MOVE WS-A TO WS-SHOW
     PERFORM ADD-N
     STRING WS-TX(1:WS-A) " " DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-PTR
     MOVE SPACES TO WS-TX
     MOVE "§zq§" TO WS-TX
     MOVE 6 TO WS-A
     CALL "BE3-SIGN-STRIP" USING WS-TX WS-A
     MOVE WS-A TO WS-SHOW
     PERFORM ADD-N
     STRING WS-TX(1:WS-A) " " DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-PTR
     MOVE SPACES TO WS-TX
     MOVE "§K§l§N" TO WS-TX
     MOVE 9 TO WS-A
     CALL "BE3-SIGN-STRIP" USING WS-TX WS-A
     MOVE WS-A TO WS-SHOW
     PERFORM ADD-N
     MOVE 0 TO WS-SHOW
     PERFORM ADD-N
     MOVE "5 Green 5 plain 0 0 1 x 3 §y 6 §zq§ 0 0" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "acceptance US12 31-3§2 Signs and hanging signs: edit by the editor (2.8, worked example 4): the lines are stripped and stored as raw and filtered text, colour and glow stay, the lock is cleared, the result is 1" TO TL-CASE
     PERFORM BEGIN-CASE
     MOVE "minecraft:oak_sign" TO WS-KEY
     MOVE 18 TO WS-SVL
     MOVE 7 TO WS-NV
     MOVE 5 TO WS-X
     MOVE 70 TO WS-Y
     MOVE 5 TO WS-Z
     CALL "BE-CREATE" USING WS-D WS-X WS-Y WS-Z WS-NV WS-KEY WS-SVL WS-IDX
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     MOVE "front_text" TO WS-NM
     MOVE 10 TO WS-NML
     PERFORM NB-C
     MOVE "messages" TO WS-NM
     MOVE 8 TO WS-NML
     MOVE 8 TO WS-LT
     MOVE 4 TO WS-LC
     PERFORM NB-L
     MOVE SPACES TO WS-NM
     MOVE -1 TO WS-NML
     MOVE "Hi" TO WS-SV
     MOVE 2 TO WS-SVL
     PERFORM NB-S
     MOVE SPACES TO WS-NM
     MOVE -1 TO WS-NML
     MOVE SPACES TO WS-SV
     MOVE 0 TO WS-SVL
     PERFORM NB-S
     MOVE SPACES TO WS-NM
     MOVE -1 TO WS-NML
     MOVE SPACES TO WS-SV
     MOVE 0 TO WS-SVL
     PERFORM NB-S
     MOVE SPACES TO WS-NM
     MOVE -1 TO WS-NML
     MOVE SPACES TO WS-SV
     MOVE 0 TO WS-SVL
     PERFORM NB-S
     MOVE "color" TO WS-NM
     MOVE 5 TO WS-NML
     MOVE "red" TO WS-SV
     MOVE 3 TO WS-SVL
     PERFORM NB-S
     MOVE "has_glowing_text" TO WS-NM
     MOVE 16 TO WS-NML
     MOVE 1 TO WS-NV
     PERFORM NB-B
     PERFORM NB-E
     MOVE "is_waxed" TO WS-NM
     MOVE 8 TO WS-NML
     MOVE 0 TO WS-NV
     PERFORM NB-B
     PERFORM LOAD-BUFFER
     MOVE 1 TO BE-XI(WS-IDX, 3)
     MOVE "0123456789abcdef" TO BE-XT(WS-IDX, 17)
     MOVE SPACES TO WS-LINE-TEXT(1)
     MOVE "§aGreen" TO WS-LINE-TEXT(1)
     MOVE 8 TO WS-LINE-LEN(1)
     MOVE SPACES TO WS-LINE-TEXT(2)
     MOVE "plain" TO WS-LINE-TEXT(2)
     MOVE 5 TO WS-LINE-LEN(2)
     MOVE SPACES TO WS-LINE-TEXT(3)
     MOVE SPACES TO WS-LINE-TEXT(3)
     MOVE 0 TO WS-LINE-LEN(3)
     MOVE SPACES TO WS-LINE-TEXT(4)
     MOVE "x§r" TO WS-LINE-TEXT(4)
     MOVE 4 TO WS-LINE-LEN(4)
     MOVE 1 TO WS-A
     CALL "BE3-SIGN-UPDATE" USING WS-IDX WS-A WS-U16 WS-LINES WS-B
     MOVE 2 TO WS-FORM
     MOVE WS-B TO WS-SHOW
     PERFORM ADD-N
     MOVE BE-XI(WS-IDX, 3) TO WS-SHOW
     PERFORM ADD-N
     PERFORM SAVE-RENDER
     MOVE "1 0 {front_text:{messages:[Green,plain,,x],color:red,has_glowing_text:1},back_text:{messages:[,,,],c" &
         "olor:black,has_glowing_text:0},is_waxed:0}" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "acceptance US12 31-3§2 Signs and hanging signs: edit by a stranger (2.8, worked example 5): nothing changes and the lock stays (result 0, lock still set; the front text keeps Hi, the back stays empty)" TO TL-CASE
     PERFORM BEGIN-CASE
     MOVE "minecraft:oak_sign" TO WS-KEY
     MOVE 18 TO WS-SVL
     MOVE 7 TO WS-NV
     MOVE 5 TO WS-X
     MOVE 70 TO WS-Y
     MOVE 5 TO WS-Z
     CALL "BE-CREATE" USING WS-D WS-X WS-Y WS-Z WS-NV WS-KEY WS-SVL WS-IDX
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     MOVE "front_text" TO WS-NM
     MOVE 10 TO WS-NML
     PERFORM NB-C
     MOVE "messages" TO WS-NM
     MOVE 8 TO WS-NML
     MOVE 8 TO WS-LT
     MOVE 4 TO WS-LC
     PERFORM NB-L
     MOVE SPACES TO WS-NM
     MOVE -1 TO WS-NML
     MOVE "Hi" TO WS-SV
     MOVE 2 TO WS-SVL
     PERFORM NB-S
     MOVE SPACES TO WS-NM
     MOVE -1 TO WS-NML
     MOVE SPACES TO WS-SV
     MOVE 0 TO WS-SVL
     PERFORM NB-S
     MOVE SPACES TO WS-NM
     MOVE -1 TO WS-NML
     MOVE SPACES TO WS-SV
     MOVE 0 TO WS-SVL
     PERFORM NB-S
     MOVE SPACES TO WS-NM
     MOVE -1 TO WS-NML
     MOVE SPACES TO WS-SV
     MOVE 0 TO WS-SVL
     PERFORM NB-S
     MOVE "color" TO WS-NM
     MOVE 5 TO WS-NML
     MOVE "black" TO WS-SV
     MOVE 5 TO WS-SVL
     PERFORM NB-S
     MOVE "has_glowing_text" TO WS-NM
     MOVE 16 TO WS-NML
     MOVE 0 TO WS-NV
     PERFORM NB-B
     PERFORM NB-E
     MOVE "is_waxed" TO WS-NM
     MOVE 8 TO WS-NML
     MOVE 0 TO WS-NV
     PERFORM NB-B
     PERFORM LOAD-BUFFER
     MOVE 1 TO BE-XI(WS-IDX, 3)
     MOVE "0123456789abcdef" TO BE-XT(WS-IDX, 17)
     MOVE SPACES TO WS-LINE-TEXT(1)
     MOVE "q" TO WS-LINE-TEXT(1)
     MOVE 1 TO WS-LINE-LEN(1)
     MOVE SPACES TO WS-LINE-TEXT(2)
     MOVE SPACES TO WS-LINE-TEXT(2)
     MOVE 0 TO WS-LINE-LEN(2)
     MOVE SPACES TO WS-LINE-TEXT(3)
     MOVE SPACES TO WS-LINE-TEXT(3)
     MOVE 0 TO WS-LINE-LEN(3)
     MOVE SPACES TO WS-LINE-TEXT(4)
     MOVE SPACES TO WS-LINE-TEXT(4)
     MOVE 0 TO WS-LINE-LEN(4)
     MOVE 1 TO WS-A
     CALL "BE3-SIGN-UPDATE" USING WS-IDX WS-A WS-V16 WS-LINES WS-B
     MOVE BE-XI(WS-IDX, 3) TO WS-C
     MOVE 0 TO WS-A
     CALL "BE3-SIGN-HAS-MESSAGE" USING WS-IDX WS-A WS-E
     MOVE 1 TO WS-A
     CALL "BE3-SIGN-HAS-MESSAGE" USING WS-IDX WS-A WS-F
     MOVE 2 TO WS-FORM
     MOVE WS-B TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-C TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-E TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-F TO WS-SHOW
     PERFORM ADD-N
     MOVE "0 1 0 1" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "acceptance US12 31-3§2 Signs and hanging signs: edit refused (2.8): a waxed sign, and a sign nobody opened for editing (no lock), both refuse the packet (result 0); the waxed sign keeps its lock" TO TL-CASE
     PERFORM BEGIN-CASE
     MOVE "minecraft:oak_sign" TO WS-KEY
     MOVE 18 TO WS-SVL
     MOVE 7 TO WS-NV
     MOVE 5 TO WS-X
     MOVE 70 TO WS-Y
     MOVE 5 TO WS-Z
     CALL "BE-CREATE" USING WS-D WS-X WS-Y WS-Z WS-NV WS-KEY WS-SVL WS-IDX
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     MOVE "front_text" TO WS-NM
     MOVE 10 TO WS-NML
     PERFORM NB-C
     MOVE "messages" TO WS-NM
     MOVE 8 TO WS-NML
     MOVE 8 TO WS-LT
     MOVE 4 TO WS-LC
     PERFORM NB-L
     MOVE SPACES TO WS-NM
     MOVE -1 TO WS-NML
     MOVE "Hi" TO WS-SV
     MOVE 2 TO WS-SVL
     PERFORM NB-S
     MOVE SPACES TO WS-NM
     MOVE -1 TO WS-NML
     MOVE SPACES TO WS-SV
     MOVE 0 TO WS-SVL
     PERFORM NB-S
     MOVE SPACES TO WS-NM
     MOVE -1 TO WS-NML
     MOVE SPACES TO WS-SV
     MOVE 0 TO WS-SVL
     PERFORM NB-S
     MOVE SPACES TO WS-NM
     MOVE -1 TO WS-NML
     MOVE SPACES TO WS-SV
     MOVE 0 TO WS-SVL
     PERFORM NB-S
     MOVE "color" TO WS-NM
     MOVE 5 TO WS-NML
     MOVE "black" TO WS-SV
     MOVE 5 TO WS-SVL
     PERFORM NB-S
     MOVE "has_glowing_text" TO WS-NM
     MOVE 16 TO WS-NML
     MOVE 0 TO WS-NV
     PERFORM NB-B
     PERFORM NB-E
     MOVE "is_waxed" TO WS-NM
     MOVE 8 TO WS-NML
     MOVE 1 TO WS-NV
     PERFORM NB-B
     PERFORM LOAD-BUFFER
     MOVE 1 TO BE-XI(WS-IDX, 3)
     MOVE "0123456789abcdef" TO BE-XT(WS-IDX, 17)
     MOVE SPACES TO WS-LINE-TEXT(1)
     MOVE "q" TO WS-LINE-TEXT(1)
     MOVE 1 TO WS-LINE-LEN(1)
     MOVE SPACES TO WS-LINE-TEXT(2)
     MOVE SPACES TO WS-LINE-TEXT(2)
     MOVE 0 TO WS-LINE-LEN(2)
     MOVE SPACES TO WS-LINE-TEXT(3)
     MOVE SPACES TO WS-LINE-TEXT(3)
     MOVE 0 TO WS-LINE-LEN(3)
     MOVE SPACES TO WS-LINE-TEXT(4)
     MOVE SPACES TO WS-LINE-TEXT(4)
     MOVE 0 TO WS-LINE-LEN(4)
     MOVE 1 TO WS-A
     CALL "BE3-SIGN-UPDATE" USING WS-IDX WS-A WS-U16 WS-LINES WS-B
     MOVE BE-XI(WS-IDX, 3) TO WS-C
     MOVE "minecraft:oak_sign" TO WS-KEY
     MOVE 18 TO WS-SVL
     MOVE 7 TO WS-NV
     MOVE 5 TO WS-X
     MOVE 70 TO WS-Y
     MOVE 5 TO WS-Z
     CALL "BE-CREATE" USING WS-D WS-X WS-Y WS-Z WS-NV WS-KEY WS-SVL WS-IDX
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     MOVE "front_text" TO WS-NM
     MOVE 10 TO WS-NML
     PERFORM NB-C
     MOVE "messages" TO WS-NM
     MOVE 8 TO WS-NML
     MOVE 8 TO WS-LT
     MOVE 4 TO WS-LC
     PERFORM NB-L
     MOVE SPACES TO WS-NM
     MOVE -1 TO WS-NML
     MOVE "Hi" TO WS-SV
     MOVE 2 TO WS-SVL
     PERFORM NB-S
     MOVE SPACES TO WS-NM
     MOVE -1 TO WS-NML
     MOVE SPACES TO WS-SV
     MOVE 0 TO WS-SVL
     PERFORM NB-S
     MOVE SPACES TO WS-NM
     MOVE -1 TO WS-NML
     MOVE SPACES TO WS-SV
     MOVE 0 TO WS-SVL
     PERFORM NB-S
     MOVE SPACES TO WS-NM
     MOVE -1 TO WS-NML
     MOVE SPACES TO WS-SV
     MOVE 0 TO WS-SVL
     PERFORM NB-S
     MOVE "color" TO WS-NM
     MOVE 5 TO WS-NML
     MOVE "black" TO WS-SV
     MOVE 5 TO WS-SVL
     PERFORM NB-S
     MOVE "has_glowing_text" TO WS-NM
     MOVE 16 TO WS-NML
     MOVE 0 TO WS-NV
     PERFORM NB-B
     PERFORM NB-E
     MOVE "is_waxed" TO WS-NM
     MOVE 8 TO WS-NML
     MOVE 0 TO WS-NV
     PERFORM NB-B
     PERFORM LOAD-BUFFER
     MOVE SPACES TO WS-LINE-TEXT(1)
     MOVE "q" TO WS-LINE-TEXT(1)
     MOVE 1 TO WS-LINE-LEN(1)
     MOVE SPACES TO WS-LINE-TEXT(2)
     MOVE SPACES TO WS-LINE-TEXT(2)
     MOVE 0 TO WS-LINE-LEN(2)
     MOVE SPACES TO WS-LINE-TEXT(3)
     MOVE SPACES TO WS-LINE-TEXT(3)
     MOVE 0 TO WS-LINE-LEN(3)
     MOVE SPACES TO WS-LINE-TEXT(4)
     MOVE SPACES TO WS-LINE-TEXT(4)
     MOVE 0 TO WS-LINE-LEN(4)
     MOVE 1 TO WS-A
     CALL "BE3-SIGN-UPDATE" USING WS-IDX WS-A WS-U16 WS-LINES WS-E
     MOVE WS-B TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-C TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-E TO WS-SHOW
     PERFORM ADD-N
     MOVE "0 1 0" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "acceptance US12 31-3§2 Signs and hanging signs: edit of the back side (2.8): side 0 stores into the back text; a line longer than the 64 bytes kept per line is cut; the front stays" TO TL-CASE
     PERFORM BEGIN-CASE
     MOVE "minecraft:oak_sign" TO WS-KEY
     MOVE 18 TO WS-SVL
     MOVE 7 TO WS-NV
     MOVE 5 TO WS-X
     MOVE 70 TO WS-Y
     MOVE 5 TO WS-Z
     CALL "BE-CREATE" USING WS-D WS-X WS-Y WS-Z WS-NV WS-KEY WS-SVL WS-IDX
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     MOVE "front_text" TO WS-NM
     MOVE 10 TO WS-NML
     PERFORM NB-C
     MOVE "messages" TO WS-NM
     MOVE 8 TO WS-NML
     MOVE 8 TO WS-LT
     MOVE 4 TO WS-LC
     PERFORM NB-L
     MOVE SPACES TO WS-NM
     MOVE -1 TO WS-NML
     MOVE "Hi" TO WS-SV
     MOVE 2 TO WS-SVL
     PERFORM NB-S
     MOVE SPACES TO WS-NM
     MOVE -1 TO WS-NML
     MOVE SPACES TO WS-SV
     MOVE 0 TO WS-SVL
     PERFORM NB-S
     MOVE SPACES TO WS-NM
     MOVE -1 TO WS-NML
     MOVE SPACES TO WS-SV
     MOVE 0 TO WS-SVL
     PERFORM NB-S
     MOVE SPACES TO WS-NM
     MOVE -1 TO WS-NML
     MOVE SPACES TO WS-SV
     MOVE 0 TO WS-SVL
     PERFORM NB-S
     MOVE "color" TO WS-NM
     MOVE 5 TO WS-NML
     MOVE "black" TO WS-SV
     MOVE 5 TO WS-SVL
     PERFORM NB-S
     MOVE "has_glowing_text" TO WS-NM
     MOVE 16 TO WS-NML
     MOVE 0 TO WS-NV
     PERFORM NB-B
     PERFORM NB-E
     MOVE "is_waxed" TO WS-NM
     MOVE 8 TO WS-NML
     MOVE 0 TO WS-NV
     PERFORM NB-B
     PERFORM LOAD-BUFFER
     MOVE 1 TO BE-XI(WS-IDX, 3)
     MOVE "0123456789abcdef" TO BE-XT(WS-IDX, 17)
     MOVE SPACES TO WS-LINE-TEXT(1)
     MOVE "LLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLL" TO WS-LINE-TEXT(1)
     MOVE 70 TO WS-LINE-LEN(1)
     MOVE SPACES TO WS-LINE-TEXT(2)
     MOVE "b" TO WS-LINE-TEXT(2)
     MOVE 1 TO WS-LINE-LEN(2)
     MOVE SPACES TO WS-LINE-TEXT(3)
     MOVE SPACES TO WS-LINE-TEXT(3)
     MOVE 0 TO WS-LINE-LEN(3)
     MOVE SPACES TO WS-LINE-TEXT(4)
     MOVE SPACES TO WS-LINE-TEXT(4)
     MOVE 0 TO WS-LINE-LEN(4)
     MOVE 0 TO WS-A
     CALL "BE3-SIGN-UPDATE" USING WS-IDX WS-A WS-U16 WS-LINES WS-B
     MOVE 2 TO WS-FORM
     MOVE WS-B TO WS-SHOW
     PERFORM ADD-N
     PERFORM SAVE-RENDER
     MOVE "1 {front_text:{messages:[Hi,,,],color:black,has_glowing_text:0},back_text:{messages:[LLLLLLLLLLLLLLL" &
         "LLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLL,b,,],color:black,has_glowing_text:0},is_waxed:0}" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "acceptance US12 31-3§2 Signs and hanging signs: long and extra data (2.2): a loaded line is kept to 64 bytes; an unknown key in a text compound is skipped" TO TL-CASE
     PERFORM BEGIN-CASE
     MOVE "minecraft:oak_sign" TO WS-KEY
     MOVE 18 TO WS-SVL
     MOVE 7 TO WS-NV
     MOVE 5 TO WS-X
     MOVE 70 TO WS-Y
     MOVE 5 TO WS-Z
     CALL "BE-CREATE" USING WS-D WS-X WS-Y WS-Z WS-NV WS-KEY WS-SVL WS-IDX
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     MOVE "front_text" TO WS-NM
     MOVE 10 TO WS-NML
     PERFORM NB-C
     MOVE "messages" TO WS-NM
     MOVE 8 TO WS-NML
     MOVE 8 TO WS-LT
     MOVE 4 TO WS-LC
     PERFORM NB-L
     MOVE SPACES TO WS-NM
     MOVE -1 TO WS-NML
     MOVE "MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM" TO WS-SV
     MOVE 70 TO WS-SVL
     PERFORM NB-S
     MOVE SPACES TO WS-NM
     MOVE -1 TO WS-NML
     MOVE SPACES TO WS-SV
     MOVE 0 TO WS-SVL
     PERFORM NB-S
     MOVE SPACES TO WS-NM
     MOVE -1 TO WS-NML
     MOVE SPACES TO WS-SV
     MOVE 0 TO WS-SVL
     PERFORM NB-S
     MOVE SPACES TO WS-NM
     MOVE -1 TO WS-NML
     MOVE SPACES TO WS-SV
     MOVE 0 TO WS-SVL
     PERFORM NB-S
     MOVE "extra" TO WS-NM
     MOVE 5 TO WS-NML
     MOVE 3 TO WS-NV
     PERFORM NB-I
     PERFORM NB-E
     PERFORM LOAD-BUFFER
     MOVE 2 TO WS-FORM
     PERFORM SAVE-RENDER
     MOVE "{front_text:{messages:[MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM,,,],color:bl" &
         "ack,has_glowing_text:0},back_text:{messages:[,,,],color:black,has_glowing_text:0},is_waxed:0}" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "acceptance US12 31-3§2 Signs and hanging signs: lists of other element types (2.2): a messages list of 2 compounds (components) fails the text; a list of lists too; an unknown key of the sign is skipped" TO TL-CASE
     PERFORM BEGIN-CASE
     MOVE "minecraft:oak_sign" TO WS-KEY
     MOVE 18 TO WS-SVL
     MOVE 7 TO WS-NV
     MOVE 5 TO WS-X
     MOVE 70 TO WS-Y
     MOVE 5 TO WS-Z
     CALL "BE-CREATE" USING WS-D WS-X WS-Y WS-Z WS-NV WS-KEY WS-SVL WS-IDX
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     MOVE "front_text" TO WS-NM
     MOVE 10 TO WS-NML
     PERFORM NB-C
     MOVE "messages" TO WS-NM
     MOVE 8 TO WS-NML
     MOVE 10 TO WS-LT
     MOVE 2 TO WS-LC
     PERFORM NB-L
     PERFORM NB-E
     PERFORM NB-E
     PERFORM NB-E
     PERFORM LOAD-BUFFER
     MOVE 2 TO WS-FORM
     PERFORM SAVE-RENDER
     MOVE "minecraft:oak_sign" TO WS-KEY
     MOVE 18 TO WS-SVL
     MOVE 7 TO WS-NV
     MOVE 5 TO WS-X
     MOVE 70 TO WS-Y
     MOVE 5 TO WS-Z
     CALL "BE-CREATE" USING WS-D WS-X WS-Y WS-Z WS-NV WS-KEY WS-SVL WS-IDX
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     MOVE "front_text" TO WS-NM
     MOVE 10 TO WS-NML
     PERFORM NB-C
     MOVE "messages" TO WS-NM
     MOVE 8 TO WS-NML
     MOVE 9 TO WS-LT
     MOVE 2 TO WS-LC
     PERFORM NB-L
     MOVE SPACES TO WS-NM
     MOVE -1 TO WS-NML
     MOVE 8 TO WS-LT
     MOVE 0 TO WS-LC
     PERFORM NB-L
     MOVE SPACES TO WS-NM
     MOVE -1 TO WS-NML
     MOVE 8 TO WS-LT
     MOVE 0 TO WS-LC
     PERFORM NB-L
     PERFORM NB-E
     MOVE "unknown" TO WS-NM
     MOVE 7 TO WS-NML
     MOVE 1 TO WS-NV
     PERFORM NB-I
     PERFORM LOAD-BUFFER
     PERFORM SAVE-RENDER
     MOVE "{front_text:{messages:[,,,],color:black,has_glowing_text:0},back_text:{messages:[,,,],color:black,ha" &
         "s_glowing_text:0},is_waxed:0} {front_text:{messages:[,,,],color:black,has_glowing_text:0},back_text:" &
         "{messages:[,,,],color:black,has_glowing_text:0},is_waxed:0}" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "acceptance US12 31-3§2 Signs and hanging signs: editor lock tick (2.9): the lock is cleared when the editor is not in the level or not within distance 4.0 of the sign; kept while both hold" TO TL-CASE
     PERFORM BEGIN-CASE
     MOVE "minecraft:oak_sign" TO WS-KEY
     MOVE 18 TO WS-SVL
     MOVE 7 TO WS-NV
     MOVE 5 TO WS-X
     MOVE 70 TO WS-Y
     MOVE 5 TO WS-Z
     CALL "BE-CREATE" USING WS-D WS-X WS-Y WS-Z WS-NV WS-KEY WS-SVL WS-IDX
     MOVE 1 TO BE-XI(WS-IDX, 3)
     MOVE 1 TO WS-A
     MOVE 1 TO WS-B
     CALL "BE3-SIGN-TICK" USING WS-IDX WS-A WS-B
     MOVE BE-XI(WS-IDX, 3) TO WS-SHOW
     PERFORM ADD-N
     MOVE "minecraft:oak_sign" TO WS-KEY
     MOVE 18 TO WS-SVL
     MOVE 7 TO WS-NV
     MOVE 5 TO WS-X
     MOVE 70 TO WS-Y
     MOVE 5 TO WS-Z
     CALL "BE-CREATE" USING WS-D WS-X WS-Y WS-Z WS-NV WS-KEY WS-SVL WS-IDX
     MOVE 1 TO BE-XI(WS-IDX, 3)
     MOVE 0 TO WS-A
     MOVE 1 TO WS-B
     CALL "BE3-SIGN-TICK" USING WS-IDX WS-A WS-B
     MOVE BE-XI(WS-IDX, 3) TO WS-SHOW
     PERFORM ADD-N
     MOVE "minecraft:oak_sign" TO WS-KEY
     MOVE 18 TO WS-SVL
     MOVE 7 TO WS-NV
     MOVE 5 TO WS-X
     MOVE 70 TO WS-Y
     MOVE 5 TO WS-Z
     CALL "BE-CREATE" USING WS-D WS-X WS-Y WS-Z WS-NV WS-KEY WS-SVL WS-IDX
     MOVE 1 TO BE-XI(WS-IDX, 3)
     MOVE 1 TO WS-A
     MOVE 0 TO WS-B
     CALL "BE3-SIGN-TICK" USING WS-IDX WS-A WS-B
     MOVE BE-XI(WS-IDX, 3) TO WS-SHOW
     PERFORM ADD-N
     MOVE "minecraft:oak_sign" TO WS-KEY
     MOVE 18 TO WS-SVL
     MOVE 7 TO WS-NV
     MOVE 5 TO WS-X
     MOVE 70 TO WS-Y
     MOVE 5 TO WS-Z
     CALL "BE-CREATE" USING WS-D WS-X WS-Y WS-Z WS-NV WS-KEY WS-SVL WS-IDX
     MOVE 1 TO BE-XI(WS-IDX, 3)
     MOVE 0 TO WS-A
     MOVE 0 TO WS-B
     CALL "BE3-SIGN-TICK" USING WS-IDX WS-A WS-B
     MOVE BE-XI(WS-IDX, 3) TO WS-SHOW
     PERFORM ADD-N
     MOVE "minecraft:oak_sign" TO WS-KEY
     MOVE 18 TO WS-SVL
     MOVE 7 TO WS-NV
     MOVE 5 TO WS-X
     MOVE 70 TO WS-Y
     MOVE 5 TO WS-Z
     CALL "BE-CREATE" USING WS-D WS-X WS-Y WS-Z WS-NV WS-KEY WS-SVL WS-IDX
     MOVE 0 TO BE-XI(WS-IDX, 3)
     MOVE 1 TO WS-A
     MOVE 1 TO WS-B
     CALL "BE3-SIGN-TICK" USING WS-IDX WS-A WS-B
     MOVE BE-XI(WS-IDX, 3) TO WS-SHOW
     PERFORM ADD-N
     MOVE "1 0 0 0 0" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "acceptance US12 31-3§2 Signs and hanging signs: line offset (2.11): y = i * lineHeight - (4 * lineHeight) / 2 for standing (10) and hanging (9) signs" TO TL-CASE
     PERFORM BEGIN-CASE
     MOVE 0 TO WS-A
     MOVE 10 TO WS-B
     CALL "BE3-SIGN-LINE-Y" USING WS-A WS-B WS-C
     MOVE WS-C TO WS-SHOW
     PERFORM ADD-N
     MOVE 1 TO WS-A
     MOVE 10 TO WS-B
     CALL "BE3-SIGN-LINE-Y" USING WS-A WS-B WS-C
     MOVE WS-C TO WS-SHOW
     PERFORM ADD-N
     MOVE 2 TO WS-A
     MOVE 10 TO WS-B
     CALL "BE3-SIGN-LINE-Y" USING WS-A WS-B WS-C
     MOVE WS-C TO WS-SHOW
     PERFORM ADD-N
     MOVE 3 TO WS-A
     MOVE 10 TO WS-B
     CALL "BE3-SIGN-LINE-Y" USING WS-A WS-B WS-C
     MOVE WS-C TO WS-SHOW
     PERFORM ADD-N
     MOVE 0 TO WS-A
     MOVE 9 TO WS-B
     CALL "BE3-SIGN-LINE-Y" USING WS-A WS-B WS-C
     MOVE WS-C TO WS-SHOW
     PERFORM ADD-N
     MOVE 1 TO WS-A
     MOVE 9 TO WS-B
     CALL "BE3-SIGN-LINE-Y" USING WS-A WS-B WS-C
     MOVE WS-C TO WS-SHOW
     PERFORM ADD-N
     MOVE 2 TO WS-A
     MOVE 9 TO WS-B
     CALL "BE3-SIGN-LINE-Y" USING WS-A WS-B WS-C
     MOVE WS-C TO WS-SHOW
     PERFORM ADD-N
     MOVE 3 TO WS-A
     MOVE 9 TO WS-B
     CALL "BE3-SIGN-LINE-Y" USING WS-A WS-B WS-C
     MOVE WS-C TO WS-SHOW
     PERFORM ADD-N
     MOVE "-20 -10 0 10 -18 -9 0 9" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "acceptance US12 31-3§2 Signs and hanging signs: text colours (2.11, 8): the text colour is the dye text colour with alpha 0xFF; the dark outline colour scales each channel by 0.4 (truncated), except black glowing text whose dark" TO TL-CASE
     PERFORM BEGIN-CASE
     MOVE 0 TO WS-A
     MOVE 0 TO WS-B
     CALL "BE3-SIGN-COLORS" USING WS-A WS-B WS-C WS-E
     MOVE WS-C TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-E TO WS-SHOW
     PERFORM ADD-N
     MOVE 14 TO WS-A
     MOVE 0 TO WS-B
     CALL "BE3-SIGN-COLORS" USING WS-A WS-B WS-C WS-E
     MOVE WS-C TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-E TO WS-SHOW
     PERFORM ADD-N
     MOVE 15 TO WS-A
     MOVE 0 TO WS-B
     CALL "BE3-SIGN-COLORS" USING WS-A WS-B WS-C WS-E
     MOVE WS-C TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-E TO WS-SHOW
     PERFORM ADD-N
     MOVE 15 TO WS-A
     MOVE 1 TO WS-B
     CALL "BE3-SIGN-COLORS" USING WS-A WS-B WS-C WS-E
     MOVE WS-C TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-E TO WS-SHOW
     PERFORM ADD-N
     MOVE 1 TO WS-A
     MOVE 1 TO WS-B
     CALL "BE3-SIGN-COLORS" USING WS-A WS-B WS-C WS-E
     MOVE WS-C TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-E TO WS-SHOW
     PERFORM ADD-N
     MOVE 12 TO WS-A
     MOVE 0 TO WS-B
     CALL "BE3-SIGN-COLORS" USING WS-A WS-B WS-C WS-E
     MOVE WS-C TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-E TO WS-SHOW
     PERFORM ADD-N
     MOVE "-1 -10066330 -65536 -10092544 -16777216 -16777216 -16777216 -988212 -38881 -10082036 -7650029 -13165" &
         "817" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "acceptance US12 31-3§2 Signs and hanging signs: glowing outline (2.11): only glowing text has an outline; it is drawn for a non-black colour or when the outline-visible flag holds (scoping first person, else squared camera" TO TL-CASE
     PERFORM BEGIN-CASE
     MOVE 15 TO WS-A
     MOVE 1 TO WS-B
     MOVE 0 TO WS-C
     COMPUTE WS-FA = 300.0
     CALL "BE3-SIGN-OUTLINE" USING WS-A WS-B WS-FA WS-C WS-E
     MOVE WS-E TO WS-SHOW
     PERFORM ADD-N
     MOVE 15 TO WS-A
     MOVE 1 TO WS-B
     MOVE 0 TO WS-C
     COMPUTE WS-FA = 255.5
     CALL "BE3-SIGN-OUTLINE" USING WS-A WS-B WS-FA WS-C WS-E
     MOVE WS-E TO WS-SHOW
     PERFORM ADD-N
     MOVE 15 TO WS-A
     MOVE 1 TO WS-B
     MOVE 0 TO WS-C
     COMPUTE WS-FA = 256.0
     CALL "BE3-SIGN-OUTLINE" USING WS-A WS-B WS-FA WS-C WS-E
     MOVE WS-E TO WS-SHOW
     PERFORM ADD-N
     MOVE 15 TO WS-A
     MOVE 1 TO WS-B
     MOVE 1 TO WS-C
     COMPUTE WS-FA = 1000.0
     CALL "BE3-SIGN-OUTLINE" USING WS-A WS-B WS-FA WS-C WS-E
     MOVE WS-E TO WS-SHOW
     PERFORM ADD-N
     MOVE 14 TO WS-A
     MOVE 1 TO WS-B
     MOVE 0 TO WS-C
     COMPUTE WS-FA = 9999.0
     CALL "BE3-SIGN-OUTLINE" USING WS-A WS-B WS-FA WS-C WS-E
     MOVE WS-E TO WS-SHOW
     PERFORM ADD-N
     MOVE 14 TO WS-A
     MOVE 0 TO WS-B
     MOVE 0 TO WS-C
     COMPUTE WS-FA = 1.0
     CALL "BE3-SIGN-OUTLINE" USING WS-A WS-B WS-FA WS-C WS-E
     MOVE WS-E TO WS-SHOW
     PERFORM ADD-N
     MOVE 15 TO WS-A
     MOVE 0 TO WS-B
     MOVE 0 TO WS-C
     COMPUTE WS-FA = 1.0
     CALL "BE3-SIGN-OUTLINE" USING WS-A WS-B WS-FA WS-C WS-E
     MOVE WS-E TO WS-SHOW
     PERFORM ADD-N
     MOVE "0 1 0 1 1 0 0" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     STOP RUN.

 BEGIN-CASE.
     MOVE SPACES TO TL-OBSERVED
     MOVE 1 TO WS-PTR
     .

 ADD-N.
     STRING FUNCTION TRIM(WS-SHOW) " " DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-PTR
     .

*> Saves entity WS-IDX in form WS-FORM, renders the compound and appends it to TL-OBSERVED.
 SAVE-RENDER.
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "BE-SAVE" USING WS-IDX WS-FORM PB-BUFFER
     CALL "NBT-WRITE-COMPOUND-END" USING PB-BUFFER
     MOVE 0 TO PB-POS
     MOVE 0 TO WS-LEN
     MOVE SPACES TO WS-OUT
     CALL "TEST-NBT-RENDER" USING PB-BUFFER WS-T10 WS-OUT WS-LEN
     CALL "PB-FREE" USING PB-BUFFER
     STRING WS-OUT(1:WS-LEN) " " DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-PTR
     .

*> The NBT builders of the cases (name WS-NM and length WS-NML, text WS-SV and length WS-SVL, number WS-NV, list type WS-LT and count WS-LC).
 NB-S.
     CALL "NBT-WRITE-STRING" USING PB-BUFFER WS-NM WS-NML WS-SV WS-SVL
     .
 NB-I.
     CALL "NBT-WRITE-INT" USING PB-BUFFER WS-NM WS-NML WS-NV
     .
 NB-LONG.
     CALL "NBT-WRITE-LONG" USING PB-BUFFER WS-NM WS-NML WS-LV
     .
 NB-B.
     CALL "NBT-WRITE-BYTE" USING PB-BUFFER WS-NM WS-NML WS-NV
     .
 NB-C.
     CALL "NBT-WRITE-COMPOUND-BEGIN" USING PB-BUFFER WS-NM WS-NML
     .
 NB-E.
     CALL "NBT-WRITE-COMPOUND-END" USING PB-BUFFER
     .
 NB-STACK.
     MOVE 0 TO WS-KP
     CALL "PNBT-STACK-WRITE" USING PB-BUFFER WS-ITEM WS-NV WS-KP
     .
 NB-L.
     CALL "NBT-WRITE-LIST-BEGIN" USING PB-BUFFER WS-NM WS-NML WS-LT WS-LC
     .

*> Loads entity WS-IDX from the compound the case built in PB-BUFFER (the closing End tag is written here).
 LOAD-BUFFER.
     CALL "NBT-WRITE-COMPOUND-END" USING PB-BUFFER
     MOVE 0 TO PB-POS
     CALL "BE-LOAD" USING WS-IDX PB-BUFFER
     CALL "PB-FREE" USING PB-BUFFER
     .
 END PROGRAM TEST-BE-31-3-2.

 COPY CORETEST.
