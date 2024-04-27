extends Node

export(String) var database_location : String = "user://database.sqlite"

func _ready() -> void:
	DatabaseManager.connect("initialized", self, "on_databases_initialized", [], CONNECT_ONESHOT)
	
	var d : Directory = Directory.new()
	var bd : String = database_location.get_base_dir()
	var loc : String = d.get_filesystem_abspath_for(bd).append_path(database_location.get_file())
	
	PLogger.log_message("Database file location: " + loc)
	PLogger.log_message("(Editor->Project->Open User Data Folder)")
	
	var file : File = File.new()
	if !file.file_exists(loc):
		PLogger.log_message("Database file doesn't exists, will run migrations!")
		PLogger.log_message("(Editor->Project->Open User Data Folder)")
		call_deferred("migrate")
	else:
		DatabaseManager.call_deferred("initialized")

	var db : SQLite3Database = SQLite3Database.new()
	db.connection_string = loc
	DatabaseManager.add_database(db)

func migrate() -> void:
	PLogger.log_message("Running migrations!")
	DatabaseManager.connect("migration", self, "_migration")
	DatabaseManager.migrate(true, false, 0)
	
	DatabaseManager.call_deferred("initialized")

func on_databases_initialized() -> void:
	# Load sessions after the databases are initialized
	# This happens on the Main node.
	call_deferred("load_data")

func _migration(clear: bool, should_seed: bool, pseed: int) -> void:
	randomize()
	
	var tb : TableBuilder = DatabaseManager.ddb.get_connection().get_table_builder()
	
	tb.create_table("data_table");
	tb.integer("id").auto_increment().next_row();
	tb.varchar("data_varchar", 60).not_null().next_row();
	tb.text("data_text").not_null().next_row();
	tb.integer("data_int").not_null().next_row();
	tb.real_double("data_double").not_null().next_row();
	tb.primary_key("id");
	tb.ccreate_table();
	tb.run_query();
	
	print("Running:")
	print(tb.result)
	
	var qb : QueryBuilder = DatabaseManager.ddb.get_connection().get_query_builder()
	
	for i in range(10):
		qb.reset()
		
		qb.insert("data_table", "data_varchar,data_text,data_int,data_double").values()
		qb.vals("vc" + str(randi()))
		qb.vals("text" + str(randi()))
		qb.vali(randi())
		qb.vald(randf() * 100000)
		qb.cvalues()
		qb.end_command()
		
		qb.run_query()
		
		print("Running:")
		print(qb.result)

func load_data() -> void:
	print("Querying data from table:")
	
	var qb : QueryBuilder = DatabaseManager.ddb.get_connection().get_query_builder()
	
	var qr : QueryResult = qb.select("id,data_varchar,data_text,data_int,data_double").from("data_table").run()
	
	while qr.next_row():
		print("ROW:")
		print("id: " + str(qr.get_cell_int(0)))
		print("data_varchar: " + str(qr.get_cell(1)))
		print("data_text: " + str(qr.get_cell(2)))
		print("data_int: " + str(qr.get_cell_int(3)))
		print("data_double: " + str(qr.get_cell_double(4)))
