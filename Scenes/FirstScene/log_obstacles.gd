extends TileMapLayer

# How many enemies the player has to slay before the logs disappear.
var required_kills: int = 12

func _ready():
	# The kill count lives in SceneManager, so it survives scene reloads.
	if SceneManager.is_quest_complete(SceneManager.LUMBERJACK_LOGS_QUEST) \
			or SceneManager.enemies_killed >= required_kills:
		disable_logs()
	else:
		SceneManager.enemy_killed.connect(_on_enemy_killed)

func _on_enemy_killed(total: int):
	if total >= required_kills:
		disable_logs()
		SceneManager.enemy_killed.disconnect(_on_enemy_killed)

func disable_logs():
	SceneManager.complete_quest(SceneManager.LUMBERJACK_LOGS_QUEST)
	visible = false
	collision_enabled = false
