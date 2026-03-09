extends Node
class_name Level

@export var tutorial : Node

func _enter_tree():
	Globals.set_level(self)

func _ready():	
	if has_node("Events"):
		setup_event_signals()
	
func get_new_parent_for_spawned_object(_spawner, _spawned_object):
	var new_parent = self
	return new_parent


func _on_player_bonus_time_received(amount):
	if has_node("UI"):
		$UI.add_bonus_time(amount)

func setup_event_signals():
	for node in $Events.get_children():
		if node is FeedbackMessage:
			node.message_started.connect($UI.hide_hud)
			node.message_finished.connect($UI.show_hud)
