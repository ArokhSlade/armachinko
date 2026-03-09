class_name SavedScore
extends Resource


@export var name : String
@export var rank : int
@export var score : int


static func is_greater_or_equal(first : SavedScore, second : SavedScore):
	if first == null:
		return false
	if second == null:
		return true
	return first.score >= second.score

func setup(new_name, new_score = 0, new_rank = 0):
	name = new_name
	rank = new_rank
	score = new_score
