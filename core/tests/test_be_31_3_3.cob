*> Test of 31-3 section 3, Banners (core/src/be-31-3.cob; T0893): the layer list, its codecs and defaults, the pattern registry and tags, the limits and the update tag.
*> Each case runs its statements and shows the items joined by single spaces ("n" integers, "f" floats x 1e6, "t" text up to a stored length).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-BE-31-3-3.
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
     MOVE "acceptance US12 31-3§3 Banners: state (3.1): a new banner has no layers and no name, so the saved form (3.2) is empty (patterns only when not EMPTY, CustomName only when present)" TO TL-CASE
     PERFORM BEGIN-CASE
     MOVE "minecraft:blue_banner" TO WS-KEY
     MOVE 21 TO WS-SVL
     MOVE 20 TO WS-NV
     MOVE 5 TO WS-X
     MOVE 70 TO WS-Y
     MOVE 5 TO WS-Z
     CALL "BE-CREATE" USING WS-D WS-X WS-Y WS-Z WS-NV WS-KEY WS-SVL WS-IDX
     MOVE 2 TO WS-FORM
     PERFORM SAVE-RENDER
     MOVE "{}" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "acceptance US12 31-3§3 Banners: NBT (3.2, worked example 6): two layers and CustomName load and save back in that order; the update tag form (no id, x, y, z) adds components (3.3)" TO TL-CASE
     PERFORM BEGIN-CASE
     MOVE "minecraft:blue_banner" TO WS-KEY
     MOVE 21 TO WS-SVL
     MOVE 20 TO WS-NV
     MOVE 5 TO WS-X
     MOVE 70 TO WS-Y
     MOVE 5 TO WS-Z
     CALL "BE-CREATE" USING WS-D WS-X WS-Y WS-Z WS-NV WS-KEY WS-SVL WS-IDX
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     MOVE "patterns" TO WS-NM
     MOVE 8 TO WS-NML
     MOVE 10 TO WS-LT
     MOVE 2 TO WS-LC
     PERFORM NB-L
     MOVE "pattern" TO WS-NM
     MOVE 7 TO WS-NML
     MOVE "minecraft:stripe_bottom" TO WS-SV
     MOVE 23 TO WS-SVL
     PERFORM NB-S
     MOVE "color" TO WS-NM
     MOVE 5 TO WS-NML
     MOVE "red" TO WS-SV
     MOVE 3 TO WS-SVL
     PERFORM NB-S
     PERFORM NB-E
     MOVE "pattern" TO WS-NM
     MOVE 7 TO WS-NML
     MOVE "minecraft:border" TO WS-SV
     MOVE 16 TO WS-SVL
     PERFORM NB-S
     MOVE "color" TO WS-NM
     MOVE 5 TO WS-NML
     MOVE "white" TO WS-SV
     MOVE 5 TO WS-SVL
     PERFORM NB-S
     PERFORM NB-E
     MOVE "CustomName" TO WS-NM
     MOVE 10 TO WS-NML
     MOVE "Flag" TO WS-SV
     MOVE 4 TO WS-SVL
     PERFORM NB-S
     PERFORM LOAD-BUFFER
     MOVE 0 TO WS-FORM
     PERFORM SAVE-RENDER
     MOVE "{patterns:[{pattern:minecraft:stripe_bottom,color:red},{pattern:minecraft:border,color:white}],Custo" &
         "mName:Flag,components:{}}" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "acceptance US12 31-3§3 Banners: decode failures (3.2): an unknown pattern id fails the whole list, as does a layer without colour, so patterns load as EMPTY (not written); an empty list is EMPTY too" TO TL-CASE
     PERFORM BEGIN-CASE
     MOVE "minecraft:blue_banner" TO WS-KEY
     MOVE 21 TO WS-SVL
     MOVE 20 TO WS-NV
     MOVE 5 TO WS-X
     MOVE 70 TO WS-Y
     MOVE 5 TO WS-Z
     CALL "BE-CREATE" USING WS-D WS-X WS-Y WS-Z WS-NV WS-KEY WS-SVL WS-IDX
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     MOVE "patterns" TO WS-NM
     MOVE 8 TO WS-NML
     MOVE 10 TO WS-LT
     MOVE 2 TO WS-LC
     PERFORM NB-L
     MOVE "pattern" TO WS-NM
     MOVE 7 TO WS-NML
     MOVE "minecraft:stripe_bottom" TO WS-SV
     MOVE 23 TO WS-SVL
     PERFORM NB-S
     MOVE "color" TO WS-NM
     MOVE 5 TO WS-NML
     MOVE "red" TO WS-SV
     MOVE 3 TO WS-SVL
     PERFORM NB-S
     PERFORM NB-E
     MOVE "pattern" TO WS-NM
     MOVE 7 TO WS-NML
     MOVE "minecraft:nope" TO WS-SV
     MOVE 14 TO WS-SVL
     PERFORM NB-S
     MOVE "color" TO WS-NM
     MOVE 5 TO WS-NML
     MOVE "white" TO WS-SV
     MOVE 5 TO WS-SVL
     PERFORM NB-S
     PERFORM NB-E
     PERFORM LOAD-BUFFER
     MOVE 2 TO WS-FORM
     PERFORM SAVE-RENDER
     MOVE "minecraft:blue_banner" TO WS-KEY
     MOVE 21 TO WS-SVL
     MOVE 20 TO WS-NV
     MOVE 5 TO WS-X
     MOVE 70 TO WS-Y
     MOVE 5 TO WS-Z
     CALL "BE-CREATE" USING WS-D WS-X WS-Y WS-Z WS-NV WS-KEY WS-SVL WS-IDX
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     MOVE "patterns" TO WS-NM
     MOVE 8 TO WS-NML
     MOVE 10 TO WS-LT
     MOVE 1 TO WS-LC
     PERFORM NB-L
     MOVE "pattern" TO WS-NM
     MOVE 7 TO WS-NML
     MOVE "minecraft:stripe_bottom" TO WS-SV
     MOVE 23 TO WS-SVL
     PERFORM NB-S
     PERFORM NB-E
     PERFORM LOAD-BUFFER
     PERFORM SAVE-RENDER
     MOVE "minecraft:blue_banner" TO WS-KEY
     MOVE 21 TO WS-SVL
     MOVE 20 TO WS-NV
     MOVE 5 TO WS-X
     MOVE 70 TO WS-Y
     MOVE 5 TO WS-Z
     CALL "BE-CREATE" USING WS-D WS-X WS-Y WS-Z WS-NV WS-KEY WS-SVL WS-IDX
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     MOVE "patterns" TO WS-NM
     MOVE 8 TO WS-NML
     MOVE 10 TO WS-LT
     MOVE 0 TO WS-LC
     PERFORM NB-L
     PERFORM LOAD-BUFFER
     PERFORM SAVE-RENDER
     MOVE "{} {} {}" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "acceptance US12 31-3§3 Banners: layer details (3.2): a patterns list of strings fails the whole list; an identifier without namespace is minecraft: (stripe_bottom); an unknown key of a layer is skipped" TO TL-CASE
     PERFORM BEGIN-CASE
     MOVE "minecraft:blue_banner" TO WS-KEY
     MOVE 21 TO WS-SVL
     MOVE 20 TO WS-NV
     MOVE 5 TO WS-X
     MOVE 70 TO WS-Y
     MOVE 5 TO WS-Z
     CALL "BE-CREATE" USING WS-D WS-X WS-Y WS-Z WS-NV WS-KEY WS-SVL WS-IDX
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     MOVE "patterns" TO WS-NM
     MOVE 8 TO WS-NML
     MOVE 8 TO WS-LT
     MOVE 1 TO WS-LC
     PERFORM NB-L
     MOVE SPACES TO WS-NM
     MOVE -1 TO WS-NML
     MOVE "x" TO WS-SV
     MOVE 1 TO WS-SVL
     PERFORM NB-S
     PERFORM LOAD-BUFFER
     MOVE 2 TO WS-FORM
     PERFORM SAVE-RENDER
     MOVE "minecraft:blue_banner" TO WS-KEY
     MOVE 21 TO WS-SVL
     MOVE 20 TO WS-NV
     MOVE 5 TO WS-X
     MOVE 70 TO WS-Y
     MOVE 5 TO WS-Z
     CALL "BE-CREATE" USING WS-D WS-X WS-Y WS-Z WS-NV WS-KEY WS-SVL WS-IDX
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     MOVE "patterns" TO WS-NM
     MOVE 8 TO WS-NML
     MOVE 10 TO WS-LT
     MOVE 1 TO WS-LC
     PERFORM NB-L
     MOVE "pattern" TO WS-NM
     MOVE 7 TO WS-NML
     MOVE "stripe_bottom" TO WS-SV
     MOVE 13 TO WS-SVL
     PERFORM NB-S
     MOVE "color" TO WS-NM
     MOVE 5 TO WS-NML
     MOVE "red" TO WS-SV
     MOVE 3 TO WS-SVL
     PERFORM NB-S
     MOVE "extra" TO WS-NM
     MOVE 5 TO WS-NML
     MOVE 1 TO WS-NV
     PERFORM NB-I
     PERFORM NB-E
     PERFORM LOAD-BUFFER
     PERFORM SAVE-RENDER
     MOVE "{} {patterns:[{pattern:minecraft:stripe_bottom,color:red}]}" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "acceptance US12 31-3§3 Banners: decode failure (3.2): a layer whose colour is not a dye name fails the whole list, so patterns load as EMPTY" TO TL-CASE
     PERFORM BEGIN-CASE
     MOVE "minecraft:blue_banner" TO WS-KEY
     MOVE 21 TO WS-SVL
     MOVE 20 TO WS-NV
     MOVE 5 TO WS-X
     MOVE 70 TO WS-Y
     MOVE 5 TO WS-Z
     CALL "BE-CREATE" USING WS-D WS-X WS-Y WS-Z WS-NV WS-KEY WS-SVL WS-IDX
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     MOVE "patterns" TO WS-NM
     MOVE 8 TO WS-NML
     MOVE 10 TO WS-LT
     MOVE 1 TO WS-LC
     PERFORM NB-L
     MOVE "pattern" TO WS-NM
     MOVE 7 TO WS-NML
     MOVE "minecraft:stripe_bottom" TO WS-SV
     MOVE 23 TO WS-SVL
     PERFORM NB-S
     MOVE "color" TO WS-NM
     MOVE 5 TO WS-NML
     MOVE "plaid" TO WS-SV
     MOVE 5 TO WS-SVL
     PERFORM NB-S
     PERFORM NB-E
     PERFORM LOAD-BUFFER
     MOVE 2 TO WS-FORM
     PERFORM SAVE-RENDER
     MOVE "{}" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "acceptance US12 31-3§3 Banners: pattern registry (3.2): the 43 banner_pattern ids in the order of the list (base 0, border 1, stripe_bottom 31, mojang 21, triangles_top 42); an unknown or differently cased id is -1" TO TL-CASE
     PERFORM BEGIN-CASE
     MOVE "base" TO WS-N32
     MOVE 4 TO WS-A
     CALL "BE3-BANNER-PATTERN" USING WS-N32 WS-A WS-B
     MOVE WS-B TO WS-SHOW
     PERFORM ADD-N
     MOVE "border" TO WS-N32
     MOVE 6 TO WS-A
     CALL "BE3-BANNER-PATTERN" USING WS-N32 WS-A WS-B
     MOVE WS-B TO WS-SHOW
     PERFORM ADD-N
     MOVE "stripe_bottom" TO WS-N32
     MOVE 13 TO WS-A
     CALL "BE3-BANNER-PATTERN" USING WS-N32 WS-A WS-B
     MOVE WS-B TO WS-SHOW
     PERFORM ADD-N
     MOVE "mojang" TO WS-N32
     MOVE 6 TO WS-A
     CALL "BE3-BANNER-PATTERN" USING WS-N32 WS-A WS-B
     MOVE WS-B TO WS-SHOW
     PERFORM ADD-N
     MOVE "triangles_top" TO WS-N32
     MOVE 13 TO WS-A
     CALL "BE3-BANNER-PATTERN" USING WS-N32 WS-A WS-B
     MOVE WS-B TO WS-SHOW
     PERFORM ADD-N
     MOVE "nope" TO WS-N32
     MOVE 4 TO WS-A
     CALL "BE3-BANNER-PATTERN" USING WS-N32 WS-A WS-B
     MOVE WS-B TO WS-SHOW
     PERFORM ADD-N
     MOVE "Base" TO WS-N32
     MOVE 4 TO WS-A
     CALL "BE3-BANNER-PATTERN" USING WS-N32 WS-A WS-B
     MOVE WS-B TO WS-SHOW
     PERFORM ADD-N
     MOVE " " TO WS-N32
     MOVE 0 TO WS-A
     CALL "BE3-BANNER-PATTERN" USING WS-N32 WS-A WS-B
     MOVE WS-B TO WS-SHOW
     PERFORM ADD-N
     MOVE "xxxxxxxxxxxxxxxxxxxxxxxxx" TO WS-N32
     MOVE 25 TO WS-A
     CALL "BE3-BANNER-PATTERN" USING WS-N32 WS-A WS-B
     MOVE WS-B TO WS-SHOW
     PERFORM ADD-N
     MOVE "0 1 31 21 42 -1 -1 -1 -1" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "acceptance US12 31-3§3 Banners: pattern tags (3.4): 32 patterns are in no_item_required (1), 10 patterns are the only member of a pattern_item tag (2), base is in none (0); 43 patterns in registry order" TO TL-CASE
     PERFORM BEGIN-CASE
     MOVE 0 TO WS-A
     CALL "BE3-BANNER-TAG" USING WS-A WS-B
     MOVE WS-B TO WS-SHOW
     PERFORM ADD-N
     MOVE 1 TO WS-A
     CALL "BE3-BANNER-TAG" USING WS-A WS-B
     MOVE WS-B TO WS-SHOW
     PERFORM ADD-N
     MOVE 2 TO WS-A
     CALL "BE3-BANNER-TAG" USING WS-A WS-B
     MOVE WS-B TO WS-SHOW
     PERFORM ADD-N
     MOVE 3 TO WS-A
     CALL "BE3-BANNER-TAG" USING WS-A WS-B
     MOVE WS-B TO WS-SHOW
     PERFORM ADD-N
     MOVE 4 TO WS-A
     CALL "BE3-BANNER-TAG" USING WS-A WS-B
     MOVE WS-B TO WS-SHOW
     PERFORM ADD-N
     MOVE 5 TO WS-A
     CALL "BE3-BANNER-TAG" USING WS-A WS-B
     MOVE WS-B TO WS-SHOW
     PERFORM ADD-N
     MOVE 6 TO WS-A
     CALL "BE3-BANNER-TAG" USING WS-A WS-B
     MOVE WS-B TO WS-SHOW
     PERFORM ADD-N
     MOVE 7 TO WS-A
     CALL "BE3-BANNER-TAG" USING WS-A WS-B
     MOVE WS-B TO WS-SHOW
     PERFORM ADD-N
     MOVE 8 TO WS-A
     CALL "BE3-BANNER-TAG" USING WS-A WS-B
     MOVE WS-B TO WS-SHOW
     PERFORM ADD-N
     MOVE 9 TO WS-A
     CALL "BE3-BANNER-TAG" USING WS-A WS-B
     MOVE WS-B TO WS-SHOW
     PERFORM ADD-N
     MOVE 10 TO WS-A
     CALL "BE3-BANNER-TAG" USING WS-A WS-B
     MOVE WS-B TO WS-SHOW
     PERFORM ADD-N
     MOVE 11 TO WS-A
     CALL "BE3-BANNER-TAG" USING WS-A WS-B
     MOVE WS-B TO WS-SHOW
     PERFORM ADD-N
     MOVE 12 TO WS-A
     CALL "BE3-BANNER-TAG" USING WS-A WS-B
     MOVE WS-B TO WS-SHOW
     PERFORM ADD-N
     MOVE 13 TO WS-A
     CALL "BE3-BANNER-TAG" USING WS-A WS-B
     MOVE WS-B TO WS-SHOW
     PERFORM ADD-N
     MOVE 14 TO WS-A
     CALL "BE3-BANNER-TAG" USING WS-A WS-B
     MOVE WS-B TO WS-SHOW
     PERFORM ADD-N
     MOVE 15 TO WS-A
     CALL "BE3-BANNER-TAG" USING WS-A WS-B
     MOVE WS-B TO WS-SHOW
     PERFORM ADD-N
     MOVE 16 TO WS-A
     CALL "BE3-BANNER-TAG" USING WS-A WS-B
     MOVE WS-B TO WS-SHOW
     PERFORM ADD-N
     MOVE 17 TO WS-A
     CALL "BE3-BANNER-TAG" USING WS-A WS-B
     MOVE WS-B TO WS-SHOW
     PERFORM ADD-N
     MOVE 18 TO WS-A
     CALL "BE3-BANNER-TAG" USING WS-A WS-B
     MOVE WS-B TO WS-SHOW
     PERFORM ADD-N
     MOVE 19 TO WS-A
     CALL "BE3-BANNER-TAG" USING WS-A WS-B
     MOVE WS-B TO WS-SHOW
     PERFORM ADD-N
     MOVE 20 TO WS-A
     CALL "BE3-BANNER-TAG" USING WS-A WS-B
     MOVE WS-B TO WS-SHOW
     PERFORM ADD-N
     MOVE 21 TO WS-A
     CALL "BE3-BANNER-TAG" USING WS-A WS-B
     MOVE WS-B TO WS-SHOW
     PERFORM ADD-N
     MOVE 22 TO WS-A
     CALL "BE3-BANNER-TAG" USING WS-A WS-B
     MOVE WS-B TO WS-SHOW
     PERFORM ADD-N
     MOVE 23 TO WS-A
     CALL "BE3-BANNER-TAG" USING WS-A WS-B
     MOVE WS-B TO WS-SHOW
     PERFORM ADD-N
     MOVE 24 TO WS-A
     CALL "BE3-BANNER-TAG" USING WS-A WS-B
     MOVE WS-B TO WS-SHOW
     PERFORM ADD-N
     MOVE 25 TO WS-A
     CALL "BE3-BANNER-TAG" USING WS-A WS-B
     MOVE WS-B TO WS-SHOW
     PERFORM ADD-N
     MOVE 26 TO WS-A
     CALL "BE3-BANNER-TAG" USING WS-A WS-B
     MOVE WS-B TO WS-SHOW
     PERFORM ADD-N
     MOVE 27 TO WS-A
     CALL "BE3-BANNER-TAG" USING WS-A WS-B
     MOVE WS-B TO WS-SHOW
     PERFORM ADD-N
     MOVE 28 TO WS-A
     CALL "BE3-BANNER-TAG" USING WS-A WS-B
     MOVE WS-B TO WS-SHOW
     PERFORM ADD-N
     MOVE 29 TO WS-A
     CALL "BE3-BANNER-TAG" USING WS-A WS-B
     MOVE WS-B TO WS-SHOW
     PERFORM ADD-N
     MOVE 30 TO WS-A
     CALL "BE3-BANNER-TAG" USING WS-A WS-B
     MOVE WS-B TO WS-SHOW
     PERFORM ADD-N
     MOVE 31 TO WS-A
     CALL "BE3-BANNER-TAG" USING WS-A WS-B
     MOVE WS-B TO WS-SHOW
     PERFORM ADD-N
     MOVE 32 TO WS-A
     CALL "BE3-BANNER-TAG" USING WS-A WS-B
     MOVE WS-B TO WS-SHOW
     PERFORM ADD-N
     MOVE 33 TO WS-A
     CALL "BE3-BANNER-TAG" USING WS-A WS-B
     MOVE WS-B TO WS-SHOW
     PERFORM ADD-N
     MOVE 34 TO WS-A
     CALL "BE3-BANNER-TAG" USING WS-A WS-B
     MOVE WS-B TO WS-SHOW
     PERFORM ADD-N
     MOVE 35 TO WS-A
     CALL "BE3-BANNER-TAG" USING WS-A WS-B
     MOVE WS-B TO WS-SHOW
     PERFORM ADD-N
     MOVE 36 TO WS-A
     CALL "BE3-BANNER-TAG" USING WS-A WS-B
     MOVE WS-B TO WS-SHOW
     PERFORM ADD-N
     MOVE 37 TO WS-A
     CALL "BE3-BANNER-TAG" USING WS-A WS-B
     MOVE WS-B TO WS-SHOW
     PERFORM ADD-N
     MOVE 38 TO WS-A
     CALL "BE3-BANNER-TAG" USING WS-A WS-B
     MOVE WS-B TO WS-SHOW
     PERFORM ADD-N
     MOVE 39 TO WS-A
     CALL "BE3-BANNER-TAG" USING WS-A WS-B
     MOVE WS-B TO WS-SHOW
     PERFORM ADD-N
     MOVE 40 TO WS-A
     CALL "BE3-BANNER-TAG" USING WS-A WS-B
     MOVE WS-B TO WS-SHOW
     PERFORM ADD-N
     MOVE 41 TO WS-A
     CALL "BE3-BANNER-TAG" USING WS-A WS-B
     MOVE WS-B TO WS-SHOW
     PERFORM ADD-N
     MOVE 42 TO WS-A
     CALL "BE3-BANNER-TAG" USING WS-A WS-B
     MOVE WS-B TO WS-SHOW
     PERFORM ADD-N
     MOVE "0 1 2 1 2 1 2 1 1 1 1 2 2 2 1 1 2 1 1 1 1 2 2 1 2 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "acceptance US12 31-3§3 Banners: limits (3.1): the tooltip shows at most MAX_PATTERNS 6 layers and the renderer draws at most 16; the stored list is not limited by either" TO TL-CASE
     PERFORM BEGIN-CASE
     MOVE 0 TO WS-A
     CALL "BE3-BANNER-LIMITS" USING WS-A WS-B WS-C
     MOVE WS-B TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-C TO WS-SHOW
     PERFORM ADD-N
     MOVE 3 TO WS-A
     CALL "BE3-BANNER-LIMITS" USING WS-A WS-B WS-C
     MOVE WS-B TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-C TO WS-SHOW
     PERFORM ADD-N
     MOVE 6 TO WS-A
     CALL "BE3-BANNER-LIMITS" USING WS-A WS-B WS-C
     MOVE WS-B TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-C TO WS-SHOW
     PERFORM ADD-N
     MOVE 7 TO WS-A
     CALL "BE3-BANNER-LIMITS" USING WS-A WS-B WS-C
     MOVE WS-B TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-C TO WS-SHOW
     PERFORM ADD-N
     MOVE 16 TO WS-A
     CALL "BE3-BANNER-LIMITS" USING WS-A WS-B WS-C
     MOVE WS-B TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-C TO WS-SHOW
     PERFORM ADD-N
     MOVE 17 TO WS-A
     CALL "BE3-BANNER-LIMITS" USING WS-A WS-B WS-C
     MOVE WS-B TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-C TO WS-SHOW
     PERFORM ADD-N
     MOVE 40 TO WS-A
     CALL "BE3-BANNER-LIMITS" USING WS-A WS-B WS-C
     MOVE WS-B TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-C TO WS-SHOW
     PERFORM ADD-N
     MOVE "0 0 3 3 6 6 6 7 6 16 6 16 6 16" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "acceptance US12 31-3§3 Banners: name (3.1): the default display name is block.minecraft.banner; a CustomName replaces it" TO TL-CASE
     PERFORM BEGIN-CASE
     MOVE "minecraft:blue_banner" TO WS-KEY
     MOVE 21 TO WS-SVL
     MOVE 20 TO WS-NV
     MOVE 5 TO WS-X
     MOVE 70 TO WS-Y
     MOVE 5 TO WS-Z
     CALL "BE-CREATE" USING WS-D WS-X WS-Y WS-Z WS-NV WS-KEY WS-SVL WS-IDX
     CALL "BE3-BANNER-NAME" USING WS-IDX WS-N32 WS-LEN
     MOVE WS-LEN TO WS-A
     MOVE WS-N32 TO WS-TX
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     MOVE "patterns" TO WS-NM
     MOVE 8 TO WS-NML
     MOVE 10 TO WS-LT
     MOVE 2 TO WS-LC
     PERFORM NB-L
     MOVE "pattern" TO WS-NM
     MOVE 7 TO WS-NML
     MOVE "minecraft:stripe_bottom" TO WS-SV
     MOVE 23 TO WS-SVL
     PERFORM NB-S
     MOVE "color" TO WS-NM
     MOVE 5 TO WS-NML
     MOVE "red" TO WS-SV
     MOVE 3 TO WS-SVL
     PERFORM NB-S
     PERFORM NB-E
     MOVE "pattern" TO WS-NM
     MOVE 7 TO WS-NML
     MOVE "minecraft:border" TO WS-SV
     MOVE 16 TO WS-SVL
     PERFORM NB-S
     MOVE "color" TO WS-NM
     MOVE 5 TO WS-NML
     MOVE "white" TO WS-SV
     MOVE 5 TO WS-SVL
     PERFORM NB-S
     PERFORM NB-E
     MOVE "CustomName" TO WS-NM
     MOVE 10 TO WS-NML
     MOVE "Flag" TO WS-SV
     MOVE 4 TO WS-SVL
     PERFORM NB-S
     PERFORM LOAD-BUFFER
     CALL "BE3-BANNER-NAME" USING WS-IDX WS-N32 WS-B
     STRING WS-TX(1:WS-A) " " DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-PTR
     STRING WS-N32(1:WS-B) " " DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-PTR
     MOVE "block.minecraft.banner Flag" TO TL-EXPECTED
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
 END PROGRAM TEST-BE-31-3-3.

 COPY CORETEST.
