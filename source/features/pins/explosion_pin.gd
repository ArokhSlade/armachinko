extends GenericPin
class_name ExplosionPin


func despawn():
	super()
	$RespawnTimer.start()


func respawn():
	super()
	$Exploder.reset()


func on_bounced(body):
	$Exploder.ignite(body)
	super(body)
	
	
func on_exploded(area):
	$Exploder.ignite(area)
	super(area)


func _on_exploder_ignited():
	$AnimationPlayer.play("flash")


func _on_exploder_exploded(igniter):
	$ScoreDonor.donate_score(igniter)
	despawn()


func _on_respawn_timer_timeout():
	respawn()
