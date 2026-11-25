extends CharacterBody2D
class_name Player

# A játékos karaktere: mozgás, blokktolás, interakció, kardos támadás, sebződés és halál.
# Az életerőt, a kincseket és azt, hogy megvan-e már a kard, a SceneManager tárolja, így ezek jelenetváltás után is megmaradnak.

@export var move_speed: float = 100
@export var push_strength: float = 10
@export var acceleration: float = 10

var has_weapon: bool = false
var is_attacking: bool = false
# Igaz, ha egy interakcióra képes objektum (NPC, láda, kapcsoló stb.) van az interakciós területen.
var can_interact: bool = false
var ignore_interact_press: bool = false

func _ready():
	# Az állapotot a SceneManagerből töltjük vissza.
	has_weapon = SceneManager.has_weapon
	update_treasure_label()
	update_hp_bar()
	# Ha egy pályabejárat megadott kezdőpozíciót, oda kerülünk (Vector2.ZERO esetén marad a jelenetben beállított hely).
	if SceneManager.player_spawn_position != Vector2(0, 0):
		position = SceneManager.player_spawn_position

func _physics_process(delta):
	if SceneManager.player_hp <= 0:
		return
	
	if not is_attacking:
		move_player()
		
	push_block()
	
	update_treasure_label()
	
	# A kard felvételét jelentő gombnyomás ne indítson egyúttal suhintást is: a jelzőt csak a gomb felengedése után töröljük.
	if not Input.is_action_pressed("interact"):
		ignore_interact_press = false

	# Az "interact" gomb támadást indít, ha már van kard, és a közelben nincs semmi, amivel interakcióba lehetne lépni.
	if Input.is_action_just_pressed("interact") and not can_interact and has_weapon and not ignore_interact_press:
		attack()
	
	move_and_slide()
	
# Mozgás a bemenet alapján, fokozatos gyorsulással.
func move_player():
	var move_vector: Vector2 = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	
	velocity = velocity.move_toward(move_vector * move_speed, acceleration)
	
	# Az iránynak megfelelő animáció játszódik le, az interakciós terület pedig a karakter elé kerül.
	if velocity.x > 0:
		$AnimatedSprite2D.play("move_right")
		$InteractArea2D.position = Vector2(5, 2)
		
	elif velocity.x < 0:
		$AnimatedSprite2D.play("move_left")
		$InteractArea2D.position = Vector2(0-5, 2)
		
	elif velocity.y < 0:
		$AnimatedSprite2D.play("move_up")
		$InteractArea2D.position = Vector2(0, -4)
		
	elif velocity.y > 0:
		$AnimatedSprite2D.play("move_down")
		$InteractArea2D.position = Vector2(0, 8)
		
	else: 
		$AnimatedSprite2D.stop()
		
func push_block():
	
	# Lekérjük a legutóbbi ütközést, megnézzük, hogy tolható blokkal történt-e, és ha igen, megtoljuk a blokkot.
	
	var collision: KinematicCollision2D = get_last_slide_collision()
	if collision:
		
		var collider_node = collision.get_collider()
		
		if collider_node.is_in_group("pushable"):
			var collision_normal: Vector2 = collision.get_normal()
			
			# Az erő az ütközési normállal ellentétes irányú, vagyis a játékostól elfelé tol.
			collider_node.apply_central_force(-collision_normal * push_strength)

# A kincsszámláló a kinyitott ládák számát mutatja.
func update_treasure_label():
	var treasure_amount: int = SceneManager.opened_chests.size()
	$%TreasureLabel.text = str(treasure_amount)

# Interakcióra képes objektum került az interakciós területre.
func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("interactable"):
		can_interact = true
		body.can_interact = true

func _on_area_2d_body_exited(body: Node2D) -> void:
	# Itt szándékosan nem a csoportot vizsgáljuk: egy objektum kikerülhet az "interactable" csoportból, miközben a játékos még mellette áll (pl. a kő a kard felvétele után).
	# Ilyenkor a can_interact igaz értéken ragadna, ami blokkolná a támadást.
	if "can_interact" in body:
		can_interact = false
		body.can_interact = false

# Ellenséggel való érintkezés (a HitboxArea2D csak az ellenségek rétegét figyeli): sebződés, visszalökés és egy rövid fehér villanás.
func _on_hitbox_area_2d_body_entered(body: Node2D) -> void:
	SceneManager.player_hp -= 1
	update_hp_bar()
	if SceneManager.player_hp <= 0:
		die()
		
	# Visszalökés az ellenségtől elfelé.
	var distance_to_player: Vector2 = global_position - body.global_position
	var knockback_direction: Vector2 = distance_to_player.normalized()
	
	var knockback_strength: float = 200
	velocity += knockback_direction * knockback_strength
	
	$DamageSFX.play()
	
	var flash_white_color: Color = Color(50, 50, 50)
	modulate = flash_white_color
	
	await get_tree().create_timer(0.2).timeout
	
	var original_color: Color = Color(1, 1, 1)
	modulate = original_color
	
# Halál: lejátszódik a halálanimáció, és elindul a DeathTimer.
func die():
	$AnimatedSprite2D.play("death")
	if $DeathTimer.is_stopped():
		$DeathTimer.start()
	
# A DeathTimer lejártakor visszaáll a teljes életerő, és újratöltődik az aktuális jelenet.
func _on_death_timer_timeout() -> void:
	SceneManager.player_hp = 4
	get_tree().call_deferred("reload_current_scene")

# Az életerő-kijelző (szívek) frissítése az aktuális életerő alapján.
func update_hp_bar():
	if SceneManager.player_hp == 4:
		%HPBar.play("4_hp")
	elif SceneManager.player_hp == 3:
		%HPBar.play("3_hp")
	elif SceneManager.player_hp == 2:
		%HPBar.play("2_hp")
	elif SceneManager.player_hp == 1:
		%HPBar.play("1_hp")
	else:
		%HPBar.play("0_hp")
		
# Kardos támadás: rövid időre megjelenik a kard, és bekapcsol a találati területe.
func attack(): 
	# Amíg az előző támadás tart, nem indulhat új.
	if not $AttackDurationTimer.is_stopped():
		return
	
	$Sword.visible = true
	%SwordArea2D.monitoring = true
	$AttackDurationTimer.start()
	is_attacking = true
	velocity = Vector2(0, 0)
	
	$AttackSFX.play()
	
	# A támadás irányát az aktuális mozgásanimáció (vagyis a nézési irány) határozza meg.
	var player_animation: String = $AnimatedSprite2D.animation
	if player_animation == "move_right":
		$AnimatedSprite2D.play("attack_right")
		$AnimationPlayer.play("attack_right")
	if player_animation == "move_left":
		$AnimatedSprite2D.play("attack_left")
		$AnimationPlayer.play("attack_left")
	if player_animation == "move_up":
		$AnimatedSprite2D.play("attack_up")
		$AnimationPlayer.play("attack_up")
	if player_animation == "move_down":
		$AnimatedSprite2D.play("attack_down")
		$AnimationPlayer.play("attack_down")

# A kard eltalált egy ellenséget (a SwordArea2D csak az ellenségek rétegét figyeli): visszalökés és sebzés.
func _on_sword_area_2d_body_entered(body: Node2D) -> void:
	var distance_to_enemy: Vector2 = body.global_position - global_position
	var knockback_direction: Vector2 = distance_to_enemy.normalized()
	
	var knockback_strength: float = 150
	
	body.velocity += knockback_direction * knockback_strength
	
	body.take_damage()
	
# A támadás vége: eltűnik a kard, és visszaáll a nézési iránynak megfelelő mozgásanimáció.
func _on_attack_duration_timer_timeout() -> void:
	$Sword.visible = false
	%SwordArea2D.monitoring = false
	is_attacking = false
	
	var player_animation: String = $AnimatedSprite2D.animation
	if player_animation == "attack_right":
		$AnimatedSprite2D.play("move_right")
	if player_animation == "attack_left":
		$AnimatedSprite2D.play("move_left")
	if player_animation == "attack_up":
		$AnimatedSprite2D.play("move_up")
	if player_animation == "attack_down":
		$AnimatedSprite2D.play("move_down")

# A WeaponPickup weapon_picked_up jelére hívódik meg: innentől a játékos tud támadni.
func _on_weapon_picked_up():
	ignore_interact_press = true
	has_weapon = true
	SceneManager.has_weapon = true
