*> BASED views of the memory a content set owns (content-api section 1: CT-REGISTRY, CT-ENTRY, CT-TAG). A set keeps
*> the table of CT-REGISTRY-COUNT registries at CT-REGISTRY-ADDR and the table of CT-TAG-COUNT tags at
*> CT-TAG-ADDR (both obtained with ALLOCATE); a program addresses them with SET ADDRESS OF. The rows have
*> the layouts of the CT-REGISTRY, CT-ENTRY and CT-TAG records of CONTENT.cpy. Package-private.
 01 B-REGISTRIES BASED.
    05 BR-ROW OCCURS 64 TIMES.
       10 BR-KEY              PIC X(64).
       10 BR-KEY-LENGTH       BINARY-LONG.
       10 BR-ENTRY-COUNT      BINARY-LONG.
       10 BR-ENTRY-ADDR       USAGE POINTER.
       10 BR-PAYLOAD-ADDR     USAGE POINTER.
       10 BR-PAYLOAD-LENGTH   BINARY-LONG.
 01 B-ENTRIES BASED.
    05 BE-ROW OCCURS 65536 TIMES.
       10 BE-KEY              PIC X(64).
       10 BE-KEY-LENGTH       BINARY-LONG.
       10 BE-PAYLOAD-OFFSET   BINARY-LONG.
       10 BE-PAYLOAD-LENGTH   BINARY-LONG.
 01 B-PAYLOAD                 PIC X(268435456) BASED.
 01 B-TAGS BASED.
    05 BT-ROW OCCURS 4096 TIMES.
       10 BT-KEY              PIC X(64).
       10 BT-KEY-LENGTH       BINARY-LONG.
       10 BT-REGISTRY         PIC X(48).
       10 BT-MEMBER-COUNT     BINARY-LONG.
       10 BT-MEMBER-ADDR      USAGE POINTER.
 01 B-MEMBERS BASED.
    05 BM-ID                  BINARY-LONG OCCURS 1048576 TIMES.
