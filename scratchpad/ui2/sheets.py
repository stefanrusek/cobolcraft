import hashlib, sys
def hexc(s): return bytes.fromhex(s)
W=H=256
PAR=dict(O='2A2A2AFF',HI='F4EFDDFF',LO='8C8366FF',F='D8D0B4FF')
def new(): return bytearray(W*H*4)
def put(img,x,y,c): img[(y*W+x)*4:(y*W+x)*4+4]=hexc(c)
def bevel(img,bw,bh,O,HI,LO,F,b,r,ox=0,oy=0):
    for y in range(bh):
        for x in range(bw):
            put(img,ox+x,oy+y,O)
            if 1<=x<=bw-2 and 1<=y<=bh-2:
                put(img,ox+x,oy+y,F)
                if y<=b or x<=b: put(img,ox+x,oy+y,HI)
                if y>=bh-1-b or x>=bw-1-b: put(img,ox+x,oy+y,LO)
    if r==1:
        for (x,y) in ((0,0),(bw-1,0),(0,bh-1),(bw-1,bh-1)):
            img[((oy+y)*W+ox+x)*4:((oy+y)*W+ox+x)*4+4]=b'\0\0\0\0'
def frame(img,x0,y0,fw,fh,TL,BR,F,t):
    for dy in range(fh):
        for dx in range(fw):
            c=F
            if dy<t or dx<t: c=TL
            if dy>=fh-t or dx>=fw-t: c=BR
            put(img,x0+dx,y0+dy,c)
def rect(img,x0,y0,x1,y1,c):
    for y in range(y0,y1+1):
        for x in range(x0,x1+1): put(img,x,y,c)
def tri(img,a,b,c,col):
    for y in range(H):
        for x in range(W):
            e1=(b[0]-a[0])*(y-a[1])-(b[1]-a[1])*(x-a[0])
            e2=(c[0]-b[0])*(y-b[1])-(c[1]-b[1])*(x-b[0])
            e3=(a[0]-c[0])*(y-c[1])-(a[1]-c[1])*(x-c[0])
            if (e1>=0 and e2>=0 and e3>=0) or (e1<=0 and e2<=0 and e3<=0): put(img,x,y,col)
SL=('5E5740FF','F4EFDDFF','A39A7AFF')
def slots_inv():
    s=[]
    for row in range(3):
        for col in range(9): s.append((8+18*col,84+18*row))
    for i in range(9): s.append((8+18*i,142))
    for i in range(4): s.append((8,8+18*i))
    for row in range(2):
        for col in range(2): s.append((98+18*col,18+18*row))
    s.append((77,62))
    return s
def inventory():
    img=new()
    bevel(img,176,166,PAR['O'],PAR['HI'],PAR['LO'],PAR['F'],2,1)
    for (x,y) in slots_inv(): frame(img,x-1,y-1,18,18,*SL,1)
    frame(img,151,25,22,22,*SL,2)
    frame(img,26,8,50,71,'14141AFF','55556AFF','2B2B33FF',1)
    rect(img,135,35,141,37,'6F674DFF'); tri(img,(142,32),(142,40),(147,36),'6F674DFF')
    return img
def crafting():
    img=new()
    bevel(img,176,166,PAR['O'],PAR['HI'],PAR['LO'],PAR['F'],2,1)
    s=[]
    for row in range(3):
        for col in range(9): s.append((8+18*col,84+18*row))
    for i in range(9): s.append((8+18*i,142))
    for row in range(3):
        for col in range(3): s.append((30+18*col,17+18*row))
    for (x,y) in s: frame(img,x-1,y-1,18,18,*SL,1)
    frame(img,121,32,22,22,*SL,2)
    rect(img,90,42,107,44,'6F674DFF'); tri(img,(106,38),(106,48),(114,43),'6F674DFF')
    return img
def book():
    img=new()
    bevel(img,147,166,PAR['O'],PAR['HI'],PAR['LO'],PAR['F'],2,1)
    return img
for n,f in (('inventory',inventory),('crafting',crafting),('book',book)):
    i=f(); nz=sum(1 for p in range(0,len(i),4) if i[p:p+4]!=b'\0\0\0\0')
    print(n,nz,hashlib.sha256(bytes(i)).hexdigest())
