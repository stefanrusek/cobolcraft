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
