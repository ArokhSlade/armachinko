extends GenericPin
class_name SheepBumper

func on_bounced(body):
	super(body)
	$SheepHitSound.play()
	$OriginBounce.on_bounced(body)
	$AnimationPlayer.play("fuzzy_bounce")

func _on_fence_area_body_entered(_body):
	$FenceHitSound.play()
