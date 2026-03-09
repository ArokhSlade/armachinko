class_name HighscoreData
extends Resource

@export var highscore_list : Array[SavedScore]
@export var max_size = 100

func player_with_score_exists(name, score):
	for entry in highscore_list:
		if entry.name == name and entry.score == score:
			return true
	return false

func update(new_score : SavedScore) -> bool:
	var new_score_added = false
	var score_copy = SavedScore.new()
	score_copy.setup(new_score.name, new_score.score, new_score.rank)
	if not player_with_score_exists(new_score.name, new_score.score):		
		highscore_list.append(score_copy)
		new_score_added = true
	sort()
	assing_ranks()
	update_size_of_sorted_list()
	return new_score_added

func sort():
	highscore_list.sort_custom(SavedScore.is_greater_or_equal)

func assing_ranks():
	var rank = 1
	for entry in highscore_list:
		entry.rank = rank
		rank += 1

func _init():
	highscore_list = []


# only works on sorted list
func update_size_of_sorted_list():
	var valid_elements_count = 0
	for i in highscore_list.size():
		if highscore_list[i] == null:			
			break
		else:
			valid_elements_count += 1	
	var new_size = mini(valid_elements_count, max_size)
	highscore_list.resize(new_size)

func get_highscore_for_player(player_name):
	var highscore = 0
	for entry in highscore_list:
		if entry.name == player_name:
			if entry.score > highscore:
				highscore = entry.score				
	return highscore
