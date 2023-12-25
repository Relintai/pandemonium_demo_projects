extends Node

# ----------------------------------------------------------------------------------------- Settings
const SERVER_PORT = 2000
const MAX_PLAYERS = 5
const SERVER_IP = "127.0.0.1"
const COLORS_LIST = [
	"#0ad609",
	"#f0bf58",
	"#1120d3",
	"#704c28",
	"#2af4ce"
]


# --------------------------------------------------------------------------------------------- Vars
onready var _menu: Control = $Menu
onready var _session_type_lbl: Label = $SessionTypeLbl

var _player_id_counter = 0
var _players = {}


# ------------------------------------------------------------------------------------- UI functions
func _start_server():
	_menu.hide()
	_session_type_lbl.text = "Server"

	var peer = NetworkedMultiplayerENet.new()
	peer.create_server(SERVER_PORT, MAX_PLAYERS)
	get_tree().network_peer = peer
	get_tree().connect("network_peer_connected", self, "_on_client_connected")
	get_tree().connect("network_peer_disconnected", self, "_on_client_disconnected")
	print("Server IP: ", IP.get_local_addresses())


func _start_client():
	_menu.hide()
	_session_type_lbl.text = "Client"

	var peer = NetworkedMultiplayerENet.new()
	peer.create_client(SERVER_IP, SERVER_PORT)
	get_tree().network_peer = peer


# ------------------------------------------------------------------- Server only internal functions
func _on_client_connected(peer_id):
	print("Connected: ", peer_id)
	var new_player_id = _player_id_counter
	_player_id_counter += 1
	_players[new_player_id] = {"peer_id": peer_id, "player_id": new_player_id}

	# Spawn player on server, for server any player is puppet (even if it's
	# autoritative)
	_spawn_new_player(new_player_id, peer_id)

	# Spawn the player on the client
	rpc_id(peer_id, "_spawn_new_player", new_player_id, peer_id)

	# Tell anyone new player appeared
	for player_id in _players.keys():
		if _players[player_id]["peer_id"] != peer_id:
			rpc_id(_players[player_id]["peer_id"], "_spawn_new_player", new_player_id, 1)

	# Spawn the actual _players on this client
	for player_id in _players.keys():
		if player_id != new_player_id:
			rpc_id(peer_id, "_spawn_new_player", player_id, 1)


func _on_client_disconnected(peer_id):
	print("Disconnected: ", peer_id)

	var disconnected_player_id = -1
	for player_id in _players.keys():
		if _players[player_id]["peer_id"] == peer_id:
			disconnected_player_id = player_id
			break

	if disconnected_player_id == -1:
		return

	_players.erase(disconnected_player_id)
	_remove_player(disconnected_player_id)

	# Tell anyone player disappeared
	for player_id in _players.keys():
		rpc_id(_players[player_id]["peer_id"], "_remove_player", disconnected_player_id)


# --------------------------------------------------------------------------------- Remote functions
func _spawn_new_player(player_id, peer_id):
	print("Spawn player id: ", player_id, ", Peer_id: ", peer_id)
	print("While my peer id is: ", get_tree().multiplayer.network_peer.get_unique_id())

	var character = load("res://Character.tscn").instance()
	character.set_network_master(peer_id)
	character.set_name("player_" + str(player_id))
	get_tree().get_current_scene().add_child(character)
	character.set_color(COLORS_LIST[player_id])


func _remove_player(player_id):
	var player_node = get_tree().get_current_scene().get_node("player_" + str(player_id))
	if player_node != null:
		player_node.queue_free()


func _ready() -> void:
	rpc_config(@"_spawn_new_player", MultiplayerAPI.RPC_MODE_REMOTE)
	rpc_config(@"_remove_player", MultiplayerAPI.RPC_MODE_REMOTE)
	
