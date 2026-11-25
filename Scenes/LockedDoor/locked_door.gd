extends StaticBody2D

# Zárt ajtó, amely kinyílik, ha elég gomb van lenyomva. Az első jelenetben a kapcsolós puzzle (SwitchPuzzleManager) jelei is ugyanezeket a függvényeket hívják.

# Ennyi lenyomott gomb kell az ajtó kinyitásához.
@export var buttons_needed: int = 1

# Ha igaz, az ajtó az első kinyitás után végleg nyitva marad, pályaváltás után is. Ezt a SceneManager jegyzi meg.
@export var stays_open: bool = false

var buttons_pressed: int = 0
var is_permanently_open: bool = false

func _ready():
	# A korábban már kinyitott, végleg nyitva maradó ajtó rögtön nyitva jelenik meg.
	if stays_open and SceneManager.is_door_opened(get_door_id()):
		open_door()

# Ajtónként egyedi azonosító, pl. "/root/FirstScene/DungeonLockedDoor".
func get_door_id() -> String:
	return str(get_path())

# Egy gomb lenyomásakor hívódik meg.
func _on_puzzle_button_pressed() -> void:
	buttons_pressed += 1
	
	if buttons_pressed >= buttons_needed:
		open_door()


# Egy gomb felengedésekor hívódik meg: ha már nincs elég lenyomott gomb, az ajtó újra bezárul (kivéve, ha végleg nyitva marad).
func _on_puzzle_button_unpressed() -> void:
	buttons_pressed -= 1
	
	if is_permanently_open:
		return
	
	if buttons_pressed < buttons_needed:
		visible = true
		$CollisionShape2D.set_deferred("disabled", false)

# Kinyitja az ajtót (elrejti, és kikapcsolja az ütközését). A végleg nyitva maradó ajtót a SceneManagerben is elmentjük.
func open_door() -> void:
	visible = false
	$CollisionShape2D.set_deferred("disabled", true)
	if stays_open:
		is_permanently_open = true
		SceneManager.open_door(get_door_id())
