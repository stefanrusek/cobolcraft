*> Pack sources (08 §1.1, §10): each pack of the stack (PK-PACK of CLSTATE.cpy) is read through its
*> source kind. Kind 0 is the built-in pack (builtin.cob); local zip and folder packs and server
*> packs are further kinds of the same four calls (US18).

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PACK-SOURCE-PATH.
*> USING CLIENT-STATE, pack (stack index), file index (1-based), path out (PIC X(256)), path length
*> out, found out (0 past the pack's last file): enumerates the pack's files.
 DATA DIVISION.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-PACK                 BINARY-LONG.
 01 L-INDEX                BINARY-LONG.
 01 L-PATH                 PIC X(256).
 01 L-LENGTH               BINARY-LONG.
 01 L-FOUND                BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-PACK L-INDEX L-PATH L-LENGTH L-FOUND.
     EVALUATE PK-KIND(L-PACK)
         WHEN 0
             CALL "BUILTIN-PATH" USING L-INDEX L-PATH L-LENGTH L-FOUND
     END-EVALUATE
     GOBACK.
 END PROGRAM PACK-SOURCE-PATH.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PACK-SOURCE-HAS.
*> USING CLIENT-STATE, pack, path (PIC X(256)), path length, found out (1 = the pack has the file).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-INDEX               BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-PACK                 BINARY-LONG.
 01 L-PATH                 PIC X(256).
 01 L-LENGTH               BINARY-LONG.
 01 L-FOUND                BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-PACK L-PATH L-LENGTH L-FOUND.
     EVALUATE PK-KIND(L-PACK)
         WHEN 0
             CALL "BUILTIN-FIND" USING L-PATH L-LENGTH WS-INDEX
             MOVE FUNCTION MIN(WS-INDEX, 1) TO L-FOUND
     END-EVALUATE
     GOBACK.
 END PROGRAM PACK-SOURCE-HAS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PACK-SOURCE-READ.
*> USING CLIENT-STATE, pack, path (PIC X(256)), path length, area, capacity, length out, found out:
*> the file's bytes.
 DATA DIVISION.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-PACK                 BINARY-LONG.
 01 L-PATH                 PIC X(256).
 01 L-LENGTH               BINARY-LONG.
 01 L-AREA                 PIC X.
 01 L-CAPACITY             BINARY-LONG.
 01 L-OUT-LENGTH           BINARY-LONG.
 01 L-FOUND                BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-PACK L-PATH L-LENGTH L-AREA L-CAPACITY L-OUT-LENGTH
         L-FOUND.
     EVALUATE PK-KIND(L-PACK)
         WHEN 0
             CALL "BUILTIN-READ" USING L-PATH L-LENGTH L-AREA L-CAPACITY L-OUT-LENGTH L-FOUND
     END-EVALUATE
     GOBACK.
 END PROGRAM PACK-SOURCE-READ.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PACK-SOURCE-IMAGE.
*> USING CLIENT-STATE, pack, path (PIC X(256)), path length, area, capacity, width out, height out,
*> found out: the texture file decoded to RGBA (rows top to bottom).
 DATA DIVISION.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-PACK                 BINARY-LONG.
 01 L-PATH                 PIC X(256).
 01 L-LENGTH               BINARY-LONG.
 01 L-AREA                 PIC X.
 01 L-CAPACITY             BINARY-LONG.
 01 L-W                    BINARY-LONG.
 01 L-H                    BINARY-LONG.
 01 L-FOUND                BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-PACK L-PATH L-LENGTH L-AREA L-CAPACITY L-W L-H L-FOUND.
     EVALUATE PK-KIND(L-PACK)
         WHEN 0
             CALL "BUILTIN-IMAGE" USING L-PATH L-LENGTH L-AREA L-CAPACITY L-W L-H L-FOUND
     END-EVALUATE
     GOBACK.
 END PROGRAM PACK-SOURCE-IMAGE.
