extends GutTest

# A kapcsolós puzzle tesztjei: a SwitchPuzzleManager és a zárt ajtó együttműködése.

var ManagerScene = load("res://Scenes/Switch/switch_puzzle_manager.tscn")
var DoorScene = load("res://Scenes/LockedDoor/locked_door.tscn")
var manager = null
var door = null

func before_each():
	manager = ManagerScene.instantiate()
	# Ugyanannyi pont kell a megoldáshoz, mint az első jelenetben.
	manager.target_score = 3
	door = DoorScene.instantiate()
	add_child_autofree(manager)
	add_child_autofree(door)
	# Ugyanazok a jelbekötések, mint a first_scene.tscn-ben.
	manager.puzzle_solved.connect(door._on_puzzle_button_pressed)
	manager.puzzle_failed.connect(door._on_puzzle_button_unpressed)

# Három helyes kapcsoló felkapcsolva: az ajtó kinyílik.
func test_correct_switches_open_door():
	for i in 3:
		manager.increase_score()
	# A nyitott ajtót az jelzi, hogy nem látható.
	assert_false(door.visible)

# A puzzle megoldva, aztán egy rossz kapcsolót is felkapcsolunk: az ajtó bezárul.
func test_wrong_switch_closes_door():
	for i in 3:
		manager.increase_score()
	manager.decrease_score()
	assert_true(door.visible)

# Először egy rossz kapcsolót kapcsolunk fel, aztán a három helyeset, majd a rosszat újra lekapcsoljuk.
# Az ajtónak ki kell nyílnia.
func test_door_opens_after_wrong_switch_first():
	manager.decrease_score()
	# A három helyes kapcsoló felkapcsolása és a rossz lekapcsolása összesen négy pontnövelés.
	for i in 4:
		manager.increase_score()
	assert_false(door.visible)
