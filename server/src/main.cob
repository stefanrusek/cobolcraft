*> cobolcraft-server (contracts/operator-surface.md §1, test-harness.md §2): the whole program is
*> SV-MAIN of libserver.a, which ends the run with its exit status.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. COBOLCRAFT-SERVER.
 PROCEDURE DIVISION.
     CALL "SV-MAIN".
 END PROGRAM COBOLCRAFT-SERVER.
