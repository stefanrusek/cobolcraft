*> One row of the provider and class index of docs/protocol/42-particles-2-effects-fire-smoke-magic.md
*> section 1. P2-PICK: 0 first, 1 age, 2 rnd, 3 none, 4 model. P2-LAYER: 0 OPAQUE, 1 TRANSLUCENT, 2 no
*> particle layer (no-render or the elder guardian group). P2-PHYS: 0 no, 1 yes, 2 no motion.
 01 P2IX.
    05 P2-FOUND               BINARY-LONG.
    05 P2-ID                  PIC 999.
    05 P2-OVR                 PIC 9.
    05 P2-SPR                 PIC 99.
    05 P2-PICK                PIC 9.
    05 P2-LAYER               PIC 9.
    05 P2-PHYS                PIC 9.
    05 P2-PROVIDER            PIC X(48).
    05 P2-CLASS               PIC X(40).
    05 P2-SECTION             PIC X(4).
