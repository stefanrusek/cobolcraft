*> The level random (core/src/worldsim-33e.cob): the java.util.Random generator of the artifact (a 48-bit linear congruential generator, multiplier 0x5DEECE66D, increment 0xB) kept as two 24-bit
*> halves of its seed, so that every product fits 64 bits. LR-READY is 0 until the seed is set (LEVEL-RANDOM-SEED, or from the world seed on first use).
 01 LEVEL-RANDOM-STATE EXTERNAL.
    05 LR-READY                  BINARY-LONG.
    05 LR-HI                     BINARY-DOUBLE.
    05 LR-LO                     BINARY-DOUBLE.
