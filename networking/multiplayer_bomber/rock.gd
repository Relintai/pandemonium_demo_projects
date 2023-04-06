extends KinematicBody2D

# Sent to everyone else
func do_explosion():
	$"AnimationPlayer".play("explode")


# Received by owner of the rock
func exploded(by_who):
	rpc("do_explosion") # Re-sent to puppet rocks
	$"../../Score".rpc("increase_score", by_who)
	do_explosion()

func _ready():
	rpc_config("do_explosion", MultiplayerAPI.RPC_MODE_PUPPET)
	rpc_config("exploded", MultiplayerAPI.RPC_MODE_MASTER)
