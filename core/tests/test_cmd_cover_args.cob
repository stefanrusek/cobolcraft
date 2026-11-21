*> Coverage-only test of the argument-type sources (core/src/cmd-types.cob, cmd-selector.cob, cmd-blocks.cob, cmd-snbt.cob,
*> cmd-coords.cob, cmd-reader.cob): each case drives a branch that the acceptance tests of 15 §6 to §9 do not reach (full lists of
*> eight entries, over-long texts, escapes, malformed numbers, empty tails). The result is "ok" or "err" (with the key when the
*> case names it); the line terminator is $, the marker ` is 70 letters x and ^ is 70 digits 1, a leading m> opens the standard
*> content set for that case and D> calls the argument parser with no input at all.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-CMD-COVER-ARGS.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY BRIGADIER.
 COPY CONTENT.
 COPY BRTRAIL REPLACING LEADING ==BT-== BY ==RS-==.
 01 WS-TYPES.
    05 FILLER PIC X(8) VALUE "en".
    05 FILLER PIC S9(9) BINARY VALUE 6.
    05 FILLER PIC X(8) VALUE "sh".
    05 FILLER PIC S9(9) BINARY VALUE 31.
    05 FILLER PIC X(8) VALUE "bs".
    05 FILLER PIC S9(9) BINARY VALUE 12.
    05 FILLER PIC X(8) VALUE "bl".
    05 FILLER PIC S9(9) BINARY VALUE 13.
    05 FILLER PIC X(8) VALUE "is".
    05 FILLER PIC S9(9) BINARY VALUE 14.
    05 FILLER PIC X(8) VALUE "ip".
    05 FILLER PIC S9(9) BINARY VALUE 15.
    05 FILLER PIC X(8) VALUE "nt".
    05 FILLER PIC S9(9) BINARY VALUE 22.
    05 FILLER PIC X(8) VALUE "nc".
    05 FILLER PIC S9(9) BINARY VALUE 21.
    05 FILLER PIC X(8) VALUE "hx".
    05 FILLER PIC S9(9) BINARY VALUE 17.
    05 FILLER PIC X(8) VALUE "ri".
    05 FILLER PIC S9(9) BINARY VALUE 39.
    05 FILLER PIC X(8) VALUE "rf".
    05 FILLER PIC S9(9) BINARY VALUE 40.
    05 FILLER PIC X(8) VALUE "tm".
    05 FILLER PIC S9(9) BINARY VALUE 43.
    05 FILLER PIC X(8) VALUE "pa".
    05 FILLER PIC S9(9) BINARY VALUE 27.
    05 FILLER PIC X(8) VALUE "an".
    05 FILLER PIC S9(9) BINARY VALUE 28.
    05 FILLER PIC X(8) VALUE "gm".
    05 FILLER PIC S9(9) BINARY VALUE 42.
    05 FILLER PIC X(8) VALUE "rl".
    05 FILLER PIC S9(9) BINARY VALUE 36.
 01 WS-TYPE-TABLE REDEFINES WS-TYPES.
    05 WS-TYPE OCCURS 16 TIMES.
       10 WS-T-LIT PIC X(8).
       10 WS-T-ID PIC S9(9) BINARY.
 01 WS-CASES.
    05 FILLER PIC X(300) VALUE "en @e[name=!a,name=!b,name=!c,name=!d,name=!e,name" & "=!f,name=!g,name=!h,name=!i]$".
    05 FILLER PIC X(20) VALUE "err".
    05 FILLER PIC X(300) VALUE "en @e[name=`]$".
    05 FILLER PIC X(20) VALUE "ok".
    05 FILLER PIC X(300) VALUE "en @e[team=!a,team=!b,team=!c,team=!d,team=!e,team" & "=!f,team=!g,team=!h,team=!i]$".
    05 FILLER PIC X(20) VALUE "err".
    05 FILLER PIC X(300) VALUE "en @e[team=`]$".
    05 FILLER PIC X(20) VALUE "ok".
    05 FILLER PIC X(300) VALUE "en @e[tag=a,tag=b,tag=c,tag=d,tag=e,tag=f,tag=g,ta" & "g=h,tag=i]$".
    05 FILLER PIC X(20) VALUE "err".
    05 FILLER PIC X(300) VALUE "en @e[tag=`]$".
    05 FILLER PIC X(20) VALUE "ok".
    05 FILLER PIC X(300) VALUE "en @e[type=!minecraft:zombie,type=!minecraft:zombi" & "e,type=!minecraft:zombie,type=!minecraft:zombie,ty" & "pe=!minecraft:zombie,type=!minecraft:zombie,type=!" & "minecraft:zombie,type=!minecraft:zombie,type=!mine" & "craft:zombie]$".
    05 FILLER PIC X(20) VALUE "err".
    05 FILLER PIC X(300) VALUE "en @e[nbt={},nbt={},nbt={},nbt={},nbt={},nbt={},nb" & "t={},nbt={},nbt={}]$".
    05 FILLER PIC X(20) VALUE "err".
    05 FILLER PIC X(300) VALUE "en @e[predicate=a,predicate=a,predicate=a,predicat" & "e=a,predicate=a,predicate=a,predicate=a,predicate=" & "a,predicate=a]$".
    05 FILLER PIC X(20) VALUE "err".
    05 FILLER PIC X(300) VALUE "en @e[scores={a=1,b=1,c=1,d=1,e=1,f=1,g=1,h=1,i=1}" & "]$".
    05 FILLER PIC X(20) VALUE "err".
    05 FILLER PIC X(300) VALUE "en @e[scores={a 1}]$".
    05 FILLER PIC X(20) VALUE "err".
    05 FILLER PIC X(300) VALUE "en @e[scores={}]$".
    05 FILLER PIC X(20) VALUE "ok".
    05 FILLER PIC X(300) VALUE "en @e[scores={`=1}]$".
    05 FILLER PIC X(20) VALUE "ok".
    05 FILLER PIC X(300) VALUE "en @e[advancements=x]$".
    05 FILLER PIC X(20) VALUE "err".
    05 FILLER PIC X(300) VALUE "en @e[advancements={}]$".
    05 FILLER PIC X(20) VALUE "ok".
    05 FILLER PIC X(300) VALUE "en @e[advancements={a={}}]$".
    05 FILLER PIC X(20) VALUE "ok".
    05 FILLER PIC X(300) VALUE "en @e[level=1,level=2]$".
    05 FILLER PIC X(20) VALUE "err".
    05 FILLER PIC X(300) VALUE "en @e[x_rotation=1,x_rotation=2]$".
    05 FILLER PIC X(20) VALUE "err".
    05 FILLER PIC X(300) VALUE "en @e[y_rotation=1,y_rotation=2]$".
    05 FILLER PIC X(20) VALUE "err".
    05 FILLER PIC X(300) VALUE "en @e[x_rotation=1.2.3]$".
    05 FILLER PIC X(20) VALUE "err".
    05 FILLER PIC X(300) VALUE "en `$".
    05 FILLER PIC X(20) VALUE "err".
    05 FILLER PIC X(300) VALUE "en 1--2-3-4-5$".
    05 FILLER PIC X(20) VALUE "ok".
    05 FILLER PIC X(300) VALUE "en 11111111111111111-1-1-1-1$".
    05 FILLER PIC X(20) VALUE "err".
    05 FILLER PIC X(300) VALUE "sh `$".
    05 FILLER PIC X(20) VALUE "ok".
    05 FILLER PIC X(300) VALUE "sh 1--2-3-4-5$".
    05 FILLER PIC X(20) VALUE "ok".
    05 FILLER PIC X(300) VALUE "sh 11111111111111111-1-1-1-1$".
    05 FILLER PIC X(20) VALUE "ok".
    05 FILLER PIC X(300) VALUE "bs glowtube[]$".
    05 FILLER PIC X(20) VALUE "ok".
    05 FILLER PIC X(300) VALUE "bs `$".
    05 FILLER PIC X(20) VALUE "err".
    05 FILLER PIC X(300) VALUE "bs glowtube[`=1]$".
    05 FILLER PIC X(20) VALUE "err".
    05 FILLER PIC X(300) VALUE "bl #a[`]$".
    05 FILLER PIC X(20) VALUE "err".
    05 FILLER PIC X(300) VALUE "bl #`[a]$".
    05 FILLER PIC X(20) VALUE "err".
    05 FILLER PIC X(300) VALUE "m>bs glowtube$".
    05 FILLER PIC X(20) VALUE "err".
    05 FILLER PIC X(300) VALUE "m>is minecraft:loam$".
    05 FILLER PIC X(20) VALUE "err".
    05 FILLER PIC X(300) VALUE "m>is loam$".
    05 FILLER PIC X(20) VALUE "err".
    05 FILLER PIC X(300) VALUE "is pry_bar[foo]$".
    05 FILLER PIC X(20) VALUE "err".
    05 FILLER PIC X(300) VALUE "ip loam[]$".
    05 FILLER PIC X(20) VALUE "ok".
    05 FILLER PIC X(300) VALUE "ip loam[a=1 x]$".
    05 FILLER PIC X(20) VALUE "err".
    05 FILLER PIC X(300) VALUE "nt [L;1b]$".
    05 FILLER PIC X(20) VALUE "err".
    05 FILLER PIC X(300) VALUE "nt [I;1b]$".
    05 FILLER PIC X(20) VALUE "err".
    05 FILLER PIC X(300) VALUE "nt -$".
    05 FILLER PIC X(20) VALUE "err".
    05 FILLER PIC X(300) VALUE "nt 0b12$".
    05 FILLER PIC X(20) VALUE "err".
    05 FILLER PIC X(300) VALUE "nt 0x$".
    05 FILLER PIC X(20) VALUE "err".
    05 FILLER PIC X(300) VALUE "nt 1e$".
    05 FILLER PIC X(20) VALUE "err".
    05 FILLER PIC X(300) VALUE "nt 1e+$".
    05 FILLER PIC X(20) VALUE "err".
    05 FILLER PIC X(300) VALUE "nt 1.5b$".
    05 FILLER PIC X(20) VALUE "err".
    05 FILLER PIC X(300) VALUE "nt 1sx$".
    05 FILLER PIC X(20) VALUE "err".
    05 FILLER PIC X(300) VALUE "nt 12abc$".
    05 FILLER PIC X(20) VALUE "err".
    05 FILLER PIC X(300) VALUE "nt bool(true$".
    05 FILLER PIC X(20) VALUE "err".
    05 FILLER PIC X(300) VALUE "nt ""abc\$".
    05 FILLER PIC X(20) VALUE "err".
    05 FILLER PIC X(300) VALUE "nt ""a\\b""$".
    05 FILLER PIC X(20) VALUE "ok".
    05 FILLER PIC X(300) VALUE "nt ""a\bb""$".
    05 FILLER PIC X(20) VALUE "ok".
    05 FILLER PIC X(300) VALUE "nt ""a\fb""$".
    05 FILLER PIC X(20) VALUE "ok".
    05 FILLER PIC X(300) VALUE "nt ""a\rb""$".
    05 FILLER PIC X(20) VALUE "ok".
    05 FILLER PIC X(300) VALUE "nt ""a\tb""$".
    05 FILLER PIC X(20) VALUE "ok".
    05 FILLER PIC X(300) VALUE "nt ""a\u0041b""$".
    05 FILLER PIC X(20) VALUE "ok".
    05 FILLER PIC X(300) VALUE "nt ""a\U00000041b""$".
    05 FILLER PIC X(20) VALUE "ok".
    05 FILLER PIC X(300) VALUE "nt ""a\xaFb""$".
    05 FILLER PIC X(20) VALUE "ok".
    05 FILLER PIC X(300) VALUE "nt ""a\xAfb""$".
    05 FILLER PIC X(20) VALUE "ok".
    05 FILLER PIC X(300) VALUE "nt ""a\xffb""$".
    05 FILLER PIC X(20) VALUE "ok".
    05 FILLER PIC X(300) VALUE "nt ""a\x4$".
    05 FILLER PIC X(20) VALUE "err".
    05 FILLER PIC X(300) VALUE "nt ""a\xzz""$".
    05 FILLER PIC X(20) VALUE "err".
    05 FILLER PIC X(300) VALUE "nt ""a\q""$".
    05 FILLER PIC X(20) VALUE "err".
    05 FILLER PIC X(300) VALUE "nt ""a\'b""$".
    05 FILLER PIC X(20) VALUE "ok".
    05 FILLER PIC X(300) VALUE "hx #^$".
    05 FILLER PIC X(20) VALUE "err".
    05 FILLER PIC X(300) VALUE "ri ^$".
    05 FILLER PIC X(20) VALUE "err".
    05 FILLER PIC X(300) VALUE "ri 3000000000$".
    05 FILLER PIC X(20) VALUE "err".
    05 FILLER PIC X(300) VALUE "ri 1-2$".
    05 FILLER PIC X(20) VALUE "err".
    05 FILLER PIC X(300) VALUE "tm 90000d$".
    05 FILLER PIC X(20) VALUE "ok".
    05 FILLER PIC X(300) VALUE "tm -100000s$".
    05 FILLER PIC X(20) VALUE "err".
    05 FILLER PIC X(300) VALUE "pa foo$".
    05 FILLER PIC X(20) VALUE "ok".
    05 FILLER PIC X(300) VALUE "an 10000000000000000000000000000000000000000x$".
    05 FILLER PIC X(20) VALUE "err".
    05 FILLER PIC X(300) VALUE "gm `$".
    05 FILLER PIC X(20) VALUE "err".
    05 FILLER PIC X(300) VALUE "en @e[type=`]$".
    05 FILLER PIC X(20) VALUE "err".
    05 FILLER PIC X(300) VALUE "en @e[scores={a=1 x}]$".
    05 FILLER PIC X(20) VALUE "err".
    05 FILLER PIC X(300) VALUE "rl a/b:c$".
    05 FILLER PIC X(20) VALUE "err".
    05 FILLER PIC X(300) VALUE "D>an".
    05 FILLER PIC X(20) VALUE "err".
    05 FILLER PIC X(300) VALUE "D>ri".
    05 FILLER PIC X(20) VALUE "err".
 01 WS-TABLE REDEFINES WS-CASES.
    05 WS-CASE OCCURS 77 TIMES.
       10 WS-CASE-LINE PIC X(300).
       10 WS-CASE-EXPECTED PIC X(20).

 01 WS-LINE                PIC X(1024).
 01 WS-LENGTH              BINARY-LONG.
 01 WS-LEVEL               BINARY-LONG VALUE 4.
 01 WS-VERDICT             BINARY-LONG.
 01 WS-COMMAND             BINARY-LONG.
 01 WS-TEXT                PIC X(64).
 01 WS-I                   BINARY-LONG.
 01 WS-J                   PIC 999.
 01 WS-AT                  BINARY-LONG.
 01 WS-NODE                BINARY-LONG.
 01 WS-CHILD               BINARY-LONG.
 01 WS-CREATED             BINARY-LONG.
 01 WS-NAME                PIC X(32).
 01 WS-NAME-LENGTH         BINARY-LONG.
 01 WS-KIND                BINARY-LONG.
 01 WS-TYPE-ID             BINARY-LONG.
 01 WS-EXPECTED            PIC X(20).
 01 WS-REST                PIC X(1024).
 01 WS-SAVED-TYPE          PIC 9.
 01 WS-INT                 BINARY-DOUBLE.
 01 WS-DOUBLE              FLOAT-LONG.
 01 WS-INF                 BINARY-LONG.
 COPY COREAPI.
 COPY CBLOCKS.
 COPY CITEMS.
 01 WS-BOOK                PIC X(40).
 PROCEDURE DIVISION.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     MOVE 2 TO ET-COUNT
     MOVE "minecraft:zombie" TO ET-KEY(1)
     MOVE 16 TO ET-KEY-LENGTH(1)
     MOVE "minecraft:pig" TO ET-KEY(2)
     MOVE 13 TO ET-KEY-LENGTH(2)
     CALL "BR-TREE-RESET"
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 16
         PERFORM ADD-TYPE
     END-PERFORM
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 77
         MOVE WS-CASE-LINE(WS-I) TO WS-LINE
         MOVE WS-CASE-EXPECTED(WS-I) TO WS-EXPECTED
         PERFORM CHECK
     END-PERFORM
     GOBACK.

*> A literal under the root named WS-T-LIT(WS-I) with the argument "v" of its type (command WS-I).
 ADD-TYPE.
     MOVE 1 TO WS-NODE
     MOVE BR-LITERAL TO WS-KIND
     MOVE 0 TO WS-TYPE-ID
     MOVE WS-T-LIT(WS-I) TO WS-NAME
     MOVE FUNCTION LENGTH(FUNCTION TRIM(WS-NAME)) TO WS-NAME-LENGTH
     CALL "BR-ADD-NODE" USING WS-NODE WS-KIND WS-NAME WS-NAME-LENGTH WS-TYPE-ID WS-CHILD WS-CREATED
     MOVE WS-CHILD TO WS-NODE
     MOVE BR-ARGUMENT TO WS-KIND
     MOVE "v" TO WS-NAME
     MOVE 1 TO WS-NAME-LENGTH
     MOVE WS-T-ID(WS-I) TO WS-TYPE-ID
     CALL "BR-ADD-NODE" USING WS-NODE WS-KIND WS-NAME WS-NAME-LENGTH WS-TYPE-ID WS-CHILD WS-CREATED
     MOVE WS-I TO BR-N-COMMAND(WS-CHILD).

*> The markers of the line: ` becomes 70 x, ^ becomes 70 digits 1 (at most once each per line).
 EXPAND.
     MOVE 0 TO WS-AT
     INSPECT WS-LINE TALLYING WS-AT FOR CHARACTERS BEFORE INITIAL "`"
     IF WS-AT < 300
         MOVE WS-LINE(WS-AT + 2:) TO WS-REST
         MOVE ALL "x" TO WS-LINE(WS-AT + 1:70)
         MOVE WS-REST TO WS-LINE(WS-AT + 71:)
     END-IF
     MOVE 0 TO WS-AT
     INSPECT WS-LINE TALLYING WS-AT FOR CHARACTERS BEFORE INITIAL "^"
     IF WS-AT < 300
         MOVE WS-LINE(WS-AT + 2:) TO WS-REST
         MOVE ALL "1" TO WS-LINE(WS-AT + 1:70)
         MOVE WS-REST TO WS-LINE(WS-AT + 71:)
     END-IF.

 CHECK.
     MOVE 4 TO WS-LEVEL
     MOVE CT-SET-TYPE TO WS-SAVED-TYPE
     PERFORM EXPAND
     IF WS-LINE(1:2) = "m>"
         MOVE CT-TYPE-STANDARD TO CT-SET-TYPE
         MOVE WS-LINE(3:) TO WS-REST
         MOVE WS-REST TO WS-LINE
     END-IF
     MOVE SPACES TO WS-TEXT
     IF WS-LINE(1:2) = "D>"
         PERFORM DIRECT
     ELSE
         MOVE 0 TO WS-LENGTH
         INSPECT WS-LINE TALLYING WS-LENGTH FOR CHARACTERS BEFORE INITIAL "$"
         MOVE SPACE TO WS-LINE(WS-LENGTH + 1:1)
         CALL "BR-PARSE" USING WS-LEVEL WS-LINE WS-LENGTH RS-TRAIL
         CALL "BR-VERDICT" USING RS-TRAIL WS-VERDICT WS-COMMAND
         IF WS-VERDICT = 0
             MOVE "ok" TO WS-TEXT
         ELSE
             STRING "err " FUNCTION TRIM(BR-E-KEY) DELIMITED BY SIZE INTO WS-TEXT
         END-IF
     END-IF
     MOVE WS-SAVED-TYPE TO CT-SET-TYPE
     IF WS-EXPECTED = "err"
         IF WS-TEXT(1:3) = "err"
             MOVE "err" TO WS-TEXT
         END-IF
     END-IF
     MOVE SPACES TO TL-CASE
     MOVE WS-I TO WS-J
     STRING "coverage 15 argument types case " WS-J " " WS-LINE(1:40) DELIMITED BY SIZE INTO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE WS-EXPECTED TO TL-EXPECTED
     MOVE WS-TEXT TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

*> The argument parser called at the end of the input: the node of the literal named by the line after D>.
 DIRECT.
     MOVE SPACES TO WS-NAME
     MOVE WS-LINE(3:2) TO WS-NAME
     MOVE BR-N-FIRST(1) TO WS-NODE
     PERFORM UNTIL BR-N-NAME(WS-NODE)(1:2) = WS-NAME(1:2)
         MOVE BR-N-NEXT(WS-NODE) TO WS-NODE
     END-PERFORM
     MOVE BR-N-FIRST(WS-NODE) TO WS-NODE
     MOVE 0 TO BR-IN-LENGTH BR-IN-CURSOR
     MOVE 4 TO BR-IN-LEVEL
     MOVE SPACES TO BR-IN-TEXT BR-E-KEY
     CALL "BR-ARG-EXT" USING WS-NODE WS-INT WS-DOUBLE WS-INF
     IF BR-E-KEY = SPACES
         MOVE "ok" TO WS-TEXT
     ELSE
         MOVE "err" TO WS-TEXT
     END-IF.

 END PROGRAM TEST-CMD-COVER-ARGS.

 COPY CORETEST.

