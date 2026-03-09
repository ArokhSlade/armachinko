extends Area3D
class_name ExplosionBlast

signal exploded # used in animation
signal activated
signal deactivated

enum State {
	INACTIVE,
	ACTIVE
}

var blast_initiator : Node3D
var state = State.INACTIVE


func set_blast_initiator(new_blast_initiator):
	blast_initiator = new_blast_initiator


func _ready():
	explode()


func _physics_process(_delta):
	match state:
		State.ACTIVE:
			for body in get_overlapping_bodies():
				if body.has_method("on_hit"):
					body.on_hit(self)


func explode():
	$AnimationPlayer.play("explode")


func activate():
	change_state(State.ACTIVE)
	activated.emit()


func deactivate():
	change_state(State.INACTIVE)
	deactivated.emit()


func change_state(new_state):
	state = new_state


func despawn():
	queue_free()


func get_blast_initiator():
	return blast_initiator
