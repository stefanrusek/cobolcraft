*> The state of the classic carvers (core/src/carvers.cob; docs/protocol/11 section 5). EXTERNAL: the world seed and the float
*> constants set by CARVER-SETUP, the carver mode and the cave floor of the ellipsoid being carved (CV-SX, CV-SZ the source chunk being walked from; CV-MODE 0 cave, 1 canyon), the
*> canyon's width factors of its 384 layers, and the parameters drawn for the cave and the tunnel being walked (so that a test can
*> read what the draws gave). The constants are single precision values (each rounded to float32 once).
 01 CV-STATE EXTERNAL.
    05 CV-READY             BINARY-LONG.
    05 CV-SEED              BINARY-DOUBLE UNSIGNED.
    05 CV-SX               BINARY-LONG.
    05 CV-SZ               BINARY-LONG.
    05 CV-MODE              BINARY-LONG.
    05 CV-FLOOR             FLOAT-LONG.
    05 CV-PI                FLOAT-LONG.
    05 CV-TWO-PI            FLOAT-LONG.
    05 CV-HALF-PI           FLOAT-LONG.
    05 CV-K092              FLOAT-LONG.
    05 CV-K07               FLOAT-LONG.
    05 CV-K01               FLOAT-LONG.
    05 CV-K09               FLOAT-LONG.
    05 CV-K075              FLOAT-LONG.
    05 CV-K005              FLOAT-LONG.
    05 CV-K08               FLOAT-LONG.
    05 CV-PROB-CAVE         FLOAT-LONG.
    05 CV-PROB-EXTRA        FLOAT-LONG.
    05 CV-PROB-CANYON       FLOAT-LONG.
    05 CV-HALF              FLOAT-LONG.
    05 CV-ONE               FLOAT-LONG.
    05 CV-TWO               FLOAT-LONG.
    05 CV-THREE             FLOAT-LONG.
    05 CV-FOUR              FLOAT-LONG.
    05 CV-SIX               FLOAT-LONG.
    05 CV-SIXTEEN           FLOAT-LONG.
    05 CV-ONE-HALF          FLOAT-LONG.
    05 CV-NEG-ONE           FLOAT-LONG.
    05 CV-NEG-04            FLOAT-LONG.
    05 CV-HMUL-LO           FLOAT-LONG.
    05 CV-HMUL-HI           FLOAT-LONG.
    05 CV-VMUL-LO           FLOAT-LONG.
    05 CV-VMUL-HI           FLOAT-LONG.
    05 CV-ROOMV-LO          FLOAT-LONG.
    05 CV-ROOMV-HI          FLOAT-LONG.
    05 CV-ROT-LO            FLOAT-LONG.
    05 CV-ROT-HI            FLOAT-LONG.
    05 CV-WIDTH             FLOAT-LONG OCCURS 384 TIMES.
 01 CV-CAVE EXTERNAL.
    05 CV-CAVE-X            BINARY-LONG.
    05 CV-CAVE-Y            BINARY-LONG.
    05 CV-CAVE-Z            BINARY-LONG.
    05 CV-CAVE-HMUL         FLOAT-LONG.
    05 CV-CAVE-VMUL         FLOAT-LONG.
    05 CV-CAVE-FLOOR        FLOAT-LONG.
    05 CV-CAVE-ROOM         BINARY-LONG.
    05 CV-CAVE-ROOMV        FLOAT-LONG.
    05 CV-CAVE-ROOMR        FLOAT-LONG.
    05 CV-CAVE-TUNNELS      BINARY-LONG.
 01 CV-TUNNEL EXTERNAL.
    05 CV-TUN-YAW           FLOAT-LONG.
    05 CV-TUN-PITCH         FLOAT-LONG.
    05 CV-TUN-THICK         FLOAT-LONG.
    05 CV-TUN-STEPS         BINARY-LONG.
    05 CV-TUN-SEED          BINARY-DOUBLE UNSIGNED.
