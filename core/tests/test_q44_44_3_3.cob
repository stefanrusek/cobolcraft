*> Test of 44 part 3 sections 2.7 to 2.10: work, strolls, bed and hiding behaviours as decision units (lane 002-lane-p49h, T22003).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-Q44-44-3-3.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-CASE                PIC X(240).
 01 WS-E                   BINARY-LONG.
 01 WS-O                   BINARY-LONG.
 01 WS-KIND.
    05 WS-KIND-T            BINARY-LONG OCCURS 8 TIMES.
 01 WS-CNT.
    05 WS-CNT-T            BINARY-LONG OCCURS 8 TIMES.
 01 WS-TAKE.
    05 WS-TAKE-T            BINARY-LONG OCCURS 8 TIMES.
 01 WS-DL.
    05 WS-DL-T            BINARY-LONG OCCURS 5 TIMES.
 01 WS-NOW                  BINARY-LONG.
 01 WS-LAST                 BINARY-LONG.
 01 WS-DRAW                 BINARY-LONG.
 01 WS-SAMEDIM              BINARY-LONG.
 01 WS-D2                   FLOAT-LONG.
 01 WS-YES                  BINARY-LONG.
 01 WS-JOB                  BINARY-LONG.
 01 WS-BREAD                BINARY-LONG.
 01 WS-WHEAT                BINARY-LONG.
 01 WS-ROOM                 BINARY-LONG.
 01 WS-LOAVES               BINARY-LONG.
 01 WS-DROPPED              BINARY-LONG.
 01 WS-N                    BINARY-LONG.
 01 WS-TOTAL                BINARY-LONG.
 01 WS-NEAR                 BINARY-LONG.
 01 WS-COOL                 BINARY-LONG.
 01 WS-WALK                 BINARY-LONG.
 01 WS-MAINNEAR             BINARY-LONG.
 01 WS-SIZE                 BINARY-LONG.
 01 WS-ENTRYNEAR            BINARY-LONG.
 01 WS-PICK                 BINARY-LONG.
 01 WS-LASTRUN              BINARY-LONG.
 01 WS-FOUND                BINARY-LONG.
 01 WS-DIST                 BINARY-LONG.
 01 WS-MODE                 BINARY-LONG.
 01 WS-INMAP                BINARY-LONG.
 01 WS-COUNTER              BINARY-LONG.
 01 WS-ACCEPT               BINARY-LONG.
 01 WS-EXPIRY               BINARY-LONG.
 01 WS-PATH                 BINARY-LONG.
 01 WS-REACH                BINARY-LONG.
 01 WS-TYPEAT               BINARY-LONG.
 01 WS-PURGE                BINARY-LONG.
 01 WS-ISVILLAGE            BINARY-LONG.
 01 WS-D0                   BINARY-LONG.
 01 WS-VKIND                BINARY-LONG.
 01 WS-REST                 BINARY-LONG.
 01 WS-SLEEPING             BINARY-LONG.
 01 WS-STOP                 BINARY-LONG.
 01 WS-BABY                 BINARY-LONG.
 01 WS-ONBED                BINARY-LONG.
 01 WS-HASBED               BINARY-LONG.
 01 WS-BUDGET               BINARY-LONG.
 01 WS-JUMPS                BINARY-LONG.
 01 WS-SURFACE              BINARY-LONG.
 01 WS-JUMP                 BINARY-LONG.
 01 WS-BEDOK                BINARY-LONG.
 01 WS-FFOUND               BINARY-LONG.
 01 WS-FWITHIN              BINARY-LONG.
 01 WS-RFOUND               BINARY-LONG.
 01 WS-STORED               BINARY-LONG.
 01 WS-SOURCE               BINARY-LONG.
 01 WS-CLOSE                BINARY-LONG.
 PROCEDURE DIVISION.
    MOVE 1000 TO WS-NOW
    MOVE 0 TO WS-LAST
    MOVE 0 TO WS-DRAW
    MOVE 1 TO WS-SAMEDIM
    COMPUTE WS-D2 = 1.0
    CALL "Q3-WORK-START" USING WS-NOW WS-LAST WS-DRAW WS-SAMEDIM WS-D2 WS-YES
    MOVE "acceptance US15 44-3§2.7 WorkAtPoi starts within 1.73 blocks when the 1-in-2 gate passes" TO WS-CASE
    MOVE 1 TO WS-E
    MOVE WS-YES TO WS-O
    CALL "Q3-EQ" USING WS-CASE WS-E WS-O
    MOVE "acceptance US15 44-3§2.7 lastCheck is set when the gate passes" TO WS-CASE
    MOVE 1000 TO WS-E
    MOVE WS-LAST TO WS-O
    CALL "Q3-EQ" USING WS-CASE WS-E WS-O
    MOVE 1100 TO WS-NOW
    MOVE 0 TO WS-DRAW
    CALL "Q3-WORK-START" USING WS-NOW WS-LAST WS-DRAW WS-SAMEDIM WS-D2 WS-YES
    MOVE "acceptance US15 44-3§2.7 less than 300 ticks since lastCheck blocks the start" TO WS-CASE
    MOVE 0 TO WS-E
    MOVE WS-YES TO WS-O
    CALL "Q3-EQ" USING WS-CASE WS-E WS-O
    MOVE "acceptance US15 44-3§2.7 and lastCheck is kept" TO WS-CASE
    MOVE 1000 TO WS-E
    MOVE WS-LAST TO WS-O
    CALL "Q3-EQ" USING WS-CASE WS-E WS-O
    MOVE 1300 TO WS-NOW
    MOVE 1 TO WS-DRAW
    CALL "Q3-WORK-START" USING WS-NOW WS-LAST WS-DRAW WS-SAMEDIM WS-D2 WS-YES
    MOVE "acceptance US15 44-3§2.7 the 1-in-2 gate failing blocks the start" TO WS-CASE
    MOVE 0 TO WS-E
    MOVE WS-YES TO WS-O
    CALL "Q3-EQ" USING WS-CASE WS-E WS-O
    MOVE "acceptance US15 44-3§2.7 and lastCheck stays (set only when the gate passes)" TO WS-CASE
    MOVE 1000 TO WS-E
    MOVE WS-LAST TO WS-O
    CALL "Q3-EQ" USING WS-CASE WS-E WS-O
    MOVE 0 TO WS-DRAW
    MOVE 0 TO WS-SAMEDIM
    CALL "Q3-WORK-START" USING WS-NOW WS-LAST WS-DRAW WS-SAMEDIM WS-D2 WS-YES
    MOVE "acceptance US15 44-3§2.7 a job site in another dimension blocks the start" TO WS-CASE
    MOVE 0 TO WS-E
    MOVE WS-YES TO WS-O
    CALL "Q3-EQ" USING WS-CASE WS-E WS-O
    MOVE 1 TO WS-SAMEDIM
    MOVE 0 TO WS-LAST
    COMPUTE WS-D2 = 3.0
    CALL "Q3-WORK-START" USING WS-NOW WS-LAST WS-DRAW WS-SAMEDIM WS-D2 WS-YES
    MOVE "acceptance US15 44-3§2.7 beyond 1.73 blocks (3.0 squared) blocks the start" TO WS-CASE
    MOVE 0 TO WS-E
    MOVE WS-YES TO WS-O
    CALL "Q3-EQ" USING WS-CASE WS-E WS-O
    MOVE 0 TO WS-LAST
    COMPUTE WS-D2 = 2.9
    CALL "Q3-WORK-START" USING WS-NOW WS-LAST WS-DRAW WS-SAMEDIM WS-D2 WS-YES
    MOVE "acceptance US15 44-3§2.7 2.9 squared is below 1.73 squared (2.9929)" TO WS-CASE
    MOVE 1 TO WS-E
    MOVE WS-YES TO WS-O
    CALL "Q3-EQ" USING WS-CASE WS-E WS-O
    MOVE 1 TO WS-SAMEDIM
    MOVE 1 TO WS-JOB
    COMPUTE WS-D2 = 2.9
    CALL "Q3-WORK-CONTINUE" USING WS-SAMEDIM WS-D2 WS-JOB WS-YES
    MOVE "acceptance US15 44-3§2.7 WorkAtPoi continues while the job site is present and near" TO WS-CASE
    MOVE 1 TO WS-E
    MOVE WS-YES TO WS-O
    CALL "Q3-EQ" USING WS-CASE WS-E WS-O
    MOVE 0 TO WS-JOB
    CALL "Q3-WORK-CONTINUE" USING WS-SAMEDIM WS-D2 WS-JOB WS-YES
    MOVE "acceptance US15 44-3§2.7 it stops when job_site is gone" TO WS-CASE
    MOVE 0 TO WS-E
    MOVE WS-YES TO WS-O
    CALL "Q3-EQ" USING WS-CASE WS-E WS-O
    MOVE 1 TO WS-JOB
    MOVE 0 TO WS-SAMEDIM
    CALL "Q3-WORK-CONTINUE" USING WS-SAMEDIM WS-D2 WS-JOB WS-YES
    MOVE "acceptance US15 44-3§2.7 it stops in another dimension" TO WS-CASE
    MOVE 0 TO WS-E
    MOVE WS-YES TO WS-O
    CALL "Q3-EQ" USING WS-CASE WS-E WS-O
    MOVE 1 TO WS-SAMEDIM
    COMPUTE WS-D2 = 3.1
    CALL "Q3-WORK-CONTINUE" USING WS-SAMEDIM WS-D2 WS-JOB WS-YES
    MOVE "acceptance US15 44-3§2.7 it stops beyond 1.73 blocks" TO WS-CASE
    MOVE 0 TO WS-E
    MOVE WS-YES TO WS-O
    CALL "Q3-EQ" USING WS-CASE WS-E WS-O
    MOVE 40 TO WS-BREAD
    MOVE 9 TO WS-WHEAT
    MOVE 64 TO WS-ROOM
    CALL "Q3-MAKE-BREAD" USING WS-BREAD WS-WHEAT WS-ROOM WS-LOAVES WS-DROPPED
    MOVE "acceptance US15 44-3§2.7 makeBread: more than 36 bread already: nothing" TO WS-CASE
    MOVE 0 TO WS-E
    MOVE WS-LOAVES TO WS-O
    CALL "Q3-EQ" USING WS-CASE WS-E WS-O
    MOVE "acceptance US15 44-3§2.7 makeBread: the wheat is kept" TO WS-CASE
    MOVE 9 TO WS-E
    MOVE WS-WHEAT TO WS-O
    CALL "Q3-EQ" USING WS-CASE WS-E WS-O
    MOVE 36 TO WS-BREAD
    MOVE 2 TO WS-WHEAT
    CALL "Q3-MAKE-BREAD" USING WS-BREAD WS-WHEAT WS-ROOM WS-LOAVES WS-DROPPED
    MOVE "acceptance US15 44-3§2.7 makeBread: 2 wheat make no bread" TO WS-CASE
    MOVE 0 TO WS-E
    MOVE WS-LOAVES TO WS-O
    CALL "Q3-EQ" USING WS-CASE WS-E WS-O
    MOVE 11 TO WS-WHEAT
    CALL "Q3-MAKE-BREAD" USING WS-BREAD WS-WHEAT WS-ROOM WS-LOAVES WS-DROPPED
    MOVE "acceptance US15 44-3§2.7 makeBread: at most 3 loaves per cycle (11 / 3 = 3, bread 36 is not more than 36)" TO WS-CASE
    MOVE 3 TO WS-E
    MOVE WS-LOAVES TO WS-O
    CALL "Q3-EQ" USING WS-CASE WS-E WS-O
    MOVE "acceptance US15 44-3§2.7 makeBread: 9 wheat are used" TO WS-CASE
    MOVE 2 TO WS-E
    MOVE WS-WHEAT TO WS-O
    CALL "Q3-EQ" USING WS-CASE WS-E WS-O
    MOVE "acceptance US15 44-3§2.7 makeBread: all fit" TO WS-CASE
    MOVE 0 TO WS-E
    MOVE WS-DROPPED TO WS-O
    CALL "Q3-EQ" USING WS-CASE WS-E WS-O
    MOVE 7 TO WS-WHEAT
    MOVE 1 TO WS-ROOM
    CALL "Q3-MAKE-BREAD" USING WS-BREAD WS-WHEAT WS-ROOM WS-LOAVES WS-DROPPED
    MOVE "acceptance US15 44-3§2.7 makeBread: 7 wheat make 2 loaves" TO WS-CASE
    MOVE 2 TO WS-E
    MOVE WS-LOAVES TO WS-O
    CALL "Q3-EQ" USING WS-CASE WS-E WS-O
    MOVE "acceptance US15 44-3§2.7 makeBread: bread that does not fit is dropped (2 loaves, room for 1)" TO WS-CASE
    MOVE 1 TO WS-E
    MOVE WS-DROPPED TO WS-O
    CALL "Q3-EQ" USING WS-CASE WS-E WS-O
    MOVE 4 TO WS-N
    MOVE 1 TO WS-KIND-T(1)
    MOVE 15 TO WS-CNT-T(1)
    MOVE 0 TO WS-KIND-T(2)
    MOVE 30 TO WS-CNT-T(2)
    MOVE 2 TO WS-KIND-T(3)
    MOVE 12 TO WS-CNT-T(3)
    MOVE 1 TO WS-KIND-T(4)
    MOVE 14 TO WS-CNT-T(4)
    CALL "Q3-COMPOST-SCAN" USING WS-N WS-KIND WS-CNT WS-TAKE WS-TOTAL
    MOVE "acceptance US15 44-3§2.7 compostItems scans from the last slot: wheat seeds 14, running total 14, 4 composted (keep 10)" TO WS-CASE
    MOVE 4 TO WS-E
    MOVE WS-TAKE-T(4) TO WS-O
    CALL "Q3-EQ" USING WS-CASE WS-E WS-O
    MOVE "acceptance US15 44-3§2.7 compostItems: beetroot seeds 12 keep 10 so 2 are composted" TO WS-CASE
    MOVE 2 TO WS-E
    MOVE WS-TAKE-T(3) TO WS-O
    CALL "Q3-EQ" USING WS-CASE WS-E WS-O
    MOVE "acceptance US15 44-3§2.7 compostItems: other items are never composted" TO WS-CASE
    MOVE 0 TO WS-E
    MOVE WS-TAKE-T(2) TO WS-O
    CALL "Q3-EQ" USING WS-CASE WS-E WS-O
    MOVE "acceptance US15 44-3§2.7 compostItems: the first wheat seed slot sees the total 29, min(19, budget 14, 15) = 14" TO WS-CASE
    MOVE 14 TO WS-E
    MOVE WS-TAKE-T(1) TO WS-O
    CALL "Q3-EQ" USING WS-CASE WS-E WS-O
    MOVE "acceptance US15 44-3§2.7 compostItems: the budget of 20 per cycle is used up" TO WS-CASE
    MOVE 20 TO WS-E
    MOVE WS-TOTAL TO WS-O
    CALL "Q3-EQ" USING WS-CASE WS-E WS-O
    MOVE 2 TO WS-N
    MOVE 1 TO WS-KIND-T(1)
    MOVE 8 TO WS-CNT-T(1)
    MOVE 1 TO WS-KIND-T(2)
    MOVE 1 TO WS-CNT-T(2)
    CALL "Q3-COMPOST-SCAN" USING WS-N WS-KIND WS-CNT WS-TAKE WS-TOTAL
    MOVE "acceptance US15 44-3§2.7 compostItems: a total of 9 seeds composts nothing" TO WS-CASE
    MOVE 0 TO WS-E
    MOVE WS-TOTAL TO WS-O
    CALL "Q3-EQ" USING WS-CASE WS-E WS-O
    MOVE "acceptance US15 44-3§2.7 compostItems: the last slot takes nothing" TO WS-CASE
    MOVE 0 TO WS-E
    MOVE WS-TAKE-T(2) TO WS-O
    CALL "Q3-EQ" USING WS-CASE WS-E WS-O
    MOVE 1 TO WS-SAMEDIM
    MOVE 0 TO WS-NEAR
    MOVE 0 TO WS-COOL
    CALL "Q3-STROLL-POI" USING WS-SAMEDIM WS-NEAR WS-COOL WS-WALK
    MOVE "acceptance US15 44-3§2.8 StrollToPoi far from the POI with the cooldown elapsed sets the walk target" TO WS-CASE
    MOVE 1 TO WS-E
    MOVE WS-WALK TO WS-O
    CALL "Q3-EQ" USING WS-CASE WS-E WS-O
    MOVE "acceptance US15 44-3§2.8 and arms the 80-tick cooldown" TO WS-CASE
    MOVE 80 TO WS-E
    MOVE WS-COOL TO WS-O
    CALL "Q3-EQ" USING WS-CASE WS-E WS-O
    CALL "Q3-STROLL-POI" USING WS-SAMEDIM WS-NEAR WS-COOL WS-WALK
    MOVE "acceptance US15 44-3§2.8 with the cooldown running nothing is set" TO WS-CASE
    MOVE 0 TO WS-E
    MOVE WS-WALK TO WS-O
    CALL "Q3-EQ" USING WS-CASE WS-E WS-O
    MOVE 0 TO WS-COOL
    MOVE 1 TO WS-NEAR
    CALL "Q3-STROLL-POI" USING WS-SAMEDIM WS-NEAR WS-COOL WS-WALK
    MOVE "acceptance US15 44-3§2.8 already within the distance: no walk" TO WS-CASE
    MOVE 0 TO WS-E
    MOVE WS-WALK TO WS-O
    CALL "Q3-EQ" USING WS-CASE WS-E WS-O
    MOVE 0 TO WS-NEAR
    MOVE 0 TO WS-SAMEDIM
    CALL "Q3-STROLL-POI" USING WS-SAMEDIM WS-NEAR WS-COOL WS-WALK
    MOVE "acceptance US15 44-3§2.8 a POI in another dimension: no walk" TO WS-CASE
    MOVE 0 TO WS-E
    MOVE WS-WALK TO WS-O
    CALL "Q3-EQ" USING WS-CASE WS-E WS-O
    MOVE 1 TO WS-SAMEDIM
    MOVE 1 TO WS-MAINNEAR
    MOVE 4 TO WS-SIZE
    MOVE 2 TO WS-DRAW
    MOVE 0 TO WS-ENTRYNEAR
    MOVE 0 TO WS-COOL
    CALL "Q3-STROLL-LIST" USING WS-MAINNEAR WS-SIZE WS-DRAW WS-SAMEDIM WS-ENTRYNEAR WS-COOL WS-WALK WS-PICK
    MOVE "acceptance US15 44-3§2.8 StrollToPoiList picks a random entry (nextInt(4) = 2, zero based: entry 3)" TO WS-CASE
    MOVE 3 TO WS-E
    MOVE WS-PICK TO WS-O
    CALL "Q3-EQ" USING WS-CASE WS-E WS-O
    MOVE "acceptance US15 44-3§2.8 and walks to it" TO WS-CASE
    MOVE 1 TO WS-E
    MOVE WS-WALK TO WS-O
    CALL "Q3-EQ" USING WS-CASE WS-E WS-O
    MOVE "acceptance US15 44-3§2.8 and arms the 100-tick cooldown" TO WS-CASE
    MOVE 100 TO WS-E
    MOVE WS-COOL TO WS-O
    CALL "Q3-EQ" USING WS-CASE WS-E WS-O
    CALL "Q3-STROLL-LIST" USING WS-MAINNEAR WS-SIZE WS-DRAW WS-SAMEDIM WS-ENTRYNEAR WS-COOL WS-WALK WS-PICK
    MOVE "acceptance US15 44-3§2.8 StrollToPoiList with the cooldown running does not walk" TO WS-CASE
    MOVE 0 TO WS-E
    MOVE WS-WALK TO WS-O
    CALL "Q3-EQ" USING WS-CASE WS-E WS-O
    MOVE 0 TO WS-COOL
    MOVE 0 TO WS-MAINNEAR
    CALL "Q3-STROLL-LIST" USING WS-MAINNEAR WS-SIZE WS-DRAW WS-SAMEDIM WS-ENTRYNEAR WS-COOL WS-WALK WS-PICK
    MOVE "acceptance US15 44-3§2.8 StrollToPoiList far from the main POI draws nothing and does not walk" TO WS-CASE
    MOVE 0 TO WS-E
    MOVE WS-PICK TO WS-O
    CALL "Q3-EQ" USING WS-CASE WS-E WS-O
    MOVE 1 TO WS-MAINNEAR
    MOVE 1 TO WS-ENTRYNEAR
    CALL "Q3-STROLL-LIST" USING WS-MAINNEAR WS-SIZE WS-DRAW WS-SAMEDIM WS-ENTRYNEAR WS-COOL WS-WALK WS-PICK
    MOVE "acceptance US15 44-3§2.8 StrollToPoiList already near the entry: no walk" TO WS-CASE
    MOVE 0 TO WS-E
    MOVE WS-WALK TO WS-O
    CALL "Q3-EQ" USING WS-CASE WS-E WS-O
    MOVE 0 TO WS-ENTRYNEAR
    MOVE 0 TO WS-SAMEDIM
    CALL "Q3-STROLL-LIST" USING WS-MAINNEAR WS-SIZE WS-DRAW WS-SAMEDIM WS-ENTRYNEAR WS-COOL WS-WALK WS-PICK
    MOVE "acceptance US15 44-3§2.8 StrollToPoiList entry in another dimension: no walk" TO WS-CASE
    MOVE 0 TO WS-E
    MOVE WS-WALK TO WS-O
    CALL "Q3-EQ" USING WS-CASE WS-E WS-O
    MOVE 100 TO WS-NOW
    MOVE 90 TO WS-LASTRUN
    MOVE 1 TO WS-FOUND
    MOVE 25 TO WS-DIST
    MOVE 7 TO WS-DRAW
    CALL "Q3-HOME-GATE" USING WS-NOW WS-LASTRUN WS-FOUND WS-DIST WS-DRAW WS-MODE
    MOVE "acceptance US15 44-3§2.8 SetClosestHome: less than 20 ticks since lastRun does nothing" TO WS-CASE
    MOVE 0 TO WS-E
    MOVE WS-MODE TO WS-O
    CALL "Q3-EQ" USING WS-CASE WS-E WS-O
    MOVE 110 TO WS-NOW
    CALL "Q3-HOME-GATE" USING WS-NOW WS-LASTRUN WS-FOUND WS-DIST WS-DRAW WS-MODE
    MOVE "acceptance US15 44-3§2.8 SetClosestHome: 20 ticks since lastRun continues" TO WS-CASE
    MOVE 1 TO WS-E
    MOVE WS-MODE TO WS-O
    CALL "Q3-EQ" USING WS-CASE WS-E WS-O
    MOVE "acceptance US15 44-3§2.8 SetClosestHome: lastRun = gameTime + nextInt(20)" TO WS-CASE
    MOVE 117 TO WS-E
    MOVE WS-LASTRUN TO WS-O
    CALL "Q3-EQ" USING WS-CASE WS-E WS-O
    MOVE 0 TO WS-LASTRUN
    MOVE 0 TO WS-FOUND
    CALL "Q3-HOME-GATE" USING WS-NOW WS-LASTRUN WS-FOUND WS-DIST WS-DRAW WS-MODE
    MOVE "acceptance US15 44-3§2.8 SetClosestHome: no home POI within 48: nothing" TO WS-CASE
    MOVE 0 TO WS-E
    MOVE WS-MODE TO WS-O
    CALL "Q3-EQ" USING WS-CASE WS-E WS-O
    MOVE "acceptance US15 44-3§2.8 SetClosestHome: lastRun not changed by that exit" TO WS-CASE
    MOVE 0 TO WS-E
    MOVE WS-LASTRUN TO WS-O
    CALL "Q3-EQ" USING WS-CASE WS-E WS-O
    MOVE 1 TO WS-FOUND
    MOVE 4 TO WS-DIST
    CALL "Q3-HOME-GATE" USING WS-NOW WS-LASTRUN WS-FOUND WS-DIST WS-DRAW WS-MODE
    MOVE "acceptance US15 44-3§2.8 SetClosestHome: the home is within squared distance 4: nothing" TO WS-CASE
    MOVE 0 TO WS-E
    MOVE WS-MODE TO WS-O
    CALL "Q3-EQ" USING WS-CASE WS-E WS-O
    MOVE 1 TO WS-INMAP
    MOVE 0 TO WS-COUNTER
    MOVE 117 TO WS-LASTRUN
    CALL "Q3-BATCH-FILTER" USING WS-INMAP WS-COUNTER WS-LASTRUN WS-ACCEPT WS-EXPIRY
    MOVE "acceptance US15 44-3§2.8 batch filter: a position already in the map is rejected" TO WS-CASE
    MOVE 0 TO WS-E
    MOVE WS-ACCEPT TO WS-O
    CALL "Q3-EQ" USING WS-CASE WS-E WS-O
    MOVE "acceptance US15 44-3§2.8 batch filter: and does not count" TO WS-CASE
    MOVE 0 TO WS-E
    MOVE WS-COUNTER TO WS-O
    CALL "Q3-EQ" USING WS-CASE WS-E WS-O
    MOVE 0 TO WS-INMAP
    CALL "Q3-BATCH-FILTER" USING WS-INMAP WS-COUNTER WS-LASTRUN WS-ACCEPT WS-EXPIRY
    MOVE "acceptance US15 44-3§2.8 batch filter: a new position is accepted" TO WS-CASE
    MOVE 1 TO WS-E
    MOVE WS-ACCEPT TO WS-O
    CALL "Q3-EQ" USING WS-CASE WS-E WS-O
    MOVE "acceptance US15 44-3§2.8 batch filter: it expires at lastRun + 40" TO WS-CASE
    MOVE 157 TO WS-E
    MOVE WS-EXPIRY TO WS-O
    CALL "Q3-EQ" USING WS-CASE WS-E WS-O
    MOVE "acceptance US15 44-3§2.8 batch filter: the counter counts it" TO WS-CASE
    MOVE 1 TO WS-E
    MOVE WS-COUNTER TO WS-O
    CALL "Q3-EQ" USING WS-CASE WS-E WS-O
    MOVE 3 TO WS-COUNTER
    CALL "Q3-BATCH-FILTER" USING WS-INMAP WS-COUNTER WS-LASTRUN WS-ACCEPT WS-EXPIRY
    MOVE "acceptance US15 44-3§2.8 batch filter: the 4th new position is still accepted" TO WS-CASE
    MOVE 1 TO WS-E
    MOVE WS-ACCEPT TO WS-O
    CALL "Q3-EQ" USING WS-CASE WS-E WS-O
    CALL "Q3-BATCH-FILTER" USING WS-INMAP WS-COUNTER WS-LASTRUN WS-ACCEPT WS-EXPIRY
    MOVE "acceptance US15 44-3§2.8 batch filter: the 5th (counter 5) is rejected, so at most 4 per run" TO WS-CASE
    MOVE 0 TO WS-E
    MOVE WS-ACCEPT TO WS-O
    CALL "Q3-EQ" USING WS-CASE WS-E WS-O
    MOVE 1 TO WS-PATH
    MOVE 1 TO WS-REACH
    MOVE 1 TO WS-TYPEAT
    MOVE 2 TO WS-COUNTER
    CALL "Q3-HOME-RESULT" USING WS-PATH WS-REACH WS-TYPEAT WS-COUNTER WS-WALK WS-PURGE
    MOVE "acceptance US15 44-3§2.8 SetClosestHome: a path with a POI type at its target sets the walk target" TO WS-CASE
    MOVE 1 TO WS-E
    MOVE WS-WALK TO WS-O
    CALL "Q3-EQ" USING WS-CASE WS-E WS-O
    MOVE "acceptance US15 44-3§2.8 SetClosestHome: no purge" TO WS-CASE
    MOVE 0 TO WS-E
    MOVE WS-PURGE TO WS-O
    CALL "Q3-EQ" USING WS-CASE WS-E WS-O
    MOVE 0 TO WS-TYPEAT
    CALL "Q3-HOME-RESULT" USING WS-PATH WS-REACH WS-TYPEAT WS-COUNTER WS-WALK WS-PURGE
    MOVE "acceptance US15 44-3§2.8 SetClosestHome: no POI type at the target: no walk" TO WS-CASE
    MOVE 0 TO WS-E
    MOVE WS-WALK TO WS-O
    CALL "Q3-EQ" USING WS-CASE WS-E WS-O
    MOVE 0 TO WS-PATH
    CALL "Q3-HOME-RESULT" USING WS-PATH WS-REACH WS-TYPEAT WS-COUNTER WS-WALK WS-PURGE
    MOVE "acceptance US15 44-3§2.8 SetClosestHome: no usable path and fewer than 5 examined purges expired entries" TO WS-CASE
    MOVE 1 TO WS-E
    MOVE WS-PURGE TO WS-O
    CALL "Q3-EQ" USING WS-CASE WS-E WS-O
    MOVE 5 TO WS-COUNTER
    CALL "Q3-HOME-RESULT" USING WS-PATH WS-REACH WS-TYPEAT WS-COUNTER WS-WALK WS-PURGE
    MOVE "acceptance US15 44-3§2.8 SetClosestHome: no usable path with 5 examined does not purge" TO WS-CASE
    MOVE 0 TO WS-E
    MOVE WS-PURGE TO WS-O
    CALL "Q3-EQ" USING WS-CASE WS-E WS-O
    MOVE 1 TO WS-PATH
    MOVE 0 TO WS-REACH
    MOVE 1 TO WS-COUNTER
    CALL "Q3-HOME-RESULT" USING WS-PATH WS-REACH WS-TYPEAT WS-COUNTER WS-WALK WS-PURGE
    MOVE "acceptance US15 44-3§2.8 SetClosestHome: a path that cannot reach is no usable path (purge)" TO WS-CASE
    MOVE 1 TO WS-E
    MOVE WS-PURGE TO WS-O
    CALL "Q3-EQ" USING WS-CASE WS-E WS-O
    MOVE 1 TO WS-ISVILLAGE
    CALL "Q3-VILLAGE-START" USING WS-ISVILLAGE WS-YES
    MOVE "acceptance US15 44-3§2.8 GoToClosestVillage does nothing inside a village" TO WS-CASE
    MOVE 0 TO WS-E
    MOVE WS-YES TO WS-O
    CALL "Q3-EQ" USING WS-CASE WS-E WS-O
    MOVE 0 TO WS-ISVILLAGE
    CALL "Q3-VILLAGE-START" USING WS-ISVILLAGE WS-YES
    MOVE "acceptance US15 44-3§2.8 GoToClosestVillage runs outside a village" TO WS-CASE
    MOVE 1 TO WS-E
    MOVE WS-YES TO WS-O
    CALL "Q3-EQ" USING WS-CASE WS-E WS-O
    MOVE 4 TO WS-D0
    MOVE 5 TO WS-DL-T(1)
    MOVE 4 TO WS-DL-T(2)
    MOVE 3 TO WS-DL-T(3)
    MOVE 1 TO WS-DL-T(4)
    MOVE 1 TO WS-DL-T(5)
    MOVE 5 TO WS-N
    CALL "Q3-VILLAGE-PICK" USING WS-D0 WS-N WS-DL WS-PICK WS-VKIND
    MOVE "acceptance US15 44-3§2.8 the first sample with a smaller distance is accepted and stops the attempts (third)" TO WS-CASE
    MOVE 3 TO WS-E
    MOVE WS-PICK TO WS-O
    CALL "Q3-EQ" USING WS-CASE WS-E WS-O
    MOVE "acceptance US15 44-3§2.8 an accepted sample" TO WS-CASE
    MOVE 1 TO WS-E
    MOVE WS-VKIND TO WS-O
    CALL "Q3-EQ" USING WS-CASE WS-E WS-O
    MOVE 5 TO WS-DL-T(1)
    MOVE 4 TO WS-DL-T(2)
    MOVE 4 TO WS-DL-T(3)
    MOVE 6 TO WS-DL-T(4)
    MOVE 7 TO WS-DL-T(5)
    CALL "Q3-VILLAGE-PICK" USING WS-D0 WS-N WS-DL WS-PICK WS-VKIND
    MOVE "acceptance US15 44-3§2.8 with no smaller sample the last equal one is the fallback (third)" TO WS-CASE
    MOVE 3 TO WS-E
    MOVE WS-PICK TO WS-O
    CALL "Q3-EQ" USING WS-CASE WS-E WS-O
    MOVE "acceptance US15 44-3§2.8 a fallback sample" TO WS-CASE
    MOVE 2 TO WS-E
    MOVE WS-VKIND TO WS-O
    CALL "Q3-EQ" USING WS-CASE WS-E WS-O
    MOVE 9 TO WS-DL-T(2)
    MOVE 9 TO WS-DL-T(3)
    CALL "Q3-VILLAGE-PICK" USING WS-D0 WS-N WS-DL WS-PICK WS-VKIND
    MOVE "acceptance US15 44-3§2.8 no sample as close as the villager: no target" TO WS-CASE
    MOVE 0 TO WS-E
    MOVE WS-PICK TO WS-O
    CALL "Q3-EQ" USING WS-CASE WS-E WS-O
    MOVE "acceptance US15 44-3§2.8 kind none" TO WS-CASE
    MOVE 0 TO WS-E
    MOVE WS-VKIND TO WS-O
    CALL "Q3-EQ" USING WS-CASE WS-E WS-O
    MOVE 0 TO WS-REST
    MOVE 1 TO WS-SLEEPING
    CALL "Q3-WAKE" USING WS-REST WS-SLEEPING WS-STOP
    MOVE "acceptance US15 44-3§2.9 WakeUp: not in REST and sleeping: stop sleeping" TO WS-CASE
    MOVE 1 TO WS-E
    MOVE WS-STOP TO WS-O
    CALL "Q3-EQ" USING WS-CASE WS-E WS-O
    MOVE 1 TO WS-REST
    CALL "Q3-WAKE" USING WS-REST WS-SLEEPING WS-STOP
    MOVE "acceptance US15 44-3§2.9 WakeUp: in REST: keeps sleeping" TO WS-CASE
    MOVE 0 TO WS-E
    MOVE WS-STOP TO WS-O
    CALL "Q3-EQ" USING WS-CASE WS-E WS-O
    MOVE 0 TO WS-REST
    MOVE 0 TO WS-SLEEPING
    CALL "Q3-WAKE" USING WS-REST WS-SLEEPING WS-STOP
    MOVE "acceptance US15 44-3§2.9 WakeUp: awake: nothing" TO WS-CASE
    MOVE 0 TO WS-E
    MOVE WS-STOP TO WS-O
    CALL "Q3-EQ" USING WS-CASE WS-E WS-O
    MOVE 1 TO WS-BABY
    MOVE 1 TO WS-ONBED
    MOVE 0 TO WS-HASBED
    CALL "Q3-JUMP-START" USING WS-BABY WS-ONBED WS-HASBED WS-YES
    MOVE "acceptance US15 44-3§2.9 JumpOnBed: a baby on a bed starts" TO WS-CASE
    MOVE 1 TO WS-E
    MOVE WS-YES TO WS-O
    CALL "Q3-EQ" USING WS-CASE WS-E WS-O
    MOVE 0 TO WS-ONBED
    MOVE 1 TO WS-HASBED
    CALL "Q3-JUMP-START" USING WS-BABY WS-ONBED WS-HASBED WS-YES
    MOVE "acceptance US15 44-3§2.9 JumpOnBed: a baby with a nearest bed starts" TO WS-CASE
    MOVE 1 TO WS-E
    MOVE WS-YES TO WS-O
    CALL "Q3-EQ" USING WS-CASE WS-E WS-O
    MOVE 0 TO WS-HASBED
    CALL "Q3-JUMP-START" USING WS-BABY WS-ONBED WS-HASBED WS-YES
    MOVE "acceptance US15 44-3§2.9 JumpOnBed: a baby with neither does not" TO WS-CASE
    MOVE 0 TO WS-E
    MOVE WS-YES TO WS-O
    CALL "Q3-EQ" USING WS-CASE WS-E WS-O
    MOVE 0 TO WS-BABY
    MOVE 1 TO WS-ONBED
    CALL "Q3-JUMP-START" USING WS-BABY WS-ONBED WS-HASBED WS-YES
    MOVE "acceptance US15 44-3§2.9 JumpOnBed: an adult does not" TO WS-CASE
    MOVE 0 TO WS-E
    MOVE WS-YES TO WS-O
    CALL "Q3-EQ" USING WS-CASE WS-E WS-O
    MOVE 3 TO WS-DRAW
    CALL "Q3-JUMP-INIT" USING WS-DRAW WS-BUDGET WS-JUMPS WS-COOL
    MOVE "acceptance US15 44-3§2.9 JumpOnBed start: 100 ticks to reach the bed" TO WS-CASE
    MOVE 100 TO WS-E
    MOVE WS-BUDGET TO WS-O
    CALL "Q3-EQ" USING WS-CASE WS-E WS-O
    MOVE "acceptance US15 44-3§2.9 JumpOnBed start: 3 + nextInt(4) jumps" TO WS-CASE
    MOVE 6 TO WS-E
    MOVE WS-JUMPS TO WS-O
    CALL "Q3-EQ" USING WS-CASE WS-E WS-O
    MOVE "acceptance US15 44-3§2.9 JumpOnBed start: no cooldown draw" TO WS-CASE
    MOVE 0 TO WS-E
    MOVE WS-COOL TO WS-O
    CALL "Q3-EQ" USING WS-CASE WS-E WS-O
    MOVE 0 TO WS-ONBED
    MOVE 0 TO WS-SURFACE
    MOVE 100 TO WS-BUDGET
    MOVE 4 TO WS-JUMPS
    MOVE 0 TO WS-COOL
    CALL "Q3-JUMP-TICK" USING WS-ONBED WS-SURFACE WS-BUDGET WS-JUMPS WS-COOL WS-JUMP
    MOVE "acceptance US15 44-3§2.9 JumpOnBed tick: off the bed the walking budget counts down" TO WS-CASE
    MOVE 99 TO WS-E
    MOVE WS-BUDGET TO WS-O
    CALL "Q3-EQ" USING WS-CASE WS-E WS-O
    MOVE "acceptance US15 44-3§2.9 JumpOnBed tick: no jump" TO WS-CASE
    MOVE 0 TO WS-E
    MOVE WS-JUMP TO WS-O
    CALL "Q3-EQ" USING WS-CASE WS-E WS-O
    MOVE 1 TO WS-ONBED
    MOVE 1 TO WS-SURFACE
    MOVE 2 TO WS-COOL
    CALL "Q3-JUMP-TICK" USING WS-ONBED WS-SURFACE WS-BUDGET WS-JUMPS WS-COOL WS-JUMP
    MOVE "acceptance US15 44-3§2.9 JumpOnBed tick: on the bed the cooldown runs down first" TO WS-CASE
    MOVE 1 TO WS-E
    MOVE WS-COOL TO WS-O
    CALL "Q3-EQ" USING WS-CASE WS-E WS-O
    MOVE "acceptance US15 44-3§2.9 JumpOnBed tick: no jump yet" TO WS-CASE
    MOVE 0 TO WS-E
    MOVE WS-JUMP TO WS-O
    CALL "Q3-EQ" USING WS-CASE WS-E WS-O
    MOVE "acceptance US15 44-3§2.9 JumpOnBed tick: the budget is not touched on the bed" TO WS-CASE
    MOVE 99 TO WS-E
    MOVE WS-BUDGET TO WS-O
    CALL "Q3-EQ" USING WS-CASE WS-E WS-O
    MOVE 0 TO WS-COOL
    CALL "Q3-JUMP-TICK" USING WS-ONBED WS-SURFACE WS-BUDGET WS-JUMPS WS-COOL WS-JUMP
    MOVE "acceptance US15 44-3§2.9 JumpOnBed tick: on the bed surface with no cooldown it jumps" TO WS-CASE
    MOVE 1 TO WS-E
    MOVE WS-JUMP TO WS-O
    CALL "Q3-EQ" USING WS-CASE WS-E WS-O
    MOVE "acceptance US15 44-3§2.9 JumpOnBed tick: one jump less" TO WS-CASE
    MOVE 3 TO WS-E
    MOVE WS-JUMPS TO WS-O
    CALL "Q3-EQ" USING WS-CASE WS-E WS-O
    MOVE "acceptance US15 44-3§2.9 JumpOnBed tick: cooldown 5" TO WS-CASE
    MOVE 5 TO WS-E
    MOVE WS-COOL TO WS-O
    CALL "Q3-EQ" USING WS-CASE WS-E WS-O
    MOVE 0 TO WS-COOL
    MOVE 0 TO WS-SURFACE
    CALL "Q3-JUMP-TICK" USING WS-ONBED WS-SURFACE WS-BUDGET WS-JUMPS WS-COOL WS-JUMP
    MOVE "acceptance US15 44-3§2.9 JumpOnBed tick: over the bed but not on its surface: no jump" TO WS-CASE
    MOVE 0 TO WS-E
    MOVE WS-JUMP TO WS-O
    CALL "Q3-EQ" USING WS-CASE WS-E WS-O
    MOVE 1 TO WS-BABY
    MOVE 1 TO WS-BEDOK
    MOVE 0 TO WS-ONBED
    MOVE 1 TO WS-BUDGET
    MOVE 3 TO WS-JUMPS
    CALL "Q3-JUMP-CONTINUE" USING WS-BABY WS-BEDOK WS-ONBED WS-BUDGET WS-JUMPS WS-YES
    MOVE "acceptance US15 44-3§2.9 JumpOnBed continues while walking with budget left" TO WS-CASE
    MOVE 1 TO WS-E
    MOVE WS-YES TO WS-O
    CALL "Q3-EQ" USING WS-CASE WS-E WS-O
    MOVE 0 TO WS-BUDGET
    CALL "Q3-JUMP-CONTINUE" USING WS-BABY WS-BEDOK WS-ONBED WS-BUDGET WS-JUMPS WS-YES
    MOVE "acceptance US15 44-3§2.9 JumpOnBed stops when tired of walking (budget 0)" TO WS-CASE
    MOVE 0 TO WS-E
    MOVE WS-YES TO WS-O
    CALL "Q3-EQ" USING WS-CASE WS-E WS-O
    MOVE 1 TO WS-ONBED
    MOVE 1 TO WS-JUMPS
    CALL "Q3-JUMP-CONTINUE" USING WS-BABY WS-BEDOK WS-ONBED WS-BUDGET WS-JUMPS WS-YES
    MOVE "acceptance US15 44-3§2.9 JumpOnBed continues on the bed with a jump left" TO WS-CASE
    MOVE 1 TO WS-E
    MOVE WS-YES TO WS-O
    CALL "Q3-EQ" USING WS-CASE WS-E WS-O
    MOVE 0 TO WS-JUMPS
    CALL "Q3-JUMP-CONTINUE" USING WS-BABY WS-BEDOK WS-ONBED WS-BUDGET WS-JUMPS WS-YES
    MOVE "acceptance US15 44-3§2.9 JumpOnBed stops when tired of jumping" TO WS-CASE
    MOVE 0 TO WS-E
    MOVE WS-YES TO WS-O
    CALL "Q3-EQ" USING WS-CASE WS-E WS-O
    MOVE 2 TO WS-JUMPS
    MOVE 0 TO WS-BEDOK
    CALL "Q3-JUMP-CONTINUE" USING WS-BABY WS-BEDOK WS-ONBED WS-BUDGET WS-JUMPS WS-YES
    MOVE "acceptance US15 44-3§2.9 JumpOnBed stops when the bed is gone" TO WS-CASE
    MOVE 0 TO WS-E
    MOVE WS-YES TO WS-O
    CALL "Q3-EQ" USING WS-CASE WS-E WS-O
    MOVE 1 TO WS-BEDOK
    MOVE 0 TO WS-BABY
    CALL "Q3-JUMP-CONTINUE" USING WS-BABY WS-BEDOK WS-ONBED WS-BUDGET WS-JUMPS WS-YES
    MOVE "acceptance US15 44-3§2.9 JumpOnBed stops when the mob grew up" TO WS-CASE
    MOVE 0 TO WS-E
    MOVE WS-YES TO WS-O
    CALL "Q3-EQ" USING WS-CASE WS-E WS-O
    MOVE 1 TO WS-FFOUND
    MOVE 1 TO WS-FWITHIN
    MOVE 1 TO WS-RFOUND
    MOVE 1 TO WS-STORED
    CALL "Q3-HIDE-PICK" USING WS-FFOUND WS-FWITHIN WS-RFOUND WS-STORED WS-SOURCE
    MOVE "acceptance US15 44-3§2.10 LocateHidingPlace prefers the home found within radius + 1 and radius" TO WS-CASE
    MOVE 1 TO WS-E
    MOVE WS-SOURCE TO WS-O
    CALL "Q3-EQ" USING WS-CASE WS-E WS-O
    MOVE 0 TO WS-FWITHIN
    CALL "Q3-HIDE-PICK" USING WS-FFOUND WS-FWITHIN WS-RFOUND WS-STORED WS-SOURCE
    MOVE "acceptance US15 44-3§2.10 a found home beyond the radius falls to the random home POI" TO WS-CASE
    MOVE 2 TO WS-E
    MOVE WS-SOURCE TO WS-O
    CALL "Q3-EQ" USING WS-CASE WS-E WS-O
    MOVE 0 TO WS-FFOUND
    MOVE 0 TO WS-RFOUND
    CALL "Q3-HIDE-PICK" USING WS-FFOUND WS-FWITHIN WS-RFOUND WS-STORED WS-SOURCE
    MOVE "acceptance US15 44-3§2.10 with neither the stored hiding_place is reused" TO WS-CASE
    MOVE 3 TO WS-E
    MOVE WS-SOURCE TO WS-O
    CALL "Q3-EQ" USING WS-CASE WS-E WS-O
    MOVE 0 TO WS-STORED
    CALL "Q3-HIDE-PICK" USING WS-FFOUND WS-FWITHIN WS-RFOUND WS-STORED WS-SOURCE
    MOVE "acceptance US15 44-3§2.10 with none of the three nothing happens" TO WS-CASE
    MOVE 0 TO WS-E
    MOVE WS-SOURCE TO WS-O
    CALL "Q3-EQ" USING WS-CASE WS-E WS-O
    MOVE 1 TO WS-CLOSE
    CALL "Q3-HIDE-WALK" USING WS-CLOSE WS-WALK
    MOVE "acceptance US15 44-3§2.10 within closeEnough of the hiding place: no walk target" TO WS-CASE
    MOVE 0 TO WS-E
    MOVE WS-WALK TO WS-O
    CALL "Q3-EQ" USING WS-CASE WS-E WS-O
    MOVE 0 TO WS-CLOSE
    CALL "Q3-HIDE-WALK" USING WS-CLOSE WS-WALK
    MOVE "acceptance US15 44-3§2.10 not within closeEnough: the walk target is set" TO WS-CASE
    MOVE 1 TO WS-E
    MOVE WS-WALK TO WS-O
    CALL "Q3-EQ" USING WS-CASE WS-E WS-O
     STOP RUN.
 END PROGRAM TEST-Q44-44-3-3.
 COPY Q3TEST.
