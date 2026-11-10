*> level.dat time handling (data-model section 6; docs/protocol/07 section 9.2 "Time and clocks";
*> docs/design/cobolcraft-standard-core.md CORE-5). The read and write of the file itself stay in
*> persistence.cob until the split of T0331.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. LEVEL-TIME-REBASE.
*> USING time (BINARY-DOUBLE, in and out): a time of day of the 30,000-tick day of a level.dat of feature 001
*> becomes the same phase of the standard 24,000-tick day: time * 24000 / 30000, truncated. (The phase rule
*> is an assumption: the documents say "re-based by the standard timeline" without a formula.)
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY RULES.
 LINKAGE SECTION.
 01 L-TIME                 BINARY-DOUBLE.
 PROCEDURE DIVISION USING L-TIME.
     COMPUTE L-TIME = L-TIME * RULE-DAY-LENGTH / RULE-OLD-DAY-LENGTH
     GOBACK.
 END PROGRAM LEVEL-TIME-REBASE.
