extends Node

var level : Level

var fresh_session = true

@export var highscore_data_path = "user://highscore_data.tres" 
var highscore_data : HighscoreData
var new_score_added = false

func load_highscore_data():
	if ResourceLoader.exists(highscore_data_path):
		highscore_data = load(highscore_data_path)
	else :
		highscore_data = HighscoreData.new()
		

func save_highscore_data():
	ResourceSaver.save(highscore_data, highscore_data_path)

func update_highscore_data(new_data : SavedScore):	
	load_highscore_data()
	new_score_added = highscore_data.update(new_data)
	save_highscore_data()

func get_level() -> Level:
	return level

func set_level(new_level):
	level = new_level

func is_fresh_session():
	return fresh_session
	
func unset_fresh_session():
	fresh_session = false
