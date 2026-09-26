extends Node2D

@export_range(1, 2) var level_number := 1
var transitioning := false
var stage_width := 2240
var message: Label
var counter: Label
var exit_gate: Area2D
var terrain: TileMapLayer
const PLAYER = preload("res://scenes/player/player.tscn")
const CRAWLER = preload("res://scenes/enemies/cave_crawler.tscn")
const PEBBLE = preload("res://scenes/objects/pebble.tscn")
const SPIKES = preload("res://scenes/objects/spikes.tscn")
const EXIT = preload("res://scenes/objects/exit.tscn")

func _ready() -> void:
	stage_width = 2240 if level_number == 1 else 2560
	RenderingServer.set_default_clear_color(Color("142330") if level_number == 1 else Color("091321"))
	terrain = $Terrain
	var player = PLAYER.instantiate()
	player.name = "Player"
	player.position = Vector2(96, 460)
	add_child(player)
	var camera := Camera2D.new()
	camera.position = Vector2(130, -100)
	camera.limit_left = 0
	camera.limit_right = stage_width
	camera.limit_top = 0
	camera.limit_bottom = 560
	player.add_child(camera)
	var enemies: Array[Vector2]
	var pebbles: Array[Vector2]
	var hazards: Array[Vector2]
	if level_number == 1:
		enemies = [Vector2(800, 468), Vector2(1560, 468)]
		pebbles = [Vector2(352, 350), Vector2(1056, 350), Vector2(1904, 350)]
		hazards = [Vector2(928, 480), Vector2(1728, 480)]
	else:
		enemies = [Vector2(728, 404), Vector2(1320, 468), Vector2(2140, 404)]
		pebbles = [Vector2(320, 350), Vector2(1248, 350), Vector2(2240, 286)]
		hazards = [Vector2(864, 416), Vector2(1440, 480), Vector2(1920, 416)]
	for point in enemies:
		var enemy = CRAWLER.instantiate()
		enemy.position = point
		# Keep enemies out of jump landing zones and spike sections.
		enemy.patrol_left = point.x - 48
		enemy.patrol_right = point.x + 48
		add_child(enemy)
	for i in pebbles.size():
		var pebble = PEBBLE.instantiate()
		pebble.position = pebbles[i]
		pebble.collectible_id = "%s:%s" % [level_number, i]
		add_child(pebble)
	for point in hazards:
		var spikes = SPIKES.instantiate()
		spikes.position = point
		add_child(spikes)
	exit_gate = EXIT.instantiate()
	exit_gate.position = Vector2(stage_width - 112, 480 if level_number == 1 else 416)
	exit_gate.reached.connect(_reach_exit)
	add_child(exit_gate)
	_add_sign(Vector2(stage_width - 220, exit_gate.position.y - 115), "SLIGHTLY DEEPER →" if level_number == 1 else "THE DEPTHS? →", 17)
	_add_sign(Vector2(48, 32), "THE SHALLOWS" if level_number == 1 else "SLIGHTLY DEEPER", 30)
	message = _add_sign(Vector2(48, 78), "At last... the entrance to the forgotten kingdom." if level_number == 1 else "Surely it cannot get much deeper than this.", 18)
	_add_sign(Vector2(48, 116), "A/D or arrows: move   W: jump   Left click: attack   R: restart", 16)
	counter = _add_sign(Vector2(48, 150), "", 17)
	GameManager.pebbles_changed.connect(_update_pebbles)
	_update_pebbles(GameManager.collected.size())
	if level_number == 1:
		_add_sign(Vector2(280, 270), "Cyan stones are optional treasures.", 16)
		_add_sign(Vector2(480, 350), "W: cross the gap →", 16)
		_add_sign(Vector2(730, 270), "Left click: swing twice", 16)
		_add_sign(Vector2(870, 325), "Pointed red = danger", 16)
	else:
		_add_sign(Vector2(280, 270), "Jump near the edge. Land on the higher ledge.", 16)
		_add_sign(Vector2(1510, 300), "A longer leap. Take a breath.", 16)
	queue_redraw()

func _add_sign(at: Vector2, text: String, size: int) -> Label:
	var label := Label.new()
	label.position = at
	label.text = text
	label.add_theme_font_size_override("font_size", size)
	label.modulate = Color("c9e1e7")
	add_child(label)
	return label

func _update_pebbles(total: int) -> void:
	counter.text = "Legendary Pebbles: %s / 6" % total

func _reach_exit() -> void:
	if transitioning:
		return
	transitioning = true
	var player = get_node("Player")
	player.set_physics_process(false)
	# Hold a safe, readable completion beat before changing scenes.
	for child in get_children():
		if child is CharacterBody2D:
			child.set_physics_process(false)
	if level_number == 1:
		_add_sign(exit_gate.position + Vector2(-520, -170), "I've conquered the Shallows. Surely the worst is behind me.", 18)
		await get_tree().create_timer(2.2).timeout
		get_tree().change_scene_to_file("res://scenes/level_2.tscn")
	else:
		GameManager.completed = true
		_add_sign(exit_gate.position + Vector2(-580, -190), "At last! I've conquered the depths of the forgotten kingdom!", 18)
		_add_sign(exit_gate.position + Vector2(-580, -150), "Week 3 complete · Pebbles: %s / 6 · R: play again" % GameManager.collected.size(), 18)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("restart"):
		if GameManager.completed:
			GameManager.new_run()
		elif not transitioning:
			get_tree().reload_current_scene()

func _draw() -> void:
	# Simple placeholder cave silhouettes; no generated artwork or animations yet.
	for x in range(0, stage_width, 160):
		draw_rect(Rect2(x + 25, 205, 45, 355), Color("1c3040") if level_number == 1 else Color("122237"))
		if level_number == 1 and terrain.get_cell_source_id(Vector2i(int((x + 75) / 32), 15)) != -1:
			draw_line(Vector2(x + 75, 472), Vector2(x + 75, 456), Color("467582"), 3)
			draw_arc(Vector2(x + 75, 457), 9, PI, TAU, 10, Color("76bac5"), 4)
