extends GenericPin
class_name CoinBarrelPin

func despawn():
	super()
	$RespawnTimer.start()


func on_exploded(area):
	super(area)
	trigger_barrel_action(blast_initiator)
	
func on_bounced(body):
	super(body)
	trigger_barrel_action(body)

func trigger_barrel_action(by_who):
	disable_interactions()
	$ScoreDonor.donate_score(by_who)
	$AudioStreamPlayer3D.play()
	$AnimationPlayer.play("coin_barrel_animation")
	await $AnimationPlayer.animation_finished
	despawn()

func _on_respawn_timer_timeout():
	respawn()
