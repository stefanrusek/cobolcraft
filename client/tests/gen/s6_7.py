from cube6 import *
define()
hdr='''*> Entity models part 6 section 7 (slime, magma cube, sulfur cube): the seven layer meshes (7.1 to 7.3), the magma slice wave (7.2), the common cube mob scale, downscale, shadow and squish tick (7.4), the slime outer layer (7.5),
*> magma texture and block light (7.6) and the sulfur cube renderer, scale stack, inner layer and custom head (7.7).
*> Entry points for the integrator (inputs; the table programs take IN (16 FLOAT-LONG) and OUT (64 FLOAT-LONG)): ops lists are count, then code (1 translate, 2 scale, 6 rotate X degrees) and three values per op in call order.
*>   EF6-MAGMA-ANIM EMM-MODEL state(1 squish): reset first, slice y = -(4 - i) x max(0, squish) x 1.7; EF6-CUBE-SCALE IN(size, squish, holds a block) OUT(x y z); EF6-CUBE-DOWNSCALE IN() OUT(ops); EF6-CUBE-SHADOW IN(size) OUT(radius);
*>   EF6-CUBE-TICK IN(squish, target squish, on ground, was on ground, magma) OUT(old squish, squish, target squish, was on ground, landed, took off): AbstractCubeMob.tick squish part; EF6-SLIME-OUTER IN(appears glowing, invisible) OUT(draw, outline);
*>   EF6-CUBE-TEXTURE IN(kind 0 slime 1 magma 2 sulfur outer 3 sulfur outer small 4 sulfur inner 5 sulfur inner small) path(out X(120)); EF6-MAGMA-BLOCKLIGHT IN() OUT(15);
*>   EF6-SULFUR-FUSE IN(fuse, partial, primed) OUT(fuseRemainingTicks); EF6-SULFUR-BODY IN(stack empty, block item, skull block) OUT(0 nothing, 1 worn head, 2 contained block); EF6-SULFUR-SWELL IN(fuse remaining) OUT(swell);
*>   EF6-SULFUR-SCALE-OPS IN(baby, invisible, size, squish, holds a block, fuse remaining) OUT(ops); EF6-SULFUR-LIT IN(fuse, fuse remaining positive) OUT(1 when the inner overlay is the white row);
*>   EF6-SULFUR-INNER IN(worn head set, holds a block, baby, invisible) OUT(mode 0 skip 1 block 2 inner model at order -1; for the block mode then the ops count and ops); EF6-SULFUR-HEAD IN() OUT(yOffset, skullYOffset, horizontal scale, vertical scale).
'''
def prog(name,body,ws='',ins=True,outs=True):
    s=' IDENTIFICATION DIVISION.\n PROGRAM-ID. %s.\n DATA DIVISION.\n'%name
    if ws: s+=' WORKING-STORAGE SECTION.\n'+ws
    s+=' LINKAGE SECTION.\n'
    s+=' 01 L-IN.\n    05 L-I                 FLOAT-LONG OCCURS 16 TIMES.\n 01 L-OUT.\n    05 L-O                 FLOAT-LONG OCCURS 64 TIMES.\n'
    s+=' PROCEDURE DIVISION USING L-IN L-OUT.\n'+body+'     GOBACK.\n END PROGRAM %s.\n\n'%name
    return s
extra=r''' IDENTIFICATION DIVISION.
 PROGRAM-ID. EF6-MAGMA-ANIM.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-NAME                PIC X(24).
 01 WS-P                   BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-DIG                 PIC 9.
 01 WS-SQ                  FLOAT-LONG.
 LINKAGE SECTION.
 COPY CLEMM.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 16 TIMES.
 PROCEDURE DIVISION USING EMM-MODEL L-IN.
     CALL "EMM-RESET" USING EMM-MODEL
     MOVE L-I(1) TO WS-SQ
     IF WS-SQ < 0
         MOVE 0 TO WS-SQ
     END-IF
     PERFORM VARYING WS-I FROM 0 BY 1 UNTIL WS-I > 7
         MOVE WS-I TO WS-DIG
         MOVE SPACES TO WS-NAME
         STRING "cube" WS-DIG DELIMITED BY SIZE INTO WS-NAME
         CALL "EMM-FIND" USING EMM-MODEL WS-NAME WS-P
         COMPUTE MM-CY(WS-P) = (WS-I - 4) * WS-SQ * 1.7
     END-PERFORM
     GOBACK.
 END PROGRAM EF6-MAGMA-ANIM.

'''
extra+=prog('EF6-CUBE-SCALE','''     MOVE 0 TO WS-Q
     IF L-I(3) = 0
         COMPUTE WS-Q = L-I(2) / (L-I(1) * 0.5 + 1)
     END-IF
     COMPUTE WS-R = 1 / (WS-Q + 1)
     COMPUTE L-O(1) = WS-R * L-I(1)
     COMPUTE L-O(2) = L-I(1) / WS-R
     MOVE L-O(1) TO L-O(3)
''',' 01 WS-Q                   FLOAT-LONG.\n 01 WS-R                   FLOAT-LONG.\n')
extra+=prog('EF6-CUBE-DOWNSCALE','''     MOVE 2 TO L-O(1)
     MOVE 2 TO L-O(2)
     MOVE 0.999 TO L-O(3) L-O(4) L-O(5)
     MOVE 1 TO L-O(6)
     MOVE 0 TO L-O(7) L-O(9)
     MOVE 0.001 TO L-O(8)
''')
extra+=prog('EF6-CUBE-SHADOW','     COMPUTE L-O(1) = L-I(1) * 0.25\n')
extra+=prog('EF6-CUBE-TICK','''     MOVE L-I(1) TO L-O(1)
     COMPUTE L-O(2) = L-I(1) + (L-I(2) - L-I(1)) * 0.5
     MOVE L-I(2) TO L-O(3)
     MOVE 0 TO L-O(5) L-O(6)
     IF L-I(3) NOT = 0 AND L-I(4) = 0
         MOVE -0.5 TO L-O(3)
         MOVE 1 TO L-O(5)
     END-IF
     IF L-I(3) = 0 AND L-I(4) NOT = 0
         MOVE 1 TO L-O(3)
         MOVE 1 TO L-O(6)
     END-IF
     MOVE L-I(3) TO L-O(4)
     IF L-I(5) NOT = 0
         COMPUTE L-O(3) = L-O(3) * 0.9
     ELSE
         COMPUTE L-O(3) = L-O(3) * 0.6
     END-IF
''')
extra+=prog('EF6-SLIME-OUTER','''     MOVE 1 TO L-O(1)
     MOVE 0 TO L-O(2)
     IF L-I(1) NOT = 0 AND L-I(2) NOT = 0
         MOVE 1 TO L-O(2)
     ELSE
         IF L-I(2) NOT = 0
             MOVE 0 TO L-O(1)
         END-IF
     END-IF
''')
extra+=r''' IDENTIFICATION DIVISION.
 PROGRAM-ID. EF6-CUBE-TEXTURE.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 16 TIMES.
 01 L-PATH                 PIC X(120).
 PROCEDURE DIVISION USING L-IN L-PATH.
     EVALUATE L-I(1)
         WHEN 0
             MOVE "textures/entity/slime/slime.png" TO L-PATH
         WHEN 1
             MOVE "textures/entity/slime/magmacube.png" TO L-PATH
         WHEN 2
             MOVE "textures/entity/sulfur_cube/sulfur_cube_outer.png" TO L-PATH
         WHEN 3
             MOVE "textures/entity/sulfur_cube/sulfur_cube_outer_small.png" TO L-PATH
         WHEN 4
             MOVE "textures/entity/sulfur_cube/sulfur_cube_inner.png" TO L-PATH
         WHEN OTHER
             MOVE "textures/entity/sulfur_cube/sulfur_cube_inner_small.png" TO L-PATH
     END-EVALUATE
     GOBACK.
 END PROGRAM EF6-CUBE-TEXTURE.

'''
extra+=prog('EF6-MAGMA-BLOCKLIGHT','     MOVE 15 TO L-O(1)\n')
extra+=prog('EF6-SULFUR-FUSE','''     MOVE 0 TO L-O(1)
     IF L-I(3) NOT = 0
         COMPUTE L-O(1) = L-I(1) - L-I(2) + 1
     END-IF
''')
extra+=prog('EF6-SULFUR-BODY','''     MOVE 2 TO L-O(1)
     IF L-I(1) NOT = 0
         MOVE 0 TO L-O(1)
     ELSE
         IF L-I(2) NOT = 0 AND L-I(3) NOT = 0
             MOVE 1 TO L-O(1)
         END-IF
     END-IF
''')
extra+=prog('EF6-SULFUR-SWELL','''     COMPUTE WS-C = 1 - L-I(1) / 10
     IF WS-C < 0
         MOVE 0 TO WS-C
     END-IF
     IF WS-C > 1
         MOVE 1 TO WS-C
     END-IF
     COMPUTE L-O(1) = 0.3 * (WS-C * WS-C) * (WS-C * WS-C)
''',' 01 WS-C                   FLOAT-LONG.\n')
extra+=prog('EF6-SULFUR-SCALE-OPS','''     MOVE 2 TO L-O(2)
     MOVE 0.999 TO L-O(3) L-O(4) L-O(5)
     MOVE 1 TO L-O(6)
     MOVE 0 TO L-O(7) L-O(9)
     MOVE 0.001 TO L-O(8)
     MOVE 2 TO L-O(10)
     MOVE 0 TO WS-Q
     IF L-I(5) = 0
         COMPUTE WS-Q = L-I(4) / (L-I(3) * 0.5 + 1)
     END-IF
     COMPUTE WS-R = 1 / (WS-Q + 1)
     COMPUTE L-O(11) = WS-R * L-I(3)
     COMPUTE L-O(12) = L-I(3) / WS-R
     MOVE L-O(11) TO L-O(13)
     MOVE 3 TO WS-N
     IF L-I(6) > 0 AND L-I(6) < 10
         COMPUTE WS-C = 1 - L-I(6) / 10
         COMPUTE WS-S = 1 + 0.3 * (WS-C * WS-C) * (WS-C * WS-C)
         MOVE 2 TO L-O(14)
         MOVE WS-S TO L-O(15) L-O(16) L-O(17)
         MOVE 4 TO WS-N
     END-IF
     MOVE 0.98 TO WS-Y0
     MOVE 0.5 TO WS-S
     IF L-I(1) NOT = 0
         MOVE 1.24 TO WS-Y0
         MOVE 1 TO WS-S
     END-IF
     MOVE 0.0625 TO WS-H
     IF L-I(2) NOT = 0
         MOVE 0 TO WS-H
     END-IF
     COMPUTE WS-K = WS-N * 4 + 2
     MOVE 2 TO L-O(WS-K)
     MOVE WS-S TO L-O(WS-K + 1) L-O(WS-K + 2) L-O(WS-K + 3)
     MOVE 1 TO L-O(WS-K + 4)
     MOVE 0 TO L-O(WS-K + 5) L-O(WS-K + 7)
     COMPUTE L-O(WS-K + 6) = WS-Y0 - WS-H
     COMPUTE L-O(1) = WS-N + 2
''',' 01 WS-Q                   FLOAT-LONG.\n 01 WS-R                   FLOAT-LONG.\n 01 WS-C                   FLOAT-LONG.\n 01 WS-S                   FLOAT-LONG.\n 01 WS-Y0                  FLOAT-LONG.\n 01 WS-H                   FLOAT-LONG.\n 01 WS-N                   BINARY-LONG.\n 01 WS-K                   BINARY-LONG.\n')
extra+=prog('EF6-SULFUR-LIT','''     MOVE 0 TO L-O(1)
     IF L-I(2) NOT = 0 AND L-I(1) >= 0
         COMPUTE WS-N = FUNCTION INTEGER-PART(L-I(1) / 5)
         IF FUNCTION MOD(WS-N, 2) = 0
             MOVE 1 TO L-O(1)
         END-IF
     END-IF
''',' 01 WS-N                   BINARY-LONG.\n')
extra+=prog('EF6-SULFUR-INNER','''     MOVE 0 TO L-O(1)
     IF L-I(1) = 0
         IF L-I(2) NOT = 0
             MOVE 1 TO L-O(1)
             MOVE 2 TO L-O(2)
             MOVE 6 TO L-O(3)
             MOVE 180 TO L-O(4)
             MOVE 0 TO L-O(5) L-O(6)
             MOVE 7 TO WS-K
             IF L-I(3) NOT = 0
                 MOVE 3 TO L-O(2)
                 MOVE 2 TO L-O(7)
                 MOVE 0.5 TO L-O(8) L-O(9) L-O(10)
                 MOVE 11 TO WS-K
             END-IF
             MOVE 1 TO L-O(WS-K)
             MOVE -0.5 TO L-O(WS-K + 1) L-O(WS-K + 3)
             MOVE -0.518 TO L-O(WS-K + 2)
         ELSE
             IF L-I(4) = 0
                 MOVE 2 TO L-O(1)
             END-IF
         END-IF
     END-IF
''',' 01 WS-K                   BINARY-LONG.\n')
extra+=prog('EF6-SULFUR-HEAD','''     MOVE 0 TO L-O(1)
     MOVE 0.625 TO L-O(2)
     MOVE 0.84210527 TO L-O(3) L-O(4)
''')
write_section_src(7,hdr,IDS,extra); write_layers(IDS)
