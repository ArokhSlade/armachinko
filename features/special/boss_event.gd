extends Node

signal condition_fulfilled

@export var required_bounced_pins : Array[Node]
var already_bounced_pins : Array[Node]
@export var boss : AnimatablePin
@export var despawn_on_start = false
func _ready():
	if despawn_on_start:
		boss.despawn()
	already_bounced_pins = []
	for pin in required_bounced_pins:
		pin.despawned.connect(on_required_bounce.bind(pin))

func on_required_bounce(pin):
	if pin not in already_bounced_pins:
		already_bounced_pins.append(pin)
		if already_bounced_pins.size() == required_bounced_pins.size():
			condition_fulfilled.emit()



func _on_condition_fulfilled() -> void:
	boss.respawn()
	#$AnimationPlayer.play("SUPERDUPERMEGABOSSSUMMON")
	#$AnimationPlayer2.play("test_spawn_animation_2")
