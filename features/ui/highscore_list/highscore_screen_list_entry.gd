extends TextureRect

@export var data : SavedScore
@export var background_images : Array[CompressedTexture2D]

@onready var rank_label =  $HBoxContainer/Rank
@onready var name_label =  $HBoxContainer/Name
@onready var score_label = $HBoxContainer/Score



func _ready():
	setup()
	texture = background_images[randi() % background_images.size()]

func update(new_data):
	set_data(new_data)
	update_text()

func clear():
	data = null
	rank_label.text = ""	
	name_label.text = ""	
	score_label.text = ""	

func update_text():
	
	rank_label.text = str(data.rank)
	name_label.text = str(data.name)
	score_label.text = str(data.score)
	var hbox = $HBoxContainer
	var target_width = hbox.size.x
	UIHelperFunctions.scale_multiple_to_target([rank_label, name_label, score_label], target_width)
	

func set_data(new_data):
	data = new_data

func setup():
	rank_label =  $HBoxContainer/Rank
	name_label =  $HBoxContainer/Name
	score_label = $HBoxContainer/Score
