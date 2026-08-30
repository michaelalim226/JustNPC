extends CharacterBody2D

## ========================================================
## ENEMY CHASER — Egg Hunt Arcade
## Mengejar player ketika player masuk radius deteksi
## Berhenti jika player terlalu jauh
## ========================================================

@export var detection_radius: float = 130.0
@export var give_up_radius: float = 220.0
@export var chase_speed: float = 105.0
@export var wander_speed: float = 30.0
@export var health: int = 2
@export var score_value: int = 75

@onready var sprite: Sprite2D = $Sprite2D
@onready var hurt_area: Area2D = get_node_or_null("HurtArea")
@onready var sfx_hit: AudioStreamPlayer2D = get_node_or_null("SfxHit")
@onready var sfx_die: AudioStreamPlayer2D = get_node_or_null("SfxDie")

enum ChaserState { IDLE, WANDER, CHASE }
var state: ChaserState = ChaserState.IDLE

var home_position: Vector2 = Vector2.ZERO
var wander_target: Vector2 = Vector2.ZERO
var wander_timer: float = 0.0
var _current_health: int = 2
var is_dead: bool = false
var _hit_flash_timer: float = 0.0
var _anim_timer: float = 0.0

## Referensi player (dicari sekali di _ready)
var _player: Node2D

func _ready() -> void:
	add_to_group("enemy")
	_current_health = health
	home_position = global_position
	wander_target = global_position
	
	## Cari player
	_player = get_tree().get_first_node_in_group("player")
	
	## HurtArea setup
	if hurt_area:
		hurt_area.collision_layer = 0
		hurt_area.collision_mask = 2
		hurt_area.body_entered.connect(_on_player_hit)
	
	collision_layer = 4
	collision_mask = 1
	
	_pick_wander_target()

func _physics_process(delta: float) -> void:
	if is_dead:
		return
	_handle_hit_flash(delta)
	_update_state()
	
	match state:
		ChaserState.IDLE, ChaserState.WANDER:
			_handle_wander(delta)
		ChaserState.CHASE:
			_handle_chase(delta)
	
	move_and_slide()
	_handle_animation(delta)

func _update_state() -> void:
	if not _player:
		_player = get_tree().get_first_node_in_group("player")
		return
	
	var dist: float = global_position.distance_to(_player.global_position)
	
	match state:
		ChaserState.IDLE, ChaserState.WANDER:
			if dist <= detection_radius:
				state = ChaserState.CHASE
		ChaserState.CHASE:
			if dist > give_up_radius:
				state = ChaserState.WANDER
				_pick_wander_target()

func _handle_wander(delta: float) -> void:
	wander_timer -= delta
	if wander_timer <= 0.0:
		_pick_wander_target()
	
	var dir: Vector2 = (wander_target - global_position)
	if dir.length() > 8.0:
		velocity = dir.normalized() * wander_speed
		if sprite:
			sprite.flip_h = velocity.x < -0.5
	else:
		velocity = velocity.move_toward(Vector2.ZERO, 200 * delta)
		wander_timer = maxf(wander_timer, 1.0)

func _handle_chase(delta: float) -> void:
	if not _player:
		return
	var dir: Vector2 = (_player.global_position - global_position).normalized()
	velocity = velocity.move_toward(dir * chase_speed, 500 * delta)
	if sprite:
		sprite.flip_h = velocity.x < -0.5
		## Visual: lebih "excited" saat mengejar
		sprite.scale = Vector2(1.15, 0.9)
	if get_slide_collision_count() > 0:
		## Jika menabrak dinding, coba arah berbeda
		velocity = velocity.rotated(PI * 0.5)

func _pick_wander_target() -> void:
	wander_timer = randf_range(2.0, 4.5)
	var offset := Vector2(
		randf_range(-80, 80),
		randf_range(-80, 80)
	)
	wander_target = home_position + offset

func _handle_animation(delta: float) -> void:
	if not sprite:
		return
	_anim_timer += delta * (12.0 if state == ChaserState.CHASE else 5.0)
	if state == ChaserState.CHASE:
		## Goyang keras saat mengejar
		sprite.scale.y = 0.9 + abs(sin(_anim_timer)) * 0.2
		sprite.scale.x = 1.15 - abs(sin(_anim_timer)) * 0.1
	else:
		sprite.scale = Vector2.ONE
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
			sprite.modulate = Color(2.0, 2.0, 2.0, 1.0)
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
	_spawn_death_effect()
	var gm := get_node_or_null("/root/GameManager")
	if gm:
		gm.kill_enemy(score_value)
	_spawn_score_popup()
	if sprite:
		var tween := create_tween()
		tween.set_parallel(true)
		tween.tween_property(sprite, "rotation", PI * 2.5, 0.45)
		tween.tween_property(sprite, "modulate:a", 0.0, 0.45)
		tween.tween_property(sprite, "scale", Vector2(0.05, 0.05), 0.45)
		tween.chain().tween_callback(queue_free)

func _spawn_death_effect() -> void:
	var p := CPUParticles2D.new()
	p.emitting = true
	p.one_shot = true
	p.amount = 14
	p.lifetime = 0.55
	p.emission_shape = CPUParticles2D.EMISSION_SHAPE_SPHERE
	p.emission_sphere_radius = 10.0
	p.initial_velocity_min = 70.0
	p.initial_velocity_max = 160.0
	p.scale_amount_min = 2.0
	p.scale_amount_max = 6.0
	p.color = Color(0.8, 0.2, 1.0, 1.0)
	get_parent().add_child(p)
	p.global_position = global_position
	get_tree().create_timer(0.7).timeout.connect(p.queue_free)

func _spawn_score_popup() -> void:
	var label := Label.new()
	label.text = "+%d" % score_value
	label.add_theme_font_size_override("font_size", 18)
	label.add_theme_color_override("font_color", Color(0.9, 0.4, 1.0, 1.0))
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
