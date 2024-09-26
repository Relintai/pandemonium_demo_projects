extends KinematicBody2D

var _velocity := Vector2.ZERO
var _accel := GSAITargetAcceleration.new()
var _valid := false
var _drag := 0.1

var agent := GSAIKinematicBody2DAgent.new()
var path := GSAIPath.new()
var follow := GSAIFollowPath.new()

func _ready() -> void:
	agent.body = self
	
	path.initialize(
		[
			Vector3(global_position.x, global_position.y, 0),
			Vector3(global_position.x, global_position.y, 0)
		],
		true
	)

	follow.agent = agent
	follow.path = path
	follow.agent = agent

func setup(
	path_offset: float,
	predict_time: float,
	accel_max: float,
	speed_max: float,
	decel_radius: float,
	arrival_tolerance: float
) -> void:
	owner.drawer.connect("path_established", self, "_on_Drawer_path_established")
	follow.path_offset = path_offset
	follow.prediction_time = predict_time
	follow.deceleration_radius = decel_radius
	follow.arrival_tolerance = arrival_tolerance

	agent.linear_acceleration_max = accel_max
	agent.linear_speed_max = speed_max
	agent.linear_drag_percentage = _drag


func _physics_process(delta: float) -> void:
	if _valid:
		follow.calculate_steering(_accel)
		agent.apply_steering(_accel, delta)


func _on_Drawer_path_established(points: Array) -> void:
	var positions : PoolVector3Array = PoolVector3Array()
	for p in points:
		positions.append(Vector3(p.x, p.y, 0))

	path.create_path(positions)
	_valid = true
