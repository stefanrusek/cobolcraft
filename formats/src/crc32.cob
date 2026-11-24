*> The zip CRC-32 (22 §7.2: reflected, polynomial 0xEDB88320, initial and final xor 0xFFFFFFFF) is
*> the crc32 function of zlib, which the package already links for cc_inflate: a direct CALL STATIC from
*> COBOL, no glue (constitution Principle I).

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CRC32.
*> USING area (any size), length (BINARY-LONG), running value (BINARY-LONG UNSIGNED, in and out):
*> continues the CRC-32 of the bytes before with the length bytes of the area. The running value of
*> no bytes is 0; the nine bytes "123456789" from 0 give 3421780262 (hex cbf43926, FM-CRC-CHECK-VALUE
*> of FORMATS.cpy). A length of 0 leaves the running value unchanged.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-CRC                 BINARY-DOUBLE.
 01 WS-BYTES               BINARY-LONG UNSIGNED.
*> cobc takes the result of a C call as a C int: the low 32 bits arrive signed.
 01 WS-RESULT              BINARY-LONG.
 01 WS-WRAP                BINARY-DOUBLE VALUE 4294967296.
 LINKAGE SECTION.
 01 L-AREA                 PIC X.
 01 L-LENGTH               BINARY-LONG.
 01 L-VALUE                BINARY-LONG UNSIGNED.
 PROCEDURE DIVISION USING L-AREA L-LENGTH L-VALUE.
     MOVE L-VALUE TO WS-CRC
     MOVE L-LENGTH TO WS-BYTES
     CALL STATIC "crc32" USING BY VALUE WS-CRC BY REFERENCE L-AREA BY VALUE WS-BYTES
         RETURNING WS-RESULT
     MOVE WS-RESULT TO WS-CRC
     IF WS-RESULT < 0
         ADD WS-WRAP TO WS-CRC
     END-IF
     MOVE WS-CRC TO L-VALUE
     GOBACK.
 END PROGRAM CRC32.
