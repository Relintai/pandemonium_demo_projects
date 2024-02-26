extends WebRoot

export(HTMLTemplate) var template : HTMLTemplate

var header : String
var footer : String

func _ready() -> void:
	header = template.render(null, { "type": "header" })
	footer = template.render(null, { "type": "footer" })

func _render_main_menu(request: WebServerRequest) -> void:
	request.head = header
	request.body += template.render(request, { "type": "menu" })
	request.footer = footer
