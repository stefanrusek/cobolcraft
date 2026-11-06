*> A pack's parsed pack.mcmeta (client/src/packs/mcmeta.cob, MCMETA-PARSE; 08 §1.5, §2, §3.3).
*> PM-VALID 0: the metadata is unusable (malformed JSON, no pack section, no description, or a
*> broken overlays, filter, language or features section) and PM-ERROR says why, phrased for a
*> player. PM-VALID 1: PM-DESC is the rendered description and PM-COMPAT the compatibility with
*> the running resource version 97.1 (08 §2.3). When the format fields failed the rules of 08
*> §2.3 the fallback reading applies: PM-COMPAT is PM-UNKNOWN, the range is the single format
*> 2147483647.0 and PM-ERROR holds the format problem. A max format written without a minor
*> (N or [N]) has PM-MAX-MINOR 2147483647 (N.*). At most 8 entries per table; more is invalid.
 78 PM-COMPATIBLE           VALUE 0.
 78 PM-TOO-OLD              VALUE 1.
 78 PM-TOO-NEW              VALUE 2.
 78 PM-UNKNOWN              VALUE 3.
 78 PM-MAX-ENTRIES          VALUE 8.
 01 PACK-META.
    05 PM-VALID             PIC 9.
    05 PM-ERROR             PIC X(128).
    05 PM-ERROR-LENGTH      BINARY-LONG.
    05 PM-DESC              PIC X(512).
    05 PM-DESC-LENGTH       BINARY-LONG.
    05 PM-COMPAT            BINARY-LONG.
    05 PM-MIN-MAJOR         BINARY-LONG.
    05 PM-MIN-MINOR         BINARY-LONG.
    05 PM-MAX-MAJOR         BINARY-LONG.
    05 PM-MAX-MINOR         BINARY-LONG.
*>  Declared overlays (08 §2.4) in declaration order, skipped entries left out; active when the
*>  range holds 97.1. Lookup goes through the active ones in reverse order, then the root (§1.5).
    05 PM-OVERLAY-COUNT     BINARY-LONG.
    05 PM-OVERLAY OCCURS 8 TIMES.
       10 PM-OVERLAY-DIR    PIC X(64).
       10 PM-OVERLAY-DIR-LENGTH BINARY-LONG.
       10 PM-OVERLAY-ACTIVE PIC 9.
*>  Filter patterns (08 §3.3): regular expressions (REGEX-FIND); an absent one matches all.
    05 PM-FILTER-COUNT      BINARY-LONG.
    05 PM-FILTER OCCURS 8 TIMES.
       10 PM-FILTER-NS      PIC X(128).
       10 PM-FILTER-NS-LENGTH BINARY-LONG.
       10 PM-FILTER-NS-PRESENT PIC 9.
       10 PM-FILTER-PATH    PIC X(128).
       10 PM-FILTER-PATH-LENGTH BINARY-LONG.
       10 PM-FILTER-PATH-PRESENT PIC 9.
*>  Languages the pack provides (08 §2.5), in the order of the JSON object; name and region are
*>  cut at 64 bytes.
    05 PM-LANG-COUNT        BINARY-LONG.
    05 PM-LANG OCCURS 8 TIMES.
       10 PM-LANG-CODE      PIC X(16).
       10 PM-LANG-CODE-LENGTH BINARY-LONG.
       10 PM-LANG-NAME      PIC X(64).
       10 PM-LANG-NAME-LENGTH BINARY-LONG.
       10 PM-LANG-REGION    PIC X(64).
       10 PM-LANG-REGION-LENGTH BINARY-LONG.
       10 PM-LANG-BIDI      PIC 9.
*>  Requested feature flags (08 §2.6) as written (a bare path means minecraft:path, §1.3).
    05 PM-FEATURE-COUNT     BINARY-LONG.
    05 PM-FEATURE OCCURS 8 TIMES.
       10 PM-FEATURE-ID     PIC X(80).
       10 PM-FEATURE-ID-LENGTH BINARY-LONG.
