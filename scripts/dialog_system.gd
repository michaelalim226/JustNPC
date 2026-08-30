extends CanvasLayer

## Signal saat dialog dibuka dan ditutup
signal dialog_started
signal dialog_ended

## Referensi node UI
@export var dialog_panel: Control
@export var dialog_label: Label
@export var speaker_label: Label
@export var hint_label: Label
@export var portrait_texture_rect: TextureRect
@export var sfx_dialog: AudioStreamPlayer

## Variabel internal sistem dialog
var dialog_list: Array = []
var current_dialog_index: int = 0
var is_dialog_active: bool = false

## Parameter Typewriter Effect
var full_text_to_display: String = ""
var displayed_char_count: int = 0
var typing_speed: float = 0.025 # detik per karakter
var typing_timer: float = 0.0
var is_typing: bool = false

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	# Otomatis mencari node UI jika belum terhubung
	if not dialog_panel:
		dialog_panel = get_node_or_null("Panel")
	if not dialog_label:
		dialog_label = get_node_or_null("Panel/MarginContainer/HBoxContainer/VBoxContainer/DialogLabel")
		if not dialog_label:
			dialog_label = get_node_or_null("Panel/DialogLabel")
	if not speaker_label:
		speaker_label = get_node_or_null("Panel/MarginContainer/HBoxContainer/VBoxContainer/SpeakerLabel")
	if not hint_label:
		hint_label = get_node_or_null("Panel/MarginContainer/HBoxContainer/VBoxContainer/HintLabel")
	if not portrait_texture_rect:
		portrait_texture_rect = get_node_or_null("Panel/MarginContainer/HBoxContainer/Portrait")
	if not sfx_dialog:
		sfx_dialog = get_node_or_null("SfxDialog")
		
	if dialog_panel:
		dialog_panel.visible = false
		dialog_panel.modulate = Color(1, 1, 1, 0)

func _process(delta: float) -> void:
	if not is_dialog_active or not is_typing:
		return
		
	typing_timer += delta
	if typing_timer >= typing_speed:
		typing_timer = 0.0
		displayed_char_count += 1
		
		if dialog_label:
			dialog_label.visible_characters = displayed_char_count
			
		# Suara ketik per beberapa karakter
		if displayed_char_count % 2 == 0 and sfx_dialog:
			sfx_dialog.pitch_scale = randf_range(0.95, 1.05)
			sfx_dialog.play()
			
		if displayed_char_count >= full_text_to_display.length():
			_finish_typing()

func _unhandled_input(event: InputEvent) -> void:
	if not is_dialog_active:
		return
		
	# Tombol E, Spasi, Enter, atau Klik Kiri
	if event.is_action_pressed("ui_accept") or (event is InputEventKey and event.pressed and event.keycode == KEY_E) or (event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT):
		get_viewport().set_input_as_handled()
		if is_typing:
			# Jika sedang mengetik, langsung tampilkan seluruh teks (Fast Forward)
			_finish_typing()
		else:
			# Jika teks sudah selesai tampil, lanjut ke dialog berikutnya
			next_dialog()
			
	# Tombol ESC untuk menutup / melewati dialog
	elif event.is_action_pressed("ui_cancel") or (event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE):
		get_viewport().set_input_as_handled()
		close_dialog()

## Memulai rangkaian dialog
func start_dialog(dialog_array: Array, speaker_name: String = "NPC Pemalas (Kamu)", portrait_texture: Texture2D = null) -> void:
	if dialog_array.is_empty():
		return
		
	dialog_list = dialog_array
	current_dialog_index = 0
	is_dialog_active = true
	
	if speaker_label:
		speaker_label.text = speaker_name
	if portrait_texture_rect and portrait_texture:
		portrait_texture_rect.texture = portrait_texture
		portrait_texture_rect.visible = true
	elif portrait_texture_rect:
		portrait_texture_rect.visible = (portrait_texture_rect.texture != null)
		
	# Pause game agar interaksi berhenti
	get_tree().paused = true
	
	if dialog_panel:
		dialog_panel.visible = true
		var tween = create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
		tween.tween_property(dialog_panel, "modulate:a", 1.0, 0.2)
		
	_show_current_dialog()
	dialog_started.emit()
	
	var gm = get_node_or_null("/root/GameManager")
	if gm and gm.has_method("change_state"):
		gm.change_state(gm.GameState.DIALOG)

## Menampilkan teks saat ini dengan efek typewriter
func _show_current_dialog() -> void:
	if current_dialog_index >= 0 and current_dialog_index < dialog_list.size():
		full_text_to_display = str(dialog_list[current_dialog_index])
		displayed_char_count = 0
		is_typing = true
		typing_timer = 0.0
		
		if dialog_label:
			dialog_label.text = full_text_to_display
			dialog_label.visible_characters = 0
			
		if hint_label:
			if current_dialog_index == dialog_list.size() - 1:
				hint_label.text = "[E / Klik] Selesai | [ESC] Tutup"
			else:
				hint_label.text = "[E / Klik] Lanjut (%d/%d) | [ESC] Lewati" % [current_dialog_index + 1, dialog_list.size()]

func _finish_typing() -> void:
	is_typing = false
	if dialog_label:
		dialog_label.visible_characters = -1

## Berpindah ke dialog berikutnya
func next_dialog() -> void:
	if not is_dialog_active:
		return
		
	current_dialog_index += 1
	if current_dialog_index < dialog_list.size():
		_show_current_dialog()
	else:
		close_dialog()

## Menutup panel dialog
func close_dialog() -> void:
	if not is_dialog_active:
		return
		
	is_dialog_active = false
	current_dialog_index = 0
	is_typing = false
	
	if dialog_panel:
		var tween = create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
		tween.tween_property(dialog_panel, "modulate:a", 0.0, 0.15)
		tween.tween_callback(func(): dialog_panel.visible = false)
		
	get_tree().paused = false
	dialog_ended.emit()
	
	var gm = get_node_or_null("/root/GameManager")
	if gm and gm.has_method("change_state") and gm.current_state != gm.GameState.GAME_OVER:
		gm.change_state(gm.GameState.PLAYING)

## Memuat dialog langsung dari JSON
func load_and_start_dialog_from_json(json_path: String, key: String, speaker_name: String = "NPC Pemalas (Kamu)", portrait: Texture2D = null) -> void:
	if not FileAccess.file_exists(json_path):
		push_error("File dialog tidak ditemukan: " + json_path)
		return
		
	var file = FileAccess.open(json_path, FileAccess.READ)
	var json_text = file.get_as_text()
	file.close()
	
	var json = JSON.new()
	var parse_result = json.parse(json_text)
	if parse_result == OK:
		var data = json.data
		if data is Dictionary and data.has(key):
			var content = data[key]
			if content is Array:
				start_dialog(content, speaker_name, portrait)
			elif content is String:
				start_dialog([content], speaker_name, portrait)
		else:
			push_error("Key dialog tidak ditemukan: " + key)
