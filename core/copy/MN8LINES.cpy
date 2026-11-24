*> The display lines of a MN8-ED text (docs/protocol/40-menus-8-book-and-sign-editors.md 2.3): begin and end index of each
*> (the count is returned by MN8-WRAP).
 01 MN8-LINES.
    05 MN8-LB          BINARY-LONG OCCURS 1100 TIMES.
    05 MN8-LE          BINARY-LONG OCCURS 1100 TIMES.
