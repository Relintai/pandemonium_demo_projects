extends KinematicBody2D

const MOTION_SPEED = 90.0

var puppet_pos = Vector2()
var puppet_motion = Vector2()

export var stunned = false

# Use sync because it will be called everywhere
func setup_bomb(bomb_name, pos, by_who):
	var bomb = preload("res://bomb.tscn").instance()
	bomb.set_name(bomb_name) # Ensure unique name for the bomb
	bomb.position = pos
	bomb.from_player = by_who
	# No need to set network master to bomb, will be owned by server by default
	get_node("../..").add_child(bomb)

var current_anim = ""
var prev_bombing = false
var bomb_index = 0


func _physics_process(_delta):
	var motion = Vector2()

	if is_network_master():
		if Input.is_action_pressed("move_left"):
			motion += Vector2(-1, 0)
		if Input.is_action_pressed("move_right"):
			motion += Vector2(1, 0)
		if Input.is_action_pressed("move_up"):
			motion += Vector2(0, -1)
		if Input.is_action_pressed("move_down"):
			motion += Vector2(0, 1)

		var bombing = Input.is_action_pressed("set_bomb")

		if stunned:
			bombing = false
			motion = Vector2()

		if bombing and not prev_bombing:
			var bomb_name = String(get_name()) + str(bomb_index)
			var bomb_pos = position
			rpc("setup_bomb", bomb_name, bomb_pos, get_tree().get_network_unique_id())

		prev_bombing = bombing

		rpc("set_puppet_motion", motion)
		rpc("set_puppet_pos", position)
	else:
		position = puppet_pos
		motion = puppet_motion

	var new_anim = "standing"
	if motion.y < 0:
		new_anim = "walk_up"
	elif motion.y > 0:
		new_anim = "walk_down"
	elif motion.x < 0:
		new_anim = "walk_left"
	elif motion.x > 0:
		new_anim = "walk_right"

	if stunned:
		new_anim = "stunned"

	if new_anim != current_anim:
		current_anim = new_anim
		get_node("anim").play(current_anim)

	# FIXME: Use move_and_slide
	move_and_slide(motion * MOTION_SPEED)
	if not is_network_master():
		puppet_pos = position # To avoid jitter


func stun():
	stunned = true


func exploded(_by_who):
	if stunned:
		return
	rpc("stun") # Stun puppets
	stun() # Stun master - could use sync to do both at once


func set_player_name(new_name):
	get_node("label").set_text(new_name)


func set_puppet_pos(pos):
	puppet_pos = pos

func set_puppet_motion(pos):
	puppet_motion = pos

func _ready():
	stunned = false
	puppet_pos = position
	
	rpc_config("set_puppet_pos", MultiplayerAPI.RPC_MODE_PUPPET)
	rpc_config("set_puppet_motion", MultiplayerAPI.RPC_MODE_PUPPET)
	rpc_config("setup_bomb", MultiplayerAPI.RPC_MODE_REMOTESYNC)
	rpc_config("stun", MultiplayerAPI.RPC_MODE_PUPPET)
	rpc_config("exploded", MultiplayerAPI.RPC_MODE_MASTER)
