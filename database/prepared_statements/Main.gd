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
	qb.insert("data_table", "data_varchar,data_text,data_int,data_double").values()
	qb.valph().valph().valph().valph()
	qb.cvalues()
	qb.end_command()
	print("Prepared statement:")
	print(qb.result)
	
	var ps : PreparedStatement = qb.create_prepared_statement()
	ps.prepare()
	
	print("Inserting 10 values!")
	
	for i in range(10):
		ps.reset()
		
		ps.bind_text(1, "vc" + str(randi()))
		ps.bind_text(2, "text" + str(randi()))
		ps.bind_int(3, randi())
		ps.bind_double(4, randf() * 100000)
		ps.step()
		


func load_data() -> void:
	print("Querying data from table using prepared statements:")
	
	var qb : QueryBuilder = DatabaseManager.ddb.get_connection().get_query_builder()
	
	var qr : QueryResult = qb.select("id").from("data_table").run()
		
	var ids : PoolIntArray = PoolIntArray()
	
	while qr.next_row():
		ids.push_back(qr.get_cell_int(0))
	
	qb.reset()
	
	qb.select("id,data_varchar,data_text,data_int,data_double").from("data_table")
	qb.where().wph("id")
	qb.end_command()
	print("Query prepared statement:")
	print(qb.result)
	
	var ps : PreparedStatement = qb.create_prepared_statement()
	ps.prepare()
	
	print("Querying rows one by one:")
	for index in ids:
		ps.reset()
		
		ps.bind_int(1, index)
		ps.step()
		
		print("ps.column_count(): " + str(ps.column_count()))
		print("id: " + str(ps.column_int(0)))
		print("data_varchar: " + str(ps.column_text(1)))
		print("data_text: " + str(ps.column_text(2)))
		print("data_int: " + str(ps.column_int(3)))
		print("data_double: " + str(ps.column_double(4)))






