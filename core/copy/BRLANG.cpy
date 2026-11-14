*> English texts of the framework translation keys (docs/protocol/15-commands-framework.md §5.1 to §5.4,
*> one row per key of the tables; the two group rows, the selector option tooltips and snbt.parser.*,
*> are not here). A text has %s and %n$s positional arguments. Used by BR-LANG-TEXT
*> (core/src/cmd-lang.cob) for console lines.
 78 LG-COUNT               VALUE 173.
 01 LG-TABLE.
    05 FILLER PIC X(48) VALUE "command.unknown.command".
    05 FILLER PIC X(200) VALUE "Unknown or incomplete command. See below for error".
    05 FILLER PIC X(48) VALUE "command.unknown.argument".
    05 FILLER PIC X(200) VALUE "Incorrect argument for command".
    05 FILLER PIC X(48) VALUE "command.expected.separator".
    05 FILLER PIC X(200) VALUE "Expected whitespace to end one argument, but found"
         & " trailing data".
    05 FILLER PIC X(48) VALUE "command.exception".
    05 FILLER PIC X(200) VALUE "Could not parse command: %s".
    05 FILLER PIC X(48) VALUE "command.context.here".
    05 FILLER PIC X(200) VALUE "<--[HERE]".
    05 FILLER PIC X(48) VALUE "command.context.parse_error".
    05 FILLER PIC X(200) VALUE "%s at position %s: %s".
    05 FILLER PIC X(48) VALUE "command.failed".
    05 FILLER PIC X(200) VALUE "An unexpected error occurred while trying to execu"
         & "te that command".
    05 FILLER PIC X(48) VALUE "command.forkLimit".
    05 FILLER PIC X(200) VALUE "Maximum number of contexts (%s) reached".
    05 FILLER PIC X(48) VALUE "command.trailing_data".
    05 FILLER PIC X(200) VALUE "Trailing data found: %s".
    05 FILLER PIC X(48) VALUE "commands.help.failed".
    05 FILLER PIC X(200) VALUE "Unknown command or insufficient permissions".
    05 FILLER PIC X(48) VALUE "parsing.expected".
    05 FILLER PIC X(200) VALUE "Expected '%s'".
    05 FILLER PIC X(48) VALUE "parsing.bool.expected".
    05 FILLER PIC X(200) VALUE "Expected boolean".
    05 FILLER PIC X(48) VALUE "parsing.bool.invalid".
    05 FILLER PIC X(200) VALUE "Invalid boolean: expected 'true' or 'false' but fo"
         & "und '%s'".
    05 FILLER PIC X(48) VALUE "parsing.int.expected".
    05 FILLER PIC X(200) VALUE "Expected integer".
    05 FILLER PIC X(48) VALUE "parsing.int.invalid".
    05 FILLER PIC X(200) VALUE "Invalid integer '%s'".
    05 FILLER PIC X(48) VALUE "parsing.long.expected".
    05 FILLER PIC X(200) VALUE "Expected long".
    05 FILLER PIC X(48) VALUE "parsing.long.invalid".
    05 FILLER PIC X(200) VALUE "Invalid long '%s'".
    05 FILLER PIC X(48) VALUE "parsing.float.expected".
    05 FILLER PIC X(200) VALUE "Expected float".
    05 FILLER PIC X(48) VALUE "parsing.float.invalid".
    05 FILLER PIC X(200) VALUE "Invalid float '%s'".
    05 FILLER PIC X(48) VALUE "parsing.double.expected".
    05 FILLER PIC X(200) VALUE "Expected double".
    05 FILLER PIC X(48) VALUE "parsing.double.invalid".
    05 FILLER PIC X(200) VALUE "Invalid double '%s'".
    05 FILLER PIC X(48) VALUE "parsing.quote.escape".
    05 FILLER PIC X(200) VALUE "Invalid escape sequence '\%s' in quoted string".
    05 FILLER PIC X(48) VALUE "parsing.quote.expected.start".
    05 FILLER PIC X(200) VALUE "Expected quote to start a string".
    05 FILLER PIC X(48) VALUE "parsing.quote.expected.end".
    05 FILLER PIC X(200) VALUE "Unclosed quoted string".
    05 FILLER PIC X(48) VALUE "argument.literal.incorrect".
    05 FILLER PIC X(200) VALUE "Expected literal %s".
    05 FILLER PIC X(48) VALUE "argument.integer.low".
    05 FILLER PIC X(200) VALUE "Integer must not be less than %s: found %s".
    05 FILLER PIC X(48) VALUE "argument.integer.big".
    05 FILLER PIC X(200) VALUE "Integer must not be more than %s: found %s".
    05 FILLER PIC X(48) VALUE "argument.long.low".
    05 FILLER PIC X(200) VALUE "Long must not be less than %s: found %s".
    05 FILLER PIC X(48) VALUE "argument.long.big".
    05 FILLER PIC X(200) VALUE "Long must not be more than %s: found %s".
    05 FILLER PIC X(48) VALUE "argument.float.low".
    05 FILLER PIC X(200) VALUE "Float must not be less than %s: found %s".
    05 FILLER PIC X(48) VALUE "argument.float.big".
    05 FILLER PIC X(200) VALUE "Float must not be more than %s: found %s".
    05 FILLER PIC X(48) VALUE "argument.double.low".
    05 FILLER PIC X(200) VALUE "Double must not be less than %s: found %s".
    05 FILLER PIC X(48) VALUE "argument.double.big".
    05 FILLER PIC X(200) VALUE "Double must not be more than %s: found %s".
    05 FILLER PIC X(48) VALUE "permissions.requires.player".
    05 FILLER PIC X(200) VALUE "A player is required to run this command here".
    05 FILLER PIC X(48) VALUE "permissions.requires.entity".
    05 FILLER PIC X(200) VALUE "An entity is required to run this command here".
    05 FILLER PIC X(48) VALUE "chat.type.admin".
    05 FILLER PIC X(200) VALUE "[%s: %s]".
    05 FILLER PIC X(48) VALUE "chat.disabled.invalid_command_signature".
    05 FILLER PIC X(200) VALUE "The command had unexpected or missing command argu"
         & "ment signatures.".
    05 FILLER PIC X(48) VALUE "multiplayer.disconnect.illegal_characters".
    05 FILLER PIC X(200) VALUE "Illegal characters in chat".
    05 FILLER PIC X(48) VALUE "multiplayer.disconnect.chat_validation_failed".
    05 FILLER PIC X(200) VALUE "Chat message validation failure".
    05 FILLER PIC X(48) VALUE "chat.validation_error".
    05 FILLER PIC X(200) VALUE "Chat validation error".
    05 FILLER PIC X(48) VALUE "multiplayer.disconnect.too_many_pending_chats".
    05 FILLER PIC X(200) VALUE "Too many unacknowledged chat messages".
    05 FILLER PIC X(48) VALUE "disconnect.spam".
    05 FILLER PIC X(200) VALUE "Kicked for spamming".
    05 FILLER PIC X(48) VALUE "chat.disabled.options".
    05 FILLER PIC X(200) VALUE "Chat disabled in client options.".
    05 FILLER PIC X(48) VALUE "chat_screen.commands_not_allowed".
    05 FILLER PIC X(200) VALUE "Sending commands is not allowed".
    05 FILLER PIC X(48) VALUE "multiplayer.confirm_command.title".
    05 FILLER PIC X(200) VALUE "Confirm Command Execution".
    05 FILLER PIC X(48) VALUE "multiplayer.confirm_command.parse_errors".
    05 FILLER PIC X(200) VALUE "You are trying to execute an unrecognized or inval"
         & "id command."
         & X"0A"
         & "Are you sure?"
         & X"0A"
         & "Command: %s".
    05 FILLER PIC X(48) VALUE "multiplayer.confirm_command.permissions_required".
    05 FILLER PIC X(200) VALUE "You are trying to execute a command that requires "
         & "elevated permissions."
         & X"0A"
         & "This might negatively affect your game."
         & X"0A"
         & "Are you sure?"
         & X"0A"
         & "Command: %s".
    05 FILLER PIC X(48) VALUE "multiplayer.confirm_command.signature_required".
    05 FILLER PIC X(200) VALUE "You are trying to execute a command that will send"
         & " chat messages using your name."
         & X"0A"
         & "It can only be run from the chat screen."
         & X"0A"
         & "Command: %s".
    05 FILLER PIC X(48) VALUE "multiplayer.confirm_command.run_command".
    05 FILLER PIC X(200) VALUE "Run Command".
    05 FILLER PIC X(48) VALUE "multiplayer.confirm_command.suggest_command".
    05 FILLER PIC X(200) VALUE "Copy to Chat Screen".
    05 FILLER PIC X(48) VALUE "argument.entity.invalid".
    05 FILLER PIC X(200) VALUE "Invalid name or UUID".
    05 FILLER PIC X(48) VALUE "argument.entity.notfound.entity".
    05 FILLER PIC X(200) VALUE "No entity was found".
    05 FILLER PIC X(48) VALUE "argument.entity.notfound.player".
    05 FILLER PIC X(200) VALUE "No player was found".
    05 FILLER PIC X(48) VALUE "argument.entity.toomany".
    05 FILLER PIC X(200) VALUE "Only one entity is allowed, but the provided selec"
         & "tor allows more than one".
    05 FILLER PIC X(48) VALUE "argument.player.toomany".
    05 FILLER PIC X(200) VALUE "Only one player is allowed, but the provided selec"
         & "tor allows more than one".
    05 FILLER PIC X(48) VALUE "argument.player.entities".
    05 FILLER PIC X(200) VALUE "Only players may be affected by this command, but "
         & "the provided selector includes entities".
    05 FILLER PIC X(48) VALUE "argument.player.unknown".
    05 FILLER PIC X(200) VALUE "That player does not exist".
    05 FILLER PIC X(48) VALUE "argument.entity.selector.not_allowed".
    05 FILLER PIC X(200) VALUE "Selector not allowed".
    05 FILLER PIC X(48) VALUE "argument.entity.selector.missing".
    05 FILLER PIC X(200) VALUE "Missing selector type".
    05 FILLER PIC X(48) VALUE "argument.entity.selector.unknown".
    05 FILLER PIC X(200) VALUE "Unknown selector type '%s'".
    05 FILLER PIC X(48) VALUE "argument.entity.options.unknown".
    05 FILLER PIC X(200) VALUE "Unknown option '%s'".
    05 FILLER PIC X(48) VALUE "argument.entity.options.inapplicable".
    05 FILLER PIC X(200) VALUE "Option '%s' isn't applicable here".
    05 FILLER PIC X(48) VALUE "argument.entity.options.valueless".
    05 FILLER PIC X(200) VALUE "Expected value for option '%s'".
    05 FILLER PIC X(48) VALUE "argument.entity.options.unterminated".
    05 FILLER PIC X(200) VALUE "Expected end of options".
    05 FILLER PIC X(48) VALUE "argument.entity.options.distance.negative".
    05 FILLER PIC X(200) VALUE "Distance cannot be negative".
    05 FILLER PIC X(48) VALUE "argument.entity.options.level.negative".
    05 FILLER PIC X(200) VALUE "Level shouldn't be negative".
    05 FILLER PIC X(48) VALUE "argument.entity.options.limit.toosmall".
    05 FILLER PIC X(200) VALUE "Limit must be at least 1".
    05 FILLER PIC X(48) VALUE "argument.entity.options.mode.invalid".
    05 FILLER PIC X(200) VALUE "Invalid or unknown game mode '%s'".
    05 FILLER PIC X(48) VALUE "argument.entity.options.sort.irreversible".
    05 FILLER PIC X(200) VALUE "Invalid or unknown sort type '%s'".
    05 FILLER PIC X(48) VALUE "argument.entity.options.type.invalid".
    05 FILLER PIC X(200) VALUE "Invalid or unknown entity type '%s'".
    05 FILLER PIC X(48) VALUE "argument.scoreHolder.empty".
    05 FILLER PIC X(200) VALUE "No relevant score holders could be found".
    05 FILLER PIC X(48) VALUE "argument.pos.missing.double".
    05 FILLER PIC X(200) VALUE "Expected a coordinate".
    05 FILLER PIC X(48) VALUE "argument.pos.missing.int".
    05 FILLER PIC X(200) VALUE "Expected a block position".
    05 FILLER PIC X(48) VALUE "argument.pos.mixed".
    05 FILLER PIC X(200) VALUE "Cannot mix world and local coordinates (everything"
         & " must either use ^ or not)".
    05 FILLER PIC X(48) VALUE "argument.pos.outofbounds".
    05 FILLER PIC X(200) VALUE "That position is outside the allowed boundaries".
    05 FILLER PIC X(48) VALUE "argument.pos.outofworld".
    05 FILLER PIC X(200) VALUE "That position is out of this world!".
    05 FILLER PIC X(48) VALUE "argument.pos.unloaded".
    05 FILLER PIC X(200) VALUE "That position is not loaded".
    05 FILLER PIC X(48) VALUE "argument.pos2d.incomplete".
    05 FILLER PIC X(200) VALUE "Incomplete (expected 2 coordinates)".
    05 FILLER PIC X(48) VALUE "argument.pos3d.incomplete".
    05 FILLER PIC X(200) VALUE "Incomplete (expected 3 coordinates)".
    05 FILLER PIC X(48) VALUE "argument.rotation.incomplete".
    05 FILLER PIC X(200) VALUE "Incomplete (expected 2 coordinates)".
    05 FILLER PIC X(48) VALUE "argument.angle.incomplete".
    05 FILLER PIC X(200) VALUE "Incomplete (expected 1 angle)".
    05 FILLER PIC X(48) VALUE "argument.angle.invalid".
    05 FILLER PIC X(200) VALUE "Invalid angle".
    05 FILLER PIC X(48) VALUE "argument.range.empty".
    05 FILLER PIC X(200) VALUE "Expected value or range of values".
    05 FILLER PIC X(48) VALUE "argument.range.ints".
    05 FILLER PIC X(200) VALUE "Only whole numbers are allowed; not decimals".
    05 FILLER PIC X(48) VALUE "argument.range.swapped".
    05 FILLER PIC X(200) VALUE "Min cannot be bigger than max".
    05 FILLER PIC X(48) VALUE "argument.time.invalid_unit".
    05 FILLER PIC X(200) VALUE "Invalid unit".
    05 FILLER PIC X(48) VALUE "argument.time.invalid_tick_count".
    05 FILLER PIC X(200) VALUE "The tick count must be non-negative".
    05 FILLER PIC X(48) VALUE "argument.time.tick_count_too_low".
    05 FILLER PIC X(200) VALUE "The tick count must not be less than %s: found %s".
    05 FILLER PIC X(48) VALUE "argument.uuid.invalid".
    05 FILLER PIC X(200) VALUE "Invalid UUID".
    05 FILLER PIC X(48) VALUE "argument.id.invalid".
    05 FILLER PIC X(200) VALUE "Invalid ID".
    05 FILLER PIC X(48) VALUE "argument.id.unknown".
    05 FILLER PIC X(200) VALUE "Unknown ID: %s".
    05 FILLER PIC X(48) VALUE "argument.dimension.invalid".
    05 FILLER PIC X(200) VALUE "Unknown dimension '%s'".
    05 FILLER PIC X(48) VALUE "argument.gamemode.invalid".
    05 FILLER PIC X(200) VALUE "Unknown game mode: %s".
    05 FILLER PIC X(48) VALUE "argument.anchor.invalid".
    05 FILLER PIC X(200) VALUE "Invalid entity anchor position %s".
    05 FILLER PIC X(48) VALUE "argument.color.invalid".
    05 FILLER PIC X(200) VALUE "Unknown color '%s'".
    05 FILLER PIC X(48) VALUE "argument.hexcolor.invalid".
    05 FILLER PIC X(200) VALUE "Invalid hex color code '%s'".
    05 FILLER PIC X(48) VALUE "argument.component.invalid".
    05 FILLER PIC X(200) VALUE "Invalid chat component: %s".
    05 FILLER PIC X(48) VALUE "argument.style.invalid".
    05 FILLER PIC X(200) VALUE "Invalid style: %s".
    05 FILLER PIC X(48) VALUE "argument.criteria.invalid".
    05 FILLER PIC X(200) VALUE "Unknown criterion '%s'".
    05 FILLER PIC X(48) VALUE "argument.enum.invalid".
    05 FILLER PIC X(200) VALUE "Invalid value '%s'".
    05 FILLER PIC X(48) VALUE "argument.swing_animation.invalid".
    05 FILLER PIC X(200) VALUE "Unknown swing animation type: %s".
    05 FILLER PIC X(48) VALUE "argument.waypoint.invalid".
    05 FILLER PIC X(200) VALUE "Selected entity is not a waypoint".
    05 FILLER PIC X(48) VALUE "argument.scoreboardDisplaySlot.invalid".
    05 FILLER PIC X(200) VALUE "Unknown display slot '%s'".
    05 FILLER PIC X(48) VALUE "argument.message.too_long".
    05 FILLER PIC X(200) VALUE "Chat message was too long (%s > maximum %s charact"
         & "ers)".
    05 FILLER PIC X(48) VALUE "argument.block.id.invalid".
    05 FILLER PIC X(200) VALUE "Unknown block type '%s'".
    05 FILLER PIC X(48) VALUE "argument.block.property.duplicate".
    05 FILLER PIC X(200) VALUE "Property '%s' can only be set once for block %s".
    05 FILLER PIC X(48) VALUE "argument.block.property.invalid".
    05 FILLER PIC X(200) VALUE "Block %s does not accept '%s' for %s property".
    05 FILLER PIC X(48) VALUE "argument.block.property.novalue".
    05 FILLER PIC X(200) VALUE "Expected value for property '%s' on block %s".
    05 FILLER PIC X(48) VALUE "argument.block.property.unclosed".
    05 FILLER PIC X(200) VALUE "Expected closing ] for block state properties".
    05 FILLER PIC X(48) VALUE "argument.block.property.unknown".
    05 FILLER PIC X(200) VALUE "Block %s does not have property '%s'".
    05 FILLER PIC X(48) VALUE "argument.block.tag.disallowed".
    05 FILLER PIC X(200) VALUE "Tags aren't allowed here; only actual blocks are".
    05 FILLER PIC X(48) VALUE "arguments.block.tag.unknown".
    05 FILLER PIC X(200) VALUE "Unknown block tag '%s'".
    05 FILLER PIC X(48) VALUE "argument.item.id.invalid".
    05 FILLER PIC X(200) VALUE "Unknown item '%s'".
    05 FILLER PIC X(48) VALUE "argument.item.tag.disallowed".
    05 FILLER PIC X(200) VALUE "Tags aren't allowed here; only actual items are".
    05 FILLER PIC X(48) VALUE "arguments.item.malformed".
    05 FILLER PIC X(200) VALUE "Malformed item: '%s'".
    05 FILLER PIC X(48) VALUE "arguments.item.overstacked".
    05 FILLER PIC X(200) VALUE "%s can only stack up to %s".
    05 FILLER PIC X(48) VALUE "arguments.item.component.expected".
    05 FILLER PIC X(200) VALUE "Expected item component".
    05 FILLER PIC X(48) VALUE "arguments.item.component.malformed".
    05 FILLER PIC X(200) VALUE "Malformed '%s' component: '%s'".
    05 FILLER PIC X(48) VALUE "arguments.item.component.repeated".
    05 FILLER PIC X(200) VALUE "Item component '%s' was repeated, but only one val"
         & "ue can be specified".
    05 FILLER PIC X(48) VALUE "arguments.item.component.unknown".
    05 FILLER PIC X(200) VALUE "Unknown item component '%s'".
    05 FILLER PIC X(48) VALUE "arguments.item.predicate.malformed".
    05 FILLER PIC X(200) VALUE "Malformed '%s' predicate: '%s'".
    05 FILLER PIC X(48) VALUE "arguments.item.predicate.unknown".
    05 FILLER PIC X(200) VALUE "Unknown item predicate '%s'".
    05 FILLER PIC X(48) VALUE "arguments.item.tag.unknown".
    05 FILLER PIC X(200) VALUE "Unknown item tag '%s'".
    05 FILLER PIC X(48) VALUE "arguments.function.unknown".
    05 FILLER PIC X(200) VALUE "Unknown function %s".
    05 FILLER PIC X(48) VALUE "arguments.function.tag.unknown".
    05 FILLER PIC X(200) VALUE "Unknown function tag '%s'".
    05 FILLER PIC X(48) VALUE "arguments.nbtpath.node.invalid".
    05 FILLER PIC X(200) VALUE "Invalid NBT path element".
    05 FILLER PIC X(48) VALUE "arguments.nbtpath.nothing_found".
    05 FILLER PIC X(200) VALUE "Found no elements matching %s".
    05 FILLER PIC X(48) VALUE "arguments.nbtpath.too_deep".
    05 FILLER PIC X(200) VALUE "Resulting NBT too deeply nested".
    05 FILLER PIC X(48) VALUE "arguments.nbtpath.too_large".
    05 FILLER PIC X(200) VALUE "Resulting NBT too large".
    05 FILLER PIC X(48) VALUE "argument.nbt.expected.compound".
    05 FILLER PIC X(200) VALUE "Expected compound tag".
    05 FILLER PIC X(48) VALUE "argument.nbt.expected.key".
    05 FILLER PIC X(200) VALUE "Expected key".
    05 FILLER PIC X(48) VALUE "argument.nbt.expected.value".
    05 FILLER PIC X(200) VALUE "Expected value".
    05 FILLER PIC X(48) VALUE "argument.nbt.trailing".
    05 FILLER PIC X(200) VALUE "Unexpected trailing data".
    05 FILLER PIC X(48) VALUE "argument.nbt.array.invalid".
    05 FILLER PIC X(200) VALUE "Invalid array type '%s'".
    05 FILLER PIC X(48) VALUE "argument.nbt.array.mixed".
    05 FILLER PIC X(200) VALUE "Can't insert %s into %s".
    05 FILLER PIC X(48) VALUE "argument.nbt.list.mixed".
    05 FILLER PIC X(200) VALUE "Can't insert %s into list of %s".
    05 FILLER PIC X(48) VALUE "arguments.objective.notFound".
    05 FILLER PIC X(200) VALUE "Unknown scoreboard objective '%s'".
    05 FILLER PIC X(48) VALUE "arguments.objective.readonly".
    05 FILLER PIC X(200) VALUE "Scoreboard objective '%s' is read-only".
    05 FILLER PIC X(48) VALUE "arguments.operation.invalid".
    05 FILLER PIC X(200) VALUE "Invalid operation".
    05 FILLER PIC X(48) VALUE "arguments.operation.div0".
    05 FILLER PIC X(200) VALUE "Cannot divide by zero".
    05 FILLER PIC X(48) VALUE "arguments.swizzle.invalid".
    05 FILLER PIC X(200) VALUE "Invalid swizzle: expected combination of 'x', 'y' "
         & "and 'z'".
    05 FILLER PIC X(48) VALUE "team.notFound".
    05 FILLER PIC X(200) VALUE "Unknown team '%s'".
    05 FILLER PIC X(48) VALUE "particle.notFound".
    05 FILLER PIC X(200) VALUE "Unknown particle: %s".
    05 FILLER PIC X(48) VALUE "particle.invalidOptions".
    05 FILLER PIC X(200) VALUE "Can't parse particle options: %s".
    05 FILLER PIC X(48) VALUE "slot.unknown".
    05 FILLER PIC X(200) VALUE "Unknown slot '%s'".
    05 FILLER PIC X(48) VALUE "slot.only_single_allowed".
    05 FILLER PIC X(200) VALUE "Only single slots allowed: got '%s'".
    05 FILLER PIC X(48) VALUE "entity.not_summonable".
    05 FILLER PIC X(200) VALUE "Can't summon entity of type %s".
    05 FILLER PIC X(48) VALUE "advancement.advancementNotFound".
    05 FILLER PIC X(200) VALUE "Unknown advancement: %s".
    05 FILLER PIC X(48) VALUE "recipe.notFound".
    05 FILLER PIC X(200) VALUE "Unknown recipe: %s".
    05 FILLER PIC X(48) VALUE "argument.resource.not_found".
    05 FILLER PIC X(200) VALUE "Can't find element '%s' of type '%s'".
    05 FILLER PIC X(48) VALUE "argument.resource.invalid_type".
    05 FILLER PIC X(200) VALUE "Element '%s' has wrong type '%s' (expected '%s')".
    05 FILLER PIC X(48) VALUE "argument.resource_tag.not_found".
    05 FILLER PIC X(200) VALUE "Can't find tag '%s' of type '%s'".
    05 FILLER PIC X(48) VALUE "argument.resource_tag.invalid_type".
    05 FILLER PIC X(200) VALUE "Tag '%s' has wrong type '%s' (expected '%s')".
    05 FILLER PIC X(48) VALUE "argument.resource_or_id.failed_to_parse".
    05 FILLER PIC X(200) VALUE "Failed to parse structure: %s".
    05 FILLER PIC X(48) VALUE "argument.resource_or_id.invalid".
    05 FILLER PIC X(200) VALUE "Invalid ID or tag".
    05 FILLER PIC X(48) VALUE "argument.resource_or_id.no_such_element".
    05 FILLER PIC X(200) VALUE "Can't find element '%s' in registry '%s'".
    05 FILLER PIC X(48) VALUE "argument.resource_selector.not_found".
    05 FILLER PIC X(200) VALUE "No matches for selector '%s' of type '%s'".
    05 FILLER PIC X(48) VALUE "commands.execute.conditional.pass".
    05 FILLER PIC X(200) VALUE "Test passed".
    05 FILLER PIC X(48) VALUE "commands.execute.conditional.pass_count".
    05 FILLER PIC X(200) VALUE "Test passed. Count: %s".
    05 FILLER PIC X(48) VALUE "commands.execute.conditional.fail".
    05 FILLER PIC X(200) VALUE "Test failed".
    05 FILLER PIC X(48) VALUE "commands.execute.conditional.fail_count".
    05 FILLER PIC X(200) VALUE "Test failed. Count: %s".
    05 FILLER PIC X(48) VALUE "commands.execute.blocks.toobig".
    05 FILLER PIC X(200) VALUE "Too many blocks in the specified area (maximum %s,"
         & " but specified %s)".
    05 FILLER PIC X(48) VALUE "commands.execute.function.instantiationFailure".
    05 FILLER PIC X(200) VALUE "Failed to instantiate function %s: %s".
    05 FILLER PIC X(48) VALUE "commands.function.instantiationFailure".
    05 FILLER PIC X(200) VALUE "Failed to instantiate function %s: %s".
    05 FILLER PIC X(48) VALUE "commands.function.result".
    05 FILLER PIC X(200) VALUE "Function %s returned %s".
    05 FILLER PIC X(48) VALUE "commands.function.success.single".
    05 FILLER PIC X(200) VALUE "Executed %s command(s) from function '%s'".
    05 FILLER PIC X(48) VALUE "commands.function.success.multiple".
    05 FILLER PIC X(200) VALUE "Executed %s command(s) from %s functions".
    05 FILLER PIC X(48) VALUE "commands.function.success.single.result".
    05 FILLER PIC X(200) VALUE "Function '%2$s' returned %1$s".
    05 FILLER PIC X(48) VALUE "commands.function.success.multiple.result".
    05 FILLER PIC X(200) VALUE "Executed %s functions".
    05 FILLER PIC X(48) VALUE "commands.function.error.argument_not_compound".
    05 FILLER PIC X(200) VALUE "Invalid argument type: %s. Expected Compound".
    05 FILLER PIC X(48) VALUE "commands.function.error.missing_argument".
    05 FILLER PIC X(200) VALUE "Missing argument %2$s to function %1$s".
    05 FILLER PIC X(48) VALUE "commands.function.error.missing_arguments".
    05 FILLER PIC X(200) VALUE "Missing arguments to function %s".
    05 FILLER PIC X(48) VALUE "commands.function.error.parse".
    05 FILLER PIC X(200) VALUE "While instantiating macro %s: Command '%s' caused "
         & "error: %s".
 01 LG-ROWS REDEFINES LG-TABLE.
    05 LG-ROW               OCCURS 173 TIMES.
       10 LG-KEY            PIC X(48).
       10 LG-TEXT           PIC X(200).
