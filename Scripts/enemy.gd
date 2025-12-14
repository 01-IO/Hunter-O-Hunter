extends CharacterBody2D

@export var speed: float = 25.0
@export var chase_speed: float = 50.0
@export var is_stationary: bool = false
@export var attack_damage: float = 12.0
@export var attack_frame: int = 6 # Attack animation frame wrt AnimatedSprite2D's attack animation
@export var max_health: float = 30.0

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var wander_timer: Timer = $WanderTimer
@onready var enemry_attack_area: Area2D = $EnemryAttackArea
@onready var detection_area: Area2D = $DetectionArea

enum { IDLE, WANDER, CHASE, ATTACK, DEATH, HURT }
var state = IDLE

var wander_direction = Vector2.ZERO
var player = null
var player_in_attack_range: bool = false
var damage_dealt_this_attack: bool = false

var curr_health: float
var is_alive: bool = true

func _ready() -> void:
	curr_health = max_health

func _physics_process(delta: float) -> void:
	match state:
		WANDER:
			velocity = wander_direction * speed
			animated_sprite.play("run")
		
		CHASE: 
			if player:
				var direction_to_player = global_position.direction_to(player.global_position)
				velocity = direction_to_player * chase_speed
				animated_sprite.play("run")
				
				if player_in_attack_range:
					state = ATTACK
					damage_dealt_this_attack = false
					print("entered")
			else:
				state = IDLE
		
		IDLE:
			velocity = Vector2.ZERO
			animated_sprite.play("idle")
		
		ATTACK:
			velocity = Vector2.ZERO
			# Only start a new attack animation if one isn't currently playing
			if not animated_sprite.is_playing() or animated_sprite.animation != "attack":
				print("Starting attack animation")
				animated_sprite.play("attack")
				damage_dealt_this_attack = false
			if animated_sprite.frame == attack_frame and not damage_dealt_this_attack:
				deal_attack_damage()
				damage_dealt_this_attack = true
		
		HURT:
			velocity= Vector2.ZERO
			animated_sprite.play("take_damage")
		
		DEATH:
			velocity = Vector2.ZERO
	
	move_and_slide()
	
	if velocity.x != 0:
		animated_sprite.flip_h = velocity.x < 0

func take_damage(damage: float):
	if !is_alive:
		return
	
	print("ENEMY TOOK DAMAGE")
	curr_health -= damage
	var message = "Enemy took %s damage, %s health remaining" % [damage, curr_health]
	print(message)
	
	if curr_health <= 0:
		is_alive = false
		state = DEATH
		animated_sprite.play("death")
	else:
		if state != HURT:
			state = HURT
			animated_sprite.animation_finished.connect(_on_hurt_animation_finished)
		animated_sprite.play("take_damage")
		#state = HURT
		#var connection 
		#connection = animated_sprite.animation_finished.connect(func():
			#
			#if state == HURT: 
				#if player:
					#state = CHASE
				#else:
					#state = WANDER
					#
			#animated_sprite.animation_finished.disconnect(connection) 
		#)

func _on_hurt_animation_finished():
	if animated_sprite.animation == "take_damage":
		animated_sprite.animation_finished.disconnect(_on_hurt_animation_finished)
		if state == HURT: 
			# Transition back to chasing or wandering
			if player:
				state = CHASE
			else:
				state = WANDER

func _on_wander_timer_timeout() -> void:
	if state == CHASE or state == ATTACK:
		return  # Don't change state while chasing or attacking
	# If stationary and hasn't detected player yet, stay IDLE
	if is_stationary and not player:
		return
	# Alternate between IDLE and WANDER
	if state == IDLE:
		state = WANDER
		wander_direction = Vector2(
			randf_range(-1.0, 1.0),
			randf_range(-1.0, 1.0)
		).normalized()
	else:  # state == WANDER
		state = IDLE
	
	wander_timer.wait_time = randf_range(2.0, 5.0)

func _on_detection_area_body_entered(body: Node2D) -> void:
	if body.name == "Hunter":
		print("Hunter detectet!")
		player = body
		state = CHASE
	
func _on_detection_area_body_exited(body: Node2D) -> void:
	if body.name == "Hunter":
		print("Hunter lost!")
		player = null
		state = IDLE

func deal_attack_damage():
	print("Enemy attack frame hit!!")
	for body in enemry_attack_area.get_overlapping_bodies():
		if body.has_method("take_damage"):
			body.take_damage(attack_damage)

func _on_enemry_attack_area_body_entered(body: Node2D) -> void:
	if body.name == "Hunter":
		player_in_attack_range = true
		state = ATTACK
		damage_dealt_this_attack = false

func _on_enemry_attack_area_body_exited(body: Node2D) -> void:
	if body.name == "Hunter":
		player_in_attack_range = false
		state = CHASE

func _on_animated_sprite_2d_animation_finished() -> void:
	
	if animated_sprite.animation == "attack":
		print("Attack animation finished. Player in range: ", player_in_attack_range)
		if player_in_attack_range:
			state = ATTACK
			damage_dealt_this_attack = false
		elif player:
			state = CHASE
	
	if state == DEATH or state == HURT:
		if animated_sprite.animation == "death":
			queue_free()
		print("enemy dead")
		return
