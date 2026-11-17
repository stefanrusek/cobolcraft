*> Coverage test, group B (worldgen entity channel, core/src/gen-ent.cob GENT-KEEP): three requests of the level's list are kept into a job that has room for one: the first fills the job
*> (16 kept), the other two do not fit and are counted as lost in the job, and the level's list is empty afterwards.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-COVE-B-GEN-ENT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY GENENT.
 01 WS-JOB.
    COPY GENJOB REPLACING LEADING ==GJ-== BY ==J-==.
 01 WS-X                   FLOAT-LONG VALUE 1.
 01 WS-Y                   FLOAT-LONG VALUE 64.
 01 WS-Z                   FLOAT-LONG VALUE 5.
 01 WS-YAW                 FLOAT-SHORT VALUE 90.
 01 WS-LEN                 BINARY-LONG VALUE 1.
 01 WS-NBT                 PIC X(1344) VALUE LOW-VALUES.
 01 WS-I                   BINARY-LONG.
 PROCEDURE DIVISION.
     MOVE "N" TO TL-MODE
     MOVE 0 TO GEL-COUNT GEL-LOST J-ENT-COUNT J-ENT-LOST
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 3
         CALL "GENT-ADD" USING WS-X WS-Y WS-Z WS-YAW WS-LEN WS-NBT
     END-PERFORM
     MOVE 15 TO J-ENT-COUNT
     CALL "GENT-KEEP" USING WS-JOB
     MOVE "test cove b gen ent: three requests into a job with room for one: 16 kept, 2 lost, the level's list empty" TO TL-CASE
     COMPUTE TL-OBSERVED-N = J-ENT-COUNT * 1000 + J-ENT-LOST * 100 + GEL-COUNT + GEL-LOST
     MOVE 16200 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     GOBACK.
 END PROGRAM TEST-COVE-B-GEN-ENT.
