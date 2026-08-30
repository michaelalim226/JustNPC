extends CharacterBody2D

@export var npc_name: String = "Warga Desa"
@export var dialog_key: String = "npc_villager"
@export var portrait_texture: Texture2D
@export var wander_radius: float = 60.0
@export var move_speed: float = 40.0

@onready var sprite: Sprite2D = $Sprite2D
@onready var prompt_label: Label = $PromptLabel
@onready var interact_area: Area2D = $InteractArea

var home_position: Vector2 = Vector2.ZERO
var target_position: Vector2 = Vector2.ZERO
var is_wandering: bool = false
var wander_timer: float = 0.0
var is_player_near: bool = false

func _ready() -> void:
	home_position = global_position
	target_position = home_position
	
	if prompt_label:
		prompt_label.text = "[E] Bicara"
		prompt_label.visible = false
		
	if interact_area:
		interact_area.body_entered.connect(_on_player_entered)
		interact_area.body_exited.connect(_on_player_exited)
		
	_pick_new_wander_target()

func _physics_process(delta: float) -> void:
	if is_player_near:
		# Berhenti bergerak saat diajak bicara
		velocity = Vector2.ZERO
		move_and_slide()
		return
		
	wander_timer -= delta
	if wander_timer <= 0.0:
		_pick_new_wander_target()
		
	if is_wandering:
		var dir = (target_position - global_position)
		if dir.length() > 4.0:
			velocity = dir.normalized() * move_speed
			if sprite:
				sprite.flip_h = (velocity.x < 0.0)
		else:
			velocity = Vector2.ZERO
			is_wandering = false
	else:
		velocity = Vector2.ZERO
		
	move_and_slide()

func _pick_new_wander_target() -> void:
	wander_timer = randf_range(2.5, 5.0)
	if randf() > 0.4:
		# Pilih posisi acak di sekitar rumah
		var offset = Vector2(randf_range(-wander_radius, wander_radius), randf_range(-wander_radius, wander_radius))
		target_position = home_position + offset
		is_wandering = true
	else:
		# Diam di tempat
		is_wandering = false

func _unhandled_input(event: InputEvent) -> void:
	if not is_player_near:
		return
		
	if event is InputEventKey and event.pressed and event.keycode == KEY_E:
		get_viewport().set_input_as_handled()
		talk()

func _on_player_entered(body: Node2D) -> void:
	if body.is_in_group("player") or body.name == "Player":
		is_player_near = true
		if prompt_label:
			prompt_label.visible = true

func _on_player_exited(body: Node2D) -> void:
	if body.is_in_group("player") or body.name == "Player":
		is_player_near = false
		if prompt_label:
			prompt_label.visible = false

func talk() -> void:
	var dialog_system = get_tree().root.find_child("DialogSystem", true, false)
	if dialog_system and dialog_system.has_method("load_and_start_dialog_from_json"):
		if not dialog_system.is_dialog_active:
			dialog_system.load_and_start_dialog_from_json("res://data/dialogs.json", dialog_key, npc_name, portrait_texture)
