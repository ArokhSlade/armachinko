extends Node3D

func _ready():
	play()

func play():
	#$AnimationPlayer.play("tutorial_box")
	$Timer.start()


func _on_timer_timeout():
	hide()
