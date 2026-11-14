*> The saved dragon fight state of the open world (docs/protocol/45-entity-nbt-9 section 3; 38 section 1): the record ENDFIGHT.cpy of end-38f.cob kept in memory while the world is
*> open, read from <world>/dimensions/minecraft/the_end/data/minecraft/ender_dragon_fight.dat when WORLD-LOAD opens an existing world (a world without the file gets the default of a new
*> End: createDefault, then END-FIGHT-INIT's seeded gateway order) and written by WORLD-SAVE. Nothing happens in a world whose dimensions lack the_end. The boss itself is not here
*> (the fight state is saved, not run).
*>
*> Entry point:
*>   END-FIGHT-IO USING action, record (ENDFIGHT.cpy): 1 load (file or default), 2 save (loads first when the world's record was never loaded), 3 get (copy of the record out), 4 set
*>     (the record in), 5 forget (the next load starts again).

 IDENTIFICATION DIVISION.
 PROGRAM-ID. END-FIGHT-IO.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY DIMENSIONS.
 COPY ENDFIGHT REPLACING ==END-FIGHT== BY ==WS-FIGHT== LEADING ==EF-== BY ==WF-==.
 01 WS-LOADED              BINARY-LONG VALUE 0.
 01 WS-FOLDER              PIC X(1024) VALUE SPACES.
 01 WS-EPOCH-SEED          BINARY-DOUBLE VALUE 0.
 01 WS-END                 BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-DIR                 PIC X(1024).
 01 WS-KIND                PIC X(8) VALUE "data".
 01 WS-PATH                PIC X(1100).
 01 WS-MADE                PIC X(1100).
 01 WS-INFO                PIC X(16).
 LINKAGE SECTION.
 01 L-ACTION               BINARY-LONG.
 COPY ENDFIGHT REPLACING LEADING ==EF-== BY ==L-==.
 PROCEDURE DIVISION USING L-ACTION END-FIGHT.
     EVALUATE L-ACTION
         WHEN 3
             MOVE WS-FIGHT TO END-FIGHT
             GOBACK
         WHEN 4
             MOVE END-FIGHT TO WS-FIGHT
             MOVE 1 TO WS-LOADED
             MOVE CW-FOLDER TO WS-FOLDER
             MOVE CW-SEED TO WS-EPOCH-SEED
             GOBACK
         WHEN 5
             MOVE 0 TO WS-LOADED
             GOBACK
     END-EVALUATE
     MOVE 0 TO WS-END
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > CW-DIM-COUNT
         IF DM-KEY(CW-DIM(WS-I)) = "minecraft:the_end"
             MOVE CW-DIM(WS-I) TO WS-END
         END-IF
     END-PERFORM
     IF WS-END = 0
         GOBACK
     END-IF
     IF WS-FOLDER NOT = CW-FOLDER OR WS-EPOCH-SEED NOT = CW-SEED
         MOVE 0 TO WS-LOADED
     END-IF
     IF L-ACTION = 1 OR WS-LOADED = 0
         CALL "END-FIGHT-LOAD" USING WS-END WS-FIGHT
         MOVE 1 TO WS-LOADED
         MOVE CW-FOLDER TO WS-FOLDER
         MOVE CW-SEED TO WS-EPOCH-SEED
     END-IF
     IF L-ACTION = 2
         CALL "END-FIGHT-SAVE" USING WS-END WS-FIGHT
     END-IF
     GOBACK.
 END PROGRAM END-FIGHT-IO.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. END-FIGHT-PATH.
*> USING the End's dimension row, path out (PIC X(1100)), path length out: <world>/dimensions/minecraft/the_end/data/minecraft/ender_dragon_fight.dat.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-DIR                 PIC X(1024).
 01 WS-DIR-LENGTH          BINARY-LONG.
 01 WS-KIND                PIC X(8) VALUE "data".
 LINKAGE SECTION.
 01 L-END                  BINARY-LONG.
 01 L-PATH                 PIC X(1100).
 01 L-LENGTH               BINARY-LONG.
 PROCEDURE DIVISION USING L-END L-PATH L-LENGTH.
     CALL "PERSIST-DIM-DIR" USING L-END WS-KIND WS-DIR WS-DIR-LENGTH
     MOVE SPACES TO L-PATH
     STRING WS-DIR(1:WS-DIR-LENGTH) "/minecraft/ender_dragon_fight.dat" DELIMITED BY SIZE INTO L-PATH
     COMPUTE L-LENGTH = WS-DIR-LENGTH + 33
     GOBACK.
 END PROGRAM END-FIGHT-PATH.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. END-FIGHT-LOAD.
*> USING the End's dimension row, record out (ENDFIGHT.cpy): the file's record, the default when the file is missing or cannot be read as gzip NBT, then END-FIGHT-INIT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY PROTO.
 01 WS-PATH                PIC X(1100).
 01 WS-PATH-LENGTH         BINARY-LONG.
 01 WS-MADE                PIC X(1100).
 01 WS-INFO                PIC X(16).
 01 WS-OUTCOME             BINARY-LONG.
 01 WS-CAPACITY            BINARY-LONG VALUE 4096.
 LINKAGE SECTION.
 01 L-END                  BINARY-LONG.
 COPY ENDFIGHT REPLACING LEADING ==EF-== BY ==L-==.
 PROCEDURE DIVISION USING L-END END-FIGHT.
     CALL "END-FIGHT-PATH" USING L-END WS-PATH WS-PATH-LENGTH
     MOVE SPACES TO WS-MADE
     STRING WS-PATH(1:WS-PATH-LENGTH) X"00" DELIMITED BY SIZE INTO WS-MADE
     CALL "CBL_CHECK_FILE_EXIST" USING WS-MADE WS-INFO
     MOVE RETURN-CODE TO WS-OUTCOME
     MOVE 0 TO RETURN-CODE
     IF WS-OUTCOME = 0
         CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
         CALL "NBT-FILE-READ" USING WS-PATH WS-PATH-LENGTH PB-BUFFER WS-OUTCOME
         IF WS-OUTCOME = 0
             CALL "END-FIGHT-READ" USING PB-BUFFER END-FIGHT
         ELSE
             CALL "END-FIGHT-DEFAULT" USING END-FIGHT
         END-IF
         CALL "PB-FREE" USING PB-BUFFER
     ELSE
         CALL "END-FIGHT-DEFAULT" USING END-FIGHT
     END-IF
     CALL "END-FIGHT-INIT" USING CW-SEED END-FIGHT
     GOBACK.
 END PROGRAM END-FIGHT-LOAD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. END-FIGHT-SAVE.
*> USING the End's dimension row, record (ENDFIGHT.cpy): creates data/ and data/minecraft/ of the End's folder and writes the file.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY PROTO.
 01 WS-PATH                PIC X(1100).
 01 WS-PATH-LENGTH         BINARY-LONG.
 01 WS-MADE                PIC X(1100).
 01 WS-CAPACITY            BINARY-LONG VALUE 4096.
 LINKAGE SECTION.
 01 L-END                  BINARY-LONG.
 COPY ENDFIGHT REPLACING LEADING ==EF-== BY ==L-==.
 PROCEDURE DIVISION USING L-END END-FIGHT.
     CALL "END-FIGHT-PATH" USING L-END WS-PATH WS-PATH-LENGTH
     MOVE SPACES TO WS-MADE
     STRING WS-PATH(1:WS-PATH-LENGTH - 33) X"00" DELIMITED BY SIZE INTO WS-MADE
     CALL "CBL_CREATE_DIR" USING WS-MADE
     MOVE SPACES TO WS-MADE
     STRING WS-PATH(1:WS-PATH-LENGTH - 23) X"00" DELIMITED BY SIZE INTO WS-MADE
     CALL "CBL_CREATE_DIR" USING WS-MADE
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "END-FIGHT-WRITE" USING PB-BUFFER END-FIGHT
     CALL "PERSIST-WRITE-FILE" USING WS-PATH WS-PATH-LENGTH PB-BUFFER
     CALL "PB-FREE" USING PB-BUFFER
     GOBACK.
 END PROGRAM END-FIGHT-SAVE.
