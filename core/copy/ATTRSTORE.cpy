*> The attribute state of the attribute command (docs/protocol/16-commands-catalog.md §5.12; core/src/cmds-entities.cob): EXTERNAL, found by the network entity id of the
*> entity (a player's PL-ENTITY-ID, any other entity's EN-ID) and the attribute's number in ATTRDEF.cpy (1 to 40). AB-ID 0 is a free entry: AB-VALUE is a base value set with
*> base set (an attribute without an entry has its default). AM-ID 0 is a free entry: a modifier has an identifier (AM-NAME), an amount and an operation (0 add_value, 1
*> add_multiplied_base, 2 add_multiplied_total; 18 §1.3). Entries of removed entities are freed by the next attribute command. Nothing else reads these values yet, and they are not saved.
 78 AB-MAX                 VALUE 4096.
 78 AM-MAX                 VALUE 4096.
 01 CORE-ATTRS EXTERNAL.
    05 AB-ENTRY OCCURS 4096 TIMES.
       10 AB-ID              BINARY-LONG.
       10 AB-ATTR            BINARY-LONG.
       10 AB-VALUE           FLOAT-LONG.
    05 AM-ENTRY OCCURS 4096 TIMES.
       10 AM-ID              BINARY-LONG.
       10 AM-ATTR            BINARY-LONG.
       10 AM-NAME-LENGTH     BINARY-LONG.
       10 AM-NAME            PIC X(64).
       10 AM-AMOUNT          FLOAT-LONG.
       10 AM-OP              BINARY-LONG.
