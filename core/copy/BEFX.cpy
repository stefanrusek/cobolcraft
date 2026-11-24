*> Effects a block entity operation asks of its caller (31-1 section 8; core/src/be-31-1.cob): FX-SOUND 0 none, 1 the open sound,
*> 2 the close sound; FX-EVENT the game event 0 none, 1 CONTAINER_OPEN, 2 CONTAINER_CLOSE; FX-TICK the delay of a scheduled block tick
*> (0 none, 5); FX-BLOCK-EVENT the parameter of block event 1 (-1 none); FX-PROP the barrel OPEN property to set (-1 none, 0, 1);
*> FX-NEIGHBOURS 1 when the neighbours of the block and the block below must be updated (trapped chest, 10.5).
 01 BE-FX.
    05 FX-SOUND          BINARY-LONG.
    05 FX-EVENT          BINARY-LONG.
    05 FX-TICK           BINARY-LONG.
    05 FX-BLOCK-EVENT    BINARY-LONG.
    05 FX-PROP           BINARY-LONG.
    05 FX-NEIGHBOURS     BINARY-LONG.
