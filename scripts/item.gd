extends Area2D

## Nomor urut fragmen (1, 2, atau 3)
@export var item_index: int = 1
@export var dialog_key: String = "item_fragment_1"

@onready var sprite: Sprite2D = $Sprite2D
@onready var prompt_label: Label = $PromptLabel
@onready var particles: CPUParticles2D = get_node_or_null("SparkleParticles")
@onready var sfx_collect: AudioStreamPlayer2D = get_node_or_null("SfxCollect")

var is_player_near: bool = false
var is_collected: bool = false
var base_y: float = 0.0
var anim_time: float = 0.0

func _ready() -> void:
	base_y = sprite.position.y
	if prompt_label:
		prompt_label.visible = false
		
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _process(delta: float) -> void:
	if is_collected:
		return
		
	# Animasi melayang naik-turun (floating bobbing)
	anim_time += delta * 3.0
	if sprite:
		sprite.position.y = base_y + sin(anim_time) * 4.0
		sprite.rotation = sin(anim_time * 0.5) * 0.05

func _unhandled_input(event: InputEvent) -> void:
	if is_collected or not is_player_near:
		return
		
	if event is InputEventKey and event.pressed and event.keycode == KEY_E:
		get_viewport().set_input_as_handled()
		collect()

func _on_body_entered(body: Node2D) -> void:
	if is_collected:
		return
	if body.is_in_group("player") or body.name == "Player":
		is_player_near = true
		if prompt_label:
			prompt_label.visible = true

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player") or body.name == "Player":
		is_player_near = false
		if prompt_label:
			prompt_label.visible = false

## Mengambil item, memutar efek suara, memicu sinyal GameManager dan dialog
func collect() -> void:
	if is_collected:
		return
		
	is_collected = true
	is_player_near = false
	if prompt_label:
		prompt_label.visible = false
		
	# Suara collect
	if sfx_collect:
		sfx_collect.play()
		
	# Partikel ledakan kilau
	if particles:
		particles.emitting = true
		particles.amount = 16
		particles.one_shot = true
		
	# Informasikan ke GameManager
	var gm = get_node_or_null("/root/GameManager")
	if gm and gm.has_method("collect_fragment"):
		gm.collect_fragment()
		
	# Picu dialog cerita fragmen melalui DialogSystem
	var dialog_system = get_tree().root.find_child("DialogSystem", true, false)
	if dialog_system and dialog_system.has_method("load_and_start_dialog_from_json"):
		dialog_system.load_and_start_dialog_from_json("res://data/dialogs.json", dialog_key)
		
	# Animasi menghilang (Scale up and fade out)
	var tween = create_tween()
	tween.tween_property(sprite, "scale", Vector2(1.8, 1.8), 0.3)
	tween.parallel().tween_property(sprite, "modulate:a", 0.0, 0.3)
	tween.tween_callback(func(): queue_free())
