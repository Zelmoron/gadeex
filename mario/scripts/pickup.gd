extends CharacterBody2D

signal collected

var active = true
var clock = 0.0
@onready var picture: Sprite2D = $Sprite


func _ready() -> void:
	velocity = Vector2(85, -200)


func _physics_process(delta: float) -> void:
	clock += delta
	velocity.y = minf(velocity.y + 900 * delta, 600.0)
	var old_x = velocity.x
	move_and_slide()
	if is_on_wall():
		velocity.x = -old_x
	picture.position.y = sin(clock * 5.0) * 2.0
	if position.y > 800:
		queue_free()


func _on_body_entered(body: Node2D) -> void:
	if active and body.is_in_group("player") and body.alive:
		active = false
		body.collect_shield()
		collected.emit()
		queue_free()
