extends HTTPSessionManagerDB

func _ready() -> void:
	DatabaseManager.connect("initialized", self, "on_databases_initialized", [], CONNECT_ONESHOT)
	# You could also connect to the migration signal, and write migrations if you need them

func on_databases_initialized() -> void:
	# Load sessions after the databases are initialized
	# This happens on the Main node.
	call_deferred("load_sessions")
