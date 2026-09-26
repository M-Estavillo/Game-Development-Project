extends Area2D

func _physics_process(_delta: float) -> void:
	for body in get_overlapping_bodies():
		if body.has_method("take_damage"):
			body.take_damage(1, global_position.x)

func _draw() -> void:
	for x in [-24, -8, 8, 24]:
		var triangle := PackedVector2Array([Vector2(x - 8, 0), Vector2(x, -22), Vector2(x + 8, 0)])
		draw_colored_polygon(triangle, Color("b96970"))
		draw_polyline(PackedVector2Array([triangle[0], triangle[1], triangle[2]]), Color("efb7b6"), 2)
