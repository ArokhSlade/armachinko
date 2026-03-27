@tool 
extends EditorScenePostImportPlugin

var gradient_material : Material = preload("res://assets/3d/textures/gradient_texture.tres")
var outline_material : Material = preload("res://assets/3d/materials/outline_9mm.tres")

var mesh_directory = "res://assets/3d/meshes/extracted_via_script/"
var anim_directory = "res://assets/animations/extracted_via_script/"
var asset_scene_directory = "res://assets/3d/asset scene files/generated_via_script/"

var _filename = ""

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

func  _get_import_options(file_path):
	print("_get_import_options(%s)" % file_path)
	
	print("_filename: " + _filename)	
	print(gradient_material)
	print(outline_material)
	print(asset_scene_directory)
	print(anim_directory)
	print(mesh_directory)
	
	_filename = extract_filename(file_path)
	
	add_import_option_advanced(TYPE_STRING, "import_plugin/info/file_path", file_path, PROPERTY_HINT_FILE, "", PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_READ_ONLY)
	add_import_option_advanced(TYPE_STRING, "import_plugin/info/filename", _filename, PROPERTY_HINT_NONE, "", PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_READ_ONLY)
	pass
	
func _get_internal_import_options(category : InternalImportCategory):
	var category_name = string(category)
	print("_get_internal_import_options(%s)" % category_name)
	match category:
		INTERNAL_IMPORT_CATEGORY_MESH_3D_NODE:
			add_import_option_advanced(TYPE_STRING, "import_plugin/material/material_overlay", "res://assets/3d/materials/outline_9mm.tres", PROPERTY_HINT_FILE, ".tres,*res")
		INTERNAL_IMPORT_CATEGORY_MESH:
			add_import_option("make_material_unique", false)
			add_import_option("material_name", "")
			add_import_option("uv1_offset", Vector3.ZERO)
			add_import_option("import_plugin/material/use_external_material", false)
			add_import_option_advanced(TYPE_STRING, "import_plugin/material/external_material", "res://assets/3d/textures/gradient_texture.tres", PROPERTY_HINT_FILE, ".tres,*res")

func _get_option_visibility(path, for_animation, option):
	print_rich("[color=yellow]_get_option_visibility(%s, %s, %s)[/color]" % [path, for_animation, option])
	return true

#NOTE(ArokhSlade, 2025 05 25): this callback is never called back. may be a bug in godot 4.3.
func _get_internal_option_visibility(category, for_animation, option):
	print_rich("[color=red]_get_internal_option_visibility(%s, %s, %s)[/color]" % [category, for_animation, option])
	match category:
		INTERNAL_IMPORT_CATEGORY_MESH:
			match option:
				"material_name", "uv1_offset":
					return get_option_value("make_material_unique") == true
			if option == "import_plugin/material/external_material":
				return get_option_value("import_plugin/material/use_external_material")
	return null

func _get_internal_option_update_view_required(category, option):
	print_rich("[color=green]_get_internal_option_update_view_required(%s, %s)[/color]" % [string(category), option])
	match category:
		INTERNAL_IMPORT_CATEGORY_MESH:
			match option:
				"import_plugin/material/use_external_material":
					return true
		INTERNAL_IMPORT_CATEGORY_MESH_3D_NODE:
			return true
	return false

func get_mesh_instances(node, result):
	if node is ImporterMeshInstance3D:
		result.append(node)
	for child in node.get_children():
		get_mesh_instances(child, result)
	return result
	
func print_node_tree(node, depth = 0):
	var string = ""
	for step in depth:
		string += "-"
	string += node.to_string()
	print(string)
	for child in node.get_children():
		print_node_tree(child, depth+1)
		
func _pre_process(scene):
	print_rich("[color=cyan]_pre_process(%s)[/color]" % scene)
	print_node_tree(scene, 0)
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
			var mesh = node as ImporterMeshInstance3D
			var path_to_material = get_option_value("import_plugin/material/material_overlay")
			if path_to_material != null and path_to_material != "":
				var material_overlay = load(path_to_material)
				mesh.set_meta("material_overlay",material_overlay)
			
			var node3d = Node3D.new()
			node.add_child(node3d) #TODO(Gerald): why?
			pass
			#var mesh_3d = node as MeshInstance3D
			#var material_path : String = get_option_value("external_material")
			#if not material_path.is_empty():
				#mesh_3d.set_surface_override_material(0, load(material_path))
			
		INTERNAL_IMPORT_CATEGORY_MESH:
			var mesh = resource as ImporterMesh
			
			if get_option_value("import_plugin/material/use_external_material"):
				print(resource)
				mesh.set_surface_material(0, gradient_material)
				print("setting material.")
			
			if (get_option_value("make_material_unique")):
				var material : BaseMaterial3D = mesh.get_surface_material(0).duplicate()
				print(material.albedo_texture.resource_path)
				material.uv1_offset = get_option_value("uv1_offset")
				mesh.set_surface_material(0, material)
				
	return null
	
	pass

func apply_make_material_unique_settings_from_metadata(mesh_instance : MeshInstance3D):
	# NOTE(Gerald, 2025 05 28)
	# we know the mesh instance has a valid mesh with material loaded from disk
	# if make_material_unique==true then we make a local copy (aka make unique)
	# of that material and set up custom values
	if (mesh_instance.get_meta("make_material_unique", false)):
		print("found make material unique settings. applying ...")
		var material : BaseMaterial3D = mesh_instance.mesh.surface_get_material(0).duplicate()
		mesh_instance.mesh.surface_set_material(0, material)
		var uv1_offset = mesh_instance.get_meta("uv1_offset", Vector3.ZERO)
		print("uv1_offset: %s" % uv1_offset)
		material.uv1_offset = uv1_offset



func _post_process(scene):
	print_rich("[color=orange]_post_process(%s)[/color]" % scene)
	print_node_tree(scene, 0)
	
	extract_meshes(scene)
	extract_animations(scene)
	
	var _filename = get_filename()	
	scene.name = _filename.to_pascal_case()		
	save_asset_scene(scene, _filename)
	
	return scene

func get_filename():
	var file_path = get_option_value("import_plugin/info/file_path")	
	if _filename == "":	
		_filename = extract_filename(file_path)
	return _filename

func extract_filename(file_path):
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

func iterate_nodes(node : Node):
	if node == null:
		return []
	var nodes = [node]
	for child in node.get_children():
		var descendants = iterate_nodes(child)
		nodes.append_array(descendants)
	return nodes

func extract_meshes(scene):
	var nodes = iterate_nodes(scene)
	print(nodes)
	
	for node in nodes:
		if node.has_meta("material_overlay"):
			var geometry = node as GeometryInstance3D
			geometry.material_overlay = node.get_meta("material_overlay")
		
		clean_up_meta_data(node)
		
		if node is MeshInstance3D:
			var mesh_instance = node
			print ("mesh found: %s" % mesh_instance)
			save_mesh(mesh_instance.mesh, mesh_instance.name)
			# by loading we make sure the resource is linked to a file
			mesh_instance.mesh = load_mesh(mesh_instance.name)

func clean_up_meta_data(node):
	print("removing metadata...")
	for data in node.get_meta_list():
		print("removing metadata:  %s" % data)
		node.remove_meta(data)

func save_mesh(resource, mesh_name):
	print("mesh_dir: " + mesh_directory)
	if not DirAccess.dir_exists_absolute(mesh_directory):
		DirAccess.make_dir_absolute(mesh_directory)
	var mesh_path = mesh_directory + get_filename() + "_" + mesh_name + "_mesh.res"
	
	ResourceSaver.save(resource, mesh_path, ResourceSaver.FLAG_NONE)
	print("saving resource mesh: %s at %s" % [resource, mesh_path] )
	
	#HACK(gerald, 2026 03 27): make godot update mesh in editor, does not always work
	ResourceLoader.load(mesh_path, "", ResourceLoader.CACHE_MODE_REPLACE)
	#var fs = EditorInterface.get_resource_filesystem()
	#fs.reimport_files([mesh_path])



func load_mesh(mesh_name):
	if not DirAccess.dir_exists_absolute(mesh_directory):
		DirAccess.make_dir_absolute(mesh_directory)
	var mesh_path = mesh_directory + get_filename() + "_" + mesh_name + "_mesh.res"	
	
	var loaded = load(mesh_path)
	return loaded

func iterate_animation_players(node):
	var result = []
	for child in node.get_children():
		if child is AnimationPlayer:
			var child_anim_players = iterate_animation_players(child)
			result.append_array(child_anim_players)
			result.append(child)
	return result

func extract_animations(scene):	
	var anim_players = iterate_animation_players(scene)
	
	if anim_players.size() == 0:
		return
		
	assert(anim_players.size() <= 1, "ERROR: more than one AnimationPlayer found during 3d asset import")
	
	var anim_player = anim_players[0]	
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
	var anim_path = anim_directory + _filename + "_" + anim_name + ".res"
	
	ResourceSaver.save(anim, anim_path,ResourceSaver.FLAG_NONE)

func load_animation(anim_name):
	if not DirAccess.dir_exists_absolute(anim_directory):
		DirAccess.make_dir_absolute(anim_directory)
	var anim_path = anim_directory + _filename + "_" + anim_name + ".res"
	
	var loaded = load(anim_path)
	return loaded

#TODO: delete?
func setup_animation_player(anim_player, anim_dict, anim_player_name = "AnimationPlayer"):
	anim_player.name = anim_player_name
	anim_player.add_animation_library("", AnimationLibrary.new())
	var anim_lib = anim_player.get_animation_library("")
	for anim_name in anim_dict.keys():
		anim_lib.add_animation(anim_name, anim_dict[anim_name])


func save_asset_scene(result, _filename):
	var packed_scene = PackedScene.new()
	packed_scene.pack(result)
	
	if not DirAccess.dir_exists_absolute(asset_scene_directory):
		DirAccess.make_dir_absolute(asset_scene_directory)
	var asset_scene_path = asset_scene_directory + _filename + ".tscn"
	
	print("saving asset scene: %s from %s to %s" % [result, _filename, asset_scene_path])
	ResourceSaver.save(packed_scene, asset_scene_path)

#
#func clean_up_meta_data(node):
	#print("removing meta_data on ", node)
	#for data in node.get_meta_list():
		#node.remove_meta(data)
	#for child in node.get_children():
		#clean_up_meta_data(child)
