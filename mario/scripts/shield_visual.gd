extends Node2D


func _draw() -> void:
	var player = get_parent()
	if player.shield_time > 0.0 and player.alive:
		var color = Color(0.25, 0.9, 1.0, 0.65)
		draw_arc(Vector2(0, -25), 34, 0, TAU, 48, color, 2.0)
		draw_circle(Vector2(0, -25), 33, Color(0.1, 0.7, 1.0, 0.07))
