extends CharacterBody2D

## ========================================================
## ENEMY GUARDIAN — Egg Hunt Arcade
## Menjaga telur tertentu. Berdiam di area dekat home.
## Menyerang dengan charge kilat ketika player mendekat.
## ========================================================

@export var guard_radius: float = 95.0      ## Radius deteksi untuk trigger charge
@export var charge_speed: float = 200.0     ## Kecepatan charge
@export var idle_orbit_speed: float = 1.2   ## Kecepatan orbit saat idle
@export var health: int = 3
@export var score_value: int = 100

@onready var sprite: Sprite2D = $Sprite2D
@onready var hurt_area: Area2D = get_node_or_null("HurtArea")
@onready var sfx_hit: AudioStreamPlayer2D = get_node_or_null("SfxHit")
@onready var sfx_die: AudioStreamPlayer2D = get_node_or_null("SfxDie")

enum GuardianState { ORBIT, CHARGE, RETURN, COOLDOWN }
var state: GuardianState = GuardianState.ORBIT

var home_position: Vector2 = Vector2.ZERO
var _orbit_angle: float = 0.0
var _orbit_radius: float = 30.0
var _charge_direction: Vector2 = Vector2.ZERO
var _charge_timer: float = 0.0
var _cooldown_timer: float = 0.0
var _current_health: int = 3
var is_dead: bool = false
var _hit_flash_timer: float = 0.0
var _player: Node2D

func _ready() -> void:
	add_to_group("enemy")
	_current_health = health
	home_position = global_position
	_orbit_angle = randf_range(0, TAU)
	
	_player = get_tree().get_first_node_in_group("player")
	
	if hurt_area:
		hurt_area.collision_layer = 0
		hurt_area.collision_mask = 2
		hurt_area.body_entered.connect(_on_player_hit)
	
	collision_layer = 4
	collision_mask = 1

func _physics_process(delta: float) -> void:
	if is_dead:
		return
	_handle_hit_flash(delta)
	
	match state:
		GuardianState.ORBIT:
			_handle_orbit(delta)
		GuardianState.CHARGE:
			_handle_charge(delta)
		GuardianState.RETURN:
			_handle_return(delta)
		GuardianState.COOLDOWN:
			_handle_cooldown(delta)
	
	move_and_slide()

func _handle_orbit(delta: float) -> void:
	## Bergerak melingkar di sekitar home_position
	_orbit_angle += idle_orbit_speed * delta
	var orbit_target := home_position + Vector2(
		cos(_orbit_angle) * _orbit_radius,
		sin(_orbit_angle) * _orbit_radius * 0.5  ## Sedikit gepeng untuk top-down look
	)
	var dir: Vector2 = (orbit_target - global_position)
	velocity = dir.normalized() * 60.0
	if sprite:
		sprite.flip_h = velocity.x < -0.5
	
	## Deteksi player
	if not _player:
		_player = get_tree().get_first_node_in_group("player")
		return
	var dist: float = global_position.distance_to(_player.global_position)
	if dist <= guard_radius:
		_start_charge()

func _start_charge() -> void:
	if not _player:
		return
	state = GuardianState.CHARGE
	_charge_direction = (_player.global_position - global_position).normalized()
	_charge_timer = 0.55  ## Durasi charge
	if sprite:
		## Visual warning: scale naik sebelum charge
		var tween := create_tween()
		tween.tween_property(sprite, "scale", Vector2(1.4, 1.4), 0.12)
		tween.tween_property(sprite, "scale", Vector2(0.9, 0.9), 0.1)

func _handle_charge(delta: float) -> void:
	_charge_timer -= delta
	velocity = _charge_direction * charge_speed
	if sprite:
		sprite.flip_h = velocity.x < -0.5
	if _charge_timer <= 0.0:
		state = GuardianState.RETURN
		velocity = Vector2.ZERO

func _handle_return(delta: float) -> void:
	var dir: Vector2 = (home_position - global_position)
	if dir.length() < 12.0:
		global_position = home_position
		state = GuardianState.COOLDOWN
		_cooldown_timer = 1.2
		velocity = Vector2.ZERO
	else:
		velocity = dir.normalized() * 80.0
	if sprite:
		sprite.scale = sprite.scale.move_toward(Vector2.ONE, 4.0 * delta)

func _handle_cooldown(delta: float) -> void:
	_cooldown_timer -= delta
	velocity = velocity.move_toward(Vector2.ZERO, 300 * delta)
	if _cooldown_timer <= 0.0:
		state = GuardianState.ORBIT
		_orbit_angle = randf_range(0, TAU)

## ========================
## COMBAT
## ========================

func take_hit() -> void:
	if is_dead:
		return
	_current_health -= 1
	_hit_flash_timer = 0.3
	if sfx_hit and sfx_hit.stream:
		sfx_hit.play()
	
	## Interrupt charge jika kena
	if state == GuardianState.CHARGE:
		state = GuardianState.COOLDOWN
		_cooldown_timer = 0.8
	
	if _current_health <= 0:
		_die()

func _handle_hit_flash(delta: float) -> void:
	if _hit_flash_timer > 0.0:
		_hit_flash_timer -= delta
		if sprite:
			sprite.modulate = Color(2.2, 2.2, 2.2, 1.0)
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
		tween.tween_property(sprite, "rotation", PI * 3.0, 0.6)
		tween.tween_property(sprite, "modulate:a", 0.0, 0.6)
		tween.tween_property(sprite, "scale", Vector2(0.0, 0.0), 0.6)
		tween.chain().tween_callback(queue_free)

func _spawn_death_effect() -> void:
	var p := CPUParticles2D.new()
	p.emitting = true
	p.one_shot = true
	p.amount = 18
	p.lifetime = 0.7
	p.emission_shape = CPUParticles2D.EMISSION_SHAPE_SPHERE
	p.emission_sphere_radius = 14.0
	p.initial_velocity_min = 80.0
	p.initial_velocity_max = 200.0
	p.scale_amount_min = 3.0
	p.scale_amount_max = 8.0
	p.color = Color(1.0, 0.7, 0.0, 1.0)
	get_parent().add_child(p)
	p.global_position = global_position
	get_tree().create_timer(1.0).timeout.connect(p.queue_free)

func _spawn_score_popup() -> void:
	var label := Label.new()
	label.text = "+%d" % score_value
	label.add_theme_font_size_override("font_size", 22)
	label.add_theme_color_override("font_color", Color(1.0, 0.8, 0.0, 1.0))
	label.add_theme_color_override("font_outline_color", Color(0.0, 0.0, 0.0, 1.0))
	label.add_theme_constant_override("outline_size", 5)
	label.z_index = 10
	get_parent().add_child(label)
	label.global_position = global_position + Vector2(-16, -24)
	var tween := label.create_tween()
	tween.tween_property(label, "position:y", label.position.y - 70, 1.0)
	tween.parallel().tween_property(label, "modulate:a", 0.0, 1.0).set_delay(0.4)
	tween.chain().tween_callback(label.queue_free)

func _on_player_hit(body: Node2D) -> void:
	if body.is_in_group("player") and body.has_method("take_damage"):
		body.take_damage()
