extends Node2D

func show_bonus_time(time_amount):
	show()
	$AnimationPlayer.play("timer_wiggling")
	update_time_label(time_amount)
	#TODO: show time amount

func update_time_label(time_amount):
	$BonusTimetoScore.text = "+ %d time" % time_amount

func _on_animation_player_animation_finished(_anim_name):
	hide()
