*> The standard command tree (docs/protocol/16-commands-catalog.md §2, §3): one registration program per command (CMDS-REG-<name>
*> in core/src/cmds-*.cob), called in the order of the catalog's registration table (§2), which is the order of the children of
*> the root (help, usage lines and the Commands packet show it). A command that is not implemented is not registered.
*>
*> Entry point: BR-STD-TREE (no arguments): an empty tree (BR-TREE-RESET) and every form of every command

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BR-STD-TREE.
 DATA DIVISION.
 PROCEDURE DIVISION.
     CALL "BR-TREE-RESET"
     CALL "CMDS-REG-DEFAULTGAMEMODE"
     CALL "CMDS-REG-DIFFICULTY"
     CALL "CMDS-REG-ME"
     CALL "CMDS-REG-GAMEMODE"
     CALL "CMDS-REG-GAMERULE"
     CALL "CMDS-REG-HELP"
     CALL "CMDS-REG-KICK"
     CALL "CMDS-REG-LIST"
     CALL "CMDS-REG-MSG"
     CALL "CMDS-REG-SAY"
     CALL "CMDS-REG-SEED"
     CALL "CMDS-REG-VERSION"
     CALL "CMDS-REG-SETWORLDSPAWN"
     CALL "CMDS-REG-SPAWNPOINT"
     CALL "CMDS-REG-TIME"
     CALL "CMDS-REG-WEATHER"
     CALL "CMDS-REG-BAN"
     CALL "CMDS-REG-BANLIST"
     CALL "CMDS-REG-DEOP"
     CALL "CMDS-REG-OP"
     CALL "CMDS-REG-PARDON"
     CALL "CMDS-REG-SAVE-ALL"
     CALL "CMDS-REG-SAVE-SWITCH"
     CALL "CMDS-REG-STOP"
     CALL "CMDS-REG-WHITELIST"
     GOBACK.
 END PROGRAM BR-STD-TREE.
