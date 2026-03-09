extends Node2D

@export var threshold : int
var count : int = 0

enum CounterState {
	AWAY,
	ARRIVING,
	LEAVING
	
}
var state = CounterState.AWAY

func _ready():
	update_text()

func increment_and_update():
	count += 1
	update_text()

func reset():
	count = 0

func update_text():
	$Icon/Label.text = "x%d" % [count]

func on_collected():
	increment_and_update()
	match state:
		CounterState.AWAY:
			arrive()
		CounterState.ARRIVING:
			pass
		CounterState.LEAVING:
			arrive()

func arrive():
	show()
	$AnimationPlayer.play("show_counter")
	
func leave():
	state = CounterState.LEAVING
	$AnimationPlayer.play("hide_counter")
	
func begone():
	state = CounterState.AWAY
	
func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	match anim_name:
		&"show_counter":
			leave()
		&"hide_counter":
			begone()
