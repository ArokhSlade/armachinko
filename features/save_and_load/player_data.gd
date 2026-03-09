extends Node

@export var data : SavedScore

var last_player_data_path = "user://last_player_data.tres"
var first_time_playing = false

func setup():	
	if last_player_exists():
		load_last_player()
		first_time_playing = false
	else:
		first_time_playing = true
		create_new_player()

func last_player_exists():
	return ResourceLoader.exists(last_player_data_path)

func load_last_player():
	data = ResourceLoader.load(last_player_data_path)

func create_new_player():
	data = SavedScore.new()
	
func update_player(_name, score=0, rank=0):
	data.setup(_name, score, rank)
	
func save_player():
	ResourceSaver.save(data, last_player_data_path)
	
func is_valid():
	return data.name && data.name != ""
