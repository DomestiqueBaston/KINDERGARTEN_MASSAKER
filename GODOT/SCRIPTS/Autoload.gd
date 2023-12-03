extends Node

const _ignored_keys = [KEY_ALT, KEY_SHIFT, KEY_CONTROL, KEY_META, KEY_MENU]

#
# Returns true if the given event can be interpreted as "any key press" by a
# temporary screen which exits when "any key" is pressed. We have to explicitly
# ignore modifier keys, to avoid exiting when, for example, the Alt-Enter
# keyboard shortcut is used to toggle full-screen mode.
#
func event_is_key_press(event: InputEvent):
	return event.is_pressed() and not (
		event is InputEventKey and event.scancode in _ignored_keys)
