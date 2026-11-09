# 40. Menus and screens, part 8: book and sign editors

| Item | Value |
|---|---|
| Covers | Round RS14 part 8: the text-editing screens that use no menu: `BookEditScreen` (book and quill), `BookSignScreen` (title entry and finalize), `AbstractSignEditScreen` with `SignEditScreen` and `HangingSignEditScreen`. Also the text-editing engines they use: `MultiLineEditBox` and `MultilineTextField` (the book page editor), `TextFieldHelper` (the sign line editor), `EditBox` (the book title field, only the parts it uses), `StringSplitter` (line wrapping and word stepping), the key-event predicates (`KeyEvent`, `InputWithModifiers`, `InputQuirks`), `PageButton`, how the screens are opened (`LocalPlayer.openItemGui`, `LocalPlayer.openTextEdit`, `ClientPacketListener.handleOpenSignEditor`, `handleOpenBook`, `WritableBookItem.use`, `ServerPlayer.openItemGui`), and the pixel layout of every element. |
| Source artifact | `minecraft-26.3-client.jar`, SHA-256 `4508d006323f24fa02876310c192d739af56516eb259000ac50f0909a68c9a2d` (the artifact recorded in `README.md`; protocol 777, data version 5023) |
| Method | Static reading of the shipped bytecode (`javap -c -p -constants`), `unzip -p` for `en_us.json` and the PNG headers of the textures named below, with no execution. |
| Evidence rule | Every number, key, ordering and rule below was read from the artifact in this round. "(inferred)" marks a deduction from the shape of read code. "(recalled, not verified)" marks a statement not read; each is repeated in Open questions. |
| Scope decisions | Standard Minecraft content is the target (ticket CC-0001; design README Parts 0, 1, 4; GAP-19). No data rows are tabulated: the textures and the language strings come from the resource pack (14), and the wood-type list is the set of PNG files `textures/gui/signs/*.png` and `textures/gui/hanging_signs/*.png` of the pack. Code-defined behaviour (editing rules, limits, layout, packets sent) is complete here. |
| Siblings (not repeated) | Server side of the edit-book packet and the book components: 25-item-registry-6 section 6. Server side of the sign update packet and the editor lock: 31-block-entities-3 section 2.8. `SignText`, the sign data model and the dye text colours (`DyeColor.textColor`): 31-block-entities-3 section 8. Wire layout of the packets: 05a (id 61 Open Sign Editor, id 59 Open Book), 05c (id 24 Edit Book, id 62 Sign Update). Font metrics: 12 section 5.10 and 14 section 10.3. `BookViewScreen` layout (reading a written book): 40-menus-5 section 4 (lectern and book view). Command block, structure block and jigsaw screens: 40-menus-1. Not in any document checked: the sibling classes `TestBlockEditScreen` and `TestInstanceBlockEditScreen` (present in the artifact; coverage-list note, Open question 16). |

Conventions: all coordinates are in GUI-scaled pixels (12 section 5.1); `W` and `H` are the scaled screen width and height; `/` between integers is Java integer division (truncation toward zero) unless "floor" is written. `font.width(s)` is the integer text width of a plain string, `ceil` of the float sum of the per-character advances (`Font.width(String)` = `Mth.ceil(StringSplitter.stringWidth)`; advances are 12 section 5.10 and 14 section 10.3). Line height is 9 (`Font.lineHeight`).

## 1. Overview and how each screen is opened

| Screen | Opened by | Closes with a packet? |
|---|---|---|
| `BookEditScreen` | the client itself, when the player uses a writable book (section 2.1) | only by the Done button (packet 0x18, no title) |
| `BookSignScreen` | the Sign button of `BookEditScreen` | by Sign and Close, or Enter in the title field (packet 0x18, with title) |
| `SignEditScreen` / `HangingSignEditScreen` | clientbound Open Sign Editor (05a id 61) | always on removal, however the screen closed (packet 0x3E) |

### 1.1 Opening the book editor

`WritableBookItem.use` calls `Player.openItemGui(stack, hand)` and awards the `item_used` stat (25-item-registry-6 section 6.1). The behaviour of `openItemGui` depends on the side:

1. Client (`LocalPlayer.openItemGui`): when the stack has the component `writable_book_content`, push `BookEditScreen(player, stack, hand, content)`. Otherwise nothing.
2. Server (`ServerPlayer.openItemGui`): acts only when the stack has `written_book_content` (it resolves component text, re-sends container changes when the resolution changed something, and sends the clientbound Open Book packet carrying the hand, 05a id 59). **A writable book makes the server send nothing.**
3. The base `Player.openItemGui` does nothing.

Consequence for a server implementation: the editor for a writable book is opened by the client's own prediction. `MultiPlayerGameMode.useItem` (read) runs `ItemStack.use` locally inside a prediction scope and also sends the use-item packet; the server need not send an open message. That the same local `use` runs for the use-on-block path is inferred (the block-use path was not read in this round).

`ClientPacketListener.handleOpenBook` reads the stack in the packet's hand and builds `BookViewScreen.BookAccess.fromItem`: a `written_book_content` gives the pages as text, otherwise a `writable_book_content` gives its pages as literal text, otherwise nothing opens. Only `BookViewScreen` is pushed (40-menus-5 section 4).

The text-filtering flag used when reading pages is `Minecraft.isTextFilteringEnabled()`: the account property `PROFANITY_FILTER_ENABLED` of the user service (read). For an offline or account-less client this is false (inferred).

### 1.2 Opening the sign editor

`handleOpenSignEditor` (05a id 61: Position, Side): look up the client block entity at the position. If it is a `SignBlockEntity` (or subclass) call `LocalPlayer.openTextEdit(sign, side)`; otherwise log the warning "Ignoring openTextEdit on an invalid entity" and do nothing. `openTextEdit` pushes `HangingSignEditScreen` when the block entity is a `HangingSignBlockEntity`, else `SignEditScreen`, with the filtering flag of 1.1. The server sends the block update for the sign before the open packet (31-block-entities-3 section 2.8), so the client block entity holds current text.

## 2. The book page editor engine (`MultilineTextField`)

`BookEditScreen` hosts one `MultiLineEditBox` widget whose logic is a `MultilineTextField`. This section is the engine; section 3 is the screen.

### 2.1 State

| Field | Meaning |
|---|---|
| `value` | the full text of the current page (UTF-16 code units; indexes below are code-unit indexes) |
| `cursor`, `selectCursor` | insertion point and selection anchor; a selection exists when they differ; the selected range is `[min, max)` |
| `selecting` | when true, cursor motion keeps `selectCursor`; when false, motion sets `selectCursor = cursor` |
| `characterLimit` | maximum `value` length; no limit by default (`Integer.MAX_VALUE`) |
| `lineLimit` | maximum display lines; no limit by default |
| `width` | wrap width in pixels |
| `displayLines` | list of `(beginIndex, endIndex)` views into `value`, rebuilt after every change (2.3) |
| value listener, cursor listener | callbacks run after a value change; the cursor listener scrolls the box to the cursor |

Negative limits are rejected. A new field starts with `value` empty, so `displayLines` holds one empty view.

### 2.2 Character rules

A typed character is accepted when it is an "allowed chat character": code point >= 32, not 127, not 167 (the section sign). Anything else typed is dropped silently. `filterText(s, allowNewline = true)` (used on inserted text) removes every character that is not allowed, except that a line feed (10) is kept. Therefore Tab, carriage return and every other control character, and the section sign, never enter a page, whether typed or pasted. Newline enters only through the Enter key or paste.

### 2.3 Wrapping (`StringSplitter.splitLines` with `LineBreakFinder`)

Input: `value`, wrap width `Wd`, empty style (so no bold; section signs cannot occur, 2.2). The effective limit is `max(Wd, 1.0)`. Starting at index 0, repeat until the whole text is consumed:

1. Scan characters from the start of the line, adding each character's advance to a running width. The scan keeps `lastSpace` (index of the latest space seen in this line, or none) and a flag "had a non-zero-width character".
2. A line feed ends the line at its own index.
3. A space records `lastSpace` before its width is added. After a character's width is added, if the flag is set and the running width is **greater than** the limit, the line ends at `lastSpace` when one exists, else at the index of the character just added (that character starts the next line). The flag is updated after this test, so the first character of a line always fits, however wide.
4. When the scan reaches the end without a break, the rest is one line.
5. A broken line is emitted as `(start, breakIndex)`. The next line starts at `breakIndex + 1` when the character at `breakIndex` is a space or a line feed (that character is consumed and belongs to no line), else at `breakIndex`.

After the loop, if the text is non-empty and its last character is a line feed, one extra empty view `(len, len)` is appended (the cursor can sit on the empty line after a final newline). An empty text is the single view `(0, 0)`.

Consequences: a space that overflows the limit is consumed on the line it overhangs; consecutive spaces break after only the first; a long unbroken word breaks mid-word at the last character that fits. A cursor index shared by two lines (wrapped without a consumed character: the end of one line equals the start of the next) belongs to the **earlier** line (`getLineAtCursor` returns the first view with `begin <= cursor <= end`).

### 2.4 Limits

- Character limit (1024 for a book page). On `setValue(text, force)` the text is first cut to the limit (`StringUtil.truncateStringIfNecessary(text, limit, false)`: keep the first `limit` code units, no ellipsis, no surrogate guard). With `force = false` a text that overflows the line limit is **ignored entirely**; with `force = true` it is accepted (this is how `BookEditScreen` loads a page, so a page with more than 14 lines from elsewhere can be shown). After `setValue` the cursor and anchor are at the end.
- Insert: if the **raw** argument is empty and nothing is selected, nothing happens (the test is made before filtering). Otherwise: filter (2.2); cut the inserted text to `characterLimit - value.length()` code units (the room left in the whole text; **the selection being replaced is not credited**, so replacing a selection when the text is exactly full inserts nothing and only deletes); replace the selected range with it; if the result would overflow the line limit the whole insertion is **rejected** (no change, no truncation); otherwise store, put the cursor after the inserted text and set the anchor equal, then run 2.3 and the listeners. Edge: a non-empty raw string that filters to empty (a pasted Tab, for example) with no selection does not return early: it replaces an empty range with the empty string, still stores, fires the value listener (`BookEditScreen` rewrites `pages[currentPage]` with the same text), reflows and moves the cursor to the selection start; the visible text does not change.
- Line-limit test (`overflowsLineLimit`): lines = number of lines `splitLines(text, Wd, empty style)` returns, plus 1 when `StringUtil.endsWithNewLine` is true; overflow when that count is greater than the line limit. The pattern read is `(?:\r\n|\v)$`. In Java regular expressions `\v` is the vertical-whitespace class: LF, VT, FF, CR, U+0085, U+2028 and U+2029; and `$` with MULTILINE off also matches before a final line terminator, so a match is found when the page ends in one of those characters (U+2028, U+2029 and U+0085 are allowed characters, 2.2). Such a page counts +1 line here. Asymmetry: only a real line feed (10) adds the extra empty display view of 2.3, so for a page ending in U+2028, U+2029 or U+0085 the overflow test counts one more line than the display shows.
- Deleting never overflows; a deletion that leaves the text over the limit is not possible.

### 2.5 Keys (`MultilineTextField.keyPressed`)

Every key press first sets `selecting` to "Shift is down". Then, in this order, the first rule that matches wins; every handled key returns true, others false (so the screen sees them).

Modifier helpers: Shift is the mask 3 of the modifier bits; Alt is mask 768; "edit shortcut" modifier (`hasControlDownWithQuirk`) is mask 192 (Control) on every platform except macOS, where it is mask 3072 (the Command key; `InputQuirks.EDIT_SHORTCUT_KEY_MODIFIER`, chosen by the operating system). These bit values are those of the SDL modifier word (the client reads input through SDL; `InputQuirks` calls `SDL_GetModState`).

A key event carries two numbers: `input()` is a physical **scancode** and `shortcutKey()` is the layout-dependent **keycode**. Both are SDL numbers. `KeyEvent.input()` returns the scancode field and `shortcutKey()` the keycode field (read). The predicates below use the scancode where noted. The numbers (scancodes 40, 41, 43, 44, 79, 80, 81, 82, 88; keycodes 8, 9, 13, 127, 1073741898 to 1073741906, 1073741912) were read in the predicates of `InputWithModifiers` and in `Screen.keyPressed`; only the key names given for them are (inferred).

| Rule | Condition | Action |
|---|---|---|
| Select all | keycode 97, edit shortcut down, no Shift, no Alt | `cursor = len`, `anchor = 0` |
| Copy | keycode 99, same modifiers | clipboard = selected text (empty string when none) |
| Paste | keycode 118, same | insert clipboard text (rules of 2.4; clipboard text is not otherwise preprocessed; 2.2 removes carriage returns and controls) |
| Cut | keycode 120, same | clipboard = selected text, then insert the empty string (deletes the selection) |
| Backspace | keycode 8 | edit shortcut down: delete from the cursor back to the start of the previous word (2.6); else delete one code unit before the cursor (`deleteText(-1)`) |
| Delete | keycode 127 | edit shortcut down: delete to the start of the next word; else delete one code unit after the cursor |
| Enter | keycode 13 or 1073741912 (keypad Enter, inferred from SDL numbering) | insert a line feed (subject to 2.4) |
| Left | keycode 1073741904 | edit shortcut: cursor to the start of the previous word; else cursor - 1 (one code unit, clamped to 0) |
| Right | keycode 1073741903 | edit shortcut: cursor to the start of the next word (2.6); else cursor + 1 (clamped to the length) |
| Up | keycode 1073741906 | without the edit shortcut: move up one display line (2.7); with it: nothing, still handled |
| Down | keycode 1073741905 | likewise, down |
| Home | keycode 1073741898 | edit shortcut: cursor 0; else the start of the cursor's display line |
| End | keycode 1073741901 | edit shortcut: cursor to the text length; else the end of the cursor's display line |
| Page-up key | keycode 1073741899 | cursor 0 |
| Page-down key | keycode 1073741902 | cursor to the text length |
| anything else | | not handled |

Deleting with `deleteText(n)` when nothing is selected first sets the anchor to `clamp(cursor + n, 0, len)`, then inserts the empty string; so the removed span is between the cursor and the anchor, and the cursor ends at the start of the span. At the very end of the text, Delete does nothing (no span).

After every cursor motion the "keep the anchor" rule is: when `selecting` is false the anchor follows the cursor. Left, Right, Up, Down, Home, End, Page keys all use `selecting` = Shift.

The key names given above for the numbers (page-up, Home, ...) follow the SDL numbering (inferred; "(recalled, not verified)" for the names only, the numbers are read). Behaviour is fixed by the numbers: a reimplementation must map its own key events to these scancode and keycode values.

Typed characters arrive through `MultiLineEditBox.charTyped`: accepted only when the box is visible, focused, and the character is allowed (2.2); then `insertText(character)`. It returns false otherwise.

### 2.6 Words

`MultilineTextField` uses the Java definition of whitespace (`Character.isWhitespace`) for words (this differs from the sign editor, which only treats space and line feed as separators, 5.4).

- Previous word: from `clamp(cursor, 0, len - 1)` step back over whitespace, then over non-whitespace; the word begins there and ends at the next whitespace or the end of text. Empty text gives an empty view.
- Next word: from `clamp(cursor, 0, len - 1)` step forward over non-whitespace, then over whitespace; the position reached is the start of the next word (the view's end is the next whitespace after it).
- Ctrl+Left moves to the start of the previous word. Ctrl+Right moves to the start of the next word. Ctrl+Backspace deletes from the previous word's start to the cursor; Ctrl+Delete deletes from the cursor to the next word's start.

### 2.7 Vertical motion and mouse positions

- Up and Down (`seekCursorLine(dy)` with dy of -1 or 1): `target = font.width(text from the cursor's line start to the cursor) + 2` (the bias constant `LINE_SEEK_PIXEL_BIAS` = 2). The destination line is the cursor's line index plus `dy`, clamped to the valid range, so on the first line Up recomputes within the same line. The new cursor is the destination line's begin index plus the length of the longest prefix of that line whose width is <= `target` (`Font.plainSubstrByWidth`). If the cursor's line is not found the last line is used (an error is logged).
- Longest prefix by width (`StringSplitter.plainIndexAtWidth`): walk the characters, subtracting each advance from the budget; the prefix ends before the first character that makes the budget negative. So a click lands on the boundary at or before the pointer: there is **no rounding to the nearest boundary**.
- Mouse click (`MultiLineEditBox.onClick`): a double click selects the word at the cursor (`selectWordAtCursor`: cursor to the previous-word view's begin, `selecting` on, cursor to its end); a single click sets `selecting` to Shift and moves the cursor to the pointer (`seekCursorToPoint`: `x = floor(mouseX - boxX - 4)`, `y = mouseY - boxY - 4 + scroll`; the line is `floor(y / 9)` clamped to the existing lines; then the longest prefix of that line that fits in `x`). Dragging sets `selecting` true, moves the cursor, then sets `selecting` to Shift again.

### 2.8 Drawing the box

The widget is clipped to its rectangle inset by 1 pixel on every side, translated by minus the scroll amount, and draws:

1. Nothing for background or decorations (`showBackground` false, `showDecorations` false in the book editor; so no border, no character counter and no placeholder text; the placeholder is empty anyway).
2. Each display line `i` at `x = boxX + 4`, `y = boxY + 4 + 9 * i`, colour `0xFF000000`, no shadow. Lines entirely outside the clip are skipped.
3. The selection highlight, for each display line that intersects the selection `[sb, se]` (that is `sb <= line.end` and `line.begin <= se`): `x0 = boxX + 4 + width(text[line.begin, max(sb, line.begin)])`; `x1 = boxX + 4 + (boxWidth - 4)` when `se > line.end`, else `boxX + 4 + width(text[line.begin, se])`; the rectangle is `x0..x1` by `y..y+9`. `GuiGraphicsExtractor.textHighlight(..., true)` draws it as two fills: first the whole rectangle with the `GUI_INVERT` pipeline using colour `0xFFFFFFFF`, then with the `GUI_TEXT_HIGHLIGHT` pipeline using colour `0xFF0000FF` (blue). Blend behaviour (read, `RenderPipelines` and `BlendFunction`): `GUI_INVERT` uses `BlendFunction.INVERT`: colour factors source `ONE_MINUS_DST_COLOR` and destination `ONE_MINUS_SRC_COLOR`, alpha factors `ONE` and `ZERO`. With the white source this gives, per colour channel, 1 minus the destination: the pixels under the highlight are colour-inverted. `GUI_TEXT_HIGHLIGHT` uses `ADDITIVE` (factors `ONE`, `ONE`), which adds blue `0xFF0000FF` to the result (clamped per channel).
4. The cursor, only when the box is focused (and input is captured) and the blink phase is on (`TextCursorUtils.isCursorVisible(t)`: on when `floor(t / 300) mod 2 = 0`, `t` being milliseconds since the box last gained focus; period 600 ms): when the cursor is before the end of the text, a 1-pixel-wide bar, the fill `x .. x+1` by `y-1 .. y+10` (height argument `9 + 1`; `TextCursorUtils.extractInsertCursor`), in the cursor colour; with `x = boxX + 4 + width(line text before the cursor)` of the cursor's line. When the cursor is at the end of the text, the append cursor is the character `_` drawn at the end of the last line with the text colour and no shadow. In the book editor the cursor colour is `0xFF000000`.
5. Box size: 122 x 134 for the page (section 3.2); wrap width 114 = 122 minus twice the inner padding 4; inner height of text = `9 * lineCount`; the content height reported to the scroll bar is that plus 8. With the 14-line limit the content never exceeds the box (14 x 9 + 8 = 134), so no scroll bar appears for pages made in the editor.

Sign editor edge (see 5.3): there the word target is computed as a UTF-16 code-unit index, and the difference (target minus cursor) is then passed to the code-point deletion routine, which applies `Util.offsetByCodepoints` to it, i.e. treats the code-unit delta as a code-point count. With surrogate pairs inside the span a different span from the word is deleted. The page editor above does not do this (it deletes by code units throughout).

## 3. `BookEditScreen`

### 3.1 State

`owner` (the local player), `book` (the item stack), `hand`, `pages` (a list of strings), `currentPage` (index), `signScreen` (a `BookSignScreen` created once in the constructor and reused), the page box, the two page buttons, the page-indicator text.

Construction: `pages` = the content's pages as strings (the filtered text when text filtering is on, else the raw text; `WritableBookContent.getPages(filtering)`); when that list is empty, `pages` = one empty string. `currentPage = 0`. The title is the translation `book.edit.title` (used for narration only).

Constants (all read): `TEXT_WIDTH` 114, `TEXT_HEIGHT` 126, `IMAGE_WIDTH` 192, `IMAGE_HEIGHT` 192, background texture 256 x 256, `MENU_BUTTON_SIZE` 98, `MENU_BUTTON_MARGIN` 4 (declared; the layout below uses 2 on each side of the centre), page button y 157, back button x 43, forward button x 116, page indicator offsets 148 and 16.

### 3.2 Layout (`init`)

Let `L = (W - 192) / 2` (background left) and `T = 2` (background top).

| Element | Position and size | Detail |
|---|---|---|
| Background | `(L, T)`, blit of `textures/gui/book.png` (identifier `minecraft:textures/gui/book.png`, a 256 x 256 PNG) region `u = 0, v = 0, 192 x 192`, texture size 256 x 256 | drawn in `extractBackground` after the base screen background |
| Page box | `x = (W - 114) / 2 - 8`, `y = 28`, size 122 x 134 | text colour and cursor colour `0xFF000000`, no shadow, no decorations, no background; character limit 1024; line limit `126 / 9 = 14` (integer division of 126 by `Font.lineHeight`); inner padding 4, so text origin `(x + 4, 32)` and wrap width 114 |
| Back button (`PageButton`) | `(L + 43, T + 157)`, size 23 x 13, backward | plays the page-turn sound |
| Forward button | `(L + 116, T + 157)`, size 23 x 13, forward | plays the page-turn sound |
| Sign button | `x = W/2 - 98 - 2 = W/2 - 100`, `y = T + 192 + 2 = 196`, width 98, height 20 (the default `Button.DEFAULT_HEIGHT`) | label translation `book.signButton` |
| Done button | `x = W/2 + 2`, `y = 196`, width 98, height 20 | label `gui.done` |
| Page indicator | right-aligned (`TextAlignment.RIGHT`) at `x = L + 148`, `y = T + 16` | translation `book.pageIndicator` with arguments `currentPage + 1` and the page count; component colour `0xFF000000`, no shadow |

`PageButton` draws the sprite `widget/page_forward` or `widget/page_backward` (highlighted variant `..._highlighted` when hovered or focused) at the button's top-left, size 23 x 13 (the PNGs are 23 x 13). Its narration label is the translation `book.page_button.next` ("Next Page") for the forward button and `book.page_button.previous` ("Previous Page") for the back button (narration only). It never takes keyboard focus after a click (`shouldTakeFocusAfterInteraction` false). Its press sound is `SoundEvents.BOOK_PAGE_TURN` played on the UI sound source with pitch 1.0 and volume 0.25 (the 1-argument `SimpleSoundInstance.forUI(event, pitch)` passes 0.25f; read), no attenuation and no position; the screen passes `playTurnSound = true` for both buttons. Initial focus is the page box. The screen is an in-game UI screen (`isInGameUi` true) and does not override `isPauseScreen`, so it uses the default **true** (a single-player game pauses while it is open).

Worked layout for `W = 320, H = 240`: `L = 64`; page box at `(95, 28)`, text origin `(99, 32)`; back button `(107, 159)`; forward button `(180, 159)`; page indicator right edge `212`, `y = 18`; Sign button `(60, 196)`; Done button `(162, 196)`.

### 3.3 Behaviour

1. Loading a page (`updatePageContent`): `page box.setValue(pages[currentPage], force = true)`, which puts the cursor at the end, then refresh the indicator text.
2. Value listener: every accepted change of the box (typing, paste, deletion) writes the whole value to `pages[currentPage]` immediately. A rejected insertion (2.4) writes nothing.
3. Back button visibility: visible only when `currentPage > 0`. The forward button is **always** visible.
4. Page back (button or Page-up key, keycode 1073741899): when `currentPage > 0` decrement it and load the page; always refresh visibility.
5. Page forward (button or Page-down key, keycode 1073741902): when `currentPage < pageCount - 1`, increment. Otherwise try to append an empty page (refused when there are already 100 pages, `appendPageToBook` returns when `pageCount >= 100`), then increment if the index is now less than the last. Then load the page and refresh visibility. At page 100 the forward key therefore reloads the same page.
6. Key handling order in the screen: Page-up key and Page-down key are intercepted first (they press the buttons and return true, so the text field's Home-of-text and End-of-text bindings (2.5) never fire in the book editor); every other key goes to `Screen.keyPressed`, which first handles Escape (below), then the focused widget (the page box), then focus navigation: `Screen.keyPressed` maps keycode 9 (Tab, reversed with Shift) and the four arrow keycodes to focus-navigation events after the focused widget declines the key. The screen adds five widgets in this order in `init`: page box, back button, forward button, Sign, Done. `AbstractWidget.nextFocusPath` returns nothing when the widget is not active (`isActive` = visible and active), so at page 0 the hidden back button is skipped in the Tab and arrow focus order. When Tab (or Shift+Tab) finds no next path, `Screen.keyPressed` clears the focus and asks again, so focus wraps around. Tab therefore moves focus off the page box: forward order page box, back (when visible), forward, Sign, Done, then wrapping to the first. The arrow keys are consumed by the text field (it returns true for them), so only Tab leaves the page box by keyboard. `PageButton.shouldTakeFocusAfterInteraction` false only stops a mouse click from giving the button focus.
7. **Escape discards.** `Screen.keyPressed` on Escape (scancode 41) with `shouldCloseOnEsc` (true) calls `onClose`, which sets the screen to none. `BookEditScreen` has no `removed` override and neither `onClose` nor Escape saves, so Escape (like any other close that is not the Done button) sends no packet and leaves the item stack unchanged; the typed text is lost.
8. Sign button: switch to `signScreen` (the same `pages` list object is shared). `Gui.setScreen` calls `removed` on the old screen (which does nothing here). When the sign screen later returns to this screen the screen is built again (`init`), the page box is recreated and loaded from `pages[currentPage]` with the cursor at the end; selection and scroll are lost, the text is kept because it lives in `pages`.
9. Done button (`saveChanges` after closing the screen): erase trailing empty pages: from the end of `pages`, remove every page whose string is empty, stopping at the first non-empty one (this can remove all pages, even page 0; a page of spaces is not empty). Then update the local item stack: set component `writable_book_content` to a `WritableBookContent` whose pages are the strings wrapped with `Filterable.passThrough` (no filtered alternative). Then send `ServerboundEditBookPacket` (05c id 24) with Slot, Pages, and Title absent.
10. Slot value in the packet: `hand = MAIN_HAND` gives `Inventory.getSelectedSlot()` (0 to 8) read at the moment of saving, `OFF_HAND` gives 40.
11. The screen does not clamp to 100 pages other than in step 5, and the page strings are not trimmed. Page strings have at most 1024 code units (2.4) and the wire limit is the same (25-item-registry-6 section 6.3).

## 4. `BookSignScreen`

Titles (narration only): the screen title is `book.sign.title` ("Book Sign Screen") and the title box narration name is `book.sign.titlebox` ("Title"). Constructed once by `BookEditScreen` with the edit screen, the player, the hand and the shared `pages` list. It stores a title string (initially empty) that survives Cancel. Its caption "by <name>" is the translation `book.byAuthor` with the player's display name, styled `DARK_GRAY`.

Layout (`init` and render), `L = (W - 192) / 2`:

| Element | Position and size | Detail |
|---|---|---|
| Background | `(L, 2)`, the same `book.png` region 0,0 192 x 192 as 3.2 | |
| Sign and Close button | `bounds(W/2 - 100, 196, 98, 20)` | label `book.finalizeButton`; **built inactive** (see Behaviour 1) |
| Cancel button | `bounds(W/2 + 2, 196, 98, 20)` | label `gui.cancel` |
| Title box (`EditBox`) | `x = (W - 114) / 2 - 3`, `y = 50`, size 114 x 20 | translation `book.sign.titlebox` as its narration name; max length 15; no border; centred text; text colour `0xFF000000`; no shadow; initial value = the stored title string |
| Label "Enter Book Title:" | at `x = L + 36 + (114 - font.width(label)) / 2`, `y = 34`, colour `0xFF000000`, shadow off | translation `book.editTitle` |
| Owner line | at `x = L + 36 + (114 - font.width(owner)) / 2`, `y = 60`, default colour argument `0xFF000000`, but the component carries the style colour DARK_GRAY (chat-format colour) which overrides it, so the effective colour is DARK_GRAY; shadow off | translation `book.byAuthor` |
| Warning | word-wrapped (`textWithWordWrap`) at `x = L + 36`, `y = 82`, wrap width 114, colour `0xFF000000`, shadow off | translation `book.finalizeWarning` |

Worked layout for `W = 320`: `L = 64`; title box at `(100, 50)`; Sign and Close `(60, 196)`; Cancel `(162, 196)`; wrapped warning starts at `(100, 82)`. Initial focus is the title box.

Behaviour:

1. Every change of the title box value re-evaluates the Sign and Close button: active when the value is not blank. `StringUtil.isBlank` is true for null, empty, or when every character satisfies `Character.isWhitespace` **or** `Character.isSpaceChar` (read; `isSpaceChar` adds the no-break spaces U+00A0, U+2007, U+202F and similar, which `isWhitespace` excludes), so a title of no-break spaces is blank and the button stays inactive. Initial state: the button is built inactive, then `init` installs the value responder and only afterwards calls `setValue(stored title)`, so the responder runs; when the stored title is non-blank (return from Cancel) the button is active as soon as the screen is shown (worked example 14).
2. Title field editing is that of `EditBox` (only the parts that matter here were read): the field accepts at most 15 code units (`setMaxLength(15)`); typed characters must be allowed chat characters; inserted text is filtered with `filterText` without line feeds (so a pasted line feed is dropped); a high surrogate is never left at the cut; Backspace (keycode 8), Delete (127), Left, Right, Home, End, select all, copy, paste and cut work as in a single-line field; word motion with the edit shortcut; Enter is not consumed by the field.
3. Enter (scancode 40 or 88, `isConfirmation`) with the field focused and its value **not empty** (a whitespace-only value counts as non-empty here) saves and closes exactly like the button. So Enter on a title of spaces sends an empty title (Open question 7).
4. Sign and Close (button or Enter): send `ServerboundEditBookPacket` with Slot (as in 3.3 step 10), Pages (the shared list as it is **now**: no trailing-empty-page erase and no local copy update happen on this path), Title present = the title field's value with leading and trailing whitespace removed (`String.trim`). Then set the screen to none. The server turns the book into a written book (25-item-registry-6 section 6.3).
5. Cancel: store the current title field value in the title string and return to the edit screen.
6. Escape: closes without any packet (default `Screen.keyPressed`), discarding both pages and title.
7. Like the edit screen it is an in-game UI screen with the default `isPauseScreen` true.

## 5. The sign line editor engine (`TextFieldHelper`)

`AbstractSignEditScreen` edits one line at a time with a `TextFieldHelper` bound to `messages[line]`. State: `cursorPos` and `selectionPos` (code-unit indexes). Construction puts the cursor at the end of the line with no selection. A "string validator" decides whether a candidate new line is accepted: **the font width of the candidate must be <= the sign's maximum line width** (`SignBlockEntity.getMaxTextLineWidth`: 90 for a sign, 60 for a hanging sign, section 6.1).

5.1 Typing (`charTyped`): when the code point is an allowed chat character (2.2) insert it; the call returns true always (the screen's `charTyped` also returns true always).

5.2 Insert: if a selection exists, delete it first (cursor and anchor become the selection start). Clamp the cursor into the line. Build the candidate by inserting the text at the cursor. When the validator accepts it, store the candidate as the new line and set both the cursor and the anchor to `min(candidate length, cursor + inserted length)`. When the validator rejects it the stored line is unchanged, but the selection has already been collapsed: the helper moves the cursor and anchor to the selection start before the test, so a rejected character typed over a selection leaves the text intact and the selection gone.

5.3 Keys (`TextFieldHelper.keyPressed`), first match wins; handled keys return true:

| Key | Action |
|---|---|
| select all (97, edit shortcut, no Shift, no Alt) | anchor 0, cursor at the end |
| copy (99) | clipboard = selected text |
| paste (118) | insert the clipboard text through 5.2, then anchor = cursor |
| cut (120) | clipboard = selected text; the line becomes the line without the selection (no validator test; cursor and anchor to the selection start) |
| Backspace (keycode 8) | delete one code point before the cursor, or the previous word when the edit shortcut is down (a selection is deleted instead); returns true. The word path computes `getWordPosition` as a code-unit index and passes (target - cursor) as the **code-point count** to the deletion routine (`Util.offsetByCodepoints`); with surrogate pairs in the span the deleted span differs from the word (Open question 17) |
| Delete (keycode 127) | the same toward the end (word path: same code-unit-delta-as-code-point-count edge); **returns false** (the deletion happens, but the key is reported as unhandled; harmless because the base screen has no binding for it) |
| Left (scancode 80) | move one code point left (one word with the edit shortcut); with Shift keep the anchor, else collapse |
| Right (scancode 79) | likewise to the right |
| Home (keycode 1073741898) | cursor 0; with Shift keep the anchor |
| End (keycode 1073741901) | cursor to the end; with Shift keep the anchor |
| anything else | not handled |

Cursor steps are in code points (`Util.offsetByCodepoints`), so a surrogate pair is one step. Removing characters with no selection removes the span between the cursor and the code-point-offset position and moves the cursor to the span start. A word step uses `StringSplitter.getWordPosition(text, direction, cursor, skipWhitespace = true)` whose separators are **only the space character and the line feed** (unlike 2.6): forward: find the next separator at or after the cursor (none: the end of the text), then skip all following separators; backward: skip separators immediately before the cursor, then step back over non-separators.

5.4 Clipboard (sign only): the clipboard getter takes the system clipboard text, deletes every carriage return, then applies `ChatFormatting.stripFormatting` (removes section-sign colour and format codes; the same method that 31-block-entities-3 section 2.8 cites, so the pattern is whatever that section documents). Nothing else is filtered: a pasted tab or line feed enters the line if the width check passes (Open question 9). The clipboard setter writes the text unchanged.

## 6. `AbstractSignEditScreen`, `SignEditScreen`, `HangingSignEditScreen`

### 6.1 Construction

Arguments: the `SignBlockEntity`, the `SignTextSlot` (side) and the text-filtering flag. The title is the translation `sign.edit` ("Edit Sign Message") for a sign and `hanging_sign.edit` ("Edit Hanging Sign Message") for a hanging sign.

1. Read the side's current `SignText`: `sign.getText(slot)`.
2. `messages[i]` for `i = 0..3` = the plain string of `getMessages(filtering)[i]` (`Component.getString`, so all styling is dropped), or the empty string when the list is shorter. A working copy of the `SignText` (colour, glow flag and the four literal lines) is kept in a mutable holder.
3. Preview text colour: the constructor branches on the glow flag first. Glowing text uses `DyeColor.getTextColor` of the text's colour directly and unscaled, black included (black text colour 0x1E1B1B, no alpha byte). Non-glowing text uses `AbstractSignRenderer.getDarkColor`, which here yields the dye text colour scaled by 0.4. Scaling rule (`ARGB.scaleRGB`): each of the red, green and blue channels is multiplied by 0.4f, truncated toward zero, and clamped to 0..255; the alpha byte is preserved. `getDarkColor` also contains a branch for black glowing text (constant `0xFFF0EBCC`, value -988212), but it can never be reached from this editor because glowing text never calls it. Dye text colours carry alpha 0, so the visible alpha comes from the font alpha-0 rule (12 section 5.10, its Open question 12); Open question 4 is that same question. Dye text colours: 31-block-entities-3 section 8.
4. Current line `line = 0`; blink origin = the time of the latest `init` (set again on every re-init, 6.5); the helper starts with the cursor at the end of line 0.
5. Line height and width limit come from the block entity (`getTextLineHeight`, `getMaxTextLineWidth`): sign 10 and 90; hanging sign 9 and 60 (read in `SignBlockEntity` and `HangingSignBlockEntity`).

### 6.2 Behaviour

1. `init`: start text input for this screen and add the **Done** button: `bounds(W/2 - 100, H/4 + 144, 200, 20)`, label `gui.done`.
2. `tick` (every game tick): if the local player is missing, or the sign block entity has been removed, or `SignBlockEntity.playerIsTooFarAwayToEdit(player uuid)` (the player entity cannot be found or is not within block interaction range 4.0 of the sign position), close (`onDone`).
3. Keys (`keyPressed`), in this order:
   a. Up (scancode 82): `line = (line - 1) & 3`; cursor to the end of the new line (no selection); handled.
   b. Down (scancode 81) or a confirmation key (scancode 40 Enter or 88 keypad Enter): `line = (line + 1) & 3`; cursor to the end; handled. Enter therefore never presses Done.
   c. Otherwise the `TextFieldHelper` (5.3); handled when it returns true.
   d. Otherwise `Screen.keyPressed`: Escape (scancode 41) calls `onClose`, which equals pressing Done; other keys fall to the widgets (a focused Done button reacts to the selection keys: `InputWithModifiers.isSelection` is scancode 40, 44 or 88 (Enter, Space, keypad Enter; `isConfirmation` is 40 or 88 only); the button is reachable with Tab, 3.3 step 6).
4. `isInputCaptured` is true (typing never triggers game key bindings).
5. Every accepted line change (`setMessage`): when the new string differs from the stored one, store it in `messages[line]`, set the working copy's line to `Component.literal(string)`, and call `SignBlockEntity.setText(copy, slot)` on the client's block entity. So the client's world copy of the sign changes on every keystroke (and is overwritten by the next server update), but **nothing is sent until the screen is removed**.
6. Done button, Escape, tick-invalidation and any other close all end in `onDone`: set the screen to none. `Gui.setScreen` calls `removed()`.
7. Lifecycle note: `Gui.setScreen` clears the old screen's focus, calls `TextInputManager.stopTextInput()` for it, then calls its `removed()`, so text input is already stopped when `removed()` runs. **`removed()`** (always runs when the screen goes away): if the connection exists, send `ServerboundSignUpdatePacket` (05c id 62) with Location = the sign position, Lines = the four `messages` strings (raw, unstripped, as typed or pasted; each at most 384 on the wire), Side = the slot the screen was opened with; then stop text input. So unlike the book editor, **every way of closing sends the text**, including Escape. The screen is not a pause screen (`isPauseScreen` false) and is an in-game UI screen.
8. Server semantics of the packet: 31-block-entities-3 section 2.8 (strip formatting, filter, lock check, update, `sendBlockUpdated`). Colour and glow are not editable on this screen and the packet cannot carry them.

### 6.3 Drawing (`extractRenderState`)

1. The base screen draws first (its background and widgets).
2. The title is drawn centred at `x = W/2`, `y = 40`, colour `0xFFFFFFFF` (the 5-argument `centeredText(font, title, W/2, 40, colour)` with colour argument -1). That overload has no shadow flag; it delegates to `text(font, sequence, x, y, colour)`, which passes shadow **true** (read), so the title is drawn with a shadow, unlike the book labels, which pass an explicit false. Constants: `SignEditScreen` also declares an unused `POST_HEIGHT` 14 (unused).
3. The sign preview (`extractSign`): push a transform; translate by `(W / 2.0f, yOffset)` as floats, where `yOffset` = 90 for `SignEditScreen` and 125 for `HangingSignEditScreen` (`getSignYOffset`); push, draw the background (6.4), pop; then scale by the text scale (`getSignTextScale`) and draw the four text lines (6.5); pop.
4. The IME overlay and text-input area follow the cursor position scaled by the same factor (the position is `cursorPosScratch * scale + (W/2, yOffset)`); the input-method integration is out of scope (Open question 10).

### 6.4 Background

| | `SignEditScreen` | `HangingSignEditScreen` |
|---|---|---|
| Texture | `textures/gui/signs/<wood>.png` (24 x 26 PNG) | `textures/gui/hanging_signs/<wood>.png` (16 x 16 PNG) |
| `<wood>` | `WoodType.name()` of the sign's block (`SignBlock.getWoodType`), e.g. `oak`; the shipped files are acacia, bamboo, birch, cherry, crimson, dark_oak, jungle, mangrove, oak, pale_oak, poplar, spruce, warped | same set |
| Transform inside the sign frame | translate `(0, 27)`, then scale 3.9 | translate `(0, -13)`, then scale 4.5 |
| Blit | at `(-12, -13)`, `u = 0, v = 0`, size `24 x displayedHeight`, texture size 24 x 26 | at `(-8, -8)`, `u = 0, v = 0`, size 16 x 16, texture size 16 x 16 |
| Height | `displayedHeight` = 12 when the block is wall-mounted (`PlainSignBlock.getAttachmentPoint` = WALL), else 26 | fixed 16 |
| Text scale | `0.9765628` on both axes (`MAGIC_TEXT_SCALE`; the class also names `MAGIC_BACKGROUND_SCALE` 3.9) | 1.0 (`MAGIC_BACKGROUND_SCALE` 4.5) |
| Text line height | 10 | 9 |
| Maximum line width | 90 | 60 |

### 6.5 Text lines

In the (translated and scaled) frame, for each line index `i` in 0..3 with string `s` (after bidirectional shaping when `Font.isBidirectional()`, which affects only what is drawn):

- `x = -(font.width(s)) / 2` (negate first, then Java integer division by 2, so for an odd width `w` the origin is `-(w / 2)` rounded toward zero, i.e. `-floor(w / 2)`).
- `y = i * lineHeight - (4 * lineHeight / 2)`; that is `i * 10 - 20` for a sign and `i * 9 - 18` for a hanging sign.
- Colour: the preview colour of 6.1 step 3; no shadow.

Cursor and selection for the current line `line` only, with `c` the cursor index and `a` the anchor, `P(k) = font.width(s[0, k)) - font.width(s) / 2` (here `font.width(s) / 2` is floor for the non-negative value):

- When `c >= 0` and the blink phase is on (`TextCursorUtils.isCursorVisible(now - blinkOrigin)`, 300 ms on and 300 ms off): if `c` is at or beyond the end of `s`, draw the append cursor `_` at `(P(len), y)` with the preview colour and no shadow; otherwise draw the insert cursor as a fill from `(P(c), y - 1)` to `(P(c) + 1, y + lineHeight)` in `ARGB.opaque(previewColour)`.
- The cursor position used for the input method is updated whether or not it is visible.
- When `a != c` draw the selection highlight: `x0 = min(P(c), P(a))`, `x1 = max(P(c), P(a))`, from `(x0, y)` to `(x1, y + lineHeight)` through `textHighlight(..., true)` (the two fills of 2.8 step 3).
- The blink origin is the time of the latest `init` (`cursorBlinkStartTime` is set inside `init` with `Util.getMillis`, not in the constructor). It is reset whenever the screen re-initialises (a window resize, for example) and is not reset by typing.

### 6.6 Worked layout (`W = 320`, `H = 240`)

Standing sign (ground): frame origin `(160, 90)`. Background: scale 3.9 around the point `(160, 117)`; blit rectangle from `x = 160 - 46.8 = 113.2` to `206.8` and `y = 117 - 50.7 = 66.3` to `66.3 + 101.4 = 167.7`; wall-mounted: the same x range, height `3.9 * 12 = 46.8`, so `y` 66.3 to 113.1. Text lines in screen y (scale 0.9765628): line 0 at `90 + (-20) * 0.9765628 = 70.47`, line 1 `80.23`, line 2 `90.0`, line 3 `99.77`; a line is centred on `x = 160`. Done button `(60, 204)` 200 x 20.

Hanging sign: frame origin `(160, 125)`. Background: scale 4.5 around `(160, 112)`; x from `160 - 36 = 124` to `196`, y from `112 - 36 = 76` to `148`. Text lines at `y = 107, 116, 125, 134` (height 9 each), centred on x = 160, scale 1. Done button `(60, 204)`.

## 7. Packet summary (cross-reference only)

| Action | Packet | Fields the client fills |
|---|---|---|
| Done in the book editor | 05c id 24 Edit Book | Slot (selected hotbar slot or 40), Pages (after trailing-empty erase), Title absent |
| Sign and Close | 05c id 24 | Slot, Pages (not erased), Title = trimmed title (0 to 15 code units typed, wire limit 32) |
| Any close of a sign editor | 05c id 62 Sign Update | Position, 4 lines, Side (VarInt: 0 back, 1 front) |

The server must therefore accept: a book with zero pages; a book with trailing empty pages (sign path); a title that is empty after trimming (Enter on spaces); and sign lines that contain a pasted line feed or tab. 25-item-registry-6 section 6.3 and 31-block-entities-3 section 2.8 describe what the vanilla server does with them.

## 8. Validation (checkable facts and worked examples)

The examples use a **test fixture** advance (every character 6 pixels wide, space also 6) so the arithmetic is independent of the font; real widths come from 12 section 5.10.

1. Wrap without spaces: wrap width 114, fixture advance 6, text of 25 `a`. Width after character `k` (0-based) is `6 * (k + 1)`; it exceeds 114 first at `k = 19`. No space was seen, so the break is at index 19: lines `(0, 19)` and `(19, 25)`; the next line starts at 19 because the break character is not a space or line feed.
2. Wrap at a space: width limit 66, text `hello world foo` (spaces at 5 and 11). At index 11 the space is recorded and the width becomes 72 > 66, so the break is at the space: lines `(0, 11)` = `hello world` and, because the break character is a space, the next start is 12: `(12, 15)` = `foo`.
3. Trailing newline: text `ab` + line feed, limit 114. Lines `(0, 2)`; the line feed ends the line at index 2 and is consumed (next start 3 = length); the extra view `(3, 3)` is appended: 2 display lines. `overflowsLineLimit` counts 1 split line + 1 for the trailing newline = 2.
4. Line limit: with 14 lines present and the cursor at the end, Enter makes the text end with a line feed; the count is 14 + 1 = 15 > 14, so the Enter is ignored. A 20-line paste into an empty page is rejected whole (no truncation to 14 lines); a 1500-character single-line paste is cut to 1024 code units first, then the line limit is tested on the cut text. At the real 114-pixel wrap width 1024 characters are far more than 14 lines, so in practice the paste is rejected whole (no change); it is not accepted truncated to 1024. Only a paste whose cut text fits in 14 lines is stored.
5. Character limit with a selection: a page of exactly 1024 characters with 5 characters selected; the user types `x`. Room = 1024 - 1024 = 0, so the inserted text is cut to the empty string: the 5 selected characters are deleted and nothing is inserted (length 1019).
6. Word motion: text `ab  cd` (indexes a0 b1 space2 space3 c4 d5), cursor 6. Ctrl+Backspace in the page editor: start at `clamp(6, 0, 5) = 5`; the character before index 5 is `c`, not whitespace; step back over non-whitespace to 4; the previous word begins at 4; delete `4 - 6 = -2`, i.e. two characters before the cursor: the text becomes `ab` followed by two spaces. For the sign editor on the line `ab  cd` with the cursor at 6, Ctrl+Left uses `getWordPosition(-1)`: no separator immediately before the cursor, then step back over `cd` to index 4.
7. Page turning: with 3 pages and `currentPage = 2`, the forward button appends page 4 (empty) and shows it (indicator "Page 4 of 4"); with 100 pages and `currentPage = 99` forward does not change the index. After typing `x` on page 4 and pressing Done, trailing empties are erased: pages `[p1, p2, p3, "x"]` are sent. If the user instead presses Back from page 4 without typing, Done erases page 4 first.
8. Escape: type text in the book editor, press Escape: no packet; the stack is unchanged. Press Done: one packet 0x18. In a sign editor, type text, press Escape: one packet 0x3E is sent with the typed lines.
9. Sign flow: the sign editor opens on a back-side edit with the packet `Side = 0`; the update packet carries Side 0. The four lines on the wire are exactly four strings (05c: no count prefix).
10. Sign preview layout: for `SignEditScreen` at `W = 320`, `H = 240` the Done button is at `(60, 204)`, the background spans `113.2` to `206.8` horizontally, and line 0 is drawn at screen y 70.47 (6.6).
11. Row selection: pressing Down on line 3 selects line 0 (`(3 + 1) & 3 = 0`); pressing Up on line 0 selects line 3 (`(0 - 1) & 3 = 3`); the cursor goes to the end of the target line.
12. Sign width: on a sign (limit 90), typing characters until the line's width would exceed 90 stops accepting characters; with fixture advance 6 the line holds 15 characters; on a hanging sign (limit 60) it holds 10.
13. Title field: typing 16 characters leaves 15; pasting `ab` + line feed + `cd` gives `abcd`; the Sign and Close button is inactive for the empty string, for `   ` and for a string of no-break spaces (U+00A0).
14. Cancel then Sign again: after typing the title `Hi`, Cancel returns to the edit screen; the sign screen's title field is `Hi` when opened again.
15. Slot: main hand with hotbar slot 4 selected sends Slot 4; off hand sends 40.

Implementer checklist: (a) the writable-book editor is opened by the client, never by a server message; (b) the sign editor is opened by packet 05a id 61 and always answers with 05c id 62 on close; (c) the wrap algorithm of 2.3 and the limits of 2.4 are what decide whether a keystroke is accepted; (d) key numbers are SDL scancodes and keycodes (2.5, 5.3).

## 9. Open questions

1. Closed: the blend functions of `GUI_INVERT` and `GUI_TEXT_HIGHLIGHT` were read (2.8 step 3). Remaining detail: the exact framebuffer format the factors apply to is not specified here.
2. Glyph advances (and therefore the real number of characters per line and per sign line) are not in this document; they come from 12 section 5.10 and 14 section 10.3. The worked examples use a fixture width, not font data.
3. The names of the SDL keys behind the keycodes and scancodes (page-up, page-down, Home, End, arrows, keypad Enter, Escape, Return) are inferred from the SDL numbering (recalled, not verified); the numbers themselves were read. Which physical key produces which number on the target platform is the implementer's mapping.
4. Dye text colours carry alpha 0 (the glow colour is used unscaled, the other colour scaled with alpha preserved, 6.1 step 3), so the visible alpha depends on the font alpha-0 rule: this is the same question as 12 section 5.10 Open question 12 and is not re-traced here. (31-block-entities-3 section 8 lists the RGB values.)
5. Closed: the page-turn volume is 0.25 (3.2).
6. `Screen.keyPressed` was read: Escape, then the focused widget, then keycode 9 and the arrow keycodes as focus navigation (3.3 step 6). Closed: the traversal order was read from the order of `addRenderableWidget` calls in `init`, `nextFocusPath` and `Screen.keyPressed` (3.3 step 6).
7. Enter in the title box with a whitespace-only title (non-empty, blank) sends a trimmed empty title; what the server does with an empty title (25-item-registry-6 section 6.3 does not list a check) was not read in this round.
8. Closed: the `isBlank` predicate (whitespace or space-separator) and the `LINE_END_PATTERN` expression were read (2.4, 4 step 1). Remaining: the Java `\v` class membership and the `$` rule are stated from the language definition, not from the artifact (recalled, not verified).
9. Sign-line paste lets control characters other than the carriage return through (2.2 filtering is not applied on the sign clipboard path); how a tab or line feed glyph is measured and drawn (zero width, missing-glyph box) belongs to the font engine and was not traced.
10. The input-method (IME) preedit overlay and `TextInputManager.setTextInputArea` calls of the page box and the sign screens were noted but not specified.
11. Closed: the 5-argument `centeredText` and `text` overloads pass shadow true (6.3 step 2). Whether the shadow is actually visible for a given colour depends on the font engine (12 section 5.10).
12. `MultilineTextField` can cut a surrogate pair when it truncates to the character limit or moves one code unit with Left and Right (`seekCursor` RELATIVE does not step by code points); `EditBox` and `TextFieldHelper` guard against this. Not verified how the font engine draws a lone surrogate.
13. The scroll bar of the page box (`AbstractScrollArea`, scroll sprites `widget/scroller` and `widget/scroller_background`, width 6, minimum scroller height 32) only matters for a page with more than 14 display lines (loaded from elsewhere). Read: the wheel scroll rate is the integer `int(9.0 / 2.0)` = 4 pixels per notch (the `MultiLineEditBox` constructor passes it to `AbstractScrollArea.defaultSettings`; the wheel handler subtracts wheel delta times the rate). Not traced: smoothing or clamping of the scroll amount.
14. That `Item.useOn` (use on a block) reaches `WritableBookItem.use` on the client was inferred from the default behaviour; only `MultiPlayerGameMode.useItem` was read.
15. Keyboard reach of the Sign and Done buttons in the book editor: Tab moves focus (3.3 step 6); Closed: order read (3.3 step 6).
16. Coverage list: `TestBlockEditScreen` and `TestInstanceBlockEditScreen` exist in the artifact and appear in no document checked; outside the scope of this part (book and sign editing).
17. Sign editor word delete with surrogate pairs (2.5, 5.3): the code-unit delta is treated as a code-point count; the exact deleted span for particular strings was not worked out beyond that statement.
