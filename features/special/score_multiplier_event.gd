extends Node2D

@export var player : Node
var score_keeper

func _ready():	
	assert(player, "remember to set the player reference")
	if player.has_method("get_score_keeper"):
		score_keeper = player.get_score_keeper()

func activate():	
	score_keeper.increment_multiplier()
	var multiplier = score_keeper.get_multiplier()
	$ScoreMilestoneMessage2/ScoreMultiplier.text = str(multiplier,"x")
	$AnimationPlayer.play("activate")
