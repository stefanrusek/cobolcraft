*> Weather (standin-content §14; data-model §9; docs/protocol/09-cobolcraft-profile.md §3.3 weather
*> values), transcribed. Tested by core/tests/test_content_tables.cob. Index the kind table by kind
*> number (WK-CLEAR 1, WK-DRIZZLE 2, WK-HAILSTORM 3, §14.1 table order).
*> Where weather applies (§14.2): a dimension with DM-WEATHER 1 (DIMENSIONS.cpy), in the biomes with
*> has_precipitation 1 (REGISTRY.cpy RB-PRECIPITATION). A dimension without weather is always sent
*> the clear sequence.
 78 WEATHER-KIND-COUNT        VALUE 3.
 78 WK-CLEAR                  VALUE 1.
 78 WK-DRIZZLE                VALUE 2.
 78 WK-HAILSTORM              VALUE 3.
*> How the weather changes (§14.3): a new world starts clear with 6000 remaining ticks; -1 means
*> "until changed" (no countdown). At 0, with r = H(d, Time): after clear the next kind is drizzle
*> when r mod 100 < 70, otherwise hailstorm; after drizzle or hailstorm it is clear; the remaining
*> time becomes the next kind's base + ((r div 100) mod span) (WK-DURATION-BASE, -SPAN).
 78 WEATHER-START-KIND        VALUE 1.
 78 WEATHER-START-TICKS       VALUE 6000.
 78 WEATHER-UNTIL-CHANGED     VALUE -1.
 78 WEATHER-DRIZZLE-CHANCE    VALUE 70.
 78 WEATHER-CHANCE-RANGE      VALUE 100.
*> On the wire (§14.4): Game Event 1 START_RAINING (value 0.0) when the kind's rain level is above
*> 0, otherwise 2 STOP_RAINING (0.0); then 7 RAIN_LEVEL_CHANGE with the rain level and 8
*> THUNDER_LEVEL_CHANGE with the thunder level.
 78 WEATHER-EVENT-START       VALUE 1.
 78 WEATHER-EVENT-STOP        VALUE 2.
 78 WEATHER-EVENT-RAIN        VALUE 7.
 78 WEATHER-EVENT-THUNDER     VALUE 8.
*> Gameplay effects (§14.6): hail strikes on every tick with Time mod 80 = 0; its damage is
*> RULES.cpy RULE-CAUSE-AMOUNT(CAUSE-HAIL) of cause cobolcraft:hail (§10.3).
 78 WEATHER-HAIL-INTERVAL     VALUE 80.
 78 WEATHER-EFFECT-NONE       VALUE 0.
 78 WEATHER-EFFECT-HAIL       VALUE 1.
*> Kinds (§14.1): key, English name, rain and thunder level in THOUSANDTHS, gameplay effect,
*> duration base and span in ticks (§14.3: clear 6000 + 0..6000, drizzle 2400 + 0..2400, hailstorm
*> 1200 + 0..1200).
 01 WEATHER-KIND-DATA.
    05 FILLER.                                  *> 1: cobolcraft:clear
       10 FILLER PIC X(32) VALUE "cobolcraft:clear".
       10 FILLER BINARY-LONG VALUE 16.
       10 FILLER PIC X(16) VALUE "Clear".
       10 FILLER BINARY-LONG VALUE 0.
       10 FILLER BINARY-LONG VALUE 0.
       10 FILLER BINARY-LONG VALUE 0.
       10 FILLER BINARY-LONG VALUE 6000.
       10 FILLER BINARY-LONG VALUE 6001.
    05 FILLER.                                  *> 2: cobolcraft:drizzle
       10 FILLER PIC X(32) VALUE "cobolcraft:drizzle".
       10 FILLER BINARY-LONG VALUE 18.
       10 FILLER PIC X(16) VALUE "Drizzle".
       10 FILLER BINARY-LONG VALUE 1000.
       10 FILLER BINARY-LONG VALUE 0.
       10 FILLER BINARY-LONG VALUE 0.
       10 FILLER BINARY-LONG VALUE 2400.
       10 FILLER BINARY-LONG VALUE 2401.
    05 FILLER.                                  *> 3: cobolcraft:hailstorm
       10 FILLER PIC X(32) VALUE "cobolcraft:hailstorm".
       10 FILLER BINARY-LONG VALUE 20.
       10 FILLER PIC X(16) VALUE "Hailstorm".
       10 FILLER BINARY-LONG VALUE 1000.
       10 FILLER BINARY-LONG VALUE 1000.
       10 FILLER BINARY-LONG VALUE 1.
       10 FILLER BINARY-LONG VALUE 1200.
       10 FILLER BINARY-LONG VALUE 1201.
 01 WEATHER-KIND-TABLE REDEFINES WEATHER-KIND-DATA.
    05 WK-ENTRY OCCURS 3 TIMES.
       10 WK-KEY                PIC X(32).
       10 WK-KEY-LENGTH         BINARY-LONG.
       10 WK-NAME               PIC X(16).
       10 WK-RAIN-MILLI         BINARY-LONG.
       10 WK-THUNDER-MILLI      BINARY-LONG.
       10 WK-EFFECT             BINARY-LONG.
       10 WK-DURATION-BASE      BINARY-LONG.
       10 WK-DURATION-SPAN      BINARY-LONG.
