extends CharacterBody2D

signal attacked(weapon: StringName)
signal interacted
signal health_changed

const MAX_HEALTH := 5
const WALK_SPEED := 134.0
const RUN_SPEED := 220.0

var health := MAX_HEALTH
var facing := Vector2.RIGHT
var attack_time := 0.0
var safe_time := 0.0
var weapon := &"sword"

@onready var sprite: AnimatedSprite2D = $Sprite


func reset() -> void:
	health = MAX_HEALTH
	attack_time = 0.0
	safe_time = 0.0
	velocity = Vector2.ZERO
	facing = Vector2.RIGHT
	_update_sprite(false, false)
	queue_redraw()


func _physics_process(delta: float) -> void:
	attack_time = maxf(attack_time - delta, 0.0)
	safe_time = maxf(safe_time - delta, 0.0)
	var direction := Input.get_vector("left", "right", "up", "down")
	var running := Input.is_action_pressed("run")
	if direction != Vector2.ZERO and attack_time == 0.0:
		facing = direction.normalized()

	velocity = direction * (RUN_SPEED if running else WALK_SPEED)
	if attack_time > 0.0:
		velocity *= 0.45
	move_and_slide()

	if attack_time == 0.0:
		if Input.is_action_just_pressed("sword"):
			_attack(&"sword", 0.26)
		elif Input.is_action_just_pressed("bow"):
			_attack(&"bow", 0.34)

	if Input.is_action_just_pressed("interact"):
		interacted.emit()
	_update_sprite(direction != Vector2.ZERO, running)
	queue_redraw()


func _attack(selected_weapon: StringName, duration: float) -> void:
	weapon = selected_weapon
	attack_time = duration
	attacked.emit(weapon)


func hurt() -> void:
	if safe_time > 0.0 or health == 0:
		return
	safe_time = 0.85
	health -= 1
	health_changed.emit()


func heal() -> void:
	if health < MAX_HEALTH:
		health += 1
		health_changed.emit()


func _update_sprite(moving: bool, running: bool) -> void:
	var animation := &"side"
	if absf(facing.y) > absf(facing.x):
		animation = &"back" if facing.y < 0.0 else &"front"
	sprite.flip_h = animation == &"side" and facing.x < 0.0
	sprite.speed_scale = 1.5 if running else 1.0
	if moving:
		sprite.play(animation)
	else:
		sprite.animation = animation
		sprite.stop()
	sprite.modulate.a = 0.65 if safe_time > 0.0 else 1.0


func _draw() -> void:
	if attack_time > 0.10 and weapon == &"sword":
		var angle := facing.angle()
		draw_arc(Vector2(0, -6), 33, angle - 0.78, angle + 0.78, 12, Color("#fff0c4"), 3, true)
