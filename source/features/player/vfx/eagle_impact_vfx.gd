extends Node3D

@export var player : Node

func despawn():
	get_parent().remove_child.call_deferred(self)
	queue_free()

func _on_animation_player_animation_finished(_eagle_impact) -> void:
	despawn()
