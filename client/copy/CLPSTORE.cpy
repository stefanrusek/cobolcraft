*> The live particle store (client/src/particles-live.cob). One EXTERNAL block per process, owned by the
*> particle programs and not part of CLIENT-STATE: the library's ENGINE record (CLENG.cpy, about 800 KB: four
*> groups of 16384 handles, the add queue, the emitter queue) is far too large to sit inside the client
*> state that every program receives by reference. A particle handle of the engine is its slot number in
*> PQ-SLOT. PQ-DATA holds the PCL record of CLPCL.cpy byte for byte (240 bytes; the field is 256 so a
*> larger record would be caught by the size test of test_particles_live). PQ-CLASS is the provider
*> class (1 heart, 2 crit, 3 poof and spit, 4 cloud and sneeze, 5 explosion, 6 sweep attack, 7 the smoke
*> family), PQ-TYPE the registry id of the particle type (42-1 section 2). Two clients in one process share this store (the process owns one view of the world).
 78 PQ-MAX                  VALUE 2048.
 01 PQ-STORE EXTERNAL.
    05 PQ-LIVE              BINARY-LONG.
    05 PQ-SLOT              OCCURS 2048 TIMES.
       10 PQ-USED           BINARY-LONG.
       10 PQ-CLASS          BINARY-LONG.
       10 PQ-TYPE           BINARY-LONG.
       10 PQ-DATA           PIC X(256).
 COPY CLENG REPLACING ==01 ENGINE.== BY ==01 ENGINE EXTERNAL.==.
