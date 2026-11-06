*> The server's TCP host (research R6, R7; contracts/core-host-api.md §2, shim-abi.md §3): it moves
*> bytes between cc_net_* connections and the core. Every accepted connection is a core network
*> connection (CORE-CONN-OPEN kind CORE-CONN-NETWORK). Received bytes go to CORE-CONN-INPUT; bytes
*> from CORE-CONN-OUTPUT are sent, a partial send keeping the rest in the slot's SV-OUT; after the
*> close flag the host flushes and closes the transport; a peer close calls CORE-CONN-CLOSED.
*> A socket error on one connection, and a connection the core has no room for, are non-fatal
*> (FR-012, research R14): one "ERROR connection: <detail>" line, that connection closed, serving
*> continues. Host state: SVSTATE.cpy.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TCP-LISTEN.
*> USING port (BINARY-LONG; 0 = system-chosen): listens on 0.0.0.0:port (SV-LISTENER, SV-BOUND-PORT).
*> A port already in use is fatal: the server cannot serve (FR-012).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY SVSTATE.
 01 WS-RC                  BINARY-LONG.
 01 WS-EDIT                PIC Z(4)9.
 01 WS-FATAL               PIC X(64).
 LINKAGE SECTION.
 01 L-PORT                 BINARY-LONG.
 PROCEDURE DIVISION USING L-PORT.
     CALL STATIC "cc_net_listen" USING BY VALUE L-PORT BY REFERENCE SV-LISTENER
         BY REFERENCE SV-BOUND-PORT RETURNING WS-RC
     IF WS-RC NOT = 0
         MOVE L-PORT TO WS-EDIT
         MOVE LOW-VALUES TO WS-FATAL
         STRING "listen: port " FUNCTION TRIM(WS-EDIT) " is already in use" DELIMITED BY SIZE
             INTO WS-FATAL
         CALL STATIC "cc_fatal" USING BY REFERENCE WS-FATAL
     END-IF
     GOBACK.
 END PROGRAM TCP-LISTEN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TCP-RELEASE.
*> USING slot (BINARY-LONG): closes the slot's transport and frees the slot. While the core still
*> holds the connection (no close flag handed back) it is told with CORE-CONN-CLOSED.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY SVSTATE.
 01 WS-SLOT                BINARY-LONG.
 LINKAGE SECTION.
 01 L-SLOT                 BINARY-LONG.
 PROCEDURE DIVISION USING L-SLOT.
     MOVE L-SLOT TO WS-SLOT
     IF SV-CLOSING(WS-SLOT) = 0
         CALL "CORE-CONN-CLOSED" USING SV-CORE-ID(WS-SLOT)
     END-IF
     CALL STATIC "cc_net_close" USING BY VALUE SV-HANDLE(WS-SLOT)
     MOVE 0 TO SV-HANDLE(WS-SLOT) SV-CORE-ID(WS-SLOT) SV-CLOSING(WS-SLOT) SV-OUT-PENDING(WS-SLOT)
     MOVE 1 TO SV-OUT-START(WS-SLOT)
     GOBACK.
 END PROGRAM TCP-RELEASE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TCP-ACCEPT.
*> Accepts every pending connection. Each gets a free slot and a core network connection; when the
*> host or the core has no room, the connection is refused: an ERROR line, then it is closed.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY SVSTATE.
 COPY COREAPI.
 COPY CCSHIM.
 01 WS-RC                  BINARY-LONG.
 01 WS-HANDLE              BINARY-LONG.
 01 WS-SLOT                BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-ID                  BINARY-LONG.
 01 WS-KIND                BINARY-LONG.
 01 WS-TEXT                PIC X(64) VALUE "ERROR connection: refused, too many connections".
 01 WS-LENGTH              BINARY-LONG.
 01 WS-PTR                 USAGE POINTER.
 PROCEDURE DIVISION.
     MOVE 0 TO WS-RC
     PERFORM UNTIL WS-RC NOT = 0
         CALL STATIC "cc_net_accept" USING BY VALUE SV-LISTENER BY REFERENCE WS-HANDLE
             RETURNING WS-RC
         IF WS-RC = 0
             MOVE 0 TO WS-SLOT WS-ID
             PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > SV-MAX-CONNS OR WS-SLOT > 0
                 IF SV-HANDLE(WS-I) = 0
                     MOVE WS-I TO WS-SLOT
                 END-IF
             END-PERFORM
             IF WS-SLOT > 0
                 MOVE CORE-CONN-NETWORK TO WS-KIND
                 CALL "CORE-CONN-OPEN" USING WS-KIND WS-ID
             END-IF
             IF WS-ID = 0
                 SET WS-PTR TO ADDRESS OF WS-TEXT
                 MOVE FUNCTION STORED-CHAR-LENGTH(WS-TEXT) TO WS-LENGTH
                 CALL "SV-PRINT" USING WS-PTR WS-LENGTH
                 CALL STATIC "cc_net_close" USING BY VALUE WS-HANDLE
             ELSE
                 MOVE WS-HANDLE TO SV-HANDLE(WS-SLOT)
                 MOVE WS-ID TO SV-CORE-ID(WS-SLOT)
                 MOVE 0 TO SV-CLOSING(WS-SLOT) SV-OUT-PENDING(WS-SLOT)
                 MOVE 1 TO SV-OUT-START(WS-SLOT)
             END-IF
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM TCP-ACCEPT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TCP-PUMP-IN.
*> USING slot (BINARY-LONG): receives everything available. The bytes go to CORE-CONN-INPUT (or are
*> dropped once the core has handed back the close flag); a peer close releases the slot.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY SVSTATE.
 COPY COREAPI.
 COPY CCSHIM.
 01 WS-SLOT                BINARY-LONG.
 01 WS-RC                  BINARY-LONG.
 01 WS-GOT                 BINARY-LONG.
 01 WS-CAPACITY            BINARY-LONG VALUE 65536.
 01 WS-AREA                PIC X(65536).
 LINKAGE SECTION.
 01 L-SLOT                 BINARY-LONG.
 PROCEDURE DIVISION USING L-SLOT.
     MOVE L-SLOT TO WS-SLOT
     MOVE 0 TO WS-RC
     PERFORM UNTIL WS-RC NOT = 0
         CALL STATIC "cc_net_recv" USING BY VALUE SV-HANDLE(WS-SLOT) BY REFERENCE WS-AREA
             BY VALUE WS-CAPACITY BY REFERENCE WS-GOT RETURNING WS-RC
         IF WS-RC = 0 AND SV-CLOSING(WS-SLOT) = 0
             SET CB-ADDR TO ADDRESS OF WS-AREA
             MOVE WS-CAPACITY TO CB-CAPACITY
             MOVE WS-GOT TO CB-LENGTH
             CALL "CORE-CONN-INPUT" USING SV-CORE-ID(WS-SLOT) CORE-BUFFER
         END-IF
     END-PERFORM
     IF WS-RC = CC-CLOSED
         CALL "TCP-RELEASE" USING WS-SLOT
     END-IF
     GOBACK.
 END PROGRAM TCP-PUMP-IN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TCP-PUMP-OUT.
*> USING slot (BINARY-LONG): sends the slot's pending bytes, then whatever CORE-CONN-OUTPUT has, until
*> the core has nothing more or the socket takes no more (the rest stays pending). Once the close
*> flag has been handed back and everything is sent, the transport is closed. A failed send is a
*> socket error: an ERROR line and the slot is released.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY SVSTATE.
 COPY COREAPI.
 COPY CCSHIM.
 01 WS-SLOT                BINARY-LONG.
 01 WS-RC                  BINARY-LONG.
 01 WS-SENT                BINARY-LONG.
 01 WS-CLOSE               BINARY-LONG.
 01 WS-DONE                BINARY-LONG.
 01 WS-PTR                 USAGE POINTER.
 01 WS-TEXT                PIC X(64) VALUE "ERROR connection: send failed: closed or reset by the peer".
 01 WS-LENGTH              BINARY-LONG.
 LINKAGE SECTION.
 01 L-SLOT                 BINARY-LONG.
 PROCEDURE DIVISION USING L-SLOT.
     MOVE L-SLOT TO WS-SLOT
     MOVE 0 TO WS-DONE
     PERFORM UNTIL WS-DONE NOT = 0
         IF SV-OUT-PENDING(WS-SLOT) = 0 AND SV-CLOSING(WS-SLOT) = 0
             SET CB-ADDR TO ADDRESS OF SV-OUT(WS-SLOT)
             MOVE SV-OUT-CAPACITY TO CB-CAPACITY
             MOVE 0 TO CB-LENGTH WS-CLOSE
             CALL "CORE-CONN-OUTPUT" USING SV-CORE-ID(WS-SLOT) CORE-BUFFER WS-CLOSE
             MOVE 1 TO SV-OUT-START(WS-SLOT)
             MOVE CB-LENGTH TO SV-OUT-PENDING(WS-SLOT)
             MOVE WS-CLOSE TO SV-CLOSING(WS-SLOT)
         END-IF
         EVALUATE TRUE
             WHEN SV-OUT-PENDING(WS-SLOT) = 0
                 MOVE 1 TO WS-DONE
             WHEN OTHER
                 SET WS-PTR TO ADDRESS OF SV-OUT(WS-SLOT)(SV-OUT-START(WS-SLOT):1)
                 CALL STATIC "cc_net_send" USING BY VALUE SV-HANDLE(WS-SLOT) BY VALUE WS-PTR
                     BY VALUE SV-OUT-PENDING(WS-SLOT) BY REFERENCE WS-SENT RETURNING WS-RC
                 ADD WS-SENT TO SV-OUT-START(WS-SLOT)
                 SUBTRACT WS-SENT FROM SV-OUT-PENDING(WS-SLOT)
                 EVALUATE TRUE
                     WHEN WS-RC NOT = 0
                         MOVE 2 TO WS-DONE
                     WHEN SV-OUT-PENDING(WS-SLOT) > 0
                         MOVE 1 TO WS-DONE
                 END-EVALUATE
         END-EVALUATE
     END-PERFORM
     EVALUATE TRUE
         WHEN WS-DONE = 2
             SET WS-PTR TO ADDRESS OF WS-TEXT
             MOVE FUNCTION STORED-CHAR-LENGTH(WS-TEXT) TO WS-LENGTH
             CALL "SV-PRINT" USING WS-PTR WS-LENGTH
             CALL "TCP-RELEASE" USING WS-SLOT
         WHEN SV-CLOSING(WS-SLOT) = 1 AND SV-OUT-PENDING(WS-SLOT) = 0
             CALL "TCP-RELEASE" USING WS-SLOT
     END-EVALUATE
     GOBACK.
 END PROGRAM TCP-PUMP-OUT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TCP-POLL.
*> USING timeout (BINARY-LONG, milliseconds): waits up to that long for the listener or a connection
*> to become readable (cc_net_poll), then accepts new connections and receives on the ready ones.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY SVSTATE.
 01 WS-HANDLES.
    05 WS-HANDLE           BINARY-LONG OCCURS 129 TIMES.
 01 WS-SLOTS.
    05 WS-SLOT-OF          BINARY-LONG OCCURS 129 TIMES.
 01 WS-READY               PIC X(130).
 01 WS-COUNT               BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-SLOT                BINARY-LONG.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-RC                  BINARY-LONG.
 LINKAGE SECTION.
 01 L-TIMEOUT              BINARY-LONG.
 PROCEDURE DIVISION USING L-TIMEOUT.
     MOVE 1 TO WS-COUNT
     MOVE SV-LISTENER TO WS-HANDLE(1)
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > SV-MAX-CONNS
         IF SV-HANDLE(WS-I) > 0
             ADD 1 TO WS-COUNT
             MOVE SV-HANDLE(WS-I) TO WS-HANDLE(WS-COUNT)
             MOVE WS-I TO WS-SLOT-OF(WS-COUNT)
         END-IF
     END-PERFORM
     MOVE LOW-VALUES TO WS-READY
     CALL STATIC "cc_net_poll" USING BY VALUE L-TIMEOUT BY REFERENCE WS-HANDLES
         BY VALUE WS-COUNT BY VALUE WS-ZERO BY REFERENCE WS-READY RETURNING WS-RC
     PERFORM VARYING WS-I FROM 2 BY 1 UNTIL WS-I > WS-COUNT
         IF WS-READY(WS-I:1) NOT = LOW-VALUE
             MOVE WS-SLOT-OF(WS-I) TO WS-SLOT
             CALL "TCP-PUMP-IN" USING WS-SLOT
         END-IF
     END-PERFORM
     IF WS-READY(1:1) NOT = LOW-VALUE
         CALL "TCP-ACCEPT"
     END-IF
     GOBACK.
 END PROGRAM TCP-POLL.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TCP-FLUSH.
*> TCP-PUMP-OUT for every connection.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY SVSTATE.
 01 WS-I                   BINARY-LONG.
 01 WS-SLOT                BINARY-LONG.
 PROCEDURE DIVISION.
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > SV-MAX-CONNS
         IF SV-HANDLE(WS-I) > 0
             MOVE WS-I TO WS-SLOT
             CALL "TCP-PUMP-OUT" USING WS-SLOT
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM TCP-FLUSH.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TCP-CLOSE-ALL.
*> Releases every connection (TCP-RELEASE) and closes the listener.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY SVSTATE.
 01 WS-I                   BINARY-LONG.
 01 WS-SLOT                BINARY-LONG.
 PROCEDURE DIVISION.
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > SV-MAX-CONNS
         IF SV-HANDLE(WS-I) > 0
             MOVE WS-I TO WS-SLOT
             CALL "TCP-RELEASE" USING WS-SLOT
         END-IF
     END-PERFORM
     CALL STATIC "cc_net_close" USING BY VALUE SV-LISTENER
     MOVE 0 TO SV-LISTENER
     GOBACK.
 END PROGRAM TCP-CLOSE-ALL.
