extends CharacterBody2D

@export var speed: float = 50.00
@export var chase_speed: float = 75.0
@export var is_stationary: bool = false

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var wander_timer: Timer = $WanderTimer

enum { IDLE, WANDER, CHASE }
var state = IDLE

var wander_direction = Vector2.ZERO
var player = null

func _ready() -> void:
	pass

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
			else:
				state = IDLE
		
		IDLE:
			velocity = Vector2.ZERO
			animated_sprite.play("idle")
	
	move_and_slide()
	
	if velocity.x != 0:
		animated_sprite.flip_h = velocity.x < 0


func _on_wander_timer_timeout() -> void:
	if state == CHASE:
		return  # Don't change state while chasing
	
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

func decideEnemyState(state):
	pass
