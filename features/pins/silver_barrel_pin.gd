extends StaticBody3D

func destroy():
	$Area3D/CollisionShape3D.call_deferred("set_disabled", true)
	$CollisionShape3D.call_deferred("set_disabled", true)
	hide()
	

func _on_area_3d_body_entered(body: Node3D) -> void:
	for effect in $Effects.get_children():
		if effect.has_method("on_bounced"):
			effect.on_bounced(body)
