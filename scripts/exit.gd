extends Area2D

signal reached
var triggered := false

func _ready() -> void:
	body_entered.connect(_enter)

func _enter(body: Node2D) -> void:
	if not triggered and body is CharacterBody2D and body.collision_layer & 2:
		triggered = true
		reached.emit()

func _draw() -> void:
	draw_rect(Rect2(-30, -76, 60, 78), Color(0.5, 0.8, 1, 0.09))
	draw_rect(Rect2(-22, -70, 44, 70), Color("8ec4d5"))
	draw_rect(Rect2(-15, -63, 30, 63), Color("223f57"))
	draw_rect(Rect2(-10, -58, 20, 58), Color("bbeced"))
