extends Control

@export var level_path : StringName = "res://features/level/main_level.tscn"

var last_button

func _ready() -> void:	
	PlayerData.setup()
	if not PlayerData.first_time_playing:
		$CanvasLayer/LastNameScroll.update_name(PlayerData.data.name)
		$CanvasLayer/LastNameScroll.show()
		
	for node in $CanvasLayer.get_children():
		if node.has_method("set_animation_player"):
			node.set_animation_player($AnimationPlayer)

	$CanvasLayer/MainButtons/StartButton.grab_focus.call_deferred()
	$CanvasLayer/NewHighscoreEntry.activate()
	

#__________________Main_Buttons__________________#

func _on_start_button_pressed() -> void:
	if $CanvasLayer/LastNameScroll.visible:
		last_button = $CanvasLayer/LastNameScroll/EditButton
		$CanvasLayer/LastNameScroll.open()
		
		
		$CanvasLayer/LastNameScroll/StartButton.focus_neighbor_bottom = $CanvasLayer/LastNameScroll/StartButton.get_path_to(%HighscoreButton)		
		$CanvasLayer/LastNameScroll/EditButton.focus_neighbor_bottom = $CanvasLayer/LastNameScroll/EditButton.get_path_to(%HighscoreButton)
		
		$CanvasLayer/LastNameScroll/StartButton.focus_neighbor_top = $CanvasLayer/LastNameScroll/StartButton.get_path_to(%QuitButton)
		$CanvasLayer/LastNameScroll/EditButton.focus_neighbor_top = $CanvasLayer/LastNameScroll/EditButton.get_path_to(%QuitButton)
		
		$CanvasLayer/LastNameScroll/StartButton.focus_next = $CanvasLayer/LastNameScroll/StartButton.focus_neighbor_bottom
		$CanvasLayer/LastNameScroll/StartButton.focus_previous = $CanvasLayer/LastNameScroll/StartButton.focus_neighbor_left
		
		$CanvasLayer/LastNameScroll/EditButton.focus_next = $CanvasLayer/LastNameScroll/EditButton.focus_neighbor_right
		$CanvasLayer/LastNameScroll/EditButton.focus_previous = $CanvasLayer/LastNameScroll/EditButton.focus_neighbor_top
		
		%HighscoreButton.focus_neighbor_top = %HighscoreButton.get_path_to($CanvasLayer/LastNameScroll/StartButton)
		%HighscoreButton.focus_previous = %HighscoreButton.focus_neighbor_top
		%QuitButton.focus_neighbor_bottom = %QuitButton.get_path_to($CanvasLayer/LastNameScroll/EditButton)
		%QuitButton.focus_next = %QuitButton.focus_neighbor_bottom
		
		%StartButton.mouse_filter = MOUSE_FILTER_IGNORE		
	else:
		last_button = %StartButton
		open_name_input_tab()

func open_name_input_tab():
	if $CanvasLayer/LastNameScroll.visible:
		$CanvasLayer/LastNameScroll.hide()
		
	$AnimationPlayer.play("enter_name_tab")	
	$CanvasLayer/EnterNameTab.open()
		
func load_game():
	get_tree().change_scene_to_file(level_path)
	
func set_last_button(button_name : StringName):
	match button_name:
		&"Start": 
			last_button = $CanvasLayer/MainButtons/StartButton
		&"Highscore":
			last_button = $CanvasLayer/MainButtons/HighscoreButton
		&"Settings":
			last_button = $CanvasLayer/MainButtons/SettingsButton
		&"Credits":
			last_button = $CanvasLayer/MainButtons/CreditsButton
		&"Quit":
			last_button = $CanvasLayer/MainButtons/QuitButton
		&"NameScrollStart":
			last_button = $CanvasLayer/LastNameScroll/StartButton
		&"NameScrollEdit":
			last_button = $CanvasLayer/LastNameScroll/EditButton

func _on_tab_closed():
	$CanvasLayer/ColorRect.hide()
	$CanvasLayer/MainButtons.show()
	if not PlayerData.first_time_playing:
		$CanvasLayer/LastNameScroll.show()
	last_button.grab_focus.call_deferred()
	$CanvasLayer/NewHighscoreEntry.activate()

func on_tab_opened():
	$CanvasLayer/ColorRect.show()
	$CanvasLayer/MainButtons.hide()
	$CanvasLayer/NewHighscoreEntry.deactivate()



func _on_highscore_button_pressed():
	$HighscorePopup.play()
	last_button = $"%HighscoreButton"


func _on_settings_button_pressed():
	last_button = %SettingsButton


func _on_credits_button_pressed():
	last_button = %CreditsButton


func _on_quit_button_pressed():
	last_button = %QuitButton

func _unhandled_input(event):
	if not $CanvasLayer/ColorRect.visible:
		if event.is_action_pressed("ui_cancel"):
			%QuitButton.grab_focus.call_deferred()
			#_on_quit_button_pressed()
			#$CanvasLayer/AreYouSureTab.open()
