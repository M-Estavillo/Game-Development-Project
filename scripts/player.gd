extends CharacterBody2D

signal health_changed(value: int)
signal landed

const SPEED := 200.0
const GRAVITY := 1100.0
const JUMP_SPEED := -480.0
const MAX_HEALTH := 3
const ATTACK_COOLDOWN := 0.35
const ATTACK_DURATION := 0.16
const INVINCIBILITY := 1.0

var health := MAX_HEALTH
var facing := 1.0
var attack_time := 0.0
var cooldown := 0.0
var invincibility := 0.0
var hit_targets: Array[Node] = []
var dead := false
var knockback_time := 0.0

@onready var attack_area: Area2D = $AttackArea
@onready var dust: CPUParticles2D = $LandingDust

func _physics_process(delta: float) -> void:
	if dead:
		return
	cooldown = maxf(0.0, cooldown - delta)
	attack_time = maxf(0.0, attack_time - delta)
	invincibility = maxf(0.0, invincibility - delta)
	knockback_time = maxf(0.0, knockback_time - delta)
	var direction := Input.get_axis("move_left", "move_right")
	if knockback_time <= 0.0:
		velocity.x = direction * SPEED
	if direction != 0.0 and attack_time <= 0.0:
		facing = signf(direction)
	attack_area.position.x = facing * 25.0
	if not is_on_floor():
		velocity.y += GRAVITY * delta
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_SPEED
	if Input.is_action_just_pressed("attack"):
		begin_attack()
	if attack_time > 0.0:
		for target in attack_area.get_overlapping_bodies():
			if target.has_method("take_damage") and not target in hit_targets:
				hit_targets.append(target)
				target.take_damage(1)
	var was_grounded := is_on_floor()
	move_and_slide()
	if is_on_floor() and not was_grounded:
		dust.restart()
		dust.emitting = true
		landed.emit()
	if position.y > 650.0:
		die()
	queue_redraw()

func begin_attack() -> void:
	if cooldown > 0.0 or dead:
		return
	cooldown = ATTACK_COOLDOWN
	attack_time = ATTACK_DURATION
	hit_targets.clear()

func take_damage(amount: int, source_x: float = 0.0) -> void:
	if invincibility > 0.0 or dead:
		return
	health = maxi(0, health - amount)
	health_changed.emit(health)
	invincibility = INVINCIBILITY
	knockback_time = 0.16
	velocity = Vector2(180.0 if global_position.x >= source_x else -180.0, -180.0)
	if health == 0:
		die()

func die() -> void:
	if dead:
		return
	dead = true
	get_tree().call_deferred("reload_current_scene")

func _draw() -> void:
	var ink := Color("192434")
	var pale := Color("e0e8df")
	if invincibility > 0.0 and int(invincibility * 16.0) % 2 == 0:
		pale = Color("e89a9a")
	# Original geometric placeholder: cape, body, oversized rounded helmet.
	draw_colored_polygon(PackedVector2Array([Vector2(-10, -15), Vector2(-facing * 21, 13), Vector2(10, 10)]), Color("586982"))
	draw_rect(Rect2(-9, -12, 18, 25), ink)
	draw_line(Vector2(-6, 10), Vector2(-7, 18), pale, 4.0)
	draw_line(Vector2(6, 10), Vector2(7, 18), pale, 4.0)
	draw_style_box(_helmet_style(pale), Rect2(-15, -33, 30, 26))
	draw_line(Vector2(-10, -21), Vector2(10, -21), ink, 4.0)
	draw_line(Vector2(facing * 4, -24), Vector2(facing * 4, -14), ink, 3.0)
	var tip := Vector2(facing * 39, -11) if attack_time > 0.0 else Vector2(facing * 18, 13)
	draw_line(Vector2(facing * 10, -3), tip, Color("ba9467"), 5.0)
	if attack_time > 0.0:
		draw_arc(Vector2(facing * 12, -6), 30, -0.8 if facing > 0 else 2.34, 0.8 if facing > 0 else 3.94, 12, Color("d6e5ce"), 2.0)
	# Temporary world-space health markers; the gameplay HUD belongs to a later milestone.
	for i in MAX_HEALTH:
		var center := Vector2(-11 + i * 11, -46)
		var heart := PackedVector2Array([center + Vector2(-4, -1), center + Vector2(-2, -3), center, center + Vector2(2, -3), center + Vector2(4, -1), center + Vector2(4, 1), center + Vector2(0, 5), center + Vector2(-4, 1)])
		draw_colored_polygon(heart, Color("dca4a4") if i < health else Color("394354"))

func _helmet_style(color: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = color
	style.corner_radius_top_left = 10
	style.corner_radius_top_right = 10
	style.corner_radius_bottom_left = 4
	style.corner_radius_bottom_right = 4
	return style
