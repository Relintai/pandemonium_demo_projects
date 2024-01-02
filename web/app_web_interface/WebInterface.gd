extends WebNode

export(NodePath) var target_node : NodePath 

func _handle_request(request: WebServerRequest) -> void:
	if request.get_method() == HTTPServerEnums.HTTP_METHOD_POST:
		var cs : String = request.get_post_parameter("bg_color")
		
		if cs.is_valid_html_color():
			var c : Color = Color(cs)
			get_node(target_node).set_color(c)
	
	var color : Color = get_node(target_node).get_color()
	
	var b : HTMLBuilder = HTMLBuilder.new()
	
	b.style()
	b.w("body { background-color: #%s; }" % [ color.to_html(false) ])
	b.w(".content {")
	b.w("width: 200px;")
	b.w("margin-left: auto;")
	b.w("margin-right: auto;")
	b.w("text-align: center;")
	b.w("margin-top: 360px;")
	b.w("background-color: white;")
	b.w("padding: 10px;")
	b.w("}")
	b.cstyle()
	
	b.write_tag()
	
	request.head += b.result
	
	b.result = ""
	
	b.div("content")
	
	b.a("/").f().w("Refresh").ca()
	b.br()
	b.br()
	
	b.form_post("/")
	
	if true: # Scope for better separation
		b.label().fora("bg_color")
		b.w("Set BG Color ")
		b.clabel()
		
		b.input_color("bg_color", "#" + color.to_html(false), "", "bg_color")
		b.br()
		b.br()
		b.input_submit("Set")
	
	b.cform()
	
	b.cdiv()
	
	b.write_tag()
	
	request.body += b.result
	
	request.compile_and_send_body()
	
