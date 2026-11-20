extends RigidBody2D

# Blocks pushed into the water sink, splash and respawn at their start.
@export var water_layer_name: String = "WaterLayer"
@export var sink_delay: float = 1.0

var spawn_position: Vector2
var is_sinking: bool = false
var water_layer: TileMapLayer

func _ready():
	spawn_position = global_position
	freeze_mode = RigidBody2D.FREEZE_MODE_KINEMATIC
	water_layer = get_tree().current_scene.find_child(water_layer_name, true, false)

func _physics_process(_delta):
	if not is_sinking and is_in_water():
		sink()

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
	
	global_position = spawn_position
	await get_tree().physics_frame
	linear_velocity = Vector2.ZERO
	$Sprite2D.visible = true
	$CollisionShape2D.set_deferred("disabled", false)
	freeze = false
	is_sinking = false
