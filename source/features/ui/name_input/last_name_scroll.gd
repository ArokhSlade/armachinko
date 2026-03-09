extends Control

signal name_confirmed
signal rename_requested
@onready var default_font_size_override = $Name["theme_override_font_sizes/font_size"]

func open():
	$ScrollAnimation.play("name_input_pop_up_scroll")
	$StartButton.grab_focus()

func update_name(new_name):
	$Name.text = new_name
	scale_text()

func _on_confirm_button_pressed():
	name_confirmed.emit()


func _on_edit_button_pressed():
	rename_requested.emit()


func scale_text():
	var outline_size = $Name["theme_override_constants/outline_size"]
	while get_line_width() > $Name.size.x - outline_size:
		$Name["theme_override_font_sizes/font_size"] -= 1.0

func get_line_width():
	var font : Font = $Name["theme_override_fonts/font"] 
	var alignment = $Name.horizontal_alignment
	var font_size = $Name["theme_override_font_sizes/font_size"] 	
	var line_width = font.get_string_size($Name.text, alignment, -1, font_size).x	
	return line_width
