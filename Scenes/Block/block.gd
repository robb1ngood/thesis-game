extends RigidBody2D

# Tolható blokk. A sima blokk és a jégblokk (ice_block.tscn) is ezt a szkriptet használja.

# A vízbe tolt blokk elsüllyed, csobban egyet, majd visszakerül a kezdőpozíciójára.
@export var water_layer_name: String = "WaterLayer"
@export var sink_delay: float = 1.0
# Csúszás közben a blokkot finoman a csempesor/-oszlop közepére húzzuk, így a csúszós (jég)blokkok pontosan beférnek az egy csempényi résekbe, és nem akadnak meg a sarkokon.
@export var center_on_tiles: bool = false
@export var tile_size: float = 16.0
@export var centering_strength: float = 10.0

var spawn_position: Vector2
var is_sinking: bool = false
var respawn_pending: bool = false
var slide_axis: Vector2 = Vector2.ZERO # a tengely, amely mentén a blokkot utoljára tolták
var push_axis: Vector2 = Vector2.ZERO # a tengely, amely mentén a játékos éppen most tolja
var water_layer: TileMapLayer

func _ready():
	spawn_position = global_position
	freeze_mode = RigidBody2D.FREEZE_MODE_KINEMATIC
	# A vízréteget név alapján keressük meg az aktuális jelenetben.
	water_layer = get_tree().current_scene.find_child(water_layer_name, true, false)

func _physics_process(_delta):
	if not is_sinking and is_in_water():
		sink()
	if center_on_tiles:
		push_axis = get_push_axis()

# Megadja, melyik tengely mentén tolja a játékos ezt a blokkot (ZERO, ha nem tolja).
func get_push_axis() -> Vector2:
	var player = get_tree().get_first_node_in_group("player")
	if player == null:
		return Vector2.ZERO
	# Csak akkor számít tolásnak, ha a játékos legutóbbi ütközése éppen ezzel a blokkal történt.
	var collision: KinematicCollision2D = player.get_last_slide_collision()
	if collision == null or collision.get_collider() != self:
		return Vector2.ZERO
	# Az ütközés normálvektorából derül ki, hogy vízszintesen (RIGHT) vagy függőlegesen (DOWN) tol.
	var normal: Vector2 = collision.get_normal()
	return Vector2.RIGHT if absf(normal.x) > absf(normal.y) else Vector2.DOWN

# Igaz, ha a blokk pozíciójához tartozó cellában van csempe a vízrétegen (-1 = üres cella).
func is_in_water() -> bool:
	if water_layer == null:
		return false
	var cell: Vector2i = water_layer.local_to_map(water_layer.to_local(global_position))
	return water_layer.get_cell_source_id(cell) != -1

# Elsüllyesztés: rövid várakozás után a blokk eltűnik, lejátszódik a csobbanás, majd a blokk visszakerül a kezdőpozíciójára.
func sink() -> void:
	is_sinking = true
	await get_tree().create_timer(sink_delay).timeout
	
	freeze = true
	$CollisionShape2D.set_deferred("disabled", true)
	$Sprite2D.visible = false
	$Splash.visible = true
	$Splash.play("default")
	await $Splash.animation_finished
	$Splash.visible = false

	# Ha egy RigidBody2D global_position-jét közvetlenül állítjuk át, az nem mindig érvényesül, így a blokk újra a vízben jelenhetne meg, és ismét elsüllyedne. Ezért az áthelyezést az _integrate_forces végzi.
	linear_velocity = Vector2.ZERO
	respawn_pending = true
	freeze = false
	sleeping = false
	# Megvárjuk, amíg az _integrate_forces ténylegesen áthelyezi a blokkot.
	while respawn_pending:
		await get_tree().physics_frame

	$Sprite2D.visible = true
	$CollisionShape2D.set_deferred("disabled", false)
	is_sinking = false

func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	# Visszahelyezés a kezdőpozícióra (lásd sink()).
	if respawn_pending:
		state.transform = Transform2D(0.0, spawn_position)
		state.linear_velocity = Vector2.ZERO
		respawn_pending = false
		return

	if center_on_tiles:
		var v: Vector2 = state.linear_velocity
		# Megjegyezzük, melyik tengely mentén tolta a játékos. Ez akkor is működik, ha a blokk beakadt (pl. egy olyan rés sarkához nyomódik, amellyel nincs egy vonalban).
		if push_axis != Vector2.ZERO:
			slide_axis = push_axis
		# Ha a blokk megállt, elfelejtjük a tengelyt. 
		# Különben a falnak támaszkodó blokkot a csempe közepe felé húznánk, jégen pedig elsodródna.
		elif v.length() < 5.0:
			slide_axis = Vector2.ZERO
		if slide_axis == Vector2.ZERO:
			return
		# A mozgásirányra merőleges sebességkomponenssel húzzuk a blokkot a csempe közepe felé.
		var pos: Vector2 = state.transform.origin
		var tile_center: Vector2 = ((pos / tile_size).floor() + Vector2(0.5, 0.5)) * tile_size
		if slide_axis == Vector2.RIGHT:
			v.y = (tile_center.y - pos.y) * centering_strength
		else:
			v.x = (tile_center.x - pos.x) * centering_strength
		state.linear_velocity = v
