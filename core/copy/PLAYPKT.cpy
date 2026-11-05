*> Decoded serverbound play packets of the join (docs/protocol/05c; 09 §3.2 play table), filled by
*> PLAY-DECODE (core/src/play.cob). Only the fields of the decoded packet are set; the others are
*> cleared.
 01 PLAY-SERVERBOUND.
*>  0x00 Accept Teleportation
    05 PSB-TELEPORT-ID        BINARY-LONG.
    05 PSB-X                  FLOAT-LONG.
    05 PSB-Y                  FLOAT-LONG.
    05 PSB-Z                  FLOAT-LONG.
    05 PSB-YAW                FLOAT-SHORT.
    05 PSB-PITCH              FLOAT-SHORT.
*>  0x0B Chunk Batch Received
    05 PSB-CHUNK-RATE         FLOAT-SHORT.
*>  0x0E Client Information (03 layout; only the view distance is kept)
    05 PSB-VIEW-DISTANCE      BINARY-LONG.
*>  0x1C Keep Alive
    05 PSB-KEEPALIVE          BINARY-DOUBLE.
