*> CORE-PACKS-STATUS (contracts/core-host-delta.md section 2; 22 section 9.2): USING generated directory
*> (PIC X(1100), z-string or space padded), status out (BINARY-LONG, CT-PACKS-* of CONTENT.cpy), reason out
*> (PIC X(128), the English console wording of 22 section 9.2, spaces for ok). Delegates to
*> CONTENT-PACKS-CHECK, which reads no jar and hashes nothing.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. CORE-PACKS-STATUS.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-DIR                  PIC X(1100).
 01 L-STATUS               BINARY-LONG.
 01 L-REASON               PIC X(128).
 PROCEDURE DIVISION USING L-DIR L-STATUS L-REASON.
     CALL "CONTENT-PACKS-CHECK" USING L-DIR L-STATUS L-REASON
     GOBACK.
 END PROGRAM CORE-PACKS-STATUS.
