*> Charged creeper (002-lane-mobsfull-h5; docs/protocol/20 section 6.1). A powered creeper has EN-VARIANT 1 (metadata 17) and explodes with twice its power
*> (STDMOB-SWELL: 6 in place of 3).
*>
*> Entry points:
*>   STDMOB-POWER USING tracker row, powered out   thunderHit: a creeper becomes powered (variant 1, metadata 17 to the viewers); powered out 1, else 0
*>   STDMOB-IGNITE USING player row, entity row, held key (PIC X(24)): the main-hand item on a creeper (mobInteract): flint_and_steel or fire_charge ignites it
*>     (EN-IGNITED 1, metadata 18 to the viewers); the flint loses 1 durability, the charge is used up; any other item does nothing. The ignition sound is open.
*>   STDMOB-CREEPER-FALL USING tracker row, fall distance (FLOAT-LONG): causeFallDamage of a creeper: the swell grows by floor(distance x 1.5) and is cut to maxSwell - 5.
*>   STDMOB-AVOID USING tracker row, table row, hx out, hz out (FLOAT-LONG), avoiding out: AvoidEntityGoal for cat and ocelot (6.0; walk 1.0, sprint 1.2 within 7 blocks,
*>     so always 1.2 inside the box): the nearest living cat or ocelot of the dimension within 6 blocks on x and z and 3 on y; the walk is straight away from it at 1.2 x
*>     the walk speed (the flee-point search of the framework is not modelled); avoiding out 1 when there is one.
*>   STDMOB-CHARGED-HEAD USING source row, victim row, dropped (BINARY-LONG, in and out): killedEntity of a powered creeper: the victim of its blast gives one head,
*>     once per creeper (dropped 1 afterwards): creeper head, zombie head, skeleton skull (piglin and wither skeleton have no row). The lingering cloud is open.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. STDMOB-POWER.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY STDMOBS.
 01 WS-M                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-POWERED              BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-POWERED.
     MOVE 0 TO L-POWERED
     CALL "STDMOB-INDEX" USING EN-TYPE(L-ROW) WS-M
     IF WS-M > 0 AND SM-KEY(WS-M) = "creeper"
         MOVE 1 TO EN-VARIANT(L-ROW)
         MOVE 1 TO L-POWERED
         CALL "STDMOB-VARIANT-SEND" USING L-ROW
     END-IF
     GOBACK.
 END PROGRAM STDMOB-POWER.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. STDMOB-IGNITE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-COST                BINARY-LONG VALUE 1.
 01 WS-BROKE               BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-ENTITY               BINARY-LONG.
 01 L-HELD                 PIC X(24).
 PROCEDURE DIVISION USING L-ROW L-ENTITY L-HELD.
     EVALUATE L-HELD
         WHEN "flint_and_steel"
             CALL "TOOL-HURT-STACK" USING PL-CONN(L-ROW) PL-HELD(L-ROW) WS-COST WS-BROKE
         WHEN "fire_charge"
             CALL "MOB-TAKE" USING L-ROW
         WHEN OTHER
             GOBACK
     END-EVALUATE
     MOVE 1 TO EN-IGNITED(L-ENTITY)
     CALL "STDMOB-VARIANT-SEND" USING L-ENTITY
     GOBACK.
 END PROGRAM STDMOB-IGNITE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. STDMOB-CREEPER-FALL.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY STDMOBS.
 01 WS-M                   BINARY-LONG.
 01 WS-ADD                 BINARY-LONG.
 01 WS-CAP                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-FALL                 FLOAT-LONG.
 PROCEDURE DIVISION USING L-ROW L-FALL.
     CALL "STDMOB-INDEX" USING EN-TYPE(L-ROW) WS-M
     IF WS-M > 0 AND SM-FUSE(WS-M) > 0
         COMPUTE WS-ADD = FUNCTION INTEGER(L-FALL * 1.5)
         COMPUTE WS-CAP = SM-FUSE(WS-M) - 5
         ADD WS-ADD TO EN-SWELL(L-ROW)
         IF EN-SWELL(L-ROW) > WS-CAP
             MOVE WS-CAP TO EN-SWELL(L-ROW)
         END-IF
     END-IF
     GOBACK.
 END PROGRAM STDMOB-CREEPER-FALL.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. STDMOB-AVOID.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY STDMOBS.
 01 WS-E                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-BEST                BINARY-LONG.
 01 WS-DX                  FLOAT-LONG.
 01 WS-DY                  FLOAT-LONG.
 01 WS-DZ                  FLOAT-LONG.
 01 WS-D2                  FLOAT-LONG.
 01 WS-BEST-D2             FLOAT-LONG.
 01 WS-H                   FLOAT-LONG.
 01 WS-SPEED               FLOAT-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-M                    BINARY-LONG.
 01 L-HX                   FLOAT-LONG.
 01 L-HZ                   FLOAT-LONG.
 01 L-AVOID                BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-M L-HX L-HZ L-AVOID.
     MOVE 0 TO L-HX L-HZ L-AVOID WS-BEST
     PERFORM VARYING WS-E FROM 1 BY 1 UNTIL WS-E > EN-COUNT
         IF EN-USED(WS-E) = 1 AND EN-DIM(WS-E) = EN-DIM(L-ROW) AND EN-HEALTH(WS-E) > 0
             COMPUTE WS-DX = EN-X(L-ROW) - EN-X(WS-E)
             COMPUTE WS-DY = EN-Y(L-ROW) - EN-Y(WS-E)
             COMPUTE WS-DZ = EN-Z(L-ROW) - EN-Z(WS-E)
             IF FUNCTION ABS(WS-DX) <= 6 AND FUNCTION ABS(WS-DZ) <= 6 AND FUNCTION ABS(WS-DY) <= 3
                 CALL "STDMOB-INDEX" USING EN-TYPE(WS-E) WS-K
                 IF WS-K > 0
                     COMPUTE WS-D2 = WS-DX * WS-DX + WS-DY * WS-DY + WS-DZ * WS-DZ
                     IF (SM-KEY(WS-K) = "cat" OR SM-KEY(WS-K) = "ocelot") AND (WS-BEST = 0 OR WS-D2 < WS-BEST-D2)
                         MOVE WS-E TO WS-BEST
                         MOVE WS-D2 TO WS-BEST-D2
                     END-IF
                 END-IF
             END-IF
         END-IF
     END-PERFORM
     IF WS-BEST > 0
         MOVE 1 TO L-AVOID
         COMPUTE WS-DX = EN-X(L-ROW) - EN-X(WS-BEST)
         COMPUTE WS-DZ = EN-Z(L-ROW) - EN-Z(WS-BEST)
         COMPUTE WS-H = FUNCTION SQRT(WS-DX * WS-DX + WS-DZ * WS-DZ)
         COMPUTE WS-SPEED = SM-WALK-MILLI(L-M) / 1000 * 1.2
         IF WS-H > 0
             COMPUTE L-HX = WS-DX / WS-H * WS-SPEED
             COMPUTE L-HZ = WS-DZ / WS-H * WS-SPEED
         END-IF
     END-IF
     GOBACK.
 END PROGRAM STDMOB-AVOID.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. STDMOB-CHARGED-HEAD.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY STDMOBS.
 01 WS-S                   BINARY-LONG.
 01 WS-V                   BINARY-LONG.
 01 WS-KEY                 PIC X(24).
 01 WS-ONE                 BINARY-LONG VALUE 1.
 LINKAGE SECTION.
 01 L-SOURCE               BINARY-LONG.
 01 L-VICTIM               BINARY-LONG.
 01 L-DROPPED              BINARY-LONG.
 PROCEDURE DIVISION USING L-SOURCE L-VICTIM L-DROPPED.
     IF L-DROPPED = 1 OR EN-VARIANT(L-SOURCE) NOT = 1
         GOBACK
     END-IF
     CALL "STDMOB-INDEX" USING EN-TYPE(L-SOURCE) WS-S
     CALL "STDMOB-INDEX" USING EN-TYPE(L-VICTIM) WS-V
     IF WS-S = 0 OR WS-V = 0
         GOBACK
     END-IF
     MOVE SPACES TO WS-KEY
     IF SM-KEY(WS-S) = "creeper"
         EVALUATE SM-KEY(WS-V)
             WHEN "creeper" MOVE "creeper_head" TO WS-KEY
             WHEN "zombie" MOVE "zombie_head" TO WS-KEY
             WHEN "skeleton" MOVE "skeleton_skull" TO WS-KEY
         END-EVALUATE
     END-IF
     IF WS-KEY NOT = SPACES
         CALL "MOB-DROP-ITEMS" USING L-VICTIM WS-KEY WS-ONE
         MOVE 1 TO L-DROPPED
     END-IF
     GOBACK.
 END PROGRAM STDMOB-CHARGED-HEAD.
