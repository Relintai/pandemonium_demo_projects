extends Sprite

export(float) var character_speed = 400.0
var path = []

var agent : NavigationAgent2D

func _ready() -> void:
	agent = get_node("NavigationAgent2D")
	agent.max_speed = 10
	
	agent.connect("link_reached", self, "link_reached")
	agent.connect("navigation_finished", self, "navigation_finished")
	agent.connect("path_changed", self, "path_changed")
	agent.connect("target_reached", self, "target_reached")
	#agent.connect("velocity_computed", self, "velocity_computed")
	agent.connect("waypoint_reached", self, "waypoint_reached")

func _physics_process(delta: float) -> void:
	var walk_distance = character_speed * delta
	
	position = agent.get_next_position()
	
	#print(agent.get_nav_path())
	
	#if agent.is_navigation_finished():
	#	set_physics_process(false)

func _unhandled_input(event):
	if not event.is_action_pressed("click"):
		return
	
	agent.target_position = get_local_mouse_position()
	print(agent.target_position)
	set_physics_process(true)
	#print(agent.get_nav_path())

func link_reached(details: Dictionary):
	print("link_reached")
	print(details)

func navigation_finished():
	print("navigation_finished")

func path_changed():
	print("path_changed")

func target_reached():
	print("target_reached")
	
func velocity_computed(safe_velocity: Vector2):
	print("velocity_computed")
	print(safe_velocity)
	
func waypoint_reached(details: Dictionary):
	print("waypoint_reached")
	print(details)

