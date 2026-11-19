*> The last game event posted (lane p49w; core/src/game-events.cob), EXTERNAL: GE-COUNT the events posted so far (every call of GAME-EVENT, before any filter), then the last one's name, position, source tracker row
*> (0 none) and affected block state (-1 none). A record for the tests and for the lanes that add listeners: what was posted, not who heard it.
 01 GE-LAST EXTERNAL.
    05 GE-COUNT              BINARY-DOUBLE.
    05 GE-NAME               PIC X(32).
    05 GE-X                  FLOAT-LONG.
    05 GE-Y                  FLOAT-LONG.
    05 GE-Z                  FLOAT-LONG.
    05 GE-SOURCE             BINARY-LONG.
    05 GE-STATE              BINARY-LONG.
