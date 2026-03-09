extends Control

@onready var score_label = $ScoreLabel


func update_score(new_score):
	score_label.text = str("Bounty: ", new_score,"$")
