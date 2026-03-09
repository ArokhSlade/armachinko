extends Node3D

@export var object_to_reset : RigidBody3D
@onready var motion_target = $MotionTarget
@export var ignore_gravity_scale = false

var object_start_position : Vector3
var original_gravity_scale

func launch_object():
	var object_to_reset_parent = object_to_reset.get_parent()
	object_to_reset_parent.remove_child(object_to_reset)
	
	object_to_reset_parent.add_child(object_to_reset)
	if ignore_gravity_scale:
		object_to_reset.gravity_scale = 0.0
	else:
		object_to_reset.gravity_scale = original_gravity_scale
		
	object_to_reset.global_rotation = Vector3.ZERO
	object_to_reset.global_position = object_start_position
	object_to_reset.linear_velocity = (motion_target.global_position - object_to_reset.global_position)
	

func _ready():
	object_start_position = object_to_reset.global_position
	original_gravity_scale = object_to_reset.gravity_scale
	call_deferred("launch_object")


func _on_reset_timer_timeout():	
	launch_object()
