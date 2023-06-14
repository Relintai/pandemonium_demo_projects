extends StaticWebPage


func _handle_request(request: WebServerRequest) -> void:
	# Render the menu
	# This is rendered in the WebRoot node's _render_main_menu method
	render_menu(request)
	
	request.body += "Scripted Test Page"

	request.compile_and_send_body()
