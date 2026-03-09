extends Milestone


@export var group_name : StringName
@export var counted_signal : StringName ## the name of the event emitted by children that count towards the milestone. the signal must have ZERO aguments.

func setup():
	if not get_tree().has_group(group_name):
		push_error("remember to set up a valid group for group milestone (group %s doesn't exist)" % group_name)
	for node in get_tree().get_nodes_in_group(group_name):
		if node.has_signal(counted_signal):
			node.connect(counted_signal, advance_progress)
		else:
			push_error("signal %s does not exist in node %s from group %s" % [counted_signal, node.name, group_name])	
