*> The named and the noise based block state providers of the feature stage (docs/protocol/35-worldgen-features-2 sections 4.1 and 5).
*>
*> A provider written as a string names an element of worldgen/block_state_provider (FD-PROV-NAMED reads and compiles it in a document of its own, so a named provider may name
*> another one; nesting beyond four levels, which only a provider that names itself reaches, is refused). The noise, dual_noise and noise_threshold providers (PV-TYPE 6, 7, 8) hold
*> NormalNoise stacks seeded from a LegacyRandomSource (5.2): the stacks live in the noise store of core/src/noise.cob, NOISE-CREATE-LEGACY adds one.
*>
*> Supported: one octave (octave_count 1), normalize enabled (the default), no amplitude modifiers, as the data pack writes them; anything else sets FD-BAD. The seed is read as a
*> JSON number, so it is exact below 2^53 (the pack's seeds are 2345).
*>
*> Entry points:
*>   FP-HASH USING text (PIC X(64)), length, hash out (BINARY-LONG): the 32 bit Java String.hashCode of the first length characters
*>   PERLIN-CREATE-LEGACY USING state (u64, the 48 bit seed of the legacy source), index out: PerlinNoise(r) of 10 section 3.1 over a legacy random source (row of the noise store)
*>   NOISE-CREATE-LEGACY USING seed (u64), base octave, base amplitude (FLOAT-LONG), handle out: NormalNoise.create of 5.2 for one octave
*>   FP-NOISE-AT USING handle, scale (FLOAT-LONG, a float widened), mode (0 the coordinates times the scale in double, 1 in float), x, y, z, value out (FLOAT-LONG, a float32 value)
*>   FP-INDEX USING value (FLOAT-LONG), size, index out: the index formula of 5.4
*>   FD-PROV-NAMED USING key (PIC X(80)), provider row out (0 and FD-BAD when absent or refused)
*>   FD-PROV-NOISE USING doc, provider object node, provider row, kind (6, 7 or 8): compiles the fields of a noise provider (FD-BAD when it cannot be placed whole)
*>   FR-PROV-NOISE USING state (XR-STATE), provider row, x, y, z, block state out: the state of a noise provider at a position (its draws are the ones of 5.6)

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FP-HASH.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-H                   BINARY-DOUBLE.
 01 WS-I                   BINARY-LONG.
 01 WS-C                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-TEXT                 PIC X(64).
 01 L-LENGTH               BINARY-LONG.
 01 L-HASH                 BINARY-LONG.
 PROCEDURE DIVISION USING L-TEXT L-LENGTH L-HASH.
     MOVE 0 TO WS-H
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > L-LENGTH
         COMPUTE WS-C = FUNCTION ORD(L-TEXT(WS-I:1)) - 1
         COMPUTE WS-H = FUNCTION MOD(WS-H * 31 + WS-C, 4294967296)
     END-PERFORM
     IF WS-H >= 2147483648
         SUBTRACT 4294967296 FROM WS-H
     END-IF
     MOVE WS-H TO L-HASH
     GOBACK.
 END PROGRAM FP-HASH.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PERLIN-CREATE-LEGACY.
*> 10 section 3.1 construction over java.util.Random: three offset draws (nextDouble * 256: (next(26) << 27 + next(27)) * 2^-53), then the shuffle of 0..255.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY NOISE.
 01 WS-HI                  BINARY-DOUBLE.
 01 WS-LO                  BINARY-DOUBLE.
 01 WS-BITS                BINARY-LONG.
 01 WS-D                   FLOAT-LONG.
 01 WS-U                   FLOAT-LONG.
 01 WS-T                   FLOAT-LONG.
 01 WS-256                 FLOAT-LONG VALUE 256.
 01 WS-UNIT-TEXT           PIC X(32) VALUE Z"1.1102230246251565E-16".
 01 WS-UNIT                FLOAT-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-BOUND               BINARY-LONG.
 01 WS-TARGET              BINARY-LONG.
 01 WS-SWAP                BINARY-SHORT UNSIGNED.
 LINKAGE SECTION.
 01 L-STATE                BINARY-DOUBLE UNSIGNED.
 01 L-INDEX                BINARY-LONG.
 PROCEDURE DIVISION USING L-STATE L-INDEX.
     CALL STATIC "cc_f64_from_text" USING BY REFERENCE WS-UNIT-TEXT WS-UNIT
     ADD 1 TO NZ-PERLIN-COUNT
     MOVE NZ-PERLIN-COUNT TO L-INDEX
     MOVE 0 TO NZ-FUDGE(L-INDEX)
     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 3
         MOVE 26 TO WS-BITS
         CALL "JRAND-NEXT" USING L-STATE WS-BITS WS-HI
         MOVE 27 TO WS-BITS
         CALL "JRAND-NEXT" USING L-STATE WS-BITS WS-LO
         COMPUTE WS-D = WS-HI * 134217728 + WS-LO
         CALL STATIC "cc_f64_mul" USING BY REFERENCE WS-D WS-UNIT WS-U
         CALL STATIC "cc_f64_mul" USING BY REFERENCE WS-U WS-256 WS-T
         EVALUATE WS-K
             WHEN 1
                 MOVE WS-T TO NZ-OX(L-INDEX)
             WHEN 2
                 MOVE WS-T TO NZ-OY(L-INDEX)
             WHEN OTHER
                 MOVE WS-T TO NZ-OZ(L-INDEX)
         END-EVALUATE
     END-PERFORM
     PERFORM VARYING WS-I FROM 0 BY 1 UNTIL WS-I > 255
         COMPUTE NZ-PERM(L-INDEX, WS-I + 1) = WS-I
     END-PERFORM
     PERFORM VARYING WS-I FROM 0 BY 1 UNTIL WS-I > 255
         COMPUTE WS-BOUND = 256 - WS-I
         CALL "JRAND-NEXT-INT-BOUND" USING L-STATE WS-BOUND WS-J
         COMPUTE WS-TARGET = WS-I + WS-J + 1
         MOVE NZ-PERM(L-INDEX, WS-I + 1) TO WS-SWAP
         MOVE NZ-PERM(L-INDEX, WS-TARGET) TO NZ-PERM(L-INDEX, WS-I + 1)
         MOVE WS-SWAP TO NZ-PERM(L-INDEX, WS-TARGET)
     END-PERFORM
     GOBACK.
 END PROGRAM PERLIN-CREATE-LEGACY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. NOISE-CREATE-LEGACY.
*> 5.2 for one octave: kA and kB are the first two nextLong of the source of the seed; octave "octave_<base>" of each factory has the source seeded with hash xor key; the layer
*> amplitude is (float)(nf * amplitude) with nf = (amplitude / 3) / (0.2702247831245211 * amplitude * sqrt 2), the second layer is 1.0181268882175227 times faster.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY NOISE.
 01 WS-M64                 PIC 9(20) VALUE 18446744073709551616.
 01 WS-SOURCE              BINARY-DOUBLE UNSIGNED.
 01 WS-KA                  BINARY-DOUBLE UNSIGNED.
 01 WS-KB                  BINARY-DOUBLE UNSIGNED.
 01 WS-SEEDBITS            BINARY-DOUBLE UNSIGNED.
 01 WS-KEY                 BINARY-DOUBLE UNSIGNED.
 01 WS-BIG                 PIC 9(20).
 01 WS-HASH                BINARY-LONG.
 01 WS-NAME                PIC X(64).
 01 WS-INDEX-EDIT          PIC -(9)9.
 01 WS-LEN                 BINARY-LONG.
 01 WS-PA                  BINARY-LONG.
 01 WS-PB                  BINARY-LONG.
 01 WS-ONE                 FLOAT-LONG VALUE 1.
 01 WS-TWO                 FLOAT-LONG VALUE 2.
 01 WS-HALF                FLOAT-LONG VALUE 0.5.
 01 WS-FREQ                FLOAT-LONG.
 01 WS-T                   FLOAT-LONG.
 01 WS-U                   FLOAT-LONG.
 01 WS-T2                  FLOAT-LONG.
 01 WS-SQ                  FLOAT-LONG.
 01 WS-DEV                 FLOAT-LONG.
 01 WS-NF                  FLOAT-LONG.
 01 WS-LAYER-AMP           FLOAT-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-DEV-TEXT            PIC X(32) VALUE Z"0.2702247831245211".
 01 WS-SECOND-TEXT         PIC X(32) VALUE Z"1.0181268882175227".
 01 WS-THIRD-TEXT          PIC X(32) VALUE Z"0.3333333333333333".
 01 WS-DEV-UNIT            FLOAT-LONG.
 01 WS-SECOND              FLOAT-LONG.
 01 WS-THIRD               FLOAT-LONG.
 01 WS-PASS                BINARY-LONG.
 LINKAGE SECTION.
 01 L-SEED                 BINARY-DOUBLE UNSIGNED.
 01 L-BASE                 BINARY-LONG.
 01 L-AMP                  FLOAT-LONG.
 01 L-HANDLE               BINARY-LONG.
 PROCEDURE DIVISION USING L-SEED L-BASE L-AMP L-HANDLE.
     CALL STATIC "cc_f64_from_text" USING BY REFERENCE WS-DEV-TEXT WS-DEV-UNIT
     CALL STATIC "cc_f64_from_text" USING BY REFERENCE WS-SECOND-TEXT WS-SECOND
     CALL STATIC "cc_f64_from_text" USING BY REFERENCE WS-THIRD-TEXT WS-THIRD
*>   the frequency 2^base
     MOVE WS-ONE TO WS-FREQ
     IF L-BASE < 0
         COMPUTE WS-N = 0 - L-BASE
         PERFORM WS-N TIMES
             CALL STATIC "cc_f64_mul" USING BY REFERENCE WS-FREQ WS-HALF WS-T
             MOVE WS-T TO WS-FREQ
         END-PERFORM
     ELSE
         PERFORM L-BASE TIMES
             CALL STATIC "cc_f64_mul" USING BY REFERENCE WS-FREQ WS-TWO WS-T
             MOVE WS-T TO WS-FREQ
         END-PERFORM
     END-IF
*>   the normalisation factor of one octave: (amp * 1/3) / (sqrt((0.2702247831245211 * |amp|)^2) * sqrt 2)
     CALL STATIC "cc_f64_abs_f64" USING BY REFERENCE L-AMP WS-U
     CALL STATIC "cc_f64_mul" USING BY REFERENCE WS-DEV-UNIT WS-U WS-T
     MOVE WS-T TO WS-T2
     CALL STATIC "cc_f64_mul" USING BY REFERENCE WS-T WS-T2 WS-SQ
     CALL STATIC "cc_f64_sqrt" USING BY REFERENCE WS-SQ WS-DEV
     CALL STATIC "cc_f64_sqrt" USING BY REFERENCE WS-TWO WS-T
     CALL STATIC "cc_f64_mul" USING BY REFERENCE WS-DEV WS-T WS-U
     CALL STATIC "cc_f64_mul" USING BY REFERENCE L-AMP WS-THIRD WS-T
     CALL STATIC "cc_f64_div" USING BY REFERENCE WS-T WS-U WS-NF
*>   the two keys: the first two nextLong of the wrapped source
     CALL "JRAND-SET-SEED" USING WS-SOURCE L-SEED
     CALL "JRAND-NEXT-LONG" USING WS-SOURCE WS-KA
     CALL "JRAND-NEXT-LONG" USING WS-SOURCE WS-KB
     MOVE L-BASE TO WS-INDEX-EDIT
     MOVE SPACES TO WS-NAME
     STRING "octave_" FUNCTION TRIM(WS-INDEX-EDIT) DELIMITED BY SIZE INTO WS-NAME
     COMPUTE WS-LEN = 7 + FUNCTION LENGTH(FUNCTION TRIM(WS-INDEX-EDIT))
     CALL "FP-HASH" USING WS-NAME WS-LEN WS-HASH
*>   the hash widened with sign to 64 bits
     IF WS-HASH < 0
         COMPUTE WS-BIG = WS-M64 + WS-HASH
         MOVE WS-BIG TO WS-SEEDBITS
     ELSE
         MOVE WS-HASH TO WS-SEEDBITS
     END-IF
     PERFORM VARYING WS-PASS FROM 1 BY 1 UNTIL WS-PASS > 2
         IF WS-PASS = 1
             MOVE WS-KA TO WS-KEY
         ELSE
             MOVE WS-KB TO WS-KEY
         END-IF
         MOVE WS-SEEDBITS TO WS-SOURCE
         CALL "CBL_XOR" USING WS-KEY WS-SOURCE BY VALUE 8
         CALL "JRAND-SET-SEED" USING WS-KEY WS-SOURCE
         IF WS-PASS = 1
             CALL "PERLIN-CREATE-LEGACY" USING WS-KEY WS-PA
         ELSE
             CALL "PERLIN-CREATE-LEGACY" USING WS-KEY WS-PB
         END-IF
     END-PERFORM
     CALL STATIC "cc_f64_mul" USING BY REFERENCE WS-NF L-AMP WS-T
     CALL STATIC "cc_f64_f32_round" USING BY REFERENCE WS-T WS-LAYER-AMP
     ADD 1 TO NZ-NOISE-COUNT
     MOVE NZ-NOISE-COUNT TO L-HANDLE
     COMPUTE NZ-FIRST(L-HANDLE) = NZ-LAYER-COUNT + 1
     MOVE 2 TO NZ-LAYER-N(L-HANDLE)
     ADD 1 TO NZ-LAYER-COUNT
     MOVE WS-PA TO NZ-L-PERLIN(NZ-LAYER-COUNT)
     MOVE WS-FREQ TO NZ-L-FREQ(NZ-LAYER-COUNT)
     MOVE WS-LAYER-AMP TO NZ-L-AMP(NZ-LAYER-COUNT)
     ADD 1 TO NZ-LAYER-COUNT
     MOVE WS-PB TO NZ-L-PERLIN(NZ-LAYER-COUNT)
     CALL STATIC "cc_f64_mul" USING BY REFERENCE WS-FREQ WS-SECOND NZ-L-FREQ(NZ-LAYER-COUNT)
     MOVE WS-LAYER-AMP TO NZ-L-AMP(NZ-LAYER-COUNT)
     GOBACK.
 END PROGRAM NOISE-CREATE-LEGACY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FP-SCALE.
*> USING coordinate (BINARY-LONG), scale (FLOAT-LONG), mode, scaled out (FLOAT-LONG): mode 0 (double) x * scale; mode 1 (double)((float) x * scale).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-F                   FLOAT-LONG.
 01 WS-T                   FLOAT-LONG.
 LINKAGE SECTION.
 01 L-COORD                BINARY-LONG.
 01 L-SCALE                FLOAT-LONG.
 01 L-MODE                 BINARY-LONG.
 01 L-OUT                  FLOAT-LONG.
 PROCEDURE DIVISION USING L-COORD L-SCALE L-MODE L-OUT.
     MOVE L-COORD TO WS-F
     IF L-MODE = 1
         CALL STATIC "cc_f64_f32_round" USING BY REFERENCE WS-F WS-T
         CALL STATIC "cc_f64_mul" USING BY REFERENCE WS-T L-SCALE WS-F
         CALL STATIC "cc_f64_f32_round" USING BY REFERENCE WS-F L-OUT
     ELSE
         CALL STATIC "cc_f64_mul" USING BY REFERENCE WS-F L-SCALE L-OUT
     END-IF
     GOBACK.
 END PROGRAM FP-SCALE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FP-NOISE-AT.
*> getNoiseValue (5.3, mode 0: (double) x * scale) and slow(P) of dual_noise (5.5, mode 1: (double)((float) x * scale)); the value is a float32.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 LINKAGE SECTION.
 01 L-HANDLE               BINARY-LONG.
 01 L-SCALE                FLOAT-LONG.
 01 L-MODE                 BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-VALUE                FLOAT-LONG.
 PROCEDURE DIVISION USING L-HANDLE L-SCALE L-MODE L-X L-Y L-Z L-VALUE.
     CALL "FP-SCALE" USING L-X L-SCALE L-MODE WS-X
     CALL "FP-SCALE" USING L-Y L-SCALE L-MODE WS-Y
     CALL "FP-SCALE" USING L-Z L-SCALE L-MODE WS-Z
     CALL "NOISE-GET" USING L-HANDLE WS-X WS-Y WS-Z L-VALUE
     GOBACK.
 END PROGRAM FP-NOISE-AT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FP-INDEX.
*> 5.4 in float arithmetic: t = clamp((1 + v) / 2, 0, 0.9999), index = (int)(t * size).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-ONE                 FLOAT-LONG VALUE 1.
 01 WS-TWO                 FLOAT-LONG VALUE 2.
 01 WS-ZERO                FLOAT-LONG VALUE 0.
 01 WS-TOP-TEXT            PIC X(32) VALUE Z"0.9999".
 01 WS-TOP-RAW             FLOAT-LONG.
 01 WS-TOP                 FLOAT-LONG.
 01 WS-A                   FLOAT-LONG.
 01 WS-B                   FLOAT-LONG.
 01 WS-T                   FLOAT-LONG.
 01 WS-S                   FLOAT-LONG.
 LINKAGE SECTION.
 01 L-VALUE                FLOAT-LONG.
 01 L-SIZE                 BINARY-LONG.
 01 L-INDEX                BINARY-LONG.
 PROCEDURE DIVISION USING L-VALUE L-SIZE L-INDEX.
     CALL STATIC "cc_f64_from_text" USING BY REFERENCE WS-TOP-TEXT WS-TOP-RAW
     CALL STATIC "cc_f64_f32_round" USING BY REFERENCE WS-TOP-RAW WS-TOP
     CALL STATIC "cc_f64_add" USING BY REFERENCE WS-ONE L-VALUE WS-A
     CALL STATIC "cc_f64_f32_round" USING BY REFERENCE WS-A WS-B
     CALL STATIC "cc_f64_div" USING BY REFERENCE WS-B WS-TWO WS-A
     CALL STATIC "cc_f64_clamp_f32" USING BY REFERENCE WS-A WS-ZERO WS-TOP WS-T
     MOVE L-SIZE TO WS-S
     CALL STATIC "cc_f64_mul" USING BY REFERENCE WS-T WS-S WS-A
     CALL STATIC "cc_f64_f32_round" USING BY REFERENCE WS-A WS-B
     CALL STATIC "cc_f64_to_i32" USING BY REFERENCE WS-B L-INDEX
     GOBACK.
 END PROGRAM FP-INDEX.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FD-PROV-NAMED IS RECURSIVE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY FEATDATA.
 01 WS-DEPTH               BINARY-LONG VALUE 0.
 01 WS-KIND                PIC X(32) VALUE "block_state_provider".
 LOCAL-STORAGE SECTION.
 COPY JSONDOC.
 01 LS-TEXT                PIC X(65536).
 01 LS-LEN                 BINARY-LONG.
 01 LS-STATUS              BINARY-LONG.
 01 LS-ROOT                BINARY-LONG VALUE 1.
 LINKAGE SECTION.
 01 L-KEY                  PIC X(80).
 01 L-INDEX                BINARY-LONG.
 PROCEDURE DIVISION USING L-KEY L-INDEX.
     MOVE 0 TO L-INDEX
     IF WS-DEPTH >= 4
         MOVE 1 TO FD-BAD
         GOBACK
     END-IF
     CALL "FD-FETCH" USING WS-KIND L-KEY LS-TEXT LS-LEN LS-STATUS
     IF LS-STATUS NOT = 0
         MOVE 1 TO FD-BAD
         GOBACK
     END-IF
     CALL "JSON-PARSE" USING JSON-DOC LS-TEXT LS-LEN
     IF JD-ERROR NOT = 0 OR JD-COUNT = 0
         MOVE 1 TO FD-BAD
         GOBACK
     END-IF
     ADD 1 TO WS-DEPTH
     CALL "FD-PROV-NODE" USING JSON-DOC LS-ROOT L-INDEX
     SUBTRACT 1 FROM WS-DEPTH
     GOBACK.
 END PROGRAM FD-PROV-NAMED.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FD-PROV-VARIETY.
*> USING doc, node, min out, max out, ok out: an InclusiveRange of 1 to 64 (35-2 section 4.5): an int, a list of two ints or {min_inclusive, max_inclusive}.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-MIN-KEY             PIC X(40) VALUE "min_inclusive".
 01 WS-MAX-KEY             PIC X(40) VALUE "max_inclusive".
 01 WS-A                   BINARY-LONG.
 01 WS-B                   BINARY-LONG.
 01 WS-OK-A                BINARY-LONG.
 01 WS-OK-B                BINARY-LONG.
 LINKAGE SECTION.
 COPY JSONDOC.
 01 L-NODE                 BINARY-LONG.
 01 L-MIN                  BINARY-LONG.
 01 L-MAX                  BINARY-LONG.
 01 L-OK                   BINARY-LONG.
 PROCEDURE DIVISION USING JSON-DOC L-NODE L-MIN L-MAX L-OK.
     MOVE 0 TO L-OK L-MIN L-MAX WS-OK-A WS-OK-B
     IF L-NODE = 0
         GOBACK
     END-IF
     EVALUATE JN-TYPE(L-NODE)
         WHEN JT-NUMBER
             CALL "FD-J-INT" USING JSON-DOC L-NODE L-MIN WS-OK-A
             MOVE L-MIN TO L-MAX
             MOVE WS-OK-A TO WS-OK-B
         WHEN JT-ARRAY
             IF JN-COUNT(L-NODE) = 2
                 CALL "JSON-ELEMENT" USING JSON-DOC L-NODE 0 WS-A
                 CALL "FD-J-INT" USING JSON-DOC WS-A L-MIN WS-OK-A
                 CALL "JSON-ELEMENT" USING JSON-DOC L-NODE 1 WS-B
                 CALL "FD-J-INT" USING JSON-DOC WS-B L-MAX WS-OK-B
             END-IF
         WHEN JT-OBJECT
             CALL "FD-J-MEMBER" USING JSON-DOC L-NODE WS-MIN-KEY WS-A
             CALL "FD-J-INT" USING JSON-DOC WS-A L-MIN WS-OK-A
             CALL "FD-J-MEMBER" USING JSON-DOC L-NODE WS-MAX-KEY WS-B
             CALL "FD-J-INT" USING JSON-DOC WS-B L-MAX WS-OK-B
     END-EVALUATE
     IF WS-OK-A = 1 AND WS-OK-B = 1 AND L-MIN >= 1 AND L-MAX <= 64 AND L-MIN <= L-MAX
         MOVE 1 TO L-OK
     END-IF
     GOBACK.
 END PROGRAM FD-PROV-VARIETY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FD-PROV-STATES.
*> USING doc, node, pool start out, count out: a non-empty list of block states (BlockState.CODEC: a bare id or an object) into the pool; FD-BAD when it is empty, absent or holds an unknown block.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY FEATDATA.
 01 WS-I                   BINARY-LONG.
 01 WS-E                   BINARY-LONG.
 01 WS-S                   BINARY-LONG.
 01 WS-OK                  BINARY-LONG.
 01 WS-IDX                 BINARY-LONG.
 LINKAGE SECTION.
 COPY JSONDOC.
 01 L-NODE                 BINARY-LONG.
 01 L-START                BINARY-LONG.
 01 L-COUNT                BINARY-LONG.
 PROCEDURE DIVISION USING JSON-DOC L-NODE L-START L-COUNT.
     COMPUTE L-START = FD-POOL-COUNT + 1
     MOVE 0 TO L-COUNT
     IF L-NODE = 0
         MOVE 1 TO FD-BAD
         GOBACK
     END-IF
     IF JN-TYPE(L-NODE) NOT = JT-ARRAY OR JN-COUNT(L-NODE) = 0
         MOVE 1 TO FD-BAD
         GOBACK
     END-IF
     PERFORM VARYING WS-I FROM 0 BY 1 UNTIL WS-I >= JN-COUNT(L-NODE)
         CALL "JSON-ELEMENT" USING JSON-DOC L-NODE WS-I WS-E
         CALL "FD-J-STATE" USING JSON-DOC WS-E WS-S WS-OK
         IF WS-OK = 0
             MOVE 1 TO FD-BAD
         END-IF
         CALL "FD-POOL-ADD" USING WS-S WS-IDX
         ADD 1 TO L-COUNT
     END-PERFORM
     GOBACK.
 END PROGRAM FD-PROV-STATES.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FD-PROV-NOISE-DEF.
*> USING doc, noise parameter node (the object of a NormalNoise), seed (u64), handle out: base_octave in -32..32, base_amplitude in 1.0E-5..1000000 (default 1), octave_count 1,
*> normalize true, no amplitude_modifiers; anything else sets FD-BAD and gives handle 0.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY FEATDATA.
 01 WS-K-OCTAVE            PIC X(40) VALUE "base_octave".
 01 WS-K-AMP               PIC X(40) VALUE "base_amplitude".
 01 WS-K-COUNT             PIC X(40) VALUE "octave_count".
 01 WS-K-NORMALIZE         PIC X(40) VALUE "normalize".
 01 WS-K-MODS              PIC X(40) VALUE "amplitude_modifiers".
 01 WS-E                   BINARY-LONG.
 01 WS-OCT                 BINARY-LONG.
 01 WS-OK                  BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-AMP                 FLOAT-LONG.
 01 WS-LO                  FLOAT-LONG VALUE 0.00001.
 01 WS-HI                  FLOAT-LONG VALUE 1000000.
 LINKAGE SECTION.
 COPY JSONDOC.
 01 L-NODE                 BINARY-LONG.
 01 L-SEED                 BINARY-DOUBLE UNSIGNED.
 01 L-HANDLE               BINARY-LONG.
 PROCEDURE DIVISION USING JSON-DOC L-NODE L-SEED L-HANDLE.
     MOVE 0 TO L-HANDLE
     IF L-NODE = 0
         MOVE 1 TO FD-BAD
         GOBACK
     END-IF
     CALL "FD-J-MEMBER" USING JSON-DOC L-NODE WS-K-OCTAVE WS-E
     CALL "FD-J-INT" USING JSON-DOC WS-E WS-OCT WS-OK
     IF WS-OK = 0 OR WS-OCT < -32 OR WS-OCT > 32
         MOVE 1 TO FD-BAD
         GOBACK
     END-IF
     MOVE 1 TO WS-AMP
     CALL "FD-J-MEMBER" USING JSON-DOC L-NODE WS-K-AMP WS-E
     IF WS-E > 0
         CALL "FD-J-DOUBLE" USING JSON-DOC WS-E WS-AMP WS-OK
         IF WS-OK = 0 OR WS-AMP < WS-LO OR WS-AMP > WS-HI
             MOVE 1 TO FD-BAD
             GOBACK
         END-IF
     END-IF
     CALL "FD-J-MEMBER" USING JSON-DOC L-NODE WS-K-COUNT WS-E
     IF WS-E > 0
         CALL "FD-J-INT" USING JSON-DOC WS-E WS-N WS-OK
         IF WS-OK = 0 OR WS-N NOT = 1
             MOVE 1 TO FD-BAD
             GOBACK
         END-IF
     END-IF
     CALL "FD-J-MEMBER" USING JSON-DOC L-NODE WS-K-NORMALIZE WS-E
     IF WS-E > 0 AND JN-TYPE(WS-E) NOT = JT-TRUE
         MOVE 1 TO FD-BAD
         GOBACK
     END-IF
     CALL "FD-J-MEMBER" USING JSON-DOC L-NODE WS-K-MODS WS-E
     IF WS-E > 0
         IF JN-COUNT(WS-E) > 0
             MOVE 1 TO FD-BAD
             GOBACK
         END-IF
     END-IF
     CALL "NOISE-CREATE-LEGACY" USING L-SEED WS-OCT WS-AMP L-HANDLE
     GOBACK.
 END PROGRAM FD-PROV-NOISE-DEF.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FD-PROV-NOISE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY FEATDATA.
 01 WS-M64                 PIC 9(20) VALUE 18446744073709551616.
 01 WS-K-SEED              PIC X(40) VALUE "seed".
 01 WS-K-NOISE             PIC X(40) VALUE "noise".
 01 WS-K-SCALE             PIC X(40) VALUE "scale".
 01 WS-K-STATES            PIC X(40) VALUE "states".
 01 WS-K-VARIETY           PIC X(40) VALUE "variety".
 01 WS-K-SLOW              PIC X(40) VALUE "slow_noise".
 01 WS-K-SLOW-SCALE        PIC X(40) VALUE "slow_scale".
 01 WS-K-THRESHOLD         PIC X(40) VALUE "threshold".
 01 WS-K-CHANCE            PIC X(40) VALUE "high_chance".
 01 WS-K-DEFAULT           PIC X(40) VALUE "default_state".
 01 WS-K-LOW               PIC X(40) VALUE "low_states".
 01 WS-K-HIGH              PIC X(40) VALUE "high_states".
 01 WS-E                   BINARY-LONG.
 01 WS-OK                  BINARY-LONG.
 01 WS-SEED-F              FLOAT-LONG.
 01 WS-LIMIT               FLOAT-LONG VALUE 9007199254740992.
 01 WS-NEG-LIMIT           FLOAT-LONG VALUE -9007199254740992.
 01 WS-SEED-N              BINARY-DOUBLE.
 01 WS-SEED-U              BINARY-DOUBLE UNSIGNED.
 01 WS-BIG                 PIC 9(20).
 01 WS-F                   FLOAT-LONG.
 01 WS-T                   FLOAT-LONG.
 01 WS-ZERO                FLOAT-LONG VALUE 0.
 01 WS-ONE                 FLOAT-LONG VALUE 1.
 01 WS-MINUS-ONE           FLOAT-LONG VALUE -1.
 01 WS-MIN                 BINARY-LONG.
 01 WS-MAX                 BINARY-LONG.
 LINKAGE SECTION.
 COPY JSONDOC.
 01 L-NODE                 BINARY-LONG.
 01 L-ROW                  BINARY-LONG.
 01 L-KIND                 BINARY-LONG.
 PROCEDURE DIVISION USING JSON-DOC L-NODE L-ROW L-KIND.
     MOVE L-KIND TO PV-TYPE(L-ROW)
*>   the seed: a JSON number below 2^53, a negative one as the two's complement word
     CALL "FD-J-MEMBER" USING JSON-DOC L-NODE WS-K-SEED WS-E
     CALL "FD-J-DOUBLE" USING JSON-DOC WS-E WS-SEED-F WS-OK
     IF WS-OK = 0 OR WS-SEED-F >= WS-LIMIT OR WS-SEED-F <= WS-NEG-LIMIT
         MOVE 1 TO FD-BAD
         GOBACK
     END-IF
     MOVE WS-SEED-F TO WS-SEED-N
     IF WS-SEED-N < 0
         COMPUTE WS-BIG = WS-M64 + WS-SEED-N
         MOVE WS-BIG TO WS-SEED-U
     ELSE
         MOVE WS-SEED-N TO WS-SEED-U
     END-IF
     CALL "FD-J-MEMBER" USING JSON-DOC L-NODE WS-K-NOISE WS-E
     CALL "FD-PROV-NOISE-DEF" USING JSON-DOC WS-E WS-SEED-U PV-H1(L-ROW)
*>   the scale: a positive float, kept as the float widened
     CALL "FD-J-MEMBER" USING JSON-DOC L-NODE WS-K-SCALE WS-E
     CALL "FD-J-DOUBLE" USING JSON-DOC WS-E WS-F WS-OK
     IF WS-OK = 0 OR WS-F <= 0
         MOVE 1 TO FD-BAD
         GOBACK
     END-IF
     CALL STATIC "cc_f64_f32_round" USING BY REFERENCE WS-F PV-F1(L-ROW)
     EVALUATE L-KIND
         WHEN 6
             CALL "FD-J-MEMBER" USING JSON-DOC L-NODE WS-K-STATES WS-E
             CALL "FD-PROV-STATES" USING JSON-DOC WS-E PV-POOL(L-ROW) PV-N(L-ROW)
         WHEN 7
             CALL "FD-J-MEMBER" USING JSON-DOC L-NODE WS-K-STATES WS-E
             CALL "FD-PROV-STATES" USING JSON-DOC WS-E PV-POOL(L-ROW) PV-N(L-ROW)
             CALL "FD-J-MEMBER" USING JSON-DOC L-NODE WS-K-SLOW WS-E
             CALL "FD-PROV-NOISE-DEF" USING JSON-DOC WS-E WS-SEED-U PV-H2(L-ROW)
             CALL "FD-J-MEMBER" USING JSON-DOC L-NODE WS-K-SLOW-SCALE WS-E
             CALL "FD-J-DOUBLE" USING JSON-DOC WS-E WS-F WS-OK
             IF WS-OK = 0 OR WS-F <= 0
                 MOVE 1 TO FD-BAD
                 GOBACK
             END-IF
             CALL STATIC "cc_f64_f32_round" USING BY REFERENCE WS-F PV-F2(L-ROW)
             CALL "FD-J-MEMBER" USING JSON-DOC L-NODE WS-K-VARIETY WS-E
             CALL "FD-PROV-VARIETY" USING JSON-DOC WS-E WS-MIN WS-MAX WS-OK
             IF WS-OK = 0
                 MOVE 1 TO FD-BAD
                 GOBACK
             END-IF
             MOVE WS-MIN TO PV-B(L-ROW)
             MOVE WS-MAX TO PV-C(L-ROW)
         WHEN OTHER
             CALL "FD-J-MEMBER" USING JSON-DOC L-NODE WS-K-THRESHOLD WS-E
             CALL "FD-J-DOUBLE" USING JSON-DOC WS-E WS-F WS-OK
             IF WS-OK = 0 OR WS-F < WS-MINUS-ONE OR WS-F > WS-ONE
                 MOVE 1 TO FD-BAD
                 GOBACK
             END-IF
             CALL STATIC "cc_f64_f32_round" USING BY REFERENCE WS-F PV-F2(L-ROW)
             CALL "FD-J-MEMBER" USING JSON-DOC L-NODE WS-K-CHANCE WS-E
             CALL "FD-J-DOUBLE" USING JSON-DOC WS-E WS-F WS-OK
             IF WS-OK = 0 OR WS-F < WS-ZERO OR WS-F > WS-ONE
                 MOVE 1 TO FD-BAD
                 GOBACK
             END-IF
             CALL STATIC "cc_f64_f32_round" USING BY REFERENCE WS-F PV-F3(L-ROW)
             CALL "FD-J-MEMBER" USING JSON-DOC L-NODE WS-K-DEFAULT WS-E
             CALL "FD-J-STATE" USING JSON-DOC WS-E PV-A(L-ROW) WS-OK
             IF WS-OK = 0
                 MOVE 1 TO FD-BAD
             END-IF
             CALL "FD-J-MEMBER" USING JSON-DOC L-NODE WS-K-LOW WS-E
             CALL "FD-PROV-STATES" USING JSON-DOC WS-E PV-POOL(L-ROW) PV-N(L-ROW)
             CALL "FD-J-MEMBER" USING JSON-DOC L-NODE WS-K-HIGH WS-E
             CALL "FD-PROV-STATES" USING JSON-DOC WS-E PV-B(L-ROW) PV-C(L-ROW)
     END-EVALUATE
     GOBACK.
 END PROGRAM FD-PROV-NOISE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FR-PROV-NOISE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY FEATDATA.
 01 WS-V                   FLOAT-LONG.
 01 WS-S                   FLOAT-LONG.
 01 WS-T                   FLOAT-LONG.
 01 WS-U                   FLOAT-LONG.
 01 WS-ONE                 FLOAT-LONG VALUE 1.
 01 WS-TWO                 FLOAT-LONG VALUE 2.
 01 WS-MINUS-ONE           FLOAT-LONG VALUE -1.
 01 WS-ZERO                FLOAT-LONG VALUE 0.
 01 WS-LO                  FLOAT-LONG.
 01 WS-SPAN                FLOAT-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-D                   BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-MODE-F              BINARY-LONG VALUE 1.
 01 WS-MODE-D              BINARY-LONG VALUE 0.
 01 WS-IDX                 BINARY-LONG.
 01 WS-PALETTE.
    05 WS-PAL              BINARY-LONG OCCURS 65 TIMES.
 LINKAGE SECTION.
 COPY XORO REPLACING LEADING ==XR-== BY ==L-==.
 01 L-PV                   BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-STATE-OUT            BINARY-LONG.
 PROCEDURE DIVISION USING L-STATE L-PV L-X L-Y L-Z L-STATE-OUT.
     CALL "FP-NOISE-AT" USING PV-H1(L-PV) PV-F1(L-PV) WS-MODE-D L-X L-Y L-Z WS-V
     EVALUATE PV-TYPE(L-PV)
         WHEN 6
             CALL "FP-INDEX" USING WS-V PV-N(L-PV) WS-IDX
             MOVE FD-POOL(PV-POOL(L-PV) + WS-IDX) TO L-STATE-OUT
*>       dual_noise (5.5): n = (int) clampedMap(slow(pos), -1, 1, min, max + 1); the palette is the states of the slow noise at n shifted positions
         WHEN 7
             CALL "FP-NOISE-AT" USING PV-H2(L-PV) PV-F2(L-PV) WS-MODE-F L-X L-Y L-Z WS-S
             CALL STATIC "cc_f64_sub" USING BY REFERENCE WS-S WS-MINUS-ONE WS-T
             CALL STATIC "cc_f64_div" USING BY REFERENCE WS-T WS-TWO WS-U
             CALL STATIC "cc_f64_clamp_f64" USING BY REFERENCE WS-U WS-ZERO WS-ONE WS-T
             COMPUTE WS-N = PV-C(L-PV) + 1 - PV-B(L-PV)
             MOVE WS-N TO WS-SPAN
             CALL STATIC "cc_f64_mul" USING BY REFERENCE WS-T WS-SPAN WS-U
             MOVE PV-B(L-PV) TO WS-LO
             CALL STATIC "cc_f64_add" USING BY REFERENCE WS-LO WS-U WS-T
             CALL STATIC "cc_f64_to_i32" USING BY REFERENCE WS-T WS-N
             PERFORM VARYING WS-I FROM 0 BY 1 UNTIL WS-I >= WS-N
                 COMPUTE WS-X = L-X + WS-I * 54545
                 COMPUTE WS-Z = L-Z + WS-I * 34234
                 CALL "FP-NOISE-AT" USING PV-H2(L-PV) PV-F2(L-PV) WS-MODE-F WS-X L-Y WS-Z WS-S
                 CALL "FP-INDEX" USING WS-S PV-N(L-PV) WS-IDX
                 MOVE FD-POOL(PV-POOL(L-PV) + WS-IDX) TO WS-PAL(WS-I + 1)
             END-PERFORM
             CALL "FP-INDEX" USING WS-V WS-N WS-IDX
             MOVE WS-PAL(WS-IDX + 1) TO L-STATE-OUT
*>       noise_threshold (5.6): below the threshold a low state; else a float against high_chance, a high state or the default
         WHEN OTHER
             IF WS-V < PV-F2(L-PV)
                 CALL "WGR-NEXT-INT-BOUND" USING L-STATE PV-N(L-PV) WS-D
                 MOVE FD-POOL(PV-POOL(L-PV) + WS-D) TO L-STATE-OUT
             ELSE
                 CALL "WGR-NEXT-FLOAT" USING L-STATE WS-T
                 IF WS-T < PV-F3(L-PV)
                     CALL "WGR-NEXT-INT-BOUND" USING L-STATE PV-C(L-PV) WS-D
                     MOVE FD-POOL(PV-B(L-PV) + WS-D) TO L-STATE-OUT
                 ELSE
                     MOVE PV-A(L-PV) TO L-STATE-OUT
                 END-IF
             END-IF
     END-EVALUATE
     GOBACK.
 END PROGRAM FR-PROV-NOISE.
