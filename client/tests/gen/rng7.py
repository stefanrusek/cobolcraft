M=(1<<48)-1; MUL=25214903917
class R:
    def __init__(s,seed): s.st=(seed^MUL)&M
    def next(s,bits):
        s.st=(s.st*MUL+11)&M
        v=s.st>>(48-bits)
        if v>=1<<31: v-=1<<32
        return v
    def nextFloat(s): return s.next(24)*5.9604645e-8
    def nextInt(s,b):
        if b&(b-1)==0: return (b*s.next(31))>>31
        while True:
            r=s.next(31); m=r%b
            if r-m+(b-1) < (1<<31): return m
if __name__=='__main__':
    r=R(1660); print([r.nextInt(7)+8 for _ in range(9)])
