*> Sign text rendering (docs/protocol/52-block-entity-models-2-signs.md; client/src/sign-render.cob).
*> The text of the sign block entities is one mesh of the frame (eye-relative, texture 2 = the UI atlas with the font, pipeline CC-PIPE-OPAQUE:
*> depth tested and written, texels under alpha 0.1 dropped), built by SGR-MESH into an area of the render list's own.
 78 MESH-SLOT-SIGNS      VALUE 65015.
 78 SGR-MAX-VERTICES     VALUE 32768.
*> Block kinds of 52-2 section 2.1 (SGR-KIND): 1 standing sign, 2 wall sign, 3 ceiling hanging sign, 4 wall hanging sign; 0 is no sign.
 78 SGR-STANDING         VALUE 1.
 78 SGR-WALL             VALUE 2.
 78 SGR-HANGING          VALUE 3.
 78 SGR-WALL-HANGING     VALUE 4.
