*> The villager brain memory store (docs/protocol/18 section 4.5 and 44 part 3 sections 2 and 4; core/src/mob-vil-mem.cob; lane 002-lane-p49p), EXTERNAL, one entry per VL-ENTRY slot of VILSTATE.cpy
*> (the same index; VL-FIND hands out the slot, VM-CLEAR runs when a slot is made or released). A memory is a type id (the MT- constants), a global position (VM-DIM, VM-X, VM-Y, VM-Z), two numbers
*> (VM-NUM, VM-NUM2: a game tick, an entity id, a speed in thousandths...) and the tick it expires (VM-EXP, 0 = never; an expired memory is erased when it is read, so nothing counts them down).
*> The claimed points of interest (home, job_site, potential_job_site, meeting_point) stay in the claim table of VILPOI.cpy, which holds their tickets: the types MT-HOME to MT-MEETING-POINT are
*> read and written through it by VM-GET, VM-PUT and VM-ERASE, so a behaviour sees one memory model.
*> VM-ACT is the active activity (the VA- constants; 0 idle, 1 work, 2 meet, 3 rest, 4 play are the schedule's values of VIL-DAY-ACT, 5 panic, 6 pre_raid, 7 raid, 8 hide); VM-T holds the timers
*> and counters of the behaviour instances (the TM- constants): the next scan of AcquirePoi, the sensors' countdowns (2.18), WorkAtPoi's last check, the hiding counter and the like.
 78 VM-MAX                VALUE 256.
 78 VM-TYPES              VALUE 24.
 78 VM-TIMERS             VALUE 64.
 78 MT-WALK-TARGET        VALUE 1.
 78 MT-HIDING-PLACE       VALUE 2.
 78 MT-HEARD-BELL-TIME    VALUE 3.
 78 MT-LAST-WORKED        VALUE 4.
 78 MT-HURT-BY            VALUE 5.
 78 MT-NEAREST-HOSTILE    VALUE 6.
 78 MT-CANT-REACH-SINCE   VALUE 7.
 78 MT-SECONDARY-JOB-SITE VALUE 8.
 78 MT-NEAREST-BED        VALUE 9.
 78 MT-GOLEM-DETECTED     VALUE 10.
 78 MT-INTERACTION-TARGET VALUE 11.
 78 MT-VISIBLE-BABIES     VALUE 12.
 78 MT-HURT-BY-ENTITY     VALUE 13.
 78 MT-HOME               VALUE 20.
 78 MT-JOB-SITE           VALUE 21.
 78 MT-POTENTIAL-JOB-SITE VALUE 22.
 78 MT-MEETING-POINT      VALUE 23.
 78 VA-IDLE              VALUE 0.
 78 VA-WORK              VALUE 1.
 78 VA-MEET              VALUE 2.
 78 VA-REST              VALUE 3.
 78 VA-PLAY              VALUE 4.
 78 VA-PANIC             VALUE 5.
 78 VA-PRE-RAID          VALUE 6.
 78 VA-RAID              VALUE 7.
 78 VA-HIDE              VALUE 8.
 78 TM-ACQ-JOB            VALUE 1.
 78 TM-ACQ-HOME           VALUE 2.
 78 TM-ACQ-MEET           VALUE 3.
 78 TM-WORK-CHECK         VALUE 4.
 78 TM-STROLL-POI         VALUE 5.
 78 TM-STROLL-LIST        VALUE 6.
 78 TM-HOME-LAST          VALUE 7.
 78 TM-HIDE-COUNT         VALUE 8.
 78 TM-SENS-HURT          VALUE 9.
 78 TM-SENS-HOSTILE       VALUE 10.
 78 TM-SENS-GOLEM         VALUE 11.
 78 TM-SENS-SECONDARY     VALUE 12.
 78 TM-SENS-BED           VALUE 13.
 78 TM-SENS-BABIES        VALUE 14.
 78 TM-SENS-INIT          VALUE 15.
 78 TM-SLEEP-OK           VALUE 16.
 78 TM-HARVEST-OK         VALUE 17.
 78 TM-HARVEST-WORKED     VALUE 18.
 78 TM-BONE-LAST          VALUE 19.
 78 TM-BONE-NEXT          VALUE 20.
 78 TM-BONE-WORKED        VALUE 21.
 78 TM-SEEDS              VALUE 22.
 78 TM-WHEAT              VALUE 23.
 78 TM-BREAD              VALUE 24.
 78 TM-BONEMEAL           VALUE 25.
 78 TM-RESTOCK-DAY        VALUE 26.
 78 TM-CELL-X             VALUE 27.
 78 TM-CELL-Y             VALUE 28.
 78 TM-CELL-Z             VALUE 29.
 78 TM-CELL-ON            VALUE 30.
 78 TM-WALK-SINCE         VALUE 31.
 78 TM-RING-NEXT          VALUE 32.
 78 TM-POT-START          VALUE 33.
 78 TM-ACQ-DELAY-JOB      VALUE 34.
 78 TM-ACQ-DELAY-HOME     VALUE 35.
 78 TM-ACQ-DELAY-MEET     VALUE 36.
 78 TM-ACQ-PREV-JOB       VALUE 37.
 78 TM-ACQ-PREV-HOME      VALUE 38.
 78 TM-ACQ-PREV-MEET      VALUE 39.
 78 TM-STAY-HIDDEN        VALUE 40.
 78 TM-ROSTER-SEEN        VALUE 41.
 78 TM-HURT-TICK          VALUE 42.
 78 TM-HURT-ID            VALUE 43.
 78 TM-HIDDEN-ON          VALUE 44.
 78 TM-CARROT             VALUE 45.
 78 TM-POTATO             VALUE 46.
 78 TM-BEET-SEEDS         VALUE 47.
 78 TM-BEETROOT           VALUE 48.
 78 TM-FARM-MODE          VALUE 49.
 78 TM-JUMP-ON            VALUE 50.
 78 TM-JUMP-BUDGET        VALUE 51.
 78 TM-JUMP-LEFT          VALUE 52.
 78 TM-JUMP-COOL          VALUE 53.
 01 VM-STATE EXTERNAL.
    05 VM-V                  OCCURS 256 TIMES.
       10 VM-ACT             BINARY-LONG.
       10 VM-M               OCCURS 24 TIMES.
          15 VM-SET          BINARY-LONG.
          15 VM-DIM          BINARY-LONG.
          15 VM-X            BINARY-LONG.
          15 VM-Y            BINARY-LONG.
          15 VM-Z            BINARY-LONG.
          15 VM-NUM          BINARY-LONG.
          15 VM-NUM2         BINARY-LONG.
          15 VM-EXP          BINARY-LONG.
       10 VM-T               BINARY-LONG OCCURS 64 TIMES.
