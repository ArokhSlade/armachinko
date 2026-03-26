@tool
extends EditorScenePostImport

var gradient_material : Material = preload("res://assets/3d/textures/gradient_texture.tres")
var outline_material : Material = preload("res://assets/3d/materials/outline_9mm.tres")

var _filename = ""
func _post_import(scene) -> Node:	
	print_rich("[color=yellow]_post_import(%s)[/color]" % scene)
	extract_meshes(scene)	
	extract_animations(scene)
	
	var _filename = get_filename()	
	scene.name = _filename.to_pascal_case()		
	save_asset_scene(scene, _filename)
	
	return scene

func get_filename():
	if _filename == "":
		_filename = get_source_file()
				
		for index in range(_filename.length()-1, 0, -1):
			if _filename[index] == '.':
				_filename = _filename.substr(0,index)
				break
				
		for index in range(_filename.length()-1, 0, -1):
			if _filename[index] == '/':
				_filename = _filename.substr(index+1)
				break
			
	return _filename

func extract_meshes(scene):
	var meshes = iterate_meshes(scene)
	for mesh_instance in meshes:
		print ("mesh found: %s" % mesh_instance)
		mesh_instance.mesh.surface_set_material(0, gradient_material)
		
		mesh_instance.material_overlay = outline_material
		
		apply_unique_material_settings_from_metadata(mesh_instance)
		
		clean_up_meta_data(mesh_instance)
		
		save_mesh(mesh_instance.mesh, mesh_instance.name)
		# by loading we make sure the resource is linked to a file
		mesh_instance.mesh = load_mesh(mesh_instance.name)

func iterate_meshes(node):
	var result = []
	for child in node.get_children():
		if child is MeshInstance3D:
			var child_meshes = iterate_meshes(child)
			result.append_array(child_meshes)
			result.append(child)
	return result

## uses the scene import plugin api
func apply_unique_material_settings_from_metadata(mesh_instance : MeshInstance3D):
	# NOTE(Gerald, 2025 05 28)
	# we know the mesh instance has a valid mesh with material loaded from disk
	# if unique_material==true then we make a local copy (aka make unique)
	# of that material and set up custom values
	if (mesh_instance.get_meta("unique_material", false)):
		print("found unique material settings. applying ...")
		var material : BaseMaterial3D = mesh_instance.mesh.surface_get_material(0).duplicate()
		mesh_instance.mesh.surface_set_material(0, material)
		var uv1_offset = mesh_instance.get_meta("uv1_offset", Vector3.ZERO)
		print("uv1_offset: %s" % uv1_offset)
		material.uv1_offset = uv1_offset

func clean_up_meta_data(node):
	print("removing metadata...")
	for data in node.get_meta_list():
		print("removing metadata:  %s" % data)
		node.remove_meta(data)

var mesh_directory = "res://assets/3d/meshes/extracted_via_script/"
func save_mesh(resource, mesh_name):
	if not DirAccess.dir_exists_absolute(mesh_directory):
		DirAccess.make_dir_absolute(mesh_directory)
	var mesh_path = mesh_directory + get_filename() + "_" + mesh_name + "_mesh.res"
	
	ResourceSaver.save(resource, mesh_path, ResourceSaver.FLAG_NONE)
	print("saving resource mesh: %s at %s" % [resource, mesh_path] )

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
		
var anim_directory = "res://assets/animations/extracted_via_script/"
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

var asset_scene_directory = "res://assets/3d/asset scene files/generated_via_script/"
func save_asset_scene(result, _filename):
	var packed_scene = PackedScene.new()
	packed_scene.pack(result)
	
	if not DirAccess.dir_exists_absolute(asset_scene_directory):
		DirAccess.make_dir_absolute(asset_scene_directory)
	var asset_scene_path = asset_scene_directory + _filename + ".tscn"
	
	print("saving asset scene: %s from %s to %s" % [result, _filename, asset_scene_path])
	ResourceSaver.save(packed_scene, asset_scene_path)
	
