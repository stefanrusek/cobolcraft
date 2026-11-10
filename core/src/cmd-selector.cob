*> Entity selectors and the argument types built on them (docs/protocol/15-commands-framework.md §7, §6.3): entity (6) with its
*> single and players-only flags, game_profile (7), score_holder (31) and message (20, which embeds selectors).
*> BR-SEL-READ parses the selector grammar of §7.2 to §7.5 into BR-SEL (core/copy/BRSEL.cpy); the arguments apply the flag
*> checks of §7.2 point 4, §7.8 and §7.9. Parsing is syntactic: the selector is evaluated against the world by the command
*> (the candidate set of §7.6 is not here), and an entity type named by type= is checked against the entity type table
*> (CORE-ENTITY-TYPES, minecraft:player always) while advancement, predicate and tag names are the command's.
*> In the trail an entity argument leaves the selector type in the integer value, the limit in BR-V-IVAL2 and BR-V-AUX 1
*> when the selector can match entities; the executor reads the options by calling BR-SEL-READ on the argument's range.
*>
*> Entry points:
*>   BR-SEL-READ USING allowed (1 when the source may use @ selectors: level 2 or more): one selector from BR-IN-CURSOR
*>   BR-ARG-ENTITY USING node, integer out, double out, infinity flag out (as BR-ARG-EXT): the types 6, 7, 31 and 20

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BR-SEL-READ.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BRIGADIER.
 COPY BRSEL.
 COPY CITEMS.
 01 WS-KEYS                PIC X(400)
     VALUE "name distance level x y z dx dy dz x_rotation y_rotation limit sort gamemode team type tag nbt scores advancements predicate".
 01 WS-SORTS               PIC X(400) VALUE "arbitrary nearest furthest random".
 01 WS-MODES               PIC X(400) VALUE "survival creative adventure spectator".
 01 WS-START               BINARY-LONG.
 01 WS-C                   BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-CH                  PIC X.
 01 WS-STR                 PIC X(1024).
 01 WS-STR-LENGTH          BINARY-LONG.
 01 WS-KEY-TEXT            PIC X(1024).
 01 WS-KEY-LENGTH          BINARY-LONG.
 01 WS-KEY-START           BINARY-LONG.
 01 WS-KEY-INDEX           BINARY-LONG.
 01 WS-VALUE-START         BINARY-LONG.
 01 WS-NEG                 BINARY-LONG.
 01 WS-INDEX               BINARY-LONG.
 01 WS-DONE                BINARY-LONG.
 01 WS-LIST-DONE           BINARY-LONG.
 01 WS-CRIT-DONE           BINARY-LONG.
 01 WS-ENTRY-END           BINARY-LONG.
 01 WS-OK                  BINARY-LONG.
 01 WS-GROUPS              BINARY-LONG.
 01 WS-GROUP-DIGITS        BINARY-LONG.
 01 WS-ERR-KEY             PIC X(48).
 01 WS-ERR-TEXT            PIC X(1024).
 01 WS-ERR-LENGTH          BINARY-LONG.
 01 WS-ERR-CURSOR          BINARY-LONG.
 01 WS-KEY                 PIC X(48).
 01 WS-A1                  PIC X(64).
 01 WS-A2                  PIC X(64).
 01 WS-N-ARGS              BINARY-LONG.
 01 WS-L1                  BINARY-LONG.
 01 WS-L2                  BINARY-LONG.
 01 WS-RC                  BINARY-LONG.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-KIND-INT            BINARY-LONG VALUE 3.
 01 WS-KIND-DOUBLE         BINARY-LONG VALUE 2.
 01 WS-INT                 BINARY-DOUBLE.
 01 WS-DOUBLE              FLOAT-LONG.
 01 WS-INF                 BINARY-LONG.
 01 WS-AUX                 BINARY-LONG.
 01 WS-INT2                BINARY-DOUBLE.
 01 WS-DOUBLE2             FLOAT-LONG.
 01 WS-RANGE-KIND          BINARY-LONG.
 01 WS-ID-START            BINARY-LONG.
 01 WS-ID-LENGTH           BINARY-LONG.
 01 WS-ID-FLAGS            BINARY-LONG.
 01 WS-IS-TAG              BINARY-LONG.
 01 WS-NAME                PIC X(1040).
 01 WS-NAME-LENGTH         BINARY-LONG.
 01 WS-SNBT-KIND           BINARY-LONG.
 01 WS-DEFAULT-NS          PIC X(10) VALUE "minecraft:".
 01 WS-LIST-COUNT          BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-BIT                 BINARY-LONG.
 01 WS-PLAYER-KEY          PIC X(16) VALUE "minecraft:player".
 LINKAGE SECTION.
 01 L-ALLOWED              BINARY-LONG.
 PROCEDURE DIVISION USING L-ALLOWED.
     GO TO MAIN-LINE.

 RAISE-NOW.
     CALL "BR-RAISE" USING WS-KEY WS-N-ARGS WS-A1 WS-L1 WS-A2 WS-L2 WS-RC.

*> An exception with no arguments at WS-RC.
 RAISE-PLAIN.
     MOVE 0 TO WS-N-ARGS WS-L1 WS-L2
     PERFORM RAISE-NOW.

*> An exception with the text WS-ERR-TEXT (WS-ERR-LENGTH, at most 64) as its argument, cursor WS-RC.
 RAISE-TEXT.
     MOVE 1 TO WS-N-ARGS
     MOVE 0 TO WS-L2
     MOVE SPACES TO WS-A1
     MOVE WS-ERR-LENGTH TO WS-L1
     IF WS-L1 > 64
         MOVE 64 TO WS-L1
     END-IF
     IF WS-L1 > 0
         MOVE WS-ERR-TEXT(1:WS-L1) TO WS-A1(1:WS-L1)
     END-IF
     PERFORM RAISE-NOW.

 SKIP-SPACES.
     CALL "BR-SNBT-SKIP-SPACES".

*> parsing.expected with the character WS-CH at the cursor.
 RAISE-EXPECTED.
     MOVE "parsing.expected" TO WS-KEY
     MOVE WS-CH TO WS-ERR-TEXT(1:1)
     MOVE 1 TO WS-ERR-LENGTH
     MOVE BR-IN-CURSOR TO WS-RC
     PERFORM RAISE-TEXT.

*> The option key refused here (WS-KEY-TEXT) at WS-RC: argument.entity.options.inapplicable.
 RAISE-INAPPLICABLE.
     MOVE "argument.entity.options.inapplicable" TO WS-KEY
     MOVE WS-KEY-TEXT TO WS-ERR-TEXT
     MOVE WS-KEY-LENGTH TO WS-ERR-LENGTH
     PERFORM RAISE-TEXT.

*> ---- the name or UUID form (§7.2 point 2) ---------------------------------------------------------------
 DO-NAME.
     MOVE BR-IN-CURSOR TO WS-C
     CALL "BR-READ-STRING" USING WS-ONE WS-C WS-STR WS-STR-LENGTH
     IF BR-E-KEY = SPACES
         PERFORM CHECK-UUID
         EVALUATE TRUE
             WHEN WS-OK = 1
                 MOVE 8 TO SL-TYPE
                 MOVE 1 TO SL-INCLUDES-ENTITIES
             WHEN WS-STR-LENGTH = 0 OR WS-STR-LENGTH > 16
                 MOVE "argument.entity.invalid" TO WS-KEY
                 MOVE BR-IN-CURSOR TO WS-RC
                 PERFORM RAISE-PLAIN
             WHEN OTHER
                 MOVE 7 TO SL-TYPE
                 MOVE 0 TO SL-INCLUDES-ENTITIES
         END-EVALUATE
         IF BR-E-KEY = SPACES
             MOVE 1 TO SL-LIMIT
             MOVE WS-STR-LENGTH TO SL-TEXT-LENGTH
             MOVE WS-STR(1:WS-STR-LENGTH) TO SL-TEXT
             MOVE WS-C TO BR-IN-CURSOR
         END-IF
     END-IF.

*> WS-OK = 1 when WS-STR is a UUID the lenient way: five groups of 1 to 16 hexadecimal digits joined by -.
 CHECK-UUID.
     MOVE 1 TO WS-OK
     MOVE 1 TO WS-GROUPS
     MOVE 0 TO WS-GROUP-DIGITS
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-STR-LENGTH
         MOVE WS-STR(WS-I:1) TO WS-CH
         EVALUATE TRUE
             WHEN WS-CH = "-"
                 IF WS-GROUP-DIGITS = 0
                     MOVE 0 TO WS-OK
                 END-IF
                 ADD 1 TO WS-GROUPS
                 MOVE 0 TO WS-GROUP-DIGITS
             WHEN (WS-CH >= "0" AND WS-CH <= "9") OR (WS-CH >= "a" AND WS-CH <= "f")
                     OR (WS-CH >= "A" AND WS-CH <= "F")
                 ADD 1 TO WS-GROUP-DIGITS
                 IF WS-GROUP-DIGITS > 16
                     MOVE 0 TO WS-OK
                 END-IF
             WHEN OTHER
                 MOVE 0 TO WS-OK
         END-EVALUATE
     END-PERFORM
     IF WS-GROUPS NOT = 5 OR WS-GROUP-DIGITS = 0
         MOVE 0 TO WS-OK
     END-IF.

*> ---- the @ form (§7.2 point 1, §7.3) -----------------------------------------------------------------
 DO-AT.
     IF L-ALLOWED = 0
         MOVE "argument.entity.selector.not_allowed" TO WS-KEY
         MOVE BR-IN-CURSOR TO WS-RC
         PERFORM RAISE-PLAIN
     ELSE
         ADD 1 TO BR-IN-CURSOR
         IF BR-IN-CURSOR >= BR-IN-LENGTH
             MOVE "argument.entity.selector.missing" TO WS-KEY
             MOVE BR-IN-CURSOR TO WS-RC
             PERFORM RAISE-PLAIN
         ELSE
             PERFORM SELECTOR-TYPE
         END-IF
     END-IF.

 SELECTOR-TYPE.
     MOVE BR-IN-TEXT(BR-IN-CURSOR + 1:1) TO WS-CH
     EVALUATE WS-CH
         WHEN "p"
             MOVE 1 TO SL-TYPE SL-LIMIT SL-SORT
         WHEN "a"
             MOVE 2 TO SL-TYPE
         WHEN "r"
             MOVE 3 TO SL-TYPE SL-SORT
             MOVE 1 TO SL-LIMIT
         WHEN "s"
             MOVE 4 TO SL-TYPE
             MOVE 1 TO SL-LIMIT SL-INCLUDES-ENTITIES
         WHEN "e"
             MOVE 5 TO SL-TYPE
             MOVE 1 TO SL-INCLUDES-ENTITIES
         WHEN "n"
             MOVE 6 TO SL-TYPE
             MOVE 1 TO SL-LIMIT SL-SORT SL-INCLUDES-ENTITIES
         WHEN OTHER
             MOVE "argument.entity.selector.unknown" TO WS-KEY
             MOVE "@" TO WS-ERR-TEXT(1:1)
             MOVE WS-CH TO WS-ERR-TEXT(2:1)
             MOVE 2 TO WS-ERR-LENGTH
             MOVE BR-IN-CURSOR TO WS-RC
             PERFORM RAISE-TEXT
     END-EVALUATE
     IF BR-E-KEY = SPACES
         ADD 1 TO BR-IN-CURSOR
         IF BR-IN-CURSOR < BR-IN-LENGTH AND BR-IN-TEXT(BR-IN-CURSOR + 1:1) = "["
             ADD 1 TO BR-IN-CURSOR
             PERFORM DO-OPTIONS
         END-IF
     END-IF.

*> ---- the option list (§7.4) ---------------------------------------------------------------------------
 DO-OPTIONS.
     MOVE 0 TO WS-DONE
     PERFORM UNTIL WS-DONE = 1 OR BR-E-KEY NOT = SPACES
         PERFORM SKIP-SPACES
         IF BR-IN-CURSOR >= BR-IN-LENGTH OR BR-IN-TEXT(BR-IN-CURSOR + 1:1) = "]"
             MOVE 1 TO WS-DONE
         ELSE
             PERFORM ONE-OPTION
             IF BR-E-KEY = SPACES
                 PERFORM AFTER-OPTION
             END-IF
         END-IF
     END-PERFORM
     IF BR-E-KEY = SPACES
         IF BR-IN-CURSOR >= BR-IN-LENGTH OR BR-IN-TEXT(BR-IN-CURSOR + 1:1) NOT = "]"
             MOVE "argument.entity.options.unterminated" TO WS-KEY
             MOVE BR-IN-CURSOR TO WS-RC
             PERFORM RAISE-PLAIN
         ELSE
             ADD 1 TO BR-IN-CURSOR
         END-IF
     END-IF.

*> After a value: a comma goes on to the next option, a closing bracket ends the list, anything else is unterminated.
 AFTER-OPTION.
     PERFORM SKIP-SPACES
     EVALUATE TRUE
         WHEN BR-IN-CURSOR < BR-IN-LENGTH AND BR-IN-TEXT(BR-IN-CURSOR + 1:1) = ","
             ADD 1 TO BR-IN-CURSOR
         WHEN BR-IN-CURSOR < BR-IN-LENGTH AND BR-IN-TEXT(BR-IN-CURSOR + 1:1) = "]"
             MOVE 1 TO WS-DONE
         WHEN OTHER
             MOVE "argument.entity.options.unterminated" TO WS-KEY
             MOVE BR-IN-CURSOR TO WS-RC
             PERFORM RAISE-PLAIN
     END-EVALUATE.

 ONE-OPTION.
     MOVE BR-IN-CURSOR TO WS-KEY-START
     MOVE BR-IN-CURSOR TO WS-C
     CALL "BR-READ-STRING" USING WS-ONE WS-C WS-KEY-TEXT WS-KEY-LENGTH
     IF BR-E-KEY = SPACES
         MOVE WS-C TO BR-IN-CURSOR
         CALL "BR-ENUM-INDEX" USING WS-KEYS WS-KEY-TEXT WS-KEY-LENGTH WS-KEY-INDEX
         MOVE WS-KEY-START TO WS-RC
         EVALUATE TRUE
             WHEN WS-KEY-INDEX < 0
                 MOVE "argument.entity.options.unknown" TO WS-KEY
                 MOVE WS-KEY-TEXT TO WS-ERR-TEXT
                 MOVE WS-KEY-LENGTH TO WS-ERR-LENGTH
                 PERFORM RAISE-TEXT
             WHEN OTHER
                 PERFORM CHECK-KEY
         END-EVALUATE
     END-IF
     IF BR-E-KEY = SPACES
         PERFORM SKIP-SPACES
         IF BR-IN-CURSOR >= BR-IN-LENGTH OR BR-IN-TEXT(BR-IN-CURSOR + 1:1) NOT = "="
             MOVE "argument.entity.options.valueless" TO WS-KEY
             MOVE WS-KEY-TEXT TO WS-ERR-TEXT
             MOVE WS-KEY-LENGTH TO WS-ERR-LENGTH
             MOVE WS-KEY-START TO WS-RC
             PERFORM RAISE-TEXT
         ELSE
             ADD 1 TO BR-IN-CURSOR
             PERFORM SKIP-SPACES
             MOVE BR-IN-CURSOR TO WS-VALUE-START
             PERFORM READ-VALUE
         END-IF
     END-IF.

*> The key-level applicability of §7.5: a set-once option and a position, range or rotation key only while unset; the
*> invertable options (name, gamemode, team, type) not after a positive value; limit and sort not on @s.
 CHECK-KEY.
     MOVE 1 TO WS-OK
     EVALUATE WS-KEY-INDEX
         WHEN 0
             IF SL-NAME-STATE = 1
                 MOVE 0 TO WS-OK
             END-IF
         WHEN 1
             IF SL-DIST-AUX > 0
                 MOVE 0 TO WS-OK
             END-IF
         WHEN 2
             IF SL-LEVEL-AUX > 0
                 MOVE 0 TO WS-OK
             END-IF
         WHEN 3 THRU 8
             COMPUTE WS-I = WS-KEY-INDEX - 2
             IF SL-HAS-POS(WS-I) = 1
                 MOVE 0 TO WS-OK
             END-IF
         WHEN 9
             IF SL-XROT-AUX > 0
                 MOVE 0 TO WS-OK
             END-IF
         WHEN 10
             IF SL-YROT-AUX > 0
                 MOVE 0 TO WS-OK
             END-IF
         WHEN 11
             IF SL-LIMIT-SET = 1 OR SL-TYPE = 4
                 MOVE 0 TO WS-OK
             END-IF
         WHEN 12
             IF SL-SORT-SET = 1 OR SL-TYPE = 4
                 MOVE 0 TO WS-OK
             END-IF
         WHEN 13
             IF SL-GM-STATE = 1
                 MOVE 0 TO WS-OK
             END-IF
         WHEN 14
             IF SL-TEAM-STATE = 1
                 MOVE 0 TO WS-OK
             END-IF
         WHEN 15
             IF SL-TYPE-STATE = 1
                 MOVE 0 TO WS-OK
             END-IF
         WHEN 18
             IF SL-SCORES-SET = 1
                 MOVE 0 TO WS-OK
             END-IF
         WHEN 19
             IF SL-ADV-SET = 1
                 MOVE 0 TO WS-OK
             END-IF
     END-EVALUATE
     IF WS-OK = 0
         MOVE WS-KEY-START TO WS-RC
         PERFORM RAISE-INAPPLICABLE
     END-IF.

*> A value-level refusal (§7.5): the key's inapplicable exception with the cursor at the start of the value.
 REFUSE-VALUE.
     MOVE WS-VALUE-START TO WS-RC
     PERFORM RAISE-INAPPLICABLE.

 READ-VALUE.
     EVALUATE WS-KEY-INDEX
         WHEN 0
             PERFORM OPT-NAME
         WHEN 1
             PERFORM OPT-DISTANCE
         WHEN 2
             PERFORM OPT-LEVEL
         WHEN 3 THRU 8
             PERFORM OPT-POSITION
         WHEN 9
         WHEN 10
             PERFORM OPT-ROTATION
         WHEN 11
             PERFORM OPT-LIMIT
         WHEN 12
             PERFORM OPT-SORT
         WHEN 13
             PERFORM OPT-GAMEMODE
         WHEN 14
             PERFORM OPT-TEAM
         WHEN 15
             PERFORM OPT-TYPE
         WHEN 16
             PERFORM OPT-TAG
         WHEN 17
             PERFORM OPT-NBT
         WHEN 18
             PERFORM OPT-SCORES
         WHEN 19
             PERFORM OPT-ADVANCEMENTS
         WHEN OTHER
             PERFORM OPT-PREDICATE
     END-EVALUATE.

*> WS-NEG = 1 after an optional !.
 READ-NEGATION.
     MOVE 0 TO WS-NEG
     IF BR-IN-CURSOR < BR-IN-LENGTH AND BR-IN-TEXT(BR-IN-CURSOR + 1:1) = "!"
         MOVE 1 TO WS-NEG
         ADD 1 TO BR-IN-CURSOR
     END-IF.

*> WS-NAME of at least minecraft: in front of the identifier of the last BR-READ-ID (WS-ID-START, WS-ID-LENGTH).
 QUALIFY-ID.
     MOVE SPACES TO WS-NAME
     MOVE 0 TO WS-I
     PERFORM VARYING WS-C FROM WS-ID-START BY 1 UNTIL WS-C >= WS-ID-START + WS-ID-LENGTH
         IF BR-IN-TEXT(WS-C + 1:1) = ":"
             MOVE 1 TO WS-I
         END-IF
     END-PERFORM
     IF WS-I = 1
         MOVE BR-IN-TEXT(WS-ID-START + 1:WS-ID-LENGTH) TO WS-NAME
         MOVE WS-ID-LENGTH TO WS-NAME-LENGTH
     ELSE
         MOVE WS-DEFAULT-NS TO WS-NAME(1:10)
         MOVE BR-IN-TEXT(WS-ID-START + 1:WS-ID-LENGTH) TO WS-NAME(11:WS-ID-LENGTH)
         COMPUTE WS-NAME-LENGTH = WS-ID-LENGTH + 10
     END-IF.

*> The invertable options: a positive value needs the state NONE (0); WS-STATE holds the option's state.
 CHECK-POSITIVE.
     IF WS-NEG = 0 AND WS-STATE NOT = 0
         PERFORM REFUSE-VALUE
     END-IF.

 OPT-NAME.
     PERFORM READ-NEGATION
     MOVE SL-NAME-STATE TO WS-STATE
     PERFORM CHECK-POSITIVE
     IF BR-E-KEY = SPACES AND SL-NAME-COUNT >= SL-MAX-LIST
         PERFORM REFUSE-VALUE
     END-IF
     IF BR-E-KEY = SPACES
         MOVE BR-IN-CURSOR TO WS-C
         CALL "BR-READ-STRING" USING WS-ONE WS-C WS-STR WS-STR-LENGTH
     END-IF
     IF BR-E-KEY = SPACES
         MOVE WS-C TO BR-IN-CURSOR
         ADD 1 TO SL-NAME-COUNT
         MOVE WS-NEG TO SL-NAME-NEG(SL-NAME-COUNT)
         IF WS-STR-LENGTH > 48
             MOVE 48 TO WS-STR-LENGTH
         END-IF
         MOVE WS-STR-LENGTH TO SL-NAME-LENGTH(SL-NAME-COUNT)
         MOVE WS-STR(1:48) TO SL-NAME-TEXT(SL-NAME-COUNT)
         MOVE 1 TO SL-NAME-STATE
         IF WS-NEG = 1
             MOVE 2 TO SL-NAME-STATE
         END-IF
     END-IF.

 OPT-DISTANCE.
     MOVE 1 TO WS-RANGE-KIND
     CALL "BR-READ-RANGE" USING WS-RANGE-KIND WS-AUX WS-INT WS-INT2 WS-DOUBLE WS-DOUBLE2
     IF BR-E-KEY = SPACES
         IF (WS-AUX NOT = 2 AND WS-DOUBLE < 0) OR (WS-AUX >= 2 AND WS-DOUBLE2 < 0)
             MOVE "argument.entity.options.distance.negative" TO WS-KEY
             MOVE WS-VALUE-START TO WS-RC
             PERFORM RAISE-PLAIN
         ELSE
             MOVE WS-AUX TO SL-DIST-AUX
             MOVE WS-DOUBLE TO SL-DIST-MIN
             MOVE WS-DOUBLE2 TO SL-DIST-MAX
             MOVE 1 TO SL-WORLD-LIMITED
         END-IF
     END-IF.

 OPT-LEVEL.
     MOVE 0 TO WS-RANGE-KIND
     CALL "BR-READ-RANGE" USING WS-RANGE-KIND WS-AUX WS-INT WS-INT2 WS-DOUBLE WS-DOUBLE2
     IF BR-E-KEY = SPACES
         IF (WS-AUX NOT = 2 AND WS-INT < 0) OR (WS-AUX >= 2 AND WS-INT2 < 0)
             MOVE "argument.entity.options.level.negative" TO WS-KEY
             MOVE WS-VALUE-START TO WS-RC
             PERFORM RAISE-PLAIN
         ELSE
             MOVE WS-AUX TO SL-LEVEL-AUX
             MOVE WS-INT TO SL-LEVEL-MIN
             MOVE WS-INT2 TO SL-LEVEL-MAX
             MOVE 0 TO SL-INCLUDES-ENTITIES
         END-IF
     END-IF.

 OPT-POSITION.
     CALL "BR-READ-PLAIN" USING WS-KIND-DOUBLE WS-INT WS-DOUBLE WS-INF
     IF BR-E-KEY = SPACES
         COMPUTE WS-I = WS-KEY-INDEX - 2
         MOVE 1 TO SL-HAS-POS(WS-I) SL-WORLD-LIMITED
         MOVE WS-DOUBLE TO SL-POS(WS-I)
     END-IF.

 OPT-ROTATION.
     MOVE 2 TO WS-RANGE-KIND
     CALL "BR-READ-RANGE" USING WS-RANGE-KIND WS-AUX WS-INT WS-INT2 WS-DOUBLE WS-DOUBLE2
     IF BR-E-KEY = SPACES
         IF WS-KEY-INDEX = 9
             MOVE WS-AUX TO SL-XROT-AUX
             MOVE WS-DOUBLE TO SL-XROT-MIN
             MOVE WS-DOUBLE2 TO SL-XROT-MAX
         ELSE
             MOVE WS-AUX TO SL-YROT-AUX
             MOVE WS-DOUBLE TO SL-YROT-MIN
             MOVE WS-DOUBLE2 TO SL-YROT-MAX
         END-IF
     END-IF.

 OPT-LIMIT.
     CALL "BR-READ-PLAIN" USING WS-KIND-INT WS-INT WS-DOUBLE WS-INF
     IF BR-E-KEY = SPACES
         IF WS-INT < 1
             MOVE "argument.entity.options.limit.toosmall" TO WS-KEY
             MOVE WS-VALUE-START TO WS-RC
             PERFORM RAISE-PLAIN
         ELSE
             MOVE WS-INT TO SL-LIMIT
             MOVE 1 TO SL-LIMIT-SET
         END-IF
     END-IF.

 OPT-SORT.
     MOVE BR-IN-CURSOR TO WS-C
     CALL "BR-READ-STRING" USING WS-ZERO WS-C WS-STR WS-STR-LENGTH
     CALL "BR-ENUM-INDEX" USING WS-SORTS WS-STR WS-STR-LENGTH WS-INDEX
     IF WS-INDEX < 0
         MOVE "argument.entity.options.sort.irreversible" TO WS-KEY
         MOVE WS-STR TO WS-ERR-TEXT
         MOVE WS-STR-LENGTH TO WS-ERR-LENGTH
         MOVE WS-VALUE-START TO WS-RC
         PERFORM RAISE-TEXT
     ELSE
         MOVE WS-INDEX TO SL-SORT
         MOVE 1 TO SL-SORT-SET
         MOVE WS-C TO BR-IN-CURSOR
     END-IF.

 OPT-GAMEMODE.
     PERFORM READ-NEGATION
     MOVE SL-GM-STATE TO WS-STATE
     PERFORM CHECK-POSITIVE
     IF BR-E-KEY = SPACES
         MOVE BR-IN-CURSOR TO WS-C
         CALL "BR-READ-STRING" USING WS-ZERO WS-C WS-STR WS-STR-LENGTH
         CALL "BR-ENUM-INDEX" USING WS-MODES WS-STR WS-STR-LENGTH WS-INDEX
         IF WS-INDEX < 0
             MOVE "argument.entity.options.mode.invalid" TO WS-KEY
             MOVE WS-STR TO WS-ERR-TEXT
             MOVE WS-STR-LENGTH TO WS-ERR-LENGTH
             MOVE WS-VALUE-START TO WS-RC
             PERFORM RAISE-TEXT
         ELSE
             MOVE WS-C TO BR-IN-CURSOR
             COMPUTE WS-BIT = 2 ** WS-INDEX
             IF WS-NEG = 1
                 ADD WS-BIT TO SL-GM-DENY
                 MOVE 2 TO SL-GM-STATE
             ELSE
                 MOVE WS-BIT TO SL-GM-ALLOW
                 MOVE 1 TO SL-GM-STATE
             END-IF
             MOVE 0 TO SL-INCLUDES-ENTITIES
         END-IF
     END-IF.

 OPT-TEAM.
     PERFORM READ-NEGATION
     MOVE SL-TEAM-STATE TO WS-STATE
     PERFORM CHECK-POSITIVE
     IF BR-E-KEY = SPACES AND SL-TEAM-COUNT >= SL-MAX-LIST
         PERFORM REFUSE-VALUE
     END-IF
     IF BR-E-KEY = SPACES
         MOVE BR-IN-CURSOR TO WS-C
         CALL "BR-READ-STRING" USING WS-ZERO WS-C WS-STR WS-STR-LENGTH
         MOVE WS-C TO BR-IN-CURSOR
         ADD 1 TO SL-TEAM-COUNT
         MOVE WS-NEG TO SL-TEAM-NEG(SL-TEAM-COUNT)
         IF WS-STR-LENGTH > 48
             MOVE 48 TO WS-STR-LENGTH
         END-IF
         MOVE WS-STR-LENGTH TO SL-TEAM-LENGTH(SL-TEAM-COUNT)
         MOVE WS-STR(1:48) TO SL-TEAM-TEXT(SL-TEAM-COUNT)
         MOVE 1 TO SL-TEAM-STATE
         IF WS-NEG = 1
             MOVE 2 TO SL-TEAM-STATE
         END-IF
     END-IF.

 OPT-TAG.
     PERFORM READ-NEGATION
     IF SL-TAG-COUNT >= SL-MAX-LIST
         PERFORM REFUSE-VALUE
     ELSE
         MOVE BR-IN-CURSOR TO WS-C
         CALL "BR-READ-STRING" USING WS-ZERO WS-C WS-STR WS-STR-LENGTH
         MOVE WS-C TO BR-IN-CURSOR
         ADD 1 TO SL-TAG-COUNT
         MOVE WS-NEG TO SL-TAG-NEG(SL-TAG-COUNT)
         IF WS-STR-LENGTH > 48
             MOVE 48 TO WS-STR-LENGTH
         END-IF
         MOVE WS-STR-LENGTH TO SL-TAG-LENGTH(SL-TAG-COUNT)
         MOVE WS-STR(1:48) TO SL-TAG-TEXT(SL-TAG-COUNT)
     END-IF.

*> type=: an optional !, # for a tag, an identifier that names an entity type (the table, minecraft:player).
 OPT-TYPE.
     PERFORM READ-NEGATION
     MOVE 0 TO WS-IS-TAG
     IF BR-IN-CURSOR < BR-IN-LENGTH AND BR-IN-TEXT(BR-IN-CURSOR + 1:1) = "#"
         MOVE 1 TO WS-IS-TAG
         ADD 1 TO BR-IN-CURSOR
     END-IF
     MOVE SL-TYPE-STATE TO WS-STATE
     IF WS-IS-TAG = 0
         PERFORM CHECK-POSITIVE
     END-IF
     IF BR-E-KEY = SPACES AND SL-TYPE-COUNT >= SL-MAX-LIST
         PERFORM REFUSE-VALUE
     END-IF
     IF BR-E-KEY = SPACES
         MOVE 0 TO WS-ID-FLAGS
         CALL "BR-READ-ID" USING WS-ID-FLAGS WS-ID-START WS-ID-LENGTH
     END-IF
     IF BR-E-KEY = SPACES
         PERFORM QUALIFY-ID
         IF WS-IS-TAG = 1
             PERFORM CHECK-TAG-REPEAT
         ELSE
             PERFORM CHECK-ENTITY-TYPE
         END-IF
     END-IF
     IF BR-E-KEY = SPACES
         ADD 1 TO SL-TYPE-COUNT
         MOVE WS-NEG TO SL-TYPE-NEG(SL-TYPE-COUNT)
         MOVE WS-IS-TAG TO SL-TYPE-TAG(SL-TYPE-COUNT)
         MOVE WS-NAME-LENGTH TO SL-TYPE-LENGTH(SL-TYPE-COUNT)
         MOVE WS-NAME TO SL-TYPE-TEXT(SL-TYPE-COUNT)
         IF WS-IS-TAG = 0
             MOVE 1 TO SL-TYPE-STATE
             IF WS-NEG = 1
                 MOVE 2 TO SL-TYPE-STATE
             END-IF
             IF WS-NEG = 0 AND WS-NAME(1:WS-NAME-LENGTH) = WS-PLAYER-KEY
                 MOVE 0 TO SL-INCLUDES-ENTITIES
             END-IF
         END-IF
     END-IF.

*> The same tag may not be given twice (a value-level refusal).
 CHECK-TAG-REPEAT.
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > SL-TYPE-COUNT
         IF SL-TYPE-TAG(WS-I) = 1 AND SL-TYPE-TEXT(WS-I) = WS-NAME
             PERFORM REFUSE-VALUE
         END-IF
     END-PERFORM.

*> An unknown entity type is argument.entity.options.type.invalid with the identifier, at the start of the value.
 CHECK-ENTITY-TYPE.
     MOVE 0 TO WS-OK
     IF WS-NAME(1:WS-NAME-LENGTH) = WS-PLAYER-KEY
         MOVE 1 TO WS-OK
     END-IF
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > ET-COUNT
         IF ET-KEY(WS-I) = WS-NAME
             MOVE 1 TO WS-OK
         END-IF
     END-PERFORM
     IF WS-OK = 0
         MOVE "argument.entity.options.type.invalid" TO WS-KEY
         MOVE WS-NAME TO WS-ERR-TEXT
         MOVE WS-NAME-LENGTH TO WS-ERR-LENGTH
         MOVE WS-VALUE-START TO WS-RC
         PERFORM RAISE-TEXT
     END-IF.

 OPT-NBT.
     PERFORM READ-NEGATION
     IF SL-NBT-COUNT >= SL-MAX-LIST
         PERFORM REFUSE-VALUE
     ELSE
         MOVE BR-IN-CURSOR TO WS-C
         CALL "BR-SNBT-VALUE" USING WS-SNBT-KIND
         IF BR-E-KEY = SPACES AND WS-SNBT-KIND NOT = 1
             MOVE "argument.nbt.expected.compound" TO WS-KEY
             MOVE WS-C TO WS-RC
             PERFORM RAISE-PLAIN
         END-IF
         IF BR-E-KEY = SPACES
             ADD 1 TO SL-NBT-COUNT
             MOVE WS-NEG TO SL-NBT-NEG(SL-NBT-COUNT)
             MOVE WS-C TO SL-NBT-START(SL-NBT-COUNT)
             MOVE BR-IN-CURSOR TO SL-NBT-END(SL-NBT-COUNT)
         END-IF
     END-IF.

 EXPECT-OPEN-BRACE.
     IF BR-IN-CURSOR < BR-IN-LENGTH AND BR-IN-TEXT(BR-IN-CURSOR + 1:1) = "{"
         ADD 1 TO BR-IN-CURSOR
     ELSE
         MOVE "{" TO WS-CH
         PERFORM RAISE-EXPECTED
     END-IF.

 EXPECT-EQUALS.
     PERFORM SKIP-SPACES
     IF BR-IN-CURSOR < BR-IN-LENGTH AND BR-IN-TEXT(BR-IN-CURSOR + 1:1) = "="
         ADD 1 TO BR-IN-CURSOR
         PERFORM SKIP-SPACES
     ELSE
         MOVE "=" TO WS-CH
         PERFORM RAISE-EXPECTED
     END-IF.

*> scores={objective=range,...}: whitespace around the tokens; the objective is an unquoted run.
 OPT-SCORES.
     PERFORM EXPECT-OPEN-BRACE
     MOVE 0 TO WS-LIST-DONE
     PERFORM UNTIL WS-LIST-DONE = 1 OR BR-E-KEY NOT = SPACES
         PERFORM SKIP-SPACES
         IF BR-IN-CURSOR < BR-IN-LENGTH AND BR-IN-TEXT(BR-IN-CURSOR + 1:1) = "}"
             ADD 1 TO BR-IN-CURSOR
             MOVE 1 TO WS-LIST-DONE
         ELSE
             PERFORM ONE-SCORE
         END-IF
     END-PERFORM
     IF BR-E-KEY = SPACES
         MOVE 1 TO SL-SCORES-SET
     END-IF.

 ONE-SCORE.
     MOVE BR-IN-CURSOR TO WS-C
     CALL "BR-READ-STRING" USING WS-ZERO WS-C WS-STR WS-STR-LENGTH
     MOVE WS-C TO BR-IN-CURSOR
     PERFORM EXPECT-EQUALS
     IF BR-E-KEY = SPACES
         MOVE 0 TO WS-RANGE-KIND
         CALL "BR-READ-RANGE" USING WS-RANGE-KIND WS-AUX WS-INT WS-INT2 WS-DOUBLE WS-DOUBLE2
     END-IF
     IF BR-E-KEY = SPACES AND SL-SCORE-COUNT >= SL-MAX-LIST
         MOVE WS-VALUE-START TO WS-RC
         PERFORM RAISE-INAPPLICABLE
     END-IF
     IF BR-E-KEY = SPACES
         ADD 1 TO SL-SCORE-COUNT
         IF WS-STR-LENGTH > 48
             MOVE 48 TO WS-STR-LENGTH
         END-IF
         MOVE WS-STR-LENGTH TO SL-SCORE-LENGTH(SL-SCORE-COUNT)
         MOVE WS-STR(1:48) TO SL-SCORE-OBJECTIVE(SL-SCORE-COUNT)
         MOVE WS-AUX TO SL-SCORE-AUX(SL-SCORE-COUNT)
         MOVE WS-INT TO SL-SCORE-MIN(SL-SCORE-COUNT)
         MOVE WS-INT2 TO SL-SCORE-MAX(SL-SCORE-COUNT)
         PERFORM SKIP-SPACES
         PERFORM AFTER-ENTRY
         MOVE WS-ENTRY-END TO WS-LIST-DONE
     END-IF.

*> After an entry of a braced list: a comma goes on, the closing brace ends it (WS-ENTRY-END 1), anything else is expected }.
 AFTER-ENTRY.
     MOVE 0 TO WS-ENTRY-END
     EVALUATE TRUE
         WHEN BR-IN-CURSOR < BR-IN-LENGTH AND BR-IN-TEXT(BR-IN-CURSOR + 1:1) = ","
             ADD 1 TO BR-IN-CURSOR
         WHEN BR-IN-CURSOR < BR-IN-LENGTH AND BR-IN-TEXT(BR-IN-CURSOR + 1:1) = "}"
             ADD 1 TO BR-IN-CURSOR
             MOVE 1 TO WS-ENTRY-END
         WHEN OTHER
             MOVE "}" TO WS-CH
             PERFORM RAISE-EXPECTED
     END-EVALUATE.

*> advancements={advancement=true|false, advancement={criterion=true|false,...},...}
 OPT-ADVANCEMENTS.
     MOVE BR-IN-CURSOR TO SL-ADV-START
     PERFORM EXPECT-OPEN-BRACE
     MOVE 0 TO WS-LIST-DONE
     PERFORM UNTIL WS-LIST-DONE = 1 OR BR-E-KEY NOT = SPACES
         PERFORM SKIP-SPACES
         IF BR-IN-CURSOR < BR-IN-LENGTH AND BR-IN-TEXT(BR-IN-CURSOR + 1:1) = "}"
             ADD 1 TO BR-IN-CURSOR
             MOVE 1 TO WS-LIST-DONE
         ELSE
             PERFORM ONE-ADVANCEMENT
         END-IF
     END-PERFORM
     IF BR-E-KEY = SPACES
         MOVE BR-IN-CURSOR TO SL-ADV-END
         MOVE 1 TO SL-ADV-SET
         MOVE 0 TO SL-INCLUDES-ENTITIES
     END-IF.

 ONE-ADVANCEMENT.
     MOVE 0 TO WS-ID-FLAGS
     CALL "BR-READ-ID" USING WS-ID-FLAGS WS-ID-START WS-ID-LENGTH
     IF BR-E-KEY = SPACES
         PERFORM EXPECT-EQUALS
     END-IF
     IF BR-E-KEY = SPACES
         IF BR-IN-CURSOR < BR-IN-LENGTH AND BR-IN-TEXT(BR-IN-CURSOR + 1:1) = "{"
             PERFORM CRITERIA-LIST
         ELSE
             PERFORM READ-BOOLEAN
         END-IF
     END-IF
     IF BR-E-KEY = SPACES
         PERFORM SKIP-SPACES
         PERFORM AFTER-ENTRY
         MOVE WS-ENTRY-END TO WS-LIST-DONE
     END-IF.

*> {criterion=true|false,...} of one advancement (its own closing brace).
 CRITERIA-LIST.
     ADD 1 TO BR-IN-CURSOR
     MOVE 0 TO WS-CRIT-DONE
     PERFORM UNTIL WS-CRIT-DONE = 1 OR BR-E-KEY NOT = SPACES
         PERFORM SKIP-SPACES
         IF BR-IN-CURSOR < BR-IN-LENGTH AND BR-IN-TEXT(BR-IN-CURSOR + 1:1) = "}"
             ADD 1 TO BR-IN-CURSOR
             MOVE 1 TO WS-CRIT-DONE
         ELSE
             MOVE BR-IN-CURSOR TO WS-C
             CALL "BR-READ-STRING" USING WS-ZERO WS-C WS-STR WS-STR-LENGTH
             MOVE WS-C TO BR-IN-CURSOR
             PERFORM EXPECT-EQUALS
             IF BR-E-KEY = SPACES
                 PERFORM READ-BOOLEAN
             END-IF
             IF BR-E-KEY = SPACES
                 PERFORM SKIP-SPACES
                 PERFORM AFTER-ENTRY
                 MOVE WS-ENTRY-END TO WS-CRIT-DONE
             END-IF
         END-IF
     END-PERFORM.

 READ-BOOLEAN.
     MOVE BR-IN-CURSOR TO WS-C
     CALL "BR-READ-STRING" USING WS-ZERO WS-C WS-STR WS-STR-LENGTH
     IF (WS-STR-LENGTH = 4 AND WS-STR(1:4) = "true") OR (WS-STR-LENGTH = 5 AND WS-STR(1:5) = "false")
         MOVE WS-C TO BR-IN-CURSOR
     ELSE
         MOVE "parsing.bool.invalid" TO WS-KEY
         MOVE WS-STR TO WS-ERR-TEXT
         MOVE WS-STR-LENGTH TO WS-ERR-LENGTH
         MOVE BR-IN-CURSOR TO WS-RC
         PERFORM RAISE-TEXT
     END-IF.

 OPT-PREDICATE.
     PERFORM READ-NEGATION
     IF SL-PRED-COUNT >= SL-MAX-LIST
         PERFORM REFUSE-VALUE
     ELSE
         MOVE 0 TO WS-ID-FLAGS
         CALL "BR-READ-ID" USING WS-ID-FLAGS WS-ID-START WS-ID-LENGTH
         IF BR-E-KEY = SPACES
             PERFORM QUALIFY-ID
             ADD 1 TO SL-PRED-COUNT
             MOVE WS-NEG TO SL-PRED-NEG(SL-PRED-COUNT)
             MOVE WS-NAME-LENGTH TO SL-PRED-LENGTH(SL-PRED-COUNT)
             MOVE WS-NAME TO SL-PRED-TEXT(SL-PRED-COUNT)
         END-IF
     END-IF.

 MAIN-LINE.
     INITIALIZE BR-SEL
     MOVE 2147483647 TO SL-LIMIT
     MOVE SPACES TO BR-E-KEY
     MOVE BR-IN-CURSOR TO WS-START
     IF BR-IN-CURSOR < BR-IN-LENGTH AND BR-IN-TEXT(BR-IN-CURSOR + 1:1) = "@"
         PERFORM DO-AT
     ELSE
         PERFORM DO-NAME
     END-IF.
 END PROGRAM BR-SEL-READ.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BR-ARG-ENTITY.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BRIGADIER.
 COPY BRSEL.
 01 WS-ALLOWED             BINARY-LONG.
 01 WS-START               BINARY-LONG.
 01 WS-C                   BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-POS                 BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-LENGTH              BINARY-LONG.
 01 WS-DONE                BINARY-LONG.
 01 WS-KEY                 PIC X(48).
 01 WS-A1                  PIC X(64).
 01 WS-A2                  PIC X(64).
 01 WS-N-ARGS              BINARY-LONG.
 01 WS-L1                  BINARY-LONG.
 01 WS-L2                  BINARY-LONG.
 01 WS-RC                  BINARY-LONG.
 01 WS-EDIT                PIC -(9)9.
 01 WS-STR                 PIC X(1024).
 01 WS-STR-LENGTH          BINARY-LONG.
 01 WS-OK                  BINARY-LONG.
 01 WS-GROUPS              BINARY-LONG.
 01 WS-GROUP-DIGITS        BINARY-LONG.
 01 WS-CH                  PIC X.
 LINKAGE SECTION.
 01 L-NODE                 BINARY-LONG.
 01 L-INT                  BINARY-DOUBLE.
 01 L-DOUBLE               FLOAT-LONG.
 01 L-INF                  BINARY-LONG.
 PROCEDURE DIVISION USING L-NODE L-INT L-DOUBLE L-INF.
     GO TO MAIN-LINE.

 RAISE-NOW.
     CALL "BR-RAISE" USING WS-KEY WS-N-ARGS WS-A1 WS-L1 WS-A2 WS-L2 WS-RC.

 RAISE-PLAIN.
     MOVE 0 TO WS-N-ARGS WS-L1 WS-L2
     PERFORM RAISE-NOW.

*> What the trail keeps of the selector just read.
 KEEP-SELECTOR.
     MOVE SL-TYPE TO L-INT
     MOVE SL-LIMIT TO BR-V-IVAL2
     MOVE SL-INCLUDES-ENTITIES TO BR-V-AUX.

*> The text up to the next space as a name, UUID or (score holder) name-only holder.
 PLAIN-NAME.
     MOVE BR-IN-CURSOR TO WS-C
     PERFORM UNTIL WS-C >= BR-IN-LENGTH OR BR-IN-TEXT(WS-C + 1:1) = SPACE
         ADD 1 TO WS-C
     END-PERFORM
     INITIALIZE BR-SEL
     MOVE 1 TO SL-LIMIT
     MOVE 7 TO SL-TYPE
     COMPUTE SL-TEXT-LENGTH = WS-C - BR-IN-CURSOR
     IF SL-TEXT-LENGTH > 64
         MOVE 64 TO SL-TEXT-LENGTH
     END-IF
     IF SL-TEXT-LENGTH > 0
         MOVE BR-IN-TEXT(BR-IN-CURSOR + 1:SL-TEXT-LENGTH) TO SL-TEXT(1:SL-TEXT-LENGTH)
     END-IF
     MOVE WS-C TO BR-IN-CURSOR.

*> The single and players-only flags of §7.2 point 4 on the selector read; the cursor of both errors is 0.
 CHECK-FLAGS.
     IF FUNCTION MOD(BR-N-FLAGS(L-NODE), 2) = 1 AND SL-LIMIT > 1
         IF BR-N-FLAGS(L-NODE) >= 2
             MOVE "argument.player.toomany" TO WS-KEY
         ELSE
             MOVE "argument.entity.toomany" TO WS-KEY
         END-IF
         MOVE 0 TO WS-RC
         PERFORM RAISE-PLAIN
     END-IF
     IF BR-E-KEY = SPACES AND BR-N-FLAGS(L-NODE) >= 2 AND SL-INCLUDES-ENTITIES = 1 AND SL-TYPE NOT = 4
         MOVE "argument.player.entities" TO WS-KEY
         MOVE 0 TO WS-RC
         PERFORM RAISE-PLAIN
     END-IF.

 DO-ENTITY.
     CALL "BR-SEL-READ" USING WS-ALLOWED
     IF BR-E-KEY = SPACES
         PERFORM CHECK-FLAGS
     END-IF
     IF BR-E-KEY = SPACES
         PERFORM KEEP-SELECTOR
     END-IF.

*> game_profile: a selector that includes entities is refused after it; else a name, up to the next space.
 DO-PROFILE.
     IF BR-IN-CURSOR < BR-IN-LENGTH AND BR-IN-TEXT(BR-IN-CURSOR + 1:1) = "@"
         CALL "BR-SEL-READ" USING WS-ALLOWED
         IF BR-E-KEY = SPACES AND SL-INCLUDES-ENTITIES = 1
             MOVE "argument.player.entities" TO WS-KEY
             MOVE BR-IN-CURSOR TO WS-RC
             PERFORM RAISE-PLAIN
         END-IF
     ELSE
         PERFORM PLAIN-NAME
     END-IF
     IF BR-E-KEY = SPACES
         PERFORM KEEP-SELECTOR
     END-IF.

*> score_holder: a selector (one result unless the node allows several), else * # names, UUIDs and names.
 DO-HOLDER.
     IF BR-IN-CURSOR < BR-IN-LENGTH AND BR-IN-TEXT(BR-IN-CURSOR + 1:1) = "@"
         CALL "BR-SEL-READ" USING WS-ALLOWED
         IF BR-E-KEY = SPACES AND SL-LIMIT > 1 AND FUNCTION MOD(BR-N-FLAGS(L-NODE), 2) = 0
             MOVE "argument.entity.toomany" TO WS-KEY
             MOVE BR-IN-CURSOR TO WS-RC
             PERFORM RAISE-PLAIN
         END-IF
     ELSE
         PERFORM PLAIN-NAME
         PERFORM HOLDER-UUID
     END-IF
     IF BR-E-KEY = SPACES
         PERFORM KEEP-SELECTOR
     END-IF.

*> A holder text that is a UUID (five hexadecimal groups) is looked up as an entity by it.
 HOLDER-UUID.
     MOVE 1 TO WS-OK
     MOVE 1 TO WS-GROUPS
     MOVE 0 TO WS-GROUP-DIGITS
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > SL-TEXT-LENGTH
         MOVE SL-TEXT(WS-I:1) TO WS-CH
         EVALUATE TRUE
             WHEN WS-CH = "-"
                 IF WS-GROUP-DIGITS = 0
                     MOVE 0 TO WS-OK
                 END-IF
                 ADD 1 TO WS-GROUPS
                 MOVE 0 TO WS-GROUP-DIGITS
             WHEN (WS-CH >= "0" AND WS-CH <= "9") OR (WS-CH >= "a" AND WS-CH <= "f")
                     OR (WS-CH >= "A" AND WS-CH <= "F")
                 ADD 1 TO WS-GROUP-DIGITS
                 IF WS-GROUP-DIGITS > 16
                     MOVE 0 TO WS-OK
                 END-IF
             WHEN OTHER
                 MOVE 0 TO WS-OK
         END-EVALUATE
     END-PERFORM
     IF WS-OK = 1 AND WS-GROUPS = 5 AND WS-GROUP-DIGITS > 0
         MOVE 8 TO SL-TYPE
         MOVE 1 TO SL-INCLUDES-ENTITIES
     END-IF.

*> message: at most 256 characters; each @ starts a selector, a missing or unknown selector type leaves the @ as text;
*> the whole rest of the line is the message. The value is the number of selectors.
 DO-MESSAGE.
     COMPUTE WS-LENGTH = BR-IN-LENGTH - BR-IN-CURSOR
     IF WS-LENGTH > 256
         MOVE "argument.message.too_long" TO WS-KEY
         MOVE 2 TO WS-N-ARGS
         MOVE WS-LENGTH TO WS-EDIT
         MOVE FUNCTION TRIM(WS-EDIT) TO WS-A1
         MOVE FUNCTION LENGTH(FUNCTION TRIM(WS-EDIT)) TO WS-L1
         MOVE "256" TO WS-A2
         MOVE 3 TO WS-L2
         MOVE -1 TO WS-RC
         PERFORM RAISE-NOW
     ELSE
         MOVE 0 TO WS-COUNT
         MOVE BR-IN-CURSOR TO WS-POS
         PERFORM UNTIL WS-POS >= BR-IN-LENGTH OR BR-E-KEY NOT = SPACES
             IF BR-IN-TEXT(WS-POS + 1:1) = "@"
                 MOVE WS-POS TO BR-IN-CURSOR
                 MOVE 1 TO WS-ALLOWED
                 CALL "BR-SEL-READ" USING WS-ALLOWED
                 EVALUATE TRUE
                     WHEN BR-E-KEY = SPACES
                         ADD 1 TO WS-COUNT
                         MOVE BR-IN-CURSOR TO WS-POS
                     WHEN BR-E-KEY = "argument.entity.selector.missing"
                             OR BR-E-KEY = "argument.entity.selector.unknown"
                         MOVE SPACES TO BR-E-KEY
                         ADD 1 TO WS-POS
                 END-EVALUATE
             ELSE
                 ADD 1 TO WS-POS
             END-IF
         END-PERFORM
         IF BR-E-KEY = SPACES
             MOVE BR-IN-LENGTH TO BR-IN-CURSOR
             MOVE WS-COUNT TO L-INT
         END-IF
     END-IF.

 MAIN-LINE.
     CALL "BR-SELECTORS-ALLOWED" USING BR-IN-LEVEL WS-ALLOWED
     EVALUATE BR-N-TYPE(L-NODE)
         WHEN BR-P-ENTITY
             PERFORM DO-ENTITY
         WHEN BR-P-GAME-PROFILE
             PERFORM DO-PROFILE
         WHEN BR-P-SCORE-HOLDER
             PERFORM DO-HOLDER
         WHEN OTHER
             PERFORM DO-MESSAGE
     END-EVALUATE.
 END PROGRAM BR-ARG-ENTITY.
