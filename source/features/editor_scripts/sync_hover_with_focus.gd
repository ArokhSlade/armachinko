@tool
extends EditorScript


func _run():	
	var scene = get_scene()
	for node in scene.find_children("*"):
		if node is Button or node is TextureButton:
			node.mouse_entered.connect(node.grab_focus, CONNECT_DEFERRED | CONNECT_PERSIST)
			if node["theme_override_styles/hover"]:
				node["theme_override_styles/hover"] = node["theme_override_styles/normal"]
