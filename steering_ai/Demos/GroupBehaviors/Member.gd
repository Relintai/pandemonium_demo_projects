extends KinematicBody2D

var separation: GSAISeparation
var cohesion: GSAICohesion
var proximity: GSAIRadiusProximity
var agent :GSAIKinematicBody2DAgent = null
var blend : GSAIBlend = null
var acceleration : GSAITargetAcceleration = null
var draw_proximity := false

var _color := Color.red
var _velocity := Vector2()

onready var collision_shape := $CollisionShape2D

func _init() -> void:
	agent = GSAIKinematicBody2DAgent.new()
	agent.body = self
	
	blend = GSAIBlend.new()
	blend.agent = agent
	
	acceleration = GSAITargetAcceleration.new()

func setup(
	linear_speed_max: float,
	linear_accel_max: float,
	proximity_radius: float,
	separation_decay_coefficient: float,
	cohesion_strength: float,
	separation_strength: float
) -> void:
	_color = Color(rand_range(0.5, 1), rand_range(0.25, 1), rand_range(0, 1))
	collision_shape.inner_color = _color

	agent.linear_acceleration_max = linear_accel_max
	agent.linear_speed_max = linear_speed_max
	agent.linear_drag_percentage = 0.1

	proximity = GSAIRadiusProximity.new()
	proximity.agent = agent
	proximity.radius = proximity_radius

	separation = GSAISeparation.new()
	separation.agent = agent
	separation.proximity = proximity
	separation.decay_coefficient = separation_decay_coefficient
	
	cohesion = GSAICohesion.new()
	cohesion.agent = agent
	cohesion.proximity = proximity
	
	blend.add_behavior(separation, separation_strength)
	blend.add_behavior(cohesion, cohesion_strength)


func _draw() -> void:
	if draw_proximity:
		draw_circle(Vector2.ZERO, proximity.radius, Color(0.4, 1.0, 0.89, 0.3))


func _physics_process(delta: float) -> void:
	if blend:
		blend.calculate_steering(acceleration)
		agent.apply_steering(acceleration, delta)


func set_neighbors(neighbor: Array) -> void:
	proximity.agents = neighbor
