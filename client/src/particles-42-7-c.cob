*> Particles part 7 (docs/protocol/42-particles-7-emitters-entities-events-commands.md), section 3: explosions. The conventions are those of particles-42-7.cob: draws in
*> EM-DRAW, particles out in the rows of client/copy/CLP6EM.cpy; the table programs take IN of 16 and OUT of 64 FLOAT-LONG.
*> Entry points for the integrator (inputs):
*>   P7-EXPLOSION site(X(24)) IN(16 floats) P6-EMITS: site block_particle IN(centre x y z, radius, the block at the drawn point is not air): one block-explosion particle of the client
*>     tracker (3.2 steps 1 to 6 with the default list of 3.3; 4 draws, and 3 more when the block is air); gust_seed IN(x y z, scale, lifetime, delay, age): one tick of GustSeedParticle
*>     (3.4, 18 draws when age mod (delay + 1) is 0); packet_particle IN(centre x y z): the particle of the Explode packet added once with velocity (1, 0, 0) (3.2 step 2).
*>   P7-EXPLOSION-KIND IN(radius, does not interact with blocks) OUT(1 when the small particle is used): 3.1 step 3. P7-EXPLOSION-SEND IN(squared distance) OUT(1 when the packet is sent).
*>   P7-EXPLOSION-N IN(particle setting is ALL, total block count) OUT(particles this tick): min(W, 512), 0 unless ALL (3.2). P7-EXPLOSION-PICK IN(r, n, block counts 1..n)
*>     OUT(1-based explosion picked by nextInt(W) = floor(r W), 0 when W is 0). P7-EXPLOSION-LIST OUT(entries, scaling 1, speed 1, scaling 2, speed 2, weight 1, weight 2): 3.3.
*>   P7-EXPLOSION-CALLER IN(caller 1 default (IN 2 = radius), 2 wind charge, 3 breeze wind charge, 4 wind-charged death (IN 2 = nextFloat)) OUT(radius, gust particles, trigger
*>     interaction): the known callers of 3.1. P7-EXPLOSION-PITCH IN(r1, r2) OUT(local sound pitch (1 + (r1 - r2) 0.2) 0.7).

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P7-EXPLOSION.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-N                   PIC X(40).
 01 WS-PV.
    05 WS-V                FLOAT-LONG OCCURS 6 TIMES.
 01 WS-A                   FLOAT-LONG OCCURS 3 TIMES.
 01 WS-LEN                 FLOAT-LONG.
 01 WS-D                   FLOAT-LONG.
 01 WS-R                   FLOAT-LONG.
 01 WS-R2                  FLOAT-LONG.
 01 WS-S                   FLOAT-LONG.
 01 WS-E                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-SC                  FLOAT-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-DRAWS.
    05 WS-DR               FLOAT-LONG OCCURS 6 TIMES.
 LINKAGE SECTION.
 01 L-SITE                 PIC X(24).
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 16 TIMES.
 COPY CLP6EM.
 PROCEDURE DIVISION USING L-SITE L-IN P6-EMITS.
     EVALUATE L-SITE
         WHEN "block_particle"
             PERFORM BLOCK-PARTICLE
         WHEN "gust_seed"
             PERFORM GUST-SEED
         WHEN "packet_particle"
             MOVE "explosion" TO WS-N
             MOVE L-I(1) TO WS-V(1)
             MOVE L-I(2) TO WS-V(2)
             MOVE L-I(3) TO WS-V(3)
             MOVE 1 TO WS-V(4)
             MOVE 0 TO WS-V(5) WS-V(6)
             CALL "P6-EMIT" USING P6-EMITS WS-N WS-PV
     END-EVALUATE
     GOBACK.

 BLOCK-PARTICLE.
     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 3
         CALL "P6-DRAW" USING P6-EMITS WS-R
         COMPUTE WS-A(WS-K) = 2 * WS-R - 1
     END-PERFORM
     COMPUTE WS-LEN = FUNCTION SQRT(WS-A(1) * WS-A(1) + WS-A(2) * WS-A(2) + WS-A(3) * WS-A(3))
     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 3
         COMPUTE WS-A(WS-K) = WS-A(WS-K) / WS-LEN
     END-PERFORM
     CALL "P6-DRAW" USING P6-EMITS WS-R
     COMPUTE WS-D = (WS-R ** (1 / 3)) * L-I(4)
     IF L-I(5) = 0
         CALL "P6-DRAW" USING P6-EMITS WS-R
         CALL "P6-DRAW" USING P6-EMITS WS-R2
         COMPUTE WS-S = (0.5 / (WS-D / L-I(4) + 0.1)) * WS-R * WS-R2 + 0.3
         CALL "P6-DRAW" USING P6-EMITS WS-R
         COMPUTE WS-E = FUNCTION INTEGER-PART(WS-R * 2)
         MOVE "poof" TO WS-N
         MOVE 0.5 TO WS-SC
         IF WS-E = 1
             MOVE "smoke" TO WS-N
             MOVE 1 TO WS-SC
         END-IF
         COMPUTE WS-V(1) = L-I(1) + WS-A(1) * WS-D * WS-SC
         COMPUTE WS-V(2) = L-I(2) + WS-A(2) * WS-D * WS-SC
         COMPUTE WS-V(3) = L-I(3) + WS-A(3) * WS-D * WS-SC
         COMPUTE WS-V(4) = WS-A(1) * WS-S
         COMPUTE WS-V(5) = WS-A(2) * WS-S
         COMPUTE WS-V(6) = WS-A(3) * WS-S
         CALL "P6-EMIT" USING P6-EMITS WS-N WS-PV
     END-IF.

 GUST-SEED.
     COMPUTE WS-E = L-I(7) - (L-I(6) + 1) * FUNCTION INTEGER-PART(L-I(7) / (L-I(6) + 1))
     IF WS-E = 0
         MOVE "gust" TO WS-N
         PERFORM 3 TIMES
             PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 6
                 CALL "P6-DRAW" USING P6-EMITS WS-DR(WS-K)
             END-PERFORM
             COMPUTE WS-V(1) = L-I(1) + (WS-DR(1) - WS-DR(2)) * L-I(4)
             COMPUTE WS-V(2) = L-I(2) + (WS-DR(3) - WS-DR(4)) * L-I(4)
             COMPUTE WS-V(3) = L-I(3) + (WS-DR(5) - WS-DR(6)) * L-I(4)
             COMPUTE WS-V(4) = L-I(7) / L-I(5)
             MOVE 0 TO WS-V(5) WS-V(6)
             CALL "P6-EMIT" USING P6-EMITS WS-N WS-PV
         END-PERFORM
     END-IF.
 END PROGRAM P7-EXPLOSION.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P7-EXPLOSION-KIND.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 16 TIMES.
 01 L-OUT.
    05 L-O                 FLOAT-LONG OCCURS 64 TIMES.
 PROCEDURE DIVISION USING L-IN L-OUT.
     MOVE 0 TO L-O(1)
     IF L-I(1) < 2 OR L-I(2) NOT = 0
         MOVE 1 TO L-O(1)
     END-IF
     GOBACK.
 END PROGRAM P7-EXPLOSION-KIND.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P7-EXPLOSION-SEND.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 16 TIMES.
 01 L-OUT.
    05 L-O                 FLOAT-LONG OCCURS 64 TIMES.
 PROCEDURE DIVISION USING L-IN L-OUT.
     MOVE 0 TO L-O(1)
     IF L-I(1) < 4096
         MOVE 1 TO L-O(1)
     END-IF
     GOBACK.
 END PROGRAM P7-EXPLOSION-SEND.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P7-EXPLOSION-N.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 16 TIMES.
 01 L-OUT.
    05 L-O                 FLOAT-LONG OCCURS 64 TIMES.
 PROCEDURE DIVISION USING L-IN L-OUT.
     MOVE 0 TO L-O(1)
     IF L-I(1) NOT = 0
         MOVE L-I(2) TO L-O(1)
         IF L-O(1) > 512
             MOVE 512 TO L-O(1)
         END-IF
     END-IF
     GOBACK.
 END PROGRAM P7-EXPLOSION-N.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P7-EXPLOSION-PICK.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-W                   FLOAT-LONG.
 01 WS-V                   FLOAT-LONG.
 01 WS-K                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 16 TIMES.
 01 L-OUT.
    05 L-O                 FLOAT-LONG OCCURS 64 TIMES.
 PROCEDURE DIVISION USING L-IN L-OUT.
     MOVE 0 TO L-O(1) WS-W
     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > L-I(2)
         ADD L-I(2 + WS-K) TO WS-W
     END-PERFORM
     COMPUTE WS-V = FUNCTION INTEGER-PART(L-I(1) * WS-W)
     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > L-I(2)
         SUBTRACT L-I(2 + WS-K) FROM WS-V
         IF WS-V < 0 AND L-O(1) = 0
             MOVE WS-K TO L-O(1)
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM P7-EXPLOSION-PICK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P7-EXPLOSION-LIST.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 16 TIMES.
 01 L-OUT.
    05 L-O                 FLOAT-LONG OCCURS 64 TIMES.
 PROCEDURE DIVISION USING L-IN L-OUT.
     MOVE 2 TO L-O(1)
     MOVE 0.5 TO L-O(2)
     MOVE 1 TO L-O(3) L-O(4) L-O(5) L-O(6) L-O(7)
     GOBACK.
 END PROGRAM P7-EXPLOSION-LIST.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P7-EXPLOSION-CALLER.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 16 TIMES.
 01 L-OUT.
    05 L-O                 FLOAT-LONG OCCURS 64 TIMES.
 PROCEDURE DIVISION USING L-IN L-OUT.
     MOVE L-I(2) TO L-O(1)
     MOVE 0 TO L-O(2) L-O(3)
     IF L-I(1) > 1
         MOVE 1 TO L-O(2) L-O(3)
     END-IF
     EVALUATE L-I(1)
         WHEN 2 MOVE 1.2 TO L-O(1)
         WHEN 3 MOVE 3 TO L-O(1)
         WHEN 4 COMPUTE L-O(1) = 3 + 2 * L-I(2)
     END-EVALUATE
     GOBACK.
 END PROGRAM P7-EXPLOSION-CALLER.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P7-EXPLOSION-PITCH.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 16 TIMES.
 01 L-OUT.
    05 L-O                 FLOAT-LONG OCCURS 64 TIMES.
 PROCEDURE DIVISION USING L-IN L-OUT.
     COMPUTE L-O(1) = (1 + (L-I(1) - L-I(2)) * 0.2) * 0.7
     GOBACK.
 END PROGRAM P7-EXPLOSION-PITCH.
