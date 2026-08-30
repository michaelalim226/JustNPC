extends Node2D

## ========================================================
## MAIN — Egg Hunt Arcade
## Controller utama: HUD, overlay screens, audio, game flow
## ========================================================

## ---- HUD Elements ----
@onready var score_label: Label      = $HUD/TopHUD/MarginContainer/HBoxContainer/ScoreSection/ScoreValue
@onready var gem_label: Label        = $HUD/TopHUD/MarginContainer/HBoxContainer/GemSection/GemValue
@onready var time_label: Label       = $HUD/TopHUD/MarginContainer/HBoxContainer/TimeSection/TimeValue
@onready var heart_1: TextureRect    = $HUD/TopHUD/MarginContainer/HBoxContainer/LifeSection/Hearts/Heart1
@onready var heart_2: TextureRect    = $HUD/TopHUD/MarginContainer/HBoxContainer/LifeSection/Hearts/Heart2
@onready var heart_3: TextureRect    = $HUD/TopHUD/MarginContainer/HBoxContainer/LifeSection/Hearts/Heart3

## ---- Overlay Screens ----
@onready var main_menu_screen: Control      = $HUD/MainMenuScreen
@onready var level_complete_screen: Control = $HUD/LevelCompleteScreen
@onready var game_over_screen: Control      = $HUD/GameOverScreen
@onready var pause_screen: Control          = $HUD/PauseScreen
@onready var screen_flash: ColorRect        = $HUD/ScreenFlash

## ---- Level Complete Labels ----
@onready var lc_score_label: Label      = $HUD/LevelCompleteScreen/Panel/VBoxContainer/StatsContainer/LCScore
@onready var lc_gems_label: Label       = $HUD/LevelCompleteScreen/Panel/VBoxContainer/StatsContainer/LCGems
@onready var lc_time_label: Label       = $HUD/LevelCompleteScreen/Panel/VBoxContainer/StatsContainer/LCTime

## ---- Game Over Labels ----
@onready var go_score_label: Label      = $HUD/GameOverScreen/Panel/VBoxContainer/StatsContainer/GOScore
@onready var go_gems_label: Label       = $HUD/GameOverScreen/Panel/VBoxContainer/StatsContainer/GOGems

## ---- Audio ----
@onready var bgm_player: AudioStreamPlayer      = $BGMPlayer
@onready var sfx_level_complete: AudioStreamPlayer = get_node_or_null("SfxLevelComplete")
@onready var sfx_game_over_sound: AudioStreamPlayer = get_node_or_null("SfxGameOver")

## Texture untuk hati
const HEART_FULL  = preload("res://assets/sprites/heart_full.png")
const HEART_EMPTY = preload("res://assets/sprites/heart_empty.png")

var _gm: Node  ## Referensi GameManager

func _ready() -> void:
	_gm = get_node_or_null("/root/GameManager")
	if not _gm:
		push_error("[Main] GameManager tidak ditemukan!")
		return
	
	## Hubungkan semua sinyal GameManager
	_gm.state_changed.connect(_on_state_changed)
	_gm.gem_collected.connect(_on_gem_collected)
	_gm.score_changed.connect(_on_score_changed)
	_gm.player_damaged.connect(_on_player_damaged)
	_gm.time_up.connect(_on_time_up)
	_gm.all_gems_collected.connect(_on_all_gems_collected)
	
	## Sembunyikan semua overlay kecuali Main Menu
	_hide_all_overlays()
	main_menu_screen.visible = true
	
	## Inisialisasi HUD
	_update_hud_initial()
	
	## Screen flash masuk
	if screen_flash:
		screen_flash.color = Color(0, 0, 0, 1)
		screen_flash.visible = true
		var tween := create_tween()
		tween.tween_property(screen_flash, "modulate:a", 0.0, 1.0)
	
	if bgm_player and not bgm_player.playing:
		bgm_player.play()

func _process(_delta: float) -> void:
	## Update timer display setiap frame saat playing
	if _gm and _gm.current_state == _gm.GameState.PLAYING:
		_update_timer_display()

func _unhandled_input(event: InputEvent) -> void:
	## ESC untuk pause/resume
	if event.is_action_pressed("ui_cancel"):
		if _gm:
			match _gm.current_state:
				_gm.GameState.PLAYING:
					_gm.pause_game()
				_gm.GameState.PAUSED:
					_gm.resume_game()

## ========================
## HUD UPDATES
## ========================

func _update_hud_initial() -> void:
	if score_label:
		score_label.text = "000000"
	if gem_label:
		gem_label.text = "00/10"
	if time_label:
		time_label.text = "03:00"
		time_label.add_theme_color_override("font_color", Color(0.3, 1.0, 0.3, 1.0))
	_update_hearts(3, 3)

func _update_timer_display() -> void:
	if not time_label or not _gm:
		return
	time_label.text = _gm.get_time_string()
	
	## Warna timer berubah berdasarkan sisa waktu
	var t: float = _gm.time_remaining
	if t > 60.0:
		time_label.add_theme_color_override("font_color", Color(0.3, 1.0, 0.3, 1.0))  ## Hijau
	elif t > 30.0:
		time_label.add_theme_color_override("font_color", Color(1.0, 0.9, 0.1, 1.0))  ## Kuning
	else:
		## Merah berkedip saat < 30 detik
		var blink: float = abs(sin(Time.get_ticks_msec() * 0.006))
		time_label.add_theme_color_override("font_color", Color(1.0, blink * 0.3, blink * 0.1, 1.0))

func _update_hearts(current: int, maximum: int) -> void:
	var hearts: Array = [heart_1, heart_2, heart_3]
	for i in range(hearts.size()):
		if not hearts[i]:
			continue
		if i < current:
			hearts[i].texture = HEART_FULL
		else:
			hearts[i].texture = HEART_EMPTY

func _on_gem_collected(current: int, total: int, _score_value: int) -> void:
	if gem_label:
		gem_label.text = "%02d/%02d" % [current, total]
	## Efek bounce pada gem counter
	if gem_label:
		var tween := gem_label.create_tween()
		tween.tween_property(gem_label, "scale", Vector2(1.4, 1.4), 0.1)
		tween.tween_property(gem_label, "scale", Vector2(1.0, 1.0), 0.15)

func _on_score_changed(new_score: int) -> void:
	if score_label:
		score_label.text = "%06d" % new_score

func _on_player_damaged(current_health: int, max_health: int) -> void:
	_update_hearts(current_health, max_health)
	_flash_screen(Color(1, 0, 0, 0.35), 0.25)

func _on_time_up() -> void:
	pass  ## Game state change akan di-handle di _on_state_changed

func _on_all_gems_collected() -> void:
	_flash_screen(Color(0.2, 1.0, 1.0, 0.5), 0.5)

## ========================
## STATE CHANGES
## ========================

func _on_state_changed(old_state, new_state) -> void:
	match new_state:
		_gm.GameState.PLAYING:
			_hide_all_overlays()
		
		_gm.GameState.PAUSED:
			pause_screen.visible = true
		
		_gm.GameState.LEVEL_COMPLETE:
			_show_level_complete()
		
		_gm.GameState.GAME_OVER:
			_show_game_over()

func _show_level_complete() -> void:
	_hide_all_overlays()
	_play_victory_sound()
	_flash_screen(Color(1, 1, 0.5, 0.7), 0.8)
	
	## Update labels
	if lc_score_label and _gm:
		lc_score_label.text = "SCORE: %s" % _gm.get_score_string()
	if lc_gems_label and _gm:
		lc_gems_label.text = "GEMS: %d/%d" % [_gm.gems_collected, _gm.total_gems]
	if lc_time_label and _gm:
		lc_time_label.text = "TIME LEFT: %s" % _gm.get_time_string()
	
	## Tunda tampilkan screen sebentar untuk efek
	await get_tree().create_timer(0.6).timeout
	level_complete_screen.visible = true

func _show_game_over() -> void:
	_hide_all_overlays()
	_play_gameover_sound()
	_flash_screen(Color(0.5, 0, 0, 0.6), 0.5)
	
	if go_score_label and _gm:
		go_score_label.text = "SCORE: %s" % _gm.get_score_string()
	if go_gems_label and _gm:
		go_gems_label.text = "GEMS FOUND: %d/%d" % [_gm.gems_collected, _gm.total_gems]
	
	await get_tree().create_timer(0.7).timeout
	game_over_screen.visible = true

func _hide_all_overlays() -> void:
	if main_menu_screen:
		main_menu_screen.visible = false
	if level_complete_screen:
		level_complete_screen.visible = false
	if game_over_screen:
		game_over_screen.visible = false
	if pause_screen:
		pause_screen.visible = false

## ========================
## SCREEN FLASH
## ========================

func _flash_screen(color: Color, duration: float) -> void:
	if not screen_flash:
		return
	screen_flash.color = color
	screen_flash.modulate.a = 1.0
	screen_flash.visible = true
	var tween := create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property(screen_flash, "modulate:a", 0.0, duration)

## ========================
## AUDIO
## ========================

func _play_victory_sound() -> void:
	if sfx_level_complete and sfx_level_complete.stream:
		sfx_level_complete.play()
	if bgm_player and bgm_player.playing:
		var tween := create_tween()
		tween.tween_property(bgm_player, "volume_db", -40.0, 1.5)

func _play_gameover_sound() -> void:
	if sfx_game_over_sound and sfx_game_over_sound.stream:
		sfx_game_over_sound.play()
	if bgm_player and bgm_player.playing:
		var tween := create_tween()
		tween.tween_property(bgm_player, "volume_db", -40.0, 1.5)

## ========================
## BUTTON HANDLERS
## ========================

## Main Menu
func _on_start_button_pressed() -> void:
	if _gm:
		_gm.start_game()
	if bgm_player:
		bgm_player.volume_db = -10.0

## Level Complete
func _on_lc_play_again_pressed() -> void:
	if _gm:
		_gm.restart_level()

func _on_lc_main_menu_pressed() -> void:
	if _gm:
		_gm.restart_level()  ## Restart akan reset ke MENU state

## Game Over
func _on_go_retry_pressed() -> void:
	if _gm:
		_gm.restart_level()

func _on_go_main_menu_pressed() -> void:
	if _gm:
		_gm.restart_level()

## Pause
func _on_resume_pressed() -> void:
	if _gm:
		_gm.resume_game()

func _on_pause_restart_pressed() -> void:
	if _gm:
		_gm.restart_level()

func _on_quit_pressed() -> void:
	get_tree().quit()
