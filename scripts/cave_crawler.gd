extends CharacterBody2D

const SPEED := 40.0
@export var patrol_left := -INF
@export var patrol_right := INF
var health := 2
var direction := -1.0
var flash_time := 0.0

@onready var edge_ray: RayCast2D = $EdgeRay
@onready var wall_ray: RayCast2D = $WallRay
@onready var contact: Area2D = $ContactArea

func _physics_process(delta: float) -> void:
	flash_time = maxf(0.0, flash_time - delta)
	edge_ray.position.x = direction * 20.0
	wall_ray.target_position.x = direction * 22.0
	edge_ray.force_raycast_update()
	wall_ray.force_raycast_update()
	if is_on_floor() and (not edge_ray.is_colliding() or wall_ray.is_colliding()):
		direction *= -1.0
	if global_position.x <= patrol_left:
		direction = 1.0
	elif global_position.x >= patrol_right:
		direction = -1.0
	velocity.x = direction * SPEED
	velocity.y += 1100.0 * delta
	move_and_slide()
	for body in contact.get_overlapping_bodies():
		if body.has_method("take_damage"):
			body.take_damage(1, global_position.x)
	queue_redraw()

func take_damage(amount: int) -> void:
	if health <= 0:
		return
	health -= amount
	flash_time = 0.12
	if health <= 0:
		queue_free()

func _draw() -> void:
	var shell := Color("b1a0cc") if flash_time > 0.0 else Color("77618f")
	for x in [-11, 0, 11]:
		draw_line(Vector2(x, 2), Vector2(x - 4, 12), Color("a18cae"), 3.0)
	draw_style_box(_shell_style(shell), Rect2(-17, -12, 34, 22))
	draw_circle(Vector2(direction * 10, -4), 3, Color("e3c6a5"))

func _shell_style(color: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = color
	style.corner_radius_top_left = 12
	style.corner_radius_top_right = 12
	style.corner_radius_bottom_left = 5
	style.corner_radius_bottom_right = 5
	return style
