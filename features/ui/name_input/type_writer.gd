extends TextureRect


signal left_neighbor_requested


func _input(event):
	if event is TypeKeyEvent:
		return
	elif event is InputEventKey:
		var type_key_event = TypeKeyEvent.from_key_event(event)
		if type_key_event:
			Input.parse_input_event(type_key_event)


func focus_key(key_string):
	if has_node(key_string):
		get_node(key_string).grab_focus.call_deferred()


func request_left_neighbor():
	left_neighbor_requested.emit()


func _on_left_keys_gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_left") or event.is_action_pressed("ui_focus_next"):
		left_neighbor_requested.emit()
