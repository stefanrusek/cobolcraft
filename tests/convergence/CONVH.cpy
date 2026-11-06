*> Convergence harness record (test infrastructure, excluded from coverage; tests/convergence/
*> convharness.cob). One per test program, passed to every CV-* program.
*>
*> CV-DIR is the test's scratch directory (repository-relative, under build/); each client's game
*> directory is <CV-DIR>/<client name>, the server program's working directory <CV-DIR>/server.
*> CV-NOW is the frame clock every client is stepped with (CL-STEP), 50 ms per CV-STEP. A client is
*> a CLIENT-STATE (client/copy/CLSTATE.cpy) allocated by CV-CLIENT-ADD at CV-ADDR(n): a test reads
*> it with `SET ADDRESS OF CLIENT-STATE TO CV-ADDR(n)` (CLIENT-STATE in its LINKAGE SECTION).
*> CV-HOST is the client hosting the world (single-player host, its SP-PUMP runs the core), 0 when
*> none. CV-SERVER is 1 while the server program's loop (SV-START) runs in this process; CV-PORT is
*> its port, or the host's port once its world is opened to others. Events queued for a client
*> (CV-QUEUE) are delivered with its next CL-STEP.
 01 CONVH.
    05 CV-DIR                PIC X(64).
    05 CV-DIR-LENGTH         BINARY-LONG.
    05 CV-NOW                BINARY-DOUBLE.
    05 CV-HOST               BINARY-LONG.
    05 CV-SERVER             BINARY-LONG.
    05 CV-PORT               BINARY-LONG.
    05 CV-STEPS-RUN          BINARY-LONG.
    05 CV-COUNT              BINARY-LONG.
    05 CV-CLIENT OCCURS 4 TIMES.
       10 CV-ADDR            USAGE POINTER.
       10 CV-EVENT-COUNT     BINARY-LONG.
       10 CV-EVENTS.
          15 CV-EVENT OCCURS 64 TIMES.
             20 CV-EV-KIND   BINARY-LONG.
             20 CV-EV-A      BINARY-LONG.
             20 CV-EV-B      BINARY-LONG.
             20 CV-EV-C      BINARY-LONG.
             20 CV-EV-X      FLOAT-SHORT.
             20 CV-EV-Y      FLOAT-SHORT.
