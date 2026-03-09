extends Node3D

@export var base_scale = 0.5:
	set(new_value):
		scale = Vector3.ONE * new_value * scale_factor

var scale_factor = 1.0

func _enter_tree():
	base_scale = scale.x


func _ready():
	$AnimationPlayer.play("float_up")

func set_score_value(score_value):
	$ScoreLabel.text = "$ %d" % score_value

func set_scale_factor(new_scale_factor):
	scale_factor = new_scale_factor
	
