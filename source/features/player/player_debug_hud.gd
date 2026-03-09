extends CanvasLayer


func update_values(total_gravity_scale, gravity_scale_from_speed, gravity_scale_from_direction, speed, speed_threshold, angle, direction):
	$VBoxContainer/TotalGravityScale/Value.text = str(total_gravity_scale)
	$VBoxContainer/GravityFromSpeed/Value.text= str(gravity_scale_from_speed)
	$VBoxContainer/GravityFromDirection/Value.text= str(gravity_scale_from_direction)
	$VBoxContainer/Speed/Value.text = str(speed)
	$VBoxContainer/SpeedThreshold/Value.text = str(speed_threshold)
	$VBoxContainer/Angle/Value.text = str(angle)
	$VBoxContainer/Direction/Value.text = str(direction)
