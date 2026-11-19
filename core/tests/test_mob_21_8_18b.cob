*> The sound of the wind charge bursts (docs/protocol/21 section 8.18, 46: entity.wind_charge.wind_burst 1776, entity.breeze.wind_burst 210; lane p49t, T39080): the Explode packet (05a 0x24) carries the registered
*> sound holder (VarInt id + 1: 1777 for a wind charge of radius 1.2, 211 for a breeze wind charge of radius 3.0), not the generic explode sound; the packet ends with no block particles and play sound true.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-MOB-21-8-18B.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY PROTO.
 01 WS-CAPACITY            BINARY-LONG VALUE 256.
 01 WS-X                   FLOAT-LONG VALUE 1.
 01 WS-Y                   FLOAT-LONG VALUE 2.
 01 WS-Z                   FLOAT-LONG VALUE 3.
 01 WS-RADIUS              FLOAT-LONG.
 01 WS-KNOCK               BINARY-LONG VALUE 0.
 01 WS-KX                  FLOAT-LONG VALUE 0.
 01 WS-KY                  FLOAT-LONG VALUE 0.
 01 WS-KZ                  FLOAT-LONG VALUE 0.
 01 WS-VALUE               BINARY-LONG.
 01 WS-DOUBLE              FLOAT-LONG.
 01 WS-FLOAT               FLOAT-SHORT.
 01 WS-INT                 BINARY-LONG.
 01 WS-BOOL                BINARY-LONG.
 01 WS-PARTICLE            BINARY-LONG.
 01 WS-DATA                PIC X(64).
 01 WS-LENGTH              BINARY-LONG.
 01 WS-SOUND               BINARY-LONG.
 PROCEDURE DIVISION.
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     MOVE "N" TO TL-MODE
     MOVE 1.2 TO WS-RADIUS
     PERFORM BUILD-AND-READ
     MOVE "acceptance US15 minecraft:wind_charge 21§8.18 the Explode packet carries entity.wind_charge.wind_burst (holder 1776 + 1)" TO TL-CASE
     MOVE 1777 TO TL-EXPECTED-N
     MOVE WS-SOUND TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 minecraft:wind_charge 21§8.18 the wind charge packet is read to its end with no error" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = PB-ERROR + (PB-LENGTH - PB-POS)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 3.0 TO WS-RADIUS
     PERFORM BUILD-AND-READ
     MOVE "acceptance US15 minecraft:breeze_wind_charge 21§8.18 the Explode packet carries entity.breeze.wind_burst (holder 210 + 1)" TO TL-CASE
     MOVE 211 TO TL-EXPECTED-N
     MOVE WS-SOUND TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 minecraft:breeze_wind_charge 21§8.18 the breeze packet is read to its end with no error" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = PB-ERROR + (PB-LENGTH - PB-POS)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.

*> Builds the packet for WS-RADIUS and reads it field by field up to and including the sound holder, the block particles and play sound.
 BUILD-AND-READ.
     CALL "PB-RESET" USING PB-BUFFER
     CALL "WIND-BUILD" USING WS-X WS-Y WS-Z WS-RADIUS WS-KNOCK WS-KX WS-KY WS-KZ PB-BUFFER
     MOVE 0 TO PB-POS
     CALL "PB-GET-VARINT" USING PB-BUFFER WS-VALUE
     CALL "PB-GET-DOUBLE" USING PB-BUFFER WS-DOUBLE
     CALL "PB-GET-DOUBLE" USING PB-BUFFER WS-DOUBLE
     CALL "PB-GET-DOUBLE" USING PB-BUFFER WS-DOUBLE
     CALL "PB-GET-FLOAT" USING PB-BUFFER WS-FLOAT
     CALL "PB-GET-INT" USING PB-BUFFER WS-INT
     CALL "PB-GET-BOOL" USING PB-BUFFER WS-BOOL
     CALL "PB-GET-PARTICLE" USING PB-BUFFER WS-PARTICLE WS-LENGTH WS-DATA
     CALL "PB-GET-VARINT" USING PB-BUFFER WS-SOUND
     CALL "PB-GET-VARINT" USING PB-BUFFER WS-INT
     CALL "PB-GET-BOOL" USING PB-BUFFER WS-BOOL.
 END PROGRAM TEST-MOB-21-8-18B.
