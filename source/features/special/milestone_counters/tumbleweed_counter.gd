extends Node2D

@export var threshold : int
var count : int = 0
@export var avalanche_event : Milestone


func _ready():
	update_text()

func increment_and_update():
	count += 1
	update_text()

func reset():
	count = 0
	update_text()

func update_text():
	$UiTumbleweedIcon/Label.text = "%d / %d" % [count, threshold]

func on_tumbleweed_collected():
	increment_and_update()
	$AnimationPlayer.play("show")
