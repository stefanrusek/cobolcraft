*> Working storage of the row checker EMCHKP.cpy (entity model tests): an expected definition row in the row syntax of EMM-ROW (client/src/entmodel-model.cob),
*> compared with the model in EMM-MODEL. A "P" row checks the parent and the nine pose values of the part, a "C" row the next cuboid of the part.
 01 CK-ROW                 PIC X(100).
 01 CK-TOK                 PIC X(24) OCCURS 14 TIMES.
 01 CK-NUM                 FLOAT-LONG OCCURS 14 TIMES.
 01 CK-PTR                 BINARY-LONG.
 01 CK-N                   BINARY-LONG.
 01 CK-K                   BINARY-LONG.
 01 CK-PART                BINARY-LONG.
 01 CK-PAR                 BINARY-LONG.
 01 CK-C                   BINARY-LONG.
 01 CK-BAD                 BINARY-LONG.
 01 CK-DIFF                FLOAT-LONG.
 01 CK-NAME                PIC X(24).
 01 CK-CN                  BINARY-LONG OCCURS 40 TIMES.
 01 CK-CASE                PIC X(160).
 01 CK-PREFIX              PIC X(120).
