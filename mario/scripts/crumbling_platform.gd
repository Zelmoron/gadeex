extends "res://scripts/platform.gd"

signal crumbled(at: Vector2)

@export_range(0.2, 5.0, 0.1) var break_delay = 1.2
var loaded_time = 0.0
@onready var sensor: Area2D = $StandArea


func _ready() -> void:
	super._ready()
	$StandArea/CollisionShape2D.position = Vector2(width / 2.0, -1)
	$StandArea/CollisionShape2D.shape.size = Vector2(width, 4)


func _physics_process(delta: float) -> void:
	for body in sensor.get_overlapping_bodies():
		if is_standing_on_top(body):
			loaded_time += delta
			break
	if loaded_time >= break_delay:
		collision_layer = 0
		crumbled.emit(global_position + Vector2(width, depth) / 2.0)
		queue_free()
		return
	if loaded_time > 0:
		$Visual.queue_redraw()


func is_standing_on_top(body: Node2D) -> bool:
	if not body.is_in_group("player"):
		return false
	if not body.alive or not body.is_on_floor():
		return false
	return absf(body.global_position.y - global_position.y) < 2
