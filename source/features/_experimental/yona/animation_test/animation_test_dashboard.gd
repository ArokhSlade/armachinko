extends Control

@onready var animation_player = $"../../AnimationPlayer"



func _on_go_red_pressed():
	animation_player.play("go_red")


func _on_reset_pressed():
	animation_player.play("RESET")


func _on_go_green_pressed():
	animation_player.play("go_green")


func _on_curl_pressed():
	animation_player.play("curl")


func _on_shock_pressed():
	animation_player.play("shock")
