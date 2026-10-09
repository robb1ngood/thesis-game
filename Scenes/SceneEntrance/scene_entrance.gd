extends Area2D

@export var next_scene: String
@export var player_spawn_position: Vector2

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_body_entered(body):
	if body is Player:
		SceneManager.player_spawn_position = player_spawn_position
		get_tree().change_scene_to_file.call_deferred(next_scene)

func _on_body_exited(body):
	pass


func _on_puzzle_button_unpressed() -> void:
	pass # Replace with function body.
