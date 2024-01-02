# Run this script like: /pandemonium -s static_serve.gd test_site_1

#extends Node
extends SceneTree
class_name StaticServe

var web_server_simple : WebServerSimple = null

func process_data_folder(path : String, uri_segment : String, parent_web_node : WebNode) -> void:
	var dir : Directory = Directory.new()
	var f : File = File.new()
	
	var index_page_path : String = path + "index.html"
	
	var has_index_page : bool = dir.file_exists(index_page_path)
	var current_node : WebNode = null
	
	if has_index_page:
		var wr : StaticWebPageFile = StaticWebPageFile.new()
		wr.file_path = index_page_path
		current_node = wr
	else:
		var wr : StaticWebPage = StaticWebPage.new()
		current_node = wr
		
	current_node.uri_segment = uri_segment
	parent_web_node.add_child(current_node)
	
	if dir.open(path) == OK:
		dir.list_dir_begin(true)
		var file_name = dir.get_next()
		while file_name != "":
			if dir.current_is_dir():
				process_data_folder(path + file_name + "/", file_name, current_node)
			else:
				if file_name == "index.html":
					file_name = dir.get_next()
					continue
				
				var wp : StaticWebPageFile = StaticWebPageFile.new()
				wp.file_path = path + file_name
				wp.uri_segment = file_name.replace(".html", "")
				current_node.add_child(wp)
				
			file_name = dir.get_next()
		dir.list_dir_end()

func setup():
	OS.low_processor_usage_mode = true
	
	var project_path : String = "./"
	
	var cmdline_args : PoolStringArray = OS.get_cmdline_args()
	
	if cmdline_args.size() > 0:
		project_path = cmdline_args[cmdline_args.size() - 1].path_ensure_end_slash()
	
	var dir : Directory = Directory.new()

	var www_root_path : String = project_path + "www_root"
	var index_page_path : String = project_path + "index.html"
	
	if !dir.dir_exists(project_path):
		PLogger.log_error("Error project directory doens't seems to exist! " + project_path)
		# If Node
		#get_tree().quit(-1)
		# If SceneTree
		quit(-1)
		return
	
	var has_www_root_folder : bool = dir.dir_exists(www_root_path)
	var has_index_page : bool = dir.file_exists(index_page_path)
	var web_root : WebNode = null
	
	if has_www_root_folder:
		var wr : WebRoot = WebRoot.new()
		wr.www_root_path = www_root_path
		web_root = wr
		
		if has_index_page:
			var index : StaticWebPageFile = StaticWebPageFile.new()
			index.file_path = index_page_path
			index.uri_segment = "/"
			web_root.add_child(index)
	else:
		if has_index_page:
			var wr : StaticWebPageFile = StaticWebPageFile.new()
			wr.file_path = index_page_path
			web_root = wr
		else:
			var wr : StaticWebPage = StaticWebPage.new()
			web_root = wr

	if dir.open(project_path) == OK:
		dir.list_dir_begin(true)
		var file_name = dir.get_next()
		while file_name != "":
			if dir.current_is_dir():
				if file_name == "www_root":
					file_name = dir.get_next()
					continue
					
				process_data_folder(project_path + file_name + "/", file_name, web_root)
			else:
				if file_name == "index.html":
					file_name = dir.get_next()
					continue
				
				var wp : StaticWebPageFile = StaticWebPageFile.new()
				wp.file_path = project_path + file_name
				wp.uri_segment = file_name.replace(".html", "")
				web_root.add_child(wp)
				
			file_name = dir.get_next()
		dir.list_dir_end()
	 
	web_server_simple = WebServerSimple.new()
	web_server_simple.start_on_ready = true
	web_server_simple.add_child(web_root)


# If it's a Node
#func _ready() -> void:
#	setup()
#	add_child(web_server_simple)

# If it's a SceneTree
func _initialize():
	setup()
	root.add_child(web_server_simple)
	
	var link0 : String = "http://" + web_server_simple.bind_host + ":" + str(web_server_simple.bind_port)
	var link1 : String = "http://127.0.0.1:" + str(web_server_simple.bind_port)
	
	var run_text : String = "Running server on: " + link1 + " (" + link0 + ")"

	PLogger.log_message(run_text)
	
	#For the lolz
	var pc : PanelContainer = PanelContainer.new()
	root.add_child(pc)
	pc.set_anchors_and_margins_preset(Control.PRESET_WIDE)
	
	var cc : CenterContainer = CenterContainer.new()
	pc.add_child(cc)
	
	var lb : LinkButton = LinkButton.new()
	cc.add_child(lb)
	lb.uri = link1
	lb.text = run_text

