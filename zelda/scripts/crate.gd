extends StaticBody2D

signal destroyed

var intact := true

@onready var sprite: AnimatedSprite2D = $Sprite


func hit(_from: Vector2) -> void:
	if not intact:
		return
	intact = false
	set_deferred("collision_layer", 0)
	sprite.play("break")
	destroyed.emit()
	await sprite.animation_finished
	queue_free()
