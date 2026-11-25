extends Node2D

# Globális állapot (SceneManager néven autoloadként fut). Itt tároljuk mindazt, aminek jelenetváltás vagy a jelenet újratöltése után is meg kell maradnia.

# Minden legyőzött ellenség után kiküldjük, az addigi legyőzések számával.
signal enemy_killed(total: int)

# Hova kerüljön a játékos a következő jelenetben (Vector2.ZERO: a jelenetben beállított helyre).
var player_spawn_position: Vector2
var player_hp: int = 4

# A kinyitott ládák neve; a tömb mérete egyben a begyűjtött kincsek száma.
var opened_chests: Array[String] = []

var enemies_killed: int = 0
var completed_quests: Array[String] = []

# A legyőzött ellenségek node-útvonalai, hogy pályaváltás után is halottak maradjanak.
var killed_enemies: Array[String] = []

# Azoknak az ajtóknak a node-útvonalai, amelyeknek pályák között is nyitva kell maradniuk.
var opened_doors: Array[String] = []

# Felvette-e már a játékos a kardot. Pályák között is megmarad.
var has_weapon: bool = false

# A favágó farönk-akadályaihoz tartozó küldetés azonosítója.
const LUMBERJACK_LOGS_QUEST: String = "lumberjack_logs"

# Elmenti a legyőzött ellenséget, és növeli a számlálót.
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

# Mindent visszaállít a kezdőállapotba (új játék indításakor).
func reset_run() -> void:
	opened_chests.clear()
	completed_quests.clear()
	killed_enemies.clear()
	opened_doors.clear()
	enemies_killed = 0
	has_weapon = false
	player_hp = 4
	player_spawn_position = Vector2.ZERO
