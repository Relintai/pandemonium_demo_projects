extends Node


# Declare member variables here. Examples:
# var a: int = 2
# var b: String = "text"


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print("")
	print("")
	print("When running this demo what you need to see is that ")
	print("between every frame steps you see 3 _process() calls, and 3 _process_group_process() start,")
	print("and 3 _process_group_process() end calls printed to the console.")
	print("This means that the ProcessGroups works properly.")
	print("_process() methods will run in the main thread, and ProcessGroup calls it's ")
	print("children's _process_group_process() in it's own thread, and ProcessGroup2 also calls it's ")
	print("children's _process_group_process() in it's own thread,")
	print("and SceneTree waits for them to finish before going to the next step.")
	print("This allows multi threaded processing similar to Godot 4s,")
	print("howewer this implementation tries t make it as explicit as possible when you are working in a thread or not.")
	print("")
	print("")
	
	get_tree().connect("idle_frame", self, "idle_frame")


func idle_frame():
	print("==============  NEW FRAME START  ==============")
