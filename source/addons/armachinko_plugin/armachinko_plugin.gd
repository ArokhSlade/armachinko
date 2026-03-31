@tool
extends EditorPlugin

var post_import_plugin = preload("res://addons/armachinko_plugin/import_plugin.gd")
var post_import_plugin_instance

func _enter_tree():
	post_import_plugin_instance = post_import_plugin.new()
	add_scene_post_import_plugin(post_import_plugin_instance)
	
func _exit_tree():
	remove_scene_post_import_plugin(post_import_plugin_instance)
