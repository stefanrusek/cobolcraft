*> How SGR-RUN and SGR-LINE-DRAW (sign-mesh.cob) paint a line: the colour (RGB integer), the pull toward the eye (a fraction of the distance; the substitute of the
*> polygon offset of 52-2 section 6.4: 0 draws the plane exactly), the brightness and sky terms of the light, and the style of the line (bold, italic, obfuscated: 0 or 1).
 01 SGR-PAINT.
    05 SP-RGB              BINARY-LONG.
    05 SP-BIAS             FLOAT-LONG.
    05 SP-BRIGHT           FLOAT-LONG.
    05 SP-SKY              FLOAT-LONG.
    05 SP-BOLD             BINARY-LONG.
    05 SP-ITALIC           BINARY-LONG.
    05 SP-OBF              BINARY-LONG.
