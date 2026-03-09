extends Milestone
## observed nodes are its children

@export var counted_signal : StringName ## the name of the event emitted by children that count towards the milestone. the signal must have ZERO aguments.

func setup():
	if counted_signal == null or counted_signal == "":
		push_error("missing counted_signal")
		return

	for node in get_children():		
		if node.has_signal(counted_signal):
			node.connect(counted_signal, advance_progress)
		else:
			push_error("milestone error: signal %s does not exist in child %s" % [counted_signal, node.name])	
	
