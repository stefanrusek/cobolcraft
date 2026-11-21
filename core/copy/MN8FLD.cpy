*> State of a single-line text field (docs/protocol/40-menus-8-book-and-sign-editors.md 4 step 2 and 5): the book title box (EditBox) and the sign
*> line editor (TextFieldHelper). One byte per UTF-16 code unit; cursor and anchor are 0 based; MAX is the length limit of the title box, ADV
*> the uniform glyph advance and MAXW the largest line width the sign validator accepts (0 for the title box); CLIP is the clipboard.
 01 MN8-FLD.
    05 MN8-FTEXT       PIC X(256).
    05 MN8-FLEN        BINARY-LONG.
    05 MN8-FCUR        BINARY-LONG.
    05 MN8-FANC        BINARY-LONG.
    05 MN8-FMAX        BINARY-LONG.
    05 MN8-FADV        BINARY-LONG.
    05 MN8-FMAXW       BINARY-LONG.
    05 MN8-FCLIP       PIC X(256).
    05 MN8-FCLIPLEN    BINARY-LONG.
    05 MN8-FCHANGED    BINARY-LONG.
