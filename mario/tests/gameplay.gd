extends SceneTree

var failures = 0
var game: Node2D


func _initialize() -> void:
	run.call_deferred()


func check(condition: bool, description: String) -> void:
	if not condition:
		failures += 1
		push_error(description)


func step(count: int) -> void:
	for index in range(count):
		await physics_frame
		await process_frame


func reset_game() -> void:
	for action in ["move_left", "move_right", "jump", "sprint", "restart"]:
		Input.action_release(action)
	if is_instance_valid(game):
		game.free()
	game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	current_scene = game
	await step(10)


func run() -> void:
	await reset_game()
	check(game.player.is_on_floor(), "Player must land on the floor")
	check(get_nodes_in_group("droids").size() == 6, "Six patrol droids must exist")
	var start_x: float = game.player.position.x
	Input.action_press("move_right")
	await step(50)
	check(game.player.position.x - start_x > 130, "Walking must move the player")
	var walk_speed: float = game.player.velocity.x
	Input.action_press("sprint")
	await step(15)
	check(game.player.velocity.x > walk_speed + 100, "Shift must enable running")
	Input.action_release("move_right")
	Input.action_release("sprint")
	game.player.position = Vector2(432, 455)
	game.player.velocity = Vector2.ZERO
	await step(5)
	Input.action_press("jump")
	await step(20)
	Input.action_release("jump")
	await step(5)
	var bonus_block: Node2D
	for block in get_nodes_in_group("blocks"):
		if block.position == Vector2(432, 336):
			bonus_block = block
	check(bonus_block.used, "Hitting the bonus crate from below must open it")
	check(get_nodes_in_group("pickups").size() == 1, "Bonus crate must spawn one energy cell")
	bonus_block.hit_from_below()
	await step(2)
	check(get_nodes_in_group("pickups").size() == 1, "Bonus crate must not spawn a second cell")
	var cell = get_nodes_in_group("pickups")[0]
	game.player.position = cell.position + Vector2(0, 22)
	game.player.velocity = Vector2.ZERO
	await step(5)
	check(game.player.shield_time > 0, "Touching an energy cell must give a shield")
	check(get_nodes_in_group("pickups").is_empty(), "Collected cell must disappear")
	await reset_game()
	var blocks_before = get_nodes_in_group("blocks").size()
	game.player.position = Vector2(528, 455)
	await step(5)
	Input.action_press("jump")
	await step(25)
	Input.action_release("jump")
	check(get_nodes_in_group("blocks").size() == blocks_before - 1, "Hitting a cracked crate must destroy it")
	await reset_game()
	var droid = get_nodes_in_group("droids")[0]
	droid.set_physics_process(false)
	droid.position = Vector2(1900, 456)
	game.player.position = Vector2(1900, 365)
	game.player.velocity = Vector2(0, 170)
	await step(24)
	check(not droid.alive, "Jumping onto a droid must defeat it")
	check(game.player.alive, "Stomping must not kill the player")
	check(game.defeated_droids == 1, "Droid counter must increase")
	await reset_game()
	droid = get_nodes_in_group("droids")[0]
	droid.set_physics_process(false)
	droid.position = Vector2(1900, 456)
	game.player.collect_shield()
	game.player.position = Vector2(1900, 455)
	await step(5)
	check(game.player.alive and game.player.shield_time == 0.0, "Shield must absorb a side collision")
	check(not droid.alive, "Shield collision must destroy the droid")
	await reset_game()
	droid = get_nodes_in_group("droids")[0]
	droid.set_physics_process(false)
	droid.position = Vector2(1900, 456)
	game.player.position = Vector2(1900, 455)
	await step(5)
	check(not game.player.alive, "Unprotected side collision must defeat the player")
	await step(90)
	game = current_scene
	check(game.player.alive and game.player.position.x < 200, "Death must restart the level")
	game.player.position = Vector2(1185, 650)
	await step(45)
	check(not game.player.alive, "Falling into a pit must defeat the player")
	await step(90)
	game = current_scene
	game.player.collect_shield()
	await step(490)
	check(game.player.shield_time == 0.0, "Shield must expire after eight seconds")
	check(get_nodes_in_group("droids").size() == game.total_droids, "Patrols must not walk into the shafts")
	for patrol in get_nodes_in_group("droids"):
		check(patrol.is_on_floor() and patrol.position.y < 500, "Patrols must stay on their platforms")
	await check_crumbling_platforms()
	await reset_game()
	await step(10)
	var actor = game.player
	var completed = await follow_route()
	print("Full run: x=", actor.position.x, ", alive=", actor.alive, ", won=", game.won)
	check(completed and game.won, "The level must be completable with movement and jump input")
	check(actor.get_node("Camera2D").get_screen_center_position().x > 4000, "Camera must follow the player through the level")
	for action in ["move_right", "sprint", "jump"]:
		Input.action_release(action)
	Input.action_press("restart")
	await step(3)
	Input.action_release("restart")
	game = current_scene
	check(not game.won and game.player.alive and game.player.position.x < 200, "R must restart the game after victory")
	Input.action_press("move_left")
	Input.action_press("sprint")
	await step(65)
	check(game.player.position.x > 0 and game.player.is_on_wall(), "Left wall must keep the player inside the level")
	Input.action_release("move_left")
	Input.action_release("sprint")
	if is_instance_valid(game):
		game.free()
	print("Gameplay failures: ", failures)
	quit(0 if failures == 0 else 1)


func travel(target: Vector2, jumping: bool) -> bool:
	var actor = game.player
	Input.action_release("jump")
	await step(1)
	if jumping:
		Input.action_press("jump")
	Input.action_press("sprint")
	var airborne = false
	for frame in range(180):
		if not actor.alive:
			break
		if not actor.is_on_floor():
			airborne = true
		var remaining: float = target.x - actor.position.x
		if absf(remaining) > 22:
			Input.action_press("move_right" if remaining > 0 else "move_left")
			Input.action_release("move_left" if remaining > 0 else "move_right")
		else:
			Input.action_release("move_right")
			Input.action_release("move_left")
		if actor.is_on_floor() and absf(remaining) < 26 and absf(actor.position.y - target.y) < 8 and (not jumping or airborne):
			Input.action_release("move_right")
			Input.action_release("move_left")
			Input.action_release("jump")
			await step(8)
			return actor.alive
		await step(1)
	push_error("Route failed near %s, target %s" % [actor.position, target])
	return false


func follow_route() -> bool:
	for point in [
		Vector3(680, 456, 0), Vector3(780, 408, 1), Vector3(930, 360, 1),
		Vector3(980, 360, 0), Vector3(1240, 456, 1), Vector3(1450, 456, 1),
		Vector3(1536, 408, 1), Vector3(1660, 360, 1), Vector3(1830, 360, 1),
		Vector3(2020, 312, 1), Vector3(2080, 312, 0), Vector3(2250, 264, 1),
		Vector3(2330, 264, 0), Vector3(2500, 336, 1), Vector3(2570, 336, 0),
		Vector3(2720, 456, 1), Vector3(2740, 456, 0), Vector3(2970, 408, 1),
		Vector3(3150, 360, 1), Vector3(3235, 360, 0), Vector3(3400, 312, 1),
		Vector3(3590, 264, 1), Vector3(3800, 336, 1), Vector3(3860, 336, 0),
		Vector3(4020, 456, 1), Vector3(4240, 456, 1), Vector3(4360, 408, 1),
		Vector3(4428, 360, 1), Vector3(4580, 360, 1), Vector3(4750, 312, 1),
		Vector3(4820, 312, 0), Vector3(5025, 456, 1),
	]:
		if not await travel(Vector2(point.x, point.y), point.z > 0):
			return false
	return game.won


func check_crumbling_platforms() -> void:
	await reset_game()
	check(get_nodes_in_group("crumbling_platforms").size() == 4, "The lesson block and three shaft platforms must exist")
	var fragile = get_nodes_in_group("crumbling_platforms")[1]
	await step(90)
	check(fragile.loaded_time == 0, "A platform without a standing player must remain intact")
	game.player.position = Vector2(3355, 325)
	game.player.velocity = Vector2.ZERO
	await step(4)
	check(fragile.loaded_time == 0, "Touching the side must not damage a platform")
	game.player.position = Vector2(3400, 390)
	game.player.velocity = Vector2(0, -200)
	await step(8)
	check(fragile.loaded_time == 0, "Hitting a platform from below must not damage it")
	game.player.position = Vector2(3400, 280)
	game.player.velocity = Vector2.ZERO
	await step(30)
	check(game.player.is_on_floor() and fragile.loaded_time > 0.1, "Standing on top must start damaging the platform")
	check(fragile.loaded_time < 0.6, "A short landing must leave time to jump")
	Input.action_press("jump")
	await step(8)
	var damage: float = fragile.loaded_time
	check(damage > 0.1, "Jumping away must preserve existing damage")
	await step(10)
	check(not game.player.is_on_floor(), "The player must be airborne for the pause check")
	check(is_equal_approx(fragile.loaded_time, damage), "Damage must pause while the player is airborne")
	Input.action_release("jump")
	for frame in range(120):
		if not is_instance_valid(fragile):
			break
		await step(1)
	check(not is_instance_valid(fragile), "Prolonged standing must destroy the platform")
	await step(15)
	check(game.player.position.y > 340, "Destroyed platform must stop supporting the player")
	await step(160)
	game = current_scene
	check(game.player.alive and game.player.position.x < 200, "Falling after collapse must restart the level")
	check(get_nodes_in_group("crumbling_platforms").size() == 4, "Restart must restore all fragile platforms")
	for restored in get_nodes_in_group("crumbling_platforms"):
		check(restored.loaded_time == 0, "Restored platforms must have full strength")

	game.player.position = Vector2(2970, 400)
	game.player.velocity = Vector2.ZERO
	await step(110)
	check(game.player.alive and game.player.is_on_floor() and game.player.position.y > 450, "The introductory fragile step must have a safe floor beneath it")
