*> Test of 44 part 3 section 2.1 to 2.5, the POI behaviours of the villager brain as decision units (lane 002-lane-p49h, T22002).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-Q44-44-3-2.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-CASE                PIC X(240).
 01 WS-E                   BINARY-LONG.
 01 WS-O                   BINARY-LONG.
 01 WS-VALID.
    05 WS-VALID-T            BINARY-LONG OCCURS 12 TIMES.
 01 WS-XS.
    05 WS-XS-T            BINARY-LONG OCCURS 8 TIMES.
 01 WS-LOSER.
    05 WS-LOSER-T            BINARY-LONG OCCURS 8 TIMES.
 01 WS-BABY                 BINARY-LONG.
 01 WS-ADULT                BINARY-LONG.
 01 WS-NOW                  BINARY-LONG.
 01 WS-NEXT                 BINARY-LONG.
 01 WS-DRAW                 BINARY-LONG.
 01 WS-MODE                 BINARY-LONG.
 01 WS-PREVIOUS             BINARY-LONG.
 01 WS-DELAY                BINARY-LONG.
 01 WS-YES                  BINARY-LONG.
 01 WS-ENTRY                BINARY-LONG.
 01 WS-RETRY                BINARY-LONG.
 01 WS-PASS                 BINARY-LONG.
 01 WS-MARK                 BINARY-LONG.
 01 WS-SAME                 BINARY-LONG.
 01 WS-FIRST                BINARY-LONG.
 01 WS-SECOND               BINARY-LONG.
 01 WS-COUNT                BINARY-LONG.
 01 WS-KEPT                 BINARY-LONG.
 01 WS-PATH                 BINARY-LONG.
 01 WS-REACH                BINARY-LONG.
 01 WS-OUTCOME              BINARY-LONG.
 01 WS-SAMEDIM              BINARY-LONG.
 01 WS-NEAR                 BINARY-LONG.
 01 WS-REC                  BINARY-LONG.
 01 WS-HOME                 BINARY-LONG.
 01 WS-OCC                  BINARY-LONG.
 01 WS-SLEEPING             BINARY-LONG.
 01 WS-OTHER                BINARY-LONG.
 01 WS-ACTION               BINARY-LONG.
 01 WS-WINNER               BINARY-LONG.
 01 WS-POT                  BINARY-LONG.
 01 WS-ACC                  BINARY-LONG.
 01 WS-JOB                  BINARY-LONG.
 01 WS-NONE                 BINARY-LONG.
 01 WS-FOUND                BINARY-LONG.
 01 WS-ACT                  BINARY-LONG.
 01 WS-ACCEPTABLE           BINARY-LONG.
 01 WS-RELEASE              BINARY-LONG.
 PROCEDURE DIVISION.
    MOVE 1 TO WS-BABY
    MOVE 1 TO WS-ADULT
    MOVE 1000 TO WS-NOW
    MOVE 0 TO WS-NEXT
    MOVE 7 TO WS-DRAW
    CALL "Q3-ACQ-GATE" USING WS-BABY WS-ADULT WS-NOW WS-NEXT WS-DRAW WS-MODE
    MOVE "acceptance US15 44-3§2.1 step 1: an adult-only AcquirePoi does nothing for a baby (timer untouched)" TO WS-CASE
    MOVE 0 TO WS-E
    MOVE WS-MODE TO WS-O
    CALL "Q3-EQ" USING WS-CASE WS-E WS-O
    MOVE "acceptance US15 44-3§2.1 step 1: the timer stays 0" TO WS-CASE
    MOVE 0 TO WS-E
    MOVE WS-NEXT TO WS-O
    CALL "Q3-EQ" USING WS-CASE WS-E WS-O
    MOVE 0 TO WS-BABY
    MOVE 0 TO WS-NEXT
    CALL "Q3-ACQ-GATE" USING WS-BABY WS-ADULT WS-NOW WS-NEXT WS-DRAW WS-MODE
    MOVE "acceptance US15 44-3§2.1 step 2: the very first evaluation ends after setting the timer" TO WS-CASE
    MOVE 1 TO WS-E
    MOVE WS-MODE TO WS-O
    CALL "Q3-EQ" USING WS-CASE WS-E WS-O
    MOVE "acceptance US15 44-3§2.1 step 2: nextScan is gameTime + nextInt(20) on the first evaluation" TO WS-CASE
    MOVE 1007 TO WS-E
    MOVE WS-NEXT TO WS-O
    CALL "Q3-EQ" USING WS-CASE WS-E WS-O
    MOVE 1006 TO WS-NOW
    CALL "Q3-ACQ-GATE" USING WS-BABY WS-ADULT WS-NOW WS-NEXT WS-DRAW WS-MODE
    MOVE "acceptance US15 44-3§2.1 step 2: before nextScan nothing happens" TO WS-CASE
    MOVE 2 TO WS-E
    MOVE WS-MODE TO WS-O
    CALL "Q3-EQ" USING WS-CASE WS-E WS-O
    MOVE "acceptance US15 44-3§2.1 step 2: the timer is kept" TO WS-CASE
    MOVE 1007 TO WS-E
    MOVE WS-NEXT TO WS-O
    CALL "Q3-EQ" USING WS-CASE WS-E WS-O
    MOVE 1007 TO WS-NOW
    MOVE 19 TO WS-DRAW
    CALL "Q3-ACQ-GATE" USING WS-BABY WS-ADULT WS-NOW WS-NEXT WS-DRAW WS-MODE
    MOVE "acceptance US15 44-3§2.1 step 2: at nextScan the scan runs" TO WS-CASE
    MOVE 3 TO WS-E
    MOVE WS-MODE TO WS-O
    CALL "Q3-EQ" USING WS-CASE WS-E WS-O
    MOVE "acceptance US15 44-3§2.1 step 2: the next scan is 20 + nextInt(20) later (1007+20+19)" TO WS-CASE
    MOVE 1046 TO WS-E
    MOVE WS-NEXT TO WS-O
    CALL "Q3-EQ" USING WS-CASE WS-E WS-O
    MOVE 1 TO WS-BABY
    MOVE 0 TO WS-ADULT
    MOVE 0 TO WS-NEXT
    MOVE 50 TO WS-NOW
    MOVE 3 TO WS-DRAW
    CALL "Q3-ACQ-GATE" USING WS-BABY WS-ADULT WS-NOW WS-NEXT WS-DRAW WS-MODE
    MOVE "acceptance US15 44-3§2.1 step 1: a baby may run the home entry (onlyAdult false)" TO WS-CASE
    MOVE 1 TO WS-E
    MOVE WS-MODE TO WS-O
    CALL "Q3-EQ" USING WS-CASE WS-E WS-O
    MOVE 100 TO WS-NOW
    MOVE 0 TO WS-PREVIOUS
    MOVE 0 TO WS-DELAY
    MOVE 0 TO WS-DRAW
    CALL "Q3-ACQ-RETRY" USING WS-NOW WS-PREVIOUS WS-DELAY WS-DRAW WS-NEXT
    MOVE "acceptance US15 44-3§2.1 retry: the first attempt waits 40 + nextInt(40) (draw 0 gives 40)" TO WS-CASE
    MOVE 40 TO WS-E
    MOVE WS-DELAY TO WS-O
    CALL "Q3-EQ" USING WS-CASE WS-E WS-O
    MOVE "acceptance US15 44-3§2.1 retry: the next allowed attempt is now + delay" TO WS-CASE
    MOVE 140 TO WS-E
    MOVE WS-NEXT TO WS-O
    CALL "Q3-EQ" USING WS-CASE WS-E WS-O
    MOVE "acceptance US15 44-3§2.1 retry: previousAttempt is now" TO WS-CASE
    MOVE 100 TO WS-E
    MOVE WS-PREVIOUS TO WS-O
    CALL "Q3-EQ" USING WS-CASE WS-E WS-O
    MOVE 200 TO WS-NOW
    MOVE 39 TO WS-DRAW
    CALL "Q3-ACQ-RETRY" USING WS-NOW WS-PREVIOUS WS-DELAY WS-DRAW WS-NEXT
    MOVE "acceptance US15 44-3§2.1 retry: the second failure adds 40 to 79 (40 + 39 + 40 = 119)" TO WS-CASE
    MOVE 119 TO WS-E
    MOVE WS-DELAY TO WS-O
    CALL "Q3-EQ" USING WS-CASE WS-E WS-O
    MOVE "acceptance US15 44-3§2.1 retry: next allowed 200 + 119" TO WS-CASE
    MOVE 319 TO WS-E
    MOVE WS-NEXT TO WS-O
    CALL "Q3-EQ" USING WS-CASE WS-E WS-O
    MOVE 300 TO WS-NOW
    MOVE 39 TO WS-DRAW
    MOVE 350 TO WS-DELAY
    CALL "Q3-ACQ-RETRY" USING WS-NOW WS-PREVIOUS WS-DELAY WS-DRAW WS-NEXT
    MOVE "acceptance US15 44-3§2.1 retry: the delay is capped at 400" TO WS-CASE
    MOVE 400 TO WS-E
    MOVE WS-DELAY TO WS-O
    CALL "Q3-EQ" USING WS-CASE WS-E WS-O
    MOVE "acceptance US15 44-3§2.1 retry: next allowed at the cap" TO WS-CASE
    MOVE 700 TO WS-E
    MOVE WS-NEXT TO WS-O
    CALL "Q3-EQ" USING WS-CASE WS-E WS-O
    MOVE 700 TO WS-NOW
    MOVE 700 TO WS-NEXT
    CALL "Q3-ACQ-SHOULD-RETRY" USING WS-NOW WS-NEXT WS-YES
    MOVE "acceptance US15 44-3§2.1 retry: allowed at the next allowed tick" TO WS-CASE
    MOVE 1 TO WS-E
    MOVE WS-YES TO WS-O
    CALL "Q3-EQ" USING WS-CASE WS-E WS-O
    MOVE 699 TO WS-NOW
    CALL "Q3-ACQ-SHOULD-RETRY" USING WS-NOW WS-NEXT WS-YES
    MOVE "acceptance US15 44-3§2.1 retry: not allowed one tick earlier" TO WS-CASE
    MOVE 0 TO WS-E
    MOVE WS-YES TO WS-O
    CALL "Q3-EQ" USING WS-CASE WS-E WS-O
    MOVE 500 TO WS-NOW
    MOVE 101 TO WS-PREVIOUS
    CALL "Q3-ACQ-STILL-VALID" USING WS-NOW WS-PREVIOUS WS-YES
    MOVE "acceptance US15 44-3§2.1 step 3: 399 ticks since the last attempt keeps the entry" TO WS-CASE
    MOVE 1 TO WS-E
    MOVE WS-YES TO WS-O
    CALL "Q3-EQ" USING WS-CASE WS-E WS-O
    MOVE 100 TO WS-PREVIOUS
    CALL "Q3-ACQ-STILL-VALID" USING WS-NOW WS-PREVIOUS WS-YES
    MOVE "acceptance US15 44-3§2.1 step 3: 400 ticks old is dropped" TO WS-CASE
    MOVE 0 TO WS-E
    MOVE WS-YES TO WS-O
    CALL "Q3-EQ" USING WS-CASE WS-E WS-O
    MOVE 0 TO WS-ENTRY
    MOVE 0 TO WS-RETRY
    CALL "Q3-ACQ-FILTER" USING WS-ENTRY WS-RETRY WS-PASS WS-MARK
    MOVE "acceptance US15 44-3§2.1 step 4: a position without an entry passes" TO WS-CASE
    MOVE 1 TO WS-E
    MOVE WS-PASS TO WS-O
    CALL "Q3-EQ" USING WS-CASE WS-E WS-O
    MOVE "acceptance US15 44-3§2.1 step 4: and is not marked" TO WS-CASE
    MOVE 0 TO WS-E
    MOVE WS-MARK TO WS-O
    CALL "Q3-EQ" USING WS-CASE WS-E WS-O
    MOVE 1 TO WS-ENTRY
    MOVE 1 TO WS-RETRY
    CALL "Q3-ACQ-FILTER" USING WS-ENTRY WS-RETRY WS-PASS WS-MARK
    MOVE "acceptance US15 44-3§2.1 step 4: an entry whose shouldRetry holds passes" TO WS-CASE
    MOVE 1 TO WS-E
    MOVE WS-PASS TO WS-O
    CALL "Q3-EQ" USING WS-CASE WS-E WS-O
    MOVE "acceptance US15 44-3§2.1 step 4: and the attempt is marked" TO WS-CASE
    MOVE 1 TO WS-E
    MOVE WS-MARK TO WS-O
    CALL "Q3-EQ" USING WS-CASE WS-E WS-O
    MOVE 0 TO WS-RETRY
    CALL "Q3-ACQ-FILTER" USING WS-ENTRY WS-RETRY WS-PASS WS-MARK
    MOVE "acceptance US15 44-3§2.1 step 4: an entry that says not yet is rejected" TO WS-CASE
    MOVE 0 TO WS-E
    MOVE WS-PASS TO WS-O
    CALL "Q3-EQ" USING WS-CASE WS-E WS-O
    MOVE "acceptance US15 44-3§2.1 step 4: and not marked" TO WS-CASE
    MOVE 0 TO WS-E
    MOVE WS-MARK TO WS-O
    CALL "Q3-EQ" USING WS-CASE WS-E WS-O
    MOVE 1 TO WS-SAME
    MOVE 0 TO WS-FIRST
    MOVE 0 TO WS-SECOND
    CALL "Q3-ACQ-START" USING WS-SAME WS-FIRST WS-SECOND WS-YES
    MOVE "acceptance US15 44-3§2.1 factory: single memory absent starts" TO WS-CASE
    MOVE 1 TO WS-E
    MOVE WS-YES TO WS-O
    CALL "Q3-EQ" USING WS-CASE WS-E WS-O
    MOVE 1 TO WS-SECOND
    CALL "Q3-ACQ-START" USING WS-SAME WS-FIRST WS-SECOND WS-YES
    MOVE "acceptance US15 44-3§2.1 factory: the stored memory present blocks" TO WS-CASE
    MOVE 0 TO WS-E
    MOVE WS-YES TO WS-O
    CALL "Q3-EQ" USING WS-CASE WS-E WS-O
    MOVE 0 TO WS-SAME
    MOVE 1 TO WS-FIRST
    MOVE 0 TO WS-SECOND
    CALL "Q3-ACQ-START" USING WS-SAME WS-FIRST WS-SECOND WS-YES
    MOVE "acceptance US15 44-3§2.1 factory: job entry (job_site present) blocks" TO WS-CASE
    MOVE 0 TO WS-E
    MOVE WS-YES TO WS-O
    CALL "Q3-EQ" USING WS-CASE WS-E WS-O
    MOVE 0 TO WS-FIRST
    CALL "Q3-ACQ-START" USING WS-SAME WS-FIRST WS-SECOND WS-YES
    MOVE "acceptance US15 44-3§2.1 factory: job entry with both absent starts" TO WS-CASE
    MOVE 1 TO WS-E
    MOVE WS-YES TO WS-O
    CALL "Q3-EQ" USING WS-CASE WS-E WS-O
    MOVE 1 TO WS-VALID-T(1)
    MOVE 1 TO WS-VALID-T(2)
    MOVE 1 TO WS-VALID-T(3)
    MOVE 1 TO WS-VALID-T(4)
    MOVE 1 TO WS-VALID-T(5)
    MOVE 1 TO WS-VALID-T(6)
    MOVE 1 TO WS-VALID-T(7)
    MOVE 1 TO WS-VALID-T(8)
    MOVE 1 TO WS-VALID-T(9)
    MOVE 1 TO WS-VALID-T(10)
    MOVE 1 TO WS-VALID-T(11)
    MOVE 1 TO WS-VALID-T(12)
    MOVE 7 TO WS-COUNT
    CALL "Q3-ACQ-LIMIT" USING WS-COUNT WS-VALID WS-KEPT
    MOVE "acceptance US15 44-3§2.1 step 4: seven filter-passing candidates are limited to five" TO WS-CASE
    MOVE 5 TO WS-E
    MOVE WS-KEPT TO WS-O
    CALL "Q3-EQ" USING WS-CASE WS-E WS-O
    MOVE 0 TO WS-VALID-T(2)
    MOVE 0 TO WS-VALID-T(6)
    CALL "Q3-ACQ-LIMIT" USING WS-COUNT WS-VALID WS-KEPT
    MOVE "acceptance US15 44-3§2.1 step 4: the validity predicate runs after the limit (the 2nd of five fails, the 6th is cut off) so 4 are kept" TO WS-CASE
    MOVE 4 TO WS-E
    MOVE WS-KEPT TO WS-O
    CALL "Q3-EQ" USING WS-CASE WS-E WS-O
    MOVE 3 TO WS-COUNT
    CALL "Q3-ACQ-LIMIT" USING WS-COUNT WS-VALID WS-KEPT
    MOVE "acceptance US15 44-3§2.1 step 4: fewer than five candidates are all examined" TO WS-CASE
    MOVE 2 TO WS-E
    MOVE WS-KEPT TO WS-O
    CALL "Q3-EQ" USING WS-CASE WS-E WS-O
    MOVE 1 TO WS-PATH
    MOVE 1 TO WS-REACH
    CALL "Q3-ACQ-OUTCOME" USING WS-PATH WS-REACH WS-OUTCOME
    MOVE "acceptance US15 44-3§2.1 step 6: a path that reaches claims the target" TO WS-CASE
    MOVE 1 TO WS-E
    MOVE WS-OUTCOME TO WS-O
    CALL "Q3-EQ" USING WS-CASE WS-E WS-O
    MOVE 0 TO WS-REACH
    CALL "Q3-ACQ-OUTCOME" USING WS-PATH WS-REACH WS-OUTCOME
    MOVE "acceptance US15 44-3§2.1 step 7: a path that does not reach gives every candidate a retry object" TO WS-CASE
    MOVE 2 TO WS-E
    MOVE WS-OUTCOME TO WS-O
    CALL "Q3-EQ" USING WS-CASE WS-E WS-O
    MOVE 0 TO WS-PATH
    CALL "Q3-ACQ-OUTCOME" USING WS-PATH WS-REACH WS-OUTCOME
    MOVE "acceptance US15 44-3§2.1 step 7: no path gives every candidate a retry object" TO WS-CASE
    MOVE 2 TO WS-E
    MOVE WS-OUTCOME TO WS-O
    CALL "Q3-EQ" USING WS-CASE WS-E WS-O
    MOVE 0 TO WS-SAMEDIM
    MOVE 1 TO WS-NEAR
    MOVE 1 TO WS-REC
    MOVE 1 TO WS-HOME
    MOVE 1 TO WS-OCC
    MOVE 0 TO WS-SLEEPING
    MOVE 0 TO WS-OTHER
    CALL "Q3-VALIDATE-POI" USING WS-SAMEDIM WS-NEAR WS-REC WS-HOME WS-OCC WS-SLEEPING WS-OTHER WS-ACTION
    MOVE "acceptance US15 44-3§2.2 another dimension: the memory is kept" TO WS-CASE
    MOVE 0 TO WS-E
    MOVE WS-ACTION TO WS-O
    CALL "Q3-EQ" USING WS-CASE WS-E WS-O
    MOVE 1 TO WS-SAMEDIM
    MOVE 0 TO WS-NEAR
    CALL "Q3-VALIDATE-POI" USING WS-SAMEDIM WS-NEAR WS-REC WS-HOME WS-OCC WS-SLEEPING WS-OTHER WS-ACTION
    MOVE "acceptance US15 44-3§2.2 farther than 16 blocks: the memory is kept" TO WS-CASE
    MOVE 0 TO WS-E
    MOVE WS-ACTION TO WS-O
    CALL "Q3-EQ" USING WS-CASE WS-E WS-O
    MOVE 1 TO WS-NEAR
    MOVE 0 TO WS-REC
    CALL "Q3-VALIDATE-POI" USING WS-SAMEDIM WS-NEAR WS-REC WS-HOME WS-OCC WS-SLEEPING WS-OTHER WS-ACTION
    MOVE "acceptance US15 44-3§2.2 no record at the position: the memory is erased" TO WS-CASE
    MOVE 1 TO WS-E
    MOVE WS-ACTION TO WS-O
    CALL "Q3-EQ" USING WS-CASE WS-E WS-O
    MOVE 1 TO WS-REC
    CALL "Q3-VALIDATE-POI" USING WS-SAMEDIM WS-NEAR WS-REC WS-HOME WS-OCC WS-SLEEPING WS-OTHER WS-ACTION
    MOVE "acceptance US15 44-3§2.2 a player sleeps in the villager's bed: erased and the ticket released" TO WS-CASE
    MOVE 2 TO WS-E
    MOVE WS-ACTION TO WS-O
    CALL "Q3-EQ" USING WS-CASE WS-E WS-O
    MOVE 1 TO WS-OTHER
    CALL "Q3-VALIDATE-POI" USING WS-SAMEDIM WS-NEAR WS-REC WS-HOME WS-OCC WS-SLEEPING WS-OTHER WS-ACTION
    MOVE "acceptance US15 44-3§2.2 another villager lies in the bed: erased, ticket not released" TO WS-CASE
    MOVE 1 TO WS-E
    MOVE WS-ACTION TO WS-O
    CALL "Q3-EQ" USING WS-CASE WS-E WS-O
    MOVE 0 TO WS-OTHER
    MOVE 1 TO WS-SLEEPING
    CALL "Q3-VALIDATE-POI" USING WS-SAMEDIM WS-NEAR WS-REC WS-HOME WS-OCC WS-SLEEPING WS-OTHER WS-ACTION
    MOVE "acceptance US15 44-3§2.2 the villager itself sleeping in the bed keeps its claim" TO WS-CASE
    MOVE 0 TO WS-E
    MOVE WS-ACTION TO WS-O
    CALL "Q3-EQ" USING WS-CASE WS-E WS-O
    MOVE 0 TO WS-SLEEPING
    MOVE 0 TO WS-OCC
    CALL "Q3-VALIDATE-POI" USING WS-SAMEDIM WS-NEAR WS-REC WS-HOME WS-OCC WS-SLEEPING WS-OTHER WS-ACTION
    MOVE "acceptance US15 44-3§2.2 a free bed keeps the claim" TO WS-CASE
    MOVE 0 TO WS-E
    MOVE WS-ACTION TO WS-O
    CALL "Q3-EQ" USING WS-CASE WS-E WS-O
    MOVE 1 TO WS-OCC
    MOVE 0 TO WS-HOME
    CALL "Q3-VALIDATE-POI" USING WS-SAMEDIM WS-NEAR WS-REC WS-HOME WS-OCC WS-SLEEPING WS-OTHER WS-ACTION
    MOVE "acceptance US15 44-3§2.2 a job site or bell memory has no bed rule" TO WS-CASE
    MOVE 0 TO WS-E
    MOVE WS-ACTION TO WS-O
    CALL "Q3-EQ" USING WS-CASE WS-E WS-O
    MOVE 3 TO WS-COUNT
    MOVE 5 TO WS-XS-T(1)
    MOVE 3 TO WS-XS-T(2)
    MOVE 9 TO WS-XS-T(3)
    CALL "Q3-COMPETE" USING WS-COUNT WS-XS WS-LOSER WS-WINNER
    MOVE "acceptance US15 44-3§2.3 the highest xp of three keeps the site (the third)" TO WS-CASE
    MOVE 3 TO WS-E
    MOVE WS-WINNER TO WS-O
    CALL "Q3-EQ" USING WS-CASE WS-E WS-O
    MOVE "acceptance US15 44-3§2.3 this villager loses" TO WS-CASE
    MOVE 1 TO WS-E
    MOVE WS-LOSER-T(1) TO WS-O
    CALL "Q3-EQ" USING WS-CASE WS-E WS-O
    MOVE "acceptance US15 44-3§2.3 the second competitor loses to this villager" TO WS-CASE
    MOVE 1 TO WS-E
    MOVE WS-LOSER-T(2) TO WS-O
    CALL "Q3-EQ" USING WS-CASE WS-E WS-O
    MOVE "acceptance US15 44-3§2.3 the winner is not erased" TO WS-CASE
    MOVE 0 TO WS-E
    MOVE WS-LOSER-T(3) TO WS-O
    CALL "Q3-EQ" USING WS-CASE WS-E WS-O
    MOVE 4 TO WS-XS-T(3)
    CALL "Q3-COMPETE" USING WS-COUNT WS-XS WS-LOSER WS-WINNER
    MOVE "acceptance US15 44-3§2.3 this villager keeps the site with the most xp" TO WS-CASE
    MOVE 1 TO WS-E
    MOVE WS-WINNER TO WS-O
    CALL "Q3-EQ" USING WS-CASE WS-E WS-O
    MOVE "acceptance US15 44-3§2.3 both competitors are erased" TO WS-CASE
    MOVE 1 TO WS-E
    MOVE WS-LOSER-T(2) TO WS-O
    CALL "Q3-EQ" USING WS-CASE WS-E WS-O
    MOVE "acceptance US15 44-3§2.3 the third is erased too" TO WS-CASE
    MOVE 1 TO WS-E
    MOVE WS-LOSER-T(3) TO WS-O
    CALL "Q3-EQ" USING WS-CASE WS-E WS-O
    MOVE 2 TO WS-COUNT
    MOVE 5 TO WS-XS-T(2)
    CALL "Q3-COMPETE" USING WS-COUNT WS-XS WS-LOSER WS-WINNER
    MOVE "acceptance US15 44-3§2.3 on equal xp the later villager wins" TO WS-CASE
    MOVE 2 TO WS-E
    MOVE WS-WINNER TO WS-O
    CALL "Q3-EQ" USING WS-CASE WS-E WS-O
    MOVE "acceptance US15 44-3§2.3 and this villager is erased" TO WS-CASE
    MOVE 1 TO WS-E
    MOVE WS-LOSER-T(1) TO WS-O
    CALL "Q3-EQ" USING WS-CASE WS-E WS-O
    MOVE 1 TO WS-COUNT
    CALL "Q3-COMPETE" USING WS-COUNT WS-XS WS-LOSER WS-WINNER
    MOVE "acceptance US15 44-3§2.3 alone it keeps the site" TO WS-CASE
    MOVE 1 TO WS-E
    MOVE WS-WINNER TO WS-O
    CALL "Q3-EQ" USING WS-CASE WS-E WS-O
    MOVE "acceptance US15 44-3§2.3 and nothing is erased" TO WS-CASE
    MOVE 0 TO WS-E
    MOVE WS-LOSER-T(1) TO WS-O
    CALL "Q3-EQ" USING WS-CASE WS-E WS-O
    MOVE 0 TO WS-POT
    MOVE 1 TO WS-ACC
    MOVE 0 TO WS-JOB
    MOVE 1 TO WS-REACH
    MOVE 0 TO WS-SAME
    CALL "Q3-YIELD-WANTS" USING WS-POT WS-ACC WS-JOB WS-REACH WS-SAME WS-YES
    MOVE "acceptance US15 44-3§2.4 a villager without job and potential site that can reach the site wants it" TO WS-CASE
    MOVE 1 TO WS-E
    MOVE WS-YES TO WS-O
    CALL "Q3-EQ" USING WS-CASE WS-E WS-O
    MOVE 1 TO WS-POT
    CALL "Q3-YIELD-WANTS" USING WS-POT WS-ACC WS-JOB WS-REACH WS-SAME WS-YES
    MOVE "acceptance US15 44-3§2.4 (a) the other has a potential site: no" TO WS-CASE
    MOVE 0 TO WS-E
    MOVE WS-YES TO WS-O
    CALL "Q3-EQ" USING WS-CASE WS-E WS-O
    MOVE 0 TO WS-POT
    MOVE 0 TO WS-ACC
    CALL "Q3-YIELD-WANTS" USING WS-POT WS-ACC WS-JOB WS-REACH WS-SAME WS-YES
    MOVE "acceptance US15 44-3§2.4 (b) its profession does not accept the type: no" TO WS-CASE
    MOVE 0 TO WS-E
    MOVE WS-YES TO WS-O
    CALL "Q3-EQ" USING WS-CASE WS-E WS-O
    MOVE 1 TO WS-ACC
    MOVE 0 TO WS-REACH
    CALL "Q3-YIELD-WANTS" USING WS-POT WS-ACC WS-JOB WS-REACH WS-SAME WS-YES
    MOVE "acceptance US15 44-3§2.4 (c) no job site and no path: no" TO WS-CASE
    MOVE 0 TO WS-E
    MOVE WS-YES TO WS-O
    CALL "Q3-EQ" USING WS-CASE WS-E WS-O
    MOVE 1 TO WS-JOB
    MOVE 1 TO WS-SAME
    CALL "Q3-YIELD-WANTS" USING WS-POT WS-ACC WS-JOB WS-REACH WS-SAME WS-YES
    MOVE "acceptance US15 44-3§2.4 (c) its job_site is this very position: yes" TO WS-CASE
    MOVE 1 TO WS-E
    MOVE WS-YES TO WS-O
    CALL "Q3-EQ" USING WS-CASE WS-E WS-O
    MOVE 0 TO WS-SAME
    CALL "Q3-YIELD-WANTS" USING WS-POT WS-ACC WS-JOB WS-REACH WS-SAME WS-YES
    MOVE "acceptance US15 44-3§2.4 (c) a job site elsewhere: no" TO WS-CASE
    MOVE 0 TO WS-E
    MOVE WS-YES TO WS-O
    CALL "Q3-EQ" USING WS-CASE WS-E WS-O
    MOVE 0 TO WS-BABY
    MOVE 1 TO WS-NONE
    MOVE 1 TO WS-FOUND
    CALL "Q3-YIELD-START" USING WS-BABY WS-NONE WS-FOUND WS-YES
    MOVE "acceptance US15 44-3§2.4 step 1 and 2: an adult without profession at a known POI runs" TO WS-CASE
    MOVE 1 TO WS-E
    MOVE WS-YES TO WS-O
    CALL "Q3-EQ" USING WS-CASE WS-E WS-O
    MOVE 1 TO WS-BABY
    CALL "Q3-YIELD-START" USING WS-BABY WS-NONE WS-FOUND WS-YES
    MOVE "acceptance US15 44-3§2.4 step 1: a baby does nothing" TO WS-CASE
    MOVE 0 TO WS-E
    MOVE WS-YES TO WS-O
    CALL "Q3-EQ" USING WS-CASE WS-E WS-O
    MOVE 0 TO WS-BABY
    MOVE 0 TO WS-NONE
    CALL "Q3-YIELD-START" USING WS-BABY WS-NONE WS-FOUND WS-YES
    MOVE "acceptance US15 44-3§2.4 step 1: a villager with a profession does nothing" TO WS-CASE
    MOVE 0 TO WS-E
    MOVE WS-YES TO WS-O
    CALL "Q3-EQ" USING WS-CASE WS-E WS-O
    MOVE 1 TO WS-NONE
    MOVE 0 TO WS-FOUND
    CALL "Q3-YIELD-START" USING WS-BABY WS-NONE WS-FOUND WS-YES
    MOVE "acceptance US15 44-3§2.4 step 2: no POI type at the site ends with no effect" TO WS-CASE
    MOVE 0 TO WS-E
    MOVE WS-YES TO WS-O
    CALL "Q3-EQ" USING WS-CASE WS-E WS-O
    MOVE 0 TO WS-ACT
    CALL "Q3-POT-START" USING WS-ACT WS-YES
    MOVE "acceptance US15 44-3§2.5 GoToPotentialJobSite starts in IDLE" TO WS-CASE
    MOVE 1 TO WS-E
    MOVE WS-YES TO WS-O
    CALL "Q3-EQ" USING WS-CASE WS-E WS-O
    MOVE 1 TO WS-ACT
    CALL "Q3-POT-START" USING WS-ACT WS-YES
    MOVE "acceptance US15 44-3§2.5 in WORK" TO WS-CASE
    MOVE 1 TO WS-E
    MOVE WS-YES TO WS-O
    CALL "Q3-EQ" USING WS-CASE WS-E WS-O
    MOVE 4 TO WS-ACT
    CALL "Q3-POT-START" USING WS-ACT WS-YES
    MOVE "acceptance US15 44-3§2.5 in PLAY" TO WS-CASE
    MOVE 1 TO WS-E
    MOVE WS-YES TO WS-O
    CALL "Q3-EQ" USING WS-CASE WS-E WS-O
    MOVE 2 TO WS-ACT
    CALL "Q3-POT-START" USING WS-ACT WS-YES
    MOVE "acceptance US15 44-3§2.5 not in MEET" TO WS-CASE
    MOVE 0 TO WS-E
    MOVE WS-YES TO WS-O
    CALL "Q3-EQ" USING WS-CASE WS-E WS-O
    MOVE 3 TO WS-ACT
    CALL "Q3-POT-START" USING WS-ACT WS-YES
    MOVE "acceptance US15 44-3§2.5 not in REST" TO WS-CASE
    MOVE 0 TO WS-E
    MOVE WS-YES TO WS-O
    CALL "Q3-EQ" USING WS-CASE WS-E WS-O
    MOVE 1 TO WS-ACCEPTABLE
    CALL "Q3-POT-STOP" USING WS-ACCEPTABLE WS-RELEASE
    MOVE "acceptance US15 44-3§2.5 on stop a record of an acquirable type gets the ticket released" TO WS-CASE
    MOVE 1 TO WS-E
    MOVE WS-RELEASE TO WS-O
    CALL "Q3-EQ" USING WS-CASE WS-E WS-O
    MOVE 0 TO WS-ACCEPTABLE
    CALL "Q3-POT-STOP" USING WS-ACCEPTABLE WS-RELEASE
    MOVE "acceptance US15 44-3§2.5 with no such record nothing is released" TO WS-CASE
    MOVE 0 TO WS-E
    MOVE WS-RELEASE TO WS-O
    CALL "Q3-EQ" USING WS-CASE WS-E WS-O
     STOP RUN.
 END PROGRAM TEST-Q44-44-3-2.
 COPY Q3TEST.
