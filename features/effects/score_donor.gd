extends Effect

@export var score_bonus = 100
@export var score_popup_scene : PackedScene

var score_popup

func donate_score(body):
	if body.has_method("get_score_keeper"):
		var score_keeper = body.get_score_keeper()
		score_keeper.modify_score(score_bonus)
		var multiplier = score_keeper.get_multiplier()
		spawn_score_popup(multiplier)

func spawn_score_popup(multiplier):
	score_popup = score_popup_scene.instantiate()	
	var score_value = score_bonus * multiplier
	score_popup.set_score_value(score_value)
	
	var scale_factor = calculate_scale_factor(score_value)
	score_popup.set_scale_factor(scale_factor)
	var level = Globals.get_level()
	var new_parent = level.get_new_parent_for_spawned_object(self, score_popup)
	new_parent.add_child(score_popup)
	score_popup.global_position = global_position	
	print(global_position)
	print(score_popup.global_position)


func calculate_scale_factor(score_value) -> float:
	var scale_factor
	if score_value >= 10000:
		scale_factor = 2
	elif score_value >= 2000: 
		scale_factor = 0.8
	elif score_value >= 1000:
		scale_factor = 0.6
	elif score_value >= 500:
		scale_factor = 0.5
	elif score_value >= 250:
		scale_factor = 0.3
	else:
		scale_factor = 1
	return scale_factor
