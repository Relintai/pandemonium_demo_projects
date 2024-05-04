extends WebRoot

var markdown_renderer : MarkdownRenderer = null

func serve_md(request: WebServerRequest) -> void:
	var path : String = request.get_path_full()
	
	var fabs : String = www_root_file_cache.wwwroot_get_file_abspath(path)
	
	if fabs == "":
		request.send_error(HTTPServerEnums.HTTP_STATUS_CODE_404_NOT_FOUND)
		return
		
	var f : File = File.new()
	if f.open(fabs, File.READ) != OK:
		request.send_error(HTTPServerEnums.HTTP_STATUS_CODE_404_NOT_FOUND)
		return
	
	request.body += markdown_renderer.render(f.get_as_text())
	
	f.close()
	
	request.compile_and_send_body()

func _handle_request_main(request: WebServerRequest) -> void:

	if request.get_path_full().ends_with(".md"):
		serve_md(request)
		return

	._handle_request_main(request)

func _ready() -> void:
	markdown_renderer = MarkdownRenderer.new()
