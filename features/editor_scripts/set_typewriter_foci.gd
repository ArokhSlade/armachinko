@tool
extends EditorScript

var row_0 = "1234567890"

func _run():
	var selection = EditorInterface.get_selection().get_selected_nodes()
	link_horizontally(selection)

func link_vertically(nodes : Array[Node]):
	var amount = nodes.size()
	var current : Control = nodes[0]	
	var next : Control = nodes[1]
	for index in nodes.size()-1:
		next = nodes[index+1]
		current.focus_neighbor_bottom = current.get_path_to(next)
		next.focus_neighbor_top = next.get_path_to(current)
		current = next		
	var last = nodes[-1]
	var first = nodes[0]
	last.focus_neighbor_bottom = last.get_path_to(first)
	first.focus_neighbor_top = first.get_path_to(last)
	

func link_horizontally(nodes : Array[Node]):	
	var amount = nodes.size()
	var current : Control = nodes[-1]
	for sibling in nodes:
		current.focus_neighbor_left = current.get_path_to(sibling)
		current.focus_next = current.focus_neighbor_left
		sibling.focus_neighbor_right = sibling.get_path_to(current)
		sibling.focus_previous = sibling.focus_neighbor_right
		current = sibling
		
