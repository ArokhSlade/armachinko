@tool
extends Marker3D

#________camera alignment____________
@export_group("Camera Alignment")
@export var camera_angle = 49.0
@export var z_offset = 4.0

func _ready():
	rotate(Vector3.RIGHT, deg_to_rad(camera_angle))
	
func _physics_process(delta: float) -> void:
	global_position = global_position
	global_rotation = Vector3.ZERO
	$Armadillo.position.z = z_offset
	global_rotation.x = deg_to_rad(camera_angle)
