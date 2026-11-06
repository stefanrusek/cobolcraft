# The Brigadier command library (com.mojang:brigadier 1.3.11)

| Item | Value |
|---|---|
| Covers | The complete behaviour of the command library that the game's command framework is built on: the string reader, the command tree and its builders, the dispatcher's parse, the context and its ranges, execution (context chain, forks, result consumer), the stock argument types, suggestions, usage strings, and every built-in exception. [15](15-commands-framework.md) describes how the game uses it; this document is what 15 could not read. |
| Source artifact | `brigadier-1.3.11.jar` (`com.mojang:brigadier` version 1.3.11), SHA-256 `9d09cf4819de83dfcd38bcb212d5f2227131791cef3abbfca3321d6fb2b9a64d`, SHA-1 `3373d1e7bf00c8b99bed1ea4efb8c47344e4a887`, 80151 bytes, 65 zip entries (54 class files, a manifest, directories). |
| Provenance | The Brigadier release named by the 26.3 version manifest (libraries entry `com.mojang:brigadier:1.3.11`, url `https://libraries.minecraft.net/com/mojang/brigadier/1.3.11/brigadier-1.3.11.jar`). The 26.3 version JSON is `https://piston-meta.mojang.com/v1/packages/80608ff6753705b6a82e2cb86a5937d4d233abd4/26.3.json` (sha1 `80608ff6753705b6a82e2cb86a5937d4d233abd4`). |
| Second artifact | `minecraft-26.3-client.jar`, SHA-256 `4508d006323f24fa02876310c192d739af56516eb259000ac50f0909a68c9a2d` (recorded in [README.md](README.md)). It does **not** contain these classes. It was used only for how the game installs and calls the library: `SharedConstants` (installs the game's exception provider), `ClientboundCommandSuggestionsPacket` (suggestion wire form), and three lines of `en_us.json` for the comparison in §8. |
| Method | Static reading of the shipped bytecode (`javap -c -p -constants`, `unzip`), with no execution. |
| Evidence rule | A statement is read from the library bytecode in this round, or marked **(inferred)**, or marked **(recalled, not verified)**. The jar calls Java platform routines (`Integer.parseInt`, `Double.parseDouble`, `Double.toString`, `Character.isWhitespace`, `String.compareToIgnoreCase`, hash-set iteration); what those routines do is not in the jar, and where this document states it, it is marked recalled. |

Terminology: a *cursor* and every range are offsets into the input string counted in UTF-16 code units. A *range*
is `[start, end)`; its length is `end - start`. *Reader* is the string reader of §1. *Source* is the opaque object
the caller passes to `parse` and `execute`; the library only hands it to requirement tests, argument parsers and
commands.

---

## 1. The string reader

State: the string (fixed) and a cursor (starts at 0, set freely by `setCursor`). Nothing bounds-checks the cursor.

### 1.1 Primitives

| Primitive | Behaviour |
|---|---|
| `canRead(n)` | true when `cursor + n <= length`, that is, at least `n` characters remain. `canRead()` is `canRead(1)`. |
| `peek()` / `peek(k)` | the character at `cursor` / `cursor + k`. No check: past the end it is a Java `StringIndexOutOfBoundsException` (a runtime exception, see §3.5). |
| `read()` | returns the character at the cursor and advances by 1 (no check). |
| `skip()` | advances by 1 (no check). |
| `getRemaining()` | the text from the cursor to the end. `getRead()` is the text from 0 to the cursor. `getRemainingLength()` is `length - cursor`. `getTotalLength()` is `length`. |
| `skipWhitespace()` | while a character can be read and Java's `Character.isWhitespace` accepts it, skip it. (The set is Java's, **recalled, not verified**: space, tab, line feed, vertical tab, form feed, carriage return, the four separators U+001C to U+001F, and Unicode space separators other than the no-break spaces U+00A0, U+2007, U+202F.) The dispatcher never calls it; only argument types may. |
| `expect(c)` | if a character can be read and equals `c`, skip it; otherwise throw `readerExpectedSymbol` with the argument `c` (message `Expected 'c'`), cursor unchanged. |
| copy | a copy constructor duplicates string and cursor. The dispatcher parses each candidate node on its own copy. |

### 1.2 Character classes

| Class | Characters (read from `isAllowedInUnquotedString`, `isAllowedNumber`, `isQuotedStringStart`) |
|---|---|
| Unquoted-string character | `0`-`9`, `A`-`Z`, `a`-`z`, `_` (95), `-` (45), `.` (46), `+` (43). Nothing else; in particular no non-ASCII letters. |
| Number-run character | `0`-`9`, `.`, `-`. Not `+`, not `e`/`E`. |
| Quote start | `"` (34) or `'` (39). The escape character is `\` (92). |

### 1.3 Numbers: `readInt`, `readLong`, `readFloat`, `readDouble`

The four are identical except for the parse routine and the exception pair:

1. Remember the start. Consume the longest run of number-run characters.
2. If the run is empty: throw the type's `Expected` exception (§8) with the reader as it is now. Nothing was consumed, so the cursor equals the start.
3. Otherwise hand the run text to Java's `Integer.parseInt`, `Long.parseLong`, `Float.parseFloat` or `Double.parseDouble`. If it throws `NumberFormatException`: **set the cursor back to the start**, then throw the type's `Invalid` exception with the run text as its argument (cursor = start).
4. If it succeeds the cursor stays after the run.

What the Java routines accept on a run built from `0-9 . -` (**recalled, not verified**; the jar only calls them):

| Type | Accepted | Rejected (so `Invalid ... 'run'`) |
|---|---|---|
| int, long | an optional leading `-` then one or more digits, fitting 32 / 64 bits; leading zeros allowed (`007` is 7), `-0` is 0 | `-` alone, `1.5`, `1-2`, `--1`, any run with `.`, overflow such as `2147483648` |
| float, double | an optional leading `-`, digits with at most one `.`, at least one digit overall (`5.`, `.5`, `-.5`, `1.25` are all valid) | `.` alone, `-`, `-.`, `1.2.3`, `1-2`, `--1` |
| float, double overflow | a long digit string whose value is beyond the type's range parses to positive or negative infinity **without** an exception; it is then caught by the range check of §5 and printed as `Infinity` | |

Explicit cases (the first two are consequences of the character class and the table above, the parse behaviour is recalled, not verified): `-0` is a valid run and gives 0 (integer) or negative zero (float/double); a lone `-` or a lone `.` is a non-empty run that the Java routine rejects, so the result is `Invalid integer '-'` / `Invalid double '.'` (and likewise long and float) with the cursor set back to the start of the run. An empty run is the separate `Expected ...` error with the cursor at the start.

What an implementer needs for float and double (recalled, not verified; Java platform behaviour): the digit string has no length limit, and the decimal-to-binary conversion must be correctly rounded to the nearest representable single-precision (float) or double-precision value, ties to even; a value beyond the largest finite value rounds to infinity. An implementation must therefore not parse by accumulating digits in a narrower type.

The value is single precision for `readFloat` and double precision for `readDouble`. Consequences read from the character class: `1e5` reads the number `1` and stops at `e`; `+3` is an empty run; `NaN` and `Infinity` cannot be typed.

### 1.4 Booleans, strings

| Routine | Behaviour |
|---|---|
| `readUnquotedString` | the longest run of unquoted-string characters, possibly empty; never throws. The cursor stops at the first other character. |
| `readQuotedString` | if nothing can be read: return `""` (no error). Else if the character is not a quote start: throw `readerExpectedStartOfQuote` at the cursor. Else skip the quote and call `readStringUntil(that quote character)`. |
| `readStringUntil(q)` | consume characters one at a time into the result. A backslash arms the escape flag (and is not copied). With the flag armed the next character is copied and the flag cleared if it is `q` or a backslash; any other character after a backslash: step the cursor back by one (so it points at that offending character) and throw `readerInvalidEscape` with the character as argument. An unescaped `q` ends the string and is consumed. Reaching the end of input (including after a trailing lone backslash) throws `readerExpectedEndOfQuote` with the cursor at the end of the input. Everything else, spaces included, is copied. Only the **active** quote may be escaped: inside `"..."` the sequence `\'` is an invalid escape, and inside `'...'` the sequence `\"` is. |
| `readString` | if nothing can be read: `""`. If the character is a quote start: skip it and `readStringUntil` that quote. Otherwise `readUnquotedString`. |
| `readBoolean` | remember the start; `readString`; if the result is empty throw `readerExpectedBool` (cursor wherever `readString` left it: the start for plain empty input, **after the closing quote for `""`**); if it equals `true` or `false` exactly (lower case) return it; otherwise set the cursor back to the start and throw `readerInvalidBool` with the text. Because it uses `readString`, `"true"` and `'false'` are accepted. |

### 1.5 Error text and context

Every `CommandSyntaxException` carries a message, a type, and optionally the input string and a cursor, captured when it is created (`createWithContext` snapshots the reader's string and its **current** cursor, so the cursor in the table of §8 is the cursor at creation).

| Part | Rule |
|---|---|
| Context text | defined only when the input is present and the cursor is not negative. With `c = min(len(input), cursor)`: `"..."` if `c > 10`, then `input[max(0, c-10) .. c)`, then `<--[HERE]`. Nothing after the cursor is shown. |
| Full message | the raw message; if a context exists, then ` at position <cursor>: <context>` appended (the cursor printed is the stored cursor, not `c`). |
| Without context | an exception made by `create(...)` has no input and cursor `-1`; its message is just the raw message. |

---

## 2. The tree

### 2.1 Nodes

| Field | Root | Literal | Argument |
|---|---|---|---|
| name | `""` | the literal text | the argument name |
| usage text | `""` | the literal | `<name>` |
| children | map name to node, **insertion order** (a linked map) | same | same |
| literal view | map name to literal child | same | same |
| argument view | map name to argument child | same | same |
| requirement | always true | predicate over the source (default always true) | same |
| command | none | optional | optional |
| redirect target | none | optional | optional |
| modifier | an identity-like default | optional | optional |
| fork flag | false | flag | flag |
| extra | | | argument type; optional custom suggestion provider |

`getChildren()` is the insertion-ordered value list. `getChild(name)` is a lookup in the combined map. A node's children are used by parsing even if it has a redirect (the redirect adds a continuation, it does not remove children; the builders forbid having both, the merge of §2.3 does not).

Ordering helper `compareTo` (used by callers that sort nodes; not used by the library itself): a literal sorts before an argument; two literals compare their names, two arguments compare their names, using Java string comparison (UTF-16 code units).

`toString` forms: root `<root>`, literal `<literal NAME>`, argument `<argument NAME:TYPE>` where `TYPE` is the type's `toString` (§5).

### 2.2 Builders

| Operation | Behaviour |
|---|---|
| `literal(name)`, `argument(name, type)` | start a builder. |
| `then(child)` | **throws `IllegalStateException` "Cannot add children to a redirected node"** if a redirect has been set; otherwise adds the child (built first, if given as a builder) to the builder's own scratch root, so same-name children merge exactly as in §2.3. |
| `executes(cmd)` | sets the command (null allowed). |
| `requires(pred)` | replaces the requirement (no combination with an earlier one). |
| `redirect(target)` | forward to `target`, no modifier, not a fork. |
| `redirect(target, singleModifier)` | forward with a modifier that wraps the single result in a one-element collection (a null modifier stays null). |
| `fork(target, modifier)` | forward with the modifier and the fork flag true. |
| `forward(target, modifier, fork)` | **throws `IllegalStateException` "Cannot forward a node with children"** if children were added; otherwise records the three. |
| `suggests(provider)` (argument builder) | sets the custom suggestion provider. |
| `build()` | creates the node with the builder's command, requirement, redirect, modifier, fork flag (and provider), then adds the builder's children in their insertion order with the merge of §2.3. |
| `createBuilder()` on a node | reconstructs a builder with requirement, redirect, modifier, fork, provider and command copied (children are not copied). On the root it throws `IllegalStateException` "Cannot convert root into a builder". |
| `dispatcher.register(literalBuilder)` | builds the node, adds it to the root with the merge of §2.3, and **returns the freshly built node**, which is not necessarily the node now in the tree when a same-name node already existed. |

### 2.3 Adding a child with a name that is already present

`addChild(new)`: a root node cannot be added (`UnsupportedOperationException` "Cannot add a RootCommandNode as a child to any other CommandNode"). Otherwise look the name up in the combined children map:

| Case | Result |
|---|---|
| No child of that name | `new` is appended at the end of the children map and recorded in the literal view or the argument view according to its class. |
| A child `old` of that name exists (of **either** kind: literals and arguments share one name space) | `old` stays in place and keeps its own class, type, requirement, redirect, modifier, fork flag and provider; **`new`'s requirement, redirect, modifier, fork flag, type and provider are discarded**. If `new` has a command, it replaces `old`'s command (a null command in `new` never clears one). Each of `new`'s children is then added to `old` by this same rule, recursively, in `new`'s order. |

### 2.4 Relevant nodes (which children the parser tries)

For a node and a reader at its cursor:

1. If the node has at least one literal child: scan from the cursor to the next space (character 32) or the end of input, call that text the word, and restore the cursor. Look the word up **exactly** (case-sensitive) in the literal view. If found, the relevant set is just that one literal. Arguments are **not** tried.
2. Otherwise (no literal children, or the word is not a literal): the relevant set is every argument child in insertion order.

Only space (32) ends a word here. A word may be empty (cursor at a space or at the end); it never matches a literal.

### 2.5 Node-level parse

| Node | Parse at the reader's cursor `s` |
|---|---|
| root | does nothing. |
| literal `L` | succeeds only if at least `len(L)` characters remain and the next `len(L)` characters equal `L` exactly, **and** the character after them is the end of input or a space; the cursor is left after the literal, and the node is appended to the context with range `[s, s+len(L)]`. Otherwise the cursor is restored and `Expected literal L` (`literalIncorrect`, cursor `s`) is thrown. (Because §2.4 already matched the whole word, this failure is not reached for ordinary names; it can occur only for a literal containing a space.) |
| argument | calls the type's two-argument `parse(reader, source)` (which for every stock type is the one-argument `parse`). Let `e` be the cursor afterwards. Stores the result in the context under the argument name as a parsed argument with range `[s, e]`, and appends the node with the same range. The argument type is responsible for stopping where it stops; the dispatcher checks the separator afterwards (§3.2). |

Note: nothing skips whitespace before an argument. An argument is parsed at exactly the character after the single separator.

### 2.6 Other node services

| Service | Behaviour |
|---|---|
| `canUse(source)` | the requirement test. |
| `isValidInput(text)` (used by ambiguity search) | literal: it matches as in §2.5 on a fresh reader; argument: the type parses `text` without error and the reader is then at the end or at a space; root: false. |
| `findAmbiguities(consumer)` | for each child `A` and each other child `B` (same parent), collect the examples of `A` (literal: its own text; argument: the type's examples) that `B` accepts; if any, report `(parent, A, B, those examples)` to the consumer and clear the set; then recurse into `A`. (Diagnostic only.) |
| `dispatcher.getPath(node)` | the names (root excluded) of the first path from the root, depth first in children order, whose last node is `node`; an empty list if none. `findNode(names)` follows names from the root and returns null at the first miss. |
| equality | two nodes are equal if their children maps are equal and their commands are equal (literal also compares the text, argument also the name and type). Not needed by an implementation that compares nodes by identity. |

---

## 3. Parsing

`parse(input, source)` creates a context builder for the root with its range at the reader's current cursor, then runs the recursive node parse of §3.1 starting at the root. It returns a parse result: the context builder, the reader, and a map from node to the exception that node produced.

### 3.1 The recursive step for a node `N` (reader at cursor, context builder `C`)

Candidates are the relevant nodes of `N` (§2.4), in that order. Keep an optional list `potentials` of successful parse results and an optional insertion-ordered map `errors` of node to exception. For each candidate `X`:

1. If `X.canUse(source)` is false, skip it.
2. Make a copy `C'` of the context and a copy `R'` of the reader.
3. Run `X.parse(R', C')` (§2.5). Then require `R'` to be at the end of input or at a space; if not, the failure is `Expected whitespace to end one argument, but found trailing data` (`dispatcherExpectedArgumentSeparator`) with the cursor where `R'` is now (just after the node's text). This check applies to every node kind.
4. A `CommandSyntaxException` from step 3 is stored in `errors` under `X`; the candidate's reader copy is reset to the cursor it had before the candidate (not needed for correctness, since each candidate has its own copy); the candidate is abandoned and the next one tried. A Java **runtime exception** (for example an out-of-range `peek`) thrown inside `X.parse` is converted into a `CommandSyntaxException` `Could not parse command: <runtime message>` (`dispatcherParseException`, cursor of `R'` at that moment) and recorded the same way.
5. On success set `C'`'s command to `X`'s command (null replaces any earlier command; the context always holds the command of its last node).
6. Decide whether to continue past `X`: the reader must have **at least 1** more character if `X` has a redirect, or **at least 2** if it has none. (Two, because a separator and one more character are needed; one for a redirect, which may be followed by a separator and nothing.)
   * **Not enough characters**: add the result (`C'`, `R'`, no exceptions) to `potentials`; go to the next candidate. `R'` is left where `X` ended, so a lone trailing space stays unread.
   * **Enough, redirect present**: skip one character (the separator); build a **new** child context builder rooted at the redirect target, with its range starting at the reader's cursor and the same source; recurse (§3.1) on the redirect target with `R'` and that new builder; attach the returned context to `C'` as its child; and **return immediately** the result (`C'`, the returned reader, the returned exceptions). No other candidate is tried and `potentials` is ignored.
   * **Enough, no redirect**: skip one character (the separator, whatever it is; step 3 guaranteed it is a space), recurse on `X` with `R'` and `C'`, and add the returned result to `potentials`.
7. After the last candidate:
   * if `potentials` is not empty: if it has more than one entry, sort it with the comparator of §3.3 (a stable sort); return the first entry.
   * otherwise return a result holding the context and the reader **as they were passed in to this step** (the reader was never advanced; each candidate worked on a copy), and the `errors` map (empty if none).

### 3.2 What the result looks like

| Situation | Context | Reader cursor | Exceptions |
|---|---|---|---|
| Input fully consumed by a chain of nodes | all nodes and arguments | at the end | empty |
| A candidate failed and nothing else succeeded | the nodes before the failing one | where the step started (just after the separator that preceded the failing word) | one entry per failed candidate, insertion order |
| Chain ends with extra text (for example a node without children followed by more input) | nodes so far | after the separator that was consumed, at the start of the extra text | empty |
| Chain ends in a trailing space | nodes so far | at the unread space | empty |
| Nothing matched at the root | empty (range at the start cursor) | at the start | empty (for example, no literal and no argument child) |

### 3.3 Choosing among several successful branches (the comparator)

The comparator orders two parse results `a` and `b`; the stable sort keeps the discovery order for ties:

1. A result whose reader is at the end of input comes before one that is not.
2. Among results of equal rank in (1): a result with **no** recorded exceptions comes before one with some.
3. Otherwise they compare equal (discovery order, which is the relevant-node order of §2.4).

Only branches that did not throw at their own node are in the list (§3.1 step 4 removes the others), but a surviving branch can carry exceptions from deeper levels, which is what rule 2 tests.

### 3.4 Context, ranges, parsed arguments

| Object | Content |
|---|---|
| Context builder | source; root node; ordered list of (node, range) for each parsed node; insertion-ordered map name to parsed argument (a later argument with the same name replaces an earlier one); the command (of the last node); an optional child context (from a redirect); a range; the modifier and fork flag of the **last** node added. |
| Range of a context | starts at the cursor at which the context was created and is widened (min start, max end) by every node added. A context with no nodes has an empty range at its start cursor. |
| Parsed argument | the range `[start, end]` it consumed and the parsed value. |
| Parsed node | the node and its range. A literal's range covers its text; an argument's covers what its type consumed (a quoted string includes the quotes). |
| Copy | duplicates the command, the arguments, the nodes, the child link, the range and the fork flag; **not** the modifier (it is set again by the next `withNode`). |
| Built context | the immutable form: source, input string, arguments, command, root node, nodes, range, optional built child, modifier, fork flag. `getArgument(name, class)` looks the name up **in that context only** (not in children); a missing name throws `IllegalArgumentException` "No such argument 'NAME' exists on this command"; a value of another class throws `IllegalArgumentException` "Argument 'NAME' is defined as A, not B". `copyFor(source)` returns itself if the source is identical, otherwise a copy with the new source. |

A redirect therefore produces a **chain** of contexts: the context of everything up to and including the redirect node, whose child is the context of the target's continuation, whose range starts after the separator.

### 3.5 Parsing is purely syntactic

No command runs during `parse`. Suggestion providers and commands are not called. Requirements are consulted once per candidate (§3.1 step 1).

---

## 4. Execution

### 4.1 `execute(input, source)` (or from a parse result)

1. `parse`.
2. If the reader can still read (input remains):
   * if the exception map has **exactly one** entry, throw that exception (its own message and cursor);
   * otherwise if the context's range is empty, throw `Unknown command` (`dispatcherUnknownCommand`) with the reader's cursor;
   * otherwise throw `Incorrect argument for command` (`dispatcherUnknownArgument`) with the reader's cursor.
3. Else build the context from the input and flatten it (§4.2). If it cannot be flattened (the last context has no command): call the result consumer once with (that context, false, 0) and throw `Unknown command` at the reader's cursor.
4. Otherwise run the chain (§4.3) and return its integer.

### 4.2 Flattening

Walk from the top context down its child links. Every context that has a child is put into the ordered **modifier list**; the last context is the **executable**. If the last context has no command the flatten fails. The two-level shape is therefore: zero or more modifier contexts (each a redirect or fork node's context) followed by the executable context. A modifier context whose node had no modifier acts as the identity (§4.3). The chain also offers `getStage` (MODIFY when there are modifiers, else EXECUTE), `getTopContext` (first modifier, else the executable) and `nextStage` (the chain without its first modifier; null when there is none), for callers that schedule the stages themselves.

### 4.3 Running the chain (`executeAll`)

| Step | Rule |
|---|---|
| No modifiers | run the executable once on the original source and return its result. |
| Otherwise | `forked` starts false; the current list of sources is `[source]`. For each modifier context in order: `forked` becomes `forked OR (this context's fork flag)`; replace the list by the concatenation, in order, of the modifier's result for each source in the list (rule below). If the new list is empty, stop and return **0** (the executable never runs). After the last modifier run the executable once per source, in order, and return the **sum** of their results. The `forked` value used by every run is the value at that moment, and the executable uses the final value. |
| Run a modifier on a source | if the context's modifier is absent, the result is the one-element list `[source]`. Otherwise copy the context for that source and call the modifier, which returns a collection of sources. If it throws a `CommandSyntaxException`: call the consumer with (that context copy, false, 0); then, if `forked` is true, the result is the empty list, otherwise rethrow. |
| Run the executable on a source | copy the context for that source; call the command, which returns an int `r` or throws a `CommandSyntaxException`. On return: call the consumer with (the copy, true, `r`); the value contributed is **1 if `forked`, otherwise `r`**. On a syntax exception: call the consumer with (the copy, false, 0); if `forked`, the value contributed is 0 (the error is swallowed), otherwise rethrow. Other (runtime) exceptions are not handled and the consumer is not called. |

So the consumer always sees the command's raw result and a success flag; the **return value** of `execute` is the sum of raw results when not forked and the count of successful runs when forked. `Command.SINGLE_SUCCESS` is the constant 1; the library gives no meaning to 0 itself.

### 4.4 The result consumer

An interface `onCommandComplete(context, success, result)`; the default installed by the dispatcher does nothing; `setConsumer` replaces it. It is called once per executable run, once per failed modifier, and once on the "cannot flatten" failure of §4.1.

---

## 5. Argument types

The contract: `parse(reader)` returns a value or throws `CommandSyntaxException`, leaving the cursor after what it consumed; `parse(reader, source)` defaults to the one-argument form; `listSuggestions(context, builder)` defaults to an empty result (a completed empty `Suggestions`); `getExamples()` defaults to an empty list.

| Type | Constructors | `parse` | `toString` | Examples |
|---|---|---|---|---|
| bool | `bool()` | `readBoolean` | none (the default object text) | `true`, `false` |
| integer | `integer()`, `integer(min)`, `integer(min, max)`; default min `-2147483648`, max `2147483647` | see below | `integer()` when both are the defaults; `integer(MIN)` when only the max is the default; otherwise `integer(MIN, MAX)` (note the comma then one space) | `0`, `123`, `-123` |
| long | same with the 64-bit limits | see below | `longArg()`, `longArg(MIN)`, `longArg(MIN, MAX)` | `0`, `123`, `-123` |
| float | defaults min `-3.4028235E38` (negative largest finite float) and max `3.4028235E38`; **not** infinities | see below | `float()`, `float(MIN)`, `float(MIN, MAX)` | `0`, `1.2`, `.5`, `-1`, `-.5`, `-1234.56` |
| double | defaults `-1.7976931348623157E308` and `1.7976931348623157E308` | see below | `double()`, `double(MIN)`, `double(MIN, MAX)` | same six |
| string | `word()`, `string()`, `greedyString()` | see below | `string()` for **all three** kinds | word: `word`, `words_with_underscores`; string: `"quoted phrase"`, `word`, `""`; greedy: `word`, `words with spaces`, `"and symbols"` |

**Number types.** Remember the start cursor; read the number (§1.3); if the value is **less than min**, set the cursor back to the start and throw the `TooLow` exception with arguments (value, min); else if **greater than max**, set the cursor back to the start and throw the `TooHigh` exception with (value, max); else return the value. Both errors therefore sit at the start of the argument. The comparison is in the type's own precision (float in single precision), and a value that parsed to infinity fails the max check. The messages (§8) print the limit first and the found value second, each by Java's string conversion of the boxed number (`Integer`, `Long`, `Float`, `Double`); for floats and doubles that conversion is Java's, which the jar does not contain. The library therefore guarantees only the message template; the digits of the limit and found value are the platform's `Float.toString` / `Double.toString`. What an implementer needs to print them like Java (**recalled, not verified**): the shortest decimal digit string that rounds back to the same value in that type's own precision (single-precision digits for float); if the magnitude is at least `1e-3` and below `1e7` plain decimal with at least one digit after the point (`1.0`, `2.0`, `0.001`, `1234567.5`); otherwise computerised scientific form with one digit before the point, at least one after, `E`, and the decimal exponent (`1.0E10`, `1.0E-4`, `3.4028235E38`); zero is `0.0` (`-0.0` for negative zero); infinities print `Infinity` and `-Infinity`. Integers and longs print as plain decimal. If the game's rendering of these values (the game substitutes its own message arguments) is what matters, it is out of scope for this document.

**String types.** `word()`: `readUnquotedString` (may return the empty string without error). `string()` (quotable phrase): `readString`: an unquoted run, or a quoted string with the escapes of §1.4. `greedyString()`: the entire rest of the input from the cursor, spaces and quotes included, with no escape processing; the cursor moves to the end of the input; may be empty.

**Helper `escapeIfRequired(s)`**: if every character of `s` is an unquoted-string character, return `s` unchanged (so the empty string stays empty and unquoted); otherwise return `"` + `s` with each `"` and each `\` preceded by a backslash + `"`.

**Suggestions.** Only `bool` overrides the default: for the text `true` and then `false`, in that order, if the builder's lower-case remaining text is a prefix of it, `suggest` it (the text `true` is not suggested when the user typed exactly `true`, §6.2). The integer, long, float, double and string types suggest nothing; a node with a custom provider uses it instead of the type (§6.1).

**Typed getters** (`getInteger(context, name)` and so on) are `getArgument` with the matching class; primitive requests map to the boxed class.

---

## 6. Suggestions

### 6.1 `getCompletionSuggestions(parse, cursor)`

`cursor` defaults to the total length of the input.

1. Find the **suggestion context** (§6.3) in the parse's context for the cursor: a context builder, a parent node, and a start position.
2. `start = min(startPos, cursor)`; `truncated = input[0..cursor)`; `truncatedLower` its lower case (`Locale.ROOT`).
3. For **every child** of the parent node (in order; **the requirement is not checked here**), build a fresh context from the suggestion context's builder using `truncated` as the input, create a suggestions builder `(truncated, truncatedLower, start)`, and ask the child to list suggestions: a literal (§6.2), an argument node (its custom provider if it has one, otherwise its type). A `CommandSyntaxException` thrown by a child produces an empty result for that child, silently. (Other exceptions are not caught.)
4. When all child results are complete, merge them with the **full original input** string (not the truncated one) as in §6.4, and return that.

### 6.2 The suggestions builder

State: the input (here `truncated`), its lower case, the start, the remaining text `input[start..]`, the remaining lower case, and a list of suggestions.

| Operation | Behaviour |
|---|---|
| `suggest(text)` | **if `text` equals the remaining text exactly (case-sensitive), do nothing**; otherwise append a text suggestion with range `[start, len(input)]` and that text. A form with a tooltip message does the same. |
| `suggest(int)` | append an integer suggestion (its text is the decimal form of the value, its value kept) with range `[start, len(input)]`; **no equality check**. A form with a tooltip exists. |
| `add(other)` | append all of the other builder's suggestions. |
| `createOffset(n)` / `restart()` | a new empty builder over the same input with start `n` / the same start (so `remaining` is recomputed). |
| `build()` | `Suggestions.create(input, list)` (§6.4). |

The literal's own listing: if the literal's lower-case text starts with the builder's remaining lower-case text, `suggest(literal text)` (original case), else nothing. The root lists nothing.

### 6.3 Finding the suggestion context (`findSuggestionContext(cursor)` on a context builder)

Let `[a, b]` be the builder's range. If `a > cursor` this is an internal error (`IllegalStateException` "Can't find node before cursor").

| Case | Result (context, parent, startPos) |
|---|---|
| `b < cursor` and the builder has a child context | recurse into the child. |
| `b < cursor`, no child, at least one node | (this, the **last** node, the last node's range end + 1). The cursor is past the last node and its separator, so the suggestions are for the children of that node. |
| `b < cursor`, no child, no nodes | (this, the root node of this builder, `a`). |
| `b >= cursor` | walk the nodes in order keeping `prev` (initially the builder's root node): the first node whose range satisfies `start <= cursor <= end` gives (this, `prev`, that node's range start), i.e. the suggestions are for the children of the **previous** node, replacing the word the cursor is in. If none matches, (this, `prev`, `a`); if `prev` is absent it is an `IllegalStateException`. |

The "root node of this builder" for a context created by a redirect is the redirect target.

### 6.4 `Suggestions`

| Item | Rule |
|---|---|
| `Suggestions.create(input, suggestions)` | if the collection is empty, return the shared empty value (range `[0,0]`, empty list). Otherwise the range is `[min of starts, max of ends]` over the suggestions; every suggestion is **expanded** to that range (below) and put into a hash set (which removes duplicates: equal range, text and tooltip, and for an integer suggestion also equal value); the set is copied to a list and sorted (below). |
| Expand | a suggestion already on the target range is returned unchanged (and keeps its integer type). Otherwise its text is rebuilt: the part of `input` from the target start to the suggestion's start (if the target starts earlier), then the text, then the part of `input` from the suggestion's end to the target end (if the target ends later); the result is a plain suggestion on the target range with the same tooltip (integer-ness is lost). |
| Sort | a sort by `compareToIgnoreCase` of the suggestions (a stable sort). Text vs text: Java `String.compareToIgnoreCase` (minimum an implementer needs: compare the two texts unit by unit; for the first pair of UTF-16 units that differ, upper-case both and, if still different, lower-case both, and order by the difference; if no unit differs the shorter text sorts first. For ASCII that equals comparing the lower-cased texts, then length. The folding is Java's and is **recalled, not verified**; non-ASCII text is outside this document's guarantee). Integer vs integer: numeric order of the values. Integer vs text, either as receiver: when the **receiver** is an integer suggestion and the argument is not, case-**sensitive** comparison of the two texts; when the receiver is a text suggestion, `compareToIgnoreCase` against the other's text. (So the comparison is not symmetric when kinds are mixed; see Open question 3.) |
| Ties | two entries equal ignoring case (`Foo`, `foo`) are not ordered by anything in the library: they keep the iteration order of the hash set, which is not specified (Open question 2). |
| `Suggestions.merge(input, collection)` | an empty collection gives the empty value; a collection of exactly one is returned **as is**; otherwise all suggestions of all members go into one hash set and `create(input, set)` is applied. |
| Suggestion application | `apply(text)`: if the range is `[0, len(text)]` the result is just the suggestion text; otherwise the prefix `text[0..start)` (if start > 0), then the suggestion text, then `text[end..]` (if `end < len(text)`). |

### 6.5 The game's wire form

The game sends `Suggestions` in `ClientboundCommandSuggestionsPacket` (transaction id, **range start**, **range length** = `end - start`, then for each suggestion in list order its text and its optional tooltip; read in the constructor of that packet class). Per-suggestion ranges, the integer-ness and the numeric sort key are not sent; the client rebuilds every suggestion on the common range. The list order is the sort of §6.4, so numeric ordering of integer suggestions survives only as list order. The 1000-entry cut, the single-slot request queue and the leading `/` are game behaviour, described in [15](15-commands-framework.md) §14.

---

## 7. Usage strings

Usage text of a node: root `""`, literal its text, argument `<name>`. `restricted` below means "hide nodes the source cannot use".

### 7.1 `getAllUsage(node, source, restricted)`

Produces a list of full lines by a depth-first walk with a running prefix (empty at the start node):

1. If `restricted` and the source cannot use `node`, produce nothing for it or below.
2. If the node has a command, emit the prefix (so a start node with a command and an empty prefix emits an empty line).
3. If the node has a redirect: emit `PREFIX REDIR` where `REDIR` is `...` if the target is the dispatcher's root, otherwise `-> ` followed by the **usage text of the target node alone**; if the prefix is empty, `PREFIX` is replaced by the node's own usage text. A node with a redirect does not descend into children.
4. Otherwise, for each child in order: recurse with prefix = the child's usage text if the prefix is empty, else the prefix, a single space, and the child's usage text.

### 7.2 `getSmartUsage(node, source)`

Returns an insertion-ordered map from each child of `node` (that the source can use) to its smart usage string, using `optional = node has a command`.

The per-node function `smart(n, optional, deep)` (returns "none" when the source cannot use `n`):

| Step | Rule |
|---|---|
| 1 | `self` = usage text of `n`, wrapped as `[` text `]` if `optional`. |
| 2 | `childOptional` = `n` has a command; the group brackets are `[` `]` if so, else `(` `)`. |
| 3 | If `deep`, return `self`. |
| 4 | If `n` has a redirect, return `self` + space + (`...` for the root, else `-> ` + the target's usage text). |
| 5 | Let `kids` be the usable children. If there is exactly one, let `t = smart(kid, childOptional, childOptional)`; if not "none", return `self` + space + `t`. |
| 6 | If there are two or more: collect, as an ordered set, `smart(kid, childOptional, true)` for each kid (these are the kids' own texts, bracketed when `childOptional`). If the set has exactly one element `u`, return `self` + space + (`[u]` if `childOptional`, else `u`) (the code path wraps a text that is already bracketed, so brackets would double (inferred); the case needs two kids with identical usage text, which one name per parent makes unreachable). If the set has two or more, return `self` + space + open bracket + the kids' plain usage texts (not the set) joined by `|` + close bracket. |
| 7 | Otherwise return `self`. |

---

## 8. Messages and exceptions

The library's default provider is `BuiltInExceptions`. **The game replaces it**: `SharedConstants` stores an instance of `net.minecraft.commands.BrigadierExceptions` in the library's public static `CommandSyntaxException.BUILT_IN_EXCEPTIONS` (and sets `ENABLE_COMMAND_STACK_TRACES` from its `COMMAND_STACK_TRACES` debug flag; the library's own default for that field is `true`), and that provider builds translatable messages (keys in [15](15-commands-framework.md) §5.1). The English column below is the library default, which an implementation that does not use the game's language file would show; the game column is as stated in 15 §5.1 (not re-read here except the three lines marked *).

`A0`, `A1` are the exception's arguments in the order passed to `create`. The `Dynamic2` exceptions are created as (found, limit); the English text puts the limit first.

| Provider method | Kind | Library English text | Thrown by | Cursor in the exception | Game text (15 §5.1) differs? |
|---|---|---|---|---|---|
| `doubleTooLow` | 2 args | `Double must not be less than ` + A1 + `, found ` + A0 | double type | start of the argument | yes: `...: found %s` (colon) |
| `doubleTooHigh` | 2 | `Double must not be more than ` + A1 + `, found ` + A0 | double | start | same |
| `floatTooLow` / `floatTooHigh` | 2 | `Float must not be less than ` / `... more than ` + A1 + `, found ` + A0 | float | start | same |
| `integerTooLow` / `integerTooHigh` | 2 | `Integer must not be less than ` / `... more than ` + A1 + `, found ` + A0 | integer | start | yes (*`argument.integer.big`: `Integer must not be more than %s: found %s`) |
| `longTooLow` / `longTooHigh` | 2 | `Long must not be less than ` / `... more than ` + A1 + `, found ` + A0 | long | start | same |
| `literalIncorrect` | 1 arg | `Expected literal ` + A0 | literal node parse | start of the literal | same |
| `readerExpectedStartOfQuote` | simple | `Expected quote to start a string` | `readQuotedString` | the cursor (at the offending character) | same |
| `readerExpectedEndOfQuote` | simple | `Unclosed quoted string` | `readStringUntil` | end of the input | same |
| `readerInvalidEscape` | 1 | `Invalid escape sequence '` + A0 + `' in quoted string` | `readStringUntil` | the offending character (one after the backslash) | yes: game text has `'\%s'` (a backslash before the character) (*`parsing.quote.escape`) |
| `readerInvalidBool` | 1 | `Invalid bool, expected true or false but found '` + A0 + `'` | `readBoolean` | start | yes: `Invalid boolean: expected 'true' or 'false' but found '%s'` |
| `readerExpectedBool` | simple | `Expected bool` | `readBoolean` | after what `readString` consumed | yes: `Expected boolean` (*`parsing.bool.expected`) |
| `readerInvalidInt` | 1 | `Invalid integer '` + A0 + `'` | `readInt` | start | same |
| `readerExpectedInt` | simple | `Expected integer` | `readInt` | start | same |
| `readerInvalidLong` / `readerExpectedLong` | 1 / simple | `Invalid long '` + A0 + `'` / `Expected long` | `readLong` | start | same |
| `readerInvalidDouble` / `readerExpectedDouble` | 1 / simple | `Invalid double '` + A0 + `'` / `Expected double` | `readDouble` | start | same |
| `readerInvalidFloat` / `readerExpectedFloat` | 1 / simple | `Invalid float '` + A0 + `'` / `Expected float` | `readFloat` | start | same |
| `readerExpectedSymbol` | 1 | `Expected '` + A0 + `'` | `expect` | the cursor, unchanged | same |
| `dispatcherUnknownCommand` | simple | `Unknown command` | `execute` | the parse result's reader cursor | yes: `Unknown or incomplete command. See below for error` |
| `dispatcherUnknownArgument` | simple | `Incorrect argument for command` | `execute` | the reader cursor | same |
| `dispatcherExpectedArgumentSeparator` | simple | `Expected whitespace to end one argument, but found trailing data` | parse, after any node | just after the node's text | same |
| `dispatcherParseException` | 1 | `Could not parse command: ` + A0 (the runtime exception's message) | parse, step 4 of §3.1 | the reader copy's cursor at that moment | same |

Programming-error exceptions (not `CommandSyntaxException`): `IllegalStateException` "Cannot add children to a redirected node"; `IllegalStateException` "Cannot forward a node with children"; `IllegalStateException` "Cannot convert root into a builder"; `UnsupportedOperationException` "Cannot add a RootCommandNode as a child to any other CommandNode"; `IllegalArgumentException` "Last command in chain must be executable"; `IllegalStateException` "Can't find node before cursor"; `IllegalArgumentException` "No such argument 'NAME' exists on this command"; `IllegalArgumentException` "Argument 'NAME' is defined as A, not B".

A message made by `create()` (no reader) has no context. The text `Unknown command` of the library carries no "see below" hint; the game adds it by text, not by logic.

---

## 9. Worked examples

All examples use this tree. Children are listed in insertion order. `exec` marks a command. All requirements are true.

```
root: foo, say, tp, name, d, f, b, run, each
foo  [exec]   children: n = integer(1, 10) [exec], bar (literal) [exec]
say           child:    msg = greedyString() [exec]
tp            child:    x = integer()  ->  y = integer() [exec]
name          child:    s = string() [exec]
d             child:    v = double() [exec]
f             child:    v = float(0, 1) [exec]
b             child:    flag = bool() [exec]
run           redirect to root (no modifier)
each          fork to root; its modifier returns three sources for each source
```

Error messages below are the **library default** text (§8), full form `message at position P: context`. "Pos" is the stored cursor.

### 9.1 Parse and execution

| # | Input | Result |
|---|---|---|
| 1 | `foo` | one potential, reader at 3 (nothing left), context nodes `foo [0,3]`, command of `foo`. Executes. |
| 2 | `foo 5` | nodes `foo [0,3]`, `n [4,5]`; `n` = 5, argument range `[4,5]`; context range `[0,5]`; executes `n`'s command. |
| 3 | `foo bar` | the word `bar` is a literal child of `foo`, so only the literal is tried (the argument `n` is not): nodes `foo [0,3]`, `bar [4,7]`. Executes `bar`'s command. |
| 4 | `foo 11` | `n` reads 11, above the max: cursor reset to 4, exception `Integer must not be more than 10, found 11` pos 4. It is the only recorded exception, input remains, so `execute` throws it: `Integer must not be more than 10, found 11 at position 4: foo <--[HERE]`. |
| 5 | `foo 0` | `Integer must not be less than 1, found 0 at position 4: foo <--[HERE]`. |
| 6 | `foo abc` | the number run is empty (`a` is not a number character): `Expected integer at position 4: foo <--[HERE]`. The same for `foo +5`. |
| 7 | `foo 1.5` | the run is `1.5`, which `parseInt` rejects: cursor reset to 4, `Invalid integer '1.5' at position 4: foo <--[HERE]`. |
| 8 | `foo 2147483648` | the run overflows 32 bits: `Invalid integer '2147483648' at position 4: foo <--[HERE]` (recalled `parseInt`). |
| 9 | `foo 5x` | `n` reads 5 and stops at `x`; the character is not a space: `Expected whitespace to end one argument, but found trailing data at position 5: foo 5<--[HERE]`. |
| 10 | `foo  5` (two spaces) | after `foo` one separator is skipped (cursor 4, which is a space); `n` is tried at 4: empty run: `Expected integer at position 4: foo <--[HERE]`. |
| 11 | `foo 5 ` (trailing space) | after `n` the reader is at 5 with one character left, fewer than two, so this branch ends there with no exception and the space unread. `execute` finds input remaining, no exceptions, a non-empty range: `Incorrect argument for command at position 5: foo 5<--[HERE]`. |
| 12 | `foo 5 6` | two characters remain, so the parser skips the space and recurses into `n`, which has no children: result reader at 6, no exceptions. `Incorrect argument for command at position 6: foo 5 <--[HERE]`. |
| 13 | `tp` | parses (reader at 2) but `tp` has no command: not flattenable; the consumer gets (context, false, 0); `Unknown command at position 2: tp<--[HERE]`. |
| 14 | `bogus` | no literal matches and the root has no arguments: nothing parsed, reader at 0, range empty: `Unknown command at position 0: <--[HERE]`. `FOO` fails the same way (literals are case-sensitive). |
| 15 | `tp 1 -2` | `x` = 1 `[3,4]`, `y` = -2 `[5,7]`; executes `y`'s command. |
| 16 | `name "a b"` | `s` = `a b`, range `[5,10]` (quotes included). |
| 17 | `name "a\"b\\c"` | `s` = `a"b\c` (the text a, a quote, b, a backslash, c), range `[5,14]`. |
| 18 | `name 'a"b'` | `s` = `a"b`: inside single quotes a double quote needs no escape. |
| 19 | `name "a\'b"` | the active quote is `"`, so `\'` is an invalid escape: `Invalid escape sequence ''' in quoted string at position 8: name "a\<--[HERE]` (pos 8 is the apostrophe; the text shown is the first 8 characters). |
| 20 | `name "a\nb"` | `Invalid escape sequence 'n' in quoted string at position 8: name "a\<--[HERE]`. |
| 21 | `name "abc` | `Unclosed quoted string at position 9: name "abc<--[HERE]` (cursor at the end). |
| 22 | `name a,b` | the unquoted run is `a`; the next character is `,`: `Expected whitespace to end one argument, but found trailing data at position 6: name a<--[HERE]`. |
| 23 | `name ` | the node `name` ends with one character left: the branch ends, space unread: `Incorrect argument for command at position 4: name<--[HERE]`. |
| 24 | `d .5` | `v` = 0.5. `d 1.5.2`: `Invalid double '1.5.2' at position 2: d <--[HERE]`. `d 1e5`: the run is `1`, then `e`: `Expected whitespace to end one argument, but found trailing data at position 3: d 1<--[HERE]`. `d -`: `Invalid double '-' at position 2: d <--[HERE]`. |
| 25 | `f 2` | float max is 1: `Float must not be more than 1.0, found 2.0 at position 2: f <--[HERE]`. The `1.0` and `2.0` are Java `Float.toString` renderings (rule in §5, recalled, not verified). |
| 26 | `b yes` | `Invalid bool, expected true or false but found 'yes' at position 2: b <--[HERE]`. `b "true"` is accepted (`flag` = true, range `[2,8]`). `b ""`: `Expected bool at position 4: b ""<--[HERE]` (cursor after the quotes). |
| 27 | `say hi  there ` | `msg` = `hi  there ` (everything from the cursor, trailing space included), range from 4 to the end. |
| 28 | `run foo 5` | `run` has a redirect and more text, so the parser skips the separator and parses `foo 5` from the root in a **child context** (range starts at 4; nodes `foo [4,7]`, `n [8,9]`). The parent context has nodes `run [0,3]` and no command. Flattened: modifier list `[parent]`, executable = child. Running: `run` has no modifier, so the source passes through unchanged; the executable runs once; `execute` returns its result. |
| 29 | `run` | the redirect rule needs 1 more character and there is none: the branch ends with the context of `run` only, which has no command: `Unknown command at position 3: run<--[HERE]`. |
| 30 | `run ` | one character remains, so the redirect is followed: the child context parses nothing (the word is empty and the root has no argument child), reader at 4. Input is exhausted but the child has no command: `Unknown command at position 4: run <--[HERE]`. |
| 31 | `each foo 5` | like 28 but `each` is a fork: for the single starting source the modifier yields 3 sources; `foo`'s command runs for each; because the chain is forked the return value is the number of successful runs (3), not the sum of results. If the modifier yielded none, `execute` returns 0 and nothing runs; if the modifier threw a syntax exception it is reported to the consumer as a failure and `execute` returns 0 instead of throwing. If one run of the command throws a syntax exception, that run counts 0 and the others still run. |

### 9.2 Suggestions (library default, cursor at the end unless noted)

| # | Input (cursor) | Suggestion context | Result `Suggestions` |
|---|---|---|---|
| S1 | `fo` | context range `[0,0]` (nothing parsed), no nodes: parent = root, start 0 | range `[0,2]`, list `foo` |
| S2 | `foo ` | parsed `foo [0,3]`, branch ended: last node `foo`, start `3 + 1 = 4`; remaining is empty | the integer child suggests nothing; the literal `bar`: range `[4,4]`, list `bar` |
| S3 | `foo b` | `n` failed with `Expected integer`, the context still holds `foo`: start 4, remaining `b` | range `[4,5]`, list `bar` |
| S4 | `foo 5` with cursor 2 | the context range `[0,5]` covers the cursor; the first node containing it is `foo [0,3]` with `prev` = root: start 0, truncated input `fo` | range `[0,2]`, list `foo` |
| S5 | `foo 5` with cursor 3 | start 0, remaining `foo`; the literal `foo` equals the remaining text exactly, so `suggest` adds nothing | the empty value (range `[0,0]`, no entries) |
| S6 | `b ` | after `b`, start 2, remaining empty | `true` and `false` suggested, sorted: range `[2,2]`, list `false`, `true` |
| S7 | `b t` | `flag` failed (`Invalid bool`), start 2, remaining `t` | range `[2,3]`, list `true` |
| S8 | `b true` | start 2, remaining `true`; `true` equals it, so skipped; `false` is not a prefix match | the empty value |
| S9 | `run f` | the parent context has a child (the redirect's context, range `[4,5]` after parsing the literal `f`): recursion into the child; its range contains cursor 5, first node `f [4,5]`, `prev` = the child's root node (the redirect target, the root): start 4, remaining `f` | root children starting with `f` case-insensitively: `foo` (suggested), `f` (equal to remaining, skipped): range `[4,5]`, list `foo` |
| S10 | a provider that calls `suggest(10)`, `suggest(9)`, `suggest(100)` at start 2 on input `x ` | all three share the range `[2,2]`, so they stay integer suggestions | numeric order: `9`, `10`, `100` (a text sort would give `10`, `100`, `9`) |
| S11 | `Foo` and `foo` both suggested | equal ignoring case: both survive the duplicate removal (different text) and keep an unspecified relative order | not reproducible |

### 9.3 Usage

| # | Call | Result |
|---|---|---|
| U1 | `getAllUsage(root, source, false)` | in order: `foo`, `foo <n>`, `foo bar`, `say <msg>`, `tp <x> <y>`, `name <s>`, `d <v>`, `f <v>`, `b <flag>`, `run ...`, `each ...`. (A node with a command emits its own prefix line first; a node with a redirect to the root prints `...` and does not descend.) |
| U2 | `getSmartUsage(foo, source)` | map `n` to `[<n>]`, `bar` to `[bar]` (optional, because `foo` has a command). |
| U3 | `getSmartUsage(root, source)` | map `foo` to `foo [<n>|bar]`; `say` to `say <msg>`; `tp` to `tp <x> <y>`; `name` to `name <s>`; `run` to `run ...`; and so on in root order. For `foo`: its command makes the group optional (`[` `]`), it has two usable children, whose smart usages are `[<n>]` and `[bar]` (two distinct set entries), so the plain usage texts are joined with `|`. |
| U4 | a redirect to a non-root node `X` (usage text `foo`) | `-> foo` instead of `...`. |

---

## 10. Validation

An implementation of this document passes if:

1. The examples of §9.1 produce the same context nodes, ranges, argument values, error type, message and cursor; the 31 inputs give those results with the library-default texts of §8 (or the game's texts when the game's provider is used).
2. The unquoted character set, the number-run set and the quote rules of §1 hold, including the escape cursor (the offending character, not the backslash) and `readBoolean`'s use of `readString`.
3. A literal child always wins over argument children for the same word, argument children are tried in insertion order, and the continue-after rule is 2 characters without a redirect and 1 with a redirect.
4. The branch comparator of §3.3 (consumed-all, then no-exceptions, then discovery order) and the single-exception rule of §4.1 are reproduced, including that a redirect branch is returned immediately.
5. Same-name merging (§2.3) keeps the old node's attributes and merges commands and children.
6. Forked execution returns the count of successful runs, unforked returns the sum of results, and a modifier that yields no sources makes `execute` return 0 (§4.3).
7. Suggestions follow §6: context finding, prefix test in lower case, the equal-text drop, range union, duplicate removal, case-insensitive sort with numeric order among integer suggestions, and the wire form of §6.5.
8. Usage strings match U1 to U4.

---

## 11. Comparison with 15-commands-framework.md

Status: **C** confirmed by this reading, **D** differs (15 should be corrected), **N** cannot be confirmed from the library (game-side or unread).

| 15 section | Statement of 15 | Status | Note |
|---|---|---|---|
| header | the library's string reader, dispatcher loop, merge and sort, number parsing are recalled | C | now read; see below for the list of differences |
| 3.1 | a literal matches the exact text case-sensitively only if the word ends at a space or end of input | C | §2.4, §2.5 |
| 3.1 | a node whose requirement is false "is not parsed, not suggested and not sent" | D (part) | parse skips it (C) and usage honours it; but `getCompletionSuggestions` does **not** test requirements on the parent's children (§6.1 step 3). Whether the game filters before calling it is not in this jar (N). |
| 3.1 | command present means "can end a command" | C | §4.1, §4.2: the last context must have a command or `Unknown command` |
| 3.1 | redirect: the node's children are those of the target | C | refined: parsing continues at the target in a new child context after one separator, and the continue-rule needs only 1 character (§3.1) |
| 3.1 | modifier = a function from a source to zero or more sources; no modifier is a plain jump | C | §4.3 (absent modifier is identity; fork flag changes failure handling and return value) |
| 3.1 | a literal alias is a redirect to the first literal | N | the mechanism (redirect) exists; which names are aliases is game data; `register` returns the new node, not the merged one (§2.2) |
| 3.2 | children held by name in insertion order (linked map); a literal and an argument cannot share a name | C | one combined map (§2.1) |
| 3.2 | same name merges into one node | C | with the precise rule of §2.3 (old attributes kept, new command replaces, children merged recursively) |
| 3.2 | relevant-node rule: matching literal alone, else every argument in order, literals skipped | C | §2.4 |
| 4.1 | arguments are separated by exactly one space; whitespace not collapsed; tabs are ordinary | C | only character 32 is a separator (§2.4, §3.1) |
| 4.1 | two spaces produce an empty argument position | C (qualified) | true only for argument types that accept an empty run (`word`, `string`); number and boolean types raise their `Expected` error at that position (§9.1 example 10) |
| 4.2 | unquoted run set `0-9 A-Z a-z _ - . +` | C | §1.2 |
| 4.2 | number run set `0-9 . -`; `1e5` not a number; `+3` not an integer; `.5` valid double text | C | §1.2, §1.3 (`.5` validity is the Java parser, recalled) |
| 4.2 | quote is `"` or `'` | C | |
| 4.2 | readString: quoted if a quote, else an unquoted run, possibly empty | C | also returns `""` at the end of input |
| 4.2 | quoted string: `expected.start` if next char not a quote | C | only for `readQuotedString`; `readString` never raises it |
| 4.2 | escape: backslash then the same quote or a backslash | C | only the active quote; the other quote kind is an invalid escape |
| 4.2 | invalid escape: "cursor set at the backslash" | **D** | the cursor is the index of the character **after** the backslash (§1.4, §9.1 examples 19, 20) |
| 4.2 | end of input before the closing quote: `expected.end`, cursor at the end | C | also after a trailing lone backslash |
| 4.2 | readInt/readLong: empty gives expected at the start; non-parsing resets the cursor to the start with the run text | C | |
| 4.2 | readFloat/readDouble the same; `NaN` and `Infinity` cannot occur in a run | C (qualified) | they cannot be typed, but a huge digit string parses to infinity without an exception and then fails the max check with found `Infinity` (§1.3) |
| 4.2 | readBoolean "reads an unquoted run" | **D** | it uses `readString`: quoted `"true"` is accepted, and `""` raises `Expected bool` with the cursor **after the quotes** (§1.4) |
| 4.2 | readBoolean: `true`/`false` exact lower case; other text resets the cursor to the start | C | |
| 4.2 | `expect(c)` consumes on match, else `parsing.expected` with `c` | C | cursor unchanged on failure |
| 4.2 | skipWhitespace skips Java whitespace | C | the dispatcher never calls it |
| 4.3 | bool/float/double/integer/long grammar, then range check, cursor reset to the start of the value | C | |
| 4.3 | string kinds: word (possibly empty), quotable phrase (`readString`), greedy (the rest, spaces included) | C | greedy may be empty; no escapes processed |
| 4.3 | `Integer must not be more than 10: found 11` (library text) | **D** | the library's own text is `Integer must not be more than 10, found 11` (comma); the colon text is the game's language file, installed over the library provider (§8) |
| 4.3 | printed numbers use Java `Float.toString` etc. | C | the library only concatenates the boxed number; Java's format is platform (recalled) |
| 4.3 | (not stated) default float and double bounds | new | ±largest finite value, not infinities (§5) |
| 4.4 | the dispatcher's own exceptions are unknown command, unknown argument, separator and a wrapped runtime error | C | §8 |
| 4.4 | skip children whose requirement fails; try on a reader copy; require a space or end after an argument; record an exception per failed child | C | the separator check applies to literals too (§3.1 step 3) |
| 4.4 | continue into children only if at least two characters remain | **D** (part) | two for a node without a redirect, **one** for a node with a redirect (§3.1 step 6) |
| 4.4 | among several parses prefer consumed-all, then no exceptions, then first | C | §3.3 (stable sort; rule order exactly as stated) |
| 4.4 | (not stated) a redirect branch returns at once | new | the first candidate that parses past a redirect ends the search; later candidates and `potentials` are ignored (§3.1) |
| 4.5 | after parse: no unread input means no error; one exception means that exception; empty range means unknown command; else unknown argument | C | this is exactly the library's `execute` (§4.1) |
| 4.5 | no command at the end means `Unknown command` at the reader's cursor | C | the consumer is also called with (context, false, 0) |
| 4.5 | a trailing space after a complete command gives unknown argument | C | §9.1 examples 11, 23 |
| 4.6 | the context line: `...` when the cursor is above 10, the ten characters before the cursor | C | for the library's own text (§1.5). The "remainder red and underlined" part is the game's presentation, not the library's (N) |
| 6.10 | the Brigadier float stops at `e`, so `1e3s` has the unit run `e3s` | C | |
| 10.1 | flattening into stages; each fork or redirect with a modifier is a stage; the last stage holds the command | C | every non-last context is a modifier stage, a missing modifier being the identity (§4.2) |
| 10.1 | breadth-first command queue and the two game rules | N | game code; the library's own `executeAll` is a nested loop (§4.3). The library exposes `nextStage` etc. for that kind of scheduler |
| 10.1 | the `execute as ... run say` chain shape | N | clause structure is game data; the nesting by redirect is as §3.1 |
| 10.2 | a syntax exception counts as failure with value 0 | C | consumer gets (context, false, 0); unforked rethrows, forked swallows |
| 10.2 | results across the sources of a fork are combined (rule not read) | C (now read) | unforked: sum of the command results; forked: number of successful runs; the consumer always gets the raw result (§4.3) |
| 14.2 | the node context is the last node at or before the cursor, or the parent at the start of a word | C | exact rule in §6.3 |
| 14.2 | literals suggest their name when `name.toLowerCase().startsWith(remaining.toLowerCase())`; arguments call the type or the custom provider | C | custom provider wins; lower-casing is `Locale.ROOT` |
| 14.2 | results merged, range the union | C | §6.4 |
| 14.2 | sorted "by the lower-cased text, ties broken by the original text" | **D** | sorted by case-insensitive text only; ties are **not** broken by the original text, they follow unspecified hash-set order (§6.4) |
| 14.2 | integer suggestions compare numerically when both are integer suggestions | C | and an integer vs a text suggestion compares texts (receiver-dependent) |
| 14.2 | duplicates removed | C | equal range, text and tooltip (and value) |
| 14.2 | (not stated) a suggestion equal to the typed text is dropped | new | `suggest(String)` ignores text equal to the remaining text; `suggest(int)` does not (§6.2) |
| 14.3 | bool suggests `true`, `false` | C | each only when the typed text is a prefix; `false` sorts before `true` |
| 14.3 | (not stated) integer, long, float, double and string types suggest nothing | new | §5 |
| 14.1 | Command Suggestions carries the range start and length and each text and optional tooltip | C | §6.5 (read in the packet constructor) |
| 14.1 | the list cut at 1000, request queue, leading `/` | N | game code |
| 15.1 | `foo` gives `command.unknown.command` at pos 0 | C | |
| 15.1 | `gamemode` (no command) gives unknown command at pos 8 | C | |
| 15.1 | `gamemode ` gives `unknown.argument` at pos 8 | C | |
| 15.1 | `demo 11` gives `argument.integer.big` ("10","11") at pos 5 | C | the argument order of the library is (found, limit): `create(11, 10)`; the message puts the limit first |
| 15.1 | `demo 5x` gives the separator error at pos 6 | C | |
| 15.1 | `demo abc` gives `parsing.int.invalid` with `abc` at pos 5 | **D** | `abc` has no number characters, so the run is empty and the error is `parsing.int.expected` ("Expected integer") at pos 5; `invalid` needs a non-empty run (`1.5`, `-`) |
| 16.4 | `5x` fails with the separator error at the `x` | C | |
| 16.5 | `"bad\q"` gives `parsing.quote.escape` with `q` | C | cursor on the `q` |
| 16.6 | `2147483648` is `parsing.int.invalid` | C | via the Java parser (recalled) |
| Open question 1 | the unquoted set, the escape cursor, the sort rule and the 2-character rule should be verified | C / D | set C; escape cursor D; sort tie-break D; 2-character rule C with the redirect exception D |

---

## Open questions

1. **Java platform behaviour (recalled, not verified).** The jar calls but does not contain `Integer.parseInt`, `Long.parseLong`, `Float.parseFloat`, `Double.parseDouble` (accepted grammar and overflow to infinity, §1.3), the `toString` of boxed numbers (the printed limit and found value, §5), `Character.isWhitespace` (§1.1), and `String.compareToIgnoreCase` for non-ASCII (§6.4). An implementation that must print `found 1.0E10` or sort non-ASCII suggestions the same way has to take those from the Java specification, not from this document.
2. **Order of suggestions equal ignoring case.** The list is built from a hash set and then stably sorted, so `Foo` and `foo` keep the set's iteration order, which depends on hashes of range, text and tooltip and is not specified. An implementation must pick a deterministic order (for example the original text); that is a deliberate deviation.
3. **Mixed integer and text suggestions.** The comparison is receiver-dependent (§6.4), so it is not symmetric when both kinds appear in one list; whether Java's sort could reject that is not established. The stock argument types never mix them.
4. **Single-element set in `getSmartUsage`.** The branch of §7.2 step 6 with exactly one distinct set element needs two sibling nodes with identical usage text, which one name per parent makes unreachable; its output (possibly doubled brackets, inferred) is irrelevant in practice.
5. **Suggestions and requirements.** `getCompletionSuggestions` does not call `canUse` on the parent's children (§6.1). Whether the game compensates (it filters the tree it sends to the client, 15 §3.3) for the server-side request path was not traced here.
6. **Not run.** Nothing was executed. Every example of §9 was derived by following the bytecode by hand; a conforming test run against the real jar would settle any slip in a cursor or a range.
7. **Message text actually seen by players.** The library texts of §8 are defaults the game overrides (`SharedConstants` installs `BrigadierExceptions`); the rows marked "yes" in the last column compare against 15 §5.1, of which only three lines were re-read here (`argument.integer.big`, `parsing.bool.expected`, `parsing.quote.escape`).
8. **Game-side scheduling.** The library offers `ContextChain.getStage` / `nextStage` / `getTopContext`; how `net.minecraft.commands.execution` drives them (queue, fork limit, sequence limit) is outside this artifact and is in 15 §10.1.
9. **`CommandSyntaxException.ENABLE_COMMAND_STACK_TRACES`.** Read: the library's static initialiser sets it to `true`; the game's `SharedConstants` overwrites it with the value of its static `COMMAND_STACK_TRACES`, which is computed at start-up by `debugFlag("COMMAND_STACK_TRACES")`, a runtime debug switch whose resulting value is not in the jar. It only controls whether Java exceptions record stack traces; it has no effect on messages, cursors or results, so a COBOL implementation can ignore it.
