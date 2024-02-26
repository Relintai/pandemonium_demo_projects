extends UserSettingsWebPage

export(HTMLTemplate) var template : HTMLTemplate

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

	request.body += template.render(request, data)
	request.compile_and_send_body()

func _ready() -> void:
	_profile_validator = FormValidator.new()

	var pw : FormField = _profile_validator.new_field("password", "Password");
	pw.ignore_if_not_exists();
	pw.need_to_have_lowercase_character().need_to_have_uppercase_character();
	pw.need_minimum_length(5);

	_profile_validator.new_field("password_check", "Password check").ignore_if_other_field_not_exists("password").need_to_match("password");
