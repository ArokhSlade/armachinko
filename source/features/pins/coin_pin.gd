extends GenericPin

@onready var idle_animation_length = $AnimationPlayer.get_animation("coin_rotation").length
@onready var collect_animation_length = $AnimationPlayer.get_animation("coin_collect").length
var last_rotation_time = 0.0

func on_bounced(by_who):
	super(by_who)
	collect(by_who)
	
func on_exploded(by_who):
	super(by_who)
	collect(blast_initiator)

func collect(by_who):
	$ScoreDonor.donate_score(by_who)
	$AudioStreamPlayer3D.play()
	last_rotation_time = $AnimationPlayer.current_animation_position
	$AnimationPlayer.play("coin_collect")
	await $AnimationPlayer.animation_finished
	despawn()

func despawn():
	super()
	$RespawnTimer.start()

func respawn():
	super()
	$AnimationPlayer.play("coin_rotation")
	var current_idle_timing = last_rotation_time + collect_animation_length + $RespawnTimer.wait_time
	current_idle_timing = fmod(current_idle_timing, idle_animation_length)
	$AnimationPlayer.seek(current_idle_timing, true, true)
	
func _on_respawn_timer_timeout():
	respawn()
