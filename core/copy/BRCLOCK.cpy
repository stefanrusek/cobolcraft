*> The state of the world clock the time command controls (docs/protocol/16-commands-catalog.md §4.5; core/src/cmd-clock.cob), EXTERNAL:
*> CK-READY 0 until the first use (then the clock runs at rate 1), CK-PAUSED 1 while paused, CK-RATE the multiplier of the clock
*> (the ticks it advances per tick) and CK-PARTIAL the fraction not yet advanced.
 01 BR-CLOCK EXTERNAL.
    05 CK-READY             BINARY-LONG.
    05 CK-PAUSED            BINARY-LONG.
    05 CK-RATE              FLOAT-LONG.
    05 CK-PARTIAL           FLOAT-LONG.
