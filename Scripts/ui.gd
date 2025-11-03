extends CanvasLayer

@onready var progress_bar = $MarginContainer/ProgressBar
@onready var health_bar: TextureProgressBar = $Health/HBoxContainer/HealthBar
@onready var normal_echo_cooldown: TextureProgressBar = $EffectHUD/HBoxContainer/NormalEchoCooldown
@onready var don_cooldown: TextureProgressBar = $EffectHUD/HBoxContainer/DonCooldown

var normal_echo_timer: float = 0.0
var normal_echo_duration: float = 0.0
var don_timer: float = 0.0
var don_duration: float = 0.0

func _ready():
	# Hide at the start
	progress_bar.visible = false
	normal_echo_cooldown.max_value = 100
	normal_echo_cooldown.value = 100
	don_cooldown.max_value = 100
	don_cooldown.value = 100

func _process(delta: float) -> void:
	if normal_echo_timer > 0:
		normal_echo_timer -= delta
		# Calculate percentage and update the radial progress bar
		normal_echo_cooldown.value = ( 1.0 - ( normal_echo_timer / normal_echo_duration )) * 100
	else:
		normal_echo_cooldown.value = 100 # set to max once finsihed
	if don_timer > 0:
		don_timer -= delta
		don_cooldown.value = ( 1.0 - (don_timer / don_duration)) * 100
	else:
		don_cooldown.value = 100

# --- Functions Connected to Player Signals ---
# DON Charge bar functions
func start_charging(duration):
	progress_bar.max_value = duration
	progress_bar.value = 0
	progress_bar.visible = true

func update_progress(current_time):
	progress_bar.value = current_time

func stop_charging():
	progress_bar.visible = false

# Ability Cooldowns
func _on_hunter_normal_echo_started(cooldown_time: Variant) -> void:
	normal_echo_duration = cooldown_time
	normal_echo_timer = cooldown_time
	normal_echo_cooldown.value = 0 # Start the visual timer from 0

func _on_hunter_don_started(cooldown_time: Variant) -> void:
	don_duration = cooldown_time
	don_timer = cooldown_time
	don_cooldown.value = 0 # Start the visual timer from 0


func _on_hunter_update_health(current_health: float, max_health: float) -> void:
	health_bar.max_value = max_health
	health_bar.value = current_health
	print("health updated in UI!")
