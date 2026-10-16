extends StaticBody2D

signal weapon_picked_up

var can_interact: bool = false
var has_weapon: bool = false

func _process(delta):
	if Input.is_action_just_pressed("interact") and can_interact:
		#$AudioStreamPlayer2D.play()
		$Sword.visible = false
		if not has_weapon:
			pick_up_weapon()
			
func pick_up_weapon():
	weapon_picked_up.emit()
	has_weapon = true
