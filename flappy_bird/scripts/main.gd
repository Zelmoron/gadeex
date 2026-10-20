extends Node2D

@onready var pipe_scene = preload("res://scenes/pipe.tscn")
@onready var pipes = $pipes
@onready var score_label = $ui/score_label
@onready var end_panel = $ui/end_panel
@onready var end_label = $ui/end_panel/end_label

const WIN_SCORE = 10

var score: int = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	end_panel.hide()


# Таймер срабатывает раз в 1,5 секунды и создаёт новую пару труб
func _on_pipe_timer_timeout() -> void:
	var pipe = pipe_scene.instantiate()
	pipe.position = Vector2(540, randf_range(200, 450))
	pipe.hit.connect(lose)
	pipe.scored.connect(add_point)
	pipes.add_child(pipe)


func add_point() -> void:
	score += 1
	score_label.text = str(score)
	if score >= WIN_SCORE:
		end_game("ПОБЕДА!")


func lose() -> void:
	end_game("ПРОИГРЫШ")


func _on_ground_body_entered(_body: Node2D) -> void:
	lose()


func end_game(text: String) -> void:
	end_label.text = text + "\n\nСЧЁТ: " + str(score)
	end_panel.show()
	get_tree().paused = true   # останавливаем всю игру


func _on_restart_button_pressed() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()


func _on_menu_button_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/menu.tscn")
