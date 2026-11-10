*> Entity models part 1 section 5 (keyframe animation engine): an animation definition as client/src/entmodel-34-1-anim.cob reads it. A channel animates
*> one bone with one target (1 position, 2 rotation, 3 scale); keyframes are sorted by timestamp (the engine does not sort). AK-INTERP: 1 linear, 2 Catmull-Rom.
 01 EM5-DEF.
    05 AD-LENGTH           FLOAT-LONG.
    05 AD-LOOP             BINARY-LONG.
    05 AD-CHANNELS         BINARY-LONG.
    05 AD-CHANNEL OCCURS 24 TIMES.
       10 AC-BONE          PIC X(24).
       10 AC-TARGET        BINARY-LONG.
       10 AC-KEYS          BINARY-LONG.
       10 AC-KEY OCCURS 40 TIMES.
          15 AK-TS         FLOAT-LONG.
          15 AK-PRE        FLOAT-LONG OCCURS 3 TIMES.
          15 AK-POST       FLOAT-LONG OCCURS 3 TIMES.
          15 AK-INTERP     BINARY-LONG.
