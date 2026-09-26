extends Area2D

@export var collectible_id := ""

func _ready() -> void:
	if GameManager.collected.has(collectible_id):
		queue_free()
	body_entered.connect(_collect)

func _collect(body: Node2D) -> void:
	if body is CharacterBody2D and body.collision_layer & 2:
		if GameManager.collect(collectible_id):
			queue_free()

func _draw() -> void:
	draw_circle(Vector2.ZERO, 15, Color(0.3, 0.9, 1.0, 0.1))
	draw_circle(Vector2.ZERO, 10, Color(0.3, 0.9, 1.0, 0.18))
	draw_colored_polygon(PackedVector2Array([Vector2(-7, 3), Vector2(-4, -5), Vector2(3, -7), Vector2(7, 1), Vector2(3, 6)]), Color("8ae1e9"))
	draw_line(Vector2(-3, -3), Vector2(2, -5), Color("e0ffff"), 2)
