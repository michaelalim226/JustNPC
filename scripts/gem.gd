extends Area2D

## ========================================================
## GEM / DIAMOND — Egg Hunt Arcade
## Collectible permata/berlian yang tersebar di seluruh map
## Auto-collect saat player menyentuhnya
## ========================================================

@export var gem_score_value: int = 100
@export var gem_id: int = 1

@onready var sprite: Sprite2D = $Sprite2D
@onready var sparkle_particles: CPUParticles2D = get_node_or_null("SparkleParticles")
@onready var sfx_collect: AudioStreamPlayer2D = get_node_or_null("SfxCollect")

var is_collected: bool = false
var _float_time: float = 0.0

func _ready() -> void:
	## Randomize float phase agar setiap permata tidak sinkron
	_float_time = randf_range(0.0, TAU)
	
	## Collision setup: deteksi player (layer 2)
	collision_layer = 0
	collision_mask = 2
	monitoring = true
	monitorable = false
	
	body_entered.connect(_on_body_entered)

func _process(delta: float) -> void:
	if is_collected:
		return
	## Animasi mengambang naik-turun
	_float_time += delta * 2.8
	if sprite:
		sprite.position.y = sin(_float_time) * 4.5
		sprite.rotation = sin(_float_time * 0.4) * 0.06

func _on_body_entered(body: Node2D) -> void:
	if is_collected:
		return
	if body.is_in_group("player"):
		collect()

func collect() -> void:
	if is_collected:
		return
	is_collected = true
	monitoring = false
	
	## Efek suara
	if sfx_collect and sfx_collect.stream:
		sfx_collect.play()
	
	## Partikel kilau
	if sparkle_particles:
		sparkle_particles.emitting = true
		sparkle_particles.one_shot = true
	
	## Spawn floating score popup
	_spawn_score_popup()
	
	## Notify GameManager
	var gm := get_node_or_null("/root/GameManager")
	if gm:
		gm.collect_gem(gem_score_value)
	
	## Animasi menghilang: scale up + fade out
	if sprite:
		var tween := create_tween()
		tween.set_parallel(true)
		tween.tween_property(sprite, "scale", Vector2(2.2, 2.2), 0.3) \
			.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
		tween.tween_property(sprite, "modulate:a", 0.0, 0.3)
		tween.chain().tween_callback(queue_free)

func _spawn_score_popup() -> void:
	## Label melayang dengan nilai score
	var label := Label.new()
	label.text = "+%d" % gem_score_value
	label.add_theme_font_size_override("font_size", 22)
	label.add_theme_color_override("font_color", Color(0.1, 0.9, 1.0, 1.0)) ## Cyan color for gem!
	label.add_theme_color_override("font_outline_color", Color(0.0, 0.0, 0.0, 1.0))
	label.add_theme_constant_override("outline_size", 5)
	label.z_index = 10
	
	## Tambahkan ke parent dulu agar bisa set global_position
	get_parent().add_child(label)
	label.global_position = global_position + Vector2(-18, -24)
	
	## Animasi melayang ke atas sambil fade
	var tween := label.create_tween()
	tween.set_parallel(true)
	tween.tween_property(label, "position:y", label.position.y - 70, 0.9) \
		.set_ease(Tween.EASE_OUT)
	tween.tween_property(label, "modulate:a", 0.0, 0.9) \
		.set_delay(0.4)
	tween.chain().tween_callback(label.queue_free)
