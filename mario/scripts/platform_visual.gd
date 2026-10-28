@tool
extends Node2D

const Art = preload("res://scripts/art.gd")
@export var fragile = false
var top_texture = Art.tile(1)
var side_texture = Art.tile(0)


func _draw() -> void:
	var platform = get_parent()
	var width: float = platform.width
	var depth: float = platform.depth
	var damage = 0.0
	if fragile and not Engine.is_editor_hint():
		damage = clampf(platform.loaded_time / platform.break_delay, 0, 1)
		var shake = sin(platform.loaded_time * 85.0) * damage * 1.5
		draw_set_transform(Vector2(shake, 0))
	for x in range(0, int(width), 48):
		for y in range(0, int(depth), 48):
			var rectangle = Rect2(x, y, minf(48, width - x), minf(48, depth - y))
			var texture = side_texture
			if y == 0:
				texture = top_texture
			draw_texture_rect(texture, rectangle, false)
	if fragile:
		draw_cracks(width, depth, damage)


func draw_cracks(width: float, depth: float, damage: float) -> void:
	draw_rect(Rect2(0, 0, width, depth), Color(0.9, 0.4, 0.12, 0.2))
	draw_rect(Rect2(0, 0, width, 3), Color("e5a259").lerp(Color("f45e42"), damage))
	for x in range(5, int(width) - 6, 12):
		draw_line(Vector2(x, depth - 4), Vector2(x + 5, depth - 10), Color("e5a259"), 2)
	for x in range(20, int(width), 40):
		var crack = PackedVector2Array([
			Vector2(x, 3), Vector2(x - 4, 8), Vector2(x + 2, 12),
			Vector2(x - 3, lerpf(14, depth - 2, damage)),
		])
		draw_polyline(crack, Color("241a1a"), 1 + damage * 2)
	if damage > 0:
		draw_rect(Rect2(5, 5, (width - 10) * (1 - damage), 2), Color("ffd08a"))
