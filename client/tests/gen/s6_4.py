from worm6 import *
r,z=worm(EMITE); setlayer('ENDERMITE',r,64,32)
IDS=['ENDERMITE']
hdr='''*> Entity models part 6 section 4 (Endermite): the four segment mesh (4.1), the age wave of setupAnim (4.2), texture.
*> Entry points for the integrator (inputs; the table programs take IN (16 FLOAT-LONG) and OUT (64 FLOAT-LONG)):
*>   EF6-ENDERMITE-ANIM EMM-MODEL state(1 ageInTicks): reset first, then yRot and pivot x of segment0 to segment3; EF6-ENDERMITE-TEXTURE IN() path(out X(120)).
'''
extra=r''' IDENTIFICATION DIVISION.
 PROGRAM-ID. EF6-ENDERMITE-ANIM.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-NAME                PIC X(24).
 01 WS-P                   BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-D                   BINARY-LONG.
 01 WS-DIG                 PIC 9.
 01 WS-A                   FLOAT-LONG.
 LINKAGE SECTION.
 COPY CLEMM.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 16 TIMES.
 PROCEDURE DIVISION USING EMM-MODEL L-IN.
     CALL "EMM-RESET" USING EMM-MODEL
     PERFORM VARYING WS-I FROM 0 BY 1 UNTIL WS-I > 3
         MOVE SPACES TO WS-NAME
         MOVE WS-I TO WS-DIG
         STRING "segment" WS-DIG DELIMITED BY SIZE INTO WS-NAME
         CALL "EMM-FIND" USING EMM-MODEL WS-NAME WS-P
         COMPUTE WS-A = L-I(1) * 0.9 + WS-I * 0.15 * 3.1415927
         COMPUTE WS-D = FUNCTION ABS(WS-I - 2)
         COMPUTE MM-CYROT(WS-P) = FUNCTION COS(WS-A) * 3.1415927 * 0.01 * (1 + WS-D)
         COMPUTE MM-CX(WS-P) = FUNCTION SIN(WS-A) * 3.1415927 * 0.1 * WS-D
     END-PERFORM
     GOBACK.
 END PROGRAM EF6-ENDERMITE-ANIM.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EF6-ENDERMITE-TEXTURE.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 16 TIMES.
 01 L-PATH                 PIC X(120).
 PROCEDURE DIVISION USING L-IN L-PATH.
     MOVE "textures/entity/endermite/endermite.png" TO L-PATH
     GOBACK.
 END PROGRAM EF6-ENDERMITE-TEXTURE.
'''
write_section_src(4,hdr,IDS,extra); write_layers(IDS)
