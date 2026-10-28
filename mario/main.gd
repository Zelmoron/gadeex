extends Node2D

const EnemyScene = preload("res://enemy.tscn")

# Платформы: x, y, ширина, высота
const PLATFORMS = [
	Rect2(0, 480, 700, 60),
	Rect2(800, 480, 500, 60),
	Rect2(950, 390, 120, 20),
	Rect2(1400, 480, 300, 60),
	Rect2(1780, 420, 120, 20),
	Rect2(1980, 360, 120, 20),
	Rect2(2180, 480, 600, 60),
	Rect2(2860, 480, 400, 60),
]

# Враги: x, y
const ENEMIES = [
	Vector2(500, 480),
	Vector2(1150, 480),
	Vector2(1600, 480),
	Vector2(2500, 480),
	Vector2(3000, 480),
]


func _ready():
	for rect in PLATFORMS:
		add_platform(rect)
	for point in ENEMIES:
		var enemy = EnemyScene.instantiate()
		enemy.position = point
		add_child(enemy)
	$Flag.body_entered.connect(_on_flag_reached)


func add_platform(rect):
	var body = StaticBody2D.new()
	body.position = rect.position
	var collision = CollisionShape2D.new()
	collision.shape = RectangleShape2D.new()
	collision.shape.size = rect.size
	collision.position = rect.size / 2
	var picture = ColorRect.new()
	picture.size = rect.size
	picture.color = Color("8b5a2b")
	body.add_child(collision)
	body.add_child(picture)
	add_child(body)
	move_child(body, 0)  # платформы рисуются позади героя


func _process(_delta):
	if Input.is_action_just_pressed("restart"):
		get_tree().reload_current_scene()


func _on_flag_reached(body):
	if body == $Player:
		$Player.set_physics_process(false)
		$UI/Message.text = "Победа!  R — заново"
