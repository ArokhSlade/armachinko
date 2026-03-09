extends Node

var highscore_data : HighscoreData
@export var highscore_data_path = "user://highscore_data.tres"	

func load_highscore_list():
	
	highscore_data = load(highscore_data_path)
	if highscore_data == null:
		create_fake_data_1()
	highscore_data.sort()
	$HighscorePopup/Table.update_entries(highscore_data)

func save_highscore_list():
	if highscore_data == null:
		create_fake_data_1()
	ResourceSaver.save(highscore_data, highscore_data_path)
	
func _ready():	
	load_highscore_list()

func create_fake_data_1():
	highscore_data = HighscoreData.new()
	
	var phuc_score = SavedScore.new ()
	var stina_score = SavedScore.new()
	var darian_score = SavedScore.new()
	
	phuc_score.setup(   "Phuc"  , 1, 1000000)
	stina_score.setup(  "Stina" , 2,  999999)
	darian_score.setup( "Darian", 3,  999998)
	
	var highscore_list : Array[SavedScore] = [
		phuc_score, 
		stina_score,
		darian_score
	]
		
	highscore_data.highscore_list = highscore_list

	highscore_data.sort()
	$HighscorePopup/Table.update_entries(highscore_data)

func create_fake_data_2():
	highscore_data = HighscoreData.new()
	
	var that_score = SavedScore.new ()
	var calais_score = SavedScore.new()
	var yona_score = SavedScore.new()
	
	that_score.setup( "Thateus"  , 1, 123)
	calais_score.setup("Calais" , 2,  12)
	yona_score.setup(  "Yona", 3,  1)
	
	var highscore_list : Array[SavedScore] = [
		that_score, 
		calais_score,
		yona_score
	]
		
	highscore_data.highscore_list = highscore_list

	highscore_data.sort()
	$HighscorePopup/Table.update_entries(highscore_data)
