extends Node

@export var root_node : Node 


@export var highlight_sound : AudioStreamPlayer
@export var menu_click : AudioStreamPlayer


func _ready() -> void:
	assert(root_node != null, "Empty root path for Interface Sounds!")
	install_sounds(root_node)

#Add new ones for other nodes you want sound for
func install_sounds(node: Node) -> void:
	for button in node.get_children():
		if button is Button:
			button.mouse_entered.connect(highlight_sound.play)
			button.focus_entered.connect(highlight_sound.play)
			button.pressed.connect(menu_click.play)
		install_sounds(button)
