*> Suggestions of the command framework (docs/protocol/15a-brigadier-command-library.md §6;
*> 15-commands-framework.md §14.2): the suggestion context of a parse and a cursor, every child of the
*> context's parent asked to list suggestions (requirements are not tested, 15a §6.1), the results
*> merged on one range, duplicates dropped and the list sorted by lower-case text (a stable sort).
*>
*> Entry points:
*>   BR-SUGGEST USING source level, line (PIC X(1024), without a leading /), byte length, cursor:
*>     fills BR-SUGGESTIONS (core/copy/BRIGADIER.cpy): start and length of the replaced text and the
*>     entries; the empty value (start 0, length 0, no entries) when nothing is suggested. A literal child
*>     suggests its name when its lower-case name starts with the lower-case text typed since the
*>     context start and the name is not that text exactly; a bool argument suggests true and false the
*>     same way; the other stock types suggest nothing (15a §5). Custom providers are the commands'.
*>   BR-SUGGESTIONS-BUILD USING transaction id, PB-BUFFER: Command Suggestions 0x0F (05a): transaction
*>     id, start, length, then each entry as a String with no tooltip.

*> The tags of a registry for the completion of a resource_or_tag argument (lane buglocate3): the files of data/minecraft/tags/<registry path>/ of the data directory the structure data
*> was loaded from (STRUCTDATA SD-DIR, the generated vanilla-data folder), named minecraft:<file name without .json>.
*>   BR-SUGGEST-TAGS USING registry (PIC X(112)), count out, names out (256 entries of PIC X(64)); nothing when the registry is not of minecraft: or no data directory is known
 IDENTIFICATION DIVISION.
 PROGRAM-ID. BR-SUGGEST-TAGS.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY STRUCTDATA.
 01 WS-PATH                PIC X(1300).
 01 WS-DIRZ                PIC X(1301).
 01 WS-LIST                PIC X(16384).
 01 WS-LIST-CAPACITY       BINARY-LONG VALUE 16384.
 01 WS-LIST-COUNT          BINARY-LONG.
 01 WS-RC                  BINARY-LONG.
 01 WS-PTR                 BINARY-LONG.
 01 WS-ENTRY               PIC X(256).
 01 WS-ENTRY-LEN           BINARY-LONG.
 01 WS-NAME-LEN            BINARY-LONG.
 01 WS-PATH-LEN            BINARY-LONG.
 01 WS-TAIL                PIC X(102).
 LINKAGE SECTION.
 01 L-REGISTRY             PIC X(112).
 01 L-COUNT                BINARY-LONG.
 01 L-NAMES.
    05 L-NAME              PIC X(64) OCCURS 256 TIMES.
 PROCEDURE DIVISION USING L-REGISTRY L-COUNT L-NAMES.
     MOVE 0 TO L-COUNT
     IF L-REGISTRY(1:10) NOT = "minecraft:" OR SD-DIR = SPACES OR SD-DIR(1:1) = LOW-VALUE
         GOBACK
     END-IF
     MOVE SPACES TO WS-TAIL WS-PATH
     MOVE L-REGISTRY(11:102) TO WS-TAIL
     STRING FUNCTION TRIM(SD-DIR) "/data/minecraft/tags/" FUNCTION TRIM(WS-TAIL) DELIMITED BY SIZE INTO WS-PATH
     MOVE LOW-VALUES TO WS-DIRZ
     COMPUTE WS-PATH-LEN = FUNCTION LENGTH(FUNCTION TRIM(WS-PATH))
     MOVE WS-PATH(1:WS-PATH-LEN) TO WS-DIRZ(1:WS-PATH-LEN)
     MOVE 0 TO WS-LIST-COUNT
     CALL STATIC "cc_fs_list" USING BY REFERENCE WS-DIRZ BY REFERENCE WS-LIST
         BY VALUE WS-LIST-CAPACITY BY REFERENCE WS-LIST-COUNT RETURNING WS-RC
     IF WS-RC NOT = 0
         GOBACK
     END-IF
     MOVE 1 TO WS-PTR
     PERFORM WS-LIST-COUNT TIMES
         MOVE SPACES TO WS-ENTRY
         MOVE 0 TO WS-ENTRY-LEN
         UNSTRING WS-LIST DELIMITED BY X"0A" INTO WS-ENTRY COUNT IN WS-ENTRY-LEN WITH POINTER WS-PTR
         IF WS-ENTRY(1:1) = "F" AND WS-ENTRY-LEN > 6 AND WS-ENTRY(WS-ENTRY-LEN - 4:5) = ".json"
                 AND WS-ENTRY-LEN <= 59 AND L-COUNT < 256
             COMPUTE WS-NAME-LEN = WS-ENTRY-LEN - 6
             ADD 1 TO L-COUNT
             MOVE SPACES TO L-NAME(L-COUNT)
             STRING "minecraft:" WS-ENTRY(2:WS-NAME-LEN) DELIMITED BY SIZE INTO L-NAME(L-COUNT)
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM BR-SUGGEST-TAGS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BR-SUGGEST.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BRIGADIER.
 COPY CORESTATE.
 COPY DIMENSIONS.
 COPY CONTENT.
 COPY CTRECIPE.
 COPY BRTRAIL REPLACING LEADING ==BT-== BY ==SR-==.
 01 WS-CTX                 BINARY-LONG.
 01 WS-A                   BINARY-LONG.
 01 WS-B                   BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-LAST                BINARY-LONG.
 01 WS-PREV                BINARY-LONG.
 01 WS-PARENT              BINARY-LONG.
 01 WS-START               BINARY-LONG.
 01 WS-FOUND               BINARY-LONG.
 01 WS-DONE                BINARY-LONG.
 01 WS-REMAINING-LENGTH    BINARY-LONG.
 01 WS-REMAINING           PIC X(1024).
 01 WS-LOWER               PIC X(1024).
 01 WS-CHILD               BINARY-LONG.
 01 WS-CANDIDATE           PIC X(64).
 01 WS-CANDIDATE-LENGTH    BINARY-LONG.
 01 WS-CANDIDATE-LOWER     PIC X(64).
 01 WS-J                   BINARY-LONG.
 01 WS-DUPLICATE           BINARY-LONG.
 01 WS-SWAP-TEXT           PIC X(64).
 01 WS-SWAP-LENGTH         BINARY-LONG.
 01 WS-LOWER-A             PIC X(64).
 01 WS-LOWER-B             PIC X(64).
 01 WS-K                 BINARY-LONG.
 01 WS-SUB-OK              BINARY-LONG.
 01 WS-SUB-P               BINARY-LONG.
 01 WS-SUB-LAST            BINARY-LONG.
 01 WS-HEAD-TABLE          PIC X(12) VALUE "@p@a@r@s@e@n".
 01 WS-TIP                 BINARY-LONG VALUE 0.
 01 WS-SWAP-TIP            BINARY-LONG.
 01 WS-MODE-NAMES.
    05 FILLER               PIC X(10) VALUE "survival".
    05 FILLER               PIC X(10) VALUE "creative".
    05 FILLER               PIC X(10) VALUE "adventure".
    05 FILLER               PIC X(10) VALUE "spectator".
 01 WS-MODE-TABLE REDEFINES WS-MODE-NAMES.
    05 WS-MODE-NAME         PIC X(10) OCCURS 4 TIMES.
 01 WS-REG-ID              BINARY-LONG.
 01 WS-REG-COUNT           BINARY-LONG.
 01 WS-CAN                 BINARY-LONG.
 01 WS-REG-STATUS          BINARY-LONG.
 01 WS-REG-ENTRY           PIC X(112).
 01 WS-REG-ENTRY-LENGTH    BINARY-LONG.
 01 WS-REG-PAYLOAD         PIC X.
 01 WS-REG-CAPACITY        BINARY-LONG VALUE 0.
 01 WS-REG-PAYLOAD-LENGTH  BINARY-LONG.
 01 WS-REG-KEY             PIC X(112).
 01 WS-TAG-COUNT           BINARY-LONG.
 01 WS-TAG-NAMES.
    05 WS-TAG-NAME         PIC X(64) OCCURS 256 TIMES.
 01 WS-SAVE-REMAINING      PIC X(1024).
 01 WS-SAVE-LOWER          PIC X(1024).
 01 WS-SAVE-LENGTH         BINARY-LONG.
 01 WS-TAG-ID              PIC X(64).
 01 WS-TAG-ID-LENGTH       BINARY-LONG.
 01 WS-TRUE-TEXT           PIC X(5) VALUE "true".
 01 WS-FALSE-TEXT          PIC X(5) VALUE "false".
 LINKAGE SECTION.
 01 L-LEVEL                BINARY-LONG.
 01 L-LINE                 PIC X(1024).
 01 L-LENGTH               BINARY-LONG.
 01 L-CURSOR               BINARY-LONG.
 PROCEDURE DIVISION USING L-LEVEL L-LINE L-LENGTH L-CURSOR.
     GO TO MAIN-LINE.

*> 15a §6.3: the context holding the cursor, the parent node whose children are suggested and the
*> start of the text they replace (WS-PARENT, WS-START).
 FIND-CONTEXT.
     MOVE 1 TO WS-CTX
     MOVE 0 TO WS-DONE
     PERFORM UNTIL WS-DONE = 1
         PERFORM CONTEXT-RANGE
         IF WS-B < L-CURSOR
             IF WS-CTX < SR-CTX-COUNT
                 ADD 1 TO WS-CTX
             ELSE
                 MOVE 1 TO WS-DONE
                 IF WS-LAST > 0
                     MOVE SR-NODE(WS-LAST) TO WS-PARENT
                     COMPUTE WS-START = SR-END(WS-LAST) + 1
                 ELSE
                     PERFORM CONTEXT-ROOT
                     MOVE WS-A TO WS-START
                 END-IF
             END-IF
         ELSE
             MOVE 1 TO WS-DONE
             PERFORM CONTEXT-ROOT
             MOVE WS-PARENT TO WS-PREV
             MOVE 0 TO WS-FOUND
             PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > SR-COUNT OR WS-FOUND = 1
                 IF SR-CTX(WS-I) = WS-CTX
                     IF SR-START(WS-I) <= L-CURSOR AND L-CURSOR <= SR-END(WS-I)
                         MOVE 1 TO WS-FOUND
                         MOVE SR-START(WS-I) TO WS-START
                         MOVE WS-PREV TO WS-PARENT
                     ELSE
                         MOVE SR-NODE(WS-I) TO WS-PREV
                     END-IF
                 END-IF
             END-PERFORM
             IF WS-FOUND = 0
                 MOVE WS-PREV TO WS-PARENT
                 MOVE WS-A TO WS-START
             END-IF
         END-IF
     END-PERFORM.

*> WS-A, WS-B: the range of context WS-CTX (its start and the largest node end, or the start when it
*> has no nodes); WS-LAST: the last trail entry of the context, 0 when it has none.
 CONTEXT-RANGE.
     MOVE SR-CTX-START(WS-CTX) TO WS-A
     MOVE WS-A TO WS-B
     MOVE 0 TO WS-LAST
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > SR-COUNT
         IF SR-CTX(WS-I) = WS-CTX
             MOVE WS-I TO WS-LAST
             IF SR-END(WS-I) > WS-B
                 MOVE SR-END(WS-I) TO WS-B
             END-IF
         END-IF
     END-PERFORM.

*> WS-PARENT: the root of context WS-CTX: the tree root, or the target of the redirect that began it.
 CONTEXT-ROOT.
     MOVE 1 TO WS-PARENT
     IF WS-CTX > 1
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > SR-COUNT
             IF SR-CTX(WS-I) = WS-CTX - 1
                 MOVE BR-N-REDIRECT(SR-NODE(WS-I)) TO WS-PARENT
             END-IF
         END-PERFORM
     END-IF.

*> One child of the parent: a literal's name, or true and false of a bool argument.
 LIST-CHILD.
     IF BR-N-KIND(WS-CHILD) = BR-LITERAL
         MOVE BR-N-NAME(WS-CHILD) TO WS-CANDIDATE
         MOVE BR-N-NAME-LENGTH(WS-CHILD) TO WS-CANDIDATE-LENGTH
         PERFORM OFFER
     ELSE
         EVALUATE BR-N-TYPE(WS-CHILD)
             WHEN BR-P-BOOL
                 IF BR-N-SUGGEST(WS-CHILD) = 0
                     MOVE WS-TRUE-TEXT TO WS-CANDIDATE
                     MOVE 4 TO WS-CANDIDATE-LENGTH
                     PERFORM OFFER
                     MOVE WS-FALSE-TEXT TO WS-CANDIDATE
                     MOVE 5 TO WS-CANDIDATE-LENGTH
                     PERFORM OFFER
                 END-IF
             WHEN BR-P-ENTITY
             WHEN BR-P-GAME-PROFILE
             WHEN BR-P-SCORE-HOLDER
                 PERFORM LIST-PLAYERS
             WHEN BR-P-GAMEMODE
                 PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 4
                     MOVE WS-MODE-NAME(WS-K) TO WS-CANDIDATE
                     MOVE FUNCTION LENGTH(FUNCTION TRIM(WS-CANDIDATE)) TO WS-CANDIDATE-LENGTH
                     PERFORM OFFER-SUB
                 END-PERFORM
             WHEN BR-P-DIMENSION
                 PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > CW-DIM-COUNT
                     MOVE SPACES TO WS-CANDIDATE
                     MOVE DM-KEY(CW-DIM(WS-K)) TO WS-CANDIDATE
                     MOVE DM-KEY-LENGTH(CW-DIM(WS-K)) TO WS-CANDIDATE-LENGTH
                     PERFORM OFFER-RESOURCE
                 END-PERFORM
             WHEN BR-P-RESOURCE
                 IF BR-N-REG-LENGTH(WS-CHILD) > 0
                     PERFORM LIST-REGISTRY
                 END-IF
             WHEN BR-P-RES-OR-TAG
             WHEN BR-P-RES-OR-TAG-KEY
                 IF BR-N-REG-LENGTH(WS-CHILD) > 0
                     PERFORM LIST-REGISTRY
                     PERFORM LIST-TAGS
                 END-IF
             WHEN BR-P-RESOURCE-KEY
                 IF BR-N-REG-LENGTH(WS-CHILD) = 16 AND BR-N-REG(WS-CHILD)(1:16) = "minecraft:recipe"
                     PERFORM LIST-RECIPES
                 END-IF
         END-EVALUATE
     END-IF.

*> The online players' names, and the selector heads when the source holds level 2 (14.3). The heads of a score holder carry their tooltips (57-client-closures-4
*> section 8.3: the provider of the score_holder nodes is the only ask_server provider with tooltips); the names never do.
 LIST-PLAYERS.
     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 64
         IF PL-USED(WS-K) = 1 AND PL-STATE(WS-K) NOT = PS-JOINING
             MOVE PL-NAME(WS-K) TO WS-CANDIDATE
             MOVE PL-NAME-LENGTH(WS-K) TO WS-CANDIDATE-LENGTH
             PERFORM OFFER-SUB
         END-IF
     END-PERFORM
     IF L-LEVEL >= 2 AND (BR-N-TYPE(WS-CHILD) = BR-P-ENTITY OR BR-N-TYPE(WS-CHILD) = BR-P-SCORE-HOLDER)
         PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 6
             MOVE SPACES TO WS-CANDIDATE
             MOVE WS-HEAD-TABLE(WS-K * 2 - 1:2) TO WS-CANDIDATE
             MOVE 2 TO WS-CANDIDATE-LENGTH
             IF BR-N-TYPE(WS-CHILD) = BR-P-SCORE-HOLDER
                 MOVE WS-K TO WS-TIP
             END-IF
             PERFORM OFFER-SUB
             MOVE 0 TO WS-TIP
         END-PERFORM
     END-IF.

*> The entries of the registry of the node (14.3 resource types).
 LIST-REGISTRY.
     MOVE SPACES TO WS-REG-KEY
     MOVE BR-N-REG(WS-CHILD) TO WS-REG-KEY
     CALL "CONTENT-REGISTRY-COUNT" USING WS-REG-KEY WS-REG-COUNT WS-REG-STATUS
     IF WS-REG-STATUS = CT-OK
         PERFORM VARYING WS-REG-ID FROM 0 BY 1 UNTIL WS-REG-ID >= WS-REG-COUNT
             CALL "CONTENT-REGISTRY-ENTRY" USING WS-REG-KEY WS-REG-ID WS-REG-ENTRY WS-REG-ENTRY-LENGTH
                 WS-REG-PAYLOAD WS-REG-CAPACITY WS-REG-PAYLOAD-LENGTH WS-REG-STATUS
             MOVE 1 TO WS-CAN
             IF BR-N-FLAGS(WS-CHILD) = 64
                 CALL "SUMMON-CAN" USING WS-REG-ID WS-CAN
             END-IF
             IF WS-REG-ENTRY-LENGTH > 0 AND WS-REG-ENTRY-LENGTH <= 64 AND WS-CAN = 1
                 MOVE SPACES TO WS-CANDIDATE
                 MOVE WS-REG-ENTRY(1:WS-REG-ENTRY-LENGTH) TO WS-CANDIDATE
                 MOVE WS-REG-ENTRY-LENGTH TO WS-CANDIDATE-LENGTH
                 PERFORM OFFER-RESOURCE
             END-IF
         END-PERFORM
     END-IF.

*> The tags of the registry of the node, offered as #namespace:path (the text typed after a # or without one is matched against the tag's identifier like a resource, so the
*> operator who typed `village` is offered #minecraft:village).
 LIST-TAGS.
     MOVE SPACES TO WS-REG-KEY
     MOVE BR-N-REG(WS-CHILD) TO WS-REG-KEY
     CALL "BR-SUGGEST-TAGS" USING WS-REG-KEY WS-TAG-COUNT WS-TAG-NAMES
     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > WS-TAG-COUNT
         MOVE WS-TAG-NAME(WS-K) TO WS-TAG-ID
         MOVE FUNCTION LENGTH(FUNCTION TRIM(WS-TAG-ID)) TO WS-TAG-ID-LENGTH
         PERFORM OFFER-TAG
     END-PERFORM.

*> One tag (WS-TAG-ID, WS-TAG-ID-LENGTH): the text typed without its leading # must match the identifier (OFFER-RESOURCE's rule); the entry is #identifier, never the text typed exactly.
 OFFER-TAG.
     MOVE WS-REMAINING TO WS-SAVE-REMAINING
     MOVE WS-LOWER TO WS-SAVE-LOWER
     MOVE WS-REMAINING-LENGTH TO WS-SAVE-LENGTH
     IF WS-REMAINING-LENGTH > 0 AND WS-REMAINING(1:1) = "#"
         COMPUTE WS-REMAINING-LENGTH = WS-SAVE-LENGTH - 1
         MOVE SPACES TO WS-REMAINING WS-LOWER
         IF WS-REMAINING-LENGTH > 0
             MOVE WS-SAVE-REMAINING(2:WS-REMAINING-LENGTH) TO WS-REMAINING
             MOVE WS-SAVE-LOWER(2:WS-REMAINING-LENGTH) TO WS-LOWER
         END-IF
     END-IF
     MOVE SPACES TO WS-CANDIDATE
     MOVE WS-TAG-ID(1:WS-TAG-ID-LENGTH) TO WS-CANDIDATE
     MOVE WS-TAG-ID-LENGTH TO WS-CANDIDATE-LENGTH
     MOVE 0 TO WS-SUB-LAST
     PERFORM VARYING WS-SUB-P FROM 1 BY 1 UNTIL WS-SUB-P > WS-CANDIDATE-LENGTH
         IF WS-CANDIDATE(WS-SUB-P:1) = ":" AND WS-SUB-LAST = 0
             MOVE WS-SUB-P TO WS-SUB-LAST
         END-IF
     END-PERFORM
     MOVE 0 TO WS-COUNT
     IF WS-REMAINING-LENGTH > 0
         INSPECT WS-REMAINING(1:WS-REMAINING-LENGTH) TALLYING WS-COUNT FOR ALL ":"
     END-IF
     PERFORM MATCH-SUB
     IF WS-SUB-OK = 0 AND WS-COUNT = 0 AND WS-SUB-LAST > 0
         MOVE SPACES TO WS-CANDIDATE
         COMPUTE WS-CANDIDATE-LENGTH = WS-TAG-ID-LENGTH - WS-SUB-LAST
         MOVE WS-TAG-ID(WS-SUB-LAST + 1:WS-CANDIDATE-LENGTH) TO WS-CANDIDATE
         PERFORM MATCH-SUB
     END-IF
     MOVE WS-SAVE-REMAINING TO WS-REMAINING
     MOVE WS-SAVE-LOWER TO WS-LOWER
     MOVE WS-SAVE-LENGTH TO WS-REMAINING-LENGTH
     MOVE SPACES TO WS-CANDIDATE
     STRING "#" WS-TAG-ID(1:WS-TAG-ID-LENGTH) DELIMITED BY SIZE INTO WS-CANDIDATE
     COMPUTE WS-CANDIDATE-LENGTH = WS-TAG-ID-LENGTH + 1
     IF WS-SUB-OK = 1
         IF NOT (WS-REMAINING-LENGTH = WS-CANDIDATE-LENGTH
                 AND WS-CANDIDATE(1:WS-CANDIDATE-LENGTH) = WS-REMAINING(1:WS-REMAINING-LENGTH))
             PERFORM ADD-ENTRY
         END-IF
     END-IF.

*> The keys of the recipes of the store (a resource_key argument of the registry minecraft:recipe).
 LIST-RECIPES.
     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > RC-COUNT
         MOVE SPACES TO WS-CANDIDATE
         MOVE RR-KEY(WS-K) TO WS-CANDIDATE
         MOVE FUNCTION LENGTH(FUNCTION TRIM(RR-KEY(WS-K))) TO WS-CANDIDATE-LENGTH
         PERFORM OFFER-RESOURCE
     END-PERFORM.

*> SharedSuggestionProvider.matchesSubStr (14.2): the typed text matches the start of the candidate or the text after a . _ or /.
 MATCH-SUB.
     MOVE 0 TO WS-SUB-OK
     IF WS-REMAINING-LENGTH = 0
         MOVE 1 TO WS-SUB-OK
     END-IF
     MOVE FUNCTION LOWER-CASE(WS-CANDIDATE) TO WS-CANDIDATE-LOWER
     PERFORM VARYING WS-SUB-P FROM 1 BY 1 UNTIL WS-SUB-P + WS-REMAINING-LENGTH - 1 > WS-CANDIDATE-LENGTH OR WS-SUB-OK = 1
         IF WS-SUB-P = 1 OR WS-CANDIDATE-LOWER(WS-SUB-P - 1:1) = "." OR WS-CANDIDATE-LOWER(WS-SUB-P - 1:1) = "_"
                 OR WS-CANDIDATE-LOWER(WS-SUB-P - 1:1) = "/"
             IF WS-CANDIDATE-LOWER(WS-SUB-P:WS-REMAINING-LENGTH) = WS-LOWER(1:WS-REMAINING-LENGTH)
                 MOVE 1 TO WS-SUB-OK
             END-IF
         END-IF
     END-PERFORM.

*> suggest(text) with the substring matching.
 OFFER-SUB.
     PERFORM MATCH-SUB
     IF WS-SUB-OK = 1
         IF NOT (WS-REMAINING-LENGTH = WS-CANDIDATE-LENGTH
                 AND WS-CANDIDATE(1:WS-CANDIDATE-LENGTH) = WS-REMAINING(1:WS-REMAINING-LENGTH))
             PERFORM ADD-ENTRY
         END-IF
     END-IF.

*> suggestResource: with a colon in the typed text the whole namespace:path is matched, else the namespace or the path.
 OFFER-RESOURCE.
     MOVE 0 TO WS-SUB-LAST
     PERFORM VARYING WS-SUB-P FROM 1 BY 1 UNTIL WS-SUB-P > WS-CANDIDATE-LENGTH
         IF WS-CANDIDATE(WS-SUB-P:1) = ":" AND WS-SUB-LAST = 0
             MOVE WS-SUB-P TO WS-SUB-LAST
         END-IF
     END-PERFORM
     MOVE 0 TO WS-COUNT
     IF WS-REMAINING-LENGTH > 0
         INSPECT WS-REMAINING(1:WS-REMAINING-LENGTH) TALLYING WS-COUNT FOR ALL ":"
     END-IF
     PERFORM MATCH-SUB
     IF WS-SUB-OK = 0 AND WS-COUNT = 0 AND WS-SUB-LAST > 0
         MOVE WS-CANDIDATE TO WS-SWAP-TEXT
         MOVE WS-CANDIDATE-LENGTH TO WS-SWAP-LENGTH
         MOVE SPACES TO WS-CANDIDATE
         COMPUTE WS-CANDIDATE-LENGTH = WS-SWAP-LENGTH - WS-SUB-LAST
         MOVE WS-SWAP-TEXT(WS-SUB-LAST + 1:WS-CANDIDATE-LENGTH) TO WS-CANDIDATE
         PERFORM MATCH-SUB
         MOVE WS-SWAP-TEXT TO WS-CANDIDATE
         MOVE WS-SWAP-LENGTH TO WS-CANDIDATE-LENGTH
     END-IF
     IF WS-SUB-OK = 1
         IF NOT (WS-REMAINING-LENGTH = WS-CANDIDATE-LENGTH
                 AND WS-CANDIDATE(1:WS-CANDIDATE-LENGTH) = WS-REMAINING(1:WS-REMAINING-LENGTH))
             PERFORM ADD-ENTRY
         END-IF
     END-IF.

*> suggest(text): when the lower-case candidate starts with the lower-case text typed, unless equal to it
*> exactly; an entry already listed is not added again.
 OFFER.
     MOVE FUNCTION LOWER-CASE(WS-CANDIDATE) TO WS-CANDIDATE-LOWER
     IF WS-REMAINING-LENGTH <= WS-CANDIDATE-LENGTH
         IF WS-CANDIDATE-LOWER(1:WS-REMAINING-LENGTH) = WS-LOWER(1:WS-REMAINING-LENGTH)
                 OR WS-REMAINING-LENGTH = 0
             IF NOT (WS-REMAINING-LENGTH = WS-CANDIDATE-LENGTH
                     AND WS-CANDIDATE(1:WS-CANDIDATE-LENGTH) = WS-REMAINING(1:WS-REMAINING-LENGTH))
                 PERFORM ADD-ENTRY
             END-IF
         END-IF
     END-IF.

 ADD-ENTRY.
     MOVE 0 TO WS-DUPLICATE
     PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > BR-SG-COUNT
         IF BR-SG-TEXT-LENGTH(WS-J) = WS-CANDIDATE-LENGTH
                 AND BR-SG-TEXT(WS-J)(1:WS-CANDIDATE-LENGTH) = WS-CANDIDATE(1:WS-CANDIDATE-LENGTH)
             MOVE 1 TO WS-DUPLICATE
         END-IF
     END-PERFORM
     IF WS-DUPLICATE = 0 AND BR-SG-COUNT < BR-SG-MAX
         ADD 1 TO BR-SG-COUNT
         MOVE WS-CANDIDATE-LENGTH TO BR-SG-TEXT-LENGTH(BR-SG-COUNT)
         MOVE WS-CANDIDATE TO BR-SG-TEXT(BR-SG-COUNT)
         MOVE WS-TIP TO BR-SG-TIP(BR-SG-COUNT)
     END-IF.

*> A stable insertion sort by lower-case text (15a §6.4).
 SORT-ENTRIES.
     PERFORM VARYING WS-I FROM 2 BY 1 UNTIL WS-I > BR-SG-COUNT
         MOVE WS-I TO WS-J
         PERFORM UNTIL WS-J < 2
             MOVE FUNCTION LOWER-CASE(BR-SG-TEXT(WS-J - 1)) TO WS-LOWER-A
             MOVE FUNCTION LOWER-CASE(BR-SG-TEXT(WS-J)) TO WS-LOWER-B
             IF WS-LOWER-A > WS-LOWER-B
                 MOVE BR-SG-TEXT(WS-J - 1) TO WS-SWAP-TEXT
                 MOVE BR-SG-TEXT-LENGTH(WS-J - 1) TO WS-SWAP-LENGTH
                 MOVE BR-SG-TIP(WS-J - 1) TO WS-SWAP-TIP
                 MOVE BR-SG-TEXT(WS-J) TO BR-SG-TEXT(WS-J - 1)
                 MOVE BR-SG-TEXT-LENGTH(WS-J) TO BR-SG-TEXT-LENGTH(WS-J - 1)
                 MOVE BR-SG-TIP(WS-J) TO BR-SG-TIP(WS-J - 1)
                 MOVE WS-SWAP-TEXT TO BR-SG-TEXT(WS-J)
                 MOVE WS-SWAP-LENGTH TO BR-SG-TEXT-LENGTH(WS-J)
                 MOVE WS-SWAP-TIP TO BR-SG-TIP(WS-J)
                 SUBTRACT 1 FROM WS-J
             ELSE
                 MOVE 1 TO WS-J
             END-IF
         END-PERFORM
     END-PERFORM.

 MAIN-LINE.
     MOVE 0 TO BR-SG-START BR-SG-LENGTH BR-SG-COUNT
     CALL "BR-PARSE" USING L-LEVEL L-LINE L-LENGTH SR-TRAIL
     PERFORM FIND-CONTEXT
     COMPUTE WS-REMAINING-LENGTH = L-CURSOR - WS-START
     MOVE SPACES TO WS-REMAINING WS-LOWER
     IF WS-REMAINING-LENGTH > 0
         MOVE L-LINE(WS-START + 1:WS-REMAINING-LENGTH) TO WS-REMAINING
         MOVE FUNCTION LOWER-CASE(WS-REMAINING(1:WS-REMAINING-LENGTH)) TO WS-LOWER
     END-IF
     MOVE BR-N-FIRST(WS-PARENT) TO WS-CHILD
     PERFORM UNTIL WS-CHILD = 0
         PERFORM LIST-CHILD
         MOVE BR-N-NEXT(WS-CHILD) TO WS-CHILD
     END-PERFORM
     IF BR-SG-COUNT > 0
         PERFORM SORT-ENTRIES
         MOVE WS-START TO BR-SG-START
         COMPUTE BR-SG-LENGTH = L-CURSOR - WS-START
     END-IF.
 END PROGRAM BR-SUGGEST.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BR-SUGGESTIONS-BUILD.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BRIGADIER.
 COPY PROTO REPLACING LEADING ==PB-== BY ==SX-==.
 01 WS-PACKET-ID           BINARY-LONG VALUE 15.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-MAX                 BINARY-LONG VALUE 32767.
 01 WS-KEY                 PIC X(72).
 01 WS-TIP-KEYS.
    05 FILLER              PIC X(72) VALUE "argument.entity.selector.nearestPlayer".
    05 FILLER              PIC X(72) VALUE "argument.entity.selector.allPlayers".
    05 FILLER              PIC X(72) VALUE "argument.entity.selector.randomPlayer".
    05 FILLER              PIC X(72) VALUE "argument.entity.selector.self".
    05 FILLER              PIC X(72) VALUE "argument.entity.selector.allEntities".
    05 FILLER              PIC X(72) VALUE "argument.entity.selector.nearestEntity".
 01 WS-TIPS REDEFINES WS-TIP-KEYS.
    05 WS-TIP-KEY          PIC X(72) OCCURS 6 TIMES.
 01 WS-I                   BINARY-LONG.
 LINKAGE SECTION.
 COPY PROTO.
 01 L-TRANSACTION          BINARY-LONG.
 PROCEDURE DIVISION USING L-TRANSACTION PB-BUFFER.
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-PACKET-ID
     CALL "PB-PUT-VARINT" USING PB-BUFFER L-TRANSACTION
     CALL "PB-PUT-VARINT" USING PB-BUFFER BR-SG-START
     CALL "PB-PUT-VARINT" USING PB-BUFFER BR-SG-LENGTH
     CALL "PB-PUT-VARINT" USING PB-BUFFER BR-SG-COUNT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > BR-SG-COUNT
         CALL "PB-PUT-STRING" USING PB-BUFFER BR-SG-TEXT(WS-I) BR-SG-TEXT-LENGTH(WS-I) WS-MAX
         IF BR-SG-TIP(WS-I) = 0
             CALL "PB-PUT-BOOL" USING PB-BUFFER WS-ZERO
         ELSE
             CALL "PB-PUT-BOOL" USING PB-BUFFER WS-ONE
             MOVE WS-TIP-KEY(BR-SG-TIP(WS-I)) TO WS-KEY
             CALL "BX-KEY" USING SX-TEXT WS-KEY
             CALL "PB-PUT-TEXT" USING PB-BUFFER SX-TEXT
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM BR-SUGGESTIONS-BUILD.
