extends StaticBody2D

# Kincsesláda: interakcióra kinyílik, egy pillanatra felbukkan belőle egy érme, és a SceneManager megjegyzi, hogy már ki van nyitva.

# Egyedi név, ez alapján jegyzi meg a SceneManager, hogy a láda ki van-e már nyitva.
@export var chest_name: String
# Igaz, amíg a láda a játékos interakciós területén van (a Player állítja be).
var can_interact: bool = false
var is_open: bool = false

func _ready():
	# A korábban kinyitott láda nyitva marad.
	if SceneManager.opened_chests.has(chest_name):
		is_open = true
		$AnimatedSprite2D.play("open")

func _process(delta):
	if Input.is_action_just_pressed("interact") and can_interact:
		if not is_open:
			open_chest()

func open_chest():
	is_open = true
	$AnimatedSprite2D.play("open")
	# Az érme (AnimatedSprite2D2) a Timer lejártáig látszik.
	$AnimatedSprite2D2.visible = true
	$Timer.start()
	# A kinyitott ládák száma egyben a begyűjtött kincsek száma.
	SceneManager.opened_chests.append(chest_name)
	$AudioStreamPlayer2D.play()

# Az érme eltüntetése.
func _on_timer_timeout() -> void:
	$AnimatedSprite2D2.visible = false
