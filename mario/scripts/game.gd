extends Node2D

const PickupScene = preload("res://scenes/pickup.tscn")
const DebrisScene = preload("res://scenes/debris.tscn")
const Art = preload("res://scripts/art.gd")

var defeated_droids = 0
var total_droids = 0
var cells = 0
var won = false
var restarting = false
var elapsed = 0.0

@onready var player: CharacterBody2D = $Player
@onready var world: Node2D = $Level
@onready var hud: Control = $HUD/Interface
@onready var gate: Sprite2D = $Level/Gate


func _ready() -> void:
	hud.game = self
	player.defeated.connect(_on_player_defeated)
	$Level/Exit.body_entered.connect(_on_exit_entered)
	for block in get_tree().get_nodes_in_group("blocks"):
		block.opened.connect(_on_block_opened)
	for platform in get_tree().get_nodes_in_group("crumbling_platforms"):
		platform.crumbled.connect(_on_platform_crumbled)
	for droid in get_tree().get_nodes_in_group("droids"):
		droid.destroyed.connect(_on_droid_destroyed)
		total_droids += 1
	player.get_node("Camera2D").reset_smoothing()


func _process(delta: float) -> void:
	if not won and player.alive:
		elapsed += delta
	if Input.is_action_just_pressed("restart"):
		get_tree().reload_current_scene()


func _on_block_opened(at: Vector2, has_bonus: bool) -> void:
	if has_bonus:
		spawn_pickup.call_deferred(at + Vector2(0, -45))
	else:
		spawn_debris(at)


func _on_platform_crumbled(at: Vector2) -> void:
	spawn_debris(at)


func _on_droid_destroyed() -> void:
	defeated_droids += 1


func _on_pickup_collected() -> void:
	cells += 1


func spawn_debris(at: Vector2) -> void:
	var effect = DebrisScene.instantiate()
	effect.position = at
	world.add_child(effect)


func spawn_pickup(at: Vector2) -> void:
	var pickup = PickupScene.instantiate()
	pickup.position = at
	world.add_child(pickup)
	pickup.collected.connect(_on_pickup_collected)


func _on_player_defeated() -> void:
	if restarting:
		return
	restarting = true
	hud.message("ПОПЫТКА ПРЕРВАНА", "Возвращаемся в начало…")
	await get_tree().create_timer(1.2).timeout
	if is_inside_tree():
		get_tree().reload_current_scene()


func _on_exit_entered(body: Node2D) -> void:
	if won or not body.is_in_group("player") or not body.alive:
		return
	won = true
	body.controls_enabled = false
	gate.texture = Art.tile(13)
	var minutes = int(elapsed) / 60
	var seconds = int(elapsed) % 60
	var result = "%02d:%02d  ·  Дроиды %d/%d  ·  R — пройти ещё раз"
	hud.message("ТЫ ВЫБРАЛСЯ С БАЗЫ", result % [minutes, seconds, defeated_droids, total_droids])
