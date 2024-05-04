# UI Extensions

This is a c++ engine module for the Pandemonium engine, containing smaller utilities.

# TouchButton

A `Control` based button, that handles multitouch properly.

# BSInputEventKey

An `inputEventKey` implementation, that matches actions exactly.

For example with the default pandemonium implementation if you have an action that gets triggered
with the key `E` then `Ctrl-E` will also trigger it.

This has the side effect, that if you bind an action to `E`, and an another one to `Ctrl-E`,
then hitting `Ctrl-E` will trigger both.

This implementation changes that behaviour.

However, you do need to replace normal input events at startup like this:

```
func _ready():
	var actions : Array = InputMap.get_actions()

	for action in actions:
		var acts : Array = InputMap.get_action_list(action)

		for i in range(len(acts)):
			var a = acts[i]
			if a is InputEventKey:
				var nie : BSInputEventKey = BSInputEventKey.new()
				nie.from_input_event_key(a as InputEventKey)
				acts[i] = nie

				InputMap.action_erase_event(action, a)
				InputMap.action_add_event(action, nie)

```

I recommend putting this code into a singleton.



