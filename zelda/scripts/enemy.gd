extends CharacterBody2D

signal destroyed

@export_enum("Жук", "Мотылёк") var kind := 0

var hero: CharacterBody2D
var flash := 0.0
var knockback := Vector2.ZERO

@onready var sprite: AnimatedSprite2D = $Sprite
@onready var health := 2 if kind == 0 else 1
@onready var speed := 65.0 if kind == 0 else 105.0
@onready var animation := "beetle" if kind == 0 else "moth"


func _ready() -> void:
	sprite.play(animation + "_move")


func _physics_process(delta: float) -> void:
	if health == 0 or not is_instance_valid(hero):
		return
	flash = maxf(flash - delta, 0.0)
	var offset := hero.global_position - global_position
	velocity = knockback
	if offset.length() < 225.0:
		var toward := offset.normalized()
		velocity += toward * speed
		if absf(toward.x) > 0.1:
			sprite.flip_h = toward.x < 0.0
	knockback = knockback.move_toward(Vector2.ZERO, 620.0 * delta)
	move_and_slide()

	sprite.modulate = Color(1.8, 1.65, 1.25) if flash > 0.0 else Color.WHITE
	if global_position.distance_to(hero.global_position) < 24.0:
		hero.hurt()


func hit(from: Vector2) -> void:
	if health == 0:
		return
	health -= 1
	if health > 0:
		flash = 0.14
		knockback = from.direction_to(global_position) * 230.0
		return

	sprite.modulate = Color.WHITE
	set_deferred("collision_layer", 0)
	sprite.play(animation + "_die")
	destroyed.emit()
	await sprite.animation_finished
	queue_free()
