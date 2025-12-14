extends Node2D

const bullet = preload("res://Scenes/bullet.tscn")

const IS_PLAYER = true

@onready var rotation_offset: Node2D = $RotationOffset
@onready var sprite_shadow: Sprite2D = $RotationOffset/Sprite2D/Shadow
@onready var shoot_position: Marker2D = $RotationOffset/Sprite2D/ShootPosition
@onready var shoot_timer: Timer = $ShootTimer

var time_between_shot: float = 0.25
var can_shoot: bool = true

func _ready() -> void:
	shoot_timer.wait_time = time_between_shot

func _process(delta: float) -> void:
	rotation_offset.rotation = lerp_angle(rotation_offset.rotation, ( get_global_mouse_position() - global_position ).angle(), 6.5 * delta)
	sprite_shadow.position = Vector2(-2, 2).rotated(-rotation_offset.rotation)
	
	#if Input.is_action_just_pressed("shoot") and can_shoot: #Maybe move this to unhandled input
		#can_shoot = false
		#shoot()
		#$ShootTimer.start()

func shoot():
	var new_bullet = bullet.instantiate()
	new_bullet.global_transform = shoot_position.global_transform
	get_parent().get_parent().add_child(new_bullet)


func _on_shoot_timer_timeout() -> void:
	can_shoot = true
