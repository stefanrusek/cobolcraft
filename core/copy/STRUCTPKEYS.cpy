*> The type-specific keys of the saved pieces (docs/protocol/36-structures-4-scattered-and-small.md section 10 and 36-structures-5-mineshaft-stronghold.md section 3.9; core/src/struct-piece-keys.cob).
*> One row per key: the piece type (the registry id of 36-1 2.4), the slot of SPC-K(1 to 8) (STRUCTSTART.cpy) that holds its value (0 for the template string, held by SPC-TPL), the kind and the bit mask.
*> Kinds: I int, B boolean (a byte), T the Template string, R Rotation (the legacy constant name: NONE, CLOCKWISE_90, CLOCKWISE_180, COUNTERCLOCKWISE_90), M Mirror (NONE, LEFT_RIGHT, FRONT_BACK),
*> V VerticalPlacement (the serialized name: on_land_surface, partly_buried, on_ocean_floor, in_mountain, underground, in_nether), D EntryDoor (OPENING, WOOD_DOOR, GRATES, IRON_DOOR), and the members of
*> the ruined portal's `Properties` compound: p a boolean that is the bit of the mask in the slot (air_pocket 1, overgrown 2, vines 4, cold 8, replace_with_blackstone 16), f the mossiness, a float held in tenths.
*> The rows of one type are written in this order, the Properties compound after the plain keys.
 78 PKT-COUNT            VALUE 75.
 01 PKT-ROWS.
    05 FILLER PIC X(30) VALUE "371I00Width                   ".
    05 FILLER PIC X(30) VALUE "372I00Height                  ".
    05 FILLER PIC X(30) VALUE "373I00Depth                   ".
    05 FILLER PIC X(30) VALUE "374I00HPos                    ".
    05 FILLER PIC X(30) VALUE "375B00hasPlacedChest0         ".
    05 FILLER PIC X(30) VALUE "376B00hasPlacedChest1         ".
    05 FILLER PIC X(30) VALUE "377B00hasPlacedChest2         ".
    05 FILLER PIC X(30) VALUE "378B00hasPlacedChest3         ".
    05 FILLER PIC X(30) VALUE "321I00Width                   ".
    05 FILLER PIC X(30) VALUE "322I00Height                  ".
    05 FILLER PIC X(30) VALUE "323I00Depth                   ".
    05 FILLER PIC X(30) VALUE "324I00HPos                    ".
    05 FILLER PIC X(30) VALUE "325B00placedMainChest         ".
    05 FILLER PIC X(30) VALUE "326B00placedHiddenChest       ".
    05 FILLER PIC X(30) VALUE "327B00placedTrap1             ".
    05 FILLER PIC X(30) VALUE "328B00placedTrap2             ".
    05 FILLER PIC X(30) VALUE "361I00Width                   ".
    05 FILLER PIC X(30) VALUE "362I00Height                  ".
    05 FILLER PIC X(30) VALUE "363I00Depth                   ".
    05 FILLER PIC X(30) VALUE "364I00HPos                    ".
    05 FILLER PIC X(30) VALUE "365B00Witch                   ".
    05 FILLER PIC X(30) VALUE "366B00Cat                     ".
    05 FILLER PIC X(30) VALUE "340T00Template                ".
    05 FILLER PIC X(30) VALUE "341I00TPX                     ".
    05 FILLER PIC X(30) VALUE "342I00TPY                     ".
    05 FILLER PIC X(30) VALUE "343I00TPZ                     ".
    05 FILLER PIC X(30) VALUE "344R00Rot                     ".
    05 FILLER PIC X(30) VALUE "540T00Template                ".
    05 FILLER PIC X(30) VALUE "541I00TPX                     ".
    05 FILLER PIC X(30) VALUE "542I00TPY                     ".
    05 FILLER PIC X(30) VALUE "543I00TPZ                     ".
    05 FILLER PIC X(30) VALUE "544R00Rot                     ".
    05 FILLER PIC X(30) VALUE "350T00Template                ".
    05 FILLER PIC X(30) VALUE "351I00TPX                     ".
    05 FILLER PIC X(30) VALUE "352I00TPY                     ".
    05 FILLER PIC X(30) VALUE "353I00TPZ                     ".
    05 FILLER PIC X(30) VALUE "354R00Rotation                ".
    05 FILLER PIC X(30) VALUE "355M00Mirror                  ".
    05 FILLER PIC X(30) VALUE "356V00VerticalPlacement       ".
    05 FILLER PIC X(30) VALUE "357p08cold                    ".
    05 FILLER PIC X(30) VALUE "358f00mossiness               ".
    05 FILLER PIC X(30) VALUE "357p01air_pocket              ".
    05 FILLER PIC X(30) VALUE "357p02overgrown               ".
    05 FILLER PIC X(30) VALUE "357p04vines                   ".
    05 FILLER PIC X(30) VALUE "357p16replace_with_blackstone ".
    05 FILLER PIC X(30) VALUE "191D00EntryDoor               ".
    05 FILLER PIC X(30) VALUE "192B00Chest                   ".
    05 FILLER PIC X(30) VALUE "201D00EntryDoor               ".
    05 FILLER PIC X(30) VALUE "202I00Steps                   ".
    05 FILLER PIC X(30) VALUE "211D00EntryDoor               ".
    05 FILLER PIC X(30) VALUE "212B00leftLow                 ".
    05 FILLER PIC X(30) VALUE "213B00leftHigh                ".
    05 FILLER PIC X(30) VALUE "214B00rightLow                ".
    05 FILLER PIC X(30) VALUE "215B00rightHigh               ".
    05 FILLER PIC X(30) VALUE "221D00EntryDoor               ".
    05 FILLER PIC X(30) VALUE "231D00EntryDoor               ".
    05 FILLER PIC X(30) VALUE "232B00Tall                    ".
    05 FILLER PIC X(30) VALUE "241D00EntryDoor               ".
    05 FILLER PIC X(30) VALUE "242B00Mob                     ".
    05 FILLER PIC X(30) VALUE "251D00EntryDoor               ".
    05 FILLER PIC X(30) VALUE "261D00EntryDoor               ".
    05 FILLER PIC X(30) VALUE "271D00EntryDoor               ".
    05 FILLER PIC X(30) VALUE "272I00Type                    ".
    05 FILLER PIC X(30) VALUE "281D00EntryDoor               ".
    05 FILLER PIC X(30) VALUE "282B00Source                  ".
    05 FILLER PIC X(30) VALUE "291D00EntryDoor               ".
    05 FILLER PIC X(30) VALUE "292B00Source                  ".
    05 FILLER PIC X(30) VALUE "301D00EntryDoor               ".
    05 FILLER PIC X(30) VALUE "302B00Left                    ".
    05 FILLER PIC X(30) VALUE "303B00Right                   ".
    05 FILLER PIC X(30) VALUE "311D00EntryDoor               ".
    05 FILLER PIC X(30) VALUE "051I00Seed                    ".
    05 FILLER PIC X(30) VALUE "111B00Chest                   ".
    05 FILLER PIC X(30) VALUE "131B00Chest                   ".
    05 FILLER PIC X(30) VALUE "151B00Mob                     ".
 01 PKT-TABLE REDEFINES PKT-ROWS.
    05 PKT-ROW OCCURS 75 TIMES.
       10 PKT-TYPE         PIC 99.
       10 PKT-SLOT         PIC 9.
       10 PKT-KIND         PIC X.
       10 PKT-MASK         PIC 99.
       10 PKT-NAME         PIC X(24).
