extends KinematicBody2D

var player_agent: GSAIAgentLocation
var velocity := Vector2.ZERO
var start_speed: float
var start_accel: float
var use_seek := true

var agent : GSAIKinematicBody2DAgent = null
var accel : GSAITargetAcceleration = null
var seek : GSAISeek = null
var flee : GSAIFlee = null


func _ready() -> void:
	agent = GSAIKinematicBody2DAgent.new()
	agent.body = self
	
	accel = GSAITargetAcceleration.new()
	
	seek = GSAISeek.new()
	seek.agent = agent
	seek.target = player_agent
	
	flee = GSAIFlee.new()
	flee.agent = agent
	flee.target = player_agent
	
	agent.linear_acceleration_max = start_accel
	agent.linear_speed_max = start_speed


func _physics_process(delta: float) -> void:
	if not player_agent:
		return

	if use_seek:
		seek.calculate_steering(accel)
	else:
		flee.calculate_steering(accel)

	agent.apply_steering(accel, delta)
