extends Node3D
class_name GenericPin


signal despawned
signal respawned
signal exploded_by(exploder)
signal exploded
signal shot_by(shooter)
signal shot
signal bounced_by(bouncer)
signal bounced


var blast_initiator

## can be affected by character collisions
@export var bounceable = true
## can be affected by explosion
@export var explodable = true
## can be affected by gun shots
@export var shootable = false

@onready var bounceable_init = bounceable
@onready var explodable_init = explodable
@onready var shootable_init = shootable

@export var bounceable_collision_shape : CollisionShape3D
@export var explodable_collision_shape : CollisionShape3D
@export var shootable_collision_shape : CollisionShape3D

func despawn():
	disable_interactions()
	hide()
	despawned.emit()


func respawn():
	enable_interactions()
	show()
	respawned.emit()


func on_hit(by_what):
	if bounceable and by_what is PhysicsBody3D:
		on_bounced(by_what)
	elif explodable and by_what is ExplosionBlast:
		on_exploded(by_what)	
	elif shootable and by_what is Area3D and by_what.has_method("get_blast_initiator"):
		#TODO: class_name for MuzzleFlash
		on_shot(by_what)


func on_bounced(body):
	bounced_by.emit(body)
	bounced.emit()


func on_shot(area):
	if area.has_method("get_blast_initiator"):
		blast_initiator = area.get_blast_initiator()
	shot_by.emit(area)
	shot.emit()
	
	
func on_exploded(area):
	if area.has_method("get_blast_initiator"):
		blast_initiator = area.get_blast_initiator()
	exploded_by.emit(area)
	exploded.emit()


func _on_body_entered(body):
	on_hit(body)


func _on_area_entered(area):	
	on_hit(area)


func disable_interactions():
	bounceable_collision_shape.set_deferred("disabled", true)
	explodable_collision_shape.set_deferred("disabled", true)
	shootable_collision_shape.set_deferred("disabled", true)
	explodable = false
	bounceable = false
	shootable = false


func enable_interactions():
	bounceable_collision_shape.set_deferred("disabled", false)
	explodable_collision_shape.set_deferred("disabled", false)
	shootable_collision_shape.set_deferred("disabled", false)
	explodable = explodable_init
	bounceable = bounceable_init
	shootable = shootable_init
