extends CharacterBody2D

const SPEED = 60.0
const GRAVITY = 1300.0

var direction = -1
var start_x = 0.0


func _ready():
	start_x = position.x
	$Hitbox.body_entered.connect(_on_hitbox_body_entered)


func _physics_process(delta):
	# Ходит туда-сюда в пределах 100 пикселей от старта
	if is_on_wall():
		direction = -direction
	elif position.x < start_x - 100:
		direction = 1
	elif position.x > start_x + 100:
		direction = -1
	velocity.x = direction * SPEED
	velocity.y += GRAVITY * delta
	move_and_slide()


func _on_hitbox_body_entered(body):
	if body.name != "Player":
		return
	# Прыгнули сверху — враг погиб, иначе погиб игрок
	if body.velocity.y > 0 and body.position.y < position.y - 10:
		body.bounce()
		queue_free()
	else:
		body.die()
