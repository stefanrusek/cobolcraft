 IDENTIFICATION DIVISION.
 PROGRAM-ID. SPIKE-ENGINE.
*> spike (throwaway, plan 003): can a movement engine in a lower library read the world through a procedure pointer
*> that the caller (client or core) sets to its own program, with -fstatic-call, from static archives and from the
*> test programs' shared libraries, and what does a call cost? SPIKE-ENGINE stands for the engine in content.
*> This file holds the engine; spike_motion_world.cob the caller's cell program and the main program.
*> USING cell program pointer, calls (BINARY-LONG), sum out (BINARY-DOUBLE).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-I                   BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 LINKAGE SECTION.
 01 L-CELL                 USAGE PROGRAM-POINTER.
 01 L-CALLS                BINARY-LONG.
 01 L-SUM                  BINARY-DOUBLE.
 PROCEDURE DIVISION USING L-CELL L-CALLS L-SUM.
     MOVE 0 TO L-SUM
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > L-CALLS
         CALL L-CELL USING WS-I WS-STATE
         ADD WS-STATE TO L-SUM
     END-PERFORM
     GOBACK.
 END PROGRAM SPIKE-ENGINE.
