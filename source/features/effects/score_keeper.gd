extends Node3D

signal score_updated(new_value)
var current_score = 0

var multiplier = 1

func modify_score(value_change):
	current_score += value_change * multiplier
	score_updated.emit(current_score)

func get_multiplier():
	return multiplier
	
func increment_multiplier():
	multiplier += 1
