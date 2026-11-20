extends StaticBody2D

signal switch_activated
signal switch_deactivated

var can_interact: bool = false
var is_activated: bool = false

func _process(delta):
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
