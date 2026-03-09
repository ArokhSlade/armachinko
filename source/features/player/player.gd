extends RigidBody3D

signal bonus_time_received(amount)

signal died
@export_category("Player")
@export_range(0,1,0.01) var bounce_when_stunned := 1.0
var old_bounce
#______________________________________________________

enum DashStyle {
	SET_VELOCITY,
	ADD_VELOCITY,
	ADD_WITH_MIN
}

@export_group("Dash")
## meters per second
@export var dash_speed : float = 75.0
@export var dash_style : DashStyle = DashStyle.ADD_WITH_MIN


#______________________________________________________
@export_group("Rotation")

## detached mode, degrees per second
@export var shotgun_rotation_speed = 360

var old_rotation_speed : float = 0.0

@onready var arm_default_rotation = $ArmadilloPivot/Armadillo/Arm.rotation

@export var arm_detached = false : 
	set(detach_requested):
		arm_detached = detach_requested
		if is_inside_tree() and not arm_detached:
			$ArmadilloPivot/Armadillo/Arm.rotation = arm_default_rotation
		#NOTE: this doesn't work at the beginning of the game,
		#      the RemoteRotation node's rotation has to be manually 
		#	   set to tmatch the arm's default rotation

enum RotationAccelerationStyle
{	 
	NONE,	## rotate with same speed
	CONSTANT_MIN_ACCELERATION, ## constant acceleration using "min" value
	CONSTANT_MAX_ACCELERATION, ## constant acceleration using "max" value
	FAST_REVERSE, ## if input rotation is opposite to current rotation, give a bonus. the greater the current rotation speed, the greater the bonus.
	FAST_GOES_FASTER, ## give a bonus rotation speed when moving faster, max bonus is given at "threshold"
	FAST_GOES_SLOWER ## give a bonus when moving slowly, the slowest accerlation is given at speed above "threshold"
}

@export var rotation_acceleration_style : RotationAccelerationStyle = RotationAccelerationStyle.NONE
@export var is_rotated_by_environment : bool = true ## the environment cannot add rotation speed to player
@export var release_stops_rotation : bool = false ## relasing the rotation button stops rotation instantly
@export var max_rotation_speed : float = 360.0
@export var min_rotation_acceleration : float = 30.0
@export var max_rotation_acceleration : float = 90.0
@export var max_acceleration_threshold : float =  360.0



@export_group("Gravity & Speed")
@export var speed_threshold = 75.0
@export var gravity_speed_scaling : Curve
@export var gravity_direction_scaling : Curve


@export_group("Freeze Frame")
@export var freeze_frame_duration : float = 0.16666
@export_range(0.0,0.25) var freeze_frame_time_scale : float = 0.01
#________working variables___________

enum PlayerState{
	NORMAL,
	STUNNED,
	DEAD
}

var player_state = PlayerState.NORMAL

@onready var shotgun_ = $ArmadilloPivot/Armadillo/Arm/Shotgun

var last_frame_collider_id : int
const COLLIDER_LOCKOUT_FRAMES : int = 5 # the amount of frames before we consider the same collider again
var collider_lockout_count : int = 0

var requested_revolutions_pending = false
var requested_revolutions_per_second = 0.0 ## from enemy stun, used in integrate forces
@onready var default_angular_damp = angular_damp

func _ready() -> void:
	if $ArmadilloPivot/Armadillo/Arm/Shotgun.has_method("get_animationplayer_from_player"):
		$ArmadilloPivot/Armadillo/Arm/Shotgun.get_animationplayer_from_player($AnimationPlayer, $AnimationPlayer2)
	arm_detached = arm_detached ## trigger setter on tree_entered
	
func _physics_process(delta: float) -> void:
	$ArmadilloPivot/Armadillo.rotation = rotation
	
	store_last_position()
	store_last_velocity()
	
	if arm_detached:
		var angle := Input.get_axis("left", "right")
		if angle != 0.0:
			angle *= -1 * deg_to_rad(shotgun_rotation_speed) * delta
			$RemoteRotation.global_rotation += Vector3(0, 0, angle)
		$ArmadilloPivot/Armadillo/Arm.global_rotation = $RemoteRotation.global_rotation		

	if player_state == PlayerState.NORMAL and Input.is_action_just_pressed("shoot"):
		shotgun_.shoot()
	
func _integrate_forces(physics_state: PhysicsDirectBodyState3D) -> void:
	match player_state:
		PlayerState.NORMAL:
			dash_on_input(physics_state)
			rotate_on_input(physics_state)
			
			adjust_gravity_scale(physics_state)
			raycast_and_spawn_impact_vfx(physics_state)	
		PlayerState.STUNNED:
			if requested_revolutions_pending:
				physics_state.angular_velocity = Vector3.FORWARD * requested_revolutions_per_second * PI * 2
				requested_revolutions_pending = false
				requested_revolutions_per_second = 0.0
				pass
				
func _process(delta):
	$ArmadilloPivot/SpeedAura.update_from_velocity(linear_velocity)

var current_speed
func adjust_gravity_scale(physics_state):
	var speed = physics_state.linear_velocity.length()
	current_speed = speed
	var velocity_2d = Vector2(physics_state.linear_velocity.x, physics_state.linear_velocity.y)
	var angle = Vector2.RIGHT.angle_to(velocity_2d)
	angle = rad_to_deg(angle)
	var normalized_angle = normalize_angle(angle)
	var direction = normalized_angle / 90.	
	var gravity_scale_from_speed = get_gravity_scale_from_speed(speed)
	var gravity_scale_from_direction = get_gravity_scale_from_direction(direction)
	gravity_scale = gravity_scale_from_speed + gravity_scale_from_direction
	$PlayerDebugHUD.update_values(gravity_scale, gravity_scale_from_speed, gravity_scale_from_direction, speed, speed_threshold, angle, direction)

##map to a equivalent value between -90 and 90 degrees 
func normalize_angle(degrees):
	degrees = fmod(degrees, 360.)
	var flip_result = false
	if degrees < -90.:
		degrees *= -1.
		flip_result = true
		
	if degrees > 270.0:
		degrees = 360. - degrees
	elif degrees > 180.:
		degrees -= 180.
		flip_result = true
	elif degrees > 90.0:
		degrees = 180.0 - degrees
		
	if flip_result: 
		degrees = -degrees
		
	return degrees
	
func get_gravity_scale_from_speed(speed):
	speed_threshold = dash_speed
	var speed_capped = clampf(speed, 0.0, speed_threshold)
	var sample_point = inverse_lerp(0.0, speed_threshold, speed_capped)
	var gravity_scale = gravity_speed_scaling.sample(sample_point)
	return gravity_scale


func get_gravity_scale_from_direction(direction):
	var sample_point = inverse_lerp(-1.0, 1.0, direction)
	var gravity_scale = gravity_direction_scaling.sample(sample_point)
	return gravity_scale


func dash_on_input(state : PhysicsDirectBodyState3D):
	if Input.is_action_just_pressed("shoot") and shotgun_.has_ammo():
		var shotgun_angle = shotgun_.global_rotation.z
		var dash_velocity = dash_speed * Vector3.UP.rotated(Vector3(0,0,1), shotgun_angle)
		
		match dash_style:
			DashStyle.ADD_WITH_MIN:
				var target_velocity = state.linear_velocity + dash_velocity
				var target_speed = target_velocity.length()
				if target_speed < dash_speed:
					target_velocity = dash_velocity
				state.linear_velocity = target_velocity
			DashStyle.SET_VELOCITY:
				state.linear_velocity = dash_velocity
			DashStyle.ADD_VELOCITY:
				state.linear_velocity += dash_velocity

func rotate_on_input(state : PhysicsDirectBodyState3D):
	if not is_rotated_by_environment:
		state.angular_velocity.z = old_rotation_speed
		
	if not arm_detached:
		var rotation_direction : float = Input.get_axis("left", "right") * -1.0
		var is_reverse_direction = sign(rotation_direction) != sign(state.angular_velocity.z)
		
		var rotation_speed_ratio = clampf(absf(state.angular_velocity.z)/deg_to_rad(max_acceleration_threshold), 0.0, 1.0)
			
		match rotation_acceleration_style:
			RotationAccelerationStyle.NONE:					
				if rotation_direction != 0.0:
					state.angular_velocity.z = 0.0
					state.transform = state.transform.rotated_local(-Vector3.FORWARD, deg_to_rad(max_rotation_speed) * get_physics_process_delta_time() * rotation_direction)
					
			RotationAccelerationStyle.CONSTANT_MIN_ACCELERATION:
				state.angular_velocity.z += rotation_direction * deg_to_rad(min_rotation_acceleration)
			RotationAccelerationStyle.CONSTANT_MAX_ACCELERATION:
				state.angular_velocity.z += rotation_direction * deg_to_rad(max_rotation_acceleration)
			RotationAccelerationStyle.FAST_REVERSE:
				if is_reverse_direction:
					state.angular_velocity.z += rotation_direction * deg_to_rad(lerpf(min_rotation_acceleration, max_rotation_acceleration,rotation_speed_ratio))
				else:		
					state.angular_velocity.z += rotation_direction * deg_to_rad(min_rotation_acceleration)
			RotationAccelerationStyle.FAST_GOES_FASTER:
				state.angular_velocity.z += rotation_direction * deg_to_rad(lerpf(min_rotation_acceleration, max_rotation_acceleration,rotation_speed_ratio))
			RotationAccelerationStyle.FAST_GOES_SLOWER:
				state.angular_velocity.z += rotation_direction * (deg_to_rad(lerpf(min_rotation_acceleration, max_rotation_acceleration,1.0-rotation_speed_ratio)))
			_:
				push_error("UNEXPECTED ROTATION STYLE")
		
		#state.angular_velocity.z = clampf(state.angular_velocity.z, -deg_to_rad(max_rotation_speed), deg_to_rad(max_rotation_speed))
		
		if release_stops_rotation:
			if rotation_direction == 0.0:
				state.angular_velocity.z = 0.0
	
	old_rotation_speed = state.angular_velocity.z

func raycast_and_spawn_impact_vfx(state : PhysicsDirectBodyState3D):
	$RayCast3D.global_position = global_position
	$RayCast3D.target_position = state.linear_velocity*get_physics_process_delta_time()
	$RayCast3D.target_position += $CollisionShape3D.shape.radius * state.linear_velocity.normalized()
	
	$RayCast3D.force_raycast_update()
	if $RayCast3D.is_colliding():
		print("ray hit : ", $RayCast3D.get_collider().name)
		var ray_normal = $RayCast3D.get_collision_normal()
		var ray_location = $RayCast3D.get_collision_point()
		var ray_vector = $RayCast3D.target_position
		var ray_axis =  ray_vector.cross(ray_normal).normalized()
		var ray_angle = Vector3.UP.angle_to(ray_normal)
		
		var xform = Transform3D()
		xform.basis.y = ray_normal
		xform.basis.x = -xform.basis.z.cross(xform.basis.y)
		xform = xform.orthonormalized()
		xform.origin = ray_location				
		$ImpactVFXSpawner.spawn_with_transform(xform)
		
		if $RayCast3D.get_collider().is_in_group("Eagle"):
			$EagleVFXSpawner.spawn_with_transform(xform)



func die():	
	player_state = PlayerState.DEAD
	died.emit()



func stun(stun_duration):
	$ArmadilloPivot/SpeedAura/SpeedAuraTip.global_position = global_position
	var ray_location = global_position
	var ray_normal = Vector3(1,1,1)
	var ray_vector = Vector3(0,-1,0)
	var ray_axis =  ray_vector.cross(ray_normal).normalized()
	var ray_angle = Vector3.UP.angle_to(ray_normal)
	
	var xform = Transform3D()
	xform.basis.y = ray_normal
	xform.basis.x = -xform.basis.z.cross(xform.basis.y)
	xform = xform.orthonormalized()
	xform.origin = ray_location
	$AlligatorVFXSpawner.spawn_with_transform(xform)
	
	var impulse_array = [-100,-80,80,100]
	var rand_impulse = impulse_array.pick_random()
	old_bounce = physics_material_override.bounce
	player_state = PlayerState.STUNNED
	$StunTimer.start(stun_duration)
	apply_impulse(Vector3(rand_impulse, 0,randi_range(-30, 30)))
	
	angular_damp_mode = DAMP_MODE_REPLACE
	var end_velocity_ratio = 0.1
	var damp_frames = stun_duration / get_physics_process_delta_time()
	var temp_damp = pow(end_velocity_ratio, 1/damp_frames)
	angular_damp = temp_damp
	
	$AnimationPlayer.play("stun")
	physics_material_override.bounce = bounce_when_stunned
	print(physics_material_override.bounce)


func request_set_revolutions_per_second(revs_per_second):
	requested_revolutions_pending = true
	requested_revolutions_per_second = revs_per_second



func _on_stun_timer_timeout() -> void:
	physics_material_override.bounce = old_bounce
	player_state = PlayerState.NORMAL
	$AnimationPlayer.play("RESET")	
	reset_damp()
#------------------------------------------------------
# "interface contract" with score effect (refer to TDD)

@onready var score_keeper = $Effects/ScoreKeeper
signal forward_score_changed(new_value)

func get_score_keeper():
	return  $Effects/ScoreKeeper
	
func _on_score_keeper_score_updated(new_value):
	forward_score_changed.emit(new_value)

#-----------------------------------------------------
#helper function for bumper.effects.bounce_boost
func get_radius():
	return $CollisionShape3D.shape.radius

@onready var last_position = global_position
@onready var current_position = global_position
func store_last_position():
	last_position = current_position
	current_position = global_position
	
func get_last_position():
	return last_position

@onready var last_velocity = linear_velocity
@onready var current_velocity = linear_velocity
func store_last_velocity():
	last_velocity = current_velocity
	current_velocity = linear_velocity
	
func get_last_velocity():
	return last_velocity


func _on_body_entered(body):
	if body.get_parent().is_in_group("Blockout") or body.is_in_group("Blockout"):
		if current_speed > 20:
			$FenceBounceSound.play()
	$AnimationPlayer2.play("bounce")


func receive_time_bonus(p_amount):
	bonus_time_received.emit(p_amount)


func freeze_frame():
	if freeze_frame_time_scale == 0.0:
		get_tree().paused = true
	else:
		Engine.time_scale = freeze_frame_time_scale
		
	var freeze_timer = get_tree().create_timer(freeze_frame_duration, true, false, true)
	await(freeze_timer.timeout)
	
	if freeze_frame_time_scale == 0.0:
		get_tree().paused = false
	else:
		Engine.time_scale = 1.0


func reset_damp():
	angular_damp_mode = DAMP_MODE_COMBINE
	angular_damp = default_angular_damp
