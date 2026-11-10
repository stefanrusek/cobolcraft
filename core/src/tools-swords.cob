*> The swords (docs/protocol/17 section 2.2; US14): TOOL-SWORD-STATS USING item key (PIC X(48)), found out (1 only for "<material>_sword"),
*> durability, attack damage, attack speed, cooldown (1/10000 ticks), mining speed (thousandths): the stats of TOOL-ITEM-STATS (tools.cob).

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TOOL-SWORD-STATS.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-KIND                PIC X(12) VALUE "sword".
 LINKAGE SECTION.
 01 L-KEY                  PIC X(48).
 01 L-FOUND                BINARY-LONG.
 01 L-DURABILITY           BINARY-LONG.
 01 L-DAMAGE               BINARY-LONG.
 01 L-SPEED                BINARY-LONG.
 01 L-COOLDOWN             BINARY-LONG.
 01 L-MINING               BINARY-LONG.
 PROCEDURE DIVISION USING L-KEY L-FOUND L-DURABILITY L-DAMAGE L-SPEED L-COOLDOWN L-MINING.
     CALL "TOOL-KIND-STATS" USING WS-KIND L-KEY L-FOUND L-DURABILITY L-DAMAGE L-SPEED L-COOLDOWN L-MINING
     GOBACK.
 END PROGRAM TOOL-SWORD-STATS.
