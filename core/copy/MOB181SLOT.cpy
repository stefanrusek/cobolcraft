*> The base metadata slots of an entity (docs/protocol/18-mob-framework.md section 1.4; generated from the table of that section, row = slot + 1).
*> MS-CLASS 1 Entity, 2 LivingEntity, 3 Mob, 4 AgeableMob.
 78 MSL-COUNT                VALUE 18.
 01 MSL-DATA.
    05 FILLER.
       10 FILLER BINARY-LONG VALUE 1.
       10 FILLER PIC X(24) VALUE "shared flags".
       10 FILLER PIC X(24) VALUE "BYTE".
       10 FILLER PIC X(24) VALUE "0".
    05 FILLER.
       10 FILLER BINARY-LONG VALUE 1.
       10 FILLER PIC X(24) VALUE "air supply".
       10 FILLER PIC X(24) VALUE "INT".
       10 FILLER PIC X(24) VALUE "300".
    05 FILLER.
       10 FILLER BINARY-LONG VALUE 1.
       10 FILLER PIC X(24) VALUE "custom name".
       10 FILLER PIC X(24) VALUE "OPTIONAL_COMPONENT".
       10 FILLER PIC X(24) VALUE "empty".
    05 FILLER.
       10 FILLER BINARY-LONG VALUE 1.
       10 FILLER PIC X(24) VALUE "custom name visible".
       10 FILLER PIC X(24) VALUE "BOOLEAN".
       10 FILLER PIC X(24) VALUE "false".
    05 FILLER.
       10 FILLER BINARY-LONG VALUE 1.
       10 FILLER PIC X(24) VALUE "silent".
       10 FILLER PIC X(24) VALUE "BOOLEAN".
       10 FILLER PIC X(24) VALUE "false".
    05 FILLER.
       10 FILLER BINARY-LONG VALUE 1.
       10 FILLER PIC X(24) VALUE "no gravity".
       10 FILLER PIC X(24) VALUE "BOOLEAN".
       10 FILLER PIC X(24) VALUE "false".
    05 FILLER.
       10 FILLER BINARY-LONG VALUE 1.
       10 FILLER PIC X(24) VALUE "pose".
       10 FILLER PIC X(24) VALUE "POSE".
       10 FILLER PIC X(24) VALUE "STANDING".
    05 FILLER.
       10 FILLER BINARY-LONG VALUE 1.
       10 FILLER PIC X(24) VALUE "ticks frozen".
       10 FILLER PIC X(24) VALUE "INT".
       10 FILLER PIC X(24) VALUE "0".
    05 FILLER.
       10 FILLER BINARY-LONG VALUE 2.
       10 FILLER PIC X(24) VALUE "living flags".
       10 FILLER PIC X(24) VALUE "BYTE".
       10 FILLER PIC X(24) VALUE "0".
    05 FILLER.
       10 FILLER BINARY-LONG VALUE 2.
       10 FILLER PIC X(24) VALUE "health".
       10 FILLER PIC X(24) VALUE "FLOAT".
       10 FILLER PIC X(24) VALUE "1.0".
    05 FILLER.
       10 FILLER BINARY-LONG VALUE 2.
       10 FILLER PIC X(24) VALUE "effect particles".
       10 FILLER PIC X(24) VALUE "PARTICLES".
       10 FILLER PIC X(24) VALUE "empty list".
    05 FILLER.
       10 FILLER BINARY-LONG VALUE 2.
       10 FILLER PIC X(24) VALUE "effect ambience".
       10 FILLER PIC X(24) VALUE "BOOLEAN".
       10 FILLER PIC X(24) VALUE "false".
    05 FILLER.
       10 FILLER BINARY-LONG VALUE 2.
       10 FILLER PIC X(24) VALUE "arrow count".
       10 FILLER PIC X(24) VALUE "INT".
       10 FILLER PIC X(24) VALUE "0".
    05 FILLER.
       10 FILLER BINARY-LONG VALUE 2.
       10 FILLER PIC X(24) VALUE "stinger count".
       10 FILLER PIC X(24) VALUE "INT".
       10 FILLER PIC X(24) VALUE "0".
    05 FILLER.
       10 FILLER BINARY-LONG VALUE 2.
       10 FILLER PIC X(24) VALUE "sleeping position".
       10 FILLER PIC X(24) VALUE "OPTIONAL_BLOCK_POS".
       10 FILLER PIC X(24) VALUE "empty".
    05 FILLER.
       10 FILLER BINARY-LONG VALUE 3.
       10 FILLER PIC X(24) VALUE "mob flags".
       10 FILLER PIC X(24) VALUE "BYTE".
       10 FILLER PIC X(24) VALUE "0".
    05 FILLER.
       10 FILLER BINARY-LONG VALUE 4.
       10 FILLER PIC X(24) VALUE "is baby".
       10 FILLER PIC X(24) VALUE "BOOLEAN".
       10 FILLER PIC X(24) VALUE "false".
    05 FILLER.
       10 FILLER BINARY-LONG VALUE 4.
       10 FILLER PIC X(24) VALUE "age locked".
       10 FILLER PIC X(24) VALUE "BOOLEAN".
       10 FILLER PIC X(24) VALUE "false".
 01 MSL-TABLE REDEFINES MSL-DATA.
    05 MSL-ENTRY OCCURS MSL-COUNT TIMES.
       10 MSL-CLASS            BINARY-LONG.
       10 MSL-NAME             PIC X(24).
       10 MSL-SERIALIZER       PIC X(24).
       10 MSL-DEFAULT          PIC X(24).
