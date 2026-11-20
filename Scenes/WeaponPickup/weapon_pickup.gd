extends StaticBody2D

signal weapon_picked_up

var can_interact: bool = false
var has_weapon: bool = false

func _ready():
	# If the sword was already taken, don't put it back on the stone.
	if SceneManager.has_weapon:
		remove_sword()

func _process(delta):
	if Input.is_action_just_pressed("interact") and can_interact:
		#$AudioStreamPlayer2D.play()
		if not has_weapon:
			pick_up_weapon()

func pick_up_weapon():
	SceneManager.has_weapon = true
	weapon_picked_up.emit()
	remove_sword()

func remove_sword():
	has_weapon = true
	can_interact = false
	$Sword.visible = false
	# Without this, standing next to the empty stone blocks sword swings,
	# because the player treats "interact" as talking to the stone.
	remove_from_group("interactable")
	# The player is usually still standing here after picking up the sword,
	# so tell them they're no longer interacting with anything.
	var player = get_tree().get_first_node_in_group("player")
	if player:
		player.can_interact = false
