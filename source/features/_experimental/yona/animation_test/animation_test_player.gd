extends RigidBody3D


signal game_is_over

@export_category("Player")

#______________________________________________________

enum DashStyle {
	SET_VELOCITY,
	ADD_VELOCITY
}

@export_group("Dash")
## meters per second
@export var dash_speed : float = 25.0
@export var dash_style : DashStyle = DashStyle.SET_VELOCITY



#______________________________________________________
@export_group("Rotation")

## detached mode, degrees per second
@export var shotgun_rotation_speed = 6.0

var old_rotation_speed : float = 0.0

enum GunMode {
	DETACHED, 
	ATTACHED
}
@export var gun_mode : GunMode :
	set(value):	
		if is_inside_tree(): # NOTE(Gerald): on game start, setters are called before ready, so shotgun is still null
			shotgun.rotation = Vector3.ZERO
			match (value):
				GunMode.DETACHED:
					shotgun.show()
				GunMode.ATTACHED:
					shotgun.hide()
				
		gun_mode = value

enum RotationAccelerationStyle
{	 
	NONE,	## rotate with same speed
	CONSTANT_MIN_ACCELERATION, ## constant acceleration using "min" value
	CONSTANT_MAX_ACCELERATION, ## constant acceleration using "max" value
	FAST_REVERSE, ## if input rotation is opposite to current rotation, give a bonus. the greater the current rotation speed, the greater the bonus.
	FAST_GOES_FASTER, ## give a bonus rotation speed when moving faster, max bonus is given at "threshold"
	FAST_GOES_SLOWER ## give a bonus when moving slowly, the slowest accerlation is given at speed above "threshold"
}

@export var rotation_acceleration_style : RotationAccelerationStyle = RotationAccelerationStyle.CONSTANT_MIN_ACCELERATION
@export var is_rotated_by_environment : bool = false ## the environment cannot add rotation speed to player
@export var release_stops_rotation : bool = false ## relasing the rotation button stops rotation instantly
@export var max_rotation_speed : float = 3600.0
@export var min_rotation_acceleration : float = 15.0
@export var max_rotation_acceleration : float = 90.0
@export var max_acceleration_threshold : float =  360.0


#________working variables___________

@onready var shotgun = $Shotgun
@onready var shotgun_transform = $ShotgunTransform
var is_alive = true



var last_frame_collider_id : int
const COLLIDER_LOCKOUT_FRAMES : int = 5 # the amount of frames before we consider the same collider again
var collider_lockout_count : int = 0

func _ready():	
	#GlobalVariables.Player = self
	pass


func _physics_process(_delta: float) -> void:
	store_last_position()
	store_last_velocity()
	
	match(gun_mode):
		GunMode.DETACHED:			
				shotgun_transform.update_rotation = false
				#shotgun.rotation =- Vector3(0 , 0 , global_rotation.z)
				var direction := Input.get_axis("left", "right")
				direction *= deg_to_rad(shotgun_rotation_speed)
				shotgun.rotation += Vector3(0, 0, direction)

		GunMode.ATTACHED:
			shotgun_transform.update_rotation = true
				# gun is built in to player
				# player rotation happens in _integrate_forces
	
	if is_alive and Input.is_action_just_pressed("shoot"):
		shotgun.shoot()

#TODO: i think there's a way without collision_point
func get_reflected_velocity(incoming_velocity, reflection_normal, collision_point):
	
		# reflect incoming velocity vector from the reflection_normal's plane
		
		# project -(incoming_velocity) onto reflection_normal
		# projection of a onto b means dot_product(a, b.normalized) * b.normalized		
		# assuming we get a normalized normal, we can skip division and normalization
		var projection = (-incoming_velocity).dot(reflection_normal) * reflection_normal
		# add 2 * (projection - (-(incoming))) to (collision_point-incoming)
		var reflected_point = 2 * (projection + incoming_velocity) + (collision_point - incoming_velocity)
		# subtract collision point from reflected position to get reflected velocity
		var reflected_velocity = reflected_point - collision_point
		return reflected_velocity


func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	if is_alive:
	
		#-------------bounce--------------
		var contact_count = get_contact_count()
	
		if contact_count > 0:
			var incoming_velocity = state.get_contact_local_velocity_at_position(0)
			var collision_normal = state.get_contact_local_normal(0)
			var collision_point = state.get_contact_local_position(0)
			var reflected_velocity : Vector3 = get_reflected_velocity(incoming_velocity, collision_normal, collision_point)
			print(state.get_contact_local_normal(0))
			print(state.get_contact_local_velocity_at_position(0))
			print(reflected_velocity)
			
			var collider_id = state.get_contact_collider_id(0)
			
			if last_frame_collider_id != 0:
				if last_frame_collider_id == collider_id:
					collider_lockout_count += 1
					if collider_lockout_count > COLLIDER_LOCKOUT_FRAMES:
						collider_lockout_count = 0
						last_frame_collider_id = 0
						
			if last_frame_collider_id == 0 or last_frame_collider_id != collider_id:			
				var collider = state.get_contact_collider_object(0)
				if collider.has_method("get_bounce_speed_multiplier"):
					#var bonus_velocity =  reflected_velocity.normalized() * collider.get_bounce_bonus_speed()
					#state.linear_velocity += bonus_velocity
					#state.linear_velocity += .4 * reflected_velocity
					var speed_multiplier = collider.get_bounce_speed_multiplier()
					state.linear_velocity = speed_multiplier * reflected_velocity
					last_frame_collider_id = collider_id
	
		#------------- shoot --------------
		if Input.is_action_just_pressed("shoot") and  shotgun.has_ammo():
			var shoot_rotation
			match gun_mode:
				GunMode.DETACHED:
					shoot_rotation = $Shotgun.global_rotation.z
				GunMode.ATTACHED:
					shoot_rotation = global_rotation.z
					
			var shoot_velocity = dash_speed * Vector3.UP.rotated(Vector3(0,0,1), shoot_rotation)
			
			match dash_style:
				DashStyle.SET_VELOCITY:
					state.linear_velocity = shoot_velocity
				DashStyle.ADD_VELOCITY:
					state.linear_velocity += shoot_velocity
			
			print( shotgun.ammo_now)
			
		#-------------rotation--------------
		
		if not is_rotated_by_environment:
				state.angular_velocity.z = old_rotation_speed
		
		if gun_mode == GunMode.ATTACHED:
			var rotation_direction : float = Input.get_axis("left", "right") * -1.0
			var is_reverse_direction = sign(rotation_direction) != sign(state.angular_velocity.z)
			
			var rotation_speed_ratio = clampf(absf(state.angular_velocity.z)/deg_to_rad(max_acceleration_threshold), 0.0, 1.0)
				
			match rotation_acceleration_style:
				RotationAccelerationStyle.NONE:
					state.angular_velocity.z = rotation_direction * deg_to_rad(max_rotation_speed)
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
			
			state.angular_velocity.z = clampf(state.angular_velocity.z, -deg_to_rad(max_rotation_speed), deg_to_rad(max_rotation_speed))
			
			if release_stops_rotation:
				if rotation_direction == 0.0:
					state.angular_velocity.z = 0.0
			
		old_rotation_speed = state.angular_velocity.z	




func die():	
	is_alive = false
	game_is_over.emit()


func take_damage():
	pass


func knockback():
	pass


func muzzle_body_entered(body: Node3D) -> void:
	if body.has_method("die"):
		print("enemy hit")
		body.die()
	else:
		pass

 
func muzzle_area_entered(area: Area3D) -> void:
	if area.find_parent("Enemy") and has_method("die") and !null:
		print("enemy hit") 
		area.find_parent("Enemy").die()
	else:
		pass

func stun():
	is_alive = false
	$StunTimer.start()
	apply_impulse(Vector3(10,randi_range(-30, 30), 0))
func _on_stun_timer_timeout() -> void:
	is_alive = true
#------------------------------------------------------
# "interface contract" with score effect (refer to TDD)

@onready var score_keeper = $Effects/ScoreKeeper
signal forward_score_changed(new_value)

func get_score_keeper():
	return score_keeper
	
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

@onready var animation_player = $AnimationPlayer

func _on_body_entered(body):
	animation_player.play("shock")
