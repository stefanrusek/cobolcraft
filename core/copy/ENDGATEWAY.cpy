*> State of the End gateway block entities (docs/protocol/31-block-entities-5-beacon-conduit-end-piston-creaking.md section 4.2 to 4.4; core/src/end-gateway.cob).
*> EXTERNAL (zero at start), not saved with the chunk (open item). EG-EPOCH: the CB-EPOCH the ids were resolved for; EG-S-GATEWAY the state of end_gateway
*> and EG-S-BEDROCK of bedrock (-1 when the set has none). EG-ROW: the entity of one gateway block: dimension row, position, age in ticks, the teleport cooldown,
*> the exit position (EG-HAS-EXIT 1 when set) and ExactTeleport.
 78 EG-MAX                  VALUE 64.
 01 END-GATEWAY-STATE EXTERNAL.
    05 EG-EPOCH               BINARY-LONG.
    05 EG-S-GATEWAY           BINARY-LONG.
    05 EG-S-BEDROCK           BINARY-LONG.
    05 EG-COUNT               BINARY-LONG.
    05 EG-ROW OCCURS 64 TIMES.
       10 EG-DIM              BINARY-LONG.
       10 EG-X                BINARY-LONG.
       10 EG-Y                BINARY-LONG.
       10 EG-Z                BINARY-LONG.
       10 EG-AGE              BINARY-LONG.
       10 EG-COOLDOWN         BINARY-LONG.
       10 EG-HAS-EXIT         BINARY-LONG.
       10 EG-EXIT-X           BINARY-LONG.
       10 EG-EXIT-Y           BINARY-LONG.
       10 EG-EXIT-Z           BINARY-LONG.
       10 EG-EXACT            BINARY-LONG.
