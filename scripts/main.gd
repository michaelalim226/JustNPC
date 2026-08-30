extends Node2D

@onready var dialog_system: CanvasLayer = $DialogSystem
@onready var hud: CanvasLayer = $HUD
@onready var item_counter_label: Label = $HUD/TopRightContainer/ItemCounterPanel/MarginContainer/HBoxContainer/CountLabel
@onready var slot1: TextureRect = $HUD/TopRightContainer/ItemCounterPanel/MarginContainer/HBoxContainer/Slot1
@onready var slot2: TextureRect = $HUD/TopRightContainer/ItemCounterPanel/MarginContainer/HBoxContainer/Slot2
@onready var slot3: TextureRect = $HUD/TopRightContainer/ItemCounterPanel/MarginContainer/HBoxContainer/Slot3
@onready var toast_panel: PanelContainer = $HUD/ToastPanel
@onready var toast_label: Label = $HUD/ToastPanel/MarginContainer/ToastLabel
@onready var pause_menu: Control = $HUD/PauseMenu
@onready var screen_flash: ColorRect = $HUD/ScreenFlash
@onready var bgm_player: AudioStreamPlayer = $BGMPlayer

var toast_tween: Tween

func _ready() -> void:
	# Dengarkan sinyal dari GameManager
	var gm = get_node_or_null("/root/GameManager")
	if gm:
		gm.item_collected.connect(_on_item_collected)
		gm.toast_requested.connect(show_toast)
		gm.state_changed.connect(_on_game_state_changed)
		gm.game_finished.connect(_on_game_finished)
		
	if toast_panel:
		toast_panel.visible = false
		toast_panel.modulate.a = 0.0
		
	if pause_menu:
		pause_menu.visible = false
		
	if screen_flash:
		screen_flash.visible = true
		screen_flash.modulate.a = 1.0 # Fade in dari hitam saat mulai
		var tween = create_tween()
		tween.tween_property(screen_flash, "modulate:a", 0.0, 0.8)
		
	# Mulai BGM
	if bgm_player and not bgm_player.playing:
		bgm_player.play()
		
	# Mulai monolog pembuka
	get_tree().create_timer(0.6).timeout.connect(func():
		if dialog_system:
			dialog_system.load_and_start_dialog_from_json("res://data/dialogs.json", "opening_monologue")
	)

func _on_item_collected(current: int, total: int) -> void:
	if item_counter_label:
		item_counter_label.text = "%d/%d" % [current, total]
		
	# Update visual slot pecahan memori
	if current >= 1 and slot1:
		slot1.modulate = Color(1, 1, 1, 1)
	if current >= 2 and slot2:
		slot2.modulate = Color(1, 1, 1, 1)
	if current >= 3 and slot3:
		slot3.modulate = Color(1, 1, 1, 1)

func show_toast(message: String, duration: float = 2.5) -> void:
	if not toast_panel or not toast_label:
		return
		
	toast_label.text = message
	toast_panel.visible = true
	
	if toast_tween and toast_tween.is_valid():
		toast_tween.kill()
		
	toast_tween = create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	toast_tween.tween_property(toast_panel, "modulate:a", 1.0, 0.25)
	toast_tween.tween_interval(duration)
	toast_tween.tween_property(toast_panel, "modulate:a", 0.0, 0.4)
	toast_tween.tween_callback(func(): toast_panel.visible = false)

func _on_game_state_changed(old_state, new_state) -> void:
	var gm = get_node_or_null("/root/GameManager")
	if not gm:
		return
		
	if pause_menu:
		pause_menu.visible = (new_state == gm.GameState.PAUSED)

func _on_game_finished() -> void:
	# Flash putih kemenangan
	if screen_flash:
		screen_flash.color = Color(1, 1, 1, 1)
		screen_flash.modulate.a = 0.0
		var tween = create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
		tween.tween_property(screen_flash, "modulate:a", 0.9, 0.4)
		tween.tween_property(screen_flash, "modulate:a", 0.0, 1.2)

# Tombol-tombol di Pause Menu
func _on_resume_button_pressed() -> void:
	var gm = get_node_or_null("/root/GameManager")
	if gm:
		gm.resume_game()

func _on_restart_button_pressed() -> void:
	get_tree().paused = false
	var gm = get_node_or_null("/root/GameManager")
	if gm:
		gm.items_collected = 0
		gm.has_escaped = false
		gm.change_state(gm.GameState.PLAYING)
	get_tree().reload_current_scene()

func _on_quit_button_pressed() -> void:
	get_tree().quit()
