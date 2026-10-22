extends RefCounted

const KIT = preload("res://assets/kit.png")
const REGIONS = [
	Rect2(47, 58, 268, 255),
	Rect2(336, 111, 287, 202),
	Rect2(653, 64, 254, 249),
	Rect2(947, 64, 257, 249),
	Rect2(60, 362, 226, 244),
	Rect2(370, 362, 230, 244),
	Rect2(663, 362, 254, 244),
	Rect2(981, 362, 228, 244),
	Rect2(66, 665, 223, 224),
	Rect2(353, 705, 287, 182),
	Rect2(640, 736, 290, 157),
	Rect2(1038, 658, 105, 235),
	Rect2(47, 920, 268, 268),
	Rect2(343, 920, 275, 268),
	Rect2(651, 934, 258, 251),
	Rect2(976, 965, 228, 209)
]


static func tile(index: int) -> AtlasTexture:
	var texture = AtlasTexture.new()
	texture.atlas = KIT
	texture.region = REGIONS[index]
	return texture


static func sprite(index: int, size: Vector2) -> Sprite2D:
	var node = Sprite2D.new()
	node.texture = tile(index)
	node.scale = size / node.texture.get_size()
	return node
