extends Control

signal tutorial_dismissed

func _ready():
	$ContinueButton.grab_focus.call_deferred()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("shoot") or event.is_action_pressed("ui_accept"):
		tutorial_dismissed.emit()


func _on_continue_button_pressed() -> void:
	tutorial_dismissed.emit()
