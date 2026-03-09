extends Control


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
