extends Node3D
class_name Effect

@export var active_on_bounce = true
@export var active_on_blast = false


func on_bounced(body):
	print(body, " bounced ", name)

func on_blasted(area):
	print(area, " blased ", name)
