extends Node

@export var user : Node


func time_stop(duration):
	user.process_mode = Node.PROCESS_MODE_DISABLED
	var timer = get_tree().create_timer(duration,true,false,true)
	await(timer)
	
