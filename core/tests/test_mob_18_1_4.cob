*> Acceptance test (US15, FR-036, SC-008; docs/protocol/18-mob-framework.md section 1.4, with doc 44 part 1 section 4): the base metadata slots and the flag bytes.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-MOB-18-1-4.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY MOB181SLOT.
 01 WS-NAME               PIC X(16).
 01 WS-MASK               BINARY-LONG.
 01 WS-GROUP              BINARY-LONG.
 PROCEDURE DIVISION.
     MOVE "acceptance US15 18§1.4 Entity metadata base slots: slots 0 to 17 are listed" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N ROUNDED = 18
     COMPUTE TL-OBSERVED-N ROUNDED = MSL-COUNT
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§1.4 Entity metadata base slots: slot 0 belongs to class Entity" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N ROUNDED = 1
     COMPUTE TL-OBSERVED-N ROUNDED = MSL-CLASS(1)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§1.4 Entity metadata base slots: slot 0 is shared flags" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "shared flags" TO TL-EXPECTED
     MOVE MSL-NAME(1) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§1.4 Entity metadata base slots: slot 0 (shared flags) serializer BYTE" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "BYTE" TO TL-EXPECTED
     MOVE MSL-SERIALIZER(1) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§1.4 Entity metadata base slots: slot 0 (shared flags) default 0" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "0" TO TL-EXPECTED
     MOVE MSL-DEFAULT(1) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§1.4 Entity metadata base slots: slot 1 belongs to class Entity" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N ROUNDED = 1
     COMPUTE TL-OBSERVED-N ROUNDED = MSL-CLASS(2)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§1.4 Entity metadata base slots: slot 1 is air supply" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "air supply" TO TL-EXPECTED
     MOVE MSL-NAME(2) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§1.4 Entity metadata base slots: slot 1 (air supply) serializer INT" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "INT" TO TL-EXPECTED
     MOVE MSL-SERIALIZER(2) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§1.4 Entity metadata base slots: slot 1 (air supply) default 300" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "300" TO TL-EXPECTED
     MOVE MSL-DEFAULT(2) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§1.4 Entity metadata base slots: slot 2 belongs to class Entity" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N ROUNDED = 1
     COMPUTE TL-OBSERVED-N ROUNDED = MSL-CLASS(3)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§1.4 Entity metadata base slots: slot 2 is custom name" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "custom name" TO TL-EXPECTED
     MOVE MSL-NAME(3) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§1.4 Entity metadata base slots: slot 2 (custom name) serializer OPTIONAL_COMPONENT" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "OPTIONAL_COMPONENT" TO TL-EXPECTED
     MOVE MSL-SERIALIZER(3) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§1.4 Entity metadata base slots: slot 2 (custom name) default empty" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "empty" TO TL-EXPECTED
     MOVE MSL-DEFAULT(3) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§1.4 Entity metadata base slots: slot 3 belongs to class Entity" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N ROUNDED = 1
     COMPUTE TL-OBSERVED-N ROUNDED = MSL-CLASS(4)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§1.4 Entity metadata base slots: slot 3 is custom name visible" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "custom name visible" TO TL-EXPECTED
     MOVE MSL-NAME(4) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§1.4 Entity metadata base slots: slot 3 (custom name visible) serializer BOOLEAN" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "BOOLEAN" TO TL-EXPECTED
     MOVE MSL-SERIALIZER(4) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§1.4 Entity metadata base slots: slot 3 (custom name visible) default false" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "false" TO TL-EXPECTED
     MOVE MSL-DEFAULT(4) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§1.4 Entity metadata base slots: slot 4 belongs to class Entity" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N ROUNDED = 1
     COMPUTE TL-OBSERVED-N ROUNDED = MSL-CLASS(5)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§1.4 Entity metadata base slots: slot 4 is silent" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "silent" TO TL-EXPECTED
     MOVE MSL-NAME(5) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§1.4 Entity metadata base slots: slot 4 (silent) serializer BOOLEAN" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "BOOLEAN" TO TL-EXPECTED
     MOVE MSL-SERIALIZER(5) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§1.4 Entity metadata base slots: slot 4 (silent) default false" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "false" TO TL-EXPECTED
     MOVE MSL-DEFAULT(5) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§1.4 Entity metadata base slots: slot 5 belongs to class Entity" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N ROUNDED = 1
     COMPUTE TL-OBSERVED-N ROUNDED = MSL-CLASS(6)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§1.4 Entity metadata base slots: slot 5 is no gravity" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "no gravity" TO TL-EXPECTED
     MOVE MSL-NAME(6) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§1.4 Entity metadata base slots: slot 5 (no gravity) serializer BOOLEAN" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "BOOLEAN" TO TL-EXPECTED
     MOVE MSL-SERIALIZER(6) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§1.4 Entity metadata base slots: slot 5 (no gravity) default false" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "false" TO TL-EXPECTED
     MOVE MSL-DEFAULT(6) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§1.4 Entity metadata base slots: slot 6 belongs to class Entity" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N ROUNDED = 1
     COMPUTE TL-OBSERVED-N ROUNDED = MSL-CLASS(7)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§1.4 Entity metadata base slots: slot 6 is pose" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "pose" TO TL-EXPECTED
     MOVE MSL-NAME(7) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§1.4 Entity metadata base slots: slot 6 (pose) serializer POSE" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "POSE" TO TL-EXPECTED
     MOVE MSL-SERIALIZER(7) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§1.4 Entity metadata base slots: slot 6 (pose) default STANDING" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "STANDING" TO TL-EXPECTED
     MOVE MSL-DEFAULT(7) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§1.4 Entity metadata base slots: slot 7 belongs to class Entity" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N ROUNDED = 1
     COMPUTE TL-OBSERVED-N ROUNDED = MSL-CLASS(8)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§1.4 Entity metadata base slots: slot 7 is ticks frozen" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "ticks frozen" TO TL-EXPECTED
     MOVE MSL-NAME(8) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§1.4 Entity metadata base slots: slot 7 (ticks frozen) serializer INT" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "INT" TO TL-EXPECTED
     MOVE MSL-SERIALIZER(8) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§1.4 Entity metadata base slots: slot 7 (ticks frozen) default 0" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "0" TO TL-EXPECTED
     MOVE MSL-DEFAULT(8) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§1.4 Entity metadata base slots: slot 8 belongs to class LivingEntity" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N ROUNDED = 2
     COMPUTE TL-OBSERVED-N ROUNDED = MSL-CLASS(9)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§1.4 Entity metadata base slots: slot 8 is living flags" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "living flags" TO TL-EXPECTED
     MOVE MSL-NAME(9) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§1.4 Entity metadata base slots: slot 8 (living flags) serializer BYTE" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "BYTE" TO TL-EXPECTED
     MOVE MSL-SERIALIZER(9) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§1.4 Entity metadata base slots: slot 8 (living flags) default 0" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "0" TO TL-EXPECTED
     MOVE MSL-DEFAULT(9) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§1.4 Entity metadata base slots: slot 9 belongs to class LivingEntity" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N ROUNDED = 2
     COMPUTE TL-OBSERVED-N ROUNDED = MSL-CLASS(10)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§1.4 Entity metadata base slots: slot 9 is health" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "health" TO TL-EXPECTED
     MOVE MSL-NAME(10) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§1.4 Entity metadata base slots: slot 9 (health) serializer FLOAT" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "FLOAT" TO TL-EXPECTED
     MOVE MSL-SERIALIZER(10) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§1.4 Entity metadata base slots: slot 9 (health) default 1.0" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "1.0" TO TL-EXPECTED
     MOVE MSL-DEFAULT(10) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§1.4 Entity metadata base slots: slot 10 belongs to class LivingEntity" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N ROUNDED = 2
     COMPUTE TL-OBSERVED-N ROUNDED = MSL-CLASS(11)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§1.4 Entity metadata base slots: slot 10 is effect particles" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "effect particles" TO TL-EXPECTED
     MOVE MSL-NAME(11) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§1.4 Entity metadata base slots: slot 10 (effect particles) serializer PARTICLES" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "PARTICLES" TO TL-EXPECTED
     MOVE MSL-SERIALIZER(11) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§1.4 Entity metadata base slots: slot 10 (effect particles) default empty list" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "empty list" TO TL-EXPECTED
     MOVE MSL-DEFAULT(11) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§1.4 Entity metadata base slots: slot 11 belongs to class LivingEntity" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N ROUNDED = 2
     COMPUTE TL-OBSERVED-N ROUNDED = MSL-CLASS(12)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§1.4 Entity metadata base slots: slot 11 is effect ambience" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "effect ambience" TO TL-EXPECTED
     MOVE MSL-NAME(12) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§1.4 Entity metadata base slots: slot 11 (effect ambience) serializer BOOLEAN" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "BOOLEAN" TO TL-EXPECTED
     MOVE MSL-SERIALIZER(12) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§1.4 Entity metadata base slots: slot 11 (effect ambience) default false" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "false" TO TL-EXPECTED
     MOVE MSL-DEFAULT(12) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§1.4 Entity metadata base slots: slot 12 belongs to class LivingEntity" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N ROUNDED = 2
     COMPUTE TL-OBSERVED-N ROUNDED = MSL-CLASS(13)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§1.4 Entity metadata base slots: slot 12 is arrow count" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "arrow count" TO TL-EXPECTED
     MOVE MSL-NAME(13) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§1.4 Entity metadata base slots: slot 12 (arrow count) serializer INT" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "INT" TO TL-EXPECTED
     MOVE MSL-SERIALIZER(13) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§1.4 Entity metadata base slots: slot 12 (arrow count) default 0" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "0" TO TL-EXPECTED
     MOVE MSL-DEFAULT(13) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§1.4 Entity metadata base slots: slot 13 belongs to class LivingEntity" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N ROUNDED = 2
     COMPUTE TL-OBSERVED-N ROUNDED = MSL-CLASS(14)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§1.4 Entity metadata base slots: slot 13 is stinger count" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "stinger count" TO TL-EXPECTED
     MOVE MSL-NAME(14) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§1.4 Entity metadata base slots: slot 13 (stinger count) serializer INT" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "INT" TO TL-EXPECTED
     MOVE MSL-SERIALIZER(14) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§1.4 Entity metadata base slots: slot 13 (stinger count) default 0" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "0" TO TL-EXPECTED
     MOVE MSL-DEFAULT(14) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§1.4 Entity metadata base slots: slot 14 belongs to class LivingEntity" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N ROUNDED = 2
     COMPUTE TL-OBSERVED-N ROUNDED = MSL-CLASS(15)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§1.4 Entity metadata base slots: slot 14 is sleeping position" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "sleeping position" TO TL-EXPECTED
     MOVE MSL-NAME(15) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§1.4 Entity metadata base slots: slot 14 (sleeping position) serializer OPTIONAL_BLOCK_POS" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "OPTIONAL_BLOCK_POS" TO TL-EXPECTED
     MOVE MSL-SERIALIZER(15) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§1.4 Entity metadata base slots: slot 14 (sleeping position) default empty" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "empty" TO TL-EXPECTED
     MOVE MSL-DEFAULT(15) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§1.4 Entity metadata base slots: slot 15 belongs to class Mob" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N ROUNDED = 3
     COMPUTE TL-OBSERVED-N ROUNDED = MSL-CLASS(16)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§1.4 Entity metadata base slots: slot 15 is mob flags" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "mob flags" TO TL-EXPECTED
     MOVE MSL-NAME(16) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§1.4 Entity metadata base slots: slot 15 (mob flags) serializer BYTE" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "BYTE" TO TL-EXPECTED
     MOVE MSL-SERIALIZER(16) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§1.4 Entity metadata base slots: slot 15 (mob flags) default 0" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "0" TO TL-EXPECTED
     MOVE MSL-DEFAULT(16) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§1.4 Entity metadata base slots: slot 16 belongs to class AgeableMob" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N ROUNDED = 4
     COMPUTE TL-OBSERVED-N ROUNDED = MSL-CLASS(17)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§1.4 Entity metadata base slots: slot 16 is is baby" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "is baby" TO TL-EXPECTED
     MOVE MSL-NAME(17) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§1.4 Entity metadata base slots: slot 16 (is baby) serializer BOOLEAN" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "BOOLEAN" TO TL-EXPECTED
     MOVE MSL-SERIALIZER(17) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§1.4 Entity metadata base slots: slot 16 (is baby) default false" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "false" TO TL-EXPECTED
     MOVE MSL-DEFAULT(17) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§1.4 Entity metadata base slots: slot 17 belongs to class AgeableMob" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N ROUNDED = 4
     COMPUTE TL-OBSERVED-N ROUNDED = MSL-CLASS(18)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§1.4 Entity metadata base slots: slot 17 is age locked" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "age locked" TO TL-EXPECTED
     MOVE MSL-NAME(18) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§1.4 Entity metadata base slots: slot 17 (age locked) serializer BOOLEAN" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "BOOLEAN" TO TL-EXPECTED
     MOVE MSL-SERIALIZER(18) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§1.4 Entity metadata base slots: slot 17 (age locked) default false" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "false" TO TL-EXPECTED
     MOVE MSL-DEFAULT(18) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO WS-GROUP
     MOVE "on_fire" TO WS-NAME
     CALL "M181-FLAG-MASK" USING WS-GROUP WS-NAME WS-MASK
     MOVE "acceptance US15 18§1.4 Entity metadata base slots: flag on_fire of group 1 is mask 1" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N ROUNDED = 1
     COMPUTE TL-OBSERVED-N ROUNDED = WS-MASK
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO WS-GROUP
     MOVE "crouching" TO WS-NAME
     CALL "M181-FLAG-MASK" USING WS-GROUP WS-NAME WS-MASK
     MOVE "acceptance US15 18§1.4 Entity metadata base slots: flag crouching of group 1 is mask 2" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N ROUNDED = 2
     COMPUTE TL-OBSERVED-N ROUNDED = WS-MASK
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO WS-GROUP
     MOVE "sprinting" TO WS-NAME
     CALL "M181-FLAG-MASK" USING WS-GROUP WS-NAME WS-MASK
     MOVE "acceptance US15 18§1.4 Entity metadata base slots: flag sprinting of group 1 is mask 8" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N ROUNDED = 8
     COMPUTE TL-OBSERVED-N ROUNDED = WS-MASK
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO WS-GROUP
     MOVE "swimming" TO WS-NAME
     CALL "M181-FLAG-MASK" USING WS-GROUP WS-NAME WS-MASK
     MOVE "acceptance US15 18§1.4 Entity metadata base slots: flag swimming of group 1 is mask 16" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N ROUNDED = 16
     COMPUTE TL-OBSERVED-N ROUNDED = WS-MASK
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO WS-GROUP
     MOVE "invisible" TO WS-NAME
     CALL "M181-FLAG-MASK" USING WS-GROUP WS-NAME WS-MASK
     MOVE "acceptance US15 18§1.4 Entity metadata base slots: flag invisible of group 1 is mask 32" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N ROUNDED = 32
     COMPUTE TL-OBSERVED-N ROUNDED = WS-MASK
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO WS-GROUP
     MOVE "glowing" TO WS-NAME
     CALL "M181-FLAG-MASK" USING WS-GROUP WS-NAME WS-MASK
     MOVE "acceptance US15 18§1.4 Entity metadata base slots: flag glowing of group 1 is mask 64" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N ROUNDED = 64
     COMPUTE TL-OBSERVED-N ROUNDED = WS-MASK
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO WS-GROUP
     MOVE "fall_flying" TO WS-NAME
     CALL "M181-FLAG-MASK" USING WS-GROUP WS-NAME WS-MASK
     MOVE "acceptance US15 18§1.4 Entity metadata base slots: flag fall_flying of group 1 is mask 128" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N ROUNDED = 128
     COMPUTE TL-OBSERVED-N ROUNDED = WS-MASK
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 2 TO WS-GROUP
     MOVE "using_item" TO WS-NAME
     CALL "M181-FLAG-MASK" USING WS-GROUP WS-NAME WS-MASK
     MOVE "acceptance US15 18§1.4 Entity metadata base slots: flag using_item of group 2 is mask 1" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N ROUNDED = 1
     COMPUTE TL-OBSERVED-N ROUNDED = WS-MASK
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 2 TO WS-GROUP
     MOVE "off_hand" TO WS-NAME
     CALL "M181-FLAG-MASK" USING WS-GROUP WS-NAME WS-MASK
     MOVE "acceptance US15 18§1.4 Entity metadata base slots: flag off_hand of group 2 is mask 2" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N ROUNDED = 2
     COMPUTE TL-OBSERVED-N ROUNDED = WS-MASK
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 2 TO WS-GROUP
     MOVE "spin_attack" TO WS-NAME
     CALL "M181-FLAG-MASK" USING WS-GROUP WS-NAME WS-MASK
     MOVE "acceptance US15 18§1.4 Entity metadata base slots: flag spin_attack of group 2 is mask 4" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N ROUNDED = 4
     COMPUTE TL-OBSERVED-N ROUNDED = WS-MASK
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 3 TO WS-GROUP
     MOVE "no_ai" TO WS-NAME
     CALL "M181-FLAG-MASK" USING WS-GROUP WS-NAME WS-MASK
     MOVE "acceptance US15 18§1.4 Entity metadata base slots: flag no_ai of group 3 is mask 1" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N ROUNDED = 1
     COMPUTE TL-OBSERVED-N ROUNDED = WS-MASK
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 3 TO WS-GROUP
     MOVE "left_handed" TO WS-NAME
     CALL "M181-FLAG-MASK" USING WS-GROUP WS-NAME WS-MASK
     MOVE "acceptance US15 18§1.4 Entity metadata base slots: flag left_handed of group 3 is mask 2" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N ROUNDED = 2
     COMPUTE TL-OBSERVED-N ROUNDED = WS-MASK
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 3 TO WS-GROUP
     MOVE "aggressive" TO WS-NAME
     CALL "M181-FLAG-MASK" USING WS-GROUP WS-NAME WS-MASK
     MOVE "acceptance US15 18§1.4 Entity metadata base slots: flag aggressive of group 3 is mask 4" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N ROUNDED = 4
     COMPUTE TL-OBSERVED-N ROUNDED = WS-MASK
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO WS-GROUP
     MOVE "no_ai" TO WS-NAME
     CALL "M181-FLAG-MASK" USING WS-GROUP WS-NAME WS-MASK
     MOVE "acceptance US15 18§1.4 Entity metadata base slots: flag no_ai of group 1 is mask 0" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N ROUNDED = 0
     COMPUTE TL-OBSERVED-N ROUNDED = WS-MASK
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 2 TO WS-GROUP
     MOVE "on_fire" TO WS-NAME
     CALL "M181-FLAG-MASK" USING WS-GROUP WS-NAME WS-MASK
     MOVE "acceptance US15 18§1.4 Entity metadata base slots: flag on_fire of group 2 is mask 0" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N ROUNDED = 0
     COMPUTE TL-OBSERVED-N ROUNDED = WS-MASK
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 4 TO WS-GROUP
     MOVE "no_ai" TO WS-NAME
     CALL "M181-FLAG-MASK" USING WS-GROUP WS-NAME WS-MASK
     MOVE "acceptance US15 18§1.4 Entity metadata base slots: flag no_ai of group 4 is mask 0" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N ROUNDED = 0
     COMPUTE TL-OBSERVED-N ROUNDED = WS-MASK
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM TEST-MOB-18-1-4.
