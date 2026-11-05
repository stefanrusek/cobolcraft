*> Contract test, server side of the wire profile (contracts/proto-api.md §4, contracts/wire-profile.md,
*> docs/protocol/09-cobolcraft-profile.md §3): every clientbound fixture equals what the core's packet
*> builders produce for the fixture's stated inputs, and every serverbound fixture decodes to the
*> stated values. The cases are grouped by phase in the test copybooks COPYed after this program
*> (test infrastructure): WIRESTATUS (handshake, status, login), WIRECONFIG (registries and
*> configuration), WIRECHUNK (chunks), WIREPLAY (play join), WIREMOVE (movement and other
*> players), WIREBLOCK (blocks and inventory), WIREITEM (ground items), WIRECHAT (chat), WIREHEALTH
*> (health, damage, death and respawn), WIREHUNGER (hunger, eating and sprinting).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. CONTRACT-WIRE-SERVER.
 PROCEDURE DIVISION.
     CALL "WIRE-STATUS-CASES"
     CALL "WIRE-CONFIG-CASES"
     CALL "WIRE-CHUNK-CASES"
     CALL "WIRE-PLAY-CASES"
     CALL "WIRE-MOVE-CASES"
     CALL "WIRE-BLOCK-CASES"
     CALL "WIRE-ITEM-CASES"
     CALL "WIRE-CHAT-CASES"
     CALL "WIRE-HEALTH-CASES"
     CALL "WIRE-HUNGER-CASES"
     STOP RUN.
 END PROGRAM CONTRACT-WIRE-SERVER.

 COPY WIRESTATUS.
 COPY WIRECONFIG.
 COPY WIRECHUNK.
 COPY WIREPLAY.
 COPY WIREMOVE.
 COPY WIREBLOCK.
 COPY WIREITEM.
 COPY WIRECHAT.
 COPY WIREHEALTH.
 COPY WIREHUNGER.
 COPY CORETEST.
