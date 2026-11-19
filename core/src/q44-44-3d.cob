*> Villager brain: bell, raid, celebration, panic, door and play behaviours (docs/protocol/44-residual-mob-questions-3-villagers-poi-raids.md sections 2.11 to 2.15, 5; lane
*> 002-lane-p49h, T22004). Pure decision units like q44-44-3b.cob. A flag is 1 or 0; distances are squared, FLOAT-LONG; the bell state is four BINARY-LONG fields in a group
*> (shaking, ticks, resonating, resonation ticks).
*>   Q3-REACT-BELL USING heard bell, raid at position, hide out                                           ReactToBell
*>   Q3-RING-BELL USING meeting point present, roll (FLOAT-LONG), within 3, is a bell, ring out           RingBell
*>   Q3-SOCIALIZE USING draw (nextInt(100)), same dimension, within 4, villager in list, closest found, its squared distance, start out, speed out, closeness out   SocializeAtBell
*>   Q3-BELL-RING USING bell state, block event (1) or hit (0)                                              BellBlockEntity ring and onHit
*>   Q3-BELL-TICK USING bell state, raiders nearby, event out (0 none, 1 resonance starts, 2 the end action runs)
*>   Q3-BELL-RANGE USING squared distance, radius, yes out                                                 closerToCenterThan(entity, radius)
*>   Q3-BELL-REFRESH USING game time, last refresh, has list, refresh out
*>   Q3-RAID-STATUS USING draw (nextInt(20)), raid at position, started, between waves, activity out (0 none, 1 PRE_RAID, 2 RAID)   SetRaidStatus
*>   Q3-RAID-RESET USING draw (nextInt(20)), raid at position, stopped, loss, reset out                      ResetRaidStatus
*>   Q3-BETWEEN-WAVES USING groups spawned, raiders alive, cooldown, yes out                                 Raid.isBetweenWaves
*>   Q3-CELEBRATE-START USING raid, victory, no blocks above, yes out; Q3-CELEBRATE-CONTINUE USING raid, stopped, yes out
*>   Q3-CELEBRATE-GATE USING draw (nextInt(100)), draw (nextInt(200)), open sky, sound out, rocket out
*>   Q3-PANIC-RUN USING hurt by, nearest hostile, yes out; Q3-PANIC-START USING panic active, erase out; Q3-PANIC-GOLEM USING game time, yes out
*>   Q3-CALM USING hurt by, hurt by entity, nearest hostile, hostile squared distance, scared out             VillagerCalmDown
*>   Q3-DOOR-GATE USING path running, same next node, countdown (in/out), proceed out; Q3-DOOR-OPEN USING path running, previous is door, next is door, node differs, closed, open out
*>   Q3-DOOR-KEEP USING too far or other dimension, still a door, closed, other mobs coming, action out (0 keep, 1 drop, 2 close and drop)
*>   Q3-TAG-GATE USING draw (nextInt(10)), friend chasing me, mode out (0 nothing, 1 flee, 2 chase); Q3-TAG-FLEE USING attempts, village table (10), pick out
*>   Q3-TAG-PICK USING babies, target table (8: the baby each one chases, 0 none), pick out, mode out (1 someone being chased, 2 any, 0 none)
*>   Q3-INTERACT-PICK USING entities, squared distance table (4), qualifies table (4), range squared, pick out                      InteractWith

 IDENTIFICATION DIVISION.
 PROGRAM-ID. Q3-REACT-BELL.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-HEARD                 BINARY-LONG.
 01 L-RAID                  BINARY-LONG.
 01 L-HIDE                  BINARY-LONG.
 PROCEDURE DIVISION USING L-HEARD L-RAID L-HIDE.
     MOVE 0 TO L-HIDE
     IF L-HEARD = 1 AND L-RAID = 0
         MOVE 1 TO L-HIDE
     END-IF
     GOBACK.
 END PROGRAM Q3-REACT-BELL.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. Q3-RING-BELL.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-LIMIT                FLOAT-LONG VALUE 0.95.
 LINKAGE SECTION.
 01 L-MEET                  BINARY-LONG.
 01 L-ROLL                  FLOAT-LONG.
 01 L-WITHIN                BINARY-LONG.
 01 L-BELL                  BINARY-LONG.
 01 L-RING                  BINARY-LONG.
 PROCEDURE DIVISION USING L-MEET L-ROLL L-WITHIN L-BELL L-RING.
     MOVE 0 TO L-RING
     IF L-MEET = 1 AND L-ROLL > WS-LIMIT AND L-WITHIN = 1 AND L-BELL = 1
         MOVE 1 TO L-RING
     END-IF
     GOBACK.
 END PROGRAM Q3-RING-BELL.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. Q3-SOCIALIZE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-LIMIT                FLOAT-LONG VALUE 32.0.
 LINKAGE SECTION.
 01 L-DRAW                  BINARY-LONG.
 01 L-SAME                  BINARY-LONG.
 01 L-NEAR                  BINARY-LONG.
 01 L-HASVIL                BINARY-LONG.
 01 L-FOUND                 BINARY-LONG.
 01 L-D2                    FLOAT-LONG.
 01 L-START                 BINARY-LONG.
 01 L-SPEED                 FLOAT-LONG.
 01 L-CLOSE                 BINARY-LONG.
 PROCEDURE DIVISION USING L-DRAW L-SAME L-NEAR L-HASVIL L-FOUND L-D2 L-START L-SPEED L-CLOSE.
     MOVE 0 TO L-START
     MOVE 0.3 TO L-SPEED
     MOVE 1 TO L-CLOSE
     IF L-DRAW = 0 AND L-SAME = 1 AND L-NEAR = 1 AND L-HASVIL = 1 AND L-FOUND = 1
         IF L-D2 <= WS-LIMIT
             MOVE 1 TO L-START
         END-IF
     END-IF
     GOBACK.
 END PROGRAM Q3-SOCIALIZE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. Q3-BELL-RING.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-BELL.
    05 L-SHAKING            BINARY-LONG.
    05 L-TICKS              BINARY-LONG.
    05 L-RESONATING         BINARY-LONG.
    05 L-RESONATION         BINARY-LONG.
 01 L-EVENT                 BINARY-LONG.
 PROCEDURE DIVISION USING L-BELL L-EVENT.
*>   A hit on a bell that is already shaking only resets ticks; every other ring starts the shaking afresh.
     IF L-EVENT = 0 AND L-SHAKING = 1
         MOVE 0 TO L-TICKS
     ELSE
         MOVE 1 TO L-SHAKING
         MOVE 0 TO L-TICKS L-RESONATION
     END-IF
     GOBACK.
 END PROGRAM Q3-BELL-RING.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. Q3-BELL-TICK.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-BELL.
    05 L-SHAKING            BINARY-LONG.
    05 L-TICKS              BINARY-LONG.
    05 L-RESONATING         BINARY-LONG.
    05 L-RESONATION         BINARY-LONG.
 01 L-RAIDERS               BINARY-LONG.
 01 L-EVENT                 BINARY-LONG.
 PROCEDURE DIVISION USING L-BELL L-RAIDERS L-EVENT.
     MOVE 0 TO L-EVENT
*>   (2) shaking: ticks counts up and the shaking ends at 50.
     IF L-SHAKING = 1
         ADD 1 TO L-TICKS
         IF L-TICKS >= 50
             MOVE 0 TO L-SHAKING L-TICKS
         END-IF
     END-IF
*>   (3) resonance starts at ticks 5 with raiders near; (4) it counts to 40, then the end action runs once.
     IF L-TICKS >= 5 AND L-RESONATION = 0 AND L-RAIDERS = 1
         MOVE 1 TO L-RESONATING
         MOVE 1 TO L-EVENT
     END-IF
     IF L-RESONATING = 1
         IF L-RESONATION < 40
             ADD 1 TO L-RESONATION
         ELSE
             MOVE 0 TO L-RESONATING
             MOVE 2 TO L-EVENT
         END-IF
     END-IF
     GOBACK.
 END PROGRAM Q3-BELL-TICK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. Q3-BELL-RANGE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-LIMIT                FLOAT-LONG.
 LINKAGE SECTION.
 01 L-D2                    FLOAT-LONG.
 01 L-RADIUS                BINARY-LONG.
 01 L-YES                   BINARY-LONG.
 PROCEDURE DIVISION USING L-D2 L-RADIUS L-YES.
     COMPUTE WS-LIMIT = L-RADIUS * L-RADIUS
     MOVE 0 TO L-YES
     IF L-D2 < WS-LIMIT
         MOVE 1 TO L-YES
     END-IF
     GOBACK.
 END PROGRAM Q3-BELL-RANGE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. Q3-BELL-REFRESH.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-NOW                   BINARY-LONG.
 01 L-LAST                  BINARY-LONG.
 01 L-HASLIST               BINARY-LONG.
 01 L-REFRESH               BINARY-LONG.
 PROCEDURE DIVISION USING L-NOW L-LAST L-HASLIST L-REFRESH.
     MOVE 0 TO L-REFRESH
     IF L-HASLIST = 0 OR L-NOW > L-LAST + 60
         MOVE 1 TO L-REFRESH
     END-IF
     GOBACK.
 END PROGRAM Q3-BELL-REFRESH.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. Q3-RAID-STATUS.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-DRAW                  BINARY-LONG.
 01 L-RAID                  BINARY-LONG.
 01 L-STARTED               BINARY-LONG.
 01 L-BETWEEN               BINARY-LONG.
 01 L-ACTIVITY              BINARY-LONG.
 PROCEDURE DIVISION USING L-DRAW L-RAID L-STARTED L-BETWEEN L-ACTIVITY.
     MOVE 0 TO L-ACTIVITY
     IF L-DRAW = 0 AND L-RAID = 1
         IF L-STARTED = 0 OR L-BETWEEN = 1
             MOVE 1 TO L-ACTIVITY
         ELSE
             MOVE 2 TO L-ACTIVITY
         END-IF
     END-IF
     GOBACK.
 END PROGRAM Q3-RAID-STATUS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. Q3-RAID-RESET.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-DRAW                  BINARY-LONG.
 01 L-RAID                  BINARY-LONG.
 01 L-STOPPED               BINARY-LONG.
 01 L-LOSS                  BINARY-LONG.
 01 L-RESET                 BINARY-LONG.
 PROCEDURE DIVISION USING L-DRAW L-RAID L-STOPPED L-LOSS L-RESET.
     MOVE 0 TO L-RESET
     IF L-DRAW = 0 AND (L-RAID = 0 OR L-STOPPED = 1 OR L-LOSS = 1)
         MOVE 1 TO L-RESET
     END-IF
     GOBACK.
 END PROGRAM Q3-RAID-RESET.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. Q3-BETWEEN-WAVES.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-GROUPS                BINARY-LONG.
 01 L-ALIVE                 BINARY-LONG.
 01 L-COOLDOWN              BINARY-LONG.
 01 L-YES                   BINARY-LONG.
 PROCEDURE DIVISION USING L-GROUPS L-ALIVE L-COOLDOWN L-YES.
     MOVE 0 TO L-YES
     IF L-GROUPS > 0 AND L-ALIVE = 0 AND L-COOLDOWN > 0
         MOVE 1 TO L-YES
     END-IF
     GOBACK.
 END PROGRAM Q3-BETWEEN-WAVES.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. Q3-CELEBRATE-START.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-RAID                  BINARY-LONG.
 01 L-VICTORY               BINARY-LONG.
 01 L-OPEN                  BINARY-LONG.
 01 L-YES                   BINARY-LONG.
 PROCEDURE DIVISION USING L-RAID L-VICTORY L-OPEN L-YES.
     MOVE 0 TO L-YES
     IF L-RAID = 1 AND L-VICTORY = 1 AND L-OPEN = 1
         MOVE 1 TO L-YES
     END-IF
     GOBACK.
 END PROGRAM Q3-CELEBRATE-START.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. Q3-CELEBRATE-CONTINUE.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-RAID                  BINARY-LONG.
 01 L-STOPPED               BINARY-LONG.
 01 L-YES                   BINARY-LONG.
 PROCEDURE DIVISION USING L-RAID L-STOPPED L-YES.
     MOVE 0 TO L-YES
     IF L-RAID = 1 AND L-STOPPED = 0
         MOVE 1 TO L-YES
     END-IF
     GOBACK.
 END PROGRAM Q3-CELEBRATE-CONTINUE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. Q3-CELEBRATE-GATE.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-D100                  BINARY-LONG.
 01 L-D200                  BINARY-LONG.
 01 L-SKY                   BINARY-LONG.
 01 L-SOUND                 BINARY-LONG.
 01 L-ROCKET                BINARY-LONG.
 PROCEDURE DIVISION USING L-D100 L-D200 L-SKY L-SOUND L-ROCKET.
     MOVE 0 TO L-SOUND L-ROCKET
     IF L-D100 = 0
         MOVE 1 TO L-SOUND
     END-IF
     IF L-D200 = 0 AND L-SKY = 1
         MOVE 1 TO L-ROCKET
     END-IF
     GOBACK.
 END PROGRAM Q3-CELEBRATE-GATE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. Q3-PANIC-RUN.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-HURT                  BINARY-LONG.
 01 L-HOSTILE               BINARY-LONG.
 01 L-YES                   BINARY-LONG.
 PROCEDURE DIVISION USING L-HURT L-HOSTILE L-YES.
     MOVE 0 TO L-YES
     IF L-HURT = 1 OR L-HOSTILE = 1
         MOVE 1 TO L-YES
     END-IF
     GOBACK.
 END PROGRAM Q3-PANIC-RUN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. Q3-PANIC-START.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-ACTIVE                BINARY-LONG.
 01 L-ERASE                 BINARY-LONG.
 PROCEDURE DIVISION USING L-ACTIVE L-ERASE.
     MOVE 0 TO L-ERASE
     IF L-ACTIVE = 0
         MOVE 1 TO L-ERASE
     END-IF
     GOBACK.
 END PROGRAM Q3-PANIC-START.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. Q3-PANIC-GOLEM.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-NOW                   BINARY-LONG.
 01 L-YES                   BINARY-LONG.
 PROCEDURE DIVISION USING L-NOW L-YES.
     MOVE 0 TO L-YES
     IF FUNCTION MOD(L-NOW, 100) = 0
         MOVE 1 TO L-YES
     END-IF
     GOBACK.
 END PROGRAM Q3-PANIC-GOLEM.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. Q3-CALM.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-LIMIT                FLOAT-LONG VALUE 36.0.
 LINKAGE SECTION.
 01 L-HURT                  BINARY-LONG.
 01 L-HENT                  BINARY-LONG.
 01 L-HOSTILE               BINARY-LONG.
 01 L-D2                    FLOAT-LONG.
 01 L-SCARED                BINARY-LONG.
 PROCEDURE DIVISION USING L-HURT L-HENT L-HOSTILE L-D2 L-SCARED.
     MOVE 0 TO L-SCARED
     IF L-HURT = 1 OR L-HENT = 1
         MOVE 1 TO L-SCARED
     END-IF
     IF L-HOSTILE = 1 AND L-D2 <= WS-LIMIT
         MOVE 1 TO L-SCARED
     END-IF
     GOBACK.
 END PROGRAM Q3-CALM.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. Q3-DOOR-GATE.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-ACTIVE                BINARY-LONG.
 01 L-SAME                  BINARY-LONG.
 01 L-COUNTDOWN             BINARY-LONG.
 01 L-PROCEED               BINARY-LONG.
 PROCEDURE DIVISION USING L-ACTIVE L-SAME L-COUNTDOWN L-PROCEED.
*>   The countdown is a hold-off: the same next node resets it to 20 and proceeds, a different one decrements it and proceeds only once it is 0 or below.
     MOVE 0 TO L-PROCEED
     IF L-ACTIVE = 1
         IF L-SAME = 1
             MOVE 20 TO L-COUNTDOWN
             MOVE 1 TO L-PROCEED
         ELSE
             SUBTRACT 1 FROM L-COUNTDOWN
             IF L-COUNTDOWN <= 0
                 MOVE 1 TO L-PROCEED
             END-IF
         END-IF
     END-IF
     GOBACK.
 END PROGRAM Q3-DOOR-GATE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. Q3-DOOR-OPEN.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-ACTIVE                BINARY-LONG.
 01 L-PREV                  BINARY-LONG.
 01 L-NEXT                  BINARY-LONG.
 01 L-DIFFERS               BINARY-LONG.
 01 L-CLOSED                BINARY-LONG.
 01 L-OPEN                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ACTIVE L-PREV L-NEXT L-DIFFERS L-CLOSED L-OPEN.
     MOVE 0 TO L-OPEN
     IF L-ACTIVE = 1 AND L-DIFFERS = 1 AND L-PREV = 1 AND L-NEXT = 1 AND L-CLOSED = 1
         MOVE 1 TO L-OPEN
     END-IF
     GOBACK.
 END PROGRAM Q3-DOOR-OPEN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. Q3-DOOR-KEEP.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-FAR                   BINARY-LONG.
 01 L-ISDOOR                BINARY-LONG.
 01 L-CLOSED                BINARY-LONG.
 01 L-OTHERS                BINARY-LONG.
 01 L-ACTION                BINARY-LONG.
 PROCEDURE DIVISION USING L-FAR L-ISDOOR L-CLOSED L-OTHERS L-ACTION.
     EVALUATE TRUE
         WHEN L-FAR = 1 OR L-ISDOOR = 0 OR L-CLOSED = 1
             MOVE 1 TO L-ACTION
         WHEN L-OTHERS = 1
             MOVE 0 TO L-ACTION
         WHEN OTHER
             MOVE 2 TO L-ACTION
     END-EVALUATE
     GOBACK.
 END PROGRAM Q3-DOOR-KEEP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. Q3-TAG-GATE.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-DRAW                  BINARY-LONG.
 01 L-CHASING               BINARY-LONG.
 01 L-MODE                  BINARY-LONG.
 PROCEDURE DIVISION USING L-DRAW L-CHASING L-MODE.
     EVALUATE TRUE
         WHEN L-DRAW NOT = 0
             MOVE 0 TO L-MODE
         WHEN L-CHASING = 1
             MOVE 1 TO L-MODE
         WHEN OTHER
             MOVE 2 TO L-MODE
     END-EVALUATE
     GOBACK.
 END PROGRAM Q3-TAG-GATE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. Q3-TAG-FLEE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-I                    BINARY-LONG.
 LINKAGE SECTION.
 01 L-ATTEMPTS              BINARY-LONG.
 01 L-VILLAGE-TABLE.
    05 L-VILLAGE            BINARY-LONG OCCURS 10 TIMES.
 01 L-PICK                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ATTEMPTS L-VILLAGE-TABLE L-PICK.
     MOVE 0 TO L-PICK
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > L-ATTEMPTS OR L-PICK > 0
         IF L-VILLAGE(WS-I) = 1
             MOVE WS-I TO L-PICK
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM Q3-TAG-FLEE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. Q3-TAG-PICK.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-I                    BINARY-LONG.
 01 WS-J                    BINARY-LONG.
 01 WS-COUNT                BINARY-LONG.
 01 WS-BEST                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-BABIES                BINARY-LONG.
 01 L-TARGET-TABLE.
    05 L-TARGET             BINARY-LONG OCCURS 8 TIMES.
 01 L-PICK                  BINARY-LONG.
 01 L-MODE                  BINARY-LONG.
 PROCEDURE DIVISION USING L-BABIES L-TARGET-TABLE L-PICK L-MODE.
*>   The chasers of each baby are the other babies that have it as their interaction target; the entries with 1 to 5 chasers are sorted ascending (the first of equals stays first).
     MOVE 0 TO L-PICK L-MODE
     IF L-BABIES = 0
         GOBACK
     END-IF
     MOVE 6 TO WS-BEST
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > L-BABIES
         MOVE 0 TO WS-COUNT
         PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > L-BABIES
             IF WS-J NOT = WS-I AND L-TARGET(WS-J) = WS-I
                 ADD 1 TO WS-COUNT
             END-IF
         END-PERFORM
         IF WS-COUNT > 0 AND WS-COUNT < WS-BEST
             MOVE WS-COUNT TO WS-BEST
             MOVE WS-I TO L-PICK
             MOVE 1 TO L-MODE
         END-IF
     END-PERFORM
     IF L-MODE = 0
         MOVE 1 TO L-PICK
         MOVE 2 TO L-MODE
     END-IF
     GOBACK.
 END PROGRAM Q3-TAG-PICK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. Q3-INTERACT-PICK.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-I                    BINARY-LONG.
 01 WS-BEST                 FLOAT-LONG.
 LINKAGE SECTION.
 01 L-ENTITIES              BINARY-LONG.
 01 L-D2-TABLE.
    05 L-D2                 FLOAT-LONG OCCURS 4 TIMES.
 01 L-OK-TABLE.
    05 L-OK                 BINARY-LONG OCCURS 4 TIMES.
 01 L-RANGE2                BINARY-LONG.
 01 L-PICK                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ENTITIES L-D2-TABLE L-OK-TABLE L-RANGE2 L-PICK.
     MOVE 0 TO L-PICK
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > L-ENTITIES
         IF L-OK(WS-I) = 1 AND L-D2(WS-I) <= L-RANGE2 AND (L-PICK = 0 OR L-D2(WS-I) < WS-BEST)
             MOVE WS-I TO L-PICK
             MOVE L-D2(WS-I) TO WS-BEST
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM Q3-INTERACT-PICK.
