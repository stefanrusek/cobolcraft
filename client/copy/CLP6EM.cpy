*> Emission record of the part 6 block emitters (42-6 sections 3 to 5): the draws go in, the emitted particles come out.
*>   EM-DRAW(1..512): the caller's random draws in the order the section documents: nextFloat/nextDouble in [0, 1), a
*>     nextInt(n) as r (the program takes floor(r * n)), a nextBoolean as r (true when r >= 0.5), a nextGaussian as its value.
*>   EM-CUR: draws consumed (reset to 0 by the entry point); EM-COUNT: particles emitted, rows EM-ROW(1..EM-COUNT):
*>     EM-NAME particle type, EM-X..EM-VZ position and velocity, EM-COLOR (ARGB or RGB24 option colour, 0 none),
*>     EM-SCALE (option scale, 0 none), EM-STATE (block state option, 0 none);
*>   EM-SOUND(1..EM-SOUND-COUNT): the sound events (names only) the sampler also starts.
 01 P6-EMITS.
    05 EM-COUNT            BINARY-LONG.
    05 EM-CUR              BINARY-LONG.
    05 EM-SOUND-COUNT      BINARY-LONG.
    05 EM-SOUND            PIC X(40) OCCURS 8 TIMES.
    05 EM-DRAW             FLOAT-LONG OCCURS 512 TIMES.
    05 EM-ROW OCCURS 128 TIMES.
       10 EM-NAME          PIC X(40).
       10 EM-X             FLOAT-LONG.
       10 EM-Y             FLOAT-LONG.
       10 EM-Z             FLOAT-LONG.
       10 EM-VX            FLOAT-LONG.
       10 EM-VY            FLOAT-LONG.
       10 EM-VZ            FLOAT-LONG.
       10 EM-COLOR         BINARY-DOUBLE.
       10 EM-SCALE         FLOAT-LONG.
       10 EM-STATE         BINARY-LONG.
