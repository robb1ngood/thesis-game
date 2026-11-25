extends Area2D

# Pályabejárat: ha a játékos belép a területére, betöltődik a következő jelenet, és a játékos a megadott kezdőpozícióban jelenik meg.

# A betöltendő jelenet elérési útja.
@export var next_scene: String
# Ide kerül a játékos az új jelenetben.
@export var player_spawn_position: Vector2

func _on_body_entered(body):
	if body is Player:
		SceneManager.player_spawn_position = player_spawn_position
		# Ütközési jel feldolgozása közben nem biztonságos jelenetet váltani, ezért késleltetve hívjuk.
		get_tree().change_scene_to_file.call_deferred(next_scene)
