extends Node3D

@export var impact_vfx_scene : PackedScene
@export var player : Node

func spawn_at(location, angle):
	var impact_vfx = impact_vfx_scene.instantiate()
	var vfx_parent = Globals.get_level().get_new_parent_for_spawned_object(self, impact_vfx)	
	vfx_parent.add_child(impact_vfx)
	impact_vfx.global_position = location
	impact_vfx.rotate(Vector3.FORWARD, -angle)
	
func spawn_with_transform(xform):
	var impact_vfx = impact_vfx_scene.instantiate()
	impact_vfx.player = player
	var vfx_parent = Globals.get_level().get_new_parent_for_spawned_object(self, impact_vfx)	
	vfx_parent.add_child(impact_vfx)
	impact_vfx.transform = xform
