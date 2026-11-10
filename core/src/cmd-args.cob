*> What a command reads from its parsed context (core/copy/BRRUN.cpy BR-RUN; docs/protocol/15-commands-framework.md §7.6, §7.8):
*> the nodes of the context by name, argument text, and entity selectors resolved against the players.
*>
*> Entry points:
*>   BX-FIND USING name (PIC X(32), space padded), index out (the argument entry of BR-R-ARG with that name, 0 = not in the context)
*>   BX-LIT USING name, index out: the same for a literal node of the context
*>   BX-STRING USING index, text out (PIC X(1024)), length out: the argument as a string: its text in the line, unquoted when it
*>     was quoted (a word, phrase or greedy string)
*>   BX-RESOLVE USING index, rows out (BX-ROWS group: BX-COUNT, BX-ROW(1 to 64) player rows): the players an entity argument
*>     selects for the source BR-SRC (15 §7.6 over the player table; the entities that are not players are not looked for), cut to
*>     the limit and ordered; none selected raises argument.entity.notfound.player (the argument is a players argument) or
*>     argument.entity.notfound.entity and sets BR-R-FAILED. A selector that uses nbt, scores, advancements or predicate raises
*>     cobolcraft.selector.unsupported with the option name and sets BR-R-FAILED (BLOCKED: no entity data, scoreboard, advancement
*>     or predicate store exists)
*>   BX-POSITION USING index, x out, y out, z out (FLOAT-LONG): a coordinate argument as a position of the source's world (a block position is the
*>     floor of it); BX-MESSAGE USING index, text out, length out; BX-TARGETS-OR-SELF USING name, rows out
*>   BX-PROFILES USING index, profiles out (BX-PROFILES group: BX-PCOUNT, BX-PROFILE(1 to 64): name, name length, offline UUID):
*>     a game_profile argument: a plain name is one profile whether or not the player is online (the profile is looked up, a
*>     never-seen name is accepted); a selector is its players

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BX-FIND.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BRRUN.
 01 WS-I                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-NAME                 PIC X(32).
 01 L-INDEX                BINARY-LONG.
 PROCEDURE DIVISION USING L-NAME L-INDEX.
     MOVE 0 TO L-INDEX
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > BR-R-COUNT OR L-INDEX > 0
         IF BA-NAME(WS-I) = L-NAME AND BA-ARG(WS-I) = 1
             MOVE WS-I TO L-INDEX
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM BX-FIND.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BX-LIT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BRRUN.
 01 WS-I                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-NAME                 PIC X(32).
 01 L-INDEX                BINARY-LONG.
 PROCEDURE DIVISION USING L-NAME L-INDEX.
     MOVE 0 TO L-INDEX
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > BR-R-COUNT OR L-INDEX > 0
         IF BA-NAME(WS-I) = L-NAME AND BA-ARG(WS-I) = 0
             MOVE WS-I TO L-INDEX
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM BX-LIT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BX-STRING.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BRIGADIER.
 COPY BRRUN.
 01 WS-QUOTED              BINARY-LONG VALUE 1.
 01 WS-CURSOR              BINARY-LONG.
 LINKAGE SECTION.
 01 L-INDEX                BINARY-LONG.
 01 L-TEXT                 PIC X(1024).
 01 L-LENGTH               BINARY-LONG.
 PROCEDURE DIVISION USING L-INDEX L-TEXT L-LENGTH.
     MOVE BR-R-LINE TO BR-IN-TEXT
     MOVE BR-R-LENGTH TO BR-IN-LENGTH
     MOVE BA-START(L-INDEX) TO WS-CURSOR
     CALL "BR-READ-STRING" USING WS-QUOTED WS-CURSOR L-TEXT L-LENGTH
     GOBACK.
 END PROGRAM BX-STRING.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BX-RESOLVE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY BRIGADIER.
 COPY BRSEL.
 COPY BRRUN.
 01 WS-ALLOWED             BINARY-LONG VALUE 1.
 01 WS-ROW                 BINARY-LONG.
 01 WS-OK                  BINARY-LONG.
 01 WS-NODE                BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-MODE-BIT            BINARY-LONG.
 01 WS-DX                  FLOAT-LONG.
 01 WS-DY                  FLOAT-LONG.
 01 WS-DZ                  FLOAT-LONG.
 01 WS-DIST                FLOAT-LONG.
 01 WS-LO                  FLOAT-LONG.
 01 WS-HI                  FLOAT-LONG.
 01 WS-ORIGIN-X            FLOAT-LONG.
 01 WS-ORIGIN-Y            FLOAT-LONG.
 01 WS-ORIGIN-Z            FLOAT-LONG.
 01 WS-LIMIT               BINARY-LONG.
 01 WS-SORT                BINARY-LONG.
 01 WS-HAS-BOX             BINARY-LONG.
 01 WS-ANY-POSITIVE        BINARY-LONG.
 01 WS-MATCHED             BINARY-LONG.
 01 WS-KEY                 PIC X(48).
 01 WS-A1                  PIC X(64).
 01 WS-A2                  PIC X(64).
 01 WS-L1                  BINARY-LONG.
 01 WS-L2                  BINARY-LONG.
 01 WS-N-ARGS              BINARY-LONG.
 01 WS-RC                  BINARY-LONG VALUE -1.
 01 WS-SWAP                BINARY-LONG.
 01 WS-DISTANCES.
    05 WS-D                 FLOAT-LONG OCCURS 64 TIMES.
 01 WS-YAW                 FLOAT-LONG.
 01 WS-PLAYER-KEY          PIC X(16) VALUE "minecraft:player".
 01 WS-DEFAULT-NS          PIC X(10) VALUE "minecraft:".
 LINKAGE SECTION.
 01 L-INDEX                BINARY-LONG.
 01 L-ROWS.
    05 BX-COUNT             BINARY-LONG.
    05 BX-ROW               BINARY-LONG OCCURS 64 TIMES.
 PROCEDURE DIVISION USING L-INDEX L-ROWS.
     GO TO MAIN-LINE.

*> The selector of the argument is read again from the line (the parse kept only its type and limit).
 READ-SELECTOR.
     MOVE BR-R-LINE TO BR-IN-TEXT
     MOVE BR-R-LENGTH TO BR-IN-LENGTH
     MOVE BA-START(L-INDEX) TO BR-IN-CURSOR
     MOVE BS-LEVEL TO BR-IN-LEVEL
     CALL "BR-SEL-READ" USING WS-ALLOWED.

*> The option of the selector this resolver cannot evaluate raises cobolcraft.selector.unsupported with its name.
 UNSUPPORTED.
     MOVE "cobolcraft.selector.unsupported" TO WS-KEY
     MOVE 1 TO WS-N-ARGS
     MOVE SPACES TO WS-A1 WS-A2
     MOVE 0 TO WS-L2
     CALL "BR-RAISE" USING WS-KEY WS-N-ARGS WS-A1 WS-L1 WS-A2 WS-L2 WS-RC
     MOVE 1 TO BR-R-FAILED.

*> The origin of the selector: x y z where given, else the source position.
 ORIGIN.
     MOVE BS-X TO WS-ORIGIN-X
     MOVE BS-Y TO WS-ORIGIN-Y
     MOVE BS-Z TO WS-ORIGIN-Z
     IF SL-HAS-POS(1) = 1
         MOVE SL-POS(1) TO WS-ORIGIN-X
     END-IF
     IF SL-HAS-POS(2) = 1
         MOVE SL-POS(2) TO WS-ORIGIN-Y
     END-IF
     IF SL-HAS-POS(3) = 1
         MOVE SL-POS(3) TO WS-ORIGIN-Z
     END-IF.

*> WS-OK 0 when the player WS-ROW fails an option (15 §7.5 over a player: no team, no tag, level 0).
 TEST-PLAYER.
     MOVE 1 TO WS-OK
     IF SL-TYPE = 7
         IF PL-NAME-LENGTH(WS-ROW) NOT = SL-TEXT-LENGTH
                 OR PL-NAME(WS-ROW)(1:SL-TEXT-LENGTH) NOT = SL-TEXT(1:SL-TEXT-LENGTH)
             MOVE 0 TO WS-OK
         END-IF
     END-IF
     IF WS-OK = 1 AND SL-DIST-AUX > 0
         PERFORM TEST-DISTANCE
     END-IF
     IF WS-OK = 1 AND WS-HAS-BOX = 1
         PERFORM TEST-BOX
     END-IF
     IF WS-OK = 1 AND SL-LEVEL-AUX > 0
         PERFORM TEST-LEVEL
     END-IF
     IF WS-OK = 1 AND SL-GM-STATE > 0
         PERFORM TEST-MODE
     END-IF
     IF WS-OK = 1 AND SL-NAME-COUNT > 0
         PERFORM TEST-NAMES
     END-IF
     IF WS-OK = 1 AND SL-TEAM-COUNT > 0
         PERFORM TEST-TEAMS
     END-IF
     IF WS-OK = 1 AND SL-TAG-COUNT > 0
         PERFORM TEST-TAGS
     END-IF
     IF WS-OK = 1 AND SL-TYPE-COUNT > 0
         PERFORM TEST-TYPES
     END-IF
     IF WS-OK = 1 AND SL-XROT-AUX > 0
         PERFORM TEST-XROT
     END-IF
     IF WS-OK = 1 AND SL-YROT-AUX > 0
         PERFORM TEST-YROT
     END-IF.

 TEST-DISTANCE.
     COMPUTE WS-DX = PL-X(WS-ROW) - WS-ORIGIN-X
     COMPUTE WS-DY = PL-Y(WS-ROW) - WS-ORIGIN-Y
     COMPUTE WS-DZ = PL-Z(WS-ROW) - WS-ORIGIN-Z
     COMPUTE WS-DIST = WS-DX * WS-DX + WS-DY * WS-DY + WS-DZ * WS-DZ
     IF (SL-DIST-AUX = 1 OR SL-DIST-AUX = 3) AND WS-DIST < SL-DIST-MIN * SL-DIST-MIN
         MOVE 0 TO WS-OK
     END-IF
     IF (SL-DIST-AUX = 2 OR SL-DIST-AUX = 3) AND WS-DIST > SL-DIST-MAX * SL-DIST-MAX
         MOVE 0 TO WS-OK
     END-IF.

*> The box [origin + lo, origin + hi] of each axis (15 §7.6 point 1) must meet the player's box (0.6 wide, 1.8 tall).
 TEST-BOX.
     MOVE 0 TO WS-DX
     IF SL-HAS-POS(4) = 1
         MOVE SL-POS(4) TO WS-DX
     END-IF
     IF WS-DX < 0
         COMPUTE WS-LO = WS-ORIGIN-X + WS-DX
         COMPUTE WS-HI = WS-ORIGIN-X + 1
     ELSE
         COMPUTE WS-LO = WS-ORIGIN-X
         COMPUTE WS-HI = WS-ORIGIN-X + WS-DX + 1
     END-IF
     IF PL-X(WS-ROW) + 0.3 <= WS-LO OR PL-X(WS-ROW) - 0.3 >= WS-HI
         MOVE 0 TO WS-OK
     END-IF
     MOVE 0 TO WS-DY
     IF SL-HAS-POS(5) = 1
         MOVE SL-POS(5) TO WS-DY
     END-IF
     IF WS-DY < 0
         COMPUTE WS-LO = WS-ORIGIN-Y + WS-DY
         COMPUTE WS-HI = WS-ORIGIN-Y + 1
     ELSE
         COMPUTE WS-LO = WS-ORIGIN-Y
         COMPUTE WS-HI = WS-ORIGIN-Y + WS-DY + 1
     END-IF
     IF PL-Y(WS-ROW) + 1.8 <= WS-LO OR PL-Y(WS-ROW) >= WS-HI
         MOVE 0 TO WS-OK
     END-IF
     MOVE 0 TO WS-DZ
     IF SL-HAS-POS(6) = 1
         MOVE SL-POS(6) TO WS-DZ
     END-IF
     IF WS-DZ < 0
         COMPUTE WS-LO = WS-ORIGIN-Z + WS-DZ
         COMPUTE WS-HI = WS-ORIGIN-Z + 1
     ELSE
         COMPUTE WS-LO = WS-ORIGIN-Z
         COMPUTE WS-HI = WS-ORIGIN-Z + WS-DZ + 1
     END-IF
     IF PL-Z(WS-ROW) + 0.3 <= WS-LO OR PL-Z(WS-ROW) - 0.3 >= WS-HI
         MOVE 0 TO WS-OK
     END-IF.

*> No experience exists: every player has level 0.
 TEST-LEVEL.
     IF (SL-LEVEL-AUX = 1 OR SL-LEVEL-AUX = 3) AND SL-LEVEL-MIN > 0
         MOVE 0 TO WS-OK
     END-IF
     IF (SL-LEVEL-AUX = 2 OR SL-LEVEL-AUX = 3) AND SL-LEVEL-MAX < 0
         MOVE 0 TO WS-OK
     END-IF.

*> The game mode masks: survival 1, creative 2 (the player's PL-MODE 0 and 1).
 TEST-MODE.
     COMPUTE WS-MODE-BIT = 2 ** PL-MODE(WS-ROW)
     IF SL-GM-STATE = 1
         COMPUTE WS-N = SL-GM-ALLOW / WS-MODE-BIT
         IF FUNCTION MOD(WS-N, 2) NOT = 1
             MOVE 0 TO WS-OK
         END-IF
     ELSE
         COMPUTE WS-N = SL-GM-DENY / WS-MODE-BIT
         IF FUNCTION MOD(WS-N, 2) = 1
             MOVE 0 TO WS-OK
         END-IF
     END-IF.

*> name=: a positive name must be one of the positive names, a negated one none of them.
 TEST-NAMES.
     MOVE 0 TO WS-ANY-POSITIVE WS-MATCHED
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > SL-NAME-COUNT
         MOVE 0 TO WS-N
         IF SL-NAME-LENGTH(WS-I) = PL-NAME-LENGTH(WS-ROW)
             MOVE PL-NAME-LENGTH(WS-ROW) TO WS-J
             IF SL-NAME-TEXT(WS-I)(1:WS-J) = PL-NAME(WS-ROW)(1:WS-J)
                 MOVE 1 TO WS-N
             END-IF
         END-IF
         IF SL-NAME-NEG(WS-I) = 1
             IF WS-N = 1
                 MOVE 0 TO WS-OK
             END-IF
         ELSE
             MOVE 1 TO WS-ANY-POSITIVE
             IF WS-N = 1
                 MOVE 1 TO WS-MATCHED
             END-IF
         END-IF
     END-PERFORM
     IF WS-ANY-POSITIVE = 1 AND WS-MATCHED = 0
         MOVE 0 TO WS-OK
     END-IF.

*> team=: a player is on no team (no teams exist): team= (empty) and team=!x match, any other positive team does not.
 TEST-TEAMS.
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > SL-TEAM-COUNT
         IF SL-TEAM-NEG(WS-I) = 0 AND SL-TEAM-LENGTH(WS-I) > 0
             MOVE 0 TO WS-OK
         END-IF
         IF SL-TEAM-NEG(WS-I) = 1 AND SL-TEAM-LENGTH(WS-I) = 0
             MOVE 0 TO WS-OK
         END-IF
     END-PERFORM.

*> tag=: a player has no tags (no tag store exists): tag= (empty) and tag=!x match, any other positive tag does not.
 TEST-TAGS.
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > SL-TAG-COUNT
         IF SL-TAG-NEG(WS-I) = 0 AND SL-TAG-LENGTH(WS-I) > 0
             MOVE 0 TO WS-OK
         END-IF
         IF SL-TAG-NEG(WS-I) = 1 AND SL-TAG-LENGTH(WS-I) = 0
             MOVE 0 TO WS-OK
         END-IF
     END-PERFORM.

*> type=: a player is minecraft:player; a positive type that is another type, or any tag, does not match; !minecraft:player excludes.
 TEST-TYPES.
     MOVE 0 TO WS-ANY-POSITIVE WS-MATCHED
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > SL-TYPE-COUNT
         MOVE 0 TO WS-N
         IF SL-TYPE-TAG(WS-I) = 0 AND SL-TYPE-LENGTH(WS-I) = 16
                 AND SL-TYPE-TEXT(WS-I)(1:16) = WS-PLAYER-KEY
             MOVE 1 TO WS-N
         END-IF
         IF SL-TYPE-NEG(WS-I) = 1
             IF WS-N = 1
                 MOVE 0 TO WS-OK
             END-IF
         ELSE
             MOVE 1 TO WS-ANY-POSITIVE
             IF WS-N = 1
                 MOVE 1 TO WS-MATCHED
             END-IF
         END-IF
     END-PERFORM
     IF WS-ANY-POSITIVE = 1 AND WS-MATCHED = 0
         MOVE 0 TO WS-OK
     END-IF.

 TEST-XROT.
     IF (SL-XROT-AUX = 1 OR SL-XROT-AUX = 3) AND PL-PITCH(WS-ROW) < SL-XROT-MIN
         MOVE 0 TO WS-OK
     END-IF
     IF (SL-XROT-AUX = 2 OR SL-XROT-AUX = 3) AND PL-PITCH(WS-ROW) > SL-XROT-MAX
         MOVE 0 TO WS-OK
     END-IF.

*> The yaw is wrapped to degrees (-180 up to 180) before the range test.
 TEST-YROT.
     COMPUTE WS-YAW = FUNCTION MOD(PL-YAW(WS-ROW) + 180, 360)
     IF WS-YAW < 0
         ADD 360 TO WS-YAW
     END-IF
     COMPUTE WS-YAW = WS-YAW - 180
     IF (SL-YROT-AUX = 1 OR SL-YROT-AUX = 3) AND WS-YAW < SL-YROT-MIN
         MOVE 0 TO WS-OK
     END-IF
     IF (SL-YROT-AUX = 2 OR SL-YROT-AUX = 3) AND WS-YAW > SL-YROT-MAX
         MOVE 0 TO WS-OK
     END-IF.

*> The players that pass the type and the options, ordered and cut to the limit.
 COLLECT.
     PERFORM VARYING WS-ROW FROM 1 BY 1 UNTIL WS-ROW > 64
         MOVE 0 TO WS-OK
         IF PL-USED(WS-ROW) = 1 AND PL-STATE(WS-ROW) NOT = PS-JOINING
             MOVE 1 TO WS-OK
             IF SL-TYPE = 4 AND WS-ROW NOT = BS-ROW
                 MOVE 0 TO WS-OK
             END-IF
             IF WS-OK = 1 AND SL-WORLD-LIMITED = 1 AND PL-DIM(WS-ROW) NOT = BS-DIM
                 MOVE 0 TO WS-OK
             END-IF
         END-IF
         IF WS-OK = 1
             PERFORM TEST-PLAYER
         END-IF
         IF WS-OK = 1
             ADD 1 TO BX-COUNT
             MOVE WS-ROW TO BX-ROW(BX-COUNT)
             COMPUTE WS-DX = PL-X(WS-ROW) - WS-ORIGIN-X
             COMPUTE WS-DY = PL-Y(WS-ROW) - WS-ORIGIN-Y
             COMPUTE WS-DZ = PL-Z(WS-ROW) - WS-ORIGIN-Z
             COMPUTE WS-D(BX-COUNT) = WS-DX * WS-DX + WS-DY * WS-DY + WS-DZ * WS-DZ
         END-IF
     END-PERFORM
     MOVE SL-SORT TO WS-SORT
     IF SL-TYPE = 1 OR SL-TYPE = 6
         MOVE 1 TO WS-SORT
     END-IF
     IF SL-TYPE = 3
         MOVE 3 TO WS-SORT
     END-IF
     IF WS-SORT = 1 OR WS-SORT = 2
         PERFORM ORDER-BY-DISTANCE
     END-IF
     IF WS-SORT = 3
         PERFORM ORDER-RANDOM
     END-IF
     MOVE SL-LIMIT TO WS-LIMIT
     IF BX-COUNT > WS-LIMIT
         MOVE WS-LIMIT TO BX-COUNT
     END-IF.

*> A selection sort on the squared distances: nearest first (sort 1) or furthest first (2).
 ORDER-BY-DISTANCE.
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I >= BX-COUNT
         MOVE WS-I TO WS-N
         PERFORM VARYING WS-J FROM WS-I BY 1 UNTIL WS-J > BX-COUNT
             IF (WS-SORT = 1 AND WS-D(WS-J) < WS-D(WS-N)) OR (WS-SORT = 2 AND WS-D(WS-J) > WS-D(WS-N))
                 MOVE WS-J TO WS-N
             END-IF
         END-PERFORM
         IF WS-N NOT = WS-I
             MOVE BX-ROW(WS-I) TO WS-SWAP
             MOVE BX-ROW(WS-N) TO BX-ROW(WS-I)
             MOVE WS-SWAP TO BX-ROW(WS-N)
             MOVE WS-D(WS-I) TO WS-DIST
             MOVE WS-D(WS-N) TO WS-D(WS-I)
             MOVE WS-DIST TO WS-D(WS-N)
         END-IF
     END-PERFORM.

*> Fisher-Yates over the matches with FUNCTION RANDOM.
 ORDER-RANDOM.
     PERFORM VARYING WS-I FROM BX-COUNT BY -1 UNTIL WS-I < 2
         COMPUTE WS-N = FUNCTION INTEGER(FUNCTION RANDOM * WS-I) + 1
         MOVE BX-ROW(WS-I) TO WS-SWAP
         MOVE BX-ROW(WS-N) TO BX-ROW(WS-I)
         MOVE WS-SWAP TO BX-ROW(WS-N)
     END-PERFORM.

 MAIN-LINE.
     MOVE 0 TO BX-COUNT
     PERFORM READ-SELECTOR
     PERFORM ORIGIN
     MOVE 0 TO WS-HAS-BOX
     IF SL-HAS-POS(4) = 1 OR SL-HAS-POS(5) = 1 OR SL-HAS-POS(6) = 1
         MOVE 1 TO WS-HAS-BOX
     END-IF
     EVALUATE TRUE
         WHEN SL-NBT-COUNT > 0
             MOVE "nbt" TO WS-A1
             MOVE 3 TO WS-L1
             PERFORM UNSUPPORTED
         WHEN SL-SCORES-SET = 1
             MOVE "scores" TO WS-A1
             MOVE 6 TO WS-L1
             PERFORM UNSUPPORTED
         WHEN SL-ADV-SET = 1
             MOVE "advancements" TO WS-A1
             MOVE 12 TO WS-L1
             PERFORM UNSUPPORTED
         WHEN SL-PRED-COUNT > 0
             MOVE "predicate" TO WS-A1
             MOVE 9 TO WS-L1
             PERFORM UNSUPPORTED
         WHEN OTHER
             PERFORM COLLECT
     END-EVALUATE
     IF BR-R-FAILED = 0 AND BX-COUNT = 0
         MOVE "argument.entity.notfound.entity" TO WS-KEY
         MOVE BA-NODE(L-INDEX) TO WS-NODE
         COMPUTE WS-N = BR-N-FLAGS(WS-NODE) / BR-F-PLAYERS
         IF FUNCTION MOD(WS-N, 2) = 1 OR SL-INCLUDES-ENTITIES = 0
             MOVE "argument.entity.notfound.player" TO WS-KEY
         END-IF
         MOVE 0 TO WS-N-ARGS WS-L1 WS-L2
         MOVE SPACES TO WS-A1 WS-A2
         CALL "BR-RAISE" USING WS-KEY WS-N-ARGS WS-A1 WS-L1 WS-A2 WS-L2 WS-RC
         MOVE 1 TO BR-R-FAILED
     END-IF
     GOBACK.
 END PROGRAM BX-RESOLVE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BX-PROFILES.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY BRIGADIER.
 COPY BRSEL.
 COPY BRRUN.
 01 WS-ALLOWED             BINARY-LONG VALUE 1.
 01 WS-ROWS.
    05 WS-COUNT             BINARY-LONG.
    05 WS-ROW               BINARY-LONG OCCURS 64 TIMES.
 01 WS-I                   BINARY-LONG.
 01 WS-KEY                 PIC X(48).
 01 WS-A1                  PIC X(64).
 01 WS-A2                  PIC X(64).
 01 WS-L1                  BINARY-LONG VALUE 0.
 01 WS-L2                  BINARY-LONG VALUE 0.
 01 WS-N-ARGS              BINARY-LONG VALUE 0.
 01 WS-RC                  BINARY-LONG VALUE -1.
 LINKAGE SECTION.
 01 L-INDEX                BINARY-LONG.
 01 L-PROFILES.
    05 BX-PCOUNT            BINARY-LONG.
    05 BX-PROFILE           OCCURS 64 TIMES.
       10 BX-P-NAME          PIC X(16).
       10 BX-P-LENGTH        BINARY-LONG.
       10 BX-P-UUID          PIC X(16).
 PROCEDURE DIVISION USING L-INDEX L-PROFILES.
     MOVE 0 TO BX-PCOUNT
     MOVE BR-R-LINE TO BR-IN-TEXT
     MOVE BR-R-LENGTH TO BR-IN-LENGTH
     MOVE BA-START(L-INDEX) TO BR-IN-CURSOR
     MOVE BS-LEVEL TO BR-IN-LEVEL
     CALL "BR-SEL-READ" USING WS-ALLOWED
     EVALUATE TRUE
         WHEN SL-TYPE = 7 AND SL-TEXT-LENGTH <= 16
             MOVE 1 TO BX-PCOUNT
             MOVE SPACES TO BX-P-NAME(1)
             MOVE SL-TEXT(1:SL-TEXT-LENGTH) TO BX-P-NAME(1)
             MOVE SL-TEXT-LENGTH TO BX-P-LENGTH(1)
             CALL "LOGIN-OFFLINE-UUID" USING BX-P-NAME(1) BX-P-LENGTH(1) BX-P-UUID(1)
         WHEN SL-TYPE = 7 OR SL-TYPE = 8
             MOVE "argument.player.unknown" TO WS-KEY
             MOVE SPACES TO WS-A1 WS-A2
             CALL "BR-RAISE" USING WS-KEY WS-N-ARGS WS-A1 WS-L1 WS-A2 WS-L2 WS-RC
             MOVE 1 TO BR-R-FAILED
         WHEN OTHER
             CALL "BX-RESOLVE" USING L-INDEX WS-ROWS
             IF BR-R-FAILED = 0
                 PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-COUNT
                     ADD 1 TO BX-PCOUNT
                     MOVE PL-NAME(WS-ROW(WS-I)) TO BX-P-NAME(BX-PCOUNT)
                     MOVE PL-NAME-LENGTH(WS-ROW(WS-I)) TO BX-P-LENGTH(BX-PCOUNT)
                     MOVE PL-UUID(WS-ROW(WS-I)) TO BX-P-UUID(BX-PCOUNT)
                 END-PERFORM
             END-IF
     END-EVALUATE
     GOBACK.
 END PROGRAM BX-PROFILES.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BX-MESSAGE.
*> USING index, text out (PIC X(1024)), length out: a message argument (15 §6.3) resolved for the source: when the source holds
*> level 2 (the atom commands/entity_selectors) each selector in it is replaced by the names of the players it selects
*> joined by a comma and a space (an empty selection is an empty text); a lone @ stays; without the permission the whole text is
*> literal. A selector that cannot be evaluated (BX-RESOLVE raises it) fails the command (BR-R-FAILED).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BRIGADIER.
 COPY BRRUN.
 01 WS-ALLOWED             BINARY-LONG.
 01 WS-POS                 BINARY-LONG.
 01 WS-END                 BINARY-LONG.
 01 WS-START               BINARY-LONG.
 01 WS-ROWS.
    05 WS-COUNT             BINARY-LONG.
    05 WS-ROW               BINARY-LONG OCCURS 64 TIMES.
 01 WS-I                   BINARY-LONG.
 01 WS-ROW-NO              BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-ALLOWED-ARG         BINARY-LONG VALUE 1.
 COPY CORESTATE.
 LINKAGE SECTION.
 01 L-INDEX                BINARY-LONG.
 01 L-TEXT                 PIC X(1024).
 01 L-LENGTH               BINARY-LONG.
 PROCEDURE DIVISION USING L-INDEX L-TEXT L-LENGTH.
     MOVE SPACES TO L-TEXT
     MOVE 0 TO L-LENGTH
     CALL "BR-SELECTORS-ALLOWED" USING BS-LEVEL WS-ALLOWED
     MOVE BA-START(L-INDEX) TO WS-START
     MOVE BA-END(L-INDEX) TO WS-END
     MOVE WS-START TO WS-POS
     PERFORM UNTIL WS-POS >= WS-END OR BR-R-FAILED = 1
         IF BR-R-LINE(WS-POS + 1:1) = "@" AND WS-ALLOWED = 1
             MOVE BR-R-LINE TO BR-IN-TEXT
             MOVE BR-R-LENGTH TO BR-IN-LENGTH
             MOVE WS-POS TO BR-IN-CURSOR
             MOVE BS-LEVEL TO BR-IN-LEVEL
             CALL "BR-SEL-READ" USING WS-ALLOWED-ARG
             IF BR-E-KEY = SPACES
                 MOVE BR-IN-CURSOR TO WS-N
                 MOVE WS-POS TO BA-START(L-INDEX)
                 CALL "BX-RESOLVE" USING L-INDEX WS-ROWS
                 IF BR-R-FAILED = 1 AND BR-E-KEY(1:19) = "argument.entity.not"
                     MOVE 0 TO BR-R-FAILED WS-COUNT
                     MOVE SPACES TO BR-E-KEY
                 END-IF
                 PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-COUNT
                     MOVE WS-ROW(WS-I) TO WS-ROW-NO
                     IF WS-I > 1
                         MOVE ", " TO L-TEXT(L-LENGTH + 1:2)
                         ADD 2 TO L-LENGTH
                     END-IF
                     MOVE PL-NAME(WS-ROW-NO)(1:PL-NAME-LENGTH(WS-ROW-NO)) TO L-TEXT(L-LENGTH + 1:PL-NAME-LENGTH(WS-ROW-NO))
                     ADD PL-NAME-LENGTH(WS-ROW-NO) TO L-LENGTH
                 END-PERFORM
                 MOVE WS-N TO WS-POS
             ELSE
                 MOVE SPACES TO BR-E-KEY
                 ADD 1 TO L-LENGTH
                 MOVE "@" TO L-TEXT(L-LENGTH:1)
                 ADD 1 TO WS-POS
             END-IF
         ELSE
             ADD 1 TO L-LENGTH
             MOVE BR-R-LINE(WS-POS + 1:1) TO L-TEXT(L-LENGTH:1)
             ADD 1 TO WS-POS
         END-IF
     END-PERFORM
     MOVE WS-START TO BA-START(L-INDEX)
     GOBACK.
 END PROGRAM BX-MESSAGE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BX-TARGETS-OR-SELF.
*> USING name (PIC X(32), space padded), rows out (BX-ROWS group as BX-RESOLVE): the players of the optional entity argument of that
*> name; when the context has none they are the source itself, which must be a player (the console raises
*> permissions.requires.player and BR-R-FAILED is set)
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BRRUN.
 01 WS-INDEX               BINARY-LONG.
 01 WS-KEY                 PIC X(48) VALUE "permissions.requires.player".
 01 WS-A1                  PIC X(64).
 01 WS-A2                  PIC X(64).
 01 WS-N-ARGS              BINARY-LONG VALUE 0.
 01 WS-L1                  BINARY-LONG VALUE 0.
 01 WS-L2                  BINARY-LONG VALUE 0.
 01 WS-RC                  BINARY-LONG VALUE -1.
 LINKAGE SECTION.
 01 L-NAME                 PIC X(32).
 01 L-ROWS.
    05 BX-COUNT             BINARY-LONG.
    05 BX-ROW               BINARY-LONG OCCURS 64 TIMES.
 PROCEDURE DIVISION USING L-NAME L-ROWS.
     MOVE 0 TO BX-COUNT
     CALL "BX-FIND" USING L-NAME WS-INDEX
     EVALUATE TRUE
         WHEN WS-INDEX > 0
             CALL "BX-RESOLVE" USING WS-INDEX L-ROWS
         WHEN BS-ROW = 0
             MOVE SPACES TO WS-A1 WS-A2
             CALL "BR-RAISE" USING WS-KEY WS-N-ARGS WS-A1 WS-L1 WS-A2 WS-L2 WS-RC
             MOVE 1 TO BR-R-FAILED
         WHEN OTHER
             MOVE 1 TO BX-COUNT
             MOVE BS-ROW TO BX-ROW(1)
     END-EVALUATE
     GOBACK.
 END PROGRAM BX-TARGETS-OR-SELF.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BX-POSITION.
*> USING index, x out, y out, z out (FLOAT-LONG): the position of a coordinate argument (15 §8): an absolute component is its value
*> (the parser added the centre correction), a relative one is the source's component plus the offset, and a local position
*> (^ ^ ^) is the anchored position of the source plus the offsets along its forward, up and left vectors (15 §8.3). A block
*> position is the floor of the result (the caller takes it).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BRRUN.
 01 WS-DEGREES             FLOAT-LONG VALUE 0.017453292.
 01 WS-YAW                 FLOAT-LONG.
 01 WS-PITCH               FLOAT-LONG.
 01 WS-CY                  FLOAT-LONG.
 01 WS-SY                  FLOAT-LONG.
 01 WS-CP                  FLOAT-LONG.
 01 WS-SP                  FLOAT-LONG.
 01 WS-CP2                 FLOAT-LONG.
 01 WS-SP2                 FLOAT-LONG.
 01 WS-FX                  FLOAT-LONG.
 01 WS-FY                  FLOAT-LONG.
 01 WS-FZ                  FLOAT-LONG.
 01 WS-UX                  FLOAT-LONG.
 01 WS-UY                  FLOAT-LONG.
 01 WS-UZ                  FLOAT-LONG.
 01 WS-LX                  FLOAT-LONG.
 01 WS-LY                  FLOAT-LONG.
 01 WS-LZ                  FLOAT-LONG.
 01 WS-EYE                 FLOAT-LONG VALUE 1.62.
 LINKAGE SECTION.
 01 L-INDEX                BINARY-LONG.
 01 L-X                    FLOAT-LONG.
 01 L-Y                    FLOAT-LONG.
 01 L-Z                    FLOAT-LONG.
 PROCEDURE DIVISION USING L-INDEX L-X L-Y L-Z.
     IF BA-KIND(L-INDEX, 1) = 2
         COMPUTE WS-YAW = (BS-YAW + 90) * WS-DEGREES
         COMPUTE WS-PITCH = 0 - BS-PITCH * WS-DEGREES
         COMPUTE WS-CY = FUNCTION COS(WS-YAW)
         COMPUTE WS-SY = FUNCTION SIN(WS-YAW)
         COMPUTE WS-CP = FUNCTION COS(WS-PITCH)
         COMPUTE WS-SP = FUNCTION SIN(WS-PITCH)
         COMPUTE WS-CP2 = FUNCTION COS(WS-PITCH + 90 * WS-DEGREES)
         COMPUTE WS-SP2 = FUNCTION SIN(WS-PITCH + 90 * WS-DEGREES)
         COMPUTE WS-FX = WS-CY * WS-CP
         MOVE WS-SP TO WS-FY
         COMPUTE WS-FZ = WS-SY * WS-CP
         COMPUTE WS-UX = WS-CY * WS-CP2
         MOVE WS-SP2 TO WS-UY
         COMPUTE WS-UZ = WS-SY * WS-CP2
         COMPUTE WS-LX = 0 - (WS-FY * WS-UZ - WS-FZ * WS-UY)
         COMPUTE WS-LY = 0 - (WS-FZ * WS-UX - WS-FX * WS-UZ)
         COMPUTE WS-LZ = 0 - (WS-FX * WS-UY - WS-FY * WS-UX)
         MOVE BS-X TO L-X
         MOVE BS-Y TO L-Y
         MOVE BS-Z TO L-Z
         IF BS-ANCHOR = 1
             ADD WS-EYE TO L-Y
         END-IF
         COMPUTE L-X = L-X + WS-FX * BA-NUM(L-INDEX, 3) + WS-UX * BA-NUM(L-INDEX, 2) + WS-LX * BA-NUM(L-INDEX, 1)
         COMPUTE L-Y = L-Y + WS-FY * BA-NUM(L-INDEX, 3) + WS-UY * BA-NUM(L-INDEX, 2) + WS-LY * BA-NUM(L-INDEX, 1)
         COMPUTE L-Z = L-Z + WS-FZ * BA-NUM(L-INDEX, 3) + WS-UZ * BA-NUM(L-INDEX, 2) + WS-LZ * BA-NUM(L-INDEX, 1)
     ELSE
         MOVE BA-NUM(L-INDEX, 1) TO L-X
         IF BA-KIND(L-INDEX, 1) = 1
             ADD BS-X TO L-X
         END-IF
         MOVE BA-NUM(L-INDEX, 2) TO L-Y
         IF BA-KIND(L-INDEX, 2) = 1
             ADD BS-Y TO L-Y
         END-IF
         MOVE BA-NUM(L-INDEX, 3) TO L-Z
         IF BA-KIND(L-INDEX, 3) = 1
             ADD BS-Z TO L-Z
         END-IF
     END-IF
     GOBACK.
 END PROGRAM BX-POSITION.
