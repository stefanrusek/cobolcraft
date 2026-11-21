*> Option table of options.txt (docs/protocol/13-client-gameplay-and-controls.md 7.1, 7.2, 7.4; contract/fixtures/client/options-default.txt):
*> every line after the pack lists in the order the file is written. Row: name, kind (B boolean, I integer, F float, J quoted name, S raw text,
*> K key name), minimum and maximum (I and F), default text (the stored form), the allowed quoted names of J separated by |.
 78 OT-COUNT               VALUE 160.
 01 OT-DATA.
    05 FILLER PIC X(40) VALUE "graphicsPreset".
    05 FILLER PIC X(1) VALUE "J".
    05 FILLER PIC X(8) VALUE ' '.
    05 FILLER PIC X(8) VALUE ' '.
    05 FILLER PIC X(48) VALUE '"fancy"'.
    05 FILLER PIC X(48) VALUE '"fast"|"fancy"|"fabulous"|"custom"'.
    05 FILLER PIC X(40) VALUE "preferredGraphicsBackend".
    05 FILLER PIC X(1) VALUE "J".
    05 FILLER PIC X(8) VALUE ' '.
    05 FILLER PIC X(8) VALUE ' '.
    05 FILLER PIC X(48) VALUE '"default"'.
    05 FILLER PIC X(48) VALUE '"default"|"opengl"|"vulkan"'.
    05 FILLER PIC X(40) VALUE "renderDistance".
    05 FILLER PIC X(1) VALUE "I".
    05 FILLER PIC X(8) VALUE '2'.
    05 FILLER PIC X(8) VALUE '32'.
    05 FILLER PIC X(48) VALUE '12'.
    05 FILLER PIC X(48) VALUE " ".
    05 FILLER PIC X(40) VALUE "simulationDistance".
    05 FILLER PIC X(1) VALUE "I".
    05 FILLER PIC X(8) VALUE '5'.
    05 FILLER PIC X(8) VALUE '32'.
    05 FILLER PIC X(48) VALUE '12'.
    05 FILLER PIC X(48) VALUE " ".
    05 FILLER PIC X(40) VALUE "entityDistanceScaling".
    05 FILLER PIC X(1) VALUE "F".
    05 FILLER PIC X(8) VALUE '0.5'.
    05 FILLER PIC X(8) VALUE '5.0'.
    05 FILLER PIC X(48) VALUE '1.0'.
    05 FILLER PIC X(48) VALUE " ".
    05 FILLER PIC X(40) VALUE "maxFps".
    05 FILLER PIC X(1) VALUE "I".
    05 FILLER PIC X(8) VALUE '10'.
    05 FILLER PIC X(8) VALUE '260'.
    05 FILLER PIC X(48) VALUE '120'.
    05 FILLER PIC X(48) VALUE " ".
    05 FILLER PIC X(40) VALUE "enableVsync".
    05 FILLER PIC X(1) VALUE "B".
    05 FILLER PIC X(8) VALUE ' '.
    05 FILLER PIC X(8) VALUE ' '.
    05 FILLER PIC X(48) VALUE 'true'.
    05 FILLER PIC X(48) VALUE " ".
    05 FILLER PIC X(40) VALUE "inactivityFpsLimit".
    05 FILLER PIC X(1) VALUE "J".
    05 FILLER PIC X(8) VALUE ' '.
    05 FILLER PIC X(8) VALUE ' '.
    05 FILLER PIC X(48) VALUE '"afk"'.
    05 FILLER PIC X(48) VALUE '"minimized"|"afk"'.
    05 FILLER PIC X(40) VALUE "fullscreen".
    05 FILLER PIC X(1) VALUE "B".
    05 FILLER PIC X(8) VALUE ' '.
    05 FILLER PIC X(8) VALUE ' '.
    05 FILLER PIC X(48) VALUE 'false'.
    05 FILLER PIC X(48) VALUE " ".
    05 FILLER PIC X(40) VALUE "exclusiveFullscreen".
    05 FILLER PIC X(1) VALUE "B".
    05 FILLER PIC X(8) VALUE ' '.
    05 FILLER PIC X(8) VALUE ' '.
    05 FILLER PIC X(48) VALUE 'false'.
    05 FILLER PIC X(48) VALUE " ".
    05 FILLER PIC X(40) VALUE "guiScale".
    05 FILLER PIC X(1) VALUE "I".
    05 FILLER PIC X(8) VALUE '0'.
    05 FILLER PIC X(8) VALUE '99'.
    05 FILLER PIC X(48) VALUE '0'.
    05 FILLER PIC X(48) VALUE " ".
    05 FILLER PIC X(40) VALUE "gamma".
    05 FILLER PIC X(1) VALUE "F".
    05 FILLER PIC X(8) VALUE '0.0'.
    05 FILLER PIC X(8) VALUE '1.0'.
    05 FILLER PIC X(48) VALUE '0.5'.
    05 FILLER PIC X(48) VALUE " ".
    05 FILLER PIC X(40) VALUE "fov".
    05 FILLER PIC X(1) VALUE "F".
    05 FILLER PIC X(8) VALUE '-1.0'.
    05 FILLER PIC X(8) VALUE '1.0'.
    05 FILLER PIC X(48) VALUE '0.0'.
    05 FILLER PIC X(48) VALUE " ".
    05 FILLER PIC X(40) VALUE "ao".
    05 FILLER PIC X(1) VALUE "B".
    05 FILLER PIC X(8) VALUE ' '.
    05 FILLER PIC X(8) VALUE ' '.
    05 FILLER PIC X(48) VALUE 'true'.
    05 FILLER PIC X(48) VALUE " ".
    05 FILLER PIC X(40) VALUE "biomeBlendRadius".
    05 FILLER PIC X(1) VALUE "I".
    05 FILLER PIC X(8) VALUE '0'.
    05 FILLER PIC X(8) VALUE '7'.
    05 FILLER PIC X(48) VALUE '2'.
    05 FILLER PIC X(48) VALUE " ".
    05 FILLER PIC X(40) VALUE "renderClouds".
    05 FILLER PIC X(1) VALUE "J".
    05 FILLER PIC X(8) VALUE ' '.
    05 FILLER PIC X(8) VALUE ' '.
    05 FILLER PIC X(48) VALUE '"true"'.
    05 FILLER PIC X(48) VALUE '"false"|"fast"|"true"'.
    05 FILLER PIC X(40) VALUE "cloudRange".
    05 FILLER PIC X(1) VALUE "I".
    05 FILLER PIC X(8) VALUE '2'.
    05 FILLER PIC X(8) VALUE '128'.
    05 FILLER PIC X(48) VALUE '128'.
    05 FILLER PIC X(48) VALUE " ".
    05 FILLER PIC X(40) VALUE "weatherRadius".
    05 FILLER PIC X(1) VALUE "I".
    05 FILLER PIC X(8) VALUE '3'.
    05 FILLER PIC X(8) VALUE '10'.
    05 FILLER PIC X(48) VALUE '10'.
    05 FILLER PIC X(48) VALUE " ".
    05 FILLER PIC X(40) VALUE "cutoutLeaves".
    05 FILLER PIC X(1) VALUE "B".
    05 FILLER PIC X(8) VALUE ' '.
    05 FILLER PIC X(8) VALUE ' '.
    05 FILLER PIC X(48) VALUE 'true'.
    05 FILLER PIC X(48) VALUE " ".
    05 FILLER PIC X(40) VALUE "vignette".
    05 FILLER PIC X(1) VALUE "B".
    05 FILLER PIC X(8) VALUE ' '.
    05 FILLER PIC X(8) VALUE ' '.
    05 FILLER PIC X(48) VALUE 'true'.
    05 FILLER PIC X(48) VALUE " ".
    05 FILLER PIC X(40) VALUE "improvedTransparency".
    05 FILLER PIC X(1) VALUE "B".
    05 FILLER PIC X(8) VALUE ' '.
    05 FILLER PIC X(8) VALUE ' '.
    05 FILLER PIC X(48) VALUE 'false'.
    05 FILLER PIC X(48) VALUE " ".
    05 FILLER PIC X(40) VALUE "particles".
    05 FILLER PIC X(1) VALUE "I".
    05 FILLER PIC X(8) VALUE '0'.
    05 FILLER PIC X(8) VALUE '2'.
    05 FILLER PIC X(48) VALUE '0'.
    05 FILLER PIC X(48) VALUE " ".
    05 FILLER PIC X(40) VALUE "entityShadows".
    05 FILLER PIC X(1) VALUE "B".
    05 FILLER PIC X(8) VALUE ' '.
    05 FILLER PIC X(8) VALUE ' '.
    05 FILLER PIC X(48) VALUE 'true'.
    05 FILLER PIC X(48) VALUE " ".
    05 FILLER PIC X(40) VALUE "chunkSectionFadeInTime".
    05 FILLER PIC X(1) VALUE "F".
    05 FILLER PIC X(8) VALUE '0.0'.
    05 FILLER PIC X(8) VALUE '2.0'.
    05 FILLER PIC X(48) VALUE '0.75'.
    05 FILLER PIC X(48) VALUE " ".
    05 FILLER PIC X(40) VALUE "prioritizeChunkUpdates".
    05 FILLER PIC X(1) VALUE "I".
    05 FILLER PIC X(8) VALUE '0'.
    05 FILLER PIC X(8) VALUE '2'.
    05 FILLER PIC X(48) VALUE '0'.
    05 FILLER PIC X(48) VALUE " ".
    05 FILLER PIC X(40) VALUE "mipmapLevels".
    05 FILLER PIC X(1) VALUE "I".
    05 FILLER PIC X(8) VALUE '0'.
    05 FILLER PIC X(8) VALUE '4'.
    05 FILLER PIC X(48) VALUE '4'.
    05 FILLER PIC X(48) VALUE " ".
    05 FILLER PIC X(40) VALUE "textureFiltering".
    05 FILLER PIC X(1) VALUE "I".
    05 FILLER PIC X(8) VALUE '0'.
    05 FILLER PIC X(8) VALUE '2'.
    05 FILLER PIC X(48) VALUE '0'.
    05 FILLER PIC X(48) VALUE " ".
    05 FILLER PIC X(40) VALUE "maxAnisotropyBit".
    05 FILLER PIC X(1) VALUE "I".
    05 FILLER PIC X(8) VALUE '1'.
    05 FILLER PIC X(8) VALUE '3'.
    05 FILLER PIC X(48) VALUE '2'.
    05 FILLER PIC X(48) VALUE " ".
    05 FILLER PIC X(40) VALUE "bobView".
    05 FILLER PIC X(1) VALUE "B".
    05 FILLER PIC X(8) VALUE ' '.
    05 FILLER PIC X(8) VALUE ' '.
    05 FILLER PIC X(48) VALUE 'true'.
    05 FILLER PIC X(48) VALUE " ".
    05 FILLER PIC X(40) VALUE "attackIndicator".
    05 FILLER PIC X(1) VALUE "I".
    05 FILLER PIC X(8) VALUE '0'.
    05 FILLER PIC X(8) VALUE '2'.
    05 FILLER PIC X(48) VALUE '1'.
    05 FILLER PIC X(48) VALUE " ".
    05 FILLER PIC X(40) VALUE "glintSpeed".
    05 FILLER PIC X(1) VALUE "F".
    05 FILLER PIC X(8) VALUE '0.0'.
    05 FILLER PIC X(8) VALUE '1.0'.
    05 FILLER PIC X(48) VALUE '0.5'.
    05 FILLER PIC X(48) VALUE " ".
    05 FILLER PIC X(40) VALUE "glintStrength".
    05 FILLER PIC X(1) VALUE "F".
    05 FILLER PIC X(8) VALUE '0.0'.
    05 FILLER PIC X(8) VALUE '1.0'.
    05 FILLER PIC X(48) VALUE '0.75'.
    05 FILLER PIC X(48) VALUE " ".
    05 FILLER PIC X(40) VALUE "showAutosaveIndicator".
    05 FILLER PIC X(1) VALUE "B".
    05 FILLER PIC X(8) VALUE ' '.
    05 FILLER PIC X(8) VALUE ' '.
    05 FILLER PIC X(48) VALUE 'true'.
    05 FILLER PIC X(48) VALUE " ".
    05 FILLER PIC X(40) VALUE "overrideWidth".
    05 FILLER PIC X(1) VALUE "I".
    05 FILLER PIC X(8) VALUE '0'.
    05 FILLER PIC X(8) VALUE '99999'.
    05 FILLER PIC X(48) VALUE '0'.
    05 FILLER PIC X(48) VALUE " ".
    05 FILLER PIC X(40) VALUE "overrideHeight".
    05 FILLER PIC X(1) VALUE "I".
    05 FILLER PIC X(8) VALUE '0'.
    05 FILLER PIC X(8) VALUE '99999'.
    05 FILLER PIC X(48) VALUE '0'.
    05 FILLER PIC X(48) VALUE " ".
    05 FILLER PIC X(40) VALUE "mouseSensitivity".
    05 FILLER PIC X(1) VALUE "F".
    05 FILLER PIC X(8) VALUE '0.0'.
    05 FILLER PIC X(8) VALUE '1.0'.
    05 FILLER PIC X(48) VALUE '0.5'.
    05 FILLER PIC X(48) VALUE " ".
    05 FILLER PIC X(40) VALUE "invertXMouse".
    05 FILLER PIC X(1) VALUE "B".
    05 FILLER PIC X(8) VALUE ' '.
    05 FILLER PIC X(8) VALUE ' '.
    05 FILLER PIC X(48) VALUE 'false'.
    05 FILLER PIC X(48) VALUE " ".
    05 FILLER PIC X(40) VALUE "invertYMouse".
    05 FILLER PIC X(1) VALUE "B".
    05 FILLER PIC X(8) VALUE ' '.
    05 FILLER PIC X(8) VALUE ' '.
    05 FILLER PIC X(48) VALUE 'false'.
    05 FILLER PIC X(48) VALUE " ".
    05 FILLER PIC X(40) VALUE "discrete_mouse_scroll".
    05 FILLER PIC X(1) VALUE "B".
    05 FILLER PIC X(8) VALUE ' '.
    05 FILLER PIC X(8) VALUE ' '.
    05 FILLER PIC X(48) VALUE 'false'.
    05 FILLER PIC X(48) VALUE " ".
    05 FILLER PIC X(40) VALUE "mouseWheelSensitivity".
    05 FILLER PIC X(1) VALUE "F".
    05 FILLER PIC X(8) VALUE '0.01'.
    05 FILLER PIC X(8) VALUE '10.0'.
    05 FILLER PIC X(48) VALUE '1.0'.
    05 FILLER PIC X(48) VALUE " ".
    05 FILLER PIC X(40) VALUE "allowCursorChanges".
    05 FILLER PIC X(1) VALUE "B".
    05 FILLER PIC X(8) VALUE ' '.
    05 FILLER PIC X(8) VALUE ' '.
    05 FILLER PIC X(48) VALUE 'true'.
    05 FILLER PIC X(48) VALUE " ".
    05 FILLER PIC X(40) VALUE "quitShortcuts".
    05 FILLER PIC X(1) VALUE "B".
    05 FILLER PIC X(8) VALUE ' '.
    05 FILLER PIC X(8) VALUE ' '.
    05 FILLER PIC X(48) VALUE 'true'.
    05 FILLER PIC X(48) VALUE " ".
    05 FILLER PIC X(40) VALUE "ctrlClickEmulatesRightClick".
    05 FILLER PIC X(1) VALUE "B".
    05 FILLER PIC X(8) VALUE ' '.
    05 FILLER PIC X(8) VALUE ' '.
    05 FILLER PIC X(48) VALUE 'false'.
    05 FILLER PIC X(48) VALUE " ".
    05 FILLER PIC X(40) VALUE "autoJump".
    05 FILLER PIC X(1) VALUE "B".
    05 FILLER PIC X(8) VALUE ' '.
    05 FILLER PIC X(8) VALUE ' '.
    05 FILLER PIC X(48) VALUE 'false'.
    05 FILLER PIC X(48) VALUE " ".
    05 FILLER PIC X(40) VALUE "rotateWithMinecart".
    05 FILLER PIC X(1) VALUE "B".
    05 FILLER PIC X(8) VALUE ' '.
    05 FILLER PIC X(8) VALUE ' '.
    05 FILLER PIC X(48) VALUE 'false'.
    05 FILLER PIC X(48) VALUE " ".
    05 FILLER PIC X(40) VALUE "operatorItemsTab".
    05 FILLER PIC X(1) VALUE "B".
    05 FILLER PIC X(8) VALUE ' '.
    05 FILLER PIC X(8) VALUE ' '.
    05 FILLER PIC X(48) VALUE 'false'.
    05 FILLER PIC X(48) VALUE " ".
    05 FILLER PIC X(40) VALUE "toggleCrouch".
    05 FILLER PIC X(1) VALUE "B".
    05 FILLER PIC X(8) VALUE ' '.
    05 FILLER PIC X(8) VALUE ' '.
    05 FILLER PIC X(48) VALUE 'false'.
    05 FILLER PIC X(48) VALUE " ".
    05 FILLER PIC X(40) VALUE "toggleSprint".
    05 FILLER PIC X(1) VALUE "B".
    05 FILLER PIC X(8) VALUE ' '.
    05 FILLER PIC X(8) VALUE ' '.
    05 FILLER PIC X(48) VALUE 'false'.
    05 FILLER PIC X(48) VALUE " ".
    05 FILLER PIC X(40) VALUE "toggleAttack".
    05 FILLER PIC X(1) VALUE "B".
    05 FILLER PIC X(8) VALUE ' '.
    05 FILLER PIC X(8) VALUE ' '.
    05 FILLER PIC X(48) VALUE 'false'.
    05 FILLER PIC X(48) VALUE " ".
    05 FILLER PIC X(40) VALUE "toggleUse".
    05 FILLER PIC X(1) VALUE "B".
    05 FILLER PIC X(8) VALUE ' '.
    05 FILLER PIC X(8) VALUE ' '.
    05 FILLER PIC X(48) VALUE 'false'.
    05 FILLER PIC X(48) VALUE " ".
    05 FILLER PIC X(40) VALUE "sprintWindow".
    05 FILLER PIC X(1) VALUE "I".
    05 FILLER PIC X(8) VALUE '0'.
    05 FILLER PIC X(8) VALUE '10'.
    05 FILLER PIC X(48) VALUE '7'.
    05 FILLER PIC X(48) VALUE " ".
    05 FILLER PIC X(40) VALUE "mainHand".
    05 FILLER PIC X(1) VALUE "J".
    05 FILLER PIC X(8) VALUE ' '.
    05 FILLER PIC X(8) VALUE ' '.
    05 FILLER PIC X(48) VALUE '"right"'.
    05 FILLER PIC X(48) VALUE '"left"|"right"'.
    05 FILLER PIC X(40) VALUE "key_key.forward".
    05 FILLER PIC X(1) VALUE "K".
    05 FILLER PIC X(8) VALUE ' '.
    05 FILLER PIC X(8) VALUE ' '.
    05 FILLER PIC X(48) VALUE 'key.keyboard.w'.
    05 FILLER PIC X(48) VALUE " ".
    05 FILLER PIC X(40) VALUE "key_key.left".
    05 FILLER PIC X(1) VALUE "K".
    05 FILLER PIC X(8) VALUE ' '.
    05 FILLER PIC X(8) VALUE ' '.
    05 FILLER PIC X(48) VALUE 'key.keyboard.a'.
    05 FILLER PIC X(48) VALUE " ".
    05 FILLER PIC X(40) VALUE "key_key.back".
    05 FILLER PIC X(1) VALUE "K".
    05 FILLER PIC X(8) VALUE ' '.
    05 FILLER PIC X(8) VALUE ' '.
    05 FILLER PIC X(48) VALUE 'key.keyboard.s'.
    05 FILLER PIC X(48) VALUE " ".
    05 FILLER PIC X(40) VALUE "key_key.right".
    05 FILLER PIC X(1) VALUE "K".
    05 FILLER PIC X(8) VALUE ' '.
    05 FILLER PIC X(8) VALUE ' '.
    05 FILLER PIC X(48) VALUE 'key.keyboard.d'.
    05 FILLER PIC X(48) VALUE " ".
    05 FILLER PIC X(40) VALUE "key_key.jump".
    05 FILLER PIC X(1) VALUE "K".
    05 FILLER PIC X(8) VALUE ' '.
    05 FILLER PIC X(8) VALUE ' '.
    05 FILLER PIC X(48) VALUE 'key.keyboard.space'.
    05 FILLER PIC X(48) VALUE " ".
    05 FILLER PIC X(40) VALUE "key_key.sneak".
    05 FILLER PIC X(1) VALUE "K".
    05 FILLER PIC X(8) VALUE ' '.
    05 FILLER PIC X(8) VALUE ' '.
    05 FILLER PIC X(48) VALUE 'key.keyboard.left.shift'.
    05 FILLER PIC X(48) VALUE " ".
    05 FILLER PIC X(40) VALUE "key_key.sprint".
    05 FILLER PIC X(1) VALUE "K".
    05 FILLER PIC X(8) VALUE ' '.
    05 FILLER PIC X(8) VALUE ' '.
    05 FILLER PIC X(48) VALUE 'key.keyboard.left.control'.
    05 FILLER PIC X(48) VALUE " ".
    05 FILLER PIC X(40) VALUE "key_key.inventory".
    05 FILLER PIC X(1) VALUE "K".
    05 FILLER PIC X(8) VALUE ' '.
    05 FILLER PIC X(8) VALUE ' '.
    05 FILLER PIC X(48) VALUE 'key.keyboard.e'.
    05 FILLER PIC X(48) VALUE " ".
    05 FILLER PIC X(40) VALUE "key_key.swapOffhand".
    05 FILLER PIC X(1) VALUE "K".
    05 FILLER PIC X(8) VALUE ' '.
    05 FILLER PIC X(8) VALUE ' '.
    05 FILLER PIC X(48) VALUE 'key.keyboard.f'.
    05 FILLER PIC X(48) VALUE " ".
    05 FILLER PIC X(40) VALUE "key_key.drop".
    05 FILLER PIC X(1) VALUE "K".
    05 FILLER PIC X(8) VALUE ' '.
    05 FILLER PIC X(8) VALUE ' '.
    05 FILLER PIC X(48) VALUE 'key.keyboard.q'.
    05 FILLER PIC X(48) VALUE " ".
    05 FILLER PIC X(40) VALUE "key_key.hotbar.1".
    05 FILLER PIC X(1) VALUE "K".
    05 FILLER PIC X(8) VALUE ' '.
    05 FILLER PIC X(8) VALUE ' '.
    05 FILLER PIC X(48) VALUE 'key.keyboard.1'.
    05 FILLER PIC X(48) VALUE " ".
    05 FILLER PIC X(40) VALUE "key_key.hotbar.2".
    05 FILLER PIC X(1) VALUE "K".
    05 FILLER PIC X(8) VALUE ' '.
    05 FILLER PIC X(8) VALUE ' '.
    05 FILLER PIC X(48) VALUE 'key.keyboard.2'.
    05 FILLER PIC X(48) VALUE " ".
    05 FILLER PIC X(40) VALUE "key_key.hotbar.3".
    05 FILLER PIC X(1) VALUE "K".
    05 FILLER PIC X(8) VALUE ' '.
    05 FILLER PIC X(8) VALUE ' '.
    05 FILLER PIC X(48) VALUE 'key.keyboard.3'.
    05 FILLER PIC X(48) VALUE " ".
    05 FILLER PIC X(40) VALUE "key_key.hotbar.4".
    05 FILLER PIC X(1) VALUE "K".
    05 FILLER PIC X(8) VALUE ' '.
    05 FILLER PIC X(8) VALUE ' '.
    05 FILLER PIC X(48) VALUE 'key.keyboard.4'.
    05 FILLER PIC X(48) VALUE " ".
    05 FILLER PIC X(40) VALUE "key_key.hotbar.5".
    05 FILLER PIC X(1) VALUE "K".
    05 FILLER PIC X(8) VALUE ' '.
    05 FILLER PIC X(8) VALUE ' '.
    05 FILLER PIC X(48) VALUE 'key.keyboard.5'.
    05 FILLER PIC X(48) VALUE " ".
    05 FILLER PIC X(40) VALUE "key_key.hotbar.6".
    05 FILLER PIC X(1) VALUE "K".
    05 FILLER PIC X(8) VALUE ' '.
    05 FILLER PIC X(8) VALUE ' '.
    05 FILLER PIC X(48) VALUE 'key.keyboard.6'.
    05 FILLER PIC X(48) VALUE " ".
    05 FILLER PIC X(40) VALUE "key_key.hotbar.7".
    05 FILLER PIC X(1) VALUE "K".
    05 FILLER PIC X(8) VALUE ' '.
    05 FILLER PIC X(8) VALUE ' '.
    05 FILLER PIC X(48) VALUE 'key.keyboard.7'.
    05 FILLER PIC X(48) VALUE " ".
    05 FILLER PIC X(40) VALUE "key_key.hotbar.8".
    05 FILLER PIC X(1) VALUE "K".
    05 FILLER PIC X(8) VALUE ' '.
    05 FILLER PIC X(8) VALUE ' '.
    05 FILLER PIC X(48) VALUE 'key.keyboard.8'.
    05 FILLER PIC X(48) VALUE " ".
    05 FILLER PIC X(40) VALUE "key_key.hotbar.9".
    05 FILLER PIC X(1) VALUE "K".
    05 FILLER PIC X(8) VALUE ' '.
    05 FILLER PIC X(8) VALUE ' '.
    05 FILLER PIC X(48) VALUE 'key.keyboard.9'.
    05 FILLER PIC X(48) VALUE " ".
    05 FILLER PIC X(40) VALUE "key_key.saveToolbarActivator".
    05 FILLER PIC X(1) VALUE "K".
    05 FILLER PIC X(8) VALUE ' '.
    05 FILLER PIC X(8) VALUE ' '.
    05 FILLER PIC X(48) VALUE 'key.keyboard.c'.
    05 FILLER PIC X(48) VALUE " ".
    05 FILLER PIC X(40) VALUE "key_key.loadToolbarActivator".
    05 FILLER PIC X(1) VALUE "K".
    05 FILLER PIC X(8) VALUE ' '.
    05 FILLER PIC X(8) VALUE ' '.
    05 FILLER PIC X(48) VALUE 'key.keyboard.x'.
    05 FILLER PIC X(48) VALUE " ".
    05 FILLER PIC X(40) VALUE "key_key.use".
    05 FILLER PIC X(1) VALUE "K".
    05 FILLER PIC X(8) VALUE ' '.
    05 FILLER PIC X(8) VALUE ' '.
    05 FILLER PIC X(48) VALUE 'key.mouse.right'.
    05 FILLER PIC X(48) VALUE " ".
    05 FILLER PIC X(40) VALUE "key_key.attack".
    05 FILLER PIC X(1) VALUE "K".
    05 FILLER PIC X(8) VALUE ' '.
    05 FILLER PIC X(8) VALUE ' '.
    05 FILLER PIC X(48) VALUE 'key.mouse.left'.
    05 FILLER PIC X(48) VALUE " ".
    05 FILLER PIC X(40) VALUE "key_key.pickItem".
    05 FILLER PIC X(1) VALUE "K".
    05 FILLER PIC X(8) VALUE ' '.
    05 FILLER PIC X(8) VALUE ' '.
    05 FILLER PIC X(48) VALUE 'key.mouse.middle'.
    05 FILLER PIC X(48) VALUE " ".
    05 FILLER PIC X(40) VALUE "key_key.chat".
    05 FILLER PIC X(1) VALUE "K".
    05 FILLER PIC X(8) VALUE ' '.
    05 FILLER PIC X(8) VALUE ' '.
    05 FILLER PIC X(48) VALUE 'key.keyboard.t'.
    05 FILLER PIC X(48) VALUE " ".
    05 FILLER PIC X(40) VALUE "key_key.playerlist".
    05 FILLER PIC X(1) VALUE "K".
    05 FILLER PIC X(8) VALUE ' '.
    05 FILLER PIC X(8) VALUE ' '.
    05 FILLER PIC X(48) VALUE 'key.keyboard.tab'.
    05 FILLER PIC X(48) VALUE " ".
    05 FILLER PIC X(40) VALUE "key_key.command".
    05 FILLER PIC X(1) VALUE "K".
    05 FILLER PIC X(8) VALUE ' '.
    05 FILLER PIC X(8) VALUE ' '.
    05 FILLER PIC X(48) VALUE 'key.keyboard.slash'.
    05 FILLER PIC X(48) VALUE " ".
    05 FILLER PIC X(40) VALUE "key_key.socialInteractions".
    05 FILLER PIC X(1) VALUE "K".
    05 FILLER PIC X(8) VALUE ' '.
    05 FILLER PIC X(8) VALUE ' '.
    05 FILLER PIC X(48) VALUE 'key.keyboard.p'.
    05 FILLER PIC X(48) VALUE " ".
    05 FILLER PIC X(40) VALUE "key_key.screenshot".
    05 FILLER PIC X(1) VALUE "K".
    05 FILLER PIC X(8) VALUE ' '.
    05 FILLER PIC X(8) VALUE ' '.
    05 FILLER PIC X(48) VALUE 'key.keyboard.f2'.
    05 FILLER PIC X(48) VALUE " ".
    05 FILLER PIC X(40) VALUE "key_key.togglePerspective".
    05 FILLER PIC X(1) VALUE "K".
    05 FILLER PIC X(8) VALUE ' '.
    05 FILLER PIC X(8) VALUE ' '.
    05 FILLER PIC X(48) VALUE 'key.keyboard.f5'.
    05 FILLER PIC X(48) VALUE " ".
    05 FILLER PIC X(40) VALUE "key_key.smoothCamera".
    05 FILLER PIC X(1) VALUE "K".
    05 FILLER PIC X(8) VALUE ' '.
    05 FILLER PIC X(8) VALUE ' '.
    05 FILLER PIC X(48) VALUE 'key.keyboard.unknown'.
    05 FILLER PIC X(48) VALUE " ".
    05 FILLER PIC X(40) VALUE "key_key.fullscreen".
    05 FILLER PIC X(1) VALUE "K".
    05 FILLER PIC X(8) VALUE ' '.
    05 FILLER PIC X(8) VALUE ' '.
    05 FILLER PIC X(48) VALUE 'key.keyboard.f11'.
    05 FILLER PIC X(48) VALUE " ".
    05 FILLER PIC X(40) VALUE "key_key.advancements".
    05 FILLER PIC X(1) VALUE "K".
    05 FILLER PIC X(8) VALUE ' '.
    05 FILLER PIC X(8) VALUE ' '.
    05 FILLER PIC X(48) VALUE 'key.keyboard.l'.
    05 FILLER PIC X(48) VALUE " ".
    05 FILLER PIC X(40) VALUE "key_key.quickActions".
    05 FILLER PIC X(1) VALUE "K".
    05 FILLER PIC X(8) VALUE ' '.
    05 FILLER PIC X(8) VALUE ' '.
    05 FILLER PIC X(48) VALUE 'key.keyboard.g'.
    05 FILLER PIC X(48) VALUE " ".
    05 FILLER PIC X(40) VALUE "key_key.toggleGui".
    05 FILLER PIC X(1) VALUE "K".
    05 FILLER PIC X(8) VALUE ' '.
    05 FILLER PIC X(8) VALUE ' '.
    05 FILLER PIC X(48) VALUE 'key.keyboard.f1'.
    05 FILLER PIC X(48) VALUE " ".
    05 FILLER PIC X(40) VALUE "key_key.toggleSpectatorShaderEffects".
    05 FILLER PIC X(1) VALUE "K".
    05 FILLER PIC X(8) VALUE ' '.
    05 FILLER PIC X(8) VALUE ' '.
    05 FILLER PIC X(48) VALUE 'key.keyboard.f4'.
    05 FILLER PIC X(48) VALUE " ".
    05 FILLER PIC X(40) VALUE "key_key.spectatorOutlines".
    05 FILLER PIC X(1) VALUE "K".
    05 FILLER PIC X(8) VALUE ' '.
    05 FILLER PIC X(8) VALUE ' '.
    05 FILLER PIC X(48) VALUE 'key.keyboard.unknown'.
    05 FILLER PIC X(48) VALUE " ".
    05 FILLER PIC X(40) VALUE "soundCategory_master".
    05 FILLER PIC X(1) VALUE "F".
    05 FILLER PIC X(8) VALUE '0.0'.
    05 FILLER PIC X(8) VALUE '1.0'.
    05 FILLER PIC X(48) VALUE '1.0'.
    05 FILLER PIC X(48) VALUE " ".
    05 FILLER PIC X(40) VALUE "soundCategory_music".
    05 FILLER PIC X(1) VALUE "F".
    05 FILLER PIC X(8) VALUE '0.0'.
    05 FILLER PIC X(8) VALUE '1.0'.
    05 FILLER PIC X(48) VALUE '1.0'.
    05 FILLER PIC X(48) VALUE " ".
    05 FILLER PIC X(40) VALUE "soundCategory_record".
    05 FILLER PIC X(1) VALUE "F".
    05 FILLER PIC X(8) VALUE '0.0'.
    05 FILLER PIC X(8) VALUE '1.0'.
    05 FILLER PIC X(48) VALUE '1.0'.
    05 FILLER PIC X(48) VALUE " ".
    05 FILLER PIC X(40) VALUE "soundCategory_weather".
    05 FILLER PIC X(1) VALUE "F".
    05 FILLER PIC X(8) VALUE '0.0'.
    05 FILLER PIC X(8) VALUE '1.0'.
    05 FILLER PIC X(48) VALUE '1.0'.
    05 FILLER PIC X(48) VALUE " ".
    05 FILLER PIC X(40) VALUE "soundCategory_block".
    05 FILLER PIC X(1) VALUE "F".
    05 FILLER PIC X(8) VALUE '0.0'.
    05 FILLER PIC X(8) VALUE '1.0'.
    05 FILLER PIC X(48) VALUE '1.0'.
    05 FILLER PIC X(48) VALUE " ".
    05 FILLER PIC X(40) VALUE "soundCategory_hostile".
    05 FILLER PIC X(1) VALUE "F".
    05 FILLER PIC X(8) VALUE '0.0'.
    05 FILLER PIC X(8) VALUE '1.0'.
    05 FILLER PIC X(48) VALUE '1.0'.
    05 FILLER PIC X(48) VALUE " ".
    05 FILLER PIC X(40) VALUE "soundCategory_neutral".
    05 FILLER PIC X(1) VALUE "F".
    05 FILLER PIC X(8) VALUE '0.0'.
    05 FILLER PIC X(8) VALUE '1.0'.
    05 FILLER PIC X(48) VALUE '1.0'.
    05 FILLER PIC X(48) VALUE " ".
    05 FILLER PIC X(40) VALUE "soundCategory_player".
    05 FILLER PIC X(1) VALUE "F".
    05 FILLER PIC X(8) VALUE '0.0'.
    05 FILLER PIC X(8) VALUE '1.0'.
    05 FILLER PIC X(48) VALUE '1.0'.
    05 FILLER PIC X(48) VALUE " ".
    05 FILLER PIC X(40) VALUE "soundCategory_ambient".
    05 FILLER PIC X(1) VALUE "F".
    05 FILLER PIC X(8) VALUE '0.0'.
    05 FILLER PIC X(8) VALUE '1.0'.
    05 FILLER PIC X(48) VALUE '1.0'.
    05 FILLER PIC X(48) VALUE " ".
    05 FILLER PIC X(40) VALUE "soundCategory_voice".
    05 FILLER PIC X(1) VALUE "F".
    05 FILLER PIC X(8) VALUE '0.0'.
    05 FILLER PIC X(8) VALUE '1.0'.
    05 FILLER PIC X(48) VALUE '1.0'.
    05 FILLER PIC X(48) VALUE " ".
    05 FILLER PIC X(40) VALUE "soundCategory_ui".
    05 FILLER PIC X(1) VALUE "F".
    05 FILLER PIC X(8) VALUE '0.0'.
    05 FILLER PIC X(8) VALUE '1.0'.
    05 FILLER PIC X(48) VALUE '1.0'.
    05 FILLER PIC X(48) VALUE " ".
    05 FILLER PIC X(40) VALUE "modelPart_cape".
    05 FILLER PIC X(1) VALUE "B".
    05 FILLER PIC X(8) VALUE ' '.
    05 FILLER PIC X(8) VALUE ' '.
    05 FILLER PIC X(48) VALUE 'true'.
    05 FILLER PIC X(48) VALUE " ".
    05 FILLER PIC X(40) VALUE "modelPart_jacket".
    05 FILLER PIC X(1) VALUE "B".
    05 FILLER PIC X(8) VALUE ' '.
    05 FILLER PIC X(8) VALUE ' '.
    05 FILLER PIC X(48) VALUE 'true'.
    05 FILLER PIC X(48) VALUE " ".
    05 FILLER PIC X(40) VALUE "modelPart_left_sleeve".
    05 FILLER PIC X(1) VALUE "B".
    05 FILLER PIC X(8) VALUE ' '.
    05 FILLER PIC X(8) VALUE ' '.
    05 FILLER PIC X(48) VALUE 'true'.
    05 FILLER PIC X(48) VALUE " ".
    05 FILLER PIC X(40) VALUE "modelPart_right_sleeve".
    05 FILLER PIC X(1) VALUE "B".
    05 FILLER PIC X(8) VALUE ' '.
    05 FILLER PIC X(8) VALUE ' '.
    05 FILLER PIC X(48) VALUE 'true'.
    05 FILLER PIC X(48) VALUE " ".
    05 FILLER PIC X(40) VALUE "modelPart_left_pants_leg".
    05 FILLER PIC X(1) VALUE "B".
    05 FILLER PIC X(8) VALUE ' '.
    05 FILLER PIC X(8) VALUE ' '.
    05 FILLER PIC X(48) VALUE 'true'.
    05 FILLER PIC X(48) VALUE " ".
    05 FILLER PIC X(40) VALUE "modelPart_right_pants_leg".
    05 FILLER PIC X(1) VALUE "B".
    05 FILLER PIC X(8) VALUE ' '.
    05 FILLER PIC X(8) VALUE ' '.
    05 FILLER PIC X(48) VALUE 'true'.
    05 FILLER PIC X(48) VALUE " ".
    05 FILLER PIC X(40) VALUE "modelPart_hat".
    05 FILLER PIC X(1) VALUE "B".
    05 FILLER PIC X(8) VALUE ' '.
    05 FILLER PIC X(8) VALUE ' '.
    05 FILLER PIC X(48) VALUE 'true'.
    05 FILLER PIC X(48) VALUE " ".
    05 FILLER PIC X(40) VALUE "soundDevice".
    05 FILLER PIC X(1) VALUE "S".
    05 FILLER PIC X(8) VALUE ' '.
    05 FILLER PIC X(8) VALUE ' '.
    05 FILLER PIC X(48) VALUE ' '.
    05 FILLER PIC X(48) VALUE " ".
    05 FILLER PIC X(40) VALUE "showSubtitles".
    05 FILLER PIC X(1) VALUE "B".
    05 FILLER PIC X(8) VALUE ' '.
    05 FILLER PIC X(8) VALUE ' '.
    05 FILLER PIC X(48) VALUE 'false'.
    05 FILLER PIC X(48) VALUE " ".
    05 FILLER PIC X(40) VALUE "directionalAudio".
    05 FILLER PIC X(1) VALUE "B".
    05 FILLER PIC X(8) VALUE ' '.
    05 FILLER PIC X(8) VALUE ' '.
    05 FILLER PIC X(48) VALUE 'false'.
    05 FILLER PIC X(48) VALUE " ".
    05 FILLER PIC X(40) VALUE "musicToast".
    05 FILLER PIC X(1) VALUE "J".
    05 FILLER PIC X(8) VALUE ' '.
    05 FILLER PIC X(8) VALUE ' '.
    05 FILLER PIC X(48) VALUE '"never"'.
    05 FILLER PIC X(48) VALUE '"never"|"pause"|"pause_and_toast"'.
    05 FILLER PIC X(40) VALUE "musicFrequency".
    05 FILLER PIC X(1) VALUE "J".
    05 FILLER PIC X(8) VALUE ' '.
    05 FILLER PIC X(8) VALUE ' '.
    05 FILLER PIC X(48) VALUE '"DEFAULT"'.
    05 FILLER PIC X(48) VALUE '"DEFAULT"|"FREQUENT"|"CONSTANT"'.
    05 FILLER PIC X(40) VALUE "chatVisibility".
    05 FILLER PIC X(1) VALUE "I".
    05 FILLER PIC X(8) VALUE '0'.
    05 FILLER PIC X(8) VALUE '2'.
    05 FILLER PIC X(48) VALUE '0'.
    05 FILLER PIC X(48) VALUE " ".
    05 FILLER PIC X(40) VALUE "chatColors".
    05 FILLER PIC X(1) VALUE "B".
    05 FILLER PIC X(8) VALUE ' '.
    05 FILLER PIC X(8) VALUE ' '.
    05 FILLER PIC X(48) VALUE 'true'.
    05 FILLER PIC X(48) VALUE " ".
    05 FILLER PIC X(40) VALUE "chatLinks".
    05 FILLER PIC X(1) VALUE "B".
    05 FILLER PIC X(8) VALUE ' '.
    05 FILLER PIC X(8) VALUE ' '.
    05 FILLER PIC X(48) VALUE 'true'.
    05 FILLER PIC X(48) VALUE " ".
    05 FILLER PIC X(40) VALUE "chatLinksPrompt".
    05 FILLER PIC X(1) VALUE "B".
    05 FILLER PIC X(8) VALUE ' '.
    05 FILLER PIC X(8) VALUE ' '.
    05 FILLER PIC X(48) VALUE 'true'.
    05 FILLER PIC X(48) VALUE " ".
    05 FILLER PIC X(40) VALUE "chatOpacity".
    05 FILLER PIC X(1) VALUE "F".
    05 FILLER PIC X(8) VALUE '0.0'.
    05 FILLER PIC X(8) VALUE '1.0'.
    05 FILLER PIC X(48) VALUE '1.0'.
    05 FILLER PIC X(48) VALUE " ".
    05 FILLER PIC X(40) VALUE "chatLineSpacing".
    05 FILLER PIC X(1) VALUE "F".
    05 FILLER PIC X(8) VALUE '0.0'.
    05 FILLER PIC X(8) VALUE '1.0'.
    05 FILLER PIC X(48) VALUE '0.0'.
    05 FILLER PIC X(48) VALUE " ".
    05 FILLER PIC X(40) VALUE "textBackgroundOpacity".
    05 FILLER PIC X(1) VALUE "F".
    05 FILLER PIC X(8) VALUE '0.0'.
    05 FILLER PIC X(8) VALUE '1.0'.
    05 FILLER PIC X(48) VALUE '0.5'.
    05 FILLER PIC X(48) VALUE " ".
    05 FILLER PIC X(40) VALUE "backgroundForChatOnly".
    05 FILLER PIC X(1) VALUE "B".
    05 FILLER PIC X(8) VALUE ' '.
    05 FILLER PIC X(8) VALUE ' '.
    05 FILLER PIC X(48) VALUE 'true'.
    05 FILLER PIC X(48) VALUE " ".
    05 FILLER PIC X(40) VALUE "chatScale".
    05 FILLER PIC X(1) VALUE "F".
    05 FILLER PIC X(8) VALUE '0.0'.
    05 FILLER PIC X(8) VALUE '1.0'.
    05 FILLER PIC X(48) VALUE '1.0'.
    05 FILLER PIC X(48) VALUE " ".
    05 FILLER PIC X(40) VALUE "chatWidth".
    05 FILLER PIC X(1) VALUE "F".
    05 FILLER PIC X(8) VALUE '0.0'.
    05 FILLER PIC X(8) VALUE '1.0'.
    05 FILLER PIC X(48) VALUE '1.0'.
    05 FILLER PIC X(48) VALUE " ".
    05 FILLER PIC X(40) VALUE "chatHeightFocused".
    05 FILLER PIC X(1) VALUE "F".
    05 FILLER PIC X(8) VALUE '0.0'.
    05 FILLER PIC X(8) VALUE '1.0'.
    05 FILLER PIC X(48) VALUE '1.0'.
    05 FILLER PIC X(48) VALUE " ".
    05 FILLER PIC X(40) VALUE "chatHeightUnfocused".
    05 FILLER PIC X(1) VALUE "F".
    05 FILLER PIC X(8) VALUE '0.0'.
    05 FILLER PIC X(8) VALUE '1.0'.
    05 FILLER PIC X(48) VALUE '0.4375'.
    05 FILLER PIC X(48) VALUE " ".
    05 FILLER PIC X(40) VALUE "chatDelay".
    05 FILLER PIC X(1) VALUE "F".
    05 FILLER PIC X(8) VALUE '0.0'.
    05 FILLER PIC X(8) VALUE '6.0'.
    05 FILLER PIC X(48) VALUE '0.0'.
    05 FILLER PIC X(48) VALUE " ".
    05 FILLER PIC X(40) VALUE "autoSuggestions".
    05 FILLER PIC X(1) VALUE "B".
    05 FILLER PIC X(8) VALUE ' '.
    05 FILLER PIC X(8) VALUE ' '.
    05 FILLER PIC X(48) VALUE 'true'.
    05 FILLER PIC X(48) VALUE " ".
    05 FILLER PIC X(40) VALUE "hideMatchedNames".
    05 FILLER PIC X(1) VALUE "B".
    05 FILLER PIC X(8) VALUE ' '.
    05 FILLER PIC X(8) VALUE ' '.
    05 FILLER PIC X(48) VALUE 'true'.
    05 FILLER PIC X(48) VALUE " ".
    05 FILLER PIC X(40) VALUE "onlyShowSecureChat".
    05 FILLER PIC X(1) VALUE "B".
    05 FILLER PIC X(8) VALUE ' '.
    05 FILLER PIC X(8) VALUE ' '.
    05 FILLER PIC X(48) VALUE 'false'.
    05 FILLER PIC X(48) VALUE " ".
    05 FILLER PIC X(40) VALUE "saveChatDrafts".
    05 FILLER PIC X(1) VALUE "B".
    05 FILLER PIC X(8) VALUE ' '.
    05 FILLER PIC X(8) VALUE ' '.
    05 FILLER PIC X(48) VALUE 'false'.
    05 FILLER PIC X(48) VALUE " ".
    05 FILLER PIC X(40) VALUE "notificationDisplayTime".
    05 FILLER PIC X(1) VALUE "F".
    05 FILLER PIC X(8) VALUE '0.5'.
    05 FILLER PIC X(8) VALUE '10.0'.
    05 FILLER PIC X(48) VALUE '1.0'.
    05 FILLER PIC X(48) VALUE " ".
    05 FILLER PIC X(40) VALUE "hideServerAddress".
    05 FILLER PIC X(1) VALUE "B".
    05 FILLER PIC X(8) VALUE ' '.
    05 FILLER PIC X(8) VALUE ' '.
    05 FILLER PIC X(48) VALUE 'false'.
    05 FILLER PIC X(48) VALUE " ".
    05 FILLER PIC X(40) VALUE "advancedItemTooltips".
    05 FILLER PIC X(1) VALUE "B".
    05 FILLER PIC X(8) VALUE ' '.
    05 FILLER PIC X(8) VALUE ' '.
    05 FILLER PIC X(48) VALUE 'false'.
    05 FILLER PIC X(48) VALUE " ".
    05 FILLER PIC X(40) VALUE "narrator".
    05 FILLER PIC X(1) VALUE "I".
    05 FILLER PIC X(8) VALUE '0'.
    05 FILLER PIC X(8) VALUE '3'.
    05 FILLER PIC X(48) VALUE '0'.
    05 FILLER PIC X(48) VALUE " ".
    05 FILLER PIC X(40) VALUE "narratorHotkey".
    05 FILLER PIC X(1) VALUE "B".
    05 FILLER PIC X(8) VALUE ' '.
    05 FILLER PIC X(8) VALUE ' '.
    05 FILLER PIC X(48) VALUE 'true'.
    05 FILLER PIC X(48) VALUE " ".
    05 FILLER PIC X(40) VALUE "highContrast".
    05 FILLER PIC X(1) VALUE "B".
    05 FILLER PIC X(8) VALUE ' '.
    05 FILLER PIC X(8) VALUE ' '.
    05 FILLER PIC X(48) VALUE 'false'.
    05 FILLER PIC X(48) VALUE " ".
    05 FILLER PIC X(40) VALUE "highContrastBlockOutline".
    05 FILLER PIC X(1) VALUE "B".
    05 FILLER PIC X(8) VALUE ' '.
    05 FILLER PIC X(8) VALUE ' '.
    05 FILLER PIC X(48) VALUE 'false'.
    05 FILLER PIC X(48) VALUE " ".
    05 FILLER PIC X(40) VALUE "screenEffectScale".
    05 FILLER PIC X(1) VALUE "F".
    05 FILLER PIC X(8) VALUE '0.0'.
    05 FILLER PIC X(8) VALUE '1.0'.
    05 FILLER PIC X(48) VALUE '1.0'.
    05 FILLER PIC X(48) VALUE " ".
    05 FILLER PIC X(40) VALUE "fovEffectScale".
    05 FILLER PIC X(1) VALUE "F".
    05 FILLER PIC X(8) VALUE '0.0'.
    05 FILLER PIC X(8) VALUE '1.0'.
    05 FILLER PIC X(48) VALUE '1.0'.
    05 FILLER PIC X(48) VALUE " ".
    05 FILLER PIC X(40) VALUE "darknessEffectScale".
    05 FILLER PIC X(1) VALUE "F".
    05 FILLER PIC X(8) VALUE '0.0'.
    05 FILLER PIC X(8) VALUE '1.0'.
    05 FILLER PIC X(48) VALUE '1.0'.
    05 FILLER PIC X(48) VALUE " ".
    05 FILLER PIC X(40) VALUE "damageTiltStrength".
    05 FILLER PIC X(1) VALUE "F".
    05 FILLER PIC X(8) VALUE '0.0'.
    05 FILLER PIC X(8) VALUE '1.0'.
    05 FILLER PIC X(48) VALUE '1.0'.
    05 FILLER PIC X(48) VALUE " ".
    05 FILLER PIC X(40) VALUE "darkMojangStudiosBackground".
    05 FILLER PIC X(1) VALUE "B".
    05 FILLER PIC X(8) VALUE ' '.
    05 FILLER PIC X(8) VALUE ' '.
    05 FILLER PIC X(48) VALUE 'false'.
    05 FILLER PIC X(48) VALUE " ".
    05 FILLER PIC X(40) VALUE "hideLightningFlashes".
    05 FILLER PIC X(1) VALUE "B".
    05 FILLER PIC X(8) VALUE ' '.
    05 FILLER PIC X(8) VALUE ' '.
    05 FILLER PIC X(48) VALUE 'false'.
    05 FILLER PIC X(48) VALUE " ".
    05 FILLER PIC X(40) VALUE "hideSplashTexts".
    05 FILLER PIC X(1) VALUE "B".
    05 FILLER PIC X(8) VALUE ' '.
    05 FILLER PIC X(8) VALUE ' '.
    05 FILLER PIC X(48) VALUE 'false'.
    05 FILLER PIC X(48) VALUE " ".
    05 FILLER PIC X(40) VALUE "menuBackgroundBlurriness".
    05 FILLER PIC X(1) VALUE "I".
    05 FILLER PIC X(8) VALUE '0'.
    05 FILLER PIC X(8) VALUE '10'.
    05 FILLER PIC X(48) VALUE '5'.
    05 FILLER PIC X(48) VALUE " ".
    05 FILLER PIC X(40) VALUE "panoramaScrollSpeed".
    05 FILLER PIC X(1) VALUE "F".
    05 FILLER PIC X(8) VALUE '0.0'.
    05 FILLER PIC X(8) VALUE '1.0'.
    05 FILLER PIC X(48) VALUE '1.0'.
    05 FILLER PIC X(48) VALUE " ".
    05 FILLER PIC X(40) VALUE "reducedDebugInfo".
    05 FILLER PIC X(1) VALUE "B".
    05 FILLER PIC X(8) VALUE ' '.
    05 FILLER PIC X(8) VALUE ' '.
    05 FILLER PIC X(48) VALUE 'false'.
    05 FILLER PIC X(48) VALUE " ".
    05 FILLER PIC X(40) VALUE "lang".
    05 FILLER PIC X(1) VALUE "S".
    05 FILLER PIC X(8) VALUE ' '.
    05 FILLER PIC X(8) VALUE ' '.
    05 FILLER PIC X(48) VALUE 'en_us'.
    05 FILLER PIC X(48) VALUE " ".
    05 FILLER PIC X(40) VALUE "lastServer".
    05 FILLER PIC X(1) VALUE "S".
    05 FILLER PIC X(8) VALUE ' '.
    05 FILLER PIC X(8) VALUE ' '.
    05 FILLER PIC X(48) VALUE ' '.
    05 FILLER PIC X(48) VALUE " ".
    05 FILLER PIC X(40) VALUE "pauseOnLostFocus".
    05 FILLER PIC X(1) VALUE "B".
    05 FILLER PIC X(8) VALUE ' '.
    05 FILLER PIC X(8) VALUE ' '.
    05 FILLER PIC X(48) VALUE 'true'.
    05 FILLER PIC X(48) VALUE " ".
    05 FILLER PIC X(40) VALUE "useNativeTransport".
    05 FILLER PIC X(1) VALUE "B".
    05 FILLER PIC X(8) VALUE ' '.
    05 FILLER PIC X(8) VALUE ' '.
    05 FILLER PIC X(48) VALUE 'true'.
    05 FILLER PIC X(48) VALUE " ".
    05 FILLER PIC X(40) VALUE "joinedFirstServer".
    05 FILLER PIC X(1) VALUE "B".
    05 FILLER PIC X(8) VALUE ' '.
    05 FILLER PIC X(8) VALUE ' '.
    05 FILLER PIC X(48) VALUE 'false'.
    05 FILLER PIC X(48) VALUE " ".
    05 FILLER PIC X(40) VALUE "skipMultiplayerWarning".
    05 FILLER PIC X(1) VALUE "B".
    05 FILLER PIC X(8) VALUE ' '.
    05 FILLER PIC X(8) VALUE ' '.
    05 FILLER PIC X(48) VALUE 'false'.
    05 FILLER PIC X(48) VALUE " ".
    05 FILLER PIC X(40) VALUE "onboardAccessibility".
    05 FILLER PIC X(1) VALUE "B".
    05 FILLER PIC X(8) VALUE ' '.
    05 FILLER PIC X(8) VALUE ' '.
    05 FILLER PIC X(48) VALUE 'true'.
    05 FILLER PIC X(48) VALUE " ".
    05 FILLER PIC X(40) VALUE "startedCleanly".
    05 FILLER PIC X(1) VALUE "B".
    05 FILLER PIC X(8) VALUE ' '.
    05 FILLER PIC X(8) VALUE ' '.
    05 FILLER PIC X(48) VALUE 'true'.
    05 FILLER PIC X(48) VALUE " ".
    05 FILLER PIC X(40) VALUE "syncChunkWrites".
    05 FILLER PIC X(1) VALUE "B".
    05 FILLER PIC X(8) VALUE ' '.
    05 FILLER PIC X(8) VALUE ' '.
    05 FILLER PIC X(48) VALUE 'false'.
    05 FILLER PIC X(48) VALUE " ".
    05 FILLER PIC X(40) VALUE "realmsNotifications".
    05 FILLER PIC X(1) VALUE "B".
    05 FILLER PIC X(8) VALUE ' '.
    05 FILLER PIC X(8) VALUE ' '.
    05 FILLER PIC X(48) VALUE 'true'.
    05 FILLER PIC X(48) VALUE " ".
    05 FILLER PIC X(40) VALUE "allowServerListing".
    05 FILLER PIC X(1) VALUE "B".
    05 FILLER PIC X(8) VALUE ' '.
    05 FILLER PIC X(8) VALUE ' '.
    05 FILLER PIC X(48) VALUE 'true'.
    05 FILLER PIC X(48) VALUE " ".
    05 FILLER PIC X(40) VALUE "inGameNotification".
    05 FILLER PIC X(1) VALUE "B".
    05 FILLER PIC X(8) VALUE ' '.
    05 FILLER PIC X(8) VALUE ' '.
    05 FILLER PIC X(48) VALUE 'false'.
    05 FILLER PIC X(48) VALUE " ".
    05 FILLER PIC X(40) VALUE "telemetryOptInExtra".
    05 FILLER PIC X(1) VALUE "B".
    05 FILLER PIC X(8) VALUE ' '.
    05 FILLER PIC X(8) VALUE ' '.
    05 FILLER PIC X(48) VALUE 'false'.
    05 FILLER PIC X(48) VALUE " ".
    05 FILLER PIC X(40) VALUE "forceUnicodeFont".
    05 FILLER PIC X(1) VALUE "B".
    05 FILLER PIC X(8) VALUE ' '.
    05 FILLER PIC X(8) VALUE ' '.
    05 FILLER PIC X(48) VALUE 'false'.
    05 FILLER PIC X(48) VALUE " ".
 01 OT-TABLE REDEFINES OT-DATA.
    05 OT-ROW OCCURS 160 TIMES.
       10 OT-NAME         PIC X(40).
       10 OT-KIND         PIC X(1).
       10 OT-MIN          PIC X(8).
       10 OT-MAX          PIC X(8).
       10 OT-DEFAULT      PIC X(48).
       10 OT-ENUM         PIC X(48).
 78 KT-COUNT               VALUE 255.
 01 KT-DATA.
    05 FILLER PIC X(40) VALUE "key.keyboard.unknown".
    05 FILLER PIC 9(4) VALUE 0.
    05 FILLER PIC X(40) VALUE "key.keyboard.a".
    05 FILLER PIC 9(4) VALUE 65.
    05 FILLER PIC X(40) VALUE "key.keyboard.b".
    05 FILLER PIC 9(4) VALUE 66.
    05 FILLER PIC X(40) VALUE "key.keyboard.c".
    05 FILLER PIC 9(4) VALUE 67.
    05 FILLER PIC X(40) VALUE "key.keyboard.d".
    05 FILLER PIC 9(4) VALUE 68.
    05 FILLER PIC X(40) VALUE "key.keyboard.e".
    05 FILLER PIC 9(4) VALUE 69.
    05 FILLER PIC X(40) VALUE "key.keyboard.f".
    05 FILLER PIC 9(4) VALUE 70.
    05 FILLER PIC X(40) VALUE "key.keyboard.g".
    05 FILLER PIC 9(4) VALUE 71.
    05 FILLER PIC X(40) VALUE "key.keyboard.h".
    05 FILLER PIC 9(4) VALUE 72.
    05 FILLER PIC X(40) VALUE "key.keyboard.i".
    05 FILLER PIC 9(4) VALUE 73.
    05 FILLER PIC X(40) VALUE "key.keyboard.j".
    05 FILLER PIC 9(4) VALUE 74.
    05 FILLER PIC X(40) VALUE "key.keyboard.k".
    05 FILLER PIC 9(4) VALUE 75.
    05 FILLER PIC X(40) VALUE "key.keyboard.l".
    05 FILLER PIC 9(4) VALUE 76.
    05 FILLER PIC X(40) VALUE "key.keyboard.m".
    05 FILLER PIC 9(4) VALUE 77.
    05 FILLER PIC X(40) VALUE "key.keyboard.n".
    05 FILLER PIC 9(4) VALUE 78.
    05 FILLER PIC X(40) VALUE "key.keyboard.o".
    05 FILLER PIC 9(4) VALUE 79.
    05 FILLER PIC X(40) VALUE "key.keyboard.p".
    05 FILLER PIC 9(4) VALUE 80.
    05 FILLER PIC X(40) VALUE "key.keyboard.q".
    05 FILLER PIC 9(4) VALUE 81.
    05 FILLER PIC X(40) VALUE "key.keyboard.r".
    05 FILLER PIC 9(4) VALUE 82.
    05 FILLER PIC X(40) VALUE "key.keyboard.s".
    05 FILLER PIC 9(4) VALUE 83.
    05 FILLER PIC X(40) VALUE "key.keyboard.t".
    05 FILLER PIC 9(4) VALUE 84.
    05 FILLER PIC X(40) VALUE "key.keyboard.u".
    05 FILLER PIC 9(4) VALUE 85.
    05 FILLER PIC X(40) VALUE "key.keyboard.v".
    05 FILLER PIC 9(4) VALUE 86.
    05 FILLER PIC X(40) VALUE "key.keyboard.w".
    05 FILLER PIC 9(4) VALUE 87.
    05 FILLER PIC X(40) VALUE "key.keyboard.x".
    05 FILLER PIC 9(4) VALUE 88.
    05 FILLER PIC X(40) VALUE "key.keyboard.y".
    05 FILLER PIC 9(4) VALUE 89.
    05 FILLER PIC X(40) VALUE "key.keyboard.z".
    05 FILLER PIC 9(4) VALUE 90.
    05 FILLER PIC X(40) VALUE "key.keyboard.1".
    05 FILLER PIC 9(4) VALUE 49.
    05 FILLER PIC X(40) VALUE "key.keyboard.2".
    05 FILLER PIC 9(4) VALUE 50.
    05 FILLER PIC X(40) VALUE "key.keyboard.3".
    05 FILLER PIC 9(4) VALUE 51.
    05 FILLER PIC X(40) VALUE "key.keyboard.4".
    05 FILLER PIC 9(4) VALUE 52.
    05 FILLER PIC X(40) VALUE "key.keyboard.5".
    05 FILLER PIC 9(4) VALUE 53.
    05 FILLER PIC X(40) VALUE "key.keyboard.6".
    05 FILLER PIC 9(4) VALUE 54.
    05 FILLER PIC X(40) VALUE "key.keyboard.7".
    05 FILLER PIC 9(4) VALUE 55.
    05 FILLER PIC X(40) VALUE "key.keyboard.8".
    05 FILLER PIC 9(4) VALUE 56.
    05 FILLER PIC X(40) VALUE "key.keyboard.9".
    05 FILLER PIC 9(4) VALUE 57.
    05 FILLER PIC X(40) VALUE "key.keyboard.0".
    05 FILLER PIC 9(4) VALUE 48.
    05 FILLER PIC X(40) VALUE "key.keyboard.enter".
    05 FILLER PIC 9(4) VALUE 257.
    05 FILLER PIC X(40) VALUE "key.keyboard.escape".
    05 FILLER PIC 9(4) VALUE 256.
    05 FILLER PIC X(40) VALUE "key.keyboard.backspace".
    05 FILLER PIC 9(4) VALUE 259.
    05 FILLER PIC X(40) VALUE "key.keyboard.tab".
    05 FILLER PIC 9(4) VALUE 258.
    05 FILLER PIC X(40) VALUE "key.keyboard.space".
    05 FILLER PIC 9(4) VALUE 32.
    05 FILLER PIC X(40) VALUE "key.keyboard.minus".
    05 FILLER PIC 9(4) VALUE 45.
    05 FILLER PIC X(40) VALUE "key.keyboard.equal".
    05 FILLER PIC 9(4) VALUE 61.
    05 FILLER PIC X(40) VALUE "key.keyboard.left.bracket".
    05 FILLER PIC 9(4) VALUE 91.
    05 FILLER PIC X(40) VALUE "key.keyboard.right.bracket".
    05 FILLER PIC 9(4) VALUE 93.
    05 FILLER PIC X(40) VALUE "key.keyboard.backslash".
    05 FILLER PIC 9(4) VALUE 92.
    05 FILLER PIC X(40) VALUE "key.keyboard.world.2".
    05 FILLER PIC 9(4) VALUE 0.
    05 FILLER PIC X(40) VALUE "key.keyboard.semicolon".
    05 FILLER PIC 9(4) VALUE 59.
    05 FILLER PIC X(40) VALUE "key.keyboard.apostrophe".
    05 FILLER PIC 9(4) VALUE 39.
    05 FILLER PIC X(40) VALUE "key.keyboard.grave.accent".
    05 FILLER PIC 9(4) VALUE 96.
    05 FILLER PIC X(40) VALUE "key.keyboard.comma".
    05 FILLER PIC 9(4) VALUE 44.
    05 FILLER PIC X(40) VALUE "key.keyboard.period".
    05 FILLER PIC 9(4) VALUE 46.
    05 FILLER PIC X(40) VALUE "key.keyboard.slash".
    05 FILLER PIC 9(4) VALUE 47.
    05 FILLER PIC X(40) VALUE "key.keyboard.caps.lock".
    05 FILLER PIC 9(4) VALUE 280.
    05 FILLER PIC X(40) VALUE "key.keyboard.f1".
    05 FILLER PIC 9(4) VALUE 290.
    05 FILLER PIC X(40) VALUE "key.keyboard.f2".
    05 FILLER PIC 9(4) VALUE 291.
    05 FILLER PIC X(40) VALUE "key.keyboard.f3".
    05 FILLER PIC 9(4) VALUE 292.
    05 FILLER PIC X(40) VALUE "key.keyboard.f4".
    05 FILLER PIC 9(4) VALUE 293.
    05 FILLER PIC X(40) VALUE "key.keyboard.f5".
    05 FILLER PIC 9(4) VALUE 294.
    05 FILLER PIC X(40) VALUE "key.keyboard.f6".
    05 FILLER PIC 9(4) VALUE 295.
    05 FILLER PIC X(40) VALUE "key.keyboard.f7".
    05 FILLER PIC 9(4) VALUE 296.
    05 FILLER PIC X(40) VALUE "key.keyboard.f8".
    05 FILLER PIC 9(4) VALUE 297.
    05 FILLER PIC X(40) VALUE "key.keyboard.f9".
    05 FILLER PIC 9(4) VALUE 298.
    05 FILLER PIC X(40) VALUE "key.keyboard.f10".
    05 FILLER PIC 9(4) VALUE 299.
    05 FILLER PIC X(40) VALUE "key.keyboard.f11".
    05 FILLER PIC 9(4) VALUE 300.
    05 FILLER PIC X(40) VALUE "key.keyboard.f12".
    05 FILLER PIC 9(4) VALUE 301.
    05 FILLER PIC X(40) VALUE "key.keyboard.print.screen".
    05 FILLER PIC 9(4) VALUE 283.
    05 FILLER PIC X(40) VALUE "key.keyboard.scroll.lock".
    05 FILLER PIC 9(4) VALUE 281.
    05 FILLER PIC X(40) VALUE "key.keyboard.pause".
    05 FILLER PIC 9(4) VALUE 284.
    05 FILLER PIC X(40) VALUE "key.keyboard.insert".
    05 FILLER PIC 9(4) VALUE 260.
    05 FILLER PIC X(40) VALUE "key.keyboard.home".
    05 FILLER PIC 9(4) VALUE 268.
    05 FILLER PIC X(40) VALUE "key.keyboard.page.up".
    05 FILLER PIC 9(4) VALUE 266.
    05 FILLER PIC X(40) VALUE "key.keyboard.delete".
    05 FILLER PIC 9(4) VALUE 261.
    05 FILLER PIC X(40) VALUE "key.keyboard.end".
    05 FILLER PIC 9(4) VALUE 269.
    05 FILLER PIC X(40) VALUE "key.keyboard.page.down".
    05 FILLER PIC 9(4) VALUE 267.
    05 FILLER PIC X(40) VALUE "key.keyboard.right".
    05 FILLER PIC 9(4) VALUE 262.
    05 FILLER PIC X(40) VALUE "key.keyboard.left".
    05 FILLER PIC 9(4) VALUE 263.
    05 FILLER PIC X(40) VALUE "key.keyboard.down".
    05 FILLER PIC 9(4) VALUE 264.
    05 FILLER PIC X(40) VALUE "key.keyboard.up".
    05 FILLER PIC 9(4) VALUE 265.
    05 FILLER PIC X(40) VALUE "key.keyboard.num.lock".
    05 FILLER PIC 9(4) VALUE 282.
    05 FILLER PIC X(40) VALUE "key.keyboard.keypad.divide".
    05 FILLER PIC 9(4) VALUE 331.
    05 FILLER PIC X(40) VALUE "key.keyboard.keypad.multiply".
    05 FILLER PIC 9(4) VALUE 332.
    05 FILLER PIC X(40) VALUE "key.keyboard.keypad.subtract".
    05 FILLER PIC 9(4) VALUE 333.
    05 FILLER PIC X(40) VALUE "key.keyboard.keypad.add".
    05 FILLER PIC 9(4) VALUE 334.
    05 FILLER PIC X(40) VALUE "key.keyboard.keypad.enter".
    05 FILLER PIC 9(4) VALUE 335.
    05 FILLER PIC X(40) VALUE "key.keyboard.keypad.1".
    05 FILLER PIC 9(4) VALUE 321.
    05 FILLER PIC X(40) VALUE "key.keyboard.keypad.2".
    05 FILLER PIC 9(4) VALUE 322.
    05 FILLER PIC X(40) VALUE "key.keyboard.keypad.3".
    05 FILLER PIC 9(4) VALUE 323.
    05 FILLER PIC X(40) VALUE "key.keyboard.keypad.4".
    05 FILLER PIC 9(4) VALUE 324.
    05 FILLER PIC X(40) VALUE "key.keyboard.keypad.5".
    05 FILLER PIC 9(4) VALUE 325.
    05 FILLER PIC X(40) VALUE "key.keyboard.keypad.6".
    05 FILLER PIC 9(4) VALUE 326.
    05 FILLER PIC X(40) VALUE "key.keyboard.keypad.7".
    05 FILLER PIC 9(4) VALUE 327.
    05 FILLER PIC X(40) VALUE "key.keyboard.keypad.8".
    05 FILLER PIC 9(4) VALUE 328.
    05 FILLER PIC X(40) VALUE "key.keyboard.keypad.9".
    05 FILLER PIC 9(4) VALUE 329.
    05 FILLER PIC X(40) VALUE "key.keyboard.keypad.0".
    05 FILLER PIC 9(4) VALUE 320.
    05 FILLER PIC X(40) VALUE "key.keyboard.keypad.period".
    05 FILLER PIC 9(4) VALUE 0.
    05 FILLER PIC X(40) VALUE "key.keyboard.world.1".
    05 FILLER PIC 9(4) VALUE 0.
    05 FILLER PIC X(40) VALUE "key.keyboard.application".
    05 FILLER PIC 9(4) VALUE 0.
    05 FILLER PIC X(40) VALUE "key.keyboard.power".
    05 FILLER PIC 9(4) VALUE 0.
    05 FILLER PIC X(40) VALUE "key.keyboard.keypad.equal".
    05 FILLER PIC 9(4) VALUE 336.
    05 FILLER PIC X(40) VALUE "key.keyboard.f13".
    05 FILLER PIC 9(4) VALUE 302.
    05 FILLER PIC X(40) VALUE "key.keyboard.f14".
    05 FILLER PIC 9(4) VALUE 303.
    05 FILLER PIC X(40) VALUE "key.keyboard.f15".
    05 FILLER PIC 9(4) VALUE 304.
    05 FILLER PIC X(40) VALUE "key.keyboard.f16".
    05 FILLER PIC 9(4) VALUE 305.
    05 FILLER PIC X(40) VALUE "key.keyboard.f17".
    05 FILLER PIC 9(4) VALUE 306.
    05 FILLER PIC X(40) VALUE "key.keyboard.f18".
    05 FILLER PIC 9(4) VALUE 307.
    05 FILLER PIC X(40) VALUE "key.keyboard.f19".
    05 FILLER PIC 9(4) VALUE 308.
    05 FILLER PIC X(40) VALUE "key.keyboard.f20".
    05 FILLER PIC 9(4) VALUE 309.
    05 FILLER PIC X(40) VALUE "key.keyboard.f21".
    05 FILLER PIC 9(4) VALUE 310.
    05 FILLER PIC X(40) VALUE "key.keyboard.f22".
    05 FILLER PIC 9(4) VALUE 311.
    05 FILLER PIC X(40) VALUE "key.keyboard.f23".
    05 FILLER PIC 9(4) VALUE 312.
    05 FILLER PIC X(40) VALUE "key.keyboard.f24".
    05 FILLER PIC 9(4) VALUE 313.
    05 FILLER PIC X(40) VALUE "key.keyboard.execute".
    05 FILLER PIC 9(4) VALUE 0.
    05 FILLER PIC X(40) VALUE "key.keyboard.help".
    05 FILLER PIC 9(4) VALUE 0.
    05 FILLER PIC X(40) VALUE "key.keyboard.menu".
    05 FILLER PIC 9(4) VALUE 348.
    05 FILLER PIC X(40) VALUE "key.keyboard.select".
    05 FILLER PIC 9(4) VALUE 0.
    05 FILLER PIC X(40) VALUE "key.keyboard.stop".
    05 FILLER PIC 9(4) VALUE 0.
    05 FILLER PIC X(40) VALUE "key.keyboard.again".
    05 FILLER PIC 9(4) VALUE 0.
    05 FILLER PIC X(40) VALUE "key.keyboard.undo".
    05 FILLER PIC 9(4) VALUE 0.
    05 FILLER PIC X(40) VALUE "key.keyboard.cut".
    05 FILLER PIC 9(4) VALUE 0.
    05 FILLER PIC X(40) VALUE "key.keyboard.copy".
    05 FILLER PIC 9(4) VALUE 0.
    05 FILLER PIC X(40) VALUE "key.keyboard.paste".
    05 FILLER PIC 9(4) VALUE 0.
    05 FILLER PIC X(40) VALUE "key.keyboard.find".
    05 FILLER PIC 9(4) VALUE 0.
    05 FILLER PIC X(40) VALUE "key.keyboard.mute".
    05 FILLER PIC 9(4) VALUE 0.
    05 FILLER PIC X(40) VALUE "key.keyboard.volume.up".
    05 FILLER PIC 9(4) VALUE 0.
    05 FILLER PIC X(40) VALUE "key.keyboard.volume.down".
    05 FILLER PIC 9(4) VALUE 0.
    05 FILLER PIC X(40) VALUE "key.keyboard.keypad.comma".
    05 FILLER PIC 9(4) VALUE 0.
    05 FILLER PIC X(40) VALUE "key.keyboard.keypad.equals.as400".
    05 FILLER PIC 9(4) VALUE 0.
    05 FILLER PIC X(40) VALUE "key.keyboard.international1".
    05 FILLER PIC 9(4) VALUE 0.
    05 FILLER PIC X(40) VALUE "key.keyboard.international2".
    05 FILLER PIC 9(4) VALUE 0.
    05 FILLER PIC X(40) VALUE "key.keyboard.international3".
    05 FILLER PIC 9(4) VALUE 0.
    05 FILLER PIC X(40) VALUE "key.keyboard.international4".
    05 FILLER PIC 9(4) VALUE 0.
    05 FILLER PIC X(40) VALUE "key.keyboard.international5".
    05 FILLER PIC 9(4) VALUE 0.
    05 FILLER PIC X(40) VALUE "key.keyboard.international6".
    05 FILLER PIC 9(4) VALUE 0.
    05 FILLER PIC X(40) VALUE "key.keyboard.international7".
    05 FILLER PIC 9(4) VALUE 0.
    05 FILLER PIC X(40) VALUE "key.keyboard.international8".
    05 FILLER PIC 9(4) VALUE 0.
    05 FILLER PIC X(40) VALUE "key.keyboard.international9".
    05 FILLER PIC 9(4) VALUE 0.
    05 FILLER PIC X(40) VALUE "key.keyboard.lang1".
    05 FILLER PIC 9(4) VALUE 0.
    05 FILLER PIC X(40) VALUE "key.keyboard.lang2".
    05 FILLER PIC 9(4) VALUE 0.
    05 FILLER PIC X(40) VALUE "key.keyboard.lang3".
    05 FILLER PIC 9(4) VALUE 0.
    05 FILLER PIC X(40) VALUE "key.keyboard.lang4".
    05 FILLER PIC 9(4) VALUE 0.
    05 FILLER PIC X(40) VALUE "key.keyboard.lang5".
    05 FILLER PIC 9(4) VALUE 0.
    05 FILLER PIC X(40) VALUE "key.keyboard.lang6".
    05 FILLER PIC 9(4) VALUE 0.
    05 FILLER PIC X(40) VALUE "key.keyboard.lang7".
    05 FILLER PIC 9(4) VALUE 0.
    05 FILLER PIC X(40) VALUE "key.keyboard.lang8".
    05 FILLER PIC 9(4) VALUE 0.
    05 FILLER PIC X(40) VALUE "key.keyboard.lang9".
    05 FILLER PIC 9(4) VALUE 0.
    05 FILLER PIC X(40) VALUE "key.keyboard.alternate.erase".
    05 FILLER PIC 9(4) VALUE 0.
    05 FILLER PIC X(40) VALUE "key.keyboard.sys.req".
    05 FILLER PIC 9(4) VALUE 0.
    05 FILLER PIC X(40) VALUE "key.keyboard.cancel".
    05 FILLER PIC 9(4) VALUE 0.
    05 FILLER PIC X(40) VALUE "key.keyboard.clear".
    05 FILLER PIC 9(4) VALUE 0.
    05 FILLER PIC X(40) VALUE "key.keyboard.prior".
    05 FILLER PIC 9(4) VALUE 0.
    05 FILLER PIC X(40) VALUE "key.keyboard.enter2".
    05 FILLER PIC 9(4) VALUE 0.
    05 FILLER PIC X(40) VALUE "key.keyboard.separator".
    05 FILLER PIC 9(4) VALUE 0.
    05 FILLER PIC X(40) VALUE "key.keyboard.out".
    05 FILLER PIC 9(4) VALUE 0.
    05 FILLER PIC X(40) VALUE "key.keyboard.oper".
    05 FILLER PIC 9(4) VALUE 0.
    05 FILLER PIC X(40) VALUE "key.keyboard.clear.again".
    05 FILLER PIC 9(4) VALUE 0.
    05 FILLER PIC X(40) VALUE "key.keyboard.crsel".
    05 FILLER PIC 9(4) VALUE 0.
    05 FILLER PIC X(40) VALUE "key.keyboard.exsel".
    05 FILLER PIC 9(4) VALUE 0.
    05 FILLER PIC X(40) VALUE "key.keyboard.keypad.00".
    05 FILLER PIC 9(4) VALUE 0.
    05 FILLER PIC X(40) VALUE "key.keyboard.keypad.000".
    05 FILLER PIC 9(4) VALUE 0.
    05 FILLER PIC X(40) VALUE "key.keyboard.thousands.separator".
    05 FILLER PIC 9(4) VALUE 0.
    05 FILLER PIC X(40) VALUE "key.keyboard.decimal.separator".
    05 FILLER PIC 9(4) VALUE 0.
    05 FILLER PIC X(40) VALUE "key.keyboard.currency.unit".
    05 FILLER PIC 9(4) VALUE 0.
    05 FILLER PIC X(40) VALUE "key.keyboard.currency.subunit".
    05 FILLER PIC 9(4) VALUE 0.
    05 FILLER PIC X(40) VALUE "key.keyboard.keypad.left.parenthesis".
    05 FILLER PIC 9(4) VALUE 0.
    05 FILLER PIC X(40) VALUE "key.keyboard.keypad.right.parenthesis".
    05 FILLER PIC 9(4) VALUE 0.
    05 FILLER PIC X(40) VALUE "key.keyboard.keypad.left.brace".
    05 FILLER PIC 9(4) VALUE 0.
    05 FILLER PIC X(40) VALUE "key.keyboard.keypad.right.brace".
    05 FILLER PIC 9(4) VALUE 0.
    05 FILLER PIC X(40) VALUE "key.keyboard.keypad.tab".
    05 FILLER PIC 9(4) VALUE 0.
    05 FILLER PIC X(40) VALUE "key.keyboard.keypad.backspace".
    05 FILLER PIC 9(4) VALUE 0.
    05 FILLER PIC X(40) VALUE "key.keyboard.keypad.a".
    05 FILLER PIC 9(4) VALUE 0.
    05 FILLER PIC X(40) VALUE "key.keyboard.keypad.b".
    05 FILLER PIC 9(4) VALUE 0.
    05 FILLER PIC X(40) VALUE "key.keyboard.keypad.c".
    05 FILLER PIC 9(4) VALUE 0.
    05 FILLER PIC X(40) VALUE "key.keyboard.keypad.d".
    05 FILLER PIC 9(4) VALUE 0.
    05 FILLER PIC X(40) VALUE "key.keyboard.keypad.e".
    05 FILLER PIC 9(4) VALUE 0.
    05 FILLER PIC X(40) VALUE "key.keyboard.keypad.f".
    05 FILLER PIC 9(4) VALUE 0.
    05 FILLER PIC X(40) VALUE "key.keyboard.keypad.xor".
    05 FILLER PIC 9(4) VALUE 0.
    05 FILLER PIC X(40) VALUE "key.keyboard.keypad.power".
    05 FILLER PIC 9(4) VALUE 0.
    05 FILLER PIC X(40) VALUE "key.keyboard.keypad.percent".
    05 FILLER PIC 9(4) VALUE 0.
    05 FILLER PIC X(40) VALUE "key.keyboard.keypad.less".
    05 FILLER PIC 9(4) VALUE 0.
    05 FILLER PIC X(40) VALUE "key.keyboard.keypad.greater".
    05 FILLER PIC 9(4) VALUE 0.
    05 FILLER PIC X(40) VALUE "key.keyboard.keypad.ampersand".
    05 FILLER PIC 9(4) VALUE 0.
    05 FILLER PIC X(40) VALUE "key.keyboard.keypad.double.ampersand".
    05 FILLER PIC 9(4) VALUE 0.
    05 FILLER PIC X(40) VALUE "key.keyboard.keypad.vertical.bar".
    05 FILLER PIC 9(4) VALUE 0.
    05 FILLER PIC X(40) VALUE "key.keyboard.keypad.double.vertical.bar".
    05 FILLER PIC 9(4) VALUE 0.
    05 FILLER PIC X(40) VALUE "key.keyboard.keypad.colon".
    05 FILLER PIC 9(4) VALUE 0.
    05 FILLER PIC X(40) VALUE "key.keyboard.keypad.hash".
    05 FILLER PIC 9(4) VALUE 0.
    05 FILLER PIC X(40) VALUE "key.keyboard.keypad.space".
    05 FILLER PIC 9(4) VALUE 0.
    05 FILLER PIC X(40) VALUE "key.keyboard.keypad.at".
    05 FILLER PIC 9(4) VALUE 0.
    05 FILLER PIC X(40) VALUE "key.keyboard.keypad.exclamation".
    05 FILLER PIC 9(4) VALUE 0.
    05 FILLER PIC X(40) VALUE "key.keyboard.keypad.memory.store".
    05 FILLER PIC 9(4) VALUE 0.
    05 FILLER PIC X(40) VALUE "key.keyboard.keypad.memory.recall".
    05 FILLER PIC 9(4) VALUE 0.
    05 FILLER PIC X(40) VALUE "key.keyboard.keypad.memory.clear".
    05 FILLER PIC 9(4) VALUE 0.
    05 FILLER PIC X(40) VALUE "key.keyboard.keypad.memory.add".
    05 FILLER PIC 9(4) VALUE 0.
    05 FILLER PIC X(40) VALUE "key.keyboard.keypad.memory.subtract".
    05 FILLER PIC 9(4) VALUE 0.
    05 FILLER PIC X(40) VALUE "key.keyboard.keypad.memory.multiply".
    05 FILLER PIC 9(4) VALUE 0.
    05 FILLER PIC X(40) VALUE "key.keyboard.keypad.memory.divide".
    05 FILLER PIC 9(4) VALUE 0.
    05 FILLER PIC X(40) VALUE "key.keyboard.keypad.plus.minus".
    05 FILLER PIC 9(4) VALUE 0.
    05 FILLER PIC X(40) VALUE "key.keyboard.keypad.clear".
    05 FILLER PIC 9(4) VALUE 0.
    05 FILLER PIC X(40) VALUE "key.keyboard.keypad.clear.entry".
    05 FILLER PIC 9(4) VALUE 0.
    05 FILLER PIC X(40) VALUE "key.keyboard.keypad.binary".
    05 FILLER PIC 9(4) VALUE 0.
    05 FILLER PIC X(40) VALUE "key.keyboard.keypad.octal".
    05 FILLER PIC 9(4) VALUE 0.
    05 FILLER PIC X(40) VALUE "key.keyboard.keypad.decimal".
    05 FILLER PIC 9(4) VALUE 330.
    05 FILLER PIC X(40) VALUE "key.keyboard.keypad.hexadecimal".
    05 FILLER PIC 9(4) VALUE 0.
    05 FILLER PIC X(40) VALUE "key.keyboard.left.control".
    05 FILLER PIC 9(4) VALUE 341.
    05 FILLER PIC X(40) VALUE "key.keyboard.left.shift".
    05 FILLER PIC 9(4) VALUE 340.
    05 FILLER PIC X(40) VALUE "key.keyboard.left.alt".
    05 FILLER PIC 9(4) VALUE 342.
    05 FILLER PIC X(40) VALUE "key.keyboard.left.win".
    05 FILLER PIC 9(4) VALUE 343.
    05 FILLER PIC X(40) VALUE "key.keyboard.right.control".
    05 FILLER PIC 9(4) VALUE 345.
    05 FILLER PIC X(40) VALUE "key.keyboard.right.shift".
    05 FILLER PIC 9(4) VALUE 344.
    05 FILLER PIC X(40) VALUE "key.keyboard.right.alt".
    05 FILLER PIC 9(4) VALUE 346.
    05 FILLER PIC X(40) VALUE "key.keyboard.right.win".
    05 FILLER PIC 9(4) VALUE 347.
    05 FILLER PIC X(40) VALUE "key.keyboard.mode".
    05 FILLER PIC 9(4) VALUE 0.
    05 FILLER PIC X(40) VALUE "key.keyboard.sleep".
    05 FILLER PIC 9(4) VALUE 0.
    05 FILLER PIC X(40) VALUE "key.keyboard.wake".
    05 FILLER PIC 9(4) VALUE 0.
    05 FILLER PIC X(40) VALUE "key.keyboard.channel.up".
    05 FILLER PIC 9(4) VALUE 0.
    05 FILLER PIC X(40) VALUE "key.keyboard.channel.down".
    05 FILLER PIC 9(4) VALUE 0.
    05 FILLER PIC X(40) VALUE "key.keyboard.media.play".
    05 FILLER PIC 9(4) VALUE 0.
    05 FILLER PIC X(40) VALUE "key.keyboard.media.pause".
    05 FILLER PIC 9(4) VALUE 0.
    05 FILLER PIC X(40) VALUE "key.keyboard.media.record".
    05 FILLER PIC 9(4) VALUE 0.
    05 FILLER PIC X(40) VALUE "key.keyboard.media.fast.forward".
    05 FILLER PIC 9(4) VALUE 0.
    05 FILLER PIC X(40) VALUE "key.keyboard.media.rewind".
    05 FILLER PIC 9(4) VALUE 0.
    05 FILLER PIC X(40) VALUE "key.keyboard.media.next.track".
    05 FILLER PIC 9(4) VALUE 0.
    05 FILLER PIC X(40) VALUE "key.keyboard.media.previous.track".
    05 FILLER PIC 9(4) VALUE 0.
    05 FILLER PIC X(40) VALUE "key.keyboard.media.stop".
    05 FILLER PIC 9(4) VALUE 0.
    05 FILLER PIC X(40) VALUE "key.keyboard.media.eject".
    05 FILLER PIC 9(4) VALUE 0.
    05 FILLER PIC X(40) VALUE "key.keyboard.media.play.pause".
    05 FILLER PIC 9(4) VALUE 0.
    05 FILLER PIC X(40) VALUE "key.keyboard.media.select".
    05 FILLER PIC 9(4) VALUE 0.
    05 FILLER PIC X(40) VALUE "key.keyboard.ac.new".
    05 FILLER PIC 9(4) VALUE 0.
    05 FILLER PIC X(40) VALUE "key.keyboard.ac.open".
    05 FILLER PIC 9(4) VALUE 0.
    05 FILLER PIC X(40) VALUE "key.keyboard.ac.close".
    05 FILLER PIC 9(4) VALUE 0.
    05 FILLER PIC X(40) VALUE "key.keyboard.ac.exit".
    05 FILLER PIC 9(4) VALUE 0.
    05 FILLER PIC X(40) VALUE "key.keyboard.ac.save".
    05 FILLER PIC 9(4) VALUE 0.
    05 FILLER PIC X(40) VALUE "key.keyboard.ac.print".
    05 FILLER PIC 9(4) VALUE 0.
    05 FILLER PIC X(40) VALUE "key.keyboard.ac.properties".
    05 FILLER PIC 9(4) VALUE 0.
    05 FILLER PIC X(40) VALUE "key.keyboard.ac.search".
    05 FILLER PIC 9(4) VALUE 0.
    05 FILLER PIC X(40) VALUE "key.keyboard.ac.home".
    05 FILLER PIC 9(4) VALUE 0.
    05 FILLER PIC X(40) VALUE "key.keyboard.ac.back".
    05 FILLER PIC 9(4) VALUE 0.
    05 FILLER PIC X(40) VALUE "key.keyboard.ac.forward".
    05 FILLER PIC 9(4) VALUE 0.
    05 FILLER PIC X(40) VALUE "key.keyboard.ac.stop".
    05 FILLER PIC 9(4) VALUE 0.
    05 FILLER PIC X(40) VALUE "key.keyboard.ac.refresh".
    05 FILLER PIC 9(4) VALUE 0.
    05 FILLER PIC X(40) VALUE "key.keyboard.ac.bookmarks".
    05 FILLER PIC 9(4) VALUE 0.
    05 FILLER PIC X(40) VALUE "key.keyboard.soft.left".
    05 FILLER PIC 9(4) VALUE 0.
    05 FILLER PIC X(40) VALUE "key.keyboard.soft.right".
    05 FILLER PIC 9(4) VALUE 0.
    05 FILLER PIC X(40) VALUE "key.keyboard.call".
    05 FILLER PIC 9(4) VALUE 0.
    05 FILLER PIC X(40) VALUE "key.keyboard.end.call".
    05 FILLER PIC 9(4) VALUE 0.
    05 FILLER PIC X(40) VALUE "key.mouse.left".
    05 FILLER PIC 9(4) VALUE 1000.
    05 FILLER PIC X(40) VALUE "key.mouse.right".
    05 FILLER PIC 9(4) VALUE 1001.
    05 FILLER PIC X(40) VALUE "key.mouse.middle".
    05 FILLER PIC 9(4) VALUE 1002.
    05 FILLER PIC X(40) VALUE "key.mouse.4".
    05 FILLER PIC 9(4) VALUE 1003.
    05 FILLER PIC X(40) VALUE "key.mouse.5".
    05 FILLER PIC 9(4) VALUE 1004.
    05 FILLER PIC X(40) VALUE "key.mouse.6".
    05 FILLER PIC 9(4) VALUE 1005.
    05 FILLER PIC X(40) VALUE "key.mouse.7".
    05 FILLER PIC 9(4) VALUE 1006.
    05 FILLER PIC X(40) VALUE "key.mouse.8".
    05 FILLER PIC 9(4) VALUE 1007.
 01 KT-TABLE REDEFINES KT-DATA.
    05 KT-ROW OCCURS 255 TIMES.
       10 KT-NAME          PIC X(40).
       10 KT-GLFW          PIC 9(4).
