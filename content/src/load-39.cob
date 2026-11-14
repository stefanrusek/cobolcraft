*> The loader of docs/protocol/39-portals.md (portals and dimension travel). LOAD-39 USING root (PIC X(1100): the folder that
*> holds data/), status out (CT-OK, CT-BAD-DATA; every error is on standard error as "ERROR registry: ..." and nothing of the
*> load stays). The document defines no data file of its own; section 1.2 names the data it reads, and the loader checks the
*> shapes of those files through the shape engine (shapes.cob, CTSHAPE.cpy):
*>   dimension_type (group dimension_type): coordinate_scale (number, 0.00001 to 30000000: 04 section 6), min_y, height and
*>     logical_height (integers; section 1.2, all four read from every dimension type), attributes (an object: the map of 38
*>     section 2; the key minecraft:gameplay/nether_portal_spawns_piglin is longer than the 32 bytes of a member name of the
*>     engine, so the attribute values are not checked);
*>   tags/block (group tag): the tag grammar of 23 section 6.1, "values" (an array of identifiers, "#" tags and
*>     {id, required} objects, required) and "replace" (boolean, optional); the tags of the document are nether_portal_frame
*>     and fire.
*> The point of interest type nether_portal and the game rules of section 1.2 are not data files (no registry of
*> 23 section 2.1 holds them): they are code constants of the portal engine. The dimension type fields of the phase 22 loader
*> (dimensions.cob) are loaded by that loader; this one only checks what the portal engine reads.
*> No member name of this loader is an assumption: every name is stated by 04, 23, 38 or section 1.2.
*> Engine limits worked around here: the entries of "values" are not checked one by one.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. LOAD-39.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-ROWS.
    05 FILLER PIC X(24) VALUE "dimension_type".
    05 FILLER PIC X(48) VALUE "-".
    05 FILLER PIC X(600) VALUE "N coordinate_scale=0.00001..30000000;I min_y;I height;I logical_height;o attributes".
    05 FILLER PIC X(24) VALUE "tag".
    05 FILLER PIC X(48) VALUE "-".
    05 FILLER PIC X(600) VALUE "A values;b replace".
 01 WS-ROW-COUNT           BINARY-LONG VALUE 2.
 01 WS-DIMENSION           PIC X(48) VALUE "dimension_type".
 01 WS-DIMENSION-GROUP     PIC X(24) VALUE "dimension_type".
 01 WS-TAGS                PIC X(48) VALUE "tags/block".
 01 WS-TAG-GROUP           PIC X(24) VALUE "tag".
 01 WS-LENIENT             BINARY-LONG VALUE 0.
 LINKAGE SECTION.
 01 L-DIR                  PIC X(1100).
 01 L-STATUS               BINARY-LONG.
 PROCEDURE DIVISION USING L-DIR L-STATUS.
     CALL "SHAPE-BEGIN"
     CALL "SHAPE-REGISTER" USING WS-ROWS WS-ROW-COUNT
     CALL "SHAPE-LOAD" USING L-DIR WS-DIMENSION WS-DIMENSION-GROUP WS-LENIENT
     CALL "SHAPE-LOAD" USING L-DIR WS-TAGS WS-TAG-GROUP WS-LENIENT
     CALL "SHAPE-END" USING L-STATUS
     GOBACK.
 END PROGRAM LOAD-39.
