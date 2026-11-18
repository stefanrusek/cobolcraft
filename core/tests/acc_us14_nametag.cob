*> Acceptance test (US14; docs/protocol/17 section 3.7, 18 section 1.4 entries 2 and 3): the name tag through the real play path. Interact (0x1A) with a name_tag
*> that has a custom_name on a living entity of a type that can be saved sets the entity's custom name (Set Entity Data entry 2 OPTIONAL_COMPONENT and entry 3
*> custom name visible true go to the viewers), sets the persistence flag and uses up one tag (not in creative); a tag without a custom_name does nothing; a hostile
*> mob (a zombie, which no other item interacts with) takes a name too.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-US14-NAMETAG.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-CONN                BINARY-LONG.
 01 WS-FLOOR               BINARY-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-COW                 BINARY-LONG.
 01 WS-ZOMBIE              BINARY-LONG.
 01 WS-ID                  BINARY-LONG.
 01 WS-DX                  FLOAT-LONG VALUE 2.
 01 WS-DZ                  FLOAT-LONG VALUE 0.
 01 WS-DZ2                 FLOAT-LONG VALUE 2.
 01 WS-HAND0               BINARY-LONG VALUE 0.
 01 WS-SNEAK0              BINARY-LONG VALUE 0.
 01 WS-KEY                 PIC X(48).
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-THREE               BINARY-LONG VALUE 3.
 01 WS-NAME                PIC X(64).
 01 WS-NAME-LENGTH         BINARY-LONG.
 01 WS-HANDLE              BINARY-LONG.
 01 WS-IDS                 PIC X(1024).
 01 WS-FOUND               BINARY-LONG.
 01 WS-HEX                 PIC X(1024).
 01 WS-HEX-LENGTH          BINARY-LONG.
 01 WS-HITS                BINARY-LONG.
 01 WS-CASE                PIC X(240).
 01 WS-EXPECT              BINARY-DOUBLE.
 01 WS-OBSERVE             BINARY-DOUBLE.
 PROCEDURE DIVISION.
     CALL "RT-OPEN" USING WS-PLAYER WS-CONN WS-FLOOR WS-CX WS-CZ
     MOVE "cow" TO WS-KEY
     CALL "RT-SPAWN-MOB" USING WS-PLAYER WS-KEY WS-DX WS-DZ WS-COW
     MOVE "zombie" TO WS-KEY
     CALL "RT-SPAWN-MOB" USING WS-PLAYER WS-KEY WS-DZ WS-DZ2 WS-ZOMBIE
     CALL "TEST-DRAIN-IDS" USING WS-CONN WS-IDS

*>   A name tag without a custom_name does nothing.
     MOVE "name_tag" TO WS-KEY
     CALL "RT-GIVE" USING WS-PLAYER WS-ONE WS-KEY WS-THREE
     MOVE EN-ID(WS-COW) TO WS-ID
     CALL "TEST-INTERACT" USING WS-CONN WS-ID WS-HAND0 WS-SNEAK0
     MOVE "acceptance US14 17 3.7 a name tag without a custom_name leaves the cow unnamed and the tag in the hand" TO WS-CASE
     MOVE 3 TO WS-EXPECT
     COMPUTE WS-OBSERVE = PL-SLOT-COUNT(WS-PLAYER, 1) + EN-CNAME-LEN(WS-COW) * 10 + EN-PERSISTENT(WS-COW) * 100
     PERFORM CHECK-N

*>   With a custom_name: the cow is named, persistent, and one tag is used up.
     MOVE "Bessie" TO WS-NAME
     MOVE 6 TO WS-NAME-LENGTH
     MOVE 0 TO WS-HANDLE
     CALL "SP-SET-NAME" USING WS-HANDLE WS-NAME WS-NAME-LENGTH
     MOVE WS-HANDLE TO PL-SLOT-VAR(WS-PLAYER, 1)
     CALL "TEST-DRAIN-IDS" USING WS-CONN WS-IDS
     CALL "TEST-INTERACT" USING WS-CONN WS-ID WS-HAND0 WS-SNEAK0
     MOVE "acceptance US14 17 3.7 the named tag sets the custom name of the cow" TO WS-CASE
     MOVE "Bessie" TO TL-EXPECTED
     MOVE SPACES TO TL-OBSERVED
     IF EN-CNAME-LEN(WS-COW) > 0
         MOVE EN-CNAME(WS-COW)(1:EN-CNAME-LEN(WS-COW)) TO TL-OBSERVED
     END-IF
     MOVE "T" TO TL-MODE
     MOVE WS-CASE TO TL-CASE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US14 17 3.7 the named cow never despawns (persistence flag) and one of the three tags is used up" TO WS-CASE
     MOVE 102 TO WS-EXPECT
     COMPUTE WS-OBSERVE = EN-PERSISTENT(WS-COW) * 100 + PL-SLOT-COUNT(WS-PLAYER, 1)
     PERFORM CHECK-N
     CALL "RT-PACKET-HEX" USING WS-CONN 101 WS-HEX WS-FOUND
     MOVE "acceptance US14 18 1.4 the viewers get Set Entity Data (0x65) for the cow" TO WS-CASE
     MOVE 1 TO WS-EXPECT
     MOVE WS-FOUND TO WS-OBSERVE
     PERFORM CHECK-N
     MOVE 0 TO WS-HITS
     INSPECT WS-HEX TALLYING WS-HITS FOR ALL "426573736965"
     MOVE "acceptance US14 18 1.4 that packet carries the name Bessie as the text component string" TO WS-CASE
     MOVE 1 TO WS-EXPECT
     MOVE WS-HITS TO WS-OBSERVE
     PERFORM CHECK-N
     MOVE 0 TO WS-HITS
     INSPECT WS-HEX TALLYING WS-HITS FOR ALL "020601"
     MOVE "acceptance US14 18 1.4 entry 2 is OPTIONAL_COMPONENT (serializer 6) and present" TO WS-CASE
     MOVE 1 TO WS-EXPECT
     MOVE WS-HITS TO WS-OBSERVE
     PERFORM CHECK-N
     MOVE 0 TO WS-HITS
     INSPECT WS-HEX TALLYING WS-HITS FOR ALL "030801"
     MOVE "acceptance US14 18 1.4 entry 3 custom name visible is the boolean true" TO WS-CASE
     MOVE 1 TO WS-EXPECT
     MOVE WS-HITS TO WS-OBSERVE
     PERFORM CHECK-N

*>   A client that starts tracking the named cow later gets the name with the Add Entity (ENTITY-VIEW-UPDATE).
     MOVE SPACE TO VW-SEEN(WS-PLAYER)(WS-COW:1)
     CALL "ENTITY-TRACK" USING WS-COW
     CALL "RT-PACKET-HEX" USING WS-CONN 101 WS-HEX WS-FOUND
     MOVE 0 TO WS-HITS
     INSPECT WS-HEX TALLYING WS-HITS FOR ALL "426573736965"
     MOVE "acceptance US14 18 1.4 a viewer that tracks the named cow afterwards is sent the name in Set Entity Data" TO WS-CASE
     MOVE 1 TO WS-EXPECT
     MOVE WS-HITS TO WS-OBSERVE
     PERFORM CHECK-N

*>   A hostile mob takes a name too.
     MOVE "Bessie" TO WS-NAME
     MOVE EN-ID(WS-ZOMBIE) TO WS-ID
     CALL "TEST-INTERACT" USING WS-CONN WS-ID WS-HAND0 WS-SNEAK0
     MOVE "acceptance US14 17 3.7 a zombie is named by the tag too and one more tag is used up" TO WS-CASE
     MOVE 106001 TO WS-EXPECT
     COMPUTE WS-OBSERVE = EN-PERSISTENT(WS-ZOMBIE) * 100000 + EN-CNAME-LEN(WS-ZOMBIE) * 1000 + PL-SLOT-COUNT(WS-PLAYER, 1)
     PERFORM CHECK-N

*>   Creative keeps the tag.
     MOVE 1 TO PL-MODE(WS-PLAYER)
     MOVE "Moo" TO WS-NAME
     MOVE 3 TO WS-NAME-LENGTH
     MOVE 0 TO WS-HANDLE
     CALL "SP-SET-NAME" USING WS-HANDLE WS-NAME WS-NAME-LENGTH
     MOVE WS-HANDLE TO PL-SLOT-VAR(WS-PLAYER, 1)
     MOVE 1 TO PL-SLOT-COUNT(WS-PLAYER, 1)
     MOVE EN-ID(WS-COW) TO WS-ID
     CALL "TEST-INTERACT" USING WS-CONN WS-ID WS-HAND0 WS-SNEAK0
     MOVE "acceptance US14 17 3.7 a creative player keeps the tag and renames the cow Moo" TO WS-CASE
     MOVE 1003 TO WS-EXPECT
     COMPUTE WS-OBSERVE = PL-SLOT-COUNT(WS-PLAYER, 1) * 1000 + EN-CNAME-LEN(WS-COW)
     PERFORM CHECK-N
     STOP RUN.

 CHECK-N.
     MOVE "N" TO TL-MODE
     MOVE WS-CASE TO TL-CASE
     MOVE WS-EXPECT TO TL-EXPECTED-N
     MOVE WS-OBSERVE TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM ACC-US14-NAMETAG.
 COPY CORETEST.
 COPY RANGEDTEST.
