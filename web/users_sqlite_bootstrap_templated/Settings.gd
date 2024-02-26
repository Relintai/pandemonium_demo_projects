extends UserSettingsWebPage

class SettingsRequestData:
		var error_str : String = ""
		var pass_val : String = ""
		var pass_check_val : String = ""

var _profile_validator : FormValidator = null

func _render_index(request : WebServerRequest) -> void:
	var user : User = request.get_meta("user");

	if !user:
		PLogger.log_error("UserSettingsWebPage _render_index !user")
		return

	var data : SettingsRequestData = SettingsRequestData.new()

	if request.get_method() == HTTPServerEnums.HTTP_METHOD_POST:
		data.pass_val = request.get_parameter("password");
		data.pass_check_val = request.get_parameter("password_check");

		var changed : bool = false;

		var errors : PoolStringArray = _profile_validator.validate(request);

		for i in range(errors.size()):
			data.error_str += errors[i] + "<br>";

		if (errors.size() == 0):
			if (data.pass_val != ""):
				if (data.pass_val != data.pass_check_val):
					data.error_str += "The passwords did not match!<br>";
				else:
					user.create_password(data.pass_val);

					changed = true;

			if (changed):
				user.save();
				emit_signal("user_settings_changed", request, user);

	var d : Dictionary = Dictionary()

	d["user"] = user;
	d["error_str"] = data.error_str;
	d["pass_val"] = data.pass_val;
	d["pass_check_val"] = data.pass_check_val;

	_render_user_page(request, d);

func _render_user_page(request: WebServerRequest, data: Dictionary) -> void:
	#print(data)
	
	var user : User = data["user"]
	
	var b : HTMLBuilder = HTMLBuilder.new()
	
	# Title
	b.div("row mb-4")
	b.div("col-2")
	b.cdiv()
		
	b.div("col-8")
	
	b.h2()
	b.w("User Settings")
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
		
	if error_str.empty() && request.get_method() == HTTPServerEnums.HTTP_METHOD_POST:
		b.div("row mb-4")
		b.div("col-2")
		b.cdiv()
			
		b.div("col-8")
		b.div("alert alert-success").attrib("role", "alert")
		b.w("Save successful!")
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
		b.label().fora("password_input").cls("form_label").f().w("New Password").clabel()
		b.input_password("password", "", "*******", "form-control", "password_input")
		b.cdiv()

		b.div("form-group")
		b.label().fora("password_check_input").cls("form_label").f().w("New Password again").clabel()
		b.input_password("password_check", "", "*******", "form-control", "password_check_input")
		b.cdiv()
		
		b.button().type("submit").cls("btn btn-outline-primary mt-3").f().w("Save").cbutton()

		b.cform()

	b.cdiv()
	
	b.div("col-2")
	b.cdiv()
	b.cdiv()
	
	
	b.write_tag()
	request.body += b.result
	request.compile_and_send_body()

func _ready() -> void:
	_profile_validator = FormValidator.new()

	var pw : FormField = _profile_validator.new_field("password", "Password");
	pw.ignore_if_not_exists();
	pw.need_to_have_lowercase_character().need_to_have_uppercase_character();
	pw.need_minimum_length(5);

	_profile_validator.new_field("password_check", "Password check").ignore_if_other_field_not_exists("password").need_to_match("password");
