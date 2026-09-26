extends Node

signal pebbles_changed(total: int)
var collected: Dictionary = {}
var completed := false

func collect(id: String) -> bool:
	if collected.has(id):
		return false
	collected[id] = true
	pebbles_changed.emit(collected.size())
	return true

func new_run() -> void:
	collected.clear()
	completed = false
	pebbles_changed.emit(0)
	get_tree().change_scene_to_file("res://scenes/level_1.tscn")
