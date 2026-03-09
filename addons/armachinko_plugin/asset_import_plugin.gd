@tool
extends EditorScenePostImportPlugin

const import_script = preload("res://features/editor_scripts/3d_asset_import_script.gd")

func _init():
	print_rich("[color=red]hello from asset import plugin")
	pass

func string(category : InternalImportCategory) -> String:
	match category:
		INTERNAL_IMPORT_CATEGORY_NODE : return "Node"
		INTERNAL_IMPORT_CATEGORY_MESH_3D_NODE: return "Mesh3DNode"
		INTERNAL_IMPORT_CATEGORY_MESH: return "Mesh"
		INTERNAL_IMPORT_CATEGORY_MATERIAL: return "Material"
		INTERNAL_IMPORT_CATEGORY_ANIMATION: return "Animation"
		INTERNAL_IMPORT_CATEGORY_ANIMATION_NODE: return "AnimationNode"
		INTERNAL_IMPORT_CATEGORY_SKELETON_3D_NODE: return "Skeleton3DNode"
		_: return "Unknown"
	return "Error"

func  _get_import_options(path):
	print("_get_import_options(%s)" % path)
	add_import_option("a custom int import option", 42)
	add_import_option_advanced(TYPE_STRING, "a general import option (test)", "res://assets/3d/textures/gradient_texture.tres", PROPERTY_HINT_FILE, ".tres,*res")
	pass
	
func _get_internal_import_options(category : InternalImportCategory):
	var category_name = string(category)
	print("_get_internal_import_options(%s)" % category_name)
	match category:
		INTERNAL_IMPORT_CATEGORY_MESH_3D_NODE:
			add_import_option("external surface material override", "gradient texture")
			add_import_option_advanced(TYPE_STRING, "external_material", "res://assets/3d/textures/gradient_texture.tres", PROPERTY_HINT_FILE, ".tres,*res")
		INTERNAL_IMPORT_CATEGORY_MESH:
			add_import_option("unique_material", false)
			add_import_option("material_name", "")
			add_import_option("uv1_offset", Vector3.ZERO)

func _get_option_visibility(path, for_animation, option):
	print_rich("[color=yellow]_get_option_visibility(%s, %s, %s)[/color]" % [path, for_animation, option])
	return true

#NOTE(ArokhSlade, 2025 05 25): this callback is never called back. may be a bug in godot.
func _get_internal_option_visibility(category, for_animation, option):
	print_rich("[color=red]_get_internal_option_visibility(%s, %s, %s)[/color]" % [category, for_animation, option])
	match category:
		INTERNAL_IMPORT_CATEGORY_MESH:
			match option:
				"material_name", "uv1_offset":
					return get_option_value("unique_material") == true
	return null

func _get_internal_option_update_view_required(category, option):
	print_rich("[color=green]_get_internal_option_update_view_required(%s, %s)[/color]" % [string(category), option])
	match category:
		INTERNAL_IMPORT_CATEGORY_MESH:
			match option:
				"unique_material":
					print("unique material - value changed - update view requested")
					return true
	return false

func get_mesh_instances(node, result):
	if node is ImporterMeshInstance3D:
		result.append(node)
	for child in node.get_children():
		get_mesh_instances(child, result)
	return result
	
func iterate(node, depth):
	var string = ""
	for step in depth:
		string += "-"
	string += node.to_string()
	print(string)
	for child in node.get_children():
		iterate(child, depth+1)
		
func _pre_process(scene):
	print_rich("[color=cyan]_pre_process(%s)[/color]" % scene)
	iterate(scene, 0)
	var mesh_instances = []
	get_mesh_instances(scene, mesh_instances)
	for mesh_instance in mesh_instances:
		print(mesh_instance)
	pass
	
## this is called before post import script
func _internal_process(category, base_node, node, resource):
	print_rich("[color=green]_internal_process(%s, %s, %s, %s)[/color]" % [string(category), base_node, node, resource])
	print(node.get_parent())
	if base_node:
		for child in base_node.get_children():
			print(" - ",child)
	match category:
		INTERNAL_IMPORT_CATEGORY_MESH_3D_NODE:
			var node3d = Node3D.new()
			node.add_child(node3d)
			pass
			#var mesh_3d = node as MeshInstance3D
			#var material_path : String = get_option_value("external_material")
			#if not material_path.is_empty():
				#mesh_3d.set_surface_override_material(0, load(material_path))
			
		INTERNAL_IMPORT_CATEGORY_MESH:
			print("unique_material: %s" % get_option_value("unique_material"))
			
			var uv1_offset = get_option_value("uv1_offset")
			print("setting meta data...")				
			var mesh_instance = node
			mesh_instance.set_meta("unique_material", true)
			mesh_instance.set_meta("uv1_offset", uv1_offset)
			
			if (get_option_value("unique_material") == true):
				print("material_name: %s" % get_option_value("material_name"))
				print("uv1_offset: %s" % uv1_offset)
				
	return null
	
	pass
	

# this is called after post import script
# could clean up meta data here, but then we need to re-save the file
# so maybe offer option to save file in this plugin to begin with?
# possibly with a checkbox in the menu
func _post_process(scene):
	print_rich("[color=orange]_post_process(%s)[/color]" % scene)
	iterate(scene, 0)
	#clean_up_meta_data(scene)
	pass

func clean_up_meta_data(node):
	print("removing meta_data on ", node)
	for data in node.get_meta_list():
		node.remove_meta(data)
	for child in node.get_children():
		clean_up_meta_data(child)
