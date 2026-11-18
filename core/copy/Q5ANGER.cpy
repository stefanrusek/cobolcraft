*> The anger state of AngerManagement (docs/protocol/44-residual-mob-questions-5-overworld-hostile.md section 3.6; programs Q5-ANGER-* of core/src/q44-44-5.cob).
*> An entity is a small integer id. AN-L-*: the live map (anger by entity), AN-U-*: the UUID map (stored values waiting to be matched), AN-SUSPECT: the entity ids
*> of the suspect list in sorted order. AN-DELAY is the conversion delay (period 2), AN-HIGHEST the highest anger.
 78 AN-MAX                  VALUE 16.
 01 Q5-ANGER.
    05 AN-DELAY            BINARY-LONG.
    05 AN-HIGHEST          BINARY-LONG.
    05 AN-LIVE-COUNT       BINARY-LONG.
    05 AN-LIVE             OCCURS AN-MAX TIMES.
       10 AN-L-ID          BINARY-LONG.
       10 AN-L-PLAYER      BINARY-LONG.
       10 AN-L-VALUE       BINARY-LONG.
    05 AN-UUID-COUNT       BINARY-LONG.
    05 AN-U                OCCURS AN-MAX TIMES.
       10 AN-U-ID          BINARY-LONG.
       10 AN-U-PLAYER      BINARY-LONG.
       10 AN-U-VALUE       BINARY-LONG.
    05 AN-SUSPECT-COUNT    BINARY-LONG.
    05 AN-SUSPECT          BINARY-LONG OCCURS AN-MAX TIMES.
