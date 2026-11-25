extends StaticBody2D

# NPC, akivel az "interact" gombbal lehet beszélgetni. 
# A párbeszéd alatt a játék szünetel (az NPC process_mode-ja Always, ezért ő közben is fut). 
# Ha is_endgame_npc igaz, ő a csónakárus, aki elég kincs esetén a beszélgetés végén elindítja a befejezést.

# Igaz, amíg az NPC a játékos interakciós területén van (a Player állítja be).
var can_interact: bool = false

@export var dialogue_lines: Array[String] = ["Hi!", "How are you?", "Bye!"]

# Igaz esetén ez a záró NPC: a szövege a begyűjtött kincsek számától függ.
@export var is_endgame_npc: bool = false

# Ennyi kincs kell ahhoz, hogy a játékos megvehesse a csónakot.
@export var required_treasure: int = 8

# A záró NPC szövegei; ő ezeket mondja a dialogue_lines helyett.
var not_enough_treasure_lines: Array[String] = [
	"Bring me at least 8 treasures and I'll sell you this boat to go home.",
	"Keep looking!",
]
var enough_treasure_lines: Array[String] = [
	"You have enough coins!",
	"The boat is all yours!",
]

var dialogue_index: int = 0
var _active_lines: Array[String] = []
var _ending_started: bool = false

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("interact") and can_interact and not _ending_started:
		_interact()

func _interact() -> void:
	# Minden beszélgetés elején kiválasztjuk, melyik szövegeket mondja az NPC.
	if dialogue_index == 0:
		_active_lines = dialogue_lines
		if is_endgame_npc:
			_active_lines = enough_treasure_lines if _has_enough_treasure() else not_enough_treasure_lines
	show_dialogue()

func _has_enough_treasure() -> bool:
	return SceneManager.opened_chests.size() >= required_treasure

# Minden gombnyomásra a következő sor jelenik meg; az utolsó után bezárul a párbeszédablak.
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
		# Vége a párbeszédnek: ha ez volt a záró beszélgetés, indul a befejezés.
		if is_endgame_npc and _has_enough_treasure():
			trigger_ending()

# Befejezés: a játékos megáll, a csónakkal együtt elhajózik, a kép elsötétül, végül betöltődik a záróképernyő.
func trigger_ending() -> void:
	_ending_started = true

	# A játékost megállítjuk, és kikapcsoljuk az irányítását.
	var player = get_tree().get_first_node_in_group("player")
	if player:
		player.velocity = Vector2.ZERO
		player.set_physics_process(false)

		# A kamera felé fordul, és leáll a sétaanimáció.
		var sprite: AnimatedSprite2D = player.get_node("AnimatedSprite2D")
		sprite.animation = "move_down"
		sprite.stop()
		sprite.frame = 0

	# Elsötétítő réteg, amely minden más fölött jelenik meg.
	var canvas := CanvasLayer.new()
	canvas.layer = 100
	var fade_rect := ColorRect.new()
	fade_rect.color = Color(0, 0, 0, 0)
	fade_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	fade_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	canvas.add_child(fade_rect)
	add_child(canvas)

	var tween := create_tween()

	# Opcionális: ha van csónak a jelenetben, a játékossal együtt elhajózik.
	var boat = get_tree().get_first_node_in_group("boat")
	if player and boat:
		player.z_index = 1  # a csónak fölé rajzoljuk
		player.global_position = boat.global_position + Vector2(0, -10)
		# A hajózás és az elsötétülés egyszerre fut; az elsötétülés 2 mp késéssel indul.
		tween.set_parallel(true)
		tween.tween_property(boat, "global_position:x", boat.global_position.x + 150, 4.0)
		tween.tween_property(player, "global_position:x", player.global_position.x + 150, 4.0)
		tween.tween_property(fade_rect, "color:a", 1.0, 2.0).set_delay(2.0)
		tween.set_parallel(false)
	else:
		tween.tween_property(fade_rect, "color:a", 1.0, 2.0)

	# Rövid szünet után betöltjük a záróképernyőt.
	tween.tween_interval(0.5)
	tween.tween_callback(func(): get_tree().change_scene_to_file("res://Scenes/EndTitle/end_title.tscn"))
