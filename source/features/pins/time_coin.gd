extends Area3D

@export var give_extra_time := 100

func despawn():
	$CollisionShape3D.call_deferred("set_disabled", true)
	hide()


func _on_body_entered(body):
	if body.is_in_group("Players"):
		$PickupTimeSound.play()
	if body.has_method("receive_time_bonus"):
		body.receive_time_bonus(give_extra_time)
		despawn()
