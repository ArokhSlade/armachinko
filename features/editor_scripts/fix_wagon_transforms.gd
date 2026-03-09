@tool
extends EditorScript

func _run():
	var scene = get_scene()
	var bumpers = get_rectangle_bumpers(scene)
	for bumper in bumpers:
		print(bumper)
	normalize_transforms_in_all(bumpers)	

func get_rectangle_bumpers(scene : Node):	
	var bumpers = scene.find_children("RectangleBumper*")
	return bumpers
	
func normalize_transforms_in_all(bumpers):
	for bumper in bumpers:
		normalize_transforms(bumper)
		
func normalize_transforms(bumper: Node):
	var model : Node3D = bumper.get_node("SetDressing/settler_wagon")
	bumper.global_transform = model.global_transform
	reset_all_children_transforms(bumper)
	
func reset_all_children_transforms(bumper):
	for child in bumper.get_children():
		child.transform = Transform3D.IDENTITY
		reset_all_children_transforms(child)
