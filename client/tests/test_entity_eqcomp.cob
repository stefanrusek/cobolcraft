 *> Item components of the equipment (54 sections 17, 18, 19, 22): Set Equipment keeps the dyed colour, the trim holders, the glint decision and, in the hands,
 *> the banner layers and the shield base colour of each slot (ENTITY-EQ-COMPONENTS); an empty stack or a stack without them clears them.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-ENTITY-EQCOMP.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLSTATE.
 COPY CLCONST.
 COPY CONTENT.
 COPY TESTLIB.
 COPY PROTO.
 01 WS-KEY                 PIC X(112).
 01 WS-ROW-AREA            PIC X(66).
 01 WS-STATUS              BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-X                   FLOAT-LONG VALUE 10.5.
 01 WS-Y                   FLOAT-LONG VALUE 64.
 01 WS-Z                   FLOAT-LONG VALUE 10.5.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 01 WS-ID                  BINARY-LONG VALUE 7.
 01 WS-CAPACITY            BINARY-LONG VALUE 4096.
 01 WS-PACKET-ID           BINARY-LONG VALUE 104.
 01 WS-SLOT                BINARY-LONG.
 01 WS-E1                  BINARY-LONG.
 01 WS-E2                  BINARY-LONG.
 01 WS-E3                  BINARY-LONG.
 01 WS-E4                  BINARY-LONG.
 01 WS-LABEL               PIC X(100).
 PROCEDURE DIVISION.
     CALL "CL-INIT" USING CLIENT-STATE
     MOVE "zombie" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE WS-ROW-AREA WS-STATUS
     CALL "MM-SPAWN" USING CLIENT-STATE WS-ID WS-TYPE WS-X WS-Y WS-Z WS-YAW
     MOVE "N" TO TL-MODE
     MOVE "eqcomp a fresh row has no dye, trim or glint" TO WS-LABEL
     PERFORM CHECK-HEAD-NONE
*>   Head (slot 5): dyed_color 0x00FF00, trim holders 3 and 5, glint override true.
     MOVE 3 TO PB-ISX-ADDED-COUNT
     MOVE 47 TO PB-ISX-TYPE(1)
     MOVE 4 TO PB-ISX-VALUE-LENGTH(1)
     MOVE X"0000FF00" TO PB-ISX-VALUE(1)
     MOVE 58 TO PB-ISX-TYPE(2)
     MOVE 2 TO PB-ISX-VALUE-LENGTH(2)
     MOVE X"0305" TO PB-ISX-VALUE(2)
     MOVE 21 TO PB-ISX-TYPE(3)
     MOVE 1 TO PB-ISX-VALUE-LENGTH(3)
     MOVE X"01" TO PB-ISX-VALUE(3)
     MOVE 5 TO WS-SLOT
     PERFORM PUT-EQUIP
     MOVE "eqcomp head keeps the dye, trim holders and the forced glint" TO WS-LABEL
     MOVE 65280 TO WS-E1
     MOVE 3 TO WS-E2
     MOVE 5 TO WS-E3
     MOVE 1 TO WS-E4
     PERFORM CHECK-HEAD
*>   An opaque dye (alpha ff) is masked to 24 bits; glint override false beats enchantments.
     MOVE X"FFA06540" TO PB-ISX-VALUE(1)
     MOVE 21 TO PB-ISX-TYPE(2)
     MOVE 1 TO PB-ISX-VALUE-LENGTH(2)
     MOVE X"00" TO PB-ISX-VALUE(2)
     MOVE 13 TO PB-ISX-TYPE(3)
     MOVE 3 TO PB-ISX-VALUE-LENGTH(3)
     MOVE X"010101" TO PB-ISX-VALUE(3)
     PERFORM PUT-EQUIP
     MOVE "eqcomp an opaque dye is masked and glint false suppresses the enchantments" TO WS-LABEL
     MOVE 10511680 TO WS-E1
     MOVE 0 TO WS-E2 WS-E3 WS-E4
     PERFORM CHECK-HEAD
*>   Enchantments alone give the glint; an inline trim holder reads as 0; the dye component (46) is not a dyed colour.
     MOVE 13 TO PB-ISX-TYPE(1)
     MOVE 3 TO PB-ISX-VALUE-LENGTH(1)
     MOVE X"010101" TO PB-ISX-VALUE(1)
     MOVE 58 TO PB-ISX-TYPE(2)
     MOVE 15 TO PB-ISX-VALUE-LENGTH(2)
     MOVE X"00016108000161000162080001620000" TO PB-ISX-VALUE(2)
     MOVE 46 TO PB-ISX-TYPE(3)
     MOVE 1 TO PB-ISX-VALUE-LENGTH(3)
     MOVE X"05" TO PB-ISX-VALUE(3)
     PERFORM PUT-EQUIP
     MOVE "eqcomp enchantments give the glint, an inline trim and a dye component set nothing else" TO WS-LABEL
     MOVE -1 TO WS-E1
     MOVE 0 TO WS-E2 WS-E3
     MOVE 1 TO WS-E4
     PERFORM CHECK-HEAD
     MOVE 1 TO PB-ISX-ADDED-COUNT
     MOVE 13 TO PB-ISX-TYPE(1)
     MOVE 1 TO PB-ISX-VALUE-LENGTH(1)
     MOVE X"00" TO PB-ISX-VALUE(1)
     PERFORM PUT-EQUIP
     MOVE "eqcomp an empty enchantments component gives no glint" TO WS-LABEL
     PERFORM CHECK-HEAD-NONE
*>   Off hand (slot 1): a shield with base_color 5 and two layers (holder 3 dye 5; inline holder dye 15); main hand stays clear.
     MOVE 2 TO PB-ISX-ADDED-COUNT
     MOVE 75 TO PB-ISX-TYPE(1)
     MOVE 1 TO PB-ISX-VALUE-LENGTH(1)
     MOVE X"05" TO PB-ISX-VALUE(1)
     MOVE 74 TO PB-ISX-TYPE(2)
     MOVE 9 TO PB-ISX-VALUE-LENGTH(2)
     MOVE X"02030500016101620F" TO PB-ISX-VALUE(2)
     MOVE 1 TO WS-SLOT
     PERFORM PUT-EQUIP
     MOVE "eqcomp the off hand keeps the base colour" TO WS-LABEL
     MOVE 5 TO TL-EXPECTED-N
     MOVE EN-HB-BASE(1, 2) TO TL-OBSERVED-N
     PERFORM ASSERT-LABEL
     MOVE "eqcomp the off hand keeps two banner layers" TO WS-LABEL
     MOVE 2 TO TL-EXPECTED-N
     MOVE EN-HB-COUNT(1, 2) TO TL-OBSERVED-N
     PERFORM ASSERT-LABEL
     MOVE "eqcomp layer 1 is holder 3 dye 5, layer 2 an inline holder (0) dye 15" TO WS-LABEL
     COMPUTE TL-EXPECTED-N = 3 * 1000000 + 5 * 10000 + 0 * 100 + 15
     COMPUTE TL-OBSERVED-N = EN-HB-PAT(1, 2, 1) * 1000000 + EN-HB-DYE(1, 2, 1) * 10000 + EN-HB-PAT(1, 2, 2) * 100 + EN-HB-DYE(1, 2, 2)
     PERFORM ASSERT-LABEL
     MOVE "eqcomp the main hand has no base colour" TO WS-LABEL
     MOVE -1 TO TL-EXPECTED-N
     MOVE EN-HB-BASE(1, 1) TO TL-OBSERVED-N
     PERFORM ASSERT-LABEL
*>   An empty stack in the off hand clears them.
     MOVE 0 TO PB-ISX-ADDED-COUNT
     PERFORM PUT-EQUIP
     MOVE "eqcomp an empty stack clears the base colour" TO WS-LABEL
     MOVE -1 TO TL-EXPECTED-N
     MOVE EN-HB-BASE(1, 2) TO TL-OBSERVED-N
     PERFORM ASSERT-LABEL
     MOVE "eqcomp an empty stack clears the layers" TO WS-LABEL
     MOVE 0 TO TL-EXPECTED-N
     MOVE EN-HB-COUNT(1, 2) TO TL-OBSERVED-N
     PERFORM ASSERT-LABEL
*>   40 layers keep 16 (each one byte holder 1, dye 1: the count 18 hex = 24 gives 24 layers).
     MOVE 1 TO PB-ISX-ADDED-COUNT
     MOVE 74 TO PB-ISX-TYPE(1)
     MOVE 49 TO PB-ISX-VALUE-LENGTH(1)
     MOVE ALL X"01" TO PB-ISX-VALUE(1)
     MOVE X"18" TO PB-ISX-VALUE(1)(1:1)
     PERFORM PUT-EQUIP
     MOVE "eqcomp at most 16 banner layers are kept" TO WS-LABEL
     MOVE 16 TO TL-EXPECTED-N
     MOVE EN-HB-COUNT(1, 2) TO TL-OBSERVED-N
     PERFORM ASSERT-LABEL
*>   A two-byte layer count (128 layers) reads as 16 kept layers.
     MOVE 1 TO PB-ISX-ADDED-COUNT
     MOVE 74 TO PB-ISX-TYPE(1)
     MOVE 258 TO PB-ISX-VALUE-LENGTH(1)
     MOVE ALL X"01" TO PB-ISX-VALUE(1)
     MOVE X"80" TO PB-ISX-VALUE(1)(1:1)
     MOVE 0 TO EN-HB-COUNT(1, 2)
     PERFORM PUT-EQUIP
     MOVE "eqcomp a layer count of 128 reads as 16" TO WS-LABEL
     MOVE 16 TO TL-EXPECTED-N
     MOVE EN-HB-COUNT(1, 2) TO TL-OBSERVED-N
     PERFORM ASSERT-LABEL
*>   The banner components of a head item (slot 5) are not kept; a zero-length component (unbreakable 4) and an inline pattern with a registered material.
     MOVE 3 TO PB-ISX-ADDED-COUNT
     MOVE 75 TO PB-ISX-TYPE(1)
     MOVE 1 TO PB-ISX-VALUE-LENGTH(1)
     MOVE X"05" TO PB-ISX-VALUE(1)
     MOVE 74 TO PB-ISX-TYPE(2)
     MOVE 1 TO PB-ISX-VALUE-LENGTH(2)
     MOVE X"00" TO PB-ISX-VALUE(2)
     MOVE 4 TO PB-ISX-TYPE(3)
     MOVE 0 TO PB-ISX-VALUE-LENGTH(3)
     MOVE 5 TO WS-SLOT
     PERFORM PUT-EQUIP
     MOVE "eqcomp the banner components of a head item are not kept" TO WS-LABEL
     MOVE 16 TO TL-EXPECTED-N
     MOVE EN-HB-COUNT(1, 2) TO TL-OBSERVED-N
     PERFORM ASSERT-LABEL
     MOVE 1 TO PB-ISX-ADDED-COUNT
     MOVE 58 TO PB-ISX-TYPE(1)
     MOVE 9 TO PB-ISX-VALUE-LENGTH(1)
     MOVE X"0300016208000162" TO PB-ISX-VALUE(1)
     MOVE X"00" TO PB-ISX-VALUE(1)(9:1)
     PERFORM PUT-EQUIP
     MOVE "eqcomp an inline pattern holder reads as no trim" TO WS-LABEL
     PERFORM CHECK-HEAD-NONE
*>   A stack for an unknown entity changes nothing (and the slot above 7 is ignored).
     MOVE 99 TO WS-ID
     MOVE 0 TO PB-ISX-ADDED-COUNT
     PERFORM PUT-EQUIP
     MOVE "eqcomp a stack for an unknown entity changes nothing" TO WS-LABEL
     MOVE 16 TO TL-EXPECTED-N
     MOVE EN-HB-COUNT(1, 2) TO TL-OBSERVED-N
     PERFORM ASSERT-LABEL
     MOVE 7 TO WS-ID
     MOVE 9 TO WS-SLOT
     PERFORM PUT-EQUIP
     MOVE "eqcomp a slot ordinal above 7 changes nothing" TO WS-LABEL
     MOVE 16 TO TL-EXPECTED-N
     MOVE EN-HB-COUNT(1, 2) TO TL-OBSERVED-N
     PERFORM ASSERT-LABEL
     STOP RUN.

 PUT-EQUIP.
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     MOVE 1 TO PB-ISX-COUNT
     MOVE 5 TO PB-ISX-ITEM
     MOVE 0 TO PB-ISX-REMOVED-COUNT
     IF WS-SLOT = 1 AND PB-ISX-ADDED-COUNT = 0
         MOVE 0 TO PB-ISX-COUNT
     END-IF
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-ID
     CALL "PB-PUT-UBYTE" USING PB-BUFFER WS-SLOT
     CALL "PB-PUT-ITEM-STACK" USING PB-BUFFER PB-ITEMSTACK-X
     MOVE 0 TO PB-POS
     CALL "ENTITY-PACKET" USING CLIENT-STATE PB-BUFFER WS-PACKET-ID.

 ASSERT-LABEL.
     MOVE "N" TO TL-MODE
     MOVE WS-LABEL TO TL-CASE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

 CHECK-HEAD-NONE.
     MOVE -1 TO WS-E1
     MOVE 0 TO WS-E2 WS-E3 WS-E4
     PERFORM CHECK-HEAD.

 CHECK-HEAD.
*>   The four head values packed as one number: dye + 100000000 * (material * 1000000 + pattern * 100 + foil) is avoided; each is its own case.
     MOVE WS-LABEL TO TL-CASE
     STRING FUNCTION TRIM(WS-LABEL) " (dye)" DELIMITED BY SIZE INTO TL-CASE
     MOVE WS-E1 TO TL-EXPECTED-N
     MOVE EN-EQ-DYE(1, 6) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE SPACES TO TL-CASE
     STRING FUNCTION TRIM(WS-LABEL) " (trim)" DELIMITED BY SIZE INTO TL-CASE
     COMPUTE TL-EXPECTED-N = WS-E2 * 1000 + WS-E3
     COMPUTE TL-OBSERVED-N = EN-EQ-TRIM-MAT(1, 6) * 1000 + EN-EQ-TRIM-PAT(1, 6)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE SPACES TO TL-CASE
     STRING FUNCTION TRIM(WS-LABEL) " (foil)" DELIMITED BY SIZE INTO TL-CASE
     MOVE WS-E4 TO TL-EXPECTED-N
     MOVE EN-EQ-FOIL(1, 6) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-ENTITY-EQCOMP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MM-SPAWN.
*> USING CLIENT-STATE, entity id, type (registry id), x y z (FLOAT-LONG), yaw (FLOAT-SHORT, also the head yaw): Add Entity.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY PROTO.
 01 WS-READY               BINARY-LONG VALUE 0.
 01 WS-CAPACITY            BINARY-LONG VALUE 1024.
 01 WS-ADD                 BINARY-LONG VALUE 1.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-UUID                PIC X(16) VALUE LOW-VALUES.
 01 WS-V0                  FLOAT-LONG VALUE 0.
 01 WS-V1                  FLOAT-LONG VALUE 0.
 01 WS-V2                  FLOAT-LONG VALUE 0.
 01 WS-A0                  FLOAT-SHORT VALUE 0.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-ID                   BINARY-LONG.
 01 L-TYPE                 BINARY-LONG.
 01 L-X                    FLOAT-LONG.
 01 L-Y                    FLOAT-LONG.
 01 L-Z                    FLOAT-LONG.
 01 L-YAW                  FLOAT-SHORT.
 PROCEDURE DIVISION USING CLIENT-STATE L-ID L-TYPE L-X L-Y L-Z L-YAW.
     IF WS-READY = 0
         CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
         MOVE 1 TO WS-READY
     END-IF
     CALL "PB-RESET" USING PB-BUFFER
     CALL "PB-PUT-VARINT" USING PB-BUFFER L-ID
     CALL "PB-PUT-UUID" USING PB-BUFFER WS-UUID
     CALL "PB-PUT-VARINT" USING PB-BUFFER L-TYPE
     CALL "PB-PUT-DOUBLE" USING PB-BUFFER L-X
     CALL "PB-PUT-DOUBLE" USING PB-BUFFER L-Y
     CALL "PB-PUT-DOUBLE" USING PB-BUFFER L-Z
     CALL "PB-PUT-LPVEC3" USING PB-BUFFER WS-V0 WS-V1 WS-V2
     CALL "PB-PUT-ANGLE" USING PB-BUFFER WS-A0
     CALL "PB-PUT-ANGLE" USING PB-BUFFER L-YAW
     CALL "PB-PUT-ANGLE" USING PB-BUFFER L-YAW
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-ZERO
     MOVE 0 TO PB-POS
     CALL "ENTITY-PACKET" USING CLIENT-STATE PB-BUFFER WS-ADD
     GOBACK.
 END PROGRAM MM-SPAWN.

