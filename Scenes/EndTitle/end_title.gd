extends Control

# Záróképernyő: a feliratok egymás után előtűnnek, majd a játékos újrakezdheti a játékot, vagy kiléphet.

# Ez a jelenet töltődik be, ha a játékos a "Play Again" gombot választja. Ha később főmenü is készül, érdemes azt megadni itt.
@export_file("*.tscn") var restart_scene_path: String = "res://Scenes/FirstScene/first_scene.tscn"

@onready var title_label: Label = %TitleLabel
@onready var subtitle_label: Label = %SubtitleLabel
@onready var treasure_label: Label = %TreasureLabel
@onready var buttons: HBoxContainer = %Buttons
@onready var play_again_button: Button = %PlayAgainButton
@onready var quit_button: Button = %QuitButton

func _ready() -> void:
	# Biztosan feloldjuk a szüneteltetést, különben a tween és a gombok nem működnének.
	get_tree().paused = false
	treasure_label.text = "Treasure collected: %d" % SceneManager.opened_chests.size()

	# Kezdetben minden elem láthatatlan, aztán egyenként tűnik elő.
	for node in [title_label, subtitle_label, treasure_label, buttons]:
		node.modulate.a = 0.0
	# Amíg a gombok nem látszanak, ne lehessen rájuk kattintani.
	buttons.mouse_filter = Control.MOUSE_FILTER_IGNORE

	# A tween lépései egymás után futnak le: cím, alcím, kincsszámláló, végül a gombok.
	var tween := create_tween()
	tween.tween_property(title_label, "modulate:a", 1.0, 1.5)
	tween.tween_property(subtitle_label, "modulate:a", 1.0, 1.0)
	tween.tween_property(treasure_label, "modulate:a", 1.0, 1.0)
	tween.tween_property(buttons, "modulate:a", 1.0, 0.8)
	# A végén a gombok kattinthatóvá válnak, és a "Play Again" gomb kapja a fókuszt.
	tween.tween_callback(func():
		buttons.mouse_filter = Control.MOUSE_FILTER_PASS
		play_again_button.grab_focus())

	play_again_button.pressed.connect(_on_play_again_pressed)
	quit_button.pressed.connect(func(): get_tree().quit())

func _on_play_again_pressed() -> void:
	# Visszaállítjuk a globális állapotot, hogy az új játék tiszta lappal induljon.
	SceneManager.opened_chests.clear()
	SceneManager.player_hp = 4
	SceneManager.player_spawn_position = Vector2.ZERO
	# Az új jelenet csak a képkocka végén jön létre, így a reset_run() még előtte lefut.
	get_tree().change_scene_to_file(restart_scene_path)
	SceneManager.reset_run()
