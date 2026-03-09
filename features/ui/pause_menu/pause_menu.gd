extends Control

signal retry_requested
signal continue_requested
signal quit_to_menu_requested

var last_button

func open():
	show()
	$PauseTab/ContinueButton.grab_focus()

func close():
	$AreYouSureTab.hide()

func request_retry():
	retry_requested.emit()

func request_continue():
	continue_requested.emit()

func open_settings():
	$PauseTab.hide()
	last_button = $PauseTab/SettingsButton
	$SettingsTab.open()
	$SettingsTab.show()
	$AnimationPlayer.play("settings_tab")

func close_settings():
	$AnimationPlayer.play_backwards("settings_tab")
	$PauseTab.show()
	$PauseTab/ContinueButton.grab_focus.call_deferred()
	last_button.grab_focus.call_deferred()

func open_quit_to_menu():
	$PauseTab.hide()
	last_button = $PauseTab/MainMenuButton
	$AreYouSureTab/Back.grab_focus.call_deferred()
	$AreYouSureTab.show()
	$AnimationPlayer.play("are_you_sure_tab")
	
func close_quit_to_menu():
	$AnimationPlayer.play_backwards("are_you_sure_tab")
	$PauseTab.show()
	$PauseTab/ContinueButton.grab_focus.call_deferred()
	last_button.grab_focus.call_deferred()

func request_quit_to_menu():
	quit_to_menu_requested.emit()

func _input(event):
	if event.is_action_pressed("pause_button") or event.is_action_pressed("ui_cancel"):
		if $AreYouSureTab.visible:
			close_quit_to_menu()
			get_viewport().set_input_as_handled()
