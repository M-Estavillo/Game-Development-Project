extends SceneTree

var failures := 0
var capture := false
var player: CharacterBody2D

func _initialize() -> void:
	capture = "--capture" in OS.get_cmdline_user_args()
	call_deferred("run")

func frames(count: int) -> void:
	for i in count:
		await physics_frame
		await process_frame

func check(ok: bool, description: String) -> void:
	print(("PASS: " if ok else "FAIL: ") + description)
	if not ok:
		failures += 1

func snapshot(label: String) -> void:
	if capture:
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png("/tmp/shallow_week4_" + label + ".png")

func run() -> void:
	change_scene_to_file("res://scenes/level_1.tscn")
	await frames(20)
	player = current_scene.get_node("Player")
	var animator: AnimationPlayer = player.get_node("AnimationPlayer")
	check(animator.has_animation("idle") and animator.has_animation("walk") and animator.has_animation("attack"), "AnimationPlayer contains idle, walk, and attack clips")
	check(animator.current_animation == "idle", "resting player selects idle")
	var initial_y: float = player.visuals.position.y
	await frames(25)
	check(absf(player.visuals.position.y - initial_y) > 0.1, "idle track changes visual position over time")
	var shape_position: Vector2 = player.get_node("CollisionShape2D").position
	await snapshot("idle")
	Input.action_press("move_right")
	await frames(6)
	check(animator.current_animation == "walk", "movement selects walk")
	var first_leg: float = player.get_node("Visuals/LegL").rotation
	await frames(8)
	check(absf(player.get_node("Visuals/LegL").rotation - first_leg) > 0.1, "walk keyframes move the legs")
	await snapshot("walk")
	Input.action_release("move_right")
	Input.action_press("move_left")
	await frames(4)
	check(player.visuals.scale.x == -1, "visual rig mirrors with movement direction")
	Input.action_release("move_left")
	await frames(3)
	Input.action_press("attack")
	await frames(2)
	Input.action_release("attack")
	check(animator.current_animation == "attack", "attack input selects the swing animation")
	var arm_angle: float = player.get_node("Visuals/Arm").rotation
	await frames(4)
	check(absf(player.get_node("Visuals/Arm").rotation - arm_angle) > 0.2, "attack track rotates the wooden stick")
	check(player.visuals.scale.x == -1, "left-facing attack stays mirrored")
	await snapshot("attack")
	await frames(20)
	check(animator.current_animation == "idle", "finished swing returns to idle")
	check(player.get_node("CollisionShape2D").position == shape_position, "animation never moves the collision shape")
	Input.action_press("jump")
	await frames(2)
	Input.action_release("jump")
	check(animator.current_animation == "air", "jump selects the airborne pose")
	await snapshot("air")
	await player.landed
	await frames(6)
	check(player.dust.emitting and not player.dust.local_coords and player.dust.color_ramp != null, "landing emits fading particles in world space")
	await snapshot("landing")
	check(current_scene.get_node("CaveBackground/Artwork").texture.resource_path.ends_with("shallows.png"), "Level 1 uses the edited Shallows asset")
	player.position = Vector2(2120, 300)
	player.set_physics_process(false)
	await frames(5)
	await snapshot("level1_end")
	change_scene_to_file("res://scenes/level_2.tscn")
	await frames(20)
	check(current_scene.get_node("CaveBackground/Artwork").texture.resource_path.ends_with("slightly-deeper.png"), "Level 2 uses the darker edited variant")
	await snapshot("level2")
	player = current_scene.get_node("Player")
	player.position = Vector2(2450, 250)
	player.set_physics_process(false)
	await frames(5)
	await snapshot("level2_end")
	print("Week 4 test failures: ", failures)
	quit(1 if failures else 0)
