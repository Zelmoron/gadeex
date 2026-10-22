extends Control

const Style = preload("res://scripts/interface_style.gd")

var game: Node2D
var progress = 0.0

@onready var sector: Label = $Sector
@onready var status: Label = $Status
@onready var counter: Label = $Counter
@onready var banner: Label = $Banner
@onready var subtitle: Label = $Subtitle


func _process(_delta: float) -> void:
	if not is_instance_valid(game) or not is_instance_valid(game.player):
		return
	var x: float = game.player.position.x
	if x < 1880:
		sector.text = "01 / БЛОК СОДЕРЖАНИЯ"
	elif x < 3984:
		sector.text = "02 / ТЕХНИЧЕСКАЯ ШАХТА"
	else:
		sector.text = "03 / ПОСАДОЧНЫЙ АНГАР"
	progress = clampf(x / 5050.0, 0, 1)
	if game.player.shield_time > 0:
		status.text = "%.1f СЕК" % game.player.shield_time
	else:
		status.text = "НЕТ ЩИТА"
	counter.text = "%02d / %02d" % [game.defeated_droids, game.total_droids]
	queue_redraw()


func message(main_text: String, detail: String) -> void:
	banner.text = main_text
	subtitle.text = detail
	queue_redraw()


func _draw() -> void:
	draw_rect(Rect2(0, 0, 960, 68), Color("08131ef5"))
	draw_line(Vector2(24, 67), Vector2(936, 67), Color("35515e"))
	draw_rect(Rect2(18, 17, 3, 30), Style.ORANGE)
	for x in [294, 649, 810]:
		draw_line(Vector2(x, 16), Vector2(x, 49), Color("213744"))
	for index in range(30):
		var color = Color("243d49")
		if float(index) / 30 < progress:
			color = Style.CYAN
		draw_rect(Rect2(322 + index * 10, 52, 7, 2), color)
	draw_rect(Rect2(0, 498, 960, 42), Color("08131ef5"))
	draw_line(Vector2(24, 498), Vector2(936, 498), Color("35515e"))
	if is_instance_valid(banner) and not banner.text.is_empty():
		draw_style_box(Style.plate(Style.CYAN), Rect2(180, 182, 600, 112))
		draw_line(Vector2(202, 194), Vector2(246, 194), Style.CYAN, 2)
		draw_line(Vector2(714, 282), Vector2(758, 282), Style.CYAN, 2)
