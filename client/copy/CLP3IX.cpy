*> One row of the registry table of docs/protocol/42-particles-3-fluid-drip-water.md section 2.
*> P3-PICK: 1 first then by age, 2 get(random), 5 first then get(i % 4, 4). P3-LAYER: 0 OPAQUE, 1 TRANSLUCENT.
 01 P3IX.
    05 P3-FOUND               BINARY-LONG.
    05 P3-ID                  PIC 999.
    05 P3-LAYER               PIC 9.
    05 P3-PICK                PIC 9.
    05 P3-OVR                 PIC 9.
    05 P3-FRAMES              PIC 9.
    05 P3-PROVIDER            PIC X(52).
    05 P3-CLASS               PIC X(40).
    05 P3-SECTION             PIC X(4).
