extends Node2D

@onready var rotation_offset: Node2D = $RotationOffset
@onready var sprite_shadow: Sprite2D = $RotationOffset/Sprite2D/Shadow
@onready var shoot_position: Marker2D = $RotationOffset/Sprite2D/ShootPosition

var time_between_shot: float = 0.25
var can_shoot: bool = true

func _ready() -> void:
	$ShootTimer.wait_time = time_between_shot

func _physics_process(delta: float) -> void:
	rotation_offset.rotation = lerp_angle(rotation_offset.rotation, ( get_global_mouse_position() - global_position ).angle(), 6.5 * delta)
	sprite_shadow.position = Vector2(-2, 2).rotated(-rotation_offset.rotation)
