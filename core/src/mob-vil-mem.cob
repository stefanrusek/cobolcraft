*> The villager brain memory store (core/copy/VLMEM.cpy; docs/protocol/18 section 4.5, 44 part 3 section 2; lane 002-lane-p49p). One memory model for every behaviour: a memory is read, written and
*> erased by type id, whatever holds it. The claimed points of interest (MT-HOME, MT-JOB-SITE, MT-POTENTIAL-JOB-SITE, MT-MEETING-POINT) live in the claim table (VILPOI.cpy: a ticket each) and are read and written
*> through it; the potential job site is the claim of the job site while VL-POT is 1 and the job_site memory the claim once it is 0. Every other memory is a row of VM-M.
*>   VM-GET USING slot, type, present out, dim, x, y, z, num, num2 out    the memory (an expired one is erased and reads as absent)
*>   VM-PUT USING slot, type, dim, x, y, z, num, num2, ticks              set it; ticks 0 = never expires, else it is erased when read at or after CW-TICKS + ticks
*>   VM-ERASE USING slot, type                                          erase it (a claimed point of interest: the claim is released)
*>   VM-HAS USING slot, type, present out
*>   VM-AT USING slot, type, dim, x, y, z   a position memory;  VM-NOTE USING slot, type, num   a number;  VM-NOTE-TTL USING slot, type, num, num2, ticks   two numbers that expire
*>   VM-CLEAR USING slot                                                a new or released slot has no memory and no timers

 IDENTIFICATION DIVISION.
 PROGRAM-ID. VM-CLEAR.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY VLMEM.
 LINKAGE SECTION.
 01 L-SLOT                  BINARY-LONG.
 PROCEDURE DIVISION USING L-SLOT.
     INITIALIZE VM-V(L-SLOT)
     GOBACK.
 END PROGRAM VM-CLEAR.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. VM-KIND-OF.
*> USING type, claim kind out (0 job site, 2 home, 3 meeting point), claimed out (1 for a type that lives in the claim table): the claim table of VILPOI.cpy.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY VLMEM.
 LINKAGE SECTION.
 01 L-TYPE                  BINARY-LONG.
 01 L-KIND                  BINARY-LONG.
 01 L-CLAIMED               BINARY-LONG.
 PROCEDURE DIVISION USING L-TYPE L-KIND L-CLAIMED.
     MOVE 1 TO L-CLAIMED
     EVALUATE L-TYPE
         WHEN MT-HOME
             MOVE 2 TO L-KIND
         WHEN MT-MEETING-POINT
             MOVE 3 TO L-KIND
         WHEN MT-JOB-SITE
             MOVE 0 TO L-KIND
         WHEN MT-POTENTIAL-JOB-SITE
             MOVE 0 TO L-KIND
         WHEN OTHER
             MOVE 0 TO L-CLAIMED
     END-EVALUATE
     GOBACK.
 END PROGRAM VM-KIND-OF.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. VM-GET.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY VLMEM.
 COPY VILSTATE.
 COPY CORESTATE.
 01 WS-KIND                 BINARY-LONG.
 01 WS-CLAIMED              BINARY-LONG.
 01 WS-FOUND                BINARY-LONG.
 LINKAGE SECTION.
 01 L-SLOT                  BINARY-LONG.
 01 L-TYPE                  BINARY-LONG.
 01 L-PRESENT               BINARY-LONG.
 01 L-DIM                   BINARY-LONG.
 01 L-X                     BINARY-LONG.
 01 L-Y                     BINARY-LONG.
 01 L-Z                     BINARY-LONG.
 01 L-NUM                   BINARY-LONG.
 01 L-NUM2                  BINARY-LONG.
 PROCEDURE DIVISION USING L-SLOT L-TYPE L-PRESENT L-DIM L-X L-Y L-Z L-NUM L-NUM2.
     MOVE 0 TO L-PRESENT L-NUM L-NUM2
     CALL "VM-KIND-OF" USING L-TYPE WS-KIND WS-CLAIMED
     IF WS-CLAIMED = 1
         CALL "VPX-OF" USING VL-ID(L-SLOT) WS-KIND L-DIM L-X L-Y L-Z WS-FOUND
*>       The job claim is the potential job site while VL-POT is 1, the job_site memory after.
         IF WS-FOUND = 1
             MOVE 1 TO L-PRESENT
             IF L-TYPE = MT-POTENTIAL-JOB-SITE AND VL-POT(L-SLOT) = 0
                 MOVE 0 TO L-PRESENT
             END-IF
             IF L-TYPE = MT-JOB-SITE AND VL-POT(L-SLOT) = 1
                 MOVE 0 TO L-PRESENT
             END-IF
         END-IF
         GOBACK
     END-IF
     IF VM-SET(L-SLOT, L-TYPE) = 1
         IF VM-EXP(L-SLOT, L-TYPE) > 0 AND CW-TICKS >= VM-EXP(L-SLOT, L-TYPE)
             INITIALIZE VM-M(L-SLOT, L-TYPE)
         ELSE
             MOVE 1 TO L-PRESENT
             MOVE VM-DIM(L-SLOT, L-TYPE) TO L-DIM
             MOVE VM-X(L-SLOT, L-TYPE) TO L-X
             MOVE VM-Y(L-SLOT, L-TYPE) TO L-Y
             MOVE VM-Z(L-SLOT, L-TYPE) TO L-Z
             MOVE VM-NUM(L-SLOT, L-TYPE) TO L-NUM
             MOVE VM-NUM2(L-SLOT, L-TYPE) TO L-NUM2
         END-IF
     END-IF
     GOBACK.
 END PROGRAM VM-GET.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. VM-HAS.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-DIM                  BINARY-LONG.
 01 WS-X                    BINARY-LONG.
 01 WS-Y                    BINARY-LONG.
 01 WS-Z                    BINARY-LONG.
 01 WS-NUM                  BINARY-LONG.
 01 WS-NUM2                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-SLOT                  BINARY-LONG.
 01 L-TYPE                  BINARY-LONG.
 01 L-PRESENT               BINARY-LONG.
 PROCEDURE DIVISION USING L-SLOT L-TYPE L-PRESENT.
     CALL "VM-GET" USING L-SLOT L-TYPE L-PRESENT WS-DIM WS-X WS-Y WS-Z WS-NUM WS-NUM2
     GOBACK.
 END PROGRAM VM-HAS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. VM-PUT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY VLMEM.
 COPY VILSTATE.
 COPY CORESTATE.
 01 WS-KIND                 BINARY-LONG.
 01 WS-CLAIMED              BINARY-LONG.
 LINKAGE SECTION.
 01 L-SLOT                  BINARY-LONG.
 01 L-TYPE                  BINARY-LONG.
 01 L-DIM                   BINARY-LONG.
 01 L-X                     BINARY-LONG.
 01 L-Y                     BINARY-LONG.
 01 L-Z                     BINARY-LONG.
 01 L-NUM                   BINARY-LONG.
 01 L-NUM2                  BINARY-LONG.
 01 L-TICKS                 BINARY-LONG.
 PROCEDURE DIVISION USING L-SLOT L-TYPE L-DIM L-X L-Y L-Z L-NUM L-NUM2 L-TICKS.
     CALL "VM-KIND-OF" USING L-TYPE WS-KIND WS-CLAIMED
     IF WS-CLAIMED = 1
         CALL "VPX-CLAIM" USING VL-ID(L-SLOT) WS-KIND L-DIM L-X L-Y L-Z
         IF L-TYPE = MT-POTENTIAL-JOB-SITE
             MOVE 1 TO VL-POT(L-SLOT)
         END-IF
         IF L-TYPE = MT-JOB-SITE
             MOVE 0 TO VL-POT(L-SLOT)
         END-IF
         GOBACK
     END-IF
     MOVE 1 TO VM-SET(L-SLOT, L-TYPE)
     MOVE L-DIM TO VM-DIM(L-SLOT, L-TYPE)
     MOVE L-X TO VM-X(L-SLOT, L-TYPE)
     MOVE L-Y TO VM-Y(L-SLOT, L-TYPE)
     MOVE L-Z TO VM-Z(L-SLOT, L-TYPE)
     MOVE L-NUM TO VM-NUM(L-SLOT, L-TYPE)
     MOVE L-NUM2 TO VM-NUM2(L-SLOT, L-TYPE)
     MOVE 0 TO VM-EXP(L-SLOT, L-TYPE)
     IF L-TICKS > 0
         COMPUTE VM-EXP(L-SLOT, L-TYPE) = CW-TICKS + L-TICKS
     END-IF
     GOBACK.
 END PROGRAM VM-PUT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. VM-ERASE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY VLMEM.
 COPY VILSTATE.
 01 WS-KIND                 BINARY-LONG.
 01 WS-CLAIMED              BINARY-LONG.
 LINKAGE SECTION.
 01 L-SLOT                  BINARY-LONG.
 01 L-TYPE                  BINARY-LONG.
 PROCEDURE DIVISION USING L-SLOT L-TYPE.
     CALL "VM-KIND-OF" USING L-TYPE WS-KIND WS-CLAIMED
     IF WS-CLAIMED = 1
         CALL "VPX-RELEASE-KIND" USING VL-ID(L-SLOT) WS-KIND
         MOVE 0 TO VL-POT(L-SLOT)
         GOBACK
     END-IF
     INITIALIZE VM-M(L-SLOT, L-TYPE)
     GOBACK.
 END PROGRAM VM-ERASE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. VM-AT.
*> USING slot, type, dim, x, y, z: a memory that is a position and nothing else, never expiring.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-A                    BINARY-LONG VALUE 0.
 01 WS-B                    BINARY-LONG VALUE 0.
 01 WS-C                    BINARY-LONG VALUE 0.
 LINKAGE SECTION.
 01 L-SLOT                  BINARY-LONG.
 01 L-TYPE                  BINARY-LONG.
 01 L-DIM                   BINARY-LONG.
 01 L-X                     BINARY-LONG.
 01 L-Y                     BINARY-LONG.
 01 L-Z                     BINARY-LONG.
 PROCEDURE DIVISION USING L-SLOT L-TYPE L-DIM L-X L-Y L-Z.
     CALL "VM-PUT" USING L-SLOT L-TYPE L-DIM L-X L-Y L-Z WS-A WS-B WS-C
     GOBACK.
 END PROGRAM VM-AT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. VM-NOTE.
*> USING slot, type, num: a memory that is one number (a game tick), never expiring.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-DIM                  BINARY-LONG VALUE 0.
 01 WS-X                    BINARY-LONG VALUE 0.
 01 WS-Y                    BINARY-LONG VALUE 0.
 01 WS-Z                    BINARY-LONG VALUE 0.
 01 WS-NUM2                 BINARY-LONG VALUE 0.
 01 WS-TTL                  BINARY-LONG VALUE 0.
 LINKAGE SECTION.
 01 L-SLOT                  BINARY-LONG.
 01 L-TYPE                  BINARY-LONG.
 01 L-NUM                   BINARY-LONG.
 PROCEDURE DIVISION USING L-SLOT L-TYPE L-NUM.
     CALL "VM-PUT" USING L-SLOT L-TYPE WS-DIM WS-X WS-Y WS-Z L-NUM WS-NUM2 WS-TTL
     GOBACK.
 END PROGRAM VM-NOTE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. VM-NOTE-TTL.
*> USING slot, type, num, num2, ticks: two numbers that expire (ticks 0 = never).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-DIM                  BINARY-LONG VALUE 0.
 01 WS-X                    BINARY-LONG VALUE 0.
 01 WS-Y                    BINARY-LONG VALUE 0.
 01 WS-Z                    BINARY-LONG VALUE 0.
 LINKAGE SECTION.
 01 L-SLOT                  BINARY-LONG.
 01 L-TYPE                  BINARY-LONG.
 01 L-NUM                   BINARY-LONG.
 01 L-NUM2                  BINARY-LONG.
 01 L-TTL                   BINARY-LONG.
 PROCEDURE DIVISION USING L-SLOT L-TYPE L-NUM L-NUM2 L-TTL.
     CALL "VM-PUT" USING L-SLOT L-TYPE WS-DIM WS-X WS-Y WS-Z L-NUM L-NUM2 L-TTL
     GOBACK.
 END PROGRAM VM-NOTE-TTL.
