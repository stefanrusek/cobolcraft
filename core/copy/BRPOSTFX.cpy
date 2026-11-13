*> The post effects of the players (docs/protocol/16-commands-catalog.md §8.11): per player row the uuid the entry belongs to (an entry of
*> another uuid is empty), the number of effects (at most 8) and their identifiers with the namespace.
 01 BR-POSTFX EXTERNAL.
    05 PFX-ENTRY            OCCURS 64 TIMES.
       10 PFX-UUID           PIC X(16).
       10 PFX-COUNT          BINARY-LONG.
       10 PFX-FX             OCCURS 8 TIMES.
          15 PFX-FX-LENGTH    BINARY-LONG.
          15 PFX-FX-ID        PIC X(64).
