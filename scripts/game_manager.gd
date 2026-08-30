extends Node

## ========================================================
## GAME MANAGER — Egg Hunt Arcade
## Autoload singleton yang mengelola state, score, dan event
## ========================================================

enum GameState {
	MENU,
	PLAYING,
	PAUSED,
	LEVEL_COMPLETE,
	GAME_OVER
}

## Sinyal global untuk semua game event
signal state_changed(old_state: GameState, new_state: GameState)
signal gem_collected(current: int, total: int, score_value: int)
signal all_gems_collected
signal time_up
signal player_damaged(current_health: int, max_health: int)
signal player_died
signal score_changed(new_score: int)
signal enemy_killed(score_value: int)
signal camera_shake_requested(intensity: float, duration: float)

## State saat ini
var current_state: GameState = GameState.MENU

## Variabel gameplay
var gems_collected: int = 0
var total_gems: int = 10
var score: int = 0
var time_remaining: float = 180.0  ## 3 menit
var player_health: int = 3
var max_health: int = 3
var is_timer_running: bool = false
var time_bonus_per_second: int = 10  ## Score bonus per detik sisa waktu

func _ready() -> void:
	## GameManager selalu aktif (tidak terpengaruh pause)
	process_mode = Node.PROCESS_MODE_ALWAYS

func _process(delta: float) -> void:
	## Timer countdown hanya saat PLAYING
	if current_state == GameState.PLAYING and is_timer_running:
		time_remaining -= delta
		if time_remaining <= 0.0:
			time_remaining = 0.0
			_trigger_time_up()

## ========================
## GAME FLOW
## ========================

func start_game() -> void:
	gems_collected = 0
	score = 0
	time_remaining = 180.0
	player_health = max_health
	is_timer_running = true
	change_state(GameState.PLAYING)

func _trigger_level_complete() -> void:
	is_timer_running = false
	## Bonus score dari sisa waktu
	var time_bonus: int = int(time_remaining) * time_bonus_per_second
	if time_bonus > 0:
		add_score(time_bonus)
	all_gems_collected.emit()
	change_state(GameState.LEVEL_COMPLETE)

func _trigger_time_up() -> void:
	is_timer_running = false
	time_up.emit()
	change_state(GameState.GAME_OVER)

## ========================
## GEM SYSTEM
## ========================

func collect_gem(score_value: int) -> void:
	if current_state != GameState.PLAYING:
		return
	gems_collected += 1
	add_score(score_value)
	gem_collected.emit(gems_collected, total_gems, score_value)
	if gems_collected >= total_gems:
		_trigger_level_complete()

## ========================
## PLAYER HEALTH
## ========================

func damage_player() -> void:
	if current_state != GameState.PLAYING:
		return
	player_health -= 1
	player_damaged.emit(player_health, max_health)
	request_camera_shake(7.0, 0.45)
	if player_health <= 0:
		player_health = 0
		player_died.emit()
		change_state(GameState.GAME_OVER)

## ========================
## ENEMY & SCORE
## ========================

func kill_enemy(score_value: int) -> void:
	if current_state != GameState.PLAYING:
		return
	add_score(score_value)
	enemy_killed.emit(score_value)

func add_score(amount: int) -> void:
	score += amount
	score_changed.emit(score)

## ========================
## STATE MACHINE
## ========================

func change_state(new_state: GameState) -> void:
	if current_state == new_state:
		return
	var old_state: GameState = current_state
	current_state = new_state
	state_changed.emit(old_state, new_state)

func pause_game() -> void:
	if current_state == GameState.PLAYING:
		change_state(GameState.PAUSED)
		get_tree().paused = true

func resume_game() -> void:
	if current_state == GameState.PAUSED:
		change_state(GameState.PLAYING)
		get_tree().paused = false

func restart_level() -> void:
	get_tree().paused = false
	change_state(GameState.MENU)
	get_tree().reload_current_scene()

## ========================
## UTILS
## ========================

func request_camera_shake(intensity: float = 5.0, duration: float = 0.3) -> void:
	camera_shake_requested.emit(intensity, duration)

func get_time_string() -> String:
	var minutes: int = int(time_remaining) / 60
	var seconds: int = int(time_remaining) % 60
	return "%02d:%02d" % [minutes, seconds]

func get_score_string() -> String:
	return "%06d" % score
