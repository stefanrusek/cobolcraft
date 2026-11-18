*> The ids the live redstone wiring (core/src/redstone-live.cob) resolves from the open block table by key, once per CB-EPOCH: the block ids (-1 when the set has none)
*> and the first state id of the wire block (its states are indexed as in 30-1 section 4.3).
 01 RL-IDS EXTERNAL.
    05 RL-EPOCH             BINARY-LONG.
    05 RL-WIRE              BINARY-LONG.
    05 RL-WIRE-FIRST        BINARY-LONG.
    05 RL-SOURCE            BINARY-LONG.
