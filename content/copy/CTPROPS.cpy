*> The property values of one block state (CONTENT-STATE-PROPS): the properties of the block in the
*> order of its property list (sorted by name, 24 part 1 section 3), each with the name and the value
*> text of the state. Package-private to content and its callers: CT-PROPS is an OUT area.
 78 CTP-MAX                VALUE 16.
 01 CT-PROPS.
    05 CTP-COUNT            BINARY-LONG.
    05 CTP-ENTRY OCCURS 16 TIMES.
       10 CTP-NAME          PIC X(24).
       10 CTP-VALUE         PIC X(32).
