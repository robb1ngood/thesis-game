extends Control

## Scene to load when the player picks "Play Again". Change to your main menu if you add one.
@export_file("*.tscn") var restart_scene_path: String = "res://Scenes/FirstScene/first_scene.tscn"

@onready var title_label: Label = %TitleLabel
@onready var subtitle_label: Label = %SubtitleLabel
@onready var treasure_label: Label = %TreasureLabel
@onready var buttons: HBoxContainer = %Buttons
@onready var play_again_button: Button = %PlayAgainButton
@onready var quit_button: Button = %QuitButton

func _ready() -> void:
	get_tree().paused = false
	treasure_label.text = "Treasure collected: %d" % SceneManager.opened_chests.size()

	# Everything starts invisible, then fades in one after another.
	for node in [title_label, subtitle_label, treasure_label, buttons]:
		node.modulate.a = 0.0
	buttons.mouse_filter = Control.MOUSE_FILTER_IGNORE

	var tween := create_tween()
	tween.tween_property(title_label, "modulate:a", 1.0, 1.5)
	tween.tween_property(subtitle_label, "modulate:a", 1.0, 1.0)
	tween.tween_property(treasure_label, "modulate:a", 1.0, 1.0)
	tween.tween_property(buttons, "modulate:a", 1.0, 0.8)
	tween.tween_callback(func():
		buttons.mouse_filter = Control.MOUSE_FILTER_PASS
		play_again_button.grab_focus())

	play_again_button.pressed.connect(_on_play_again_pressed)
	quit_button.pressed.connect(func(): get_tree().quit())

func _on_play_again_pressed() -> void:
	# Reset the global state so a new run starts clean.
	SceneManager.opened_chests.clear()
	SceneManager.player_hp = 4
	SceneManager.player_spawn_position = Vector2.ZERO
	get_tree().change_scene_to_file(restart_scene_path)
