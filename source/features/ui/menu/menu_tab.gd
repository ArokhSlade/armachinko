extends TextureRect
class_name MenuTab

signal opened
signal closed

@export var initial_focus : Control
@export var tab_anim_name : StringName

var active = false
var animation_player

func activate():
	active = true
	initial_focus.grab_focus()
	
func deactivate():
	active = false
	
func close():
	if animation_player and animation_player.has_animation(tab_anim_name):
		animation_player.play_backwards(tab_anim_name)
	else:
		hide()
	deactivate()
	closed.emit()	

func open():
	opened.emit()
	activate()
	show()
	if animation_player and animation_player.has_animation(tab_anim_name):
		animation_player.play(tab_anim_name)

func set_animation_player(p_animation_player):
	self.animation_player = p_animation_player


func _ready():
	gui_input.connect(on_subtree_gui_input)
	set_up_listener_for_subtree_gui_input(self, on_subtree_gui_input)

func set_up_listener_for_subtree_gui_input(node : Control, listener : Callable):
	for child in node.get_children():
		if child.has_signal("gui_input"):
			child.gui_input.connect(listener)
			set_up_listener_for_subtree_gui_input(child, listener)

func on_subtree_gui_input(event : InputEvent):
	if event.is_action_pressed("ui_cancel"):
		close()
