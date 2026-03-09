extends Control

signal retry_requested
signal back_requested

@export var highscore_data_path = "user://highscore_data.tres" 
var highscore_data : HighscoreData


func load_highscore_data():
	if ResourceLoader.exists(highscore_data_path):
		highscore_data = load(highscore_data_path)
	else :
		highscore_data = HighscoreData.new()
		

func save_highscore_data():
	ResourceSaver.save(highscore_data, highscore_data_path)

@onready var highscore_table = $HighscoreList/UiHighscoreListTags/HighscoreTable

func update_contents(new_data : SavedScore):
	$GameOverSign/Buttons/RetryButton.grab_focus.call_deferred()
	$GameOverSign/PlayerName.text = new_data.name
	UIHelperFunctions.scale_text($GameOverSign/PlayerName)
	Globals.update_highscore_data(new_data)
	highscore_table.update_entries(Globals.highscore_data)
	UIHelperFunctions.scale_text($"../HUD/ScoreDisplay/ScoreLabel")

func _on_back_to_menu_button_pressed():
	back_requested.emit()


func _on_retry_button_pressed():
	retry_requested.emit()
