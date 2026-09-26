extends SceneTree

var failures := 0
var landing_count := 0
var room: Node
var player: CharacterBody2D
var crawler: CharacterBody2D

func _initialize() -> void:
	call_deferred("run")

func frames(count: int) -> void:
	for i in count:
		await physics_frame
		await process_frame

func check(condition: bool, description: String) -> void:
	if condition:
		print("PASS: " + description)
	else:
		push_error("FAIL: " + description)
		failures += 1

func run() -> void:
	room = load("res://tests/fixtures/week_2_room.tscn").instantiate()
	root.add_child(room)
	current_scene = room
	player = room.get_node("Player")
	crawler = room.get_node("CaveCrawler")
	player.landed.connect(func(): landing_count += 1)
	await frames(15)
	check(player.is_on_floor(), "player settles on the floor")
	var start_x := player.position.x
	Input.action_press("move_right")
	await frames(20)
	Input.action_release("move_right")
	check(player.position.x > start_x + 55, "right input moves at approximately 200 px/s")
	Input.action_press("move_left")
	await frames(10)
	Input.action_release("move_left")
	check(player.facing == -1, "left input changes direction")
	var start_y := player.position.y
	Input.action_press("jump")
	await frames(1)
	Input.action_release("jump")
	await frames(15)
	check(player.position.y < start_y - 55, "jump rises against gravity")
	var airborne_velocity := player.velocity.y
	Input.action_press("jump")
	await frames(1)
	Input.action_release("jump")
	check(player.velocity.y > airborne_velocity, "jump cannot be repeated in midair")
	await frames(45)
	check(player.is_on_floor() and landing_count >= 2, "landing collision triggers dust signal")
	check(player.dust.one_shot and player.dust.amount > 0, "landing particle emitter is configured")
	# Verify each teaching jump using actual input and physics.
	crawler.set_physics_process(false)
	player.position = Vector2(150, 462)
	player.velocity = Vector2.ZERO
	await frames(4)
	for destination in [Vector2(265, 410), Vector2(440, 330), Vector2(610, 373)]:
		Input.action_press("jump")
		Input.action_press("move_right")
		await frames(1)
		Input.action_release("jump")
		var ticks := 0
		while player.position.x < destination.x and ticks < 65:
			await frames(1)
			ticks += 1
		Input.action_release("move_right")
		await frames(40)
		check(player.is_on_floor() and absf(player.position.y - (destination.y - 18)) < 3, "platform reachable at x=" + str(destination.x))
	# Keep player away while checking crawler's edge and wall rays.
	player.position = Vector2(90, 462)
	player.velocity = Vector2.ZERO
	crawler.set_physics_process(true)
	crawler.position = Vector2(596, 361)
	crawler.direction = -1
	await frames(30)
	check(crawler.direction == 1 and crawler.position.y < 380, "crawler turns before platform edge")
	crawler.position = Vector2(938, 468)
	crawler.direction = 1
	await frames(30)
	check(crawler.direction == -1, "crawler turns at wall")
	# Place combatants just outside contact range but inside stick range.
	player.health = 3
	player.invincibility = 0.0
	player.knockback_time = 0.0
	crawler.position = Vector2(400, 468)
	crawler.velocity = Vector2.ZERO
	crawler.set_physics_process(false)
	player.position = Vector2(365, 462)
	player.velocity = Vector2.ZERO
	player.facing = 1
	await frames(4)
	Input.action_press("attack")
	await frames(1)
	Input.action_release("attack")
	await frames(12)
	check(crawler.health == 1, "one swing damages an enemy exactly once")
	player.begin_attack()
	check(player.attack_time == 0, "cooldown prevents an early second swing")
	await frames(12)
	Input.action_press("attack")
	await frames(1)
	Input.action_release("attack")
	await frames(12)
	check(not is_instance_valid(crawler), "second swing defeats the crawler")
	# Real contact Area2D damage and invincibility.
	crawler = load("res://scenes/enemies/cave_crawler.tscn").instantiate()
	crawler.position = Vector2(365, 468)
	room.add_child(crawler)
	await frames(3)
	check(player.health == 2, "crawler contact removes one health")
	player.take_damage(1, 400)
	check(player.health == 2, "invincibility rejects repeated damage")
	crawler.queue_free()
	await frames(65)
	player.take_damage(1, 400)
	check(player.health == 1, "damage works after invincibility expires")
	await frames(65)
	player.take_damage(1, 400)
	await frames(5)
	check(current_scene != room and current_scene.get_node("Player").health == 3, "death reloads room with full health")
	print("Week 2 smoke test failures: ", failures)
	quit(1 if failures else 0)
