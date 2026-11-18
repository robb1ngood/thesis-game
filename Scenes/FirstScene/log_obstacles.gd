extends TileMapLayer

# How many enemies the player has to slay before the logs disappear.
var required_kills: int = 1

func _ready():
	# The kill count lives in SceneManager, so it survives scene reloads.
	if SceneManager.enemies_killed >= required_kills:
		disable_logs()
	else:
		SceneManager.enemy_killed.connect(_on_enemy_killed)

func _on_enemy_killed(total: int):
	if total >= required_kills:
		disable_logs()
		SceneManager.enemy_killed.disconnect(_on_enemy_killed)

func disable_logs():
	visible = false
	collision_enabled = false
