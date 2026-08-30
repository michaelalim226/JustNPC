extends CharacterBody2D

## ========================================================
## ENEMY PATROL — Egg Hunt Arcade
## Bergerak bolak-balik antara dua titik (patrol route)
## Melukai player jika menyentuhnya
## ========================================================

@export var patrol_distance: float = 130.0
@export var patrol_direction: Vector2 = Vector2.RIGHT  ## Arah patrol: RIGHT, UP, dll
@export var move_speed: float = 65.0
@export var health: int = 2
@export var score_value: int = 50

@onready var sprite: Sprite2D = $Sprite2D
@onready var hurt_area: Area2D = get_node_or_null("HurtArea")
@onready var sfx_hit: AudioStreamPlayer2D = get_node_or_null("SfxHit")
@onready var sfx_die: AudioStreamPlayer2D = get_node_or_null("SfxDie")

var home_position: Vector2 = Vector2.ZERO
var point_a: Vector2 = Vector2.ZERO
var point_b: Vector2 = Vector2.ZERO
var moving_to_b: bool = true
var _current_health: int = 2
var is_dead: bool = false
var _hit_flash_timer: float = 0.0
var _anim_timer: float = 0.0

func _ready() -> void:
	add_to_group("enemy")
	_current_health = health
	home_position = global_position
	
	## Dua titik waypoint berdasarkan arah dan jarak patrol
	point_a = home_position - patrol_direction.normalized() * patrol_distance * 0.5
	point_b = home_position + patrol_direction.normalized() * patrol_distance * 0.5
	
	## HurtArea mendeteksi player
	if hurt_area:
		hurt_area.collision_layer = 0
		hurt_area.collision_mask = 2  ## Layer player
		hurt_area.body_entered.connect(_on_player_hit)
	
	collision_layer = 4   ## Layer enemy
	collision_mask = 1    ## Collide dengan environment

func _physics_process(delta: float) -> void:
	if is_dead:
		return
	_handle_hit_flash(delta)
	_handle_patrol(delta)
	_handle_animation(delta)

func _handle_patrol(delta: float) -> void:
	var target: Vector2 = point_b if moving_to_b else point_a
	var dir: Vector2 = (target - global_position)
	
	if dir.length() < 6.0:
		## Sampai di waypoint, balik arah
		moving_to_b = not moving_to_b
	else:
		velocity = dir.normalized() * move_speed
		if sprite:
			sprite.flip_h = (velocity.x < -0.5)
	
	move_and_slide()
	
	## Jika menabrak sesuatu, balik arah
	if get_slide_collision_count() > 0:
		moving_to_b = not moving_to_b

func _handle_animation(delta: float) -> void:
	if not sprite:
		return
	_anim_timer += delta * 8.0
	sprite.position.y = sin(_anim_timer) * 2.0

## ========================
## COMBAT
## ========================

func take_hit() -> void:
	if is_dead:
		return
	_current_health -= 1
	_hit_flash_timer = 0.25
	
	if sfx_hit and sfx_hit.stream:
		sfx_hit.play()
	
	if _current_health <= 0:
		_die()

func _handle_hit_flash(delta: float) -> void:
	if _hit_flash_timer > 0.0:
		_hit_flash_timer -= delta
		if sprite:
			sprite.modulate = Color(2.0, 2.0, 2.0, 1.0)  ## Flash putih terang
	else:
		if sprite and not is_dead:
			sprite.modulate = Color(1.0, 1.0, 1.0, 1.0)

func _die() -> void:
	if is_dead:
		return
	is_dead = true
	set_physics_process(false)
	
	if sfx_die and sfx_die.stream:
		sfx_die.play()
	
	## Efek kematian: partikel meledak
	_spawn_death_effect()
	
	## Laporkan score ke GameManager
	var gm := get_node_or_null("/root/GameManager")
	if gm:
		gm.kill_enemy(score_value)
	
	## Score popup
	_spawn_score_popup()
	
	## Animasi mati: spin + fade
	if sprite:
		var tween := create_tween()
		tween.set_parallel(true)
		tween.tween_property(sprite, "rotation", PI * 2.0, 0.4)
		tween.tween_property(sprite, "modulate:a", 0.0, 0.4)
		tween.tween_property(sprite, "scale", Vector2(0.1, 0.1), 0.4)
		tween.chain().tween_callback(queue_free)

func _spawn_death_effect() -> void:
	var p := CPUParticles2D.new()
	p.emitting = true
	p.one_shot = true
	p.amount = 12
	p.lifetime = 0.5
	p.emission_shape = CPUParticles2D.EMISSION_SHAPE_SPHERE
	p.emission_sphere_radius = 8.0
	p.initial_velocity_min = 60.0
	p.initial_velocity_max = 140.0
	p.scale_amount_min = 3.0
	p.scale_amount_max = 6.0
	p.color = Color(1.0, 0.3, 0.1, 1.0)
	get_parent().add_child(p)
	p.global_position = global_position
	var t := get_tree().create_timer(0.7)
	t.timeout.connect(p.queue_free)

func _spawn_score_popup() -> void:
	var label := Label.new()
	label.text = "+%d" % score_value
	label.add_theme_font_size_override("font_size", 18)
	label.add_theme_color_override("font_color", Color(1.0, 0.5, 0.1, 1.0))
	label.add_theme_color_override("font_outline_color", Color(0.0, 0.0, 0.0, 1.0))
	label.add_theme_constant_override("outline_size", 4)
	label.z_index = 10
	get_parent().add_child(label)
	label.global_position = global_position + Vector2(-14, -20)
	var tween := label.create_tween()
	tween.tween_property(label, "position:y", label.position.y - 55, 0.8)
	tween.parallel().tween_property(label, "modulate:a", 0.0, 0.8).set_delay(0.3)
	tween.chain().tween_callback(label.queue_free)

func _on_player_hit(body: Node2D) -> void:
	if body.is_in_group("player") and body.has_method("take_damage"):
		body.take_damage()
