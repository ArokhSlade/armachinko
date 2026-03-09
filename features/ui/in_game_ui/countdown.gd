extends Control


func _process(delta: float) -> void:
	$Label.text = str(snapped($CountdownTimer.time_left, 1))


func _on_countdown_timer_timeout() -> void:
	get_parent().get_parent()._on_player_died()
