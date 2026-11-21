*> Particles part 6 (docs/protocol/42-particles-6-emitters-blocks.md) section 4: block-entity client tickers. P6-BE-TICK runs one client tick of
*> one block entity; draws and output rows are those of client/copy/CLP6EM.cpy (see particles-42-6-b.cob).
*>
*> Entry points for the integrator (inputs):
*>   P6-BE-TICK class(PIC X(24)) P(3 integers) PROPS(12 integers) P6-EMITS: classes and PROPS (1-based):
*>     campfire_entity   1 signal_fire, 2 facing 2D data value (0 south, 1 west, 2 north, 3 east), 3-6 the four item slots hold an item
*>     trial_spawner     1 emission mode (0 none, 1 small flames, 2 flames and smoke, 3 smoke inside and top face), 2 ominous, 3 game time
*>     monster_spawner   1 a player is near and a display entity exists
*>     vault             1 mode (0 idle, 1 activation, 2 deactivation), 2 the shared data has a display item, 3 ominous
*>     noxious_gas       1 game time, 2 a source was found, 3-5 the source X, Y, Z (P6-NOXIOUS-SOURCE)
*>     geyser_plume      1 game time, 2 eruption tick, 3 a source was found, 4-6 the source X, Y, Z, 7 continuous (0 erupting)
*>   P6-NOXIOUS-SOURCE water-source(5 flags) passable(5 flags): dy out (0 none, 1-5 the source offset above P) for the cells P + 1 to P + 5;
*>   P6-VAULT-CONNECT keyhole(3 floats) target(3 floats: the player's position + (0, height / 2, 0)) P6-EMITS: the connection particles of 4.4.
*> The block entity's own bookkeeping (spawn delay, the sculk catalyst bloom of 4.5, which is a server packet of section 9) emits nothing here.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P6-STEP2D.
*> Direction.from2DDataValue step: USING value (0 south, 1 west, 2 north, 3 east), x step out, z step out.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-D                    BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 PROCEDURE DIVISION USING L-D L-X L-Z.
     EVALUATE L-D
         WHEN 0
             MOVE 0 TO L-X
             MOVE 1 TO L-Z
         WHEN 1
             MOVE -1 TO L-X
             MOVE 0 TO L-Z
         WHEN 2
             MOVE 0 TO L-X
             MOVE -1 TO L-Z
         WHEN OTHER
             MOVE 1 TO L-X
             MOVE 0 TO L-Z
     END-EVALUATE
     GOBACK.
 END PROGRAM P6-STEP2D.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P6-D-CAMPFIRE.
*> 4.1 CampfireBlockEntity.particleTick: draw rf < 0.11: loop while pass < ri(2) + 2 (the bound is drawn each pass, then three-axis smoke: the
*> campfire cosy or signal smoke at (X + 0.5 + (rd / 3) * sign, Y + rd + rd, Z + 0.5 + (rd / 3) * sign), draws rd then rb per horizontal axis, velocity
*> (0, 0.07, 0)). Then each slot with an item and a draw rf < 0.2: four `smoke` at the item position, velocity (0, 0.0005, 0), the direction
*> from2DDataValue((slot + facing) mod 4) and its clockwise neighbour.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-SMOKE               PIC X(40) VALUE "smoke".
 01 WS-N                   PIC X(40).
 01 WS-R                   FLOAT-LONG.
 01 WS-PASS                BINARY-LONG.
 01 WS-BOUND               BINARY-LONG.
 01 WS-SLOT                BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-D                   BINARY-LONG.
 01 WS-C                   BINARY-LONG.
 01 WS-SIGN                FLOAT-LONG.
 01 WS-DX                  BINARY-LONG.
 01 WS-DZ                  BINARY-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-Y1                  FLOAT-LONG.
 01 WS-PV.
    05 WS-V                FLOAT-LONG OCCURS 6 TIMES.
 LINKAGE SECTION.
 COPY CLP6ARG.
 COPY CLP6EM.
 PROCEDURE DIVISION USING L-P L-PROPS P6-EMITS.
     CALL "P6-DRAW" USING P6-EMITS WS-R
     IF WS-R < 0.11
         IF L-PR(1) NOT = 0
             MOVE "campfire_signal_smoke" TO WS-N
         ELSE
             MOVE "campfire_cosy_smoke" TO WS-N
         END-IF
         MOVE 0 TO WS-PASS
         CALL "P6-DRAW" USING P6-EMITS WS-R
         COMPUTE WS-BOUND = FUNCTION INTEGER-PART(WS-R * 2) + 2
         PERFORM UNTIL WS-PASS >= WS-BOUND
             INITIALIZE WS-PV
             CALL "P6-DRAW" USING P6-EMITS WS-R
             MOVE WS-R TO WS-Y1
             CALL "P6-DRAW" USING P6-EMITS WS-R
             MOVE -1 TO WS-SIGN
             IF WS-R >= 0.5
                 MOVE 1 TO WS-SIGN
             END-IF
             COMPUTE WS-V(1) = L-PP(1) + 0.5 + WS-Y1 / 3 * WS-SIGN
             CALL "P6-DRAW" USING P6-EMITS WS-R
             MOVE WS-R TO WS-Y1
             CALL "P6-DRAW" USING P6-EMITS WS-R
             COMPUTE WS-V(2) = L-PP(2) + WS-Y1 + WS-R
             CALL "P6-DRAW" USING P6-EMITS WS-R
             MOVE WS-R TO WS-Y1
             CALL "P6-DRAW" USING P6-EMITS WS-R
             MOVE -1 TO WS-SIGN
             IF WS-R >= 0.5
                 MOVE 1 TO WS-SIGN
             END-IF
             COMPUTE WS-V(3) = L-PP(3) + 0.5 + WS-Y1 / 3 * WS-SIGN
             MOVE 0.07 TO WS-V(5)
             CALL "P6-EMIT" USING P6-EMITS WS-N WS-PV
             ADD 1 TO WS-PASS
             CALL "P6-DRAW" USING P6-EMITS WS-R
             COMPUTE WS-BOUND = FUNCTION INTEGER-PART(WS-R * 2) + 2
         END-PERFORM
     END-IF
     PERFORM VARYING WS-SLOT FROM 0 BY 1 UNTIL WS-SLOT > 3
         COMPUTE WS-K = WS-SLOT + 3
         IF L-PR(WS-K) NOT = 0
             CALL "P6-DRAW" USING P6-EMITS WS-R
             IF WS-R < 0.2
                 COMPUTE WS-D = FUNCTION MOD(WS-SLOT + L-PR(2), 4)
                 COMPUTE WS-C = FUNCTION MOD(WS-D + 1, 4)
                 CALL "P6-STEP2D" USING WS-D WS-DX WS-DZ
                 CALL "P6-STEP2D" USING WS-C WS-CX WS-CZ
                 INITIALIZE WS-PV
                 COMPUTE WS-V(1) = L-PP(1) + 0.5 - WS-DX * 0.3125 + WS-CX * 0.3125
                 COMPUTE WS-V(2) = L-PP(2) + 0.5
                 COMPUTE WS-V(3) = L-PP(3) + 0.5 - WS-DZ * 0.3125 + WS-CZ * 0.3125
                 MOVE 0.0005 TO WS-V(5)
                 PERFORM 4 TIMES
                     CALL "P6-EMIT" USING P6-EMITS WS-SMOKE WS-PV
                 END-PERFORM
             END-IF
         END-IF
     END-PERFORM
     GOBACK.

 END PROGRAM P6-D-CAMPFIRE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P6-OFFSET-RANDOM.
*> Vec3.offsetRandom: USING emits, spread k, out (three floats): three draws, each (rf - 0.5) * k.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-R                   FLOAT-LONG.
 01 WS-A                   BINARY-LONG.
 LINKAGE SECTION.
 COPY CLP6EM.
 01 L-K                    FLOAT-LONG.
 01 L-OUT.
    05 L-O                 FLOAT-LONG OCCURS 3 TIMES.
 PROCEDURE DIVISION USING P6-EMITS L-K L-OUT.
     PERFORM VARYING WS-A FROM 1 BY 1 UNTIL WS-A > 3
         CALL "P6-DRAW" USING P6-EMITS WS-R
         COMPUTE L-O(WS-A) = (WS-R - 0.5) * L-K
     END-PERFORM
     GOBACK.
 END PROGRAM P6-OFFSET-RANDOM.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P6-D-TRIAL-SPAWNER.
*> 4.2 TrialSpawnerState.emitParticles (PROPS 1 mode, 2 ominous, 3 game time): small flames: draw ri(2) == 0, then p = centre + offsetRandom(0.9): `small_flame`
*> (`soul_fire_flame` ominous); flames and smoke: p = centre + offsetRandom(1.0): `smoke`, then `flame` (`soul_fire_flame`); cooldown: p = centre +
*> offsetRandom(0.9), draw ri(3) == 0: `smoke` at p; game time mod 20 = 0: draw n = ri(4) + 20, n `smoke` at centre + (0, 0.5, 0).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-SMOKE               PIC X(40) VALUE "smoke".
 01 WS-FLAME               PIC X(40).
 01 WS-R                   FLOAT-LONG.
 01 WS-K                   FLOAT-LONG.
 01 WS-OFF.
    05 WS-O                FLOAT-LONG OCCURS 3 TIMES.
 01 WS-N                   BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-PV.
    05 WS-V                FLOAT-LONG OCCURS 6 TIMES.
 LINKAGE SECTION.
 COPY CLP6ARG.
 COPY CLP6EM.
 PROCEDURE DIVISION USING L-P L-PROPS P6-EMITS.
     INITIALIZE WS-PV
     EVALUATE L-PR(1)
         WHEN 1
             IF L-PR(2) NOT = 0
                 MOVE "soul_fire_flame" TO WS-FLAME
             ELSE
                 MOVE "small_flame" TO WS-FLAME
             END-IF
             CALL "P6-DRAW" USING P6-EMITS WS-R
             IF WS-R < 0.5
                 MOVE 0.9 TO WS-K
                 CALL "P6-OFFSET-RANDOM" USING P6-EMITS WS-K WS-OFF
                 PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 3
                     COMPUTE WS-V(WS-I) = L-PP(WS-I) + 0.5 + WS-O(WS-I)
                 END-PERFORM
                 CALL "P6-EMIT" USING P6-EMITS WS-FLAME WS-PV
             END-IF
         WHEN 2
             IF L-PR(2) NOT = 0
                 MOVE "soul_fire_flame" TO WS-FLAME
             ELSE
                 MOVE "flame" TO WS-FLAME
             END-IF
             MOVE 1.0 TO WS-K
             CALL "P6-OFFSET-RANDOM" USING P6-EMITS WS-K WS-OFF
             PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 3
                 COMPUTE WS-V(WS-I) = L-PP(WS-I) + 0.5 + WS-O(WS-I)
             END-PERFORM
             CALL "P6-EMIT" USING P6-EMITS WS-SMOKE WS-PV
             CALL "P6-EMIT" USING P6-EMITS WS-FLAME WS-PV
         WHEN 3
             MOVE 0.9 TO WS-K
             CALL "P6-OFFSET-RANDOM" USING P6-EMITS WS-K WS-OFF
             PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 3
                 COMPUTE WS-V(WS-I) = L-PP(WS-I) + 0.5 + WS-O(WS-I)
             END-PERFORM
             CALL "P6-DRAW" USING P6-EMITS WS-R
             IF WS-R < 0.3333333333333333
                 CALL "P6-EMIT" USING P6-EMITS WS-SMOKE WS-PV
             END-IF
             IF FUNCTION MOD(L-PR(3), 20) = 0
                 CALL "P6-DRAW" USING P6-EMITS WS-R
                 COMPUTE WS-N = FUNCTION INTEGER-PART(WS-R * 4) + 20
                 COMPUTE WS-V(1) = L-PP(1) + 0.5
                 COMPUTE WS-V(2) = L-PP(2) + 1
                 COMPUTE WS-V(3) = L-PP(3) + 0.5
                 PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-N
                     CALL "P6-EMIT" USING P6-EMITS WS-SMOKE WS-PV
                 END-PERFORM
             END-IF
     END-EVALUATE
     GOBACK.
 END PROGRAM P6-D-TRIAL-SPAWNER.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P6-D-MONSTER-SPAWNER.
*> 4.3 BaseSpawner.clientTick (PROPS 1: a player is near and a display entity exists): draws x, y, z (X + rd ...), `smoke` then `flame` there.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-SMOKE               PIC X(40) VALUE "smoke".
 01 WS-FLAME               PIC X(40) VALUE "flame".
 01 WS-R                   FLOAT-LONG.
 01 WS-A                   BINARY-LONG.
 01 WS-PV.
    05 WS-V                FLOAT-LONG OCCURS 6 TIMES.
 LINKAGE SECTION.
 COPY CLP6ARG.
 COPY CLP6EM.
 PROCEDURE DIVISION USING L-P L-PROPS P6-EMITS.
     IF L-PR(1) NOT = 0
         INITIALIZE WS-PV
         PERFORM VARYING WS-A FROM 1 BY 1 UNTIL WS-A > 3
             CALL "P6-DRAW" USING P6-EMITS WS-R
             COMPUTE WS-V(WS-A) = L-PP(WS-A) + WS-R
         END-PERFORM
         CALL "P6-EMIT" USING P6-EMITS WS-SMOKE WS-PV
         CALL "P6-EMIT" USING P6-EMITS WS-FLAME WS-PV
     END-IF
     GOBACK.
 END PROGRAM P6-D-MONSTER-SPAWNER.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P6-CAGE-POS.
*> 4.4 randomPosInsideCage (kind 0: P + (0.1 + rd * 0.8, 0.25 + rd * 0.5, 0.1 + rd * 0.8)) and randomPosCenterOfCage (kind 1: P + 0.4 + rd * 0.2
*> per axis): USING emits, block, kind, position out (three floats); three draws x, y, z.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-R                   FLOAT-LONG.
 LINKAGE SECTION.
 COPY CLP6EM.
 COPY CLP6ARG.
 01 L-KIND                 BINARY-LONG.
 01 L-OUT.
    05 L-O                 FLOAT-LONG OCCURS 3 TIMES.
 PROCEDURE DIVISION USING P6-EMITS L-P L-KIND L-OUT.
     CALL "P6-DRAW" USING P6-EMITS WS-R
     IF L-KIND = 0
         COMPUTE L-O(1) = L-PP(1) + 0.1 + WS-R * 0.8
     ELSE
         COMPUTE L-O(1) = L-PP(1) + 0.4 + WS-R * 0.2
     END-IF
     CALL "P6-DRAW" USING P6-EMITS WS-R
     IF L-KIND = 0
         COMPUTE L-O(2) = L-PP(2) + 0.25 + WS-R * 0.5
     ELSE
         COMPUTE L-O(2) = L-PP(2) + 0.4 + WS-R * 0.2
     END-IF
     CALL "P6-DRAW" USING P6-EMITS WS-R
     IF L-KIND = 0
         COMPUTE L-O(3) = L-PP(3) + 0.1 + WS-R * 0.8
     ELSE
         COMPUTE L-O(3) = L-PP(3) + 0.4 + WS-R * 0.2
     END-IF
     GOBACK.
 END PROGRAM P6-CAGE-POS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P6-D-VAULT.
*> 4.4 VaultBlockEntity$Client (PROPS 1 mode 0 idle / 1 activation / 2 deactivation, 2 display item, 3 ominous): idle: draw rf <= 0.5: p = randomPosInsideCage,
*> `smoke` at p and (with a display item) the flame (`small_flame`, ominous `soul_fire_flame`); activation: 20 times `smoke` then the flame at a cage position;
*> deactivation: 20 times a centre-of-cage position, then three Gaussian draws * 0.02 as the velocity: the flame.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-SMOKE               PIC X(40) VALUE "smoke".
 01 WS-FLAME               PIC X(40).
 01 WS-R                   FLOAT-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-A                   BINARY-LONG.
 01 WS-KIND                BINARY-LONG.
 01 WS-POS.
    05 WS-PO               FLOAT-LONG OCCURS 3 TIMES.
 01 WS-PV.
    05 WS-V                FLOAT-LONG OCCURS 6 TIMES.
 LINKAGE SECTION.
 COPY CLP6ARG.
 COPY CLP6EM.
 PROCEDURE DIVISION USING L-P L-PROPS P6-EMITS.
     IF L-PR(3) NOT = 0
         MOVE "soul_fire_flame" TO WS-FLAME
     ELSE
         MOVE "small_flame" TO WS-FLAME
     END-IF
     INITIALIZE WS-PV
     EVALUATE L-PR(1)
         WHEN 0
             CALL "P6-DRAW" USING P6-EMITS WS-R
             IF WS-R <= 0.5
                 MOVE 0 TO WS-KIND
                 CALL "P6-CAGE-POS" USING P6-EMITS L-P WS-KIND WS-POS
                 MOVE WS-PO(1) TO WS-V(1)
                 MOVE WS-PO(2) TO WS-V(2)
                 MOVE WS-PO(3) TO WS-V(3)
                 CALL "P6-EMIT" USING P6-EMITS WS-SMOKE WS-PV
                 IF L-PR(2) NOT = 0
                     CALL "P6-EMIT" USING P6-EMITS WS-FLAME WS-PV
                 END-IF
             END-IF
         WHEN 1
             PERFORM 20 TIMES
                 MOVE 0 TO WS-KIND
                 CALL "P6-CAGE-POS" USING P6-EMITS L-P WS-KIND WS-POS
                 MOVE WS-PO(1) TO WS-V(1)
                 MOVE WS-PO(2) TO WS-V(2)
                 MOVE WS-PO(3) TO WS-V(3)
                 CALL "P6-EMIT" USING P6-EMITS WS-SMOKE WS-PV
                 CALL "P6-EMIT" USING P6-EMITS WS-FLAME WS-PV
             END-PERFORM
         WHEN 2
             PERFORM 20 TIMES
                 MOVE 1 TO WS-KIND
                 CALL "P6-CAGE-POS" USING P6-EMITS L-P WS-KIND WS-POS
                 MOVE WS-PO(1) TO WS-V(1)
                 MOVE WS-PO(2) TO WS-V(2)
                 MOVE WS-PO(3) TO WS-V(3)
                 PERFORM VARYING WS-A FROM 4 BY 1 UNTIL WS-A > 6
                     CALL "P6-DRAW" USING P6-EMITS WS-R
                     COMPUTE WS-V(WS-A) = WS-R * 0.02
                 END-PERFORM
                 CALL "P6-EMIT" USING P6-EMITS WS-FLAME WS-PV
             END-PERFORM
     END-EVALUATE
     GOBACK.
 END PROGRAM P6-D-VAULT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P6-VAULT-CONNECT.
*> 4.4 connection particles: USING keyhole (three floats), target (the connected player's position + (0, height / 2, 0)), emits: draw k = Mth.nextInt(2, 5) =
*> 2 + floor(r * 4); per particle three offsetRandom(1.0) draws; `vault_connection` at the keyhole with velocity target - keyhole + offset.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-N                   PIC X(40) VALUE "vault_connection".
 01 WS-R                   FLOAT-LONG.
 01 WS-K                   FLOAT-LONG VALUE 1.0.
 01 WS-COUNT               BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-A                   BINARY-LONG.
 01 WS-OFF.
    05 WS-O                FLOAT-LONG OCCURS 3 TIMES.
 01 WS-PV.
    05 WS-V                FLOAT-LONG OCCURS 6 TIMES.
 LINKAGE SECTION.
 01 L-KEY.
    05 L-KH                FLOAT-LONG OCCURS 3 TIMES.
 01 L-TARGET.
    05 L-TG                FLOAT-LONG OCCURS 3 TIMES.
 COPY CLP6EM.
 PROCEDURE DIVISION USING L-KEY L-TARGET P6-EMITS.
     CALL "P6-DRAW" USING P6-EMITS WS-R
     COMPUTE WS-COUNT = 2 + FUNCTION INTEGER-PART(WS-R * 4)
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-COUNT
         CALL "P6-OFFSET-RANDOM" USING P6-EMITS WS-K WS-OFF
         PERFORM VARYING WS-A FROM 1 BY 1 UNTIL WS-A > 3
             MOVE L-KH(WS-A) TO WS-V(WS-A)
             COMPUTE WS-V(WS-A + 3) = L-TG(WS-A) - L-KH(WS-A) + WS-O(WS-A)
         END-PERFORM
         CALL "P6-EMIT" USING P6-EMITS WS-N WS-PV
     END-PERFORM
     GOBACK.
 END PROGRAM P6-VAULT-CONNECT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P6-NOXIOUS-SOURCE.
*> 4.6 findNoxiousGasSource: USING water-source flags (cells P + 1 to P + 5), passable flags (air, the water block or an empty collision shape), dy out
*> (0 none, 1-5): a water source with a passable block continues; a cell that is not a water source and is passable is the source; any other cell
*> ends the scan; running out of cells gives none.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-I                   BINARY-LONG.
 01 WS-DONE                BINARY-LONG.
 LINKAGE SECTION.
 01 L-WS.
    05 L-W                 BINARY-LONG OCCURS 5 TIMES.
 01 L-PASS.
    05 L-PA                BINARY-LONG OCCURS 5 TIMES.
 01 L-DY                   BINARY-LONG.
 PROCEDURE DIVISION USING L-WS L-PASS L-DY.
     MOVE 0 TO L-DY
     MOVE 0 TO WS-DONE
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 5 OR WS-DONE = 1
         EVALUATE TRUE
             WHEN L-W(WS-I) NOT = 0 AND L-PA(WS-I) NOT = 0
                 CONTINUE
             WHEN L-W(WS-I) = 0 AND L-PA(WS-I) NOT = 0
                 MOVE WS-I TO L-DY
                 MOVE 1 TO WS-DONE
             WHEN OTHER
                 MOVE 1 TO WS-DONE
         END-EVALUATE
     END-PERFORM
     GOBACK.
 END PROGRAM P6-NOXIOUS-SOURCE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P6-D-SULFUR.
*> 4.6 client tickers of the potent sulfur block: kind 0 noxious gas (PROPS 1 game time, 2 source found, 3-5 the source): every 20 game ticks
*> `noxious_gas_cloud` at the source centre; kind 1 geyser plume (PROPS 1 game time, 2 eruption tick, 3 found, 4-6 source, 7 continuous): t = time
*> - eruption tick; t mod 20 = 0: `geyser` at (sx + 0.5, sy, sz + 0.5) with the option height sy - Y - 1 (EM-STATE); t mod 40 = 0: the sound
*> `geyser_eruption_active` (`geyser_eruption_continuous`) at the source centre.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-CLOUD               PIC X(40) VALUE "noxious_gas_cloud".
 01 WS-GEYSER              PIC X(40) VALUE "geyser".
 01 WS-SOUND               PIC X(40).
 01 WS-T                   BINARY-LONG.
 01 WS-ZERO-C              BINARY-DOUBLE VALUE 0.
 01 WS-ZERO-S              FLOAT-LONG VALUE 0.
 01 WS-H                   BINARY-LONG.
 01 WS-PV.
    05 WS-V                FLOAT-LONG OCCURS 6 TIMES.
 LINKAGE SECTION.
 COPY CLP6ARG.
 01 L-KIND                 BINARY-LONG.
 COPY CLP6EM.
 PROCEDURE DIVISION USING L-P L-PROPS L-KIND P6-EMITS.
     INITIALIZE WS-PV
     IF L-KIND = 0
         IF FUNCTION MOD(L-PR(1), 20) = 0 AND L-PR(2) NOT = 0
             COMPUTE WS-V(1) = L-PR(3) + 0.5
             COMPUTE WS-V(2) = L-PR(4) + 0.5
             COMPUTE WS-V(3) = L-PR(5) + 0.5
             CALL "P6-EMIT" USING P6-EMITS WS-CLOUD WS-PV
         END-IF
     ELSE
         IF L-PR(3) NOT = 0
             COMPUTE WS-T = L-PR(1) - L-PR(2)
             IF FUNCTION MOD(WS-T, 20) = 0
                 COMPUTE WS-V(1) = L-PR(4) + 0.5
                 COMPUTE WS-V(2) = L-PR(5)
                 COMPUTE WS-V(3) = L-PR(6) + 0.5
                 COMPUTE WS-H = L-PR(5) - L-PP(2) - 1
                 CALL "P6-EMIT" USING P6-EMITS WS-GEYSER WS-PV
                 CALL "P6-EMIT-OPTION" USING P6-EMITS WS-ZERO-C WS-ZERO-S WS-H
             END-IF
             IF FUNCTION MOD(WS-T, 40) = 0
                 IF L-PR(7) NOT = 0
                     MOVE "geyser_eruption_continuous" TO WS-SOUND
                 ELSE
                     MOVE "geyser_eruption_active" TO WS-SOUND
                 END-IF
                 CALL "P6-EMIT-SOUND" USING P6-EMITS WS-SOUND
             END-IF
         END-IF
     END-IF
     GOBACK.
 END PROGRAM P6-D-SULFUR.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P6-BE-TICK.
*> Section 4: USING class (PIC X(24): campfire_entity, trial_spawner, monster_spawner, vault, noxious_gas, geyser_plume), block position, PROPS, emits.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 LINKAGE SECTION.
 01 L-CLASS                PIC X(24).
 COPY CLP6ARG.
 COPY CLP6EM.
 PROCEDURE DIVISION USING L-CLASS L-P L-PROPS P6-EMITS.
     MOVE 0 TO EM-COUNT EM-CUR EM-SOUND-COUNT
     EVALUATE L-CLASS
         WHEN "campfire_entity"
             CALL "P6-D-CAMPFIRE" USING L-P L-PROPS P6-EMITS
         WHEN "trial_spawner"
             CALL "P6-D-TRIAL-SPAWNER" USING L-P L-PROPS P6-EMITS
         WHEN "monster_spawner"
             CALL "P6-D-MONSTER-SPAWNER" USING L-P L-PROPS P6-EMITS
         WHEN "vault"
             CALL "P6-D-VAULT" USING L-P L-PROPS P6-EMITS
         WHEN "noxious_gas"
             CALL "P6-D-SULFUR" USING L-P L-PROPS WS-ZERO P6-EMITS
         WHEN "geyser_plume"
             CALL "P6-D-SULFUR" USING L-P L-PROPS WS-ONE P6-EMITS
     END-EVALUATE
     GOBACK.
 END PROGRAM P6-BE-TICK.
