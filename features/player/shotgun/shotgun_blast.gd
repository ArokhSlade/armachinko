extends Area3D

var shooter

func setup(new_shooter):
	shooter = new_shooter

func activate():
	$AnimationPlayer.play("blast")
	
	
func despawn():
	get_parent().remove_child.call_deferred(self)
	queue_free.call_deferred()

func get_blast_initiator():
	return shooter
