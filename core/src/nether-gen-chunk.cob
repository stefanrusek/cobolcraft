*> The Nether chunk generator (docs/protocol/37-nether-2 to 4; T1635 to T1688): a whole chunk of the dimension minecraft:the_nether made atomically in
*> the CELLS.cpy format (min y 0, 16 sections): the density grid and fill (nether-37-2.cob), the biome cells (nether-37-3.cob), the surface pass
*> (nether-37-4.cob) and the cave carver (nether-37-4b.cob). The features of 37-5 and the structures of 37-6 are made by their own stages.
*> Pure of the dimension plumbing: all state is NETHER.cpy, rebuilt when the seed or the noise store changes.
*>
*> Entry point:
*>   NETHER-GEN-CHUNK USING world seed (BINARY-DOUBLE, signed: the level seed, CW-SEED), chunk x, chunk z (BINARY-LONG), chunk memory (the
*>     CELLS.cpy block; block states and biomes are written, light is left alone), marker-y out (BINARY-LONG, always -1: no marker pillar).
*>   It needs the block table (CBLOCKS.cpy; minecraft:netherrack, lava, bedrock, basalt, gravel, blackstone, soul_sand, soul_soil, the two nylium and
*>   two wart blocks) and the biome table (the five Nether biomes) of the open world.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. NETHER-GEN-CHUNK.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CELLS.
 LINKAGE SECTION.
 01 L-SEED                 BINARY-DOUBLE.
 01 L-CX                   BINARY-LONG.
 01 L-CZ                   BINARY-LONG.
 01 L-CHUNK                PIC X.
 01 L-MARKER-Y             BINARY-LONG.
 PROCEDURE DIVISION USING L-SEED L-CX L-CZ L-CHUNK L-MARKER-Y.
     SET ADDRESS OF CE-CHUNK TO ADDRESS OF L-CHUNK
     MOVE -1 TO L-MARKER-Y
     MOVE LOW-VALUES TO CE-STATES
     MOVE LOW-VALUES TO CE-BIOMES
     CALL "NETHER-SETUP" USING L-SEED
     CALL "NETHER-STATES"
     CALL "NETHER-CORNERS" USING L-CX L-CZ
     CALL "NETHER-FILL" USING L-CHUNK
     CALL "NETHER-BIOME-GRID" USING L-CX L-CZ
     CALL "NETHER-BIOME-STORE" USING L-CHUNK
     CALL "NETHER-SURFACE" USING L-CHUNK L-CX L-CZ
     GOBACK.
 END PROGRAM NETHER-GEN-CHUNK.
