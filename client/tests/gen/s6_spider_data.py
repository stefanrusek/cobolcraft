import doc6
RB=('-15','-1','-1','16','2','2'); LB=('-1','-1','-1','16','2','2')
LEGS=[('right_hind_leg',-4,15,2,0,0.7853982,-0.7853982,'R'),('left_hind_leg',4,15,2,0,-0.7853982,0.7853982,'L'),
 ('right_middle_hind_leg',-4,15,1,0,0.3926991,-0.58119464,'R'),('left_middle_hind_leg',4,15,1,0,-0.3926991,0.58119464,'L'),
 ('right_middle_front_leg',-4,15,0,0,-0.3926991,-0.58119464,'R'),('left_middle_front_leg',4,15,0,0,0.3926991,0.58119464,'L'),
 ('right_front_leg',-4,15,-1,0,-0.7853982,-0.7853982,'R'),('left_front_leg',4,15,-1,0,0.7853982,0.7853982,'L')]
def rows():
    r=['P head root 0 15 -3 0 0 0','C head 32 4 -4 -4 -8 8 8 8 0 0','P body0 root 0 15 0 0 0 0','C body0 0 0 -3 -3 -3 6 6 6 0 0','P body1 root 0 15 9 0 0 0','C body1 0 12 -5 -4 -6 10 8 12 0 0']
    for n,x,y,z,rx,ry,rz,s in LEGS:
        b=RB if s=='R' else LB
        r.append('P %s root %s %s %s %s %s %s'%(n,x,y,z,rx,ry,rz))
        r.append('C %s 18 0 %s %s %s %s %s %s 0 %d'%(n,b[0],b[1],b[2],b[3],b[4],b[5],1 if s=='L' else 0))
    return r
