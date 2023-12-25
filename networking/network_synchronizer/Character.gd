extends KinematicBody

# ----------------------------------------------------------------------------------------- Settings
const MOVE_SPEED: int = 10
const MOTION_INTERPOLATE_SPEED: int = 20
const VELOCITY_INTERPOLATE_SPEED: int = 2
const GRAVITY: int = 10
const JUMP_IMPULSE: float = 6.0


# --------------------------------------------------------------------------------------------- Vars
onready var avatar_container: Spatial = $AvatarContainer
onready var _mesh: MeshInstance = $AvatarContainer/Mesh
var linear_velocity := Vector3()
onready var camera: Camera = $Camera
var on_floor: bool = false


# ---------------------------------------------------------------------------------------------- API
func set_color(color):
	var mat = _mesh.get_surface_material(0)
	if mat == null:
		mat = SpatialMaterial.new()
	else:
		mat = mat.duplicate()
	mat.set_albedo(Color(color))
	_mesh.set_surface_material(0, mat)


func update_safe_body_transform():
	$KinematicBody.transform = transform


# ------------------------------------------------------------------------------------ Notifications
func _ready():
	## Avoid colliding with parent
	$KinematicBody.add_collision_exception_with(self)

	if "player_0" == name:
		$KinematicBody.collision_layer = 0
		$KinematicBody.collision_mask = 0
	
	$AvatarContainer.physics_interpolation_mode = PHYSICS_INTERPOLATION_MODE_ON


# ------------------------------------------------------------------------------ Processing internal
## Computes one motion step.
func step_body(delta: float, input_direction: Vector3, is_jumping: bool):
	_set_player_orientation(input_direction)

	var motion: Vector3 = input_direction * MOVE_SPEED
	var new_velocity: Vector3

	if on_floor and linear_velocity.length() < MOVE_SPEED:
		new_velocity = linear_velocity.linear_interpolate(motion, MOTION_INTERPOLATE_SPEED * delta)
		if is_jumping:
			new_velocity.y = new_velocity.y + JUMP_IMPULSE
	else:
		new_velocity = linear_velocity.linear_interpolate(motion, VELOCITY_INTERPOLATE_SPEED * delta)
		new_velocity.y = new_velocity.y - GRAVITY * delta

	if new_velocity.length() > 0.01:
		linear_velocity = move_and_slide(new_velocity, Vector3(0, 1, 0))
		on_floor = is_on_floor()


func _set_player_orientation(input_direction):
	if input_direction.length_squared() < 0.01:
		return
	avatar_container.transform = avatar_container.transform.looking_at(input_direction, Vector3(0, 1, 0))
