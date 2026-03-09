@tool 
extends Camera3D

@export var max_y_pos : Node3D 
@export var min_y_pos : Node3D
@export var focus : Node3D
@export var centered_mode : bool = false
@onready var max_y = max_y_pos.global_position.y if max_y_pos else 0.0
@onready var min_y = min_y_pos.global_position.y if min_y_pos else 0.0

func _process(_delta):
	if not focus:
		return
		
	var both_limits_set = max_y_pos and min_y_pos
	
	if centered_mode or not (both_limits_set):
		global_position.y = focus.global_position.y
		global_position.x = focus.global_position.x		
	else:
		max_y = max_y_pos.global_position.y
		min_y = min_y_pos.global_position.y	
		global_position.y = clampf(focus.global_position.y,min_y, max_y)
		
		
