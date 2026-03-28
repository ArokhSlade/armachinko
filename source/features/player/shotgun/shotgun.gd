extends Node3D

@export var blast_scene : PackedScene = load("res://features/player/shotgun/shotgun_blast.tscn")
@export var wielder : Node ## who wields this gun? (the player)

var animation_player1

enum ReloadMode {
	RELOAD_SHELL_EACH, #0
	RELOAD_SHELL_ALL, #1
	PRESS_TO_RELOAD
}
@export var reload_mode : ReloadMode
@export var infinite_ammo : bool
@onready var ammo_now = ammo_max
@onready var ammo_charge_timer = $AmmoChargeTimer
@onready var shoot_sfx = $SFX/Shoot
@onready var reload_sfx = $SFX/Reload
@export var ammo_max :int = 1
@export var reload_time : float = 1 : ## Reload Speed in Seconds
	set(value):
		reload_time = value
		if is_inside_tree():
			ammo_charge_timer.wait_time = value

func _ready():
	ammo_charge_timer.wait_time = reload_time

	
func shoot():
	if not has_ammo():
			#play empy_gun sound 
			return
	
	spawn_blast()
	
	
	animation_player1.play("Shot__reaction")
	ammo_now = clampi(ammo_now-1, 0, ammo_max)
	shoot_sfx.play()
	$AnimationPlayer.play("reload")


	if ammo_charge_timer.is_stopped():
		if reload_mode == ReloadMode.RELOAD_SHELL_EACH:
				ammo_charge_timer.start()
		elif reload_mode == ReloadMode.RELOAD_SHELL_ALL:
			if ammo_now <= 0:
				ammo_charge_timer.start()
		else:
			push_error("UNEXPECTED CASE IN SHOOT")

func has_ammo() -> bool:
	return ammo_now > 0 or infinite_ammo

func modify_ammo(value : int):
	ammo_now = clampi(ammo_now+value, 0, ammo_max)
	if ammo_now == ammo_max:
		ammo_charge_timer.stop()


func _on_ammo_charge_timer_timeout():
	if not infinite_ammo:
		if reload_mode == 0:
			reload_sfx.play()
			modify_ammo(1)

		elif reload_mode == 1:
			reload_sfx.play()
			modify_ammo(ammo_max)

#TODO(Gerald): replace with signals?
func get_animationplayer_from_player(p_animation_player1):
	self.animation_player1 = p_animation_player1


func spawn_blast():
	
	var blast = blast_scene.instantiate()
	blast.setup(wielder)
	var blast_parent = Globals.get_level().get_new_parent_for_spawned_object(self, blast)
	blast_parent.add_child(blast)
	blast.global_position = $ShotgunSpawner.global_position
	blast.global_rotation.z = $ShotgunSpawner.global_rotation.z
	blast.activate()
