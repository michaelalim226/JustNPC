extends Node2D

## ========================================================
## PROJECTILE — Egg Hunt Arcade
## Dibuat secara dinamis dari player.gd
## ========================================================

## Property yang di-set oleh player SEBELUM add_child()
var direction: Vector2 = Vector2.RIGHT
var speed: float = 490.0
var max_lifetime: float = 0.65

## Internal
var _lifetime: float = 0.0
var _detect_area: Area2D

## Preload texture
const PROJ_TEXTURE = preload("res://assets/sprites/projectile.png")

func _ready() -> void:
	## ---- Collision Area untuk mendeteksi enemy ----
	_detect_area = Area2D.new()
	_detect_area.collision_layer = 0
	_detect_area.collision_mask = 4   ## Layer 3 (enemy CharacterBody2D)
	_detect_area.monitorable = false
	_detect_area.monitoring = true
	
	var shape := CircleShape2D.new()
	shape.radius = 6.0
	var col := CollisionShape2D.new()
	col.shape = shape
	_detect_area.add_child(col)
	add_child(_detect_area)
	_detect_area.body_entered.connect(_on_hit_body)
	
	## ---- Visual (Sprite2D dari texture) ----
	var spr := Sprite2D.new()
	if PROJ_TEXTURE:
		spr.texture = PROJ_TEXTURE
		spr.scale = Vector2(1.4, 1.4)
	else:
		## Fallback jika texture belum ada
		var cr := ColorRect.new()
		cr.size = Vector2(12, 12)
		cr.position = Vector2(-6, -6)
		cr.color = Color(0.3, 0.95, 1.0)
		add_child(cr)
	add_child(spr)
	
	## ---- Efek glow dengan partikel ringan ----
	var glow_trail := CPUParticles2D.new()
	glow_trail.emitting = true
	glow_trail.amount = 5
	glow_trail.lifetime = 0.15
	glow_trail.emission_shape = CPUParticles2D.EMISSION_SHAPE_POINT
	glow_trail.direction = Vector2(-direction.x, -direction.y)
	glow_trail.spread = 20.0
	glow_trail.initial_velocity_min = 20.0
	glow_trail.initial_velocity_max = 50.0
	glow_trail.scale_amount_min = 2.0
	glow_trail.scale_amount_max = 4.0
	glow_trail.color = Color(0.3, 0.95, 1.0, 0.7)
	add_child(glow_trail)

func _process(delta: float) -> void:
	## Gerak lurus
	global_position += direction * speed * delta
	_lifetime += delta
	
	## Auto-destroy setelah max_lifetime
	if _lifetime >= max_lifetime:
		queue_free()
		return
	
	## Destroy jika keluar dari batas map
	if abs(global_position.x) > 1350 or abs(global_position.y) > 1050:
		queue_free()

func _on_hit_body(body: Node2D) -> void:
	## Cek apakah mengenai enemy
	if body.is_in_group("enemy"):
		if body.has_method("take_hit"):
			body.take_hit()
		## Hit effect kecil sebelum free
		_spawn_hit_effect()
		queue_free()

func _spawn_hit_effect() -> void:
	## Buat partikel kecil saat kena enemy
	var particles := CPUParticles2D.new()
	particles.emitting = true
	particles.one_shot = true
	particles.amount = 8
	particles.lifetime = 0.3
	particles.emission_shape = CPUParticles2D.EMISSION_SHAPE_SPHERE
	particles.emission_sphere_radius = 4.0
	particles.initial_velocity_min = 80.0
	particles.initial_velocity_max = 150.0
	particles.scale_amount_min = 2.0
	particles.scale_amount_max = 5.0
	particles.color = Color(1.0, 0.8, 0.2, 1.0)
	get_parent().add_child(particles)
	particles.global_position = global_position
	
	## Auto-free partikel setelah selesai
	var timer := get_tree().create_timer(0.5)
	timer.timeout.connect(particles.queue_free)
