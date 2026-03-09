extends VBoxContainer

@export var table_entry_scene : PackedScene

func populate_entries(highscore_data, max_size):
	if highscore_data == null:
		return
		
	var scores = highscore_data.highscore_list
	
	for placeholder in get_children():
		remove_child(placeholder)
		placeholder.queue_free()

	var entries_count = mini(max_size, scores.size())
	for index in entries_count:
		var new_entry = table_entry_scene.instantiate()
		new_entry.setup()
		new_entry.update(scores[index])
		add_child(new_entry)
		

func update_entries(highscore_data):
	if highscore_data == null:
		clear_entries()
	else:
		var scores = highscore_data.highscore_list
		
		var entries_count = mini(scores.size(), get_children().size())
		var entries = get_children()
		for index in entries_count:
			entries[index].update(scores[index])

func clear_entries():
	for entry in get_children():
		entry.clear()
