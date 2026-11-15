*> Test of BIOME-CLIMATE-JSON (core/src/biome-climate.cob): has_precipitation, temperature and temperature_modifier read from the strict
*> JSON of a biome entry (a standard set), the members that are absent or a text that is not JSON leave the outputs as they were.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-BIOME-CLIMATE-JSON.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 01 WS-DOC                 PIC X(200).
 01 WS-LENGTH              BINARY-LONG.
 01 WS-PRECIPITATION       BINARY-LONG.
 01 WS-TEMPERATURE         FLOAT-LONG.
 01 WS-FROZEN              BINARY-LONG.
 01 WS-TEXT                PIC -9.99.
 01 WS-P                   PIC 9.
 01 WS-F                   PIC 9.
 PROCEDURE DIVISION.
     MOVE "test biome climate json: a frozen biome with rain" TO TL-CASE
     MOVE '{"downfall":0.5,"has_precipitation":true,"temperature":0.0,"temperature_modifier":"frozen"}' TO WS-DOC
     PERFORM READ-DOC
     MOVE "1 0.00 1" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "test biome climate json: a dry hot biome, the modifier none" TO TL-CASE
     MOVE '{"has_precipitation":false,"temperature":2.0,"temperature_modifier":"none"}' TO WS-DOC
     PERFORM READ-DOC
     MOVE "0 2.00 0" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "test biome climate json: absent members leave the outputs as they were" TO TL-CASE
     MOVE '{"downfall":0.5}' TO WS-DOC
     PERFORM READ-DOC
     MOVE "1 0.30 0" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "test biome climate json: a text that is not JSON leaves the outputs as they were" TO TL-CASE
     MOVE '{"temperature":' TO WS-DOC
     PERFORM READ-DOC
     MOVE "1 0.30 0" TO TL-EXPECTED
     PERFORM CHECK
     STOP RUN.

 READ-DOC.
     MOVE 1 TO WS-PRECIPITATION
     MOVE 0.3 TO WS-TEMPERATURE
     MOVE 0 TO WS-FROZEN
     MOVE FUNCTION LENGTH(FUNCTION TRIM(WS-DOC)) TO WS-LENGTH
     CALL "BIOME-CLIMATE-JSON" USING WS-DOC WS-LENGTH WS-PRECIPITATION WS-TEMPERATURE WS-FROZEN.

 CHECK.
     COMPUTE WS-TEXT ROUNDED = WS-TEMPERATURE
     MOVE WS-PRECIPITATION TO WS-P
     MOVE WS-FROZEN TO WS-F
     MOVE SPACES TO TL-OBSERVED
     STRING WS-P " " FUNCTION TRIM(WS-TEXT) " " WS-F DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "T" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-BIOME-CLIMATE-JSON.
