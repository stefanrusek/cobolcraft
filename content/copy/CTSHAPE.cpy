*> The element store of the data shape loaders of the content library (load-35-*.cob, load-36-*.cob, load-37-*.cob,
*> load-38.cob, load-39.cob; engine in shapes.cob). EXTERNAL: every program that copies this book shares the one record.
*> A loader registers the type rows of its document part (SHAPE-TYPE-ADD: a group, a type name and a field list) and
*> loads the files of the registries it owns (SHAPE-LOAD); each accepted file becomes an element row whose bytes are
*> a private copy of the file text (SH-E-ADDR, SH-E-LENGTH). The field list of a type is "<form><space><member>[=<arg>]"
*> entries separated by ";". The form is a letter: a capital means a required member, a small letter an optional one.
*>   S string        D identifier ("a:b", "b", or with "#" for H only)   I integer (arg "min..max", either side may be empty)
*>   N number (arg "min..max")   B boolean   E enum (arg "a|b|c": the value, without a "minecraft:" prefix, is one of them)
*>   O any object    A any array     X any value
*>   T an object of the group named by the arg ("-" row of the group: no "type" member; else "type" names a row)
*>   R an identifier or an object of the group    V a number or an object of the group
*>   L an array of objects of the group    K an array of identifiers
*>   P a number, an identifier or an object of the group (a provider: a constant, a registry entry or a typed object)
*>   F an object of the group, an identifier, or an array of those (a function or condition list)
*>   M an array whose elements are each of form P
*>   H a holder set of the group: an identifier or "#tag", an object of the group, or an array of identifiers and objects
*> A type row named "!" closes a group: an unknown type is an error also in a nested object (loot.cob).
*> A type row named "-" is the shape of a group whose objects carry no "type" member (a placed feature, a pool).
 78 SH-MAX-TYPES           VALUE 2048.
 78 SH-MAX-ELEMENTS        VALUE 4096.
 01 SH-STORE EXTERNAL.
    05 SH-TYPE-COUNT       BINARY-LONG.
    05 SH-ELEMENT-COUNT    BINARY-LONG.
    05 SH-MARK             BINARY-LONG.
    05 SH-TYPE OCCURS 2048 TIMES.
       10 SH-T-GROUP       PIC X(24).
       10 SH-T-NAME        PIC X(48).
       10 SH-T-FIELDS      PIC X(600).
    05 SH-ELEMENT OCCURS 4096 TIMES.
       10 SH-E-REGISTRY    PIC X(48).
       10 SH-E-KEY         PIC X(64).
       10 SH-E-TYPE        BINARY-LONG.
       10 SH-E-LENGTH      BINARY-LONG.
       10 SH-E-ADDR        USAGE POINTER.
