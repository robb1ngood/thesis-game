extends Area2D

# Padlón lévő nyomógomb, amelyet egy tolható blokk vagy a játékos nyomhat le.
# Lenyomáskor a pressed, felengedéskor az unpressed jelet küldi.

# Igaz esetén a gomb lenyomva marad (egyszer használatos gomb).
@export var is_single_use: bool = false

# Hány test van éppen a gombon.
var bodies_on_top: int = 0
signal pressed
signal unpressed

func _on_body_entered(body: Node2D) -> void:
	bodies_on_top += 1
	if body.is_in_group("pushable") or body is Player:
		# Csak akkor jelzünk, ha ez az első test a gombon.
		if bodies_on_top == 1:
			$AudioStreamPlayer2D.pitch_scale = 1.0
			$AudioStreamPlayer2D.play()
			pressed.emit()
			$AnimatedSprite2D.play("pressed")

func _on_body_exited(body: Node2D) -> void:
	# Az egyszer használatos gomb sosem enged fel.
	if is_single_use:
		return
	
	bodies_on_top -= 1
	if body.is_in_group("pushable") or body is Player:
		# Csak akkor enged fel, ha már semmi sincs rajta; a mélyebb hang jelzi a felengedést.
		if bodies_on_top == 0:
			$AudioStreamPlayer2D.pitch_scale = 0.8
			$AudioStreamPlayer2D.play()
			unpressed.emit()
			$AnimatedSprite2D.play("unpressed")
