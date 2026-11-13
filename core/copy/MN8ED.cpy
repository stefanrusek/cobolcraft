*> State of the book page editor (docs/protocol/40-menus-8-book-and-sign-editors.md 2.1) shared by the MN8- programs and their tests:
*> text of the page (one byte per UTF-16 code unit), its length, cursor and anchor (0 based), the character and line limits, the wrap
*> width and the uniform glyph advance of the test fixture (section 8), a clipboard and the "value changed" flag of the last call.
 01 MN8-ED.
    05 MN8-TEXT        PIC X(1100).
    05 MN8-LEN         BINARY-LONG.
    05 MN8-CUR         BINARY-LONG.
    05 MN8-ANC         BINARY-LONG.
    05 MN8-CHARLIM     BINARY-LONG.
    05 MN8-LINELIM     BINARY-LONG.
    05 MN8-WIDTH       BINARY-LONG.
    05 MN8-ADV         BINARY-LONG.
    05 MN8-CLIP        PIC X(1100).
    05 MN8-CLIPLEN     BINARY-LONG.
    05 MN8-CHANGED     BINARY-LONG.
