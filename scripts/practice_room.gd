extends Node2D

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("restart"):
		get_tree().reload_current_scene()

func _draw() -> void:
	# Plain prototype scenery; physical platforms are separate StaticBody2D nodes.
	for x in range(0, 960, 120):
		draw_rect(Rect2(x + 20, 195, 48, 345), Color("101d2c"))
	for child in get_children():
		if child is StaticBody2D:
			var collider: CollisionShape2D = child.get_node("CollisionShape2D")
			var size: Vector2 = collider.shape.size
			var rect := Rect2(child.position - size / 2.0, size)
			draw_rect(rect, Color("354858"))
			draw_line(rect.position, rect.position + Vector2(size.x, 0), Color("8aa5ae"), 3.0)
