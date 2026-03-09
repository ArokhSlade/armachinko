extends Node

@export var music_player : AudioStreamPlayer



func _on_ui_time_zone_changed_to(new_time_zone: Variant) -> void:	
	var music = music_player.get_stream_playback()
	if new_time_zone == "UNSAFE":
		music.switch_to_clip_by_name(&"Ingame Soundtrack Part 2")
	if new_time_zone == "SAFE":
		music.switch_to_clip_by_name(&"Ingame Soundtrack")
