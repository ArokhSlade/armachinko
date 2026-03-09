extends Area3D
class_name AreaPin


signal despawned
signal respawned
signal exploded_by(exploder)
signal exploded
signal shot_by(shooter)
signal shot
signal bounced_by(bouncer)
signal bounced


var blast_initiator

@export var explodable = true
@export var bounceable = true
@export var shootable = false

@onready var explodable_init = explodable
@onready var bounceable_init = bounceable
@onready var shootable_init = shootable


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
	$CollisionShape3D.set_deferred("disabled", true)
	#$Area3D/CollisionShape3D.set_deferred("disabled", true)
	explodable = false
	bounceable = false
	shootable = false


func enable_interactions():
	$CollisionShape3D.disabled = false
	#TODO(Gerald): if we're going to consolidate this script
	#for all pin types, make sure to remember that area pins
	#have no separate area3d member and no physicsbody root
	#$Area3D/CollisionShape3D.disabled = false
	explodable = explodable_init
	bounceable = bounceable_init
	shootable = shootable_init
