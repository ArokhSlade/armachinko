extends AnimatableBody3D
class_name AnimatablePin

signal despawned
signal respawned
signal blasted_by(blast_initiator)
signal bounced_by(bouncer)
signal bounced
signal blasted

var blast_initiator

var can_bounce = true
var can_blast = true

func despawn():
	disable_interaction()
	hide()
	despawned.emit()

func respawn():
	enable_interaction()
	show()
	respawned.emit()

func _on_area_3d_body_entered(body):
	if can_bounce:
		on_bounced(body)
	
func _on_area_3d_area_entered(area):
	if can_blast:
		on_blasted(area)

func on_blasted(area):
	if area.has_method("get_blast_initiator"):
		blast_initiator = area.get_blast_initiator()
		blasted_by.emit(blast_initiator)
		blasted.emit()
	
func on_bounced(body):
	bounced_by.emit(body)
	bounced.emit()
	
func disable_interaction():
	disable_collision()
	disable_bouncing()
	disable_blasting()

func enable_interaction():
	enable_collision()
	enable_bouncing()
	enable_blasting()

func disable_collision():
	$CollisionShape3D.call_deferred("set_disabled", true)

func enable_collision():
	$CollisionShape3D.call_deferred("set_disabled", false)

func disable_bouncing():
	can_bounce = false

func disable_blasting():
	can_blast = false	

func enable_bouncing():
	can_bounce = true	

func enable_blasting():
	can_blast = true	
