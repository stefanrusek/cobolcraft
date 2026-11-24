*> A parsed JSON document (client/src/json.cob; RFC 8259 grammar). JSON-PARSE fills it from a text
*> the caller keeps alive (JD-ADDR); nodes are numbered from 1 in document order, node 1 is the
*> root. Object members carry their key as a span of the text (JN-KEY-POS, JN-KEY-LENGTH: between
*> the quotes, escapes not yet decoded); strings likewise (JN-POS, JN-LENGTH); numbers their value.
*> A malformed text sets JD-ERROR to 1 and leaves no nodes (JD-COUNT 0).
 78 JT-OBJECT               VALUE 1.
 78 JT-ARRAY                VALUE 2.
 78 JT-STRING               VALUE 3.
 78 JT-NUMBER               VALUE 4.
 78 JT-TRUE                 VALUE 5.
 78 JT-FALSE                VALUE 6.
 78 JT-NULL                 VALUE 7.
 78 JD-MAX-NODES            VALUE 4096.
 01 JSON-DOC.
    05 JD-ADDR              USAGE POINTER.
    05 JD-LENGTH            BINARY-LONG.
    05 JD-ERROR             PIC 9.
    05 JD-COUNT             BINARY-LONG.
    05 JD-NODE OCCURS 4096 TIMES.
       10 JN-TYPE           BINARY-LONG.
       10 JN-PARENT         BINARY-LONG.
       10 JN-FIRST          BINARY-LONG.   *> first child, 0 = none
       10 JN-LAST           BINARY-LONG.   *> last child
       10 JN-NEXT           BINARY-LONG.   *> next sibling, 0 = none
       10 JN-COUNT          BINARY-LONG.   *> children
       10 JN-KEY-POS        BINARY-LONG.   *> 1-based offset of the key text (members only)
       10 JN-KEY-LENGTH     BINARY-LONG.
       10 JN-POS            BINARY-LONG.   *> 1-based offset of the string text
       10 JN-LENGTH         BINARY-LONG.
       10 JN-NUM            FLOAT-LONG.
