extends Node3D


func play_scream():
	$AnimationTree["parameters/TimeSeek/seek_request"] = 0.0
	$AnimationPlayer2.play("SreamVfx")
