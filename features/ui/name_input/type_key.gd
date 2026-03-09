@tool
extends TextureButton


@export var letter : StringName = "A"
	
	
func _ready():
	$KeyLabel.text = letter


func generate_event(key_label):
	var my_event = TypeKeyEvent.new()
	var keycode = OS.find_keycode_from_string(key_label)
	my_event.keycode = keycode
	my_event.pressed = true
	if letter in "-_":
		my_event.key_string = letter
	else:
		my_event.update()
	Input.parse_input_event(my_event)


func _on_pressed():
	generate_event($KeyLabel.text)
