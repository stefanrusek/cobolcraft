*> What ENTITY-NBT-ONE has read of a compound into the fields of ENKFIELDS.cpy (KD- instead of EK-): KD-GROUP is MOVEd to EK-ENTRY(row) once the entity exists.
 01 KD-DATA.
    05 KD-GROUP.
       COPY ENKFIELDS REPLACING LEADING ==EK-== BY ==KD-==.
