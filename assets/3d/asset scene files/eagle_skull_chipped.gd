extends Node3D

func play_transition():
	$AnimationPlayer2.play("StageSwap")

func play_scream():
	$AnimationTree["parameters/TimeSeek/seek_request"] = 0.0
	$AnimationPlayer2.play("ChippedScreamVfx")
