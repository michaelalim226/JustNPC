extends Node

## Enum untuk semua status permainan
enum GameState {
	MENU,
	PLAYING,
	DIALOG,
	PAUSED,
	GAME_OVER
}

## Sinyal-sinyal global untuk event permainan
signal state_changed(old_state: GameState, new_state: GameState)
signal item_collected(current: int, total_needed: int)
signal all_items_collected
signal game_finished
signal camera_shake_requested(intensity: float, duration: float)
signal toast_requested(message: String, duration: float)

## State saat ini (default: PLAYING)
var current_state: GameState = GameState.PLAYING

## Variabel pelacak progres game
var items_collected: int = 0
var total_items_needed: int = 3
var has_escaped: bool = false
var game_start_time: float = 0.0

func _ready() -> void:
	# GameManager selalu aktif meskipun game di-pause
	process_mode = Node.PROCESS_MODE_ALWAYS
	game_start_time = Time.get_ticks_msec() / 1000.0
	print("[GameManager] Dimulai. State awal: %s" % _state_to_string(current_state))

func _unhandled_input(event: InputEvent) -> void:
	# Tombol ESC untuk toggle pause menu saat sedang bermain biasa
	if event.is_action_pressed("ui_cancel") or (event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE):
		if current_state == GameState.PLAYING:
			pause_game()
		elif current_state == GameState.PAUSED:
			resume_game()

## Mengubah state permainan
func change_state(new_state: GameState) -> void:
	if current_state == new_state:
		return
		
	var old_state: GameState = current_state
	current_state = new_state
	
	print("[GameManager] State: %s -> %s" % [_state_to_string(old_state), _state_to_string(new_state)])
	state_changed.emit(old_state, new_state)

## Menjeda game (Pause)
func pause_game() -> void:
	if current_state == GameState.PLAYING:
		change_state(GameState.PAUSED)
		get_tree().paused = true

## Melanjutkan game dari jeda (Resume)
func resume_game() -> void:
	if current_state == GameState.PAUSED:
		change_state(GameState.PLAYING)
		get_tree().paused = false

## Mengambil item Memory Fragment
func collect_fragment() -> void:
	items_collected += 1
	print("[GameManager] Memory Fragment diambil (%d/%d)" % [items_collected, total_items_needed])
	item_collected.emit(items_collected, total_items_needed)
	
	# Memicu notifikasi toast
	toast_requested.emit("✨ Memory Fragment [%d/%d] Terkumpul!" % [items_collected, total_items_needed], 2.5)
	
	if items_collected >= total_items_needed:
		all_items_collected.emit()
		toast_requested.emit("🔓 GERBANG DESA TERBUKA! Segera menuju gerbang!", 4.0)
		request_camera_shake(5.0, 0.5)

## Memeriksa apakah pemain sudah memiliki cukup item untuk kabur
func can_escape() -> bool:
	return items_collected >= total_items_needed

## Menandai akhir permainan (Ending / Escape)
func trigger_escape_ending() -> void:
	has_escaped = true
	change_state(GameState.GAME_OVER)
	game_finished.emit()
	print("[GameManager] NPC Berhasil kabur dari game!")

## Memicu efek getar kamera
func request_camera_shake(intensity: float = 6.0, duration: float = 0.35) -> void:
	camera_shake_requested.emit(intensity, duration)

## Mengatur efek slow-motion (game feel)
func set_slow_motion(enabled: bool, scale: float = 0.8) -> void:
	Engine.time_scale = scale if enabled else 1.0

## Helper string representation
func _state_to_string(state: GameState) -> String:
	match state:
		GameState.MENU: return "MENU"
		GameState.PLAYING: return "PLAYING"
		GameState.DIALOG: return "DIALOG"
		GameState.PAUSED: return "PAUSED"
		GameState.GAME_OVER: return "GAME_OVER"
		_: return "UNKNOWN"
