extends TextureProgressBar

var timer: Timer

func setup(t: Timer) -> void:
	timer = t
	
func _process(_delta: float) -> void:
	if timer == null:
		return
	if timer.is_stopped():
		value = max_value
	else: 
		value = 1.0 - timer.time_left/timer.wait_time
