from prog6 import *
verts=[(1,'L','0.4999','V1'),(1,'0','0.4999','V0'),(2,'0','0','V0'),(2,'L','0','V1'),(3,'L','0.4999','V1'),(3,'0','0.4999','V0'),(4,'0','0','V0'),(4,'L','0','V1'),
       (5,'L','0.5','F+0.5'),(6,'L','1','F+0.5'),(7,'L','1','F'),(8,'L','0.5','F')]
ang=[('0.2','3.141592653589793'),('0.2','0'),('0.2','1.5707963267948966'),('0.2','4.71238898038469'),('0.282','2.356194490192345'),('0.282','0.7853981633974483'),('0.282','5.497787143782138'),('0.282','3.9269908169872414')]
def build():
    qb=''
    for k,(p,y,u,v) in enumerate(verts):
        b=k*5
        qb+='     MOVE WS-PX(%d) TO L-O(%d)\n'%(p,b+1)
        qb+='     %s\n'%('MOVE WS-LL TO L-O(%d)'%(b+2) if y=='L' else 'MOVE 0 TO L-O(%d)'%(b+2))
        qb+='     MOVE WS-PZ(%d) TO L-O(%d)\n     MOVE %s TO L-O(%d)\n'%(p,b+3,u,b+4)
        ve={'V1':'WS-V1','V0':'WS-V0','F+0.5':'WS-F + 0.5','F':'WS-F'}[v]
        qb+='     COMPUTE L-O(%d) = %s\n'%(b+5,ve)
    pts=''
    for k,(r,a) in enumerate(ang,1):
        pts+='     COMPUTE WS-PX(%d) = %s * FUNCTION COS(L-I(1) + %s)\n     COMPUTE WS-PZ(%d) = %s * FUNCTION SIN(L-I(1) + %s)\n'%(k,r,a,k,r,a)
    head='     MOVE L-I(2) TO WS-LL\n     COMPUTE WS-PH = FUNCTION MOD(L-I(3) * 0.5, 1)\n     COMPUTE WS-V0 = -1 + WS-PH\n     COMPUTE WS-V1 = WS-V0 + WS-LL * 2.5\n     COMPUTE WS-N = FUNCTION INTEGER(L-I(3))\n     MOVE 0 TO WS-F\n     IF FUNCTION MOD(WS-N, 2) = 0\n         MOVE 0.5 TO WS-F\n     END-IF\n'
    ws=' 01 WS-LL                  FLOAT-LONG.\n 01 WS-PH                  FLOAT-LONG.\n 01 WS-V0                  FLOAT-LONG.\n 01 WS-V1                  FLOAT-LONG.\n 01 WS-F                   FLOAT-LONG.\n 01 WS-N                   BINARY-LONG.\n 01 WS-P8.\n    05 WS-PX               FLOAT-LONG OCCURS 8 TIMES.\n    05 WS-PZ               FLOAT-LONG OCCURS 8 TIMES.\n'
    q=prog('EF6-GUARDIAN-BEAM-QUADS',head+pts+qb,ws)
    q+=prog('EF6-ELDER-PARTICLE','''     COMPUTE WS-F = (L-I(1) + L-I(2)) / 30
     COMPUTE L-O(1) = 0.05 + 0.5 * FUNCTION SIN(WS-F * 3.1415927)
     MOVE 3 TO L-O(2)
     MOVE 6 TO L-O(3)
     COMPUTE L-O(4) = 60 - 150 * WS-F
     MOVE 0 TO L-O(5) L-O(6)
     MOVE 2 TO L-O(7)
     MOVE 0.42553192 TO L-O(8)
     MOVE -0.42553192 TO L-O(9) L-O(10)
     MOVE 1 TO L-O(11)
     MOVE 0 TO L-O(12)
     MOVE -0.56 TO L-O(13)
     MOVE 3.5 TO L-O(14)
''',' 01 WS-F                   FLOAT-LONG.\n')
    return q
