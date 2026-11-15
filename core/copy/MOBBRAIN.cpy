*> Brain state of one mob (docs/protocol/18-mob-framework.md sections 4.5 to 4.7), table driven. Memory modules are numbered by
*> the caller (the registry order of 4.5); BR-TTL is -1 for a memory without expiry. BR-ACT lists the activities of the
*> brain in priority order with up to three memories each must have present. BHV-RECORD is one behaviour (4.6).
 01 BR-STATE.
    05 BR-MEMORY OCCURS 32 TIMES.
       10 BR-PRESENT        BINARY-LONG.
       10 BR-TTL            BINARY-LONG.
       10 BR-VALUE          BINARY-LONG.
    05 BR-ACT-COUNT         BINARY-LONG.
    05 BR-ACT OCCURS 8 TIMES.
       10 BR-ACT-REQ        BINARY-LONG OCCURS 3 TIMES.
 01 BHV-RECORD.
    05 BHV-STATUS           BINARY-LONG.
    05 BHV-END-TIME         BINARY-LONG.
    05 BHV-MIN              BINARY-LONG.
    05 BHV-MAX              BINARY-LONG.
    05 BHV-ROLL             BINARY-LONG.
    05 BHV-TIME             BINARY-LONG.
    05 BHV-MEMORY-OK        BINARY-LONG.
    05 BHV-EXTRA-OK         BINARY-LONG.
    05 BHV-CAN-STILL-USE    BINARY-LONG.
    05 BHV-ACTION           BINARY-LONG.
