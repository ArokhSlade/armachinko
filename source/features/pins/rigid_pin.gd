extends RigidBody3D
class_name RigidPin

signal despawned
signal respawned
signal blasted_by(blast_initiator)
signal bounced_by(bouncer)
signal bounced
signal blasted

var blast_initiator


func despawn():
	disable_interaction()
	hide()
	despawned.emit()

func respawn():
	enable_interaction()
	show()
	respawned.emit()

func _on_area_3d_body_entered(body):
	bounced_by.emit(body)
	bounced.emit()
	
func _on_area_3d_area_entered(area):
	if area.has_method("get_blast_initiator"):
		blast_initiator = area.get_blast_initiator()
	blasted_by.emit(blast_initiator)
	blasted.emit()

	
func disable_interaction():
	disable_bouncing()
	disable_blasting()

func enable_interaction():
	enable_bouncing()
	enable_blasting()

func disable_bouncing():
	$CollisionShape3D.call_deferred("set_disabled", true)

func disable_blasting():
	$Area3D/CollisionShape3D.call_deferred("set_disabled", true)
	

func enable_bouncing():
	$CollisionShape3D.call_deferred("set_disabled", false)

func enable_blasting():
	$Area3D/CollisionShape3D.call_deferred("set_disabled", false)
