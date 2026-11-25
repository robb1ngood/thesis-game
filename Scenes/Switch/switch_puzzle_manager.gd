extends Marker2D

# Kapcsolós rejtvény vezérlője. A kapcsolók jelei növelik vagy csökkentik a pontszámot.
# Az első jelenetben néhány kapcsoló fordítva van bekötve (felkapcsolva csökkenti a pontszámot), így csak a helyes kombináció oldja meg a puzzle.

signal puzzle_solved
signal puzzle_failed

# Ennyi pont kell a megoldáshoz.
@export var target_score: int
var score: int
var is_solved: bool = false

func increase_score():
	score += 1
	# A megoldást csak egyszer jelezzük (amíg el nem rontják).
	if score >= target_score and not is_solved:
		is_solved = true
		puzzle_solved.emit()

func decrease_score():
	score -= 1
	# Ha a pontszám a cél alá esik, a rejtvény újra megoldatlan.
	if score < target_score and is_solved:
		is_solved = false
		puzzle_failed.emit()
