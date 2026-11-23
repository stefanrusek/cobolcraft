*> The spawn egg used on a mob of its own type (wrap I2 round 6, T24090; docs/protocol/18-mob-framework.md section 6.12, 25-item-registry-6 section 3.9, 44-residual-mob-questions-7-aquatic.md sections
*> 6.2, 8.2 and 10.1). SpawnEggItem.spawnOffspringFromSpawnEgg runs in Mob.interact step 1a, before the shears, the lead rules and mobInteract (44-7 section 10.3.1): for an ageable mob whose type is the
*> egg's, getBreedOffspring is asked with the clicked mob as both parents; a null result (a zombie nautilus, a parrot) ends the use with nothing spawned and the egg kept; the child is a baby (age
*> -24000) at the clicked mob's position with yaw 0, and one egg is used (not in creative mode). The clicked mob is not bred: no cooldown, no love, no hearts, no orb. MOB-INTERACT calls it
*> right after the name tag.
*>   MOB-EGG-KIND USING species, kind out         1 an ageable land animal (MOB-BREED-BABY), 2 an ageable water creature (squid, glow squid, dolphin, axolotl), 3 a nautilus (owner and tame copied), 0 no offspring
*>   EGG-AXOLOTL-VARIANT USING draw, parent variant, child variant out   Axolotl.getBreedOffspring (44-7 section 8.2): draw nextInt(1200) = 0 gives blue (EN-VARIANT 5), else the coin picks one of two
*>                                                copies of the clicked axolotl's variant (EN-VARIANT = 1 + the variant id)
*>   MOB-EGG-BABY USING player row, entity row, held key (PIC X(48)), used out   the rule above; used 1 when a baby was born
*> Not built (recorded on T24090): the villager (its offspring needs the village type roll of 19 section 22) and the zombie family's baby by the same rule for a non-ageable type (the egg's type is created
*> and setBaby(true) applied, 25-6 section 3.9); the frog, mule and the two skeleton and zombie horses are left out because no document states their getBreedOffspring result; the entity_data and the other
*> item components of the egg are not applied to the baby (as in TOOLUSE-EGG).

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MOB-EGG-KIND.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 LINKAGE SECTION.
 01 L-SPECIES              PIC X(24).
 01 L-KIND                 BINARY-LONG.
 PROCEDURE DIVISION USING L-SPECIES L-KIND.
     MOVE 0 TO L-KIND
     EVALUATE L-SPECIES
         WHEN "pig" WHEN "cow" WHEN "mooshroom" WHEN "sheep" WHEN "chicken" WHEN "horse" WHEN "donkey" WHEN "llama"
         WHEN "camel" WHEN "rabbit" WHEN "goat" WHEN "fox" WHEN "panda" WHEN "bee" WHEN "turtle" WHEN "wolf"
         WHEN "cat" WHEN "ocelot" WHEN "armadillo" WHEN "sniffer" WHEN "strider" WHEN "hoglin" WHEN "polar_bear"
             MOVE 1 TO L-KIND
         WHEN "squid" WHEN "glow_squid" WHEN "dolphin" WHEN "axolotl"
             MOVE 2 TO L-KIND
         WHEN "nautilus"
             MOVE 3 TO L-KIND
     END-EVALUATE
     GOBACK.
 END PROGRAM MOB-EGG-KIND.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EGG-AXOLOTL-VARIANT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 LINKAGE SECTION.
 01 L-DRAW                 BINARY-LONG.
 01 L-PARENT               BINARY-LONG.
 01 L-CHILD                BINARY-LONG.
 PROCEDURE DIVISION USING L-DRAW L-PARENT L-CHILD.
     MOVE L-PARENT TO L-CHILD
     IF L-DRAW = 0
         MOVE 5 TO L-CHILD
     END-IF
     GOBACK.
 END PROGRAM EGG-AXOLOTL-VARIANT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MOB-EGG-BABY.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CONTENT.
 01 WS-LEN                 BINARY-LONG.
 01 WS-POS                 BINARY-LONG.
 01 WS-EGG-SPECIES         PIC X(24).
 01 WS-KEY                 PIC X(24).
 01 WS-KIND                BINARY-LONG.
 01 WS-BABY                BINARY-LONG.
 01 WS-FULL                PIC X(112).
 01 WS-TYPE                BINARY-LONG.
 01 WS-ENTITY-ROW          PIC X(66).
 01 WS-STATUS              BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 01 WS-SALT                BINARY-LONG VALUE 35.
 01 WS-BOUND               BINARY-LONG VALUE 1200.
 01 WS-DRAW                BINARY-LONG.
 01 WS-VARIANT             BINARY-LONG.
 01 WS-SELF                BINARY-LONG.
 01 WS-FLAG-INDEX          BINARY-LONG VALUE 16.
 01 WS-BOOLEAN             BINARY-LONG VALUE 8.
 01 WS-TRUE                BINARY-LONG VALUE 1.
 LINKAGE SECTION.
 01 L-PLAYER               BINARY-LONG.
 01 L-ENTITY               BINARY-LONG.
 01 L-HELD                 PIC X(48).
 01 L-USED                 BINARY-LONG.
 PROCEDURE DIVISION USING L-PLAYER L-ENTITY L-HELD L-USED.
     MOVE 0 TO L-USED
*>   The held item must be <species>_spawn_egg, and the species the clicked mob's own.
     COMPUTE WS-LEN = FUNCTION LENGTH(FUNCTION TRIM(L-HELD)) - 10
     IF WS-LEN < 1 OR WS-LEN > 24
         GOBACK
     END-IF
     COMPUTE WS-POS = WS-LEN + 1
     IF L-HELD(WS-POS:10) NOT = "_spawn_egg"
         GOBACK
     END-IF
     MOVE SPACES TO WS-EGG-SPECIES
     MOVE L-HELD(1:WS-LEN) TO WS-EGG-SPECIES
     CALL "MOB-SPECIES-KEY" USING L-ENTITY WS-KEY
     IF WS-KEY NOT = WS-EGG-SPECIES
         GOBACK
     END-IF
     CALL "MOB-EGG-KIND" USING WS-KEY WS-KIND
     IF WS-KIND = 0
         GOBACK
     END-IF
     IF WS-KIND = 2
         MOVE SPACES TO WS-FULL
         STRING "minecraft:" DELIMITED BY SIZE WS-KEY DELIMITED BY SPACE INTO WS-FULL
         CALL "CONTENT-ENTITY-BY-KEY" USING WS-FULL WS-TYPE WS-ENTITY-ROW WS-STATUS
         MOVE EN-DIM(L-ENTITY) TO WS-DIM
         MOVE EN-X(L-ENTITY) TO WS-X
         MOVE EN-Y(L-ENTITY) TO WS-Y
         MOVE EN-Z(L-ENTITY) TO WS-Z
         CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-X WS-Y WS-Z WS-YAW WS-BABY
         CALL "M19-BABY-START-AGE" USING WS-KEY EN-MOBAGE(WS-BABY)
         IF WS-KEY = "axolotl"
*>           Axolotl.getBreedOffspring: the rare roll (8.2) and the variant of the clicked axolotl; the child is persistent.
             CALL "XP-RANDOM" USING WS-SALT WS-BOUND WS-DRAW
             CALL "EGG-AXOLOTL-VARIANT" USING WS-DRAW EN-VARIANT(L-ENTITY) WS-VARIANT
             MOVE WS-VARIANT TO EN-VARIANT(WS-BABY)
             MOVE EN-WOOL(L-ENTITY) TO EN-WOOL(WS-BABY)
             MOVE 1 TO EN-PERSISTENT(WS-BABY)
             CALL "AXOLOTL-DATA-SEND" USING WS-BABY
         ELSE
             CALL "AQUA-META-SEND" USING WS-BABY WS-FLAG-INDEX WS-BOOLEAN WS-TRUE
         END-IF
     ELSE
*>       The clicked mob is both parents.
         MOVE L-ENTITY TO WS-SELF
         CALL "MOB-BREED-BABY" USING L-ENTITY WS-SELF WS-BABY
     END-IF
     CALL "MOB-TAKE" USING L-PLAYER
     MOVE 1 TO L-USED
     GOBACK.
 END PROGRAM MOB-EGG-BABY.
