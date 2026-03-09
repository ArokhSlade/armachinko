extends Control

@export var data : SavedScore

func update(new_data):
	set_data(new_data)
	update_text()

func clear():
	data = null
	$Name.text = ""
	$Rank.text = ""
	$Score.text = ""

func update_text():
	$Name.text = str(data.name)
	if has_node(^"Rank"):
		$Rank.text = str(data.rank)
	$Score.text = str(data.score)
	var target_width = size.x
	UIHelperFunctions.scale_multiple_to_target([$Rank, $Name, $Score], target_width)
	

func set_data(new_data):
	data = new_data
