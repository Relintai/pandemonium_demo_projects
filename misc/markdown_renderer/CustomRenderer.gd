extends TextEdit


func _ready():
	var f : File = File.new()
	
	var mdr : CustomMarkdownRenderer = CustomMarkdownRenderer.new()
	mdr.render_type = MarkdownRenderer.RENDERER_TYPE_CUSTOM
	
	f.open("res://TEST.md", File.READ)

	text = mdr.render(f.get_as_text())
	
	f.close()
