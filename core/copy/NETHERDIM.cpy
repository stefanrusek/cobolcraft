*> Switch of the Nether's seam (nether-dim.cob). ND-PLACEHOLDER 1 keeps the placeholder terrain (nether-gen-placeholder.cob) even when the tables
*> hold what the real generator needs: the portal tests that pin exact heights of the placeholder set it; 0 (the start value) is the real generator.
 01 NETHER-DIM-SWITCH EXTERNAL.
    05 ND-PLACEHOLDER         BINARY-LONG.
