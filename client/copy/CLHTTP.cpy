*> One HTTP/1.1 GET of client/src/http.cob (research R10; server-pushed packs, 08 §9.3). Fixed size
*> (3784 bytes). A fresh record (WORKING-STORAGE, or zero bytes) is idle; HTTP-START fills it,
*> HTTP-STEP advances it without blocking, HTTP-RELEASE closes it and frees the body.
*>   HR-STATE        0 idle, 1 running, 2 done (the whole body is in), 3 failed.
*>   HR-ERROR        the failure reason (HR-ERROR-LENGTH bytes) when HR-STATE is 3: "invalid URL",
*>                   "unresolved host", "connection failed" (refused, reset, TLS handshake or
*>                   verification), "connection closed early", "malformed response",
*>                   "HTTP status <code>" (any status other than 200), "file size is bigger than
*>                   maximum allowed" (08 §9.3: declared length or streamed bytes over the limit).
*>   HR-BODY-ADDR    the body bytes (allocated, grown as needed; NULL while the body is empty),
*>                   HR-BODY-LENGTH of them. Kept after a failure until HTTP-RELEASE.
*>   HR-HANDLE       the cc_net/cc_tls handle while connected (0 otherwise): a caller may wait on
*>                   it with cc_net_poll. The connection is closed as soon as the state is 2 or 3.
*> The rest is private to http.cob.
 01 HTTP-REQUEST.
    05 HR-STATE                BINARY-LONG.
       88 HR-IDLE              VALUE 0.
       88 HR-RUNNING           VALUE 1.
       88 HR-DONE              VALUE 2.
       88 HR-FAILED            VALUE 3.
    05 HR-ERROR                PIC X(128).
    05 HR-ERROR-LENGTH         BINARY-LONG.
    05 HR-BODY-ADDR            USAGE POINTER.
    05 HR-BODY-LENGTH          BINARY-LONG.
    05 HR-HANDLE               BINARY-LONG.
*>  Private: body capacity, size limit, 1 for https, HTTP status code (0 until the status line).
    05 HR-BODY-CAPACITY        BINARY-LONG.
    05 HR-LIMIT                BINARY-LONG.
    05 HR-TLS                  BINARY-LONG.
    05 HR-STATUS               BINARY-LONG.
*>  Private: where the exchange is.
    05 HR-PHASE                BINARY-LONG.
       88 HR-CONNECTING        VALUE 1.
       88 HR-SENDING           VALUE 2.
       88 HR-HEAD              VALUE 3.
       88 HR-BODY              VALUE 4.
       88 HR-CHUNK-SIZE        VALUE 5.
       88 HR-CHUNK-DATA        VALUE 6.
       88 HR-CHUNK-END         VALUE 7.
       88 HR-TRAILER           VALUE 8.
       88 HR-TO-CLOSE          VALUE 9.
*>  Private: Transfer-Encoding chunked seen, Content-Length seen, bytes left of the body or chunk.
    05 HR-CHUNKED              BINARY-LONG.
    05 HR-HAS-LENGTH           BINARY-LONG.
    05 HR-REMAINING            BINARY-DOUBLE.
*>  Private: the request bytes and how many are sent.
    05 HR-SENT                 BINARY-LONG.
    05 HR-REQUEST-LENGTH       BINARY-LONG.
    05 HR-REQUEST              PIC X(2560).
*>  Private: the response line being assembled (status line, header, chunk size, trailer).
    05 HR-LINE-LENGTH          BINARY-LONG.
    05 HR-LINE                 PIC X(1024).
