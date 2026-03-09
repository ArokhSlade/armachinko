extends MeshInstance3D

@export var raycast : RayCast3D

func _process(_delta):
	if mesh is ImmediateMesh:
		mesh.clear_surfaces()
		mesh.surface_begin(Mesh.PrimitiveType.PRIMITIVE_LINES)
		mesh.surface_set_color(Color.GREEN)
		mesh.surface_add_vertex(raycast.global_position)
		mesh.surface_set_color(Color.RED)
		mesh.surface_add_vertex(raycast.global_position + raycast.target_position)
		mesh.surface_end()
