*> The bastion remnant's variants (docs/protocol/37-nether-6 section 5; T1710): the four start-template variants with the sizes of their pool closures, the shared pools each reaches, the totals of
*> the bastion's data and the degradation rules of the generic processor list. The jigsaw engine (struct-jig*.cob) reads the pools themselves from the data; these are the doc's counts.
*>
*> Entry points (variants: 1 housing units, 2 hoglin stable, 3 treasure room, 4 bridge):
*>   NETHER-BASTION-VARIANT USING variant, code (1 pools in the closure, 2 templates in the closure, 3 pools of its own family), value out (-1 when unknown)
*>   NETHER-BASTION-START-TEMPLATE USING variant, name out (PIC X(48), without the namespace), length out (0 when unknown)
*>   NETHER-BASTION-SHARED USING shared pool (1 blocks/gold, 2 mobs/piglin, 3 mobs/piglin_melee, 4 mobs/hoglin), variant, reached out (1 or 0)
*>   NETHER-BASTION-TOTAL USING code (1 start pool elements, 2 weight of each, 3 template pool files, 4 structure NBT files, 5 related processor lists, 6 chest loot tables), value out (-1 when unknown)
*>   NETHER-BASTION-DEGRADE USING rule (1 to 5), input block out (PIC X(40)), output block out (PIC X(40), air for the air state), probability out in millionths (-1 beyond the five)

 IDENTIFICATION DIVISION.
 PROGRAM-ID. NETHER-BASTION-VARIANT.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-VARIANT              BINARY-LONG.
 01 L-CODE                 BINARY-LONG.
 01 L-VALUE                BINARY-LONG.
 PROCEDURE DIVISION USING L-VARIANT L-CODE L-VALUE.
     MOVE -1 TO L-VALUE
     IF L-VARIANT < 1 OR L-VARIANT > 4
         GOBACK
     END-IF
     EVALUATE L-CODE ALSO L-VARIANT
         WHEN 1 ALSO 1
             MOVE 18 TO L-VALUE
         WHEN 1 ALSO 2
             MOVE 17 TO L-VALUE
         WHEN 1 ALSO 3
             MOVE 22 TO L-VALUE
         WHEN 1 ALSO 4
             MOVE 10 TO L-VALUE
         WHEN 2 ALSO 1
             MOVE 38 TO L-VALUE
         WHEN 2 ALSO 2
             MOVE 62 TO L-VALUE
         WHEN 2 ALSO 3
             MOVE 66 TO L-VALUE
         WHEN 2 ALSO 4
             MOVE 19 TO L-VALUE
         WHEN 3 ALSO 1
             MOVE 15 TO L-VALUE
         WHEN 3 ALSO 2
             MOVE 13 TO L-VALUE
         WHEN 3 ALSO 3
             MOVE 20 TO L-VALUE
         WHEN 3 ALSO 4
             MOVE 7 TO L-VALUE
     END-EVALUATE
     GOBACK.
 END PROGRAM NETHER-BASTION-VARIANT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. NETHER-BASTION-START-TEMPLATE.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-VARIANT              BINARY-LONG.
 01 L-NAME                 PIC X(48).
 01 L-LENGTH               BINARY-LONG.
 PROCEDURE DIVISION USING L-VARIANT L-NAME L-LENGTH.
     MOVE SPACES TO L-NAME
     EVALUATE L-VARIANT
         WHEN 1
             MOVE "bastion/units/air_base" TO L-NAME
         WHEN 2
             MOVE "bastion/hoglin_stable/air_base" TO L-NAME
         WHEN 3
             MOVE "bastion/treasure/big_air_full" TO L-NAME
         WHEN 4
             MOVE "bastion/bridge/starting_pieces/entrance_base" TO L-NAME
     END-EVALUATE
     MOVE 0 TO L-LENGTH
     IF L-NAME NOT = SPACES
         MOVE FUNCTION LENGTH(FUNCTION TRIM(L-NAME TRAILING)) TO L-LENGTH
     END-IF
     GOBACK.
 END PROGRAM NETHER-BASTION-START-TEMPLATE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. NETHER-BASTION-SHARED.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-SHARED               BINARY-LONG.
 01 L-VARIANT              BINARY-LONG.
 01 L-REACHED              BINARY-LONG.
 PROCEDURE DIVISION USING L-SHARED L-VARIANT L-REACHED.
     MOVE 0 TO L-REACHED
     EVALUATE L-SHARED
         WHEN 1
             IF L-VARIANT = 1 OR L-VARIANT = 2
                 MOVE 1 TO L-REACHED
             END-IF
         WHEN 2
         WHEN 3
             MOVE 1 TO L-REACHED
         WHEN 4
             IF L-VARIANT = 2 OR L-VARIANT = 4
                 MOVE 1 TO L-REACHED
             END-IF
     END-EVALUATE
     GOBACK.
 END PROGRAM NETHER-BASTION-SHARED.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. NETHER-BASTION-TOTAL.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-CODE                 BINARY-LONG.
 01 L-VALUE                BINARY-LONG.
 PROCEDURE DIVISION USING L-CODE L-VALUE.
     EVALUATE L-CODE
         WHEN 1
             MOVE 4 TO L-VALUE
         WHEN 2
             MOVE 1 TO L-VALUE
         WHEN 3
             MOVE 60 TO L-VALUE
         WHEN 4
             MOVE 167 TO L-VALUE
         WHEN 5
             MOVE 11 TO L-VALUE
         WHEN 6
             MOVE 4 TO L-VALUE
         WHEN OTHER
             MOVE -1 TO L-VALUE
     END-EVALUATE
     GOBACK.
 END PROGRAM NETHER-BASTION-TOTAL.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. NETHER-BASTION-DEGRADE.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-RULE                 BINARY-LONG.
 01 L-IN                   PIC X(40).
 01 L-OUT                  PIC X(40).
 01 L-PROB                 BINARY-LONG.
 PROCEDURE DIVISION USING L-RULE L-IN L-OUT L-PROB.
     MOVE SPACES TO L-IN L-OUT
     MOVE -1 TO L-PROB
     EVALUATE L-RULE
         WHEN 1
             MOVE "polished_blackstone_bricks" TO L-IN
             MOVE "cracked_polished_blackstone_bricks" TO L-OUT
             MOVE 300000 TO L-PROB
         WHEN 2
             MOVE "blackstone" TO L-IN
             MOVE "air" TO L-OUT
             MOVE 100 TO L-PROB
         WHEN 3
             MOVE "gold_block" TO L-IN
             MOVE "cracked_polished_blackstone_bricks" TO L-OUT
             MOVE 300000 TO L-PROB
         WHEN 4
             MOVE "gilded_blackstone" TO L-IN
             MOVE "blackstone" TO L-OUT
             MOVE 500000 TO L-PROB
         WHEN 5
             MOVE "blackstone" TO L-IN
             MOVE "gilded_blackstone" TO L-OUT
             MOVE 10000 TO L-PROB
     END-EVALUATE
     GOBACK.
 END PROGRAM NETHER-BASTION-DEGRADE.
