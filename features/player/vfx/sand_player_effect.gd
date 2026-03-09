extends Node3D

@export var player : Node

func despawn():
	get_parent().remove_child.call_deferred(self)
	queue_free()

func _on_animation_player_animation_finished(sand_swirling) -> void:
	despawn()
	
func compute_scale_from_velocity(last_player_velocity):
	var speed = last_player_velocity.length()
	speed = clampf(speed,0.,110.)
	#var eased_speed = ease(speed, 2)
	var new_scale = Vector3(speed / 110 * 5  + 0.5,speed / 110 * 5  + 0.5,speed / 110 * 5  + 0.5)
	return new_scale
		
func _process(_delta):
	var last_player_velocity = player.get_last_velocity()
	var new_scale_value = compute_scale_from_velocity(last_player_velocity)
	$SandDonut.scale = new_scale_value

#func compute_intensity_from_velocity(velocity):
#	var speed = velocity.length()
#	speed = clampf(0.,75.,speed)
#	var new_intensity = speed / 75 * 5 + 1
#	return new_intensity

#func _process(_delta):
	#var last_player_velocity = player.get_last_velocity()
	#var new_intensity_value = compute_intensity_from_velocity(last_player_velocity)
	#$SandDonut.material_override.set_shader_parameter("shader_parameter/Shape_Distortion_Intensity",new_intensity_value)
