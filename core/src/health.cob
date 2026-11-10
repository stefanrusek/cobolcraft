*> Health, damage, death and respawn (US7; standin-content §10; data-model §6;
*> docs/protocol/09-cobolcraft-profile.md §3.3 Health rows, §3.2 row 0x7C death message; 05a, 05b,
*> 05c).
*>
*> Health is kept in PL-HEALTH (0 to 20, 17 section 4.10). Only survival players are hurt: a player in
*> creative takes no damage from any cause and keeps the health it had (US7-6, US7 edge case), and
*> only survival players are sent Set Health.
*>
*> Damage (HEALTH-DAMAGE, 17 section 4.7): an alive survival player is hurt by a hit when its
*> invulnerable time (PL-HURT-COOLDOWN) is at most 10: it loses the amount (never below 0), lastHurt
*> (PL-LAST-HURT) is the amount and the time becomes 20; the player and every player that has its
*> entity are sent Damage Event (the cause's damage type, §10.3; source ids = attacker entity id +
*> 1, or 0 without an attacker) and Hurt Animation. While the time is above 10 a hit of at most
*> lastHurt is ignored and a stronger one loses only the excess (no events, no new window). Every
*> accepted hit adds the damage type's exhaustion (RULES.cpy) and the player is sent Set Health. At
*> 0 the player dies (HEALTH-DIE). Fall damage is applied by MOVE-PLAYER (core/src/movement.cob).
*>
*> Attack (HEALTH-ATTACK, 05c 0x01, §10.4): from an alive attacker, on an alive player of the same
*> dimension (not the attacker) or a mob of that dimension, whose collision box is within 4.0
*> blocks of the attacker's eye point (feet + (0, 1.6, 0)) at its nearest point; it does the held
*> item's attack damage (ITEMS.cpy IT-ATTACK, the bare hand 1), to a player only when
*> `player-combat` is on. A ground item, an unknown entity or a target out of reach is not hit.
*>
*> Mob damage (HEALTH-MOB-DAMAGE, 17 section 4.7, US9-4, §14.6): a mob takes the same hurt window
*> (EN-HURT, EN-LAST-HURT) as a player; on a fresh hit it loses the amount (never below 0); its viewers are sent Damage Event (the
*> cause's damage type: player_attack for a player's hit, hail for hail; source id = attacker entity
*> id + 1, or 0 without an attacker) and Hurt Animation; a mob that can flee (MOBS.cpy MB-FLEE-MILLI
*> above 0: the sodgrazer) flees from an attacker for 40 ticks (§12.3); at 0 health it is defeated
*> (MOB-DEFEAT, core/src/mobs.cob).
*>
*> Recovery (HEALTH-TICK, step 4 of §9.5): every tick the hurt window of each alive player
*> decreases, then the hunger rules run (HUNGER-TICK, core/src/hunger.cob: eating, the FoodData tick
*> with natural regeneration and starvation, 17 section 4.9); last, hail (WEATHER-HAIL-PLAYER,
*> core/src/weather.cob, §14.6). A hit adds 0.1 exhaustion to the attacker (17 section 4.9).
*>
*> Death (HEALTH-DIE, §10.6): the player is dead (PS-DEAD, PL-DEATH-CAUSE); a survival break in
*> progress ends, eating stops and the sprinting flag and starvation count are cleared; the player is sent Player Combat Kill and every player in play, in any dimension,
*> System Chat with the death message (§10.7, a `translate` component with literal arguments);
*> every non-empty inventory slot s (ascending) becomes a ground item of its whole stack at the feet
*> + (0, 0.5, 0) with motion (((s mod 6) x 2 - 5) x 0.02, 0.2, (((s div 6) mod 6) x 2 - 5) x 0.02)
*> and pickup delay 30, and the emptied inventory is sent (Container Set Content). The dimension,
*> position and game mode stay as they are until respawn. A player who left while dead is dead again
*> on the next join and is sent Player Combat Kill after the join sequence (HEALTH-DEATH-SCREEN,
*> core/src/players.cob keeps the death).
*>
*> Respawn (HEALTH-RESPAWN, Client Command 0x0C action 0 from a dead player): health 20, food 20,
*> saturation 5.0, exhaustion 0, every counter 0, the world spawn point and yaw in cobolcraft:main; game mode, held
*> slot and inventory unchanged. The player is sent Respawn (data to keep 0x00), Player Abilities and
*> the arrival part of the join sequence (PLAY-ARRIVE); its entity moves to the spawn point for the
*> others and the player is sent the entities it now sees.
*>
*> Entry points:
*>   HEALTH-DAMAGE USING player row, amount, cause (RULES.cpy CAUSE-*), attacker entity id (0 none),
*>     attacker player row (0 none)                       (BINARY-LONG each)
*>   HEALTH-DIE USING player row, cause, attacker player row (0 none)
*>   HEALTH-ATTACK USING connection id, PLAY-SERVERBOUND  Attack
*>   HEALTH-MOB-DAMAGE USING mob tracker row, amount, cause, attacker player row (0 none)
*>     (BINARY-LONG each)
*>   HEALTH-RESPAWN USING connection id, PLAY-SERVERBOUND Client Command
*>   HEALTH-TICK                                          the per-tick rules (CORE-TICK)
*>   HEALTH-SEND USING player row                         Set Health to the player
*>   HEALTH-DEATH-SCREEN USING player row                 Player Combat Kill of its death
*>   HEALTH-VIEWERS-SEND USING entity row, PB-BUFFER      to every player that has the entity
*> Builders (append id + body to the caller's PB-BUFFER; DEATH-TEXT-BUILD fills a PB-TEXT):
*>   SET-HEALTH-BUILD USING health (FLOAT-SHORT), food (BINARY-LONG), saturation (FLOAT-SHORT), PB-BUFFER
*>   DAMAGE-EVENT-BUILD USING entity id, damage type, source id, PB-BUFFER
*>   HURT-ANIMATION-BUILD USING entity id, PB-BUFFER
*>   COMBAT-KILL-BUILD USING entity id, PB-TEXT, PB-BUFFER
*>   DEATH-TEXT-BUILD USING cause, victim name (PIC X(16)), length, attacker name, length, PB-TEXT

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SET-HEALTH-BUILD.
*> USING health (FLOAT-SHORT), food (BINARY-LONG), saturation (FLOAT-SHORT), PB-BUFFER: Set Health
*> 0x6A (05b; 09 §3.3): Float health, VarInt food, Float saturation.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-PACKET-ID           BINARY-LONG VALUE 106.
 LINKAGE SECTION.
 COPY PROTO.
 01 L-HEALTH               FLOAT-SHORT.
 01 L-FOOD                 BINARY-LONG.
 01 L-SATURATION           FLOAT-SHORT.
 PROCEDURE DIVISION USING L-HEALTH L-FOOD L-SATURATION PB-BUFFER.
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-PACKET-ID
     CALL "PB-PUT-FLOAT" USING PB-BUFFER L-HEALTH
     CALL "PB-PUT-VARINT" USING PB-BUFFER L-FOOD
     CALL "PB-PUT-FLOAT" USING PB-BUFFER L-SATURATION
     GOBACK.
 END PROGRAM SET-HEALTH-BUILD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. DAMAGE-EVENT-BUILD.
*> USING entity id, damage type id, source id (BINARY-LONG), PB-BUFFER: Damage Event 0x19 (05a;
*> 09 §3.3): entity id, damage type, source cause id and source direct id (both the source id),
*> source position absent.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-PACKET-ID           BINARY-LONG VALUE 25.
 01 WS-ABSENT              BINARY-LONG VALUE 0.
 LINKAGE SECTION.
 COPY PROTO.
 01 L-ENTITY-ID            BINARY-LONG.
 01 L-TYPE                 BINARY-LONG.
 01 L-SOURCE               BINARY-LONG.
 PROCEDURE DIVISION USING L-ENTITY-ID L-TYPE L-SOURCE PB-BUFFER.
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-PACKET-ID
     CALL "PB-PUT-VARINT" USING PB-BUFFER L-ENTITY-ID
     CALL "PB-PUT-VARINT" USING PB-BUFFER L-TYPE
     CALL "PB-PUT-VARINT" USING PB-BUFFER L-SOURCE
     CALL "PB-PUT-VARINT" USING PB-BUFFER L-SOURCE
     CALL "PB-PUT-BOOL" USING PB-BUFFER WS-ABSENT
     GOBACK.
 END PROGRAM DAMAGE-EVENT-BUILD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. HURT-ANIMATION-BUILD.
*> USING entity id (BINARY-LONG), PB-BUFFER: Hurt Animation 0x2B (05a; 09 §3.3): entity id, yaw 0.0.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-PACKET-ID           BINARY-LONG VALUE 43.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 LINKAGE SECTION.
 COPY PROTO.
 01 L-ENTITY-ID            BINARY-LONG.
 PROCEDURE DIVISION USING L-ENTITY-ID PB-BUFFER.
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-PACKET-ID
     CALL "PB-PUT-VARINT" USING PB-BUFFER L-ENTITY-ID
     CALL "PB-PUT-FLOAT" USING PB-BUFFER WS-YAW
     GOBACK.
 END PROGRAM HURT-ANIMATION-BUILD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. COMBAT-KILL-BUILD.
*> USING entity id (BINARY-LONG), PB-TEXT, PB-BUFFER: Player Combat Kill 0x45 (05a; 09 §3.3): the
*> dead player's entity id and the death message as network NBT (09 §1).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-PACKET-ID           BINARY-LONG VALUE 69.
 LINKAGE SECTION.
 COPY PROTO.
 01 L-ENTITY-ID            BINARY-LONG.
 PROCEDURE DIVISION USING L-ENTITY-ID PB-TEXT PB-BUFFER.
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-PACKET-ID
     CALL "PB-PUT-VARINT" USING PB-BUFFER L-ENTITY-ID
     CALL "PB-PUT-TEXT" USING PB-BUFFER PB-TEXT
     GOBACK.
 END PROGRAM COMBAT-KILL-BUILD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. DEATH-TEXT-BUILD.
*> USING cause (BINARY-LONG, RULES.cpy CAUSE-*), victim name (PIC X(16)), its length, attacker name
*> (PIC X(16)), its length, PB-TEXT out: the cause's death message of MESSAGES.cpy, a `translate`
*> component whose arguments are the victim's and the attacker's names as the message lists them.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY MESSAGES.
 01 WS-I                   BINARY-LONG.
 LINKAGE SECTION.
 COPY PROTO.
 01 L-CAUSE                BINARY-LONG.
 01 L-VICTIM               PIC X(16).
 01 L-VICTIM-LENGTH        BINARY-LONG.
 01 L-ATTACKER             PIC X(16).
 01 L-ATTACKER-LENGTH      BINARY-LONG.
 PROCEDURE DIVISION USING L-CAUSE L-VICTIM L-VICTIM-LENGTH L-ATTACKER L-ATTACKER-LENGTH PB-TEXT.
     INITIALIZE PB-TEXT
     MOVE PB-TEXT-TRANSLATE TO PB-TX-KIND
     MOVE DTH-KEY(L-CAUSE) TO PB-TX-VALUE
     MOVE DTH-KEY-LENGTH(L-CAUSE) TO PB-TX-LENGTH
     MOVE DTH-ARG-COUNT(L-CAUSE) TO PB-TX-ARG-COUNT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > PB-TX-ARG-COUNT
         IF DTH-ARG-KIND(L-CAUSE, WS-I) = MSG-ARG-VICTIM
             MOVE L-VICTIM TO PB-TX-ARG-VALUE(WS-I)
             MOVE L-VICTIM-LENGTH TO PB-TX-ARG-LENGTH(WS-I)
         ELSE
             MOVE L-ATTACKER TO PB-TX-ARG-VALUE(WS-I)
             MOVE L-ATTACKER-LENGTH TO PB-TX-ARG-LENGTH(WS-I)
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM DEATH-TEXT-BUILD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. HEALTH-VIEWERS-SEND.
*> USING entity row (BINARY-LONG), PB-BUFFER: sends the packet to every player whose client has the
*> entity (CORE-VIEWS).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-PLAYER              BINARY-LONG.
 LINKAGE SECTION.
 COPY PROTO.
 01 L-ENTITY               BINARY-LONG.
 PROCEDURE DIVISION USING L-ENTITY PB-BUFFER.
     PERFORM VARYING WS-PLAYER FROM 1 BY 1 UNTIL WS-PLAYER > CORE-MAX-PLAYERS
         IF PL-USED(WS-PLAYER) = 1 AND VW-SEEN(WS-PLAYER)(L-ENTITY:1) = "1"
             CALL "CORE-SEND" USING PL-CONN(WS-PLAYER) PB-BUFFER
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM HEALTH-VIEWERS-SEND.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. HEALTH-SEND.
*> USING player row (BINARY-LONG): Set Health of the player's health, food and saturation to the player.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY PROTO.
 01 WS-CAPACITY            BINARY-LONG VALUE 32.
 01 WS-SATURATION          FLOAT-SHORT.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     MOVE PL-SATURATION(L-ROW) TO WS-SATURATION
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "SET-HEALTH-BUILD" USING PL-HEALTH(L-ROW) PL-FOOD(L-ROW) WS-SATURATION PB-BUFFER
     CALL "CORE-SEND" USING PL-CONN(L-ROW) PB-BUFFER
     CALL "PB-FREE" USING PB-BUFFER
     GOBACK.
 END PROGRAM HEALTH-SEND.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. HEALTH-DEATH-SCREEN.
*> USING player row (BINARY-LONG) of a dead player: Player Combat Kill with the message of its death
*> (PL-DEATH-CAUSE, PL-KILLER-*) to the player; it opens the death screen with that cause line.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY PROTO.
 01 WS-CAPACITY            BINARY-LONG VALUE 256.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     CALL "DEATH-TEXT-BUILD" USING PL-DEATH-CAUSE(L-ROW) PL-NAME(L-ROW) PL-NAME-LENGTH(L-ROW)
         PL-KILLER-NAME(L-ROW) PL-KILLER-LENGTH(L-ROW) PB-TEXT
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "COMBAT-KILL-BUILD" USING PL-ENTITY-ID(L-ROW) PB-TEXT PB-BUFFER
     CALL "CORE-SEND" USING PL-CONN(L-ROW) PB-BUFFER
     CALL "PB-FREE" USING PB-BUFFER
     GOBACK.
 END PROGRAM HEALTH-DEATH-SCREEN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. HEALTH-DIE.
*> USING player row, cause, attacker player row (0 = none) (BINARY-LONG each): the player dies (see
*> above); the death message is also queued as a console line (CONSOLE-TEXT, US13-3).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CMENU.
 COPY RULES.
 COPY PROTO.
 01 WS-CAPACITY            BINARY-LONG VALUE 256.
 01 WS-ROW                 BINARY-LONG.
 01 WS-ID                  BINARY-LONG.
 01 WS-S                   BINARY-LONG.
 01 WS-Q                   BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-VX                  FLOAT-LONG.
 01 WS-VY                  FLOAT-LONG.
 01 WS-VZ                  FLOAT-LONG.
 01 WS-ITEM                BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-DELAY               BINARY-LONG VALUE 30.
 01 WS-ITEM-ROW            BINARY-LONG.
 01 WS-THROW               BINARY-LONG VALUE 1.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-CAUSE                BINARY-LONG.
 01 L-ATTACKER             BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-CAUSE L-ATTACKER.
     MOVE L-ROW TO WS-ROW
     CALL "EFFECT-CLEAR-ALL" USING WS-ROW
     MOVE PS-DEAD TO PL-STATE(WS-ROW)
     MOVE L-CAUSE TO PL-DEATH-CAUSE(WS-ROW)
     MOVE SPACES TO PL-KILLER-NAME(WS-ROW)
     MOVE 0 TO PL-KILLER-LENGTH(WS-ROW)
     IF L-ATTACKER > 0
         MOVE PL-NAME(L-ATTACKER) TO PL-KILLER-NAME(WS-ROW)
         MOVE PL-NAME-LENGTH(L-ATTACKER) TO PL-KILLER-LENGTH(WS-ROW)
     END-IF
     CALL "BLOCK-BREAK-END" USING WS-ROW
     CALL "HUNGER-CANCEL" USING WS-ROW
     MOVE 0 TO PL-SPRINTING(WS-ROW)
     CALL "HEALTH-DEATH-SCREEN" USING WS-ROW
     CALL "DEATH-TEXT-BUILD" USING PL-DEATH-CAUSE(WS-ROW) PL-NAME(WS-ROW) PL-NAME-LENGTH(WS-ROW)
         PL-KILLER-NAME(WS-ROW) PL-KILLER-LENGTH(WS-ROW) PB-TEXT
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "SYSTEM-CHAT-BUILD" USING PB-TEXT PB-BUFFER
     PERFORM VARYING WS-ID FROM 1 BY 1 UNTIL WS-ID > CORE-MAX-CONNS
         IF CN-USED(WS-ID) = 1 AND CN-PHASE(WS-ID) = PH-PLAY AND CN-PLAYER(WS-ID) > 0
             CALL "CORE-SEND" USING WS-ID PB-BUFFER
         END-IF
     END-PERFORM
     CALL "PB-FREE" USING PB-BUFFER
     CALL "CONSOLE-TEXT" USING PB-TEXT
     MOVE PL-DIM(WS-ROW) TO WS-DIM
     MOVE PL-X(WS-ROW) TO WS-X
     COMPUTE WS-Y = PL-Y(WS-ROW) + RULE-DEATH-DY-MILLI / 1000
     MOVE PL-Z(WS-ROW) TO WS-Z
     COMPUTE WS-VY = RULE-DEATH-LIFT-MILLI / 1000
     PERFORM VARYING WS-S FROM 0 BY 1 UNTIL WS-S > 40
         MOVE 0 TO WS-COUNT
         IF WS-S < 36
             MOVE PL-SLOT-ITEM(WS-ROW, WS-S + 1) TO WS-ITEM
             MOVE PL-SLOT-COUNT(WS-ROW, WS-S + 1) TO WS-COUNT
             MOVE 0 TO PL-SLOT-ITEM(WS-ROW, WS-S + 1) PL-SLOT-COUNT(WS-ROW, WS-S + 1)
                 PL-SLOT-VAR(WS-ROW, WS-S + 1)
         ELSE
*>           Armor and the off-hand (container slots 36 to 40) are dropped like the rest of the inventory.
             MOVE MN-EQUIP-ITEM(WS-ROW, WS-S - 35) TO WS-ITEM
             MOVE MN-EQUIP-COUNT(WS-ROW, WS-S - 35) TO WS-COUNT
             MOVE 0 TO MN-EQUIP-ITEM(WS-ROW, WS-S - 35) MN-EQUIP-COUNT(WS-ROW, WS-S - 35)
                 MN-EQUIP-VAR(WS-ROW, WS-S - 35)
         END-IF
         IF WS-COUNT > 0
             COMPUTE WS-Q = WS-S / 6
             COMPUTE WS-VX = (FUNCTION MOD(WS-S, 6) * 2 - 5) * RULE-DEATH-SPREAD-MILLI / 1000
             COMPUTE WS-VZ = (FUNCTION MOD(WS-Q, 6) * 2 - 5) * RULE-DEATH-SPREAD-MILLI / 1000
             CALL "GI-SPAWN" USING WS-DIM WS-X WS-Y WS-Z WS-VX WS-VY WS-VZ WS-ITEM WS-COUNT
                 WS-DELAY WS-ITEM-ROW
         END-IF
     END-PERFORM
     CALL "MENU-RELEASE" USING WS-ROW WS-THROW
     COMPUTE PL-STATE-ID(WS-ROW) = FUNCTION MOD(PL-STATE-ID(WS-ROW) + 1, 32768)
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "PLAY-CONTENT-BUILD" USING WS-ROW PB-BUFFER
     CALL "CORE-SEND" USING PL-CONN(WS-ROW) PB-BUFFER
     CALL "PB-FREE" USING PB-BUFFER
     GOBACK.
 END PROGRAM HEALTH-DIE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. HEALTH-DAMAGE.
*> USING player row, amount, cause, attacker entity id (0 = none), attacker player row (0 = none)
*> (BINARY-LONG each): the damage rules above, in whole points: HEALTH-HURT (combat.cob) over thousandths.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-MILLI               BINARY-LONG.
 01 WS-RESULT              BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-AMOUNT               BINARY-LONG.
 01 L-CAUSE                BINARY-LONG.
 01 L-SOURCE               BINARY-LONG.
 01 L-ATTACKER             BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-AMOUNT L-CAUSE L-SOURCE L-ATTACKER.
     COMPUTE WS-MILLI = L-AMOUNT * 1000
     CALL "HEALTH-HURT" USING L-ROW WS-MILLI L-CAUSE L-SOURCE L-ATTACKER WS-RESULT
     GOBACK.
 END PROGRAM HEALTH-DAMAGE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. HEALTH-MOB-DAMAGE.
*> USING mob tracker row, amount, cause (RULES.cpy CAUSE-*), attacker player row (0 = none)
*> (BINARY-LONG each): the mob damage rules above.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY RULES.
 COPY MOBS.
 COPY PROTO.
 01 WS-CAPACITY            BINARY-LONG VALUE 64.
 01 WS-ROW                 BINARY-LONG.
 01 WS-SOURCE              BINARY-LONG.
 01 WS-APPLY               BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-AMOUNT               BINARY-LONG.
 01 L-CAUSE                BINARY-LONG.
 01 L-ATTACKER             BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-AMOUNT L-CAUSE L-ATTACKER.
     MOVE L-ROW TO WS-ROW
     IF EN-HURT(WS-ROW) > RULE-HURT-FRESH
         IF L-AMOUNT > EN-LAST-HURT(WS-ROW)
             COMPUTE WS-APPLY = L-AMOUNT - EN-LAST-HURT(WS-ROW)
             MOVE L-AMOUNT TO EN-LAST-HURT(WS-ROW)
             COMPUTE EN-HEALTH(WS-ROW) = FUNCTION MAX(0, EN-HEALTH(WS-ROW) - WS-APPLY)
             IF EN-HEALTH(WS-ROW) = 0
                 CALL "MOB-DEFEAT" USING WS-ROW
             END-IF
         END-IF
         GOBACK
     END-IF
     COMPUTE EN-HEALTH(WS-ROW) = FUNCTION MAX(0, EN-HEALTH(WS-ROW) - L-AMOUNT)
     MOVE L-AMOUNT TO EN-LAST-HURT(WS-ROW)
     MOVE RULE-HURT-WINDOW TO EN-HURT(WS-ROW)
     MOVE 0 TO WS-SOURCE
     IF L-ATTACKER > 0
         COMPUTE WS-SOURCE = PL-ENTITY-ID(L-ATTACKER) + 1
     END-IF
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "DAMAGE-EVENT-BUILD" USING EN-ID(WS-ROW) RULE-CAUSE-TYPE(L-CAUSE) WS-SOURCE
         PB-BUFFER
     CALL "HEALTH-VIEWERS-SEND" USING WS-ROW PB-BUFFER
     CALL "PB-RESET" USING PB-BUFFER
     CALL "HURT-ANIMATION-BUILD" USING EN-ID(WS-ROW) PB-BUFFER
     CALL "HEALTH-VIEWERS-SEND" USING WS-ROW PB-BUFFER
     CALL "PB-FREE" USING PB-BUFFER
     IF L-ATTACKER > 0 AND MB-FLEE-MILLI(EN-TYPE(WS-ROW) - MOB-FIRST-TYPE + 1) > 0
         MOVE MOB-FLEE-TICKS TO EN-FLEE(WS-ROW)
         MOVE L-ATTACKER TO EN-FLEE-PLAYER(WS-ROW)
         MOVE PL-ENTITY-ID(L-ATTACKER) TO EN-FLEE-ID(WS-ROW)
         MOVE PL-X(L-ATTACKER) TO EN-FLEE-X(WS-ROW)
         MOVE PL-Z(L-ATTACKER) TO EN-FLEE-Z(WS-ROW)
     END-IF
     IF EN-HEALTH(WS-ROW) = 0
         CALL "MOB-DEFEAT" USING WS-ROW
     END-IF
     GOBACK.
 END PROGRAM HEALTH-MOB-DAMAGE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. HEALTH-ATTACK.
*> USING connection id, PLAY-SERVERBOUND (a decoded Attack 0x01): the attack rules above.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY RULES.
 COPY CITEMS.
 COPY CONTENT.
 01 WS-ROW                 BINARY-LONG.
 01 WS-TARGET              BINARY-LONG.
 01 WS-ENTITY              BINARY-LONG.
 01 WS-E                   BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-ITEM                BINARY-LONG.
 01 WS-AMOUNT              BINARY-LONG.
 01 WS-CAUSE               BINARY-LONG.
 01 WS-EX                  FLOAT-LONG.
 01 WS-EY                  FLOAT-LONG.
 01 WS-EZ                  FLOAT-LONG.
 01 WS-TX                  FLOAT-LONG.
 01 WS-TY                  FLOAT-LONG.
 01 WS-TZ                  FLOAT-LONG.
 01 WS-HALF                FLOAT-LONG.
 01 WS-HEIGHT              FLOAT-LONG.
 01 WS-DX                  FLOAT-LONG.
 01 WS-DY                  FLOAT-LONG.
 01 WS-DZ                  FLOAT-LONG.
 01 WS-REACH               FLOAT-LONG.
 01 WS-EXHAUST             FLOAT-LONG.
 LINKAGE SECTION.
 COPY COREAPI.
 COPY PLAYPKT.
 01 L-ID                   BINARY-LONG.
 PROCEDURE DIVISION USING L-ID PLAY-SERVERBOUND.
     SET ADDRESS OF CORE-SETTINGS TO ADDRESS OF CW-SETTINGS
     MOVE CN-PLAYER(L-ID) TO WS-ROW
     IF PL-STATE(WS-ROW) NOT = PS-ALIVE
         GOBACK
     END-IF
     MOVE 0 TO WS-ENTITY
     PERFORM VARYING WS-E FROM 1 BY 1 UNTIL WS-E > EN-COUNT OR WS-ENTITY > 0
         IF EN-USED(WS-E) = 1 AND EN-ID(WS-E) = PSB-TARGET
             MOVE WS-E TO WS-ENTITY
         END-IF
     END-PERFORM
     IF WS-ENTITY = 0
         GOBACK
     END-IF
     MOVE EN-PLAYER(WS-ENTITY) TO WS-TARGET
     IF EN-TYPE(WS-ENTITY) = CR-LOOSE-ITEM OR WS-TARGET = WS-ROW
             OR EN-DIM(WS-ENTITY) NOT = PL-DIM(WS-ROW)
         GOBACK
     END-IF
     IF WS-TARGET > 0 AND PL-STATE(WS-TARGET) NOT = PS-ALIVE
         GOBACK
     END-IF
*>   Nearest point of the target's box to the eye point, then the distance to it.
     COMPUTE WS-TYPE = EN-TYPE(WS-ENTITY) + 1
     COMPUTE WS-HALF = ET-WIDTH-MILLI(WS-TYPE) / 2000
     COMPUTE WS-HEIGHT = ET-HEIGHT-MILLI(WS-TYPE) / 1000
     MOVE PL-X(WS-ROW) TO WS-EX
     COMPUTE WS-EY = PL-Y(WS-ROW) + RULE-ATTACK-EYE-MILLI / 1000
     MOVE PL-Z(WS-ROW) TO WS-EZ
     MOVE EN-X(WS-ENTITY) TO WS-TX
     MOVE EN-Y(WS-ENTITY) TO WS-TY
     MOVE EN-Z(WS-ENTITY) TO WS-TZ
     COMPUTE WS-DX = WS-EX - FUNCTION MAX(WS-TX - WS-HALF, FUNCTION MIN(WS-EX, WS-TX + WS-HALF))
     COMPUTE WS-DY = WS-EY - FUNCTION MAX(WS-TY, FUNCTION MIN(WS-EY, WS-TY + WS-HEIGHT))
     COMPUTE WS-DZ = WS-EZ - FUNCTION MAX(WS-TZ - WS-HALF, FUNCTION MIN(WS-EZ, WS-TZ + WS-HALF))
     COMPUTE WS-REACH = RULE-ATTACK-REACH-MILLI / 1000
     IF WS-DX * WS-DX + WS-DY * WS-DY + WS-DZ * WS-DZ > WS-REACH * WS-REACH
         GOBACK
     END-IF
     COMPUTE WS-EXHAUST = RULE-EXHAUST-ATTACK-MILLI / 1000
     CALL "HUNGER-EXHAUST" USING WS-ROW WS-EXHAUST
*>   The standard set: the tool rules of 17 section 4 (combat.cob COMBAT-ATTACK); the cobolcraft set keeps its stand-in damage below.
     IF CT-SET-TYPE NOT = CT-TYPE-COBOLCRAFT
         CALL "COMBAT-ATTACK" USING WS-ROW WS-ENTITY
         GOBACK
     END-IF
     MOVE 0 TO WS-ITEM
     IF PL-SLOT-COUNT(WS-ROW, PL-HELD(WS-ROW) + 1) > 0
         MOVE PL-SLOT-ITEM(WS-ROW, PL-HELD(WS-ROW) + 1) TO WS-ITEM
     END-IF
     MOVE IT-ATTACK(WS-ITEM + 1) TO WS-AMOUNT
     IF WS-TARGET = 0
         MOVE CAUSE-PLAYER TO WS-CAUSE
         CALL "HEALTH-MOB-DAMAGE" USING WS-ENTITY WS-AMOUNT WS-CAUSE WS-ROW
         GOBACK
     END-IF
     IF CS-PLAYER-COMBAT NOT = 1
         GOBACK
     END-IF
     MOVE CAUSE-PLAYER TO WS-CAUSE
     CALL "HEALTH-DAMAGE" USING WS-TARGET WS-AMOUNT WS-CAUSE PL-ENTITY-ID(WS-ROW) WS-ROW
     GOBACK.
 END PROGRAM HEALTH-ATTACK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. HEALTH-RESPAWN.
*> USING connection id, PLAY-SERVERBOUND (a decoded Client Command 0x0C): action 0 PERFORM_RESPAWN
*> from a dead player respawns it (see above); anything else does nothing.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY RULES.
 COPY DIMENSIONS.
 COPY PROTO.
 01 WS-CAPACITY            BINARY-LONG VALUE 128.
 01 WS-ROW                 BINARY-LONG.
 01 WS-KEEP                BINARY-LONG VALUE 0.
 01 WS-ON-GROUND           BINARY-LONG VALUE 1.
 LINKAGE SECTION.
 COPY PLAYPKT.
 01 L-ID                   BINARY-LONG.
 PROCEDURE DIVISION USING L-ID PLAY-SERVERBOUND.
     MOVE CN-PLAYER(L-ID) TO WS-ROW
     IF PSB-ACTION NOT = 0 OR PL-STATE(WS-ROW) NOT = PS-DEAD
         GOBACK
     END-IF
     CALL "MENU-FORCE-CLOSE" USING WS-ROW
     MOVE PS-ALIVE TO PL-STATE(WS-ROW)
     MOVE RULE-MAX-HEALTH TO PL-HEALTH(WS-ROW)
     MOVE RULE-MAX-FOOD TO PL-FOOD(WS-ROW)
     MOVE RULE-START-SATURATION TO PL-SATURATION(WS-ROW)
     MOVE 0 TO PL-EXHAUSTION(WS-ROW) PL-HURT-COOLDOWN(WS-ROW) PL-RECOVER-TICKS(WS-ROW)
         PL-DEATH-CAUSE(WS-ROW) PL-KILLER-LENGTH(WS-ROW) PL-SPRINTING(WS-ROW)
         PL-EATING-ITEM(WS-ROW) PL-FLYING(WS-ROW) PL-LAST-HURT(WS-ROW)
     MOVE SPACES TO PL-KILLER-NAME(WS-ROW)
     MOVE DIM-MAIN TO PL-DIM(WS-ROW)
     MOVE CW-SPAWN-X TO PL-X(WS-ROW)
     MOVE CW-SPAWN-Y TO PL-Y(WS-ROW) PL-FALL-START(WS-ROW)
     MOVE CW-SPAWN-Z TO PL-Z(WS-ROW)
     MOVE CW-SPAWN-YAW TO PL-YAW(WS-ROW)
     MOVE 0 TO PL-PITCH(WS-ROW)
     MOVE 1 TO PL-ON-GROUND(WS-ROW)
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "PLAY-RESPAWN-BUILD" USING PL-DIM(WS-ROW) PL-MODE(WS-ROW) WS-KEEP PB-BUFFER
     CALL "CORE-SEND" USING L-ID PB-BUFFER
     CALL "PB-RESET" USING PB-BUFFER
     CALL "PLAY-ABILITIES-BUILD" USING PL-MODE(WS-ROW) PL-FLYING(WS-ROW) PB-BUFFER
     CALL "CORE-SEND" USING L-ID PB-BUFFER
     CALL "PB-FREE" USING PB-BUFFER
     CALL "PLAY-ARRIVE" USING L-ID
     CALL "ENTITY-VIEWER-FORGET" USING WS-ROW
     MOVE PL-DIM(WS-ROW) TO EN-DIM(PL-ENTITY-ROW(WS-ROW))
     CALL "ENTITY-MOVE" USING PL-ENTITY-ROW(WS-ROW) PL-X(WS-ROW) PL-Y(WS-ROW) PL-Z(WS-ROW)
         PL-YAW(WS-ROW) PL-PITCH(WS-ROW) WS-ON-GROUND
     CALL "ENTITY-VIEWER-REFRESH" USING WS-ROW
     GOBACK.
 END PROGRAM HEALTH-RESPAWN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. HEALTH-TICK.
*> No parameters; called once per tick (step 4 of standin §9.5): the hurt cooldown and recovery
*> rules above, for every alive player (each player's rules touch only that player).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY RULES.
 01 WS-ROW                 BINARY-LONG.
 PROCEDURE DIVISION.
     PERFORM VARYING WS-ROW FROM 1 BY 1 UNTIL WS-ROW > CORE-MAX-PLAYERS
         IF PL-USED(WS-ROW) = 1 AND PL-STATE(WS-ROW) = PS-ALIVE
             IF PL-HURT-COOLDOWN(WS-ROW) > 0
                 SUBTRACT 1 FROM PL-HURT-COOLDOWN(WS-ROW)
             END-IF
             CALL "HUNGER-TICK" USING WS-ROW
         END-IF
         IF PL-USED(WS-ROW) = 1 AND PL-STATE(WS-ROW) = PS-ALIVE
             CALL "WEATHER-HAIL-PLAYER" USING WS-ROW
         END-IF
     END-PERFORM
     CALL "EFFECTS-TICK"
     GOBACK.
 END PROGRAM HEALTH-TICK.
