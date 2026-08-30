extends Area2D

## ========================================================
## DANGER ZONE — Egg Hunt Arcade
## Area berbahaya (kolam, rawa, dsb) yang melukai player
## jika player berdiri di dalamnya terlalu lama
## ========================================================

@export var damage_interval: float = 1.2   ## Interval damage per detik
@export var initial_delay: float = 0.7     ## Delay sebelum damage pertama

var player_inside: bool = false
var _damage_timer: float = 0.0
var _player_ref: Node2D

func _ready() -> void:
	collision_layer = 0
	collision_mask = 2  ## Deteksi player
	monitoring = true
	monitorable = false
	
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _process(delta: float) -> void:
	if not player_inside or not _player_ref:
		return
	
	_damage_timer -= delta
	if _damage_timer <= 0.0:
		_damage_timer = damage_interval
		if _player_ref.has_method("take_damage"):
			_player_ref.take_damage()

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_inside = true
		_player_ref = body
		_damage_timer = initial_delay  ## Kecil delay sebelum damage pertama

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_inside = false
		_player_ref = null
