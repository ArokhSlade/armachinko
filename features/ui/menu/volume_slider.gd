@tool
extends HSlider

@export var knob_texture_normal : CompressedTexture2D
@export var knob_texture_highlight : CompressedTexture2D

func _ready():	
	update_slider_position()

func set_slider_position(new_value):
	var new_pos_x = normalize(new_value) * $MotionRange.size.x
	$MotionRange/Knob.position.x = new_pos_x


func normalize(absolute_value):
	var normalized_value = inverse_lerp(min_value, max_value, absolute_value)
	return normalized_value
	

func update_slider_position():
	set_slider_position(value)


func _on_value_changed(new_value):
	set_slider_position(new_value)


func _on_mouse_entered():
	$MotionRange/Knob/KnobImageHighlight.show()


func _on_mouse_exited():
	$MotionRange/Knob/KnobImageHighlight.hide()
