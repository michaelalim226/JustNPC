extends CharacterBody2D

## Kecepatan gerak karakter (pixel per detik)
@export var speed: float = 200.0

## Parameter akselerasi dan friksi untuk pergerakan mulus
@export var acceleration: float = 1200.0
@export var friction: float = 1000.0

## Referensi node internal
@onready var sprite: Sprite2D = $Sprite2D
@onready var anim_player: AnimationPlayer = get_node_or_null("AnimationPlayer")
@onready var dust_particles: CPUParticles2D = get_node_or_null("DustParticles")
@onready var camera: Camera2D = get_node_or_null("Camera2D")
@onready var sfx_footstep: AudioStreamPlayer2D = get_node_or_null("SfxFootstep")

## Variabel internal animasi dan langkah kaki
var footstep_timer: float = 0.0
var footstep_interval: float = 0.3
var walk_anim_timer: float = 0.0
var is_moving: bool = false

# Variabel untuk Camera Shake
var shake_intensity: float = 0.0
var shake_duration: float = 0.0
var original_camera_offset: Vector2 = Vector2.ZERO

func _ready() -> void:
	if camera:
		original_camera_offset = camera.offset
		
	# Hubungkan sinyal camera shake dari GameManager jika ada
	var gm = get_node_or_null("/root/GameManager")
	if gm and gm.has_signal("camera_shake_requested"):
		gm.camera_shake_requested.connect(apply_camera_shake)

func _physics_process(delta: float) -> void:
	move_player(delta)
	_handle_animations(delta)
	_handle_camera_shake(delta)

## Mendapatkan vektor arah input (WASD / Arrow Keys)
func get_input_direction() -> Vector2:
	var direction: Vector2 = Vector2.ZERO
	direction.x = Input.get_axis("ui_left", "ui_right")
	direction.y = Input.get_axis("ui_up", "ui_down")
	
	if direction.length() > 0.0:
		direction = direction.normalized()
		
	return direction

## Logika pergerakan karakter dan deteksi tabrakan
func move_player(delta: float) -> void:
	var input_direction: Vector2 = get_input_direction()
	
	if input_direction != Vector2.ZERO:
		is_moving = true
		velocity = velocity.move_toward(input_direction * speed, acceleration * delta)
		
		# Balik hadap karakter (Sprite Flip)
		if input_direction.x < 0.0:
			if sprite: sprite.flip_h = true
		elif input_direction.x > 0.0:
			if sprite: sprite.flip_h = false
			
		# Partikel debu saat melangkah
		if dust_particles:
			dust_particles.emitting = true
			
		# Efek suara langkah kaki (Footsteps)
		footstep_timer += delta
		if footstep_timer >= footstep_interval:
			footstep_timer = 0.0
			_play_footstep()
	else:
		is_moving = false
		velocity = velocity.move_toward(Vector2.ZERO, friction * delta)
		if dust_particles:
			dust_particles.emitting = false
		footstep_timer = footstep_interval * 0.8
		
	move_and_slide()

## Mengelola animasi idle bounce dan walk wobble
func _handle_animations(delta: float) -> void:
	if not sprite:
		return
		
	if is_moving:
		# Animasi berjalan (bergoyang sedikit ke kiri-kanan)
		walk_anim_timer += delta * 14.0
		sprite.position.y = -abs(sin(walk_anim_timer)) * 3.0
		sprite.rotation = sin(walk_anim_timer * 0.5) * 0.08
	else:
		# Animasi idle (bernapas / naik-turun halus)
		walk_anim_timer += delta * 2.5
		sprite.position.y = sin(walk_anim_timer) * 1.5
		sprite.rotation = 0.0

## Memainkan suara langkah kaki dengan pitch bervariasi
func _play_footstep() -> void:
	if sfx_footstep:
		sfx_footstep.pitch_scale = randf_range(0.9, 1.15)
		sfx_footstep.play()

## Memicu efek getar kamera
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
