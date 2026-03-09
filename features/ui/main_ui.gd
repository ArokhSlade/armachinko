extends CanvasLayer

@export var title_screen_path : String = "res://features/ui/menu/title_screen.tscn"

signal time_zone_changed_to(new_time_zone)

enum TimeZone {
	SAFE,
	UNSAFE,
	DANGER
}
var time_zone = TimeZone.SAFE
var show_once = false # let the animation_play play the game_over screen once
var opened_tab = false # if for example settings is opened
var score : int
var game_running = false # player is alive and can open pause menu.
#TODO: replace with game states: TUTORIAL -> GAME_PLAYING -> GAME_PAUSE -> GAME_OVER

@onready var animation_player = $AnimationPlayer
@onready var score_label = $HUD/ScoreDisplay/ScoreLabel
@onready var score_display = $HUD/ScoreDisplay
#Pause_Tab
@onready var pause_menu = $PauseMenu
@onready var pause_tab = $PauseMenu/PauseTab
@onready var settings_tab = $PauseMenu/SettingsTab
@onready var current_score_display = $PauseMenu/PauseTab/Score
#Game_Over
@onready var game_over_screen = $GameOverScreen
@onready var game_over_score_label = $GameOverScreen/GameOverSign/ScoreNumber
@onready var retry_button = $GameOverScreen/GameOverSign/Buttons/RetryButton
@onready var back_to_menu_button = $GameOverScreen/GameOverSign/Buttons/BackToMenuButton
#Countdown/HUD
@export_range(0, 999, 0.1) var countdown_time = 200
@export var not_much_time_left_indicator = 30
@export var last_seconds_indicator = 10
@onready var hud = $HUD
@onready var countdown_label = $HUD/Countdown/Timer/UiIconTimerGreenGlow/Time
@onready var countdown_timer = $HUD/Countdown/CountdownTimer
@onready var countdown_animation_player = $HUD/Countdown/Timer/AnimationPlayer
#events
@export var avalanche_event : Milestone

func _ready():
	$Vignette.get_vignette().hide()
	$TutorialMusicPlayer.play()
	$TutorialOverlay.show()
	get_tree().paused = true 
	if  avalanche_event:
		$TumbleweedCounter.threshold = avalanche_event.threshold
	else:
		push_error("Remember to set avalanche event so tumbleweed counter knows threshold")
		
		
#__________________Pause_Tab___________________#

func start_game():
	get_tree().paused = false 
	countdown_timer.wait_time = countdown_time
	countdown_timer.start()
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
	$HUD.show()


func on_tutorial_dismissed():
	if game_running == false: 
		game_running = true
		$BackgroundMusicPlayer.play()
		$TutorialMusicPlayer.stop()
		$TutorialOverlay.hide()
		start_game()

func update_pause_menu():
	if game_running:
		if Input.is_action_just_pressed("pause_button") and not get_tree().paused:
			pause_menu.open()
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
			hud.hide()
			opened_tab = true
			countdown_timer.paused = true
			get_tree().paused = true


func _on_continue_button_pressed() -> void:
	pause_menu.hide()
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
	opened_tab = false
	get_tree().paused = false
	hud.show()
	countdown_timer.paused = false
 
#__________________GameOverScreen___________________#

func _on_player_died() -> void:
	if !show_once:
		$Vignette.get_anim_player().stop()
		$Vignette.get_vignette().hide()
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		show_once = true
		game_running = false
		print("Game is over!")
		game_over_screen.show()
		game_over_screen.update_contents(PlayerData.data)
		animation_player.play("sliding_game_over_board")
		opened_tab = true
		countdown_timer.stop()
		hud.hide()		
		$BackgroundMusicPlayer.stop()
		get_tree().paused = true
		$GameOverScreen/GameOverMusic.play(3)
		if score == 0:
			_on_player_forward_score_changed(0)
		PlayerData.save_player()

func _on_button_shower_timeout() -> void:
	retry_button.show()
	$GameOverSign/Buttons/RetryButton.grab_focus()
	back_to_menu_button.show()


func _on_back_to_menu_button_pressed() -> void:	
	get_tree().paused = false
	Globals.unset_fresh_session()
	get_tree().change_scene_to_file(title_screen_path)


func retry_game() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()


func quit_to_menu() -> void:
	get_tree().paused = false
	Globals.update_highscore_data(PlayerData.data)	
	Globals.unset_fresh_session()
	get_tree().change_scene_to_file(title_screen_path)


#__________________Score_Display___________________#

func _on_player_forward_score_changed(new_value : Variant) -> void:
	score = new_value
	score_label.text = str("Bounty: ", score,"$")
	game_over_score_label.text = str(score,"$")
	current_score_display.text = str(score, "$")
	PlayerData.data.score = score

#__________________Countdown_Timer___________________#

func _process(_delta: float) -> void:
	if opened_tab:
		$Backround.show()
	else:
		$Backround.hide()

	update_pause_menu()
	countdown_label.text = str(snapped(countdown_timer.time_left, 1))

	if game_running:
		match time_zone:
			TimeZone.SAFE:			
				if countdown_timer.time_left <= not_much_time_left_indicator :
					time_zone = TimeZone.UNSAFE
					countdown_animation_player.play("fade_red")
					time_zone_changed_to.emit("UNSAFE")
					$Vignette.get_vignette().show()
			TimeZone.UNSAFE:			
				if countdown_timer.time_left > not_much_time_left_indicator:
					time_zone = TimeZone.SAFE
					countdown_animation_player.play("fade_green")
					time_zone_changed_to.emit("SAFE")
					$Vignette.get_vignette().hide()
					$Vignette.get_anim_player().stop()
				elif countdown_timer.time_left <= last_seconds_indicator:
					time_zone = TimeZone.DANGER
					$Vignette.get_vignette().show()
					$Vignette.get_anim_player().play("vignette_timer")
					print($Vignette.get_anim_player())
					countdown_animation_player.play("hand_turning_loop")
			TimeZone.DANGER:
				if countdown_timer.time_left > not_much_time_left_indicator:
					time_zone = TimeZone.SAFE
					time_zone_changed_to.emit("SAFE")
					countdown_animation_player.play("fade_green")
					$Vignette.get_anim_player().stop()
					$Vignette.get_vignette().hide()
				elif countdown_timer.time_left > last_seconds_indicator:
					time_zone = TimeZone.UNSAFE
					countdown_animation_player.play("fade_red")
					$Vignette.get_anim_player().stop()

func _on_countdown_timer_timeout() -> void:
	_on_player_died()


func on_tumbleweed_collected():
	$TumbleweedCounter.on_tumbleweed_collected()	

func on_tumbleweed_threshold_hit():
	$TumbleweedCounter.reset()

func add_bonus_time(amount):
	countdown_timer.start(countdown_timer.time_left + amount)

func hide_hud():
	$HUD.hide()
	
func show_hud():
	$HUD.show()

func _on_explosion_pin_milestone_progress_changed() -> void:
	$ExplosionPinCounter.on_collected()

func _on_coin_milestone_progress_changed() -> void:
	$CoinCounter.on_collected()

func _on_enemy_milestone_progress_changed() -> void:
	$EnemyCounter.on_collected()


func _on_cactus_bumper_milestone_progress_changed() -> void:
	$CactusPinCounter.on_collected()
