*> The type-specific keys of a saved piece (docs/protocol/36-structures-4-scattered-and-small.md section 10, 36-structures-5-mineshaft-stronghold.md section 3.9; the key table is STRUCTPKEYS.cpy, the values
*> SPC-K(1 to 8) and SPC-TPL of STRUCTSTART.cpy). The writer and the reader of the chunk NBT (struct-start-nbt.cob) call these; the capture of a start (struct-start.cob) fills the values from the builder.
*> Saved flags (a chest, a spawner, the witch and the cat) are the builder's placed flags when the start is captured, that is after the first chunk's placement of the start.
*>
*> Entry points:
*>   STRUCT-PIECE-ENUM USING kind (R, M, V or D), mode (0 name out from the ordinal, 1 ordinal out from the name, -1 when the name is not one), ordinal, name (PIC X(24)): the enum spellings of the table
*>   STRUCT-PIECE-KEYS-WRITE USING PB-BUFFER, piece row of the store: appends the keys the table lists for the piece's type to the open piece compound, then the `Properties` compound when the type has one
*>   STRUCT-PIECE-KEY-SET USING piece type, key name (PIC X(24)), NBT type of the value, integer value (a float as tenths), string value (PIC X(64)), values (8 BINARY-LONG), template (PIC X(64)), result out:
*>     stores one key read from a piece compound (0 the type has no such key or the tag has the wrong type, 1 stored, 2 an enum key with a string that is not a constant)
*>   STRUCT-PIECE-KEYS-CAPTURE USING builder row, store piece row: the values of the keys from the builder's piece (scattered: size from the box and the orientation, HPos SP-T-AUX, the placed flags SP-F1 to SP-F4;
*>     template: the template key, SP-T-X..Z, rotation, mirror and the ruined portal's packed properties; stronghold: SP-F1 the entry door and SP-F2 to SP-F4 and SP-MST the type fields)

 IDENTIFICATION DIVISION.
 PROGRAM-ID. STRUCT-PIECE-ENUM.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-ROWS.
    05 FILLER              PIC X(21) VALUE "R0NONE".
    05 FILLER              PIC X(21) VALUE "R1CLOCKWISE_90".
    05 FILLER              PIC X(21) VALUE "R2CLOCKWISE_180".
    05 FILLER              PIC X(21) VALUE "R3COUNTERCLOCKWISE_90".
    05 FILLER              PIC X(21) VALUE "M0NONE".
    05 FILLER              PIC X(21) VALUE "M1LEFT_RIGHT".
    05 FILLER              PIC X(21) VALUE "M2FRONT_BACK".
    05 FILLER              PIC X(21) VALUE "V0on_land_surface".
    05 FILLER              PIC X(21) VALUE "V1partly_buried".
    05 FILLER              PIC X(21) VALUE "V2on_ocean_floor".
    05 FILLER              PIC X(21) VALUE "V3in_mountain".
    05 FILLER              PIC X(21) VALUE "V4underground".
    05 FILLER              PIC X(21) VALUE "V5in_nether".
    05 FILLER              PIC X(21) VALUE "D0OPENING".
    05 FILLER              PIC X(21) VALUE "D1WOOD_DOOR".
    05 FILLER              PIC X(21) VALUE "D2GRATES".
    05 FILLER              PIC X(21) VALUE "D3IRON_DOOR".
 01 WS-TAB REDEFINES WS-ROWS.
    05 WS-E OCCURS 17 TIMES.
       10 WS-E-KIND        PIC X.
       10 WS-E-ORD         PIC 9.
       10 WS-E-NAME        PIC X(19).
 01 WS-I                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-KIND                 PIC X.
 01 L-MODE                 BINARY-LONG.
 01 L-ORD                  BINARY-LONG.
 01 L-NAME                 PIC X(24).
 PROCEDURE DIVISION USING L-KIND L-MODE L-ORD L-NAME.
     IF L-MODE = 0
         MOVE SPACES TO L-NAME
     ELSE
         MOVE -1 TO L-ORD
     END-IF
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 17
         IF WS-E-KIND(WS-I) = L-KIND
             IF L-MODE = 0 AND WS-E-ORD(WS-I) = L-ORD
                 MOVE WS-E-NAME(WS-I) TO L-NAME
             END-IF
             IF L-MODE = 1 AND WS-E-NAME(WS-I) = L-NAME
                 MOVE WS-E-ORD(WS-I) TO L-ORD
             END-IF
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM STRUCT-PIECE-ENUM.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. STRUCT-PIECE-KEYS-WRITE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY STRUCTSTART.
 COPY STRUCTPKEYS.
 01 WN                     PIC X(32).
 01 WL                     BINARY-LONG.
 01 WS-R                   BINARY-LONG.
 01 WS-KIND                PIC X.
 01 WS-SLOT                BINARY-LONG.
 01 WS-MASK                BINARY-LONG.
 01 WS-V                   BINARY-LONG.
 01 WS-Q                   BINARY-LONG.
 01 WS-Q2                  BINARY-LONG.
 01 WS-BIT                 BINARY-LONG.
 01 WS-MODE-NAME           BINARY-LONG VALUE 0.
 01 WS-ENUM                PIC X(24).
 01 WS-ENUM-LEN            BINARY-LONG.
 01 WS-TPL                 PIC X(64).
 01 WS-TPL-LEN             BINARY-LONG.
 01 WS-F                   FLOAT-SHORT.
 01 WS-PROPS               BINARY-LONG.
 LINKAGE SECTION.
 COPY PROTO.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING PB-BUFFER L-ROW.
     MOVE 0 TO WS-PROPS
     PERFORM VARYING WS-R FROM 1 BY 1 UNTIL WS-R > PKT-COUNT
         IF PKT-TYPE(WS-R) = SPC-TYPE(L-ROW)
             MOVE SPACES TO WN
             MOVE PKT-NAME(WS-R) TO WN
             COMPUTE WL = FUNCTION LENGTH(FUNCTION TRIM(WN TRAILING))
             MOVE PKT-KIND(WS-R) TO WS-KIND
             MOVE PKT-SLOT(WS-R) TO WS-SLOT
             MOVE 0 TO WS-V
             IF WS-SLOT > 0
                 MOVE SPC-K(L-ROW, WS-SLOT) TO WS-V
             END-IF
             EVALUATE WS-KIND
                 WHEN "I"
                     CALL "NBT-WRITE-INT" USING PB-BUFFER WN WL WS-V
                 WHEN "B"
                     CALL "NBT-WRITE-BYTE" USING PB-BUFFER WN WL WS-V
                 WHEN "T"
                     IF SPC-TPL(L-ROW) NOT = SPACES
                         MOVE SPC-TPL(L-ROW) TO WS-TPL
                         COMPUTE WS-TPL-LEN = FUNCTION LENGTH(FUNCTION TRIM(WS-TPL TRAILING))
                         CALL "NBT-WRITE-STRING" USING PB-BUFFER WN WL WS-TPL WS-TPL-LEN
                     END-IF
                 WHEN "R" WHEN "M" WHEN "V" WHEN "D"
                     CALL "STRUCT-PIECE-ENUM" USING WS-KIND WS-MODE-NAME WS-V WS-ENUM
                     COMPUTE WS-ENUM-LEN = FUNCTION LENGTH(FUNCTION TRIM(WS-ENUM TRAILING))
                     CALL "NBT-WRITE-STRING" USING PB-BUFFER WN WL WS-ENUM WS-ENUM-LEN
                 WHEN OTHER
                     MOVE 1 TO WS-PROPS
             END-EVALUATE
         END-IF
     END-PERFORM
     IF WS-PROPS = 1
         MOVE SPACES TO WN
         MOVE "Properties" TO WN
         MOVE 10 TO WL
         CALL "NBT-WRITE-COMPOUND-BEGIN" USING PB-BUFFER WN WL
         PERFORM VARYING WS-R FROM 1 BY 1 UNTIL WS-R > PKT-COUNT
             IF PKT-TYPE(WS-R) = SPC-TYPE(L-ROW) AND (PKT-KIND(WS-R) = "p" OR PKT-KIND(WS-R) = "f")
                 MOVE SPACES TO WN
                 MOVE PKT-NAME(WS-R) TO WN
                 COMPUTE WL = FUNCTION LENGTH(FUNCTION TRIM(WN TRAILING))
                 MOVE PKT-SLOT(WS-R) TO WS-SLOT
                 MOVE PKT-MASK(WS-R) TO WS-MASK
                 MOVE SPC-K(L-ROW, WS-SLOT) TO WS-V
                 IF PKT-KIND(WS-R) = "f"
                     COMPUTE WS-F = WS-V / 10
                     CALL "NBT-WRITE-FLOAT" USING PB-BUFFER WN WL WS-F
                 ELSE
                     DIVIDE WS-V BY WS-MASK GIVING WS-Q
                     DIVIDE WS-Q BY 2 GIVING WS-Q2 REMAINDER WS-BIT
                     CALL "NBT-WRITE-BYTE" USING PB-BUFFER WN WL WS-BIT
                 END-IF
             END-IF
         END-PERFORM
         CALL "NBT-WRITE-COMPOUND-END" USING PB-BUFFER
     END-IF
     GOBACK.
 END PROGRAM STRUCT-PIECE-KEYS-WRITE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. STRUCT-PIECE-KEY-SET.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY STRUCTPKEYS.
 01 WS-R                   BINARY-LONG.
 01 WS-SLOT                BINARY-LONG.
 01 WS-KIND                PIC X.
 01 WS-MODE-ORD            BINARY-LONG VALUE 1.
 01 WS-ORD                 BINARY-LONG.
 01 WS-ENUM                PIC X(24).
 01 WS-NUMERIC             BINARY-LONG.
 LINKAGE SECTION.
 01 L-TYPE                 BINARY-LONG.
 01 L-NAME                 PIC X(24).
 01 L-VTYPE                BINARY-LONG.
 01 L-INT                  BINARY-LONG.
 01 L-STR                  PIC X(64).
 01 L-KS.
    05 L-K                 BINARY-LONG OCCURS 8 TIMES.
 01 L-TPL                  PIC X(64).
 01 L-RESULT               BINARY-LONG.
 PROCEDURE DIVISION USING L-TYPE L-NAME L-VTYPE L-INT L-STR L-KS L-TPL L-RESULT.
     MOVE 0 TO L-RESULT
*>   a numeric tag (byte, short, int, float) reads as a number, any other tag type as absent
     MOVE 0 TO WS-NUMERIC
     IF L-VTYPE = 1 OR L-VTYPE = 2 OR L-VTYPE = 3 OR L-VTYPE = 5
         MOVE 1 TO WS-NUMERIC
     END-IF
     PERFORM VARYING WS-R FROM 1 BY 1 UNTIL WS-R > PKT-COUNT OR L-RESULT > 0
         IF PKT-TYPE(WS-R) = L-TYPE AND PKT-NAME(WS-R) = L-NAME
             MOVE PKT-KIND(WS-R) TO WS-KIND
             MOVE PKT-SLOT(WS-R) TO WS-SLOT
             EVALUATE TRUE
                 WHEN (WS-KIND = "I") AND WS-NUMERIC = 1
*>                   a float tag (held in tenths by the reader) reads as its integer part
                     IF L-VTYPE = 5
                         DIVIDE L-INT BY 10 GIVING L-K(WS-SLOT)
                     ELSE
                         MOVE L-INT TO L-K(WS-SLOT)
                     END-IF
                     MOVE 1 TO L-RESULT
                 WHEN (WS-KIND = "B") AND WS-NUMERIC = 1
                     MOVE 0 TO L-K(WS-SLOT)
                     IF L-INT NOT = 0
                         MOVE 1 TO L-K(WS-SLOT)
                     END-IF
                     MOVE 1 TO L-RESULT
                 WHEN (WS-KIND = "T") AND L-VTYPE = 8
                     MOVE L-STR TO L-TPL
                     MOVE 1 TO L-RESULT
                 WHEN (WS-KIND = "R" OR WS-KIND = "M" OR WS-KIND = "V" OR WS-KIND = "D") AND L-VTYPE = 8
                     MOVE L-STR TO WS-ENUM
                     CALL "STRUCT-PIECE-ENUM" USING WS-KIND WS-MODE-ORD WS-ORD WS-ENUM
                     IF WS-ORD >= 0
                         MOVE WS-ORD TO L-K(WS-SLOT)
                         MOVE 1 TO L-RESULT
                     ELSE
                         MOVE 2 TO L-RESULT
                     END-IF
                 WHEN (WS-KIND = "p") AND WS-NUMERIC = 1
                     IF L-INT NOT = 0
                         ADD PKT-MASK(WS-R) TO L-K(WS-SLOT)
                     END-IF
                     MOVE 1 TO L-RESULT
                 WHEN (WS-KIND = "f") AND WS-NUMERIC = 1
                     IF L-VTYPE = 5
                         MOVE L-INT TO L-K(WS-SLOT)
                     ELSE
                         COMPUTE L-K(WS-SLOT) = L-INT * 10
                     END-IF
                     MOVE 1 TO L-RESULT
                 WHEN OTHER
                     CONTINUE
             END-EVALUATE
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM STRUCT-PIECE-KEY-SET.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. STRUCT-PIECE-KEYS-CAPTURE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY STRUCTSTART.
 COPY STRUCTPIECE.
 COPY STRUCTTPL.
 01 WS-DX                  BINARY-LONG.
 01 WS-DY                  BINARY-LONG.
 01 WS-DZ                  BINARY-LONG.
 01 WS-MOSS                BINARY-LONG.
 01 WS-LOW                 BINARY-LONG.
 01 WS-PLACE               BINARY-LONG.
 01 WS-FLAGS               BINARY-LONG.
 01 WS-TROW                BINARY-LONG.
 LINKAGE SECTION.
 01 L-B                    BINARY-LONG.
 01 L-P                    BINARY-LONG.
 PROCEDURE DIVISION USING L-B L-P.
     EVALUATE TRUE
         WHEN SPC-TYPE(L-P) = 37 OR SPC-TYPE(L-P) = 32 OR SPC-TYPE(L-P) = 36
*>           Width, Height, Depth: the extents the piece was made with (the box swaps the horizontal ones for east and west), HPos the height position
             COMPUTE WS-DX = SP-X1(L-B) - SP-X0(L-B) + 1
             COMPUTE WS-DY = SP-Y1(L-B) - SP-Y0(L-B) + 1
             COMPUTE WS-DZ = SP-Z1(L-B) - SP-Z0(L-B) + 1
             IF SP-ORIENT(L-B) = 0 OR SP-ORIENT(L-B) = 2
                 MOVE WS-DX TO SPC-K(L-P, 1)
                 MOVE WS-DZ TO SPC-K(L-P, 3)
             ELSE
                 MOVE WS-DZ TO SPC-K(L-P, 1)
                 MOVE WS-DX TO SPC-K(L-P, 3)
             END-IF
             MOVE WS-DY TO SPC-K(L-P, 2)
             MOVE SP-T-AUX(L-B) TO SPC-K(L-P, 4)
             EVALUATE SPC-TYPE(L-P)
                 WHEN 37
                     MOVE SP-F1(L-B) TO SPC-K(L-P, 5)
                     MOVE SP-F2(L-B) TO SPC-K(L-P, 6)
                     MOVE SP-F3(L-B) TO SPC-K(L-P, 7)
                     MOVE SP-F4(L-B) TO SPC-K(L-P, 8)
                 WHEN 32
*>                   the jungle temple's flags in the builder are trap 1, trap 2, main chest, hidden chest
                     MOVE SP-F3(L-B) TO SPC-K(L-P, 5)
                     MOVE SP-F4(L-B) TO SPC-K(L-P, 6)
                     MOVE SP-F1(L-B) TO SPC-K(L-P, 7)
                     MOVE SP-F2(L-B) TO SPC-K(L-P, 8)
                 WHEN OTHER
                     MOVE SP-F1(L-B) TO SPC-K(L-P, 5)
                     MOVE SP-F2(L-B) TO SPC-K(L-P, 6)
             END-EVALUATE
         WHEN SPC-TYPE(L-P) = 34 OR SPC-TYPE(L-P) = 35 OR SPC-TYPE(L-P) = 54
             MOVE SP-T-ROW(L-B) TO WS-TROW
             IF WS-TROW >= 1 AND WS-TROW <= TP-COUNT
                 MOVE TP-KEY(WS-TROW) TO SPC-TPL(L-P)
             END-IF
             MOVE SP-T-X(L-B) TO SPC-K(L-P, 1)
             MOVE SP-T-Y(L-B) TO SPC-K(L-P, 2)
             MOVE SP-T-Z(L-B) TO SPC-K(L-P, 3)
             MOVE SP-T-ROT(L-B) TO SPC-K(L-P, 4)
             IF SPC-TYPE(L-P) = 35
*>               the ruined portal's AUX: the properties in the low five bits, 32 times the placement, 256 times the mossiness in tenths
                 MOVE SP-T-MIR(L-B) TO SPC-K(L-P, 5)
                 DIVIDE SP-T-AUX(L-B) BY 256 GIVING WS-MOSS REMAINDER WS-LOW
                 DIVIDE WS-LOW BY 32 GIVING WS-PLACE REMAINDER WS-FLAGS
                 MOVE WS-PLACE TO SPC-K(L-P, 6)
                 MOVE WS-FLAGS TO SPC-K(L-P, 7)
                 MOVE WS-MOSS TO SPC-K(L-P, 8)
             END-IF
         WHEN SPC-TYPE(L-P) >= 19 AND SPC-TYPE(L-P) <= 31
             MOVE SP-F1(L-B) TO SPC-K(L-P, 1)
             MOVE SP-F2(L-B) TO SPC-K(L-P, 2)
             MOVE SP-F3(L-B) TO SPC-K(L-P, 3)
             MOVE SP-F4(L-B) TO SPC-K(L-P, 4)
             MOVE SP-MST(L-B) TO SPC-K(L-P, 5)
         WHEN SPC-TYPE(L-P) = 5 OR SPC-TYPE(L-P) = 15
*>           the fortress's bridge end filler keeps its Seed and the monster throne its spawner flag in the builder's F1
             MOVE SP-F1(L-B) TO SPC-K(L-P, 1)
         WHEN SPC-TYPE(L-P) = 11 OR SPC-TYPE(L-P) = 13
*>           a turn piece's F1 is its roll, F2 the pending chest flag that is the saved Chest
             MOVE SP-F2(L-B) TO SPC-K(L-P, 1)
         WHEN OTHER
             CONTINUE
     END-EVALUATE
     GOBACK.
 END PROGRAM STRUCT-PIECE-KEYS-CAPTURE.
