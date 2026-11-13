*> Test of 31-3 section 1, Types and owning blocks (core/src/be-31-3.cob; T0889): the six types, the sizes of sign text, the valid blocks of the skull type, the update tags and that the pot and the shelf have slots.
*> Each case runs its statements and shows the items joined by single spaces ("n" integers, "f" floats x 1e6, "t" text up to a stored length).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-BE-31-3-1.
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
     MOVE "acceptance US12 31-3§1 Types and owning blocks: registration (1): text width and line height (sign 90 and 10, hanging sign 60 and 9), the sign ticker (2.9), no ticker for banner, skull, pot and shelf on the server, pot one slot," TO TL-CASE
     PERFORM BEGIN-CASE
     MOVE 7 TO WS-NV
     CALL "BE3-REGISTRATION" USING WS-NV WS-A WS-B WS-C WS-E
     MOVE WS-A TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-B TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-C TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-E TO WS-SHOW
     PERFORM ADD-N
     MOVE 8 TO WS-NV
     CALL "BE3-REGISTRATION" USING WS-NV WS-A WS-B WS-C WS-E
     MOVE WS-A TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-B TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-C TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-E TO WS-SHOW
     PERFORM ADD-N
     MOVE 20 TO WS-NV
     CALL "BE3-REGISTRATION" USING WS-NV WS-A WS-B WS-C WS-E
     MOVE WS-A TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-B TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-C TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-E TO WS-SHOW
     PERFORM ADD-N
     MOVE 16 TO WS-NV
     CALL "BE3-REGISTRATION" USING WS-NV WS-A WS-B WS-C WS-E
     MOVE WS-A TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-B TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-C TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-E TO WS-SHOW
     PERFORM ADD-N
     MOVE 41 TO WS-NV
     CALL "BE3-REGISTRATION" USING WS-NV WS-A WS-B WS-C WS-E
     MOVE WS-A TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-B TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-C TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-E TO WS-SHOW
     PERFORM ADD-N
     MOVE 39 TO WS-NV
     CALL "BE3-REGISTRATION" USING WS-NV WS-A WS-B WS-C WS-E
     MOVE WS-A TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-B TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-C TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-E TO WS-SHOW
     PERFORM ADD-N
     MOVE "90 10 1 0 60 9 1 0 0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 3" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "acceptance US12 31-3§1 Types and owning blocks: type keys by registry id (1): sign 7, hanging_sign 8, banner 20, skull 16, decorated_pot 41, shelf 39" TO TL-CASE
     PERFORM BEGIN-CASE
     MOVE 7 TO WS-NV
     CALL "BE-TYPE-INFO" USING WS-NV WS-N24 WS-LEN WS-A
     STRING WS-N24(1:WS-LEN) " " DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-PTR
     MOVE 8 TO WS-NV
     CALL "BE-TYPE-INFO" USING WS-NV WS-N24 WS-LEN WS-A
     STRING WS-N24(1:WS-LEN) " " DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-PTR
     MOVE 20 TO WS-NV
     CALL "BE-TYPE-INFO" USING WS-NV WS-N24 WS-LEN WS-A
     STRING WS-N24(1:WS-LEN) " " DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-PTR
     MOVE 16 TO WS-NV
     CALL "BE-TYPE-INFO" USING WS-NV WS-N24 WS-LEN WS-A
     STRING WS-N24(1:WS-LEN) " " DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-PTR
     MOVE 41 TO WS-NV
     CALL "BE-TYPE-INFO" USING WS-NV WS-N24 WS-LEN WS-A
     STRING WS-N24(1:WS-LEN) " " DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-PTR
     MOVE 39 TO WS-NV
     CALL "BE-TYPE-INFO" USING WS-NV WS-N24 WS-LEN WS-A
     STRING WS-N24(1:WS-LEN) " " DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-PTR
     MOVE "sign hanging_sign banner skull decorated_pot shelf" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "acceptance US12 31-3§1 Types and owning blocks: skull valid blocks (1): the 14 listed head and skull blocks, floor and wall, are valid for the skull type; zombie_skull and creeper_skull are not (14 accepted of 16 offered)" TO TL-CASE
     PERFORM BEGIN-CASE
     MOVE 0 TO WS-F
     MOVE "minecraft:skeleton_skull" TO WS-KEY
     MOVE 24 TO WS-SVL
     MOVE 16 TO WS-NV
     CALL "BE-VALID-BLOCK" USING WS-NV WS-KEY WS-SVL WS-A
     ADD WS-A TO WS-F
     MOVE "minecraft:skeleton_wall_skull" TO WS-KEY
     MOVE 29 TO WS-SVL
     MOVE 16 TO WS-NV
     CALL "BE-VALID-BLOCK" USING WS-NV WS-KEY WS-SVL WS-A
     ADD WS-A TO WS-F
     MOVE "minecraft:creeper_head" TO WS-KEY
     MOVE 22 TO WS-SVL
     MOVE 16 TO WS-NV
     CALL "BE-VALID-BLOCK" USING WS-NV WS-KEY WS-SVL WS-A
     ADD WS-A TO WS-F
     MOVE "minecraft:creeper_wall_head" TO WS-KEY
     MOVE 27 TO WS-SVL
     MOVE 16 TO WS-NV
     CALL "BE-VALID-BLOCK" USING WS-NV WS-KEY WS-SVL WS-A
     ADD WS-A TO WS-F
     MOVE "minecraft:dragon_head" TO WS-KEY
     MOVE 21 TO WS-SVL
     MOVE 16 TO WS-NV
     CALL "BE-VALID-BLOCK" USING WS-NV WS-KEY WS-SVL WS-A
     ADD WS-A TO WS-F
     MOVE "minecraft:dragon_wall_head" TO WS-KEY
     MOVE 26 TO WS-SVL
     MOVE 16 TO WS-NV
     CALL "BE-VALID-BLOCK" USING WS-NV WS-KEY WS-SVL WS-A
     ADD WS-A TO WS-F
     MOVE "minecraft:zombie_head" TO WS-KEY
     MOVE 21 TO WS-SVL
     MOVE 16 TO WS-NV
     CALL "BE-VALID-BLOCK" USING WS-NV WS-KEY WS-SVL WS-A
     ADD WS-A TO WS-F
     MOVE "minecraft:zombie_wall_head" TO WS-KEY
     MOVE 26 TO WS-SVL
     MOVE 16 TO WS-NV
     CALL "BE-VALID-BLOCK" USING WS-NV WS-KEY WS-SVL WS-A
     ADD WS-A TO WS-F
     MOVE "minecraft:wither_skeleton_skull" TO WS-KEY
     MOVE 31 TO WS-SVL
     MOVE 16 TO WS-NV
     CALL "BE-VALID-BLOCK" USING WS-NV WS-KEY WS-SVL WS-A
     ADD WS-A TO WS-F
     MOVE "minecraft:wither_skeleton_wall_skull" TO WS-KEY
     MOVE 36 TO WS-SVL
     MOVE 16 TO WS-NV
     CALL "BE-VALID-BLOCK" USING WS-NV WS-KEY WS-SVL WS-A
     ADD WS-A TO WS-F
     MOVE "minecraft:player_head" TO WS-KEY
     MOVE 21 TO WS-SVL
     MOVE 16 TO WS-NV
     CALL "BE-VALID-BLOCK" USING WS-NV WS-KEY WS-SVL WS-A
     ADD WS-A TO WS-F
     MOVE "minecraft:player_wall_head" TO WS-KEY
     MOVE 26 TO WS-SVL
     MOVE 16 TO WS-NV
     CALL "BE-VALID-BLOCK" USING WS-NV WS-KEY WS-SVL WS-A
     ADD WS-A TO WS-F
     MOVE "minecraft:piglin_head" TO WS-KEY
     MOVE 21 TO WS-SVL
     MOVE 16 TO WS-NV
     CALL "BE-VALID-BLOCK" USING WS-NV WS-KEY WS-SVL WS-A
     ADD WS-A TO WS-F
     MOVE "minecraft:piglin_wall_head" TO WS-KEY
     MOVE 26 TO WS-SVL
     MOVE 16 TO WS-NV
     CALL "BE-VALID-BLOCK" USING WS-NV WS-KEY WS-SVL WS-A
     ADD WS-A TO WS-F
     MOVE "minecraft:zombie_skull" TO WS-KEY
     MOVE 22 TO WS-SVL
     MOVE 16 TO WS-NV
     CALL "BE-VALID-BLOCK" USING WS-NV WS-KEY WS-SVL WS-A
     ADD WS-A TO WS-F
     MOVE "minecraft:creeper_skull" TO WS-KEY
     MOVE 23 TO WS-SVL
     MOVE 16 TO WS-NV
     CALL "BE-VALID-BLOCK" USING WS-NV WS-KEY WS-SVL WS-A
     ADD WS-A TO WS-F
     MOVE WS-F TO WS-SHOW
     PERFORM ADD-N
     MOVE "14" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "acceptance US12 31-3§1 Types and owning blocks: update tags and packets (1, 2.10, 3.3, 4.3, 5.6, 6.2): sign, hanging sign, skull and pot send the custom-only tag (kind 1), the banner the tag without metadata (2), the shelf its" TO TL-CASE
     PERFORM BEGIN-CASE
     MOVE 7 TO WS-NV
     CALL "BE-SYNC-INFO" USING WS-NV WS-A WS-B
     MOVE WS-A TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-B TO WS-SHOW
     PERFORM ADD-N
     MOVE 8 TO WS-NV
     CALL "BE-SYNC-INFO" USING WS-NV WS-A WS-B
     MOVE WS-A TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-B TO WS-SHOW
     PERFORM ADD-N
     MOVE 20 TO WS-NV
     CALL "BE-SYNC-INFO" USING WS-NV WS-A WS-B
     MOVE WS-A TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-B TO WS-SHOW
     PERFORM ADD-N
     MOVE 16 TO WS-NV
     CALL "BE-SYNC-INFO" USING WS-NV WS-A WS-B
     MOVE WS-A TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-B TO WS-SHOW
     PERFORM ADD-N
     MOVE 41 TO WS-NV
     CALL "BE-SYNC-INFO" USING WS-NV WS-A WS-B
     MOVE WS-A TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-B TO WS-SHOW
     PERFORM ADD-N
     MOVE 39 TO WS-NV
     CALL "BE-SYNC-INFO" USING WS-NV WS-A WS-B
     MOVE WS-A TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-B TO WS-SHOW
     PERFORM ADD-N
     MOVE "1 1 1 1 2 1 1 1 1 1 6 1" TO TL-EXPECTED
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
 END PROGRAM TEST-BE-31-3-1.

 COPY CORETEST.
