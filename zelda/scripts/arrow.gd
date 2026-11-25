extends Node2D

const SPEED := 435.0

var direction := Vector2.RIGHT
var time_left := 0.72


func _physics_process(delta: float) -> void:
	var next := global_position + direction * SPEED * delta
	var query := PhysicsRayQueryParameters2D.create(global_position, next, 7)
	var collision := get_world_2d().direct_space_state.intersect_ray(query)
	if not collision.is_empty():
		var body = collision.collider
		if body.has_method("hit"):
			body.hit(global_position)
		queue_free()
		return

	global_position = next
	time_left -= delta
	if time_left <= 0.0:
		queue_free()
