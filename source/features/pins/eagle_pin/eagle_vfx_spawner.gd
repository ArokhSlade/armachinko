extends Node3D

@export var eagle_impact_vfx_scene : PackedScene


func spawn_at(location, angle):
	var eagle_impact_vfx = eagle_impact_vfx_scene.instantiate()
	var vfx_parent = Globals.get_level().get_new_parent_for_spawned_object(self, eagle_impact_vfx)	
	vfx_parent.add_child(eagle_impact_vfx)
	eagle_impact_vfx.global_position = location
	eagle_impact_vfx.rotate(Vector3.FORWARD, -angle)
	
func spawn_with_transform(xform):
	var eagle_impact_vfx = eagle_impact_vfx_scene.instantiate()
	eagle_impact_vfx.player = owner
	var vfx_parent = Globals.get_level().get_new_parent_for_spawned_object(self, eagle_impact_vfx)	
	vfx_parent.add_child(eagle_impact_vfx)
	eagle_impact_vfx.transform = xform
