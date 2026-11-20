extends Node2D

signal enemy_killed(total: int)

var player_spawn_position: Vector2
var player_hp: int = 4

var opened_chests: Array[String] = []

var enemies_killed: int = 0
var completed_quests: Array[String] = []

# Node paths of enemies that have died, so they stay dead after a level change.
var killed_enemies: Array[String] = []

# Node paths of doors that should stay open between levels.
var opened_doors: Array[String] = []

# Whether the player has picked up the sword. Carries over between levels.
var has_weapon: bool = false

# Quest id used for the lumberjack's log obstacles.
const LUMBERJACK_LOGS_QUEST: String = "lumberjack_logs"

func register_kill(enemy_id: String = "") -> void:
	if enemy_id != "" and not killed_enemies.has(enemy_id):
		killed_enemies.append(enemy_id)
	enemies_killed += 1
	enemy_killed.emit(enemies_killed)

func is_enemy_killed(enemy_id: String) -> bool:
	return killed_enemies.has(enemy_id)

func open_door(door_id: String) -> void:
	if not opened_doors.has(door_id):
		opened_doors.append(door_id)

func is_door_opened(door_id: String) -> bool:
	return opened_doors.has(door_id)

func complete_quest(quest_id: String) -> void:
	if not completed_quests.has(quest_id):
		completed_quests.append(quest_id)

func is_quest_complete(quest_id: String) -> bool:
	return completed_quests.has(quest_id)

func reset_run() -> void:
	opened_chests.clear()
	completed_quests.clear()
	killed_enemies.clear()
	opened_doors.clear()
	enemies_killed = 0
	has_weapon = false
	player_hp = 4
	player_spawn_position = Vector2.ZERO
