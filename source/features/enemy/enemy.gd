extends PathFollow3D
@export var speed := 1 #meters per second
@export var attack_stun_duration = 1.0
@export var attack_revolutions_per_second = 5.0 ## full rotations per second

signal despawned
signal respawned
signal blasted_by(blast_initiator)
signal bounced_by(bouncer)
signal bounced
signal blasted

signal attacked
signal died
signal heading_changed

enum EnemyState {
	WALKING, 
	TRANSITIONING,
	STANCING,
	ATTACKING,
	DYING,
	DEAD
}

var state : EnemyState

var blast_initiator

var last_position : Vector3

enum Heading {
	RIGHT,
	LEFT
}
var heading : Heading


func _ready():
	update_heading()
	rotation_mode = PathFollow3D.ROTATION_NONE	
	walk()
	

func walk():
	state = EnemyState.WALKING	
	$AnimatedSprite3D.play("walk" + get_heading_suffix())

func _process(_delta):
	update_heading()
	
	
func _physics_process(delta: float) -> void:	
	
	scan_for_shotgun_hits()
	
	match state:
		EnemyState.WALKING:
			progress += speed * delta

func scan_for_shotgun_hits():
	if not is_alive():
		return
	
	for area in $HitArea.get_overlapping_areas():
		if area.has_method("get_blast_initiator"):
			blast_initiator = area.get_blast_initiator()
			match state:
				EnemyState.WALKING, EnemyState.ATTACKING, EnemyState.TRANSITIONING, EnemyState.STANCING:
					$ScoreDonor.donate_score(blast_initiator)
					die(area.global_position)
					blasted.emit()
					blasted_by.emit(blast_initiator)

func is_alive():
	match state:
		EnemyState.DYING, EnemyState.DEAD:
			return false
	return true
		

func _on_alert_area_body_entered(_body):
	match state:
		EnemyState.WALKING:
			$AlertSound.play()
			transition()
		EnemyState.DYING, EnemyState.STANCING, EnemyState.ATTACKING:
			pass
		_:
			assert(false, "unexpected state on alert area entered")

func _on_alert_area_body_exited(_body):
	match state:
		EnemyState.DYING, EnemyState.DEAD:
			return
		EnemyState.STANCING, EnemyState.TRANSITIONING:
			$CalmDownTimer.start()
			stance()
		EnemyState.ATTACKING:
			pass
		EnemyState.WALKING:
			$CalmDownTimer.start()
			stance()
		_:
			assert(false, "unexpected enemy state on alert area exited")

func _on_hit_area_body_entered(body):
	$HitSound.play()	
	
	match state:
		EnemyState.TRANSITIONING:
			attack(body)
		EnemyState.STANCING:
			attack(body)
		EnemyState.WALKING:
			attack(body)
	
	bounced_by.emit(body)
	bounced.emit()
	
#TODO(Gerald): why does this exist?	
func _on_hit_area_area_entered(_area):
	#if area.has_method("get_blast_initiator"):
		#blast_initiator = area.get_blast_initiator()
	#
	#
		#match state:
			#EnemyState.WALKING, EnemyState.ATTACKING, EnemyState.TRANSITIONING, EnemyState.STANCING:
				#die(area.global_position)
				#
	#
	#blasted_by.emit(blast_initiator)
	#blasted.emit()
	pass


func _on_animated_sprite_3d_animation_finished():
	match state:
		EnemyState.DYING:
			despawn()
		EnemyState.ATTACKING:
			stance()
		EnemyState.TRANSITIONING:
			stance()
		_:
			assert(false, "animation finished with uncaught state")


func _on_calm_down_timer_timeout():
	match state:
		EnemyState.DYING, EnemyState.DEAD:
			return
		_:
			walk()

func transition():
	state = EnemyState.TRANSITIONING
	$AnimatedSprite3D.play("stance_transition"+get_heading_suffix())

func stance():
	state = EnemyState.STANCING
	$AnimatedSprite3D.play("stance"+get_heading_suffix())
	

func attack(target : RigidBody3D):	
		state = EnemyState.ATTACKING
		
		if target.has_method("stun"):
			target.stun(attack_stun_duration)
		if target.has_method("request_set_revolutions_per_second"):
			target.request_set_revolutions_per_second(attack_revolutions_per_second)
			

		$AnimatedSprite3D.play("attack" + get_heading_suffix())
		attacked.emit()
	
func die(blast_position):
	state = EnemyState.DYING
	if blast_position.y <= global_position.y:
		$AnimatedSprite3D.play("die_front"+get_heading_suffix())
	else:
		$AnimatedSprite3D.play("die_behind"+get_heading_suffix())
		
	died.emit()




func despawn():
	disable_interaction()
	hide()
	state = EnemyState.DEAD
	despawned.emit()

func respawn():
	progress_ratio = 0 	
	enable_interaction()
	show()
	walk()
	respawned.emit()


func disable_interaction():
	$HitArea/CollisionShape3D.call_deferred("set_disabled", true)
	$AlertArea/CollisionShape3D.call_deferred("set_disabled", true)

func enable_interaction():
	$HitArea/CollisionShape3D.call_deferred("set_disabled", false)
	$AlertArea/CollisionShape3D.call_deferred("set_disabled", false)


func update_heading():
	var old_heading = heading	
	
	if global_position.x > last_position.x:
		heading = Heading.RIGHT
	elif global_position.x < last_position.x:
		heading = Heading.LEFT
	
	last_position = global_position
	
	if old_heading != heading:
		heading_changed.emit()

func get_heading_suffix():	
	match heading:
		Heading.RIGHT:
			return "_r"
		Heading.LEFT: 
			return "_l"
		_:
			push_error("unexpected heading")
			return "_r"


func _on_heading_changed():
	match state:
		EnemyState.WALKING:
			walk()
		
