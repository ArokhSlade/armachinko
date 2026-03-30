extends Node

@export var default_volume_level = 0.65

@export var master_volume_linear = default_volume_level ##between 0 and 1
@export var music_volume_linear = default_volume_level  ##between 0 and 1
@export var sfx_volume_linear = default_volume_level  ##between 0 and 1

@export var fullscreen = true

var master_bus
var music_bus
var sfx_bus

enum InputDevice {
	Keyboard,
	Gamepad
}

var last_used_input_device = InputDevice.Keyboard

#TODO: load and store settings data
#TODO: add display settings
#TODO: add control settings

@export_file("*.png") var mouse_image_path : String

func _ready():
	setup()


func setup():
	setup_audio()
	setup_display()
	@warning_ignore( "integer_division" )
	var mouse_image = load(mouse_image_path)
	Input.set_custom_mouse_cursor(mouse_image,Input.CURSOR_ARROW, Vector2(int(mouse_image.get_width()/2), mouse_image.get_height()/2))
	

func setup_audio():
	master_bus = AudioServer.get_bus_index("Master")
	music_bus = AudioServer.get_bus_index("Music")
	sfx_bus = AudioServer.get_bus_index("SFX")
	AudioServer.set_bus_volume_db(master_bus, linear_to_db(master_volume_linear))
	AudioServer.set_bus_volume_db(music_bus, linear_to_db(music_volume_linear))
	AudioServer.set_bus_volume_db(sfx_bus, linear_to_db(sfx_volume_linear))
	
	
func setup_display():
	var window = get_window()
	if fullscreen:
		window.mode = Window.Mode.MODE_EXCLUSIVE_FULLSCREEN
	else:
		window.mode = Window.Mode.MODE_WINDOWED 

func _input(event):
	if event is InputEventKey:
		last_used_input_device = InputDevice.Keyboard
	elif event is InputEventJoypadButton or event is InputEventJoypadMotion:
		last_used_input_device = InputDevice.Gamepad
