*> Constants of the block-update machinery (docs/protocol/29 section 1): the setBlock flag bits, the combined flag
*> constants and the recursion budget. Directions are numbered as in the document's Direction ordinals: 0 down,
*> 1 up, 2 north, 3 south, 4 west, 5 east (see BU-DIRECTION, blockupd-29.cob).
 78 BU-UPDATE-NEIGHBORS                  VALUE 1.
 78 BU-UPDATE-CLIENTS                    VALUE 2.
 78 BU-UPDATE-INVISIBLE                  VALUE 4.
 78 BU-UPDATE-IMMEDIATE                  VALUE 8.
 78 BU-UPDATE-KNOWN-SHAPE                VALUE 16.
 78 BU-UPDATE-SUPPRESS-DROPS             VALUE 32.
 78 BU-UPDATE-MOVE-BY-PISTON             VALUE 64.
 78 BU-UPDATE-SKIP-SHAPE-ON-WIRE         VALUE 128.
 78 BU-UPDATE-SKIP-BLOCK-ENTITY-SIDEEFFECTS VALUE 256.
 78 BU-UPDATE-SKIP-ON-PLACE              VALUE 512.
 78 BU-UPDATE-NONE                       VALUE 260.
 78 BU-UPDATE-ALL                        VALUE 3.
 78 BU-UPDATE-ALL-IMMEDIATE              VALUE 11.
 78 BU-UPDATE-SKIP-ALL-SIDEEFFECTS       VALUE 816.
 78 BU-UPDATE-LIMIT                      VALUE 512.
