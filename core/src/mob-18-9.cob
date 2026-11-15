*> Server-side entity tracking and sending of the mob framework (docs/protocol/18-mob-framework.md section 9; lane 002-lane-mobsfull-h13).
*>
*>   M189-TRACK USING entity type id, tracking range (chunks) out, update interval (ticks) out   9.1 / 1.1 the registry values of a type (the key as the entity table holds it, without namespace; 5 and 3 for a type the registry lacks)
*>   M189-IN-RANGE USING player row, entity row, in range out                                   9.1 the horizontal squared distance is at most min(range, view distance x 16)^2
*>   M189-PACK-DEGREES USING degrees (FLOAT-LONG), packed out (0 to 255)                         9.2 step 4: 256 steps per turn
*>   M189-ROT-CHANGED USING packed yaw, last yaw, packed pitch, last pitch, changed out          9.2 step 4: a packed value differing by 1 or more
*>   M189-POS-CHANGE USING dx, dy, dz (FLOAT-LONG), tick count, change out                       9.2 step 6: squared length >= 2^-17 or tickCount mod 60 = 0
*>   M189-UPDATE-DUE USING tick count, interval, due out                                         9.2 step 3: tickCount is a multiple of the type's interval
*>   M189-FULL-SYNC USING precise, teleport delay, was riding, on-ground changed, full out        9.2 step 6: when an Entity Position Sync replaces a delta
*>   M189-DELTA-FITS USING dx, dy, dz (FLOAT-LONG), fits out                                      9.2 step 6: VecDeltaCodec.tryEncode, each axis round(delta x 4096) as a signed 16-bit value
*>   M189-VELOCITY-DUE USING squared change (FLOAT-LONG), now zero, last zero, due out            9.2 step 7: Set Entity Motion when the squared change exceeds 1.0E-7 or it fell to exactly zero

 IDENTIFICATION DIVISION.
 PROGRAM-ID. M189-TRACK.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CITEMS.
 COPY MOB181.
 01 WS-CACHE.
    05 WS-C-ENTRY OCCURS 200 TIMES.
       10 WS-C-KEY         PIC X(48).
       10 WS-C-TRACK       BINARY-LONG.
       10 WS-C-UPD         BINARY-LONG.
 01 WS-KEY                 PIC X(24).
 01 WS-ROW                 BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-TYPE                 BINARY-LONG.
 01 L-TRACK                BINARY-LONG.
 01 L-UPDATE               BINARY-LONG.
 PROCEDURE DIVISION USING L-TYPE L-TRACK L-UPDATE.
     MOVE 5 TO L-TRACK
     MOVE 3 TO L-UPDATE
     IF L-TYPE < 0 OR L-TYPE >= ET-COUNT
         GOBACK
     END-IF
     COMPUTE WS-I = L-TYPE + 1
     IF WS-C-KEY(WS-I) = ET-KEY(WS-I)
         MOVE WS-C-TRACK(WS-I) TO L-TRACK
         MOVE WS-C-UPD(WS-I) TO L-UPDATE
         GOBACK
     END-IF
     MOVE SPACES TO WS-KEY
     MOVE ET-KEY(WS-I) TO WS-KEY
     CALL "M181-FIND" USING WS-KEY WS-ROW
     IF WS-ROW > 0
         MOVE M1-TRACK(WS-ROW) TO L-TRACK
         MOVE M1-UPD(WS-ROW) TO L-UPDATE
     END-IF
     MOVE ET-KEY(WS-I) TO WS-C-KEY(WS-I)
     MOVE L-TRACK TO WS-C-TRACK(WS-I)
     MOVE L-UPDATE TO WS-C-UPD(WS-I)
     GOBACK.
 END PROGRAM M189-TRACK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. M189-IN-RANGE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-TRACK               BINARY-LONG.
 01 WS-UPDATE              BINARY-LONG.
 01 WS-RANGE               BINARY-LONG.
 01 WS-DX                  FLOAT-LONG.
 01 WS-DZ                  FLOAT-LONG.
 LINKAGE SECTION.
 COPY COREAPI.
 01 L-PLAYER               BINARY-LONG.
 01 L-ROW                  BINARY-LONG.
 01 L-IN                   BINARY-LONG.
 PROCEDURE DIVISION USING L-PLAYER L-ROW L-IN.
     SET ADDRESS OF CORE-SETTINGS TO ADDRESS OF CW-SETTINGS
     CALL "M189-TRACK" USING EN-TYPE(L-ROW) WS-TRACK WS-UPDATE
     COMPUTE WS-RANGE = FUNCTION MIN(WS-TRACK, CS-VIEW-DISTANCE) * 16
     COMPUTE WS-DX = EN-X(L-ROW) - PL-X(L-PLAYER)
     COMPUTE WS-DZ = EN-Z(L-ROW) - PL-Z(L-PLAYER)
     MOVE 0 TO L-IN
     IF WS-DX * WS-DX + WS-DZ * WS-DZ <= WS-RANGE * WS-RANGE
         MOVE 1 TO L-IN
     END-IF
     GOBACK.
 END PROGRAM M189-IN-RANGE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. M189-PACK-DEGREES.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-N                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-DEGREES              FLOAT-LONG.
 01 L-PACKED               BINARY-LONG.
 PROCEDURE DIVISION USING L-DEGREES L-PACKED.
     COMPUTE WS-N = FUNCTION INTEGER(L-DEGREES * 256 / 360)
     COMPUTE L-PACKED = FUNCTION MOD(WS-N, 256)
     GOBACK.
 END PROGRAM M189-PACK-DEGREES.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. M189-ROT-CHANGED.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-YAW                  BINARY-LONG.
 01 L-LAST-YAW             BINARY-LONG.
 01 L-PITCH                BINARY-LONG.
 01 L-LAST-PITCH           BINARY-LONG.
 01 L-CHANGED              BINARY-LONG.
 PROCEDURE DIVISION USING L-YAW L-LAST-YAW L-PITCH L-LAST-PITCH L-CHANGED.
     MOVE 0 TO L-CHANGED
     IF FUNCTION ABS(L-YAW - L-LAST-YAW) >= 1 OR FUNCTION ABS(L-PITCH - L-LAST-PITCH) >= 1
         MOVE 1 TO L-CHANGED
     END-IF
     GOBACK.
 END PROGRAM M189-ROT-CHANGED.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. M189-POS-CHANGE.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-DX                   FLOAT-LONG.
 01 L-DY                   FLOAT-LONG.
 01 L-DZ                   FLOAT-LONG.
 01 L-TICK                 BINARY-LONG.
 01 L-CHANGE               BINARY-LONG.
 PROCEDURE DIVISION USING L-DX L-DY L-DZ L-TICK L-CHANGE.
     MOVE 0 TO L-CHANGE
     IF L-DX * L-DX + L-DY * L-DY + L-DZ * L-DZ >= 0.00000762939453125 OR FUNCTION MOD(L-TICK, 60) = 0
         MOVE 1 TO L-CHANGE
     END-IF
     GOBACK.
 END PROGRAM M189-POS-CHANGE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. M189-UPDATE-DUE.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-TICK                 BINARY-LONG.
 01 L-INTERVAL             BINARY-LONG.
 01 L-DUE                  BINARY-LONG.
 PROCEDURE DIVISION USING L-TICK L-INTERVAL L-DUE.
     MOVE 0 TO L-DUE
     IF L-INTERVAL > 0 AND FUNCTION MOD(L-TICK, L-INTERVAL) = 0
         MOVE 1 TO L-DUE
     END-IF
     GOBACK.
 END PROGRAM M189-UPDATE-DUE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. M189-FULL-SYNC.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-PRECISE              BINARY-LONG.
 01 L-DELAY                BINARY-LONG.
 01 L-RIDING               BINARY-LONG.
 01 L-GROUND               BINARY-LONG.
 01 L-FULL                 BINARY-LONG.
 PROCEDURE DIVISION USING L-PRECISE L-DELAY L-RIDING L-GROUND L-FULL.
     MOVE 0 TO L-FULL
     IF L-PRECISE = 1 OR L-DELAY > 400 OR L-RIDING = 1 OR L-GROUND = 1
         MOVE 1 TO L-FULL
     END-IF
     GOBACK.
 END PROGRAM M189-FULL-SYNC.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. M189-DELTA-FITS.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-Q                   BINARY-DOUBLE.
 LINKAGE SECTION.
 01 L-DX                   FLOAT-LONG.
 01 L-DY                   FLOAT-LONG.
 01 L-DZ                   FLOAT-LONG.
 01 L-FITS                 BINARY-LONG.
 PROCEDURE DIVISION USING L-DX L-DY L-DZ L-FITS.
     MOVE 1 TO L-FITS
     COMPUTE WS-Q ROUNDED = L-DX * 4096
     IF WS-Q > 32767 OR WS-Q < -32768
         MOVE 0 TO L-FITS
     END-IF
     COMPUTE WS-Q ROUNDED = L-DY * 4096
     IF WS-Q > 32767 OR WS-Q < -32768
         MOVE 0 TO L-FITS
     END-IF
     COMPUTE WS-Q ROUNDED = L-DZ * 4096
     IF WS-Q > 32767 OR WS-Q < -32768
         MOVE 0 TO L-FITS
     END-IF
     GOBACK.
 END PROGRAM M189-DELTA-FITS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. M189-VELOCITY-DUE.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-CHANGE               FLOAT-LONG.
 01 L-NOW-ZERO             BINARY-LONG.
 01 L-LAST-ZERO            BINARY-LONG.
 01 L-DUE                  BINARY-LONG.
 PROCEDURE DIVISION USING L-CHANGE L-NOW-ZERO L-LAST-ZERO L-DUE.
     MOVE 0 TO L-DUE
     IF L-CHANGE > 0.0000001 OR (L-NOW-ZERO = 1 AND L-LAST-ZERO = 0)
         MOVE 1 TO L-DUE
     END-IF
     GOBACK.
 END PROGRAM M189-VELOCITY-DUE.
