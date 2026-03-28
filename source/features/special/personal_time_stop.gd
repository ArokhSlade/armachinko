extends Node

@export var user : Node

#TODO(Gerald): dead code.
func time_stop(_duration):
	user.process_mode = Node.PROCESS_MODE_DISABLED
	#var timer = get_tree().create_timer(duration,true,false,true)
	#W 0:00:07:0228   "await" keyword not needed in this case, because the expression isn't a coroutine nor a signal.
  	#<GDScript Error>REDUNDANT_AWAIT
	#await(timer)
	
