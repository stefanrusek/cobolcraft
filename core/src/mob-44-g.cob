*> Slime chunks and the sniffer's diggable blocks (002-lane-mobsa2; docs/protocol/54-client-gap-closures.md section 8).
*> M44-SLIME-SEED USING chunk x, chunk z (BINARY-LONG), world seed (BINARY-DOUBLE), seed out (BINARY-DOUBLE): (S + T1 + T2 + T3 + T4) xor 987234911 with
*>   T1 = int32(int32(a x a) x 4987142), T2 = int32(a x 5947611), T3 = int32(b x b) x 4392871 (64 bit), T4 = int32(b x 389711); a = chunk x, b = chunk z. The 64 bit wrap of the sum is
*>   not reproduced: the sum must stay inside a signed 64 bit word.
*> M44-SLIME-CHUNK USING chunk x, chunk z, world seed, slime out: the first nextInt(10) of the Java generator seeded with that seed is 0.
*> M44-SNIFFER-DIGGABLE USING bare block key (PIC X(48)), diggable out: the block tag sniffer_diggable_block: dirt, coarse_dirt, rooted_dirt, mud, muddy_mangrove_roots, moss_block,
*>   pale_moss_block, grass_block, podzol.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. M44-WRAP32.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-VALUE                BINARY-DOUBLE.
 PROCEDURE DIVISION USING L-VALUE.
     COMPUTE L-VALUE = FUNCTION MOD(L-VALUE, 4294967296)
     IF L-VALUE >= 2147483648
         SUBTRACT 4294967296 FROM L-VALUE
     END-IF
     GOBACK.
 END PROGRAM M44-WRAP32.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. M44-SLIME-SEED.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-A                   BINARY-DOUBLE.
 01 WS-B                   BINARY-DOUBLE.
 01 WS-T                   BINARY-DOUBLE.
 01 WS-SUM                 BINARY-DOUBLE.
 01 WS-SALT                BINARY-DOUBLE VALUE 987234911.
 LINKAGE SECTION.
 01 L-CX                   BINARY-LONG.
 01 L-CZ                   BINARY-LONG.
 01 L-SEED                 BINARY-DOUBLE.
 01 L-OUT                  BINARY-DOUBLE.
 PROCEDURE DIVISION USING L-CX L-CZ L-SEED L-OUT.
     MOVE L-CX TO WS-A
     MOVE L-CZ TO WS-B
     MOVE L-SEED TO WS-SUM
     COMPUTE WS-T = WS-A * WS-A
     CALL "M44-WRAP32" USING WS-T
     COMPUTE WS-T = WS-T * 4987142
     CALL "M44-WRAP32" USING WS-T
     ADD WS-T TO WS-SUM
     COMPUTE WS-T = WS-A * 5947611
     CALL "M44-WRAP32" USING WS-T
     ADD WS-T TO WS-SUM
     COMPUTE WS-T = WS-B * WS-B
     CALL "M44-WRAP32" USING WS-T
     COMPUTE WS-T = WS-T * 4392871
     ADD WS-T TO WS-SUM
     COMPUTE WS-T = WS-B * 389711
     CALL "M44-WRAP32" USING WS-T
     ADD WS-T TO WS-SUM
     CALL "CBL_XOR" USING WS-SALT WS-SUM BY VALUE 8
     MOVE WS-SUM TO L-OUT
     GOBACK.
 END PROGRAM M44-SLIME-SEED.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. M44-SLIME-CHUNK.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-SEED                BINARY-DOUBLE.
 01 WS-SEED-U REDEFINES WS-SEED BINARY-DOUBLE UNSIGNED.
 01 WS-STATE               BINARY-DOUBLE UNSIGNED.
 01 WS-DRAW                BINARY-LONG.
 01 WS-TEN                 BINARY-LONG VALUE 10.
 LINKAGE SECTION.
 01 L-CX                   BINARY-LONG.
 01 L-CZ                   BINARY-LONG.
 01 L-SEED                 BINARY-DOUBLE.
 01 L-SLIME                BINARY-LONG.
 PROCEDURE DIVISION USING L-CX L-CZ L-SEED L-SLIME.
     CALL "M44-SLIME-SEED" USING L-CX L-CZ L-SEED WS-SEED
     CALL "JRAND-SET-SEED" USING WS-STATE WS-SEED-U
     CALL "JRAND-NEXT-INT-BOUND" USING WS-STATE WS-TEN WS-DRAW
     MOVE 0 TO L-SLIME
     IF WS-DRAW = 0
         MOVE 1 TO L-SLIME
     END-IF
     GOBACK.
 END PROGRAM M44-SLIME-CHUNK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. M44-SNIFFER-DIGGABLE.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-KEY                  PIC X(48).
 01 L-DIGGABLE             BINARY-LONG.
 PROCEDURE DIVISION USING L-KEY L-DIGGABLE.
     MOVE 0 TO L-DIGGABLE
     EVALUATE L-KEY
         WHEN "dirt" WHEN "coarse_dirt" WHEN "rooted_dirt" WHEN "mud" WHEN "muddy_mangrove_roots"
         WHEN "moss_block" WHEN "pale_moss_block" WHEN "grass_block" WHEN "podzol"
             MOVE 1 TO L-DIGGABLE
     END-EVALUATE
     GOBACK.
 END PROGRAM M44-SNIFFER-DIGGABLE.
