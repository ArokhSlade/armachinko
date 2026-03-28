extends Node2D
class_name FeedbackMessage

signal message_started
signal message_finished

func tigger_reward():
	message_started.emit()
	show()
	$AnimationPlayer.play("feedback_message")
	

func _on_animation_player_animation_finished(_anim_name):
	hide()
	message_finished.emit()
