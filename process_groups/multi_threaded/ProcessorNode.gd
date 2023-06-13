extends Node


# Declare member variables here. Examples:
# var a: int = 2
# var b: String = "text"


# Called when the node enters the scene tree for the first time.
#func _ready() -> void:
#	set_process_group_process(false)
#	set_process_group_process(true)

func _process_group_process(delta: float) -> void:
	print(str(get_path()) + " _process_group_process() start")
	OS.delay_msec(1000)
	print(str(get_path()) + " _process_group_process() fin")
	
	
func _process(delta: float) -> void:
	print(str(get_path()) + " _process()")

#func _notification(what: int) -> void:
#	#print(what)
#	if what >= 60 && what <= 70:
#		print(what)
