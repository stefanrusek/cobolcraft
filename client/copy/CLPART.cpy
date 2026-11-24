*> Particle options (docs/protocol/42-particles-1-shared-model-engine.md section 3): the decoded value
*> of every ParticleOptions class. PO-KIND is the option kind of the registry (simple, block, color,
*> spell, geyser, geyser-base, dust, dust-transition, power, item, sculk-charge, shriek, vibration,
*> trail). PO-ERROR is 0, or 1 for a short read, a malformed value or a block state id outside the
*> registry. A caller that wants the registry check sets PO-BLOCK-STATE-COUNT before decoding (0 =
*> unchecked). Colours are ARGB words in a BINARY-DOUBLE (0 to 4294967295).
 01 PART-OPTIONS.
    05 PO-KIND                PIC X(16).
    05 PO-ERROR               BINARY-LONG.
    05 PO-BLOCK-STATE-COUNT   BINARY-LONG.
    05 PO-BLOCK-STATE         BINARY-LONG.
    05 PO-ITEM-ID             BINARY-LONG.
    05 PO-ITEM-COUNT          BINARY-LONG.
    05 PO-ITEM-ADDED          BINARY-LONG.
    05 PO-ITEM-REMOVED        BINARY-LONG.
    05 PO-COLOR               BINARY-DOUBLE.
    05 PO-TO-COLOR            BINARY-DOUBLE.
    05 PO-SCALE               FLOAT-LONG.
    05 PO-POWER               FLOAT-LONG.
    05 PO-DELAY               BINARY-LONG.
    05 PO-ROLL                FLOAT-LONG.
    05 PO-SRC-TYPE            BINARY-LONG.
    05 PO-SRC-X               BINARY-LONG.
    05 PO-SRC-Y               BINARY-LONG.
    05 PO-SRC-Z               BINARY-LONG.
    05 PO-SRC-ENTITY          BINARY-LONG.
    05 PO-SRC-YOFFSET         FLOAT-LONG.
    05 PO-ARRIVAL             BINARY-LONG.
    05 PO-TARGET-X            FLOAT-LONG.
    05 PO-TARGET-Y            FLOAT-LONG.
    05 PO-TARGET-Z            FLOAT-LONG.
    05 PO-DURATION            BINARY-LONG.
    05 PO-WATER-BLOCKS        BINARY-LONG.
    05 PO-BURST               FLOAT-LONG.
