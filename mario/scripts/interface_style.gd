extends RefCounted

const INK = Color("c9dce2")
const MUTED = Color("7797a4")
const CYAN = Color("70c6d1")
const ORANGE = Color("e6a264")


static func plate(accent: Color) -> StyleBoxFlat:
	var style = StyleBoxFlat.new()
	style.bg_color = Color("0c1b26f5")
	style.set_border_width_all(1)
	style.border_width_left = 3
	style.border_color = accent.darkened(0.55)
	style.content_margin_left = 14
	style.content_margin_right = 14
	style.content_margin_top = 9
	style.content_margin_bottom = 10
	style.shadow_color = Color(0, 0, 0, 0.35)
	style.shadow_size = 2
	style.shadow_offset = Vector2(2, 3)
	return style
