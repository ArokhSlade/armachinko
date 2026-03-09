extends AudioStreamPlayer


@export var fade_out_start_point = 0.95 ## between 0. and 1.
@export var looping = true


@onready var default_volume_db = volume_db

func _process(_delta):
	if looping and not playing:
		volume_db = default_volume_db
		seek(0.0)
		play()
		
	var current_position = get_playback_position() + AudioServer.get_time_since_last_mix()

	
	var duration = stream.get_length()
	var current_position_normalized = clampf(current_position / duration, 0.0, 1.0)
	print ("cur_pos:",current_position,"/",duration,"=",current_position_normalized)
	var fade_pos = current_position_normalized - fade_out_start_point
	var fade_range = 1.0 - fade_out_start_point
	var fade_ratio = fade_pos / fade_range
	var volume_ratio = 1.0 - fade_ratio
	print ("fade: %f/%f=%f -> %f" % [fade_pos,fade_range,fade_ratio,volume_ratio])
	
	var volume = db_to_linear(volume_db)
	if playing:
		if current_position_normalized >= fade_out_start_point:
			volume = lerp(0.0, 1.0, volume_ratio)
			volume_db = linear_to_db(volume)
	
	
	print(volume, ", ", volume_db)
