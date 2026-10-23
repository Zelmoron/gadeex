extends Node2D

var velocity := Vector2(300, 200)
var player_score := 0
var computer_score := 0


func _ready():
	$Menu/Start.pressed.connect(start_game)
	$Menu/Quit.pressed.connect(get_tree().quit)


func start_game():
	player_score = 0
	computer_score = 0
	$Player.position.y = 210
	$Computer.position.y = 210
	$Menu/Message.text = "Стрелки вверх / вниз. Игра до 7 очков."
	$Menu.hide()
	reset_ball()


func reset_ball():
	$Ball.position = Vector2(394, 244)
	velocity = Vector2([-300, 300].pick_random(), [-200, 200].pick_random())
	$Score.text = "%d : %d" % [player_score, computer_score]


func _physics_process(delta):
	if $Menu.visible:
		return
	$Player.position.y += Input.get_axis("ui_up", "ui_down") * 350 * delta
	$Computer.position.y = move_toward($Computer.position.y, $Ball.position.y - 34, 150 * delta)
	$Player.position.y = clampf($Player.position.y, 0, 420)
	$Computer.position.y = clampf($Computer.position.y, 0, 420)
	$Ball.position += velocity * delta
	if $Ball.position.y <= 0 or $Ball.position.y >= 488:
		velocity.y = -velocity.y
		$Ball.position.y = clampf($Ball.position.y, 0, 488)
	if velocity.x < 0 and $Ball.get_rect().intersects($Player.get_rect()):
		$Ball.position.x = 42
		velocity.x = -velocity.x
	if velocity.x > 0 and $Ball.get_rect().intersects($Computer.get_rect()):
		$Ball.position.x = 746
		velocity.x = -velocity.x
	if $Ball.position.x < -12 or $Ball.position.x > 800:
		if $Ball.position.x < 0:
			computer_score += 1
		else:
			player_score += 1
		reset_ball()
		if player_score == 7 or computer_score == 7:
			$Menu/Message.text = "Победа!" if player_score == 7 else "Поражение!"
			$Menu.show()


func _unhandled_key_input(event):
	if event.is_action_pressed("ui_cancel"):
		$Menu.show()
