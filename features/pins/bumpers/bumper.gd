extends StaticBody3D

signal bounced()
signal bounced_by(bouncer)
signal bounced_me(who)


func destroy():
	$Area3D/CollisionShape3D.call_deferred("set_disabled", true)
	$CollisionShape3D.call_deferred("set_disabled", true)
	hide()

func _on_area_3d_body_entered(body: Node3D) -> void:
	for effect in $Effects.get_children():
		if effect.has_method("on_bounced"):
			effect.on_bounced(body)
	bounced.emit()
	bounced_by.emit(body)
	bounced_me.emit(self)

func explosion_destroy(area3D : Area3D):
	for effect in $Effects.get_children():
		if effect.has_method("on_explosion"):
			effect.on_explosion(area3D)


func _on_fence_side_body_entered(body: Node3D) -> void:
	if body.is_in_group("Players"):
		$TriangleHitSound.play()
