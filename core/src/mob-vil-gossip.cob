*> Live gossip and the reputation price of villagers (docs/protocol/19 sections 22.4 and 22.5; lane 002-lane-mobsb2, T7102). The rules are VIL-GOSSIP-ADD, VIL-GOSSIP-DECAY,
*> VIL-REPUTATION and VIL-SPECIAL of mob-19-22.cob; the state is VILGOSSIP.cpy. Gaps: the exchange of gossip between villagers, the VILLAGER_KILLED event to the villagers nearby,
*> golems and villagers as targets, (the Hero of the Village discount is read from the player's effect, T8103).
*>
*>   VG-FIND USING villager id, target id, create (0/1), slot out     the entry of a pair (0 none)
*>   VG-ADD USING villager id, target id, type (1 to 5), amount       adds to a gossip value (cap and drop rules of 22.5)
*>   VG-REP USING villager id, target id, reputation out              the weighted sum
*>   VG-EVENT USING villager id, target id, event                     1 zombie villager cured, 2 trade, 3 villager hurt, 4 villager killed (22.5)
*>   VG-FORGET USING villager id                                      the villager is gone
*>   VL-SPECIALS USING villager slot, player row                      updateSpecialPrices: the special price of every offer for this player
*>   VL-TICK USING villager slot                                      the daily decay of the gossip

 IDENTIFICATION DIVISION.
 PROGRAM-ID. VG-FIND.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY VILGOSSIP.
 01 WS-I                    BINARY-LONG.
 LINKAGE SECTION.
 01 L-VIL                   BINARY-LONG.
 01 L-TARGET                BINARY-LONG.
 01 L-CREATE                BINARY-LONG.
 01 L-SLOT                  BINARY-LONG.
 PROCEDURE DIVISION USING L-VIL L-TARGET L-CREATE L-SLOT.
     MOVE 0 TO L-SLOT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > GS-MAX OR L-SLOT > 0
         IF GS-VIL(WS-I) = L-VIL AND GS-TARGET(WS-I) = L-TARGET
             MOVE WS-I TO L-SLOT
         END-IF
     END-PERFORM
     IF L-SLOT = 0 AND L-CREATE = 1
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > GS-MAX OR L-SLOT > 0
             IF GS-VIL(WS-I) = 0
                 INITIALIZE GS-ENTRY(WS-I)
                 MOVE L-VIL TO GS-VIL(WS-I)
                 MOVE L-TARGET TO GS-TARGET(WS-I)
                 MOVE WS-I TO L-SLOT
             END-IF
         END-PERFORM
     END-IF
     GOBACK.
 END PROGRAM VG-FIND.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. VG-ADD.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY VILGOSSIP.
 01 WS-SLOT                 BINARY-LONG.
 01 WS-YES                  BINARY-LONG VALUE 1.
 01 WS-NEW                  BINARY-LONG.
 LINKAGE SECTION.
 01 L-VIL                   BINARY-LONG.
 01 L-TARGET                BINARY-LONG.
 01 L-TYPE                  BINARY-LONG.
 01 L-AMOUNT                BINARY-LONG.
 PROCEDURE DIVISION USING L-VIL L-TARGET L-TYPE L-AMOUNT.
     CALL "VG-FIND" USING L-VIL L-TARGET WS-YES WS-SLOT
     IF WS-SLOT > 0
         CALL "VIL-GOSSIP-ADD" USING L-TYPE GS-V(WS-SLOT, L-TYPE) L-AMOUNT WS-NEW
         MOVE WS-NEW TO GS-V(WS-SLOT, L-TYPE)
     END-IF
     GOBACK.
 END PROGRAM VG-ADD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. VG-REP.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY VILGOSSIP.
 01 WS-SLOT                 BINARY-LONG.
 01 WS-NO                   BINARY-LONG VALUE 0.
 LINKAGE SECTION.
 01 L-VIL                   BINARY-LONG.
 01 L-TARGET                BINARY-LONG.
 01 L-REP                   BINARY-LONG.
 PROCEDURE DIVISION USING L-VIL L-TARGET L-REP.
     MOVE 0 TO L-REP
     CALL "VG-FIND" USING L-VIL L-TARGET WS-NO WS-SLOT
     IF WS-SLOT > 0
         CALL "VIL-REPUTATION" USING GS-ENTRY(WS-SLOT)(9:20) L-REP
     END-IF
     GOBACK.
 END PROGRAM VG-REP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. VG-EVENT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-T                    BINARY-LONG.
 01 WS-A                    BINARY-LONG.
 LINKAGE SECTION.
 01 L-VIL                   BINARY-LONG.
 01 L-TARGET                BINARY-LONG.
 01 L-EVENT                 BINARY-LONG.
 PROCEDURE DIVISION USING L-VIL L-TARGET L-EVENT.
     EVALUATE L-EVENT
         WHEN 1
             MOVE 4 TO WS-T
             MOVE 20 TO WS-A
             CALL "VG-ADD" USING L-VIL L-TARGET WS-T WS-A
             MOVE 3 TO WS-T
             MOVE 25 TO WS-A
             CALL "VG-ADD" USING L-VIL L-TARGET WS-T WS-A
         WHEN 2
             MOVE 5 TO WS-T
             MOVE 2 TO WS-A
             CALL "VG-ADD" USING L-VIL L-TARGET WS-T WS-A
         WHEN 3
             MOVE 2 TO WS-T
             MOVE 25 TO WS-A
             CALL "VG-ADD" USING L-VIL L-TARGET WS-T WS-A
         WHEN 4
             MOVE 1 TO WS-T
             MOVE 25 TO WS-A
             CALL "VG-ADD" USING L-VIL L-TARGET WS-T WS-A
     END-EVALUATE
     GOBACK.
 END PROGRAM VG-EVENT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. VG-FORGET.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY VILGOSSIP.
 01 WS-I                    BINARY-LONG.
 LINKAGE SECTION.
 01 L-VIL                   BINARY-LONG.
 PROCEDURE DIVISION USING L-VIL.
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > GS-MAX
         IF GS-VIL(WS-I) = L-VIL
             INITIALIZE GS-ENTRY(WS-I)
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM VG-FORGET.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. VL-SPECIALS.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY VILSTATE.
 01 WS-I                    BINARY-LONG.
 01 WS-REP                  BINARY-LONG.
 01 WS-HERO                 BINARY-LONG VALUE -1.
 01 WS-HERO-ID              BINARY-LONG VALUE 31.
 01 WS-HERO-TICKS           BINARY-LONG.
 01 WS-WANT                 PIC X(32).
 01 WS-EXTRA                PIC X(32).
 01 WS-GIVE                 PIC X(32).
 01 WS-WC                   BINARY-LONG.
 01 WS-EC                   BINARY-LONG.
 01 WS-GC                   BINARY-LONG.
 01 WS-MU                   BINARY-LONG.
 01 WS-XPV                  BINARY-LONG.
 01 WS-MULT                 BINARY-LONG.
 01 WS-MASK                 BINARY-LONG.
 01 WS-MOD                  BINARY-LONG.
 01 WS-BASE                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-SLOT                  BINARY-LONG.
 01 L-ROW                   BINARY-LONG.
 PROCEDURE DIVISION USING L-SLOT L-ROW.
     CALL "VG-REP" USING VL-ID(L-SLOT) PL-ENTITY-ID(L-ROW) WS-REP
*>   The Hero of the Village effect (id 31): the amplifier, -1 without it.
     CALL "EFFECT-LEVEL" USING L-ROW WS-HERO-ID WS-HERO WS-HERO-TICKS
     SUBTRACT 1 FROM WS-HERO
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > VL-O-N(L-SLOT)
         CALL "VIL-TRADE-ROW" USING VL-O-ROW(L-SLOT, WS-I) WS-WANT WS-WC WS-EXTRA WS-EC WS-GIVE WS-GC WS-MU WS-XPV WS-MULT WS-MASK WS-MOD
         COMPUTE WS-BASE = WS-WC + VL-O-EXTRA(L-SLOT, WS-I)
         CALL "VIL-SPECIAL" USING WS-REP WS-MULT WS-BASE WS-HERO VL-O-SPECIAL(L-SLOT, WS-I)
     END-PERFORM
     GOBACK.
 END PROGRAM VL-SPECIALS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. VL-TICK.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY VILSTATE.
 COPY VILGOSSIP.
 01 WS-I                    BINARY-LONG.
 01 WS-T                    BINARY-LONG.
 01 WS-NEW                  BINARY-LONG.
 LINKAGE SECTION.
 01 L-SLOT                  BINARY-LONG.
 PROCEDURE DIVISION USING L-SLOT.
*>   The first call only records the time (22.5 maybeDecayGossip).
     IF VL-LAST-DECAY(L-SLOT) = 0
         COMPUTE VL-LAST-DECAY(L-SLOT) = CW-TICKS
         GOBACK
     END-IF
     IF CW-TICKS - VL-LAST-DECAY(L-SLOT) >= 24000
         MOVE CW-TICKS TO VL-LAST-DECAY(L-SLOT)
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > GS-MAX
             IF GS-VIL(WS-I) = VL-ID(L-SLOT)
                 PERFORM VARYING WS-T FROM 1 BY 1 UNTIL WS-T > 5
                     IF GS-V(WS-I, WS-T) > 0
                         CALL "VIL-GOSSIP-DECAY" USING WS-T GS-V(WS-I, WS-T) WS-NEW
                         MOVE WS-NEW TO GS-V(WS-I, WS-T)
                     END-IF
                 END-PERFORM
             END-IF
         END-PERFORM
     END-IF
     GOBACK.
 END PROGRAM VL-TICK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. VL-HURT-BY.
*> USING entity row, attacker player row (0 none): VILLAGER_HURT (22.5) for a villager hurt by a player.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY VLMEM.
 01 WS-SLOT                 BINARY-LONG.
 01 WS-NO                   BINARY-LONG VALUE 0.
 01 WS-HURT                 BINARY-LONG VALUE 3.
 01 WS-NOW                  BINARY-LONG.
 01 WS-ID                   BINARY-LONG.
 01 WS-ZERO                 BINARY-LONG VALUE 0.
 01 WS-TTL                  BINARY-LONG VALUE 40.
 LINKAGE SECTION.
 01 L-ROW                   BINARY-LONG.
 01 L-ATTACKER              BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-ATTACKER.
     IF L-ATTACKER > 0
         CALL "VL-FIND" USING EN-ID(L-ROW) WS-NO WS-SLOT
         IF WS-SLOT > 0
             CALL "VG-EVENT" USING EN-ID(L-ROW) PL-ENTITY-ID(L-ATTACKER) WS-HURT
*>           The last damage source lives 40 ticks: hurt_by and hurt_by_entity (44 section 4.6; set at once, the 20 tick sensor scan is not waited for).
             MOVE CW-TICKS TO WS-NOW
             MOVE PL-ENTITY-ID(L-ATTACKER) TO WS-ID
             CALL "VM-NOTE-TTL" USING WS-SLOT MT-HURT-BY WS-NOW WS-ID WS-TTL
             CALL "VM-NOTE-TTL" USING WS-SLOT MT-HURT-BY-ENTITY WS-ID WS-ZERO WS-TTL
         END-IF
     END-IF
     GOBACK.
 END PROGRAM VL-HURT-BY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. VL-STEP.
*> USING entity row, asleep out (1 while the villager sleeps in its bed): the per-step upkeep of a villager (the daily gossip decay, the brain).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY VILSTATE.
 01 WS-SLOT                 BINARY-LONG.
 01 WS-NO                   BINARY-LONG VALUE 0.
 LINKAGE SECTION.
 01 L-ROW                   BINARY-LONG.
 01 L-ASLEEP                BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-ASLEEP.
     MOVE 0 TO L-ASLEEP
     CALL "VL-FIND" USING EN-ID(L-ROW) WS-NO WS-SLOT
     IF WS-SLOT > 0
         CALL "VL-TICK" USING WS-SLOT
         CALL "VL-SCAN" USING L-ROW
         CALL "VL-GIFT-TICK" USING L-ROW
         CALL "VL-BRAIN" USING L-ROW
         CALL "VL-BREED-STEP" USING L-ROW
         CALL "VL-GOLEM-STEP" USING L-ROW
         CALL "VL-GOSSIP-STEP" USING L-ROW
         CALL "VL-FEAR-STEP" USING L-ROW
         MOVE VL-SLEEP(WS-SLOT) TO L-ASLEEP
     END-IF
     GOBACK.
 END PROGRAM VL-STEP.
