extends Node3D



@export var speed_to_intensity : Curve
@export var min_speed : float = 40
@export var max_speed : float = 150

func update_from_velocity(velocity):
	var speed = velocity.length()
	align_orientation_with_vector(velocity)
	set_intensity_by_speed(speed)


func align_orientation_with_vector(vector):
	transform.basis.x = vector.normalized()
	transform.basis.z = -Vector3.FORWARD
	transform.basis.y = transform.basis.x.cross(transform.basis.z)
	transform.basis = transform.basis.orthonormalized()


func set_intensity_by_speed(speed):
	var new_intensity = compute_aura_intensity_from_speed(speed)
	set_intensity(new_intensity)
	

func set_intensity(new_intensity):
	assert(new_intensity >= 0.0 and new_intensity <= 1.0)	
	$SpeedAura.material_override.set_shader_parameter("Transparancy", new_intensity)
	$TrailMesh.material_override.set_shader_parameter("trail_transparency", new_intensity)
	#print("Speed Aura Transparancy: ", $SpeedAura.material_override.get_shader_parameter("Transparancy"))


func compute_aura_intensity_from_speed(speed):
	assert(min_speed != max_speed, "min speed should not be the same as max_speed")
	speed = clampf(speed, min_speed, max_speed)
	var speed_normalized = (speed - min_speed) / (max_speed - min_speed)
	var intensity = speed_to_intensity.sample(speed_normalized)
	#print("speed: ", speed, ", intensity: ", intensity)
	return intensity
