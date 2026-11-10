*> Status effects of the local player (docs/protocol/49 sections 1 to 3): EFFECTS-CLEAR empties the list; EFFECT-SET adds an effect or replaces the
*> one of the same id (Update Mob Effect, 05b 0x87); CLIENT-EFFECT-REMOVE drops one (Remove Mob Effect, 05b 0x4F); HUD-TICK is one client tick of the HUD
*> (the tick count, the damage cooldown and every duration down by one, hearts.cob); EFFECT-INFO reads a row of the table of section 2.4 (CLEFFECT.cpy);
*> EFFECT-COMPARE and EFFECT-ORDER give the natural order of section 2.3; EFFECT-ALPHA the icon alpha of 2.5; EFFECT-NAME-TEXT and
*> EFFECT-DURATION-TEXT the texts of 3.3 and 3.4 (a pack's lang keys effect.minecraft.<key>, enchantment.level.<n> and effect.duration.infinite
*> replace the English fallbacks).

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EFFECTS-CLEAR.
*> USING CLIENT-STATE.
 DATA DIVISION.
 LINKAGE SECTION.
 COPY CLSTATE.
 PROCEDURE DIVISION USING CLIENT-STATE.
     MOVE 0 TO EF-COUNT
     GOBACK.
 END PROGRAM EFFECTS-CLEAR.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EFFECT-INFO.
*> USING effect id, beneficial (out: 1 = category Beneficial), colour (out, RGB integer), key (out, PIC X(80)), key length, English name (out, PIC X(64)),
*> name length. An id outside the table is harmful, colour 0, key "unknown".
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLCONST.
 COPY CLEFFECT.
 01 WS-HEX                 PIC X(6).
 01 WS-I                   BINARY-LONG.
 01 WS-DIGIT               BINARY-LONG.
 LINKAGE SECTION.
 01 L-ID                   BINARY-LONG.
 01 L-BENEFICIAL           BINARY-LONG.
 01 L-COLOUR               BINARY-LONG.
 01 L-KEY                  PIC X(80).
 01 L-KEY-LENGTH           BINARY-LONG.
 01 L-NAME                 PIC X(64).
 01 L-NAME-LENGTH          BINARY-LONG.
 PROCEDURE DIVISION USING L-ID L-BENEFICIAL L-COLOUR L-KEY L-KEY-LENGTH L-NAME L-NAME-LENGTH.
     MOVE SPACES TO L-KEY L-NAME
     IF L-ID < 0 OR L-ID >= EF-TABLE-COUNT
         MOVE 0 TO L-BENEFICIAL L-COLOUR
         MOVE "unknown" TO L-KEY L-NAME
         MOVE 7 TO L-KEY-LENGTH L-NAME-LENGTH
         GOBACK
     END-IF
     MOVE 0 TO L-BENEFICIAL
     IF EF-ROW-CATEGORY(L-ID + 1) = "B"
         MOVE 1 TO L-BENEFICIAL
     END-IF
     MOVE EF-ROW-COLOUR(L-ID + 1) TO WS-HEX
     MOVE 0 TO L-COLOUR
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 6
         COMPUTE WS-DIGIT = FUNCTION ORD(WS-HEX(WS-I:1)) - 1
         IF WS-DIGIT >= 65
             SUBTRACT 55 FROM WS-DIGIT
         ELSE
             SUBTRACT 48 FROM WS-DIGIT
         END-IF
         COMPUTE L-COLOUR = L-COLOUR * 16 + WS-DIGIT
     END-PERFORM
     MOVE EF-ROW-KEY(L-ID + 1) TO L-KEY
     MOVE FUNCTION LENGTH(FUNCTION TRIM(EF-ROW-KEY(L-ID + 1))) TO L-KEY-LENGTH
     MOVE EF-ROW-NAME(L-ID + 1) TO L-NAME
     MOVE FUNCTION LENGTH(FUNCTION TRIM(EF-ROW-NAME(L-ID + 1))) TO L-NAME-LENGTH
     GOBACK.
 END PROGRAM EFFECT-INFO.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EFFECT-SET.
*> USING CLIENT-STATE, effect id, amplifier, duration (-1 infinite), flags: adds the effect or replaces the entry with the same id.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLCONST.
 01 WS-I                   BINARY-LONG.
 01 WS-AT                  BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-ID                   BINARY-LONG.
 01 L-AMP                  BINARY-LONG.
 01 L-DUR                  BINARY-LONG.
 01 L-FLAGS                BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-ID L-AMP L-DUR L-FLAGS.
     MOVE 0 TO WS-AT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > EF-COUNT
         IF EF-ID(WS-I) = L-ID
             MOVE WS-I TO WS-AT
         END-IF
     END-PERFORM
     IF WS-AT = 0 AND EF-COUNT < EF-TABLE-COUNT
         ADD 1 TO EF-COUNT
         MOVE EF-COUNT TO WS-AT
     END-IF
     IF WS-AT > 0
         MOVE L-ID TO EF-ID(WS-AT)
         MOVE L-AMP TO EF-AMP(WS-AT)
         MOVE L-DUR TO EF-DUR(WS-AT)
         MOVE L-FLAGS TO EF-FLAGS(WS-AT)
     END-IF
     GOBACK.
 END PROGRAM EFFECT-SET.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CLIENT-EFFECT-REMOVE.
*> USING CLIENT-STATE, effect id: drops the entry (the later ones move up); an effect the player does not have is ignored.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLCONST.
 01 WS-I                   BINARY-LONG.
 01 WS-AT                  BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-ID                   BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-ID.
     MOVE 0 TO WS-AT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > EF-COUNT
         IF EF-ID(WS-I) = L-ID
             MOVE WS-I TO WS-AT
         END-IF
     END-PERFORM
     IF WS-AT > 0
         PERFORM VARYING WS-I FROM WS-AT BY 1 UNTIL WS-I >= EF-COUNT
             MOVE EF-ENTRY(WS-I + 1) TO EF-ENTRY(WS-I)
         END-PERFORM
         SUBTRACT 1 FROM EF-COUNT
     END-IF
     GOBACK.
 END PROGRAM CLIENT-EFFECT-REMOVE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. HUD-TICK.
*> USING CLIENT-STATE: one client tick (49 sections 2.5 and 5.1): the HUD tick count rises, the damage cooldown falls toward 0, and every effect's
*> remaining duration falls by one (an infinite one stays, none goes below 0; an effect at 0 stays listed until Remove Mob Effect).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-I                   BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 PROCEDURE DIVISION USING CLIENT-STATE.
     ADD 1 TO HB-TICK
     IF HB-COOLDOWN > 0
         SUBTRACT 1 FROM HB-COOLDOWN
     END-IF
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > EF-COUNT
         IF EF-DUR(WS-I) > 0
             SUBTRACT 1 FROM EF-DUR(WS-I)
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM HUD-TICK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EFFECT-COLOUR-CMP.
*> USING colour a, colour b, result (-1 a first, 0 equal, 1 b first): the colour compare of 49 section 2.3.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-CA                   BINARY-LONG.
 01 L-CB                   BINARY-LONG.
 01 L-RESULT               BINARY-LONG.
 PROCEDURE DIVISION USING L-CA L-CB L-RESULT.
     EVALUATE TRUE
         WHEN L-CA < L-CB
             MOVE -1 TO L-RESULT
         WHEN L-CA > L-CB
             MOVE 1 TO L-RESULT
     END-EVALUATE
     GOBACK.
 END PROGRAM EFFECT-COLOUR-CMP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EFFECT-COMPARE.
*> USING CLIENT-STATE, entry a, entry b, result (-1 a first, 0 equal, 1 b first): the natural order of 49 section 2.3. Rule A applies when both
*> durations are above 32147 or both effects are ambient: ambient (false first), then colour. Otherwise rule B: ambient, infinite (false first),
*> shorter duration first, then colour.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-BENEFICIAL          BINARY-LONG.
 01 WS-CA                  BINARY-LONG.
 01 WS-CB                  BINARY-LONG.
 01 WS-KEY                 PIC X(80).
 01 WS-KEY-LENGTH          BINARY-LONG.
 01 WS-NAME                PIC X(64).
 01 WS-NAME-LENGTH         BINARY-LONG.
 01 WS-AA                  BINARY-LONG.
 01 WS-AB                  BINARY-LONG.
 01 WS-IA                  BINARY-LONG.
 01 WS-IB                  BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-A                    BINARY-LONG.
 01 L-B                    BINARY-LONG.
 01 L-RESULT               BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-A L-B L-RESULT.
     MOVE 0 TO L-RESULT WS-AA WS-AB WS-IA WS-IB
     IF FUNCTION MOD(EF-FLAGS(L-A), 2) = 1
         MOVE 1 TO WS-AA
     END-IF
     IF FUNCTION MOD(EF-FLAGS(L-B), 2) = 1
         MOVE 1 TO WS-AB
     END-IF
     IF EF-DUR(L-A) = -1
         MOVE 1 TO WS-IA
     END-IF
     IF EF-DUR(L-B) = -1
         MOVE 1 TO WS-IB
     END-IF
     CALL "EFFECT-INFO" USING EF-ID(L-A) WS-BENEFICIAL WS-CA WS-KEY WS-KEY-LENGTH WS-NAME WS-NAME-LENGTH
     CALL "EFFECT-INFO" USING EF-ID(L-B) WS-BENEFICIAL WS-CB WS-KEY WS-KEY-LENGTH WS-NAME WS-NAME-LENGTH
     EVALUATE TRUE
         WHEN WS-AA < WS-AB
             MOVE -1 TO L-RESULT
         WHEN WS-AA > WS-AB
             MOVE 1 TO L-RESULT
         WHEN (EF-DUR(L-A) > 32147 AND EF-DUR(L-B) > 32147) OR WS-AA = 1
             CALL "EFFECT-COLOUR-CMP" USING WS-CA WS-CB L-RESULT
         WHEN WS-IA < WS-IB
             MOVE -1 TO L-RESULT
         WHEN WS-IA > WS-IB
             MOVE 1 TO L-RESULT
         WHEN EF-DUR(L-A) < EF-DUR(L-B)
             MOVE -1 TO L-RESULT
         WHEN EF-DUR(L-A) > EF-DUR(L-B)
             MOVE 1 TO L-RESULT
         WHEN OTHER
             CALL "EFFECT-COLOUR-CMP" USING WS-CA WS-CB L-RESULT
     END-EVALUATE
     GOBACK.
 END PROGRAM EFFECT-COMPARE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EFFECT-ORDER.
*> USING CLIENT-STATE, order (a group of 40 BINARY-LONG), count (out): the entry numbers in ascending natural order (a stable insertion sort).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-I                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-HOLD                BINARY-LONG.
 01 WS-RESULT              BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-ORDERS.
    05 L-ORDER             BINARY-LONG OCCURS 40 TIMES.
 01 L-COUNT                BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-ORDERS L-COUNT.
     MOVE EF-COUNT TO L-COUNT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > L-COUNT
         MOVE WS-I TO L-ORDER(WS-I)
     END-PERFORM
     PERFORM VARYING WS-I FROM 2 BY 1 UNTIL WS-I > L-COUNT
         MOVE L-ORDER(WS-I) TO WS-HOLD
         COMPUTE WS-J = WS-I - 1
         MOVE 1 TO WS-RESULT
         PERFORM UNTIL WS-J < 1 OR WS-RESULT <= 0
             CALL "EFFECT-COMPARE" USING CLIENT-STATE L-ORDER(WS-J) WS-HOLD WS-RESULT
             IF WS-RESULT > 0
                 MOVE L-ORDER(WS-J) TO L-ORDER(WS-J + 1)
                 SUBTRACT 1 FROM WS-J
             END-IF
         END-PERFORM
         MOVE WS-HOLD TO L-ORDER(WS-J + 1)
     END-PERFORM
     GOBACK.
 END PROGRAM EFFECT-ORDER.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EFFECT-ALPHA.
*> USING duration, ambient (1 = ambient), alpha (out, thousandths): 49 section 2.5. 1000 unless the effect is not ambient and finite with at most 200
*> ticks left; then clamp(base + swing, 0, 1) with base = min(0.5, 0.01 D) and swing = cos(D pi / 5) min(0.25, 0.025 k), k = 10 - D div 20.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-K                   BINARY-LONG.
 01 WS-Q                   BINARY-LONG.
 01 WS-BASE                FLOAT-LONG.
 01 WS-SWING               FLOAT-LONG.
 01 WS-A                   FLOAT-LONG.
 LINKAGE SECTION.
 01 L-DUR                  BINARY-LONG.
 01 L-AMBIENT              BINARY-LONG.
 01 L-ALPHA                BINARY-LONG.
 PROCEDURE DIVISION USING L-DUR L-AMBIENT L-ALPHA.
     MOVE 1000 TO L-ALPHA
     IF L-AMBIENT = 0 AND L-DUR >= 0 AND L-DUR <= 200
         COMPUTE WS-Q = L-DUR / 20
         COMPUTE WS-K = 10 - WS-Q
         COMPUTE WS-BASE = FUNCTION MIN(0.5, 0.01 * L-DUR)
         COMPUTE WS-SWING = FUNCTION COS(L-DUR * 3.14159265358979 / 5) * FUNCTION MIN(0.25, 0.025 * WS-K)
         COMPUTE WS-A = WS-BASE + WS-SWING
         IF WS-A < 0
             MOVE 0 TO WS-A
         END-IF
         COMPUTE L-ALPHA ROUNDED = WS-A * 1000
     END-IF
     GOBACK.
 END PROGRAM EFFECT-ALPHA.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EFFECT-NAME-TEXT.
*> USING CLIENT-STATE, effect id, amplifier, text (out, PIC X(64)), length: the display name (lang key effect.minecraft.<key>, else the English
*> name), then for an amplifier 1 to 9 a space and enchantment.level.<amplifier + 1> (49 section 3.3); amplifiers 0 and 10 and over add nothing.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-BENEFICIAL          BINARY-LONG.
 01 WS-COLOUR              BINARY-LONG.
 01 WS-KEY                 PIC X(80).
 01 WS-KEY-LENGTH          BINARY-LONG.
 01 WS-NAME                PIC X(64).
 01 WS-NAME-LENGTH         BINARY-LONG.
 01 WS-LANG-KEY            PIC X(80).
 01 WS-LANG-LENGTH         BINARY-LONG.
 01 WS-LANG-TEXT           PIC X(512).
 01 WS-LANG-TEXT-LENGTH    BINARY-LONG.
 01 WS-LEVEL               PIC Z9.
 01 WS-POINTER             BINARY-LONG.
 01 WS-ROMAN-DATA.
    05 FILLER              PIC X(4) VALUE "II  ".
    05 FILLER              PIC X(4) VALUE "III ".
    05 FILLER              PIC X(4) VALUE "IV  ".
    05 FILLER              PIC X(4) VALUE "V   ".
    05 FILLER              PIC X(4) VALUE "VI  ".
    05 FILLER              PIC X(4) VALUE "VII ".
    05 FILLER              PIC X(4) VALUE "VIII".
    05 FILLER              PIC X(4) VALUE "IX  ".
    05 FILLER              PIC X(4) VALUE "X   ".
 01 WS-ROMAN REDEFINES WS-ROMAN-DATA.
    05 WS-NUMERAL          PIC X(4) OCCURS 9 TIMES.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-ID                   BINARY-LONG.
 01 L-AMP                  BINARY-LONG.
 01 L-TEXT                 PIC X(64).
 01 L-LENGTH               BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-ID L-AMP L-TEXT L-LENGTH.
     CALL "EFFECT-INFO" USING L-ID WS-BENEFICIAL WS-COLOUR WS-KEY WS-KEY-LENGTH WS-NAME WS-NAME-LENGTH
     MOVE SPACES TO WS-LANG-KEY
     STRING "effect.minecraft." WS-KEY(1:WS-KEY-LENGTH) DELIMITED BY SIZE INTO WS-LANG-KEY
     COMPUTE WS-LANG-LENGTH = 17 + WS-KEY-LENGTH
     CALL "LANG-GET" USING CLIENT-STATE WS-LANG-KEY WS-LANG-LENGTH WS-LANG-TEXT WS-LANG-TEXT-LENGTH
     MOVE SPACES TO L-TEXT
     IF WS-LANG-TEXT(1:WS-LANG-TEXT-LENGTH) = WS-LANG-KEY(1:WS-LANG-LENGTH)
         MOVE WS-NAME(1:WS-NAME-LENGTH) TO L-TEXT
         MOVE WS-NAME-LENGTH TO L-LENGTH
     ELSE
         MOVE FUNCTION MIN(WS-LANG-TEXT-LENGTH, 40) TO L-LENGTH
         MOVE WS-LANG-TEXT(1:L-LENGTH) TO L-TEXT
     END-IF
     IF L-AMP >= 1 AND L-AMP <= 9
         COMPUTE WS-LEVEL = L-AMP + 1
         MOVE SPACES TO WS-LANG-KEY
         STRING "enchantment.level." FUNCTION TRIM(WS-LEVEL) DELIMITED BY SIZE INTO WS-LANG-KEY
         COMPUTE WS-LANG-LENGTH = 18 + FUNCTION LENGTH(FUNCTION TRIM(WS-LEVEL))
         CALL "LANG-GET" USING CLIENT-STATE WS-LANG-KEY WS-LANG-LENGTH WS-LANG-TEXT WS-LANG-TEXT-LENGTH
         IF WS-LANG-TEXT(1:WS-LANG-TEXT-LENGTH) = WS-LANG-KEY(1:WS-LANG-LENGTH)
             MOVE WS-NUMERAL(L-AMP) TO WS-LANG-TEXT
             MOVE FUNCTION LENGTH(FUNCTION TRIM(WS-NUMERAL(L-AMP))) TO WS-LANG-TEXT-LENGTH
         END-IF
         COMPUTE WS-POINTER = L-LENGTH + 1
         STRING " " WS-LANG-TEXT(1:WS-LANG-TEXT-LENGTH) DELIMITED BY SIZE INTO L-TEXT WITH POINTER WS-POINTER
         COMPUTE L-LENGTH = WS-POINTER - 1
     END-IF
     GOBACK.
 END PROGRAM EFFECT-NAME-TEXT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EFFECT-DURATION-TEXT.
*> USING CLIENT-STATE, duration (ticks, -1 infinite), text (out, PIC X(64)), length: effect.duration.infinite (English "∞") for an infinite effect,
*> else seconds = floor(ticks / 20) as "mm:ss", or "hh:mm:ss" from one hour (49 section 3.4).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-S                   BINARY-LONG.
 01 WS-M                   BINARY-LONG.
 01 WS-H                   BINARY-LONG.
 01 WS-HH                  PIC 99.
 01 WS-MM                  PIC 99.
 01 WS-SS                  PIC 99.
 01 WS-LANG-KEY            PIC X(80) VALUE "effect.duration.infinite".
 01 WS-LANG-LENGTH         BINARY-LONG VALUE 24.
 01 WS-LANG-TEXT           PIC X(512).
 01 WS-LANG-TEXT-LENGTH    BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-DUR                  BINARY-LONG.
 01 L-TEXT                 PIC X(64).
 01 L-LENGTH               BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-DUR L-TEXT L-LENGTH.
     MOVE SPACES TO L-TEXT
     IF L-DUR < 0
         CALL "LANG-GET" USING CLIENT-STATE WS-LANG-KEY WS-LANG-LENGTH WS-LANG-TEXT WS-LANG-TEXT-LENGTH
         IF WS-LANG-TEXT(1:WS-LANG-TEXT-LENGTH) = WS-LANG-KEY(1:WS-LANG-LENGTH)
             MOVE X"E288" TO WS-LANG-TEXT
             MOVE X"9E" TO WS-LANG-TEXT(3:1)
             MOVE 3 TO WS-LANG-TEXT-LENGTH
         END-IF
         MOVE FUNCTION MIN(WS-LANG-TEXT-LENGTH, 64) TO L-LENGTH
         MOVE WS-LANG-TEXT(1:L-LENGTH) TO L-TEXT
         GOBACK
     END-IF
     COMPUTE WS-S = L-DUR / 20
     COMPUTE WS-M = WS-S / 60
     COMPUTE WS-S = WS-S - WS-M * 60
     COMPUTE WS-H = WS-M / 60
     COMPUTE WS-M = WS-M - WS-H * 60
     MOVE WS-S TO WS-SS
     MOVE WS-M TO WS-MM
     IF WS-H > 0
         MOVE FUNCTION MOD(WS-H, 100) TO WS-HH
         STRING WS-HH ":" WS-MM ":" WS-SS DELIMITED BY SIZE INTO L-TEXT
         MOVE 8 TO L-LENGTH
     ELSE
         STRING WS-MM ":" WS-SS DELIMITED BY SIZE INTO L-TEXT
         MOVE 5 TO L-LENGTH
     END-IF
     GOBACK.
 END PROGRAM EFFECT-DURATION-TEXT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EFFECTS-HUD-ADD.
*> USING CLIENT-STATE, GUI width, GUI height: the status-effect icons of the world HUD (49 sections 2.1 to 2.5). Effects with the show-icon flag
*> (0x04), in descending natural order; the beneficial ones form a row at y 1, the others a row at y 27, each icon 24 x 24 at x = W - 25 b
*> (b counting the row's icons from 1) on the background sprite (the ambient one for an ambient effect) with the 18 x 18 icon at (x + 3, y + 3);
*> the icon's alpha is the widget state (0 opaque, else thousandths + 1; EFFECT-ALPHA).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLCONST.
 01 WS-ORDERS.
    05 WS-ORDER            BINARY-LONG OCCURS 40 TIMES.
 01 WS-N                   BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-E                   BINARY-LONG.
 01 WS-B                   BINARY-LONG.
 01 WS-H                   BINARY-LONG.
 01 WS-BENEFICIAL          BINARY-LONG.
 01 WS-COLOUR              BINARY-LONG.
 01 WS-KEY                 PIC X(80).
 01 WS-KEY-LENGTH          BINARY-LONG.
 01 WS-NAME                PIC X(64).
 01 WS-NAME-LENGTH         BINARY-LONG.
 01 WS-AMBIENT             BINARY-LONG.
 01 WS-ALPHA               BINARY-LONG.
 01 WS-KIND                BINARY-LONG VALUE WK-SPRITE.
 01 WS-ACTION              BINARY-LONG VALUE 0.
 01 WS-ARG                 BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-24                  BINARY-LONG VALUE 24.
 01 WS-24B                 BINARY-LONG VALUE 24.
 01 WS-18                  BINARY-LONG VALUE 18.
 01 WS-18B                 BINARY-LONG VALUE 18.
 01 WS-STATE               BINARY-LONG.
 01 WS-STATE0              BINARY-LONG VALUE 0.
 01 WS-LENGTH              BINARY-LONG VALUE 0.
 01 WS-TEXT                PIC X(512).
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-GW                   BINARY-LONG.
 01 L-GH                   BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-GW L-GH.
     IF EF-COUNT = 0
         GOBACK
     END-IF
     CALL "EFFECT-ORDER" USING CLIENT-STATE WS-ORDERS WS-N
     MOVE 0 TO WS-B WS-H
     MOVE SPACES TO WS-TEXT
     PERFORM VARYING WS-I FROM WS-N BY -1 UNTIL WS-I < 1
         MOVE WS-ORDER(WS-I) TO WS-E
         IF FUNCTION MOD(FUNCTION INTEGER(EF-FLAGS(WS-E) / 4), 2) = 1
             CALL "EFFECT-INFO" USING EF-ID(WS-E) WS-BENEFICIAL WS-COLOUR WS-KEY WS-KEY-LENGTH WS-NAME
                 WS-NAME-LENGTH
             IF WS-BENEFICIAL = 1
                 ADD 1 TO WS-B
                 COMPUTE WS-X = L-GW - 25 * WS-B
                 MOVE 1 TO WS-Y
             ELSE
                 ADD 1 TO WS-H
                 COMPUTE WS-X = L-GW - 25 * WS-H
                 MOVE 27 TO WS-Y
             END-IF
             MOVE FUNCTION MOD(EF-FLAGS(WS-E), 2) TO WS-AMBIENT
             MOVE GSP-EFFECT-BG TO WS-ARG
             IF WS-AMBIENT = 1
                 MOVE GSP-EFFECT-BG-AMBIENT TO WS-ARG
             END-IF
             CALL "WIDGET-ADD" USING CLIENT-STATE WS-KIND WS-ACTION WS-ARG WS-X WS-Y WS-24 WS-24B
                 WS-TEXT WS-LENGTH WS-STATE0
             CALL "EFFECT-ALPHA" USING EF-DUR(WS-E) WS-AMBIENT WS-ALPHA
             MOVE 0 TO WS-STATE
             IF WS-ALPHA < 1000
                 COMPUTE WS-STATE = WS-ALPHA + 1
             END-IF
             COMPUTE WS-ARG = GSP-MOB-EFFECT-0 + EF-ID(WS-E)
             ADD 3 TO WS-X WS-Y
             CALL "WIDGET-ADD" USING CLIENT-STATE WS-KIND WS-ACTION WS-ARG WS-X WS-Y WS-18 WS-18B
                 WS-TEXT WS-LENGTH WS-STATE
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM EFFECTS-HUD-ADD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EFFECTS-PANEL-ADD.
*> USING CLIENT-STATE, GUI width, left (the screen's leftPos), top, can see (out 1/0): the effects panel of the survival inventory screen (49 section 3).
*> x0 = left + 178; avail = width - x0; can see is avail >= 32 (the screen's showsActiveEffects: it also switches the world HUD's icons off). With
*> effects and room, every effect (show-icon flag or not) is a row in ascending natural order: stride 33, or 132 div (count - 1) from 6 effects; the
*> row is the nine-slice background (32 high, bw = min(row width, max(32 + name, 32 + duration) + 7) wide; the row width is avail - 7 from 120, else 32),
*> the icon at (x0 + 7, y + 7), and, when bw leaves text room (bw - 39 > 0), the name (clipped to that room) at (x0 + 32, y + 7) and the duration at
*> (x0 + 32, y + 16). The duration is drawn in its grey (#808080, as the grey luminance); the tooltip of a compact or clipped row is not drawn.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLCONST.
 01 WS-ORDERS.
    05 WS-ORDER            BINARY-LONG OCCURS 40 TIMES.
 01 WS-N                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-E                   BINARY-LONG.
 01 WS-X0                  BINARY-LONG.
 01 WS-AVAIL               BINARY-LONG.
 01 WS-RW                  BINARY-LONG.
 01 WS-STRIDE              BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-BW                  BINARY-LONG.
 01 WS-GREY                BINARY-LONG.
 01 WS-NAME                PIC X(64).
 01 WS-NAME-LENGTH         BINARY-LONG.
 01 WS-DURATION            PIC X(64).
 01 WS-DURATION-LENGTH     BINARY-LONG.
 01 WS-TEXT                PIC X(512).
 01 WS-TEXT2               PIC X(256).
 01 WS-NAME-WIDTH          BINARY-LONG.
 01 WS-DUR-WIDTH           BINARY-LONG.
 01 WS-ROOM                BINARY-LONG.
 01 WS-KIND                BINARY-LONG.
 01 WS-ACTION              BINARY-LONG VALUE 0.
 01 WS-ARG                 BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-W                   BINARY-LONG.
 01 WS-H                   BINARY-LONG.
 01 WS-STATE               BINARY-LONG VALUE 0.
 01 WS-LENGTH              BINARY-LONG.
 01 WS-NO-TEXT             PIC X(512).
 01 WS-ZERO                BINARY-LONG VALUE 0.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-GW                   BINARY-LONG.
 01 L-LEFT                 BINARY-LONG.
 01 L-TOP                  BINARY-LONG.
 01 L-SEE                  BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-GW L-LEFT L-TOP L-SEE.
     COMPUTE WS-X0 = L-LEFT + 178
     COMPUTE WS-AVAIL = L-GW - WS-X0
     MOVE 0 TO L-SEE
     IF WS-AVAIL >= 32
         MOVE 1 TO L-SEE
     END-IF
     IF L-SEE = 0 OR EF-COUNT = 0
         GOBACK
     END-IF
     MOVE 32 TO WS-RW
     IF WS-AVAIL >= 120
         COMPUTE WS-RW = WS-AVAIL - 7
     END-IF
     MOVE 33 TO WS-STRIDE
     IF EF-COUNT > 5
         COMPUTE WS-STRIDE = 132 / (EF-COUNT - 1)
     END-IF
     MOVE SPACES TO WS-NO-TEXT
     CALL "EFFECT-ORDER" USING CLIENT-STATE WS-ORDERS WS-N
     PERFORM VARYING WS-J FROM 0 BY 1 UNTIL WS-J >= WS-N
         MOVE WS-ORDER(WS-J + 1) TO WS-E
         COMPUTE WS-Y = L-TOP + WS-J * WS-STRIDE
         CALL "EFFECT-NAME-TEXT" USING CLIENT-STATE EF-ID(WS-E) EF-AMP(WS-E) WS-NAME WS-NAME-LENGTH
         CALL "EFFECT-DURATION-TEXT" USING CLIENT-STATE EF-DUR(WS-E) WS-DURATION WS-DURATION-LENGTH
         MOVE WS-NAME TO WS-TEXT2
         CALL "UI-TEXT-WIDTH" USING CLIENT-STATE WS-TEXT2 WS-NAME-LENGTH WS-NAME-WIDTH
         MOVE WS-DURATION TO WS-TEXT2
         CALL "UI-TEXT-WIDTH" USING CLIENT-STATE WS-TEXT2 WS-DURATION-LENGTH WS-DUR-WIDTH
         COMPUTE WS-BW = FUNCTION MIN(WS-RW, FUNCTION MAX(32 + WS-NAME-WIDTH, 32 + WS-DUR-WIDTH) + 7)
         MOVE WK-SPRITE TO WS-KIND
         MOVE GSP-INV-EFFECT-BG TO WS-ARG
         IF FUNCTION MOD(EF-FLAGS(WS-E), 2) = 1
             MOVE GSP-INV-EFFECT-BG-AMBIENT TO WS-ARG
         END-IF
         MOVE 32 TO WS-H
         MOVE 0 TO WS-LENGTH
         CALL "WIDGET-ADD" USING CLIENT-STATE WS-KIND WS-ACTION WS-ARG WS-X0 WS-Y WS-BW WS-H
             WS-NO-TEXT WS-LENGTH WS-STATE
         COMPUTE WS-ARG = GSP-MOB-EFFECT-0 + EF-ID(WS-E)
         COMPUTE WS-X = WS-X0 + 7
         COMPUTE WS-Y = WS-Y + 7
         MOVE 18 TO WS-W WS-H
         CALL "WIDGET-ADD" USING CLIENT-STATE WS-KIND WS-ACTION WS-ARG WS-X WS-Y WS-W WS-H
             WS-NO-TEXT WS-LENGTH WS-STATE
         COMPUTE WS-ROOM = WS-BW - 39
         IF WS-ROOM > 0
             PERFORM UNTIL WS-NAME-WIDTH <= WS-ROOM OR WS-NAME-LENGTH <= 1
                 SUBTRACT 1 FROM WS-NAME-LENGTH
                 MOVE WS-NAME TO WS-TEXT2
                 CALL "UI-TEXT-WIDTH" USING CLIENT-STATE WS-TEXT2 WS-NAME-LENGTH WS-NAME-WIDTH
             END-PERFORM
             MOVE WK-LABEL TO WS-KIND
             MOVE 0 TO WS-ARG
             COMPUTE WS-X = WS-X0 + 32
             MOVE WS-ROOM TO WS-W
             MOVE 9 TO WS-H
             MOVE SPACES TO WS-TEXT
             MOVE WS-NAME(1:WS-NAME-LENGTH) TO WS-TEXT
             CALL "WIDGET-ADD" USING CLIENT-STATE WS-KIND WS-ACTION WS-ARG WS-X WS-Y WS-W WS-H
                 WS-TEXT WS-NAME-LENGTH WS-STATE
             COMPUTE WS-Y = WS-Y + 9
             MOVE SPACES TO WS-TEXT
             MOVE WS-DURATION(1:WS-DURATION-LENGTH) TO WS-TEXT
             CALL "WIDGET-ADD" USING CLIENT-STATE WS-KIND WS-ACTION WS-ARG WS-X WS-Y WS-W WS-H
                 WS-TEXT WS-DURATION-LENGTH WS-STATE
*>           The duration is #808080 (49 section 3.3).
             MOVE 8355712 TO WS-GREY
             CALL "WIDGET-COLOUR" USING CLIENT-STATE WS-GREY
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM EFFECTS-PANEL-ADD.
