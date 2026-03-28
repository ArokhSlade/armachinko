extends Node
class_name UIHelperFunctions


static func scale_text(node : Control, step_size = 3.0):
	var outline_size = node["theme_override_constants/outline_size"]
	while get_line_width(node) > node.size.x - outline_size:
		node["theme_override_font_sizes/font_size"] -= step_size

static func get_line_width(node : Control):
	var font : Font = node["theme_override_fonts/font"] 
	var alignment = node.horizontal_alignment
	var font_size = node["theme_override_font_sizes/font_size"] 
	var line_width = font.get_string_size(node.text, alignment, -1, font_size).x
	return line_width

static func get_combined_line_width(nodes : Array[Control]):
	var combined_line_width = 0.0
	for node in nodes:
		combined_line_width += get_line_width(node)
	return combined_line_width

#TODO(Gerald): delete? not used anywhere.
static func scale_multiple_texts(nodes : Array[Control], step_size = 1.0):
	var outline_size = nodes[0]["theme_override_constants/outline_size"]
	var combined_size_x = 0.0
	for node in nodes:
		combined_size_x += node.size.x
	while get_combined_line_width(nodes) > combined_size_x:
		for node in nodes:
			node["theme_override_font_sizes/font_size"] -= step_size
	var last_pos_x = nodes[0].position.x
	for node in nodes:
		node.position.x = last_pos_x
		node.size.x = get_line_width(node) + outline_size
		
		last_pos_x = node.position.x + node.size.x + 1

static func scale_multiple_to_target(nodes : Array[Control], target_width, step_size = 1.0):
	var outline_size = nodes[0]["theme_override_constants/outline_size"]
	
	while get_combined_line_width(nodes) > target_width:
		for node in nodes:
			node["theme_override_font_sizes/font_size"] -= step_size
	
	for node in nodes:
		node.custom_minimum_size.x = get_line_width(node) + outline_size
