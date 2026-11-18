*> Live redstone, the note block (docs/protocol/30-redstone-5 section 8): the rising edge of its signal plays a note through a block event (8.3, 8.4: not under a block above unless the
*> instrument works above a note block), the block event sends the sound (8.5). The note and the instrument are those of the state: the instrument that the block below would choose (8.2)
*> needs a per-block instrument table that the content tables of this core do not hold (the Instrument column of 24 part 2 and the other block documents, not extracted); the pitch is exact.
*> Deviations: the seed of the sound is 0 (the level's nextLong is not drawn); no game event NOTE_BLOCK_PLAY goes out; the tune by right click and the play by left click are not wired.
*> Entry points:
*>   RL-NOTE-HOOK USING kind, dimension row, x, y, z, state, a, b, out    kinds 3 neighborChanged and 10 block event of a note block (out 1 when the event was handled)

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RL-NOTE-SOUND.
*> USING dimension row, x, y, z, sound key (PIC X(48)), pitch x 1e7: Sound Effect (05b 0x77) at the block centre, source RECORDS (2), volume 3.0, seed 0, to the viewers of the chunk (8.5 step 4).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CONTENT.
 COPY PROTO.
 01 WS-READY               PIC 9 VALUE 0.
 01 WS-CAPACITY            BINARY-LONG VALUE 64.
 01 WS-PACKET-ID           BINARY-LONG VALUE 119.
 01 WS-REGISTRY            PIC X(48) VALUE "minecraft:sound_event".
 01 WS-KEY                 PIC X(112).
 01 WS-ID                  BINARY-LONG.
 01 WS-STATUS              BINARY-LONG.
 01 WS-HOLDER              BINARY-LONG.
 01 WS-SOURCE              BINARY-LONG VALUE 2.
 01 WS-FX                  BINARY-LONG.
 01 WS-FY                  BINARY-LONG.
 01 WS-FZ                  BINARY-LONG.
 01 WS-VOLUME              FLOAT-SHORT VALUE 3.0.
 01 WS-PITCH               FLOAT-SHORT.
 01 WS-SEED                BINARY-DOUBLE VALUE 0.
 01 WS-CX                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-NONE                BINARY-LONG VALUE 0.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-SOUND                PIC X(48).
 01 L-PITCH                BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z L-SOUND L-PITCH.
     IF WS-READY = 0
         CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
         MOVE 1 TO WS-READY
     END-IF
     MOVE SPACES TO WS-KEY
     STRING "minecraft:" FUNCTION TRIM(L-SOUND) DELIMITED BY SIZE INTO WS-KEY
     CALL "CONTENT-STATIC-ID" USING WS-REGISTRY WS-KEY WS-ID WS-STATUS
     COMPUTE WS-HOLDER = WS-ID + 1
     COMPUTE WS-FX = L-X * 8 + 4
     COMPUTE WS-FY = L-Y * 8 + 4
     COMPUTE WS-FZ = L-Z * 8 + 4
     COMPUTE WS-PITCH = L-PITCH / 10000000
     COMPUTE WS-CX = (L-X - FUNCTION MOD(L-X, 16)) / 16
     COMPUTE WS-CZ = (L-Z - FUNCTION MOD(L-Z, 16)) / 16
     CALL "PB-RESET" USING PB-BUFFER
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-PACKET-ID
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-HOLDER
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-SOURCE
     CALL "PB-PUT-INT" USING PB-BUFFER WS-FX
     CALL "PB-PUT-INT" USING PB-BUFFER WS-FY
     CALL "PB-PUT-INT" USING PB-BUFFER WS-FZ
     CALL "PB-PUT-FLOAT" USING PB-BUFFER WS-VOLUME
     CALL "PB-PUT-FLOAT" USING PB-BUFFER WS-PITCH
     CALL "PB-PUT-LONG" USING PB-BUFFER WS-SEED
     CALL "VIEWERS-SEND" USING L-DIM WS-CX WS-CZ WS-NONE PB-BUFFER
     GOBACK.
 END PROGRAM RL-NOTE-SOUND.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RL-NOTE-HOOK RECURSIVE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CBLOCKS.
 01 WS-INSTRUMENT          PIC X(16) VALUE "instrument".
 01 WS-NOTE                PIC X(16) VALUE "note".
 01 WS-POWERED             PIC X(16) VALUE "powered".
 01 WS-KEEP                PIC X(16) VALUE "keep".
 LOCAL-STORAGE SECTION.
 01 LS-SIGNAL              BINARY-LONG.
 01 LS-POWERED             BINARY-LONG.
 01 LS-PLAY                BINARY-LONG.
 01 LS-WRITE               BINARY-LONG.
 01 LS-NEW-POWERED         BINARY-LONG.
 01 LS-NAME                PIC X(16).
 01 LS-NEW                 BINARY-LONG.
 01 LS-OLD                 PIC X(16).
 01 LS-I                   BINARY-LONG.
 01 LS-INST                BINARY-LONG.
 01 LS-TYPE                BINARY-LONG.
 01 LS-TUNABLE             BINARY-LONG.
 01 LS-CUSTOM              BINARY-LONG.
 01 LS-WORKS               BINARY-LONG.
 01 LS-QY                  BINARY-LONG.
 01 LS-ASTATE              BINARY-LONG.
 01 LS-AIR                 BINARY-LONG.
 01 LS-EVENT               BINARY-LONG.
 01 LS-GAME                BINARY-LONG.
 01 LS-BLOCK               BINARY-LONG.
 01 LS-A                   BINARY-LONG VALUE 0.
 01 LS-B                   BINARY-LONG VALUE 0.
 01 LS-FLAGS               BINARY-LONG VALUE 3.
 01 LS-BUDGET              BINARY-LONG VALUE 512.
 01 LS-RESULT              BINARY-LONG.
 01 LS-NOTE-N              BINARY-LONG.
 01 LS-SKULL               BINARY-LONG VALUE 0.
 01 LS-RES                 BINARY-LONG.
 01 LS-SOUND               BINARY-LONG.
 01 LS-PITCH               BINARY-LONG.
 01 LS-PART                BINARY-LONG.
 01 LS-PVEL                BINARY-LONG.
 01 LS-PACKET              BINARY-LONG.
 01 LS-INAME               PIC X(32).
 01 LS-ISOUND              PIC X(48).
 LINKAGE SECTION.
 01 L-KIND                 BINARY-LONG.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-STATE                BINARY-LONG.
 01 L-A                    BINARY-LONG.
 01 L-B                    BINARY-LONG.
 01 L-OUT                  BINARY-LONG.
 PROCEDURE DIVISION USING L-KIND L-DIM L-X L-Y L-Z L-STATE L-A L-B L-OUT.
     MOVE CB-S-BLOCK(L-STATE + 1) TO LS-BLOCK
*>   the instrument number of the state's instrument property (8.1 table order)
     CALL "SW-SET-PROP" USING L-STATE WS-INSTRUMENT WS-KEEP LS-NEW LS-OLD
     MOVE 0 TO LS-INST
     PERFORM VARYING LS-I FROM 0 BY 1 UNTIL LS-I > 26
         CALL "RS2-NOTE-NAME" USING LS-I LS-INAME LS-ISOUND
         IF FUNCTION TRIM(LS-INAME) = FUNCTION TRIM(LS-OLD)
             MOVE LS-I TO LS-INST
         END-IF
     END-PERFORM
     CALL "RS2-NOTE-NAME" USING LS-INST LS-INAME LS-ISOUND
     CALL "RS2-NOTE-TYPE" USING LS-INST LS-TYPE LS-TUNABLE LS-CUSTOM LS-WORKS
     EVALUATE L-KIND
         WHEN 3
*>           neighborChanged (8.3): a note on the rising edge, then powered follows
             CALL "RL-HAS-SIGNAL" USING L-DIM L-X L-Y L-Z LS-SIGNAL
             CALL "RL-GET-BOOL" USING L-STATE WS-POWERED LS-POWERED
             CALL "RS2-NOTE-NEIGHBOR" USING LS-SIGNAL LS-POWERED LS-PLAY LS-WRITE LS-NEW-POWERED
             IF LS-PLAY = 1
                 COMPUTE LS-QY = L-Y + 1
                 CALL "WORLD-GET-BLOCK" USING L-DIM L-X LS-QY L-Z LS-ASTATE
                 MOVE 0 TO LS-AIR
                 IF LS-ASTATE = 0
                     MOVE 1 TO LS-AIR
                 END-IF
                 CALL "RS2-NOTE-PLAY" USING LS-WORKS LS-AIR LS-EVENT LS-GAME
                 IF LS-EVENT = 1
                     CALL "BE-ADD" USING L-DIM L-X L-Y L-Z LS-BLOCK LS-A LS-B
                 END-IF
             END-IF
             IF LS-WRITE = 1
                 CALL "RL-SET-BOOL" USING L-STATE WS-POWERED LS-NEW-POWERED LS-NEW
                 CALL "LEVEL-SET-BLOCK" USING L-DIM L-X L-Y L-Z LS-NEW LS-FLAGS LS-BUDGET LS-RESULT
             END-IF
         WHEN 10
*>           the block event (8.5): the sound of the instrument at the note's pitch
             CALL "RL-PROP-NUM" USING L-STATE WS-NOTE LS-NOTE-N
             CALL "RS2-NOTE-EVENT" USING LS-INST LS-NOTE-N LS-SKULL LS-RES LS-SOUND LS-PITCH LS-PART LS-PVEL LS-PACKET
             IF LS-RES = 1
                 IF LS-SOUND = 1
                     CALL "RL-NOTE-SOUND" USING L-DIM L-X L-Y L-Z LS-ISOUND LS-PITCH
                 END-IF
                 MOVE LS-PACKET TO L-OUT
             END-IF
     END-EVALUATE
     GOBACK.
 END PROGRAM RL-NOTE-HOOK.
