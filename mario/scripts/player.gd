extends CharacterBody2D

signal defeated

const WALK_SPEED = 190.0
const RUN_SPEED = 310.0
const JUMP_SPEED = -530.0
const GRAVITY = 1250.0

var alive = true
var controls_enabled = true
var shield_time = 0.0
var invulnerability = 0.0
var coyote_time = 0.0
var jump_buffer = 0.0
var animation_time = 0.0
var animation_name = "idle"
var jump_was_held = false

@onready var sprite: Sprite2D = $Sprite


func _ready() -> void:
	sprite.scale = Vector2(64, 64) / (sprite.texture.get_size() / 4.0)


func _physics_process(delta: float) -> void:
	if not alive:
		return
	shield_time = maxf(0.0, shield_time - delta)
	invulnerability = maxf(0.0, invulnerability - delta)
	if is_on_floor():
		coyote_time = 0.1
	else:
		coyote_time = maxf(0.0, coyote_time - delta)
	jump_buffer = maxf(0.0, jump_buffer - delta)
	var direction = 0.0
	if controls_enabled:
		direction = Input.get_axis("move_left", "move_right")
	var running = controls_enabled and Input.is_action_pressed("sprint")
	var target_speed = WALK_SPEED
	if running:
		target_speed = RUN_SPEED
	velocity.x = move_toward(velocity.x, direction * target_speed, 1700.0 * delta)
	var jump_held = controls_enabled and Input.is_action_pressed("jump")
	if jump_held and not jump_was_held:
		jump_buffer = 0.12
	if not is_on_floor():
		velocity.y = minf(velocity.y + GRAVITY * delta, 900.0)
	if jump_buffer > 0.0 and coyote_time > 0.0:
		velocity.y = JUMP_SPEED
		jump_buffer = 0.0
		coyote_time = 0.0
	if not jump_held and jump_was_held and velocity.y < -200.0:
		velocity.y *= 0.55
	jump_was_held = jump_held
	var upward = velocity.y < 0.0
	move_and_slide()
	if upward:
		for index in get_slide_collision_count():
			var collision = get_slide_collision(index)
			var object = collision.get_collider()
			if collision.get_normal().y > 0.6 and object.has_method("hit_from_below"):
				object.hit_from_below()
	if position.y > 700.0:
		die()
	update_animation(delta, running)
	$ShieldVisual.queue_redraw()


func update_animation(delta: float, running: bool) -> void:
	var next = "idle"
	if not is_on_floor():
		next = "jump"
	elif absf(velocity.x) > 10.0:
		if running:
			next = "run"
		else:
			next = "walk"
	if next != animation_name:
		animation_time = 0.0
		animation_name = next
	animation_time += delta
	if absf(velocity.x) > 5.0:
		sprite.flip_h = velocity.x < 0.0
	if animation_name == "idle":
		sprite.frame = int(animation_time * 4.0) % 4
	elif animation_name == "walk":
		sprite.frame = 4 + int(animation_time * 9.0) % 4
	elif animation_name == "run":
		sprite.frame = 8 + int(animation_time * 13.0) % 4
	elif velocity.y < -130.0:
		sprite.frame = 12
	elif velocity.y < 100.0:
		sprite.frame = 13
	else:
		sprite.frame = 14
	sprite.modulate.a = 1.0
	if invulnerability > 0.0 and int(invulnerability * 14) % 2 == 1:
		sprite.modulate.a = 0.4


func bounce() -> void:
	velocity.y = -330.0
	coyote_time = 0.0
	jump_buffer = 0.0


func collect_shield() -> void:
	shield_time = 8.0
	$ShieldVisual.queue_redraw()


func take_hit() -> bool:
	if not alive or invulnerability > 0.0:
		return false
	if shield_time > 0.0:
		shield_time = 0.0
		invulnerability = 1.0
		$ShieldVisual.queue_redraw()
		return true
	die()
	return false


func die() -> void:
	if not alive:
		return
	alive = false
	$ShieldVisual.queue_redraw()
	sprite.frame = 15
	velocity = Vector2.ZERO
	defeated.emit()
	var tween = create_tween()
	tween.tween_property(sprite, "modulate:a", 0.0, 0.65)
