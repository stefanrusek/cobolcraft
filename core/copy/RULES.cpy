*> Player rules (standin-content §10.1, §11.1), transcribed. Tested by core/tests/test_content_tables.cob.
*> Maximum health (§10.1): health is a whole number 0..30; new and respawned players have 30.
 78 RULE-MAX-HEALTH           VALUE 30.
*> Maximum food level (§11.1): food is a whole number 0..24; new and respawned players have 24.
 78 RULE-MAX-FOOD             VALUE 24.
*> Day length (§4.8): the time of day runs 0..29999, advancing 1 per tick and wrapping to 0.
 78 RULE-DAY-LENGTH           VALUE 30000.
