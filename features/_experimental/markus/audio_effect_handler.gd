extends Node
# this script handles the behaviour of an audio effect, which is applied dynamically to the music.
# it lowers the gain of upper frequency bands to create a dampening effect
# it fades the gain over time using the tween function
# it gets the AudioServer node using a bus name, effect index, and parameter name.
# it gets the bus the ingame music is routed to
# it gets the effects on that bus by name: eq10(not sure this is the correct name) is an equalizer -> manipulation of 10 single frequency bands
# it gets the effect index
# it gets the effect parameter(s)
# it gets the current gain on the effect parameter(s)
# if pause -> it fades the current value to -3,-6,-12,-16 on the higher bands
# if !pause -> it fades the current value BACK to 0
@export var root_node : Node 
@export var initial_gain : float = 0.0#db
@export var target_gain : float = -20.0 #db
@export var fade_duration : float = 2.0 #seconds
var music_bus_index
func _ready():
	var music_bus_index = AudioServer.get_bus_index("Music")
# cheap variant
func _update():
	AudioServer.set_bus_volume_db(music_bus_index, target_gain)
#var effect_index = 
#var effect_parameter_index
# function to fade

#func fade_gain():
	#var tween = get_tree().create_tween()
	## tween_property(object: Object, property: NodePath, final_val: Variant, duration: float) 
	#tween.tween_property(
		#self,
		#root_node,
		#target_gain,
		#fade_duration
	#).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)
#
	#tween.start()
