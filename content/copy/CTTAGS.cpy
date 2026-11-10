*> The tag loader's collected files (docs/protocol/23-registry-loading.md section 6.3 step A), shared by the programs of
*> tags.cob (EXTERNAL). TAG-ADD-FILE appends the entries of each pack's tag file in pack order; TAGS-BUILD
*> resolves them. A tag exists once any file of it has been read (a file that fails to decode still creates
*> it). Package-private.
 78 TG-MAX-TAGS             VALUE 4096.
 78 TG-MAX-ENTRIES          VALUE 16384.
 01 TG-STATE EXTERNAL.
    05 TG-TAG-COUNT          BINARY-LONG.
    05 TG-ENTRY-COUNT        BINARY-LONG.
    05 TG-ERRORS             BINARY-LONG.
    05 TG-TAG OCCURS 4096 TIMES.
       10 TG-T-KEY           PIC X(112).
       10 TG-T-REGISTRY      PIC X(48).
       10 TG-T-STATE         PIC 9.         *> 0 not built, 1 being built, 2 built, 3 failed
       10 TG-T-MARK          PIC 9.         *> visited mark of TAG-REACHES
    05 TG-ENTRY OCCURS 16384 TIMES.
       10 TG-E-TAG           BINARY-LONG.   *> index of the owning tag
       10 TG-E-KIND          PIC X.         *> E element, T tag reference
       10 TG-E-REQUIRED      PIC X.         *> Y or N
       10 TG-E-ALIVE         PIC X.         *> Y, or N after a later file's replace
       10 TG-E-ID            PIC X(112).     *> namespace:path
       10 TG-E-PACK          PIC X(32).     *> the pack the entry came from
