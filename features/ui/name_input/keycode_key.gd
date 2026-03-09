@tool
extends TextureButton


@export var keycode : Key = KEY_MINUS	


func generate_keycode_event():
	var my_event = TypeKeyEvent.new()	
	my_event.keycode = keycode
	my_event.pressed = true
	my_event.update()
	Input.parse_input_event(my_event)


func _on_pressed():
	generate_keycode_event()
