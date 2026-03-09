extends Node
class_name Milestone

signal threshold_hit
signal progress_changed

@export var threshold : int ## how many times must the listened event be received to trigger the multiplier?

var progress = 0
var active = true


func setup():
	pass

func _ready():
	if threshold <= 0:
		push_error("threshold must be at least 1, but is %d" % threshold)
	setup()

func advance_progress():
	if not active: 
		return
		
	progress += 1
	progress_changed.emit()
	
	if progress >= threshold:
		hit_threshold()

func hit_threshold():
	threshold_hit.emit()
	disable()

func disable():
	active = false
