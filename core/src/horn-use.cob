*> The use of a goat horn (docs/protocol/25 part 7 section 12.2 InstrumentItem.use, 17 section 3.x use_cooldown; CC-0014): HORN-ITEM-USE handles Use Item (0x43) for a goat_horn in the
*> hand that uses (hand 0 the held hotbar slot, hand 1 the off-hand). While the horn is on its cooldown the use is a PASS (nothing happens, not consumed). Else: the instrument's sound
*> event (the item's default instrument ponder_goat_horn: item.goat_horn.sound.0) is played at the player's position as a Sound packet (0x77) in source records (2), volume range / 16 =
*> 16.0, pitch 1.0, to every viewer except the player; the game event instrument_play is posted at the player with the player as the source; the horn gets an item cooldown of
*> floor(7.0 x 20) = 140 ticks (TS-HORN-COOLDOWN, CTOOLS.cpy), which the player is told with Cooldown (0x16: the group, here the item's registry key, and the ticks). Not done, waiting
*> for the clean-room documentation of the item in use (a gap named in CC-0014): the use state of 140 ticks (startUsingItem / stopUsingItem and their item_interact_* events), the
*> using-item flags of Set Entity Data entry 8 for viewers, and the instrument of a stack that carries an `instrument` component of another instrument than the default (no table of
*> the instrument entries to sound events is documented; every horn plays the default sound).
*> The use state (docs/protocol/58 sections 2.1 and 2.2; CC-0014 round 4): the use of a horn is LivingEntity.startUsingItem for 140 ticks (TS-HORN-USE-START, -HAND of CTOOLS.cpy), ignored while
*> another use (a bow, eating, a raised shield) is going, with item_interact_start at the player. The used hand's Set Equipment and the living entity flags (Set Entity Data entry 8: 1 using an item,
*> 2 the used hand is the off-hand) go to the viewers with the next tick (USE-FLAGS-SYNC, poses.cob; the stack keeps the instrument component of the prototype, 58 section 5.2). The use ends
*> at 140 ticks (completion), when the key is let go or the held slot changes (HUNGER-CANCEL, the shared stopUsingItem of play.cob and inventory.cob), or when the used hand no longer holds a
*> goat_horn (58 section 2.2); each end posts item_interact_finish at the player.
*>
*>   HORN-ITEM-USE USING connection id, PLAY-SERVERBOUND, done out (1 = the horn was played, 0 = the item is passed on)
*>   HORN-USE-STOP USING player row: ends the horn use when there is one (stopUsingItem: item_interact_finish)
*>   HORN-USE-TICK USING player row: the per tick rule of the horn use (the same item in the used hand, completion at 140 ticks), then USE-FLAGS-SYNC for every item in use

 IDENTIFICATION DIVISION.
 PROGRAM-ID. HORN-ITEM-USE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CTOOLS.
 COPY CMENU.
 COPY PROTO.
 01 WS-READY               PIC 9 VALUE 0.
 01 WS-CAPACITY            BINARY-LONG VALUE 64.
 01 WS-ROW                 BINARY-LONG.
 01 WS-SLOT                BINARY-LONG.
 01 WS-KEY                 PIC X(48).
 01 WS-REGISTRY            PIC X(48) VALUE "minecraft:sound_event".
 01 WS-SOUND               PIC X(112) VALUE "minecraft:item.goat_horn.sound.0".
 01 WS-SOUND-ID            BINARY-LONG.
 01 WS-STATUS              BINARY-LONG.
 01 WS-HOLDER              BINARY-LONG.
 01 WS-SOUND-PACKET        BINARY-LONG VALUE 119.
 01 WS-COOLDOWN-PACKET     BINARY-LONG VALUE 22.
 01 WS-SOURCE              BINARY-LONG VALUE 2.
 01 WS-VOLUME              FLOAT-SHORT VALUE 16.0.
 01 WS-PITCH               FLOAT-SHORT VALUE 1.0.
 01 WS-SEED                BINARY-DOUBLE VALUE 0.
 01 WS-GROUP               PIC X(20) VALUE "minecraft:goat_horn".
 01 WS-GROUP-LENGTH        BINARY-LONG VALUE 19.
 01 WS-TICKS               BINARY-LONG VALUE 140.
 01 WS-EVENT               PIC X(32) VALUE "instrument_play".
 01 WS-EV-START            PIC X(32) VALUE "item_interact_start".
 01 WS-ACTIVE              BINARY-LONG.
 01 WS-FLAGS               BINARY-LONG.
 01 WS-FX                  BINARY-LONG.
 01 WS-FY                  BINARY-LONG.
 01 WS-FZ                  BINARY-LONG.
 01 WS-BX                  BINARY-LONG.
 01 WS-BZ                  BINARY-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 LINKAGE SECTION.
 COPY PLAYPKT.
 01 L-ID                   BINARY-LONG.
 01 L-DONE                 BINARY-LONG.
 PROCEDURE DIVISION USING L-ID PLAY-SERVERBOUND L-DONE.
     MOVE 0 TO L-DONE
     MOVE CN-PLAYER(L-ID) TO WS-ROW
     IF PL-STATE(WS-ROW) NOT = PS-ALIVE OR PL-MODE(WS-ROW) = 3
         GOBACK
     END-IF
*>   The stack of the hand that uses: the held hotbar slot (hand 0) or the off-hand slot (hand 1).
     MOVE SPACES TO WS-KEY
     COMPUTE WS-SLOT = PL-HELD(WS-ROW) + 1
     IF PSB-HAND = 0 AND PL-SLOT-COUNT(WS-ROW, WS-SLOT) > 0
         CALL "TOOLUSE-KEY" USING PL-SLOT-ITEM(WS-ROW, WS-SLOT) WS-KEY
     END-IF
     IF PSB-HAND = 1 AND MN-EQUIP-COUNT(WS-ROW, 5) > 0
         CALL "TOOLUSE-KEY" USING MN-EQUIP-ITEM(WS-ROW, 5) WS-KEY
     END-IF
     IF WS-KEY NOT = "goat_horn"
         GOBACK
     END-IF
*>   An item on its cooldown cannot be used (ServerPlayerGameMode.useItem passes).
     CALL "COMBAT-TS-CHECK" USING WS-ROW
     IF CW-TICKS + 1 < TS-HORN-COOLDOWN(WS-ROW)
         GOBACK
     END-IF
     IF WS-READY = 0
         CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
         MOVE 1 TO WS-READY
     END-IF
*>   LivingEntity.startUsingItem (58 section 2.2): ignored while another item is in use; the equipment and flags packets follow with the next tick (USE-FLAGS-SYNC).
     CALL "USE-FLAGS-GET" USING WS-ROW WS-ACTIVE WS-FLAGS
     IF WS-ACTIVE = 0
         COMPUTE TS-HORN-USE-START(WS-ROW) = CW-TICKS + 1
         MOVE PSB-HAND TO TS-HORN-USE-HAND(WS-ROW)
         CALL "GAME-EVENT-AT" USING WS-EV-START PL-ENTITY-ROW(WS-ROW)
     END-IF
*>   The instrument's sound at the player's position (fixed point eighths), to the viewers except the player.
     CALL "CONTENT-STATIC-ID" USING WS-REGISTRY WS-SOUND WS-SOUND-ID WS-STATUS
     COMPUTE WS-HOLDER = WS-SOUND-ID + 1
     COMPUTE WS-FX = PL-X(WS-ROW) * 8
     COMPUTE WS-FY = PL-Y(WS-ROW) * 8
     COMPUTE WS-FZ = PL-Z(WS-ROW) * 8
     COMPUTE WS-BX = FUNCTION INTEGER(PL-X(WS-ROW))
     COMPUTE WS-BZ = FUNCTION INTEGER(PL-Z(WS-ROW))
     COMPUTE WS-CX = (WS-BX - FUNCTION MOD(WS-BX, 16)) / 16
     COMPUTE WS-CZ = (WS-BZ - FUNCTION MOD(WS-BZ, 16)) / 16
     CALL "PB-RESET" USING PB-BUFFER
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-SOUND-PACKET
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-HOLDER
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-SOURCE
     CALL "PB-PUT-INT" USING PB-BUFFER WS-FX
     CALL "PB-PUT-INT" USING PB-BUFFER WS-FY
     CALL "PB-PUT-INT" USING PB-BUFFER WS-FZ
     CALL "PB-PUT-FLOAT" USING PB-BUFFER WS-VOLUME
     CALL "PB-PUT-FLOAT" USING PB-BUFFER WS-PITCH
     CALL "PB-PUT-LONG" USING PB-BUFFER WS-SEED
     CALL "VIEWERS-SEND" USING PL-DIM(WS-ROW) WS-CX WS-CZ WS-ROW PB-BUFFER
*>   Game event instrument_play at the player, the player as the source (30 part 8 section 14).
     CALL "GAME-EVENT-AT" USING WS-EVENT PL-ENTITY-ROW(WS-ROW)
*>   The cooldown: floor(use_duration x 20) ticks on the item (its registry key is the group), told to the player.
     COMPUTE TS-HORN-COOLDOWN(WS-ROW) = CW-TICKS + 1 + WS-TICKS
     CALL "PB-RESET" USING PB-BUFFER
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-COOLDOWN-PACKET
     CALL "PB-PUT-IDENTIFIER" USING PB-BUFFER WS-GROUP WS-GROUP-LENGTH
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-TICKS
     CALL "CORE-SEND" USING PL-CONN(WS-ROW) PB-BUFFER
     MOVE 1 TO L-DONE
     GOBACK.
 END PROGRAM HORN-ITEM-USE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. HORN-USE-STOP.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CTOOLS.
 01 WS-EV-FINISH           PIC X(32) VALUE "item_interact_finish".
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     CALL "COMBAT-TS-CHECK" USING L-ROW
     IF TS-HORN-USE-START(L-ROW) > 0
         MOVE 0 TO TS-HORN-USE-START(L-ROW)
         CALL "GAME-EVENT-AT" USING WS-EV-FINISH PL-ENTITY-ROW(L-ROW)
     END-IF
     GOBACK.
 END PROGRAM HORN-USE-STOP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. HORN-USE-TICK.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CTOOLS.
 COPY CMENU.
 01 WS-SLOT                BINARY-LONG.
 01 WS-KEY                 PIC X(48).
 01 WS-DURATION            BINARY-LONG VALUE 140.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     CALL "COMBAT-TS-CHECK" USING L-ROW
     IF TS-HORN-USE-START(L-ROW) > 0
*>       The stack of the used hand must still be a goat_horn (58 section 2.2: a different item in the hand stops the use).
         MOVE SPACES TO WS-KEY
         COMPUTE WS-SLOT = PL-HELD(L-ROW) + 1
         IF TS-HORN-USE-HAND(L-ROW) = 0 AND PL-SLOT-COUNT(L-ROW, WS-SLOT) > 0
             CALL "TOOLUSE-KEY" USING PL-SLOT-ITEM(L-ROW, WS-SLOT) WS-KEY
         END-IF
         IF TS-HORN-USE-HAND(L-ROW) = 1 AND MN-EQUIP-COUNT(L-ROW, 5) > 0
             CALL "TOOLUSE-KEY" USING MN-EQUIP-ITEM(L-ROW, 5) WS-KEY
         END-IF
*>       Completion: the use duration floor(7.0 x 20) = 140 ticks has passed (completeUsingItem ends in stopUsingItem).
         IF WS-KEY NOT = "goat_horn" OR CW-TICKS + 1 >= TS-HORN-USE-START(L-ROW) + WS-DURATION
             CALL "HORN-USE-STOP" USING L-ROW
         END-IF
     END-IF
     CALL "USE-FLAGS-SYNC" USING L-ROW
     GOBACK.
 END PROGRAM HORN-USE-TICK.
