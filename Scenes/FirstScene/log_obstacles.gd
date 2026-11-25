extends TileMapLayer

# A favágóhoz tartozó farönk-akadályok, amelyek elég legyőzött ellenség után eltűnnek.

# Ennyi ellenséget kell legyőznie a játékosnak, hogy a farönkök eltűnjenek.
@export var required_kills: int = 12

func _ready():
	# A legyőzések számát a SceneManager tárolja, így az a jelenet újratöltése után is megmarad.
	if SceneManager.is_quest_complete(SceneManager.LUMBERJACK_LOGS_QUEST) \
			or SceneManager.enemies_killed >= required_kills:
		disable_logs()
	else:
		# Még nincs elég legyőzés, ezért figyeljük a SceneManager enemy_killed jelét.
		SceneManager.enemy_killed.connect(_on_enemy_killed)

func _on_enemy_killed(total: int):
	if total >= required_kills:
		disable_logs()
		SceneManager.enemy_killed.disconnect(_on_enemy_killed)

# Elrejti a rönköket, kikapcsolja az ütközésüket, és teljesítettnek jelöli a küldetést.
func disable_logs():
	SceneManager.complete_quest(SceneManager.LUMBERJACK_LOGS_QUEST)
	visible = false
	collision_enabled = false
