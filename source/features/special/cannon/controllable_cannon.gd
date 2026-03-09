extends AnimatableBody3D




@export var shoot_speed = 100.0 ## meters per second
@export var rotation_speed = 360.0 ## degrees per second
@export var angle_range = 90.0 ## degrees per second


var player_inside 
var blocked = false

var can_shoot = true
var can_rotate = true

@onready var default_angle = rotation.z
var min_angle
var max_angle

func update_angle_range():	
	max_angle = default_angle + deg_to_rad(angle_range/2.0)
	min_angle = default_angle - deg_to_rad(angle_range/2.0)

func _ready():
	#$cannon/AnimationPlayer.play("fire")
	#$cannon/CannonVfx/AnimationPlayer.play("Cannon_Muzzle")
	update_angle_range()

func _physics_process(delta: float) -> void:
	if not player_inside: 
		return
	
	#if can_rotate:
	var rotation_request = Input.get_axis("left", "right")
	if rotation_request != 0.0:
		var new_angle = rotation.z
		new_angle += deg_to_rad(rotation_speed) * delta * rotation_request
		new_angle = clampf(new_angle, min_angle, max_angle)
		rotate(Vector3.FORWARD, deg_to_rad(rotation_speed) * delta * rotation_request)
		print(rotation.z)

	if Input.is_action_pressed("shoot") and can_shoot: 
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



func disable_shoot():
	can_shoot = false
	
func enable_shoot():
	can_shoot = true
	
func disable_rotate():
	can_rotate = false
	
func enable_rotate():
	can_rotate = true
