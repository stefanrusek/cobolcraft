       IDENTIFICATION DIVISION.
       PROGRAM-ID. SPIKE-DIRECT-OPENSSL.
      * spike (throwaway): COBOL calling OpenSSL libcrypto directly,
      * with no C glue (constitution v1.2.0 Principle I): one-shot
      * EVP_Digest with EVP_sha1 and EVP_md5.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       01 WS-DATA     PIC X(19) VALUE "OfflinePlayer:Notch".
       01 WS-ABC      PIC X(3)  VALUE "abc".
       01 WS-LEN      BINARY-DOUBLE UNSIGNED.
       01 WS-MD       PIC X(20).
       01 WS-MDLEN    BINARY-LONG UNSIGNED.
       01 WS-ALG      USAGE POINTER.
       01 WS-NULL     USAGE POINTER VALUE NULL.
       01 WS-RC       BINARY-LONG.
       PROCEDURE DIVISION.
           CALL STATIC "EVP_sha1" RETURNING WS-ALG
           MOVE 3 TO WS-LEN
           CALL STATIC "EVP_Digest" USING BY REFERENCE WS-ABC
                BY VALUE WS-LEN BY REFERENCE WS-MD
                BY REFERENCE WS-MDLEN BY VALUE WS-ALG
                BY VALUE WS-NULL RETURNING WS-RC
           DISPLAY "SHA1(abc) RC=" WS-RC " LEN=" WS-MDLEN
           DISPLAY "  " FUNCTION HEX-OF(WS-MD)
           CALL STATIC "EVP_md5" RETURNING WS-ALG
           MOVE 19 TO WS-LEN
           CALL STATIC "EVP_Digest" USING BY REFERENCE WS-DATA
                BY VALUE WS-LEN BY REFERENCE WS-MD
                BY REFERENCE WS-MDLEN BY VALUE WS-ALG
                BY VALUE WS-NULL RETURNING WS-RC
           DISPLAY "MD5(OfflinePlayer:Notch) RC=" WS-RC
           DISPLAY "  " FUNCTION HEX-OF(WS-MD(1:16))
           STOP RUN.
