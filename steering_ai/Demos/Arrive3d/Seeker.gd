extends KinematicBody

var target_node: Spatial

var agent : GSAIKinematicBody3DAgent = null
var target : GSAIAgentLocation = null
var accel : GSAITargetAcceleration = null
var blend : GSAIBlend = null
var face : GSAIFace = null
var arrive : GSAIArrive = null

func _init() -> void:
	agent = GSAIKinematicBody3DAgent.new()
	agent.body = self
	
	target = GSAIAgentLocation.new()
	accel = GSAITargetAcceleration.new()
	blend = GSAIBlend.new()
	blend.agent = agent
	
	face = GSAIFace.new()
	face.agent = agent
	face.target = target
	face.use_z = true
	
	arrive = GSAIArrive.new()
	arrive.agent = agent
	arrive.target = target

func _physics_process(delta: float) -> void:
	target.position = target_node.transform.origin
	target.position.y = transform.origin.y
	blend.calculate_steering(accel)
	agent.apply_steering(accel, delta)


func setup(
	align_tolerance: float,
	angular_deceleration_radius: float,
	angular_accel_max: float,
	angular_speed_max: float,
	deceleration_radius: float,
	arrival_tolerance: float,
	linear_acceleration_max: float,
	linear_speed_max: float,
	_target: Spatial
) -> void:
	agent.linear_speed_max = linear_speed_max
	agent.linear_acceleration_max = linear_acceleration_max
	agent.linear_drag_percentage = 0.05
	agent.angular_acceleration_max = angular_accel_max
	agent.angular_speed_max = angular_speed_max
	agent.angular_drag_percentage = 0.1

	arrive.arrival_tolerance = arrival_tolerance
	arrive.deceleration_radius = deceleration_radius

	face.alignment_tolerance = align_tolerance
	face.deceleration_radius = angular_deceleration_radius

	target_node = _target
	self.target.position = target_node.transform.origin
	blend.add_behavior(arrive, 1)
	blend.add_behavior(face, 1)
