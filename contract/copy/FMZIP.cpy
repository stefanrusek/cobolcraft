*> Zip archive records of formats/src/zip.cob (package-private; docs/protocol/08-resource-packs.md §1.1).
*> A ZIP-OPEN handle is the address of an allocated ZIP-ARCHIVE: the whole file in allocated memory
*> (ZA-DATA-ADDR, ZA-DATA-SIZE bytes) and an allocated ZIP-TABLE of ZA-COUNT entries, one per
*> central directory entry whose name is 1 to 256 bytes long, in central directory order.
 01 ZIP-ARCHIVE            BASED.
    05 ZA-DATA-ADDR        USAGE POINTER.
    05 ZA-TABLE-ADDR       USAGE POINTER.
    05 ZA-DATA-SIZE        BINARY-LONG.
    05 ZA-COUNT            BINARY-LONG.
*> One entry. Offsets are 0-based in the file. ZE-USABLE 0: an entry whose sizes or local header
*> offset cannot be used (zip64 markers 0xFFFFFFFF, a size of 2^31 or more, a compressed size or
*> local header offset past the end of the file); its sizes and offset are 0 and it reads as corrupt.
 01 ZIP-TABLE              BASED.
    05 ZIP-ENTRY           OCCURS 65535 TIMES.
       10 ZE-NAME-OFFSET   BINARY-LONG.
       10 ZE-NAME-LENGTH   BINARY-LONG.
       10 ZE-METHOD        BINARY-LONG.
       10 ZE-FLAGS         BINARY-LONG.
       10 ZE-COMP-SIZE     BINARY-LONG.
       10 ZE-SIZE          BINARY-LONG.
       10 ZE-LOCAL         BINARY-LONG.
       10 ZE-USABLE        BINARY-LONG.
