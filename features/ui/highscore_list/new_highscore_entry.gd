extends Control

func activate():
	if Globals.new_score_added:
		show()
		$AnimationPlayer.play("new_entry_wiggle")

func deactivate():
	hide()
