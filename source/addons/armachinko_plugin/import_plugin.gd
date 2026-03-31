@tool 
extends EditorScenePostImportPlugin

var mesh_directory = "res://assets/3d/meshes/extracted_via_script/"
var anim_directory = "res://assets/animations/extracted_via_script/"
var asset_scene_directory = "res://assets/3d/asset scene files/generated_via_script/"

var filename = ""


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


func  _get_import_options(file_path):	
	add_import_option("import_plugin/extract_meshes", false)
	add_import_option("import_plugin/extract_animations", false)
	add_import_option("import_plugin/generate_asset_scene", false)
	
	add_import_option_advanced(TYPE_STRING, "import_plugin/info/file_path", file_path, PROPERTY_HINT_FILE, "", PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_READ_ONLY)
	filename = extractfilename(file_path)
	add_import_option_advanced(TYPE_STRING, "import_plugin/info/filename", filename, PROPERTY_HINT_NONE, "", PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_READ_ONLY)	
	
	
func _get_internal_import_options(category : InternalImportCategory):
	match category:
		INTERNAL_IMPORT_CATEGORY_MESH_3D_NODE:
			add_import_option_advanced(TYPE_STRING, "import_plugin/material/material_overlay", "res://assets/3d/materials/outline_9mm.tres", PROPERTY_HINT_FILE, ".tres,*res")
		INTERNAL_IMPORT_CATEGORY_MESH:
			add_import_option("import_plugin/material/make_material_unique", false)
			add_import_option("import_plugin/material/uv1_offset", Vector3.ZERO)
			add_import_option("import_plugin/material/use_external_material", false)
			add_import_option_advanced(TYPE_STRING, "import_plugin/material/external_material", "res://assets/3d/textures/gradient_texture.tres", PROPERTY_HINT_FILE, ".tres,*res")


#NOTE(ArokhSlade): this callback is never called back. may be a bug in godot.
func _get_internal_option_visibility(category, for_animation, option):
	match category:
		INTERNAL_IMPORT_CATEGORY_MESH:
			match option:
				"import_plugin/material/uv1_offset":
					return get_option_value("import_plugin/material/make_material_unique")
	return null


func get_mesh_instances(node, result):
	if node is ImporterMeshInstance3D:
		result.append(node)
	for child in node.get_children():
		get_mesh_instances(child, result)
	return result


func _internal_process(category, base_node, node, resource):
	match category:
		INTERNAL_IMPORT_CATEGORY_MESH_3D_NODE:
			var mesh = node as ImporterMeshInstance3D
			var material_overlay_path = get_option_value("import_plugin/material/material_overlay")
			if material_overlay_path != null and material_overlay_path != "":
				var material_overlay = load(material_overlay_path)
				mesh.set_meta("material_overlay",material_overlay)
			
		INTERNAL_IMPORT_CATEGORY_MESH:
			var mesh = resource as ImporterMesh
			
			if get_option_value("import_plugin/material/use_external_material"):
				var external_material_path = get_option_value("import_plugin/material/external_material")
				var external_material = load(external_material_path)
				mesh.set_surface_material(0, external_material)
	
			if (get_option_value("import_plugin/material/make_material_unique")):
				var material : BaseMaterial3D = mesh.get_surface_material(0)
				material = material.duplicate()
				material.uv1_offset = get_option_value("import_plugin/material/uv1_offset")
				mesh.set_surface_material(0, material)
	return null


func _post_process(scene):
	if get_option_value("import_plugin/extract_meshes"):
		extract_meshes(scene)
	if get_option_value("import_plugin/extract_animations"):
		extract_animations(scene)
	
	scene.name = filename.to_pascal_case()
	if get_option_value("import_plugin/generate_asset_scene"):
		save_asset_scene(scene, filename)
	
	clean_up()
	
	return scene


func extract_meshes(scene):
	var nodes = get_nodes(scene)
	
	for node in nodes:
		if node.has_meta("material_overlay"):
			var geometry = node as GeometryInstance3D
			geometry.material_overlay = node.get_meta("material_overlay")
		
		clean_up_meta_data(node)
		
		if node is MeshInstance3D:
			var mesh_instance = node
			var mesh_name = mesh_instance.name.to_snake_case()
			save_mesh(mesh_instance.mesh, mesh_name)
			# by loading we make sure the resource is linked to a file
			mesh_instance.mesh = load_mesh(mesh_name)


func save_mesh(resource, mesh_name):
	if not DirAccess.dir_exists_absolute(mesh_directory):
		DirAccess.make_dir_recursive_absolute(mesh_directory)
	var mesh_path = mesh_directory + filename + "_" + mesh_name + "_mesh.res"
	
	ResourceSaver.save(resource, mesh_path, ResourceSaver.FLAG_NONE)
	


func load_mesh(mesh_name):
	var mesh_path = mesh_directory + filename + "_" + mesh_name + "_mesh.res"	
	if not FileAccess.file_exists(mesh_path):
		push_error("could not load file at %s" % mesh_path)
		return null
	
	var loaded = ResourceLoader.load(mesh_path, "", ResourceLoader.CACHE_MODE_REPLACE)
	return loaded
	
	
func get_nodes(node):
	if node == null:
		return []
	var nodes = [node]
	for child in node.get_children():
		var descendants = get_nodes(child)
		nodes.append_array(descendants)
	return nodes
	
	
func clean_up_meta_data(node):
	for data in node.get_meta_list():
		node.remove_meta(data)


func get_animation_player(node):
	if node is AnimationPlayer:
		return node
	for child in node.get_children():
		var anim_player = get_animation_player(child)
		if anim_player != null:
			return anim_player
	return null


func extract_animations(scene):	
	var anim_player = get_animation_player(scene)
	if anim_player == null:
		return
	
	var anim_lib = anim_player.get_animation_library("")
	
	for anim_name in anim_player.get_animation_list():
		var anim = anim_player.get_animation(anim_name)
		
		save_animation(anim_name, anim)
		anim_lib.remove_animation(anim_name)
		var loaded = load_animation(anim_name)
		anim_lib.add_animation(anim_name, loaded)


func save_animation(anim_name, anim):
	if not DirAccess.dir_exists_absolute(anim_directory):
		DirAccess.make_dir_absolute(anim_directory)
	var anim_path = anim_directory + filename + "_" + anim_name + ".res"
	
	ResourceSaver.save(anim, anim_path,ResourceSaver.FLAG_NONE)


func load_animation(anim_name):
	var anim_path = anim_directory + filename + "_" + anim_name + ".res"
	if not FileAccess.file_exists(anim_path):
		push_error("could not load file at %s" % anim_path)
		return null
	
	var loaded = load(anim_path)
	return loaded


func save_asset_scene(result, filename):
	var packed_scene = PackedScene.new()
	packed_scene.pack(result)
	
	if not DirAccess.dir_exists_absolute(asset_scene_directory):
		DirAccess.make_dir_recursive_absolute(asset_scene_directory)
	var asset_scene_path = asset_scene_directory + filename + ".tscn"
	
	ResourceSaver.save(packed_scene, asset_scene_path)


#TODO(Gerald): could live in a utitlity class
func extractfilename(file_path):
	var filename = ""
	for index in range(file_path.length()-1, 0, -1):
		if file_path[index] == '.':
			filename = file_path.substr(0,index)
			break
	for index in range(filename.length()-1, 0, -1):
		if filename[index] == '/':
			filename = filename.substr(index+1)
			break
	return filename


func clean_up():
	filename = ""
