extends CanvasLayer

@onready var progress_bar = $MarginContainer/ProgressBar

func _ready():
	# Hide at the start
	progress_bar.visible = false

func start_charging(duration):
	progress_bar.max_value = duration
	progress_bar.value = 0
	progress_bar.visible = true

func update_progress(current_time):
	progress_bar.value = current_time

func stop_charging():
	progress_bar.visible = false
