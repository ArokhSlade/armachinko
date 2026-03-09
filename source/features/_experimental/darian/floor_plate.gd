extends Area3D

signal activated(body)

var already_hit = false



func _on_body_entered(body: Node3D) -> void:
	if already_hit == false:
		$Label3D/AnimationPlayer.play("light_up")
		already_hit = true
		activated.emit(body)
