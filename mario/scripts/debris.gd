extends Node2D

const Art = preload("res://scripts/art.gd")


func _ready() -> void:
	for index in range(4):
		var piece = Art.sprite(15, Vector2(24, 24))
		add_child(piece)
		var tween = create_tween().set_parallel(true)
		tween.tween_property(piece, "position", Vector2((index - 1.5) * 45, 90), 0.5).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
		tween.tween_property(piece, "rotation", (index - 1.5) * 2, 0.5)
		tween.tween_property(piece, "modulate:a", 0.0, 0.5)
	await get_tree().create_timer(0.5).timeout
	queue_free()
