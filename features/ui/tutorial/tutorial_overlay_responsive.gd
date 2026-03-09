extends Control

signal tutorial_dismissed

func _ready():
	$ContinueButton.grab_focus.call_deferred()
	match SettingsData.last_used_input_device:
		SettingsData.InputDevice.Keyboard:
			$KeyboardTutorialContents.show()
			$ControllerTutorialContents.hide()
		SettingsData.InputDevice.Gamepad:
			$KeyboardTutorialContents.hide()
			$ControllerTutorialContents.show()

func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		$KeyboardTutorialContents.show()
		$ControllerTutorialContents.hide()
	elif event is InputEventJoypadButton or event is InputEventJoypadMotion:
		$KeyboardTutorialContents.hide()
		$ControllerTutorialContents.show()
		
	if event.is_action_pressed("shoot") or event.is_action_pressed("ui_accept"):
		tutorial_dismissed.emit()


func _on_continue_button_pressed() -> void:
	tutorial_dismissed.emit()
