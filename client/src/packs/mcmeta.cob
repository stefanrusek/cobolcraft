*> pack.mcmeta (docs/protocol/08-resource-packs.md §2): MCMETA-PARSE reads the pack section
*> (description, format range, compatibility with the running resource version 97.1, 08 §2.1 to
*> §2.3), the overlays (§1.5, §2.4), the filter (§3.3), the languages (§2.5) and the features
*> (§2.6) into PACK-META (CLMCMETA.cpy); MCMETA-FILTERS tells whether a pack's filter hides a
*> resource of the packs below it (§3.3).
*>
*> Invalid metadata (PM-VALID 0) versus the fallback reading: 08 §2.3 has a pack whose format
*> fields break the rules read again for its description alone, with the range "unknown"; only
*> when that fails too (malformed JSON, no pack section, no description) is the metadata unusable.
*> The other sections are decoded on their own (08 §2: "each section is decoded only when the
*> client asks for it"), and a section that fails to decode is a parse error of the pack's
*> metadata (08 §1.5: a bad overlay directory name "is a parse error for the overlays section"),
*> so a broken overlays, filter, language or features section makes the metadata invalid. That
*> includes a filter pattern that is no valid regular expression (08 §3.3: patterns are Java
*> regular expressions; Java rejects a pattern that does not compile) and, since we cannot
*> evaluate it, a pattern outside the subset REGEX-FIND supports (client/src/regex.cob): the
*> player sees the problem rather than a pack whose filter silently does nothing. Tables hold 8
*> entries (CLMCMETA.cpy); a section with more is reported as invalid too.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MCMETA-PARSE.
*> USING CLIENT-STATE, text area (pack.mcmeta, any size), text length (BINARY-LONG), PACK-META
*> out. The description is rendered with JSON-TEXT-RENDER (an array: its elements' renders
*> joined), so a translate key resolves through the loaded language.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY JSONDOC.
 01 WS-ROOT                BINARY-LONG VALUE 1.
 01 WS-PACK                BINARY-LONG.
 01 WS-DESC                BINARY-LONG.
 01 WS-NODE                BINARY-LONG.
 01 WS-KEY                 PIC X(32).
 01 WS-KEY-LENGTH          BINARY-LONG.
 01 WS-MODE                BINARY-LONG VALUE 0.
 01 WS-PRESENT             BINARY-LONG.
 01 WS-HAS-RANGE           BINARY-LONG.
 01 WS-PROBLEM             PIC X(128).
 01 WS-SECTION             BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 COPY CLMCMETA.
 01 L-TEXT                 PIC X.
 01 L-LENGTH               BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-TEXT L-LENGTH PACK-META.
     INITIALIZE PACK-META
     MOVE 1 TO PM-VALID
     MOVE SPACES TO WS-PROBLEM
     MOVE 0 TO WS-PACK WS-DESC
     CALL "JSON-PARSE" USING JSON-DOC L-TEXT L-LENGTH
     IF JD-ERROR = 1
         MOVE "malformed JSON" TO WS-PROBLEM
     ELSE
         MOVE "pack" TO WS-KEY
         MOVE 4 TO WS-KEY-LENGTH
         CALL "JSON-MEMBER" USING JSON-DOC WS-ROOT WS-KEY WS-KEY-LENGTH WS-PACK
         MOVE "description" TO WS-KEY
         MOVE 11 TO WS-KEY-LENGTH
         CALL "JSON-MEMBER" USING JSON-DOC WS-PACK WS-KEY WS-KEY-LENGTH WS-DESC
     END-IF
     EVALUATE TRUE
         WHEN WS-PROBLEM NOT = SPACES
             CONTINUE
         WHEN WS-PACK = 0
             MOVE "missing pack section" TO WS-PROBLEM
         WHEN JN-TYPE(WS-PACK) NOT = JT-OBJECT
             MOVE "missing pack section" TO WS-PROBLEM
         WHEN WS-DESC = 0
             MOVE "missing description" TO WS-PROBLEM
         WHEN JN-TYPE(WS-DESC) NOT = JT-STRING AND JN-TYPE(WS-DESC) NOT = JT-OBJECT
                 AND JN-TYPE(WS-DESC) NOT = JT-ARRAY
             MOVE "invalid description" TO WS-PROBLEM
     END-EVALUATE
     IF WS-PROBLEM = SPACES
         CALL "MCMETA-DESC" USING CLIENT-STATE JSON-DOC WS-DESC PACK-META
         CALL "MCMETA-VERSIONS" USING JSON-DOC WS-PACK WS-MODE PM-MIN-MAJOR PM-MIN-MINOR
             PM-MAX-MAJOR PM-MAX-MINOR WS-PRESENT WS-HAS-RANGE PM-ERROR
         EVALUATE TRUE
             WHEN PM-ERROR NOT = SPACES
                 MOVE PM-UNKNOWN TO PM-COMPAT
                 MOVE 2147483647 TO PM-MIN-MAJOR PM-MAX-MAJOR
                 MOVE 0 TO PM-MIN-MINOR PM-MAX-MINOR
                 MOVE FUNCTION LENGTH(FUNCTION TRIM(PM-ERROR TRAILING)) TO PM-ERROR-LENGTH
             WHEN PM-MAX-MAJOR < 97 OR (PM-MAX-MAJOR = 97 AND PM-MAX-MINOR < 1)
                 MOVE PM-TOO-OLD TO PM-COMPAT
             WHEN PM-MIN-MAJOR > 97 OR (PM-MIN-MAJOR = 97 AND PM-MIN-MINOR > 1)
                 MOVE PM-TOO-NEW TO PM-COMPAT
             WHEN OTHER
                 MOVE PM-COMPATIBLE TO PM-COMPAT
         END-EVALUATE
*>       The optional sections, in the order of 08 §2; the first problem stops the reading.
         PERFORM VARYING WS-SECTION FROM 1 BY 1 UNTIL WS-SECTION > 4 OR WS-PROBLEM NOT = SPACES
             EVALUATE WS-SECTION
                 WHEN 1
                     MOVE "overlays" TO WS-KEY
                     MOVE 8 TO WS-KEY-LENGTH
                 WHEN 2
                     MOVE "filter" TO WS-KEY
                     MOVE 6 TO WS-KEY-LENGTH
                 WHEN 3
                     MOVE "language" TO WS-KEY
                     MOVE 8 TO WS-KEY-LENGTH
                 WHEN 4
                     MOVE "features" TO WS-KEY
                     MOVE 8 TO WS-KEY-LENGTH
             END-EVALUATE
             CALL "JSON-MEMBER" USING JSON-DOC WS-ROOT WS-KEY WS-KEY-LENGTH WS-NODE
             IF WS-NODE > 0
                 EVALUATE WS-SECTION
                     WHEN 1
                         CALL "MCMETA-OVERLAYS" USING JSON-DOC WS-NODE PACK-META WS-PROBLEM
                     WHEN 2
                         CALL "MCMETA-FILTER" USING JSON-DOC WS-NODE PACK-META WS-PROBLEM
                     WHEN 3
                         CALL "MCMETA-LANGUAGE" USING JSON-DOC WS-NODE PACK-META WS-PROBLEM
                     WHEN 4
                         CALL "MCMETA-FEATURES" USING JSON-DOC WS-NODE PACK-META WS-PROBLEM
                 END-EVALUATE
             END-IF
         END-PERFORM
     END-IF
     IF WS-PROBLEM NOT = SPACES
         INITIALIZE PACK-META
         MOVE WS-PROBLEM TO PM-ERROR
         MOVE FUNCTION LENGTH(FUNCTION TRIM(PM-ERROR TRAILING)) TO PM-ERROR-LENGTH
     END-IF
     GOBACK.
 END PROGRAM MCMETA-PARSE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MCMETA-DESC.
*> USING CLIENT-STATE, JSON-DOC, description node (a string, object or array), PACK-META: renders
*> the description into PM-DESC (an array: each element rendered and appended; at most 512 bytes).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-TEXT                PIC X(512).
 01 WS-LENGTH              BINARY-LONG.
 01 WS-EL                  BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-AT                  BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 COPY JSONDOC.
 01 L-NODE                 BINARY-LONG.
 COPY CLMCMETA.
 PROCEDURE DIVISION USING CLIENT-STATE JSON-DOC L-NODE PACK-META.
     MOVE SPACES TO PM-DESC
     MOVE 0 TO PM-DESC-LENGTH
     IF JN-TYPE(L-NODE) = JT-ARRAY
         MOVE JN-FIRST(L-NODE) TO WS-EL
     ELSE
         MOVE L-NODE TO WS-EL
     END-IF
     PERFORM UNTIL WS-EL = 0
         CALL "JSON-TEXT-RENDER" USING CLIENT-STATE JSON-DOC WS-EL WS-TEXT WS-LENGTH
         COMPUTE WS-N = FUNCTION MIN(WS-LENGTH, 512 - PM-DESC-LENGTH)
         IF WS-N > 0
             COMPUTE WS-AT = PM-DESC-LENGTH + 1
             MOVE WS-TEXT(1:WS-N) TO PM-DESC(WS-AT:WS-N)
             ADD WS-N TO PM-DESC-LENGTH
         END-IF
         MOVE 0 TO WS-N
         IF JN-TYPE(L-NODE) = JT-ARRAY
             MOVE JN-NEXT(WS-EL) TO WS-N
         END-IF
         MOVE WS-N TO WS-EL
     END-PERFORM
     GOBACK.
 END PROGRAM MCMETA-DESC.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MCMETA-INT.
*> USING JSON-DOC, node (0 = absent), value out, ok out (BINARY-LONG 1 when the node is a
*> non-negative integer number up to 2147483647).
 DATA DIVISION.
 LINKAGE SECTION.
 COPY JSONDOC.
 01 L-NODE                 BINARY-LONG.
 01 L-VALUE                BINARY-LONG.
 01 L-OK                   BINARY-LONG.
 PROCEDURE DIVISION USING JSON-DOC L-NODE L-VALUE L-OK.
     MOVE 0 TO L-VALUE L-OK
     IF L-NODE > 0
         IF JN-TYPE(L-NODE) = JT-NUMBER
             IF JN-NUM(L-NODE) >= 0 AND JN-NUM(L-NODE) <= 2147483647
                     AND JN-NUM(L-NODE) = FUNCTION INTEGER-PART(JN-NUM(L-NODE))
                 COMPUTE L-VALUE = JN-NUM(L-NODE)
                 MOVE 1 TO L-OK
             END-IF
         END-IF
     END-IF
     GOBACK.
 END PROGRAM MCMETA-INT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MCMETA-FORMAT.
*> USING JSON-DOC, node, is-max (BINARY-LONG 1 for max_format), major out, minor out, ok out: a
*> format value (08 §2.1): an integer N or an array [N] is N.0 as a minimum and N.* (minor
*> 2147483647) as a maximum; [N, M, ...] is N.M. The array holds 1 to 256 non-negative integers.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-EL                  BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-VALUE               BINARY-LONG.
 01 WS-OK                  BINARY-LONG.
 LINKAGE SECTION.
 COPY JSONDOC.
 01 L-NODE                 BINARY-LONG.
 01 L-IS-MAX               BINARY-LONG.
 01 L-MAJOR                BINARY-LONG.
 01 L-MINOR                BINARY-LONG.
 01 L-OK                   BINARY-LONG.
 PROCEDURE DIVISION USING JSON-DOC L-NODE L-IS-MAX L-MAJOR L-MINOR L-OK.
     COMPUTE L-MINOR = L-IS-MAX * 2147483647
     CALL "MCMETA-INT" USING JSON-DOC L-NODE L-MAJOR L-OK
     IF JN-TYPE(L-NODE) = JT-ARRAY AND JN-COUNT(L-NODE) >= 1 AND JN-COUNT(L-NODE) <= 256
         MOVE 1 TO L-OK
         MOVE 0 TO WS-K
         MOVE JN-FIRST(L-NODE) TO WS-EL
         PERFORM UNTIL WS-EL = 0
             ADD 1 TO WS-K
             CALL "MCMETA-INT" USING JSON-DOC WS-EL WS-VALUE WS-OK
             EVALUATE TRUE
                 WHEN WS-OK = 0
                     MOVE 0 TO L-OK
                 WHEN WS-K = 1
                     MOVE WS-VALUE TO L-MAJOR
                 WHEN WS-K = 2
                     MOVE WS-VALUE TO L-MINOR
             END-EVALUATE
             MOVE JN-NEXT(WS-EL) TO WS-EL
         END-PERFORM
     END-IF
     GOBACK.
 END PROGRAM MCMETA-FORMAT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MCMETA-INTRANGE.
*> USING JSON-DOC, node, low out, high out, ok out: a legacy integer range (08 §2.2
*> supported_formats, §2.4 formats): an integer N (N to N), an array [low, high] or an object
*> {min_inclusive, max_inclusive}; low must not exceed high.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-A                   BINARY-LONG.
 01 WS-B                   BINARY-LONG.
 01 WS-OK-A                BINARY-LONG.
 01 WS-OK-B                BINARY-LONG.
 01 WS-KEY                 PIC X(32).
 01 WS-KEY-LENGTH          BINARY-LONG.
 LINKAGE SECTION.
 COPY JSONDOC.
 01 L-NODE                 BINARY-LONG.
 01 L-LOW                  BINARY-LONG.
 01 L-HIGH                 BINARY-LONG.
 01 L-OK                   BINARY-LONG.
 PROCEDURE DIVISION USING JSON-DOC L-NODE L-LOW L-HIGH L-OK.
     CALL "MCMETA-INT" USING JSON-DOC L-NODE L-LOW L-OK
     MOVE L-LOW TO L-HIGH
     MOVE 0 TO WS-A WS-B
     EVALUATE TRUE
         WHEN L-OK = 1
             CONTINUE
         WHEN JN-TYPE(L-NODE) = JT-ARRAY AND JN-COUNT(L-NODE) = 2
             MOVE JN-FIRST(L-NODE) TO WS-A
             MOVE JN-NEXT(WS-A) TO WS-B
         WHEN JN-TYPE(L-NODE) = JT-OBJECT
             MOVE "min_inclusive" TO WS-KEY
             MOVE 13 TO WS-KEY-LENGTH
             CALL "JSON-MEMBER" USING JSON-DOC L-NODE WS-KEY WS-KEY-LENGTH WS-A
             MOVE "max_inclusive" TO WS-KEY
             CALL "JSON-MEMBER" USING JSON-DOC L-NODE WS-KEY WS-KEY-LENGTH WS-B
     END-EVALUATE
     IF L-OK = 0
         CALL "MCMETA-INT" USING JSON-DOC WS-A L-LOW WS-OK-A
         CALL "MCMETA-INT" USING JSON-DOC WS-B L-HIGH WS-OK-B
         COMPUTE L-OK = WS-OK-A * WS-OK-B
     END-IF
     IF L-LOW > L-HIGH
         MOVE 0 TO L-OK
     END-IF
     GOBACK.
 END PROGRAM MCMETA-INTRANGE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MCMETA-VERSIONS.
*> USING JSON-DOC, object node (the pack section or an overlay entry), mode (BINARY-LONG 0 the
*> pack section: legacy range key "supported_formats" and "pack_format"; 1 an overlay entry:
*> "formats", no pack_format), min major, min minor, max major, max minor out, present out (1
*> when any format field is there), has-range out (1 when the legacy range is there), problem out
*> (PIC X(128), spaces when the fields pass the rules of 08 §2.3 for client resource packs, whose
*> last pre-minor version is 64; else the rule's message).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-KEY                 PIC X(32).
 01 WS-KEY-LENGTH          BINARY-LONG.
 01 WS-MIN                 BINARY-LONG.
 01 WS-MAX                 BINARY-LONG.
 01 WS-RANGE               BINARY-LONG.
 01 WS-PF-NODE             BINARY-LONG.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-OK                  BINARY-LONG.
 01 WS-BAD                 BINARY-LONG.
 01 WS-LOW                 BINARY-LONG.
 01 WS-HIGH                BINARY-LONG.
 01 WS-PF                  BINARY-LONG.
 LINKAGE SECTION.
 COPY JSONDOC.
 01 L-NODE                 BINARY-LONG.
 01 L-MODE                 BINARY-LONG.
 01 L-MIN-MAJOR            BINARY-LONG.
 01 L-MIN-MINOR            BINARY-LONG.
 01 L-MAX-MAJOR            BINARY-LONG.
 01 L-MAX-MINOR            BINARY-LONG.
 01 L-PRESENT              BINARY-LONG.
 01 L-HAS-RANGE            BINARY-LONG.
 01 L-PROBLEM              PIC X(128).
 PROCEDURE DIVISION USING JSON-DOC L-NODE L-MODE L-MIN-MAJOR L-MIN-MINOR L-MAX-MAJOR
         L-MAX-MINOR L-PRESENT L-HAS-RANGE L-PROBLEM.
     MOVE SPACES TO L-PROBLEM
     MOVE 0 TO L-MIN-MAJOR L-MIN-MINOR L-MAX-MAJOR L-MAX-MINOR WS-BAD WS-PF-NODE
     MOVE "min_format" TO WS-KEY
     MOVE 10 TO WS-KEY-LENGTH
     CALL "JSON-MEMBER" USING JSON-DOC L-NODE WS-KEY WS-KEY-LENGTH WS-MIN
     MOVE "max_format" TO WS-KEY
     CALL "JSON-MEMBER" USING JSON-DOC L-NODE WS-KEY WS-KEY-LENGTH WS-MAX
     IF L-MODE = 0
         MOVE "supported_formats" TO WS-KEY
         MOVE 17 TO WS-KEY-LENGTH
         CALL "JSON-MEMBER" USING JSON-DOC L-NODE WS-KEY WS-KEY-LENGTH WS-RANGE
         MOVE "pack_format" TO WS-KEY
         MOVE 11 TO WS-KEY-LENGTH
         CALL "JSON-MEMBER" USING JSON-DOC L-NODE WS-KEY WS-KEY-LENGTH WS-PF-NODE
     ELSE
         MOVE "formats" TO WS-KEY
         MOVE 7 TO WS-KEY-LENGTH
         CALL "JSON-MEMBER" USING JSON-DOC L-NODE WS-KEY WS-KEY-LENGTH WS-RANGE
     END-IF
     MOVE 0 TO L-PRESENT L-HAS-RANGE
     IF WS-MIN > 0 OR WS-MAX > 0 OR WS-RANGE > 0 OR WS-PF-NODE > 0
         MOVE 1 TO L-PRESENT
     END-IF
     IF WS-RANGE > 0
         MOVE 1 TO L-HAS-RANGE
         CALL "MCMETA-INTRANGE" USING JSON-DOC WS-RANGE WS-LOW WS-HIGH WS-OK
         COMPUTE WS-BAD = WS-BAD + 1 - WS-OK
     END-IF
     IF WS-MIN > 0
         CALL "MCMETA-FORMAT" USING JSON-DOC WS-MIN WS-ZERO L-MIN-MAJOR L-MIN-MINOR WS-OK
         COMPUTE WS-BAD = WS-BAD + 1 - WS-OK
     END-IF
     IF WS-MAX > 0
         CALL "MCMETA-FORMAT" USING JSON-DOC WS-MAX WS-ONE L-MAX-MAJOR L-MAX-MINOR WS-OK
         COMPUTE WS-BAD = WS-BAD + 1 - WS-OK
     END-IF
     IF WS-PF-NODE > 0
         CALL "MCMETA-INT" USING JSON-DOC WS-PF-NODE WS-PF WS-OK
         COMPUTE WS-BAD = WS-BAD + 1 - WS-OK
     END-IF
     EVALUATE TRUE
         WHEN WS-BAD > 0
             MOVE "invalid format value" TO L-PROBLEM
         WHEN (WS-MIN = 0 AND WS-MAX > 0) OR (WS-MIN > 0 AND WS-MAX = 0)
             MOVE "missing field, must declare both min_format and max_format" TO L-PROBLEM
         WHEN WS-MIN > 0 AND (L-MIN-MAJOR > L-MAX-MAJOR
                 OR (L-MIN-MAJOR = L-MAX-MAJOR AND L-MIN-MINOR > L-MAX-MINOR))
             MOVE "min_format is greater than max_format" TO L-PROBLEM
         WHEN WS-MIN > 0 AND L-MODE = 0 AND L-MIN-MAJOR > 64 AND WS-RANGE > 0
             MOVE "supported_formats is deprecated starting from pack format 65" TO L-PROBLEM
         WHEN WS-MIN > 0 AND L-MIN-MAJOR > 64 AND WS-PF-NODE > 0
                 AND (WS-PF < L-MIN-MAJOR OR WS-PF > L-MAX-MAJOR)
             MOVE "pack_format is outside min_format and max_format" TO L-PROBLEM
         WHEN WS-MIN > 0 AND L-MODE = 0 AND L-MIN-MAJOR <= 64 AND WS-PF-NODE = 0
             MOVE "missing field pack_format" TO L-PROBLEM
         WHEN WS-MIN > 0 AND L-MIN-MAJOR <= 64 AND WS-RANGE > 0
                 AND (WS-LOW NOT = L-MIN-MAJOR OR WS-HIGH NOT = L-MAX-MAJOR)
             MOVE "version declaration mismatch" TO L-PROBLEM
         WHEN WS-MIN > 0 AND L-MIN-MAJOR < 15 AND L-MIN-MAJOR NOT = L-MAX-MAJOR
             MOVE "Multi-version packs cannot support minimum version of less than 15"
                 TO L-PROBLEM
         WHEN WS-MIN > 0
             CONTINUE
         WHEN WS-RANGE > 0 AND WS-HIGH <= 64
             MOVE WS-LOW TO L-MIN-MAJOR
             MOVE WS-HIGH TO L-MAX-MAJOR
         WHEN WS-PF-NODE > 0 AND WS-RANGE = 0 AND WS-PF <= 64
             MOVE WS-PF TO L-MIN-MAJOR L-MAX-MAJOR
         WHEN WS-RANGE > 0 OR WS-PF-NODE > 0
             MOVE "declares support for version newer than 64, but is missing mandatory fields "
                 & "min_format and max_format" TO L-PROBLEM
         WHEN OTHER
             MOVE "could not be parsed, missing format version information" TO L-PROBLEM
     END-EVALUATE
     GOBACK.
 END PROGRAM MCMETA-VERSIONS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MCMETA-ARRAY.
*> USING JSON-DOC, object node, key (PIC X(32)), key length, first element out, count out, ok
*> out (1 when the member is there and is an array).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-MEMBER              BINARY-LONG.
 LINKAGE SECTION.
 COPY JSONDOC.
 01 L-NODE                 BINARY-LONG.
 01 L-KEY                  PIC X(32).
 01 L-KEY-LENGTH           BINARY-LONG.
 01 L-FIRST                BINARY-LONG.
 01 L-COUNT                BINARY-LONG.
 01 L-OK                   BINARY-LONG.
 PROCEDURE DIVISION USING JSON-DOC L-NODE L-KEY L-KEY-LENGTH L-FIRST L-COUNT L-OK.
     MOVE 0 TO L-FIRST L-COUNT L-OK
     CALL "JSON-MEMBER" USING JSON-DOC L-NODE L-KEY L-KEY-LENGTH WS-MEMBER
     IF WS-MEMBER > 0
         IF JN-TYPE(WS-MEMBER) = JT-ARRAY
             MOVE 1 TO L-OK
             MOVE JN-FIRST(WS-MEMBER) TO L-FIRST
             MOVE JN-COUNT(WS-MEMBER) TO L-COUNT
         END-IF
     END-IF
     GOBACK.
 END PROGRAM MCMETA-ARRAY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MCMETA-OVERLAYS.
*> USING JSON-DOC, overlays section node, PACK-META, problem out (PIC X(128); left as it is when
*> the section is fine): the entries of 08 §2.4. An entry with no format field is skipped
*> ("Unknown or broken overlay entry"); a directory name outside [-_a-zA-Z0-9.]+ (or longer than
*> 64 bytes), broken format fields, or an entry without "formats" while the lowest declared
*> minimum is at or below 64 make the section invalid.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-KEY                 PIC X(32).
 01 WS-KEY-LENGTH          BINARY-LONG.
 01 WS-EL                  BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-OK                  BINARY-LONG.
 01 WS-BAD                 BINARY-LONG.
 01 WS-DIR-NODE            BINARY-LONG.
 01 WS-DIR                 PIC X(80).
 01 WS-CAP                 BINARY-LONG VALUE 80.
 01 WS-LENGTH              BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-C                   PIC X.
 01 WS-MODE                BINARY-LONG VALUE 1.
 01 WS-MIN-MAJOR           BINARY-LONG.
 01 WS-MIN-MINOR           BINARY-LONG.
 01 WS-MAX-MAJOR           BINARY-LONG.
 01 WS-MAX-MINOR           BINARY-LONG.
 01 WS-PRESENT             BINARY-LONG.
 01 WS-HAS-RANGE           BINARY-LONG.
 01 WS-PROBLEM             PIC X(128).
 01 WS-LOWEST              BINARY-LONG.
 01 WS-WITHOUT-RANGE       BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 LINKAGE SECTION.
 COPY JSONDOC.
 01 L-NODE                 BINARY-LONG.
 COPY CLMCMETA.
 01 L-PROBLEM              PIC X(128).
 PROCEDURE DIVISION USING JSON-DOC L-NODE PACK-META L-PROBLEM.
     MOVE "entries" TO WS-KEY
     MOVE 7 TO WS-KEY-LENGTH
     CALL "MCMETA-ARRAY" USING JSON-DOC L-NODE WS-KEY WS-KEY-LENGTH WS-EL WS-COUNT WS-OK
     COMPUTE WS-BAD = 1 - WS-OK
     MOVE 2147483647 TO WS-LOWEST
     MOVE 0 TO WS-WITHOUT-RANGE
     IF WS-COUNT > PM-MAX-ENTRIES
         MOVE "too many overlays" TO L-PROBLEM
         MOVE 0 TO WS-EL
     END-IF
     PERFORM UNTIL WS-EL = 0 OR WS-BAD = 1
         MOVE 0 TO WS-LENGTH WS-PRESENT
         IF JN-TYPE(WS-EL) = JT-OBJECT
             MOVE "directory" TO WS-KEY
             MOVE 9 TO WS-KEY-LENGTH
             CALL "JSON-MEMBER" USING JSON-DOC WS-EL WS-KEY WS-KEY-LENGTH WS-DIR-NODE
             CALL "JSON-STRING" USING JSON-DOC WS-DIR-NODE WS-DIR WS-CAP WS-LENGTH
             CALL "MCMETA-VERSIONS" USING JSON-DOC WS-EL WS-MODE WS-MIN-MAJOR WS-MIN-MINOR
                 WS-MAX-MAJOR WS-MAX-MINOR WS-PRESENT WS-HAS-RANGE WS-PROBLEM
         END-IF
         IF WS-LENGTH = 0 OR WS-LENGTH > 64
             MOVE 1 TO WS-BAD
         END-IF
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-LENGTH OR WS-BAD = 1
             MOVE WS-DIR(WS-I:1) TO WS-C
             IF NOT ((WS-C >= "a" AND WS-C <= "z") OR (WS-C >= "A" AND WS-C <= "Z")
                     OR (WS-C >= "0" AND WS-C <= "9") OR WS-C = "-" OR WS-C = "_"
                     OR WS-C = ".")
                 MOVE 1 TO WS-BAD
             END-IF
         END-PERFORM
         IF WS-PRESENT = 1 AND WS-BAD = 0
             IF WS-PROBLEM NOT = SPACES
                 MOVE 1 TO WS-BAD
             END-IF
             ADD 1 TO PM-OVERLAY-COUNT
             MOVE PM-OVERLAY-COUNT TO WS-N
             MOVE WS-DIR(1:64) TO PM-OVERLAY-DIR(WS-N)
             MOVE WS-LENGTH TO PM-OVERLAY-DIR-LENGTH(WS-N)
             MOVE 0 TO PM-OVERLAY-ACTIVE(WS-N)
             IF (WS-MIN-MAJOR < 97 OR (WS-MIN-MAJOR = 97 AND WS-MIN-MINOR <= 1))
                     AND (WS-MAX-MAJOR > 97 OR (WS-MAX-MAJOR = 97 AND WS-MAX-MINOR >= 1))
                 MOVE 1 TO PM-OVERLAY-ACTIVE(WS-N)
             END-IF
             MOVE FUNCTION MIN(WS-LOWEST, WS-MIN-MAJOR) TO WS-LOWEST
             COMPUTE WS-WITHOUT-RANGE = WS-WITHOUT-RANGE + 1 - WS-HAS-RANGE
         END-IF
         MOVE JN-NEXT(WS-EL) TO WS-EL
     END-PERFORM
     IF WS-LOWEST <= 64 AND WS-WITHOUT-RANGE > 0
         MOVE 1 TO WS-BAD
     END-IF
     IF WS-BAD = 1
         MOVE "invalid overlays section" TO L-PROBLEM
     END-IF
     GOBACK.
 END PROGRAM MCMETA-OVERLAYS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MCMETA-PATTERN.
*> USING JSON-DOC, filter entry node, key (PIC X(32)), key length, pattern out (PIC X(128)),
*> length out, present out (PIC 9), problem out (PIC X(128); left as it is when fine): one
*> IdentifierPattern field (08 §3.3): absent, or a string that REGEX-FIND accepts (at most 128
*> bytes).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-MEMBER              BINARY-LONG.
 01 WS-TEXT                PIC X(256).
 01 WS-CAP                 BINARY-LONG VALUE 256.
 01 WS-LENGTH              BINARY-LONG.
 01 WS-SUBJ                PIC X(256).
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-MATCHED             BINARY-LONG.
 01 WS-ERROR               BINARY-LONG.
 LINKAGE SECTION.
 COPY JSONDOC.
 01 L-NODE                 BINARY-LONG.
 01 L-KEY                  PIC X(32).
 01 L-KEY-LENGTH           BINARY-LONG.
 01 L-PATTERN              PIC X(128).
 01 L-LENGTH               BINARY-LONG.
 01 L-PRESENT              PIC 9.
 01 L-PROBLEM              PIC X(128).
 PROCEDURE DIVISION USING JSON-DOC L-NODE L-KEY L-KEY-LENGTH L-PATTERN L-LENGTH L-PRESENT
         L-PROBLEM.
     MOVE SPACES TO L-PATTERN
     MOVE 0 TO L-LENGTH L-PRESENT
     CALL "JSON-MEMBER" USING JSON-DOC L-NODE L-KEY L-KEY-LENGTH WS-MEMBER
     IF WS-MEMBER > 0
         MOVE 1 TO L-PRESENT
         MOVE 1 TO WS-ERROR
         IF JN-TYPE(WS-MEMBER) = JT-STRING
             MOVE SPACES TO WS-TEXT
             CALL "JSON-STRING" USING JSON-DOC WS-MEMBER WS-TEXT WS-CAP WS-LENGTH
             MOVE WS-TEXT(1:128) TO L-PATTERN
             MOVE WS-LENGTH TO L-LENGTH
             IF WS-LENGTH <= 128
                 CALL "REGEX-FIND" USING L-PATTERN L-LENGTH WS-SUBJ WS-ZERO WS-MATCHED
                     WS-ERROR
             END-IF
             IF WS-ERROR = 1
                 MOVE "invalid filter pattern" TO L-PROBLEM
             END-IF
         ELSE
             MOVE "invalid filter section" TO L-PROBLEM
         END-IF
     END-IF
     GOBACK.
 END PROGRAM MCMETA-PATTERN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MCMETA-FILTER.
*> USING JSON-DOC, filter section node, PACK-META, problem out (PIC X(128); left as it is when
*> the section is fine): the "block" array of IdentifierPatterns (08 §3.3).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-KEY                 PIC X(32).
 01 WS-KEY-LENGTH          BINARY-LONG.
 01 WS-EL                  BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-OK                  BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 LINKAGE SECTION.
 COPY JSONDOC.
 01 L-NODE                 BINARY-LONG.
 COPY CLMCMETA.
 01 L-PROBLEM              PIC X(128).
 PROCEDURE DIVISION USING JSON-DOC L-NODE PACK-META L-PROBLEM.
     MOVE "block" TO WS-KEY
     MOVE 5 TO WS-KEY-LENGTH
     CALL "MCMETA-ARRAY" USING JSON-DOC L-NODE WS-KEY WS-KEY-LENGTH WS-EL WS-COUNT WS-OK
     EVALUATE TRUE
         WHEN WS-OK = 0
             MOVE "invalid filter section" TO L-PROBLEM
         WHEN WS-COUNT > PM-MAX-ENTRIES
             MOVE "too many filter patterns" TO L-PROBLEM
             MOVE 0 TO WS-EL
     END-EVALUATE
     PERFORM UNTIL WS-EL = 0 OR L-PROBLEM NOT = SPACES
         IF JN-TYPE(WS-EL) = JT-OBJECT
             ADD 1 TO PM-FILTER-COUNT
             MOVE PM-FILTER-COUNT TO WS-N
             MOVE "namespace" TO WS-KEY
             MOVE 9 TO WS-KEY-LENGTH
             CALL "MCMETA-PATTERN" USING JSON-DOC WS-EL WS-KEY WS-KEY-LENGTH PM-FILTER-NS(WS-N)
                 PM-FILTER-NS-LENGTH(WS-N) PM-FILTER-NS-PRESENT(WS-N) L-PROBLEM
             MOVE "path" TO WS-KEY
             MOVE 4 TO WS-KEY-LENGTH
             CALL "MCMETA-PATTERN" USING JSON-DOC WS-EL WS-KEY WS-KEY-LENGTH
                 PM-FILTER-PATH(WS-N) PM-FILTER-PATH-LENGTH(WS-N) PM-FILTER-PATH-PRESENT(WS-N)
                 L-PROBLEM
         ELSE
             MOVE "invalid filter section" TO L-PROBLEM
         END-IF
         MOVE JN-NEXT(WS-EL) TO WS-EL
     END-PERFORM
     GOBACK.
 END PROGRAM MCMETA-FILTER.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MCMETA-LANGUAGE.
*> USING JSON-DOC, language section node, PACK-META, problem out (PIC X(128); left as it is when
*> the section is fine): language code (1 to 16 bytes) to LanguageInfo {name, region: non-empty
*> strings; bidirectional: optional boolean} (08 §2.5).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-KEY                 PIC X(32).
 01 WS-KEY-LENGTH          BINARY-LONG.
 01 WS-M                   BINARY-LONG.
 01 WS-FIELD               BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-CODE                PIC X(32).
 01 WS-CODE-CAP            BINARY-LONG VALUE 32.
 01 WS-CODE-LENGTH         BINARY-LONG.
 01 WS-TEXT                PIC X(64).
 01 WS-CAP                 BINARY-LONG VALUE 64.
 01 WS-NAME-LENGTH         BINARY-LONG.
 01 WS-REGION-LENGTH       BINARY-LONG.
 01 WS-BAD                 BINARY-LONG.
 LINKAGE SECTION.
 COPY JSONDOC.
 01 L-NODE                 BINARY-LONG.
 COPY CLMCMETA.
 01 L-PROBLEM              PIC X(128).
 PROCEDURE DIVISION USING JSON-DOC L-NODE PACK-META L-PROBLEM.
     MOVE 0 TO WS-BAD WS-M
     EVALUATE TRUE
         WHEN JN-TYPE(L-NODE) NOT = JT-OBJECT
             MOVE 1 TO WS-BAD
         WHEN JN-COUNT(L-NODE) > PM-MAX-ENTRIES
             MOVE "too many languages" TO L-PROBLEM
         WHEN OTHER
             MOVE JN-FIRST(L-NODE) TO WS-M
     END-EVALUATE
     PERFORM UNTIL WS-M = 0 OR WS-BAD = 1
         ADD 1 TO PM-LANG-COUNT
         MOVE PM-LANG-COUNT TO WS-N
         MOVE SPACES TO WS-CODE
         CALL "JSON-KEY" USING JSON-DOC WS-M WS-CODE WS-CODE-CAP WS-CODE-LENGTH
         MOVE WS-CODE(1:16) TO PM-LANG-CODE(WS-N)
         MOVE WS-CODE-LENGTH TO PM-LANG-CODE-LENGTH(WS-N)
         MOVE "name" TO WS-KEY
         MOVE 4 TO WS-KEY-LENGTH
         CALL "JSON-MEMBER" USING JSON-DOC WS-M WS-KEY WS-KEY-LENGTH WS-FIELD
         MOVE SPACES TO WS-TEXT
         CALL "JSON-STRING" USING JSON-DOC WS-FIELD WS-TEXT WS-CAP WS-NAME-LENGTH
         MOVE WS-TEXT TO PM-LANG-NAME(WS-N)
         MOVE WS-NAME-LENGTH TO PM-LANG-NAME-LENGTH(WS-N)
         MOVE "region" TO WS-KEY
         MOVE 6 TO WS-KEY-LENGTH
         CALL "JSON-MEMBER" USING JSON-DOC WS-M WS-KEY WS-KEY-LENGTH WS-FIELD
         MOVE SPACES TO WS-TEXT
         CALL "JSON-STRING" USING JSON-DOC WS-FIELD WS-TEXT WS-CAP WS-REGION-LENGTH
         MOVE WS-TEXT TO PM-LANG-REGION(WS-N)
         MOVE WS-REGION-LENGTH TO PM-LANG-REGION-LENGTH(WS-N)
         IF WS-CODE-LENGTH = 0 OR WS-CODE-LENGTH > 16 OR WS-NAME-LENGTH = 0
                 OR WS-REGION-LENGTH = 0
             MOVE 1 TO WS-BAD
         END-IF
         MOVE "bidirectional" TO WS-KEY
         MOVE 13 TO WS-KEY-LENGTH
         CALL "JSON-MEMBER" USING JSON-DOC WS-M WS-KEY WS-KEY-LENGTH WS-FIELD
         MOVE 0 TO PM-LANG-BIDI(WS-N)
         IF WS-FIELD > 0
             EVALUATE JN-TYPE(WS-FIELD)
                 WHEN JT-TRUE
                     MOVE 1 TO PM-LANG-BIDI(WS-N)
                 WHEN JT-FALSE
                     CONTINUE
                 WHEN OTHER
                     MOVE 1 TO WS-BAD
             END-EVALUATE
         END-IF
         MOVE JN-NEXT(WS-M) TO WS-M
     END-PERFORM
     IF WS-BAD = 1
         MOVE "invalid language section" TO L-PROBLEM
     END-IF
     GOBACK.
 END PROGRAM MCMETA-LANGUAGE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MCMETA-FEATURES.
*> USING JSON-DOC, features section node, PACK-META, problem out (PIC X(128); left as it is when
*> the section is fine): the "enabled" array of identifiers (08 §2.6; identifier rules §1.3: a
*> namespace of a-z 0-9 _ - . and a path that also allows /; at most 80 bytes here).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-KEY                 PIC X(32).
 01 WS-KEY-LENGTH          BINARY-LONG.
 01 WS-EL                  BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-OK                  BINARY-LONG.
 01 WS-BAD                 BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-TEXT                PIC X(128).
 01 WS-CAP                 BINARY-LONG VALUE 128.
 01 WS-LENGTH              BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-C                   PIC X.
 01 WS-COLONS              BINARY-LONG.
 01 WS-IN-PATH             BINARY-LONG.
 LINKAGE SECTION.
 COPY JSONDOC.
 01 L-NODE                 BINARY-LONG.
 COPY CLMCMETA.
 01 L-PROBLEM              PIC X(128).
 PROCEDURE DIVISION USING JSON-DOC L-NODE PACK-META L-PROBLEM.
     MOVE "enabled" TO WS-KEY
     MOVE 7 TO WS-KEY-LENGTH
     CALL "MCMETA-ARRAY" USING JSON-DOC L-NODE WS-KEY WS-KEY-LENGTH WS-EL WS-COUNT WS-OK
     COMPUTE WS-BAD = 1 - WS-OK
     IF WS-COUNT > PM-MAX-ENTRIES
         MOVE "too many features" TO L-PROBLEM
         MOVE 0 TO WS-EL
     END-IF
     PERFORM UNTIL WS-EL = 0 OR WS-BAD = 1
         MOVE SPACES TO WS-TEXT
         CALL "JSON-STRING" USING JSON-DOC WS-EL WS-TEXT WS-CAP WS-LENGTH
         IF JN-TYPE(WS-EL) NOT = JT-STRING OR WS-LENGTH > 80
             MOVE 1 TO WS-BAD
         END-IF
         MOVE 0 TO WS-COLONS
         INSPECT WS-TEXT TALLYING WS-COLONS FOR ALL ":"
         MOVE 0 TO WS-IN-PATH
         IF WS-COLONS = 0
             MOVE 1 TO WS-IN-PATH
         END-IF
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-LENGTH OR WS-BAD = 1
             MOVE WS-TEXT(WS-I:1) TO WS-C
             EVALUATE TRUE
                 WHEN WS-C = ":" AND WS-IN-PATH = 0
                     MOVE 1 TO WS-IN-PATH
                 WHEN (WS-C >= "a" AND WS-C <= "z") OR (WS-C >= "0" AND WS-C <= "9")
                         OR WS-C = "_" OR WS-C = "-" OR WS-C = "."
                     CONTINUE
                 WHEN WS-C = "/" AND WS-IN-PATH = 1
                     CONTINUE
                 WHEN OTHER
                     MOVE 1 TO WS-BAD
             END-EVALUATE
         END-PERFORM
         IF WS-BAD = 0
             ADD 1 TO PM-FEATURE-COUNT
             MOVE PM-FEATURE-COUNT TO WS-N
             MOVE WS-TEXT(1:80) TO PM-FEATURE-ID(WS-N)
             MOVE WS-LENGTH TO PM-FEATURE-ID-LENGTH(WS-N)
         END-IF
         MOVE JN-NEXT(WS-EL) TO WS-EL
     END-PERFORM
     IF WS-BAD = 1
         MOVE "invalid features section" TO L-PROBLEM
     END-IF
     GOBACK.
 END PROGRAM MCMETA-FEATURES.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MCMETA-FILTERS.
*> USING PACK-META, namespace (PIC X(64)), namespace length, path (PIC X(256)), path length,
*> hidden out (BINARY-LONG): 1 when some filter pattern of the pack matches the resource, that
*> is its namespace pattern (absent: any) and its path pattern (absent: any) both find a match
*> (08 §3.3: Pattern.asPredicate). Such a resource is hidden in every pack below this one.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-I                   BINARY-LONG.
 01 WS-NS                  PIC X(256).
 01 WS-PAT                 PIC X(128).
 01 WS-PAT-LENGTH          BINARY-LONG.
 01 WS-NS-MATCH            BINARY-LONG.
 01 WS-PATH-MATCH          BINARY-LONG.
 01 WS-ERROR               BINARY-LONG.
 LINKAGE SECTION.
 COPY CLMCMETA.
 01 L-NS                   PIC X(64).
 01 L-NS-LENGTH            BINARY-LONG.
 01 L-PATH                 PIC X(256).
 01 L-PATH-LENGTH          BINARY-LONG.
 01 L-HIDDEN               BINARY-LONG.
 PROCEDURE DIVISION USING PACK-META L-NS L-NS-LENGTH L-PATH L-PATH-LENGTH L-HIDDEN.
     MOVE 0 TO L-HIDDEN
     MOVE L-NS TO WS-NS
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > PM-FILTER-COUNT OR L-HIDDEN = 1
         MOVE 1 TO WS-NS-MATCH WS-PATH-MATCH
         IF PM-FILTER-NS-PRESENT(WS-I) = 1
             MOVE PM-FILTER-NS(WS-I) TO WS-PAT
             MOVE PM-FILTER-NS-LENGTH(WS-I) TO WS-PAT-LENGTH
             CALL "REGEX-FIND" USING WS-PAT WS-PAT-LENGTH WS-NS L-NS-LENGTH WS-NS-MATCH
                 WS-ERROR
         END-IF
         IF PM-FILTER-PATH-PRESENT(WS-I) = 1
             MOVE PM-FILTER-PATH(WS-I) TO WS-PAT
             MOVE PM-FILTER-PATH-LENGTH(WS-I) TO WS-PAT-LENGTH
             CALL "REGEX-FIND" USING WS-PAT WS-PAT-LENGTH L-PATH L-PATH-LENGTH WS-PATH-MATCH
                 WS-ERROR
         END-IF
         IF WS-NS-MATCH = 1 AND WS-PATH-MATCH = 1
             MOVE 1 TO L-HIDDEN
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM MCMETA-FILTERS.
