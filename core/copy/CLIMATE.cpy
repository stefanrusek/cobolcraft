*> The parameter points of the multi-noise biome source (docs/protocol/10 section 7.2; core/src/climate.cob). EXTERNAL.
*> A point: the biome key, the quantised interval (minimum, maximum) of temperature, humidity, continentalness, erosion,
*> depth and weirdness, and the quantised offset. CL-COUNT points in registration (list) order.
 78 CL-MAX-POINTS          VALUE 8192.
 01 CL-STORE EXTERNAL.
    05 CL-COUNT             BINARY-LONG.
    05 CL-POINT OCCURS 8192 TIMES.
       10 CL-BIOME          PIC X(40).
       10 CL-MIN            BINARY-DOUBLE OCCURS 6 TIMES.
       10 CL-MAX            BINARY-DOUBLE OCCURS 6 TIMES.
       10 CL-OFFSET         BINARY-DOUBLE.
*> The memo of CLIMATE-BIOME-AT (core/src/climate.cob): the biome of a quart cell is read from the six router functions and the
*> point table once, until the seed (DENSITY-SETUP) or the points (CLIMATE-POINTS-RESET, CLIMATE-POINT-ADD) change. Direct mapped:
*> the entry of a cell holds its key and its answer, valid while its CM-STAMP is the generation CM-GEN plus 1 (a reset raises the generation; a never written entry holds 0).
 78 CM-SIZE               VALUE 32768.
 01 CL-MEMO EXTERNAL.
    05 CM-GEN               BINARY-LONG.
    05 CM-ENTRY OCCURS 32768 TIMES.
       10 CM-STAMP          BINARY-LONG.
       10 CM-QX             BINARY-LONG.
       10 CM-QY             BINARY-LONG.
       10 CM-QZ             BINARY-LONG.
       10 CM-INDEX          BINARY-LONG.
       10 CM-BIOME          PIC X(40).
