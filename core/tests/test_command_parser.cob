*> Implementation test of the command line parser (core/src/commands.cob CMD-PARSE; standin-content
*> §16.1 typing and order of checks, §16.3 argument parsers, §16.4 usage string rule). The console
*> (sender 0, operator permission) parses each line. A parsed line is shown as "ok <command> <value
*> of each word after the name>" (literal words as they are, integers in decimal, doubles with two
*> decimals, words and greedy phrases as written); a refused line as the §16 reply key(arguments).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-COMMAND-PARSER.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY COREAPI.
 COPY PROTO.
 COPY CMDPARSE.
 COPY COMMANDS.
 01 WS-SENDER              BINARY-LONG VALUE 0.
 01 WS-LINE                PIC X(768).
 01 WS-LENGTH              BINARY-LONG.
 01 WS-TEXT                PIC X(1024).
 01 WS-PTR                 BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-NODE                BINARY-LONG.
 01 WS-INT-EDIT            PIC -(9)9.
 01 WS-DOUBLE-EDIT         PIC -(9)9.99.
 PROCEDURE DIVISION.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS

*>   Tokenising (§16.1: words split at single spaces).
     MOVE "test command parser a line is split at single spaces: howto is one word" TO TL-CASE
     MOVE "howto" TO WS-LINE
     PERFORM PARSE-LINE
     MOVE CQ-WORD-COUNT TO WS-INT-EDIT
     MOVE SPACES TO WS-TEXT
     STRING FUNCTION TRIM(WS-INT-EDIT) " words, " DELIMITED BY SIZE INTO WS-TEXT
     PERFORM RENDER-RESULT
     MOVE "1 words, ok howto" TO TL-EXPECTED
     PERFORM CHECK-TEXT
     MOVE "test command parser two spaces make an empty word: clock  5 is three words and the "
         & "empty word is an invalid argument" TO TL-CASE
     MOVE "clock  5" TO WS-LINE
     PERFORM PARSE-LINE
     MOVE CQ-WORD-COUNT TO WS-INT-EDIT
     MOVE SPACES TO WS-TEXT
     STRING FUNCTION TRIM(WS-INT-EDIT) " words, " DELIMITED BY SIZE INTO WS-TEXT
     MOVE 10 TO WS-PTR
     PERFORM RENDER-REPLY
     MOVE "3 words, cobolcraft.command.invalid_argument(,clock <ticks>)" TO TL-EXPECTED
     PERFORM CHECK-TEXT

*>   Integer with bounds (clock <ticks>: 0 to 29999).
     MOVE "test command parser integer: clock 29999 parses" TO TL-CASE
     MOVE "clock 29999" TO WS-LINE
     MOVE "ok clock 29999" TO TL-EXPECTED
     PERFORM PARSE-CHECK
     MOVE "test command parser integer: clock 0 parses (lower bound)" TO TL-CASE
     MOVE "clock 0" TO WS-LINE
     MOVE "ok clock 0" TO TL-EXPECTED
     PERFORM PARSE-CHECK
     MOVE "test command parser integer above its maximum is an invalid argument" TO TL-CASE
     MOVE "clock 30000" TO WS-LINE
     MOVE "cobolcraft.command.invalid_argument(30000,clock <ticks>)" TO TL-EXPECTED
     PERFORM PARSE-CHECK
     MOVE "test command parser integer below its minimum is an invalid argument" TO TL-CASE
     MOVE "clock -1" TO WS-LINE
     MOVE "cobolcraft.command.invalid_argument(-1,clock <ticks>)" TO TL-EXPECTED
     PERFORM PARSE-CHECK
     MOVE "test command parser a word that is not an integer is an invalid argument" TO TL-CASE
     MOVE "clock 12a" TO WS-LINE
     MOVE "cobolcraft.command.invalid_argument(12a,clock <ticks>)" TO TL-EXPECTED
     PERFORM PARSE-CHECK
     MOVE "test command parser a sign alone is not an integer" TO TL-CASE
     MOVE "clock -" TO WS-LINE
     MOVE "cobolcraft.command.invalid_argument(-,clock <ticks>)" TO TL-EXPECTED
     PERFORM PARSE-CHECK
     MOVE "test command parser leading zeros are allowed in an integer" TO TL-CASE
     MOVE "clock 00000000001" TO WS-LINE
     MOVE "ok clock 1" TO TL-EXPECTED
     PERFORM PARSE-CHECK
     MOVE "test command parser an integer beyond 32 bits is an invalid argument" TO TL-CASE
     MOVE "clock 99999999999" TO WS-LINE
     MOVE "cobolcraft.command.invalid_argument(99999999999,clock <ticks>)" TO TL-EXPECTED
     PERFORM PARSE-CHECK
     MOVE "test command parser a missing integer is a missing argument" TO TL-CASE
     MOVE "clock" TO WS-LINE
     MOVE "cobolcraft.command.missing_argument(clock <ticks>)" TO TL-EXPECTED
     PERFORM PARSE-CHECK
     MOVE "test command parser extra words after the last argument are an invalid argument"
         TO TL-CASE
     MOVE "clock 5 6" TO WS-LINE
     MOVE "cobolcraft.command.invalid_argument(6,clock <ticks>)" TO TL-EXPECTED
     PERFORM PARSE-CHECK
     MOVE "test command parser extra words after a command without arguments" TO TL-CASE
     MOVE "howto please" TO WS-LINE
     MOVE "cobolcraft.command.invalid_argument(please,howto)" TO TL-EXPECTED
     PERFORM PARSE-CHECK

*>   Double (x, z: -30000000 to 30000000; y: 0 to 256 in the tree and min_y to min_y + height - 2
*>   of the dimension).
     MOVE "test command parser doubles: homestead -12.25 54 8.5 parses" TO TL-CASE
     MOVE "homestead -12.25 54 8.5" TO WS-LINE
     MOVE "ok homestead -12.25 54.00 8.50" TO TL-EXPECTED
     PERFORM PARSE-CHECK
     MOVE "test command parser doubles: a leading point and a trailing point parse" TO TL-CASE
     MOVE "homestead .5 3. -.25" TO WS-LINE
     MOVE "ok homestead 0.50 3.00 -0.25" TO TL-EXPECTED
     PERFORM PARSE-CHECK
     MOVE "test command parser a double with two points is an invalid argument" TO TL-CASE
     MOVE "homestead 1.2.3 5 5" TO WS-LINE
     MOVE "cobolcraft.command.invalid_argument(1.2.3,homestead <x> <y> <z>)" TO TL-EXPECTED
     PERFORM PARSE-CHECK
     MOVE "test command parser a point alone is not a double" TO TL-CASE
     MOVE "homestead . 5 5" TO WS-LINE
     MOVE "cobolcraft.command.invalid_argument(.,homestead <x> <y> <z>)" TO TL-EXPECTED
     PERFORM PARSE-CHECK
     MOVE "test command parser a double beyond 30000000 is an invalid argument" TO TL-CASE
     MOVE "homestead 30000000.5 5 5" TO WS-LINE
     MOVE "cobolcraft.command.invalid_argument(30000000.5,homestead <x> <y> <z>)" TO TL-EXPECTED
     PERFORM PARSE-CHECK
     MOVE "test command parser a double with many digits parses" TO TL-CASE
     MOVE "homestead 1.0000000000000001 000000000000000000000000000000005 5" TO WS-LINE
     MOVE "ok homestead 1.00 5.00 5.00" TO TL-EXPECTED
     PERFORM PARSE-CHECK
     MOVE "test command parser y above the main dimension's top (254) is an invalid argument"
         TO TL-CASE
     MOVE "homestead 5 254.5 5" TO WS-LINE
     MOVE "cobolcraft.command.invalid_argument(254.5,homestead <x> <y> <z>)" TO TL-EXPECTED
     PERFORM PARSE-CHECK
     MOVE "test command parser y = 254 in the main dimension parses" TO TL-CASE
     MOVE "homestead 5 254 5" TO WS-LINE
     MOVE "ok homestead 5.00 254.00 5.00" TO TL-EXPECTED
     PERFORM PARSE-CHECK
     MOVE "test command parser y below 0 is an invalid argument" TO TL-CASE
     MOVE "homestead 5 -0.5 5" TO WS-LINE
     MOVE "cobolcraft.command.invalid_argument(-0.5,homestead <x> <y> <z>)" TO TL-EXPECTED
     PERFORM PARSE-CHECK

*>   Single word (dimension, item, mob, what) and literal words.
     MOVE "test command parser single words and literals: skies main drizzle 30 parses" TO TL-CASE
     MOVE "skies main drizzle 30" TO WS-LINE
     MOVE "ok skies main drizzle 30" TO TL-EXPECTED
     PERFORM PARSE-CHECK
     MOVE "test command parser a word that is none of the listed words is an invalid argument"
         TO TL-CASE
     MOVE "skies main fog" TO WS-LINE
     MOVE "cobolcraft.command.invalid_argument(fog,skies <dimension> <kind> [<seconds>])"
         TO TL-EXPECTED
     PERFORM PARSE-CHECK
     MOVE "test command parser an empty single word is an invalid argument" TO TL-CASE
     MOVE "supply Alice  3" TO WS-LINE
     MOVE "cobolcraft.command.invalid_argument(,supply <player> <item> [<count>])" TO TL-EXPECTED
     PERFORM PARSE-CHECK

*>   Greedy phrase and player names.
     MOVE "test command parser a greedy phrase takes the rest of the line as written" TO TL-CASE
     MOVE "murmur Alice hello  big   world" TO WS-LINE
     MOVE "ok murmur Alice hello  big   world" TO TL-EXPECTED
     PERFORM PARSE-CHECK
     MOVE "test command parser a greedy phrase after the command name" TO TL-CASE
     MOVE "announce all hands" TO WS-LINE
     MOVE "ok announce all hands" TO TL-EXPECTED
     PERFORM PARSE-CHECK
     MOVE "test command parser a player name is a word (its validity is the command's check)"
         TO TL-CASE
     MOVE "promote Bad-Name!" TO WS-LINE
     MOVE "ok promote Bad-Name!" TO TL-EXPECTED
     PERFORM PARSE-CHECK
     MOVE "test command parser an optional argument may be left out" TO TL-CASE
     MOVE "relocate Alice at 1 2 3" TO WS-LINE
     MOVE "ok relocate Alice at 1.00 2.00 3.00" TO TL-EXPECTED
     PERFORM PARSE-CHECK

*>   Unknown command and the usage string rule (§16.4).
     MOVE "test command parser an unknown command name" TO TL-CASE
     MOVE "frobnicate now" TO WS-LINE
     MOVE "cobolcraft.command.unknown(frobnicate)" TO TL-EXPECTED
     PERFORM PARSE-CHECK
     MOVE "test command parser guestlist alone names the first usage form, guestlist on" TO TL-CASE
     MOVE "guestlist" TO WS-LINE
     MOVE "cobolcraft.command.missing_argument(guestlist on)" TO TL-EXPECTED
     PERFORM PARSE-CHECK
     MOVE "test command parser guestlist add names guestlist add <player>" TO TL-CASE
     MOVE "guestlist add" TO WS-LINE
     MOVE "cobolcraft.command.missing_argument(guestlist add <player>)" TO TL-EXPECTED
     PERFORM PARSE-CHECK
     MOVE "test command parser relocate Alice to names the to form" TO TL-CASE
     MOVE "relocate Alice to" TO WS-LINE
     MOVE "cobolcraft.command.missing_argument(relocate <player> to <target>)" TO TL-EXPECTED
     PERFORM PARSE-CHECK
     MOVE "test command parser vitality with an amount out of range names the amount form"
         TO TL-CASE
     MOVE "vitality Alice 31" TO WS-LINE
     MOVE "cobolcraft.command.invalid_argument(31,vitality <player> <amount>)" TO TL-EXPECTED
     PERFORM PARSE-CHECK
     MOVE "test command parser a word matching no form names the command's first form" TO TL-CASE
     MOVE "mode Alice flying" TO WS-LINE
     MOVE "cobolcraft.command.invalid_argument(flying,mode <player> survival)" TO TL-EXPECTED
     PERFORM PARSE-CHECK
     MOVE "test command parser a fixed word of a later form selects that form" TO TL-CASE
     MOVE "sweep mobs area main 1 2" TO WS-LINE
     MOVE "cobolcraft.command.missing_argument(sweep <what> area <dimension> <x1> <y1> <z1> <x2> "
         & "<y2> <z2>)" TO TL-EXPECTED
     PERFORM PARSE-CHECK

*>   y against the dimension named in the line (cobolcraft:subroutine: 0 to 126).
     MOVE 1 TO CS-EXTRA-DIMENSIONS
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     MOVE "test command parser y above the subroutine's top (126) is an invalid argument"
         TO TL-CASE
     MOVE "relocate Alice at 0 127 0 subroutine" TO WS-LINE
     MOVE "cobolcraft.command.invalid_argument(127,relocate <player> at <x> <y> <z> "
         & "[<dimension>])" TO TL-EXPECTED
     PERFORM PARSE-CHECK
     MOVE "test command parser y = 126 in the subroutine parses" TO TL-CASE
     MOVE "relocate Alice at 0 126 0 subroutine" TO WS-LINE
     MOVE "ok relocate Alice at 0.00 126.00 0.00 subroutine" TO TL-EXPECTED
     PERFORM PARSE-CHECK
     MOVE "test command parser y1 and y2 of sweep area use the named dimension" TO TL-CASE
     MOVE "sweep mobs area subroutine 0 0 0 1 200 1" TO WS-LINE
     MOVE "cobolcraft.command.invalid_argument(200,sweep <what> area <dimension> <x1> <y1> <z1> "
         & "<x2> <y2> <z2>)" TO TL-EXPECTED
     PERFORM PARSE-CHECK
     MOVE "test command parser y of an unknown dimension is checked against main (the dimension "
         & "is the command's own check)" TO TL-CASE
     MOVE "conjure abend 0 200 0 nowhere" TO WS-LINE
     MOVE "ok conjure abend 0.00 200.00 0.00 nowhere" TO TL-EXPECTED
     PERFORM PARSE-CHECK
     STOP RUN.

 PARSE-LINE.
     COMPUTE WS-LENGTH = FUNCTION LENGTH(FUNCTION TRIM(WS-LINE TRAILING))
     CALL "CMD-PARSE" USING WS-SENDER WS-LINE WS-LENGTH PB-TEXT.

 PARSE-CHECK.
     PERFORM PARSE-LINE
     MOVE SPACES TO WS-TEXT
     MOVE 1 TO WS-PTR
     PERFORM RENDER-RESULT
     PERFORM CHECK-TEXT.

*> Appends at WS-PTR the reply (when the line was refused) or "ok ..." to WS-TEXT.
 RENDER-RESULT.
     MOVE FUNCTION LENGTH(FUNCTION TRIM(WS-TEXT TRAILING)) TO WS-PTR
     IF WS-PTR > 1
         ADD 2 TO WS-PTR
     ELSE
         MOVE 1 TO WS-PTR
     END-IF
     IF PB-TX-LENGTH > 0
         PERFORM RENDER-REPLY
     ELSE
         STRING "ok " CD-NAME(CQ-COMMAND)(1:CD-NAME-LENGTH(CQ-COMMAND)) DELIMITED BY SIZE
             INTO WS-TEXT POINTER WS-PTR
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > CQ-STEP-COUNT
             STRING " " DELIMITED BY SIZE INTO WS-TEXT POINTER WS-PTR
             MOVE CQ-STEP-NODE(WS-I) TO WS-NODE
             EVALUATE TRUE
                 WHEN CT-TYPE(WS-NODE) = 1
                     STRING CT-NAME(WS-NODE)(1:CT-NAME-LENGTH(WS-NODE)) DELIMITED BY SIZE
                         INTO WS-TEXT POINTER WS-PTR
                 WHEN CT-PARSER(WS-NODE) = 3
                     MOVE CQ-STEP-INT(WS-I) TO WS-INT-EDIT
                     STRING FUNCTION TRIM(WS-INT-EDIT) DELIMITED BY SIZE INTO WS-TEXT
                         POINTER WS-PTR
                 WHEN CT-PARSER(WS-NODE) = 2
                     COMPUTE WS-DOUBLE-EDIT ROUNDED = CQ-STEP-DOUBLE(WS-I)
                     STRING FUNCTION TRIM(WS-DOUBLE-EDIT) DELIMITED BY SIZE INTO WS-TEXT
                         POINTER WS-PTR
                 WHEN CQ-STEP-LENGTH(WS-I) > 0
                     STRING CQ-LINE(CQ-STEP-START(WS-I):CQ-STEP-LENGTH(WS-I)) DELIMITED BY SIZE
                         INTO WS-TEXT POINTER WS-PTR
             END-EVALUATE
         END-PERFORM
     END-IF.

 RENDER-REPLY.
     STRING PB-TX-VALUE(1:PB-TX-LENGTH) "(" DELIMITED BY SIZE INTO WS-TEXT POINTER WS-PTR
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > PB-TX-ARG-COUNT
         IF WS-I > 1
             STRING "," DELIMITED BY SIZE INTO WS-TEXT POINTER WS-PTR
         END-IF
         IF PB-TX-ARG-LENGTH(WS-I) > 0
             STRING PB-TX-ARG-VALUE(WS-I)(1:PB-TX-ARG-LENGTH(WS-I)) DELIMITED BY SIZE
                 INTO WS-TEXT POINTER WS-PTR
         END-IF
     END-PERFORM
     STRING ")" DELIMITED BY SIZE INTO WS-TEXT POINTER WS-PTR.

 CHECK-TEXT.
     MOVE "T" TO TL-MODE
     MOVE WS-TEXT TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

 END PROGRAM TEST-COMMAND-PARSER.

 COPY CORETEST.
