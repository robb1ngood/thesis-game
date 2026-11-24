extends GutTest

var ManagerScene = load("res://Scenes/Switch/switch_puzzle_manager.tscn")
var DoorScene = load("res://Scenes/LockedDoor/locked_door.tscn")
var manager = null
var door = null

func before_each():
	manager = ManagerScene.instantiate()
	manager.target_score = 3
	door = DoorScene.instantiate()
	add_child_autofree(manager)
	add_child_autofree(door)
	# Same connections as in first_scene.tscn
	manager.puzzle_solved.connect(door._on_puzzle_button_pressed)
	manager.puzzle_failed.connect(door._on_puzzle_button_unpressed)

# Three correct switches turned on: the door opens.
func test_correct_switches_open_door():
	for i in 3:
		manager.increase_score()
	assert_false(door.visible)

# The puzzle is solved, then a wrong switch is turned on: the door closes.
func test_wrong_switch_closes_door():
	for i in 3:
		manager.increase_score()
	manager.decrease_score()
	assert_true(door.visible)

# A wrong switch is turned on first, then the three correct ones,
# then the wrong one is turned off again. The door should open.
func test_door_opens_after_wrong_switch_first():
	manager.decrease_score()
	for i in 4:
		manager.increase_score()
	assert_false(door.visible)
