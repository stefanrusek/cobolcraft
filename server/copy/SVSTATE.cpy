*> Host state of the server program (research R6; contracts/core-host-api.md §2). Package-private:
*> the listener, the transports the host moves bytes for, and the tick clock. One EXTERNAL record
*> shared by the programs of server/src (and read by the server tests).
*>
*> A connection slot is free while SV-HANDLE is 0. SV-CORE-ID is the core's connection id. SV-CLOSING
*> is 1 once CORE-CONN-OUTPUT handed back the close flag: the core has released that id (it may be
*> reused for a new connection), so the host only flushes SV-OUT and then closes the transport.
*> SV-OUT holds bytes taken from CORE-CONN-OUTPUT and not yet sent: SV-OUT-PENDING bytes from offset
*> SV-OUT-START (1-based); a partial cc_net_send leaves the rest there for the next flush.
*> SV-CONSOLE-OPEN is 1 from SV-START until the end of console input (operator-surface §4): only
*> then does cc_net_poll also wait for standard input.

 78 SV-MAX-CONNS           VALUE 128.     *> transports; the core itself accepts CORE-MAX-CONNS
 78 SV-OUT-CAPACITY        VALUE 65536.
 78 SV-TICK-MS             VALUE 50.      *> one CORE-TICK per elapsed 50 ms (R6)

 01 SV-HOST EXTERNAL.
    05 SV-LISTENER         BINARY-LONG.   *> cc_net handle, 0 = not listening
    05 SV-BOUND-PORT       BINARY-LONG.   *> the port actually listened on
    05 SV-PORT             BINARY-LONG.   *> the configured port (operator-surface §2)
    05 SV-SETTINGS         PIC X(3829).   *> the CORE-SETTINGS the world was opened with
    05 SV-NEXT-TICK        BINARY-DOUBLE. *> clock (SV-NOW-MS) at which the next tick is due
    05 SV-TICKS            BINARY-DOUBLE. *> CORE-TICK calls made since SV-START
    05 SV-CONSOLE-OPEN     BINARY-LONG.   *> 1 while console input is read (0 after its end)
    05 SV-CONN OCCURS 128 TIMES.
       10 SV-HANDLE        BINARY-LONG.
       10 SV-CORE-ID       BINARY-LONG.
       10 SV-CLOSING       PIC 9.
       10 SV-OUT-START     BINARY-LONG.
       10 SV-OUT-PENDING   BINARY-LONG.
       10 SV-OUT           PIC X(65536).
