@tool
extends EditorPlugin

var import_plugin = preload("res://addons/armachinko_plugin/import_plugin.gd")
var import_plugin_instance

func _enter_tree():
	import_plugin_instance = import_plugin.new()
	add_scene_post_import_plugin(import_plugin_instance)
	
func _exit_tree():
	remove_scene_post_import_plugin(import_plugin_instance)
