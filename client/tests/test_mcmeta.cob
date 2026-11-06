*> Implementation test of client/src/packs/mcmeta.cob (MCMETA-PARSE, MCMETA-FILTERS; 08 §1.5,
*> §2, §3.3): the pack section's description (string, object or array text component) and format
*> range in every form of 08 §2.1 to §2.3 with the compatibility against the running 97.1
*> (compatible, too old, too new, unknown after the fallback reading), overlays (directory names,
*> activity, the formats-required rule, the broken-entry skip), filter patterns and the find
*> matching of MCMETA-FILTERS, languages, features, and invalid metadata (malformed JSON, no pack
*> section, no description, broken optional sections) reported with a problem text.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-MCMETA.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLSTATE.
 COPY CLMCMETA.
 COPY TESTLIB.
 01 WS-JSON                PIC X(4000).
 01 WS-JSON-LENGTH         BINARY-LONG.
 01 WS-SUM                 PIC X(1024).
 01 WS-PTR                 BINARY-LONG.
 01 WS-EDIT                PIC -(10)9.
 01 WS-I                   BINARY-LONG.
 01 WS-LEN                 BINARY-LONG.
 01 WS-NS                  PIC X(64).
 01 WS-NS-LENGTH           BINARY-LONG.
 01 WS-PATH                PIC X(256).
 01 WS-PATH-LENGTH         BINARY-LONG.
 01 WS-HIDDEN              BINARY-LONG.
 PROCEDURE DIVISION.
     CALL "CL-INIT" USING CLIENT-STATE
     CALL "PACK-STACK-INIT" USING CLIENT-STATE
     CALL "LANG-LOAD" USING CLIENT-STATE

*>   Description forms (08 §2.2): a string, an object (text or translate), an array.
     MOVE '{"pack":{"description":"My pack","min_format":97,"max_format":97}}' TO WS-JSON
     PERFORM DO-PARSE
     MOVE "mcmeta a string description with min_format 97 and max_format 97 is compatible, "
         & "97.0 to 97.*" TO TL-CASE
     MOVE "valid=1 compat=0 min=97.0 max=97.2147483647 desc=My pack" TO TL-EXPECTED
     PERFORM SUMMARIZE
     MOVE '{"pack":{"description":{"translate":"cobolcraft.screen.server_list.title"},'
         & '"min_format":97,"max_format":97},"unknown_section":{"x":1}}' TO WS-JSON
     PERFORM DO-PARSE
     MOVE "mcmeta a translate object description renders through the language; unknown "
         & "sections are ignored" TO TL-CASE
     MOVE "valid=1 compat=0 min=97.0 max=97.2147483647 desc=Servers" TO TL-EXPECTED
     PERFORM SUMMARIZE
     MOVE '{"pack":{"description":["A",{"text":"B"},"C"],"min_format":97,"max_format":97}}'
         TO WS-JSON
     PERFORM DO-PARSE
     MOVE "mcmeta an array description concatenates its elements" TO TL-CASE
     MOVE "valid=1 compat=0 min=97.0 max=97.2147483647 desc=ABC" TO TL-EXPECTED
     PERFORM SUMMARIZE
     MOVE "mcmeta a valid pack without optional sections has no overlays, filters, languages "
         & "or features" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 0 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = PM-OVERLAY-COUNT + PM-FILTER-COUNT + PM-LANG-COUNT
         + PM-FEATURE-COUNT
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Compatibility against 97.1 (08 §2.3) and the format forms (08 §2.1).
     MOVE '{"pack":{"description":"d","min_format":[90],"max_format":[97,0]}}' TO WS-JSON
     PERFORM DO-PARSE
     MOVE "mcmeta max_format [97, 0] is below 97.1: too old" TO TL-CASE
     MOVE "valid=1 compat=1 min=90.0 max=97.0 desc=d" TO TL-EXPECTED
     PERFORM SUMMARIZE
     MOVE '{"pack":{"description":"d","min_format":[97,1],"max_format":[97,1]}}' TO WS-JSON
     PERFORM DO-PARSE
     MOVE "mcmeta the single format [97, 1] is compatible" TO TL-CASE
     MOVE "valid=1 compat=0 min=97.1 max=97.1 desc=d" TO TL-EXPECTED
     PERFORM SUMMARIZE
     MOVE '{"pack":{"description":"d","min_format":[97,2],"max_format":99}}' TO WS-JSON
     PERFORM DO-PARSE
     MOVE "mcmeta min_format [97, 2] is above 97.1: too new" TO TL-CASE
     MOVE "valid=1 compat=2 min=97.2 max=99.2147483647 desc=d" TO TL-EXPECTED
     PERFORM SUMMARIZE
     MOVE '{"pack":{"description":"d","min_format":98,"max_format":98}}' TO WS-JSON
     PERFORM DO-PARSE
     MOVE "mcmeta min_format 98 is too new" TO TL-CASE
     MOVE "valid=1 compat=2 min=98.0 max=98.2147483647 desc=d" TO TL-EXPECTED
     PERFORM SUMMARIZE
     MOVE '{"pack":{"description":"d","min_format":65,"max_format":96}}' TO WS-JSON
     PERFORM DO-PARSE
     MOVE "mcmeta max_format 96 is too old" TO TL-CASE
     MOVE "valid=1 compat=1 min=65.0 max=96.2147483647 desc=d" TO TL-EXPECTED
     PERFORM SUMMARIZE
     MOVE '{"pack":{"description":"d","min_format":[97,1,5],"max_format":[97]}}' TO WS-JSON
     PERFORM DO-PARSE
     MOVE "mcmeta a format array uses only its first two numbers; max_format [97] is 97.*"
         TO TL-CASE
     MOVE "valid=1 compat=0 min=97.1 max=97.2147483647 desc=d" TO TL-EXPECTED
     PERFORM SUMMARIZE

*>   Rows of 08 §2.3.
     MOVE '{"pack":{"description":"d","min_format":97}}' TO WS-JSON
     PERFORM DO-PARSE
     MOVE "mcmeta only min_format: unknown (fallback reading)" TO TL-CASE
     MOVE "valid=1 compat=3 min=2147483647.0 max=2147483647.0 desc=d error=missing field, "
         & "must declare both min_format and max_format" TO TL-EXPECTED
     PERFORM SUMMARIZE
     MOVE '{"pack":{"description":"d","max_format":97}}' TO WS-JSON
     PERFORM DO-PARSE
     MOVE "mcmeta only max_format: unknown" TO TL-CASE
     MOVE "valid=1 compat=3 min=2147483647.0 max=2147483647.0 desc=d error=missing field, "
         & "must declare both min_format and max_format" TO TL-EXPECTED
     PERFORM SUMMARIZE
     MOVE '{"pack":{"description":"d","supported_formats":[10,64]}}' TO WS-JSON
     PERFORM DO-PARSE
     MOVE "mcmeta legacy supported_formats [10, 64] is the range 10.0 to 64.0: too old" TO TL-CASE
     MOVE "valid=1 compat=1 min=10.0 max=64.0 desc=d" TO TL-EXPECTED
     PERFORM SUMMARIZE
     MOVE '{"pack":{"description":"d","supported_formats":{"min_inclusive":20,'
         & '"max_inclusive":30},"pack_format":99}}' TO WS-JSON
     PERFORM DO-PARSE
     MOVE "mcmeta legacy supported_formats as an object; pack_format is then not used" TO TL-CASE
     MOVE "valid=1 compat=1 min=20.0 max=30.0 desc=d" TO TL-EXPECTED
     PERFORM SUMMARIZE
     MOVE '{"pack":{"description":"d","supported_formats":34}}' TO WS-JSON
     PERFORM DO-PARSE
     MOVE "mcmeta legacy supported_formats as an integer" TO TL-CASE
     MOVE "valid=1 compat=1 min=34.0 max=34.0 desc=d" TO TL-EXPECTED
     PERFORM SUMMARIZE
     MOVE '{"pack":{"description":"d","supported_formats":[10,70]}}' TO WS-JSON
     PERFORM DO-PARSE
     MOVE "mcmeta legacy supported_formats past 64: unknown" TO TL-CASE
     MOVE "valid=1 compat=3 min=2147483647.0 max=2147483647.0 desc=d error=declares support "
         & "for version newer than 64, but is missing mandatory fields min_format and "
         & "max_format" TO TL-EXPECTED
     PERFORM SUMMARIZE
     MOVE '{"pack":{"description":"d","supported_formats":[30,20]}}' TO WS-JSON
     PERFORM DO-PARSE
     MOVE "mcmeta legacy supported_formats with min above max: unknown" TO TL-CASE
     MOVE "valid=1 compat=3 min=2147483647.0 max=2147483647.0 desc=d error=invalid format "
         & "value" TO TL-EXPECTED
     PERFORM SUMMARIZE
     MOVE '{"pack":{"description":"d","pack_format":15}}' TO WS-JSON
     PERFORM DO-PARSE
     MOVE "mcmeta only pack_format 15: the single version 15.0, too old" TO TL-CASE
     MOVE "valid=1 compat=1 min=15.0 max=15.0 desc=d" TO TL-EXPECTED
     PERFORM SUMMARIZE
     MOVE '{"pack":{"description":"d","pack_format":70}}' TO WS-JSON
     PERFORM DO-PARSE
     MOVE "mcmeta only pack_format 70: unknown" TO TL-CASE
     MOVE "valid=1 compat=3 min=2147483647.0 max=2147483647.0 desc=d error=declares support "
         & "for version newer than 64, but is missing mandatory fields min_format and "
         & "max_format" TO TL-EXPECTED
     PERFORM SUMMARIZE
     MOVE '{"pack":{"description":"d"}}' TO WS-JSON
     PERFORM DO-PARSE
     MOVE "mcmeta no format field at all: unknown" TO TL-CASE
     MOVE "valid=1 compat=3 min=2147483647.0 max=2147483647.0 desc=d error=could not be "
         & "parsed, missing format version information" TO TL-EXPECTED
     PERFORM SUMMARIZE
     MOVE '{"pack":{"description":"d","min_format":98,"max_format":97}}' TO WS-JSON
     PERFORM DO-PARSE
     MOVE "mcmeta min_format above max_format: unknown" TO TL-CASE
     MOVE "valid=1 compat=3 min=2147483647.0 max=2147483647.0 desc=d error=min_format is "
         & "greater than max_format" TO TL-EXPECTED
     PERFORM SUMMARIZE
     MOVE '{"pack":{"description":"d","min_format":[97,2],"max_format":[97,1]}}' TO WS-JSON
     PERFORM DO-PARSE
     MOVE "mcmeta min_format above max_format by the minor: unknown" TO TL-CASE
     MOVE "valid=1 compat=3 min=2147483647.0 max=2147483647.0 desc=d error=min_format is "
         & "greater than max_format" TO TL-EXPECTED
     PERFORM SUMMARIZE
     MOVE '{"pack":{"description":"d","min_format":65,"max_format":97,'
         & '"supported_formats":[65,97]}}' TO WS-JSON
     PERFORM DO-PARSE
     MOVE "mcmeta min_format above 64 with supported_formats: unknown" TO TL-CASE
     MOVE "valid=1 compat=3 min=2147483647.0 max=2147483647.0 desc=d error=supported_formats "
         & "is deprecated starting from pack format 65" TO TL-EXPECTED
     PERFORM SUMMARIZE
     MOVE '{"pack":{"description":"d","min_format":65,"max_format":97,"pack_format":70}}'
         TO WS-JSON
     PERFORM DO-PARSE
     MOVE "mcmeta min_format above 64 with pack_format inside the majors: compatible" TO TL-CASE
     MOVE "valid=1 compat=0 min=65.0 max=97.2147483647 desc=d" TO TL-EXPECTED
     PERFORM SUMMARIZE
     MOVE '{"pack":{"description":"d","min_format":65,"max_format":97,"pack_format":99}}'
         TO WS-JSON
     PERFORM DO-PARSE
     MOVE "mcmeta min_format above 64 with pack_format outside the majors: unknown" TO TL-CASE
     MOVE "valid=1 compat=3 min=2147483647.0 max=2147483647.0 desc=d error=pack_format is "
         & "outside min_format and max_format" TO TL-EXPECTED
     PERFORM SUMMARIZE
     MOVE '{"pack":{"description":"d","min_format":60,"max_format":97}}' TO WS-JSON
     PERFORM DO-PARSE
     MOVE "mcmeta min_format at or below 64 without pack_format: unknown" TO TL-CASE
     MOVE "valid=1 compat=3 min=2147483647.0 max=2147483647.0 desc=d error=missing field "
         & "pack_format" TO TL-EXPECTED
     PERFORM SUMMARIZE
     MOVE '{"pack":{"description":"d","min_format":60,"max_format":97,"pack_format":60}}'
         TO WS-JSON
     PERFORM DO-PARSE
     MOVE "mcmeta min_format at or below 64 with pack_format: compatible" TO TL-CASE
     MOVE "valid=1 compat=0 min=60.0 max=97.2147483647 desc=d" TO TL-EXPECTED
     PERFORM SUMMARIZE
     MOVE '{"pack":{"description":"d","min_format":60,"max_format":97,"pack_format":60,'
         & '"supported_formats":[60,97]}}' TO WS-JSON
     PERFORM DO-PARSE
     MOVE "mcmeta min_format at or below 64 with an agreeing supported_formats: compatible"
         TO TL-CASE
     MOVE "valid=1 compat=0 min=60.0 max=97.2147483647 desc=d" TO TL-EXPECTED
     PERFORM SUMMARIZE
     MOVE '{"pack":{"description":"d","min_format":60,"max_format":97,"pack_format":60,'
         & '"supported_formats":[61,97]}}' TO WS-JSON
     PERFORM DO-PARSE
     MOVE "mcmeta min_format at or below 64 with a disagreeing supported_formats: unknown"
         TO TL-CASE
     MOVE "valid=1 compat=3 min=2147483647.0 max=2147483647.0 desc=d error=version "
         & "declaration mismatch" TO TL-EXPECTED
     PERFORM SUMMARIZE
     MOVE '{"pack":{"description":"d","min_format":10,"max_format":97,"pack_format":10}}'
         TO WS-JSON
     PERFORM DO-PARSE
     MOVE "mcmeta a multi-version range starting below 15: unknown" TO TL-CASE
     MOVE "valid=1 compat=3 min=2147483647.0 max=2147483647.0 desc=d error=Multi-version "
         & "packs cannot support minimum version of less than 15" TO TL-EXPECTED
     PERFORM SUMMARIZE
     MOVE '{"pack":{"description":"d","min_format":10,"max_format":10,"pack_format":10}}'
         TO WS-JSON
     PERFORM DO-PARSE
     MOVE "mcmeta a single version below 15 is allowed: too old" TO TL-CASE
     MOVE "valid=1 compat=1 min=10.0 max=10.2147483647 desc=d" TO TL-EXPECTED
     PERFORM SUMMARIZE

*>   Malformed format values fall back to unknown.
     MOVE '{"pack":{"description":"d","min_format":[],"max_format":97}}' TO WS-JSON
     PERFORM DO-PARSE
     MOVE "mcmeta an empty format array: unknown" TO TL-CASE
     MOVE "valid=1 compat=3 min=2147483647.0 max=2147483647.0 desc=d error=invalid format "
         & "value" TO TL-EXPECTED
     PERFORM SUMMARIZE
     MOVE '{"pack":{"description":"d","min_format":"97","max_format":97}}' TO WS-JSON
     PERFORM DO-PARSE
     MOVE "mcmeta a string format: unknown" TO TL-CASE
     MOVE "valid=1 compat=3 min=2147483647.0 max=2147483647.0 desc=d error=invalid format "
         & "value" TO TL-EXPECTED
     PERFORM SUMMARIZE
     MOVE '{"pack":{"description":"d","min_format":-1,"max_format":97}}' TO WS-JSON
     PERFORM DO-PARSE
     MOVE "mcmeta a negative format: unknown" TO TL-CASE
     MOVE "valid=1 compat=3 min=2147483647.0 max=2147483647.0 desc=d error=invalid format "
         & "value" TO TL-EXPECTED
     PERFORM SUMMARIZE
     MOVE '{"pack":{"description":"d","min_format":[97,1.5],"max_format":97}}' TO WS-JSON
     PERFORM DO-PARSE
     MOVE "mcmeta a fractional format number: unknown" TO TL-CASE
     MOVE "valid=1 compat=3 min=2147483647.0 max=2147483647.0 desc=d error=invalid format "
         & "value" TO TL-EXPECTED
     PERFORM SUMMARIZE
     MOVE '{"pack":{"description":"d","pack_format":"x"}}' TO WS-JSON
     PERFORM DO-PARSE
     MOVE "mcmeta a string pack_format: unknown" TO TL-CASE
     MOVE "valid=1 compat=3 min=2147483647.0 max=2147483647.0 desc=d error=invalid format "
         & "value" TO TL-EXPECTED
     PERFORM SUMMARIZE
     MOVE '{"pack":{"description":"d","supported_formats":[1,2,3]}}' TO WS-JSON
     PERFORM DO-PARSE
     MOVE "mcmeta a supported_formats array of three: unknown" TO TL-CASE
     MOVE "valid=1 compat=3 min=2147483647.0 max=2147483647.0 desc=d error=invalid format "
         & "value" TO TL-EXPECTED
     PERFORM SUMMARIZE
     MOVE '{"pack":{"description":"d","supported_formats":{"min_inclusive":20}}}' TO WS-JSON
     PERFORM DO-PARSE
     MOVE "mcmeta a supported_formats object without max_inclusive: unknown" TO TL-CASE
     MOVE "valid=1 compat=3 min=2147483647.0 max=2147483647.0 desc=d error=invalid format "
         & "value" TO TL-EXPECTED
     PERFORM SUMMARIZE
     MOVE '{"pack":{"description":"d","supported_formats":true}}' TO WS-JSON
     PERFORM DO-PARSE
     MOVE "mcmeta a boolean supported_formats: unknown" TO TL-CASE
     MOVE "valid=1 compat=3 min=2147483647.0 max=2147483647.0 desc=d error=invalid format "
         & "value" TO TL-EXPECTED
     PERFORM SUMMARIZE

*>   Invalid metadata.
     MOVE '{"pack":{"description":"d"' TO WS-JSON
     PERFORM DO-PARSE
     MOVE "mcmeta malformed JSON is invalid" TO TL-CASE
     MOVE "valid=0 error=malformed JSON" TO TL-EXPECTED
     PERFORM SUMMARIZE
     MOVE '{"other":{"description":"d"}}' TO WS-JSON
     PERFORM DO-PARSE
     MOVE "mcmeta no pack section is invalid" TO TL-CASE
     MOVE "valid=0 error=missing pack section" TO TL-EXPECTED
     PERFORM SUMMARIZE
     MOVE '["pack"]' TO WS-JSON
     PERFORM DO-PARSE
     MOVE "mcmeta a root that is no object has no pack section" TO TL-CASE
     MOVE "valid=0 error=missing pack section" TO TL-EXPECTED
     PERFORM SUMMARIZE
     MOVE '{"pack":5}' TO WS-JSON
     PERFORM DO-PARSE
     MOVE "mcmeta a pack section that is no object is missing" TO TL-CASE
     MOVE "valid=0 error=missing pack section" TO TL-EXPECTED
     PERFORM SUMMARIZE
     MOVE '{"pack":{"min_format":97,"max_format":97}}' TO WS-JSON
     PERFORM DO-PARSE
     MOVE "mcmeta no description is invalid" TO TL-CASE
     MOVE "valid=0 error=missing description" TO TL-EXPECTED
     PERFORM SUMMARIZE
     MOVE '{"pack":{"pack_format":99}}' TO WS-JSON
     PERFORM DO-PARSE
     MOVE "mcmeta no description and a broken format: the fallback fails too, invalid"
         TO TL-CASE
     MOVE "valid=0 error=missing description" TO TL-EXPECTED
     PERFORM SUMMARIZE
     MOVE '{"pack":{"description":5,"min_format":97,"max_format":97}}' TO WS-JSON
     PERFORM DO-PARSE
     MOVE "mcmeta a number description is invalid" TO TL-CASE
     MOVE "valid=0 error=invalid description" TO TL-EXPECTED
     PERFORM SUMMARIZE

*>   Overlays (08 §1.5, §2.4).
     MOVE '{"pack":{"description":"d","min_format":97,"max_format":97},"overlays":{"entries":['
         & '{"directory":"ov_a","min_format":90,"max_format":97},'
         & '{"directory":"ov-b.2","min_format":98,"max_format":99},'
         & '{"directory":"ov_c"},'
         & '{"directory":"OV_D","min_format":[97,1],"max_format":[97,1]},'
         & '{"directory":"ov_e","min_format":[97,2],"max_format":97}]}}' TO WS-JSON
     PERFORM DO-PARSE
     MOVE "mcmeta overlays: an entry without formats is skipped, active when the range holds "
         & "97.1" TO TL-CASE
     MOVE "valid=1 overlays=4 ov_a:1 ov-b.2:0 OV_D:1 ov_e:0" TO TL-EXPECTED
     PERFORM SUM-OVERLAYS
     MOVE '{"pack":{"description":"d","min_format":97,"max_format":97},"overlays":{"entries":['
         & '{"directory":"l","formats":[10,20]},'
         & '{"directory":"m","min_format":60,"max_format":97,"formats":[60,97]}]}}' TO WS-JSON
     PERFORM DO-PARSE
     MOVE "mcmeta overlays: with a minimum at or below 64 every entry carries formats" TO TL-CASE
     MOVE "valid=1 overlays=2 l:0 m:1" TO TL-EXPECTED
     PERFORM SUM-OVERLAYS
     MOVE '{"pack":{"description":"d","min_format":97,"max_format":97},"overlays":{"entries":['
         & '{"directory":"a","min_format":60,"max_format":97,"formats":[60,97]},'
         & '{"directory":"b","min_format":90,"max_format":97}]}}' TO WS-JSON
     PERFORM DO-PARSE
     MOVE "mcmeta overlays: an entry without formats when another starts at or below 64 is "
         & "invalid" TO TL-CASE
     MOVE "valid=0 overlays=0 error=invalid overlays section" TO TL-EXPECTED
     PERFORM SUM-OVERLAYS
     MOVE '{"pack":{"description":"d","min_format":97,"max_format":97},"overlays":{"entries":['
         & '{"directory":"bad/name","min_format":97,"max_format":97}]}}' TO WS-JSON
     PERFORM DO-PARSE
     MOVE "mcmeta overlays: a directory name outside [-_a-zA-Z0-9.]+ is invalid" TO TL-CASE
     MOVE "valid=0 overlays=0 error=invalid overlays section" TO TL-EXPECTED
     PERFORM SUM-OVERLAYS
     MOVE '{"pack":{"description":"d","min_format":97,"max_format":97},"overlays":{"entries":['
         & '{"directory":"","min_format":97,"max_format":97}]}}' TO WS-JSON
     PERFORM DO-PARSE
     MOVE "mcmeta overlays: an empty directory name is invalid" TO TL-CASE
     MOVE "valid=0 overlays=0 error=invalid overlays section" TO TL-EXPECTED
     PERFORM SUM-OVERLAYS
     MOVE '{"pack":{"description":"d","min_format":97,"max_format":97},"overlays":{"entries":['
         & '{"min_format":97,"max_format":97}]}}' TO WS-JSON
     PERFORM DO-PARSE
     MOVE "mcmeta overlays: an entry without a directory is invalid" TO TL-CASE
     MOVE "valid=0 overlays=0 error=invalid overlays section" TO TL-EXPECTED
     PERFORM SUM-OVERLAYS
     MOVE '{"pack":{"description":"d","min_format":97,"max_format":97},"overlays":{"entries":['
         & '{"directory":"a","min_format":97}]}}' TO WS-JSON
     PERFORM DO-PARSE
     MOVE "mcmeta overlays: an entry with only min_format is invalid" TO TL-CASE
     MOVE "valid=0 overlays=0 error=invalid overlays section" TO TL-EXPECTED
     PERFORM SUM-OVERLAYS
     MOVE '{"pack":{"description":"d","min_format":97,"max_format":97},"overlays":{"entry":[]}}'
         TO WS-JSON
     PERFORM DO-PARSE
     MOVE "mcmeta overlays: a section without entries is invalid" TO TL-CASE
     MOVE "valid=0 overlays=0 error=invalid overlays section" TO TL-EXPECTED
     PERFORM SUM-OVERLAYS
     MOVE '{"pack":{"description":"d","min_format":97,"max_format":97},"overlays":{"entries":['
         & '"a"]}}' TO WS-JSON
     PERFORM DO-PARSE
     MOVE "mcmeta overlays: an entry that is no object is invalid" TO TL-CASE
     MOVE "valid=0 overlays=0 error=invalid overlays section" TO TL-EXPECTED
     PERFORM SUM-OVERLAYS
     MOVE '{"pack":{"description":"d","min_format":97,"max_format":97},"overlays":{"entries":['
         & '{"directory":"a1","min_format":97,"max_format":97},'
         & '{"directory":"a2","min_format":97,"max_format":97},'
         & '{"directory":"a3","min_format":97,"max_format":97},'
         & '{"directory":"a4","min_format":97,"max_format":97},'
         & '{"directory":"a5","min_format":97,"max_format":97},'
         & '{"directory":"a6","min_format":97,"max_format":97},'
         & '{"directory":"a7","min_format":97,"max_format":97},'
         & '{"directory":"a8","min_format":97,"max_format":97},'
         & '{"directory":"a9","min_format":97,"max_format":97}]}}' TO WS-JSON
     PERFORM DO-PARSE
     MOVE "mcmeta overlays: more than 8 entries is invalid" TO TL-CASE
     MOVE "valid=0 overlays=0 error=too many overlays" TO TL-EXPECTED
     PERFORM SUM-OVERLAYS
     MOVE '{"pack":{"description":"d","min_format":97,"max_format":97},"overlays":{"entries":['
         & '{"directory":"aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",'
         & '"min_format":97,"max_format":97}]}}' TO WS-JSON
     PERFORM DO-PARSE
     MOVE "mcmeta overlays: a directory name longer than 64 bytes is invalid" TO TL-CASE
     MOVE "valid=0 overlays=0 error=invalid overlays section" TO TL-EXPECTED
     PERFORM SUM-OVERLAYS

*>   Filter (08 §3.3).
     MOVE '{"pack":{"description":"d","min_format":97,"max_format":97},"filter":{"block":['
         & '{"namespace":"^cobolcraft$","path":"\\.png$"},{"path":"^lang/"}]}}' TO WS-JSON
     PERFORM DO-PARSE
     MOVE "mcmeta filter: two patterns read, the absent namespace marked" TO TL-CASE
     MOVE "valid=1 filters=2 ns=^cobolcraft$ path=\.png$ | ns=* path=^lang/" TO TL-EXPECTED
     PERFORM SUM-FILTERS
     MOVE "cobolcraft" TO WS-NS
     MOVE "textures/block/stone.png" TO WS-PATH
     MOVE "mcmeta filter: cobolcraft textures/block/stone.png is hidden" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     PERFORM CHECK-HIDDEN
     MOVE "models/block/stone.json" TO WS-PATH
     MOVE "mcmeta filter: cobolcraft models/block/stone.json is not hidden" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     PERFORM CHECK-HIDDEN
     MOVE "cobolcraftx" TO WS-NS
     MOVE "textures/block/stone.png" TO WS-PATH
     MOVE "mcmeta filter: the anchored namespace pattern does not hide cobolcraftx" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     PERFORM CHECK-HIDDEN
     MOVE "lang/en_us.json" TO WS-PATH
     MOVE "mcmeta filter: an absent namespace pattern matches every namespace" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     PERFORM CHECK-HIDDEN
     MOVE "x/lang/en_us.json" TO WS-PATH
     MOVE "mcmeta filter: the anchored path pattern needs lang/ at the start" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     PERFORM CHECK-HIDDEN
     MOVE '{"pack":{"description":"d","min_format":97,"max_format":97},"filter":{"block":['
         & '{"namespace":"craft"}]}}' TO WS-JSON
     PERFORM DO-PARSE
     MOVE "cobolcraft" TO WS-NS
     MOVE "anything" TO WS-PATH
     MOVE "mcmeta filter: a namespace pattern is a find match and an absent path matches all"
         TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     PERFORM CHECK-HIDDEN
     MOVE '{"pack":{"description":"d","min_format":97,"max_format":97},"filter":{"block":[{}]}}'
         TO WS-JSON
     PERFORM DO-PARSE
     MOVE "mcmeta filter: an empty pattern hides everything" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     PERFORM CHECK-HIDDEN
     MOVE '{"pack":{"description":"d","min_format":97,"max_format":97}}' TO WS-JSON
     PERFORM DO-PARSE
     MOVE "mcmeta filter: a pack without a filter hides nothing" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     PERFORM CHECK-HIDDEN
     MOVE '{"pack":{"description":"d","min_format":97,"max_format":97},"filter":{"blocks":[]}}'
         TO WS-JSON
     PERFORM DO-PARSE
     MOVE "mcmeta filter: a section without block is invalid" TO TL-CASE
     MOVE "valid=0 filters=0 error=invalid filter section" TO TL-EXPECTED
     PERFORM SUM-FILTERS
     MOVE '{"pack":{"description":"d","min_format":97,"max_format":97},"filter":{"block":['
         & '{"path":"(png"}]}}' TO WS-JSON
     PERFORM DO-PARSE
     MOVE "mcmeta filter: an invalid regular expression makes the metadata invalid" TO TL-CASE
     MOVE "valid=0 filters=0 error=invalid filter pattern" TO TL-EXPECTED
     PERFORM SUM-FILTERS
     MOVE '{"pack":{"description":"d","min_format":97,"max_format":97},"filter":{"block":['
         & '{"namespace":"(?i)x"}]}}' TO WS-JSON
     PERFORM DO-PARSE
     MOVE "mcmeta filter: an unsupported namespace expression makes the metadata invalid"
         TO TL-CASE
     MOVE "valid=0 filters=0 error=invalid filter pattern" TO TL-EXPECTED
     PERFORM SUM-FILTERS
     MOVE '{"pack":{"description":"d","min_format":97,"max_format":97},"filter":{"block":['
         & '{"path":5}]}}' TO WS-JSON
     PERFORM DO-PARSE
     MOVE "mcmeta filter: a pattern that is no string is invalid" TO TL-CASE
     MOVE "valid=0 filters=0 error=invalid filter section" TO TL-EXPECTED
     PERFORM SUM-FILTERS
     MOVE '{"pack":{"description":"d","min_format":97,"max_format":97},"filter":{"block":['
         & '7]}}' TO WS-JSON
     PERFORM DO-PARSE
     MOVE "mcmeta filter: an entry that is no object is invalid" TO TL-CASE
     MOVE "valid=0 filters=0 error=invalid filter section" TO TL-EXPECTED
     PERFORM SUM-FILTERS
     MOVE '{"pack":{"description":"d","min_format":97,"max_format":97},"filter":{"block":['
         & '{"path":"aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa'
         & 'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"}]}}' TO WS-JSON
     PERFORM DO-PARSE
     MOVE "mcmeta filter: a pattern longer than 128 bytes is invalid" TO TL-CASE
     MOVE "valid=0 filters=0 error=invalid filter pattern" TO TL-EXPECTED
     PERFORM SUM-FILTERS
     MOVE '{"pack":{"description":"d","min_format":97,"max_format":97},"filter":{"block":['
         & '{},{},{},{},{},{},{},{},{}]}}' TO WS-JSON
     PERFORM DO-PARSE
     MOVE "mcmeta filter: more than 8 patterns is invalid" TO TL-CASE
     MOVE "valid=0 filters=0 error=too many filter patterns" TO TL-EXPECTED
     PERFORM SUM-FILTERS

*>   Languages (08 §2.5).
     MOVE '{"pack":{"description":"d","min_format":97,"max_format":97},"language":{'
         & '"tlh_aa":{"name":"Klingon","region":"Kronos","bidirectional":true},'
         & '"xx_yy":{"name":"X","region":"Y","bidirectional":false},'
         & '"zz_zz":{"name":"Z","region":"W"}}}' TO WS-JSON
     PERFORM DO-PARSE
     MOVE "mcmeta language: codes with name, region and bidirectional (default false)"
         TO TL-CASE
     MOVE "valid=1 languages=3 tlh_aa/Klingon/Kronos/1 xx_yy/X/Y/0 zz_zz/Z/W/0" TO TL-EXPECTED
     PERFORM SUM-LANGUAGES
     MOVE '{"pack":{"description":"d","min_format":97,"max_format":97},"language":{'
         & '"aa":{"name":"","region":"R"}}}' TO WS-JSON
     PERFORM DO-PARSE
     MOVE "mcmeta language: an empty name is invalid" TO TL-CASE
     MOVE "valid=0 languages=0 error=invalid language section" TO TL-EXPECTED
     PERFORM SUM-LANGUAGES
     MOVE '{"pack":{"description":"d","min_format":97,"max_format":97},"language":{'
         & '"aa":{"name":"N"}}}' TO WS-JSON
     PERFORM DO-PARSE
     MOVE "mcmeta language: a missing region is invalid" TO TL-CASE
     MOVE "valid=0 languages=0 error=invalid language section" TO TL-EXPECTED
     PERFORM SUM-LANGUAGES
     MOVE '{"pack":{"description":"d","min_format":97,"max_format":97},"language":{'
         & '"aaaaaaaaaaaaaaaaa":{"name":"N","region":"R"}}}' TO WS-JSON
     PERFORM DO-PARSE
     MOVE "mcmeta language: a code longer than 16 characters is invalid" TO TL-CASE
     MOVE "valid=0 languages=0 error=invalid language section" TO TL-EXPECTED
     PERFORM SUM-LANGUAGES
     MOVE '{"pack":{"description":"d","min_format":97,"max_format":97},"language":{'
         & '"":{"name":"N","region":"R"}}}' TO WS-JSON
     PERFORM DO-PARSE
     MOVE "mcmeta language: an empty code is invalid" TO TL-CASE
     MOVE "valid=0 languages=0 error=invalid language section" TO TL-EXPECTED
     PERFORM SUM-LANGUAGES
     MOVE '{"pack":{"description":"d","min_format":97,"max_format":97},"language":{'
         & '"aa":{"name":"N","region":"R","bidirectional":1}}}' TO WS-JSON
     PERFORM DO-PARSE
     MOVE "mcmeta language: a bidirectional that is no boolean is invalid" TO TL-CASE
     MOVE "valid=0 languages=0 error=invalid language section" TO TL-EXPECTED
     PERFORM SUM-LANGUAGES
     MOVE '{"pack":{"description":"d","min_format":97,"max_format":97},"language":{'
         & '"aa":"N"}}' TO WS-JSON
     PERFORM DO-PARSE
     MOVE "mcmeta language: a LanguageInfo that is no object is invalid" TO TL-CASE
     MOVE "valid=0 languages=0 error=invalid language section" TO TL-EXPECTED
     PERFORM SUM-LANGUAGES
     MOVE '{"pack":{"description":"d","min_format":97,"max_format":97},"language":[]}'
         TO WS-JSON
     PERFORM DO-PARSE
     MOVE "mcmeta language: a section that is no object is invalid" TO TL-CASE
     MOVE "valid=0 languages=0 error=invalid language section" TO TL-EXPECTED
     PERFORM SUM-LANGUAGES
     MOVE '{"pack":{"description":"d","min_format":97,"max_format":97},"language":{'
         & '"a1":{"name":"N","region":"R"},"a2":{"name":"N","region":"R"},'
         & '"a3":{"name":"N","region":"R"},"a4":{"name":"N","region":"R"},'
         & '"a5":{"name":"N","region":"R"},"a6":{"name":"N","region":"R"},'
         & '"a7":{"name":"N","region":"R"},"a8":{"name":"N","region":"R"},'
         & '"a9":{"name":"N","region":"R"}}}' TO WS-JSON
     PERFORM DO-PARSE
     MOVE "mcmeta language: more than 8 languages is invalid" TO TL-CASE
     MOVE "valid=0 languages=0 error=too many languages" TO TL-EXPECTED
     PERFORM SUM-LANGUAGES

*>   Features (08 §2.6).
     MOVE '{"pack":{"description":"d","min_format":97,"max_format":97},"features":{"enabled":['
         & '"cobolcraft:extra","minecraft:trade_rebalance","bundle","x/y.z"]}}' TO WS-JSON
     PERFORM DO-PARSE
     MOVE "mcmeta features: the enabled identifiers in order (a bare path is minecraft's)"
         TO TL-CASE
     MOVE "valid=1 features=4 cobolcraft:extra minecraft:trade_rebalance bundle x/y.z"
         TO TL-EXPECTED
     PERFORM SUM-FEATURES
     MOVE '{"pack":{"description":"d","min_format":97,"max_format":97},"features":{}}'
         TO WS-JSON
     PERFORM DO-PARSE
     MOVE "mcmeta features: a section without enabled is invalid" TO TL-CASE
     MOVE "valid=0 features=0 error=invalid features section" TO TL-EXPECTED
     PERFORM SUM-FEATURES
     MOVE '{"pack":{"description":"d","min_format":97,"max_format":97},"features":{"enabled":['
         & '"Bad:id"]}}' TO WS-JSON
     PERFORM DO-PARSE
     MOVE "mcmeta features: an upper-case namespace is no identifier, invalid" TO TL-CASE
     MOVE "valid=0 features=0 error=invalid features section" TO TL-EXPECTED
     PERFORM SUM-FEATURES
     MOVE '{"pack":{"description":"d","min_format":97,"max_format":97},"features":{"enabled":['
         & '"ok:bad path"]}}' TO WS-JSON
     PERFORM DO-PARSE
     MOVE "mcmeta features: a space in the path is no identifier, invalid" TO TL-CASE
     MOVE "valid=0 features=0 error=invalid features section" TO TL-EXPECTED
     PERFORM SUM-FEATURES
     MOVE '{"pack":{"description":"d","min_format":97,"max_format":97},"features":{"enabled":['
         & '5]}}' TO WS-JSON
     PERFORM DO-PARSE
     MOVE "mcmeta features: an entry that is no string is invalid" TO TL-CASE
     MOVE "valid=0 features=0 error=invalid features section" TO TL-EXPECTED
     PERFORM SUM-FEATURES
     MOVE '{"pack":{"description":"d","min_format":97,"max_format":97},"features":{"enabled":['
         & '"aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"'
         & ']}}' TO WS-JSON
     PERFORM DO-PARSE
     MOVE "mcmeta features: an identifier longer than 80 bytes is invalid" TO TL-CASE
     MOVE "valid=0 features=0 error=invalid features section" TO TL-EXPECTED
     PERFORM SUM-FEATURES
     MOVE '{"pack":{"description":"d","min_format":97,"max_format":97},"features":{"enabled":['
         & '"a","b","c","d","e","f","g","h","i"]}}' TO WS-JSON
     PERFORM DO-PARSE
     MOVE "mcmeta features: more than 8 identifiers is invalid" TO TL-CASE
     MOVE "valid=0 features=0 error=too many features" TO TL-EXPECTED
     PERFORM SUM-FEATURES
     STOP RUN.

 DO-PARSE.
     MOVE 4000 TO WS-JSON-LENGTH
     PERFORM UNTIL WS-JSON-LENGTH = 0 OR WS-JSON(WS-JSON-LENGTH:1) NOT = SPACE
         SUBTRACT 1 FROM WS-JSON-LENGTH
     END-PERFORM
     CALL "MCMETA-PARSE" USING CLIENT-STATE WS-JSON WS-JSON-LENGTH PACK-META
     MOVE SPACES TO WS-JSON.

 ADD-VALID.
     MOVE SPACES TO WS-SUM
     MOVE 1 TO WS-PTR
     STRING "valid=" PM-VALID DELIMITED BY SIZE INTO WS-SUM WITH POINTER WS-PTR.

 ADD-NUMBER.
     MOVE WS-I TO WS-EDIT
     STRING FUNCTION TRIM(WS-EDIT) DELIMITED BY SIZE INTO WS-SUM WITH POINTER WS-PTR.

 ADD-ERROR.
     IF PM-ERROR-LENGTH > 0
         STRING " error=" PM-ERROR(1:PM-ERROR-LENGTH) DELIMITED BY SIZE
             INTO WS-SUM WITH POINTER WS-PTR
     END-IF.

 ASSERT-SUM.
     MOVE "T" TO TL-MODE
     MOVE WS-SUM TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

 SUMMARIZE.
     PERFORM ADD-VALID
     IF PM-VALID = 1
         STRING " compat=" DELIMITED BY SIZE INTO WS-SUM WITH POINTER WS-PTR
         MOVE PM-COMPAT TO WS-I
         PERFORM ADD-NUMBER
         STRING " min=" DELIMITED BY SIZE INTO WS-SUM WITH POINTER WS-PTR
         MOVE PM-MIN-MAJOR TO WS-I
         PERFORM ADD-NUMBER
         STRING "." DELIMITED BY SIZE INTO WS-SUM WITH POINTER WS-PTR
         MOVE PM-MIN-MINOR TO WS-I
         PERFORM ADD-NUMBER
         STRING " max=" DELIMITED BY SIZE INTO WS-SUM WITH POINTER WS-PTR
         MOVE PM-MAX-MAJOR TO WS-I
         PERFORM ADD-NUMBER
         STRING "." DELIMITED BY SIZE INTO WS-SUM WITH POINTER WS-PTR
         MOVE PM-MAX-MINOR TO WS-I
         PERFORM ADD-NUMBER
         STRING " desc=" PM-DESC(1:FUNCTION MAX(PM-DESC-LENGTH, 1)) DELIMITED BY SIZE
             INTO WS-SUM WITH POINTER WS-PTR
     END-IF
     PERFORM ADD-ERROR
     PERFORM ASSERT-SUM.

 SUM-OVERLAYS.
     PERFORM ADD-VALID
     STRING " overlays=" DELIMITED BY SIZE INTO WS-SUM WITH POINTER WS-PTR
     MOVE PM-OVERLAY-COUNT TO WS-I
     PERFORM ADD-NUMBER
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > PM-OVERLAY-COUNT
         MOVE PM-OVERLAY-DIR-LENGTH(WS-I) TO WS-LEN
         STRING " " PM-OVERLAY-DIR(WS-I)(1:WS-LEN) ":" PM-OVERLAY-ACTIVE(WS-I)
             DELIMITED BY SIZE INTO WS-SUM WITH POINTER WS-PTR
     END-PERFORM
     PERFORM ADD-ERROR
     PERFORM ASSERT-SUM.

 SUM-FILTERS.
     PERFORM ADD-VALID
     STRING " filters=" DELIMITED BY SIZE INTO WS-SUM WITH POINTER WS-PTR
     MOVE PM-FILTER-COUNT TO WS-I
     PERFORM ADD-NUMBER
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > PM-FILTER-COUNT
         IF WS-I > 1
             STRING " |" DELIMITED BY SIZE INTO WS-SUM WITH POINTER WS-PTR
         END-IF
         IF PM-FILTER-NS-PRESENT(WS-I) = 1
             MOVE PM-FILTER-NS-LENGTH(WS-I) TO WS-LEN
             STRING " ns=" PM-FILTER-NS(WS-I)(1:WS-LEN) DELIMITED BY SIZE
                 INTO WS-SUM WITH POINTER WS-PTR
         ELSE
             STRING " ns=*" DELIMITED BY SIZE INTO WS-SUM WITH POINTER WS-PTR
         END-IF
         IF PM-FILTER-PATH-PRESENT(WS-I) = 1
             MOVE PM-FILTER-PATH-LENGTH(WS-I) TO WS-LEN
             STRING " path=" PM-FILTER-PATH(WS-I)(1:WS-LEN) DELIMITED BY SIZE
                 INTO WS-SUM WITH POINTER WS-PTR
         ELSE
             STRING " path=*" DELIMITED BY SIZE INTO WS-SUM WITH POINTER WS-PTR
         END-IF
     END-PERFORM
     PERFORM ADD-ERROR
     PERFORM ASSERT-SUM.

 CHECK-HIDDEN.
     MOVE 64 TO WS-NS-LENGTH
     PERFORM UNTIL WS-NS-LENGTH = 0 OR WS-NS(WS-NS-LENGTH:1) NOT = SPACE
         SUBTRACT 1 FROM WS-NS-LENGTH
     END-PERFORM
     MOVE 256 TO WS-PATH-LENGTH
     PERFORM UNTIL WS-PATH-LENGTH = 0 OR WS-PATH(WS-PATH-LENGTH:1) NOT = SPACE
         SUBTRACT 1 FROM WS-PATH-LENGTH
     END-PERFORM
     MOVE 7 TO WS-HIDDEN
     CALL "MCMETA-FILTERS" USING PACK-META WS-NS WS-NS-LENGTH WS-PATH WS-PATH-LENGTH WS-HIDDEN
     MOVE "N" TO TL-MODE
     MOVE WS-HIDDEN TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

 SUM-LANGUAGES.
     PERFORM ADD-VALID
     STRING " languages=" DELIMITED BY SIZE INTO WS-SUM WITH POINTER WS-PTR
     MOVE PM-LANG-COUNT TO WS-I
     PERFORM ADD-NUMBER
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > PM-LANG-COUNT
         MOVE PM-LANG-CODE-LENGTH(WS-I) TO WS-LEN
         STRING " " PM-LANG-CODE(WS-I)(1:WS-LEN) "/" DELIMITED BY SIZE
             INTO WS-SUM WITH POINTER WS-PTR
         MOVE PM-LANG-NAME-LENGTH(WS-I) TO WS-LEN
         STRING PM-LANG-NAME(WS-I)(1:WS-LEN) "/" DELIMITED BY SIZE
             INTO WS-SUM WITH POINTER WS-PTR
         MOVE PM-LANG-REGION-LENGTH(WS-I) TO WS-LEN
         STRING PM-LANG-REGION(WS-I)(1:WS-LEN) "/" PM-LANG-BIDI(WS-I) DELIMITED BY SIZE
             INTO WS-SUM WITH POINTER WS-PTR
     END-PERFORM
     PERFORM ADD-ERROR
     PERFORM ASSERT-SUM.

 SUM-FEATURES.
     PERFORM ADD-VALID
     STRING " features=" DELIMITED BY SIZE INTO WS-SUM WITH POINTER WS-PTR
     MOVE PM-FEATURE-COUNT TO WS-I
     PERFORM ADD-NUMBER
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > PM-FEATURE-COUNT
         MOVE PM-FEATURE-ID-LENGTH(WS-I) TO WS-LEN
         STRING " " PM-FEATURE-ID(WS-I)(1:WS-LEN) DELIMITED BY SIZE
             INTO WS-SUM WITH POINTER WS-PTR
     END-PERFORM
     PERFORM ADD-ERROR
     PERFORM ASSERT-SUM.
 END PROGRAM TEST-MCMETA.
