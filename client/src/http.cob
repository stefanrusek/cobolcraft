*> Non-blocking HTTP/1.1 GET client for server-pushed packs (research R10; 08 §9.1 step 1, §9.3):
*> plain COBOL over cc_net for http URLs and over cc_tls (system trust or SSL_CERT_FILE, host
*> name verification) for https URLs. One request is the record HTTP-REQUEST of CLHTTP.cpy:
*> HTTP-START connects, HTTP-STEP advances it without ever blocking (connect and handshake status,
*> sending the request, reading whatever has arrived, parsing the status line, the headers and a
*> Content-Length, chunked or read-until-close body), HTTP-RELEASE closes it and frees the body.
*> Only status 200 is success; redirects and every other status fail (R10: 08 §9.2 "HTTP error").
*> The size limit (08 §9.3) is checked against Content-Length and again while streaming.
*> Public: HTTP-URL-VALID, HTTP-PACK-HEADERS, HTTP-START, HTTP-STEP, HTTP-RELEASE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. HTTP-URL-VALID.
*> USING url (PIC X(1024)), url length (BINARY-LONG), valid out (BINARY-LONG): 1 when the URL
*> parses as a URL whose protocol is http or https (any letter case) with a non-empty host
*> (08 §9.1 step 1), else 0.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-TLS                 BINARY-LONG.
 01 WS-HOST                PIC X(300).
 01 WS-HOST-LENGTH         BINARY-LONG.
 01 WS-AUTHORITY           PIC X(300).
 01 WS-AUTHORITY-LENGTH    BINARY-LONG.
 01 WS-PORT                BINARY-LONG.
 01 WS-PATH                PIC X(1024).
 01 WS-PATH-LENGTH         BINARY-LONG.
 LINKAGE SECTION.
 01 L-URL                  PIC X(1024).
 01 L-LENGTH               BINARY-LONG.
 01 L-VALID                BINARY-LONG.
 PROCEDURE DIVISION USING L-URL L-LENGTH L-VALID.
     CALL "HTTP-URL-PARSE" USING L-URL L-LENGTH L-VALID WS-TLS WS-HOST WS-HOST-LENGTH
         WS-AUTHORITY WS-AUTHORITY-LENGTH WS-PORT WS-PATH WS-PATH-LENGTH
     GOBACK.
 END PROGRAM HTTP-URL-VALID.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. HTTP-PACK-HEADERS.
*> USING player name (PIC X(16)), name length, offline UUID (PIC X(16), the 16 raw bytes), header
*> block out (PIC X(1024)), block length out: the request headers of 08 §9.3, each "Name: value"
*> and CRLF, in the order 08 §9.3 lists them. Values:
*>   X-Minecraft-Username     the player name.
*>   X-Minecraft-UUID         the UUID as 32 lowercase hex digits in 8-4-4-4-12 hyphenated form
*>                            (08 §9.3 does not state the form; the task brief fixes hyphenated
*>                            lowercase).
*>   X-Minecraft-Version      "26.3": the game version of protocol 777 (docs/protocol/README.md,
*>                            "Java Edition 26.3").
*>   X-Minecraft-Version-ID   "26.3": the game version id from version.json (04 §KnownPack:
*>                            "the game version id from version.json, 26.3 in this artifact").
*>   X-Minecraft-Pack-Format  "97.1": the client's resource pack version (08 §2.1: resource_major
*>                            97, resource_minor 1).
*>   User-Agent               "Minecraft Java/26.3" (08 §9.3: Minecraft Java/<version>).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-HEX                 PIC X(32).
 01 WS-POINTER             BINARY-LONG.
 01 WS-CRLF                PIC XX VALUE X"0D0A".
 LINKAGE SECTION.
 01 L-NAME                 PIC X(16).
 01 L-NAME-LENGTH          BINARY-LONG.
 01 L-UUID                 PIC X(16).
 01 L-BLOCK                PIC X(1024).
 01 L-BLOCK-LENGTH         BINARY-LONG.
 PROCEDURE DIVISION USING L-NAME L-NAME-LENGTH L-UUID L-BLOCK L-BLOCK-LENGTH.
     MOVE FUNCTION LOWER-CASE(FUNCTION HEX-OF(L-UUID)) TO WS-HEX
     MOVE SPACES TO L-BLOCK
     MOVE 1 TO WS-POINTER
     STRING "X-Minecraft-Username: " L-NAME(1:L-NAME-LENGTH) WS-CRLF
         "X-Minecraft-UUID: " WS-HEX(1:8) "-" WS-HEX(9:4) "-" WS-HEX(13:4) "-" WS-HEX(17:4) "-"
         WS-HEX(21:12) WS-CRLF
         "X-Minecraft-Version: 26.3" WS-CRLF
         "X-Minecraft-Version-ID: 26.3" WS-CRLF
         "X-Minecraft-Pack-Format: 97.1" WS-CRLF
         "User-Agent: Minecraft Java/26.3" WS-CRLF
         DELIMITED BY SIZE INTO L-BLOCK WITH POINTER WS-POINTER
     COMPUTE L-BLOCK-LENGTH = WS-POINTER - 1
     GOBACK.
 END PROGRAM HTTP-PACK-HEADERS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. HTTP-START.
*> USING HTTP-REQUEST, url (PIC X(1024)), url length, header block (PIC X(1024)), header block
*> length, size limit (BINARY-LONG, bytes): releases what the record still holds, then starts the
*> non-blocking connect (cc_net_connect for http, cc_tls_connect for https; port 80 or 443 unless
*> the URL names one) and builds the request: "GET <path> HTTP/1.1", Host, the header block,
*> "Connection: close". HR-STATE 1, or 3 at once with "invalid URL" or "unresolved host".
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CCSHIM.
 01 WS-VALID               BINARY-LONG.
 01 WS-HOST                PIC X(300).
 01 WS-HOST-LENGTH         BINARY-LONG.
 01 WS-HOST-Z              PIC X(300).
 01 WS-AUTHORITY           PIC X(300).
 01 WS-AUTHORITY-LENGTH    BINARY-LONG.
 01 WS-PORT                BINARY-LONG.
 01 WS-PATH                PIC X(1024).
 01 WS-PATH-LENGTH         BINARY-LONG.
 01 WS-POINTER             BINARY-LONG.
 01 WS-RC                  BINARY-LONG.
 01 WS-TEXT                PIC X(128).
 01 WS-CRLF                PIC XX VALUE X"0D0A".
 LINKAGE SECTION.
 COPY CLHTTP.
 01 L-URL                  PIC X(1024).
 01 L-URL-LENGTH           BINARY-LONG.
 01 L-HEADERS              PIC X(1024).
 01 L-HEADERS-LENGTH       BINARY-LONG.
 01 L-LIMIT                BINARY-LONG.
 PROCEDURE DIVISION USING HTTP-REQUEST L-URL L-URL-LENGTH L-HEADERS L-HEADERS-LENGTH L-LIMIT.
     CALL "HTTP-RELEASE" USING HTTP-REQUEST
     MOVE SPACES TO HR-ERROR
     MOVE 0 TO HR-ERROR-LENGTH HR-STATUS HR-CHUNKED HR-HAS-LENGTH HR-REMAINING HR-SENT
         HR-LINE-LENGTH HR-PHASE
     MOVE L-LIMIT TO HR-LIMIT
     CALL "HTTP-URL-PARSE" USING L-URL L-URL-LENGTH WS-VALID HR-TLS WS-HOST WS-HOST-LENGTH
         WS-AUTHORITY WS-AUTHORITY-LENGTH WS-PORT WS-PATH WS-PATH-LENGTH
     IF WS-VALID = 0
         MOVE "invalid URL" TO WS-TEXT
         CALL "HTTP-FAIL" USING HTTP-REQUEST WS-TEXT
     ELSE
         MOVE SPACES TO HR-REQUEST
         MOVE 1 TO WS-POINTER
         STRING "GET " WS-PATH(1:WS-PATH-LENGTH) " HTTP/1.1" WS-CRLF
             "Host: " WS-AUTHORITY(1:WS-AUTHORITY-LENGTH) WS-CRLF
             DELIMITED BY SIZE INTO HR-REQUEST WITH POINTER WS-POINTER
         IF L-HEADERS-LENGTH > 0
             STRING L-HEADERS(1:L-HEADERS-LENGTH) DELIMITED BY SIZE INTO HR-REQUEST
                 WITH POINTER WS-POINTER
         END-IF
         STRING "Connection: close" WS-CRLF WS-CRLF DELIMITED BY SIZE INTO HR-REQUEST
             WITH POINTER WS-POINTER
         COMPUTE HR-REQUEST-LENGTH = WS-POINTER - 1
         MOVE LOW-VALUES TO WS-HOST-Z
         MOVE WS-HOST(1:WS-HOST-LENGTH) TO WS-HOST-Z(1:WS-HOST-LENGTH)
         MOVE 0 TO HR-HANDLE
         EVALUATE HR-TLS
             WHEN 1
                 CALL STATIC "cc_tls_connect" USING BY REFERENCE WS-HOST-Z BY VALUE WS-PORT
                     BY REFERENCE HR-HANDLE RETURNING WS-RC
             WHEN OTHER
                 CALL STATIC "cc_net_connect" USING BY REFERENCE WS-HOST-Z BY VALUE WS-PORT
                     BY REFERENCE HR-HANDLE RETURNING WS-RC
         END-EVALUATE
         IF WS-RC = CC-UNRESOLVED
             MOVE 0 TO HR-HANDLE
             MOVE "unresolved host" TO WS-TEXT
             CALL "HTTP-FAIL" USING HTTP-REQUEST WS-TEXT
         ELSE
             SET HR-RUNNING TO TRUE
             SET HR-CONNECTING TO TRUE
         END-IF
     END-IF
     GOBACK.
 END PROGRAM HTTP-START.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. HTTP-STEP.
*> USING HTTP-REQUEST: advances a running request without blocking: checks the connect (and TLS
*> handshake), sends what it can of the request, then reads what has arrived (at most 64 reads of
*> 16 KiB a call) and parses it. HR-STATE 2 when the whole body is in, 3 on any failure. Nothing
*> when the request is not running.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CCSHIM.
 01 WS-RC                  BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-SENT                BINARY-LONG.
 01 WS-READS               BINARY-LONG.
 01 WS-AREA                PIC X(16384).
 01 WS-CAPACITY            BINARY-LONG VALUE 16384.
 01 WS-GOT                 BINARY-LONG.
 01 WS-TEXT                PIC X(128).
 LINKAGE SECTION.
 COPY CLHTTP.
 PROCEDURE DIVISION USING HTTP-REQUEST.
     IF HR-RUNNING
         MOVE 0 TO WS-RC
         IF HR-CONNECTING
             EVALUATE HR-TLS
                 WHEN 1
                     CALL STATIC "cc_tls_status" USING BY VALUE HR-HANDLE RETURNING WS-RC
                 WHEN OTHER
                     CALL STATIC "cc_net_status" USING BY VALUE HR-HANDLE RETURNING WS-RC
             END-EVALUATE
             IF WS-RC = 0
                 SET HR-SENDING TO TRUE
             END-IF
         END-IF
         IF HR-SENDING
             COMPUTE WS-COUNT = HR-REQUEST-LENGTH - HR-SENT
             MOVE 0 TO WS-SENT
             EVALUATE HR-TLS
                 WHEN 1
                     CALL STATIC "cc_tls_send" USING BY VALUE HR-HANDLE
                         BY REFERENCE HR-REQUEST(HR-SENT + 1:WS-COUNT) BY VALUE WS-COUNT
                         BY REFERENCE WS-SENT RETURNING WS-RC
                 WHEN OTHER
                     CALL STATIC "cc_net_send" USING BY VALUE HR-HANDLE
                         BY REFERENCE HR-REQUEST(HR-SENT + 1:WS-COUNT) BY VALUE WS-COUNT
                         BY REFERENCE WS-SENT RETURNING WS-RC
             END-EVALUATE
             ADD WS-SENT TO HR-SENT
             IF HR-SENT >= HR-REQUEST-LENGTH
                 SET HR-HEAD TO TRUE
             END-IF
         END-IF
*>       A refused or reset connect, a failed handshake or verification, or a send to a closed
*>       connection.
         IF WS-RC = CC-CLOSED
             MOVE "connection failed" TO WS-TEXT
             CALL "HTTP-FAIL" USING HTTP-REQUEST WS-TEXT
         END-IF
         MOVE 0 TO WS-READS
         PERFORM UNTIL WS-READS >= 64 OR NOT HR-RUNNING OR HR-PHASE < 3
             ADD 1 TO WS-READS
             EVALUATE HR-TLS
                 WHEN 1
                     CALL STATIC "cc_tls_recv" USING BY VALUE HR-HANDLE BY REFERENCE WS-AREA
                         BY VALUE WS-CAPACITY BY REFERENCE WS-GOT RETURNING WS-RC
                 WHEN OTHER
                     CALL STATIC "cc_net_recv" USING BY VALUE HR-HANDLE BY REFERENCE WS-AREA
                         BY VALUE WS-CAPACITY BY REFERENCE WS-GOT RETURNING WS-RC
             END-EVALUATE
             EVALUATE TRUE
                 WHEN WS-RC = 0
                     CALL "HTTP-CONSUME" USING HTTP-REQUEST WS-AREA WS-GOT
                 WHEN WS-RC = CC-AGAIN
                     MOVE 64 TO WS-READS
                 WHEN HR-TO-CLOSE
                     CALL "HTTP-FINISH" USING HTTP-REQUEST
                 WHEN OTHER
                     MOVE "connection closed early" TO WS-TEXT
                     CALL "HTTP-FAIL" USING HTTP-REQUEST WS-TEXT
             END-EVALUATE
         END-PERFORM
     END-IF
     GOBACK.
 END PROGRAM HTTP-STEP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. HTTP-CONSUME.
*> USING HTTP-REQUEST, received bytes (area), count: feeds them through the response parser: body
*> bytes go to the body, line bytes (status line, headers, chunk sizes, trailers) are assembled in
*> HR-LINE and handed to HTTP-LINE at each LF. Bytes after the end of the response are ignored.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-POS                 BINARY-LONG.
 01 WS-END                 BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-AVAILABLE           BINARY-LONG.
 01 WS-TEXT                PIC X(128).
 01 B-AREA                 PIC X(1073741824) BASED.
 LINKAGE SECTION.
 COPY CLHTTP.
 01 L-AREA                 PIC X.
 01 L-COUNT                BINARY-LONG.
 PROCEDURE DIVISION USING HTTP-REQUEST L-AREA L-COUNT.
     SET ADDRESS OF B-AREA TO ADDRESS OF L-AREA
     MOVE 1 TO WS-POS
     PERFORM UNTIL WS-POS > L-COUNT OR NOT HR-RUNNING
         COMPUTE WS-AVAILABLE = L-COUNT - WS-POS + 1
         EVALUATE TRUE
             WHEN HR-BODY OR HR-CHUNK-DATA
                 COMPUTE WS-COUNT = FUNCTION MIN(HR-REMAINING, WS-AVAILABLE)
                 CALL "HTTP-BODY-APPEND" USING HTTP-REQUEST L-AREA WS-POS WS-COUNT
                 ADD WS-COUNT TO WS-POS
                 SUBTRACT WS-COUNT FROM HR-REMAINING
                 EVALUATE TRUE
                     WHEN HR-REMAINING > 0
                         CONTINUE
                     WHEN HR-BODY
                         CALL "HTTP-FINISH" USING HTTP-REQUEST
                     WHEN OTHER
                         SET HR-CHUNK-END TO TRUE
                 END-EVALUATE
             WHEN HR-TO-CLOSE
                 CALL "HTTP-BODY-APPEND" USING HTTP-REQUEST L-AREA WS-POS WS-AVAILABLE
                 ADD WS-AVAILABLE TO WS-POS
             WHEN OTHER
                 MOVE WS-POS TO WS-END
                 PERFORM UNTIL WS-END > L-COUNT
                     IF B-AREA(WS-END:1) = X"0A"
                         EXIT PERFORM
                     END-IF
                     ADD 1 TO WS-END
                 END-PERFORM
                 COMPUTE WS-COUNT = WS-END - WS-POS
                 IF HR-LINE-LENGTH + WS-COUNT > 1024
                     MOVE "malformed response" TO WS-TEXT
                     CALL "HTTP-FAIL" USING HTTP-REQUEST WS-TEXT
                 ELSE
                     IF WS-COUNT > 0
                         MOVE B-AREA(WS-POS:WS-COUNT)
                             TO HR-LINE(HR-LINE-LENGTH + 1:WS-COUNT)
                         ADD WS-COUNT TO HR-LINE-LENGTH
                     END-IF
                     COMPUTE WS-POS = WS-END + 1
                     IF WS-END <= L-COUNT
                         CALL "HTTP-LINE" USING HTTP-REQUEST
                     END-IF
                 END-IF
         END-EVALUATE
     END-PERFORM
     GOBACK.
 END PROGRAM HTTP-CONSUME.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. HTTP-LINE.
*> USING HTTP-REQUEST: handles the complete line in HR-LINE (its LF already dropped, a CR before
*> it is dropped here) by phase: the status line, a header, the empty line ending the headers, a
*> chunk size, the empty line after chunk data, a trailer line or the empty line ending them.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-LINE                PIC X(1024).
 01 WS-LENGTH              BINARY-LONG.
 01 WS-NEED                BINARY-LONG.
 01 WS-TEXT                PIC X(128).
 LINKAGE SECTION.
 COPY CLHTTP.
 PROCEDURE DIVISION USING HTTP-REQUEST.
     MOVE SPACES TO WS-LINE
     MOVE HR-LINE-LENGTH TO WS-LENGTH
     MOVE 0 TO HR-LINE-LENGTH
     IF WS-LENGTH > 0
         MOVE HR-LINE(1:WS-LENGTH) TO WS-LINE
         IF WS-LINE(WS-LENGTH:1) = X"0D"
             MOVE SPACE TO WS-LINE(WS-LENGTH:1)
             SUBTRACT 1 FROM WS-LENGTH
         END-IF
     END-IF
     EVALUATE TRUE
         WHEN HR-HEAD AND HR-STATUS = 0
             CALL "HTTP-STATUS-LINE" USING HTTP-REQUEST WS-LINE
         WHEN HR-HEAD AND WS-LENGTH > 0
             CALL "HTTP-HEADER-LINE" USING HTTP-REQUEST WS-LINE WS-LENGTH
         WHEN HR-HEAD AND HR-CHUNKED = 1
             SET HR-CHUNK-SIZE TO TRUE
         WHEN HR-HEAD AND HR-HAS-LENGTH = 1 AND HR-REMAINING > HR-LIMIT
             MOVE "file size is bigger than maximum allowed" TO WS-TEXT
             CALL "HTTP-FAIL" USING HTTP-REQUEST WS-TEXT
         WHEN HR-HEAD AND HR-HAS-LENGTH = 1 AND HR-REMAINING = 0
             CALL "HTTP-FINISH" USING HTTP-REQUEST
         WHEN HR-HEAD AND HR-HAS-LENGTH = 1
             MOVE HR-REMAINING TO WS-NEED
             CALL "HTTP-GROW" USING HTTP-REQUEST WS-NEED
             SET HR-BODY TO TRUE
         WHEN HR-HEAD
             SET HR-TO-CLOSE TO TRUE
         WHEN HR-CHUNK-SIZE
             CALL "HTTP-CHUNK-SIZE" USING HTTP-REQUEST WS-LINE WS-LENGTH
         WHEN HR-CHUNK-END AND WS-LENGTH = 0
             SET HR-CHUNK-SIZE TO TRUE
         WHEN HR-CHUNK-END
             MOVE "malformed response" TO WS-TEXT
             CALL "HTTP-FAIL" USING HTTP-REQUEST WS-TEXT
         WHEN WS-LENGTH = 0
             CALL "HTTP-FINISH" USING HTTP-REQUEST
     END-EVALUATE
     GOBACK.
 END PROGRAM HTTP-LINE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. HTTP-STATUS-LINE.
*> USING HTTP-REQUEST, line (PIC X(1024), space-padded): "HTTP/<version> <3 digits> <reason>".
*> 200 continues with the headers; another code fails with "HTTP status <code>"; anything else
*> fails with "malformed response".
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-SPACE               BINARY-LONG.
 01 WS-CODE                PIC X(3).
 01 WS-AFTER               PIC X.
 01 WS-TEXT                PIC X(128).
 LINKAGE SECTION.
 COPY CLHTTP.
 01 L-LINE                 PIC X(1024).
 PROCEDURE DIVISION USING HTTP-REQUEST L-LINE.
     MOVE "xxx" TO WS-CODE
     MOVE "x" TO WS-AFTER
     MOVE 0 TO WS-SPACE
     INSPECT L-LINE TALLYING WS-SPACE FOR CHARACTERS BEFORE INITIAL SPACE
     IF L-LINE(1:5) = "HTTP/" AND WS-SPACE <= 1019
         MOVE L-LINE(WS-SPACE + 2:3) TO WS-CODE
         MOVE L-LINE(WS-SPACE + 5:1) TO WS-AFTER
     END-IF
     EVALUATE TRUE
         WHEN WS-CODE IS NOT NUMERIC OR WS-AFTER NOT = SPACE
             MOVE "malformed response" TO WS-TEXT
             CALL "HTTP-FAIL" USING HTTP-REQUEST WS-TEXT
         WHEN WS-CODE NOT = "200"
             MOVE SPACES TO WS-TEXT
             STRING "HTTP status " WS-CODE DELIMITED BY SIZE INTO WS-TEXT
             CALL "HTTP-FAIL" USING HTTP-REQUEST WS-TEXT
         WHEN OTHER
             MOVE 200 TO HR-STATUS
     END-EVALUATE
     GOBACK.
 END PROGRAM HTTP-STATUS-LINE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. HTTP-HEADER-LINE.
*> USING HTTP-REQUEST, line (PIC X(1024)), its length (> 0): a "Name: value" header. Names
*> compare without letter case. Content-Length must be 1 to 18 digits ("malformed response"
*> otherwise); Transfer-Encoding containing "chunked" selects the chunked body, which takes
*> precedence over Content-Length. Other headers and lines without a name are ignored.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-COLON               BINARY-LONG.
 01 WS-NAME                PIC X(64).
 01 WS-VALUE               PIC X(1024).
 01 WS-DIGITS              PIC X(1024).
 01 WS-DIGITS-LENGTH       BINARY-LONG.
 01 WS-NUMBER              PIC 9(18).
 01 WS-CHUNKED             BINARY-LONG.
 01 WS-OK                  BINARY-LONG.
 01 WS-TEXT                PIC X(128).
 LINKAGE SECTION.
 COPY CLHTTP.
 01 L-LINE                 PIC X(1024).
 01 L-LENGTH               BINARY-LONG.
 PROCEDURE DIVISION USING HTTP-REQUEST L-LINE L-LENGTH.
     MOVE 0 TO WS-COLON
     INSPECT L-LINE(1:L-LENGTH) TALLYING WS-COLON FOR CHARACTERS BEFORE INITIAL ":"
     IF WS-COLON > 0 AND WS-COLON < L-LENGTH
         MOVE FUNCTION LOWER-CASE(L-LINE(1:WS-COLON)) TO WS-NAME
         MOVE L-LINE(WS-COLON + 1:) TO WS-VALUE
         MOVE SPACE TO WS-VALUE(1:1)
         EVALUATE WS-NAME
             WHEN "content-length"
                 MOVE FUNCTION TRIM(WS-VALUE LEADING) TO WS-DIGITS
                 MOVE 0 TO WS-DIGITS-LENGTH WS-OK
                 INSPECT WS-DIGITS TALLYING WS-DIGITS-LENGTH
                     FOR CHARACTERS BEFORE INITIAL SPACE
                 IF WS-DIGITS-LENGTH > 0 AND WS-DIGITS-LENGTH <= 18
                     IF WS-DIGITS(1:WS-DIGITS-LENGTH) IS NUMERIC
                             AND WS-DIGITS(WS-DIGITS-LENGTH + 1:) = SPACES
                         MOVE 1 TO WS-OK
                     END-IF
                 END-IF
                 IF WS-OK = 0
                     MOVE "malformed response" TO WS-TEXT
                     CALL "HTTP-FAIL" USING HTTP-REQUEST WS-TEXT
                 ELSE
                     MOVE WS-DIGITS(1:WS-DIGITS-LENGTH) TO WS-NUMBER
                     MOVE WS-NUMBER TO HR-REMAINING
                     MOVE 1 TO HR-HAS-LENGTH
                 END-IF
             WHEN "transfer-encoding"
                 MOVE FUNCTION LOWER-CASE(WS-VALUE) TO WS-VALUE
                 MOVE 0 TO WS-CHUNKED
                 INSPECT WS-VALUE TALLYING WS-CHUNKED FOR ALL "chunked"
                 IF WS-CHUNKED > 0
                     MOVE 1 TO HR-CHUNKED
                 END-IF
         END-EVALUATE
     END-IF
     GOBACK.
 END PROGRAM HTTP-HEADER-LINE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. HTTP-CHUNK-SIZE.
*> USING HTTP-REQUEST, line (PIC X(1024)), its length: a chunk-size line, 1 to 15 hex digits
*> optionally followed by an extension (";..."). Size 0 starts the trailer; a chunk that would
*> take the body over the limit fails the request while streaming (08 §9.3).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-I                   BINARY-LONG.
 01 WS-C                   PIC X.
 01 WS-DIGITS              BINARY-LONG.
 01 WS-MORE                BINARY-LONG.
 01 WS-SIZE                BINARY-DOUBLE.
 01 WS-TEXT                PIC X(128).
 LINKAGE SECTION.
 COPY CLHTTP.
 01 L-LINE                 PIC X(1024).
 01 L-LENGTH               BINARY-LONG.
 PROCEDURE DIVISION USING HTTP-REQUEST L-LINE L-LENGTH.
     MOVE 0 TO WS-SIZE WS-DIGITS
     MOVE 1 TO WS-MORE
     PERFORM VARYING WS-I FROM 1 BY 1
             UNTIL WS-I > L-LENGTH OR WS-MORE = 0 OR WS-DIGITS > 15
         MOVE FUNCTION LOWER-CASE(L-LINE(WS-I:1)) TO WS-C
         EVALUATE TRUE
             WHEN WS-C >= "0" AND WS-C <= "9"
                 COMPUTE WS-SIZE = WS-SIZE * 16 + FUNCTION ORD(WS-C) - 49
                 ADD 1 TO WS-DIGITS
             WHEN WS-C >= "a" AND WS-C <= "f"
                 COMPUTE WS-SIZE = WS-SIZE * 16 + FUNCTION ORD(WS-C) - 88
                 ADD 1 TO WS-DIGITS
             WHEN OTHER
                 MOVE 0 TO WS-MORE
         END-EVALUATE
     END-PERFORM
     EVALUATE TRUE
         WHEN WS-DIGITS = 0 OR WS-DIGITS > 15
             MOVE "malformed response" TO WS-TEXT
             CALL "HTTP-FAIL" USING HTTP-REQUEST WS-TEXT
         WHEN WS-SIZE = 0
             SET HR-TRAILER TO TRUE
         WHEN HR-BODY-LENGTH + WS-SIZE > HR-LIMIT
             MOVE "file size is bigger than maximum allowed" TO WS-TEXT
             CALL "HTTP-FAIL" USING HTTP-REQUEST WS-TEXT
         WHEN OTHER
             MOVE WS-SIZE TO HR-REMAINING
             SET HR-CHUNK-DATA TO TRUE
     END-EVALUATE
     GOBACK.
 END PROGRAM HTTP-CHUNK-SIZE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. HTTP-BODY-APPEND.
*> USING HTTP-REQUEST, area, offset (1-based), count: appends count bytes of the area from that
*> offset to the body, or fails the request when the body would pass the size limit (08 §9.3,
*> checked while streaming).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-NEED                BINARY-LONG.
 01 WS-TEXT                PIC X(128).
 01 B-AREA                 PIC X(1073741824) BASED.
 01 B-BODY                 PIC X(1073741824) BASED.
 LINKAGE SECTION.
 COPY CLHTTP.
 01 L-AREA                 PIC X.
 01 L-POS                  BINARY-LONG.
 01 L-COUNT                BINARY-LONG.
 PROCEDURE DIVISION USING HTTP-REQUEST L-AREA L-POS L-COUNT.
     COMPUTE WS-NEED = HR-BODY-LENGTH + L-COUNT
     IF WS-NEED > HR-LIMIT
         MOVE "file size is bigger than maximum allowed" TO WS-TEXT
         CALL "HTTP-FAIL" USING HTTP-REQUEST WS-TEXT
     ELSE
         CALL "HTTP-GROW" USING HTTP-REQUEST WS-NEED
         SET ADDRESS OF B-AREA TO ADDRESS OF L-AREA
         SET ADDRESS OF B-BODY TO HR-BODY-ADDR
         MOVE B-AREA(L-POS:L-COUNT) TO B-BODY(HR-BODY-LENGTH + 1:L-COUNT)
         MOVE WS-NEED TO HR-BODY-LENGTH
     END-IF
     GOBACK.
 END PROGRAM HTTP-BODY-APPEND.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. HTTP-GROW.
*> USING HTTP-REQUEST, bytes needed: makes the body capacity at least that: a new area of the
*> larger of the need, twice the capacity and 4096 bytes (never more than the larger of the need
*> and the limit), the body copied over, the old area freed.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-TWICE               BINARY-LONG.
 01 WS-CEILING             BINARY-LONG.
 01 WS-CAPACITY            BINARY-LONG.
 01 WS-NEW                 USAGE POINTER.
 01 B-OLD                  PIC X(1073741824) BASED.
 01 B-NEW                  PIC X(1073741824) BASED.
 LINKAGE SECTION.
 COPY CLHTTP.
 01 L-NEED                 BINARY-LONG.
 PROCEDURE DIVISION USING HTTP-REQUEST L-NEED.
     IF L-NEED > HR-BODY-CAPACITY
         COMPUTE WS-TWICE = HR-BODY-CAPACITY * 2
         COMPUTE WS-CEILING = FUNCTION MAX(L-NEED, HR-LIMIT)
         COMPUTE WS-CAPACITY = FUNCTION MAX(L-NEED, WS-TWICE, 4096)
         COMPUTE WS-CAPACITY = FUNCTION MIN(WS-CAPACITY, WS-CEILING)
         ALLOCATE WS-CAPACITY CHARACTERS RETURNING WS-NEW
         IF HR-BODY-LENGTH > 0
             SET ADDRESS OF B-OLD TO HR-BODY-ADDR
             SET ADDRESS OF B-NEW TO WS-NEW
             MOVE B-OLD(1:HR-BODY-LENGTH) TO B-NEW(1:HR-BODY-LENGTH)
         END-IF
         IF HR-BODY-ADDR NOT = NULL
             FREE HR-BODY-ADDR
         END-IF
         SET HR-BODY-ADDR TO WS-NEW
         MOVE WS-CAPACITY TO HR-BODY-CAPACITY
     END-IF
     GOBACK.
 END PROGRAM HTTP-GROW.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. HTTP-FINISH.
*> USING HTTP-REQUEST: the whole body is in: closes the connection, HR-STATE 2.
 DATA DIVISION.
 LINKAGE SECTION.
 COPY CLHTTP.
 PROCEDURE DIVISION USING HTTP-REQUEST.
     CALL "HTTP-CLOSE" USING HTTP-REQUEST
     SET HR-DONE TO TRUE
     GOBACK.
 END PROGRAM HTTP-FINISH.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. HTTP-FAIL.
*> USING HTTP-REQUEST, reason (PIC X(128)): closes the connection, HR-ERROR and its length set,
*> HR-STATE 3. The body received so far stays until HTTP-RELEASE.
 DATA DIVISION.
 LINKAGE SECTION.
 COPY CLHTTP.
 01 L-TEXT                 PIC X(128).
 PROCEDURE DIVISION USING HTTP-REQUEST L-TEXT.
     CALL "HTTP-CLOSE" USING HTTP-REQUEST
     MOVE L-TEXT TO HR-ERROR
     COMPUTE HR-ERROR-LENGTH = FUNCTION LENGTH(FUNCTION TRIM(L-TEXT TRAILING))
     SET HR-FAILED TO TRUE
     GOBACK.
 END PROGRAM HTTP-FAIL.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. HTTP-CLOSE.
*> USING HTTP-REQUEST: closes the connection when one is open (HR-HANDLE 0 afterwards).
 DATA DIVISION.
 LINKAGE SECTION.
 COPY CLHTTP.
 PROCEDURE DIVISION USING HTTP-REQUEST.
     IF HR-HANDLE > 0
         EVALUATE HR-TLS
             WHEN 1
                 CALL STATIC "cc_tls_close" USING BY VALUE HR-HANDLE
             WHEN OTHER
                 CALL STATIC "cc_net_close" USING BY VALUE HR-HANDLE
         END-EVALUATE
         MOVE 0 TO HR-HANDLE
     END-IF
     GOBACK.
 END PROGRAM HTTP-CLOSE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. HTTP-RELEASE.
*> USING HTTP-REQUEST: closes the connection, frees the body (HR-BODY-ADDR NULL, length 0) and
*> leaves the request idle (HR-STATE 0). Safe on a fresh or already released record.
 DATA DIVISION.
 LINKAGE SECTION.
 COPY CLHTTP.
 PROCEDURE DIVISION USING HTTP-REQUEST.
     CALL "HTTP-CLOSE" USING HTTP-REQUEST
     IF HR-BODY-ADDR NOT = NULL
         FREE HR-BODY-ADDR
         SET HR-BODY-ADDR TO NULL
     END-IF
     MOVE 0 TO HR-BODY-LENGTH HR-BODY-CAPACITY
     SET HR-IDLE TO TRUE
     GOBACK.
 END PROGRAM HTTP-RELEASE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. HTTP-URL-PARSE.
*> USING url (PIC X(1024)), url length, valid out, tls out (1 for https), host out (PIC X(300),
*> without IPv6 brackets), host length out, authority out (PIC X(300): host and port as written,
*> without user info, for the Host header), authority length out, port out (80 or 443 unless the
*> URL names one), path out (PIC X(1024): path and query, "/" when empty, fragment dropped), path
*> length out. Valid when the length is 8 to 1024, no byte is a space or a control character, the
*> protocol is http or https (any letter case) followed by "//", the host is 1 to 255 bytes and
*> an explicit port is 1 to 65535 (an empty port means the default).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-I                   BINARY-LONG.
 01 WS-START               BINARY-LONG.
 01 WS-END                 BINARY-LONG.
 01 WS-HOST-START          BINARY-LONG.
 01 WS-HOST-END            BINARY-LONG.
 01 WS-PORT-START          BINARY-LONG.
 01 WS-PORT-LENGTH         BINARY-LONG.
 01 WS-CLOSE               BINARY-LONG.
 01 WS-SCHEME              PIC X(8).
 01 WS-BRACKET             BINARY-LONG.
 LINKAGE SECTION.
 01 L-URL                  PIC X(1024).
 01 L-LENGTH               BINARY-LONG.
 01 L-VALID                BINARY-LONG.
 01 L-TLS                  BINARY-LONG.
 01 L-HOST                 PIC X(300).
 01 L-HOST-LENGTH          BINARY-LONG.
 01 L-AUTHORITY            PIC X(300).
 01 L-AUTHORITY-LENGTH     BINARY-LONG.
 01 L-PORT                 BINARY-LONG.
 01 L-PATH                 PIC X(1024).
 01 L-PATH-LENGTH          BINARY-LONG.
 PROCEDURE DIVISION USING L-URL L-LENGTH L-VALID L-TLS L-HOST L-HOST-LENGTH L-AUTHORITY
         L-AUTHORITY-LENGTH L-PORT L-PATH L-PATH-LENGTH.
     MOVE SPACES TO L-HOST L-AUTHORITY L-PATH
     MOVE 0 TO L-VALID L-TLS L-HOST-LENGTH L-AUTHORITY-LENGTH L-PATH-LENGTH WS-START
     MOVE 80 TO L-PORT
*>   Length, bytes and protocol.
     IF L-LENGTH >= 8 AND L-LENGTH <= 1024
         MOVE FUNCTION LOWER-CASE(L-URL(1:8)) TO WS-SCHEME
         EVALUATE TRUE
             WHEN WS-SCHEME(1:7) = "http://"
                 MOVE 8 TO WS-START
             WHEN WS-SCHEME = "https://"
                 MOVE 9 TO WS-START
                 MOVE 1 TO L-TLS
                 MOVE 443 TO L-PORT
         END-EVALUATE
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > L-LENGTH
             IF L-URL(WS-I:1) <= SPACE OR L-URL(WS-I:1) = X"7F"
                 MOVE 0 TO WS-START
             END-IF
         END-PERFORM
     END-IF
*>   Authority: up to the first "/", "?" or "#"; user info up to the last "@" is dropped.
     IF WS-START > 0
         MOVE WS-START TO WS-END WS-HOST-START
         PERFORM UNTIL WS-END > L-LENGTH
             IF L-URL(WS-END:1) = "/" OR "?" OR "#"
                 EXIT PERFORM
             END-IF
             IF L-URL(WS-END:1) = "@"
                 COMPUTE WS-HOST-START = WS-END + 1
             END-IF
             ADD 1 TO WS-END
         END-PERFORM
*>       Host and port: "[v6]:port" or "name:port".
         MOVE WS-END TO WS-HOST-END WS-PORT-START
         MOVE 0 TO WS-CLOSE WS-BRACKET
         IF WS-HOST-START < WS-END
             IF L-URL(WS-HOST-START:1) = "["
                 MOVE 1 TO WS-BRACKET
             END-IF
         END-IF
*>       In "[v6]" the colons before "]" belong to the address.
         PERFORM VARYING WS-I FROM WS-HOST-START BY 1 UNTIL WS-I >= WS-END
             IF L-URL(WS-I:1) = "]" AND WS-CLOSE = 0
                 MOVE WS-I TO WS-CLOSE
             END-IF
             IF L-URL(WS-I:1) = ":" AND WS-PORT-START = WS-END
                     AND (WS-BRACKET = 0 OR WS-CLOSE > 0)
                 MOVE WS-I TO WS-HOST-END
                 COMPUTE WS-PORT-START = WS-I + 1
             END-IF
         END-PERFORM
         IF WS-BRACKET = 1
             EVALUATE TRUE
                 WHEN WS-CLOSE = 0
                     MOVE 0 TO WS-START
                 WHEN WS-CLOSE + 1 NOT = WS-HOST-END
                     MOVE 0 TO WS-START
             END-EVALUATE
             ADD 1 TO WS-HOST-START
             MOVE WS-CLOSE TO WS-HOST-END
         END-IF
         COMPUTE L-HOST-LENGTH = WS-HOST-END - WS-HOST-START
         COMPUTE WS-PORT-LENGTH = WS-END - WS-PORT-START
         IF L-HOST-LENGTH < 1 OR L-HOST-LENGTH > 255 OR WS-PORT-LENGTH > 5
             MOVE 0 TO WS-START
         END-IF
     END-IF
     IF WS-START > 0 AND WS-PORT-LENGTH > 0
         IF L-URL(WS-PORT-START:WS-PORT-LENGTH) IS NUMERIC
             COMPUTE L-PORT = FUNCTION NUMVAL(L-URL(WS-PORT-START:WS-PORT-LENGTH))
         END-IF
         IF L-URL(WS-PORT-START:WS-PORT-LENGTH) IS NOT NUMERIC OR L-PORT < 1 OR L-PORT > 65535
             MOVE 0 TO WS-START
         END-IF
     END-IF
*>   Results; the path keeps the query and drops the fragment.
     IF WS-START > 0
         MOVE 1 TO L-VALID
         MOVE L-URL(WS-HOST-START:L-HOST-LENGTH) TO L-HOST
         COMPUTE L-AUTHORITY-LENGTH = WS-END - WS-HOST-START
         IF L-URL(WS-HOST-START - 1:1) = "["
             SUBTRACT 1 FROM WS-HOST-START
             ADD 1 TO L-AUTHORITY-LENGTH
         END-IF
         MOVE L-URL(WS-HOST-START:L-AUTHORITY-LENGTH) TO L-AUTHORITY
         MOVE "/" TO L-PATH
         MOVE 1 TO L-PATH-LENGTH
         MOVE WS-END TO WS-I
         PERFORM UNTIL WS-I > L-LENGTH OR L-URL(WS-I:1) = "#"
             ADD 1 TO WS-I
         END-PERFORM
         COMPUTE WS-PORT-LENGTH = WS-I - WS-END
         IF WS-PORT-LENGTH > 0
             IF L-URL(WS-END:1) = "/"
                 MOVE 0 TO L-PATH-LENGTH
             END-IF
             MOVE L-URL(WS-END:WS-PORT-LENGTH) TO L-PATH(L-PATH-LENGTH + 1:WS-PORT-LENGTH)
             ADD WS-PORT-LENGTH TO L-PATH-LENGTH
         END-IF
     END-IF
     GOBACK.
 END PROGRAM HTTP-URL-PARSE.
