extends AnimatedSprite3D


func despawn():
	get_parent().remove_child.call_deferred(self)
	queue_free()


func _on_animation_finished() -> void:
	despawn()
