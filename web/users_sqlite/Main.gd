
extends Node

export(String) var database_location : String = "user://database.sqlite"

func _ready() -> void:
	var d : Directory = Directory.new()
	var bd : String = database_location.get_base_dir()
	var loc : String = d.get_filesystem_abspath_for(bd).append_path(database_location.get_file())
	
	var file : File = File.new()
	if !file.file_exists(loc):
		PLogger.log_message("Database file doesn't exists, will run migrations!")
		call_deferred("migrate")
	else:
		call_deferred("db_initialized")

	var db : SQLite3Database = SQLite3Database.new()
	db.connection_string = loc
	DatabaseManager.add_database(db)
	

func migrate() -> void:
	PLogger.log_message("Running migrations!")
	DatabaseManager.connect("migration", self, "_migration")
	DatabaseManager.migrate(true, false, 0)
	
	call_deferred("db_initialized")
	
func db_initialized() -> void:
	DatabaseManager.initialized()

func _migration(clear: bool, should_seed: bool, pseed: int) -> void:
	#create admin account
	pass
