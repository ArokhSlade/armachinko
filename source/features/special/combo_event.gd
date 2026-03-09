extends Node

signal condition_fulfilled

@export var required_bounced_pins : Array[Node]
var already_bounced_pins : Array[Node]

func _ready():
	already_bounced_pins = []
	for pin in required_bounced_pins:
		pin.bounced.connect(on_required_bounce.bind(pin))

func on_required_bounce(pin):
	if pin not in already_bounced_pins:
		already_bounced_pins.append(pin)
		if already_bounced_pins.size() == required_bounced_pins.size():
			condition_fulfilled.emit()



func _on_condition_fulfilled() -> void:
	#$AudioStreamPlayer3D.play()
	$AnimationPlayer.play("Door_Open")
