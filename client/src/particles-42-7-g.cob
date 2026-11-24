*> Particles part 7 (docs/protocol/42-particles-7-emitters-entities-events-commands.md), section 7: the entity events that spawn particles.
*> Entry point for the integrator (inputs): P7-ENTITY-EVENT id(BINARY-LONG) kind(X(24), the entity class: arrow, snowball, egg, living, tamable, horse, ocelot, wolf, others as the row) count(out) particle(X(24), out, spaces
*>   for none) site(X(24), out): the emission rule that draws them (the site of P7-BASE or P7-MOB where one exists; item_break, fox_eat, arrow_event, tracking, block_honey name rules of other documents). Count 0 with a particle
*>   is the stochastic witch row (6.14); an id outside the table gives spaces.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P7-ENTITY-EVENT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-TAB.
    05 FILLER PIC 9(4) VALUE 0.
    05 FILLER PIC X(24) VALUE "arrow".
    05 FILLER PIC X(24) VALUE "entity_effect".
    05 FILLER PIC 9(4) VALUE 20.
    05 FILLER PIC X(24) VALUE "arrow_event".
    05 FILLER PIC 9(4) VALUE 3.
    05 FILLER PIC X(24) VALUE "snowball".
    05 FILLER PIC X(24) VALUE "item".
    05 FILLER PIC 9(4) VALUE 8.
    05 FILLER PIC X(24) VALUE "item_break".
    05 FILLER PIC 9(4) VALUE 3.
    05 FILLER PIC X(24) VALUE "egg".
    05 FILLER PIC X(24) VALUE "item".
    05 FILLER PIC 9(4) VALUE 8.
    05 FILLER PIC X(24) VALUE "egg".
    05 FILLER PIC 9(4) VALUE 3.
    05 FILLER PIC X(24) VALUE "living".
    05 FILLER PIC X(24) VALUE SPACES.
    05 FILLER PIC 9(4) VALUE 0.
    05 FILLER PIC X(24) VALUE SPACES.
    05 FILLER PIC 9(4) VALUE 6.
    05 FILLER PIC X(24) VALUE "tamable".
    05 FILLER PIC X(24) VALUE "smoke".
    05 FILLER PIC 9(4) VALUE 7.
    05 FILLER PIC X(24) VALUE "taming".
    05 FILLER PIC 9(4) VALUE 7.
    05 FILLER PIC X(24) VALUE "tamable".
    05 FILLER PIC X(24) VALUE "heart".
    05 FILLER PIC 9(4) VALUE 7.
    05 FILLER PIC X(24) VALUE "taming".
    05 FILLER PIC 9(4) VALUE 6.
    05 FILLER PIC X(24) VALUE "horse".
    05 FILLER PIC X(24) VALUE "smoke".
    05 FILLER PIC 9(4) VALUE 7.
    05 FILLER PIC X(24) VALUE "taming".
    05 FILLER PIC 9(4) VALUE 7.
    05 FILLER PIC X(24) VALUE "horse".
    05 FILLER PIC X(24) VALUE "heart".
    05 FILLER PIC 9(4) VALUE 7.
    05 FILLER PIC X(24) VALUE "taming".
    05 FILLER PIC 9(4) VALUE 8.
    05 FILLER PIC X(24) VALUE "wolf".
    05 FILLER PIC X(24) VALUE SPACES.
    05 FILLER PIC 9(4) VALUE 0.
    05 FILLER PIC X(24) VALUE SPACES.
    05 FILLER PIC 9(4) VALUE 56.
    05 FILLER PIC X(24) VALUE "wolf".
    05 FILLER PIC X(24) VALUE SPACES.
    05 FILLER PIC 9(4) VALUE 0.
    05 FILLER PIC X(24) VALUE SPACES.
    05 FILLER PIC 9(4) VALUE 12.
    05 FILLER PIC X(24) VALUE "*".
    05 FILLER PIC X(24) VALUE "heart".
    05 FILLER PIC 9(4) VALUE 5.
    05 FILLER PIC X(24) VALUE "villager".
    05 FILLER PIC 9(4) VALUE 13.
    05 FILLER PIC X(24) VALUE "*".
    05 FILLER PIC X(24) VALUE "angry_villager".
    05 FILLER PIC 9(4) VALUE 5.
    05 FILLER PIC X(24) VALUE "villager".
    05 FILLER PIC 9(4) VALUE 14.
    05 FILLER PIC X(24) VALUE "*".
    05 FILLER PIC X(24) VALUE "happy_villager".
    05 FILLER PIC 9(4) VALUE 5.
    05 FILLER PIC X(24) VALUE "villager".
    05 FILLER PIC 9(4) VALUE 42.
    05 FILLER PIC X(24) VALUE "*".
    05 FILLER PIC X(24) VALUE "splash".
    05 FILLER PIC 9(4) VALUE 5.
    05 FILLER PIC X(24) VALUE "villager".
    05 FILLER PIC 9(4) VALUE 15.
    05 FILLER PIC X(24) VALUE "*".
    05 FILLER PIC X(24) VALUE "witch".
    05 FILLER PIC 9(4) VALUE 0.
    05 FILLER PIC X(24) VALUE "witch".
    05 FILLER PIC 9(4) VALUE 18.
    05 FILLER PIC X(24) VALUE "*".
    05 FILLER PIC X(24) VALUE "heart".
    05 FILLER PIC 9(4) VALUE 7.
    05 FILLER PIC X(24) VALUE "taming".
    05 FILLER PIC 9(4) VALUE 20.
    05 FILLER PIC X(24) VALUE "*".
    05 FILLER PIC X(24) VALUE "poof".
    05 FILLER PIC 9(4) VALUE 20.
    05 FILLER PIC X(24) VALUE "poof".
    05 FILLER PIC 9(4) VALUE 35.
    05 FILLER PIC X(24) VALUE "*".
    05 FILLER PIC X(24) VALUE "totem_of_undying".
    05 FILLER PIC 9(4) VALUE 0.
    05 FILLER PIC X(24) VALUE "tracking".
    05 FILLER PIC 9(4) VALUE 38.
    05 FILLER PIC X(24) VALUE "*".
    05 FILLER PIC X(24) VALUE "happy_villager".
    05 FILLER PIC 9(4) VALUE 7.
    05 FILLER PIC X(24) VALUE "dolphin_event".
    05 FILLER PIC 9(4) VALUE 40.
    05 FILLER PIC X(24) VALUE "ocelot".
    05 FILLER PIC X(24) VALUE "smoke".
    05 FILLER PIC 9(4) VALUE 7.
    05 FILLER PIC X(24) VALUE "taming".
    05 FILLER PIC 9(4) VALUE 41.
    05 FILLER PIC X(24) VALUE "ocelot".
    05 FILLER PIC X(24) VALUE "heart".
    05 FILLER PIC 9(4) VALUE 7.
    05 FILLER PIC X(24) VALUE "taming".
    05 FILLER PIC 9(4) VALUE 45.
    05 FILLER PIC X(24) VALUE "*".
    05 FILLER PIC X(24) VALUE "item".
    05 FILLER PIC 9(4) VALUE 8.
    05 FILLER PIC X(24) VALUE "fox_eat".
    05 FILLER PIC 9(4) VALUE 46.
    05 FILLER PIC X(24) VALUE "*".
    05 FILLER PIC X(24) VALUE "portal".
    05 FILLER PIC 9(4) VALUE 128.
    05 FILLER PIC X(24) VALUE "teleport".
    05 FILLER PIC 9(4) VALUE 47.
    05 FILLER PIC X(24) VALUE "*".
    05 FILLER PIC X(24) VALUE "item".
    05 FILLER PIC 9(4) VALUE 5.
    05 FILLER PIC X(24) VALUE "item_break".
    05 FILLER PIC 9(4) VALUE 48.
    05 FILLER PIC X(24) VALUE "*".
    05 FILLER PIC X(24) VALUE "item".
    05 FILLER PIC 9(4) VALUE 5.
    05 FILLER PIC X(24) VALUE "item_break".
    05 FILLER PIC 9(4) VALUE 49.
    05 FILLER PIC X(24) VALUE "*".
    05 FILLER PIC X(24) VALUE "item".
    05 FILLER PIC 9(4) VALUE 5.
    05 FILLER PIC X(24) VALUE "item_break".
    05 FILLER PIC 9(4) VALUE 50.
    05 FILLER PIC X(24) VALUE "*".
    05 FILLER PIC X(24) VALUE "item".
    05 FILLER PIC 9(4) VALUE 5.
    05 FILLER PIC X(24) VALUE "item_break".
    05 FILLER PIC 9(4) VALUE 51.
    05 FILLER PIC X(24) VALUE "*".
    05 FILLER PIC X(24) VALUE "item".
    05 FILLER PIC 9(4) VALUE 5.
    05 FILLER PIC X(24) VALUE "item_break".
    05 FILLER PIC 9(4) VALUE 52.
    05 FILLER PIC X(24) VALUE "*".
    05 FILLER PIC X(24) VALUE "item".
    05 FILLER PIC 9(4) VALUE 5.
    05 FILLER PIC X(24) VALUE "item_break".
    05 FILLER PIC 9(4) VALUE 65.
    05 FILLER PIC X(24) VALUE "*".
    05 FILLER PIC X(24) VALUE "item".
    05 FILLER PIC 9(4) VALUE 5.
    05 FILLER PIC X(24) VALUE "item_break".
    05 FILLER PIC 9(4) VALUE 68.
    05 FILLER PIC X(24) VALUE "*".
    05 FILLER PIC X(24) VALUE "item".
    05 FILLER PIC 9(4) VALUE 5.
    05 FILLER PIC X(24) VALUE "item_break".
    05 FILLER PIC 9(4) VALUE 54.
    05 FILLER PIC X(24) VALUE "*".
    05 FILLER PIC X(24) VALUE SPACES.
    05 FILLER PIC 9(4) VALUE 0.
    05 FILLER PIC X(24) VALUE "block_honey".
    05 FILLER PIC 9(4) VALUE 55.
    05 FILLER PIC X(24) VALUE "*".
    05 FILLER PIC X(24) VALUE SPACES.
    05 FILLER PIC 9(4) VALUE 0.
    05 FILLER PIC X(24) VALUE SPACES.
    05 FILLER PIC 9(4) VALUE 60.
    05 FILLER PIC X(24) VALUE "*".
    05 FILLER PIC X(24) VALUE "poof".
    05 FILLER PIC 9(4) VALUE 20.
    05 FILLER PIC X(24) VALUE "poof".
    05 FILLER PIC 9(4) VALUE 67.
    05 FILLER PIC X(24) VALUE "*".
    05 FILLER PIC X(24) VALUE "bubble".
    05 FILLER PIC 9(4) VALUE 8.
    05 FILLER PIC X(24) VALUE "drown".
 01 WS-TAB-R REDEFINES WS-TAB.
    05 WS-E OCCURS 35 TIMES.
       10 WS-ID             PIC 9(4).
       10 WS-KIND           PIC X(24).
       10 WS-PARTICLE       PIC X(24).
       10 WS-COUNT          PIC 9(4).
       10 WS-SITE           PIC X(24).
 01 WS-I                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-ID                  BINARY-LONG.
 01 L-KIND                PIC X(24).
 01 L-COUNT               BINARY-LONG.
 01 L-PARTICLE            PIC X(24).
 01 L-SITE                PIC X(24).
 PROCEDURE DIVISION USING L-ID L-KIND L-COUNT L-PARTICLE L-SITE.
     MOVE 0 TO L-COUNT
     MOVE SPACES TO L-PARTICLE L-SITE
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 35
         IF WS-ID(WS-I) = L-ID AND (WS-KIND(WS-I) = "*" OR WS-KIND(WS-I) = L-KIND)
             MOVE WS-COUNT(WS-I) TO L-COUNT
             MOVE WS-PARTICLE(WS-I) TO L-PARTICLE
             MOVE WS-SITE(WS-I) TO L-SITE
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM P7-ENTITY-EVENT.
