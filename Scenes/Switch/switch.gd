extends StaticBody2D

# Kapcsoló, amelyet az "interact" gombbal lehet be- és kikapcsolni. Állapotváltáskor a switch_activated vagy a switch_deactivated jelet küldi.

signal switch_activated
signal switch_deactivated

# Igaz, amíg a kapcsoló a játékos interakciós területén van (a Player állítja be).
var can_interact: bool = false
var is_activated: bool = false

func _process(delta):
	# Ha a játékos mellette áll, és megnyomja az "interact" gombot, átváltjuk a kapcsolót.
	if Input.is_action_just_pressed("interact") and can_interact:
		$AudioStreamPlayer2D.play()
		if is_activated:
			deactivate_switch()
		else:
			activate_switch()
			
func activate_switch():
	$AnimatedSprite2D.play("activated")
	is_activated = true
	switch_activated.emit()

func deactivate_switch():
	$AnimatedSprite2D.play("deactivated")
	is_activated = false
	switch_deactivated.emit()
