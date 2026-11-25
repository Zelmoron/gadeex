extends Control

const MENU_TEXT = {
	"menu": ["Янтарный брод", "Играть"],
	"pause": ["Пауза", "Продолжить"],
	"lost": ["Поражение", "Начать заново"],
	"won": ["Победа", "Сыграть ещё раз"]
}
const HEART = [
	Vector2(0, 3), Vector2(3, 0), Vector2(6, 0), Vector2(9, 3), Vector2(12, 0),
	Vector2(15, 0), Vector2(18, 3), Vector2(18, 8), Vector2(9, 16), Vector2(0, 8)
]

var health := 5

@onready var overlay: ColorRect = $Overlay
@onready var primary: Button = $Overlay/Panel/Primary
@onready var secondary: Button = $Overlay/Panel/Secondary


func show_health(value: int) -> void:
	health = value
	queue_redraw()


func show_overlay(mode: String) -> void:
	overlay.visible = mode != "play"
	queue_redraw()
	if not overlay.visible:
		return

	$Overlay/Panel/Title.text = MENU_TEXT[mode][0]
	primary.text = MENU_TEXT[mode][1]
	secondary.text = "Выйти" if mode == "menu" else "В главное меню"
	primary.grab_focus()


func _draw() -> void:
	if overlay.visible:
		return
	draw_rect(Rect2(12, 12, 126, 32), Color("#26312bd9"))
	for i in range(5):
		draw_set_transform(Vector2(19 + i * 23, 20))
		draw_colored_polygon(PackedVector2Array(HEART), Color("#ef8776") if i < health else Color("#716768"))
	draw_set_transform(Vector2.ZERO)
