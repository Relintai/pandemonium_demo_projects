extends UserLoginWebPage

var _login_validator : FormValidator = null

#func _render_index(request: WebServerRequest) -> void:
#	request.set_post_parameter("username", request.get_post_parameter("username").to_upper())
#
#	._render_index(request)

func log_login_error(uname_val : String, error_str : String) -> void:
	PLogger.log_error("{0}: User login error! name: \"{1}\", error str: \"{2}\"!".format([ Time.get_datetime_string_from_system(), uname_val, error_str ]))
	printerr("{0}: User login error! name: \"{1}\", error str: \"{2}\"!".format([ Time.get_datetime_string_from_system(), uname_val, error_str]))

func log_login_success(uname_val : String) -> void:
	PLogger.log_error("{0}: User login success! name: \"{1}\"!".format([ Time.get_datetime_string_from_system(), uname_val ]))
	printerr("{0}: User login success! name: \"{1}\"!".format([ Time.get_datetime_string_from_system(), uname_val ]))

func _render_index(request: WebServerRequest) -> void:
	#request.set_post_parameter("username", request.get_post_parameter("username").to_upper())
	
	var error_str : String
	var uname_val : String
	var email_val : String
	var pass_val : String
	var pass_check_val : String

	if (request.get_method() == HTTPServerEnums.HTTP_METHOD_POST):
		var errors : PoolStringArray = _login_validator.validate(request);
		for i in range(errors.size()):
			error_str += errors[i] + "<br>";

		uname_val = request.get_parameter("username")#.to_upper();
		pass_val = request.get_parameter("password");

		var user : User = UserDB.get_user_name(uname_val);

		if (user):
			if (!user.check_password(pass_val)):
				error_str += "Invalid username or password!";
			else:
				var session : HTTPSession = request.get_or_create_session();

				session.add("user_id", user.get_user_id());

				request.get_server().get_session_manager().save_session(session)

				var c : WebServerCookie = WebServerCookie.new()
				c.set_data("session_id", session.get_session_id());
				c.set_path("/");
				c.http_only = true
				c.secure = false
				#c.use_expiry_date = false
				#c.same_site = WebServerCookie.SAME_SITE_LAX
				request.response_add_cookie(c);
				
				log_login_success(uname_val)
				
				emit_signal("user_logged_in", request, user);

				var d : Dictionary = Dictionary()

				d["type"] = "render_login_success";
				d["user"] = user;

				_render_user_page(request, d);

				return;
		else:
			error_str += "Invalid username or password!";
	
	if !error_str.empty():
		log_login_error(uname_val, error_str)
	
	var d : Dictionary = Dictionary()

	d["type"] = "render_login_request_default";
	d["error_str"] = error_str;
	d["uname_val"] = uname_val;
	d["pass_val"] = pass_val;

	_render_user_page(request, d);

func _render_user_page(request: WebServerRequest, data: Dictionary) -> void:
	var type : String = data["type"]

	if type == "render_login_success":
		request.send_redirect(redirect_on_success_url)
		return


	var b : HTMLBuilder = HTMLBuilder.new()

	# Title
	b.div("row mb-4")
	b.div("col-2")
	b.cdiv()

	b.div("col-8")

	b.h2()
	b.w("Login")
	b.ch2()

	b.cdiv()

	b.div("col-2")
	b.cdiv()
	b.cdiv()

	# Errors
	var error_str : String = data["error_str"]

	if !error_str.empty():
		b.div("row mb-4")
		b.div("col-2")
		b.cdiv()

		b.div("col-8")
		b.div("alert alert-danger").attrib("role", "alert")
		b.w(error_str)
		b.cdiv()
		b.cdiv()

		b.div("col-2")
		b.cdiv()
		b.cdiv()

	# Form
	b.div("row")
	b.div("col-2")
	b.cdiv()

	b.div("col-8")

	if true:
		b.form().method_post()
		b.csrf_tokenr(request)

		b.div("form-group")
		b.label().fora("username_input").cls("form_label").f().w("Username").clabel()
		b.input_text("username", data["uname_val"], "", "form-control", "username_input")
		b.cdiv()

		b.div("form-group")
		b.label().fora("password_input").cls("form_label").f().w("Password").clabel()
		b.input_password("password", "", "*******", "form-control", "password_input")
		b.cdiv()
			
		b.button().type("submit").cls("btn btn-outline-primary mt-3").f().w("Send").cbutton()

		b.cform()

	b.cdiv()

	b.div("col-2")
	b.cdiv()
	b.cdiv()

	b.write_tag()
	request.body += b.result
	request.compile_and_send_body()

func _ready() -> void:
	_login_validator = FormValidator.new()

	_login_validator.new_field("username", "Username").need_to_exist().need_to_be_alpha_numeric().need_minimum_length(5).need_maximum_length(20);

	var pw : FormField = _login_validator.new_field("password", "Password");
	pw.need_to_exist();
	pw.need_to_have_lowercase_character().need_to_have_uppercase_character();
	pw.need_minimum_length(5);

