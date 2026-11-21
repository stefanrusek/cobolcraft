from mesh7 import *
import math
def wither_rows(g):
    c0=0.20420352
    r=['P shoulders root 0 0 0 0 0 0','C shoulders 0 16 -10 3.9 -0.5 20 3 3 %s 0'%g,
       'P ribcage root -2 6.9 -0.5 %s 0 0'%c0,'C ribcage 0 22 0 0 0 3 10 3 %s 0'%g,'C ribcage 24 22 -4 1.5 0.5 11 2 2 %s 0'%g,'C ribcage 24 22 -4 4 0.5 11 2 2 %s 0'%g,'C ribcage 24 22 -4 6.5 0.5 11 2 2 %s 0'%g,
       'P tail root -2 %s %s 0.83252203 0 0'%(lit(6.9+math.cos(c0)*10),lit(-0.5+math.sin(c0)*10)),'C tail 12 22 0 0 0 3 6 3 %s 0'%g,
       'P center_head root 0 0 0 0 0 0','C center_head 0 0 -4 -4 -4 8 8 8 %s 0'%g,
       'P right_head root -8 4 0 0 0 0','C right_head 32 0 -4 -4 -4 6 6 6 %s 0'%g,'P left_head root 10 4 0 0 0 0','C left_head 32 0 -4 -4 -4 6 6 6 %s 0'%g]
    return r
def define():
    setlayer('WITHER',wither_rows(0),64,64); setlayer('WITHER_ARMOR',wither_rows(0.5),64,64)
    setlayer('WITHER_SKULL',['P head root 0 0 0 0 0 0','C head 0 35 -4 -8 -4 8 8 8 0 0'],64,64)
