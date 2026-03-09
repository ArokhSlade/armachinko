extends Node3D

func play_animation():
	for coin in get_children():
		coin.set("emitting", true)
