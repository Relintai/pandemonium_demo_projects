extends UserRegisterWebPage

var _registration_validator : FormValidator = null

func log_registration_error(uname_val : String, email_val : String, error_str : String) -> void:
	PLogger.log_error("{0}: User registration error! name: \"{1}\", email: \"{2}\", error str: \"{3}\"!".format([ Time.get_datetime_string_from_system(), uname_val, email_val, error_str ]))
	printerr("{0}: User registration error! name: \"{1}\", email: \"{2}\", error str: \"{3}\"!".format([ Time.get_datetime_string_from_system(), uname_val, email_val, error_str]))

func log_registration_success(uname_val : String, email_val : String) -> void:
	PLogger.log_error("{0}: User registration success! name: \"{1}\", email: \"{2}\"!".format([ Time.get_datetime_string_from_system(), uname_val, email_val ]))
	printerr("{0}: User registration success! name: \"{1}\", email: \"{2}\"!".format([ Time.get_datetime_string_from_system(), uname_val, email_val ]))

func _render_index(request: WebServerRequest) -> void:
	var error_str : String
	var uname_val : String
	var email_val : String
	var pass_val : String
	var pass_check_val : String

	if (request.get_method() == HTTPServerEnums.HTTP_METHOD_POST):
		var errors : PoolStringArray = _registration_validator.validate(request);

		for i in range(errors.size()):
			error_str += errors[i] + "<br>";

		uname_val = request.get_parameter("username");
		
		#uname_val = uname_val.to_upper()
		email_val = request.get_parameter("email");
		pass_val = request.get_parameter("password");
		pass_check_val = request.get_parameter("password_check");

		# todo username length etc check
		# todo pw length etc check
		
		if (UserDB.is_username_taken(uname_val)):
			error_str += "Username already taken!<br>";

		if (UserDB.is_email_taken(email_val)):
			error_str += "Email already in use!<br>";

		if (pass_val != pass_check_val):
			error_str += "The passwords did not match!<br>";

		if (error_str.empty()):
			var user : User = null
			user = UserDB.create_user();

			user.set_user_name(uname_val);
			user.set_email(email_val);

			user.create_password(pass_val);
			user.save();

			emit_signal("user_registered", request, user);

			var d : Dictionary = Dictionary()

			d["type"] = "render_register_success";
			d["user"] = user;
			
			log_registration_success(uname_val, email_val)
			
			_render_user_page(request, d);

			return;
		else:
			log_registration_error(uname_val, email_val, error_str)

	var d : Dictionary = Dictionary()

	d["type"] = "render_register_request_default";
	d["error_str"] = error_str;
	d["uname_val"] = uname_val;
	d["email_val"] = email_val;
	d["pass_val"] = pass_val;
	d["pass_check_val"] = pass_check_val;

	_render_user_page(request, d);

func _render_user_page(request: WebServerRequest, data: Dictionary) -> void:
	if data["type"] == "render_register_success":
		render_register_success(request, data)
		return
		
	render_register_default(request, data)
	
	
func render_register_success(request: WebServerRequest, data: Dictionary) -> void:
	var b : HTMLBuilder = HTMLBuilder.new()
	
	# Title
	b.div("row mb-4")
	b.div("col-2")
	b.cdiv()
		
	b.div("col-8")
	
	b.h2()
	b.w("Registration successful!")
	b.ch2()
	
	b.cdiv()
	
	b.div("col-2")
	b.cdiv()
	b.cdiv()
	
	# msg
	b.div("row")
	b.div("col-2")
	b.cdiv()
		
	b.div("col-8")
	b.w("Login Here:").br()
	b.br()
	b.a(redirect_on_success_url)
	b.w(">> Login <<")
	b.ca()
	b.cdiv()
	
	b.div("col-2")
	b.cdiv()
	b.cdiv()
	
	b.write_tag()
	request.body += b.result
	request.compile_and_send_body()

	
func render_register_default(request: WebServerRequest, data: Dictionary) -> void:
	var b : HTMLBuilder = HTMLBuilder.new()
	
	# Title
	b.div("row mb-4")
	b.div("col-2")
	b.cdiv()
		
	b.div("col-8")
	
	b.h2()
	b.w("Registration")
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
		b.label().fora("email_input").cls("form_label").f().w("Email").clabel()
		b.input_text("email", data["email_val"], "", "form-control", "email_input")
		b.cdiv()

		b.div("form-group")
		b.label().fora("password_input").cls("form_label").f().w("Password").clabel()
		b.input_password("password", "", "*******", "form-control", "password_input")
		b.cdiv()

		b.div("form-group")
		b.label().fora("password_check_input").cls("form_label").f().w("Password again").clabel()
		b.input_password("password_check", "", "*******", "form-control", "password_check_input")
		b.cdiv()
		
		b.button().type("submit").cls("btn btn-outline-primary mt-3").f().w("Register").cbutton()

		b.cform()

	b.cdiv()
	
	b.div("col-2")
	b.cdiv()
	b.cdiv()
	
	
	b.write_tag()
	request.body += b.result
	request.compile_and_send_body()


func _on_Register_user_registered(request: WebServerRequest, user: User) -> void:
	user.read_lock()
	var uid : int = user.user_id
	user.read_unlock()
	
	user.write_lock()
	user.rank = 1
	user.write_unlock()
	user.save()
	
#	if uid == 1:
#		user.write_lock()
#		user.rank = 3
#		user.write_unlock()
#		user.save()
#	else:
#		var ulevel : int = ProjectSettings.get("app/registration_start_user_level")
#		user.write_lock()
#		user.rank = ulevel
#		user.write_unlock()
#		user.save()

func _ready() -> void:
	_registration_validator = FormValidator.new()
	
	_registration_validator.new_field("username", "Username").need_to_exist().need_to_be_alpha_numeric().need_minimum_length(5).need_maximum_length(20);
	_registration_validator.new_field("email", "Email").need_to_exist().need_to_be_email();

	var pw : FormField = _registration_validator.new_field("password", "Password");
	pw.need_to_exist();
	pw.need_to_have_lowercase_character().need_to_have_uppercase_character();
	pw.need_minimum_length(5);

	_registration_validator.new_field("password_check", "Password check").need_to_match("password");

	_registration_validator.new_field("email", "Email").need_to_exist().need_to_be_email();

