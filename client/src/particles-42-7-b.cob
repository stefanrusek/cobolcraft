*> Particles part 7 (docs/protocol/42-particles-7-emitters-entities-events-commands.md) section 2: the `/particle` command.
*>
*> Entry points for the integrator (inputs):
*>   P7-COORD token(PIC X(24)) flag base value(out): one vec3 coordinate: `~` or `~n` is relative to base (no correction); an absolute coordinate whose text has
*>     no `.` gets 0.5 added when the flag is set (the argument's centre-correct flag), else it is the number.
*>   P7-VEC3 text(PIC X(80): three coordinates) flag base(3 floats) out(3 floats): x and z with the flag, y always without (the `pos` argument has the flag set,
*>     `delta` does not).
*>   P7-PARTICLE-CMD permission known options-ok name(PIC X(40)) pos(3 floats) delta(3 floats) speed count force viewers-in-range code(out) success(out)
*>     P7-PACKETS: step 1 to 7. code: 0 sent (success = the viewers, one packet in row 1: override limiter = force, always show false, count, delta as
*>     distances, speed on all three axes, DEFAULT), 1 permission level below 2, 2 `particle.notFound`, 3 `particle.invalidOptions`, 4
*>     `commands.particle.failed` (no viewer). The caller counts the viewers with P7-PLAYER-SEES (per viewer, radius by force).

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P7-COORD.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-DOTS                BINARY-LONG.
 01 WS-REST                PIC X(24).
 LINKAGE SECTION.
 01 L-TOKEN                PIC X(24).
 01 L-FLAG                 BINARY-LONG.
 01 L-BASE                 FLOAT-LONG.
 01 L-VALUE                FLOAT-LONG.
 PROCEDURE DIVISION USING L-TOKEN L-FLAG L-BASE L-VALUE.
     IF L-TOKEN(1:1) = "~"
         MOVE L-TOKEN(2:23) TO WS-REST
         MOVE L-BASE TO L-VALUE
         IF WS-REST NOT = SPACES
             COMPUTE L-VALUE = L-BASE + FUNCTION NUMVAL(WS-REST)
         END-IF
     ELSE
         MOVE 0 TO WS-DOTS
         INSPECT L-TOKEN TALLYING WS-DOTS FOR ALL "."
         COMPUTE L-VALUE = FUNCTION NUMVAL(L-TOKEN)
         IF L-FLAG NOT = 0 AND WS-DOTS = 0
             COMPUTE L-VALUE = L-VALUE + 0.5
         END-IF
     END-IF
     GOBACK.
 END PROGRAM P7-COORD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P7-VEC3.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-TOK1                PIC X(24).
 01 WS-TOK2                PIC X(24).
 01 WS-TOK3                PIC X(24).
 01 WS-NOFLAG              BINARY-LONG VALUE 0.
 LINKAGE SECTION.
 01 L-TEXT                 PIC X(80).
 01 L-FLAG                 BINARY-LONG.
 01 L-BASE.
    05 L-B                 FLOAT-LONG OCCURS 3 TIMES.
 01 L-OUT.
    05 L-O                 FLOAT-LONG OCCURS 3 TIMES.
 PROCEDURE DIVISION USING L-TEXT L-FLAG L-BASE L-OUT.
     MOVE SPACES TO WS-TOK1 WS-TOK2 WS-TOK3
     UNSTRING L-TEXT DELIMITED BY ALL SPACE INTO WS-TOK1 WS-TOK2 WS-TOK3
     CALL "P7-COORD" USING WS-TOK1 L-FLAG L-B(1) L-O(1)
     CALL "P7-COORD" USING WS-TOK2 WS-NOFLAG L-B(2) L-O(2)
     CALL "P7-COORD" USING WS-TOK3 L-FLAG L-B(3) L-O(3)
     GOBACK.
 END PROGRAM P7-VEC3.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P7-PARTICLE-CMD.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-PERM                 BINARY-LONG.
 01 L-KNOWN                BINARY-LONG.
 01 L-OK                   BINARY-LONG.
 01 L-NAME                 PIC X(40).
 01 L-POS.
    05 L-P                 FLOAT-LONG OCCURS 3 TIMES.
 01 L-DELTA.
    05 L-D                 FLOAT-LONG OCCURS 3 TIMES.
 01 L-SPEED                FLOAT-LONG.
 01 L-COUNT                BINARY-LONG.
 01 L-FORCE                BINARY-LONG.
 01 L-VIEWERS              BINARY-LONG.
 01 L-CODE                 BINARY-LONG.
 01 L-SUCCESS              BINARY-LONG.
 COPY CLP7PK.
 PROCEDURE DIVISION USING L-PERM L-KNOWN L-OK L-NAME L-POS L-DELTA L-SPEED L-COUNT L-FORCE L-VIEWERS
         L-CODE L-SUCCESS P7-PACKETS.
     MOVE 0 TO PS-COUNT L-SUCCESS
     EVALUATE TRUE
         WHEN L-PERM < 2
             MOVE 1 TO L-CODE
         WHEN L-KNOWN = 0
             MOVE 2 TO L-CODE
         WHEN L-OK = 0
             MOVE 3 TO L-CODE
         WHEN L-VIEWERS = 0
             MOVE 4 TO L-CODE
         WHEN OTHER
             MOVE 0 TO L-CODE
             MOVE L-VIEWERS TO L-SUCCESS
             MOVE 1 TO PS-COUNT
             MOVE L-NAME TO PS-NAME(1)
             MOVE 0 TO PS-FORCE(1) PS-ALWAYS(1)
             IF L-FORCE NOT = 0
                 MOVE 1 TO PS-FORCE(1)
             END-IF
             MOVE L-P(1) TO PS-X(1)
             MOVE L-P(2) TO PS-Y(1)
             MOVE L-P(3) TO PS-Z(1)
             MOVE L-COUNT TO PS-COUNT-OF(1)
             MOVE L-D(1) TO PS-DX(1)
             MOVE L-D(2) TO PS-DY(1)
             MOVE L-D(3) TO PS-DZ(1)
             MOVE L-SPEED TO PS-SX(1) PS-SY(1) PS-SZ(1)
             MOVE 0 TO PS-MODE(1) PS-STATE(1)
     END-EVALUATE
     GOBACK.
 END PROGRAM P7-PARTICLE-CMD.
