*> Constants and records of the formats library that are not in FMZIP.cpy (the zip archive and entry
*> records, shared with the zip reader) or FMREGEX.cpy (the compiled expression), both in this folder
*> (specs/002-client-polish/contracts/formats-api.md; T0052). Contract artifact (constitution 3.3):
*> not edited by lanes. Nothing here repeats a definition of FMZIP.cpy, FMREGEX.cpy or JSONDOC.cpy.
*> Every status below is a BINARY-LONG a program returns through a status parameter.

*> File and directory status words (FILE-READ-AT, FILE-READ-ALL, FILE-WRITE, DIR-ENSURE, DIR-RENAME,
*> DIR-REMOVE-TREE, FILE-EXISTS). 0 and 1 and 5 are the words FILE-READ-ALL has returned since 001.
 78 FM-OK                  VALUE 0.
 78 FM-UNREADABLE          VALUE 1.   *> cannot be opened, read, created, written or removed
 78 FM-NOT-FOUND           VALUE 2.   *> the file or directory does not exist
 78 FM-EXISTS              VALUE 3.   *> DIR-ENSURE found a file where a directory is wanted;
*>                                       DIR-RENAME found the target
 78 FM-SHORT-WRITE         VALUE 4.   *> FILE-WRITE wrote fewer bytes than asked
 78 FM-TOO-BIG             VALUE 5.   *> the file is larger than the capacity: the length out is its size
 78 FM-PATH-LONG           VALUE 6.   *> the path exceeds FM-PATH-MAX
 78 FM-PATH-MAX            VALUE 1100.
*> FILE-EXISTS answers through its status: FM-OK = a file exists, FM-NOT-FOUND = nothing, FM-IS-DIR =
*> a directory exists.
 78 FM-IS-DIR              VALUE 7.

*> Zip status words (ZIP-OPEN, ZIP-READ, ZIP-READ-RANGE, ZIP-CRC-CHECK); 22 section 8.4 rejects with a
*> reason. ZIP-READ has returned 0, 2 and 5 since 001 (2 = corrupt or unsupported, 5 = too small).
 78 FM-ZIP-OK             VALUE 0.
 78 FM-ZIP-UNREADABLE      VALUE 1.   *> the file cannot be opened or read
 78 FM-ZIP-CORRUPT         VALUE 2.   *> no end record, a bad central directory, a bad local header,
*>                                       an inflate failure or a size mismatch
 78 FM-ZIP-CAPACITY        VALUE 5.   *> the entry is larger than the caller's capacity
 78 FM-ZIP-ZIP64           VALUE 8.   *> zip64 end record or marker
 78 FM-ZIP-MULTI-DISK      VALUE 9.
 78 FM-ZIP-ENCRYPTED       VALUE 10.  *> an encrypted entry (general purpose flag bit 0)
 78 FM-ZIP-METHOD          VALUE 11.  *> a method other than 0 and 8
 78 FM-ZIP-CRC             VALUE 12.  *> ZIP-CRC-CHECK: the data's CRC-32 differs from the central record's
 78 FM-ZIP-NO-ENTRY        VALUE 13.  *> an entry number out of range

*> CRC-32 of the zip format (CRC32): the running value starts at 0; the check value of the nine
*> bytes "123456789" is the constant below (22 section 7.2).
 78 FM-CRC-CHECK-VALUE     VALUE 3421780262.   *> hex cbf43926

*> SHA-256 (SHA256-INIT, SHA256-UPDATE, SHA256-FINAL): the context is an opaque pointer to an OpenSSL
*> EVP_MD_CTX the init call allocates and the final call frees. The digest is 32 bytes.
 78 FM-SHA-DIGEST-BYTES   VALUE 32.
 01 FMSHA.
    05 FMSHA-CTX            USAGE POINTER.   *> NULL before SHA256-INIT and after SHA256-FINAL
    05 FMSHA-STATE          BINARY-LONG.     *> 0 idle, 1 open (set by SHA256-INIT and -FINAL)
 01 FMSHA-DIGEST            PIC X(32).

*> JSON-STRICT reason codes (23 section 3.2): the returned code is 0 or one of these, with the byte
*> offset of the problem (0-based) in the offset parameter.
 78 FM-JS-OK               VALUE 0.
 78 FM-JS-SYNTAX           VALUE 1.   *> a token the grammar does not allow, an unterminated string
 78 FM-JS-COMMENT          VALUE 2.   *> a comment (// or /* */)
 78 FM-JS-TRAILING-COMMA   VALUE 3.   *> a comma before a closing bracket or brace
 78 FM-JS-DUPLICATE-KEY    VALUE 4.   *> an object repeats a member name
 78 FM-JS-TRAILING-DATA    VALUE 5.   *> "Did not consume the entire document."
 78 FM-JS-NUMBER           VALUE 6.   *> a number that does not parse
 78 FM-JS-UNQUOTED-NAME    VALUE 7.   *> an object member name without quotes
 78 FM-JS-DEPTH            VALUE 8.   *> nesting deeper than the document buffer holds
 78 FM-JS-CAPACITY         VALUE 9.   *> more nodes than the document buffer holds
 78 FM-JS-ESCAPE           VALUE 10.  *> a bad string escape or a control character in a string
