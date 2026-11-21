extends RigidBody2D

# Blocks pushed into the water sink, splash and respawn at their start.
@export var water_layer_name: String = "WaterLayer"
@export var sink_delay: float = 1.0
# While sliding, gently pull the block onto the middle of its row/column of tiles,
# so slippery blocks (ice) line up with 1-tile gaps instead of catching on corners.
@export var center_on_tiles: bool = false
@export var tile_size: float = 16.0
@export var centering_strength: float = 10.0

var spawn_position: Vector2
var is_sinking: bool = false
var respawn_pending: bool = false
var slide_axis: Vector2 = Vector2.ZERO # axis the block was last pushed along
var push_axis: Vector2 = Vector2.ZERO # axis the player is pushing along right now
var water_layer: TileMapLayer

func _ready():
	spawn_position = global_position
	freeze_mode = RigidBody2D.FREEZE_MODE_KINEMATIC
	water_layer = get_tree().current_scene.find_child(water_layer_name, true, false)

func _physics_process(_delta):
	if not is_sinking and is_in_water():
		sink()
	if center_on_tiles:
		push_axis = get_push_axis()

# The axis the player is pushing this block along, or ZERO if they aren't.
func get_push_axis() -> Vector2:
	var player = get_tree().get_first_node_in_group("player")
	if player == null:
		return Vector2.ZERO
	var collision: KinematicCollision2D = player.get_last_slide_collision()
	if collision == null or collision.get_collider() != self:
		return Vector2.ZERO
	var normal: Vector2 = collision.get_normal()
	return Vector2.RIGHT if absf(normal.x) > absf(normal.y) else Vector2.DOWN

func is_in_water() -> bool:
	if water_layer == null:
		return false
	var cell: Vector2i = water_layer.local_to_map(water_layer.to_local(global_position))
	return water_layer.get_cell_source_id(cell) != -1

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

	# Setting global_position on a RigidBody2D doesn't always stick, so the block
	# could reappear in the water and sink again. Move it in _integrate_forces instead.
	linear_velocity = Vector2.ZERO
	respawn_pending = true
	freeze = false
	sleeping = false
	while respawn_pending:
		await get_tree().physics_frame

	$Sprite2D.visible = true
	$CollisionShape2D.set_deferred("disabled", false)
	is_sinking = false

func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	if respawn_pending:
		state.transform = Transform2D(0.0, spawn_position)
		state.linear_velocity = Vector2.ZERO
		respawn_pending = false
		return

	if center_on_tiles:
		var v: Vector2 = state.linear_velocity
		# Remember which axis the player pushed along. This also works when the
		# block is stuck (e.g. pressed against the corner of a gap it isn't lined up with).
		if push_axis != Vector2.ZERO:
			slide_axis = push_axis
		# Once the block stops, forget the axis. Otherwise a block resting against a
		# wall gets pulled toward the tile center and, on ice, drifts off.
		elif v.length() < 5.0:
			slide_axis = Vector2.ZERO
		if slide_axis == Vector2.ZERO:
			return
		var pos: Vector2 = state.transform.origin
		var tile_center: Vector2 = ((pos / tile_size).floor() + Vector2(0.5, 0.5)) * tile_size
		if slide_axis == Vector2.RIGHT:
			v.y = (tile_center.y - pos.y) * centering_strength
		else:
			v.x = (tile_center.x - pos.x) * centering_strength
		state.linear_velocity = v
