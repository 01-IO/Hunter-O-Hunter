extends CharacterBody2D

@export var movement_speed: float = 150.0

#Echo variables
@onready var normal_echo_light: PointLight2D = $NormalEchoLight
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

var is_charging: bool = false
var charge_time: float = 0.0

#Stun state
var is_stunned: bool = false

#Signals to communicate with the UI and MainScene
signal charge_started(charge_duration)
signal charge_updated(current_time)
signal charge_released(final_time)

enum HunterState {
	IDLE,
	RUNNING
}

var setHunterState = HunterState.IDLE

func _physics_process(delta: float) -> void:
	# Don't move if stunned or charging
	if is_stunned or is_charging:
		velocity = Vector2.ZERO
		move_and_slide()
		return
	
	# Handle player movement
	var direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = direction * movement_speed
	# Handle sprite flip
	if velocity.x != 0:
		animated_sprite.flip_h = velocity.x < 0
	
	if velocity.x or velocity.y != 0:
		setHunterState = HunterState.RUNNING
	else:
		setHunterState = HunterState.IDLE
	match setHunterState:
		HunterState.IDLE:
			animated_sprite.play("idle")
		HunterState.RUNNING:
			animated_sprite.play("run")
	

	move_and_slide()

func _unhandled_input(event):
	# Can't use abilities while stunned
	if is_stunned:
		return

	# --- Normal Echo ---
	if event.is_action_pressed("normal_echo") and not is_charging:
		emit_normal_echo()

	# --- Double or Nothing Echo ---
	if event.is_action_pressed("double_or_nothing"):
		is_charging = true
		charge_time = 0.0
		# We'll define the total charge duration here. Let's say 2 seconds.
		emit_signal("charge_started", 2.0)

	if event.is_action_released("double_or_nothing"):
		if is_charging:
			is_charging = false
			emit_signal("charge_released", charge_time)


func _process(delta):
	# Update charge timer if charging
	if is_charging:
		charge_time += delta
		emit_signal("charge_updated", charge_time)


func emit_normal_echo():
	# Use a Tween to create a smooth flash effect for the normal echo
	var tween = create_tween()
	# Flash on
	tween.tween_property(normal_echo_light, "energy", 10, 0.1).from(0)
	tween.tween_property(normal_echo_light, "texture_scale", 1.5, 0.2)
	# Fade out
	tween.tween_property(normal_echo_light, "energy", 0.0, 0.8)
	tween.parallel().tween_property(normal_echo_light, "texture_scale", 1.0, 0.8)


func stun(duration) -> void:
	is_stunned = true
	print("Player stunned!")
	await get_tree().create_timer(duration).timeout
	is_stunned = false
	print("Player recovered from stun.")
