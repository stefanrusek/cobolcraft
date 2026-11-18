*> Acceptance test (lane p49o, T36000; docs/protocol/16 section 5.8 `summon`, 21 section 8, 45-8 and 45-9): in a standard world /summon creates every entity type the
*> core can build, not only the mobs of STDMOBS.cpy: ground items (with an Item), experience orbs, primed TNT, falling blocks, area effect clouds, lightning bolts, end
*> crystals, armor stands, item frames, paintings, the seven minecarts, the boats and rafts, the interaction, display, mannequin, cushion and marker entities, the arrows,
*> snowballs, eggs, pearls, fireballs, wind charges, experience bottles and thrown potions, the bat and the happy ghast. Each goes through the real command (Opal
*> holds operator status): commands.summon.success [key], one entity of the type at the position, and the player who stands there is sent it (VW-SEEN; the marker is
*> never sent, 21 section 8.9). The two types with noSummon (player and fishing_bobber, 18 section 3 flags) are entity.not_summonable.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-CMD-SUMMON-ENTITIES.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY PROTO.
 COPY CITEMS.
 COPY BRWORLD.
 01 WS-ID-OPAL             BINARY-LONG.
 01 WS-NAME                PIC X(16).
 01 WS-NAME-LENGTH         BINARY-LONG.
 01 WS-LINE                PIC X(768).
 01 WS-TEXT                PIC X(4096).
 01 WS-DISCARD             PIC X(4096).
 01 WS-EXPECTED            PIC X(1024).
 01 WS-EXPECTED-N          BINARY-DOUBLE.
 01 WS-NUM                 BINARY-DOUBLE.
 01 WS-CURSOR              BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-KEEP                BINARY-LONG.
 01 WS-KEY-TEXT            PIC X(48).
 01 WS-KEY-LENGTH          BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-SEEN                BINARY-LONG.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-DX                  PIC -(3)9.
 01 WS-DZ                  PIC -(3)9.
 01 WS-KEYS.
    05 FILLER PIC X(32) VALUE "experience_orb".
    05 FILLER PIC X(32) VALUE "tnt".
    05 FILLER PIC X(32) VALUE "falling_block".
    05 FILLER PIC X(32) VALUE "area_effect_cloud".
    05 FILLER PIC X(32) VALUE "lightning_bolt".
    05 FILLER PIC X(32) VALUE "end_crystal".
    05 FILLER PIC X(32) VALUE "armor_stand".
    05 FILLER PIC X(32) VALUE "item_frame".
    05 FILLER PIC X(32) VALUE "glow_item_frame".
    05 FILLER PIC X(32) VALUE "painting".
    05 FILLER PIC X(32) VALUE "minecart".
    05 FILLER PIC X(32) VALUE "chest_minecart".
    05 FILLER PIC X(32) VALUE "hopper_minecart".
    05 FILLER PIC X(32) VALUE "furnace_minecart".
    05 FILLER PIC X(32) VALUE "tnt_minecart".
    05 FILLER PIC X(32) VALUE "spawner_minecart".
    05 FILLER PIC X(32) VALUE "command_block_minecart".
    05 FILLER PIC X(32) VALUE "oak_boat".
    05 FILLER PIC X(32) VALUE "bamboo_raft".
    05 FILLER PIC X(32) VALUE "oak_chest_boat".
    05 FILLER PIC X(32) VALUE "bamboo_chest_raft".
    05 FILLER PIC X(32) VALUE "interaction".
    05 FILLER PIC X(32) VALUE "block_display".
    05 FILLER PIC X(32) VALUE "item_display".
    05 FILLER PIC X(32) VALUE "mannequin".
    05 FILLER PIC X(32) VALUE "cushion".
    05 FILLER PIC X(32) VALUE "arrow".
    05 FILLER PIC X(32) VALUE "snowball".
    05 FILLER PIC X(32) VALUE "egg".
    05 FILLER PIC X(32) VALUE "ender_pearl".
    05 FILLER PIC X(32) VALUE "fireball".
    05 FILLER PIC X(32) VALUE "small_fireball".
    05 FILLER PIC X(32) VALUE "wind_charge".
    05 FILLER PIC X(32) VALUE "breeze_wind_charge".
    05 FILLER PIC X(32) VALUE "experience_bottle".
    05 FILLER PIC X(32) VALUE "splash_potion".
    05 FILLER PIC X(32) VALUE "lingering_potion".
    05 FILLER PIC X(32) VALUE "bat".
    05 FILLER PIC X(32) VALUE "happy_ghast".
    05 FILLER PIC X(32) VALUE "ominous_item_spawner".
    05 FILLER PIC X(32) VALUE "firework_rocket".
    05 FILLER PIC X(32) VALUE "eye_of_ender".
    05 FILLER PIC X(32) VALUE "marker".
    05 FILLER PIC X(32) VALUE "shulker_bullet".
    05 FILLER PIC X(32) VALUE "llama_spit".
 01 WS-KEY-TABLE REDEFINES WS-KEYS.
    05 WS-KEY-ROW             PIC X(32) OCCURS 45 TIMES.
 PROCEDURE DIVISION.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     CALL "TEST-STANDARD-TABLES"
     MOVE "Opal" TO WS-NAME
     MOVE 4 TO WS-NAME-LENGTH
     CALL "TEST-JOIN-OP" USING WS-NAME WS-NAME-LENGTH WS-ID-OPAL
     MOVE CN-PLAYER(WS-ID-OPAL) TO WS-PLAYER
     CALL "TEST-DRAIN-CHAT" USING WS-ID-OPAL WS-DISCARD
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 45
         MOVE WS-KEY-ROW(WS-I) TO WS-KEY-TEXT
         COMPUTE WS-KEY-LENGTH = FUNCTION LENGTH(FUNCTION TRIM(WS-KEY-TEXT))
         COMPUTE WS-J = FUNCTION MOD(WS-I, 8) + 1
         MOVE WS-J TO WS-DX
         COMPUTE WS-J = WS-I / 8 + 1
         MOVE WS-J TO WS-DZ
         MOVE SPACES TO WS-LINE
         STRING "summon minecraft:" WS-KEY-TEXT(1:WS-KEY-LENGTH) " ~" FUNCTION TRIM(WS-DX) " ~ ~" FUNCTION TRIM(WS-DZ)
             DELIMITED BY SIZE INTO WS-LINE
         MOVE SPACES TO WS-EXPECTED
         STRING "commands.summon.success(minecraft:" WS-KEY-TEXT(1:WS-KEY-LENGTH) ")"
             DELIMITED BY SIZE INTO WS-EXPECTED
         MOVE SPACES TO TL-CASE
         STRING "acceptance US15 /summon minecraft:" WS-KEY-TEXT(1:WS-KEY-LENGTH) ": Summoned new entity"
             DELIMITED BY SIZE INTO TL-CASE
         CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
         CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
         PERFORM FIND-ENTITY
         MOVE SPACES TO TL-CASE
         STRING "acceptance US15 /summon minecraft:" WS-KEY-TEXT(1:WS-KEY-LENGTH) " creates one entity of the type"
             DELIMITED BY SIZE INTO TL-CASE
         MOVE 1 TO WS-EXPECTED-N
         MOVE WS-COUNT TO WS-NUM
         CALL "TEST-EXPECT-NUMBER" USING TL-CASE WS-EXPECTED-N WS-NUM
         MOVE SPACES TO TL-CASE
         STRING "acceptance US15 /summon minecraft:" WS-KEY-TEXT(1:WS-KEY-LENGTH) " the player is sent it"
             DELIMITED BY SIZE INTO TL-CASE
         IF WS-KEY-TEXT = "marker"
             MOVE 0 TO WS-EXPECTED-N
         ELSE
             MOVE 1 TO WS-EXPECTED-N
         END-IF
         MOVE WS-SEEN TO WS-NUM
         CALL "TEST-EXPECT-NUMBER" USING TL-CASE WS-EXPECTED-N WS-NUM
     END-PERFORM

     MOVE "acceptance US15 /summon leash_knot: the core has no knot entity" TO TL-CASE
     MOVE "summon minecraft:leash_knot" TO WS-LINE
     MOVE "entity.not_summonable(minecraft:leash_knot)" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
*>   Tab completion lists the entity types /summon can create (the summonable_entities provider of 15 section 14.4, answered by the server for the ask_server node).
     MOVE "acceptance US15 /summon completes the types that can be summoned" TO TL-CASE
     MOVE "/summon exp" TO WS-LINE
     MOVE 11 TO WS-CURSOR
     CALL "TEST-SUGGEST" USING WS-ID-OPAL 7 WS-LINE WS-CURSOR
     CALL "TEST-DRAIN-SUGGESTIONS" USING WS-ID-OPAL WS-TEXT
     MOVE "7 8 3 [minecraft:experience_bottle,minecraft:experience_orb]" TO WS-EXPECTED
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US15 /summon does not complete the fishing bobber (noSummon)" TO TL-CASE
     MOVE "/summon fishing" TO WS-LINE
     MOVE 15 TO WS-CURSOR
     CALL "TEST-SUGGEST" USING WS-ID-OPAL 8 WS-LINE WS-CURSOR
     CALL "TEST-DRAIN-SUGGESTIONS" USING WS-ID-OPAL WS-TEXT
     MOVE "8 0 0 []" TO WS-EXPECTED
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US15 /summon does not complete the leash knot (the core has no entity for it)" TO TL-CASE
     MOVE "/summon leash" TO WS-LINE
     MOVE 13 TO WS-CURSOR
     CALL "TEST-SUGGEST" USING WS-ID-OPAL 9 WS-LINE WS-CURSOR
     CALL "TEST-DRAIN-SUGGESTIONS" USING WS-ID-OPAL WS-TEXT
     MOVE "9 0 0 []" TO WS-EXPECTED
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US15 /summon the player type has noSummon" TO TL-CASE
     MOVE "summon minecraft:player" TO WS-LINE
     MOVE "entity.not_summonable(minecraft:player)" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US15 /summon the fishing bobber type has noSummon" TO TL-CASE
     MOVE "summon minecraft:fishing_bobber" TO WS-LINE
     MOVE "entity.not_summonable(minecraft:fishing_bobber)" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     STOP RUN.

*> WS-COUNT: the entities of the type key WS-KEY-TEXT that stand in the world (the players' rows excluded), WS-ROW the last one, WS-SEEN 1 when
*> the player has been sent it.
 FIND-ENTITY.
     MOVE 0 TO WS-COUNT WS-ROW WS-SEEN
     PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > EN-COUNT
         IF EN-USED(WS-J) = 1 AND EN-PLAYER(WS-J) = 0
             COMPUTE WS-KEEP = EN-TYPE(WS-J) + 1
             IF ET-KEY(WS-KEEP) = WS-KEY-TEXT
                 ADD 1 TO WS-COUNT
                 MOVE WS-J TO WS-ROW
             END-IF
         END-IF
     END-PERFORM
     IF WS-ROW > 0
         IF VW-SEEN(WS-PLAYER)(WS-ROW:1) = "1"
             MOVE 1 TO WS-SEEN
         END-IF
     END-IF.
 END PROGRAM TEST-CMD-SUMMON-ENTITIES.

 COPY CORETEST.
 COPY CMDTEST.
