extends CharacterBody2D

@onready var animation: AnimationPlayer = $AnimationPlayer

const GRAVITY = 1200
const JUMP_SPEED = -400

var started: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	animation.play("fly")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	# Пробел: взмах. Падать птица начинает только после первого взмаха.
	if Input.is_action_just_pressed("ui_accept"):
		started = true
		velocity.y = JUMP_SPEED

	if started:
		velocity.y += GRAVITY * delta

	# Потолок: выше экрана птица не улетает
	if position.y < 0:
		position.y = 0
		velocity.y = 0

	move_and_slide()
