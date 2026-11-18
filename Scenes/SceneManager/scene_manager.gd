extends Node2D

signal enemy_killed(total: int)

var player_spawn_position: Vector2
var player_hp: int = 4

var opened_chests: Array[String] = []

var enemies_killed: int = 0
var completed_quests: Array[String] = []

func register_kill() -> void:
	enemies_killed += 1
	enemy_killed.emit(enemies_killed)

func complete_quest(quest_id: String) -> void:
	if not completed_quests.has(quest_id):
		completed_quests.append(quest_id)

func is_quest_complete(quest_id: String) -> bool:
	return completed_quests.has(quest_id)

func reset_run() -> void:
	opened_chests.clear()
	completed_quests.clear()
	enemies_killed = 0
	player_hp = 4
	player_spawn_position = Vector2.ZERO
