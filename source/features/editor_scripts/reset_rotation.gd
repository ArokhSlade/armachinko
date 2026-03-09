@tool
extends EditorScript



func _run():	
	var scene = get_scene()
	print(scene)
	var set_dressing = scene.find_child("Set Dressing")
	print(set_dressing)
	for child in set_dressing.find_children("*"):		
		print(child.name)
		child.rotation = Vector3.ZERO
		child.scale = Vector3(1,1,1)
