extends CharacterBody2D

signal destroyed

const Art = preload("res://scripts/art.gd")
var direction = -1.0
@export var speed = 58.0
@export var patrol_distance = 100.0
var home_x = 0.0
var alive = true
var animation_time = 0.0
var death_time = 0.0
@onready var picture: Sprite2D = $Sprite
@onready var floor_ray: RayCast2D = $FloorRay


func _ready() -> void:
	home_x = position.x


func _physics_process(delta: float) -> void:
	if not alive:
		death_time += delta
		picture.texture = Art.tile(8 + mini(int(death_time * 7.0), 2))
		picture.modulate.a = minf(1.0, (0.8 - death_time) * 4.0)
		if death_time > 0.8:
			queue_free()
		return
	animation_time += delta
	if position.x < home_x - patrol_distance:
		direction = 1.0
	elif position.x > home_x + patrol_distance:
		direction = -1.0
	floor_ray.position.x = direction * 24
	floor_ray.force_raycast_update()
	if is_on_wall() or (is_on_floor() and not floor_ray.is_colliding()):
		direction *= -1.0
	velocity.x = direction * speed
	velocity.y += 1250.0 * delta
	move_and_slide()
	picture.flip_h = direction > 0.0
	picture.texture = Art.tile(4 + int(animation_time * 7.0) % 4)
	if position.y > 800:
		queue_free()


func _on_body_entered(body: Node2D) -> void:
	if not alive or not body.is_in_group("player") or not body.alive:
		return
	if body.velocity.y > 0.0 and body.global_position.y < global_position.y - 18.0:
		body.bounce()
		die()
	elif body.take_hit():
		die()


func die() -> void:
	if not alive:
		return
	alive = false
	velocity = Vector2.ZERO
	destroyed.emit()
	$CollisionShape2D.set_deferred("disabled", true)
