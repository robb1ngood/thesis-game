extends Marker2D

signal puzzle_solved
signal puzzle_failed

@export var target_score: int
var score: int = 0
var is_solved: bool = false

func increase_score():
	score += 1
	_update_state()

func decrease_score():
	score -= 1
	_update_state()

# Only emit when the puzzle actually changes between solved and unsolved.
# The door counts these signals like button presses, so emitting
# puzzle_failed on every wrong move would push its counter below zero.
func _update_state():
	var solved_now := score >= target_score
	if solved_now == is_solved:
		return
	is_solved = solved_now
	if is_solved:
		puzzle_solved.emit()
	else:
		puzzle_failed.emit()
