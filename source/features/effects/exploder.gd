extends Effect

signal ignited
signal exploded(igniter)

@export var explosion_blast_scene : PackedScene

var igniter
var explosion_blast 
var in_progress = false


func ignite(new_igniter):
	if not in_progress: 
		in_progress = true
		igniter = new_igniter
		ignited.emit()
	
	
func explode():	
	spawn_explosion_blast()
	
	
func spawn_explosion_blast():
	explosion_blast = explosion_blast_scene.instantiate()
	explosion_blast.set_blast_initiator(igniter)	
	
	var level = Globals.get_level()
	var explosion_parent = level.get_new_parent_for_spawned_object(self, explosion_blast)
	
	explosion_parent.add_child(explosion_blast)
	explosion_blast.global_position = global_position	

	await explosion_blast.activated
	exploded.emit(igniter)


func get_igniter():
	return igniter


func reset():
	in_progress = false
	explosion_blast = null
