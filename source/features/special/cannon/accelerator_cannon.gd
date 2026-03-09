extends AnimatableBody3D



@export var disable_rotation = false
@export var shoot_speed = 150.0 # meters per second
@export var rotation_speed = 90.0 ## degrees per second
@export var spread_angle = 60.0 ## degrees

var player_inside 
var blocked = false

@onready var default_angle = rotation.z
var max_angle
var min_angle

var going_up = true
var swivel_count = 0

func _ready():
	max_angle = default_angle + deg_to_rad(spread_angle*.5)
	min_angle = default_angle - deg_to_rad(spread_angle*.5)

func swivel(delta):
	swivel_count += 1
	var new_angle = rotation.z
	if swivel_count > 2:
		return
	if going_up:
		if new_angle < max_angle:
			new_angle += deg_to_rad(rotation_speed) * delta
		else:
			going_up = false
			swivel(delta)
	else:
		if new_angle > min_angle:
			new_angle -= deg_to_rad(rotation_speed) * delta
		else:
			going_up = true
		
	#new_angle = clampf(new_angle, min_angle, max_angle)
	rotation.z = new_angle
	
	
func _physics_process(delta: float) -> void:
	if not player_inside: 
		return
	
	swivel_count = 0
	if disable_rotation == false: 
		swivel(delta)

	if Input.is_action_pressed("shoot"):
		$cannon/AnimationPlayer.play("fire")
		$cannon/CannonVfx/AnimationPlayer.play("Cannon_Muzzle")
		$AudioStreamPlayer3D.play()
		player_inside.global_rotation = global_rotation
		player_inside.global_position = $PlayerShootPosition.global_position
		player_inside.show()
		player_inside.process_mode = Node.PROCESS_MODE_INHERIT
		var shoot_direction = Vector3.UP.rotated(Vector3.BACK, global_rotation.z)
		player_inside.linear_velocity = shoot_speed * shoot_direction
		player_inside = null

func _on_body_entered(body: Node3D) -> void:
	if not body.is_in_group("Players"):
		return
	if blocked:
		return
	
	body.process_mode = Node.PROCESS_MODE_DISABLED
	body.hide()
	body.global_position = global_position
	player_inside = body
	$cannon/AnimationPlayer.play("get_ready")
	$BlockedTimer.start()
	blocked = true



func _on_blocked_timer_timeout() -> void:
	blocked = false
