extends CharacterBody2D

const SPEED = 220.0
const JUMP_SPEED = -520.0
const GRAVITY = 1300.0


func _physics_process(delta):
	velocity.y += GRAVITY * delta
	velocity.x = Input.get_axis("move_left", "move_right") * SPEED
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_SPEED
	move_and_slide()

	# Анимация: стоит, идёт или прыгает
	if velocity.x != 0:
		$Sprite.flip_h = velocity.x < 0
	if not is_on_floor():
		$Sprite.frame = 12
	elif velocity.x != 0:
		$Sprite.frame = 4 + Time.get_ticks_msec() / 120 % 4
	else:
		$Sprite.frame = 0

	if position.y > 700:
		die()


func bounce():
	velocity.y = -350.0


func die():
	get_tree().reload_current_scene.call_deferred()
