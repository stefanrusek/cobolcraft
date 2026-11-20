*> The standard command tree (docs/protocol/16-commands-catalog.md §2, §3): one registration program per command (CMDS-REG-<name>
*> in core/src/cmds-*.cob), called in the order of the catalog's registration table (§2), which is the order of the children of
*> the root (help, usage lines and the Commands packet show it): the order of 57-client-closures-4 section 6.1. A command that is not implemented is not registered.
*>
*> Entry point: BR-STD-TREE (no arguments): an empty tree (BR-TREE-RESET) and every form of every command

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BR-STD-TREE.
*> The dedicated-only commands (ban-ip, banlist, ban, deop, op, pardon, pardon-ip, perf, save-all, save-off, save-on, setidletimeout, stop, transfer, whitelist)
*> are registered only for a dedicated server (host kind 0); publish and unpublish (CMDS-REG-LAN) only for a hosted world (57-client-closures-4 section 3.4).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-KIND                BINARY-LONG.
 01 WS-APPLIED             BINARY-LONG.
 01 WS-MISSING             BINARY-LONG.
 01 WS-DOC-EXECUTE      PIC X(32) VALUE "execute".
 01 WS-DOC-DATA         PIC X(32) VALUE "data".
 01 WS-DOC-TIME         PIC X(32) VALUE "time".
 01 WS-DOC-TEST         PIC X(32) VALUE "test".
 01 WS-DOC-RANDOM       PIC X(32) VALUE "random".
 01 WS-DOC-CLONE        PIC X(32) VALUE "clone".
 01 WS-DOC-COMPUTE      PIC X(32) VALUE "compute".
 01 WS-DOC-SWING        PIC X(32) VALUE "swing".
 01 WS-DOC-DIALOG       PIC X(32) VALUE "dialog".
 01 WS-DOC-DEBUG        PIC X(32) VALUE "debug".
 PROCEDURE DIVISION.
     CALL "BR-TREE-RESET"
     CALL "BA-HOST-KIND" USING WS-KIND
     CALL "CMDS-REG-ADVANCEMENT"
     CALL "CMDS-REG-ATTRIBUTE"
     CALL "BR-DOC-FILL" USING WS-DOC-EXECUTE
     CALL "CMDS-REG-EXECUTE"
     CALL "CMDS-REG-BOSSBAR"
     CALL "CMDS-REG-CLEAR"
     CALL "BR-DOC-FILL" USING WS-DOC-CLONE
     CALL "CMDS-REG-CLONE"
     CALL "BR-DOC-FILL" USING WS-DOC-COMPUTE
     CALL "CMDS-REG-COMPUTE"
     CALL "CMDS-REG-DAMAGE"
     CALL "BR-DOC-FILL" USING WS-DOC-DATA
     CALL "CMDS-REG-DATA"
     CALL "CMDS-REG-DATAPACK"
     CALL "BR-DOC-FILL" USING WS-DOC-DEBUG
     CALL "CMDS-REG-DEBUG"
     CALL "CMDS-REG-DEFAULTGAMEMODE"
     CALL "BR-DOC-FILL" USING WS-DOC-DIALOG
     CALL "CMDS-REG-DIALOG"
     CALL "CMDS-REG-DIFFICULTY"
     CALL "CMDS-REG-EFFECT"
     CALL "CMDS-REG-ME"
     CALL "CMDS-REG-ENCHANT"
     CALL "CMDS-REG-EXPERIENCE"
     CALL "CMDS-REG-FILL"
     CALL "CMDS-REG-FILLBIOME"
     CALL "CMDS-REG-FORCELOAD"
     CALL "CMDS-REG-FUNCTION"
     CALL "CMDS-REG-GAMEMODE"
     CALL "CMDS-REG-GAMERULE"
     CALL "CMDS-REG-GIVE"
     CALL "CMDS-REG-HELP"
     CALL "CMDS-REG-ITEM"
     CALL "CMDS-REG-KICK"
     CALL "CMDS-REG-KILL"
     CALL "CMDS-REG-LIST"
     CALL "CMDS-REG-LOCATE"
     CALL "CMDS-REG-LOOT"
     CALL "CMDS-REG-MSG"
     CALL "BR-DOC-FILL" USING WS-DOC-SWING
     CALL "CMDS-REG-SWING"
     CALL "CMDS-REG-PARTICLE"
     CALL "CMDS-REG-PLACE"
     CALL "CMDS-REG-PLAYSOUND"
     CALL "CMDS-REG-POSTEFFECT"
     CALL "BR-DOC-FILL" USING WS-DOC-RANDOM
     CALL "CMDS-REG-RANDOM"
     CALL "CMDS-REG-RELOAD"
     CALL "CMDS-REG-RECIPE"
     CALL "CMDS-REG-FETCHPROFILE"
     CALL "CMDS-REG-RETURN"
     CALL "CMDS-REG-RIDE"
     CALL "CMDS-REG-ROTATE"
     CALL "CMDS-REG-SAY"
     CALL "CMDS-REG-SCHEDULE"
     CALL "CMDS-REG-SCOREBOARD"
     CALL "CMDS-REG-SEED"
     CALL "CMDS-REG-VERSION"
     CALL "CMDS-REG-SETBLOCK"
     CALL "CMDS-REG-SPAWNPOINT"
     CALL "CMDS-REG-SETWORLDSPAWN"
     CALL "CMDS-REG-SPECTATE"
     CALL "CMDS-REG-SPREADPLAYERS"
     CALL "CMDS-REG-STOPSOUND"
     CALL "CMDS-REG-STOPWATCH"
     CALL "CMDS-REG-SUMMON"
     CALL "CMDS-REG-TAG"
     CALL "CMDS-REG-TEAM"
     CALL "CMDS-REG-TEAMMSG"
     CALL "CMDS-REG-TELEPORT"
     CALL "CMDS-REG-TELLRAW"
     CALL "BR-DOC-FILL" USING WS-DOC-TEST
     CALL "CMDS-REG-TICK"
     CALL "BR-DOC-FILL" USING WS-DOC-TIME
     CALL "CMDS-REG-TIME"
     CALL "CMDS-REG-TITLE"
     CALL "CMDS-REG-TRIGGER"
     CALL "CMDS-REG-WAYPOINT"
     CALL "CMDS-REG-WEATHER"
     CALL "CMDS-REG-WORLDBORDER"
     CALL "CMDS-REG-DEV"
     IF WS-KIND = 0
         CALL "CMDS-REG-BAN-IP"
         CALL "CMDS-REG-BANLIST"
         CALL "CMDS-REG-BAN"
         CALL "CMDS-REG-DEOP"
         CALL "CMDS-REG-OP"
         CALL "CMDS-REG-PARDON"
         CALL "CMDS-REG-PARDON-IP"
         CALL "CMDS-REG-PERF"
         CALL "CMDS-REG-SAVE-ALL"
         CALL "CMDS-REG-SAVE-SWITCH"
         CALL "CMDS-REG-SETIDLETIMEOUT"
         CALL "CMDS-REG-STOP"
         CALL "CMDS-REG-TRANSFER"
         CALL "CMDS-REG-WHITELIST"
     END-IF
     CALL "CMDS-REG-LAN"
     CALL "BR-SUGGEST-APPLY" USING WS-APPLIED WS-MISSING
     GOBACK.
 END PROGRAM BR-STD-TREE.
