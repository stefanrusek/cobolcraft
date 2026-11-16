*> Camel rider input and random sitting (002-lane-mobsa4; docs/protocol/54-client-gap-closures.md sections 6.3 and 6.4).
*> - M44-CAMEL-RIDER-JUMP USING row, strength (the data of START_RIDING_JUMP), ok out: the server side of a dash: a saddled camel that is standing (not in a pose transition: pose time at least 52)
*>   with no dash cooldown starts the dash (cooldown 55, M44-CAMEL-DASH) when the strength is above 0. The impulse itself is the rider's client's. Nothing calls it yet: the Player Command handler
*>   (movement.cob, action 0x2A) has no START_RIDING_JUMP action (gap); the rider's forward input that stands a sitting camel up and the water stand-up are not modelled (no rider input in core).
*> - M44-CAMEL-BRAIN USING row (after M44-CAMEL-TICK): RandomSitting: with chance 1 in 120 a tick (the RunOne selection every 30 to 60 ticks: stand-in) M44-CAMEL-SIT changes the pose of an idle camel;
*>   the metadata is sent.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. M44-CAMEL-RIDER-JUMP.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-STARTED             BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-STRENGTH             BINARY-LONG.
 01 L-OK                   BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-STRENGTH L-OK.
     MOVE 0 TO L-OK
     IF EN-SADDLE(L-ROW) = 1 AND L-STRENGTH > 0 AND EN-CAMEL-POSE(L-ROW) = 0 AND CW-TIME - EN-CAMEL-POSE-T(L-ROW) >= 52
         CALL "M44-CAMEL-DASH" USING L-ROW WS-STARTED
         MOVE WS-STARTED TO L-OK
     END-IF
     GOBACK.
 END PROGRAM M44-CAMEL-RIDER-JUMP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. M44-CAMEL-BRAIN.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-SALT                BINARY-LONG VALUE 140.
 01 WS-BOUND               BINARY-LONG VALUE 120.
 01 WS-DRAW                BINARY-LONG.
 01 WS-LEASHED             BINARY-LONG.
 01 WS-CHANGED             BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     CALL "XP-RANDOM" USING WS-SALT WS-BOUND WS-DRAW
     IF WS-DRAW = 0
         MOVE 0 TO WS-LEASHED
         IF EN-LEASH(L-ROW) > 0 OR EN-LEASH-KNOT(L-ROW) > 0
             MOVE 1 TO WS-LEASHED
         END-IF
         CALL "M44-CAMEL-SIT" USING L-ROW CW-TIME WS-LEASHED EN-RIDER(L-ROW) WS-CHANGED
         IF WS-CHANGED = 1
             CALL "MOB-DATA-SEND" USING L-ROW
         END-IF
     END-IF
     GOBACK.
 END PROGRAM M44-CAMEL-BRAIN.
