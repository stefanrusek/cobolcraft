*> The decoded potion_contents component (stack-potion.cob; docs/protocol/25 section 9.1): PR-POTION the potion registry id (-1 none), PR-HAS-COLOR and PR-COLOR the custom colour (ARGB int), PR-N custom
*> effects (at most 8: id, amplifier, duration with -1 infinite), PR-NAME the custom name (PR-NAME-LEN bytes, 0 none). COPY with REPLACING LEADING ==PR-== for another prefix.
 01 PR-REC.
    05 PR-POTION           BINARY-LONG.
    05 PR-HAS-COLOR        BINARY-LONG.
    05 PR-COLOR            BINARY-LONG.
    05 PR-N                BINARY-LONG.
    05 PR-FX OCCURS 8 TIMES.
       10 PR-FX-ID         BINARY-LONG.
       10 PR-FX-AMP        BINARY-LONG.
       10 PR-FX-DUR        BINARY-LONG.
    05 PR-NAME-LEN         BINARY-LONG.
    05 PR-NAME             PIC X(64).
