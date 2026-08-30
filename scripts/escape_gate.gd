extends Area2D

@onready var sprite: Sprite2D = $Sprite2D
@onready var prompt_label: Label = $PromptLabel
@onready var aura_particles: CPUParticles2D = get_node_or_null("AuraParticles")
@onready var sfx_unlock: AudioStreamPlayer2D = get_node_or_null("SfxUnlock")
@onready var sfx_escape: AudioStreamPlayer2D = get_node_or_null("SfxEscape")

@export var tex_closed: Texture2D
@export var tex_open: Texture2D

var is_player_near: bool = false
var is_unlocked: bool = false
var anim_pulse_timer: float = 0.0

func _ready() -> void:
	if not tex_closed:
		tex_closed = load("res://assets/sprites/gate_closed.png")
	if not tex_open:
		tex_open = load("res://assets/sprites/gate_open.png")
		
	if sprite and tex_closed:
		sprite.texture = tex_closed
		
	if prompt_label:
		prompt_label.visible = false
		
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	
	# Dengarkan status unlock dari GameManager
	var gm = get_node_or_null("/root/GameManager")
	if gm and gm.has_signal("all_items_collected"):
		gm.all_items_collected.connect(_on_all_items_collected)

func _process(delta: float) -> void:
	# Efek getar/berkilau halus pada gerbang saat terbuka
	if is_unlocked and sprite:
		anim_pulse_timer += delta * 4.0
		var pulse: float = 1.0 + sin(anim_pulse_timer) * 0.04
		sprite.scale = Vector2(pulse, pulse)

func _unhandled_input(event: InputEvent) -> void:
	if not is_player_near:
		return
		
	if event is InputEventKey and event.pressed and event.keycode == KEY_E:
		get_viewport().set_input_as_handled()
		interact_with_gate()

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") or body.name == "Player":
		is_player_near = true
		_update_prompt()

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player") or body.name == "Player":
		is_player_near = false
		if prompt_label:
			prompt_label.visible = false

func _update_prompt() -> void:
	if not prompt_label:
		return
	var gm = get_node_or_null("/root/GameManager")
	if gm and gm.can_escape():
		prompt_label.text = "Tekan [E] untuk KABUR DARI GAME!"
		prompt_label.modulate = Color(0.4, 1.0, 0.4)
	else:
		var current: int = gm.items_collected if gm else 0
		prompt_label.text = "Gerbang Terkunci! (%d/3 Fragments)" % current
		prompt_label.modulate = Color(1.0, 0.6, 0.4)
	prompt_label.visible = true

func _on_all_items_collected() -> void:
	is_unlocked = true
	if sprite and tex_open:
		sprite.texture = tex_open
		
	if sfx_unlock:
		sfx_unlock.play()
		
	if aura_particles:
		aura_particles.amount = 32
		aura_particles.color = Color(0.3, 0.9, 1.0, 0.8)
		
	if is_player_near:
		_update_prompt()

func interact_with_gate() -> void:
	var gm = get_node_or_null("/root/GameManager")
	var dialog_system = get_tree().root.find_child("DialogSystem", true, false)
	
	if gm and gm.can_escape():
		# Pemain berhasil kabur!
		if sfx_escape:
			sfx_escape.play()
			
		if gm.has_method("request_camera_shake"):
			gm.request_camera_shake(8.0, 0.8)
			
		if dialog_system and dialog_system.has_method("load_and_start_dialog_from_json"):
			dialog_system.load_and_start_dialog_from_json("res://data/dialogs.json", "ending_dialog")
			
		gm.trigger_escape_ending()
	else:
		# Gerbang masih terkunci
		if gm and gm.has_method("request_camera_shake"):
			gm.request_camera_shake(3.0, 0.2)
			
		if dialog_system and dialog_system.has_method("load_and_start_dialog_from_json"):
			dialog_system.load_and_start_dialog_from_json("res://data/dialogs.json", "gate_locked")
