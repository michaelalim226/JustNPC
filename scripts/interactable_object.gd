extends Area2D

@export var object_name: String = "Objek"
@export var dialog_key: String = "interact_tree"
@export var speaker_name: String = "NPC Pemalas (Kamu)"

@onready var prompt_label: Label = get_node_or_null("PromptLabel")

var is_player_near: bool = false

func _ready() -> void:
	if prompt_label:
		prompt_label.text = "[E] Periksa %s" % object_name
		prompt_label.visible = false
		
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _unhandled_input(event: InputEvent) -> void:
	if not is_player_near:
		return
		
	if event is InputEventKey and event.pressed and event.keycode == KEY_E:
		get_viewport().set_input_as_handled()
		interact()

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") or body.name == "Player":
		is_player_near = true
		if prompt_label:
			prompt_label.visible = true

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player") or body.name == "Player":
		is_player_near = false
		if prompt_label:
			prompt_label.visible = false

func interact() -> void:
	var dialog_system = get_tree().root.find_child("DialogSystem", true, false)
	if dialog_system and dialog_system.has_method("load_and_start_dialog_from_json"):
		if not dialog_system.is_dialog_active:
			dialog_system.load_and_start_dialog_from_json("res://data/dialogs.json", dialog_key, speaker_name)
