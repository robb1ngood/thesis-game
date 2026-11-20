extends RigidBody2D

# Name of the TileMapLayer that counts as water.
@export var water_layer_name: String = "WaterLayer"
# How long the block can be in the water before it sinks.
@export var sink_delay: float = 1.0

var spawn_position: Vector2
var is_sinking: bool = false
var water_layer: TileMapLayer

func _ready():
	spawn_position = global_position
	# While frozen, the block is moved by code instead of by physics.
	freeze_mode = RigidBody2D.FREEZE_MODE_KINEMATIC
	# Water is on its own collision layer ("Water", layer 6) that blocks don't
	# collide with, so they can be pushed into it. Find it to check tiles.
	water_layer = get_tree().current_scene.find_child(water_layer_name, true, false) as TileMapLayer

func _physics_process(_delta):
	if not is_sinking and is_in_water():
		sink()

# True when the block's center is over a water tile.
func is_in_water() -> bool:
	if water_layer == null:
		return false
	var cell: Vector2i = water_layer.local_to_map(water_layer.to_local(global_position))
	return water_layer.get_cell_source_id(cell) != -1

func sink() -> void:
	is_sinking = true
	
	await get_tree().create_timer(sink_delay).timeout
	
	# Take the block out of the physics simulation and hide it.
	freeze = true
	linear_velocity = Vector2.ZERO
	$CollisionShape2D.set_deferred("disabled", true)
	$Sprite2D.visible = false
	
	$Splash.visible = true
	$Splash.frame = 0
	$Splash.play("default")
	await $Splash.animation_finished
	$Splash.visible = false
	
	await respawn()

func respawn() -> void:
	# Move it back and make sure the move stuck before letting it sink again.
	for attempt in 5:
		global_position = spawn_position
		PhysicsServer2D.body_set_state(get_rid(), PhysicsServer2D.BODY_STATE_TRANSFORM, Transform2D(0.0, spawn_position))
		await get_tree().physics_frame
		await get_tree().physics_frame
		if not is_in_water():
			break
		push_warning("Block respawn didn't stick (attempt %d), position: %s" % [attempt + 1, global_position])
	
	linear_velocity = Vector2.ZERO
	angular_velocity = 0.0
	$Sprite2D.visible = true
	$CollisionShape2D.set_deferred("disabled", false)
	freeze = false
	is_sinking = false
