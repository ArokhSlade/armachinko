extends MenuTab
class_name Settings


var master_bus
var music_bus 
var sfx_bus

@onready var window = get_window()

func _ready() -> void:
	super()
	var vsync_mode = DisplayServer.window_get_vsync_mode()
	
	if vsync_mode == DisplayServer.VSyncMode.VSYNC_DISABLED:
		$GraphicsandControls/VSync/VSynncCheckbox.button_pressed = false
	else:
		$GraphicsandControls/VSync/VSynncCheckbox.button_pressed = true
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED)

	var window_mode = window.mode
	if window_mode in [Window.Mode.MODE_EXCLUSIVE_FULLSCREEN, Window.Mode.MODE_FULLSCREEN]:
		$GraphicsandControls/Fullscreen/FullscreenCheckbox.button_pressed = true
	else: 
		$GraphicsandControls/Fullscreen/FullscreenCheckbox.button_pressed = false
	
	
	master_bus = AudioServer.get_bus_index("Master")
	music_bus = AudioServer.get_bus_index("Music")
	sfx_bus = AudioServer.get_bus_index("SFX")
	
	$GraphicsandControls/MainVolume/MainVolumeSliderFrame.value = db_to_linear(AudioServer.get_bus_volume_db(master_bus))	
	$GraphicsandControls/MainVolume/MainVolumeSliderFrame.update_slider_position()
	$GraphicsandControls/Music/MusicSlider.value = db_to_linear(AudioServer.get_bus_volume_db(music_bus))
	$GraphicsandControls/Sounds/SFXSlider.value = db_to_linear(AudioServer.get_bus_volume_db(sfx_bus))
	

#_______________________DISPLAY_________________________#

func _on_fullscreen_checkbox_toggled(toggled_on: bool) -> void:
	if toggled_on:
		window.mode = Window.Mode.MODE_EXCLUSIVE_FULLSCREEN
	else:
		window.mode = Window.Mode.MODE_WINDOWED 


func _on_v_synnc_checkbox_toggled(toggled_on: bool) -> void:
	if toggled_on: 
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED)
	else:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)

#_______________________AUDIO_________________________#


func _on_main_volume_slider_value_changed(value: float) -> void:	
	AudioServer.set_bus_volume_db(master_bus, linear_to_db(value))
	SettingsData.master_volume_linear = value

func _on_music_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(music_bus, linear_to_db(value))
	SettingsData.music_volume_linear = value

func _on_sfx_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(sfx_bus, linear_to_db(value))
	SettingsData.sfx_volume_linear = value




func _on_main_volume_checkbox_toggled(toggled_on: bool) -> void:
	AudioServer.set_bus_mute(master_bus, not toggled_on)


func _on_music_checkbox_toggled(toggled_on: bool) -> void:
	AudioServer.set_bus_mute(music_bus, not toggled_on)
	
	
func _on_sounds_checkbox_toggled(toggled_on: bool) -> void:	
	AudioServer.set_bus_mute(sfx_bus, not toggled_on)

#___________________INPUT_CONTROLS__________________#


func _on_input_style_a_checkbox_toggled(toggled_on: bool) -> void:
	$Controls/InputStyleBCheckbox.button_pressed = not toggled_on

func _on_input_style_b_checkbox_toggled(toggled_on: bool) -> void:
	$Controls/InputStyleACheckbox.button_pressed = not toggled_on


func _on_sfx_slider_gui_input(event):
	if event is InputEventMouseButton:
		if event.pressed:
			$SFXSamplePlayer.play()
