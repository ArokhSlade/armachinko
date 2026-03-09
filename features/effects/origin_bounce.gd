extends Node3D

@export var impulse_strength = 50.0

func on_bounced(body):
	if body.is_in_group("Players") and body is RigidBody3D:
		bounce_from_origin(body)

func bounce_from_origin(body : RigidBody3D):
	var bounce_direction = (body.global_position - global_position).normalized()
	var bonus_impulse = impulse_strength * bounce_direction
	body.apply_impulse(bonus_impulse)
