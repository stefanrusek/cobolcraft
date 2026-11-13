*> The entity tags of the tag command (docs/protocol/16-commands-catalog.md §5.9; core/src/cmds-entities.cob): EXTERNAL, one entry per tag of an
*> entity, found by the network entity id of the entity (a player's PL-ENTITY-ID, any other entity's EN-ID). TG-ID 0 is a free entry; TG-COUNT is the
*> highest entry ever used. An entity has at most 1024 tags. Tags are not saved and not read by the selector option tag= yet.
 78 TG-MAX                 VALUE 4096.
 01 CORE-TAGS EXTERNAL.
    05 TG-COUNT             BINARY-LONG.
    05 TG-ENTRY OCCURS 4096 TIMES.
       10 TG-ID              BINARY-LONG.
       10 TG-LENGTH          BINARY-LONG.
       10 TG-NAME            PIC X(128).
