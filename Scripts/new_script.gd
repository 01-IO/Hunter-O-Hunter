# main.gd
extends Node2D

@onready var player = $Hunter
@onready var ui = $UI
@onready var canvas_modulate = $CanvasModulate
@onready var full_map_light = $DirectionalLight2D
@onready var effect_timer = $EffectTimer

# --- Config for Double or Nothing ---
const CHARGE_DURATION = 2.0
const SUCCESS_START_TIME = 1.73 # Corresponds to Position X = 260
const SUCCESS_END_TIME = 1.87   # Corresponds to Position X = 260 + 20
const EFFECT_DURATION = 3.0 # How long the success/fail effect lasts

const NORMAL_COLOR = Color("333333")
const STUN_COLOR = Color("000000")


func _ready():
	# Connect signals from the player to the UI
	player.charge_started.connect(ui.start_charging)
	player.charge_updated.connect(ui.update_progress)
	
	# Connect the player's charge release to this script's logic
	player.charge_released.connect(_on_player_charge_released)
	
	# Connect the timer's timeout signal
	effect_timer.timeout.connect(_on_effect_timer_timeout)


func _on_player_charge_released(final_time):
	# Stop the UI progress bar
	ui.stop_charging()
	
	# Check if the release time is within the success window
	if final_time >= SUCCESS_START_TIME and final_time <= SUCCESS_END_TIME:
		# SUCCESS!
		print("Double or Nothing: SUCCESS!")
		full_map_light.enabled = true
		effect_timer.start(EFFECT_DURATION)
	else:
		# FAILURE!
		print("Double or Nothing: FAILURE!")
		canvas_modulate.color = STUN_COLOR
		player.stun(EFFECT_DURATION)
		effect_timer.start(EFFECT_DURATION)


func _on_effect_timer_timeout():
	# This function is called when the timer finishes, resetting all effects.
	print("Effects have worn off.")
	full_map_light.enabled = false
	canvas_modulate.color = NORMAL_COLOR


### **Part 5: Final Check**

#You've built all the pieces! Now just make sure:
#
#1.  The scripts are saved and attached to the correct nodes.
#2.  The scenes (`player.tscn`, `ui.tscn`) are saved.
#3.  In `Project -> Project Settings -> General -> Application -> Run`, set the **Main Scene** to `main.tscn`.
#4.  Hit **F5** to run your project!
#
#You should now be able to:
#
#* Move with WASD.
#* Left-click to emit a small, revealing echo.
#* Hold Right-click to charge the "Double or Nothing" echo, see the UI bar, and release.
#* Succeeding reveals the map; failing makes the screen black and stuns you.
#
#### **Part 6: Next Steps (For Day 2!)**
#
#With the core mechanic done, you can now build the rest of the game.
#
#* **Enemies:** Create simple enemies (`CharacterBody2D` or `Area2D`) that move around. They are only visible when in the light.
#* **Objective:** What is the hunter hunting? Add a collectible, a specific enemy to find, or an exit point.
#* **Sound:** Add sound effects! A charging sound, a success "ping", a failure "buzz", and a pulsing heartbeat when stunned will add a lot of atmosphere.
#* **Polish:** Add particle effects for the echoes, a proper player sprite, and a more interesting level layout.
#
#Good luck with your game jam! You have a solid foundation now.
