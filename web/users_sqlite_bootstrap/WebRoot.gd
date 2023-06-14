extends WebRoot

var header : String
var footer : String

func _ready() -> void:
	var b : HTMLBuilder = HTMLBuilder.new()
	
	b.meta().charset_utf_8()
	b.meta().attrib("name", "viewport").attrib("content", "width=device-width, initial-scale=1, shrink-to-fit=no")
	b.link().rel("stylesheet").type("text/css").href("/css/bootstrap.min.css")
	b.link().rel("stylesheet").type("text/css").href("/css/main.css")
	
	b.write_tag()
	
	header = b.result
	
	b.result = ""
	
	b.cdiv()
	b.ctag("main")
	b.script().src("/js/jquery-3.3.1.js").f().cscript()
	b.script().src("/js/popper.js").f().cscript()
	b.script().src("/js/bootstrap.min.js").f().cscript()
	b.write_tag()
	
	footer = b.result

func _render_main_menu(request: WebServerRequest) -> void:
	request.head = header
	
	var user : User = request.get_meta("user", null)
	
	var b : HTMLBuilder = HTMLBuilder.new()
	
	b.nav().cls("navbar navbar-expand-lg navbar-light bg-light")
	
	if true:
		b.a("/", "navbar-brand").f().w("USTB").ca()
		
		b.button().cls("navbar-toggler").type("button").attrib("data-toggle", "collapse").attrib("data-target", "#navbarSupportedContent").attrib("aria-controls", "navbarSupportedContent").attrib("aria-expanded", "false").attrib("aria-label", "Toggle navigation")
		b.span().cls("navbar-toggler-icon").f().cspan()
		b.cbutton()
		
		b.div("collapse navbar-collapse", "navbarSupportedContent")
		
		b.ul().cls("navbar-nav mr-auto")
		if true:
			b.li().cls("nav-item")
			b.a("/", "nav-link").f().w("Index").ca()
			b.cli()
			
			if user:
				b.li().cls("nav-item")
				b.a("/user/settings", "nav-link").f().w("User Settings").ca()
				b.cli()
				
				b.li().cls("nav-item")
				b.a("/user/logout", "nav-link").f().w("Logout").ca()
				b.cli()
				
				b.li().cls("nav-item")
				#b.a("/user/settings", "nav-link").f().w("(Logged in as " + user.user_name + ")!").ca()
				b.a("", "nav-link").f().w("Logged in as: " + user.user_name + "!").ca()
				b.cli()
				
			else:
				b.li().cls("nav-item")
				b.a("/user/login", "nav-link").f().w("Login").ca()
				b.cli()
				
				b.li().cls("nav-item")
				b.a("/user/register", "nav-link").f().w("Register").ca()
				b.cli()
				
		b.cul()

		b.cdiv()
	
	b.cnav()

	b.tag("main").cls("mt-5")
	
	b.div("container-fluid")

	b.write_tag()
	request.body += b.result
	
	request.footer = footer
