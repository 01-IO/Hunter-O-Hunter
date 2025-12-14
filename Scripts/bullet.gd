extends Sprite2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var shadow: Sprite2D = $Shadow
@onready var ray_cast_2d: RayCast2D = $RayCast2D

@export var speed: float = 120.0
@export var bullet_damage: float = 15.0

var is_hit: bool = false

func _physics_process(delta: float) -> void:
	global_position += Vector2(1, 0).rotated(rotation) * speed * delta
	shadow.position = Vector2(-2, 2).rotated(-rotation)
	
	if is_hit:
		return
	
	if ray_cast_2d.is_colliding():
		var collider = ray_cast_2d.get_collider()
		
		if !collider.get("IS_PLAYER"): #make sure it's not player taking damage from bullet
			is_hit = true
			
			if collider.has_method("take_damage"):
				collider.take_damage(bullet_damage)
				print("Bullet hit, dealt %s, dealt damage to: %s" % [bullet_damage, collider.name])
			#play bullet remvoal animation whether it hits enemy or wall
			animation_player.play("remove")

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "remove":
		queue_free()


func _on_distance_timer_timeout() -> void:
	animation_player.play("remove")
