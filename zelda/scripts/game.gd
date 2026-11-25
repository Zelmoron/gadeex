extends Node2D

const ROOMS = [
	preload("res://scenes/rooms/forest.tscn"),
	preload("res://scenes/rooms/river.tscn"),
	preload("res://scenes/rooms/ruins.tscn")
]
const ARROW = preload("res://scenes/arrow.tscn")

var mode := "menu"
var room := 0
var area: Node2D
var chest: StaticBody2D
var enemies_left := 0
var seals := 0
var destroyed_targets := {}

@onready var world: Node2D = $World
@onready var hero: CharacterBody2D = $World/Player
@onready var hud: Control = $HUD


func _ready() -> void:
	hud.primary.pressed.connect(_start_or_resume)
	hud.secondary.pressed.connect(_back_or_quit)
	_load_room(0, Vector2(112, 240))
	_set_mode("menu")


func _process(_delta: float) -> void:
	if mode != "play":
		return
	if hero.position.x >= 880.0 and room < ROOMS.size() - 1:
		_load_room(room + 1, Vector2(48, hero.position.y))
	elif hero.position.x <= 16.0 and room > 0:
		_load_room(room - 1, Vector2(848, hero.position.y))


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause") and not event.is_echo():
		if mode == "play":
			_set_mode("pause")
		elif mode == "pause":
			_set_mode("play")


func _load_room(next_room: int, arrival: Vector2) -> void:
	if area != null:
		world.remove_child(area)
		area.queue_free()

	room = next_room
	area = ROOMS[room].instantiate()
	chest = area.get_node_or_null("Chest")
	enemies_left = 0

	for actor in area.get_children():
		if not actor.is_in_group("targets"):
			continue
		var key := "%s/%s" % [area.name, actor.name]
		if destroyed_targets.has(key):
			actor.free()
			continue
		var is_enemy := actor is CharacterBody2D
		if is_enemy:
			actor.hero = hero
			enemies_left += 1
		actor.destroyed.connect(_record_destroyed_target.bind(key, is_enemy))

	world.add_child(area)
	hero.position = arrival
	hero.reset_physics_interpolation()
	hud.show_health(hero.health)


func _on_attacked(weapon: StringName) -> void:
	if weapon == &"sword":
		_swing_sword()
		return

	var arrow = ARROW.instantiate()
	arrow.direction = hero.facing
	arrow.rotation = hero.facing.angle()
	area.add_child(arrow)
	arrow.global_position = hero.global_position + Vector2(0, -4)


func _swing_sword() -> void:
	for target in get_tree().get_nodes_in_group("targets"):
		var offset: Vector2 = target.global_position - hero.global_position
		var distance := offset.length()
		if distance > 52.0 or (distance > 12.0 and hero.facing.dot(offset.normalized()) < 0.4):
			continue
		var query := PhysicsRayQueryParameters2D.create(hero.global_position, target.global_position, 1)
		if get_world_2d().direct_space_state.intersect_ray(query).is_empty():
			target.hit(hero.global_position)


func _near_chest() -> bool:
	return chest != null and hero.global_position.distance_to(chest.global_position) < 57.0


func _on_interacted() -> void:
	if _near_chest() and seals == ROOMS.size():
		chest.get_node("Sprite").frame = 1
		_set_mode("won")


func _record_destroyed_target(key: String, is_enemy: bool) -> void:
	destroyed_targets[key] = true
	if not is_enemy:
		hero.heal()
		return

	enemies_left -= 1
	if enemies_left == 0:
		seals += 1


func _on_health_changed() -> void:
	hud.show_health(hero.health)
	if hero.health == 0:
		_set_mode("lost")


func _set_mode(next_mode: String) -> void:
	mode = next_mode
	get_tree().paused = mode != "play"
	hud.show_overlay(mode)


func _reset_game() -> void:
	destroyed_targets.clear()
	seals = 0
	hero.reset()
	_load_room(0, Vector2(112, 240))


func _start_or_resume() -> void:
	if mode != "pause":
		_reset_game()
	_set_mode("play")


func _back_or_quit() -> void:
	if mode == "menu":
		get_tree().quit()
	else:
		_reset_game()
		_set_mode("menu")
