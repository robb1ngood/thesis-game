extends StaticBody2D

# Felvehető kard egy kövön. Interakcióra a játékos felveszi, és ettől kezdve tud támadni.

signal weapon_picked_up

# Igaz, amíg a kő a játékos interakciós területén van (a Player állítja be).
var can_interact: bool = false
# Igaz, ha a kardot már felvették (a kő üres).
var has_weapon: bool = false

func _ready():
	# Ha a kardot már felvették, ne tegyük vissza a kőre.
	if SceneManager.has_weapon:
		remove_sword()

func _process(delta):
	if Input.is_action_just_pressed("interact") and can_interact:
		#$AudioStreamPlayer2D.play()
		if not has_weapon:
			pick_up_weapon()

# A kard felvétele: elmentjük a SceneManagerbe, és a weapon_picked_up jellel szólunk a játékosnak.
func pick_up_weapon():
	SceneManager.has_weapon = true
	weapon_picked_up.emit()
	remove_sword()

# Leveszi a kardot a kőről; a kővel ezután már nem lehet interakcióba lépni.
func remove_sword():
	has_weapon = true
	can_interact = false
	$Sword.visible = false
	# Enélkül az üres kő mellett állva nem lehetne suhintani, mert a játékos az "interact" gombnyomást a kővel való interakcióként értelmezné.
	remove_from_group("interactable")
	# A játékos a kard felvétele után általában még itt áll, ezért jelezzük neki, hogy már nem lép interakcióba semmivel.
	var player = get_tree().get_first_node_in_group("player")
	if player:
		player.can_interact = false
