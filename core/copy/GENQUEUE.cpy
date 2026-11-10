*> The chunk generation queue (research R12; core/src/gen-queue.cob): chunks wanted by a player's view
*> that are not loaded yet. GQ-BUDGET is the number of chunks CORE-TICK generates per tick (a hosting
*> mechanism, not game behaviour: it changes when a chunk exists, not what it holds); the queue is served
*> nearest first, by the distance of the chunk to the nearest alive player of its dimension.
*> GQ-GENERATED counts the chunks the queue has generated since the world was opened.
 78 GQ-CAPACITY            VALUE 1024.
 78 GQ-BUDGET              VALUE 2.
 01 GEN-QUEUE EXTERNAL.
    05 GQ-COUNT             BINARY-LONG.
    05 GQ-GENERATED         BINARY-DOUBLE.
    05 GQ-ENTRY OCCURS 1024 TIMES.
       10 GQ-DIM            BINARY-LONG.
       10 GQ-X              BINARY-LONG.
       10 GQ-Z              BINARY-LONG.
