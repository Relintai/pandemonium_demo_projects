extends WebRoot

export(String, MULTILINE) var menu_text : String

func _render_main_menu(request: WebServerRequest) -> void:
	request.body += menu_text
