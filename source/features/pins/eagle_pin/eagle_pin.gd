extends AnimatablePin
class_name EaglePin

@export var max_health = 6
@export var chipped_health = 4
@export var cracked_health = 2

var health_now = max_health

@export var despawn_delay = 1.4333
@export var respawn_time = 60.0

enum EagleState {
	IDLE,
	DYING
}

var state = EagleState.IDLE
@onready var current_model = $EagleSkullNormal

func on_bounced(body):
	super(body)
	if body.is_in_group("Players"):
		take_damage_from(1, body)
	if body.has_method("freeze_frame"):
		body.freeze_frame()

func take_damage_from(damage, body):
	modify_health(-damage)
	var transitioned = false
	
	match health_now:
		chipped_health:
			current_model.hide()
			current_model = $EagleSkullChipped
			current_model.show()
			transitioned = true
			
		cracked_health:
			current_model.hide()
			current_model = $EagleSkullCracked
			current_model.show()
			transitioned = true
			
	if transitioned:
		current_model.play_transition()
	else:
		play_scream_animation()
		
	if health_now > 0:
		$BossHitSound.play()
	else:
		die_from(body)
		play_death_animation()


func die_from(body):
	disable_interaction()
	$BossDeadSound.play()
	$ScoreDonor.donate_score(body)
	state = EagleState.DYING
	$DespawnDelayTimer.start(despawn_delay)


func _on_despawn_delay_timer_timeout():
	match state:
		EagleState.DYING:
			despawn()
			$RespawnTimer.start(respawn_time)

func respawn():
	super()
	health_now = max_health
	state = EagleState.IDLE
	
func modify_health(amount):
	health_now = clampi(health_now + amount, 0, max_health)


func disable_collision():
	super()
	$CollisionPolygon3D.set_disabled.call_deferred(true)
	
func enable_collision():
	super()
	$CollisionPolygon3D.set_disabled.call_deferred(false)


func play_scream_animation():
	if current_model.has_method("play_scream"):	
		current_model.play_scream()
	

func play_death_animation():
	if current_model.has_method("play_death"):
		current_model.play_death()
