extends CharacterBody2D

@export var speed: float = 30
@export var acceleration: float = 5
@export var HP: int = 2
@export var lose_interest_distance: float = 120

var target: Node2D
var is_dead: bool = false

func _ready():
	# Enemies killed earlier stay dead when the level is loaded again.
	if SceneManager.is_enemy_killed(get_enemy_id()):
		queue_free()

# Unique per enemy, e.g. "/root/FirstScene/Enemies/ShellfishEnemy3".
func get_enemy_id() -> String:
	return str(get_path())

func _physics_process(delta):
	if HP <= 0:
		return
	chase_target()
	animate_enemy()
	move_and_slide()
	
func chase_target():
	if is_instance_valid(target):
		var distance_to_player: Vector2 = target.global_position - global_position
		
		if distance_to_player.length() > lose_interest_distance:
			target = null
			
		else:
			var direction_normal: Vector2 = distance_to_player.normalized()
			velocity = velocity.move_toward(direction_normal * speed, acceleration)
			return
	
	velocity = velocity.move_toward(Vector2.ZERO, acceleration)

func animate_enemy():
	if velocity.length() < 0.1:
		$AnimatedSprite2D.play("default")
		return
		
	var normal_velocity: Vector2 = velocity.normalized()
	
	if normal_velocity.x > 0.707:
		$AnimatedSprite2D.play("move_right")
	elif normal_velocity.x < -0.707:
		$AnimatedSprite2D.play("move_left")
	elif normal_velocity.y > 0.707:
		$AnimatedSprite2D.play("move_down")
	elif normal_velocity.y < -0.707:
		$AnimatedSprite2D.play("move_up")

func _on_player_detect_area_2d_body_entered(body: Node2D) -> void:
	if body is Player:
		target = body

func take_damage():
	if is_dead:
		return
	HP -= 1
	if HP <= 0:
		die()
		
	play_damage_sfx()
	
	var flash_red_color: Color = Color(10, 0, 0)
	modulate = flash_red_color
	
	await get_tree().create_timer(0.2).timeout
	
	if is_instance_valid(self):
		var original_color: Color = Color(1, 1, 1)
		modulate = original_color

func play_damage_sfx():
	$DamageSFX.play()
	
func die():
	is_dead = true
	SceneManager.register_kill(get_enemy_id())
	$GPUParticles2D.emitting = true
	$AnimatedSprite2D.visible = false
	$CollisionShape2D.set_deferred("disabled", true)
	
	await get_tree().create_timer(1).timeout
	
	queue_free()
