*> The potion_contents component (id 53) of a stack (lane itemcomp, T9602; docs/protocol/25 section 9.1, 9.3, 46 section 4.1 and 8.1). Wire layout (the stream codec of 25 section 9.1: Optional holder, Optional Int,
*> list of MobEffectInstance, Optional String): Boolean, VarInt potion id; Boolean, Int custom colour; VarInt count, each effect VarInt id, VarInt amplifier, VarInt duration, Booleans ambient, visible, show icon
*> and a Boolean for a hidden effect; Boolean, String custom name. The wire layout of an effect instance inside the component is not in the documents (gap: the order above is the vanilla codec shape and the
*> Update Mob Effect fields of 05b 0x87); an instance with a hidden effect is not read.
*>
*>   SC-POTION-ID USING key (PIC X(32), with or without minecraft:), id out (-1 unknown)                        the registry id of a potion from the table POTIONS.cpy
*>   SC-POTION-SET USING handle (in, out), potion id                                                              a stack of that potion without custom effects
*>   SC-POTION-GET USING handle, potion out (-1), has colour out, colour out, custom effect count out            what the component holds
*>   SC-POTION-ADD-EFFECT USING handle (in, out), effect id, amplifier, duration                                  a custom effect after the others (at most 8; a full list is left alone)
*>   SC-POTION-EFFECT USING handle, n (1 based), effect id out, amplifier out, duration out                       a custom effect (id -1 past the end)
*>   SC-POTION-RESOLVE USING handle, duration scale in thousandths, count out, effects out (8 x id, amplifier, duration)   the potion's effects then the custom ones, duration max(floor(d x scale), 1)
*>   SC-POTION-READ USING handle, POTREC record out; SC-POTION-WRITE USING handle (in, out), POTREC record      the whole component

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SC-VGET.
*> USING value (PIC X(2048)), position (in and out, 1 based), number out: a VarInt of up to five bytes; a value of 2^31 or more is the negative int.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-B                   BINARY-LONG.
 01 WS-MUL                 BINARY-DOUBLE.
 01 WS-SUM                 BINARY-DOUBLE.
 01 WS-DONE                BINARY-LONG.
 LINKAGE SECTION.
 01 L-VALUE                PIC X(2048).
 01 L-POS                  BINARY-LONG.
 01 L-NUMBER               BINARY-LONG.
 PROCEDURE DIVISION USING L-VALUE L-POS L-NUMBER.
     MOVE 0 TO WS-SUM WS-DONE
     MOVE 1 TO WS-MUL
     PERFORM UNTIL WS-DONE = 1
         IF L-POS > 2048 OR WS-MUL > 268435456
             MOVE 1 TO WS-DONE
         ELSE
             COMPUTE WS-B = FUNCTION ORD(L-VALUE(L-POS:1)) - 1
             ADD 1 TO L-POS
             IF WS-B >= 128
                 COMPUTE WS-SUM = WS-SUM + (WS-B - 128) * WS-MUL
                 COMPUTE WS-MUL = WS-MUL * 128
             ELSE
                 COMPUTE WS-SUM = WS-SUM + WS-B * WS-MUL
                 MOVE 1 TO WS-DONE
             END-IF
         END-IF
     END-PERFORM
     IF WS-SUM >= 2147483648
         COMPUTE WS-SUM = WS-SUM - 4294967296
     END-IF
     MOVE WS-SUM TO L-NUMBER
     GOBACK.
 END PROGRAM SC-VGET.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SC-VPUT.
*> USING value (PIC X(2048)), position (in and out, 1 based), number (any int; a negative one takes five bytes): appends the VarInt.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-N                   BINARY-DOUBLE.
 01 WS-B                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-VALUE                PIC X(2048).
 01 L-POS                  BINARY-LONG.
 01 L-NUMBER               BINARY-LONG.
 PROCEDURE DIVISION USING L-VALUE L-POS L-NUMBER.
     MOVE L-NUMBER TO WS-N
     IF WS-N < 0
         ADD 4294967296 TO WS-N
     END-IF
     PERFORM UNTIL WS-N < 128
         COMPUTE WS-B = FUNCTION MOD(WS-N, 128) + 128
         MOVE FUNCTION CHAR(WS-B + 1) TO L-VALUE(L-POS:1)
         ADD 1 TO L-POS
         COMPUTE WS-N = WS-N / 128
     END-PERFORM
     MOVE FUNCTION CHAR(WS-N + 1) TO L-VALUE(L-POS:1)
     ADD 1 TO L-POS
     GOBACK.
 END PROGRAM SC-VPUT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SC-POTION-ID.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY POTIONS.
 01 WS-PT REDEFINES POTION-DATA.
    05 WS-ROW OCCURS 46 TIMES.
       10 WS-KEY           PIC X(24).
       10 WS-REST          BINARY-LONG OCCURS 7 TIMES.
 01 WS-WANT                PIC X(24).
 01 WS-I                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-KEY                  PIC X(32).
 01 L-ID                   BINARY-LONG.
 PROCEDURE DIVISION USING L-KEY L-ID.
     MOVE -1 TO L-ID
     IF L-KEY(1:10) = "minecraft:"
         MOVE L-KEY(11:22) TO WS-WANT
     ELSE
         MOVE L-KEY(1:24) TO WS-WANT
     END-IF
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > PT-COUNT
         IF WS-KEY(WS-I) = WS-WANT
             COMPUTE L-ID = WS-I - 1
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM SC-POTION-ID.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SC-POTION-READ.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-TYPE                BINARY-LONG VALUE 53.
 01 WS-VALUE               PIC X(2048).
 01 WS-LENGTH              BINARY-LONG.
 01 WS-FOUND               BINARY-LONG.
 01 WS-POS                 BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-B                   BINARY-LONG.
 01 WS-ID                  BINARY-LONG.
 01 WS-AMP                 BINARY-LONG.
 01 WS-DUR                 BINARY-LONG.
 01 WS-HIDDEN              BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-COLOR               BINARY-DOUBLE.
 LINKAGE SECTION.
 01 L-HANDLE               BINARY-LONG.
 COPY POTREC REPLACING LEADING ==PR-== BY ==L-PR-==.
 PROCEDURE DIVISION USING L-HANDLE L-PR-REC.
     INITIALIZE L-PR-REC
     MOVE -1 TO L-PR-POTION
     CALL "SP-GET-COMPONENT-X" USING L-HANDLE WS-TYPE WS-VALUE WS-LENGTH WS-FOUND
     IF WS-FOUND = 0
         GOBACK
     END-IF
     MOVE 1 TO WS-POS
     COMPUTE WS-B = FUNCTION ORD(WS-VALUE(WS-POS:1)) - 1
     ADD 1 TO WS-POS
     IF WS-B = 1
         CALL "SC-VGET" USING WS-VALUE WS-POS L-PR-POTION
     END-IF
     COMPUTE WS-B = FUNCTION ORD(WS-VALUE(WS-POS:1)) - 1
     ADD 1 TO WS-POS
     IF WS-B = 1
         MOVE 1 TO L-PR-HAS-COLOR
         MOVE 0 TO WS-COLOR
         PERFORM 4 TIMES
             COMPUTE WS-COLOR = WS-COLOR * 256 + FUNCTION ORD(WS-VALUE(WS-POS:1)) - 1
             ADD 1 TO WS-POS
         END-PERFORM
         IF WS-COLOR >= 2147483648
             COMPUTE WS-COLOR = WS-COLOR - 4294967296
         END-IF
         MOVE WS-COLOR TO L-PR-COLOR
     END-IF
     CALL "SC-VGET" USING WS-VALUE WS-POS WS-N
     MOVE 0 TO WS-HIDDEN
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-N OR WS-HIDDEN = 1
         CALL "SC-VGET" USING WS-VALUE WS-POS WS-ID
         CALL "SC-VGET" USING WS-VALUE WS-POS WS-AMP
         CALL "SC-VGET" USING WS-VALUE WS-POS WS-DUR
         ADD 3 TO WS-POS
         COMPUTE WS-B = FUNCTION ORD(WS-VALUE(WS-POS:1)) - 1
         ADD 1 TO WS-POS
         IF WS-B = 1
             MOVE 1 TO WS-HIDDEN
         ELSE
             IF L-PR-N < 8
                 ADD 1 TO L-PR-N
                 MOVE WS-ID TO L-PR-FX-ID(L-PR-N)
                 MOVE WS-AMP TO L-PR-FX-AMP(L-PR-N)
                 MOVE WS-DUR TO L-PR-FX-DUR(L-PR-N)
             END-IF
         END-IF
     END-PERFORM
     IF WS-HIDDEN = 0
         COMPUTE WS-B = FUNCTION ORD(WS-VALUE(WS-POS:1)) - 1
         ADD 1 TO WS-POS
         IF WS-B = 1
             CALL "SC-VGET" USING WS-VALUE WS-POS WS-J
             IF WS-J > 64
                 MOVE 64 TO L-PR-NAME-LEN
             ELSE
                 MOVE WS-J TO L-PR-NAME-LEN
             END-IF
             MOVE WS-VALUE(WS-POS:L-PR-NAME-LEN) TO L-PR-NAME
         END-IF
     END-IF
     GOBACK.
 END PROGRAM SC-POTION-READ.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SC-POTION-WRITE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-TYPE                BINARY-LONG VALUE 53.
 01 WS-VALUE               PIC X(2048).
 01 WS-POS                 BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-COLOR               BINARY-DOUBLE.
 01 WS-BYTE                BINARY-LONG.
 01 WS-LENGTH              BINARY-LONG.
 LINKAGE SECTION.
 01 L-HANDLE               BINARY-LONG.
 COPY POTREC REPLACING LEADING ==PR-== BY ==L-PR-==.
 PROCEDURE DIVISION USING L-HANDLE L-PR-REC.
     MOVE SPACES TO WS-VALUE
     MOVE 1 TO WS-POS
     IF L-PR-POTION >= 0
         MOVE X"01" TO WS-VALUE(WS-POS:1)
         ADD 1 TO WS-POS
         CALL "SC-VPUT" USING WS-VALUE WS-POS L-PR-POTION
     ELSE
         MOVE X"00" TO WS-VALUE(WS-POS:1)
         ADD 1 TO WS-POS
     END-IF
     IF L-PR-HAS-COLOR = 1
         MOVE X"01" TO WS-VALUE(WS-POS:1)
         ADD 1 TO WS-POS
         MOVE L-PR-COLOR TO WS-COLOR
         IF WS-COLOR < 0
             ADD 4294967296 TO WS-COLOR
         END-IF
         PERFORM VARYING WS-I FROM 3 BY -1 UNTIL WS-I < 0
             COMPUTE WS-BYTE = FUNCTION MOD(WS-COLOR / (256 ** WS-I), 256)
             MOVE FUNCTION CHAR(WS-BYTE + 1) TO WS-VALUE(WS-POS:1)
             ADD 1 TO WS-POS
         END-PERFORM
     ELSE
         MOVE X"00" TO WS-VALUE(WS-POS:1)
         ADD 1 TO WS-POS
     END-IF
     CALL "SC-VPUT" USING WS-VALUE WS-POS L-PR-N
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > L-PR-N
         CALL "SC-VPUT" USING WS-VALUE WS-POS L-PR-FX-ID(WS-I)
         CALL "SC-VPUT" USING WS-VALUE WS-POS L-PR-FX-AMP(WS-I)
         CALL "SC-VPUT" USING WS-VALUE WS-POS L-PR-FX-DUR(WS-I)
         MOVE X"000101" TO WS-VALUE(WS-POS:3)
         ADD 3 TO WS-POS
         MOVE X"00" TO WS-VALUE(WS-POS:1)
         ADD 1 TO WS-POS
     END-PERFORM
     IF L-PR-NAME-LEN > 0
         MOVE X"01" TO WS-VALUE(WS-POS:1)
         ADD 1 TO WS-POS
         CALL "SC-VPUT" USING WS-VALUE WS-POS L-PR-NAME-LEN
         MOVE L-PR-NAME(1:L-PR-NAME-LEN) TO WS-VALUE(WS-POS:L-PR-NAME-LEN)
         ADD L-PR-NAME-LEN TO WS-POS
     ELSE
         MOVE X"00" TO WS-VALUE(WS-POS:1)
         ADD 1 TO WS-POS
     END-IF
     COMPUTE WS-LENGTH = WS-POS - 1
     CALL "SP-SET-COMPONENT-X" USING L-HANDLE WS-TYPE WS-VALUE WS-LENGTH
     GOBACK.
 END PROGRAM SC-POTION-WRITE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SC-POTION-SET.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY POTREC.
 LINKAGE SECTION.
 01 L-HANDLE               BINARY-LONG.
 01 L-POTION               BINARY-LONG.
 PROCEDURE DIVISION USING L-HANDLE L-POTION.
     INITIALIZE PR-REC
     MOVE L-POTION TO PR-POTION
     CALL "SC-POTION-WRITE" USING L-HANDLE PR-REC
     GOBACK.
 END PROGRAM SC-POTION-SET.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SC-POTION-GET.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY POTREC.
 LINKAGE SECTION.
 01 L-HANDLE               BINARY-LONG.
 01 L-POTION               BINARY-LONG.
 01 L-HAS-COLOR            BINARY-LONG.
 01 L-COLOR                BINARY-LONG.
 01 L-CUSTOM               BINARY-LONG.
 PROCEDURE DIVISION USING L-HANDLE L-POTION L-HAS-COLOR L-COLOR L-CUSTOM.
     CALL "SC-POTION-READ" USING L-HANDLE PR-REC
     MOVE PR-POTION TO L-POTION
     MOVE PR-HAS-COLOR TO L-HAS-COLOR
     MOVE PR-COLOR TO L-COLOR
     MOVE PR-N TO L-CUSTOM
     GOBACK.
 END PROGRAM SC-POTION-GET.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SC-POTION-ADD-EFFECT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY POTREC.
 LINKAGE SECTION.
 01 L-HANDLE               BINARY-LONG.
 01 L-ID                   BINARY-LONG.
 01 L-AMP                  BINARY-LONG.
 01 L-DUR                  BINARY-LONG.
 PROCEDURE DIVISION USING L-HANDLE L-ID L-AMP L-DUR.
     CALL "SC-POTION-READ" USING L-HANDLE PR-REC
     IF PR-N < 8
         ADD 1 TO PR-N
         MOVE L-ID TO PR-FX-ID(PR-N)
         MOVE L-AMP TO PR-FX-AMP(PR-N)
         MOVE L-DUR TO PR-FX-DUR(PR-N)
         CALL "SC-POTION-WRITE" USING L-HANDLE PR-REC
     END-IF
     GOBACK.
 END PROGRAM SC-POTION-ADD-EFFECT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SC-POTION-EFFECT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY POTREC.
 LINKAGE SECTION.
 01 L-HANDLE               BINARY-LONG.
 01 L-N                    BINARY-LONG.
 01 L-ID                   BINARY-LONG.
 01 L-AMP                  BINARY-LONG.
 01 L-DUR                  BINARY-LONG.
 PROCEDURE DIVISION USING L-HANDLE L-N L-ID L-AMP L-DUR.
     CALL "SC-POTION-READ" USING L-HANDLE PR-REC
     MOVE -1 TO L-ID
     MOVE 0 TO L-AMP L-DUR
     IF L-N >= 1 AND L-N <= PR-N
         MOVE PR-FX-ID(L-N) TO L-ID
         MOVE PR-FX-AMP(L-N) TO L-AMP
         MOVE PR-FX-DUR(L-N) TO L-DUR
     END-IF
     GOBACK.
 END PROGRAM SC-POTION-EFFECT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SC-POTION-RESOLVE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY POTIONS.
 01 WS-PT REDEFINES POTION-DATA.
    05 WS-ROW OCCURS 46 TIMES.
       10 WS-KEY           PIC X(24).
       10 WS-NFX           BINARY-LONG.
       10 WS-FX OCCURS 2 TIMES.
          15 WS-FX-ID      BINARY-LONG.
          15 WS-FX-AMP     BINARY-LONG.
          15 WS-FX-DUR     BINARY-LONG.
 COPY POTREC.
 01 WS-I                   BINARY-LONG.
 01 WS-OUT                 BINARY-LONG.
 01 WS-ID                  BINARY-LONG.
 01 WS-AMP                 BINARY-LONG.
 01 WS-DUR                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-HANDLE               BINARY-LONG.
 01 L-SCALE                BINARY-LONG.
 01 L-COUNT                BINARY-LONG.
 01 L-FX.
    05 L-FX-E OCCURS 8 TIMES.
       10 L-FX-ID          BINARY-LONG.
       10 L-FX-AMP         BINARY-LONG.
       10 L-FX-DUR         BINARY-LONG.
 PROCEDURE DIVISION USING L-HANDLE L-SCALE L-COUNT L-FX.
     MOVE 0 TO L-COUNT
     CALL "SC-POTION-READ" USING L-HANDLE PR-REC
     IF PR-POTION >= 0 AND PR-POTION < PT-COUNT
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-NFX(PR-POTION + 1)
             MOVE WS-FX-ID(PR-POTION + 1, WS-I) TO WS-ID
             MOVE WS-FX-AMP(PR-POTION + 1, WS-I) TO WS-AMP
             MOVE WS-FX-DUR(PR-POTION + 1, WS-I) TO WS-DUR
*>           The table's durations are at least 1 (instant effects 1), so they are always scaled.
             IF L-COUNT < 8
                 ADD 1 TO L-COUNT
                 MOVE WS-ID TO L-FX-ID(L-COUNT)
                 MOVE WS-AMP TO L-FX-AMP(L-COUNT)
                 COMPUTE WS-OUT = FUNCTION INTEGER(WS-DUR * L-SCALE / 1000)
                 IF WS-OUT < 1
                     MOVE 1 TO WS-OUT
                 END-IF
                 MOVE WS-OUT TO L-FX-DUR(L-COUNT)
             END-IF
         END-PERFORM
     END-IF
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > PR-N
         MOVE PR-FX-ID(WS-I) TO WS-ID
         MOVE PR-FX-AMP(WS-I) TO WS-AMP
         MOVE PR-FX-DUR(WS-I) TO WS-DUR
         IF L-COUNT < 8
             ADD 1 TO L-COUNT
             MOVE WS-ID TO L-FX-ID(L-COUNT)
             MOVE WS-AMP TO L-FX-AMP(L-COUNT)
             IF WS-DUR > 0
                 COMPUTE WS-OUT = FUNCTION INTEGER(WS-DUR * L-SCALE / 1000)
                 IF WS-OUT < 1
                     MOVE 1 TO WS-OUT
                 END-IF
                 MOVE WS-OUT TO L-FX-DUR(L-COUNT)
             ELSE
                 MOVE WS-DUR TO L-FX-DUR(L-COUNT)
             END-IF
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM SC-POTION-RESOLVE.
