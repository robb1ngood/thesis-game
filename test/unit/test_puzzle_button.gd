extends GutTest

var PuzzleButtonScene = load("res://Scenes/PuzzleButton/puzzle_button.tscn")
var button = null

func before_each():
	# Instantiate a fresh copy of the scene to give each test a completely clean state.
	button = PuzzleButtonScene.instantiate()
	
	# Add the button to the active scene tree so it can process signals. 
	# Wrapping it in autofree() tells GUT to free the node from memory after the test finishes, preventing orphan node leaks.
	add_child(autofree(button))

# Test Case 1: Verifies that stepping onto the button triggers the "pressed" signal and increments the body counter.
func test_button_pressed_signal_emitted_on_entry():
	# Tells GUT to start listening for any signals emitted by the button instance.
	watch_signals(button)
	
	# Create a simple Node2D to act as an entering physics body, registering it with autofree() to avoid memory leaks.
	var dummy_body = autofree(Node2D.new())
	
	# Add the dummy node to the "pushable" group so the button script recognizes it as a valid trigger object.
	dummy_body.add_to_group("pushable")
	
	# Manually invoke the collision callback function, passing in our mock object.
	button._on_body_entered(dummy_body)
	
	# Confirm that the custom "pressed" signal was emitted during the function call.
	assert_signal_emitted(button, "pressed")
	
	# Confirm that the button script correctly incremented its internal counter to 1.
	assert_eq(button.bodies_on_top, 1)

# Test Case 2: Verifies that stepping off the button triggers the "unpressed" signal and resets the body counter.
func test_button_unpressed_signal_emitted_on_exit():
	# Start tracking signals on the button instance.
	watch_signals(button)
	
	# Create and configure the mock trigger body.
	var dummy_body = autofree(Node2D.new())
	dummy_body.add_to_group("pushable")
	
	# Simulate the full movement sequence: first stepping onto the button, then stepping off.
	button._on_body_entered(dummy_body)
	button._on_body_exited(dummy_body)
	
	# Confirm that the "unpressed" signal was fired when the object left.
	assert_signal_emitted(button, "unpressed")
	
	# Confirm that the active body counter returned back to 0.
	assert_eq(button.bodies_on_top, 0)

# Test Case 3: Verifies that enabling the single-use flag locks the button in its pressed state when the object leaves.
func test_single_use_button_remains_pressed():
	# Set the exported single-use property to true before executing the test sequence.
	button.is_single_use = true
	
	# Start tracking signals.
	watch_signals(button)
	
	# Create the mock trigger body.
	var dummy_body = autofree(Node2D.new())
	dummy_body.add_to_group("pushable")
	
	# Simulate stepping onto the button and then stepping off.
	button._on_body_entered(dummy_body)
	button._on_body_exited(dummy_body)
	
	# Confirm that the "unpressed" signal was NOT emitted because single-use buttons bypass deactivation.
	assert_signal_not_emitted(button, "unpressed")
	
	# Confirm that the counter stayed at 1 because the exit function returned early without decrementing.
	assert_eq(button.bodies_on_top, 1)
