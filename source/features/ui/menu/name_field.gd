extends HBoxContainer

func _ready():
	update()
	
func update():
	if PlayerData.is_valid():
		$Username.text = PlayerData.data.name
	visible = PlayerData.is_valid()
	
