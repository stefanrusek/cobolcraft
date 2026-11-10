*> Decoded serverbound play packets the core handles (docs/protocol/05c; 09 §3.2 play table), filled by
*> PLAY-DECODE (core/src/play.cob). Only the fields of the decoded packet are set; the others are
*> cleared.
 01 PLAY-SERVERBOUND.
*>  0x00 Accept Teleportation; 0x1E to 0x21 Move Player use the position and rotation fields too
    05 PSB-TELEPORT-ID        BINARY-LONG.
    05 PSB-X                  FLOAT-LONG.
    05 PSB-Y                  FLOAT-LONG.
    05 PSB-Z                  FLOAT-LONG.
    05 PSB-YAW                FLOAT-SHORT.
    05 PSB-PITCH              FLOAT-SHORT.
*>  0x01 Attack: the target entity id (VarInt). 0x0C Client Command uses PSB-ACTION (VarInt action).
*>  0x2A Player Command: the entity id (VarInt) in PSB-TARGET, the action (VarInt) in PSB-ACTION and
*>  the data (VarInt) in PSB-DATA.
    05 PSB-TARGET             BINARY-LONG.
    05 PSB-DATA               BINARY-LONG.
*>  0x0B Chunk Batch Received
    05 PSB-CHUNK-RATE         FLOAT-SHORT.
*>  0x0E Client Information (03 layout; only the view distance is kept)
    05 PSB-VIEW-DISTANCE      BINARY-LONG.
*>  0x1C Keep Alive
    05 PSB-KEEPALIVE          BINARY-DOUBLE.
*>  0x1E to 0x21 Move Player: MoveFlags (UByte: 0x01 on ground, 0x02 horizontal collision);
*>  0x28 Player Abilities: flags (Byte: 0x02 flying)
    05 PSB-FLAGS              BINARY-LONG.
*>  0x29 Player Action: action (VarInt), block position, face (UByte), sequence (VarInt).
*>  0x42 Use Item On: hand (VarInt), block position, face (VarInt), cursor, inside, world border hit,
*>  sequence. The face is reduced modulo 6 (05c: the decoders wrap). 0x43 Use Item: hand (VarInt),
*>  sequence (VarInt), yaw and pitch (Floats, in PSB-YAW and PSB-PITCH).
    05 PSB-ACTION             BINARY-LONG.
    05 PSB-HAND               BINARY-LONG.
    05 PSB-BX                 BINARY-LONG.
    05 PSB-BY                 BINARY-LONG.
    05 PSB-BZ                 BINARY-LONG.
    05 PSB-FACE               BINARY-LONG.
    05 PSB-CURSOR-X           FLOAT-SHORT.
    05 PSB-CURSOR-Y           FLOAT-SHORT.
    05 PSB-CURSOR-Z           FLOAT-SHORT.
    05 PSB-INSIDE             BINARY-LONG.
    05 PSB-BORDER             BINARY-LONG.
    05 PSB-SEQUENCE           BINARY-LONG.
*>  0x36 Set Carried Item, 0x12 Container Click and 0x39 Set Creative Mode Slot: slot (Short).
    05 PSB-SLOT               BINARY-LONG.
*>  0x12 Container Click: container id, state id, button, click type (0 to 6; out of range is 0),
*>  the client's predicted changed slots (HashedStack: item and count, 0 = empty; no components)
*>  and its predicted carried item.
    05 PSB-CONTAINER          BINARY-LONG.
    05 PSB-STATE-ID           BINARY-LONG.
    05 PSB-BUTTON             BINARY-LONG.
    05 PSB-CLICK-TYPE         BINARY-LONG.
    05 PSB-CHANGED-COUNT      BINARY-LONG.
    05 PSB-CHANGED OCCURS 128 TIMES.
       10 PSB-CHANGED-SLOT    BINARY-LONG.
       10 PSB-CHANGED-ITEM    BINARY-LONG.
       10 PSB-CHANGED-AMOUNT  BINARY-LONG.
    05 PSB-CARRIED-ITEM       BINARY-LONG.
    05 PSB-CARRIED-COUNT      BINARY-LONG.
*>  0x27 Place Recipe: container id in PSB-CONTAINER, the recipe display id (VarInt) and use max
*>  items (Boolean, 1 = true).
    05 PSB-RECIPE             BINARY-LONG.
    05 PSB-USE-MAX            BINARY-LONG.
*>  0x2F Recipe Book Change Settings: book type (0 to 3), is open and is filtering (0 or 1). 0x30 Recipe Book Seen: the
*>  display id is in PSB-RECIPE.
    05 PSB-BOOK-TYPE          BINARY-LONG.
    05 PSB-BOOK-OPEN          BINARY-LONG.
    05 PSB-BOOK-FILTER        BINARY-LONG.
*>  0x39 Set Creative Mode Slot: the stack (count 0 = empty).
    05 PSB-STACK-ITEM         BINARY-LONG.
    05 PSB-STACK-COUNT        BINARY-LONG.
    05 PSB-STACK-VAR          BINARY-LONG.   *> the component patch as a handle of CSTACK.cpy (0 = none)
*>  0x0F Command Suggestion: the transaction id (VarInt); its text is in PSB-MESSAGE. 0x07 Chat
*>  Command: the command text (without the leading `/`) is in PSB-MESSAGE.
    05 PSB-TRANSACTION        BINARY-LONG.
*>  0x09 Chat (unsigned; 09 §1): the message (String, at most 256 UTF-16 code units, so at most 768
*>  UTF-8 bytes) and its byte length. Timestamp, salt, signature and last seen messages are read and
*>  not kept.
    05 PSB-MESSAGE-LENGTH     BINARY-LONG.
    05 PSB-MESSAGE            PIC X(768).
