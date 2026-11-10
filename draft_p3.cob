*> Acceptance test of docs/protocol/42-particles-7-emitters-entities-events-commands.md section 3 (Explosions): the server particle choice, the packet range, the client tracker (particle count, explosion pick, one block-explosion particle with its draw order, the default list) and the gust seed. Expected texts are computed independently by a script
*> from the document's formulas; each case injects the draws in the documented order and compares the emission list (5 decimals), the sounds and the count of draws consumed.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-PARTICLES-42-7-3.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLP6EM.
 COPY TESTLIB.
 01 WS-NAME                PIC X(160).
 01 WS-CLASS               PIC X(24).
 01 WS-INT                 PIC X(300).
 01 WS-DRT                 PIC X(8000).
 01 WS-EXP                 PIC X(8000).
 01 WS-OBS                 PIC X(12000).
 01 WS-OBS2                PIC X(12000).
 01 WS-LEN                 BINARY-LONG.
 01 WS-START               BINARY-LONG.
 01 WS-IN.
    05 WS-IV               FLOAT-LONG OCCURS 16 TIMES.
 01 WS-OUT.
    05 WS-OV               FLOAT-LONG OCCURS 64 TIMES.
 01 WS-LIST.
    05 WS-NUM              FLOAT-LONG OCCURS 2100 TIMES.
 01 WS-COUNT               BINARY-LONG.
 01 WS-TEXT                PIC X(8000).
 01 WS-TOK                 PIC X(40).
 01 WS-PTR                 BINARY-LONG.
 01 WS-PTR2                BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-ED                  PIC -(5)9.99999.
 01 WS-EDC                 PIC -(10)9.
 01 WS-EDS                 PIC 9.99.
 01 WS-EDR                 PIC 9.99999.
 01 WS-V                   FLOAT-LONG.
 01 WS-E                   FLOAT-LONG.
 01 WS-O                   FLOAT-LONG.
 PROCEDURE DIVISION.
     MOVE "block explosion particle centre (10, 64, -5, 4) notAir 0 draws 7" TO WS-NAME
     MOVE "block_particle" TO WS-CLASS
     MOVE "10.0 64.0 -5.0 4.0 0.0" TO WS-INT
     MOVE SPACES TO WS-DRT
     MOVE "0.9 0.2 0.7 0.5 0.3 0.8 0.1" TO WS-DRT
     MOVE SPACES TO WS-EXP
     MOVE "poof 11.17909 63.11568 -4.41045 0.32257 -0.24193 0.16129 (7)" TO WS-EXP
     PERFORM RUN-CASE
     MOVE "block explosion particle centre (10, 64, -5, 4) notAir 0 draws 7" TO WS-NAME
     MOVE "block_particle" TO WS-CLASS
     MOVE "10.0 64.0 -5.0 4.0 0.0" TO WS-INT
     MOVE SPACES TO WS-DRT
     MOVE "0.9 0.2 0.7 0.5 0.3 0.8 0.9" TO WS-DRT
     MOVE SPACES TO WS-EXP
     MOVE "smoke 12.35818 62.23136 -3.82091 0.32257 -0.24193 0.16129 (7"
         & ")" TO WS-EXP
     PERFORM RUN-CASE
     MOVE "block explosion particle centre (0, 0, 0, 2.5) notAir 0 draws 7" TO WS-NAME
     MOVE "block_particle" TO WS-CLASS
     MOVE "0.0 0.0 0.0 2.5 0.0" TO WS-INT
     MOVE SPACES TO WS-DRT
     MOVE "0.1 0.1 0.1 0.001 0.6 0.6 0.4" TO WS-DRT
     MOVE SPACES TO WS-EXP
     MOVE "poof -0.07217 -0.07217 -0.07217 -0.69282 -0.69282 -0.69282 ("
         & "7)" TO WS-EXP
     PERFORM RUN-CASE
     MOVE "block explosion particle centre (0, 0, 0, 2.5) notAir 1 draws 4" TO WS-NAME
     MOVE "block_particle" TO WS-CLASS
     MOVE "0.0 0.0 0.0 2.5 1.0" TO WS-INT
     MOVE SPACES TO WS-DRT
     MOVE "0.9 0.2 0.7 0.5" TO WS-DRT
     MOVE SPACES TO WS-EXP
     MOVE " (4)" TO WS-EXP
     PERFORM RUN-CASE
     MOVE "block explosion particle centre (100, 70, 100, 6) notAir 0 draws 7" TO WS-NAME
     MOVE "block_particle" TO WS-CLASS
     MOVE "100.0 70.0 100.0 6.0 0.0" TO WS-INT
     MOVE SPACES TO WS-DRT
     MOVE "0.6 0.7 0.8 0.99 0.0 1.0 0.5" TO WS-DRT
     MOVE SPACES TO WS-EXP
     MOVE "smoke 101.59820 73.19641 104.79461 0.08018 0.16036 0.24054 ("
         & "7)" TO WS-EXP
     PERFORM RUN-CASE
     MOVE "gust seed age 0 lifetime 6 delay 0" TO WS-NAME
     MOVE "gust_seed" TO WS-CLASS
     MOVE "1.0 64.0 2.0 1.5 6.0 0.0 0.0" TO WS-INT
     MOVE SPACES TO WS-DRT
     MOVE "0.237964627 0.544229225 0.369955167 0.603920039 0.625720304 "
         & "0.065528859 0.013167992 0.837469082 0.259354014 0.234330961 "
         & "0.995644836 0.470263508 0.836461451 0.476353209 0.639068141 "
         & "0.150616424 0.634860658 0.868045307" TO WS-DRT
     MOVE SPACES TO WS-EXP
     MOVE "gust 0.54060 63.64905 2.84029 0.00000 0.00000 0.00000 | gust"
         & " -0.23645 64.03753 2.78807 0.00000 0.00000 0.00000 | gust 1."
         & "54016 64.73268 1.65022 0.00000 0.00000 0.00000 (18)" TO WS-EXP
     PERFORM RUN-CASE
     MOVE "gust seed age 5 lifetime 6 delay 0" TO WS-NAME
     MOVE "gust_seed" TO WS-CLASS
     MOVE "1.0 64.0 2.0 1.5 6.0 0.0 5.0" TO WS-INT
     MOVE SPACES TO WS-DRT
     MOVE "0.237964627 0.544229225 0.369955167 0.603920039 0.625720304 "
         & "0.065528859 0.013167992 0.837469082 0.259354014 0.234330961 "
         & "0.995644836 0.470263508 0.836461451 0.476353209 0.639068141 "
         & "0.150616424 0.634860658 0.868045307" TO WS-DRT
     MOVE SPACES TO WS-EXP
     MOVE "gust 0.54060 63.64905 2.84029 0.83333 0.00000 0.00000 | gust"
         & " -0.23645 64.03753 2.78807 0.83333 0.00000 0.00000 | gust 1."
         & "54016 64.73268 1.65022 0.83333 0.00000 0.00000 (18)" TO WS-EXP
     PERFORM RUN-CASE
     MOVE "gust seed age 0 lifetime 6 delay 2" TO WS-NAME
     MOVE "gust_seed" TO WS-CLASS
     MOVE "1.0 64.0 2.0 1.5 6.0 2.0 0.0" TO WS-INT
     MOVE SPACES TO WS-DRT
     MOVE "0.237964627 0.544229225 0.369955167 0.603920039 0.625720304 "
         & "0.065528859 0.013167992 0.837469082 0.259354014 0.234330961 "
         & "0.995644836 0.470263508 0.836461451 0.476353209 0.639068141 "
         & "0.150616424 0.634860658 0.868045307" TO WS-DRT
     MOVE SPACES TO WS-EXP
     MOVE "gust 0.54060 63.64905 2.84029 0.00000 0.00000 0.00000 | gust"
         & " -0.23645 64.03753 2.78807 0.00000 0.00000 0.00000 | gust 1."
         & "54016 64.73268 1.65022 0.00000 0.00000 0.00000 (18)" TO WS-EXP
     PERFORM RUN-CASE
     MOVE "gust seed age 1 lifetime 6 delay 2" TO WS-NAME
     MOVE "gust_seed" TO WS-CLASS
     MOVE "1.0 64.0 2.0 1.5 6.0 2.0 1.0" TO WS-INT
     MOVE SPACES TO WS-DRT
     MOVE "0.237964627 0.544229225 0.369955167 0.603920039 0.625720304 "
         & "0.065528859 0.013167992 0.837469082 0.259354014 0.234330961 "
         & "0.995644836 0.470263508 0.836461451 0.476353209 0.639068141 "
         & "0.150616424 0.634860658 0.868045307" TO WS-DRT
     MOVE SPACES TO WS-EXP
     MOVE " (0)" TO WS-EXP
     PERFORM RUN-CASE
     MOVE "gust seed age 3 lifetime 6 delay 2" TO WS-NAME
     MOVE "gust_seed" TO WS-CLASS
     MOVE "1.0 64.0 2.0 1.5 6.0 2.0 3.0" TO WS-INT
     MOVE SPACES TO WS-DRT
     MOVE "0.237964627 0.544229225 0.369955167 0.603920039 0.625720304 "
         & "0.065528859 0.013167992 0.837469082 0.259354014 0.234330961 "
         & "0.995644836 0.470263508 0.836461451 0.476353209 0.639068141 "
         & "0.150616424 0.634860658 0.868045307" TO WS-DRT
     MOVE SPACES TO WS-EXP
     MOVE "gust 0.54060 63.64905 2.84029 0.50000 0.00000 0.00000 | gust"
         & " -0.23645 64.03753 2.78807 0.50000 0.00000 0.00000 | gust 1."
         & "54016 64.73268 1.65022 0.50000 0.00000 0.00000 (18)" TO WS-EXP
     PERFORM RUN-CASE
     MOVE "gust seed age 10 lifetime 20 delay 4" TO WS-NAME
     MOVE "gust_seed" TO WS-CLASS
     MOVE "0.0 0.0 0.0 3.0 20.0 4.0 10.0" TO WS-INT
     MOVE SPACES TO WS-DRT
     MOVE "0.237964627 0.544229225 0.369955167 0.603920039 0.625720304 "
         & "0.065528859 0.013167992 0.837469082 0.259354014 0.234330961 "
         & "0.995644836 0.470263508 0.836461451 0.476353209 0.639068141 "
         & "0.150616424 0.634860658 0.868045307" TO WS-DRT
     MOVE SPACES TO WS-EXP
     MOVE "gust -0.91879 -0.70189 1.68057 0.50000 0.00000 0.00000 | gus"
         & "t -2.47290 0.07507 1.57614 0.50000 0.00000 0.00000 | gust 1."
         & "08032 1.46536 -0.69955 0.50000 0.00000 0.00000 (18)" TO WS-EXP
     PERFORM RUN-CASE
     MOVE "packet particle: the explosion particle is added once at the centre with velocity (1, 0, 0)" TO WS-NAME
     MOVE "packet_particle" TO WS-CLASS
     MOVE "3.0 70.0 -4.0" TO WS-INT
     MOVE SPACES TO WS-DRT
     MOVE SPACES TO WS-EXP
     MOVE "explosion 3.00000 70.00000 -4.00000 1.00000 0.00000 0.00000 "
         & "(0)" TO WS-EXP
     PERFORM RUN-CASE
     MOVE 1.2 TO WS-IV(1)
     MOVE 0.0 TO WS-IV(2)
     CALL "P7-EXPLOSION-KIND" USING WS-IN WS-OUT
     MOVE "particle selection radius 1.2 keeps blocks 0 (1 = small) [1]" TO WS-NAME
     MOVE 1.0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 2.0 TO WS-IV(1)
     MOVE 0.0 TO WS-IV(2)
     CALL "P7-EXPLOSION-KIND" USING WS-IN WS-OUT
     MOVE "particle selection radius 2 keeps blocks 0 (1 = small) [1]" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 1.99 TO WS-IV(1)
     MOVE 0.0 TO WS-IV(2)
     CALL "P7-EXPLOSION-KIND" USING WS-IN WS-OUT
     MOVE "particle selection radius 1.99 keeps blocks 0 (1 = small) [1]" TO WS-NAME
     MOVE 1.0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 5.0 TO WS-IV(1)
     MOVE 1.0 TO WS-IV(2)
     CALL "P7-EXPLOSION-KIND" USING WS-IN WS-OUT
     MOVE "particle selection radius 5 keeps blocks 1 (1 = small) [1]" TO WS-NAME
     MOVE 1.0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 3.0 TO WS-IV(1)
     MOVE 0.0 TO WS-IV(2)
     CALL "P7-EXPLOSION-KIND" USING WS-IN WS-OUT
     MOVE "particle selection radius 3 keeps blocks 0 (1 = small) [1]" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0.5 TO WS-IV(1)
     MOVE 1.0 TO WS-IV(2)
     CALL "P7-EXPLOSION-KIND" USING WS-IN WS-OUT
     MOVE "particle selection radius 0.5 keeps blocks 1 (1 = small) [1]" TO WS-NAME
     MOVE 1.0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0.0 TO WS-IV(1)
     CALL "P7-EXPLOSION-SEND" USING WS-IN WS-OUT
     MOVE "packet sent to a player at squared distance 0 [1]" TO WS-NAME
     MOVE 1.0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 4095.0 TO WS-IV(1)
     CALL "P7-EXPLOSION-SEND" USING WS-IN WS-OUT
     MOVE "packet sent to a player at squared distance 4095 [1]" TO WS-NAME
     MOVE 1.0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 4096.0 TO WS-IV(1)
     CALL "P7-EXPLOSION-SEND" USING WS-IN WS-OUT
     MOVE "packet sent to a player at squared distance 4096 [1]" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 5000.0 TO WS-IV(1)
     CALL "P7-EXPLOSION-SEND" USING WS-IN WS-OUT
     MOVE "packet sent to a player at squared distance 5000 [1]" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 1.0 TO WS-IV(1)
     MOVE 10.0 TO WS-IV(2)
     CALL "P7-EXPLOSION-N" USING WS-IN WS-OUT
     MOVE "tick particle count all 1 weight 10 [1]" TO WS-NAME
     MOVE 10.0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 1.0 TO WS-IV(1)
     MOVE 600.0 TO WS-IV(2)
     CALL "P7-EXPLOSION-N" USING WS-IN WS-OUT
     MOVE "tick particle count all 1 weight 600 [1]" TO WS-NAME
     MOVE 512.0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 1.0 TO WS-IV(1)
     MOVE 512.0 TO WS-IV(2)
     CALL "P7-EXPLOSION-N" USING WS-IN WS-OUT
     MOVE "tick particle count all 1 weight 512 [1]" TO WS-NAME
     MOVE 512.0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0.0 TO WS-IV(1)
     MOVE 10.0 TO WS-IV(2)
     CALL "P7-EXPLOSION-N" USING WS-IN WS-OUT
     MOVE "tick particle count all 0 weight 10 [1]" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 1.0 TO WS-IV(1)
     MOVE 0.0 TO WS-IV(2)
     CALL "P7-EXPLOSION-N" USING WS-IN WS-OUT
     MOVE "tick particle count all 1 weight 0 [1]" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0.0 TO WS-IV(1)
     MOVE 2.0 TO WS-IV(2)
     MOVE 3.0 TO WS-IV(3)
     MOVE 5.0 TO WS-IV(4)
     CALL "P7-EXPLOSION-PICK" USING WS-IN WS-OUT
     MOVE "explosion pick r 0 counts [3, 5] [1]" TO WS-NAME
     MOVE 1.0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0.37 TO WS-IV(1)
     MOVE 2.0 TO WS-IV(2)
     MOVE 3.0 TO WS-IV(3)
     MOVE 5.0 TO WS-IV(4)
     CALL "P7-EXPLOSION-PICK" USING WS-IN WS-OUT
     MOVE "explosion pick r 0.37 counts [3, 5] [1]" TO WS-NAME
     MOVE 1.0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0.38 TO WS-IV(1)
     MOVE 2.0 TO WS-IV(2)
     MOVE 3.0 TO WS-IV(3)
     MOVE 5.0 TO WS-IV(4)
     CALL "P7-EXPLOSION-PICK" USING WS-IN WS-OUT
     MOVE "explosion pick r 0.38 counts [3, 5] [1]" TO WS-NAME
     MOVE 2.0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0.99 TO WS-IV(1)
     MOVE 2.0 TO WS-IV(2)
     MOVE 3.0 TO WS-IV(3)
     MOVE 5.0 TO WS-IV(4)
     CALL "P7-EXPLOSION-PICK" USING WS-IN WS-OUT
     MOVE "explosion pick r 0.99 counts [3, 5] [1]" TO WS-NAME
     MOVE 2.0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0.5 TO WS-IV(1)
     MOVE 1.0 TO WS-IV(2)
     MOVE 4.0 TO WS-IV(3)
     CALL "P7-EXPLOSION-PICK" USING WS-IN WS-OUT
     MOVE "explosion pick r 0.5 counts [4] [1]" TO WS-NAME
     MOVE 1.0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0.7 TO WS-IV(1)
     MOVE 3.0 TO WS-IV(2)
     MOVE 1.0 TO WS-IV(3)
     MOVE 1.0 TO WS-IV(4)
     MOVE 1.0 TO WS-IV(5)
     CALL "P7-EXPLOSION-PICK" USING WS-IN WS-OUT
     MOVE "explosion pick r 0.7 counts [1, 1, 1] [1]" TO WS-NAME
     MOVE 3.0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0.2 TO WS-IV(1)
     MOVE 3.0 TO WS-IV(2)
     MOVE 2.0 TO WS-IV(3)
     MOVE 0.0 TO WS-IV(4)
     MOVE 6.0 TO WS-IV(5)
     CALL "P7-EXPLOSION-PICK" USING WS-IN WS-OUT
     MOVE "explosion pick r 0.2 counts [2, 0, 6] [1]" TO WS-NAME
     MOVE 1.0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     CALL "P7-EXPLOSION-LIST" USING WS-IN WS-OUT
     MOVE "block explosion list total weight [1]" TO WS-NAME
     MOVE 2.0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "block explosion list total weight [2]" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "block explosion list total weight [3]" TO WS-NAME
     MOVE 1.0 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "block explosion list total weight [4]" TO WS-NAME
     MOVE 1.0 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "block explosion list total weight [5]" TO WS-NAME
     MOVE 1.0 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "block explosion list total weight [6]" TO WS-NAME
     MOVE 1.0 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "block explosion list total weight [7]" TO WS-NAME
     MOVE 1.0 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE 1.0 TO WS-IV(1)
     MOVE 5.0 TO WS-IV(2)
     CALL "P7-EXPLOSION-CALLER" USING WS-IN WS-OUT
     MOVE "known caller 1 (input 5): radius, gust particles, trigger interaction [1]" TO WS-NAME
     MOVE 5.0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "known caller 1 (input 5): radius, gust particles, trigger interaction [2]" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "known caller 1 (input 5): radius, gust particles, trigger interaction [3]" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE 2.0 TO WS-IV(1)
     MOVE 0.0 TO WS-IV(2)
     CALL "P7-EXPLOSION-CALLER" USING WS-IN WS-OUT
     MOVE "known caller 2 (input 0): radius, gust particles, trigger interaction [1]" TO WS-NAME
     MOVE 1.2 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "known caller 2 (input 0): radius, gust particles, trigger interaction [2]" TO WS-NAME
     MOVE 1.0 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "known caller 2 (input 0): radius, gust particles, trigger interaction [3]" TO WS-NAME
     MOVE 1.0 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE 3.0 TO WS-IV(1)
     MOVE 0.0 TO WS-IV(2)
     CALL "P7-EXPLOSION-CALLER" USING WS-IN WS-OUT
     MOVE "known caller 3 (input 0): radius, gust particles, trigger interaction [1]" TO WS-NAME
     MOVE 3.0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "known caller 3 (input 0): radius, gust particles, trigger interaction [2]" TO WS-NAME
     MOVE 1.0 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "known caller 3 (input 0): radius, gust particles, trigger interaction [3]" TO WS-NAME
     MOVE 1.0 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE 4.0 TO WS-IV(1)
     MOVE 0.25 TO WS-IV(2)
     CALL "P7-EXPLOSION-CALLER" USING WS-IN WS-OUT
     MOVE "known caller 4 (input 0.25): radius, gust particles, trigger interaction [1]" TO WS-NAME
     MOVE 3.5 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "known caller 4 (input 0.25): radius, gust particles, trigger interaction [2]" TO WS-NAME
     MOVE 1.0 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "known caller 4 (input 0.25): radius, gust particles, trigger interaction [3]" TO WS-NAME
     MOVE 1.0 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE 4.0 TO WS-IV(1)
     MOVE 1.0 TO WS-IV(2)
     CALL "P7-EXPLOSION-CALLER" USING WS-IN WS-OUT
     MOVE "known caller 4 (input 1): radius, gust particles, trigger interaction [1]" TO WS-NAME
     MOVE 5.0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "known caller 4 (input 1): radius, gust particles, trigger interaction [2]" TO WS-NAME
     MOVE 1.0 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "known caller 4 (input 1): radius, gust particles, trigger interaction [3]" TO WS-NAME
     MOVE 1.0 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0.5 TO WS-IV(1)
     MOVE 0.5 TO WS-IV(2)
     CALL "P7-EXPLOSION-PITCH" USING WS-IN WS-OUT
     MOVE "local sound pitch 0.5 0.5 [1]" TO WS-NAME
     MOVE 0.7 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 1.0 TO WS-IV(1)
     MOVE 0.0 TO WS-IV(2)
     CALL "P7-EXPLOSION-PITCH" USING WS-IN WS-OUT
     MOVE "local sound pitch 1 0 [1]" TO WS-NAME
     MOVE 0.84 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0.0 TO WS-IV(1)
     MOVE 1.0 TO WS-IV(2)
     CALL "P7-EXPLOSION-PITCH" USING WS-IN WS-OUT
     MOVE "local sound pitch 0 1 [1]" TO WS-NAME
     MOVE 0.56 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
 STOP RUN.

 RUN-CASE.
     MOVE WS-INT TO WS-TEXT
     PERFORM PARSE-LIST
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 16
         MOVE 0 TO WS-IV(WS-I)
     END-PERFORM
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-COUNT
         MOVE WS-NUM(WS-I) TO WS-IV(WS-I)
     END-PERFORM
     MOVE WS-DRT TO WS-TEXT
     PERFORM PARSE-LIST
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 2048
         MOVE 0.5 TO EM-DRAW(WS-I)
     END-PERFORM
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-COUNT
         MOVE WS-NUM(WS-I) TO EM-DRAW(WS-I)
     END-PERFORM
     MOVE 0 TO EM-COUNT EM-CUR EM-SOUND-COUNT
     CALL "P7-EXPLOSION" USING WS-CLASS WS-IN P6-EMITS
     PERFORM RENDER
     MOVE FUNCTION LENGTH(FUNCTION TRIM(WS-OBS)) TO WS-LEN
     IF WS-LEN > 1000
         MOVE WS-OBS(1:480) TO WS-OBS2(1:480)
         MOVE "..." TO WS-OBS2(481:3)
         COMPUTE WS-START = WS-LEN - 479
         MOVE WS-OBS(WS-START:480) TO WS-OBS2(484:480)
         MOVE WS-OBS2 TO WS-OBS
     END-IF
     MOVE SPACES TO TL-CASE
     STRING "acceptance US12 42-7§3 Explosions: " FUNCTION TRIM(WS-NAME) DELIMITED BY SIZE INTO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE WS-EXP TO TL-EXPECTED
     MOVE WS-OBS TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

 CHECK-NUM.
     MOVE SPACES TO TL-CASE
     STRING "acceptance US12 42-7§3 Explosions: " FUNCTION TRIM(WS-NAME) DELIMITED BY SIZE INTO TL-CASE
     MOVE "N" TO TL-MODE
     IF FUNCTION ABS(WS-O - WS-E) <= 0.00002
         MOVE WS-E TO WS-O
     END-IF
     COMPUTE TL-EXPECTED-N ROUNDED = WS-E * 100000
     COMPUTE TL-OBSERVED-N ROUNDED = WS-O * 100000
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

 CHECK-TEXT.
     MOVE SPACES TO TL-CASE
     STRING "acceptance US12 42-7§3 Explosions: " FUNCTION TRIM(WS-NAME) DELIMITED BY SIZE INTO TL-CASE
     MOVE "T" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

 PARSE-LIST.
     MOVE 0 TO WS-COUNT
     MOVE 1 TO WS-PTR
     PERFORM UNTIL WS-PTR > 8000 OR WS-TEXT(WS-PTR:) = SPACES
         MOVE SPACES TO WS-TOK
         UNSTRING WS-TEXT DELIMITED BY ALL SPACE INTO WS-TOK WITH POINTER WS-PTR
         IF WS-TOK NOT = SPACES
             ADD 1 TO WS-COUNT
             COMPUTE WS-NUM(WS-COUNT) = FUNCTION NUMVAL(WS-TOK)
         END-IF
     END-PERFORM.

 RENDER.
     MOVE SPACES TO WS-OBS
     MOVE 1 TO WS-PTR2
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > EM-COUNT
         IF WS-I > 1
             STRING " | " DELIMITED BY SIZE INTO WS-OBS WITH POINTER WS-PTR2
         END-IF
         STRING FUNCTION TRIM(EM-NAME(WS-I)) " " DELIMITED BY SIZE INTO WS-OBS WITH POINTER WS-PTR2
         MOVE EM-X(WS-I) TO WS-V
         PERFORM ADD-NUMBER
         MOVE EM-Y(WS-I) TO WS-V
         PERFORM ADD-NUMBER
         MOVE EM-Z(WS-I) TO WS-V
         PERFORM ADD-NUMBER
         MOVE EM-VX(WS-I) TO WS-V
         PERFORM ADD-NUMBER
         MOVE EM-VY(WS-I) TO WS-V
         PERFORM ADD-NUMBER
         MOVE EM-VZ(WS-I) TO WS-V
         PERFORM ADD-LAST-NUMBER
         IF EM-COLOR(WS-I) NOT = 0
             MOVE EM-COLOR(WS-I) TO WS-EDC
             COMPUTE WS-EDS ROUNDED = EM-SCALE(WS-I)
             STRING " c=" FUNCTION TRIM(WS-EDC) " s=" WS-EDS DELIMITED BY SIZE INTO WS-OBS WITH POINTER WS-PTR2
         END-IF
         IF EM-STATE(WS-I) NOT = 0
             MOVE EM-STATE(WS-I) TO WS-EDC
             STRING " st=" FUNCTION TRIM(WS-EDC) DELIMITED BY SIZE INTO WS-OBS WITH POINTER WS-PTR2
         END-IF
     END-PERFORM
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > EM-SOUND-COUNT
         STRING " # " FUNCTION TRIM(EM-SOUND(WS-I)) DELIMITED BY SIZE INTO WS-OBS WITH POINTER WS-PTR2
     END-PERFORM
     MOVE EM-CUR TO WS-EDC
     STRING " (" FUNCTION TRIM(WS-EDC) ")" DELIMITED BY SIZE INTO WS-OBS WITH POINTER WS-PTR2.

 ADD-NUMBER.
     PERFORM ADD-LAST-NUMBER
     STRING " " DELIMITED BY SIZE INTO WS-OBS WITH POINTER WS-PTR2.

 ADD-LAST-NUMBER.
     COMPUTE WS-ED ROUNDED = WS-V
     STRING FUNCTION TRIM(WS-ED) DELIMITED BY SIZE INTO WS-OBS WITH POINTER WS-PTR2.
 END PROGRAM TEST-PARTICLES-42-7-3.
