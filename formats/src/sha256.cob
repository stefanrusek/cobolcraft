*> SHA-256 (22 §7.2: incremental over blocks, a 32-byte digest) by direct OpenSSL EVP_MD_CTX_* calls from
*> COBOL, no glue (spike_jar_digest; constitution Principle I). The context is the FMSHA record of
*> contract/copy/FORMATS.cpy: the pointer to an EVP_MD_CTX that SHA256-INIT allocates and SHA256-FINAL
*> frees, and a state word (0 idle, 1 open). OpenSSL is linked by formats/Makefile (-lcrypto, 3.x).

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SHA256-INIT.
*> USING context (FMSHA): starts a digest. The context is open afterwards (state 1, pointer set).
*> An earlier context of the same record that was never finished is not freed: call FINAL first.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-ALGORITHM           USAGE POINTER.
 01 WS-NONE                USAGE POINTER VALUE NULL.
 01 WS-RC                  BINARY-LONG.
 LINKAGE SECTION.
 COPY FORMATS.
 PROCEDURE DIVISION USING FMSHA.
     CALL STATIC "EVP_MD_CTX_new" RETURNING FMSHA-CTX
     CALL STATIC "EVP_sha256" RETURNING WS-ALGORITHM
     CALL STATIC "EVP_DigestInit_ex" USING BY VALUE FMSHA-CTX BY VALUE WS-ALGORITHM
         BY VALUE WS-NONE RETURNING WS-RC
     MOVE 1 TO FMSHA-STATE
     MOVE 0 TO RETURN-CODE
     GOBACK.
 END PROGRAM SHA256-INIT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SHA256-UPDATE.
*> USING context (FMSHA, open), area (any size), length (BINARY-LONG): adds the bytes to the digest.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-BYTES               BINARY-DOUBLE UNSIGNED.
 01 WS-RC                  BINARY-LONG.
 LINKAGE SECTION.
 COPY FORMATS.
 01 L-AREA                 PIC X.
 01 L-LENGTH               BINARY-LONG.
 PROCEDURE DIVISION USING FMSHA L-AREA L-LENGTH.
     MOVE L-LENGTH TO WS-BYTES
     CALL STATIC "EVP_DigestUpdate" USING BY VALUE FMSHA-CTX BY REFERENCE L-AREA
         BY VALUE WS-BYTES RETURNING WS-RC
     MOVE 0 TO RETURN-CODE
     GOBACK.
 END PROGRAM SHA256-UPDATE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SHA256-FINAL.
*> USING context (FMSHA, open), digest out (PIC X(32)): ends the digest, frees the context (pointer
*> NULL, state 0).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-SIZE                BINARY-LONG UNSIGNED.
 01 WS-RC                  BINARY-LONG.
 LINKAGE SECTION.
 COPY FORMATS.
 01 L-DIGEST               PIC X(32).
 PROCEDURE DIVISION USING FMSHA L-DIGEST.
     CALL STATIC "EVP_DigestFinal_ex" USING BY VALUE FMSHA-CTX BY REFERENCE L-DIGEST
         BY REFERENCE WS-SIZE RETURNING WS-RC
     CALL STATIC "EVP_MD_CTX_free" USING BY VALUE FMSHA-CTX
     SET FMSHA-CTX TO NULL
     MOVE 0 TO FMSHA-STATE
     MOVE 0 TO RETURN-CODE
     GOBACK.
 END PROGRAM SHA256-FINAL.
