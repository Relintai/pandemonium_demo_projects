extends WebNode

export(bool) var render_back_arrow : bool = true
export(String) var serve_folder : String

enum EditActions {
	UPLOAD = 0,
	DELETE,
	CREATE_FOLDER,
	DELETE_FOLDER,
	#RENAME, TODO
}

class BFSNEntry:
	var uri : String
	var data : String

var _folder_indexes : Array
var _folder_uris : PoolStringArray
var _index : String

var _file_cache : FileCache = FileCache.new()

var _lock : RWLock = RWLock.new()

func _ready():
	var dir : Directory = Directory.new()
	
	if !dir.dir_exists(serve_folder):
		dir.make_dir_recursive(serve_folder)
	
	load_dir()

func _handle_request_main(request : WebServerRequest) -> void:
	if (web_permission):
		if (web_permission.activate(request)):
			return;
	
	if request.get_method() == HTTPServerEnums.HTTP_METHOD_POST:
		var folder_name : String = request.get_path(true, false);
		
		if !_folder_uris.contains(folder_name):
			PLogger.log_error("!_folder_uris.contains(folder_name) ! '{0}'".format([ folder_name ]))
			request.send_error(HTTPServerEnums.HTTP_STATUS_CODE_500_INTERNAL_SERVER_ERROR)
			return
		
		var action : int = int(request.get_post_parameter("action"))
		
		if action == EditActions.UPLOAD:
			var file_name : String = request.get_file_file_name(0)
			
			if file_name.empty():
				PLogger.log_error("file_name.empty()!")
				request.send_error(HTTPServerEnums.HTTP_STATUS_CODE_500_INTERNAL_SERVER_ERROR)
				return
			
			var www_file_path : String = folder_name.append_path(file_name)
			var tfp : String = _file_cache.wwwroot_get_simplified_abs_path(www_file_path)
			
			if tfp.empty():
				PLogger.log_error("tfp.empty()! " + www_file_path)
				request.send_error(HTTPServerEnums.HTTP_STATUS_CODE_500_INTERNAL_SERVER_ERROR)
				return
			
			request.move_file(0, tfp)

			load_dir()
		elif action == EditActions.CREATE_FOLDER:
			var new_folder_name : String = request.get_post_parameter("folder")
			
			if !new_folder_name.empty():
				var www_file_path : String = folder_name.append_path(new_folder_name)
				var full_path : String = _file_cache.wwwroot_get_simplified_abs_path(www_file_path)

				if full_path.empty():
					PLogger.log_error("full_path.empty()!")
					request.send_error(HTTPServerEnums.HTTP_STATUS_CODE_500_INTERNAL_SERVER_ERROR)
					return
				
				var d : Directory = Directory.new()
				d.make_dir_recursive(full_path)
				load_dir()
		elif action == EditActions.DELETE_FOLDER:
			var folder : String = request.get_post_parameter("folder")
			var folder_uri : String = folder_name.append_path(folder)
			
			if !_folder_uris.contains(folder_uri):
				PLogger.log_error("!folder.contains(folder_name) ! '{0}'".format([ folder_uri ]))
				request.send_error(HTTPServerEnums.HTTP_STATUS_CODE_500_INTERNAL_SERVER_ERROR)
				return
			
			if !folder.empty():
				var full_path : String = serve_folder.append_path(folder_uri)
				
				if full_path.empty():
					PLogger.log_error("full_path.empty()!")
					request.send_error(HTTPServerEnums.HTTP_STATUS_CODE_500_INTERNAL_SERVER_ERROR)
					return
					
				var d : Directory = Directory.new()
				d.remove(full_path)
				load_dir()
		elif action == EditActions.DELETE:
			var file : String = request.get_post_parameter("file")
			var file_uri_path : String = folder_name.append_path(file)
			
			_lock.read_lock()
			if !_file_cache.wwwroot_has_file(file_uri_path):
					_lock.read_unlock()
					PLogger.log_error("!_file_cache.wwwroot_has_file(file_uri_path)")
					request.send_error(HTTPServerEnums.HTTP_STATUS_CODE_500_INTERNAL_SERVER_ERROR)
					return
			_lock.read_unlock()

			if !file_uri_path.empty():
				var full_path : String = serve_folder.append_path(file_uri_path)
				
				if full_path.empty():
					PLogger.log_error("full_path.empty()!")
					request.send_error(HTTPServerEnums.HTTP_STATUS_CODE_500_INTERNAL_SERVER_ERROR)
					return
					
				var d : Directory = Directory.new()
				d.remove(full_path)
				load_dir()
	
	var rp : String = request.get_current_path_segment();

	if (rp.empty()):
		handle_request(request);
		return;

	var file_name : String = request.get_path(true, false);
	file_name = file_name.to_lower();
	
	var fabspath : String = _file_cache.wwwroot_get_file_abspath(file_name)

	if (!fabspath.empty()):
		request.send_file(fabspath);
		
		return;

	if (!try_route_request_to_children(request)):
		handle_request(request);

func _handle_request(request : WebServerRequest):
	var file_name : String = request.get_path(true, false);

	_lock.read_lock()

	for e in _folder_indexes:
		if (e.uri == file_name):
			render_menu(request);
			
			if render_back_arrow:
				var b : HTMLBuilder = HTMLBuilder.new()
				
				b.div("row mb-4")
				b.div("col-2")
				b.cdiv()
					
				b.div("col-8 pt-2 pb-2 panel_content")
				
				b.h4()
				b.a(get_full_uri_parent()).f().w("<--- back").ca()
				b.ch4()
				
				b.cdiv()
				
				b.div("col-2")
				b.cdiv()
				b.cdiv()
				
				b.write_tag()
				
				request.body += b.result

			request.body += e.data.replace("%%csrf_token", request.get_csrf_token());
			request.compile_and_send_body();
			
			_lock.read_unlock()
			
			return;
			
	_lock.read_unlock()

	request.send_error(HTTPServerEnums.HTTP_STATUS_CODE_404_NOT_FOUND);

func load_dir() -> void:
	_lock.write_lock()
	
	_folder_indexes.clear()
	_folder_uris.clear()
	
	_file_cache.clear();

	if (serve_folder.empty()):
		_file_cache.set_wwwroot(serve_folder);
		_file_cache.clear();
	else:
		_file_cache.set_wwwroot(serve_folder);
		evaluate_dir(_file_cache.get_wwwroot_abs(), true);
	
	_lock.write_unlock()

func evaluate_dir(path : String, top_level : bool = false) -> void:
	var dir : Directory = Directory.new()
	dir.open(path)
	
	var serve_folder : String = _file_cache.get_wwwroot_abs();

	var dir_uri : String

	if (!top_level):
		dir_uri = path.substr(serve_folder.length(), path.length() - serve_folder.length());
	else:
		dir_uri = "/";
		
	_folder_uris.push_back(dir_uri)

	var folders : PoolStringArray = PoolStringArray()
	var files : PoolStringArray = PoolStringArray()

	dir.list_dir_begin(true);

	var file : String = dir.get_next();

	while !file.empty():
		var np : String = path.append_path(file);
		var nnp : String = np.substr(serve_folder.length(), np.length() - serve_folder.length());

		if (dir.current_is_dir()):
			folders.push_back(nnp);
			evaluate_dir(np);
		else:
			files.push_back(nnp);

		file = dir.get_next();

	dir.list_dir_end();

	folders.sort();
	files.sort();

	render_dir_page(dir_uri, folders, files, top_level);


func render_dir_page(dir_uri : String, folders : PoolStringArray, files : PoolStringArray, top_level : bool) -> void:
	var b : HTMLBuilder = HTMLBuilder.new()

	var uri : String = get_full_uri(false);
		
	if uri == "/":
		uri = ""

	#b.div("file_list");
	if true:
		if (!top_level):
			b.div("row").f().div("col-2").f().cdiv().div("col-8 pt-2 pb-2 panel_content")
			if true:
				b.a(uri + dir_uri.path_get_prev_dir()).f().w("..").ca();
			b.cdiv().div("col-2").f().cdiv().cdiv()
		

		for i in range(folders.size()):
			b.div("row").f().div("col-2").f().cdiv().div("col-8 pt-2 pb-2 panel_content")
			if true:
				b.form_post(uri + dir_uri, "form-inline")
				
				b.div("mr-5")
				b.a(uri + folders[i]).f().w("(Folder) ").w(folders[i].get_file()).ca();
				b.cdiv()
				
				if true:
					b.csrf_token("%%csrf_token")
					b.input_hidden("action", str(EditActions.DELETE_FOLDER))
					b.input_hidden("folder", folders[i].get_file())
					b.input_submit("X")
				b.cform()
			b.cdiv().div("col-2").f().cdiv().cdiv()
		

		for i in range(files.size()):
			b.div("row").f().div("col-2").f().cdiv().div("col-8 pt-2 pb-2 panel_content")
			if true:
				b.form_post(uri + dir_uri, "form-inline")
				
				b.div("mr-5")
				b.a(uri + files[i]).f().w("(File) ").w(files[i].get_file()).ca();
				b.cdiv()
				
				if true:
					b.csrf_token("%%csrf_token")
					b.input_hidden("action", str(EditActions.DELETE))
					b.input_hidden("file", files[i].get_file())
					b.input_submit("X")
				b.cform()
			b.cdiv().div("col-2").f().cdiv().cdiv()
			
		if folders.size() == 0 && files.size() == 0:
			b.div("row").f().div("col-2").f().cdiv().div("col-8 pt-2 pb-2 panel_content")
			if true:
				b.w("Directory is empty.")
			b.cdiv().div("col-2").f().cdiv().cdiv()
	
	#b.cdiv();
	
	b.div("row mt-4").f().div("col-2").f().cdiv().div("col-8 pt-2 pb-2 panel_content")
	b.w("Upload new file")
	b.cdiv().div("col-2").f().cdiv().cdiv()
	
	b.div("row").f().div("col-2").f().cdiv().div("col-8 pt-2 pb-2")
	b.form_post(uri + dir_uri).enctype_multipart_form_data()
	if true:
		b.csrf_token("%%csrf_token")
		b.input_hidden("action", str(EditActions.UPLOAD))
		b.input_file("file")
		b.input_submit("Upload")
	b.cform()
	b.cdiv().div("col-2").f().cdiv().cdiv()
	
	b.div("row mt-4").f().div("col-2").f().cdiv().div("col-8 pt-2 pb-2 panel_content")
	b.w("Create new folder")
	b.cdiv().div("col-2").f().cdiv().cdiv()
	
	b.div("row").f().div("col-2").f().cdiv().div("col-8 pt-2 pb-2")
	b.form_post(uri + dir_uri)
	if true:
		b.csrf_token("%%csrf_token")
		b.input_hidden("action", str(EditActions.CREATE_FOLDER))
		b.input_text("folder")
		b.input_submit("Create")
	b.cform()
	b.cdiv().div("col-2").f().cdiv().cdiv()
	
	b.write_tag()

	var e : BFSNEntry = BFSNEntry.new()
	e.uri = dir_uri;
	e.data = b.result;

	_folder_indexes.push_back(e);

	if (dir_uri == "/"):
		_index = b.result;

