extends StaticBody2D

@export var buttons_needed: int = 1

# If true, the door stays open for good once it has been opened,
# even after changing levels. SceneManager remembers it.
@export var stays_open: bool = false

var buttons_pressed: int = 0
var is_permanently_open: bool = false

func _ready():
	if stays_open and SceneManager.is_door_opened(get_door_id()):
		open_door()

# Unique per door, e.g. "/root/FirstScene/DungeonLockedDoor".
func get_door_id() -> String:
	return str(get_path())

func _on_puzzle_button_pressed() -> void:
	buttons_pressed += 1
	
	if buttons_pressed >= buttons_needed:
		open_door()


func _on_puzzle_button_unpressed() -> void:
	buttons_pressed -= 1
	
	if is_permanently_open:
		return
	
	if buttons_pressed < buttons_needed:
		visible = true
		$CollisionShape2D.set_deferred("disabled", false)

func open_door() -> void:
	visible = false
	$CollisionShape2D.set_deferred("disabled", true)
	if stays_open:
		is_permanently_open = true
		SceneManager.open_door(get_door_id())
