*> The feature flags of the level that the command tree depends on (docs/protocol/57-client-closures-4 section 4.6: the default feature set holds only vanilla, so
*> the game rule max_minecart_speed, which needs minecart_improvements, has no command nodes). Zero is the default set; the tree is built at every world open
*> (BR-STD-TREE), so a test sets BRF-MINECART-IMPROVEMENTS to 1 before it rebuilds the tree. Reading enabled_features of level.dat into it is not done.
 01 BR-FEATURES EXTERNAL.
    05 BRF-MINECART-IMPROVEMENTS BINARY-LONG.
