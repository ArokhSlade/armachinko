extends GenericPin

func on_bounced(body):
	super(body)
	if body.is_in_group("Players") and body is RigidBody3D:
		$OriginBounce.bounce_from_origin(body)
		$AudioStreamPlayer3D.play()
