extends GenericPin
class_name CactusBumper


func on_bounced(body):
	super(body)
	$BouncedAudioPlayer.play()
	$OriginBounce.on_bounced(body)
	$AnimationPlayer.play("bounce_animation")
