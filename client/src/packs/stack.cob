*> The pack stack (08 §3.1, §3.2, §9.6; data-model §13 "Resource pack"): PK-PACK holds the packs
*> bottom first: the built-in pack, fixed at the bottom; the enabled local packs in the user's order
*> (OP-ENABLED is top first); the active server packs, the most recently pushed on top. A path is read
*> from the top-most pack that has it, unless a pack's filter hides it from the packs below (08
*> §3.3, source.cob); a path no pack has is missing (the missing-texture stripes for a texture).
*> PACK-STACK-BUILD builds the stack, PACKS-RELOAD reloads everything drawn from it (US18-3). A pack
*> that cannot be used, and a file of it that cannot be read, is a pack error (US18-5;
*> PACK-ERROR-ADD): "<pack> cannot be used: <problem>" (08 §10.8.6), shown on the pack screen.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PACK-STACK-INIT.
*> USING CLIENT-STATE: a stack of the built-in pack alone.
 DATA DIVISION.
 LINKAGE SECTION.
 COPY CLSTATE.
 PROCEDURE DIVISION USING CLIENT-STATE.
     MOVE 1 TO PK-COUNT
     MOVE 0 TO PK-KIND(1)
     MOVE 1 TO PK-LEVEL(1)
     GOBACK.
 END PROGRAM PACK-STACK-INIT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PACK-STACK-BUILD.
*> USING CLIENT-STATE (LP-ENTRY scanned, OP-ENABLED and RP-PACK set): closes the packs of the old
*> stack, then stacks the built-in pack (level 1), the generated vanilla pack when the packs are ok
*> (level 3), every enabled usable local pack (bottom first, level 4) and every active server pack
*> (push order, level 5), opening each (PACK-SOURCE-OPEN; one that fails is a pack error
*> and left out), then lists their files from the top down (filters hide files below).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLCONST.
 COPY CONTENT.
 01 WS-I                   BINARY-LONG.
 01 WS-ENTRY               BINARY-LONG.
 01 WS-HEX                 PIC X(16) VALUE "0123456789abcdef".
 01 WS-N                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-NUMBER              PIC X(8).
 01 WS-UUID                PIC X(36).
 01 WS-UUID-LENGTH         BINARY-LONG.
 01 WS-MISSING-KEY         PIC X(80) VALUE "cobolcraft.screen.packs.problem.missing".
 01 WS-MISSING-KEY-LENGTH  BINARY-LONG VALUE 39.
 01 WS-NO-ARG              PIC X(256) VALUE SPACES.
 01 WS-NO-ARG-LENGTH       BINARY-LONG VALUE 0.
 LINKAGE SECTION.
 COPY CLSTATE.
 PROCEDURE DIVISION USING CLIENT-STATE.
     PERFORM VARYING WS-I FROM 2 BY 1 UNTIL WS-I > PK-COUNT
         CALL "PACK-SOURCE-CLOSE" USING CLIENT-STATE WS-I
     END-PERFORM
     MOVE 0 TO PK-ERROR-COUNT
     CALL "PACK-STACK-INIT" USING CLIENT-STATE
*>   Level 3: the generated vanilla resource pack, when the start-up check said ok (level 2, the skin,
*>   is the built-in optional pack of the cobolcraft world type, absent unless enabled).
     IF CL-PACKS-STATUS = CT-PACKS-OK AND CL-GENERATED-DIR-LENGTH > 0
         ADD 1 TO PK-COUNT
         INITIALIZE PK-PACK(PK-COUNT)
         MOVE 1 TO PK-KIND(PK-COUNT)
         MOVE 3 TO PK-LEVEL(PK-COUNT)
         MOVE "generated/vanilla" TO PK-ID(PK-COUNT)
         MOVE 17 TO PK-ID-LENGTH(PK-COUNT)
         STRING CL-GENERATED-DIR(1:CL-GENERATED-DIR-LENGTH) "/vanilla-resources" DELIMITED BY SIZE
             INTO PK-ROOT(PK-COUNT)
         COMPUTE PK-ROOT-LENGTH(PK-COUNT) = CL-GENERATED-DIR-LENGTH + 18
         CALL "PACK-STACK-OPEN" USING CLIENT-STATE
     END-IF
     PERFORM VARYING WS-I FROM OP-COUNT BY -1 UNTIL WS-I < 1
         CALL "LOCAL-PACK-FIND" USING CLIENT-STATE OP-ID(WS-I) OP-ID-LENGTH(WS-I) WS-ENTRY
         IF WS-ENTRY = 0
*>           Enabled but gone (removed or renamed): the stack falls back, the pack screen says so.
             CALL "PACK-ERROR-NAMED" USING CLIENT-STATE OP-ID(WS-I) OP-ID-LENGTH(WS-I) WS-MISSING-KEY
                 WS-MISSING-KEY-LENGTH WS-NO-ARG WS-NO-ARG-LENGTH
         END-IF
         IF WS-ENTRY > 0 AND PK-COUNT < CL-MAX-PACKS
             IF LP-VALID(WS-ENTRY) = 1
                 ADD 1 TO PK-COUNT
                 INITIALIZE PK-PACK(PK-COUNT)
                 MOVE LP-KIND(WS-ENTRY) TO PK-KIND(PK-COUNT)
                 MOVE 4 TO PK-LEVEL(PK-COUNT)
                 MOVE LP-ID(WS-ENTRY) TO PK-ID(PK-COUNT)
                 MOVE LP-ID-LENGTH(WS-ENTRY) TO PK-ID-LENGTH(PK-COUNT)
                 STRING CL-GAME-DIR(1:CL-GAME-DIR-LENGTH) "/resourcepacks/"
                     LP-NAME(WS-ENTRY)(1:LP-NAME-LENGTH(WS-ENTRY)) DELIMITED BY SIZE
                     INTO PK-ROOT(PK-COUNT)
                 COMPUTE PK-ROOT-LENGTH(PK-COUNT) = CL-GAME-DIR-LENGTH + 15
                     + LP-NAME-LENGTH(WS-ENTRY)
                 CALL "PACK-STACK-OPEN" USING CLIENT-STATE
             END-IF
         END-IF
     END-PERFORM
*>   Server packs: id server/<push number as 8 hex digits>/<uuid> (08 §9.6).
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > RP-COUNT
         IF RP-STEP(WS-I) = RPS-ACTIVE AND PK-COUNT < CL-MAX-PACKS
             ADD 1 TO PK-COUNT
             INITIALIZE PK-PACK(PK-COUNT)
             MOVE 2 TO PK-KIND(PK-COUNT)
             MOVE WS-I TO PK-SERVER(PK-COUNT)
             MOVE 5 TO PK-LEVEL(PK-COUNT)
             MOVE RP-NUMBER(WS-I) TO WS-N
             PERFORM VARYING WS-K FROM 8 BY -1 UNTIL WS-K < 1
                 MOVE WS-HEX(FUNCTION MOD(WS-N, 16) + 1:1) TO WS-NUMBER(WS-K:1)
                 COMPUTE WS-N = WS-N / 16
             END-PERFORM
             CALL "UUID-TEXT" USING RP-UUID(WS-I) WS-UUID WS-UUID-LENGTH
             STRING "server/" WS-NUMBER "/" WS-UUID DELIMITED BY SIZE INTO PK-ID(PK-COUNT)
             MOVE 52 TO PK-ID-LENGTH(PK-COUNT)
             MOVE RP-FILE(WS-I) TO PK-ROOT(PK-COUNT)
             MOVE RP-FILE-LENGTH(WS-I) TO PK-ROOT-LENGTH(PK-COUNT)
             CALL "PACK-STACK-OPEN" USING CLIENT-STATE
         END-IF
     END-PERFORM
     PERFORM VARYING WS-I FROM PK-COUNT BY -1 UNTIL WS-I < 2
         CALL "PACK-SOURCE-FILES" USING CLIENT-STATE WS-I
     END-PERFORM
     GOBACK.
 END PROGRAM PACK-STACK-BUILD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PACK-STACK-OPEN.
*> USING CLIENT-STATE: opens the pack just stacked (PK-COUNT); one that cannot be used is a pack
*> error (unreadable, no pack.mcmeta, bad pack.mcmeta) and leaves the stack.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-PROBLEM             BINARY-LONG.
 01 WS-EMPTY               PIC X(256) VALUE SPACES.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-KEYS.
    05 FILLER PIC X(48) VALUE "cobolcraft.screen.packs.problem.unreadable".
    05 FILLER PIC X(48) VALUE "cobolcraft.screen.packs.problem.no_metadata".
    05 FILLER PIC X(48) VALUE "cobolcraft.screen.packs.problem.bad_metadata".
 01 WS-KEY-TABLE REDEFINES WS-KEYS.
    05 WS-PROBLEM-KEY      PIC X(48) OCCURS 3 TIMES.
 01 WS-KEY                 PIC X(80).
 01 WS-KEY-LENGTH          BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 PROCEDURE DIVISION USING CLIENT-STATE.
     CALL "PACK-SOURCE-OPEN" USING CLIENT-STATE PK-COUNT WS-PROBLEM
     IF WS-PROBLEM > 0
         MOVE WS-PROBLEM-KEY(WS-PROBLEM) TO WS-KEY
         MOVE FUNCTION LENGTH(FUNCTION TRIM(WS-KEY)) TO WS-KEY-LENGTH
         CALL "PACK-ERROR-ADD" USING CLIENT-STATE PK-COUNT WS-KEY WS-KEY-LENGTH WS-EMPTY WS-ZERO
         CALL "PACK-SOURCE-CLOSE" USING CLIENT-STATE PK-COUNT
         SUBTRACT 1 FROM PK-COUNT
     END-IF
     GOBACK.
 END PROGRAM PACK-STACK-OPEN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PACKS-RELOAD.
*> USING CLIENT-STATE: a new stack (PACK-STACK-BUILD) and everything drawn from it loaded again:
*> language, font and UI atlas, block, entity and environment atlases, baked models, item icons;
*> every section is meshed again (US18-3).
 DATA DIVISION.
 LINKAGE SECTION.
 COPY CLSTATE.
 PROCEDURE DIVISION USING CLIENT-STATE.
     CALL "PACK-STACK-BUILD" USING CLIENT-STATE
     CALL "LANG-LOAD" USING CLIENT-STATE
     CALL "FONT-LOAD" USING CLIENT-STATE
     CALL "ATLAS-BUILD" USING CLIENT-STATE
     CALL "ENTITY-ATLAS-BUILD" USING CLIENT-STATE
     CALL "ENVIRONMENT-ATLAS-BUILD" USING CLIENT-STATE
     CALL "MODELS-BAKE" USING CLIENT-STATE
     CALL "ITEMDEFS-LOAD" USING CLIENT-STATE
     MOVE -1 TO SK-MESHED-U
     GOBACK.
 END PROGRAM PACKS-RELOAD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PACK-PROBLEM-TEXT.
*> USING CLIENT-STATE, pack name (PIC X(80)), name length, problem key (PIC X(80)), key length,
*> problem argument (PIC X(256)), argument length, text out (PIC X(256)), length out: "<pack> cannot
*> be used: <problem>" through the language (08 §10.8.6 cobolcraft.screen.packs.error).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLARGS.
 01 WS-PROBLEM             PIC X(512).
 01 WS-PROBLEM-LENGTH      BINARY-LONG.
 01 WS-TEXT                PIC X(512).
 01 WS-LENGTH              BINARY-LONG.
 01 WS-KEY                 PIC X(80) VALUE "cobolcraft.screen.packs.error".
 01 WS-KEY-LENGTH          BINARY-LONG VALUE 29.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-NAME                 PIC X(80).
 01 L-NAME-LENGTH          BINARY-LONG.
 01 L-KEY                  PIC X(80).
 01 L-KEY-LENGTH           BINARY-LONG.
 01 L-ARG                  PIC X(256).
 01 L-ARG-LENGTH           BINARY-LONG.
 01 L-TEXT                 PIC X(256).
 01 L-LENGTH               BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-NAME L-NAME-LENGTH L-KEY L-KEY-LENGTH L-ARG
         L-ARG-LENGTH L-TEXT L-LENGTH.
     MOVE 1 TO LA-COUNT
     MOVE L-ARG TO LA-TEXT(1)
     MOVE L-ARG-LENGTH TO LA-LENGTH(1)
     CALL "LANG-FORMAT" USING CLIENT-STATE L-KEY L-KEY-LENGTH LANG-ARGS WS-PROBLEM
         WS-PROBLEM-LENGTH
     MOVE 2 TO LA-COUNT
     MOVE L-NAME TO LA-TEXT(1)
     MOVE L-NAME-LENGTH TO LA-LENGTH(1)
     MOVE WS-PROBLEM(1:256) TO LA-TEXT(2)
     MOVE FUNCTION MIN(WS-PROBLEM-LENGTH, 256) TO LA-LENGTH(2)
     CALL "LANG-FORMAT" USING CLIENT-STATE WS-KEY WS-KEY-LENGTH LANG-ARGS WS-TEXT WS-LENGTH
     MOVE WS-TEXT(1:256) TO L-TEXT
     MOVE FUNCTION MIN(WS-LENGTH, 256) TO L-LENGTH
     GOBACK.
 END PROGRAM PACK-PROBLEM-TEXT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PACK-ERROR-ADD.
*> USING CLIENT-STATE, pack, problem key (PIC X(80)), key length, problem argument (PIC X(256)),
*> argument length: records the pack error (at most CL-MAX-PACK-ERRORS, each text once). The pack's
*> name is its id without the "file/" of a local pack.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-NAME                PIC X(80).
 01 WS-NAME-LENGTH         BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-PACK                 BINARY-LONG.
 01 L-KEY                  PIC X(80).
 01 L-KEY-LENGTH           BINARY-LONG.
 01 L-ARG                  PIC X(256).
 01 L-ARG-LENGTH           BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-PACK L-KEY L-KEY-LENGTH L-ARG L-ARG-LENGTH.
     MOVE SPACES TO WS-NAME
     MOVE PK-ID(L-PACK) TO WS-NAME
     MOVE PK-ID-LENGTH(L-PACK) TO WS-NAME-LENGTH
     CALL "PACK-ERROR-NAMED" USING CLIENT-STATE WS-NAME WS-NAME-LENGTH L-KEY L-KEY-LENGTH L-ARG
         L-ARG-LENGTH
     GOBACK.
 END PROGRAM PACK-ERROR-ADD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PACK-ERROR-NAMED.
*> USING CLIENT-STATE, pack id (PIC X(80)), its length, problem key, key length, problem argument,
*> argument length: PACK-ERROR-ADD for a pack that is not in the stack (one enabled whose file is gone).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLCONST.
 01 WS-NAME                PIC X(80).
 01 WS-NAME-LENGTH         BINARY-LONG.
 01 WS-TEXT                PIC X(256).
 01 WS-LENGTH              BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-SEEN                BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-ID                   PIC X(80).
 01 L-ID-LENGTH            BINARY-LONG.
 01 L-KEY                  PIC X(80).
 01 L-KEY-LENGTH           BINARY-LONG.
 01 L-ARG                  PIC X(256).
 01 L-ARG-LENGTH           BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-ID L-ID-LENGTH L-KEY L-KEY-LENGTH L-ARG L-ARG-LENGTH.
     MOVE L-ID TO WS-NAME
     MOVE L-ID-LENGTH TO WS-NAME-LENGTH
     IF WS-NAME(1:5) = "file/"
         MOVE L-ID(6:75) TO WS-NAME
         SUBTRACT 5 FROM WS-NAME-LENGTH
     END-IF
     CALL "PACK-PROBLEM-TEXT" USING CLIENT-STATE WS-NAME WS-NAME-LENGTH L-KEY L-KEY-LENGTH L-ARG
         L-ARG-LENGTH WS-TEXT WS-LENGTH
     MOVE 0 TO WS-SEEN
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > PK-ERROR-COUNT
         IF PK-ERROR-TEXT(WS-I) = WS-TEXT
             MOVE 1 TO WS-SEEN
         END-IF
     END-PERFORM
     IF WS-SEEN = 0 AND PK-ERROR-COUNT < CL-MAX-PACK-ERRORS
         ADD 1 TO PK-ERROR-COUNT
         MOVE WS-TEXT TO PK-ERROR-TEXT(PK-ERROR-COUNT)
         MOVE WS-LENGTH TO PK-ERROR-LENGTH(PK-ERROR-COUNT)
     END-IF
     GOBACK.
 END PROGRAM PACK-ERROR-NAMED.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. UUID-TEXT.
*> USING UUID (PIC X(16), raw bytes), text out (PIC X(36)), length out: the lowercase hyphenated
*> form 8-4-4-4-12.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-HEX                 PIC X(16) VALUE "0123456789abcdef".
 01 WS-I                   BINARY-LONG.
 01 WS-B                   BINARY-LONG.
 01 WS-PTR                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-UUID                 PIC X(16).
 01 L-TEXT                 PIC X(36).
 01 L-LENGTH               BINARY-LONG.
 PROCEDURE DIVISION USING L-UUID L-TEXT L-LENGTH.
     MOVE 1 TO WS-PTR
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 16
         IF WS-I = 5 OR WS-I = 7 OR WS-I = 9 OR WS-I = 11
             MOVE "-" TO L-TEXT(WS-PTR:1)
             ADD 1 TO WS-PTR
         END-IF
         COMPUTE WS-B = FUNCTION ORD(L-UUID(WS-I:1)) - 1
         MOVE WS-HEX(WS-B / 16 + 1:1) TO L-TEXT(WS-PTR:1)
         MOVE WS-HEX(FUNCTION MOD(WS-B, 16) + 1:1) TO L-TEXT(WS-PTR + 1:1)
         ADD 2 TO WS-PTR
     END-PERFORM
     MOVE 36 TO L-LENGTH
     GOBACK.
 END PROGRAM UUID-TEXT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PACK-RESOLVE.
*> USING CLIENT-STATE, path (PIC X(256)), path length, pack out: the top-most pack holding the
*> path, 0 = missing (also when a pack's filter hides it from the packs below, source.cob).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-PACK                BINARY-LONG.
 01 WS-FOUND               BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-PATH                 PIC X(256).
 01 L-LENGTH               BINARY-LONG.
 01 L-PACK                 BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-PATH L-LENGTH L-PACK.
     MOVE 0 TO L-PACK
     PERFORM VARYING WS-PACK FROM PK-COUNT BY -1 UNTIL WS-PACK < 1 OR L-PACK > 0
         CALL "PACK-SOURCE-HAS" USING CLIENT-STATE WS-PACK L-PATH L-LENGTH WS-FOUND
         IF WS-FOUND = 1
             MOVE WS-PACK TO L-PACK
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM PACK-RESOLVE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PACK-READ.
*> USING CLIENT-STATE, path (PIC X(256)), path length, area, capacity, length out, found out.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-PACK                BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-PATH                 PIC X(256).
 01 L-LENGTH               BINARY-LONG.
 01 L-AREA                 PIC X.
 01 L-CAPACITY             BINARY-LONG.
 01 L-OUT-LENGTH           BINARY-LONG.
 01 L-FOUND                BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-PATH L-LENGTH L-AREA L-CAPACITY L-OUT-LENGTH L-FOUND.
     MOVE 0 TO L-OUT-LENGTH L-FOUND
     CALL "PACK-RESOLVE" USING CLIENT-STATE L-PATH L-LENGTH WS-PACK
     IF WS-PACK > 0
         CALL "PACK-SOURCE-READ" USING CLIENT-STATE WS-PACK L-PATH L-LENGTH L-AREA L-CAPACITY
             L-OUT-LENGTH L-FOUND
     END-IF
     GOBACK.
 END PROGRAM PACK-READ.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PACK-IMAGE.
*> USING CLIENT-STATE, path (PIC X(256)), path length, area, capacity, width out, height out,
*> found out.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-PACK                BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-PATH                 PIC X(256).
 01 L-LENGTH               BINARY-LONG.
 01 L-AREA                 PIC X.
 01 L-CAPACITY             BINARY-LONG.
 01 L-W                    BINARY-LONG.
 01 L-H                    BINARY-LONG.
 01 L-FOUND                BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-PATH L-LENGTH L-AREA L-CAPACITY L-W L-H L-FOUND.
     MOVE 0 TO L-W L-H L-FOUND
     CALL "PACK-RESOLVE" USING CLIENT-STATE L-PATH L-LENGTH WS-PACK
     IF WS-PACK > 0
         CALL "PACK-SOURCE-IMAGE" USING CLIENT-STATE WS-PACK L-PATH L-LENGTH L-AREA L-CAPACITY
             L-W L-H L-FOUND
     END-IF
     GOBACK.
 END PROGRAM PACK-IMAGE.
