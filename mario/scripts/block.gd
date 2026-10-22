extends StaticBody2D

signal opened(block_position: Vector2, bonus: bool)

const Art = preload("res://scripts/art.gd")
@export var bonus = false
var used = false
@onready var picture: Sprite2D = $Sprite


func _ready() -> void:
	if bonus:
		picture.texture = Art.tile(3)
	else:
		picture.texture = Art.tile(2)
	picture.scale = Vector2(48, 48) / picture.texture.get_size()


func hit_from_below() -> void:
	if used:
		return
	used = true
	opened.emit(global_position, bonus)
	if bonus:
		picture.texture = Art.tile(14)
		var tween = create_tween()
		tween.tween_property(picture, "position:y", -9.0, 0.08)
		tween.tween_property(picture, "position:y", 0.0, 0.12)
	else:
		$CollisionShape2D.set_deferred("disabled", true)
		queue_free()
