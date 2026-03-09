extends RigidPin

var despawn_underway = false

func despawn():
	if not despawn_underway:
		despawn_underway = true
		$AnimationPlayer.play("destroy")
		despawned.emit()

func delete_from_game():
	get_parent().remove_child(self)
	queue_free()


func _on_despawn_timer_timeout() -> void:
	delete_from_game()

func set_despawn_timer(amount):
	pass
	#$DespawnTimer.stop()
	#$DespawnTimer.start(amount)
