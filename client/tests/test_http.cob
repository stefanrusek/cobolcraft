*> Implementation test of client/src/http.cob (HTTP-URL-VALID, HTTP-PACK-HEADERS, HTTP-START,
*> HTTP-STEP, HTTP-RELEASE; research R10, 08 §9.1 step 1 and §9.3) against tools/testsrv/testsrv.py
*> over real loopback HTTP and HTTPS (TEST-TESTSRV-START trusts the test CA through SSL_CERT_FILE):
*> GET with Content-Length and chunked bodies, the 08 §9.3 request headers (testsrv --request-log),
*> non-200 statuses as failures, the 250 MiB-style size limit by declared length and while
*> streaming, unresolvable host, refused connection and TLS verification failure, URL validation.
*> Response shapes testsrv cannot produce (no length, early close, malformed lines, chunk
*> extensions and trailers) come from a raw loopback server in this program (HT-RAW).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-HTTP.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CLHTTP.
 COPY CCSHIM.
 01 WS-WWW                 PIC X(256) VALUE "build/client-test-http/www".
 01 WS-OPTIONS             PIC X(256).
 01 WS-HTTP                BINARY-LONG.
 01 WS-HTTPS               BINARY-LONG.
 01 WS-PORT-TEXT           PIC 9(5).
 01 WS-URL                 PIC X(1024).
 01 WS-URL-LENGTH          BINARY-LONG.
 01 WS-VALID               BINARY-LONG.
 01 WS-LIMIT               BINARY-LONG.
 01 WS-BIG-LIMIT           BINARY-LONG VALUE 262144000.
 01 WS-HEADERS             PIC X(1024).
 01 WS-HEADERS-LENGTH      BINARY-LONG.
 01 WS-NO-HEADERS          PIC X(1024) VALUE SPACES.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-NAME                PIC X(16) VALUE "Notch".
 01 WS-NAME-LENGTH         BINARY-LONG VALUE 5.
 01 WS-UUID                PIC X(16).
 01 WS-TEXT                PIC X(1024).
 01 WS-LOG                 PIC X(1024).
 01 WS-LOG-PATH            PIC X(256) VALUE "build/client-test-http/requests.log".
 01 WS-LOG-CAP             BINARY-LONG VALUE 1024.
 01 WS-LOG-LENGTH          BINARY-LONG.
 01 WS-OK                  BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-RC                  BINARY-LONG.
 01 WS-LISTENER            BINARY-LONG.
 01 WS-PORT                BINARY-LONG.
 01 WS-CRLF                PIC XX VALUE X"0D0A".
 01 WS-RAW                 PIC X(4096).
 01 WS-RAW-LENGTH          BINARY-LONG.
 01 WS-LONG-NAME           PIC X(1100) VALUE ALL "a".
*> URL validation table (08 §9.1 step 1): expected flag, then the URL.
 01 WS-URL-CASES.
    05 FILLER PIC X(48) VALUE "1http://a/".
    05 FILLER PIC X(48) VALUE "1https://example.com:8443/p?q=1#f".
    05 FILLER PIC X(48) VALUE "1HTTP://Example.COM".
    05 FILLER PIC X(48) VALUE "1http://user:pw@host/x".
    05 FILLER PIC X(48) VALUE "1http://[::1]:8080/".
    05 FILLER PIC X(48) VALUE "1http://host:/x".
    05 FILLER PIC X(48) VALUE "1http://host?q".
    05 FILLER PIC X(48) VALUE "0ftp://a/".
    05 FILLER PIC X(48) VALUE "0httpx://a/".
    05 FILLER PIC X(48) VALUE "0http:/a".
    05 FILLER PIC X(48) VALUE "0http://".
    05 FILLER PIC X(48) VALUE "0http:///x".
    05 FILLER PIC X(48) VALUE "0http://:80/".
    05 FILLER PIC X(48) VALUE "0http://a:x/".
    05 FILLER PIC X(48) VALUE "0http://a:70000/".
    05 FILLER PIC X(48) VALUE "0http://a:0/".
    05 FILLER PIC X(48) VALUE "0http://a:123456/".
    05 FILLER PIC X(48) VALUE "0http://[::1/".
    05 FILLER PIC X(48) VALUE "0http://[::1]x/".
    05 FILLER PIC X(48) VALUE "0http://[]/".
    05 FILLER PIC X(48) VALUE "0http://a b/".
    05 FILLER PIC X(48) VALUE "0file:///etc/passwd".
    05 FILLER PIC X(48) VALUE "0".
 01 WS-URL-TABLE REDEFINES WS-URL-CASES.
    05 WS-URL-CASE OCCURS 23 TIMES.
       10 WS-URL-EXPECT    PIC X.
       10 WS-URL-TEXT      PIC X(47).
 PROCEDURE DIVISION.
     CALL "SYSTEM" USING "rm -rf build/client-test-http && mkdir -p build/client-test-http/www"
         & " && python3 -c ""import sys; open(sys.argv[1], 'wb').write(bytes(i % 251 for i in"
         & " range(10000)))"" build/client-test-http/www/body.bin"
     MOVE FUNCTION HEX-TO-CHAR("b50ad385829d3141a2167e7d7539ba7f") TO WS-UUID

*>   The record layout.
     MOVE "N" TO TL-MODE
     MOVE "http request record is 3784 bytes" TO TL-CASE
     MOVE 3784 TO TL-EXPECTED-N
     MOVE LENGTH OF HTTP-REQUEST TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   URL validation (08 §9.1 step 1).
     MOVE "T" TO TL-MODE
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 23
         MOVE SPACES TO WS-URL TL-CASE
         MOVE WS-URL-TEXT(WS-I) TO WS-URL
         MOVE 0 TO WS-URL-LENGTH
         IF WS-URL NOT = SPACES
             COMPUTE WS-URL-LENGTH = FUNCTION LENGTH(FUNCTION TRIM(WS-URL TRAILING))
         END-IF
         STRING "http url valid " WS-URL-EXPECT(WS-I) " for '" FUNCTION TRIM(WS-URL) "'"
             DELIMITED BY SIZE INTO TL-CASE
         MOVE -1 TO WS-VALID
         CALL "HTTP-URL-VALID" USING WS-URL WS-URL-LENGTH WS-VALID
         MOVE WS-URL-EXPECT(WS-I) TO TL-EXPECTED
         MOVE WS-VALID TO WS-PORT-TEXT
         MOVE WS-PORT-TEXT(5:1) TO TL-OBSERVED
         IF WS-VALID < 0
             MOVE "-1" TO TL-OBSERVED
         END-IF
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     END-PERFORM
     MOVE "http url valid 0 for a URL longer than its field length 1025" TO TL-CASE
     MOVE ALL "a" TO WS-URL
     MOVE "http://" TO WS-URL(1:7)
     MOVE 1025 TO WS-URL-LENGTH
     CALL "HTTP-URL-VALID" USING WS-URL WS-URL-LENGTH WS-VALID
     MOVE "0" TO TL-EXPECTED
     MOVE WS-VALID TO WS-PORT-TEXT
     MOVE WS-PORT-TEXT(5:1) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "http url valid 0 for a host longer than 255 bytes" TO TL-CASE
     MOVE ALL "a" TO WS-URL
     MOVE "http://" TO WS-URL(1:7)
     MOVE "/" TO WS-URL(270:1)
     MOVE 270 TO WS-URL-LENGTH
     CALL "HTTP-URL-VALID" USING WS-URL WS-URL-LENGTH WS-VALID
     MOVE WS-VALID TO WS-PORT-TEXT
     MOVE WS-PORT-TEXT(5:1) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   The 08 §9.3 request headers.
     MOVE "http pack headers are the 08 §9.3 request headers, each ending in CRLF" TO TL-CASE
     CALL "HTTP-PACK-HEADERS" USING WS-NAME WS-NAME-LENGTH WS-UUID WS-HEADERS WS-HEADERS-LENGTH
     MOVE SPACES TO TL-EXPECTED TL-OBSERVED
     STRING "X-Minecraft-Username: Notch|"
         "X-Minecraft-UUID: b50ad385-829d-3141-a216-7e7d7539ba7f|"
         "X-Minecraft-Version: 26.3|X-Minecraft-Version-ID: 26.3|X-Minecraft-Pack-Format: 97.1|"
         "User-Agent: Minecraft Java/26.3|" DELIMITED BY SIZE INTO TL-EXPECTED
     MOVE 0 TO WS-OK
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-HEADERS-LENGTH
         EVALUATE WS-HEADERS(WS-I:1)
             WHEN X"0D"
                 CONTINUE
             WHEN X"0A"
                 ADD 1 TO WS-OK
                 MOVE "|" TO TL-OBSERVED(WS-OK:1)
             WHEN OTHER
                 ADD 1 TO WS-OK
                 MOVE WS-HEADERS(WS-I:1) TO TL-OBSERVED(WS-OK:1)
         END-EVALUATE
     END-PERFORM
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Invalid URL and unresolvable host fail at once.
     MOVE "http start of an invalid URL fails at once with invalid URL" TO TL-CASE
     MOVE "ftp://127.0.0.1/body.bin" TO WS-URL
     MOVE 24 TO WS-URL-LENGTH
     CALL "HTTP-START" USING HTTP-REQUEST WS-URL WS-URL-LENGTH WS-NO-HEADERS WS-ZERO WS-BIG-LIMIT
     MOVE "3 0 invalid URL" TO TL-EXPECTED
     CALL "HT-SUMMARY" USING HTTP-REQUEST TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "http start of an unresolvable host fails at once (http)" TO TL-CASE
     MOVE "http://nonexistent.invalid/pack.zip" TO WS-URL
     MOVE 35 TO WS-URL-LENGTH
     CALL "HTTP-START" USING HTTP-REQUEST WS-URL WS-URL-LENGTH WS-NO-HEADERS WS-ZERO WS-BIG-LIMIT
     MOVE "3 0 unresolved host" TO TL-EXPECTED
     CALL "HT-SUMMARY" USING HTTP-REQUEST TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "http start of an unresolvable host fails at once (https)" TO TL-CASE
     MOVE "https://nonexistent.invalid/pack.zip" TO WS-URL
     MOVE 36 TO WS-URL-LENGTH
     CALL "HTTP-START" USING HTTP-REQUEST WS-URL WS-URL-LENGTH WS-NO-HEADERS WS-ZERO WS-BIG-LIMIT
     CALL "HT-SUMMARY" USING HTTP-REQUEST TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   A refused connection.
     MOVE "http get of a refused connection fails with connection failed" TO TL-CASE
     CALL STATIC "cc_net_listen" USING BY VALUE WS-ZERO BY REFERENCE WS-LISTENER
         BY REFERENCE WS-PORT RETURNING WS-RC
     CALL STATIC "cc_net_close" USING BY VALUE WS-LISTENER
     MOVE WS-PORT TO WS-PORT-TEXT
     MOVE SPACES TO WS-URL
     STRING "http://127.0.0.1:" WS-PORT-TEXT "/body.bin" DELIMITED BY SIZE INTO WS-URL
     CALL "HT-GET" USING WS-URL WS-NO-HEADERS WS-ZERO WS-BIG-LIMIT HTTP-REQUEST
     MOVE "3 0 connection failed" TO TL-EXPECTED
     CALL "HT-SUMMARY" USING HTTP-REQUEST TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Content-Length bodies over HTTP and HTTPS.
     MOVE SPACES TO WS-OPTIONS
     CALL "TEST-TESTSRV-START" USING WS-WWW WS-OPTIONS WS-HTTP WS-HTTPS
     MOVE "http get over cc_net with Content-Length delivers the whole body" TO TL-CASE
     CALL "HT-URL" USING WS-HTTP WS-ZERO WS-URL
     CALL "HT-GET" USING WS-URL WS-NO-HEADERS WS-ZERO WS-BIG-LIMIT HTTP-REQUEST
     MOVE "2 10000 body ok" TO TL-EXPECTED
     CALL "HT-SUMMARY" USING HTTP-REQUEST TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "http release closes, frees the body and leaves the request idle" TO TL-CASE
     CALL "HTTP-RELEASE" USING HTTP-REQUEST
     MOVE "0 0 null handle 0" TO TL-EXPECTED
     CALL "HT-SUMMARY" USING HTTP-REQUEST WS-TEXT
     MOVE WS-TEXT TO TL-OBSERVED
     IF HR-BODY-ADDR = NULL AND HR-HANDLE = 0
         STRING FUNCTION TRIM(WS-TEXT) " null handle 0" DELIMITED BY SIZE INTO TL-OBSERVED
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "http get over cc_tls with Content-Length delivers the whole body" TO TL-CASE
     CALL "HT-URL" USING WS-HTTPS WS-ONE WS-URL
     CALL "HT-GET" USING WS-URL WS-NO-HEADERS WS-ZERO WS-BIG-LIMIT HTTP-REQUEST
     MOVE "2 10000 body ok" TO TL-EXPECTED
     CALL "HT-SUMMARY" USING HTTP-REQUEST TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "http get of a missing file fails with HTTP status 404" TO TL-CASE
     MOVE WS-HTTP TO WS-PORT-TEXT
     MOVE SPACES TO WS-URL
     STRING "http://127.0.0.1:" WS-PORT-TEXT "/missing.zip" DELIMITED BY SIZE INTO WS-URL
     CALL "HT-GET" USING WS-URL WS-NO-HEADERS WS-ZERO WS-BIG-LIMIT HTTP-REQUEST
     MOVE "3 0 HTTP status 404" TO TL-EXPECTED
     CALL "HT-SUMMARY" USING HTTP-REQUEST TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   TLS verification failure: the test CA is not trusted.
     MOVE "http get over cc_tls fails with connection failed when the certificate is not trusted"
         TO TL-CASE
     SET ENVIRONMENT "SSL_CERT_FILE" TO "build/client-test-http/absent.pem"
     CALL "HT-URL" USING WS-HTTPS WS-ONE WS-URL
     CALL "HT-GET" USING WS-URL WS-NO-HEADERS WS-ZERO WS-BIG-LIMIT HTTP-REQUEST
     MOVE "3 0 connection failed" TO TL-EXPECTED
     CALL "HT-SUMMARY" USING HTTP-REQUEST TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   The request headers as the server sees them.
     MOVE "--request-log build/client-test-http/requests.log" TO WS-OPTIONS
     CALL "TEST-TESTSRV-START" USING WS-WWW WS-OPTIONS WS-HTTP WS-HTTPS
     MOVE "http get sends GET <path>, Host, the 08 §9.3 headers and Connection: close" TO TL-CASE
     MOVE WS-HTTP TO WS-PORT-TEXT
     MOVE SPACES TO WS-URL
     STRING "http://127.0.0.1:" WS-PORT-TEXT "/body.bin?x=1#frag" DELIMITED BY SIZE INTO WS-URL
     CALL "HT-GET" USING WS-URL WS-HEADERS WS-HEADERS-LENGTH WS-BIG-LIMIT HTTP-REQUEST
     MOVE SPACES TO WS-LOG TL-EXPECTED
     CALL "TEST-READ-FILE" USING WS-LOG-PATH WS-LOG WS-LOG-CAP WS-LOG-LENGTH
     INSPECT WS-LOG REPLACING ALL X"0A" BY "|"
     STRING "GET /body.bin?x=1 HTTP/1.1|Host: 127.0.0.1:" WS-PORT-TEXT
         "|X-Minecraft-Username: Notch|"
         "X-Minecraft-UUID: b50ad385-829d-3141-a216-7e7d7539ba7f|"
         "X-Minecraft-Version: 26.3|X-Minecraft-Version-ID: 26.3|X-Minecraft-Pack-Format: 97.1|"
         "User-Agent: Minecraft Java/26.3|Connection: close||" DELIMITED BY SIZE INTO TL-EXPECTED
     MOVE WS-LOG TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "http get with the 08 §9.3 headers delivers the body" TO TL-CASE
     MOVE "2 10000 body ok" TO TL-EXPECTED
     CALL "HT-SUMMARY" USING HTTP-REQUEST TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Chunked bodies.
     MOVE "--chunked" TO WS-OPTIONS
     CALL "TEST-TESTSRV-START" USING WS-WWW WS-OPTIONS WS-HTTP WS-HTTPS
     MOVE "http get over cc_net of a chunked body delivers the whole body" TO TL-CASE
     CALL "HT-URL" USING WS-HTTP WS-ZERO WS-URL
     CALL "HT-GET" USING WS-URL WS-NO-HEADERS WS-ZERO WS-BIG-LIMIT HTTP-REQUEST
     MOVE "2 10000 body ok" TO TL-EXPECTED
     CALL "HT-SUMMARY" USING HTTP-REQUEST TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "http get over cc_tls of a chunked body delivers the whole body" TO TL-CASE
     CALL "HT-URL" USING WS-HTTPS WS-ONE WS-URL
     CALL "HT-GET" USING WS-URL WS-NO-HEADERS WS-ZERO WS-BIG-LIMIT HTTP-REQUEST
     CALL "HT-SUMMARY" USING HTTP-REQUEST TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Size limit while streaming: a chunked body has no declared length.
     MOVE "--chunked --oversize 20000" TO WS-OPTIONS
     CALL "TEST-TESTSRV-START" USING WS-WWW WS-OPTIONS WS-HTTP WS-HTTPS
     MOVE "http get of a chunked body over the limit fails while streaming (2 chunks kept)"
         TO TL-CASE
     MOVE 10000 TO WS-LIMIT
     CALL "HT-URL" USING WS-HTTP WS-ZERO WS-URL
     CALL "HT-GET" USING WS-URL WS-NO-HEADERS WS-ZERO WS-LIMIT HTTP-REQUEST
     MOVE "3 8192 file size is bigger than maximum allowed" TO TL-EXPECTED
     CALL "HT-SUMMARY" USING HTTP-REQUEST TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "http get of a chunked body exactly at the limit succeeds" TO TL-CASE
     MOVE 20000 TO WS-LIMIT
     CALL "HT-GET" USING WS-URL WS-NO-HEADERS WS-ZERO WS-LIMIT HTTP-REQUEST
     MOVE "2 20000 zeros" TO TL-EXPECTED
     CALL "HT-SUMMARY" USING HTTP-REQUEST TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Size limit by the declared length.
     MOVE "--oversize 5000" TO WS-OPTIONS
     CALL "TEST-TESTSRV-START" USING WS-WWW WS-OPTIONS WS-HTTP WS-HTTPS
     MOVE "http get of a Content-Length over the limit fails before any body byte" TO TL-CASE
     MOVE 4999 TO WS-LIMIT
     CALL "HT-URL" USING WS-HTTP WS-ZERO WS-URL
     CALL "HT-GET" USING WS-URL WS-NO-HEADERS WS-ZERO WS-LIMIT HTTP-REQUEST
     MOVE "3 0 file size is bigger than maximum allowed" TO TL-EXPECTED
     CALL "HT-SUMMARY" USING HTTP-REQUEST TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "http get of a Content-Length exactly at the limit succeeds" TO TL-CASE
     MOVE 5000 TO WS-LIMIT
     CALL "HT-GET" USING WS-URL WS-NO-HEADERS WS-ZERO WS-LIMIT HTTP-REQUEST
     MOVE "2 5000 zeros" TO TL-EXPECTED
     CALL "HT-SUMMARY" USING HTTP-REQUEST TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Non-200 statuses.
     MOVE "--status 500" TO WS-OPTIONS
     CALL "TEST-TESTSRV-START" USING WS-WWW WS-OPTIONS WS-HTTP WS-HTTPS
     MOVE "http get over cc_tls answered 500 fails with HTTP status 500" TO TL-CASE
     CALL "HT-URL" USING WS-HTTPS WS-ONE WS-URL
     CALL "HT-GET" USING WS-URL WS-NO-HEADERS WS-ZERO WS-BIG-LIMIT HTTP-REQUEST
     MOVE "3 0 HTTP status 500" TO TL-EXPECTED
     CALL "HT-SUMMARY" USING HTTP-REQUEST TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "TEST-TESTSRV-STOP"

*>   Response shapes from a raw loopback server.
     MOVE "http response without length or chunking is read until the server closes" TO TL-CASE
     MOVE SPACES TO WS-RAW
     STRING "HTTP/1.0 200 OK" WS-CRLF "Server: raw" WS-CRLF WS-CRLF "until close body"
         DELIMITED BY SIZE INTO WS-RAW
     CALL "HT-RAW" USING WS-RAW WS-BIG-LIMIT HTTP-REQUEST
     MOVE "2 16 until close body" TO TL-EXPECTED
     CALL "HT-SUMMARY" USING HTTP-REQUEST TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "http response read until close fails when it passes the limit" TO TL-CASE
     MOVE 8 TO WS-LIMIT
     CALL "HT-RAW" USING WS-RAW WS-LIMIT HTTP-REQUEST
     MOVE "3 0 file size is bigger than maximum allowed" TO TL-EXPECTED
     CALL "HT-SUMMARY" USING HTTP-REQUEST TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "http response with Content-Length 0 is done with an empty body" TO TL-CASE
     MOVE SPACES TO WS-RAW
     STRING "HTTP/1.1 200 OK" WS-CRLF "content-length:   0  " WS-CRLF WS-CRLF
         DELIMITED BY SIZE INTO WS-RAW
     CALL "HT-RAW" USING WS-RAW WS-BIG-LIMIT HTTP-REQUEST
     MOVE "2 0" TO TL-EXPECTED
     CALL "HT-SUMMARY" USING HTTP-REQUEST TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "http response closed before its Content-Length fails with connection closed early"
         TO TL-CASE
     MOVE SPACES TO WS-RAW
     STRING "HTTP/1.1 200 OK" WS-CRLF "Content-Length: 100" WS-CRLF WS-CRLF "0123456789"
         DELIMITED BY SIZE INTO WS-RAW
     CALL "HT-RAW" USING WS-RAW WS-BIG-LIMIT HTTP-REQUEST
     MOVE "3 10 connection closed early" TO TL-EXPECTED
     CALL "HT-SUMMARY" USING HTTP-REQUEST TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "http response closed inside the headers fails with connection closed early" TO TL-CASE
     MOVE SPACES TO WS-RAW
     STRING "HTTP/1.1 200 OK" WS-CRLF "Content-Le" DELIMITED BY SIZE INTO WS-RAW
     CALL "HT-RAW" USING WS-RAW WS-BIG-LIMIT HTTP-REQUEST
     MOVE "3 0 connection closed early" TO TL-EXPECTED
     CALL "HT-SUMMARY" USING HTTP-REQUEST TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "http response with a redirect status fails with HTTP status 301" TO TL-CASE
     MOVE SPACES TO WS-RAW
     STRING "HTTP/1.1 301 Moved Permanently" WS-CRLF "Location: http://a/" WS-CRLF WS-CRLF
         DELIMITED BY SIZE INTO WS-RAW
     CALL "HT-RAW" USING WS-RAW WS-BIG-LIMIT HTTP-REQUEST
     MOVE "3 0 HTTP status 301" TO TL-EXPECTED
     CALL "HT-SUMMARY" USING HTTP-REQUEST TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "http response chunked with an extension, odd header lines and a trailer" TO TL-CASE
     MOVE SPACES TO WS-RAW
     STRING "HTTP/1.1 200 OK" WS-CRLF "Transfer-Encoding: Chunked" WS-CRLF "nocolon" WS-CRLF
         ":empty name" WS-CRLF "Content-Length: 3" WS-CRLF WS-CRLF
         "5;ext=1" WS-CRLF "hello" WS-CRLF "6" X"0A" " world" X"0A" "0" WS-CRLF
         "Trailer: t" WS-CRLF WS-CRLF DELIMITED BY SIZE INTO WS-RAW
     CALL "HT-RAW" USING WS-RAW WS-BIG-LIMIT HTTP-REQUEST
     MOVE "2 11 hello world" TO TL-EXPECTED
     CALL "HT-SUMMARY" USING HTTP-REQUEST TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Malformed responses.
     MOVE "T" TO TL-MODE
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 8
         MOVE SPACES TO WS-RAW TL-CASE
         EVALUATE WS-I
             WHEN 1
                 STRING "garbage" WS-CRLF WS-CRLF DELIMITED BY SIZE INTO WS-RAW
             WHEN 2
                 STRING "HTTP/1.1 2000 OK" WS-CRLF WS-CRLF DELIMITED BY SIZE INTO WS-RAW
             WHEN 3
                 STRING "HTTP/1.1" WS-CRLF WS-CRLF DELIMITED BY SIZE INTO WS-RAW
             WHEN 4
                 STRING "HTTP/1.1 200 OK" WS-CRLF "Content-Length: 12a" WS-CRLF WS-CRLF
                     DELIMITED BY SIZE INTO WS-RAW
             WHEN 5
                 STRING "HTTP/1.1 200 OK" WS-CRLF "X-Long: " WS-LONG-NAME WS-CRLF WS-CRLF
                     DELIMITED BY SIZE INTO WS-RAW
             WHEN 6
                 STRING "HTTP/1.1 200 OK" WS-CRLF "Transfer-Encoding: chunked" WS-CRLF WS-CRLF
                     "zz" WS-CRLF DELIMITED BY SIZE INTO WS-RAW
             WHEN 7
                 STRING "HTTP/1.1 200 OK" WS-CRLF "Transfer-Encoding: chunked" WS-CRLF WS-CRLF
                     "5" WS-CRLF "helloX" WS-CRLF DELIMITED BY SIZE INTO WS-RAW
             WHEN 8
                 STRING "HTTP/1.1 200 OK" WS-CRLF "Transfer-Encoding: chunked" WS-CRLF WS-CRLF
                     "1234567890abcdef0" WS-CRLF DELIMITED BY SIZE INTO WS-RAW
         END-EVALUATE
         MOVE WS-I TO WS-PORT-TEXT
         STRING "http malformed response " WS-PORT-TEXT(5:1)
             " fails with malformed response" DELIMITED BY SIZE INTO TL-CASE
         CALL "HT-RAW" USING WS-RAW WS-BIG-LIMIT HTTP-REQUEST
         MOVE SPACES TO TL-OBSERVED
         CALL "HT-SUMMARY" USING HTTP-REQUEST TL-OBSERVED
         MOVE "3 0 malformed response" TO TL-EXPECTED
         IF WS-I = 7
             MOVE "3 5 malformed response" TO TL-EXPECTED
         END-IF
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     END-PERFORM
     CALL "HTTP-RELEASE" USING HTTP-REQUEST
     STOP RUN.
 END PROGRAM TEST-HTTP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. HT-URL.
*> USING port, tls (1 for https), url out (PIC X(1024)): http://127.0.0.1:<port>/body.bin, or
*> https://127.0.0.1:<port>/body.bin (the test certificate names that address).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-PORT-TEXT           PIC 9(5).
 LINKAGE SECTION.
 01 L-PORT                 BINARY-LONG.
 01 L-TLS                  BINARY-LONG.
 01 L-URL                  PIC X(1024).
 PROCEDURE DIVISION USING L-PORT L-TLS L-URL.
     MOVE L-PORT TO WS-PORT-TEXT
     MOVE SPACES TO L-URL
     IF L-TLS = 1
         STRING "https://127.0.0.1:" WS-PORT-TEXT "/body.bin" DELIMITED BY SIZE INTO L-URL
     ELSE
         STRING "http://127.0.0.1:" WS-PORT-TEXT "/body.bin" DELIMITED BY SIZE INTO L-URL
     END-IF
     GOBACK.
 END PROGRAM HT-URL.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. HT-GET.
*> USING url (PIC X(1024), trailing spaces cut), header block (PIC X(1024)), its length, size
*> limit, HTTP-REQUEST: HTTP-RELEASE, HTTP-START, then HTTP-STEP every 5 ms until the request is
*> no longer running (at most 10 s).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-URL-LENGTH          BINARY-LONG.
 01 WS-TRIES               BINARY-LONG.
 01 WS-MICROS              BINARY-LONG VALUE 5000.
 LINKAGE SECTION.
 01 L-URL                  PIC X(1024).
 01 L-HEADERS              PIC X(1024).
 01 L-HEADERS-LENGTH       BINARY-LONG.
 01 L-LIMIT                BINARY-LONG.
 COPY CLHTTP.
 PROCEDURE DIVISION USING L-URL L-HEADERS L-HEADERS-LENGTH L-LIMIT HTTP-REQUEST.
     CALL "HTTP-RELEASE" USING HTTP-REQUEST
     COMPUTE WS-URL-LENGTH = FUNCTION LENGTH(FUNCTION TRIM(L-URL TRAILING))
     CALL "HTTP-START" USING HTTP-REQUEST L-URL WS-URL-LENGTH L-HEADERS L-HEADERS-LENGTH L-LIMIT
     PERFORM VARYING WS-TRIES FROM 1 BY 1 UNTIL WS-TRIES > 2000 OR NOT HR-RUNNING
         CALL "HTTP-STEP" USING HTTP-REQUEST
         IF HR-RUNNING
             CALL STATIC "usleep" USING BY VALUE WS-MICROS
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM HT-GET.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. HT-RAW.
*> USING response (PIC X(4096), trailing spaces cut), size limit, HTTP-REQUEST: a raw loopback
*> server on a free port; the request goes to http://127.0.0.1:<port>/raw; once the whole request
*> has arrived (so closing does not reset the connection) the server sends the response bytes and
*> closes. HTTP-STEP runs every 5 ms until the request is no longer running (at most 10 s).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CCSHIM.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-LISTENER            BINARY-LONG.
 01 WS-SERVER              BINARY-LONG.
 01 WS-PORT                BINARY-LONG.
 01 WS-PORT-TEXT           PIC 9(5).
 01 WS-RC                  BINARY-LONG.
 01 WS-URL                 PIC X(1024).
 01 WS-URL-LENGTH          BINARY-LONG.
 01 WS-NO-HEADERS          PIC X(1024) VALUE SPACES.
 01 WS-TRIES               BINARY-LONG.
 01 WS-MICROS              BINARY-LONG VALUE 5000.
 01 WS-IN                  PIC X(4096).
 01 WS-IN-LENGTH           BINARY-LONG.
 01 WS-CAP                 BINARY-LONG.
 01 WS-GOT                 BINARY-LONG.
 01 WS-SENT                BINARY-LONG.
 01 WS-LENGTH              BINARY-LONG.
 01 WS-ENDS                BINARY-LONG.
 01 WS-DONE                BINARY-LONG.
 LINKAGE SECTION.
 01 L-RESPONSE             PIC X(4096).
 01 L-LIMIT                BINARY-LONG.
 COPY CLHTTP.
 PROCEDURE DIVISION USING L-RESPONSE L-LIMIT HTTP-REQUEST.
     CALL "HTTP-RELEASE" USING HTTP-REQUEST
     COMPUTE WS-LENGTH = FUNCTION LENGTH(FUNCTION TRIM(L-RESPONSE TRAILING))
     CALL STATIC "cc_net_listen" USING BY VALUE WS-ZERO BY REFERENCE WS-LISTENER
         BY REFERENCE WS-PORT RETURNING WS-RC
     MOVE WS-PORT TO WS-PORT-TEXT
     MOVE SPACES TO WS-URL
     STRING "http://127.0.0.1:" WS-PORT-TEXT "/raw" DELIMITED BY SIZE INTO WS-URL
     COMPUTE WS-URL-LENGTH = FUNCTION LENGTH(FUNCTION TRIM(WS-URL TRAILING))
     CALL "HTTP-START" USING HTTP-REQUEST WS-URL WS-URL-LENGTH WS-NO-HEADERS WS-ZERO L-LIMIT
     MOVE 0 TO WS-SERVER WS-IN-LENGTH WS-DONE
     PERFORM VARYING WS-TRIES FROM 1 BY 1 UNTIL WS-TRIES > 2000 OR NOT HR-RUNNING
         CALL "HTTP-STEP" USING HTTP-REQUEST
         IF WS-SERVER = 0
             CALL STATIC "cc_net_accept" USING BY VALUE WS-LISTENER BY REFERENCE WS-SERVER
                 RETURNING WS-RC
             IF WS-RC NOT = 0
                 MOVE 0 TO WS-SERVER
             END-IF
         END-IF
         IF WS-SERVER > 0 AND WS-DONE = 0
             COMPUTE WS-CAP = 4096 - WS-IN-LENGTH
             CALL STATIC "cc_net_recv" USING BY VALUE WS-SERVER
                 BY REFERENCE WS-IN(WS-IN-LENGTH + 1:WS-CAP) BY VALUE WS-CAP
                 BY REFERENCE WS-GOT RETURNING WS-RC
             IF WS-RC = 0
                 ADD WS-GOT TO WS-IN-LENGTH
             END-IF
             MOVE 0 TO WS-ENDS
             INSPECT WS-IN(1:FUNCTION MAX(WS-IN-LENGTH, 1)) TALLYING WS-ENDS
                 FOR ALL X"0D0A0D0A"
             IF WS-ENDS > 0
                 CALL STATIC "cc_net_send" USING BY VALUE WS-SERVER BY REFERENCE L-RESPONSE
                     BY VALUE WS-LENGTH BY REFERENCE WS-SENT RETURNING WS-RC
                 CALL STATIC "cc_net_close" USING BY VALUE WS-SERVER
                 MOVE 1 TO WS-DONE
             END-IF
         END-IF
         IF HR-RUNNING
             CALL STATIC "usleep" USING BY VALUE WS-MICROS
         END-IF
     END-PERFORM
     IF WS-DONE = 0 AND WS-SERVER > 0
         CALL STATIC "cc_net_close" USING BY VALUE WS-SERVER
     END-IF
     CALL STATIC "cc_net_close" USING BY VALUE WS-LISTENER
     GOBACK.
 END PROGRAM HT-RAW.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. HT-SUMMARY.
*> USING HTTP-REQUEST, text out (PIC X(1024)): "<state> <body length>", then " <error>" when
*> failed; when done, " body ok" if the body is the body.bin pattern (byte i = (i - 1) mod 251),
*> " zeros" if it is all zero bytes, or else the body itself when it is at most 64 bytes.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-EDIT                PIC -(9)9.
 01 WS-EDIT2               PIC -(9)9.
 01 WS-I                   BINARY-LONG.
 01 WS-M                   BINARY-LONG.
 01 WS-PATTERN             BINARY-LONG.
 01 WS-ZEROS               BINARY-LONG.
 01 B-BODY                 PIC X(1073741824) BASED.
 LINKAGE SECTION.
 COPY CLHTTP.
 01 L-TEXT                 PIC X(1024).
 PROCEDURE DIVISION USING HTTP-REQUEST L-TEXT.
     MOVE SPACES TO L-TEXT
     MOVE HR-STATE TO WS-EDIT
     MOVE HR-BODY-LENGTH TO WS-EDIT2
     STRING FUNCTION TRIM(WS-EDIT) " " FUNCTION TRIM(WS-EDIT2) DELIMITED BY SIZE INTO L-TEXT
     IF HR-FAILED AND HR-ERROR-LENGTH > 0
         STRING FUNCTION TRIM(L-TEXT) " " HR-ERROR(1:HR-ERROR-LENGTH) DELIMITED BY SIZE
             INTO L-TEXT
     END-IF
     IF HR-DONE AND HR-BODY-LENGTH > 0
         SET ADDRESS OF B-BODY TO HR-BODY-ADDR
         MOVE 1 TO WS-PATTERN WS-ZEROS
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > HR-BODY-LENGTH
             COMPUTE WS-M = FUNCTION MOD(WS-I - 1, 251)
             IF B-BODY(WS-I:1) NOT = FUNCTION CHAR(WS-M + 1)
                 MOVE 0 TO WS-PATTERN
             END-IF
             IF B-BODY(WS-I:1) NOT = LOW-VALUE
                 MOVE 0 TO WS-ZEROS
             END-IF
         END-PERFORM
         EVALUATE TRUE
             WHEN WS-PATTERN = 1 AND HR-BODY-LENGTH > 251
                 STRING FUNCTION TRIM(L-TEXT) " body ok" DELIMITED BY SIZE INTO L-TEXT
             WHEN WS-ZEROS = 1
                 STRING FUNCTION TRIM(L-TEXT) " zeros" DELIMITED BY SIZE INTO L-TEXT
             WHEN HR-BODY-LENGTH <= 64
                 STRING FUNCTION TRIM(L-TEXT) " " B-BODY(1:HR-BODY-LENGTH) DELIMITED BY SIZE
                     INTO L-TEXT
             WHEN OTHER
                 STRING FUNCTION TRIM(L-TEXT) " body bad" DELIMITED BY SIZE INTO L-TEXT
         END-EVALUATE
     END-IF
     GOBACK.
 END PROGRAM HT-SUMMARY.

 COPY CLTEST.
