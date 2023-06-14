extends WebRoot

export(String, MULTILINE) var menu_str : String

func _render_main_menu(request: WebServerRequest) -> void:
	# You can render the menu differently for logged in users for example
	# The middlewares will run before routing (in order they are in the middlewares property)
	request.body += menu_str

	# The UserSessionSetupWebServerMiddleware makes this available here:
	# If you want to do this manually, you can do it via request.session + the UserDB singleton
	# I recommend looking at the middleware code on the engine c++ side to see an example
	var user : User = request.get_meta("user")
	
	if user:
		request.body += "You are logged in as : " + user.user_name + ".<br><br>"
	else:
		request.body += "You are not logged in.<br><br>"
