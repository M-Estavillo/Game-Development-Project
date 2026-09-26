extends SceneTree

var failures := 0
var room: Node
var player: CharacterBody2D
var manager: Node

func _initialize() -> void:
	call_deferred("run")

func frames(count: int) -> void:
	for i in count:
		await physics_frame
		await process_frame

func check(ok: bool, description: String) -> void:
	print(("PASS: " if ok else "FAIL: ") + description)
	if not ok:
		failures += 1

func load_level(number: int) -> void:
	change_scene_to_file("res://scenes/level_%s.tscn" % number)
	await frames(12)
	room = current_scene
	player = room.get_node("Player")

func walk_to(x: float, jump := false) -> bool:
	if jump:
		Input.action_press("jump")
	Input.action_press("move_right")
	for i in 900:
		await frames(1)
		Input.action_release("jump")
		if is_instance_valid(player):
			var target_near := false
			for enemy in room.get_children():
				if enemy is CharacterBody2D and enemy != player and enemy.health > 0:
					var separation: Vector2 = enemy.position - player.position
					if separation.x > 0 and separation.x < 58 and absf(separation.y) < 40:
						target_near = true
						break
			if target_near:
				if player.is_on_floor():
					Input.action_release("move_right")
				if i % 2 == 0:
					Input.action_press("attack")
				else:
					Input.action_release("attack")
			else:
				Input.action_press("move_right")
				Input.action_release("attack")
		if not is_instance_valid(player) or current_scene != room:
			Input.action_release("move_right")
			Input.action_release("attack")
			return false
		if player.position.x >= x or room.transitioning:
			Input.action_release("move_right")
			Input.action_release("attack")
			return true
	Input.action_release("move_right")
	Input.action_release("attack")
	return false

func route(points: Array) -> bool:
	for point in points:
		if not await walk_to(point.x, point.y == 1):
			print("Route failed heading to ", point)
			return false
		if point.y == 1:
			await frames(35)
		if not is_instance_valid(player) or current_scene != room:
			print("Died after waypoint ", point)
			return false
	return true

func run() -> void:
	manager = root.get_node("GameManager")
	manager.collected.clear()
	await load_level(1)
	check(room.get_node("Terrain").get_used_cells().size() > 100 and player.is_on_floor(), "Level 1 uses collidable TileMapLayer terrain")
	var first = await route([Vector2(550,0), Vector2(680,1), Vector2(868,0), Vector2(1020,1), Vector2(1260,0), Vector2(1410,1), Vector2(1665,0), Vector2(1820,1), Vector2(2110,0)])
	check(first, "Level 1 traversed from spawn to exit with input, hazards and enemies active")
	await frames(155)
	check(current_scene.name == "Level2", "Level 1 exit loads Level 2 without requiring pebbles")
	if current_scene.name != "Level2":
		await load_level(2)
	else:
		room = current_scene
		player = room.get_node("Player")
	var second = await route([Vector2(430,0), Vector2(570,1), Vector2(802,0), Vector2(960,1), Vector2(1008,0), Vector2(1165,1), Vector2(1377,0), Vector2(1535,1), Vector2(1590,0), Vector2(1740,1), Vector2(1855,0), Vector2(2015,1), Vector2(2440,0)])
	await frames(5)
	check(second and manager.completed, "Level 2 traversed and final goal completes the run")
	# Independent collection and restart checks use actual overlap detection.
	manager.collected.clear()
	manager.completed = false
	for level in [1,2]:
		await load_level(level)
		var pebbles: Array[Node] = []
		for child in room.get_children():
			if child is Area2D and child.get_script() == load("res://scripts/pebble.gd"):
				pebbles.append(child)
		check(pebbles.size() == 3, "Level %s has exactly three pebbles" % level)
		for pebble in pebbles:
			player.position = pebble.position
			player.velocity = Vector2.ZERO
			await frames(4)
		check(manager.collected.size() == level * 3, "Level %s collects pebbles through Area2D" % level)
	check(manager.collected.size() == 6, "pebble total persists across levels")
	await load_level(2)
	var remaining := 0
	for child in room.get_children():
		if child is Area2D and child.get_script() == load("res://scripts/pebble.gd"):
			remaining += 1
	check(remaining == 0 and manager.collected.size() == 6, "restart cannot duplicate collected pebbles")
	player.position = Vector2(1920, 390)
	player.velocity = Vector2.ZERO
	await frames(15)
	check(player.health == 2, "spikes damage on contact with invincibility")
	player.position = Vector2(1664, 670)
	await frames(12)
	check(current_scene != room and current_scene.name == "Level2", "falling restarts the current level")
	check(manager.collected.size() == 6, "death preserves collected pebble IDs")
	manager.new_run()
	await frames(12)
	check(current_scene.name == "Level1" and manager.collected.is_empty(), "new run resets progress and starts Level 1")
	print("Week 3 test failures: ", failures)
	quit(1 if failures else 0)
