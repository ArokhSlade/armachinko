extends MenuTab


@export var highscore_data_path = "user://highscore_data.tres" 
var highscore_data : HighscoreData
@export var list_length = 3

@onready var highscore_table = $ScrollContainer/HighscoreList
@export var scroll_speed = 1. ## pixels per second

enum ScrollState {
	NONE,
	DOWN,
	UP
}



var state = ScrollState.NONE
var current_scroll = 0.0

func activate():
	highlight_new_entry()
	$HighscoreCloseButton.grab_focus.call_deferred()
	update()
	super()
	
func deactivate():
	super()
	clear_new_entry_notification()
	
func clear_new_entry_notification():
	Globals.new_score_added = false

func update():
	load_highscore_data()
	update_player_highscore()
	
	highscore_data.max_size = list_length
	highscore_table.populate_entries(highscore_data, list_length)
	save_highscore_data()

func update_player_highscore():
	var player_name = PlayerData.data.name
	var player_highscore = highscore_data.get_highscore_for_player(player_name)
	
	$PlayerName.text = player_name + "'s"
	$PlayerScore.text = str(player_highscore)
	UIHelperFunctions.scale_text($PlayerName)
	UIHelperFunctions.scale_text($PlayerScore)

func load_highscore_data():
	if ResourceLoader.exists(highscore_data_path):
		highscore_data = load(highscore_data_path)
	if highscore_data == null:
		highscore_data = HighscoreData.new()
		

func save_highscore_data():
	ResourceSaver.save(highscore_data, highscore_data_path)

func _process(delta):
	match state:
		ScrollState.DOWN:
			scroll_by(scroll_speed * delta)
		ScrollState.UP:
			scroll_by(-1 * scroll_speed * delta)

func start_scrolling_down():
	state = ScrollState.DOWN

func start_scrolling_up():
	state = ScrollState.UP

func stop_scrolling():
	state = ScrollState.NONE

func scroll_by(scroll_step):
	current_scroll += scroll_step
	$ScrollContainer.scroll_vertical = current_scroll

func highlight_new_entry():
	#var lit_entry = find_entry(PlayerData.data)
	pass
	
#func find_entry
