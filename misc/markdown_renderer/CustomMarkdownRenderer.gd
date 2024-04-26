extends MarkdownRenderer
class_name CustomMarkdownRenderer

var count : int = 0

func _renderer_callback(data: MarkdownRendererCustomRendererCallback) -> void:
	data.result = str(count) + "\n"
	data.result += "callback_type:" + str(data.callback_type) + "\n"
	data.result += "text:" + data.text + "\n"
	data.result += "content:" + data.content + "\n"
	data.result += "level:" + str(data.level) + "\n"
	data.result += "list_flags:" + str(data.list_flags) + "\n"
	data.result += "table_flags:" + str(data.table_flags) + "\n"
	data.result += "link:" + data.link + "\n"
	data.result += "auto_link_type:" + str(data.auto_link_type) + "\n"
	data.result += "title:" + data.title + "\n"
	data.result += "alt:" + data.alt + "\n"
	data.result += "num:" + str(data.num) + "\n"
	data.result += "display_mode:" + str(data.display_mode) + "\n"
	data.result += "inline_render:" + str(data.inline_render) + "\n"
	data.result += "\n\n"
	
	count += 1
