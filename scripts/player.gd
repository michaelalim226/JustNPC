extends CharacterBody2D

## ========================================================
## PLAYER — Egg Hunt Arcade
## Movement, combat, health, camera shake
## ========================================================

@export var speed: float = 230.0
@export var acceleration: float = 1400.0
@export var friction: float = 1200.0
@export var invulnerability_duration: float = 1.6
@export var attack_cooldown: float = 0.32

## Node references
@onready var sprite: Sprite2D = $Sprite2D
@onready var dust_particles: CPUParticles2D = get_node_or_null("DustParticles")
@onready var camera: Camera2D = get_node_or_null("Camera2D")
@onready var sfx_footstep: AudioStreamPlayer2D = get_node_or_null("SfxFootstep")
@onready var sfx_shoot: AudioStreamPlayer2D = get_node_or_null("SfxShoot")
@onready var sfx_hurt: AudioStreamPlayer2D = get_node_or_null("SfxHurt")

## Preload projectile script
const ProjectileScript = preload("res://scripts/projectile.gd")

## Movement state
var walk_anim_timer: float = 0.0
var is_moving: bool = false
var last_direction: Vector2 = Vector2.RIGHT

## Combat state
var can_attack: bool = true
var _attack_timer: float = 0.0

## Health & invulnerability
var is_invulnerable: bool = false
var _invuln_timer: float = 0.0
var _blink_timer: float = 0.0

## Camera shake
var shake_intensity: float = 0.0
var shake_duration: float = 0.0
var original_camera_offset: Vector2 = Vector2.ZERO

## Game state flag
var is_dead: bool = false

func _ready() -> void:
	add_to_group("player")
	if camera:
		original_camera_offset = camera.offset
	
	var gm = get_node_or_null("/root/GameManager")
	if gm:
		if gm.has_signal("camera_shake_requested"):
			gm.camera_shake_requested.connect(apply_camera_shake)
		gm.player_died.connect(_on_player_died)

func _physics_process(delta: float) -> void:
	if is_dead:
		return
	_handle_invulnerability(delta)
	_handle_attack_cooldown(delta)
	_handle_movement(delta)
	_handle_attack_input()
	_handle_animations(delta)
	_handle_camera_shake(delta)

## ========================
## MOVEMENT
## ========================

func _handle_movement(delta: float) -> void:
	var dir := Vector2.ZERO
	dir.x = Input.get_axis("ui_left", "ui_right")
	dir.y = Input.get_axis("ui_up", "ui_down")
	
	if dir.length() > 0.0:
		dir = dir.normalized()
		last_direction = dir
		is_moving = true
		velocity = velocity.move_toward(dir * speed, acceleration * delta)
		
		if sprite:
			sprite.flip_h = dir.x < -0.1
		if dust_particles:
			dust_particles.emitting = true
		
		## Suara langkah kaki
		_handle_footstep(delta)
	else:
		is_moving = false
		velocity = velocity.move_toward(Vector2.ZERO, friction * delta)
		if dust_particles:
			dust_particles.emitting = false
	
	move_and_slide()

## Timer footstep sederhana
var _footstep_timer: float = 0.0
var _footstep_interval: float = 0.28

func _handle_footstep(delta: float) -> void:
	_footstep_timer += delta
	if _footstep_timer >= _footstep_interval:
		_footstep_timer = 0.0
		if sfx_footstep and sfx_footstep.stream:
			sfx_footstep.pitch_scale = randf_range(0.88, 1.12)
			sfx_footstep.play()

## ========================
## ATTACK
## ========================

func _handle_attack_input() -> void:
	if Input.is_action_just_pressed("attack") and can_attack:
		_shoot()

func _shoot() -> void:
	can_attack = false
	_attack_timer = attack_cooldown
	
	if sfx_shoot and sfx_shoot.stream:
		sfx_shoot.pitch_scale = randf_range(0.95, 1.05)
		sfx_shoot.play()
	
	## Spawn projectile di node induk scene
	var main_node = get_tree().root.get_node_or_null("Main")
	if not main_node:
		return
	
	var proj := Node2D.new()
	proj.set_script(ProjectileScript)
	proj.name = "Projectile"
	proj.direction = last_direction  ## Set sebelum add_child agar _ready() tahu arahnya
	main_node.add_child(proj)
	proj.global_position = global_position + last_direction * 26.0

func _handle_attack_cooldown(delta: float) -> void:
	if not can_attack:
		_attack_timer -= delta
		if _attack_timer <= 0.0:
			can_attack = true

## ========================
## HEALTH & DAMAGE
## ========================

func take_damage() -> void:
	if is_invulnerable or is_dead:
		return
	is_invulnerable = true
	_invuln_timer = invulnerability_duration
	_blink_timer = invulnerability_duration
	
	if sfx_hurt and sfx_hurt.stream:
		sfx_hurt.play()
	
	var gm = get_node_or_null("/root/GameManager")
	if gm:
		gm.damage_player()

func _handle_invulnerability(delta: float) -> void:
	if not is_invulnerable:
		return
	_invuln_timer -= delta
	_blink_timer -= delta
	
	## Efek berkedip merah-transparan
	if sprite:
		var blink_state: bool = int(_blink_timer * 9.0) % 2 == 0
		sprite.modulate = Color(1.0, 0.35, 0.35, 1.0) if blink_state else Color(1.0, 1.0, 1.0, 0.3)
	
	if _invuln_timer <= 0.0:
		is_invulnerable = false
		_invuln_timer = 0.0
		if sprite:
			sprite.modulate = Color(1.0, 1.0, 1.0, 1.0)

func _on_player_died() -> void:
	is_dead = true
	set_physics_process(false)
	if sprite:
		var tween = create_tween()
		tween.tween_property(sprite, "modulate", Color(1, 0.1, 0.1, 0), 0.8)
		tween.parallel().tween_property(sprite, "scale", Vector2(0, 0), 0.8)

## ========================
## ANIMATIONS
## ========================

func _handle_animations(delta: float) -> void:
	if not sprite or is_invulnerable:
		return
	if is_moving:
		walk_anim_timer += delta * 14.0
		sprite.position.y = -abs(sin(walk_anim_timer)) * 3.0
		sprite.rotation = sin(walk_anim_timer * 0.5) * 0.08
	else:
		walk_anim_timer += delta * 2.5
		sprite.position.y = sin(walk_anim_timer) * 1.5
		sprite.rotation = 0.0

## ========================
## CAMERA SHAKE
## ========================

func apply_camera_shake(intensity: float = 5.0, duration: float = 0.3) -> void:
	shake_intensity = intensity
	shake_duration = duration

func _handle_camera_shake(delta: float) -> void:
	if not camera:
		return
	if shake_duration > 0.0:
		shake_duration -= delta
		camera.offset = original_camera_offset + Vector2(
			randf_range(-shake_intensity, shake_intensity),
			randf_range(-shake_intensity, shake_intensity)
		)
	else:
		camera.offset = original_camera_offset
