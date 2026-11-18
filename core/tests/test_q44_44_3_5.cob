*> Test of 44 part 3 sections 2.17, 2.18, 3.2 to 3.4 and 4 as decision units: farmer and movement helpers, sensor timing, restock day, trading, sensors (lane 002-lane-p49h, T22005).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-Q44-44-3-5.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-CASE                PIC X(240).
 01 WS-E                   BINARY-LONG.
 01 WS-O                   BINARY-LONG.
 01 WS-DRAWS.
    05 WS-DRAWS-T            BINARY-LONG OCCURS 8 TIMES.
 01 WS-VT.
    05 WS-VT-T            BINARY-LONG OCCURS 8 TIMES.
 01 WS-BT.
    05 WS-BT-T            BINARY-LONG OCCURS 8 TIMES.
 01 WS-OT.
    05 WS-OT-T            BINARY-LONG OCCURS 8 TIMES.
 01 WS-SPEED                FLOAT-LONG.
 01 WS-D2                   FLOAT-LONG.
 01 WS-SAMEDIM              BINARY-LONG.
 01 WS-HASSINCE             BINARY-LONG.
 01 WS-SINCE                BINARY-LONG.
 01 WS-NOW                  BINARY-LONG.
 01 WS-GIVEUP               BINARY-LONG.
 01 WS-D                    BINARY-LONG.
 01 WS-TOOFAR               BINARY-LONG.
 01 WS-CLOSE                BINARY-LONG.
 01 WS-FOUND                BINARY-LONG.
 01 WS-OUTCOME              BINARY-LONG.
 01 WS-INST                 BINARY-LONG.
 01 WS-HEARD                BINARY-LONG.
 01 WS-COUNTER              BINARY-LONG.
 01 WS-NEAR                 BINARY-LONG.
 01 WS-DONE                 BINARY-LONG.
 01 WS-D1                   BINARY-LONG.
 01 WS-D2X                  BINARY-LONG.
 01 WS-D3                   BINARY-LONG.
 01 WS-OX                   BINARY-LONG.
 01 WS-OY                   BINARY-LONG.
 01 WS-OZ                   BINARY-LONG.
 01 WS-SEES                 BINARY-LONG.
 01 WS-RUN                  BINARY-LONG.
 01 WS-HEIGHT               BINARY-LONG.
 01 WS-VY                   BINARY-LONG.
 01 WS-OK                   BINARY-LONG.
 01 WS-MAXAGE               BINARY-LONG.
 01 WS-AIR                  BINARY-LONG.
 01 WS-FARMLAND             BINARY-LONG.
 01 WS-VALID                BINARY-LONG.
 01 WS-GRIEFING             BINARY-LONG.
 01 WS-FARMER               BINARY-LONG.
 01 WS-NEXTOK               BINARY-LONG.
 01 WS-CELLS                BINARY-LONG.
 01 WS-DRAW                 BINARY-LONG.
 01 WS-PICK                 BINARY-LONG.
 01 WS-HASCELL              BINARY-LONG.
 01 WS-WORKED               BINARY-LONG.
 01 WS-ACT                  BINARY-LONG.
 01 WS-REMAINING            BINARY-LONG.
 01 WS-YES                  BINARY-LONG.
 01 WS-TICK                 BINARY-LONG.
 01 WS-LAST                 BINARY-LONG.
 01 WS-MEAL                 BINARY-LONG.
 01 WS-TARGET               BINARY-LONG.
 01 WS-N                    BINARY-LONG.
 01 WS-NEXTCYCLE            BINARY-LONG.
 01 WS-GREW                 BINARY-LONG.
 01 WS-INTERVAL             BINARY-LONG.
 01 WS-CDN                  BINARY-LONG.
 01 WS-SCAN                 BINARY-LONG.
 01 WS-COUNT                BINARY-LONG.
 01 WS-ACTION               BINARY-LONG.
 01 WS-GOLEM                BINARY-LONG.
 01 WS-SET                  BINARY-LONG.
 01 WS-EXPIRY               BINARY-LONG.
 01 WS-BABY                 BINARY-LONG.
 01 WS-LASTUPDATE           BINARY-LONG.
 01 WS-HASDMG               BINARY-LONG.
 01 WS-LIVING               BINARY-LONG.
 01 WS-ENTBAD               BINARY-LONG.
 01 WS-HURTACT              BINARY-LONG.
 01 WS-ENTACT               BINARY-LONG.
 01 WS-MAXSTACK             BINARY-LONG.
 01 WS-SPLIT                BINARY-LONG.
 01 WS-FOOD                 BINARY-LONG.
 01 WS-PARTNER              BINARY-LONG.
 01 WS-WHEAT                BINARY-LONG.
 01 WS-WILLING              BINARY-LONG.
 01 WS-HASITEM              BINARY-LONG.
 01 WS-A                    BINARY-LONG.
 01 WS-B                    BINARY-LONG.
 01 WS-C                    BINARY-LONG.
 01 WS-ALIVE                BINARY-LONG.
 01 WS-DIFFERS              BINARY-LONG.
 01 WS-MATCHES              BINARY-LONG.
 01 WS-LOOKTIME             BINARY-LONG.
 01 WS-DISPLAY              BINARY-LONG.
 01 WS-IDX                  BINARY-LONG.
 01 WS-TIMER                BINARY-LONG.
 01 WS-TRADING              BINARY-LONG.
 01 WS-WATER                BINARY-LONG.
 01 WS-HURT                 BINARY-LONG.
 01 WS-ACTIVE               BINARY-LONG.
 01 WS-LASTDAY              BINARY-LONG.
 01 WS-DAY                  BINARY-LONG.
 01 WS-CHANGED              BINARY-LONG.
 PROCEDURE DIVISION.
    COMPUTE WS-SPEED = 0
    COMPUTE WS-D2 = 0
    MOVE 1 TO WS-SAMEDIM
    MOVE 0 TO WS-HASSINCE
    MOVE 0 TO WS-SINCE
    MOVE 5000 TO WS-NOW
    MOVE 1200 TO WS-GIVEUP
    MOVE 5 TO WS-D
    MOVE 100 TO WS-TOOFAR
    MOVE 1 TO WS-CLOSE
    MOVE 0 TO WS-FOUND
    CALL "Q3-BLOCKMEM" USING WS-SAMEDIM WS-HASSINCE WS-SINCE WS-NOW WS-GIVEUP WS-D WS-TOOFAR WS-CLOSE WS-FOUND WS-OUTCOME
    MOVE "acceptance US15 44-3§2.17 a position within tooFar but beyond closeEnough: walk to the block itself" TO WS-CASE
    MOVE 3 TO WS-E
    MOVE WS-OUTCOME TO WS-O
    CALL "Q3-EQ" USING WS-CASE WS-E WS-O
    MOVE 1 TO WS-D
    CALL "Q3-BLOCKMEM" USING WS-SAMEDIM WS-HASSINCE WS-SINCE WS-NOW WS-GIVEUP WS-D WS-TOOFAR WS-CLOSE WS-FOUND WS-OUTCOME
    MOVE "acceptance US15 44-3§2.17 already within closeEnough: nothing" TO WS-CASE
    MOVE 0 TO WS-E
    MOVE WS-OUTCOME TO WS-O
    CALL "Q3-EQ" USING WS-CASE WS-E WS-O
    MOVE 150 TO WS-D
    MOVE 1 TO WS-FOUND
    CALL "Q3-BLOCKMEM" USING WS-SAMEDIM WS-HASSINCE WS-SINCE WS-NOW WS-GIVEUP WS-D WS-TOOFAR WS-CLOSE WS-FOUND WS-OUTCOME
    MOVE "acceptance US15 44-3§2.17 beyond tooFar with a random position found: walk to it" TO WS-CASE
    MOVE 2 TO WS-E
    MOVE WS-OUTCOME TO WS-O
    CALL "Q3-EQ" USING WS-CASE WS-E WS-O
    MOVE 0 TO WS-FOUND
    CALL "Q3-BLOCKMEM" USING WS-SAMEDIM WS-HASSINCE WS-SINCE WS-NOW WS-GIVEUP WS-D WS-TOOFAR WS-CLOSE WS-FOUND WS-OUTCOME
    MOVE "acceptance US15 44-3§2.17 beyond tooFar and all 1000 attempts failed: release and erase" TO WS-CASE
    MOVE 1 TO WS-E
    MOVE WS-OUTCOME TO WS-O
    CALL "Q3-EQ" USING WS-CASE WS-E WS-O
    MOVE 5 TO WS-D
    MOVE 0 TO WS-SAMEDIM
    CALL "Q3-BLOCKMEM" USING WS-SAMEDIM WS-HASSINCE WS-SINCE WS-NOW WS-GIVEUP WS-D WS-TOOFAR WS-CLOSE WS-FOUND WS-OUTCOME
    MOVE "acceptance US15 44-3§2.17 a position in another dimension: release and erase" TO WS-CASE
    MOVE 1 TO WS-E
    MOVE WS-OUTCOME TO WS-O
    CALL "Q3-EQ" USING WS-CASE WS-E WS-O
    MOVE 1 TO WS-SAMEDIM
    MOVE 1 TO WS-HASSINCE
    MOVE 3800 TO WS-SINCE
    CALL "Q3-BLOCKMEM" USING WS-SAMEDIM WS-HASSINCE WS-SINCE WS-NOW WS-GIVEUP WS-D WS-TOOFAR WS-CLOSE WS-FOUND WS-OUTCOME
    MOVE "acceptance US15 44-3§2.17 unreachable for 1200 ticks exactly: not yet (the test is strictly more)" TO WS-CASE
    MOVE 3 TO WS-E
    MOVE WS-OUTCOME TO WS-O
    CALL "Q3-EQ" USING WS-CASE WS-E WS-O
    MOVE 3799 TO WS-SINCE
    CALL "Q3-BLOCKMEM" USING WS-SAMEDIM WS-HASSINCE WS-SINCE WS-NOW WS-GIVEUP WS-D WS-TOOFAR WS-CLOSE WS-FOUND WS-OUTCOME
    MOVE "acceptance US15 44-3§2.17 unreachable for 1201 ticks: release and erase" TO WS-CASE
    MOVE 1 TO WS-E
    MOVE WS-OUTCOME TO WS-O
    CALL "Q3-EQ" USING WS-CASE WS-E WS-O
    MOVE 1 TO WS-INST
    CALL "Q3-BLOCKMEM-PARAMS" USING WS-INST WS-CLOSE WS-TOOFAR WS-GIVEUP WS-SPEED
    MOVE "acceptance US15 44-3§2.17 job_site entry: closeEnough 9" TO WS-CASE
    MOVE 9 TO WS-E
    MOVE WS-CLOSE TO WS-O
    CALL "Q3-EQ" USING WS-CASE WS-E WS-O
    MOVE "acceptance US15 44-3§2.17 job_site entry: tooFar 100" TO WS-CASE
    MOVE 100 TO WS-E
    MOVE WS-TOOFAR TO WS-O
    CALL "Q3-EQ" USING WS-CASE WS-E WS-O
    MOVE "acceptance US15 44-3§2.17 job_site entry: giveUpAfter 1200" TO WS-CASE
    MOVE 1200 TO WS-E
    MOVE WS-GIVEUP TO WS-O
    CALL "Q3-EQ" USING WS-CASE WS-E WS-O
    MOVE "acceptance US15 44-3§2.17 job_site entry: speed 1.0 (times s)" TO WS-CASE
    MOVE 1000 TO WS-E
    COMPUTE WS-O = FUNCTION INTEGER(WS-SPEED * 1000 + 0.5)
    CALL "Q3-EQ" USING WS-CASE WS-E WS-O
    MOVE 2 TO WS-INST
    CALL "Q3-BLOCKMEM-PARAMS" USING WS-INST WS-CLOSE WS-TOOFAR WS-GIVEUP WS-SPEED
    MOVE "acceptance US15 44-3§2.17 home entry: closeEnough 1" TO WS-CASE
    MOVE 1 TO WS-E
    MOVE WS-CLOSE TO WS-O
    CALL "Q3-EQ" USING WS-CASE WS-E WS-O
    MOVE "acceptance US15 44-3§2.17 home entry: tooFar 150" TO WS-CASE
    MOVE 150 TO WS-E
    MOVE WS-TOOFAR TO WS-O
    CALL "Q3-EQ" USING WS-CASE WS-E WS-O
    MOVE "acceptance US15 44-3§2.17 home entry: giveUpAfter 1200" TO WS-CASE
    MOVE 1200 TO WS-E
    MOVE WS-GIVEUP TO WS-O
    CALL "Q3-EQ" USING WS-CASE WS-E WS-O
    MOVE 3 TO WS-INST
    CALL "Q3-BLOCKMEM-PARAMS" USING WS-INST WS-CLOSE WS-TOOFAR WS-GIVEUP WS-SPEED
    MOVE "acceptance US15 44-3§2.17 meeting point in the meet activity: closeEnough 6" TO WS-CASE
    MOVE 6 TO WS-E
    MOVE WS-CLOSE TO WS-O
    CALL "Q3-EQ" USING WS-CASE WS-E WS-O
    MOVE "acceptance US15 44-3§2.17 meeting point in the meet activity: tooFar 100" TO WS-CASE
    MOVE 100 TO WS-E
    MOVE WS-TOOFAR TO WS-O
    CALL "Q3-EQ" USING WS-CASE WS-E WS-O
    MOVE "acceptance US15 44-3§2.17 meeting point in the meet activity: giveUpAfter 200" TO WS-CASE
    MOVE 200 TO WS-E
    MOVE WS-GIVEUP TO WS-O
    CALL "Q3-EQ" USING WS-CASE WS-E WS-O
    MOVE 4 TO WS-INST
    CALL "Q3-BLOCKMEM-PARAMS" USING WS-INST WS-CLOSE WS-TOOFAR WS-GIVEUP WS-SPEED
    MOVE "acceptance US15 44-3§2.17 meeting point in pre-raid: closeEnough 2" TO WS-CASE
    MOVE 2 TO WS-E
    MOVE WS-CLOSE TO WS-O
    CALL "Q3-EQ" USING WS-CASE WS-E WS-O
    MOVE "acceptance US15 44-3§2.17 meeting point in pre-raid: tooFar 150" TO WS-CASE
    MOVE 150 TO WS-E
    MOVE WS-TOOFAR TO WS-O
    CALL "Q3-EQ" USING WS-CASE WS-E WS-O
    MOVE "acceptance US15 44-3§2.17 meeting point in pre-raid: giveUpAfter 200" TO WS-CASE
    MOVE 200 TO WS-E
    MOVE WS-GIVEUP TO WS-O
    CALL "Q3-EQ" USING WS-CASE WS-E WS-O
    MOVE "acceptance US15 44-3§2.17 meeting point in pre-raid: speed 1.5 s" TO WS-CASE
    MOVE 1500 TO WS-E
    COMPUTE WS-O = FUNCTION INTEGER(WS-SPEED * 1000 + 0.5)
    CALL "Q3-EQ" USING WS-CASE WS-E WS-O
    MOVE 1000 TO WS-NOW
    MOVE 900 TO WS-HEARD
    MOVE 10 TO WS-COUNTER
    MOVE 1 TO WS-NEAR
    CALL "Q3-HIDDEN" USING WS-NOW WS-HEARD WS-COUNTER WS-NEAR WS-DONE
    MOVE "acceptance US15 44-3§2.17 SetHiddenState: near the hiding place the counter advances" TO WS-CASE
    MOVE 11 TO WS-E
    MOVE WS-COUNTER TO WS-O
    CALL "Q3-EQ" USING WS-CASE WS-E WS-O
    MOVE "acceptance US15 44-3§2.17 SetHiddenState: not done" TO WS-CASE
    MOVE 0 TO WS-E
    MOVE WS-DONE TO WS-O
    CALL "Q3-EQ" USING WS-CASE WS-E WS-O
    MOVE 0 TO WS-NEAR
    CALL "Q3-HIDDEN" USING WS-NOW WS-HEARD WS-COUNTER WS-NEAR WS-DONE
    MOVE "acceptance US15 44-3§2.17 SetHiddenState: away from the hiding place the counter does not advance" TO WS-CASE
    MOVE 11 TO WS-E
    MOVE WS-COUNTER TO WS-O
    CALL "Q3-EQ" USING WS-CASE WS-E WS-O
    MOVE 700 TO WS-HEARD
    CALL "Q3-HIDDEN" USING WS-NOW WS-HEARD WS-COUNTER WS-NEAR WS-DONE
    MOVE "acceptance US15 44-3§2.17 SetHiddenState: the bell was heard 300 ticks ago: hiding ends" TO WS-CASE
    MOVE 1 TO WS-E
    MOVE WS-DONE TO WS-O
    CALL "Q3-EQ" USING WS-CASE WS-E WS-O
    MOVE "acceptance US15 44-3§2.17 SetHiddenState: the counter is reset" TO WS-CASE
    MOVE 0 TO WS-E
    MOVE WS-COUNTER TO WS-O
    CALL "Q3-EQ" USING WS-CASE WS-E WS-O
    MOVE 701 TO WS-HEARD
    MOVE 300 TO WS-COUNTER
    MOVE 1 TO WS-NEAR
    CALL "Q3-HIDDEN" USING WS-NOW WS-HEARD WS-COUNTER WS-NEAR WS-DONE
    MOVE "acceptance US15 44-3§2.17 SetHiddenState: the counter at 300 keeps hiding (it must exceed 300)" TO WS-CASE
    MOVE 0 TO WS-E
    MOVE WS-DONE TO WS-O
    CALL "Q3-EQ" USING WS-CASE WS-E WS-O
    MOVE "acceptance US15 44-3§2.17 SetHiddenState: and counts to 301" TO WS-CASE
    MOVE 301 TO WS-E
    MOVE WS-COUNTER TO WS-O
    CALL "Q3-EQ" USING WS-CASE WS-E WS-O
    CALL "Q3-HIDDEN" USING WS-NOW WS-HEARD WS-COUNTER WS-NEAR WS-DONE
    MOVE "acceptance US15 44-3§2.17 SetHiddenState: the counter at 301 ends the hiding" TO WS-CASE
    MOVE 1 TO WS-E
    MOVE WS-DONE TO WS-O
    CALL "Q3-EQ" USING WS-CASE WS-E WS-O
    MOVE 0 TO WS-D1
    MOVE 0 TO WS-D2X
    MOVE 19 TO WS-D3
    CALL "Q3-SKY-OFFSET" USING WS-D1 WS-D2X WS-D3 WS-OX WS-OY WS-OZ
    MOVE "acceptance US15 44-3§2.17 MoveToSkySeeingSpot offset x = nextInt(20) - 10 (0 gives -10)" TO WS-CASE
    MOVE -10 TO WS-E
    MOVE WS-OX TO WS-O
    CALL "Q3-EQ" USING WS-CASE WS-E WS-O
    MOVE "acceptance US15 44-3§2.17 MoveToSkySeeingSpot offset y = nextInt(6) - 3 (0 gives -3)" TO WS-CASE
    MOVE -3 TO WS-E
    MOVE WS-OY TO WS-O
    CALL "Q3-EQ" USING WS-CASE WS-E WS-O
    MOVE "acceptance US15 44-3§2.17 MoveToSkySeeingSpot offset z = nextInt(20) - 10 (19 gives 9)" TO WS-CASE
    MOVE 9 TO WS-E
    MOVE WS-OZ TO WS-O
    CALL "Q3-EQ" USING WS-CASE WS-E WS-O
    MOVE 1 TO WS-SEES
    CALL "Q3-SKY-START" USING WS-SEES WS-RUN
    MOVE "acceptance US15 44-3§2.17 MoveToSkySeeingSpot: a villager that sees the sky does nothing" TO WS-CASE
    MOVE 0 TO WS-E
    MOVE WS-RUN TO WS-O
    CALL "Q3-EQ" USING WS-CASE WS-E WS-O
    MOVE 0 TO WS-SEES
    CALL "Q3-SKY-START" USING WS-SEES WS-RUN
    MOVE "acceptance US15 44-3§2.17 MoveToSkySeeingSpot: otherwise it looks for a spot" TO WS-CASE
    MOVE 1 TO WS-E
    MOVE WS-RUN TO WS-O
    CALL "Q3-EQ" USING WS-CASE WS-E WS-O
    MOVE 1 TO WS-SEES
    MOVE 64 TO WS-HEIGHT
    MOVE 64 TO WS-VY
    CALL "Q3-SKY-ACCEPT" USING WS-SEES WS-HEIGHT WS-VY WS-OK
    MOVE "acceptance US15 44-3§2.17 MoveToSkySeeingSpot: sky seen and the height not above the villager: accepted" TO WS-CASE
    MOVE 1 TO WS-E
    MOVE WS-OK TO WS-O
    CALL "Q3-EQ" USING WS-CASE WS-E WS-O
    MOVE 65 TO WS-HEIGHT
    CALL "Q3-SKY-ACCEPT" USING WS-SEES WS-HEIGHT WS-VY WS-OK
    MOVE "acceptance US15 44-3§2.17 MoveToSkySeeingSpot: motion-blocking height above the villager: rejected" TO WS-CASE
    MOVE 0 TO WS-E
    MOVE WS-OK TO WS-O
    CALL "Q3-EQ" USING WS-CASE WS-E WS-O
    MOVE 60 TO WS-HEIGHT
    MOVE 0 TO WS-SEES
    CALL "Q3-SKY-ACCEPT" USING WS-SEES WS-HEIGHT WS-VY WS-OK
    MOVE "acceptance US15 44-3§2.17 MoveToSkySeeingSpot: no sky: rejected" TO WS-CASE
    MOVE 0 TO WS-E
    MOVE WS-OK TO WS-O
    CALL "Q3-EQ" USING WS-CASE WS-E WS-O
    MOVE 1 TO WS-MAXAGE
    MOVE 0 TO WS-AIR
    MOVE 0 TO WS-FARMLAND
    CALL "Q3-HARVEST-CELL" USING WS-MAXAGE WS-AIR WS-FARMLAND WS-VALID
    MOVE "acceptance US15 44-3§2.17 HarvestFarmland: a fully grown crop is a valid cell" TO WS-CASE
    MOVE 1 TO WS-E
    MOVE WS-VALID TO WS-O
    CALL "Q3-EQ" USING WS-CASE WS-E WS-O
    MOVE 0 TO WS-MAXAGE
    MOVE 1 TO WS-AIR
    MOVE 1 TO WS-FARMLAND
    CALL "Q3-HARVEST-CELL" USING WS-MAXAGE WS-AIR WS-FARMLAND WS-VALID
    MOVE "acceptance US15 44-3§2.17 HarvestFarmland: air over farmland is a valid cell" TO WS-CASE
    MOVE 1 TO WS-E
    MOVE WS-VALID TO WS-O
    CALL "Q3-EQ" USING WS-CASE WS-E WS-O
    MOVE 0 TO WS-FARMLAND
    CALL "Q3-HARVEST-CELL" USING WS-MAXAGE WS-AIR WS-FARMLAND WS-VALID
    MOVE "acceptance US15 44-3§2.17 HarvestFarmland: air over other ground is not" TO WS-CASE
    MOVE 0 TO WS-E
    MOVE WS-VALID TO WS-O
    CALL "Q3-EQ" USING WS-CASE WS-E WS-O
    MOVE 0 TO WS-AIR
    CALL "Q3-HARVEST-CELL" USING WS-MAXAGE WS-AIR WS-FARMLAND WS-VALID
    MOVE "acceptance US15 44-3§2.17 HarvestFarmland: a young crop is not" TO WS-CASE
    MOVE 0 TO WS-E
    MOVE WS-VALID TO WS-O
    CALL "Q3-EQ" USING WS-CASE WS-E WS-O
    MOVE 1 TO WS-GRIEFING
    MOVE 1 TO WS-FARMER
    MOVE 100 TO WS-NOW
    MOVE 50 TO WS-NEXTOK
    MOVE 5 TO WS-CELLS
    MOVE 4 TO WS-DRAW
    CALL "Q3-HARVEST-START" USING WS-GRIEFING WS-FARMER WS-NOW WS-NEXTOK WS-CELLS WS-DRAW WS-PICK
    MOVE "acceptance US15 44-3§2.17 HarvestFarmland: one cell chosen uniformly (draw 4 of 5: cell 5)" TO WS-CASE
    MOVE 5 TO WS-E
    MOVE WS-PICK TO WS-O
    CALL "Q3-EQ" USING WS-CASE WS-E WS-O
    MOVE 0 TO WS-GRIEFING
    CALL "Q3-HARVEST-START" USING WS-GRIEFING WS-FARMER WS-NOW WS-NEXTOK WS-CELLS WS-DRAW WS-PICK
    MOVE "acceptance US15 44-3§2.17 HarvestFarmland: mob_griefing off: no start" TO WS-CASE
    MOVE 0 TO WS-E
    MOVE WS-PICK TO WS-O
    CALL "Q3-EQ" USING WS-CASE WS-E WS-O
    MOVE 1 TO WS-GRIEFING
    MOVE 0 TO WS-FARMER
    CALL "Q3-HARVEST-START" USING WS-GRIEFING WS-FARMER WS-NOW WS-NEXTOK WS-CELLS WS-DRAW WS-PICK
    MOVE "acceptance US15 44-3§2.17 HarvestFarmland: not a farmer: no start" TO WS-CASE
    MOVE 0 TO WS-E
    MOVE WS-PICK TO WS-O
    CALL "Q3-EQ" USING WS-CASE WS-E WS-O
    MOVE 1 TO WS-FARMER
    MOVE 0 TO WS-CELLS
    CALL "Q3-HARVEST-START" USING WS-GRIEFING WS-FARMER WS-NOW WS-NEXTOK WS-CELLS WS-DRAW WS-PICK
    MOVE "acceptance US15 44-3§2.17 HarvestFarmland: no valid cell: no start" TO WS-CASE
    MOVE 0 TO WS-E
    MOVE WS-PICK TO WS-O
    CALL "Q3-EQ" USING WS-CASE WS-E WS-O
    MOVE 5 TO WS-CELLS
    MOVE 100 TO WS-NEXTOK
    CALL "Q3-HARVEST-START" USING WS-GRIEFING WS-FARMER WS-NOW WS-NEXTOK WS-CELLS WS-DRAW WS-PICK
    MOVE "acceptance US15 44-3§2.17 HarvestFarmland: only when now is above nextOkStartTime" TO WS-CASE
    MOVE 0 TO WS-E
    MOVE WS-PICK TO WS-O
    CALL "Q3-EQ" USING WS-CASE WS-E WS-O
    MOVE 1 TO WS-HASCELL
    MOVE 0 TO WS-NEAR
    MOVE 200 TO WS-NOW
    MOVE 150 TO WS-NEXTOK
    MOVE 7 TO WS-WORKED
    CALL "Q3-HARVEST-STEP" USING WS-HASCELL WS-NEAR WS-NOW WS-NEXTOK WS-WORKED WS-ACT
    MOVE "acceptance US15 44-3§2.17 HarvestFarmland tick: away from the cell nothing happens" TO WS-CASE
    MOVE 0 TO WS-E
    MOVE WS-ACT TO WS-O
    CALL "Q3-EQ" USING WS-CASE WS-E WS-O
    MOVE "acceptance US15 44-3§2.17 HarvestFarmland tick: and the counter does not advance" TO WS-CASE
    MOVE 7 TO WS-E
    MOVE WS-WORKED TO WS-O
    CALL "Q3-EQ" USING WS-CASE WS-E WS-O
    MOVE 1 TO WS-NEAR
    CALL "Q3-HARVEST-STEP" USING WS-HASCELL WS-NEAR WS-NOW WS-NEXTOK WS-WORKED WS-ACT
    MOVE "acceptance US15 44-3§2.17 HarvestFarmland tick: at the cell with now above nextOk the work steps run" TO WS-CASE
    MOVE 1 TO WS-E
    MOVE WS-ACT TO WS-O
    CALL "Q3-EQ" USING WS-CASE WS-E WS-O
    MOVE "acceptance US15 44-3§2.17 HarvestFarmland tick: the counter advances" TO WS-CASE
    MOVE 8 TO WS-E
    MOVE WS-WORKED TO WS-O
    CALL "Q3-EQ" USING WS-CASE WS-E WS-O
    MOVE 200 TO WS-NEXTOK
    CALL "Q3-HARVEST-STEP" USING WS-HASCELL WS-NEAR WS-NOW WS-NEXTOK WS-WORKED WS-ACT
    MOVE "acceptance US15 44-3§2.17 HarvestFarmland tick: now not above nextOk: no work" TO WS-CASE
    MOVE 0 TO WS-E
    MOVE WS-ACT TO WS-O
    CALL "Q3-EQ" USING WS-CASE WS-E WS-O
    MOVE "acceptance US15 44-3§2.17 HarvestFarmland tick: the counter still advances" TO WS-CASE
    MOVE 9 TO WS-E
    MOVE WS-WORKED TO WS-O
    CALL "Q3-EQ" USING WS-CASE WS-E WS-O
    MOVE 0 TO WS-HASCELL
    MOVE 0 TO WS-NEAR
    CALL "Q3-HARVEST-STEP" USING WS-HASCELL WS-NEAR WS-NOW WS-NEXTOK WS-WORKED WS-ACT
    MOVE "acceptance US15 44-3§2.17 HarvestFarmland tick: with no cell set the distance test does not apply (counter 10)" TO WS-CASE
    MOVE 10 TO WS-E
    MOVE WS-WORKED TO WS-O
    CALL "Q3-EQ" USING WS-CASE WS-E WS-O
    MOVE 3 TO WS-REMAINING
    MOVE 1 TO WS-DRAW
    CALL "Q3-HARVEST-RECHOOSE" USING WS-REMAINING WS-DRAW WS-NOW WS-NEXTOK WS-PICK
    MOVE "acceptance US15 44-3§2.17 HarvestFarmland: a new cell from the remaining list (draw 1: second)" TO WS-CASE
    MOVE 2 TO WS-E
    MOVE WS-PICK TO WS-O
    CALL "Q3-EQ" USING WS-CASE WS-E WS-O
    MOVE "acceptance US15 44-3§2.17 HarvestFarmland: nextOkStartTime = now + 20" TO WS-CASE
    MOVE 220 TO WS-E
    MOVE WS-NEXTOK TO WS-O
    CALL "Q3-EQ" USING WS-CASE WS-E WS-O
    MOVE 0 TO WS-REMAINING
    MOVE 7 TO WS-NEXTOK
    CALL "Q3-HARVEST-RECHOOSE" USING WS-REMAINING WS-DRAW WS-NOW WS-NEXTOK WS-PICK
    MOVE "acceptance US15 44-3§2.17 HarvestFarmland: no cell left: none and nextOk untouched" TO WS-CASE
    MOVE 0 TO WS-E
    MOVE WS-PICK TO WS-O
    CALL "Q3-EQ" USING WS-CASE WS-E WS-O
    MOVE "acceptance US15 44-3§2.17 HarvestFarmland: nextOk is kept" TO WS-CASE
    MOVE 7 TO WS-E
    MOVE WS-NEXTOK TO WS-O
    CALL "Q3-EQ" USING WS-CASE WS-E WS-O
    CALL "Q3-HARVEST-STOP" USING WS-NOW WS-NEXTOK WS-WORKED
    MOVE "acceptance US15 44-3§2.17 HarvestFarmland stop: nextOkStartTime = now + 40" TO WS-CASE
    MOVE 240 TO WS-E
    MOVE WS-NEXTOK TO WS-O
    CALL "Q3-EQ" USING WS-CASE WS-E WS-O
    MOVE "acceptance US15 44-3§2.17 HarvestFarmland stop: timeWorkedSoFar 0" TO WS-CASE
    MOVE 0 TO WS-E
    MOVE WS-WORKED TO WS-O
    CALL "Q3-EQ" USING WS-CASE WS-E WS-O
    MOVE 199 TO WS-WORKED
    CALL "Q3-HARVEST-CONTINUE" USING WS-WORKED WS-YES
    MOVE "acceptance US15 44-3§2.17 HarvestFarmland continues below 200 ticks of work" TO WS-CASE
    MOVE 1 TO WS-E
    MOVE WS-YES TO WS-O
    CALL "Q3-EQ" USING WS-CASE WS-E WS-O
    MOVE 200 TO WS-WORKED
    CALL "Q3-HARVEST-CONTINUE" USING WS-WORKED WS-YES
    MOVE "acceptance US15 44-3§2.17 HarvestFarmland ends at 200" TO WS-CASE
    MOVE 0 TO WS-E
    MOVE WS-YES TO WS-O
    CALL "Q3-EQ" USING WS-CASE WS-E WS-O
    MOVE 20 TO WS-TICK
    MOVE 0 TO WS-LAST
    MOVE 1 TO WS-MEAL
    MOVE 1 TO WS-TARGET
    CALL "Q3-BONEMEAL-START" USING WS-TICK WS-LAST WS-MEAL WS-TARGET WS-YES
    MOVE "acceptance US15 44-3§2.17 UseBonemeal starts on tickCount % 10 = 0 with bone meal and a target" TO WS-CASE
    MOVE 1 TO WS-E
    MOVE WS-YES TO WS-O
    CALL "Q3-EQ" USING WS-CASE WS-E WS-O
    MOVE 21 TO WS-TICK
    CALL "Q3-BONEMEAL-START" USING WS-TICK WS-LAST WS-MEAL WS-TARGET WS-YES
    MOVE "acceptance US15 44-3§2.17 UseBonemeal: not off the 10-tick beat" TO WS-CASE
    MOVE 0 TO WS-E
    MOVE WS-YES TO WS-O
    CALL "Q3-EQ" USING WS-CASE WS-E WS-O
    MOVE 500 TO WS-TICK
    MOVE 341 TO WS-LAST
    CALL "Q3-BONEMEAL-START" USING WS-TICK WS-LAST WS-MEAL WS-TARGET WS-YES
    MOVE "acceptance US15 44-3§2.17 UseBonemeal: less than 160 ticks after the last session" TO WS-CASE
    MOVE 0 TO WS-E
    MOVE WS-YES TO WS-O
    CALL "Q3-EQ" USING WS-CASE WS-E WS-O
    MOVE 340 TO WS-LAST
    CALL "Q3-BONEMEAL-START" USING WS-TICK WS-LAST WS-MEAL WS-TARGET WS-YES
    MOVE "acceptance US15 44-3§2.17 UseBonemeal: 160 ticks after the last session" TO WS-CASE
    MOVE 1 TO WS-E
    MOVE WS-YES TO WS-O
    CALL "Q3-EQ" USING WS-CASE WS-E WS-O
    MOVE 0 TO WS-MEAL
    CALL "Q3-BONEMEAL-START" USING WS-TICK WS-LAST WS-MEAL WS-TARGET WS-YES
    MOVE "acceptance US15 44-3§2.17 UseBonemeal: no bone meal" TO WS-CASE
    MOVE 0 TO WS-E
    MOVE WS-YES TO WS-O
    CALL "Q3-EQ" USING WS-CASE WS-E WS-O
    MOVE 1 TO WS-MEAL
    MOVE 0 TO WS-TARGET
    CALL "Q3-BONEMEAL-START" USING WS-TICK WS-LAST WS-MEAL WS-TARGET WS-YES
    MOVE "acceptance US15 44-3§2.17 UseBonemeal: no young crop in reach" TO WS-CASE
    MOVE 0 TO WS-E
    MOVE WS-YES TO WS-O
    CALL "Q3-EQ" USING WS-CASE WS-E WS-O
    MOVE 4 TO WS-N
    MOVE 0 TO WS-DRAWS-T(1)
    MOVE 1 TO WS-DRAWS-T(2)
    MOVE 0 TO WS-DRAWS-T(3)
    MOVE 2 TO WS-DRAWS-T(4)
    CALL "Q3-RESERVOIR" USING WS-N WS-DRAWS WS-PICK
    MOVE "acceptance US15 44-3§2.17 UseBonemeal reservoir: the third qualifying cell replaced the choice (draw 0), the fourth did not" TO WS-CASE
    MOVE 3 TO WS-E
    MOVE WS-PICK TO WS-O
    CALL "Q3-EQ" USING WS-CASE WS-E WS-O
    MOVE 0 TO WS-N
    CALL "Q3-RESERVOIR" USING WS-N WS-DRAWS WS-PICK
    MOVE "acceptance US15 44-3§2.17 UseBonemeal reservoir: no qualifying cell: none" TO WS-CASE
    MOVE 0 TO WS-E
    MOVE WS-PICK TO WS-O
    CALL "Q3-EQ" USING WS-CASE WS-E WS-O
    MOVE 1 TO WS-N
    CALL "Q3-RESERVOIR" USING WS-N WS-DRAWS WS-PICK
    MOVE "acceptance US15 44-3§2.17 UseBonemeal reservoir: one cell is chosen with certainty" TO WS-CASE
    MOVE 1 TO WS-E
    MOVE WS-PICK TO WS-O
    CALL "Q3-EQ" USING WS-CASE WS-E WS-O
    MOVE 100 TO WS-NOW
    MOVE 100 TO WS-NEXTCYCLE
    MOVE 1 TO WS-NEAR
    MOVE 5 TO WS-WORKED
    CALL "Q3-BONEMEAL-TICK" USING WS-NOW WS-NEXTCYCLE WS-NEAR WS-WORKED WS-ACT
    MOVE "acceptance US15 44-3§2.17 UseBonemeal tick: on time and at the cell a bone meal is used" TO WS-CASE
    MOVE 1 TO WS-E
    MOVE WS-ACT TO WS-O
    CALL "Q3-EQ" USING WS-CASE WS-E WS-O
    MOVE "acceptance US15 44-3§2.17 UseBonemeal tick: the counter advances" TO WS-CASE
    MOVE 6 TO WS-E
    MOVE WS-WORKED TO WS-O
    CALL "Q3-EQ" USING WS-CASE WS-E WS-O
    MOVE 101 TO WS-NEXTCYCLE
    CALL "Q3-BONEMEAL-TICK" USING WS-NOW WS-NEXTCYCLE WS-NEAR WS-WORKED WS-ACT
    MOVE "acceptance US15 44-3§2.17 UseBonemeal tick: before nextWorkCycleTime: nothing" TO WS-CASE
    MOVE 0 TO WS-E
    MOVE WS-ACT TO WS-O
    CALL "Q3-EQ" USING WS-CASE WS-E WS-O
    MOVE "acceptance US15 44-3§2.17 UseBonemeal tick: and the counter does not advance" TO WS-CASE
    MOVE 6 TO WS-E
    MOVE WS-WORKED TO WS-O
    CALL "Q3-EQ" USING WS-CASE WS-E WS-O
    MOVE 100 TO WS-NEXTCYCLE
    MOVE 0 TO WS-NEAR
    CALL "Q3-BONEMEAL-TICK" USING WS-NOW WS-NEXTCYCLE WS-NEAR WS-WORKED WS-ACT
    MOVE "acceptance US15 44-3§2.17 UseBonemeal tick: away from the cell: nothing" TO WS-CASE
    MOVE 0 TO WS-E
    MOVE WS-ACT TO WS-O
    CALL "Q3-EQ" USING WS-CASE WS-E WS-O
    MOVE 1 TO WS-GREW
    MOVE 0 TO WS-NEXTCYCLE
    CALL "Q3-BONEMEAL-GREW" USING WS-GREW WS-NOW WS-NEXTCYCLE
    MOVE "acceptance US15 44-3§2.17 UseBonemeal: when the crop grew nextWorkCycleTime = now + 40" TO WS-CASE
    MOVE 140 TO WS-E
    MOVE WS-NEXTCYCLE TO WS-O
    CALL "Q3-EQ" USING WS-CASE WS-E WS-O
    MOVE 0 TO WS-GREW
    MOVE 5 TO WS-NEXTCYCLE
    CALL "Q3-BONEMEAL-GREW" USING WS-GREW WS-NOW WS-NEXTCYCLE
    MOVE "acceptance US15 44-3§2.17 UseBonemeal: when nothing grew it is kept" TO WS-CASE
    MOVE 5 TO WS-E
    MOVE WS-NEXTCYCLE TO WS-O
    CALL "Q3-EQ" USING WS-CASE WS-E WS-O
    MOVE 79 TO WS-WORKED
    MOVE 1 TO WS-TARGET
    CALL "Q3-BONEMEAL-CONTINUE" USING WS-WORKED WS-TARGET WS-YES
    MOVE "acceptance US15 44-3§2.17 UseBonemeal continues below 80 ticks with a target" TO WS-CASE
    MOVE 1 TO WS-E
    MOVE WS-YES TO WS-O
    CALL "Q3-EQ" USING WS-CASE WS-E WS-O
    MOVE 80 TO WS-WORKED
    CALL "Q3-BONEMEAL-CONTINUE" USING WS-WORKED WS-TARGET WS-YES
    MOVE "acceptance US15 44-3§2.17 UseBonemeal ends at 80" TO WS-CASE
    MOVE 0 TO WS-E
    MOVE WS-YES TO WS-O
    CALL "Q3-EQ" USING WS-CASE WS-E WS-O
    MOVE 3 TO WS-WORKED
    MOVE 0 TO WS-TARGET
    CALL "Q3-BONEMEAL-CONTINUE" USING WS-WORKED WS-TARGET WS-YES
    MOVE "acceptance US15 44-3§2.17 UseBonemeal ends without a target" TO WS-CASE
    MOVE 0 TO WS-E
    MOVE WS-YES TO WS-O
    CALL "Q3-EQ" USING WS-CASE WS-E WS-O
    MOVE 20 TO WS-INTERVAL
    MOVE 7 TO WS-DRAW
    CALL "Q3-SENSOR-INIT" USING WS-INTERVAL WS-DRAW WS-CDN
    MOVE "acceptance US15 44-3§2.18 randomlyDelayStart: the countdown starts at nextInt(interval)" TO WS-CASE
    MOVE 7 TO WS-E
    MOVE WS-CDN TO WS-O
    CALL "Q3-EQ" USING WS-CASE WS-E WS-O
    MOVE 2 TO WS-CDN
    CALL "Q3-SENSOR-TICK" USING WS-CDN WS-INTERVAL WS-SCAN
    MOVE "acceptance US15 44-3§2.18 the countdown is decremented first: 1 is above 0, no scan" TO WS-CASE
    MOVE 0 TO WS-E
    MOVE WS-SCAN TO WS-O
    CALL "Q3-EQ" USING WS-CASE WS-E WS-O
    CALL "Q3-SENSOR-TICK" USING WS-CDN WS-INTERVAL WS-SCAN
    MOVE "acceptance US15 44-3§2.18 the countdown reaching 0 scans" TO WS-CASE
    MOVE 1 TO WS-E
    MOVE WS-SCAN TO WS-O
    CALL "Q3-EQ" USING WS-CASE WS-E WS-O
    MOVE "acceptance US15 44-3§2.18 and is reset to the interval" TO WS-CASE
    MOVE 20 TO WS-E
    MOVE WS-CDN TO WS-O
    CALL "Q3-EQ" USING WS-CASE WS-E WS-O
    MOVE 0 TO WS-CDN
    CALL "Q3-SENSOR-TICK" USING WS-CDN WS-INTERVAL WS-SCAN
    MOVE "acceptance US15 44-3§2.18 a countdown started at 0 scans on the first tick (-1 is at most 0)" TO WS-CASE
    MOVE 1 TO WS-E
    MOVE WS-SCAN TO WS-O
    CALL "Q3-EQ" USING WS-CASE WS-E WS-O
    MOVE 1 TO WS-FARMER
    MOVE 3 TO WS-COUNT
    CALL "Q3-SECONDARY" USING WS-FARMER WS-COUNT WS-ACTION
    MOVE "acceptance US15 44-3§4.1 secondary_pois: a farmer with farmland stores the list" TO WS-CASE
    MOVE 1 TO WS-E
    MOVE WS-ACTION TO WS-O
    CALL "Q3-EQ" USING WS-CASE WS-E WS-O
    MOVE 0 TO WS-COUNT
    CALL "Q3-SECONDARY" USING WS-FARMER WS-COUNT WS-ACTION
    MOVE "acceptance US15 44-3§4.1 secondary_pois: an empty list erases the memory" TO WS-CASE
    MOVE 0 TO WS-E
    MOVE WS-ACTION TO WS-O
    CALL "Q3-EQ" USING WS-CASE WS-E WS-O
    MOVE 0 TO WS-FARMER
    MOVE 3 TO WS-COUNT
    CALL "Q3-SECONDARY" USING WS-FARMER WS-COUNT WS-ACTION
    MOVE "acceptance US15 44-3§4.1 secondary_pois: other professions have no secondary blocks" TO WS-CASE
    MOVE 0 TO WS-E
    MOVE WS-ACTION TO WS-O
    CALL "Q3-EQ" USING WS-CASE WS-E WS-O
    MOVE 1 TO WS-GOLEM
    CALL "Q3-GOLEM-SENSOR" USING WS-GOLEM WS-SET WS-EXPIRY
    MOVE "acceptance US15 44-3§4.3 golem_detected: an iron golem in the list sets the memory" TO WS-CASE
    MOVE 1 TO WS-E
    MOVE WS-SET TO WS-O
    CALL "Q3-EQ" USING WS-CASE WS-E WS-O
    MOVE "acceptance US15 44-3§4.3 golem_detected: with an expiry of 599 ticks" TO WS-CASE
    MOVE 599 TO WS-E
    MOVE WS-EXPIRY TO WS-O
    CALL "Q3-EQ" USING WS-CASE WS-E WS-O
    MOVE 0 TO WS-GOLEM
    CALL "Q3-GOLEM-SENSOR" USING WS-GOLEM WS-SET WS-EXPIRY
    MOVE "acceptance US15 44-3§4.3 golem_detected: no golem leaves it" TO WS-CASE
    MOVE 0 TO WS-E
    MOVE WS-SET TO WS-O
    CALL "Q3-EQ" USING WS-CASE WS-E WS-O
    MOVE 4 TO WS-N
    MOVE 1 TO WS-VT-T(1)
    MOVE 1 TO WS-BT-T(1)
    MOVE 1 TO WS-VT-T(2)
    MOVE 0 TO WS-BT-T(2)
    MOVE 0 TO WS-VT-T(3)
    MOVE 1 TO WS-BT-T(3)
    MOVE 1 TO WS-VT-T(4)
    MOVE 1 TO WS-BT-T(4)
    CALL "Q3-BABIES" USING WS-N WS-VT WS-BT WS-OT WS-COUNT
    MOVE "acceptance US15 44-3§4.4 visible_villager_babies: villagers that are babies, in list order (2)" TO WS-CASE
    MOVE 2 TO WS-E
    MOVE WS-COUNT TO WS-O
    CALL "Q3-EQ" USING WS-CASE WS-E WS-O
    MOVE "acceptance US15 44-3§4.4 the first is entry 1" TO WS-CASE
    MOVE 1 TO WS-E
    MOVE WS-OT-T(1) TO WS-O
    CALL "Q3-EQ" USING WS-CASE WS-E WS-O
    MOVE "acceptance US15 44-3§4.4 the second is entry 4 (the adult villager and the baby of another type are skipped)" TO WS-CASE
    MOVE 4 TO WS-E
    MOVE WS-OT-T(2) TO WS-O
    CALL "Q3-EQ" USING WS-CASE WS-E WS-O
    MOVE 0 TO WS-N
    CALL "Q3-BABIES" USING WS-N WS-VT WS-BT WS-OT WS-COUNT
    MOVE "acceptance US15 44-3§4.4 an empty list gives an empty list" TO WS-CASE
    MOVE 0 TO WS-E
    MOVE WS-COUNT TO WS-O
    CALL "Q3-EQ" USING WS-CASE WS-E WS-O
    MOVE 0 TO WS-BABY
    MOVE 300 TO WS-NOW
    MOVE 5 TO WS-DRAW
    CALL "Q3-BED-GATE" USING WS-BABY WS-NOW WS-DRAW WS-LASTUPDATE WS-RUN
    MOVE "acceptance US15 44-3§4.5 nearest_bed: adults return at once" TO WS-CASE
    MOVE 0 TO WS-E
    MOVE WS-RUN TO WS-O
    CALL "Q3-EQ" USING WS-CASE WS-E WS-O
    MOVE 1 TO WS-BABY
    CALL "Q3-BED-GATE" USING WS-BABY WS-NOW WS-DRAW WS-LASTUPDATE WS-RUN
    MOVE "acceptance US15 44-3§4.5 nearest_bed: a baby scans" TO WS-CASE
    MOVE 1 TO WS-E
    MOVE WS-RUN TO WS-O
    CALL "Q3-EQ" USING WS-CASE WS-E WS-O
    MOVE "acceptance US15 44-3§4.5 nearest_bed: lastUpdate = gameTime + nextInt(20)" TO WS-CASE
    MOVE 305 TO WS-E
    MOVE WS-LASTUPDATE TO WS-O
    CALL "Q3-EQ" USING WS-CASE WS-E WS-O
    MOVE 1 TO WS-HASDMG
    MOVE 1 TO WS-LIVING
    MOVE 0 TO WS-ENTBAD
    CALL "Q3-HURTBY" USING WS-HASDMG WS-LIVING WS-ENTBAD WS-HURTACT WS-ENTACT
    MOVE "acceptance US15 44-3§4.6 hurt_by: a last damage source is stored" TO WS-CASE
    MOVE 1 TO WS-E
    MOVE WS-HURTACT TO WS-O
    CALL "Q3-EQ" USING WS-CASE WS-E WS-O
    MOVE "acceptance US15 44-3§4.6 hurt_by_entity: a living attacker is stored" TO WS-CASE
    MOVE 1 TO WS-E
    MOVE WS-ENTACT TO WS-O
    CALL "Q3-EQ" USING WS-CASE WS-E WS-O
    MOVE 0 TO WS-LIVING
    CALL "Q3-HURTBY" USING WS-HASDMG WS-LIVING WS-ENTBAD WS-HURTACT WS-ENTACT
    MOVE "acceptance US15 44-3§4.6 hurt_by: a source with no living entity leaves hurt_by_entity alone" TO WS-CASE
    MOVE 0 TO WS-E
    MOVE WS-ENTACT TO WS-O
    CALL "Q3-EQ" USING WS-CASE WS-E WS-O
    MOVE 0 TO WS-HASDMG
    MOVE 0 TO WS-ENTBAD
    CALL "Q3-HURTBY" USING WS-HASDMG WS-LIVING WS-ENTBAD WS-HURTACT WS-ENTACT
    MOVE "acceptance US15 44-3§4.6 hurt_by: no last damage source erases the memory" TO WS-CASE
    MOVE 2 TO WS-E
    MOVE WS-HURTACT TO WS-O
    CALL "Q3-EQ" USING WS-CASE WS-E WS-O
    MOVE 1 TO WS-ENTBAD
    CALL "Q3-HURTBY" USING WS-HASDMG WS-LIVING WS-ENTBAD WS-HURTACT WS-ENTACT
    MOVE "acceptance US15 44-3§4.6 hurt_by_entity: a dead or other-level entity is erased" TO WS-CASE
    MOVE 2 TO WS-E
    MOVE WS-ENTACT TO WS-O
    CALL "Q3-EQ" USING WS-CASE WS-E WS-O
    MOVE 64 TO WS-MAXSTACK
    MOVE 40 TO WS-COUNT
    CALL "Q3-HALF-STACK" USING WS-COUNT WS-MAXSTACK WS-SPLIT
    MOVE "acceptance US15 44-3§3.3 throwHalfStack: above half of a max stack of 64 the split is count / 2" TO WS-CASE
    MOVE 20 TO WS-E
    MOVE WS-SPLIT TO WS-O
    CALL "Q3-EQ" USING WS-CASE WS-E WS-O
    MOVE 32 TO WS-COUNT
    CALL "Q3-HALF-STACK" USING WS-COUNT WS-MAXSTACK WS-SPLIT
    MOVE "acceptance US15 44-3§3.3 throwHalfStack: 32 is not above half of 64 but above 24: split 32 - 24 = 8" TO WS-CASE
    MOVE 8 TO WS-E
    MOVE WS-SPLIT TO WS-O
    CALL "Q3-EQ" USING WS-CASE WS-E WS-O
    MOVE 33 TO WS-COUNT
    CALL "Q3-HALF-STACK" USING WS-COUNT WS-MAXSTACK WS-SPLIT
    MOVE "acceptance US15 44-3§3.3 throwHalfStack: 33 is above 32: split 16" TO WS-CASE
    MOVE 16 TO WS-E
    MOVE WS-SPLIT TO WS-O
    CALL "Q3-EQ" USING WS-CASE WS-E WS-O
    MOVE 16 TO WS-MAXSTACK
    MOVE 12 TO WS-COUNT
    CALL "Q3-HALF-STACK" USING WS-COUNT WS-MAXSTACK WS-SPLIT
    MOVE "acceptance US15 44-3§3.3 throwHalfStack: a stack of 16 max: 12 is above 8, split 6" TO WS-CASE
    MOVE 6 TO WS-E
    MOVE WS-SPLIT TO WS-O
    CALL "Q3-EQ" USING WS-CASE WS-E WS-O
    MOVE 64 TO WS-MAXSTACK
    MOVE 20 TO WS-COUNT
    CALL "Q3-HALF-STACK" USING WS-COUNT WS-MAXSTACK WS-SPLIT
    MOVE "acceptance US15 44-3§3.3 throwHalfStack: 20 is not above 24: skipped" TO WS-CASE
    MOVE 0 TO WS-E
    MOVE WS-SPLIT TO WS-O
    CALL "Q3-EQ" USING WS-CASE WS-E WS-O
    MOVE 100 TO WS-MAXSTACK
    MOVE 40 TO WS-COUNT
    CALL "Q3-HALF-STACK" USING WS-COUNT WS-MAXSTACK WS-SPLIT
    MOVE "acceptance US15 44-3§3.3 throwHalfStack: above 24 but not above half of a larger stack: count - 24 = 16" TO WS-CASE
    MOVE 16 TO WS-E
    MOVE WS-SPLIT TO WS-O
    CALL "Q3-EQ" USING WS-CASE WS-E WS-O
    MOVE 24 TO WS-FOOD
    MOVE 0 TO WS-FARMER
    MOVE 1 TO WS-PARTNER
    MOVE 10 TO WS-WHEAT
    MOVE 0 TO WS-WILLING
    MOVE 0 TO WS-HASITEM
    CALL "Q3-TRADE-THROW" USING WS-FOOD WS-FARMER WS-PARTNER WS-WHEAT WS-WILLING WS-HASITEM WS-A WS-B WS-C
    MOVE "acceptance US15 44-3§3.3 excess food (24 points) goes to a partner that wants food" TO WS-CASE
    MOVE 1 TO WS-E
    MOVE WS-A TO WS-O
    CALL "Q3-EQ" USING WS-CASE WS-E WS-O
    MOVE "acceptance US15 44-3§3.3 no wheat throw for a non-farmer" TO WS-CASE
    MOVE 0 TO WS-E
    MOVE WS-B TO WS-O
    CALL "Q3-EQ" USING WS-CASE WS-E WS-O
    MOVE "acceptance US15 44-3§3.3 nothing willing: no third throw" TO WS-CASE
    MOVE 0 TO WS-E
    MOVE WS-C TO WS-O
    CALL "Q3-EQ" USING WS-CASE WS-E WS-O
    MOVE 0 TO WS-PARTNER
    CALL "Q3-TRADE-THROW" USING WS-FOOD WS-FARMER WS-PARTNER WS-WHEAT WS-WILLING WS-HASITEM WS-A WS-B WS-C
    MOVE "acceptance US15 44-3§3.3 a non-farmer does not throw food at a partner that does not want it" TO WS-CASE
    MOVE 0 TO WS-E
    MOVE WS-A TO WS-O
    CALL "Q3-EQ" USING WS-CASE WS-E WS-O
    MOVE 1 TO WS-FARMER
    MOVE 33 TO WS-WHEAT
    MOVE 23 TO WS-FOOD
    CALL "Q3-TRADE-THROW" USING WS-FOOD WS-FARMER WS-PARTNER WS-WHEAT WS-WILLING WS-HASITEM WS-A WS-B WS-C
    MOVE "acceptance US15 44-3§3.3 under 24 food points: no food throw" TO WS-CASE
    MOVE 0 TO WS-E
    MOVE WS-A TO WS-O
    CALL "Q3-EQ" USING WS-CASE WS-E WS-O
    MOVE "acceptance US15 44-3§3.3 a farmer with more than 32 wheat throws half a stack of wheat" TO WS-CASE
    MOVE 1 TO WS-E
    MOVE WS-B TO WS-O
    CALL "Q3-EQ" USING WS-CASE WS-E WS-O
    MOVE 24 TO WS-FOOD
    MOVE 32 TO WS-WHEAT
    MOVE 1 TO WS-WILLING
    MOVE 1 TO WS-HASITEM
    CALL "Q3-TRADE-THROW" USING WS-FOOD WS-FARMER WS-PARTNER WS-WHEAT WS-WILLING WS-HASITEM WS-A WS-B WS-C
    MOVE "acceptance US15 44-3§3.3 a farmer throws excess food even if the partner does not want it" TO WS-CASE
    MOVE 1 TO WS-E
    MOVE WS-A TO WS-O
    CALL "Q3-EQ" USING WS-CASE WS-E WS-O
    MOVE "acceptance US15 44-3§3.3 32 wheat is not more than half a stack" TO WS-CASE
    MOVE 0 TO WS-E
    MOVE WS-B TO WS-O
    CALL "Q3-EQ" USING WS-CASE WS-E WS-O
    MOVE "acceptance US15 44-3§3.3 the willing-to-trade items that it holds are thrown (all three can happen on one tick)" TO WS-CASE
    MOVE 1 TO WS-E
    MOVE WS-C TO WS-O
    CALL "Q3-EQ" USING WS-CASE WS-E WS-O
    MOVE 0 TO WS-HASITEM
    CALL "Q3-TRADE-THROW" USING WS-FOOD WS-FARMER WS-PARTNER WS-WHEAT WS-WILLING WS-HASITEM WS-A WS-B WS-C
    MOVE "acceptance US15 44-3§3.3 a willing set it holds nothing of: no throw" TO WS-CASE
    MOVE 0 TO WS-E
    MOVE WS-C TO WS-O
    CALL "Q3-EQ" USING WS-CASE WS-E WS-O
    COMPUTE WS-D2 = 5.0
    CALL "Q3-TRADE-NEAR" USING WS-D2 WS-NEAR
    MOVE "acceptance US15 44-3§3.3 TradeWithVillager: at squared distance 5 the exchange runs" TO WS-CASE
    MOVE 1 TO WS-E
    MOVE WS-NEAR TO WS-O
    CALL "Q3-EQ" USING WS-CASE WS-E WS-O
    COMPUTE WS-D2 = 5.5
    CALL "Q3-TRADE-NEAR" USING WS-D2 WS-NEAR
    MOVE "acceptance US15 44-3§3.3 TradeWithVillager: farther than squared 5 does nothing more" TO WS-CASE
    MOVE 0 TO WS-E
    MOVE WS-NEAR TO WS-O
    CALL "Q3-EQ" USING WS-CASE WS-E WS-O
    MOVE 1 TO WS-ALIVE
    MOVE 0 TO WS-BABY
    COMPUTE WS-D2 = 17.0
    CALL "Q3-SHOW-START" USING WS-ALIVE WS-BABY WS-D2 WS-YES
    MOVE "acceptance US15 44-3§3.4 ShowTradesToPlayer: a living adult villager and a player within squared 17" TO WS-CASE
    MOVE 1 TO WS-E
    MOVE WS-YES TO WS-O
    CALL "Q3-EQ" USING WS-CASE WS-E WS-O
    COMPUTE WS-D2 = 18.0
    CALL "Q3-SHOW-START" USING WS-ALIVE WS-BABY WS-D2 WS-YES
    MOVE "acceptance US15 44-3§3.4 ShowTradesToPlayer: beyond squared 17" TO WS-CASE
    MOVE 0 TO WS-E
    MOVE WS-YES TO WS-O
    CALL "Q3-EQ" USING WS-CASE WS-E WS-O
    MOVE 1 TO WS-BABY
    COMPUTE WS-D2 = 4.0
    CALL "Q3-SHOW-START" USING WS-ALIVE WS-BABY WS-D2 WS-YES
    MOVE "acceptance US15 44-3§3.4 ShowTradesToPlayer: not for a baby" TO WS-CASE
    MOVE 0 TO WS-E
    MOVE WS-YES TO WS-O
    CALL "Q3-EQ" USING WS-CASE WS-E WS-O
    MOVE 0 TO WS-BABY
    MOVE 0 TO WS-ALIVE
    CALL "Q3-SHOW-START" USING WS-ALIVE WS-BABY WS-D2 WS-YES
    MOVE "acceptance US15 44-3§3.4 ShowTradesToPlayer: not for a dead villager" TO WS-CASE
    MOVE 0 TO WS-E
    MOVE WS-YES TO WS-O
    CALL "Q3-EQ" USING WS-CASE WS-E WS-O
    MOVE 1 TO WS-DIFFERS
    MOVE 1 TO WS-MATCHES
    MOVE 3 TO WS-LOOKTIME
    CALL "Q3-SHOW-LOOK" USING WS-DIFFERS WS-MATCHES WS-LOOKTIME WS-DISPLAY
    MOVE "acceptance US15 44-3§3.4 the player holds another item and an offer takes it: the result is shown" TO WS-CASE
    MOVE 1 TO WS-E
    MOVE WS-DISPLAY TO WS-O
    CALL "Q3-EQ" USING WS-CASE WS-E WS-O
    MOVE "acceptance US15 44-3§3.4 and the look time is 900" TO WS-CASE
    MOVE 900 TO WS-E
    MOVE WS-LOOKTIME TO WS-O
    CALL "Q3-EQ" USING WS-CASE WS-E WS-O
    MOVE 0 TO WS-MATCHES
    CALL "Q3-SHOW-LOOK" USING WS-DIFFERS WS-MATCHES WS-LOOKTIME WS-DISPLAY
    MOVE "acceptance US15 44-3§3.4 no offer takes the held item: the display is cleared" TO WS-CASE
    MOVE 0 TO WS-E
    MOVE WS-DISPLAY TO WS-O
    CALL "Q3-EQ" USING WS-CASE WS-E WS-O
    MOVE 0 TO WS-DIFFERS
    MOVE 3 TO WS-LOOKTIME
    CALL "Q3-SHOW-LOOK" USING WS-DIFFERS WS-MATCHES WS-LOOKTIME WS-DISPLAY
    MOVE "acceptance US15 44-3§3.4 the same item: nothing changes" TO WS-CASE
    MOVE 2 TO WS-E
    MOVE WS-DISPLAY TO WS-O
    CALL "Q3-EQ" USING WS-CASE WS-E WS-O
    MOVE "acceptance US15 44-3§3.4 and the look time is kept" TO WS-CASE
    MOVE 3 TO WS-E
    MOVE WS-LOOKTIME TO WS-O
    CALL "Q3-EQ" USING WS-CASE WS-E WS-O
    MOVE 3 TO WS-N
    MOVE 0 TO WS-IDX
    MOVE 38 TO WS-TIMER
    CALL "Q3-SHOW-CYCLE" USING WS-N WS-IDX WS-TIMER
    MOVE "acceptance US15 44-3§3.4 with several entries the display cycles every 40 ticks: timer 39" TO WS-CASE
    MOVE 39 TO WS-E
    MOVE WS-TIMER TO WS-O
    CALL "Q3-EQ" USING WS-CASE WS-E WS-O
    MOVE "acceptance US15 44-3§3.4 not yet the next entry" TO WS-CASE
    MOVE 0 TO WS-E
    MOVE WS-IDX TO WS-O
    CALL "Q3-EQ" USING WS-CASE WS-E WS-O
    CALL "Q3-SHOW-CYCLE" USING WS-N WS-IDX WS-TIMER
    MOVE "acceptance US15 44-3§3.4 the 40th tick shows the next entry" TO WS-CASE
    MOVE 1 TO WS-E
    MOVE WS-IDX TO WS-O
    CALL "Q3-EQ" USING WS-CASE WS-E WS-O
    MOVE "acceptance US15 44-3§3.4 and restarts the timer" TO WS-CASE
    MOVE 0 TO WS-E
    MOVE WS-TIMER TO WS-O
    CALL "Q3-EQ" USING WS-CASE WS-E WS-O
    MOVE 2 TO WS-IDX
    MOVE 39 TO WS-TIMER
    CALL "Q3-SHOW-CYCLE" USING WS-N WS-IDX WS-TIMER
    MOVE "acceptance US15 44-3§3.4 after the last entry the list starts over" TO WS-CASE
    MOVE 0 TO WS-E
    MOVE WS-IDX TO WS-O
    CALL "Q3-EQ" USING WS-CASE WS-E WS-O
    MOVE 1 TO WS-N
    MOVE 0 TO WS-IDX
    MOVE 39 TO WS-TIMER
    CALL "Q3-SHOW-CYCLE" USING WS-N WS-IDX WS-TIMER
    MOVE "acceptance US15 44-3§3.4 one entry does not cycle" TO WS-CASE
    MOVE 0 TO WS-E
    MOVE WS-IDX TO WS-O
    CALL "Q3-EQ" USING WS-CASE WS-E WS-O
    MOVE 1 TO WS-TRADING
    MOVE 1 TO WS-ALIVE
    MOVE 0 TO WS-WATER
    MOVE 0 TO WS-HURT
    COMPUTE WS-D2 = 16.0
    CALL "Q3-TRADE-SINK" USING WS-TRADING WS-ALIVE WS-WATER WS-HURT WS-D2 WS-ACTIVE
    MOVE "acceptance US15 44-3§3.4 LookAndFollowTradingPlayerSink: a trading player within squared 16" TO WS-CASE
    MOVE 1 TO WS-E
    MOVE WS-ACTIVE TO WS-O
    CALL "Q3-EQ" USING WS-CASE WS-E WS-O
    COMPUTE WS-D2 = 17.0
    CALL "Q3-TRADE-SINK" USING WS-TRADING WS-ALIVE WS-WATER WS-HURT WS-D2 WS-ACTIVE
    MOVE "acceptance US15 44-3§3.4 LookAndFollowTradingPlayerSink: beyond 4 blocks" TO WS-CASE
    MOVE 0 TO WS-E
    MOVE WS-ACTIVE TO WS-O
    CALL "Q3-EQ" USING WS-CASE WS-E WS-O
    COMPUTE WS-D2 = 4.0
    MOVE 1 TO WS-WATER
    CALL "Q3-TRADE-SINK" USING WS-TRADING WS-ALIVE WS-WATER WS-HURT WS-D2 WS-ACTIVE
    MOVE "acceptance US15 44-3§3.4 LookAndFollowTradingPlayerSink: not in water" TO WS-CASE
    MOVE 0 TO WS-E
    MOVE WS-ACTIVE TO WS-O
    CALL "Q3-EQ" USING WS-CASE WS-E WS-O
    MOVE 0 TO WS-WATER
    MOVE 1 TO WS-HURT
    CALL "Q3-TRADE-SINK" USING WS-TRADING WS-ALIVE WS-WATER WS-HURT WS-D2 WS-ACTIVE
    MOVE "acceptance US15 44-3§3.4 LookAndFollowTradingPlayerSink: not hurt recently" TO WS-CASE
    MOVE 0 TO WS-E
    MOVE WS-ACTIVE TO WS-O
    CALL "Q3-EQ" USING WS-CASE WS-E WS-O
    MOVE 0 TO WS-HURT
    MOVE 0 TO WS-TRADING
    CALL "Q3-TRADE-SINK" USING WS-TRADING WS-ALIVE WS-WATER WS-HURT WS-D2 WS-ACTIVE
    MOVE "acceptance US15 44-3§3.4 LookAndFollowTradingPlayerSink: no trading player" TO WS-CASE
    MOVE 0 TO WS-E
    MOVE WS-ACTIVE TO WS-O
    CALL "Q3-EQ" USING WS-CASE WS-E WS-O
    MOVE 1 TO WS-TRADING
    MOVE 0 TO WS-ALIVE
    CALL "Q3-TRADE-SINK" USING WS-TRADING WS-ALIVE WS-WATER WS-HURT WS-D2 WS-ACTIVE
    MOVE "acceptance US15 44-3§3.4 LookAndFollowTradingPlayerSink: not for a dead villager" TO WS-CASE
    MOVE 0 TO WS-E
    MOVE WS-ACTIVE TO WS-O
    CALL "Q3-EQ" USING WS-CASE WS-E WS-O
    MOVE 0 TO WS-LASTDAY
    MOVE 0 TO WS-DAY
    CALL "Q3-RESTOCK-DAY" USING WS-LASTDAY WS-DAY WS-CHANGED
    MOVE "acceptance US15 44-3§3.2 the restock check day starts at 0: day 0 is not a change" TO WS-CASE
    MOVE 0 TO WS-E
    MOVE WS-CHANGED TO WS-O
    CALL "Q3-EQ" USING WS-CASE WS-E WS-O
    MOVE 7 TO WS-DAY
    CALL "Q3-RESTOCK-DAY" USING WS-LASTDAY WS-DAY WS-CHANGED
    MOVE "acceptance US15 44-3§3.2 after a load the first check at day 7 sees a changed day" TO WS-CASE
    MOVE 1 TO WS-E
    MOVE WS-CHANGED TO WS-O
    CALL "Q3-EQ" USING WS-CASE WS-E WS-O
     STOP RUN.
 END PROGRAM TEST-Q44-44-3-5.
 COPY Q3TEST.
