extends Node2D

signal hit
signal scored

const SPEED = 150

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	position.x -= SPEED * delta
	# Труба ушла за левый край экрана, удаляем её
	if position.x < -100:
		queue_free()


# Птица задела верхнюю или нижнюю трубу
func _on_pipe_body_entered(_body: Node2D) -> void:
	hit.emit()


# Птица пролетела между трубами
func _on_score_area_body_entered(_body: Node2D) -> void:
	scored.emit()
