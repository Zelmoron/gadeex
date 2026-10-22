extends StaticBody2D

@export var width = 48.0
@export var depth = 48.0


func _ready() -> void:
	$CollisionShape2D.position = Vector2(width, depth) / 2.0
	$CollisionShape2D.shape.size = Vector2(width, depth)
	$Visual.queue_redraw()
