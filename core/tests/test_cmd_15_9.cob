*> Acceptance test of docs/protocol/15-commands-framework.md §9 Blocks, items, text and NBT: block_state and block_predicate
*> (§9.1), item_stack and item_predicate (§9.2), component and style (§9.3), nbt_compound_tag, nbt_tag and the SNBT value
*> grammar (§9.4) and nbt_path (§9.5). The world is the cobolcraft test world (blocks cardstack with axis x/y/z and punched,
*> glowtube with lit; items loam and pry_bar; the identifier without a namespace is in the namespace of the content set).
*> The result reads "ok v[start,end]" then for blocks b= the block key, p= the property pairs of the state, a= 1 for a tag,
*> 2 for a trailing NBT; for items it= the item key and a= 1 tag, 2 components or conditions, 4 any item; or
*> "err <key>|<args>@<cursor>" (cursor -1: the exception has no input context). The values of data components, the codec of
*> components and styles and the existence of block and item tags are checked at execution, not by the parse.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-CMD-15-9.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY BRIGADIER.
 COPY BRTRAIL REPLACING LEADING ==BT-== BY ==RS-==.
 01 WS-TYPES.
    05 FILLER PIC X(8) VALUE "bs".
    05 FILLER PIC S9(9) BINARY VALUE 12.
    05 FILLER PIC S9(9) BINARY VALUE 0.
    05 FILLER PIC S9(9) BINARY VALUE 0.
    05 FILLER PIC S9(9) BINARY VALUE 0.
    05 FILLER PIC S9(9) BINARY VALUE 0.
    05 FILLER PIC X(40) VALUE SPACES.
    05 FILLER PIC X(8) VALUE "bl".
    05 FILLER PIC S9(9) BINARY VALUE 13.
    05 FILLER PIC S9(9) BINARY VALUE 0.
    05 FILLER PIC S9(9) BINARY VALUE 0.
    05 FILLER PIC S9(9) BINARY VALUE 0.
    05 FILLER PIC S9(9) BINARY VALUE 0.
    05 FILLER PIC X(40) VALUE SPACES.
    05 FILLER PIC X(8) VALUE "is".
    05 FILLER PIC S9(9) BINARY VALUE 14.
    05 FILLER PIC S9(9) BINARY VALUE 0.
    05 FILLER PIC S9(9) BINARY VALUE 0.
    05 FILLER PIC S9(9) BINARY VALUE 0.
    05 FILLER PIC S9(9) BINARY VALUE 0.
    05 FILLER PIC X(40) VALUE SPACES.
    05 FILLER PIC X(8) VALUE "ip".
    05 FILLER PIC S9(9) BINARY VALUE 15.
    05 FILLER PIC S9(9) BINARY VALUE 0.
    05 FILLER PIC S9(9) BINARY VALUE 0.
    05 FILLER PIC S9(9) BINARY VALUE 0.
    05 FILLER PIC S9(9) BINARY VALUE 0.
    05 FILLER PIC X(40) VALUE SPACES.
    05 FILLER PIC X(8) VALUE "co".
    05 FILLER PIC S9(9) BINARY VALUE 18.
    05 FILLER PIC S9(9) BINARY VALUE 0.
    05 FILLER PIC S9(9) BINARY VALUE 0.
    05 FILLER PIC S9(9) BINARY VALUE 0.
    05 FILLER PIC S9(9) BINARY VALUE 0.
    05 FILLER PIC X(40) VALUE SPACES.
    05 FILLER PIC X(8) VALUE "st".
    05 FILLER PIC S9(9) BINARY VALUE 19.
    05 FILLER PIC S9(9) BINARY VALUE 0.
    05 FILLER PIC S9(9) BINARY VALUE 0.
    05 FILLER PIC S9(9) BINARY VALUE 0.
    05 FILLER PIC S9(9) BINARY VALUE 0.
    05 FILLER PIC X(40) VALUE SPACES.
    05 FILLER PIC X(8) VALUE "nc".
    05 FILLER PIC S9(9) BINARY VALUE 21.
    05 FILLER PIC S9(9) BINARY VALUE 0.
    05 FILLER PIC S9(9) BINARY VALUE 0.
    05 FILLER PIC S9(9) BINARY VALUE 0.
    05 FILLER PIC S9(9) BINARY VALUE 0.
    05 FILLER PIC X(40) VALUE SPACES.
    05 FILLER PIC X(8) VALUE "nt".
    05 FILLER PIC S9(9) BINARY VALUE 22.
    05 FILLER PIC S9(9) BINARY VALUE 0.
    05 FILLER PIC S9(9) BINARY VALUE 0.
    05 FILLER PIC S9(9) BINARY VALUE 0.
    05 FILLER PIC S9(9) BINARY VALUE 0.
    05 FILLER PIC X(40) VALUE SPACES.
    05 FILLER PIC X(8) VALUE "np".
    05 FILLER PIC S9(9) BINARY VALUE 23.
    05 FILLER PIC S9(9) BINARY VALUE 0.
    05 FILLER PIC S9(9) BINARY VALUE 0.
    05 FILLER PIC S9(9) BINARY VALUE 0.
    05 FILLER PIC S9(9) BINARY VALUE 0.
    05 FILLER PIC X(40) VALUE SPACES.
 01 WS-TYPE-TABLE REDEFINES WS-TYPES.
    05 WS-TYPE OCCURS 9 TIMES.
       10 WS-T-LIT PIC X(8).
       10 WS-T-ID PIC S9(9) BINARY.
       10 WS-T-FLAGS PIC S9(9) BINARY.
       10 WS-T-HASMIN PIC S9(9) BINARY.
       10 WS-T-IMIN PIC S9(9) BINARY.
       10 WS-T-SK PIC S9(9) BINARY.
       10 WS-T-REG PIC X(40).
 01 WS-CASES.
    05 FILLER PIC X(300) VALUE "bs glowtube[lit=false]$".
    05 FILLER PIC X(200) VALUE "ok v[3,22] b=cobolcraft:glowtube p=lit=f" &
         "alse a=0".
    05 FILLER PIC X(300) VALUE "bs cobolcraft:glowtube[lit=true]$".
    05 FILLER PIC X(200) VALUE "ok v[3,32] b=cobolcraft:glowtube p=lit=t" &
         "rue a=0".
    05 FILLER PIC X(300) VALUE "bs cardstack[axis=y,punched=true]$".
    05 FILLER PIC X(200) VALUE "ok v[3,33] b=cobolcraft:cardstack p=axis" &
         "=y,punched=true a=0".
    05 FILLER PIC X(300) VALUE "bs cardstack[ punched = false , axis = x" &
         " ]$".
    05 FILLER PIC X(200) VALUE "ok v[3,42] b=cobolcraft:cardstack p=axis" &
         "=x,punched=false a=0".
    05 FILLER PIC X(300) VALUE "bs nothing$".
    05 FILLER PIC X(200) VALUE "err argument.block.id.invalid|cobolcraft" &
         ":nothing@3".
    05 FILLER PIC X(300) VALUE "bs glowtube[x=1]$".
    05 FILLER PIC X(200) VALUE "err argument.block.property.unknown|cobo" &
         "lcraft:glowtube|x@12".
    05 FILLER PIC X(300) VALUE "bs glowtube[lit=maybe]$".
    05 FILLER PIC X(200) VALUE "err argument.block.property.invalid|cobo" &
         "lcraft:glowtube|maybe|lit@16".
    05 FILLER PIC X(300) VALUE "bs glowtube[lit]$".
    05 FILLER PIC X(200) VALUE "err argument.block.property.novalue|lit|" &
         "cobolcraft:glowtube@15".
    05 FILLER PIC X(300) VALUE "bs glowtube[lit=true,lit=false]$".
    05 FILLER PIC X(200) VALUE "err argument.block.property.duplicate|li" &
         "t|cobolcraft:glowtube@21".
    05 FILLER PIC X(300) VALUE "bs glowtube[lit=true$".
    05 FILLER PIC X(200) VALUE "err argument.block.property.unclosed@20".
    05 FILLER PIC X(300) VALUE "bs glowtube[lit=true x$".
    05 FILLER PIC X(200) VALUE "err argument.block.property.unclosed@21".
    05 FILLER PIC X(300) VALUE "bs #stone$".
    05 FILLER PIC X(200) VALUE "err argument.block.tag.disallowed@3".
    05 FILLER PIC X(300) VALUE "bl #minecraft:stone$".
    05 FILLER PIC X(200) VALUE "ok v[3,19] b= p= a=1".
    05 FILLER PIC X(300) VALUE "bl #foo[lit=true]{a:1}$".
    05 FILLER PIC X(200) VALUE "ok v[3,22] b= p= a=3".
    05 FILLER PIC X(300) VALUE "bl glowtube[lit=false]$".
    05 FILLER PIC X(200) VALUE "ok v[3,22] b=cobolcraft:glowtube p=lit=f" &
         "alse a=0".
    05 FILLER PIC X(300) VALUE "bl nothing$".
    05 FILLER PIC X(200) VALUE "err argument.block.id.invalid|cobolcraft" &
         ":nothing@3".
    05 FILLER PIC X(300) VALUE "is loam$".
    05 FILLER PIC X(200) VALUE "ok v[3,7] it=cobolcraft:loam a=0".
    05 FILLER PIC X(300) VALUE "is cobolcraft:pry_bar$".
    05 FILLER PIC X(200) VALUE "ok v[3,21] it=cobolcraft:pry_bar a=0".
    05 FILLER PIC X(300) VALUE "is pry_bar[damage=5]$".
    05 FILLER PIC X(200) VALUE "ok v[3,20] it=cobolcraft:pry_bar a=2".
    05 FILLER PIC X(300) VALUE "is loam[!food]$".
    05 FILLER PIC X(200) VALUE "ok v[3,14] it=cobolcraft:loam a=2".
    05 FILLER PIC X(300) VALUE "is loam[a=1,b={c:[1,2]}]$".
    05 FILLER PIC X(200) VALUE "ok v[3,24] it=cobolcraft:loam a=2".
    05 FILLER PIC X(300) VALUE "is loam[ a = 1 , !b ]$".
    05 FILLER PIC X(200) VALUE "ok v[3,21] it=cobolcraft:loam a=2".
    05 FILLER PIC X(300) VALUE "is loam[]$".
    05 FILLER PIC X(200) VALUE "ok v[3,9] it=cobolcraft:loam a=0".
    05 FILLER PIC X(300) VALUE "is nothing$".
    05 FILLER PIC X(200) VALUE "err argument.item.id.invalid|cobolcraft:" &
         "nothing@3".
    05 FILLER PIC X(300) VALUE "is #loam$".
    05 FILLER PIC X(200) VALUE "err argument.item.tag.disallowed@3".
    05 FILLER PIC X(300) VALUE "is loam[a=1,a=2]$".
    05 FILLER PIC X(200) VALUE "err arguments.item.component.repeated|co" &
         "bolcraft:a@-1".
    05 FILLER PIC X(300) VALUE "is loam[a=1,!a]$".
    05 FILLER PIC X(200) VALUE "err arguments.item.component.repeated|co" &
         "bolcraft:a@-1".
    05 FILLER PIC X(300) VALUE "is loam[a=1,$".
    05 FILLER PIC X(200) VALUE "err arguments.item.component.expected@12".
    05 FILLER PIC X(300) VALUE "is loam[a=1$".
    05 FILLER PIC X(200) VALUE "err parsing.expected|]@11".
    05 FILLER PIC X(300) VALUE "is loam[a=]$".
    05 FILLER PIC X(200) VALUE "err argument.nbt.expected.value@10".
    05 FILLER PIC X(300) VALUE "ip loam$".
    05 FILLER PIC X(200) VALUE "ok v[3,7] it=cobolcraft:loam a=0".
    05 FILLER PIC X(300) VALUE "ip #loam$".
    05 FILLER PIC X(200) VALUE "ok v[3,8] it= a=1".
    05 FILLER PIC X(300) VALUE "ip *$".
    05 FILLER PIC X(200) VALUE "ok v[3,4] it= a=4".
    05 FILLER PIC X(300) VALUE "ip loam[count=5]$".
    05 FILLER PIC X(200) VALUE "ok v[3,16] it=cobolcraft:loam a=2".
    05 FILLER PIC X(300) VALUE "ip loam[a|b,!c,d~e,f]$".
    05 FILLER PIC X(200) VALUE "ok v[3,21] it=cobolcraft:loam a=2".
    05 FILLER PIC X(300) VALUE "ip #x:y[a={b:1}]$".
    05 FILLER PIC X(200) VALUE "ok v[3,16] it= a=3".
    05 FILLER PIC X(300) VALUE "ip nothing$".
    05 FILLER PIC X(200) VALUE "err argument.item.id.invalid|cobolcraft:" &
         "nothing@3".
    05 FILLER PIC X(300) VALUE "ip loam[a=$".
    05 FILLER PIC X(200) VALUE "err argument.nbt.expected.value@10".
    05 FILLER PIC X(300) VALUE "co ""hello world""$".
    05 FILLER PIC X(200) VALUE "ok v[3,16]".
    05 FILLER PIC X(300) VALUE "co {text:'x'}$".
    05 FILLER PIC X(200) VALUE "ok v[3,13]".
    05 FILLER PIC X(300) VALUE "co [""""]$".
    05 FILLER PIC X(200) VALUE "ok v[3,7]".
    05 FILLER PIC X(300) VALUE "co 5$".
    05 FILLER PIC X(200) VALUE "ok v[3,4]".
    05 FILLER PIC X(300) VALUE "st {bold:true}$".
    05 FILLER PIC X(200) VALUE "ok v[3,14]".
    05 FILLER PIC X(300) VALUE "st {color:'red'}$".
    05 FILLER PIC X(200) VALUE "ok v[3,16]".
    05 FILLER PIC X(300) VALUE "st {}$".
    05 FILLER PIC X(200) VALUE "ok v[3,5]".
    05 FILLER PIC X(300) VALUE "co {$".
    05 FILLER PIC X(200) VALUE "err argument.nbt.expected.key@4".
    05 FILLER PIC X(300) VALUE "nc {a:1,b:""x"",c:[1,2],d:{e:1b}}$".
    05 FILLER PIC X(200) VALUE "ok v[3,31]".
    05 FILLER PIC X(300) VALUE "nc {}$".
    05 FILLER PIC X(200) VALUE "ok v[3,5]".
    05 FILLER PIC X(300) VALUE "nc { a : 1 , b : 2 }$".
    05 FILLER PIC X(200) VALUE "ok v[3,20]".
    05 FILLER PIC X(300) VALUE "nc 5$".
    05 FILLER PIC X(200) VALUE "err argument.nbt.expected.compound@3".
    05 FILLER PIC X(300) VALUE "nc {a:1}x$".
    05 FILLER PIC X(200) VALUE "err command.expected.separator@8".
    05 FILLER PIC X(300) VALUE "nc {a:1$".
    05 FILLER PIC X(200) VALUE "err parsing.expected|}@7".
    05 FILLER PIC X(300) VALUE "nc {:1}$".
    05 FILLER PIC X(200) VALUE "err argument.nbt.expected.key@4".
    05 FILLER PIC X(300) VALUE "nc {"""":1}$".
    05 FILLER PIC X(200) VALUE "err snbt.parser.empty_key@4".
    05 FILLER PIC X(300) VALUE "nc {a 1}$".
    05 FILLER PIC X(200) VALUE "err parsing.expected|:@6".
    05 FILLER PIC X(300) VALUE "nc {a:}$".
    05 FILLER PIC X(200) VALUE "err argument.nbt.expected.value@6".
    05 FILLER PIC X(300) VALUE "nc {a:1,}$".
    05 FILLER PIC X(200) VALUE "err argument.nbt.expected.key@8".
    05 FILLER PIC X(300) VALUE "nt 5$".
    05 FILLER PIC X(200) VALUE "ok v[3,4]".
    05 FILLER PIC X(300) VALUE "nt 5b$".
    05 FILLER PIC X(200) VALUE "ok v[3,5]".
    05 FILLER PIC X(300) VALUE "nt 5S$".
    05 FILLER PIC X(200) VALUE "ok v[3,5]".
    05 FILLER PIC X(300) VALUE "nt 1.5f$".
    05 FILLER PIC X(200) VALUE "ok v[3,7]".
    05 FILLER PIC X(300) VALUE "nt 1.5$".
    05 FILLER PIC X(200) VALUE "ok v[3,6]".
    05 FILLER PIC X(300) VALUE "nt true$".
    05 FILLER PIC X(200) VALUE "ok v[3,7]".
    05 FILLER PIC X(300) VALUE "nt false$".
    05 FILLER PIC X(200) VALUE "ok v[3,8]".
    05 FILLER PIC X(300) VALUE "nt abc$".
    05 FILLER PIC X(200) VALUE "ok v[3,6]".
    05 FILLER PIC X(300) VALUE "nt [1,2]$".
    05 FILLER PIC X(200) VALUE "ok v[3,8]".
    05 FILLER PIC X(300) VALUE "nt []$".
    05 FILLER PIC X(200) VALUE "ok v[3,5]".
    05 FILLER PIC X(300) VALUE "nt [B;1b,2b]$".
    05 FILLER PIC X(200) VALUE "ok v[3,12]".
    05 FILLER PIC X(300) VALUE "nt [I;1,2]$".
    05 FILLER PIC X(200) VALUE "ok v[3,10]".
    05 FILLER PIC X(300) VALUE "nt [L;1l,2]$".
    05 FILLER PIC X(200) VALUE "ok v[3,11]".
    05 FILLER PIC X(300) VALUE "nt [B;]$".
    05 FILLER PIC X(200) VALUE "ok v[3,7]".
    05 FILLER PIC X(300) VALUE "nt 0x1F$".
    05 FILLER PIC X(200) VALUE "ok v[3,7]".
    05 FILLER PIC X(300) VALUE "nt 0b101$".
    05 FILLER PIC X(200) VALUE "ok v[3,8]".
    05 FILLER PIC X(300) VALUE "nt 1_000$".
    05 FILLER PIC X(200) VALUE "ok v[3,8]".
    05 FILLER PIC X(300) VALUE "nt 'a\x41'$".
    05 FILLER PIC X(200) VALUE "ok v[3,10]".
    05 FILLER PIC X(300) VALUE "nt ""a\n\s""$".
    05 FILLER PIC X(200) VALUE "ok v[3,10]".
    05 FILLER PIC X(300) VALUE "nt -5$".
    05 FILLER PIC X(200) VALUE "ok v[3,5]".
    05 FILLER PIC X(300) VALUE "nt +5$".
    05 FILLER PIC X(200) VALUE "ok v[3,5]".
    05 FILLER PIC X(300) VALUE "nt 1e5$".
    05 FILLER PIC X(200) VALUE "ok v[3,6]".
    05 FILLER PIC X(300) VALUE "nt 1.5E-3d$".
    05 FILLER PIC X(200) VALUE "ok v[3,10]".
    05 FILLER PIC X(300) VALUE "nt 5ub$".
    05 FILLER PIC X(200) VALUE "ok v[3,6]".
    05 FILLER PIC X(300) VALUE "nt bool(true)$".
    05 FILLER PIC X(200) VALUE "ok v[3,13]".
    05 FILLER PIC X(300) VALUE "nt uuid(""12345678-1234-1234-1234-123456" &
         "789abc"")$".
    05 FILLER PIC X(200) VALUE "ok v[3,47]".
    05 FILLER PIC X(300) VALUE "nt {a:1}$".
    05 FILLER PIC X(200) VALUE "ok v[3,8]".
    05 FILLER PIC X(300) VALUE "nt [I;1b]$".
    05 FILLER PIC X(200) VALUE "err snbt.parser.invalid_array_element_ty" &
         "pe@6".
    05 FILLER PIC X(300) VALUE "nt [B;1i]$".
    05 FILLER PIC X(200) VALUE "err snbt.parser.invalid_array_element_ty" &
         "pe@6".
    05 FILLER PIC X(300) VALUE "nt [L;1.5]$".
    05 FILLER PIC X(200) VALUE "err snbt.parser.invalid_array_element_ty" &
         "pe@6".
    05 FILLER PIC X(300) VALUE "nt 01$".
    05 FILLER PIC X(200) VALUE "err snbt.parser.leading_zero_not_allowed" &
         "@3".
    05 FILLER PIC X(300) VALUE "nt 1_$".
    05 FILLER PIC X(200) VALUE "err snbt.parser.undescore_not_allowed@3".
    05 FILLER PIC X(300) VALUE "nt ""abc$".
    05 FILLER PIC X(200) VALUE "err parsing.quote.expected.end@7".
    05 FILLER PIC X(300) VALUE "nt foo(1)$".
    05 FILLER PIC X(200) VALUE "err snbt.parser.no_such_operation|foo@3".
    05 FILLER PIC X(300) VALUE "nt 5x$".
    05 FILLER PIC X(200) VALUE "err snbt.parser.invalid_unquoted_start@3".
    05 FILLER PIC X(300) VALUE "nt [1,2$".
    05 FILLER PIC X(200) VALUE "err parsing.expected|]@7".
    05 FILLER PIC X(300) VALUE "nt [1 2]$".
    05 FILLER PIC X(200) VALUE "err parsing.expected|]@6".
    05 FILLER PIC X(300) VALUE "nt '\q'$".
    05 FILLER PIC X(200) VALUE "err snbt.parser.invalid_string_contents@" &
         "5".
    05 FILLER PIC X(300) VALUE "np foo$".
    05 FILLER PIC X(200) VALUE "ok v[3,6]".
    05 FILLER PIC X(300) VALUE "np foo.bar$".
    05 FILLER PIC X(200) VALUE "ok v[3,10]".
    05 FILLER PIC X(300) VALUE "np foo[0]$".
    05 FILLER PIC X(200) VALUE "ok v[3,9]".
    05 FILLER PIC X(300) VALUE "np []$".
    05 FILLER PIC X(200) VALUE "ok v[3,5]".
    05 FILLER PIC X(300) VALUE "np [0]$".
    05 FILLER PIC X(200) VALUE "ok v[3,6]".
    05 FILLER PIC X(300) VALUE "np {a:1}$".
    05 FILLER PIC X(200) VALUE "ok v[3,8]".
    05 FILLER PIC X(300) VALUE "np foo{a:1}$".
    05 FILLER PIC X(200) VALUE "ok v[3,11]".
    05 FILLER PIC X(300) VALUE "np foo[{a:1}]$".
    05 FILLER PIC X(200) VALUE "ok v[3,13]".
    05 FILLER PIC X(300) VALUE "np ""a b"".c$".
    05 FILLER PIC X(200) VALUE "ok v[3,10]".
    05 FILLER PIC X(300) VALUE "np foo.bar[0].baz$".
    05 FILLER PIC X(200) VALUE "ok v[3,17]".
    05 FILLER PIC X(300) VALUE "np a[-1]$".
    05 FILLER PIC X(200) VALUE "ok v[3,8]".
    05 FILLER PIC X(300) VALUE "np a[{b:1}].c$".
    05 FILLER PIC X(200) VALUE "ok v[3,13]".
    05 FILLER PIC X(300) VALUE "np 'x'{y:2}$".
    05 FILLER PIC X(200) VALUE "ok v[3,11]".
    05 FILLER PIC X(300) VALUE "np foo.{a:1}$".
    05 FILLER PIC X(200) VALUE "err arguments.nbtpath.node.invalid@7".
    05 FILLER PIC X(300) VALUE "np foo..bar$".
    05 FILLER PIC X(200) VALUE "err arguments.nbtpath.node.invalid@7".
    05 FILLER PIC X(300) VALUE "np foo[$".
    05 FILLER PIC X(200) VALUE "err parsing.int.expected@7".
    05 FILLER PIC X(300) VALUE "np foo[x]$".
    05 FILLER PIC X(200) VALUE "err parsing.int.expected@7".
    05 FILLER PIC X(300) VALUE "np foo[0$".
    05 FILLER PIC X(200) VALUE "err parsing.expected|]@8".
    05 FILLER PIC X(300) VALUE "np foo]$".
    05 FILLER PIC X(200) VALUE "err parsing.expected|.@6".
 01 WS-TABLE REDEFINES WS-CASES.
    05 WS-CASE OCCURS 114 TIMES.
       10 WS-CASE-LINE PIC X(300).
       10 WS-CASE-EXPECTED PIC X(200).
 01 WS-LINE                PIC X(1024).
 01 WS-LENGTH              BINARY-LONG.
 01 WS-LEVEL               BINARY-LONG VALUE 4.
 01 WS-VERDICT             BINARY-LONG.
 01 WS-COMMAND             BINARY-LONG.
 01 WS-TEXT                PIC X(1024).
 01 WS-POS                 BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-E                   BINARY-LONG.
 01 WS-EDIT                PIC -(19)9.
 01 WS-NUMBER              PIC X(32).
 01 WS-NUMBER-LENGTH       BINARY-LONG.
 01 WS-KIND-DOUBLE         BINARY-LONG VALUE 2.
 01 WS-ZERO-INF            BINARY-LONG VALUE 0.
 01 WS-NODE                BINARY-LONG.
 01 WS-CHILD               BINARY-LONG.
 01 WS-CREATED             BINARY-LONG.
 01 WS-NAME                PIC X(32).
 01 WS-NAME-LENGTH         BINARY-LONG.
 01 WS-KIND                BINARY-LONG.
 01 WS-TYPE-ID             BINARY-LONG.
 01 WS-EXPECTED            PIC X(1024).
 01 WS-ARG-TEXT            PIC X(1024).
 COPY COREAPI.
 COPY CBLOCKS.
 COPY CITEMS.
 01 WS-PROPS               PIC X(160).
 01 WS-BLOCK               BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-LEN                 BINARY-LONG.
 PROCEDURE DIVISION.
     PERFORM SETUP
     CALL "BR-TREE-RESET"
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 9
         PERFORM ADD-TYPE
     END-PERFORM
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 114
         MOVE WS-CASE-LINE(WS-I) TO WS-LINE
         MOVE WS-CASE-EXPECTED(WS-I) TO WS-EXPECTED
         PERFORM CHECK
     END-PERFORM
     GOBACK.

*> A literal under the root named WS-T-LIT(WS-I) with the argument "v" of its type (command WS-I).
 ADD-TYPE.
     MOVE 1 TO WS-NODE
     MOVE BR-LITERAL TO WS-KIND
     MOVE 0 TO WS-TYPE-ID
     MOVE WS-T-LIT(WS-I) TO WS-NAME
     MOVE FUNCTION LENGTH(FUNCTION TRIM(WS-NAME)) TO WS-NAME-LENGTH
     CALL "BR-ADD-NODE" USING WS-NODE WS-KIND WS-NAME WS-NAME-LENGTH WS-TYPE-ID WS-CHILD WS-CREATED
     MOVE WS-CHILD TO WS-NODE
     MOVE BR-ARGUMENT TO WS-KIND
     MOVE "v" TO WS-NAME
     MOVE 1 TO WS-NAME-LENGTH
     MOVE WS-T-ID(WS-I) TO WS-TYPE-ID
     CALL "BR-ADD-NODE" USING WS-NODE WS-KIND WS-NAME WS-NAME-LENGTH WS-TYPE-ID WS-CHILD WS-CREATED
     MOVE WS-I TO BR-N-COMMAND(WS-CHILD)
     MOVE WS-T-FLAGS(WS-I) TO BR-N-FLAGS(WS-CHILD)
     MOVE WS-T-HASMIN(WS-I) TO BR-N-HAS-MIN(WS-CHILD)
     MOVE WS-T-IMIN(WS-I) TO BR-N-IMIN(WS-CHILD)
     MOVE WS-T-SK(WS-I) TO BR-N-STRING-KIND(WS-CHILD)
     MOVE FUNCTION LENGTH(FUNCTION TRIM(WS-T-REG(WS-I))) TO BR-N-REG-LENGTH(WS-CHILD)
     MOVE WS-T-REG(WS-I) TO BR-N-REG(WS-CHILD).

 CHECK.
     MOVE 4 TO WS-LEVEL
     IF WS-LINE(1:2) = "0>"
         MOVE 0 TO WS-LEVEL
         MOVE WS-LINE(3:) TO WS-ARG-TEXT
         MOVE WS-ARG-TEXT TO WS-LINE
     END-IF
     MOVE 0 TO WS-LENGTH
     INSPECT WS-LINE TALLYING WS-LENGTH FOR CHARACTERS BEFORE INITIAL "$"
     MOVE SPACE TO WS-LINE(WS-LENGTH + 1:1)
     CALL "BR-PARSE" USING WS-LEVEL WS-LINE WS-LENGTH RS-TRAIL
     CALL "BR-VERDICT" USING RS-TRAIL WS-VERDICT WS-COMMAND
     MOVE SPACES TO WS-TEXT
     MOVE 1 TO WS-POS
     IF WS-VERDICT = 0
         PERFORM DESCRIBE-OK
     ELSE
         PERFORM DESCRIBE-ERROR
     END-IF
     MOVE SPACES TO TL-CASE
     MOVE WS-LEVEL TO WS-EDIT
     STRING "acceptance US13 15§9 Blocks, items, text and NBT [" WS-LINE(1:WS-LENGTH) "] level " FUNCTION TRIM(WS-EDIT) DELIMITED BY SIZE INTO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE WS-EXPECTED TO TL-EXPECTED
     MOVE WS-TEXT TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

 DESCRIBE-ERROR.
     STRING "err " FUNCTION TRIM(BR-E-KEY) DELIMITED BY SIZE INTO WS-TEXT WITH POINTER WS-POS
     PERFORM VARYING WS-E FROM 1 BY 1 UNTIL WS-E > BR-E-ARG-COUNT
         STRING "|" DELIMITED BY SIZE INTO WS-TEXT WITH POINTER WS-POS
         IF BR-E-ARG-LENGTH(WS-E) > 0
             STRING BR-E-ARG(WS-E)(1:BR-E-ARG-LENGTH(WS-E)) DELIMITED BY SIZE
                 INTO WS-TEXT WITH POINTER WS-POS
         END-IF
     END-PERFORM
     MOVE BR-E-CURSOR TO WS-EDIT
     STRING "@" FUNCTION TRIM(WS-EDIT) DELIMITED BY SIZE INTO WS-TEXT WITH POINTER WS-POS.

*> "ok" and the argument range, then the value text of the type.
 DESCRIBE-OK.
     MOVE "ok" TO WS-TEXT(1:2)
     MOVE 3 TO WS-POS
     MOVE RS-COUNT TO WS-E
     MOVE RS-START(WS-E) TO WS-EDIT
     STRING " v[" FUNCTION TRIM(WS-EDIT) "," DELIMITED BY SIZE INTO WS-TEXT WITH POINTER WS-POS
     MOVE RS-END(WS-E) TO WS-EDIT
     STRING FUNCTION TRIM(WS-EDIT) "]" DELIMITED BY SIZE INTO WS-TEXT WITH POINTER WS-POS
     MOVE BR-N-TYPE(RS-NODE(WS-E)) TO WS-TYPE-ID
     PERFORM DESCRIBE-VALUE.

*> " i=<n>" for an integer value
 PUT-INT.
     MOVE RS-IVAL(WS-E) TO WS-EDIT
     STRING " i=" FUNCTION TRIM(WS-EDIT) DELIMITED BY SIZE INTO WS-TEXT WITH POINTER WS-POS.

*> a double as Java prints it
 PUT-DOUBLE-1.
     CALL "BR-NUMBER-TEXT" USING WS-KIND-DOUBLE RS-IVAL(WS-E) RS-DVAL(WS-E) WS-ZERO-INF
         WS-NUMBER WS-NUMBER-LENGTH
     STRING WS-NUMBER(1:WS-NUMBER-LENGTH) DELIMITED BY SIZE INTO WS-TEXT WITH POINTER WS-POS.

 PUT-DOUBLE-2.
     CALL "BR-NUMBER-TEXT" USING WS-KIND-DOUBLE RS-IVAL2(WS-E) RS-DVAL2(WS-E) WS-ZERO-INF
         WS-NUMBER WS-NUMBER-LENGTH
     STRING WS-NUMBER(1:WS-NUMBER-LENGTH) DELIMITED BY SIZE INTO WS-TEXT WITH POINTER WS-POS.


 DESCRIBE-VALUE.
     EVALUATE WS-TYPE-ID
         WHEN BR-P-BLOCK-STATE
         WHEN BR-P-BLOCK-PREDICATE
             PERFORM DESCRIBE-BLOCK
         WHEN BR-P-ITEM-STACK
         WHEN BR-P-ITEM-PREDICATE
             PERFORM DESCRIBE-ITEM
         WHEN OTHER
             CONTINUE
     END-EVALUATE.

 DESCRIBE-BLOCK.
     STRING " b=" DELIMITED BY SIZE INTO WS-TEXT WITH POINTER WS-POS
     MOVE SPACES TO WS-PROPS
     IF RS-IVAL(WS-E) >= 0
         COMPUTE WS-BLOCK = CB-S-BLOCK(RS-IVAL(WS-E) + 1) + 1
         MOVE CB-KEY-LENGTH(WS-BLOCK) TO WS-LEN
         STRING CB-KEY(WS-BLOCK)(1:WS-LEN) DELIMITED BY SIZE INTO WS-TEXT WITH POINTER WS-POS
         MOVE RS-IVAL(WS-E) TO WS-STATE
         CALL "BLOCKS-STATE-PROPS" USING WS-STATE WS-PROPS
     END-IF
     MOVE FUNCTION LENGTH(FUNCTION TRIM(WS-PROPS TRAILING)) TO WS-LEN
     IF WS-PROPS = SPACES
         MOVE 0 TO WS-LEN
     END-IF
     STRING " p=" DELIMITED BY SIZE INTO WS-TEXT WITH POINTER WS-POS
     IF WS-LEN > 0
         STRING WS-PROPS(1:WS-LEN) DELIMITED BY SIZE INTO WS-TEXT WITH POINTER WS-POS
     END-IF
     MOVE RS-AUX(WS-E) TO WS-EDIT
     STRING " a=" FUNCTION TRIM(WS-EDIT) DELIMITED BY SIZE INTO WS-TEXT WITH POINTER WS-POS.

 DESCRIBE-ITEM.
     STRING " it=" DELIMITED BY SIZE INTO WS-TEXT WITH POINTER WS-POS
     IF RS-IVAL(WS-E) >= 0
         COMPUTE WS-BLOCK = RS-IVAL(WS-E) + 1
         MOVE IT-KEY-LENGTH(WS-BLOCK) TO WS-LEN
         STRING IT-KEY(WS-BLOCK)(1:WS-LEN) DELIMITED BY SIZE INTO WS-TEXT WITH POINTER WS-POS
     END-IF
     MOVE RS-AUX(WS-E) TO WS-EDIT
     STRING " a=" FUNCTION TRIM(WS-EDIT) DELIMITED BY SIZE INTO WS-TEXT WITH POINTER WS-POS.


 SETUP.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS.

 END PROGRAM TEST-CMD-15-9.


 COPY CORETEST.
