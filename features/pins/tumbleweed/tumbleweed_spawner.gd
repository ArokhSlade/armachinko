@tool
extends Marker3D

signal spawned(tumbleweed)

@export var tumbleweed_scene : PackedScene
@export var tumbleweed_despawn_time = 10
@export var angle_range : float ##degrees
@export var min_speed : float #meter per second
@export var max_speed : float #meter per second
@export var min_delay : float #seconds
@export var max_delay : float #seconds

var rad_half_angle


func _process(_delta):
	rad_half_angle = deg_to_rad(angle_range)*.5
	var up = Vector3.UP
	var rot_axis = transform.basis.z
	var speed_scale = .25
	var dist = max_speed * speed_scale
	$MarkerMid.position = up * dist
	var right_handle = up.rotated(rot_axis, -rad_half_angle) * dist
	var left_handle = up.rotated(rot_axis, +rad_half_angle) * dist
	$MarkerRightMax.position = right_handle
	$MarkerLeftMax.position = left_handle
	
	dist = min_speed * speed_scale
	right_handle = up.rotated(rot_axis, -rad_half_angle) * dist
	left_handle = up.rotated(rot_axis, +rad_half_angle) * dist
	$MarkerRightMin.position = right_handle
	$MarkerLeftMin.position = left_handle

func spawn():
	rad_half_angle = deg_to_rad(angle_range)*.5
	var tumbleweed = tumbleweed_scene.instantiate() as RigidBody3D
	var tumble_parent = Globals.get_level().get_new_parent_for_spawned_object(self, tumbleweed)
	tumble_parent.add_child(tumbleweed)
	tumbleweed.set_despawn_timer(tumbleweed_despawn_time)
	tumbleweed.global_position = global_position
	tumbleweed.global_rotation = global_rotation
	var angle_variation = randf_range(-rad_half_angle, rad_half_angle)
	tumbleweed.rotate(tumbleweed.transform.basis.z, angle_variation)
	var speed = randf_range(min_speed, max_speed)	
	tumbleweed.linear_velocity = tumbleweed.transform.basis.y.normalized() * speed
	spawned.emit(tumbleweed)
	reset_timer()
	$AudioStreamPlayer3D.play()

func reset_timer():
		var new_timer = randf_range(min_delay, max_delay)
		$SpawnTimer.start(new_timer)
