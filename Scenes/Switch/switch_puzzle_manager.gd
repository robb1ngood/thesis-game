extends Marker2D

signal puzzle_solved
signal puzzle_failed

@export var target_score: int
var score: int
var is_solved: bool = false

func increase_score():
	score += 1
	if score >= target_score and not is_solved:
		is_solved = true
		puzzle_solved.emit()

func decrease_score():
	score -= 1
	if score < target_score and is_solved:
		is_solved = false
		puzzle_failed.emit()
