extends GutTest

var PuzzleButtonScene = load("res://Scenes/PuzzleButton/puzzle_button.tscn")
var button = null

func before_each():
	button = PuzzleButtonScene.instantiate()
	add_child(autofree(button))

func test_button_pressed_signal_emitted_on_entry():
	watch_signals(button)
	var dummy_body = autofree(Node2D.new())
	dummy_body.add_to_group("pushable")
	
	button._on_body_entered(dummy_body)
	
	assert_signal_emitted(button, "pressed")
	assert_eq(button.bodies_on_top, 1)

func test_button_unpressed_signal_emitted_on_exit():
	watch_signals(button)
	var dummy_body = autofree(Node2D.new())
	dummy_body.add_to_group("pushable")
	
	button._on_body_entered(dummy_body)
	button._on_body_exited(dummy_body)
	
	assert_signal_emitted(button, "unpressed")
	assert_eq(button.bodies_on_top, 0)

func test_single_use_button_remains_pressed():
	button.is_single_use = true
	watch_signals(button)
	var dummy_body = autofree(Node2D.new())
	dummy_body.add_to_group("pushable")
	
	button._on_body_entered(dummy_body)
	button._on_body_exited(dummy_body)
	
	assert_signal_not_emitted(button, "unpressed")
	assert_eq(button.bodies_on_top, 1)
