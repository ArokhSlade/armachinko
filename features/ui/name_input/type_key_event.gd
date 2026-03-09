extends InputEventKey
class_name TypeKeyEvent

var key_string : StringName

static var valid_chars = " abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890_-"

static func from_key_event(key_event : InputEventKey) -> TypeKeyEvent:
	var event = TypeKeyEvent.new()
	if key_event.shift_pressed:
		print("shift_pressed")
		event.shift_pressed = true
	event.keycode = key_event.keycode
	event.pressed = key_event.pressed
	event.update()
	if event.key_string in valid_chars:
		return event
	elif event.keycode == KEY_BACKSPACE:
		return event
	else:
		return null

func update():
	if keycode == KEY_MINUS:
		if shift_pressed:
			key_string = "_"
		else: 
			key_string = "-"
	else:
		key_string = OS.get_keycode_string(keycode)	
	print(key_string)
