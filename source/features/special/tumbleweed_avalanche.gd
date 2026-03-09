extends Milestone

@export var spawn_rate_multiplier = 20.0
@export var avalanche_duration = 3.0

var avalanche_timer : Timer

func reset():
	change_spawn_rates(1.0 / spawn_rate_multiplier)	
	progress = 0
	active = true
	link_with_spawners()

func unlink_with_spawners():
	for spawner in get_tree().get_nodes_in_group("TumbleweedSpawners"):
		spawner.spawned.disconnect(register_tumbleweed)

func link_with_spawners():
	for spawner in get_tree().get_nodes_in_group("TumbleweedSpawners"):
		spawner.spawned.connect(register_tumbleweed)

func register_tumbleweed(new_tumbleweed):
	new_tumbleweed.bounced.connect(advance_progress)
	
func _ready():
	super()
	setup_timer()
	link_with_spawners()

func hit_threshold():
	threshold_hit.emit()
	disable()
	activate_avalanche()
	
func activate_avalanche():
	unlink_with_spawners()
	change_spawn_rates(spawn_rate_multiplier)
	avalanche_timer.start(avalanche_duration)

func change_spawn_rates(new_spawn_rate_multiplier):
	for spawner in get_tree().get_nodes_in_group("TumbleweedSpawners"):
		spawner.min_delay *= 1.0 / new_spawn_rate_multiplier
		spawner.max_delay *= 1.0 / new_spawn_rate_multiplier
		spawner.reset_timer()

func setup_timer():
	avalanche_timer = Timer.new()	
	avalanche_timer.one_shot = true
	avalanche_timer.timeout.connect(reset)
	add_child(avalanche_timer)
