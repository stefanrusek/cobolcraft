*> The state of one game session (lane bugchat, operator report: the chat of the previous world showed in the next one).
*> CLIENT-SESSION-RESET drops everything the client keeps of a session the player was in: the chat lines and the line being typed,
*> the command tree and the suggestions, the recipe book, the inventory, the open bench or container screen and the stack on
*> the cursor, experience, effects and the other status values of the local player, the entity replica and the player
*> list, the world replica and the particles, the portal overlay and the sounds waiting to play, the book, sign, anvil, form and merchant screens, the creative search and the
*> block break progress. NET-CLOSE calls it when the game connection is closed (quit to the title screen, the Disconnect
*> control, a Disconnect of the server, a lost connection) and NET-BUFFERS-INIT (NET-OPEN, NET-OPEN-MEMORY) when the next one opens. A
*> dimension change (Respawn) is not a new session: it never calls this. The things that belong to the client and not to
*> the session (options, packs, the server list, the registries of the configuration phase, the creative hotbars) stay.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CLIENT-SESSION-RESET.
*> USING CLIENT-STATE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-I                   BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 PROCEDURE DIVISION USING CLIENT-STATE.
*>   Chat, commands, recipes: one group each (every field starts at 0 or spaces in CL-INIT).
     INITIALIZE CH-STATE CM-STATE RK-STATE
*>   The HUD closures of the connection (57-5 section 1.3, hud-title.cob): boss bars, chat arrival data and delay queue, titles, action bar, scoreboard.
     CALL "HUD-RESET" USING CLIENT-STATE
*>   The inventory and the menus.
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 36
         MOVE 0 TO PL-SLOT-COUNT(WS-I) PL-SLOT-ITEM(WS-I) PL-SLOT-FOIL(WS-I) PL-SLOT-DAMAGE(WS-I)
         MOVE 0 TO PL-SLOT-DYE(WS-I) PL-SLOT-POTION(WS-I)
     END-PERFORM
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 16
         INITIALIZE IX-STACK(WS-I)
         INITIALIZE MX-ENTRY(WS-I)
         MOVE 0 TO BM-DATA(WS-I)
     END-PERFORM
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 64
         INITIALIZE BX-STACK(WS-I)
     END-PERFORM
     MOVE 0 TO PL-OFFHAND-COUNT PL-OFFHAND-ITEM PL-STACK-FOIL PL-OFFHAND-FOIL PL-OFFHAND-DAMAGE MX-COUNT
     MOVE 0 TO PL-STACK-DYE PL-OFFHAND-DYE PL-STACK-POTION PL-OFFHAND-POTION
     MOVE 0 TO BM-ID BM-STATE-ID BM-TYPE PL-CARRIED-COUNT PL-CARRIED-ITEM PL-INV-STATE-ID PL-HELD
     MOVE 0 TO PL-XP-LEVEL PL-XP-PROGRESS PL-XP-TOTAL
     MOVE 0 TO BC-PRIMARY BC-SECONDARY
     MOVE 0 TO MC-COUNT MC-LEVEL MC-XP MC-PROGRESS MC-RESTOCK MC-SCROLL MC-SELECTED MC-DRAGGING
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 32
         INITIALIZE MC-OFFER(WS-I)
         INITIALIZE SC-ENTRY(WS-I)
     END-PERFORM
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 21
         INITIALIZE MC-DISP(WS-I)
     END-PERFORM
     MOVE 0 TO SC-COUNT SC-START
     MOVE 0 TO CX-DRAG-ON CX-DRAG-BUTTON CX-DRAG-N CX-SKIP-RELEASE CX-PREV-SLOT CX-PREV-MS CX-DOUBLE
         CX-LAST-X CX-LAST-Y
     MOVE 0 TO CR-COUNT CR-THROTTLE CR-SCROLLING CR-SCROLL CR-QUERY-LEN
     MOVE 0 TO MT-ENTITY MT-KIND MT-SADDLE MT-BODY MT-ICON
     MOVE 0 TO AN-ID AN-ITEM AN-NAME-LENGTH AN-SENT-LENGTH
*>   The text editors: book, sign, forms, command blocks.
     MOVE SPACES TO BK-VALUE BK-CLIP
     MOVE 0 TO BK-LEN BK-CURSOR BK-ANCHOR BK-SELECTING BK-LINE-COUNT BK-OVERFLOW BK-CLIP-LEN
     MOVE 0 TO BE-PAGE-COUNT BE-CURRENT BE-HAND BE-ACTIVE BE-MODE BE-TITLE-LEN
     MOVE SPACES TO BE-TITLE
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 100
         INITIALIZE BE-PAGE(WS-I)
     END-PERFORM
     MOVE 0 TO SG-LINE SG-CURSOR SG-ANCHOR SG-CLIP-LEN
     MOVE SPACES TO SG-CLIP
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 4
         INITIALIZE SG-ROW(WS-I)
         MOVE SPACES TO EB-JG-TEXT(WS-I)
         MOVE 0 TO EB-JG-LEN(WS-I)
     END-PERFORM
     MOVE 0 TO EF-FOCUS EB-FORM EB-MC EB-MC-ENTITY EB-CMD-LEN EB-ST-NAME-LEN EB-ST-META-LEN EB-TI-INFO-LEN
     MOVE SPACES TO EB-CMD
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 12
         MOVE SPACES TO EF-TEXT(WS-I)
         MOVE 0 TO EF-LEN(WS-I)
     END-PERFORM
*>   The local player's status values.
     CALL "EFFECTS-CLEAR" USING CLIENT-STATE
     MOVE 0 TO PL-PERM PL-ABSORPTION PL-ARMOR PL-ON-FIRE PL-TICKS-FROZEN PL-KB-X PL-KB-Z PL-SLIP-X PL-SLIP-Z
     MOVE 20 TO PL-MAX-HEALTH
     MOVE 300 TO PL-MAX-AIR PL-AIR
     MOVE 0 TO PL-RAIN PL-THUNDER PL-WEATHER
     CALL "HUD-NEW-PLAYER" USING CLIENT-STATE
*>   The portal overlay and the sounds waiting to play on the next tick (dimension presentation).
     MOVE 0 TO DX-PORTAL DX-PORTAL-OLD DX-SOUND DX-FLASH DX-FLASH-OLD DX-FLASH-SOUND
*>   The block being broken and the breaks of the other players.
     MOVE 0 TO TG-HIT TG-ENTITY-HIT CT-BREAKING CT-DONE CT-SEQUENCE CT-ACK BD-ENTITY BDS-COUNT
*>   What is in the world: the entities, the player list, the chunks and their meshes, the particles.
     CALL "ENTITIES-CLEAR" USING CLIENT-STATE
     CALL "WORLD-CLEAR" USING CLIENT-STATE
     CALL "PARTICLES-CLEAR" USING CLIENT-STATE
     GOBACK.
 END PROGRAM CLIENT-SESSION-RESET.
