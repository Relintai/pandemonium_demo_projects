extends Camera


func _ready() -> void:
	if is_network_master():
		current = true
	else:
		set_process_input(false)
