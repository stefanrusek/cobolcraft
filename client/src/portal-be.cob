*> The block entities of the end portal and the end gateway on the client (docs/protocol/52 section 8.1 point 2 and 8.3 point 2; lane portalrender T54020).
*> A client creates a block entity only for an entry of the block entity list of a Level Chunk packet (06 section 3.2) or when a block change gives a cell a state
*> whose block has one; a block with no entity is not drawn. EP-ENTRY holds the entities of type 14 (end_portal) and 22 (end_gateway); the gateway's carries its
*> Age (the Age of the entry's tag, one more each client tick: the spawn beam of 8.9) and its teleport cooldown.
*>
*> Entry points:
*>   PORTAL-BLOCK-KIND USING CLIENT-STATE, state id, kind out        14 for an end_portal state, 22 for an end_gateway state, else 0
*>   PORTAL-BE-FIND USING CLIENT-STATE, x, y, z, row out             the entity at a position (0 none)
*>   PORTAL-BE-SET USING CLIENT-STATE, x, y, z, type, age            makes the entity (a second one at a position keeps the first, its type taken)
*>   PORTAL-BE-REMOVE USING CLIENT-STATE, x, y, z                    drops the entity at a position
*>   PORTAL-BE-FORGET USING CLIENT-STATE, chunk x, chunk z           drops every entity of a chunk (a chunk forgotten or sent again)
*>   PORTAL-BE-CHUNK USING CLIENT-STATE, chunk x, chunk z, count, heads, data    the entries of type 14 and 22 of a chunk packet's list
*>   PORTAL-BE-BLOCK USING CLIENT-STATE, x, y, z, state              a block change: the entity of the new state's block (made, kept or dropped)
*>   PORTAL-BE-TICK USING CLIENT-STATE                               one client tick: the gateways' age and cooldown

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PORTAL-BLOCK-KIND.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-I                   BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-STATE                BINARY-LONG.
 01 L-KIND                 BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-STATE L-KIND.
     MOVE 0 TO L-KIND
     CALL "STATE-TABLES-ENSURE" USING CLIENT-STATE
*>   The two block ids, looked up by name once per table size.
     IF EP-BLOCKS-FOR NOT = ST-COUNT + 1
         MOVE 0 TO EP-BLOCK-PORTAL EP-BLOCK-GATEWAY
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 2048
             IF ST-BLOCK-NAME(WS-I) = "end_portal"
                 MOVE WS-I TO EP-BLOCK-PORTAL
             END-IF
             IF ST-BLOCK-NAME(WS-I) = "end_gateway"
                 MOVE WS-I TO EP-BLOCK-GATEWAY
             END-IF
         END-PERFORM
         COMPUTE EP-BLOCKS-FOR = ST-COUNT + 1
     END-IF
     IF L-STATE >= 0 AND L-STATE < ST-COUNT
         IF EP-BLOCK-PORTAL > 0 AND ST-BLOCK(L-STATE + 1) = EP-BLOCK-PORTAL - 1
             MOVE 14 TO L-KIND
         END-IF
         IF EP-BLOCK-GATEWAY > 0 AND ST-BLOCK(L-STATE + 1) = EP-BLOCK-GATEWAY - 1
             MOVE 22 TO L-KIND
         END-IF
     END-IF
     GOBACK.
 END PROGRAM PORTAL-BLOCK-KIND.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PORTAL-BE-FIND.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-I                   BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-X L-Y L-Z L-ROW.
     MOVE 0 TO L-ROW
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > EP-COUNT OR L-ROW > 0
         IF EP-X(WS-I) = L-X AND EP-Y(WS-I) = L-Y AND EP-Z(WS-I) = L-Z
             MOVE WS-I TO L-ROW
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM PORTAL-BE-FIND.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PORTAL-BE-SET.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLCONST.
 01 WS-ROW                 BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-TYPE                 BINARY-LONG.
 01 L-AGE                  BINARY-DOUBLE.
 PROCEDURE DIVISION USING CLIENT-STATE L-X L-Y L-Z L-TYPE L-AGE.
     CALL "PORTAL-BE-FIND" USING CLIENT-STATE L-X L-Y L-Z WS-ROW
     IF WS-ROW = 0 AND EP-COUNT < CL-MAX-PORTALS
         ADD 1 TO EP-COUNT
         MOVE EP-COUNT TO WS-ROW
         MOVE L-X TO EP-X(WS-ROW)
         MOVE L-Y TO EP-Y(WS-ROW)
         MOVE L-Z TO EP-Z(WS-ROW)
         MOVE L-AGE TO EP-AGE(WS-ROW)
         MOVE 0 TO EP-COOLDOWN(WS-ROW)
     END-IF
     IF WS-ROW > 0
         MOVE L-TYPE TO EP-TYPE(WS-ROW)
     END-IF
     GOBACK.
 END PROGRAM PORTAL-BE-SET.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PORTAL-BE-REMOVE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-ROW                 BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-X L-Y L-Z.
     CALL "PORTAL-BE-FIND" USING CLIENT-STATE L-X L-Y L-Z WS-ROW
     IF WS-ROW > 0
         MOVE EP-ENTRY(EP-COUNT) TO EP-ENTRY(WS-ROW)
         SUBTRACT 1 FROM EP-COUNT
     END-IF
     GOBACK.
 END PROGRAM PORTAL-BE-REMOVE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PORTAL-BE-FORGET.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-I                   BINARY-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-CX                   BINARY-LONG.
 01 L-CZ                   BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-CX L-CZ.
*>   Backwards, so that the entry moved into a hole (the last) has been looked at.
     PERFORM VARYING WS-I FROM EP-COUNT BY -1 UNTIL WS-I < 1
         COMPUTE WS-CX = FUNCTION INTEGER(EP-X(WS-I) / 16)
         COMPUTE WS-CZ = FUNCTION INTEGER(EP-Z(WS-I) / 16)
         IF WS-CX = L-CX AND WS-CZ = L-CZ
             MOVE EP-ENTRY(EP-COUNT) TO EP-ENTRY(WS-I)
             SUBTRACT 1 FROM EP-COUNT
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM PORTAL-BE-FORGET.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PORTAL-BE-AGE.
*> USING data (the chunk list's data bytes), offset (the bytes before the tag), length, age out (BINARY-DOUBLE): the Age of the tag, the network form of a
*> compound (07: no name, the entries, an End tag); the gateway's carries Age (a long), ExactTeleport (a byte) and exit_portal (an int array of 3), walked entry by
*> entry; 0 when it has no Age or does not parse.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-POS                 BINARY-LONG.
 01 WS-END                 BINARY-LONG.
 01 WS-TAG                 BINARY-LONG.
 01 WS-NAME-LENGTH         BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-BYTE                BINARY-LONG.
 01 WS-STOP                BINARY-LONG.
 01 WS-IS-AGE              BINARY-LONG.
 01 WS-LEN4                BINARY-DOUBLE.
 LINKAGE SECTION.
 01 L-DATA                 PIC X(262144).
 01 L-OFFSET               BINARY-LONG.
 01 L-LENGTH               BINARY-LONG.
 01 L-AGE                  BINARY-DOUBLE.
 PROCEDURE DIVISION USING L-DATA L-OFFSET L-LENGTH L-AGE.
     MOVE 0 TO L-AGE
     COMPUTE WS-POS = L-OFFSET + 2
     COMPUTE WS-END = L-OFFSET + L-LENGTH
     MOVE 0 TO WS-STOP
     PERFORM UNTIL WS-STOP = 1 OR WS-POS > WS-END
         COMPUTE WS-TAG = FUNCTION ORD(L-DATA(WS-POS:1)) - 1
         IF WS-TAG = 0
             MOVE 1 TO WS-STOP
         ELSE
             COMPUTE WS-NAME-LENGTH = (FUNCTION ORD(L-DATA(WS-POS + 1:1)) - 1) * 256 + FUNCTION ORD(L-DATA(WS-POS + 2:1)) - 1
             MOVE 0 TO WS-IS-AGE
             IF WS-TAG = 4 AND WS-NAME-LENGTH = 3 AND L-DATA(WS-POS + 3:3) = "Age"
                 MOVE 1 TO WS-IS-AGE
             END-IF
             COMPUTE WS-POS = WS-POS + 3 + WS-NAME-LENGTH
             EVALUATE WS-TAG
                 WHEN 4
                     IF WS-IS-AGE = 1
                         MOVE 0 TO L-AGE
                         PERFORM VARYING WS-K FROM 0 BY 1 UNTIL WS-K > 7
                             COMPUTE WS-BYTE = FUNCTION ORD(L-DATA(WS-POS + WS-K:1)) - 1
                             COMPUTE L-AGE = L-AGE * 256 + WS-BYTE
                         END-PERFORM
                     END-IF
                     ADD 8 TO WS-POS
                 WHEN 1
                     ADD 1 TO WS-POS
                 WHEN 11
                     COMPUTE WS-LEN4 = (FUNCTION ORD(L-DATA(WS-POS:1)) - 1) * 16777216 + (FUNCTION ORD(L-DATA(WS-POS + 1:1)) - 1) * 65536
                         + (FUNCTION ORD(L-DATA(WS-POS + 2:1)) - 1) * 256 + FUNCTION ORD(L-DATA(WS-POS + 3:1)) - 1
                     COMPUTE WS-POS = WS-POS + 4 + WS-LEN4 * 4
                 WHEN OTHER
                     MOVE 1 TO WS-STOP
             END-EVALUATE
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM PORTAL-BE-AGE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PORTAL-BE-CHUNK.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-E                   BINARY-LONG.
 01 WS-AT                  BINARY-LONG.
 01 WS-OFFSET              BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-LENGTH              BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-AGE                 BINARY-DOUBLE.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-CX                   BINARY-LONG.
 01 L-CZ                   BINARY-LONG.
 01 L-COUNT                BINARY-LONG.
 01 L-HEADS.
    05 L-HEAD              BINARY-LONG OCCURS 2560 TIMES.
 01 L-DATA                 PIC X(262144).
 PROCEDURE DIVISION USING CLIENT-STATE L-CX L-CZ L-COUNT L-HEADS L-DATA.
     CALL "PORTAL-BE-FORGET" USING CLIENT-STATE L-CX L-CZ
     MOVE 0 TO WS-OFFSET
     PERFORM VARYING WS-E FROM 0 BY 1 UNTIL WS-E >= L-COUNT
         COMPUTE WS-AT = WS-E * 5
         MOVE L-HEAD(WS-AT + 4) TO WS-TYPE
         MOVE L-HEAD(WS-AT + 5) TO WS-LENGTH
         IF WS-TYPE = 14 OR WS-TYPE = 22
             COMPUTE WS-X = L-CX * 16 + L-HEAD(WS-AT + 1)
             MOVE L-HEAD(WS-AT + 2) TO WS-Y
             COMPUTE WS-Z = L-CZ * 16 + L-HEAD(WS-AT + 3)
             MOVE 0 TO WS-AGE
             IF WS-TYPE = 22 AND WS-LENGTH > 0
                 CALL "PORTAL-BE-AGE" USING L-DATA WS-OFFSET WS-LENGTH WS-AGE
             END-IF
             CALL "PORTAL-BE-SET" USING CLIENT-STATE WS-X WS-Y WS-Z WS-TYPE WS-AGE
         END-IF
         ADD WS-LENGTH TO WS-OFFSET
     END-PERFORM
     GOBACK.
 END PROGRAM PORTAL-BE-CHUNK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PORTAL-BE-BLOCK.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-KIND                BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-ZERO                BINARY-DOUBLE VALUE 0.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-STATE                BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-X L-Y L-Z L-STATE.
     CALL "PORTAL-BLOCK-KIND" USING CLIENT-STATE L-STATE WS-KIND
     CALL "PORTAL-BE-FIND" USING CLIENT-STATE L-X L-Y L-Z WS-ROW
     EVALUATE TRUE
         WHEN WS-KIND = 0 AND WS-ROW > 0
             CALL "PORTAL-BE-REMOVE" USING CLIENT-STATE L-X L-Y L-Z
         WHEN WS-KIND > 0 AND WS-ROW = 0
             CALL "PORTAL-BE-SET" USING CLIENT-STATE L-X L-Y L-Z WS-KIND WS-ZERO
     END-EVALUATE
     GOBACK.
 END PROGRAM PORTAL-BE-BLOCK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PORTAL-BE-TICK.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-I                   BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 PROCEDURE DIVISION USING CLIENT-STATE.
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > EP-COUNT
         IF EP-TYPE(WS-I) = 22
             ADD 1 TO EP-AGE(WS-I)
             IF EP-COOLDOWN(WS-I) > 0
                 SUBTRACT 1 FROM EP-COOLDOWN(WS-I)
             END-IF
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM PORTAL-BE-TICK.
