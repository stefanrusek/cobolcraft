*> Warden residual behaviours (docs/protocol/44-residual-mob-questions-5-overworld-hostile.md section 3, worked examples 7 to 9 of section 9, checks 7 and 8 of section 10; lane 002-lane-p49i,
*> T22530; phase task T2738). Programs of core/src/q44-44-5.cob.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-Q44-44-5-3.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY Q5ANGER.
 01 WS-CASE                PIC X(240).
 01 WS-E                   BINARY-DOUBLE.
 01 WS-O                   BINARY-DOUBLE.
 01 WS-I                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-A                   BINARY-LONG.
 01 WS-B                   BINARY-LONG.
 01 WS-C                   BINARY-LONG.
 01 WS-D                   BINARY-LONG.
 01 WS-F                   BINARY-LONG.
 01 WS-G                   BINARY-LONG.
 01 WS-NAME                PIC X(24).
 01 WS-PRI                 BINARY-LONG.
 01 WS-PLAYERS             PIC X(64) VALUE ALL "0".
 01 WS-ACCEPTED            PIC X(64) VALUE ALL "0".
 01 WS-STATUS.
    05 WS-ST               BINARY-LONG OCCURS 64 TIMES.
 01 WS-L1                  BINARY-LONG VALUE 1.
 01 WS-L0                  BINARY-LONG VALUE 0.
 01 WS-DISP                PIC 9(4).
 PROCEDURE DIVISION.
*>   Constants.
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 10
         CALL "Q5-WARDEN-CONST" USING WS-I WS-A
         EVALUATE WS-I
             WHEN 1
                 MOVE 100 TO WS-E
             WHEN 2
                 MOVE 134 TO WS-E
             WHEN 3
                 MOVE 84 TO WS-E
             WHEN 4
                 MOVE 84 TO WS-E
             WHEN 5
                 MOVE 1200 TO WS-E
             WHEN 6
                 MOVE 100 TO WS-E
             WHEN 7
                 MOVE 24 TO WS-E
             WHEN 8
                 MOVE 20 TO WS-E
             WHEN 9
                 MOVE 100 TO WS-E
             WHEN OTHER
                 MOVE 200 TO WS-E
         END-EVALUATE
         MOVE WS-I TO WS-DISP
         MOVE SPACES TO WS-CASE
         STRING "constant " DELIMITED BY SIZE WS-DISP DELIMITED BY SIZE " (dig 100, emerge 134, roar 84, sniffing 84, dig cooldown 1200, disturbance 100, follow range 24, scan 20, sniff 100 to 200)"
             DELIMITED BY SIZE INTO WS-CASE
         MOVE WS-A TO WS-O
         PERFORM CHECK-N
     END-PERFORM
*>   The activity pick: the first valid of EMERGE, DIG, ROAR, FIGHT, INVESTIGATE, SNIFF, IDLE.
*>   (emerging, roar, dig cooldown, attack, disturbance, sniffing) -> activity
     CALL "Q5-WARDEN-ACTIVITY" USING WS-L1 WS-L1 WS-L1 WS-L1 WS-L1 WS-L1 WS-A
     MOVE "activity: is_emerging wins over everything" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE WS-A TO WS-O
     PERFORM CHECK-N
     MOVE 0 TO WS-I
     MOVE 0 TO WS-J
     CALL "Q5-WARDEN-ACTIVITY" USING WS-I WS-I WS-I WS-J WS-J WS-J WS-A
     MOVE "activity: no roar target and no dig cooldown is DIG" TO WS-CASE
     MOVE 2 TO WS-E
     MOVE WS-A TO WS-O
     PERFORM CHECK-N
     MOVE 1 TO WS-B
     CALL "Q5-WARDEN-ACTIVITY" USING WS-I WS-B WS-I WS-I WS-I WS-I WS-A
     MOVE "activity: a roar target (dig needs it absent) is ROAR" TO WS-CASE
     MOVE 3 TO WS-E
     MOVE WS-A TO WS-O
     PERFORM CHECK-N
     CALL "Q5-WARDEN-ACTIVITY" USING WS-I WS-I WS-B WS-B WS-B WS-B WS-A
     MOVE "activity: a dig cooldown blocks DIG: the attack target gives FIGHT" TO WS-CASE
     MOVE 4 TO WS-E
     MOVE WS-A TO WS-O
     PERFORM CHECK-N
     CALL "Q5-WARDEN-ACTIVITY" USING WS-I WS-I WS-B WS-I WS-B WS-B WS-A
     MOVE "activity: a disturbance location without attack target is INVESTIGATE" TO WS-CASE
     MOVE 5 TO WS-E
     MOVE WS-A TO WS-O
     PERFORM CHECK-N
     CALL "Q5-WARDEN-ACTIVITY" USING WS-I WS-I WS-B WS-I WS-I WS-B WS-A
     MOVE "activity: is_sniffing alone is SNIFF" TO WS-CASE
     MOVE 6 TO WS-E
     MOVE WS-A TO WS-O
     PERFORM CHECK-N
     CALL "Q5-WARDEN-ACTIVITY" USING WS-I WS-I WS-B WS-I WS-I WS-I WS-A
     MOVE "activity: nothing else is IDLE" TO WS-CASE
     MOVE 7 TO WS-E
     MOVE WS-A TO WS-O
     PERFORM CHECK-N
*>   The behaviour lists and their priorities (the priority rule: start + slot - 1).
     MOVE 7 TO WS-I
     MOVE 1 TO WS-J
     CALL "Q5-WARDEN-BEHAVIOUR" USING WS-I WS-J WS-PRI WS-NAME
     MOVE "IDLE slot 1 is SetRoarTarget at priority 10" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE 0 TO WS-O
     IF WS-NAME = "set roar target" AND WS-PRI = 10
         MOVE 1 TO WS-O
     END-IF
     PERFORM CHECK-N
     MOVE 2 TO WS-J
     CALL "Q5-WARDEN-BEHAVIOUR" USING WS-I WS-J WS-PRI WS-NAME
     MOVE "IDLE slot 2 is TryToSniff at priority 11 (second, not last)" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE 0 TO WS-O
     IF WS-NAME = "try to sniff" AND WS-PRI = 11
         MOVE 1 TO WS-O
     END-IF
     PERFORM CHECK-N
     MOVE 3 TO WS-J
     CALL "Q5-WARDEN-BEHAVIOUR" USING WS-I WS-J WS-PRI WS-NAME
     MOVE "IDLE slot 3 is the stroll group at priority 12 (last)" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE 0 TO WS-O
     IF WS-NAME = "stroll group" AND WS-PRI = 12
         MOVE 1 TO WS-O
     END-IF
     PERFORM CHECK-N
     MOVE 4 TO WS-I
     MOVE 6 TO WS-J
     CALL "Q5-WARDEN-BEHAVIOUR" USING WS-I WS-J WS-PRI WS-NAME
     MOVE "FIGHT slot 6 is the melee attack at priority 15" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE 0 TO WS-O
     IF WS-NAME = "melee" AND WS-PRI = 15
         MOVE 1 TO WS-O
     END-IF
     PERFORM CHECK-N
     MOVE 0 TO WS-I
     MOVE 4 TO WS-J
     CALL "Q5-WARDEN-BEHAVIOUR" USING WS-I WS-J WS-PRI WS-NAME
     MOVE "CORE slot 4 is the move-to-target sink at priority 3" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE 0 TO WS-O
     IF WS-NAME = "move to target sink" AND WS-PRI = 3
         MOVE 1 TO WS-O
     END-IF
     PERFORM CHECK-N
     MOVE 2 TO WS-I
     MOVE 2 TO WS-J
     CALL "Q5-WARDEN-BEHAVIOUR" USING WS-I WS-J WS-PRI WS-NAME
     MOVE "DIG slot 2 is Digging at priority 1" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE 0 TO WS-O
     IF WS-NAME = "digging" AND WS-PRI = 1
         MOVE 1 TO WS-O
     END-IF
     PERFORM CHECK-N
     MOVE 1 TO WS-I
     MOVE 1 TO WS-J
     CALL "Q5-WARDEN-BEHAVIOUR" USING WS-I WS-J WS-PRI WS-NAME
     MOVE "EMERGE slot 1 is Emerging at priority 5" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE 0 TO WS-O
     IF WS-NAME = "emerging" AND WS-PRI = 5
         MOVE 1 TO WS-O
     END-IF
     PERFORM CHECK-N
     MOVE 5 TO WS-I
     MOVE 2 TO WS-J
     CALL "Q5-WARDEN-BEHAVIOUR" USING WS-I WS-J WS-PRI WS-NAME
     MOVE "INVESTIGATE slot 2 walks to the disturbance at priority 6" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE 0 TO WS-O
     IF WS-NAME = "walk to disturbance" AND WS-PRI = 6
         MOVE 1 TO WS-O
     END-IF
     PERFORM CHECK-N
     MOVE 6 TO WS-I
     MOVE 2 TO WS-J
     CALL "Q5-WARDEN-BEHAVIOUR" USING WS-I WS-J WS-PRI WS-NAME
     MOVE "SNIFF slot 2 is Sniffing at priority 6" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE 0 TO WS-O
     IF WS-NAME = "sniffing" AND WS-PRI = 6
         MOVE 1 TO WS-O
     END-IF
     PERFORM CHECK-N
     MOVE 3 TO WS-I
     MOVE 1 TO WS-J
     CALL "Q5-WARDEN-BEHAVIOUR" USING WS-I WS-J WS-PRI WS-NAME
     MOVE "ROAR slot 1 is Roar at priority 10" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE 0 TO WS-O
     IF WS-NAME = "roar" AND WS-PRI = 10
         MOVE 1 TO WS-O
     END-IF
     PERFORM CHECK-N
     MOVE 3 TO WS-J
     CALL "Q5-WARDEN-BEHAVIOUR" USING WS-I WS-J WS-PRI WS-NAME
     MOVE "a slot past the list has no behaviour (priority -1)" TO WS-CASE
     MOVE -1 TO WS-E
     MOVE WS-PRI TO WS-O
     PERFORM CHECK-N
*>   TryToSniff (worked example 7).
     CALL "Q5-SNIFF-START" USING WS-L1 WS-L1 WS-L0 WS-L1 WS-L0 WS-A
     MOVE "TryToSniff starts with a nearest attackable, no disturbance and no cooldown" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE WS-A TO WS-O
     PERFORM CHECK-N
     CALL "Q5-SNIFF-START" USING WS-L1 WS-L1 WS-L1 WS-L1 WS-L0 WS-A
     MOVE "TryToSniff does not start while the sniff cooldown is present" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-A TO WS-O
     PERFORM CHECK-N
     CALL "Q5-SNIFF-START" USING WS-L1 WS-L1 WS-L0 WS-L0 WS-L0 WS-A
     MOVE "TryToSniff needs a nearest attackable" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-A TO WS-O
     PERFORM CHECK-N
     CALL "Q5-SNIFF-START" USING WS-L1 WS-L1 WS-L0 WS-L1 WS-L1 WS-A
     MOVE "TryToSniff does not start with a disturbance location" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-A TO WS-O
     PERFORM CHECK-N
     CALL "Q5-SNIFF-START" USING WS-L0 WS-L1 WS-L0 WS-L1 WS-L0 WS-A
     MOVE "TryToSniff needs is_sniffing registered" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-A TO WS-O
     PERFORM CHECK-N
     CALL "Q5-SNIFF-START" USING WS-L1 WS-L0 WS-L0 WS-L1 WS-L0 WS-A
     MOVE "TryToSniff needs walk_target registered" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-A TO WS-O
     PERFORM CHECK-N
     MOVE 0 TO WS-I
     CALL "Q5-SNIFF-COOLDOWN" USING WS-I WS-A
     MOVE 100 TO WS-I
     CALL "Q5-SNIFF-COOLDOWN" USING WS-I WS-B
     MOVE "the sniff cooldown is uniform from 100 to 200: the draws 0 and 100 give both ends" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE 0 TO WS-O
     IF WS-A = 100 AND WS-B = 200
         MOVE 1 TO WS-O
     END-IF
     PERFORM CHECK-N
*>   Digging.
     CALL "Q5-DIG-START" USING WS-L1 WS-L0 WS-A
     MOVE "Digging on the ground: the digging pose" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE WS-A TO WS-O
     PERFORM CHECK-N
     CALL "Q5-DIG-START" USING WS-L0 WS-L1 WS-A
     MOVE "Digging in a liquid off the ground: the agitated sound and the behaviour stops at once" TO WS-CASE
     MOVE 2 TO WS-E
     MOVE WS-A TO WS-O
     PERFORM CHECK-N
     CALL "Q5-DIG-START" USING WS-L0 WS-L0 WS-A
     MOVE "Digging cannot start in the air" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-A TO WS-O
     PERFORM CHECK-N
     CALL "Q5-DIG-STOP" USING WS-L0 WS-A
     MOVE "when Digging stops the warden is removed (DISCARDED)" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE WS-A TO WS-O
     PERFORM CHECK-N
     CALL "Q5-DIG-STOP" USING WS-L1 WS-A
     MOVE "an already removed warden is not removed again" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-A TO WS-O
     PERFORM CHECK-N
*>   Emerging.
     CALL "Q5-EMERGE-START" USING WS-L1 WS-L0 WS-A
     MOVE "Emerging starts with is_emerging and no walk target" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE WS-A TO WS-O
     PERFORM CHECK-N
     CALL "Q5-EMERGE-START" USING WS-L1 WS-L1 WS-A
     MOVE "Emerging does not start with a walk target" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-A TO WS-O
     PERFORM CHECK-N
     CALL "Q5-EMERGE-START" USING WS-L0 WS-L0 WS-A
     MOVE "Emerging needs is_emerging" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-A TO WS-O
     PERFORM CHECK-N
     CALL "Q5-EMERGE-STOP" USING WS-L1 WS-A
     MOVE "when Emerging stops with the pose still EMERGING it becomes STANDING" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE WS-A TO WS-O
     PERFORM CHECK-N
     CALL "Q5-EMERGE-STOP" USING WS-L0 WS-A
     MOVE "when Emerging stops with another pose nothing changes" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-A TO WS-O
     PERFORM CHECK-N
*>   The sensor pick (worked example 8): a pig at 3 blocks, a player at 10; both accepted.
     MOVE "01" TO WS-PLAYERS(1:2)
     MOVE "11" TO WS-ACCEPTED(1:2)
     MOVE 2 TO WS-I
     CALL "Q5-WARDEN-PICK" USING WS-I WS-PLAYERS WS-ACCEPTED WS-A
     MOVE "sensor: the player is picked even though the pig is nearer" TO WS-CASE
     MOVE 2 TO WS-E
     MOVE WS-A TO WS-O
     PERFORM CHECK-N
     MOVE "00" TO WS-PLAYERS(1:2)
     CALL "Q5-WARDEN-PICK" USING WS-I WS-PLAYERS WS-ACCEPTED WS-A
     MOVE "sensor: with no player the first accepted non-player is picked (the pig, the nearest)" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE WS-A TO WS-O
     PERFORM CHECK-N
     MOVE "01" TO WS-PLAYERS(1:2)
     MOVE "10" TO WS-ACCEPTED(1:2)
     CALL "Q5-WARDEN-PICK" USING WS-I WS-PLAYERS WS-ACCEPTED WS-A
     MOVE "sensor: a player that fails canTargetEntity is skipped for the pig" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE WS-A TO WS-O
     PERFORM CHECK-N
     MOVE "00" TO WS-ACCEPTED(1:2)
     CALL "Q5-WARDEN-PICK" USING WS-I WS-PLAYERS WS-ACCEPTED WS-A
     MOVE "sensor: nothing accepted erases nearest_attackable (index 0)" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-A TO WS-O
     PERFORM CHECK-N
*>   Anger levels.
     MOVE 39 TO WS-I
     CALL "Q5-ANGER-LEVEL" USING WS-I WS-A WS-B
     MOVE 40 TO WS-I
     CALL "Q5-ANGER-LEVEL" USING WS-I WS-C WS-D
     MOVE 80 TO WS-I
     CALL "Q5-ANGER-LEVEL" USING WS-I WS-F WS-G
     MOVE "anger levels: 39 is calm, 40 agitated, 80 angry (only ANGRY is angry)" TO WS-CASE
     MOVE 121 TO WS-E
     COMPUTE WS-O = WS-A * 1000 + WS-C * 100 + WS-F * 10 + WS-G + WS-B * 10000 + WS-D * 20000
     PERFORM CHECK-N
*>   Anger management: sort order (worked example 9), the cap, the single suspect, the clear.
     MOVE 1 TO WS-D
     CALL "Q5-ANGER-INIT" USING Q5-ANGER WS-D
     MOVE 1 TO WS-I
     MOVE 0 TO WS-J
     MOVE 60 TO WS-A
     CALL "Q5-ANGER-INCREASE" USING Q5-ANGER WS-I WS-B WS-A WS-C
     MOVE "a single suspect: the highest anger is exactly its value" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE 0 TO WS-O
     IF AN-HIGHEST = 60 AND AN-SUSPECT-COUNT = 1
         MOVE 1 TO WS-O
     END-IF
     PERFORM CHECK-N
     CALL "Q5-ANGER-INIT" USING Q5-ANGER WS-D
*>   A player with 60 (not angry), a zombie with 90 (angry), a player with 85 (angry).
     MOVE 1 TO WS-I
     MOVE 1 TO WS-B
     MOVE 60 TO WS-A
     CALL "Q5-ANGER-INCREASE" USING Q5-ANGER WS-I WS-B WS-A WS-C
     MOVE 2 TO WS-I
     MOVE 0 TO WS-B
     MOVE 90 TO WS-A
     CALL "Q5-ANGER-INCREASE" USING Q5-ANGER WS-I WS-B WS-A WS-C
     MOVE 3 TO WS-I
     MOVE 1 TO WS-B
     MOVE 85 TO WS-A
     CALL "Q5-ANGER-INCREASE" USING Q5-ANGER WS-I WS-B WS-A WS-C
     MOVE "anger sort: C (angry player), B (angry), A (not angry)" TO WS-CASE
     MOVE 321 TO WS-E
     COMPUTE WS-O = AN-SUSPECT(1) * 100 + AN-SUSPECT(2) * 10 + AN-SUSPECT(3)
     PERFORM CHECK-N
     MOVE "anger: the highest anger is the maximum over the suspects (90)" TO WS-CASE
     MOVE 90 TO WS-E
     MOVE AN-HIGHEST TO WS-O
     PERFORM CHECK-N
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 64
         MOVE 1 TO WS-ST(WS-I)
     END-PERFORM
     CALL "Q5-ANGER-TOP" USING Q5-ANGER WS-STATUS WS-A
     MOVE "the top suspect is C" TO WS-CASE
     MOVE 3 TO WS-E
     MOVE WS-A TO WS-O
     PERFORM CHECK-N
     MOVE 4 TO WS-ST(3)
     CALL "Q5-ANGER-TOP" USING Q5-ANGER WS-STATUS WS-A
     MOVE "the top suspect skips one the filter rejects: B" TO WS-CASE
     MOVE 2 TO WS-E
     MOVE WS-A TO WS-O
     PERFORM CHECK-N
     MOVE 4 TO WS-ST(2)
     MOVE 4 TO WS-ST(1)
     CALL "Q5-ANGER-TOP" USING Q5-ANGER WS-STATUS WS-A
     MOVE "no suspect passes the filter: no top suspect" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-A TO WS-O
     PERFORM CHECK-N
     MOVE 0 TO WS-I
     CALL "Q5-ANGER-ACTIVE" USING Q5-ANGER WS-I WS-A
     MOVE "getActiveAnger for no entity is the highest anger" TO WS-CASE
     MOVE 90 TO WS-E
     MOVE WS-A TO WS-O
     PERFORM CHECK-N
     MOVE 3 TO WS-I
     CALL "Q5-ANGER-ACTIVE" USING Q5-ANGER WS-I WS-A
     MOVE "getActiveAnger of entity C is its value 85" TO WS-CASE
     MOVE 85 TO WS-E
     MOVE WS-A TO WS-O
     PERFORM CHECK-N
     MOVE 9 TO WS-I
     CALL "Q5-ANGER-ACTIVE" USING Q5-ANGER WS-I WS-A
     MOVE "getActiveAnger of an unknown entity is 0" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-A TO WS-O
     PERFORM CHECK-N
*>   The cap at 150.
     MOVE 3 TO WS-I
     MOVE 1 TO WS-B
     MOVE 100 TO WS-A
     CALL "Q5-ANGER-INCREASE" USING Q5-ANGER WS-I WS-B WS-A WS-C
     MOVE "increases cap at 150 (85 + 100)" TO WS-CASE
     MOVE 150 TO WS-E
     MOVE WS-C TO WS-O
     PERFORM CHECK-N
*>   Clear: C goes, B (angry) leads, A follows.
     MOVE 3 TO WS-I
     CALL "Q5-ANGER-CLEAR" USING Q5-ANGER WS-I
     MOVE "clearAnger removes the entry and the suspect: B then A remain" TO WS-CASE
     MOVE 221 TO WS-E
     COMPUTE WS-O = AN-SUSPECT-COUNT * 100 + AN-SUSPECT(1) * 10 + AN-SUSPECT(2)
     PERFORM CHECK-N
     MOVE "after the clear the highest anger is 90" TO WS-CASE
     MOVE 90 TO WS-E
     MOVE AN-HIGHEST TO WS-O
     PERFORM CHECK-N
*>   Tick: delay, UUID entries, the dimension change keeping anger by UUID.
     MOVE 1 TO WS-D
     CALL "Q5-ANGER-INIT" USING Q5-ANGER WS-D
     MOVE 1 TO WS-I
     MOVE 1 TO WS-B
     MOVE 5 TO WS-A
     CALL "Q5-ANGER-INCREASE" USING Q5-ANGER WS-I WS-B WS-A WS-C
     MOVE 2 TO WS-I
     MOVE 0 TO WS-B
     MOVE 1 TO WS-A
     CALL "Q5-ANGER-INCREASE" USING Q5-ANGER WS-I WS-B WS-A WS-C
     MOVE 3 TO WS-I
     MOVE 1 TO WS-B
     MOVE 9 TO WS-A
     CALL "Q5-ANGER-INCREASE" USING Q5-ANGER WS-I WS-B WS-A WS-C
     MOVE 4 TO WS-I
     MOVE 1 TO WS-B
     MOVE 20 TO WS-A
     CALL "Q5-ANGER-INCREASE" USING Q5-ANGER WS-I WS-B WS-A WS-C
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 64
         MOVE 1 TO WS-ST(WS-I)
     END-PERFORM
     MOVE 3 TO WS-ST(3)
     MOVE 2 TO WS-ST(4)
     CALL "Q5-ANGER-TICK" USING Q5-ANGER WS-STATUS
     MOVE "tick: entity 1 (5) loses 1; entity 2 (1) is dropped; entity 3 (9) removed by a dimension change goes to the UUID map with 8; entity 4 killed is dropped" TO WS-CASE
     MOVE 1418 TO WS-E
     COMPUTE WS-O = AN-LIVE-COUNT * 1000 + AN-L-VALUE(1) * 100 + AN-UUID-COUNT * 10 + AN-U-VALUE(1)
     PERFORM CHECK-N
     MOVE "tick: the suspect list holds only entity 1" TO WS-CASE
     MOVE 11 TO WS-E
     COMPUTE WS-O = AN-SUSPECT-COUNT * 10 + AN-SUSPECT(1)
     PERFORM CHECK-N
*>   Entity 3 comes back: the delay runs out (1 -> 0 on the first tick above reset it to 2), so the next tick after one more tick converts it.
     MOVE 1 TO WS-ST(3)
     CALL "Q5-ANGER-TICK" USING Q5-ANGER WS-STATUS
     MOVE "tick: with the delay at 2 the first tick only counts it down (the UUID entry stays and loses 1: 7)" TO WS-CASE
     MOVE 17 TO WS-E
     COMPUTE WS-O = AN-UUID-COUNT * 10 + AN-U-VALUE(1)
     PERFORM CHECK-N
     CALL "Q5-ANGER-TICK" USING Q5-ANGER WS-STATUS
     MOVE "tick: when the delay reaches 0 the UUID entry of the found entity moves to the live map" TO WS-CASE
     MOVE 20 TO WS-E
     COMPUTE WS-O = AN-LIVE-COUNT * 10 + AN-UUID-COUNT
     PERFORM CHECK-N
*>   Increase of an entity with a pending UUID value adds it without the cap.
     MOVE 1 TO WS-D
     CALL "Q5-ANGER-INIT" USING Q5-ANGER WS-D
     MOVE 1 TO AN-UUID-COUNT
     MOVE 7 TO AN-U-ID(1)
     MOVE 1 TO AN-U-PLAYER(1)
     MOVE 120 TO AN-U-VALUE(1)
     MOVE 7 TO WS-I
     MOVE 1 TO WS-B
     MOVE 100 TO WS-A
     CALL "Q5-ANGER-INCREASE" USING Q5-ANGER WS-I WS-B WS-A WS-C
     MOVE "increase with a pending UUID value of 120: min(150, 100) + 120 = 220 (the cap is not applied again) and the UUID entry is removed" TO WS-CASE
     MOVE 2200 TO WS-E
     COMPUTE WS-O = WS-C * 10 + AN-UUID-COUNT
     PERFORM CHECK-N
*>   Entries in the middle of the maps: dropping the first of three live entries, a new entity above the cap, the UUID maps with several entries.
     MOVE 1 TO WS-D
     CALL "Q5-ANGER-INIT" USING Q5-ANGER WS-D
     MOVE 1 TO WS-I
     MOVE 1 TO WS-B
     MOVE 10 TO WS-A
     CALL "Q5-ANGER-INCREASE" USING Q5-ANGER WS-I WS-B WS-A WS-C
     MOVE 2 TO WS-I
     CALL "Q5-ANGER-INCREASE" USING Q5-ANGER WS-I WS-B WS-A WS-C
     MOVE 3 TO WS-I
     MOVE 200 TO WS-A
     CALL "Q5-ANGER-INCREASE" USING Q5-ANGER WS-I WS-B WS-A WS-C
     MOVE "a new entity with an increase of 200 is capped at 150" TO WS-CASE
     MOVE 150 TO WS-E
     MOVE WS-C TO WS-O
     PERFORM CHECK-N
     MOVE 1 TO WS-I
     CALL "Q5-ANGER-CLEAR" USING Q5-ANGER WS-I
     MOVE "clearing the first of three entries keeps the other two (2 and 3 shift down; two suspects)" TO WS-CASE
     MOVE 2232 TO WS-E
     COMPUTE WS-O = AN-LIVE-COUNT * 1000 + AN-L-ID(1) * 100 + AN-L-ID(2) * 10 + AN-SUSPECT-COUNT
     PERFORM CHECK-N
*>   Tick with three UUID entries: 5 (value 1) and 6 (value 9) found, 7 (value 5) not.
     MOVE 1 TO WS-D
     CALL "Q5-ANGER-INIT" USING Q5-ANGER WS-D
     MOVE 3 TO AN-UUID-COUNT
     MOVE 5 TO AN-U-ID(1)
     MOVE 1 TO AN-U-PLAYER(1)
     MOVE 1 TO AN-U-VALUE(1)
     MOVE 6 TO AN-U-ID(2)
     MOVE 0 TO AN-U-PLAYER(2)
     MOVE 9 TO AN-U-VALUE(2)
     MOVE 7 TO AN-U-ID(3)
     MOVE 1 TO AN-U-PLAYER(3)
     MOVE 5 TO AN-U-VALUE(3)
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 64
         MOVE 0 TO WS-ST(WS-I)
     END-PERFORM
     MOVE 1 TO WS-ST(5)
     MOVE 1 TO WS-ST(6)
     CALL "Q5-ANGER-TICK" USING Q5-ANGER WS-STATUS
     MOVE "tick: the found entities 5 (value 1) and 6 (9) join the live map, 5 is then dropped for its value; 6 keeps 8; entity 7 stays in the UUID map with 4" TO WS-CASE
     MOVE 1104 TO WS-E
     COMPUTE WS-O = AN-LIVE-COUNT * 1000 + AN-UUID-COUNT * 100 + AN-U-VALUE(1)
     PERFORM CHECK-N
*>   A tick that drops the first of two UUID entries (value 1) while the entities are not found.
     CALL "Q5-ANGER-INIT" USING Q5-ANGER WS-L1
     MOVE 2 TO AN-UUID-COUNT
     MOVE 5 TO AN-U-ID(1)
     MOVE 1 TO AN-U-VALUE(1)
     MOVE 6 TO AN-U-ID(2)
     MOVE 9 TO AN-U-VALUE(2)
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 64
         MOVE 0 TO WS-ST(WS-I)
     END-PERFORM
     CALL "Q5-ANGER-TICK" USING Q5-ANGER WS-STATUS
     MOVE "tick: the UUID entry of value 1 is dropped, the next one shifts down and loses 1 (entity 6 with 8)" TO WS-CASE
     MOVE 168 TO WS-E
     COMPUTE WS-O = AN-UUID-COUNT * 100 + AN-U-ID(1) * 10 + AN-U-VALUE(1)
     PERFORM CHECK-N
*>   A pending UUID entry that is not the last one is removed by an increase.
     CALL "Q5-ANGER-INIT" USING Q5-ANGER WS-L1
     MOVE 2 TO AN-UUID-COUNT
     MOVE 8 TO AN-U-ID(1)
     MOVE 1 TO AN-U-PLAYER(1)
     MOVE 120 TO AN-U-VALUE(1)
     MOVE 9 TO AN-U-ID(2)
     MOVE 1 TO AN-U-PLAYER(2)
     MOVE 30 TO AN-U-VALUE(2)
     MOVE 8 TO WS-I
     MOVE 1 TO WS-B
     MOVE 10 TO WS-A
     CALL "Q5-ANGER-INCREASE" USING Q5-ANGER WS-I WS-B WS-A WS-C
     MOVE "increase of entity 8 with a pending 120: 10 + 120 = 130, and entity 9's pending entry shifts down" TO WS-CASE
     MOVE 13019 TO WS-E
     COMPUTE WS-O = WS-C * 100 + AN-UUID-COUNT * 10 + AN-U-ID(1)
     PERFORM CHECK-N
     STOP RUN.

 CHECK-N.
     MOVE "N" TO TL-MODE
     MOVE SPACES TO TL-CASE
     STRING "acceptance US15 44-5§3 Warden residual behaviours: " DELIMITED BY SIZE FUNCTION TRIM(WS-CASE) DELIMITED BY SIZE INTO TL-CASE
     MOVE WS-E TO TL-EXPECTED-N
     MOVE WS-O TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-Q44-44-5-3.
