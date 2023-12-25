extends NetworkedController
# Take cares to control the player and propagate the motion on the other peers


const MAX_PLAYER_DISTANCE: float = 20.0

var _position_id := -1
var _rotation_id := -1


func _ready():
	# Notify the NetworkSync who is controlling parent nodes.
	NetworkSync.set_node_as_controlled_by(get_parent(), self)
	NetworkSync.register_variable(get_parent(), "translation")
	NetworkSync.register_variable(get_parent(), "linear_velocity")
	NetworkSync.register_variable(get_parent(), "on_floor")
	if not get_tree().multiplayer.is_network_server():
		set_physics_process(false)


func _physics_process(_delta):
	"""
	# Changes the character relevancy to scale the net traffic depending on the character
	importance.
	for character in get_tree().get_nodes_in_group("characters"):
		if character != get_parent():
			var delta_distance = character.get_global_transform().origin - get_parent().get_global_transform().origin

			var is_far_away = delta_distance.length_squared() > (MAX_PLAYER_DISTANCE * MAX_PLAYER_DISTANCE)
			set_doll_peer_active(character.get_network_master(), !is_far_away);
	"""


func _collect_inputs(_delta: float, db: DataBuffer):
	# Collects the player inputs.

	var input_direction := Vector3()
	var is_jumping: bool = false

	if Input.is_action_pressed("forward"):
		input_direction -= get_parent().camera.global_transform.basis.z
	if Input.is_action_pressed("backward"):
		input_direction += get_parent().camera.global_transform.basis.z
	if Input.is_action_pressed("left"):
		input_direction -= get_parent().camera.global_transform.basis.x
	if Input.is_action_pressed("right"):
		input_direction += get_parent().camera.global_transform.basis.x
	if Input.is_action_pressed("jump"):
		is_jumping = true
	input_direction.y = 0
	input_direction = input_direction.normalized()

	db.add_bool(is_jumping)

	var has_input: bool = input_direction.length_squared() > 0.0
	db.add_bool(has_input)
	if has_input:
		db.add_normalized_vector2(Vector2(input_direction.x, input_direction.z), DataBuffer.COMPRESSION_LEVEL_3)


func _controller_process(delta: float, db: DataBuffer):
	# Process the controller.

	# Take the inputs
	var is_jumping = db.read_bool()
	var input_direction := Vector2()

	var has_input = db.read_bool()
	if has_input:
		input_direction = db.read_normalized_vector2(DataBuffer.COMPRESSION_LEVEL_3)

	var initial_transform: Vector3 = get_parent().transform.origin

	# Process the character
	get_parent().step_body(delta, Vector3(input_direction.x, 0.0, input_direction.y), is_jumping)

	var after_transform: Vector3 = get_parent().transform.origin

	var mode = "Client"
	if is_server_controller():
		mode = "Server"

	mode = ""

	#if "player_0" == get_parent().name:
	#	print(get_parent().name, " ", mode, ", Input: ", get_current_input_id(), " Delta: ", delta, " Dir: ", Vector3(input_direction.x, 0.0, input_direction.y), " Jump: ", is_jumping, " - Initial t ", initial_transform, " result t", after_transform)


func _count_input_size(inputs: DataBuffer) -> int:
	# Count the input buffer size.
	var size: int = 0
	size += inputs.get_bool_size()
	inputs.skip_bool()
	size += inputs.get_bool_size()
	if inputs.read_bool():
		size += inputs.get_normalized_vector2_size(DataBuffer.COMPRESSION_LEVEL_3)

	return size


func _are_inputs_different(inputs_A: DataBuffer, inputs_B: DataBuffer) -> bool:
	# Compare two inputs, returns true when those are different or false when are close enough.
	if inputs_A.read_bool() != inputs_B.read_bool():
		return true

	var inp_A_has_i = inputs_A.read_bool()
	var inp_B_has_i = inputs_B.read_bool()
	if inp_A_has_i != inp_B_has_i:
		return true

	if inp_A_has_i:
		var inp_A_dir = inputs_A.read_normalized_vector2(DataBuffer.COMPRESSION_LEVEL_3)
		var inp_B_dir = inputs_B.read_normalized_vector2(DataBuffer.COMPRESSION_LEVEL_3)
		if (inp_A_dir - inp_B_dir).length_squared() > 0.0001:
			return true

	return false


func _collect_epoch_data(buffer: DataBuffer):
	buffer.add_vector3(get_parent().global_transform.origin, DataBuffer.COMPRESSION_LEVEL_0)
	buffer.add_vector3(get_parent().avatar_container.rotation, DataBuffer.COMPRESSION_LEVEL_2)


func _apply_epoch(_delta: float, alpha: float, past_buffer: DataBuffer, future_buffer: DataBuffer):
	var past_position := past_buffer.read_vector3(DataBuffer.COMPRESSION_LEVEL_0)
	var past_rotation := past_buffer.read_vector3(DataBuffer.COMPRESSION_LEVEL_2)

	var future_position := future_buffer.read_vector3(DataBuffer.COMPRESSION_LEVEL_0)
	var future_rotation := future_buffer.read_vector3(DataBuffer.COMPRESSION_LEVEL_2)

	get_parent().global_transform.origin = lerp(past_position, future_position, alpha)
	get_parent().avatar_container.rotation = lerp(past_rotation, future_rotation, alpha)
