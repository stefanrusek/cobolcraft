*> The slot of each connection for its latest unprocessed Command Suggestion request (docs/protocol/54-client-gap-closures.md section 14.1;
*> core/src/cmd-wire.cob CMD-SUGGEST fills it, CMD-SUGGEST-FLUSH answers it once per tick): pending flag, the player row and entity id it was
*> taken for, the transaction id and the text as sent (with the slash).
 01 SUG-SLOTS EXTERNAL.
    05 SG-SLOT              OCCURS 64 TIMES.
       10 SG-PENDING         BINARY-LONG.
       10 SG-ROW             BINARY-LONG.
       10 SG-ENTITY          BINARY-LONG.
       10 SG-TRANSACTION     BINARY-LONG.
       10 SG-LENGTH          BINARY-LONG.
       10 SG-TEXT            PIC X(1024).
