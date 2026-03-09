extends FeedbackMessage


@export var player : Node
var score_keeper

func _ready():	
	assert(player, "remember to set the player reference")
	if player.has_method("get_score_keeper"):
		score_keeper = player.get_score_keeper() #this can fail when player's ready wasn't called yet

func tigger_reward():	
	if score_keeper == null:
		score_keeper = player.get_score_keeper()
	score_keeper.increment_multiplier()
	var multiplier = score_keeper.get_multiplier()
	$ScoreMilestoneMessage2/MultiplierNumber.text = str(multiplier,"x")
	super()
