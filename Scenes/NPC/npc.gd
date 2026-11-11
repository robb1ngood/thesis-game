extends StaticBody2D

var can_interact: bool = false

@export var dialogue_lines: Array[String] = ["Hi!", "How are you?", "Bye!"]

@export_group("Ending")
@export var is_endgame_npc: bool = false
@export var required_treasure: int = 1
@export var not_enough_treasure_lines: Array[String] = [
	"Bring me 10 treasures and I'll sell you this boat to go home.",
	"Keep looking!",
]
@export var enough_treasure_lines: Array[String] = [
	"You found them all!",
	"The boat is all yours!",
]
@export_file("*.tscn") var end_title_scene_path: String = "res://Scenes/EndTitle/end_title.tscn"

var dialogue_index: int = 0
var _active_lines: Array[String] = []
var _ending_started: bool = false

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("interact") and can_interact and not _ending_started:
		_interact()

func _interact() -> void:
	# Pick which set of lines to read at the start of every conversation.
	if dialogue_index == 0:
		_active_lines = dialogue_lines
		if is_endgame_npc:
			_active_lines = enough_treasure_lines if _has_enough_treasure() else not_enough_treasure_lines
	show_dialogue()

func _has_enough_treasure() -> bool:
	return SceneManager.opened_chests.size() >= required_treasure

func show_dialogue() -> void:
	$AudioStreamPlayer2D.play()
	if dialogue_index < _active_lines.size():
		$CanvasLayer.visible = true
		get_tree().paused = true
		$CanvasLayer/DialogueLabel.text = _active_lines[dialogue_index]
		dialogue_index += 1
	else:
		$CanvasLayer.visible = false
		get_tree().paused = false
		dialogue_index = 0
		# Dialogue finished: if this was the ending conversation, roll the ending.
		if is_endgame_npc and _has_enough_treasure():
			trigger_ending()

func trigger_ending() -> void:
	_ending_started = true

	var player = get_tree().get_first_node_in_group("player")
	if player:
		player.velocity = Vector2.ZERO
		player.set_physics_process(false)

		# Face the camera and stop the walk animation.
		var sprite: AnimatedSprite2D = player.get_node("AnimatedSprite2D")
		sprite.animation = "move_down"
		sprite.stop()
		sprite.frame = 0

	# Fade-to-black overlay that sits above everything.
	var canvas := CanvasLayer.new()
	canvas.layer = 100
	var fade_rect := ColorRect.new()
	fade_rect.color = Color(0, 0, 0, 0)
	fade_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	fade_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	canvas.add_child(fade_rect)
	add_child(canvas)

	var tween := create_tween()

	# Optional: sail the boat away with the player if there's one in the scene.
	var boat = get_tree().get_first_node_in_group("boat")
	if player and boat:
		player.z_index = 1  # draw above the boat
		player.global_position = boat.global_position + Vector2(0, -10)
		tween.set_parallel(true)
		tween.tween_property(boat, "global_position:x", boat.global_position.x + 150, 4.0)
		tween.tween_property(player, "global_position:x", player.global_position.x + 150, 4.0)
		tween.tween_property(fade_rect, "color:a", 1.0, 2.0).set_delay(2.0)
		tween.set_parallel(false)
	else:
		tween.tween_property(fade_rect, "color:a", 1.0, 2.0)

	tween.tween_interval(0.5)
	tween.tween_callback(func(): get_tree().change_scene_to_file(end_title_scene_path))
